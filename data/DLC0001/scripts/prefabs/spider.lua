require "brains/spiderbrain"
require "stategraphs/SGspider"

local assets =
{
	Asset("ANIM", "anim/ds_spider_basic.zip"),
	Asset("ANIM", "anim/spider_build.zip"),
	Asset("SOUND", "sound/spider.fsb"),
}

local warrior_assets =
{
	Asset("ANIM", "anim/ds_spider_basic.zip"),
	Asset("ANIM", "anim/ds_spider_warrior.zip"),
	Asset("ANIM", "anim/spider_warrior_build.zip"),
	Asset("SOUND", "sound/spider.fsb"),
}
    
local prefabs =
{
	"spidergland",
    "monstermeat",
    "silk",
}

local function ShouldAcceptItem(inst, item, giver)

    if giver.prefab ~= "webber" then
        return false
    end

    if inst.components.sleeper:IsAsleep() then
        return false
    end
    
    if inst.components.eater:CanEat(item) then
        return true
    end
end

function GetOtherSpiders(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 15,  {"spider"}, {"FX", "NOCLICK", "DECOR","INLIMBO"})
    return ents
end

local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.eater:CanEat(item) then  

        local playedfriendsfx = false
        if inst.components.combat.target and inst.components.combat.target == giver then
            inst.components.combat:SetTarget(nil)
        elseif giver.components.leader then
            inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
            playedfriendsfx = true
            giver.components.leader:AddFollower(inst)
            local loyaltyTime = item.components.edible:GetHunger() * TUNING.SPIDER_LOYALTY_PER_HUNGER
            inst.components.follower:AddLoyaltyTime(loyaltyTime)
        end

        local spiders = GetOtherSpiders(inst)
        local maxSpiders = 3

        for k,v in pairs(spiders) do
            if maxSpiders < 0 then
                break
            end

            if v.components.combat.target and v.components.combat.target == giver then
                v.components.combat:SetTarget(nil)
            elseif giver.components.leader then
                if not playedfriendsfx then
                    v.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
                    playedfriendsfx = true
                end
                giver.components.leader:AddFollower(v)
                local loyaltyTime = item.components.edible:GetHunger() * TUNING.SPIDER_LOYALTY_PER_HUNGER
                if v.components.follower then
                    v.components.follower:AddLoyaltyTime(loyaltyTime)
                end
            end
            maxSpiders = maxSpiders - 1

            if v.components.sleeper:IsAsleep() then
                v.components.sleeper:WakeUp()
            end
        end
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("taunt")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function NormalRetarget(inst)
    local targetDist = TUNING.SPIDER_TARGET_DIST
    if inst.components.knownlocations:GetLocation("investigate") then
        targetDist = TUNING.SPIDER_INVESTIGATETARGET_DIST
    end
    if GetSeasonManager() and GetSeasonManager():IsSpring() then
        targetDist = targetDist * TUNING.SPRING_COMBAT_MOD
    end
    return FindEntity(inst, targetDist, 
        function(guy) 
            if inst.components.combat:CanTarget(guy)
               and not (inst.components.follower and inst.components.follower.leader == guy)
               and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion")) then
                return (guy:HasTag("character") and not guy:HasTag("monster"))
            end
    end)
end

local function WarriorRetarget(inst)
    local targetDist = TUNING.SPIDER_WARRIOR_TARGET_DIST
    if GetSeasonManager() and GetSeasonManager():IsSpring() then
        targetDist = targetDist * TUNING.SPRING_COMBAT_MOD
    end
    return FindEntity(inst, targetDist, function(guy)
		return ((guy:HasTag("character") and not guy:HasTag("monster")) or guy:HasTag("pig"))
               and inst.components.combat:CanTarget(guy)
               and not (inst.components.follower and inst.components.follower.leader == guy)
               and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion"))
	end)
end

local function FindWarriorTargets(guy)
	return ((guy:HasTag("character") and not guy:HasTag("monster")) or guy:HasTag("pig"))
               and inst.components.combat:CanTarget(guy)
               and not (inst.components.follower and inst.components.follower.leader == guy)
end

local function keeptargetfn(inst, target)
   return target
          and target.components.combat
          and target.components.health
          and not target.components.health:IsDead()
          and not (inst.components.follower and inst.components.follower.leader == target)
          and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and target:HasTag("companion"))
end

local function ShouldSleep(inst)
    return GetClock():IsDay()
           and not (inst.components.combat and inst.components.combat.target)
           and not (inst.components.homeseeker and inst.components.homeseeker:HasHome() )
           and not (inst.components.burnable and inst.components.burnable:IsBurning() )
           and not (inst.components.follower and inst.components.follower.leader)
end

local function ShouldWake(inst)
    local wakeRadius = TUNING.SPIDER_WARRIOR_WAKE_RADIUS
    if GetSeasonManager() and GetSeasonManager():IsSpring() then
        wakeRadius = wakeRadius * TUNING.SPRING_COMBAT_MOD
    end
    return GetClock():IsNight()
           or (inst.components.combat and inst.components.combat.target)
           or (inst.components.homeseeker and inst.components.homeseeker:HasHome() )
           or (inst.components.burnable and inst.components.burnable:IsBurning() )
           or (inst.components.follower and inst.components.follower.leader)
           or (inst:HasTag("spider_warrior") and FindEntity(inst, wakeRadius, function(...) return FindWarriorTargets(inst, ...) end ))
end

local function DoReturn(inst)
	if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home.components.childspawner
    and not (inst.components.follower and inst.components.follower.leader) then
		inst.components.homeseeker.home.components.childspawner:GoHome(inst)
	end
end

local function StartDay(inst)
	if inst:IsAsleep() then
		DoReturn(inst)	
	end
end


local function OnEntitySleep(inst)
	if GetClock():IsDay() then
		DoReturn(inst)
	end
end

local function SummonFriends(inst, attacker)
    local summonDist = TUNING.SPIDER_SUMMON_WARRIORS_RADIUS
    if GetSeasonManager() and GetSeasonManager():IsSpring() then
        summonDist = summonDist * TUNING.SPRING_COMBAT_MOD
    end
	local den = GetClosestInstWithTag("spiderden",inst, TUNING.SPIDER_SUMMON_WARRIORS_RADIUS)
	if den and den.components.combat and den.components.combat.onhitfn then
		den.components.combat.onhitfn(den, attacker)
	end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return dude:HasTag("spider")
               and not dude.components.health:IsDead()
               and dude.components.follower
               and dude.components.follower.leader == inst.components.follower.leader
    end, 10)
end

local function StartNight(inst)
    inst.components.sleeper:WakeUp()
end

local function SanityAura(inst, observer)

    if observer.prefab == "webber" then
        return 0
    end

    return -TUNING.SANITYAURA_SMALL

end

local function create_common(Sim)
	local inst = CreateEntity()
	
	inst:ListenForEvent( "daytime", function(i, data) StartDay( inst ) end, GetWorld())	
	inst.OnEntitySleep = OnEntitySleep
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .5 )
    inst.Transform:SetFourFaced()
    
    
    ----------
    
    inst:AddTag("monster")
    inst:AddTag("hostile")
	inst:AddTag("scarytoprey")    
    inst:AddTag("canbetrapped")
    inst:AddTag("smallcreature")
    
    MakeCharacterPhysics(inst, 10, .5)

    
    inst:AddTag("spider")
    inst.AnimState:SetBank("spider")
    inst.AnimState:PlayAnimation("idle")
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.TOTAL_DAY_TIME
    
    -- locomotor must be constructed before the stategraph!
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

  
    inst:SetStateGraph("SGspider")
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("monstermeat", 1)
    inst.components.lootdropper:AddRandomLoot("silk", .5)
    inst.components.lootdropper:AddRandomLoot("spidergland", .5)
    inst.components.lootdropper.numrandomloot = 1
    
    ---------------------        
    MakeMediumBurnableCharacter(inst, "body")
    MakeMediumFreezableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY
    ---------------------       
    

    ------------------
    inst:AddComponent("health")

    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
	inst.components.combat:SetOnHit(SummonFriends)
    
    ------------------
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    ------------------
    
    inst:AddComponent("knownlocations")

    ------------------
    
    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!
    
    ------------------
    
    inst:AddComponent("inspectable")
    
    ------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    ------------------

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = SanityAura
    
    
    local brain = require "brains/spiderbrain"
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("dusktime", function() StartNight(inst) end, GetWorld())

    return inst
end

local function create_spider(Sim)
    local inst = create_common(Sim)
    
    inst.AnimState:SetBuild("spider_build")

    inst.components.health:SetMaxHealth(TUNING.SPIDER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, NormalRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_RUN_SPEED

    return inst
end

local function create_warrior(Sim)
    local inst = create_common(Sim)
    
    inst.AnimState:SetBuild("spider_warrior_build")

    inst:AddTag("spider_warrior")

    inst.components.health:SetMaxHealth(TUNING.SPIDER_WARRIOR_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_WARRIOR_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_WARRIOR_ATTACK_PERIOD + math.random()*2)
    inst.components.combat:SetRange(TUNING.SPIDER_WARRIOR_ATTACK_RANGE, TUNING.SPIDER_WARRIOR_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, WarriorRetarget)
    
    inst.components.locomotor.walkspeed = TUNING.SPIDER_WARRIOR_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_WARRIOR_RUN_SPEED
	
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    return inst
end


return Prefab( "forest/monsters/spider", create_spider, assets, prefabs),
    Prefab( "forest/monsters/spider_warrior", create_warrior, warrior_assets) 
