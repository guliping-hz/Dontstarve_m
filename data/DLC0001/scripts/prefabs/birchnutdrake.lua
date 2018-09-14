require("brains/birchnutdrakebrain")
require "stategraphs/SGbirchnutdrake"

local assets = 
{
	Asset("ANIM", "anim/treedrake.zip"),
	Asset("ANIM", "anim/treedrake_build.zip"),
}

local prefabs =
{
	"acorn",
	"twigs"
}

local function CanBeAttacked(inst, attacker)
	return not inst.sg:HasStateTag("hidden") and (not attacker or (not attacker:HasTag("birchnutdrake") and not attacker:HasTag("birchnutroot") and not attacker:HasTag("birchnut")))
end

local function RetargetFn(inst)
	if inst.sg:HasStateTag("hidden") then return end
    return FindEntity(inst, inst.range and inst.range or TUNING.DECID_MONSTER_TARGET_DIST*1.5, function(guy)
        return inst.components.combat:CanTarget(guy) and not guy:HasTag("wall") and not guy:HasTag("birchnutdrake")
    end)
end

local function KeepTargetFn(inst, target)
	if inst.sg:HasStateTag("exit") then return false end
	if inst.sg:HasStateTag("hidden") then return true end
    if target then
        return distsq(inst:GetPosition(), target:GetPosition()) < 20*20
        and not target.components.health:IsDead()
        and inst.components.combat:CanTarget(target)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, 15, function(dude)
	        return dude:HasTag("birchnutdrake") and not dude.components.health:IsDead()
		end, 10)
end

local function OnLostTarget(inst)
	if not inst.sg:HasStateTag("hidden") and inst:GetTimeAlive() > 5 then
		inst.sg:GoToState("exit")
	end
end

local function Exit(inst)
	if not inst.sg:HasStateTag("hidden") then
		inst.sg:GoToState("exit")
	end
end

local function Enter(inst)
	if not inst.sg:HasStateTag("hidden") then
		inst.sg:GoToState("enter")
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(1.25, .75)

	trans:SetFourFaced()
	MakeCharacterPhysics(inst, 1, .25)

	anim:SetBank("treedrake")
	anim:SetBuild("treedrake_build")
	anim:PlayAnimation("enter")

	inst:AddTag("birchnutdrake")
	inst:AddTag("monster")
	inst:AddTag("scarytoprey")

	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper.numrandomloot = 1
	inst.components.lootdropper:AddRandomLoot("acorn", .4)
	inst.components.lootdropper:AddRandomLoot("twigs", .6)

	inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3.5
	
	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetRange(2.5, 3)
    inst.components.combat:SetAttackPeriod(2)
	inst.components.combat.canbeattackedfn = CanBeAttacked
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/decidous/drake_hit")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:DoTaskInTime(5, function(inst)
    	inst:ListenForEvent("losttarget", OnLostTarget)
    end)

	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(50)

    inst:AddComponent("sleeper")
    inst.components.sleeper.sleeptestfn = function() return false end

    inst:AddComponent("knownlocations")

	inst:SetStateGraph("SGbirchnutdrake")
	inst:SetBrain(require("brains/birchnutdrakebrain"))

	MakeSmallBurnableCharacter(inst, "treedrake_root", Vector3(0,-1,.1))
	inst.components.burnable:SetBurnTime(10)
	inst.components.health.fire_damage_scale = 2
	inst:ListenForEvent("death", function(inst)
		if inst.components.burnable and inst.components.burnable:IsBurning() then
			inst:DoTaskInTime(.5, function(inst)
				if inst.components.burnable and inst.components.burnable:IsBurning() then
					inst.components.burnable:Extinguish()
				end
			end)
		end
	end)
    inst.components.propagator.flashpoint = 5 + math.random()*3
	MakeSmallFreezableCharacter(inst)

	inst.Exit = Exit
	inst.Enter = Enter

	-- Enter(inst)

	return inst
end

return Prefab("birchnutdrake", fn, assets, prefabs)