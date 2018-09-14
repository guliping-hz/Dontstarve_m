
local Resurrectable = Class(function(self, inst)
    self.inst = inst
end)

function Resurrectable:FindClosestResurrector()
	local res = nil
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			return item
		end
	end

	local closest_dist = 0
	for k,v in pairs(Ents) do
		if v.components.resurrector and v.components.resurrector:CanBeUsed() then
			local dist = v:GetDistanceSqToInst(self.inst)
			if not res or dist < closest_dist then
				res = v
				closest_dist = dist
			end
		end
	end

	return res
end

function Resurrectable:CanResurrect()
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			return true
		end
	end

	local res = false

	if SaveGameIndex:CanUseExternalResurector() then
		res = SaveGameIndex:GetResurrector() 
	end

	if res == nil or res == false then
		res = self:FindClosestResurrector()
	end

	if res then
		return true
	end

	return false
end

local function TrySpawnSkeleton(inst)
	if inst and inst.last_death_position then
		inst:DoTaskInTime(3, function(inst)
			local skel = SpawnPrefab("skeleton_player")
			if skel then
				skel.Transform:SetPosition(inst.last_death_position.x, inst.last_death_position.y, inst.last_death_position.z)
			end
			inst.last_death_position = nil
		end)
	end
end

function Resurrectable:DoResurrect()
    self.inst:PushEvent("resurrect")
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			self.inst.sg:GoToState("amulet_rebirth")
			TrySpawnSkeleton(self.inst)
			return true
		end
	end
	
	local res = self:FindClosestResurrector()
	if res and res.components.resurrector then
		res.components.resurrector:Resurrect(self.inst)
		TrySpawnSkeleton(self.inst)
		return true
	end

	return false
end

return Resurrectable
