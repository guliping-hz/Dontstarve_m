local assets =
{
	Asset("ANIM", "anim/ice_puddle.zip"),
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    anim:SetBank("ice_puddle")
    anim:SetBuild("ice_puddle")
    anim:PlayAnimation("full")
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
    
    inst:AddTag("fx")

    return inst
end

return Prefab( "common/fx/ice_puddle", fn, assets) 
