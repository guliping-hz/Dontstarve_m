local assets = 
{
	Asset("ANIM", "anim/fertilizer.zip")
}

local prefabs = 
{

}

local function OnFinished(inst)
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("fertilizer")
    inst.AnimState:SetBuild("fertilizer")
    inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FERTILIZER_USES)
    inst.components.finiteuses:SetUses(TUNING.FERTILIZER_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished) 

	inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES

    inst:AddComponent("smotherer")

	return inst
end

return Prefab("inventory/fertilizer", fn, assets, prefabs)