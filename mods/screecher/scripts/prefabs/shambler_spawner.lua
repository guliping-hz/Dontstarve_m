assets = {
	--Asset("ANIM", "anim/rock.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
    --inst.Physics:ClearCollisionMask()

	inst:ListenForEvent("spawn_shambler", function()
		local shambler = SpawnPrefab("shambler")
		local scale = 1+math.random()/2
		shambler.Transform:SetScale(scale,scale,scale)
		shambler:AddTag("finale")
		local pos = inst:GetPosition()
		shambler.Transform:SetPosition(pos:Get())
		inst:DoTaskInTime(math.random()/2, function()
			shambler.components.shamblermodes:SetKind("killer")
		end)
	end, GetPlayer())
	return inst
end

return Prefab("shambler_spawner", fn, assets)
