--Clean up this component. No longer is moisture manager, is WorldMoisture

local easing = require("easing")

local MoistureManager = Class(function(self, inst)
	self.inst = inst
	self.entities =	{}
	self.world_wet = false

    self.moistureclamp = {min = 0, max = 100}
    self.moisture = 0
    self.numSegs = 5
    self.baseDryingRate = 0

    self.maxDryingRate = 0.3
    self.minDryingRate = 0

    self.maxWorldMoistureRate = .75
    self.minWorldMoistureRate = 0

    self.optimalDryingTemp = 70

    self.worldDryLevel = TUNING.MOISTURE_DRY_THRESHOLD--30
    self.worldWetLevel = TUNING.MOISTURE_WET_THRESHOLD--70

	-- self.inst:ListenForEvent("rainstart", function() self:StartMakeWorldWet() end)
	-- self.inst:ListenForEvent("rainstop", function() self:StartMakeWorldDry() end)
	self.inst:ListenForEvent("worldmoisturechange", function(inst, data) self:CheckForChange(data) end)

	self.inst:StartUpdatingComponent(self)
end)

function MoistureManager:GetDebugString()
	return string.format("\n\t\tWorldMoisture Rate: %2.2f -- %2.2f\n\t\tDrying Rate: %2.2f\n\t\tWorldMoisture: %2.2f\n\t\tCombinedRate: %2.2f ", 
		self:GetWorldMoistureRate(), GetWorld().components.seasonmanager.precip_rate,
		self:GetDryingRate(), 
		self:GetWorldMoisture(),
		self:GetWorldMoistureRate() - self:GetDryingRate())
end

function MoistureManager:StartMakeWorldWet(time)
	self.task_start_time = GetTime()
	self.task_time = time or TUNING.WET_TIME
	self.inst:DoTaskInTime(time or TUNING.WET_TIME, function() self:MakeWorldWet() end)
end

function MoistureManager:StartMakeWorldDry(time)
	self.task_start_time = GetTime()
	self.task_time = time or TUNING.DRY_TIME
	self.inst:DoTaskInTime(time or TUNING.DRY_TIME, function() self:MakeWorldDry() end)
end

function MoistureManager:MakeWorldWet()
	self.world_wet = true
	self.inst:PushEvent("worldwet")
	self.task_time = nil
	for k,v in pairs(Ents) do
		if v and 
		v.components.inventoryitem and
		v.components.inventoryitem:IsSheltered() then
			self:MakeEntityDry(v)
		end
	end
end

function MoistureManager:MakeWorldDry()
	self.entities = {}
	self.inst:PushEvent("worlddry")
	self.task_time = nil
	self.world_wet = false
end

function MoistureManager:MakeEntityDry(inst)
	--print(inst, " is sheltered! Making dry.")
	self.entities[inst] = inst
end

function MoistureManager:MakeEntityWet(inst)
	if self.entities[inst] then
		--print(inst, " is not in dry list!")
		self.entities[inst] = nil
	end
end

function MoistureManager:IsEntityWet(inst)

	if inst.components.moisturelistener then
		return inst.components.moisturelistener:IsWet()
	end

	if inst.components.waterproofer then
		return false
	end

	if self:IsWorldWet() and not self.entities[inst] then
		return true
	end
end

function MoistureManager:IsEntityDry(inst)

	if inst.components.moisturelistener then
		return not inst.components.moisturelistener:IsWet()
	end

	--If inst isn't in here then it's wet
	if inst.components.waterproofer then
		return true
	end

	return self.entities[inst]
end

function MoistureManager:IsWorldWet()
	return self.world_wet
end

function MoistureManager:OnSave()
	local data = {}
	data.moisture = self.moisture
	data.world_wet = self.world_wet
	return data
end

function MoistureManager:OnLoad(data)
	if data then
		self.moisture = data.moisture
		self.world_wet = data.world_wet
	end
end

function MoistureManager:CheckForChange(data)
	if self:IsWorldWet() then
		if data.new < self.worldDryLevel then
			self:MakeWorldDry()
		end
	else
		if data.new > self.worldWetLevel then
			self:MakeWorldWet()
		end
	end
end

function MoistureManager:GetWorldMoisture()
	return self.moisture
end

function MoistureManager:DoDelta(num)
	local currentLevel = self:GetWorldMoisture()
	self:SetWorldMoistureLevel(self.moisture + num)
	self.inst:PushEvent("worldmoisturechange", {old = currentLevel, new = self.moisture})
end

function MoistureManager:SetWorldMoistureLevel(num)
	self.moisture = math.clamp(num, self.moistureclamp.min, self.moistureclamp.max)
end

function MoistureManager:GetWorldMoistureRate()
	local seasonmgr = GetSeasonManager()
	local precip = seasonmgr.precip_rate		
	if seasonmgr and not seasonmgr:IsRaining() then
		return 0
	end

	local rate = easing.inSine(precip, self.minWorldMoistureRate, self.maxWorldMoistureRate, 1)
	return rate
end

function MoistureManager:GetDryingRate()
	--Look @ player temp too
	local sm = self.inst.components.seasonmanager
	local rate = self.baseDryingRate
	local rate = rate + easing.linear(sm:GetCurrentTemperature(), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp) 
	--rate = math.clamp(rate, self.baseDryingRate, self.maxDryingRate)
	rate = rate + easing.inExpo(self:GetWorldMoisture() , 0, 1, self.moistureclamp.max)

	rate = math.clamp(rate, 0.01, 1)

	if self:GetWorldMoistureRate() > 0 then
		rate = 0
	end

	return rate
end

function MoistureManager:OnUpdate(dt)
	local moisture_rate = self:GetWorldMoistureRate()
	local drying_rate = -self:GetDryingRate()

	self:DoDelta((moisture_rate + drying_rate) * dt)
end

function MoistureManager:LongUpdate(dt)
	self:OnUpdate(dt)
end


return MoistureManager