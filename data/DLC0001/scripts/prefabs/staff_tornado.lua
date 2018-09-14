local assets = 
{
	Asset("ANIM", "anim/tornado.zip"),
	Asset("ANIM", "anim/tornado_stick.zip"),
	Asset("ANIM", "anim/swap_tornado_stick.zip"),
}

local function getspawnlocation(inst, target)
	local tarPos = target:GetPosition()
	local pos = inst:GetPosition()
	local vec = tarPos - pos
	vec = vec:Normalize()
	local dist = pos:Dist(tarPos)
	return pos + (vec * (dist * .15))
end

local function cantornado(staff, caster, target, pos)
    return target and (
        (target.components.health and target.components.combat and caster.components.combat:CanTarget(target)) 
        or target.components.workable
        )
end

local function spawntornado(staff, target, pos)
    local tornado = SpawnPrefab("tornado")
    tornado.WINDSTAFF_CASTER = staff.components.inventoryitem.owner
    local spawnPos = staff:GetPosition() + TheCamera:GetDownVec()
    local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
    local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
    tornado.Transform:SetPosition(getspawnlocation(staff, target):Get())
    tornado.components.knownlocations:RememberLocation("target", targetPos)

    staff.components.finiteuses:Use(1)
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_tornado_stick", "swap_tornado_stick")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onfinished(inst)
    inst:Remove()
end

local function staff_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("tornado_stick")
    anim:SetBuild("tornado_stick")
    anim:PlayAnimation("idle")
    -------   
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster:SetSpellTestFn(cantornado)
    inst.components.spellcaster:SetSpellFn(spawntornado)
    inst.components.spellcaster.castingstate = "castspell_tornado"
    inst.components.spellcaster.actiontype = "SCIENCE"

    inst.components.finiteuses:SetMaxUses(TUNING.TORNADOSTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.TORNADOSTAFF_USES)
    inst:AddTag("nopunch")
 
    return inst
end

local function tornado_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("tornado")
	anim:SetBuild("tornado")
	anim:PlayAnimation("tornado_pre")
	anim:PushAnimation("tornado_loop")

    sound:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

	inst:DoTaskInTime(TUNING.TORNADO_LIFETIME, function() inst.sg:GoToState("despawn") end)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

	inst:AddComponent("knownlocations")

	inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.TORNADO_WALK_SPEED * 0.33
    inst.components.locomotor.runspeed = TUNING.TORNADO_WALK_SPEED

    inst:SetStateGraph("SGtornado")
    inst:SetBrain(require "brains/tornadobrain")

    inst.WINDSTAFF_CASTER = nil

	return inst
end

return Prefab("staff_tornado", staff_fn, assets), 
Prefab("tornado", tornado_fn, assets)