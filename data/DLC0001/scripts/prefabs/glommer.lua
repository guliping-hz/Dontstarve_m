require("brains/glommerbrain")
require "stategraphs/SGglommer"

local assets=
{
	Asset("ANIM", "anim/glommer.zip"),
}

local prefabs = 
{
	"glommerfuel",
	"glommerwings",
	"monstermeat",
}

SetSharedLootTable('glommer',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'glommerwings',			1.00},
    {'glommerfuel',				1.00},
    {'glommerfuel',				1.00},
})

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) 
    and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) 
    and GetWorld().components.clock:GetMoonPhase() ~= "full"
end

local function CalcSanityAura(inst, observer)
	return TUNING.SANITYAURA_TINY
end

local function LeaveWorld(inst)
    inst:Remove()
end

local function OnEntitySleep(inst)
	if inst.ShouldLeaveWorld then
		LeaveWorld(inst)
	end
end

local function OnSave(inst, data)
	data.ShouldLeaveWorld = inst.ShouldLeaveWorld
end

local function OnLoad(inst, data)
	if data then
		inst.ShouldLeaveWorld = data.ShouldLeaveWorld
	end
end

local function OnSpawnFuel(inst, fuel)
	inst.sg:GoToState("goo", fuel)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()

	inst.DynamicShadow:SetSize(2, .75)
	inst.Transform:SetFourFaced()

 	MakeGhostPhysics(inst, 1, .5)

 	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("glommer.png")
	minimap:SetPriority(5)

    inst.AnimState:SetBank("glommer")
    inst.AnimState:SetBuild("glommer")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("companion")
	inst:AddTag("glommer")
	inst:AddTag("flying")
    inst:AddTag("cattoyairborne")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("follower")
	inst:AddComponent("health")
	inst:AddComponent("combat")
	inst:AddComponent("knownlocations")
	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('glommer') 

	inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

	inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawnFuel)
    inst.components.periodicspawner.prefab = "glommerfuel"
    inst.components.periodicspawner.basetime = TUNING.TOTAL_DAY_TIME * 2
    inst.components.periodicspawner.randtime = TUNING.TOTAL_DAY_TIME * 2
    inst.components.periodicspawner:Start()
	
    local brain = require("brains/glommerbrain")
    inst:SetBrain(brain)
    inst:SetStateGraph("SGglommer")

    MakeMediumFreezableCharacter(inst, "glommer_body")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep

	return inst
end


return Prefab("common/creatures/glommer", fn, assets, prefabs)