local assets=
{
	Asset("ANIM", "exportedanim/helipad.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    --MakeInventoryPhysics(inst)
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "helipad.tex" )
	minimap:SetPriority( 8 )

    inst.AnimState:SetBank("helipad")
    inst.AnimState:SetBuild("helipad")
    inst.AnimState:PlayAnimation("idle")
    
    local anim = inst.entity:AddAnimState()
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_WORLD_BACKGROUND )
	anim:SetSortOrder( 3 )

	local scale = 2
	inst.Transform:SetScale(scale, scale, scale)

	local amt = 0.4
	inst.AnimState:SetMultColour(amt,amt,amt,amt)

    return inst
end

return Prefab( "common/inventory/helipad", fn, assets) 

