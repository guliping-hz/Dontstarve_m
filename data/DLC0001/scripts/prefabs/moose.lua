require("brains/moosebrain")
require "stategraphs/SGmoose"

local assets =
{
	Asset("ANIM", "anim/goosemoose_build.zip"),
    Asset("ANIM", "anim/goosemoose_basic.zip"),
    Asset("ANIM", "anim/goosemoose_actions.zip"),
    --Asset("SOUND", "sound/moose.fsb"),
}

local prefabs =
{
    "mooseegg",
    "mossling",
    "goose_feather",
    "drumstick",
}

local MOOSE_SCALE = 1.55

SetSharedLootTable( 'moose',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'drumstick',        1.00},
    {'drumstick',        1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    0.33},
    {'goose_feather',    0.33},
})

local BASE_TAGS = {"structure"}
local SEE_STRUCTURE_DIST = 20

local TARGET_DIST = 10
local LOSE_TARGET_DIST = 30

local function LeaveWorld(inst)
    inst:Remove()
end

local function NearPlayerBase(inst)
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_STRUCTURE_DIST, BASE_TAGS)
    if #ents >= 2 then
        inst.SeenBase = true
        return true
    end
end

local function RetargetFn(inst)
    if inst.sg:HasStateTag("busy") then return end

    local target = nil

    if not target and inst.components.entitytracker:GetEntity("egg") then
         target =  FindEntity(inst.components.entitytracker:GetEntity("egg"), TARGET_DIST, function(guy) 
            return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("prey")
               and not guy:HasTag("smallcreature")
               and not guy:HasTag("mossling")
        end)
    end

    if not target then
        target =  FindEntity(inst, TARGET_DIST, function(guy) 
            return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("prey")
               and not guy:HasTag("smallcreature")
               and not guy:HasTag("mossling")
        end)
    end

    return target
end

local function KeepTargetFn(inst, target)
    local landing = inst.components.knownlocations:GetLocation("landpoint")

    return inst.components.combat:CanTarget(target) and inst:GetDistanceSqToInst(target) <= LOSE_TARGET_DIST*LOSE_TARGET_DIST and
    (landing and target:GetPosition():DistSq(landing) <= LOSE_TARGET_DIST* LOSE_TARGET_DIST or true)

end

local function OnEntitySleep(inst)
    if inst.shouldGoAway then
        LeaveWorld(inst)
    end
end

local function OnSeasonChange(inst, data)
    inst.shouldGoAway = (GetSeasonManager():GetSeason() ~= SEASONS.SPRING or GetSeasonManager().incaves)
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function OnCollide(inst, other)
    --Destroy?
end

local function OnSave(inst, data)
    data.WantsToLayEgg = inst.WantsToLayEgg
    data.CanDisarm = inst.CanDisarm
    data.shouldGoAway = inst.shouldGoAway
end

local function OnLoad(inst, data)
    if data.WantsToLayEgg then 
        inst.WantsToLayEgg = data.WantsToLayEgg
    end
    if data.CanDisarm then 
        inst.CanDisarm = data.CanDisarm
    end
    inst.shouldGoAway = data.shouldGoAway or false
end

local function ontimerdone(inst, data)
    if data.name == "WantsToLayEgg" then
        inst.WantsToLayEgg = true
    end

    if data.name == "DisarmCooldown" then
        inst.CanDisarm = true
    end
end

local function fn(Sim)
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

    local s = MOOSE_SCALE

    trans:SetScale(s,s,s)

	shadow:SetSize(6, 2.75)

	MakeCharacterPhysics(inst, 5000, 1)

    inst.Physics:SetCollisionCallback(OnCollide)

    inst.Transform:SetFourFaced()

    anim:SetBank("goosemoose")
    anim:SetBuild("goosemoose_build")
    anim:PlayAnimation("idle", true)
    
    ------------------------------------------

    inst:AddTag("moose")
    inst:AddTag("epic")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    ------------------
    
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 15)

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOOSE_HEALTH)
    inst.components.health.destroytime = 3
    
    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.MOOSE_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.MOOSE_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "goosemoose_body"
    inst.components.combat:SetAttackPeriod(TUNING.MOOSE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/moose/hurt")
    ------------------------------------------
 
    inst:AddComponent("sleeper")
    inst.shouldGoAway = false
    
    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('moose')  
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("named")
    inst.components.named.possiblenames = {STRINGS.NAMES["MOOSE1"], STRINGS.NAMES["MOOSE2"]}
    inst.components.named:PickNewName()
    inst:DoPeriodicTask(5, function(inst)
        inst.components.named:PickNewName()
    end)

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("inventory")
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")

    ------------------------------------------

    inst:AddComponent("eater")
    inst.components.eater.foodprefs = {"MEAT", "VEGGIE", "SEEDS"}
    inst.components.eater.eatwholestack = true

    ------------------------------------------

    inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld() )
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleep)

    ------------------------------------------

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "goosemoose_body")

    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("EggHatch", ontimerdone)

    inst.WantsToLayEgg = false
    inst.CanDisarm = false

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MOOSE_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MOOSE_RUN_SPEED

    inst:SetStateGraph("SGmoose")
    local brain = require("brains/moosebrain")
    inst:SetBrain(brain)

    return inst
end

return Prefab( "common/monsters/moose", fn, assets, prefabs) 
