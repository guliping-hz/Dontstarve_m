local assets = {

	Asset("ANIM", "exportedanim/camper1_basic.zip"),
	Asset("ANIM", "exportedanim/camper1_basic_build.zip"),
	Asset("ANIM", "exportedanim/camper2_basic.zip"),
	Asset("ANIM", "exportedanim/camper2_basic_build.zip"),
}

local prefabs =
{
    "flashlight_lightpiece",
    "scary_shadow",
}   

local function OnActivate(inst)
	if inst.components.highlight then
		inst.components.highlight:UnHighlight()
	end
	inst:RemoveTag("CLICK")
	inst:RemoveComponent("activatable")
	inst.components.health:SetInvincible(false)

	local player = GetPlayer()
	if player and player.components.scarymodencountermanager then
		
		--First camper (runner)
		if inst.campertype == 1 then
			player:PushEvent("firstcamperactivated") -- let the manager know we've activated this guy

		--Second camper (dead guy)
		elseif inst.campertype == 2 then
			player:PushEvent("secondcamperactivated") -- let the manager know we've activated this guy

		--Third camper (cowerer)
		elseif inst.campertype == 3 then
			inst.SoundEmitter:PlaySound("scary_mod/music/anticipate")
			inst:DoTaskInTime(2, function() 
				inst:RemoveTag("tbdcamper")
				inst:AddTag("cowercamper")
				inst.sg:GoToState("continuecower")
				inst.components.talker:Say("I took Carly's face so he wouldn't.", 2.5, false)
			end)
		end
	end
end

local function create_camper(Sim, campertype)
	local inst = CreateEntity()

	inst.campertype = campertype

	inst:AddTag("campergeneral")
	inst:AddTag("tbdcamper")
	inst:AddTag("character")
	inst:AddTag("CLICK")

	inst.name = "???"

	inst:ListenForEvent("removecampername", function(it, data) 
		if data.camper == inst then
			inst.name = ""
		end
	end, GetPlayer())

	inst.entity:SetCanSleep(false)

	inst.entity:AddTransform()

	if TUNING.IS_FPS then
		inst.Transform:SetScale(1.5,1.5,1.5)
	end

	MakeObstaclePhysics(inst, .5)

	inst.entity:AddAnimState()
	inst.AnimState:SetBank("Camper")
	inst.AnimState:SetBuild("camper2_basic_build")

	inst.entity:AddSoundEmitter()
		
	inst.entity:AddLightWatcher()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(1.5, .5)	

	inst:AddComponent("locomotor")
	inst.components.locomotor:SetSlowMultiplier(1)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorecreep = false }
	inst.components.locomotor.walkspeed = TUNING.CAMPER_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.CAMPER_WALK_SPEED

	inst:AddComponent("health")
	inst.components.health:SetInvincible(true)
	inst.components.health:SetMaxHealth(TUNING.CAMPER_HEALTH)

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = 0

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.distance = TUNING.CAMPER_ACTIVATE_DISTANCE

	inst.playerfirepit = nil
	inst:ListenForEvent("killallsounds", function()
        inst.SoundEmitter:KillSound("cowerfemale")
        inst.SoundEmitter:KillSound("cowermale")
        inst.SoundEmitter:KillSound("blooddrip")
    end, GetPlayer())

	inst:AddComponent("talker")
    inst.components.talker.colour = Vector3(0.4, 0.4, 0.5)
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.fontsize = 28
    inst.components.talker.offset = Vector3(0,-520,0)

    inst:AddComponent("playerprox")

	inst:SetStateGraph("SGcamper")
	inst.sg:GoToState("echolocate")

	return inst
end

local function create_camper_runner(Sim)
	local inst = create_camper(Sim, 1)
	inst.nameoffset = 150

	inst.AnimState:SetBank("Camper")
	inst.AnimState:SetBuild("camper2_basic_build")

	inst.prevpos = Point(0, 0, 0)
	inst.hasdestination = false
	inst.Physics:ClearCollisionMask()

	-- disable her backpack until she runs
	inst:DoTaskInTime(0, function(inst)
		local pack = FindEntity(inst,15,function(guy) return guy.prefab == "note_diary1" end)
		if pack then
			pack.components.activatable.inactive = false
			pack:RemoveTag("CLICK")
		end
	end)

	return inst
end

local function create_camper_fake(Sim)
	local inst = create_camper(Sim, 2)
	inst.nameoffset = 250

	inst.AnimState:SetBank("Camper")
	inst.AnimState:SetBuild("camper1_basic_build")

    inst:AddComponent("scaryshadow")
    inst:DoTaskInTime(0, function()
        inst.components.scaryshadow:SpawnShadow(inst, 2)
    end)

    inst.reveal = false
    inst.idlefinished = false
    inst.donereveal = false

    inst.SoundEmitter:PlaySound("scary_mod/stuff/blood_drip_LP", "blooddrip")

	return inst
end

local function create_camper_cowerer(Sim)
	local inst = create_camper(Sim, 3)
	inst.nameoffset = 150

	inst.AnimState:SetBank("Camper")
	inst.AnimState:SetBuild("camper2_basic_build")

	inst.playerhasapproached = false
	inst.components.playerprox:SetDist(TUNING.CAMPER_PROX_NEAR_DISTANCE, TUNING.CAMPER_PROX_FAR_DISTANCE)
	inst.components.playerprox.onnear = function()
		inst.playerhasapproached = true
	end
	inst.components.playerprox.onfar = function()
		if inst.playerhasapproached then
			GetPlayer():PushEvent("thirdcamperdead")
			inst:RemoveTag("CLICK")
			inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream")

			inst.components.health:SetInvincible(false)
			inst.components.health:Kill()
		end
	end

	return inst
end

return Prefab("common/camper", create_camper, assets, nil),
	Prefab("common/camper_runner", create_camper_runner, assets, nil),
	Prefab("common/camper_fake", create_camper_fake, assets, nil)
	--jcheng: no longer doing the cowerer guy. Not adding much.
	--Prefab("common/camper_cowerer", create_camper_cowerer, assets, nil),
