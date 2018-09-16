local assets=
{
	Asset("ANIM", "exportedanim/scary_shadow.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    --MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("scary_shadow")
    inst.AnimState:SetBuild("scary_shadow")
    inst.AnimState:PlayAnimation("idle")
    
    local anim = inst.entity:AddAnimState()
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

    return inst
end

return Prefab( "common/inventory/scary_shadow", fn, assets) 

