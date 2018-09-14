require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "behaviours/chaseandram"


local TIME_BETWEEN_EATING = 3.5

local MAX_CHASE_TIME = 10
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60
local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30

local BASE_TAGS = {"structure"}
local FOOD_TAGS = {"edible"}
local STEAL_TAGS = {"structure"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO", "burnt"}

local VALID_FOODS = 
{
    "berries",
    "cave_banana",
    "carrot",   
    "red_cap",
    "blue_cap",
    "green_cap", 
}

local function ItemIsInList(item, list)
    for k,v in pairs(list) do
        if v == item or k == item then
            return true
        end
    end
end

local function GoHome(inst)
    if inst.components.knownlocations:GetLocation("home") then
        return BufferedAction(inst, nil, ACTIONS.GOHOME, nil, inst.components.knownlocations:GetLocation("home") )
    end
end

local function EatFoodAction(inst)  --Look for food to eat

    local target = nil
    local action = nil

    -- If we don't check that the target is not a beehive, we will keep doing targeting stuff while there's precious honey on the ground
    if inst.sg:HasStateTag("busy") and (inst.components.combat and inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and not
    inst.sg:HasStateTag("wantstoeat") then
        return
    end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST, FOOD_TAGS, NO_TAGS) 

    local honeypass = true
    while not target do
        if not target then
            for k,v in pairs(ents) do
                if v and ((honeypass and v:HasTag("honeyed")) or not honeypass) and v:IsOnValidGround() and inst.components.eater:CanEat(v) and not v.components.inventoryitem:IsHeld() then
                    target = v
                    break
                end
            end
        end    

        if target then
            local action = BufferedAction(inst,target,ACTIONS.PICKUP)
            return action 
        end

        if honeypass == false then break end
        honeypass = false
    end
end

local function StealFoodAction(inst) --Look for things to take food from (EatFoodAction handles picking up/ eating)

    -- Food On Ground > Pots = Farms = Drying Racks > Beebox > Look In Fridge > Chests > Backpacks (on ground) > Plants

    local target = nil

    if inst.sg:HasStateTag("busy") or 
    (inst.components.inventory and inst.components.inventory:IsFull()) then
        return
    end

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_STRUCTURE_DIST, nil, NO_TAGS) 
    local honeypass = true

    --Look for crop/ cookpots/ drying rack, harvest them.
    while not target do
        if not target then
            for k,item in pairs(ents) do
                if (item.components.stewer and item.components.stewer:IsDone()) or
                (item.components.dryer and item.components.dryer:IsDone()) or
                (item.components.crop and item.components.crop:IsReadyForHarvest()) then
                    target = item
                    break
                end
            end
        end

        -- Only crock pot is okay during honeypass
        if (honeypass and target and target.components.stewer) or (not honeypass and target) then
            return BufferedAction(inst, target, ACTIONS.HARVEST)
        end


        --Beeboxes
        if not target then
            for k,item in pairs(ents) do
                if item and item:HasTag("beebox") and item.components.harvestable and item.components.harvestable:CanBeHarvested() then
                    target = item
                    break
                end
            end
        end

        -- Beeboxes okay during honeypass
        if target then
            return BufferedAction(inst, target, ACTIONS.HARVEST)
        end

        --Fridges
        if not target then
            for k,item in pairs(ents) do
                if item and item:HasTag("fridge") and item.components.container and not item.components.container:IsEmpty()
                and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) then --For icepack.
                    -- Look only for honey things in the fridge on first pass
                    local foodstuffs = nil
                    if honeypass then
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end)
                    else
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end)
                    end
                    if foodstuffs then
                        target = item
                        break
                    end
                end
            end
        end

        if target then
            return BufferedAction(inst, target, ACTIONS.HAMMER)
        end

        --Chests
        if not target then
            for k,item in pairs(ents) do
                if item and item:HasTag("chest") and item.components.container and not item.components.container:IsEmpty() then
                    -- Look only for honey things in chests on first pass
                    local foodstuffs = nil
                    if honeypass then
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end)
                    else
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end)
                    end
                    if foodstuffs then
                        target = item
                        break
                    end
                end
            end
        end

        if target then
            return BufferedAction(inst, target, ACTIONS.HAMMER)
        end

        if not target then
            for k,item in pairs(ents) do
                if item and item:HasTag("backpack") and
                    item.components.container and not 
                    item.components.container:IsEmpty() and not 
                    item.components.inventoryitem:IsHeld() then
                     -- Look only for honey things in the backpack on first pass
                    local foodstuffs = nil
                    if honeypass then
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end)
                    else
                        foodstuffs = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end)
                    end
                    if foodstuffs then
                        target = foodstuffs
                        break
                    end
                end
            end
        end

        if target then
            return BufferedAction(inst, target, ACTIONS.STEAL)
        end

        --Berrybushes, carrots etc. (only valid for not honey pass)
        if not target and not honeypass then
            for k,item in pairs(ents) do
                if item.components.pickable and 
                item.components.pickable.caninteractwith and 
                item.components.pickable:CanBePicked() and
                ItemIsInList(item.components.pickable.product, VALID_FOODS) then
                    target = item
                    break
                end
            end
        end

        if target then
            return BufferedAction(inst, target, ACTIONS.PICK)
        end

        if honeypass == false then break end
        honeypass = false
    end
end

local function AttackHiveAction(inst)
    local hive = FindEntity(inst, SEE_STRUCTURE_DIST, function(guy) 
            return inst.components.combat:CanTarget(guy)
               and guy:HasTag("beehive") end)
    if hive then return BufferedAction(inst, hive, ACTIONS.ATTACK) end
end

local function ShouldFollowFn(inst)
    return not inst.NearPlayerBase(inst) and not inst.SeenBase
end

local function ShouldEatFoodFn(inst)
    return inst.NearPlayerBase(inst) or inst.SeenBase
end

local BeargerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BeargerBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

            WhileNode(function() return self.inst.CanGroundPound and self.inst.components.combat.target and not self.inst.components.combat.target:HasTag("beehive") and 
            (distsq(self.inst:GetPosition(), self.inst.components.combat.target:GetPosition()) > 10*10 or self.inst.sg:HasStateTag("running")) end, 
                "Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),

            ChaseAndAttack(self.inst, 20, 60, nil, nil, true),

            WhileNode(function() return ShouldEatFoodFn(self.inst) end, "At Base",
                PriorityNode(
                {
                    DoAction(self.inst, EatFoodAction),
                    DoAction(self.inst, StealFoodAction),
                })),            

            DoAction(self.inst, EatFoodAction),
            DoAction(self.inst, StealFoodAction),
            DoAction(self.inst, AttackHiveAction),

            WhileNode(function() return ShouldFollowFn(self.inst) end, "Follow To Base",
                PriorityNode(
                {
                    --[[We want the bearger to follow the player]]
                    Follow(self.inst, function() return  GetPlayer() end, 0, 15, 20, false)
                })),

            StandStill(self.inst)
            --Wander(self.inst, function() return self.inst:GetPosition() end, 5),

        }, .25)
    
    self.bt = BT(self.inst, root)
         
end

function BeargerBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return BeargerBrain