local FlashlightWatcher = Class(function(self, inst)
	self.inst = inst

	self.makeflickeronlit = false
	self.currently_flashed = false

	self.inst.entity:AddLightWatcher() -- required by the flashlightwatcher

	inst:StartUpdatingComponent(self)
end)

function FlashlightWatcher:OnUpdate(dt)
	local player = GetPlayer()
	if player and self.inst then
		local flashlight_ent = player.FlashlightEnt()
		if flashlight_ent then
			local lightbm = flashlight_ent.components.lightbeam
			if lightbm then
				if lightbm:IsPointLit(self.inst:GetPosition()) then
					self:GetLit(flashlight_ent, dt)
				else
					self:GetUnlit(flashlight_ent, dt)
				end
			end
		end
	end
end

function FlashlightWatcher:GetLit(flashlight_ent, dt)
	if not self.currently_flashed then
		self.inst:PushEvent("flashed", {flashlight_ent=flashlight_ent, forceflicker=self.makeflickeronlit})
		self.currently_flashed = true
	end
	self.inst:PushEvent("lit", {flashlight_ent=flashlight_ent, dt=dt})
end

function FlashlightWatcher:GetUnlit(flashlight_ent, dt)
	if self.currently_flashed then
		self.inst:PushEvent("unlit", {flashlight_ent=flashlight_ent})
		self.currently_flashed = false
	end
end

function FlashlightWatcher:IsLit()
	return self.currently_flashed
end

function FlashlightWatcher:GetDebugString()
	return string.format("Lit: %s", tostring(self.currently_flashed))
end

return FlashlightWatcher
