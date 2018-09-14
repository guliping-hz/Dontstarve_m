local function StartTransform(inst)
	inst.components.transformer.queuedTransform = false
	inst.components.transformer:StartTransform()
end

local function StartRevert(inst)
	inst.components.transformer.queuedRevert = false
	inst.components.transformer:StartRevert()
end

local Transformer = Class(function(self, inst)
	
	self.inst = inst

	self.transformPrefab = "rabbit"

	self.objectData = nil

	self.transformEvent = nil
	self.transformEventTarget = nil

	self.revertEvent = nil
	self.revertEventTarget = nil

	self.onTransform = nil
	self.onRevert = nil

	self.transformed = false

	self.transformOffScreen = true

	self.queuedTransform = false
	self.queuedRevert = false

end)

function Transformer:GetDebugString()
	return tostring(self.transformed)
end

function Transformer:SetOnTransformFn(fn)
	self.onTransform = fn
end

function Transformer:SetOnRevertFn(fn)
	self.onRevert = fn
end

function Transformer:SetObjectData(data)
	self.objectData = data
end

function Transformer:GetObjectData()
	local c_data = {}
	local p_data = {}

	for k,v in pairs(self.inst.components) do
		if v.OnSave then
			local t, refs = v:OnSave()
			if t then
				c_data[k] = t
			end
		end
	end

	if self.inst.OnSave then
		self.inst.OnSave(self.inst, p_data)
	end

	self.objectData = {
		prefab = self.inst.prefab,
		component_data = c_data,
		prefab_data = p_data,
	}
end

function Transformer:RemoveSleepEvents()
	if self.sleepRevertEvent then
		self.inst:RemoveEventCallback("entitysleep", StartRevert)
		self.sleepRevertEvent = nil
	end

	if self.sleepTransformEvent then
		self.inst:RemoveEventCallback("entitysleep", StartTransform)
		self.sleepTransformEvent = nil
	end

	self.queuedRevert = false
	self.queuedTransform = false
end

function Transformer:SetRevertEvent(event, target)
    self.inst:DoTaskInTime(.1, function()
		if self.revertEventFn then return end
	
		self.revertEvent = event
		self.revertEventTarget = target or nil

		self.revertEventFn = function() self:StartRevert() end
		self.inst:ListenForEvent(self.revertEvent, function() self:StartRevert() end, self.revertEventTarget or GetWorld())
	end)
end

function Transformer:SetTransformEvent(event, target)
    self.inst:DoTaskInTime(.1, function()
		if self.transformEventFn then return end

		self.transformEvent = event
		self.transformEventTarget = target or nil

		self.transformEventFn = function()self:StartTransform() end
		self.inst:ListenForEvent(self.transformEvent, self.transformEventFn, self.transformEventTarget or GetWorld())
	end)
end

function Transformer:SetOnLoadCheck(check)
	self.onLoadCheck = check
end

function Transformer:Transform()
	self.inst:DoTaskInTime(math.random(), function() 
		local transformedPrefab = SpawnPrefab(self.transformPrefab)
		transformedPrefab.Transform:SetPosition(self.inst:GetPosition():Get())

		if not transformedPrefab.components.transformer then
			transformedPrefab:AddComponentAtRuntime("transformer")
		end

		if self.revertEvent then
			transformedPrefab.components.transformer:SetRevertEvent(self.revertEvent, self.revertEventTarget)
		end

		if self.onLoadCheck then
			transformedPrefab.components.transformer:SetOnLoadCheck(self.onLoadCheck)
		end

		transformedPrefab.components.transformer:SetObjectData(self.objectData)
		transformedPrefab.components.transformer.transformed = true
		transformedPrefab.components.transformer.transformOffScreen = self.transformOffScreen

		self.inst:Remove()
	end)
end

function Transformer:TransformOnSleep()
	self.queuedTransform = true
	self.sleepTransformEvent = self.inst:ListenForEvent("entitysleep", StartTransform)
end

function Transformer:StartTransform()
	self:RemoveSleepEvents()

	if not self.transformed then
		if (self.transformOffScreen and self.inst:IsAsleep()) or not self.transformOffScreen then
			self:GetObjectData()
			self:Transform()
		else
			self:TransformOnSleep()
		end
	end
end

function Transformer:Revert()
	self.inst:DoTaskInTime(math.random(), function() 
		local obj = SpawnPrefab(self.objectData.prefab)
		if obj then
			obj.Transform:SetPosition(self.inst:GetPosition():Get())
			for k,v in pairs(self.objectData.component_data) do
				local cmp = obj.components[k]
				if cmp and cmp.OnLoad then
					cmp:OnLoad(v)
				end
			end

			if obj.OnLoad then
				obj.OnLoad(obj, self.objectData.item_data)
			end

			self.inst:Remove()
		end
	end)
end

function Transformer:RevertOnSleep()
	self.queuedRevert = true
	self.sleepRevertEvent = self.inst:ListenForEvent("entitysleep", StartRevert)	
end

function Transformer:StartRevert()
	self:RemoveSleepEvents()

	if self.transformed then
		if (self.transformOffScreen and self.inst:IsAsleep()) or not self.transformOffScreen then
			self:Revert()
		else
			self:RevertOnSleep()
		end
	end
end

function Transformer:OnSave()
	local data = {}
	local refs = {}

	data.queuedTransform = self.queuedTransform
	data.queuedRevert = self.queuedRevert

	data.transformPrefab = self.transformPrefab
	data.transformed = self.transformed
	data.objectData = self.objectData or nil

	data.transformEvent = self.transformEvent
	data.revertEvent = self.revertEvent

	data.onLoadCheck = self.onLoadCheck
	
	if self.transformEventTarget then
		data.transformEventTarget = self.transformEventTarget.GUID
		table.insert(refs, self.transformEventTarget.GUID)
	end

	if self.revertEventTarget then
		data.revertEventTarget = self.revertEventTarget.GUID
		table.insert(refs, self.revertEventTarget.GUID)
	end

	return data, refs
end

function Transformer:OnLoad(data)
	if data then
		self.transformPrefab = data.transformPrefab
		self.objectData = data.objectData
		self.transformed = data.transformed
		self.transformEvent = data.transformEvent
		self.revertEvent = data.revertEvent
		self.onLoadCheck = data.onLoadCheck

		if data.queuedRevert then
			self:RevertOnSleep()
		end

		if data.queuedTransform then
			self:TransformOnSleep()
		end
	end
end

function Transformer:LoadPostPass(ents, data)
	self.inst:DoTaskInTime(0, function(inst)
		if inst.components.transformer.onLoadCheck ~= nil then
			if inst.components.transformer.onLoadCheck() and not inst.components.transformer.transformed then
				inst.components.transformer:GetObjectData()
				inst.components.transformer:Transform()
			elseif not inst.components.transformer.onLoadCheck() and inst.components.transformer.transformed then
				inst.components.transformer:Revert()
			end
		end
	end)

	if self.transformEvent then
		if data.transformEventTarget then
			local tar = ents[data.transformEventTarget]
			if tar then
				tar = tar.entity
				self:SetTransformEvent(self.transformEvent, tar)
			end
		else
			self:SetTransformEvent(self.transformEvent)
		end
	end

	if self.revertEvent then
		if data.revertEventTarget then
			local tar = ents[data.revertEventTarget]
			if tar then
				tar = tar.entity
				self:SetRevertEvent(self.revertEvent, tar)
			end
		else
			self:SetRevertEvent(self.revertEvent)
		end
	end

end

return Transformer