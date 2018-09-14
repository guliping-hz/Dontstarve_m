local assets=
{
	Asset("ANIM", "anim/coontail.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("coontail")
    inst.AnimState:SetBuild("coontail")
    inst.AnimState:PlayAnimation("idle")  
    
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inspectable")    
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddTag("cattoy")
        
	return inst
end

return Prefab("common/inventory/coontail", fn, assets)
