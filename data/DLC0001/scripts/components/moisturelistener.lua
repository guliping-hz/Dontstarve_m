--Updated by "inventorymoisture" on the world.
--Updated in batches to avoid slowdown due to the amount of inventory items.
local updatePeriod = 5
local MoistureListener = Class(function(self, inst)
	self.inst = inst
	self.owner = nil

	self.moisture = 0

	self.wet = false

	self.dryingSpeed = -1
	self.dryingResistance = 1
	
	self.wetnessSpeed = 0.5
	self.wetnessResistance = 1

	self.lastUpdate = GetTime() or 0

	self.wetnessThreshold = TUNING.MOISTURE_WET_THRESHOLD
	self.drynessThreshold = TUNING.MOISTURE_DRY_THRESHOLD
	
	self.inst:DoTaskInTime(0, function() GetWorld().components.inventorymoisture:TrackItem(self.inst) end)
end)

function MoistureListener:OnSave()
	local data = {}
	data.moisture = self.moisture
	return data
end

function MoistureListener:OnLoad(data)
	if data then
		self.moisture = data.moisture
	end
end

function MoistureListener:GetDebugString()
	return string.format("Current Moisture: %2.2f, Target Moisture: %2.2f", self.moisture, self:GetTargetMoisture() or 0)
end

function MoistureListener:IsWet()
	return self.wet
end

function MoistureListener:Dilute(number, moisture)
	if self.inst.components.stackable then
		self.moisture = (self.inst.components.stackable.stacksize * self.moisture + number * moisture) / ( number + self.inst.components.stackable.stacksize )
	end
end

function MoistureListener:GetMoisture()
	return self.moisture
end

function MoistureListener:GetTargetMoisture()
	if (not GetWorld().components.seasonmanager:IsRaining() and not 
	(self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner)) or not 
	self.inst.components.inventoryitem then
		return 0
	end
	local owner = self.inst.components.inventoryitem.owner
	if owner then
		if owner.components.container then
			--All containers keep items dry.
			return 0
		elseif owner.components.inventory and owner.components.moisture then
			return owner.components.moisture:GetMoisture() 
		end
	else
		return GetWorld().components.moisturemanager:GetWorldMoisture()
	end
end

function MoistureListener:DoUpdate()
	self:UpdateMoisture(GetTime() - self.lastUpdate)
end

function MoistureListener:UpdateMoisture(dt)
	local targetMoisture = self:GetTargetMoisture() or 0

	local speed = 0
	if targetMoisture and targetMoisture > self.moisture then
		speed = self.wetnessSpeed * self.wetnessResistance
	else
		speed = self.dryingSpeed * self.dryingResistance
	end
	
	local difference = targetMoisture - self.moisture
	local delta = speed * dt

	if math.abs(difference) < math.abs(delta) then
		delta = difference
	end

	self.moisture = self.moisture + delta

	if self.moisture >= self.wetnessThreshold then
		self.wet = true
        self.inst:PushEvent("itemwet")
	elseif self.moisture < self.drynessThreshold then
		self.wet = false
        self.inst:PushEvent("itemdry")
	end

	self.lastUpdate = GetTime()
end


return MoistureListener