local assets=
{
	Asset("ANIM", "anim/lightning_goat_horn.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("lightning_goat_horn")
    inst.AnimState:SetBuild("lightning_goat_horn")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

	return inst
end

return Prefab( "common/inventory/lightninggoathorn", fn, assets) 
