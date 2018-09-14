require("brains/beargerbrain")
require "stategraphs/SGbearger"

local assets =
{
	Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("SOUND", "sound/bearger.fsb"),
}

local prefabs =
{
    "groundpound_fx",
    "groundpoundring_fx",
    "bearger_fur",
    "collapse_small",
}

SetSharedLootTable( 'bearger',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'bearger_fur',      1.00},
})

local BASE_TAGS = {"structure"}
local SEE_STRUCTURE_DIST = 20

local TARGET_DIST = 7.5

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

local function CalcSanityAura(inst, observer)
    if inst.components.combat.target then
        return -TUNING.SANITYAURA_HUGE
    end

    return -TUNING.SANITYAURA_LARGE
end

local function RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then return end
    if inst.last_eat_time and (GetTime() - inst.last_eat_time) > TUNING.BEARGER_DISGRUNTLE_TIME then
        return FindEntity(inst, TARGET_DIST*5, function(guy) 
            return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("prey")
               and not guy:HasTag("smallcreature")
        end)
    else
        return FindEntity(inst, TARGET_DIST, function(guy)
            return inst.components.combat:CanTarget(guy)
                and not guy:HasTag("prey")
                and not guy:HasTag("smallcreature")
        end)
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnEntitySleep(inst)
    if ((not inst:NearPlayerBase() and inst.SeenBase and not inst.components.combat:TargetIs(GetPlayer())) 
        or inst.components.sleeper:IsAsleep() 
        or inst.KilledPlayer)
        and not NearPlayerBase(inst) then
        --Bearger has seen your base and been lured off! Despawn.
        --Or the bearger has killed you, you've been punished enough.
        --Only applies if not currently at base
        LeaveWorld(inst)
    elseif (not inst:NearPlayerBase() and not inst.SeenBase) 
        or (inst.components.combat:TargetIs(GetPlayer()) and not inst.KilledPlayer) then
        --Get back in there Bearger! You still have work to do.
        local init_pos = inst:GetPosition()
        local player_pos = GetPlayer():GetPosition()
        local angle = GetPlayer():GetAngleToPoint(init_pos)
        local offset = FindWalkableOffset(player_pos, angle*DEGREES, 40, 10)
        local pos = player_pos + offset
        
        if pos and distsq(player_pos, init_pos) > 1600 then
            --There's a crash if you teleport without the delay
            if not inst.components.combat:TargetIs(GetPlayer()) then
                inst.components.combat:SetTarget(nil)
            end
            inst:DoTaskInTime(.1, function() 
                inst.Transform:SetPosition(pos:Get())
            end)
        end
    elseif inst.shouldGoAway then
        LeaveWorld(inst)
    end
end

local function OnSave(inst, data)
    data.SeenBase = inst.SeenBase
    data.CanGroundPound = inst.CanGroundPound
    data.num_food_cherrypicked = inst.num_food_cherrypicked
    data.num_good_food_eaten = inst.num_good_food_eaten
    data.KilledPlayer = inst.KilledPlayer
    data.shouldGoAway = inst.shouldGoAway
end

local function OnLoad(inst, data)
    if data then
        inst.SeenBase = data.SeenBase
        inst.CanGroundPound = data.CanGroundPound
        inst.num_food_cherrypicked = data.num_food_cherrypicked or 0
        inst.num_good_food_eaten = data.num_good_food_eaten or 0
        inst.KilledPlayer = data.KilledPlayer or false
        inst.shouldGoAway = data.shouldGoAway or false
    end
end

local function OnSeasonChange(inst, data)
    inst.shouldGoAway = (GetSeasonManager():GetSeason() ~= SEASONS.AUTUMN or GetSeasonManager().incaves)
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function OnCollide(inst, other)
    if not inst.sg:HasStateTag("running") and not other:HasTag("tree") then return end
    
    local v1 = Vector3(inst.Physics:GetVelocity())
    if v1:LengthSq() < 1 then return end

    inst:DoTaskInTime(2*FRAMES, function()
        if other and other.components.workable and other.components.workable.workleft > 0 then
            SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
            other.components.lootdropper:SetLoot({})
            other.components.workable:Destroy(inst)
        end
    end)
end

local function WorkEntities(inst)
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 5)
    local heading_angle = -(inst.Transform:GetRotation())
    local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))

    for k,v in pairs(ents) do
        if v and v.components.workable and not v:HasTag("insect") then
            local hp = v:GetPosition()
            local offset = (hp - pt):GetNormalized()     
            local dot = offset:Dot(dir)
            if dot > .3 then
                v.components.workable:Destroy(inst)
            end
        end
    end
end

local function LaunchItem(inst, target, item)
    if item.Physics then

        local x, y, z = item:GetPosition():Get()
        y = .1
        item.Physics:Teleport(x,y,z)

        local hp = target:GetPosition()
        local pt = inst:GetPosition()
        local vel = (hp - pt):GetNormalized()     
        local speed = 5 + (math.random() * 2)
        local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)

    end
end

local function OnHitOther(inst, data)
    local other = data.target
    if other and other.components.inventory then
        local item = other.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if not item then return end
        other.components.inventory:DropItem(item)
        LaunchItem(inst, data.target, item)
    end
end

local function ontimerdone(inst, data)
    if data.name == "GroundPound" then
        inst.CanGroundPound = true
    end
end

local function ShouldSleep(inst)
    if inst.num_good_food_eaten >= TUNING.BEARGER_NUM_FOOD_FOR_SATISFIED then
        inst.num_good_food_eaten = 0
        inst.sleep_time = GetTime()
        return true
    end
    return false
end

local function ShouldWake(inst)
    local wake = inst.sleep_time and (GetTime() - inst.sleep_time) > TUNING.BEARGER_SLEEP_WHEN_SATISFIED_TIME
    if wake == nil then wake = true end
    wake = wake
        or (inst.components.combat and inst.components.combat.target)
        or (inst.components.freezable and inst.components.freezable:IsFrozen())
    return wake
end

local function OnLostTarget(inst, data)
    --Remove the listening set up on "OnCombatTarget"
    if data.oldtarget and data.oldtarget.BEARGER_OnDropItemFn then
        inst:RemoveEventCallback("dropitem", data.oldtarget.BEARGER_OnDropItemFn, data.oldtarget)
    end
end

local function OnCombatTarget(inst, data)
    --Listen for dropping of items... if it's food, maybe forgive your target?
    if data.oldtarget then
        OnLostTarget(inst, data)
    end
    if data.target then
        inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
        inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
        data.target.BEARGER_OnDropItemFn = function(target, info)
            if inst.components.eater:CanEat(info.item) then
                if info.item:HasTag("honeyed") or math.random() < 1 then
                    inst.components.combat:SetTarget(nil)
                end
            end
        end
        inst:ListenForEvent("dropitem", data.target.BEARGER_OnDropItemFn, data.target)
    else
        inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED 
    end
end

local function SetStandState(inst, state)
    --"quad" or "bi" state
    inst.StandState = string.lower(state)
end

local function IsStandState(inst, state)
    return inst.StandState == string.lower(state)
end

local function OnKill(inst, data)
    if data and data.victim == GetPlayer() then
        inst.KilledPlayer = true
    end
end

local function OnPlayerAction(inst, player, data)
    local playerAction = data.action
    local selfAction = inst:GetBufferedAction()
    if not playerAction or not selfAction then return end --You're not doing anything so whatever.

    if playerAction.target == selfAction.target then -- We got a problem bud.
        
        inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
        if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
            inst.sg:GoToState("targetstolen")
        else
            inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
            inst.components.combat:SuggestTarget(player)
        end
    end
end

local function fn(Sim)
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(6, 3.5)
    
    inst.Transform:SetFourFaced()
    
    local s = 1
    trans:SetScale(s,s,s)

	MakeCharacterPhysics(inst, 1000, 1.5)
    inst.Physics:SetCollisionCallback(OnCollide)

    anim:SetBank("bearger")
    anim:SetBuild("bearger_build")
    anim:PlayAnimation("idle_loop", true)
    
    ------------------------------------------

	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bearger")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEARGER_HEALTH)
    inst.components.health.destroytime = 5
    
    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE)
    inst.components.combat:SetAreaDamage(6, 0.8)
    inst.components.combat.hiteffectsymbol = "bearger_body"
    inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")
    inst:ListenForEvent("killed", function(inst, data)
        if inst.components.combat and data and data.victim == inst.components.combat.target then
            inst.components.combat.target = nil
        end 
    end)

    ------------------------------------------
 
    inst.shouldGoAway = false
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    
    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("bearger")
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("thief")
    inst:AddComponent("inventory")
    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 4
    inst.components.groundpounder.numRings = 5
    inst:AddComponent("timer")
    inst:AddComponent("eater")
    inst.components.eater.foodprefs = {"MEAT", "VEGGIE", "GENERIC"}
    inst.components.eater.eatwholestack = true

    ------------------------------------------

    inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld() )
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("timerdone", ontimerdone)

    ------------------------------------------

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "bearger_body")

    SetStandState(inst, "QUAD")--SetStandState(inst, "BI")
    inst.SetStandState = SetStandState
    inst.IsStandState = IsStandState
    inst.SeenBase = false
    inst.NearPlayerBase = NearPlayerBase
    inst.WorkEntities = WorkEntities
    inst.CanGroundPound = false
    inst.KilledPlayer = false

    inst.num_good_food_eaten = 0

    inst.num_food_cherrypicked = 0
    -- inst:ListenForEvent("harvestsomething", function(it, data) --Target got harvested, increase displeasure
    --     local ba = inst:GetBufferedAction()
    --     if ba and data.object == ba.target then
    --         inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    --         if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
    --             inst.sg:GoToState("targetstolen")
    --         else
    --             inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
    --             inst.components.combat:SuggestTarget(GetPlayer())
    --         end
    --     end
    -- end, GetPlayer())
    -- inst:ListenForEvent("picksomething", function(it, data) --Target got picked, increase displeasure
    --     local ba = inst:GetBufferedAction()
    --     if ba and data.object == ba.target then
    --         inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    --         if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
    --             inst.sg:GoToState("targetstolen")
    --         else
    --             inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
    --             inst.components.combat:SuggestTarget(GetPlayer())
    --         end
    --     end
    -- end, GetPlayer())
    -- inst:ListenForEvent("onpickup", function(it, data) --Target got picked up, increase displeasure
    --     local ba = inst:GetBufferedAction()
    --     if ba and data.item == ba.target then
    --         inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    --         if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
    --             inst.sg:GoToState("targetstolen")
    --         else
    --             inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
    --             inst.components.combat:SuggestTarget(GetPlayer())
    --         end
    --     end
    -- end, GetPlayer())
    -- inst:ListenForEvent("opencontainer", function(it, data) --Target container has been opened, prepare for anger
    --     local ba = inst:GetBufferedAction()
    --     if ba and data.container == ba.target then
    --         inst.targcontainer = data.container 
    --     end
    -- end, GetPlayer())
    -- inst:ListenForEvent("closecontainer", function(it, data) --Target container has been closed, we cool
    --     local ba = inst:GetBufferedAction() -- This isn't perfect: closing any container will count, but it doesn't seem worth tracking that
    --     if ba and data.container == ba.target then
    --         inst.targcontainer = nil
    --     end
    -- end, GetPlayer())
    -- inst:ListenForEvent("itemget", function(it, data) --Edible thing has been removed from target container, increase displeasure
    --     if inst.targcontainer and data.item and inst.components.eater:CanEat(data.item) then
    --         inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    --         if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
    --             inst.sg:GoToState("targetstolen")
    --         else
    --             inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
    --             inst.components.combat:SuggestTarget(GetPlayer())
    --         end
    --     end
    -- end, GetPlayer())

    inst:ListenForEvent("actionsuccess", function(player, data) OnPlayerAction(inst, player, data) end, GetPlayer())

    inst:ListenForEvent("killed", OnKill)
    inst:ListenForEvent("newcombattarget", OnCombatTarget)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:SetStateGraph("SGbearger")
    local brain = require("brains/beargerbrain")
    inst:SetBrain(brain)

    return inst
end

return Prefab( "common/monsters/bearger", fn, assets, prefabs) 