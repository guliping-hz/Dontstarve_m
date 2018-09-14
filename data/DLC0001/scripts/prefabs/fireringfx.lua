local assets =
{
	Asset("ANIM", "anim/dragonfly_ring_fx.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    anim:SetBank("dragonfly_ring_fx")
    anim:SetBuild("dragonfly_ring_fx")
    anim:PlayAnimation("idle")
    anim:SetFinalOffset(-1)

    anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst.persists = false
    inst:AddTag("fx")
    inst:ListenForEvent("animover", function() 
        inst.AnimState:ClearBloomEffectHandle()
        inst:Remove() 
    end)

    return inst
end

return Prefab("common/fx/firering_fx", fn, assets) 
