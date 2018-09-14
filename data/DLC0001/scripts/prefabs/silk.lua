local assets=
{
	Asset("ANIM", "anim/silk.zip"),
}

local function CanUpgrade(inst, target, doer)
    return doer:HasTag("spiderwhisperer")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("silk")
    inst.AnimState:SetBuild("silk")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("upgrader")
    inst.components.upgrader.canupgradefn = CanUpgrade
    inst.components.upgrader.upgradetype = "SPIDER"
    
    
    return inst
end

return Prefab( "common/inventory/silk", fn, assets) 
