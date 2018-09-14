local easing = require("easing")

local Temperature = Class(function(self, inst)
    self.inst = inst
	self.settemp = nil
	self.rate = 0
	self.current = TUNING.STARTING_TEMP
	self.maxtemp = TUNING.MAX_ENTITY_TEMP
	self.mintemp = TUNING.MIN_ENTITY_TEMP
	self.overheattemp = TUNING.OVERHEAT_TEMP
	self.hurtrate = TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME
	self.inherentinsulation = 0
	self.inherentsummerinsulation = 0
	self.shelterinsulation = TUNING.INSULATION_MED_LARGE

	--At max moisture, the player will feel cooler than at minimum
	self.maxmoisturepenalty = TUNING.MOISTURE_TEMP_PENALTY

	self:OnUpdate(0)

	self.last_real_delta = 0

	self.inst:ListenForEvent("sheltered", function()
		self.sheltered = true
	end)
	self.inst:ListenForEvent("unsheltered", function()
		self.sheltered = false
	end)
	
	self.inst:StartUpdatingComponent(self)
end)

function Temperature:DoDelta(delta)
	local old = self.current 
	self.current = self.current + delta
	self.inst:PushEvent("temperaturedelta", {last = old, new = self.current})
end

function Temperature:GetCurrent()
	return self.current 
end

function Temperature:GetMax()
	return self.maxtemp 
end

function Temperature:OnSave()
	return { current = self.current }
			 
end

function Temperature:SetTemp(temp)
	if temp then
		self.settemp = temp
		local old = self.current 
		self.current = temp
		self.inst:PushEvent("temperaturedelta", {last = old, new = self.current})		
	else
		self.settemp = nil
	end
end

function Temperature:OnProgress()
	self.current = 30
end


function Temperature:OnLoad(data)

	self.current = data.current or self.current
	self:OnUpdate(0)
	
end

function Temperature:SetTemperature(value)
	local last = self.current

	self.current = value

    if (self.current < 0) ~= (last < 0)  then
    	if self.current < 0 then
    		self.inst:PushEvent("startfreezing")
    	else
    		self.inst:PushEvent("stopfreezing")
    	end
    end

    if (self.current > self.overheattemp) ~= (last > self.overheattemp) then
    	if self.current > self.overheattemp then
    		self.inst:PushEvent("startoverheating")
    	else
    		self.inst:PushEvent("stopoverheating")
    	end
    end

	self.inst:PushEvent("temperaturedelta")

end

function Temperature:GetDebugString()
    return string.format("%2.2fC at %2.2f (delta: %2.2f)", self:GetCurrent(), self.rate, self.last_real_delta)
end

function Temperature:IsFreezing()
	return self.current < 0
end

function Temperature:IsOverheating()
	return self.current > self.overheattemp
end

function Temperature:GetInsulation()
	local winterInsulation = self.inherentinsulation
	local summerInsulation = self.inherentsummerinsulation

	if self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.insulator then
				local insulationValue, insulationType = v.components.insulator:GetInsulation()
				
				if insulationType == "WINTER" then
					winterInsulation = winterInsulation + insulationValue
				elseif insulationType == "SUMMER" then
					summerInsulation = summerInsulation + insulationValue
					if self.sheltered then
						summerInsulation = summerInsulation + self.shelterinsulation
					end
				else
					print(v, " has invalid insulation type: ", insulationType)
				end

			end
		end
	end
	
	if self.inst.components.beard then
		--Beards help winterInsulation but hurt summerInsulation
		winterInsulation = winterInsulation + self.inst.components.beard:GetInsulation()
		summerInsulation = summerInsulation - self.inst.components.beard:GetInsulation()
	end

	if GetWorld():IsCave() then
		summerInsulation = summerInsulation + TUNING.CAVE_INSULATION_BONUS
		winterInsulation = winterInsulation + TUNING.CAVE_INSULATION_BONUS
	end

	if GetClock():IsDusk() then
		summerInsulation = summerInsulation + TUNING.DUSK_INSULATION_BONUS
	elseif GetClock():IsNight() then
		summerInsulation = summerInsulation + TUNING.NIGHT_INSULATION_BONUS
	end

	if winterInsulation < 0 then winterInsulation = 0 end
	if summerInsulation < 0 then summerInsulation = 0 end
	return winterInsulation, summerInsulation
end

function Temperature:GetMoisturePenalty()
	local moisture = self.inst.components.moisture
	if not moisture then return 0 end
	return Lerp(0, self.maxmoisturepenalty, moisture:GetMoisture()/moisture.moistureclamp.max)
end

function Temperature:OnUpdate(dt, applyhealthdelta)
	
	if self.settemp then return end

	if applyhealthdelta == nil then
		applyhealthdelta = true
	end
	
	if (self.inst.components.health and self.inst.components.health.invincible == true) or self.inst.is_teleporting == true then
		return
	end

    local last = self.current

    local seasonmgr = GetSeasonManager()
	local ambient_delta = ((seasonmgr and seasonmgr:GetCurrentTemperature() or TUNING.STARTING_TEMP) - self.current) or 0

	ambient_delta = ambient_delta - self:GetMoisturePenalty()

	if seasonmgr and self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.heater then
				local heat = v.components.heater:GetEquippedHeat()
				if heat ~= nil and heat > self.current then
					ambient_delta = ambient_delta + (heat - self.current)
				elseif heat ~= nil and heat < self.current then
					ambient_delta = ambient_delta - (self.current - heat)
				end
			end
		end
		for k,v in pairs(self.inst.components.inventory.itemslots) do
			if v.components.heater then
				local carrieddelta = v.components.heater:GetCarriedHeat()
				if carrieddelta ~= nil then
					ambient_delta = ambient_delta + carrieddelta
				end
			end
		end
		if self.inst.components.inventory.overflow and self.inst.components.inventory.overflow.components.container then
			for k,v in pairs(self.inst.components.inventory.overflow.components.container.slots) do
				if v.components.heater then
					local carrieddelta = v.components.heater:GetCarriedHeat()
					if carrieddelta ~= nil then
						ambient_delta = ambient_delta + carrieddelta
					end
				end
			end
		end
		-- Recently eaten temperatured food is inherently equipped heat/cold
		if self.inst.recent_temperatured_food and self.inst.recent_temperatured_food ~= 0 then
			ambient_delta = ambient_delta + self.inst.recent_temperatured_food
		end
	end

	-- If very hot (basically only when have overheating screen effect showing) and under shelter, cool slightly
    if self.current > TUNING.TREE_SHADE_COOLING_THRESHOLD and self.sheltered then
		ambient_delta = ambient_delta - (self.current - TUNING.TREE_SHADE_COOLER)
	end

	--now figure out the temperature where we are standing
	local x,y,z = self.inst.Transform:GetWorldPosition()
	
	local ZERO_DISTANCE = 10
	local ZERO_DISTSQ = ZERO_DISTANCE*ZERO_DISTANCE

	local ents = TheSim:FindEntities(x,y,z, ZERO_DISTANCE, {"HASHEATER"})
	local area_heat = 0
	local num_area_heat_sources = 0
    for k,v in pairs(ents) do 
		if v.components.heater and v ~= self.inst and not v:IsInLimbo() then
			local heat = v.components.heater:GetHeat(self.inst)
			local distsq = self.inst:GetDistanceSqToInst(v)

			-- This produces a gentle falloff from 1 to zero.
			local heatfactor = ((-1/ZERO_DISTSQ)*distsq) + 1
			local mm = GetWorld().components.moisturemanager
	        if mm and ((not mm:IsEntityDry(self.inst)) or (mm:IsWorldWet() and not GetPlayer().components.inventory:IsWaterproof())) then
	            heatfactor = heatfactor * TUNING.WET_HEAT_FACTOR_PENALTY
	        end

			if heat*heatfactor > self.current then
				if heat > 0 then
					area_heat = area_heat + (heat*heatfactor - self.current)
					num_area_heat_sources = num_area_heat_sources + 1
				end
			elseif heat*heatfactor < self.current then
				if heat < 0 then
					area_heat = area_heat - (self.current - heat*heatfactor)
					num_area_heat_sources = num_area_heat_sources + 1
				end
			end
		end
    end	
    if num_area_heat_sources > 0 then
    	ambient_delta = ambient_delta + (area_heat / num_area_heat_sources)
    end
	
	local winterInsulation, summerInsulation = self:GetInsulation()

	local delta = ambient_delta
	self.last_real_delta = delta
	local freezeTime = TUNING.SEG_TIME + winterInsulation
	local overheatTime = TUNING.SEG_TIME + summerInsulation 
	-- local freeze_or_overheat_time = TUNING.SEG_TIME + total_insulation

	if seasonmgr then
		if self:IsCooling() and self:IsCool() then
			if seasonmgr:GetCurrentTemperature() >= TUNING.STARTING_TEMP then --cooling down, obj is cold, world is hot
				self.rate = math.max(delta, -TUNING.WARM_DEGREES_PER_SEC)
			else --cooling down, obj is cold, world is cold
				self.rate = math.max(delta, -TUNING.SEG_TIME / freezeTime) 
			end
		elseif self:IsWarming() and self:IsCool() then 
			if seasonmgr:GetCurrentTemperature() >= TUNING.STARTING_TEMP then --warming up, obj is cold and world is hot
				self.rate = math.min(delta, TUNING.SEG_TIME / overheatTime)
			else --warming up, obj is cold and world is cold
				self.rate = math.min(delta, self.current <= 0 and TUNING.THAW_DEGREES_PER_SEC or TUNING.WARM_DEGREES_PER_SEC)
			end
		elseif self:IsCooling() and self:IsWarm() then
			if seasonmgr:GetCurrentTemperature() >= TUNING.STARTING_TEMP then --cooling down, obj is warm and world is hot
				self.rate = math.max(delta, self.current >= self.overheattemp and -TUNING.THAW_DEGREES_PER_SEC or -TUNING.WARM_DEGREES_PER_SEC)
			else --cooling down, obj is warm and world is cold
				self.rate = math.max(delta, -TUNING.SEG_TIME / freezeTime)
			end
		elseif self:IsWarming() and self:IsWarm() then
			if seasonmgr:GetCurrentTemperature() >= TUNING.STARTING_TEMP then --warming up, obj is warm, world is hot
				self.rate = math.min(delta, TUNING.SEG_TIME / overheatTime)
			else --warming up, obj is warm, world is cold
				self.rate = math.min(delta, TUNING.WARM_DEGREES_PER_SEC)
			end
		else
			self.rate = 0
		end
	end

	if self.inst.components.inventoryitem and 
		self.inst.components.inventoryitem.owner and 
		self.inst.components.inventoryitem.owner:HasTag("fridge") and not
		self.inst.components.inventoryitem.owner:HasTag("nocool") and --For icepack.
		self.current > 0 then -- Don't cool it below freezing
		self.rate = -TUNING.WARM_DEGREES_PER_SEC
		if self.inst.components.inventoryitem.owner:HasTag("lowcool") then
			self.rate = self.rate * .5
		end
	end
		
	-- --Always get "slowest" rate. Max when cooling, Min when warming.
	-- if delta < 0 and self.current < TUNING.STARTING_TEMP then
	-- 	self.rate = math.max(delta, -TUNING.SEG_TIME / freeze_or_overheat_time)
	-- elseif delta > 0 and self.current < TUNING.STARTING_TEMP then	
	-- 	self.rate = math.min(delta, self.current <= 0 and TUNING.THAW_DEGREES_PER_SEC or TUNING.WARM_DEGREES_PER_SEC)
	-- elseif delta < 0 and self.current >= TUNING.STARTING_TEMP then
	-- 	self.rate = math.max(delta, self.current <= self.overheattemp and -TUNING.THAW_DEGREES_PER_SEC or -TUNING.WARM_DEGREES_PER_SEC)
	-- elseif delta > 0 and self.current >= TUNING.STARTING_TEMP then	
	-- 	self.rate = math.min(delta, TUNING.SEG_TIME / freeze_or_overheat_time)
	-- else
	-- 	self.rate = 0
	-- end
		
    self.current = math.max( math.min( self.current + self.rate*dt, self.maxtemp), self.mintemp)
	
    if (self.current < 0) ~= (last < 0)  then
    	if self.current < 0 then
    		self.inst:PushEvent("startfreezing")
    	else
    		self.inst:PushEvent("stopfreezing")
    	end
    end

    if (self.current > self.overheattemp) ~= (last > self.overheattemp) then
    	if self.current > self.overheattemp then
    		self.inst:PushEvent("startoverheating")
    	else
    		self.inst:PushEvent("stopoverheating")
    	end
    end

	self.inst:PushEvent("temperaturedelta")
	
	if applyhealthdelta and self.current < 0 and self.inst.components.health then
		self.inst.components.health:DoDelta(-self.hurtrate*dt, true, "cold") 
	elseif applyhealthdelta and self.current > self.overheattemp and self.inst.components.health then
		self.inst.components.health:DoDelta(-self.hurtrate*dt, true, "hot") 
	end
	
end

function Temperature:IsCooling()
	return self.last_real_delta < 0
end

function Temperature:IsWarming()
	return self.last_real_delta > 0
end

function Temperature:IsCool()
	return self.current < TUNING.STARTING_TEMP
end

function Temperature:IsWarm()
	return self.current >= TUNING.STARTING_TEMP
end

return Temperature
