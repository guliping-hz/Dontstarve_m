
local camperspawners = {}
-- global
function SpawnCampers(amount)
	local remainingcampers = {}
	for i,v in ipairs(camperspawners) do
		table.insert( remainingcampers, v )
	end
	local campers_spawned = 0
	while #remainingcampers > 0 do
		local index, spawner = GetRandomItemWithIndex(remainingcampers)
		local camper = SpawnPrefab("camper")
		camper.Transform:SetPosition(spawner.Transform:GetWorldPosition())
		table.remove(remainingcampers, index)
		campers_spawned = campers_spawned + 1
		if campers_spawned == amount then
			break
		end
	end
end

local function makecamperspawn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

	table.insert(camperspawners, inst)

	return inst
end

return Prefab("camperspawn", makecamperspawn)
