local assets =
{
	Asset("ANIM", "anim/ice_splash.zip"),
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("ice_splash")
    anim:SetBuild("ice_splash")
    anim:PlayAnimation("full")
    
    inst:AddTag("fx")

    return inst
end

return Prefab( "common/fx/ice_splash", fn, assets) 
