--Guardians are summoned by other creatures (see mossling & moose)

local Guardian = Class(function(self, inst)
	self.inst = inst
	self.prefab = nil
	self.guardian = nil
	self.onsummonfn = nil
	self.onguardiandeathfn = nil

	--When summons >= threshold, spawn prefab
	self.threshold = 20
	self.summons = 0

	self.decaytime = 20
end)

function Guardian:DoDelta(d)
	
	local old = self.summons

	self.summons = self.summons + d
	self.summons = math.clamp(self.summons, 0, self.threshold)

	self.inst:PushEvent("summonsdelta", {old = old, new = self.summons})
	
	self:StartDecay()
	
	if not self.guardian and self:SummonsAtMax() then
		self:SummonGuardian()
	elseif self.guardian and self:SummonsAtMin() then
		self:DismissGuardian()
	end
end

function Guardian:SummonsAtMax()
	return self.summons >= self.threshold
end

function Guardian:SummonsAtMin()
	return self.summons <= 0
end

function Guardian:Call(d)
	self:DoDelta(d or 1)
end

function Guardian:Decay(d)
	self:DoDelta(d or -1)
end

function Guardian:StartDecay()
	if self.decaytask then
		self.decaytask:Cancel()
		self.decaytask = nil
	end
	if self.summons > 0 then
		self.decaytask = self.inst:DoTaskInTime(self.decaytime, function() self:Decay() end)
	end
end

function Guardian:SummonGuardian(override)
	if not self.prefab then
		print("No prefab set in Guardian component!")
		return
	end

	if override then
		self.guardian = override
	end

	--Look for a prefab of this type already in the world.
	local guard = FindEntity(self.inst, 30, function(ent) return ent.prefab == self.prefab end)
	if not self.guardian and guard then
		print("Found Guardian")
		self.guardian = guard
	end

	if not self.guardian then
		local pt = self.inst:GetPosition()
		self.guardian = SpawnPrefab(self.prefab)
		self.guardian.Transform:SetPosition(pt:Get())

		if self.onsummonfn then
			self.onsummonfn(self.inst, self.guardian)
		end
	end

	self.inst:ListenForEvent("death", function(inst, data) self:OnGuardianDeath(data) end, self.guardian)
end

function Guardian:OnGuardianDeath(data)
	if self.onguardiandeathfn then
		local cause = data and data.cause or nil
		self.onguardiandeathfn(self.inst, self.guardian, cause)
	end
	self.guardian = nil
end

function Guardian:DismissGuardian()
	if not self.guardian then
		return
	end
	print("dismiss guardian")
	if self.ondismissfn then
		self.ondismissfn(self.inst, self.guardian)
	else
		self.guardian:Remove()
	end

	self.guardian = nil	
end

function Guardian:HasGuardian()
	return self.guardian ~= nil
end

function Guardian:OnSave()
	local data = {}
	local refs = {}

	data.summons = self.summons

	if self.guardian then
		data.guardian = self.guardian.GUID
		table.insert(refs, self.guardian.GUID)
	end

	return data, refs
end

function Guardian:OnLoad(data)
	if data and data.summons then
		self.summons = data.summons
		self:StartDecay()
	end
end

function Guardian:LoadPostPass(ents, data)
	if data.guardian then
		local guard = ents[data.guardian]
		if guard then
			guard = guard.entity
			self:SummonGuardian(guard)
		end
	end
end

return Guardian