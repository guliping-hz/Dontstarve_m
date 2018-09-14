local assets = 
{
	Asset("ANIM", "anim/glommer_wings.zip"),
}

local prefabs = {}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)

	anim:SetBank("glommer_wings")
	anim:SetBuild("glommer_wings")
	anim:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

	return inst
end


return Prefab("glommerwings", fn, assets, prefabs)