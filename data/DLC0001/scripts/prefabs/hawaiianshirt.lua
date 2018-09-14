local assets=
{
	Asset("ANIM", "anim/torso_hawaiian.zip"),
}

local function onperish(inst)
	inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_hawaiian", "swap_body")
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function create()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("hawaiian_shirt")
    inst.AnimState:SetBuild("torso_hawaiian")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.HAWAIIANSHIRT_PERISHTIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)
    inst:AddTag("show_spoilage")

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()
    
	return inst
end

return Prefab( "common/inventory/hawaiianshirt", create, assets)
		
