require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"


local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 12
local TARGET_FOLLOW_DIST = 6

local MAX_WANDER_DIST = 3


local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end


local PackbotBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DoOrders(inst)
    local orders = inst.components.ordertaker.orders
    local action = BufferedAction(inst, orders.target, orders.action)
    
    table.insert(action.onsuccess, orders.onsuccess)
    table.insert(action.onfail, orders.onfail)
    action.testfn = orders.testfn
    
    return action 
end

function PackbotBrain:OnStart()
    local root = 
    PriorityNode({
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return self.inst.components.ordertaker.orders.target end, "HasOrders", DoAction(self.inst, DoOrders)),
        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
        
    }, .25)
    self.bt = BT(self.inst, root)
end

return PackbotBrain