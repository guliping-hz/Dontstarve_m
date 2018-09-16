local assets=
{
	Asset("ANIM", "exportedanim/tent_cone.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tent_cone")
    inst.AnimState:SetBuild("tent_cone")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("scaryshadow")
    inst:DoTaskInTime(0, function()
        inst.components.scaryshadow:SpawnShadow(inst, 2.2)
    end)
    
    return inst
end

return Prefab( "common/inventory/tent_cone", fn, assets) 

