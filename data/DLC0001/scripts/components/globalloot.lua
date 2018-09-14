local GlobalLoot = Class(function(self,inst)
	self.inst = inst
	self.loot = {}
	self.inst:ListenForEvent("entity_death", function(world, data) self:OnEntityDeath(data) end, GetWorld())
end)

function GlobalLoot:AddGlobalLoot(data)
	table.insert(self.loot, data)
end

function GlobalLoot:OnEntityDeath(data)
	for k,v in pairs(self.loot) do
		local canDrop = true

		if v.candropfn and not v.candropfn(data.inst, v.loot) then 
			canDrop = false 
		end

		if v.droppers and not table.contains(v.droppers, data.inst.prefab) then
			canDrop = false
		end

		if canDrop then
			if math.random() < v.dropchance then
				data.inst.components.lootdropper:SpawnLootPrefab(v.loot)
			end
		end
	end
end

return GlobalLoot