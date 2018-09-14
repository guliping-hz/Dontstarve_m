local assets=
{
	Asset("ANIM", "anim/goosemoose_nest.zip"),
}

local prefabs =
{
    "moose_nest_fx"
}

local function InitEgg(inst)
	inst.sg:GoToState("land")
	inst.EggHatched = false
    inst.components.timer:StartTimer("HatchTimer", TUNING.MOOSE_EGG_HATCH_TIMER)
end

local function OnSummonMoose(inst, guardian)
    local pt = guardian:GetPosition()
    pt.y = 20
    pt.x = pt.x + math.random()
    pt.z = pt.z + math.random()
    guardian.Transform:SetPosition(pt:Get())
    guardian.sg:GoToState("glide")
end

local function OnGuardianDeath(inst, guardian, cause)
	local herd = inst.components.herd.members
	for k,v in pairs(herd) do
		k.mother_dead = true
		k.components.locomotor:SetShouldRun(true)
        if cause and cause == GetPlayer().prefab then
            k.components.combat:SetTarget(GetPlayer())
        end
    end
end

local function OnDismissMoose(inst, guardian)
	guardian.shouldGoAway = true
end

local function OnSave(inst, data)
	data.EggHatched = inst.EggHatched
end

local function OnLoad(inst, data)
	inst.EggHatched = data.EggHatched
	if inst.EggHatched then
		inst.sg:GoToState("idle_empty")
	else
		inst.sg:GoToState("idle_full")
	end
end

local function OnTimerDone(inst, data)
    if data.name == "HatchTimer" then
        inst.sg:GoToState("crack")
    end
end

local function destroy(inst)
    local time_to_erode = 1
    local tick_time = TheSim:GetTickTime()

    inst:StartThread( function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
            ticks = ticks + 1
            Yield()
        end
        inst:Remove()
    end)
end

local function MakeWorkable(inst, bool)
    if bool then
        local function onhammered(inst, worker)
            inst.sg:GoToState("crack")
            inst.components.timer:StopTimer("HatchTimer")
            inst:MakeWorkable(false)
        end
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst.components.workable:SetOnWorkCallback(function(inst, worker) 
            if worker.components.combat then
                worker.components.combat:GetAttacked(inst, TUNING.MOOSE_EGG_DAMAGE, nil, "electric")
            end
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("hit")
            end
        end)
    else
        inst:RemoveComponent("workable")
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    local s = 1.33
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("goosemoose_nest")
    inst.AnimState:SetBuild("goosemoose_nest")
    inst.AnimState:PlayAnimation("nest")
  
    inst:AddComponent("inspectable")   
    inst:AddComponent("timer")
    inst:AddComponent("entitytracker")

    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("mossling")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd.updatepos = false
    inst.components.herd.onempty = destroy

    inst:AddComponent("guardian")
    inst.components.guardian.prefab = "moose"
    inst.components.guardian.onsummonfn = OnSummonMoose
    inst.components.guardian.ondismissfn = OnDismissMoose
    inst.components.guardian.onguardiandeathfn = OnGuardianDeath

    inst:AddTag("lightningrod")
    inst.lightningpriority = 2

    inst:AddComponent("named")
    inst.components.named.possiblenames = {STRINGS.NAMES["MOOSEEGG1"], STRINGS.NAMES["MOOSEEGG2"]}
    inst.components.named:PickNewName()
    inst:DoPeriodicTask(5, function(inst)
        inst.components.named:PickNewName()
    end)
    
    inst.MakeWorkable = MakeWorkable

    inst:SetStateGraph("SGmooseegg")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.InitEgg = InitEgg
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

return Prefab( "common/objects/mooseegg", fn, assets, prefabs)