require "behaviours/chaseandattack"
require "behaviours/chaseandram"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/faceentity"
require "behaviours/findlight"
require "behaviours/panic"

local RUN_AWAY_DIST = 10
local SEE_FOOD_DIST = 10
local SEE_TARGET_DIST = 6

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 3
local MAX_FOLLOW_DIST = 8

local MAX_CHASE_DIST = 7
local MAX_CHASE_TIME = 8
local MAX_WANDER_DIST = 32

local START_RUN_DIST = 8
local STOP_RUN_DIST = 12

local AVOID_PROJECTILE_ATTACKS = false

local MAX_CHARGE_CHASE_TIME = 5
local MAX_CHARGE_DIST = 25
local CHASE_GIVEUP_DIST = 10
local MAX_CHARGE_ATTACKS = 2 -- actually one, chase-and-attack uses >= instead of just >

local ShamblerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function ShamblerBrain:OnStart()
	local root = PriorityNode({
		FaceEntity(self.inst, function() return GetPlayer() end, function() return true end),
	}, 1)

	self.bt = BT(self.inst, root)
end

function ShamblerBrain:OnInitializationComplete()
	self.inst.components.knownlocations:RememberLocation("home",
		Point(self.inst.Transform:GetWorldPosition()))
end

return ShamblerBrain
