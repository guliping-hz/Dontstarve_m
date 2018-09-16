
assets = {
	Asset("ANIM", "anim/ds_pig_basic.zip"),
	Asset("ANIM", "anim/pig_build.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	trans:SetFourFaced()
	local shadow = inst.entity:AddDynamicShadow()
	local anim = inst.entity:AddAnimState()
	shadow:SetSize( 1.5, .75 )

	anim:SetBank("pigman")
	anim:SetBuild("pig_build")
	anim:PlayAnimation("idle_loop")
	trans:SetScale(1.2, 3.5, 1.2)

	return inst
end

return Prefab("totem_pole", fn, assets)
