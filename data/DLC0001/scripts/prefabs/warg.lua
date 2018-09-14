require("brains/wargbrain")
require "stategraphs/SGwarg"

local assets =
{
	Asset("ANIM", "anim/warg_actions.zip"),
	Asset("ANIM", "anim/warg_build.zip"),
}

local prefabs = 
{
	"hound",
	"icehound",
	"firehound",
	"monstermeat",
	"houndstooth",
}

SetSharedLootTable('warg',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             0.50},
    {'monstermeat',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

local function RetargetFn(inst)
	if inst.sg:HasStateTag("hidden") then return end
    return FindEntity(inst, TUNING.WARG_TARGETRANGE, function(guy)
        return inst.components.combat:CanTarget(guy) 
        and not guy:HasTag("wall") 
        and not guy:HasTag("warg") 
        and not guy:HasTag("hound")
    end)
end

local function KeepTargetFn(inst, target)
	if inst.sg:HasStateTag("hidden") then return end
    if target then
        return distsq(inst:GetPosition(), target:GetPosition()) < 40*40
        and not target.components.health:IsDead()
        and inst.components.combat:CanTarget(target)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, TUNING.WARG_MAXHELPERS, function(dude)
	        return dude:HasTag("warg") or dude:HasTag("hound") 
	        and not dude.components.health:IsDead()
		end, TUNING.WARG_TARGETRANGE)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.5 )

	local s = 1
	trans:SetScale(s,s,s)

	trans:SetFourFaced()
	MakeCharacterPhysics(inst, 1000, 2)

	anim:SetBank("warg")
	anim:SetBuild("warg_build")
	anim:PlayAnimation("idle")

	inst:AddTag("monster")
	inst:AddTag("warg")
	inst:AddTag("scarytoprey")
	inst:AddTag("houndfriend")
	inst:AddTag("largecreature")


	inst:AddComponent("inspectable")

	inst:AddComponent("leader")

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = TUNING.WARG_RUNSPEED
    inst.components.locomotor:SetShouldRun(true)

	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
    inst.components.combat:SetRange(TUNING.WARG_ATTACKRANGE)
    inst.components.combat:SetAttackPeriod(TUNING.WARG_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
    inst:ListenForEvent("attacked", OnAttacked)

	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH)

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('warg') 

    inst:AddComponent("sleeper")

	MakeLargeFreezableCharacter(inst)
	MakeLargeBurnableCharacter(inst, "swap_fire")

	inst:SetStateGraph("SGwarg")
	inst:SetBrain(require("brains/wargbrain"))

	return inst
end

return Prefab("warg", fn, assets, prefabs)