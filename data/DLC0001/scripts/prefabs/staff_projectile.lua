local assets=
{
	Asset("ANIM", "anim/staff_projectile.zip"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
end

local function OnHitIce(inst, owner, target)
    if not target:HasTag("freezable") then
        local fx = SpawnPrefab("shatter")
        fx.Transform:SetPosition(target:GetPosition():Get())
        fx.components.shatterfx:SetLevel(2)
    end    

    inst:Remove()
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("projectile")
    anim:SetBuild("staff_projectile")
    
    inst:AddTag("projectile")
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetLaunchOffset(Vector3(2, .5, 0))
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

local function ice()
    local inst = common()
    inst.AnimState:PlayAnimation("ice_spin_loop", true)
    inst.components.projectile:SetOnHitFn(OnHitIce)
    
    return inst
end

local function fire()
    local inst = common()
    inst.AnimState:PlayAnimation("fire_spin_loop", true)
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.components.projectile:SetOnHitFn(OnHit)
    --colour projectile
    --inst.AnimState:SetMultColour(0, 0, 0, 1)
    return inst
end

return Prefab( "common/inventory/ice_projectile", ice, assets), 
       Prefab("common/inventory/fire_projectile", fire, assets) 
