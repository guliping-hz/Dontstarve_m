local assets=
{
	Asset("ANIM", "exportedanim/blood.zip"),
}

local function fn(Sim, animname)
	local inst = CreateEntity()
	inst.entity:AddTransform()
    
    local anim = inst.entity:AddAnimState()
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_WORLD_BACKGROUND )
	anim:SetSortOrder( 3 )

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blood")
    inst.AnimState:SetBuild("blood")
    inst.AnimState:PlayAnimation(animname)

    local scale = 1+math.random()
    inst.Transform:SetScale(scale,scale,scale)

    local rotation = math.random()*360
    inst.Transform:SetRotation(rotation)
    
    return inst
end

return 
	Prefab( "common/inventory/blood1", function(Sim) return fn(Sim, "blood1") end, assets),
	Prefab( "common/inventory/blood2", function(Sim) return fn(Sim, "blood2") end, assets),
	Prefab( "common/inventory/blood3", function(Sim) return fn(Sim, "blood3") end, assets)

