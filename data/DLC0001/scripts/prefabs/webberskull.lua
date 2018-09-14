local assets = 
{
	Asset("ANIM", "anim/skulls.zip"),
	Asset("ANIM", "anim/webber.zip"),
}

local prefabs = 
{
	"webber",
}

local function UnlockWebber(inst, target)
    inst:AddTag("lightningrod")
    inst.lightningpriority = 100

	local player = GetPlayer()
	player.profile:UnlockCharacter("webber")
	player.profile.dirty = true
	player.profile:Save()

	Sleep(0.5)

	GetWorld().components.seasonmanager:DoLightningStrike(inst:GetPosition())

	Sleep(0.1)

	local light = SpawnPrefab("chesterlight")

	local webber = SpawnPrefab("puppet_webber")
	webber.Physics:SetCapsule(1, 1)
	webber.Transform:SetPosition(inst:GetPosition():Get())
	light.Transform:SetPosition(inst:GetPosition():Get())
	light:TurnOn()
	webber.AnimState:PlayAnimation("sleep", true)
	webber.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	webber:DoTaskInTime(0, function(webber) webber.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/appear") end)

	Sleep(1)

	webber.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/hurt")
	webber.AnimState:PushAnimation("wakeup")
	webber:DoTaskInTime(41*FRAMES, function(webber) PlayFootstep(webber) end)
	webber:DoTaskInTime(72*FRAMES, function(webber) PlayFootstep(webber) end)
	webber:DoTaskInTime(89*FRAMES, function(webber) PlayFootstep(webber) end)
	webber.AnimState:PushAnimation("idle_loop", true)

	Sleep(4)

	webber.AnimState:PlayAnimation("jump")
	PlayFootstep(webber)

	Sleep(.61)
	
	webber.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/appear")
	webber:Remove()
	light:TurnOff()
	local fx = SpawnPrefab("maxwell_smoke")
	fx.Transform:SetPosition(inst:GetPosition():Get())

	inst:ResetGrave()

	Sleep(.5)

	for i = 1, 6 do		
		local spider = SpawnPrefab("spider")
		local spawnPoint = inst:GetPosition()
		spider.Transform:SetPosition(spawnPoint:Get())
		spider.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderExitLair")
		spider.sg:GoToState("taunt")
		spider.components.combat:SetTarget(target)
	end

	inst:RemoveTag("lightningrod")
	inst.lightningpriority = -100
end

local function StartUnlockSequence(inst, target)
	inst.UnlockSequence = inst:StartThread(function() UnlockWebber(inst, target) end) 
end

local function OnBury(inst, hole, doer)
	StartUnlockSequence(hole, doer)
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local snd = inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	anim:SetBank("skulls")
	anim:SetBuild("skulls")
	anim:PlayAnimation("f4")

	inst:AddTag("webberskull")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("skull_webber")
	inst:AddComponent("inspectable")
	inst:AddComponent("buryable")
	inst.components.buryable:SetOnBury(OnBury)

	return inst
end

return Prefab("common/inventory/webberskull", fn, assets, prefabs)