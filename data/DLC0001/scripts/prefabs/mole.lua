require("brains/molebrain")
require "stategraphs/SGmole"

local assets=
{
	Asset("ANIM", "anim/mole_build.zip"),
	Asset("ANIM", "anim/mole_basic.zip"),
	Asset("SOUND", "sound/mole.fsb"),
}


-- make him pop up periodically


local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
    "mole_move_fx"
}

local function OnAttacked(inst, data)
    -- Don't spread the word when whacked
    if data and data.weapon and data.weapon == "hammer" then return end 

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, {'mole'})
    
    local num_friends = 0
    local maxnum = 5
    for k,v in pairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1
        
        if num_friends > maxnum then
            break
        end
    end
end

local function OnWentHome(inst)
    local molehill = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if not molehill then return end
    if molehill.components.inventory then
        inst.components.inventory:TransferInventory(molehill)
    end
    inst.sg:GoToState("idle")
end

local function GetCookProductFn(inst)
    return "cookedsmallmeat"
end

local function OnCookedFn(inst)
    if inst.components.health then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
    end
end

local function onpickup(inst)
    inst:PushEvent("ontrapped")
    inst.SoundEmitter:KillSound("move")
    inst.SoundEmitter:KillSound("sniff")
    inst.SoundEmitter:KillSound("stunned")
    if inst.stunnedkillsleepsfxtask then inst.stunnedkillsleepsfxtask:Cancel() inst.stunnedkillsleepsfxtask = nil end
    if inst.stunnedsleepsfxtask then inst.stunnedsleepsfxtask:Cancel() inst.stunnedsleepsfxtask = nil end
end

local function OnLoad(inst, data)
    if data then
        inst.needs_home_time = data.needs_home_time and -data.needs_home_time or nil 
    end
end

local function OnSave(inst, data)
    data.needs_home_time = inst.needs_home_time and (GetTime() - inst.needs_home_time) or nil
end

local function SetState(inst, state)
	--"under" or "above"
    inst.State = string.lower(state)
    if inst.State == "under" then
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    elseif inst.State == "above" then
        ChangeToCharacterPhysics(inst)
    end
end

local function IsState(inst, state)
    return inst.State == string.lower(state)
end

local function CanBeAttacked(inst)
    return ((inst.State == "above") and not inst.components.inventoryitem.canbepickedup)
end

local function displaynamefn(inst)
    if inst.State == "under" and not inst:HasTag("INLIMBO") then
        return STRINGS.NAMES.MOLE_UNDERGROUND
    else
        return STRINGS.NAMES.MOLE_ABOVEGROUND
    end
end

local function getstatus(inst)
    if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
        return "HELD"
    elseif inst.State == "under" then
        return "UNDERGROUND"
    else
        return "ABOVEGROUND"
    end
end

local function ondrop(inst)
    inst.SoundEmitter:KillSound("move")
    inst.SoundEmitter:KillSound("sniff")
    inst.SoundEmitter:KillSound("stunned")
    inst:SetState("above")
    inst.sg:GoToState("stunned", true)
    if not (inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid()) and not GetWorld():IsCave() then
        inst.needs_home_time = GetTime()
    end
end

local function OnSleep(inst)
    inst.SoundEmitter:KillAllSounds()
end

local function OnRemove(inst)
    inst.SoundEmitter:KillAllSounds()
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	-- local shadow = inst.entity:AddDynamicShadow()
	-- shadow:SetSize( 1, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 99999, 0.5)

    anim:SetBank("mole")
    anim:SetBuild("mole_build")
    anim:PlayAnimation("idle_under")
    
    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("mole")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")    
    inst:AddTag("baitstealer")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")

    inst:AddComponent("tradable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2.75

    inst:SetStateGraph("SGmole")
    local brain = require("brains/molebrain")
    inst:SetBrain(brain)

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOLE_HEALTH)
    inst.components.health.murdersound = "dontstarve_DLC001/creatures/mole/death"
    inst.components.health.fire_damage_scale = 0
    
    inst:AddComponent("combat")
    inst.components.combat.canbeattackedfn = CanBeAttacked
    --inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/mole/hurt")
    
    inst:AddComponent("eater")
    inst.components.eater:SetElemental()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"smallmeat"})
    inst.components.lootdropper.trappable = false

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 3
    inst.force_onwenthome_message = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.trappable = false
    -- inst.components.inventoryitem:SetOnPickupFn(onpickup)
    -- inst.components.inventoryitem:SetOnDroppedFn(ondrop) Done in MakeFeedablePet

    inst:AddComponent("knownlocations")
    inst.last_above_time = 0
    inst.make_home_delay = math.random(5,10)
    inst.peek_interval = math.random(15,25)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst.displaynamefn = displaynamefn
    inst.name = STRINGS.NAMES.MOLE_ABOVEGROUND

    inst:AddComponent("sleeper")

    SetState(inst, "under")
    inst.SetState = SetState
    inst.IsState = IsState
    
    -- MakeSmallBurnableCharacter(inst, "mole")
    MakeTinyFreezableCharacter(inst, "chest")
    -- inst.components.burnable:MakeNotWildfireStarter()
	    
    inst.OnSave = OnSave     
    inst.OnLoad = OnLoad
    -- inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep    
    inst.OnRemoveEntity = OnRemove
    inst:ListenForEvent("enterlimbo", OnRemove)
    
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onwenthome", OnWentHome)

    MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, onpickup, ondrop)

    return inst
end

return Prefab( "forest/animals/mole", fn, assets, prefabs) 