local assets=
{
	Asset("ANIM", "exportedanim/letters.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    --MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("letters")
    inst.AnimState:SetBuild("letters")
    inst.AnimState:PlayAnimation("dark")
    
    local anim = inst.entity:AddAnimState()
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst.Transform:SetScale(-1, 1, 1)
	inst.Transform:SetRotation(90)
	inst.AnimState:SetAddColour(0.6,0,0,0)

	inst.seen = false
	inst.entity:AddSoundEmitter()
	inst:DoPeriodicTask(0, function(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		if TheSim:GetLightAtPoint(x, y, z) > TUNING.SCARY_MOD_DARKNESS_CUTOFF + 0.2 and not inst.seen then
            inst.SoundEmitter:PlaySound("scary_mod/stuff/bloodyground")
            inst.seen = true
        end
	end)

    return inst
end

return Prefab( "common/inventory/letters_dark", fn, assets) 

