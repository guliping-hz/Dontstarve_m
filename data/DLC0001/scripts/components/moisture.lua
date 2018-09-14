local easing = require("easing")
local Moisture = Class(function(self, inst)
    self.inst = inst

    self.moistureclamp = {min = 0, max = 100}
    self.moisture = 0
    self.numSegs = 5
    self.baseDryingRate = 0

    self.maxDryingRate = 0.1
    self.minDryingRate = 0

    self.maxPlayerTempDrying = 5
    self.minPlayerTempDrying = 0

    self.maxMoistureRate = .75
    self.minMoistureRate = 0

    self.optimalDryingTemp = 50

    self.delta = 0

    self.sheltered = false
    self.new_sheltered = false
    self.prev_sheltered = false
    self.shelter_waterproofness = TUNING.WATERPROOFNESS_SMALLMED

	self.inst:StartUpdatingComponent(self)

	self.inst:DoPeriodicTask(0.5, function() self:CheckForShelter() end)
end)

function Moisture:CheckForShelter()
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 3, {"shelter"}, {"FX", "NOCLICK", "DECOR", "INLIMBO", "stump", "burnt"})
	if #ents > 0 then
		-- Check if have been sheltered before we set sheltered/prev_sheltered to true so that we are only doing the announce after having been under shelter for a couple updates
		if self.new_sheltered and self.prev_sheltered then
			self.sheltered = true
			self.inst:PushEvent("sheltered") -- Set sheltered to true in temperature
			if (not self.lastannouncetime or (GetTime() - self.lastannouncetime > TUNING.TOTAL_DAY_TIME)) and
				GetSeasonManager() and (GetSeasonManager():IsRaining() or GetSeasonManager():GetCurrentTemperature() >= TUNING.OVERHEAT_TEMP - 5) then
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_SHELTER"))
				self.lastannouncetime = GetTime()
			end
		end
		if self.new_sheltered then self.prev_sheltered = true end -- Have we been sheltered for an update?
		self.new_sheltered = true
	else
		self.sheltered = false
		self.prev_sheltered = false
		self.new_sheltered = false
		self.inst:PushEvent("unsheltered")
	end

	local soundShouldPlay = GetSeasonManager() and GetSeasonManager():IsRaining() and self.sheltered
    if soundShouldPlay ~= self.inst.SoundEmitter:PlayingSound("treerainsound") then
        if soundShouldPlay then
		    self.inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/rain_on_tree", "treerainsound") 
        else
		    self.inst.SoundEmitter:KillSound("treerainsound")
		end
    end
end

function Moisture:GetDebugString()

	local temp = self.inst.components.temperature
	local sm = GetWorld().components.seasonmanager
	local rate = self.baseDryingRate

	return string.format("\n\t\tMoisture Rate: %2.2f -- %2.2f\n\t\tDrying Rate: %2.2f\n\t\tMoisture: %2.2f\n\t\tCombinedRate: %2.2f\n\t\t %2.2f, %2.2f, %2.2f ", 
		self:GetMoistureRate(), GetWorld().components.seasonmanager.precip_rate,
		self:GetDryingRate(), 
		self:GetMoisture(),
		self:GetMoistureRate() - self:GetDryingRate(),
		easing.linear(sm:GetCurrentTemperature(), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp),
		easing.inExpo(temp:GetCurrent(), self.minPlayerTempDrying, self.maxPlayerTempDrying, self.optimalDryingTemp),
		easing.inExpo(self:GetMoisture() , 0, 1, self.moistureclamp.max))
end

function Moisture:AnnounceMoisture(oldSegs, newSegs)
	if oldSegs < 1 and newSegs >= 1 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_DAMP"))
	elseif oldSegs < 2 and newSegs >= 2 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_WET"))
	elseif oldSegs < 3 and newSegs >= 3 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_WETTER"))
	elseif oldSegs < 4 and newSegs >= 4 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_SOAKED"))
	end
end

function Moisture:DoDelta(num)
	local currentLevel = self:GetMoisture()
	local oldSegs = self:GetSegs()
	self:SetMoistureLevel(self.moisture + num)
	local newSegs = self:GetSegs()
	self:AnnounceMoisture(oldSegs, newSegs)
	self.inst:PushEvent("moisturechange", {old = currentLevel, new = self.moisture})
end

function Moisture:SetMoistureLevel(num)
	self.moisture = math.clamp(num, self.moistureclamp.min, self.moistureclamp.max)
end

function Moisture:GetMoisture()
	return self.moisture
end

function Moisture:GetMoisturePercent()
	return self.moisture / self.moistureclamp.max
end

function Moisture:GetSegs()
	local perNotch = self.moistureclamp.max/self.numSegs
	local num = self.moisture/perNotch

	local full = math.ceil(num - 1)
	full = math.max(full, 0)
	local empty = num - full

	--Full is the number of full drops for UI, empty is the alpha value of the currently filling drop.
	--if num is 4.5 then full is 4 & empty is 0.5
	return full, empty
end

function Moisture:GetMoistureRate()
	local seasonmgr = GetSeasonManager()
	
	if seasonmgr and not seasonmgr:IsRaining() then
		return 0
	end

	local precip = seasonmgr.precip_rate	
	if seasonmgr and seasonmgr:IsSpring() and seasonmgr.incaves then
		precip = precip * TUNING.CAVES_MOISTURE_MULT
	end

	local rate = easing.inSine(precip, self.minMoistureRate, self.maxMoistureRate, 1)

	if self.inst.components.inventory:IsWaterproof() then
		rate = 0
	else
		if self.sheltered then
			rate = rate * (1 - (self.inst.components.inventory:GetWaterproofness() + self.shelter_waterproofness))
		else
			rate = rate * (1 - self.inst.components.inventory:GetWaterproofness())
		end
	end

	return rate
end

function Moisture:GetEquippedMoistureRate()
	local rate = 0
	local max = 0

	if self.inst.components.inventory then
		rate, max = self.inst.components.inventory:GetEquippedMoistureRate()
	end

	-- If rate and max are nonzero (i.e. wearing a moisturizing equipment) and the drying rate is less than
	-- the moisture rate of the equipment AND we're at max moisture for the equipment, set the two rates equal.
	-- This will prevent the arrow flickering as well as hold the moisture steady at max level
	if rate ~= 0 and max ~= 0 and self.moisture >= max and self:GetDryingRate() <= rate then
		rate = self:GetDryingRate()
	end

	if math.abs(rate) <= 0.01 then rate = 0 end

	return rate
end

function Moisture:GetDryingRate()

	local temp = self.inst.components.temperature
	local sm = GetWorld().components.seasonmanager
	local rate = self.baseDryingRate

	local heaterPower = 0
	
	local x,y,z = self.inst:GetPosition():Get()
	local ZERO_DISTANCE = 10
	local ZERO_DISTSQ = ZERO_DISTANCE*ZERO_DISTANCE
	local ents = TheSim:FindEntities(x,y,z, ZERO_DISTANCE, {"HASHEATER"})

    for k,v in pairs(ents) do 
		if v.components.heater and not v.components.heater.iscooler and v ~= self.inst and not v:IsInLimbo() then
			local heat = v.components.heater:GetHeat(self.inst)
			local distsq = self.inst:GetDistanceSqToInst(v)

			-- This produces a gentle falloff from 1 to zero.
			local heatfactor = ((-1/ZERO_DISTSQ)*distsq) + 1
			local mm = GetWorld().components.moisturemanager
	        if mm and ((not mm:IsEntityDry(self.inst)) or (mm:IsWorldWet() and not GetPlayer().components.inventory:IsWaterproof())) then
	            heatfactor = heatfactor * TUNING.WET_HEAT_FACTOR_PENALTY
	        end

	        heaterPower = heaterPower + heatfactor
		end
    end
    
    heaterPower = math.clamp(heaterPower, 0, 1)

    if self:GetSegs() >= 3 then
		rate = rate + easing.linear(heaterPower, self.minPlayerTempDrying, 5, 1)
	else
		rate = rate + easing.linear(heaterPower, self.minPlayerTempDrying, 2, 1)
	end

	--Look @ player temp too

	rate = rate + easing.linear(sm:GetCurrentTemperature(), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp)
	rate = rate + easing.inExpo(self:GetMoisture() , 0, 1, self.moistureclamp.max)
	rate = math.clamp(rate, 0, self.maxDryingRate + self.maxPlayerTempDrying)


	-- Don't dry if it's raining
	if self:GetMoistureRate() > 0 then
		rate = 0
	end

	return rate
end

function Moisture:GetDelta()
	return self.delta
end

function Moisture:OnUpdate(dt)
	local drying_rate = -self:GetDryingRate()
	local moisture_rate = self:GetMoistureRate() + self:GetEquippedMoistureRate()
	self.delta = (moisture_rate + drying_rate)
	
	self:DoDelta(self.delta * dt)
end

function Moisture:LongUpdate(dt)
	self:OnUpdate(dt)
end

function Moisture:OnSave()
	local data = {}
	data.moisture = self.moisture
	return data
end

function Moisture:OnLoad(data)
	if data then
		self.moisture = data.moisture
	end
end

return Moisture