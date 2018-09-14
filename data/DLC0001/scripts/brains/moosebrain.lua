require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/leash"


local TIME_BETWEEN_EATING = 3.5

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 500
local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30

local START_FACE_DIST = 15
local KEEP_FACE_DIST = 20

local BASE_TAGS = {"structure"}
local FOOD_TAGS = {"edible"}
local STEAL_TAGS = {"structure"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO"}

local function GoHome(inst)
    if inst.shouldGoAway and not inst.components.combat.target then
        local pos = inst:GetPosition()
        pos.y = 30
        return BufferedAction(inst, nil, ACTIONS.GOHOME)
    end
end

local function GetFaceTargetFn(inst)
    if inst.sg:HasStateTag("busy") then return end

    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)

    if inst.sg:HasStateTag("busy") then return false end

    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function LayEgg(inst)
    if not inst.components.entitytracker:GetEntity("egg") and inst.WantsToLayEgg then
        return BufferedAction(inst, nil, ACTIONS.LAYEGG)
    end
end

local MooseBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MooseBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.shouldGoAway end, "Go Away",
                DoAction(self.inst, GoHome)),

            Leash(self.inst, self.inst.components.knownlocations:GetLocation("landpoint"), 25, 3),

            ChaseAndAttack(self.inst),
            
            DoAction(self.inst, LayEgg),

            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),

            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("landpoint") end, 15),
        },1)
    
    self.bt = BT(self.inst, root)
         
end

function MooseBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return MooseBrain