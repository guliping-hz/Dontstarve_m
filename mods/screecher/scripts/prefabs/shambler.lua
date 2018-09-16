local assets = 
{
	Asset("ANIM", "exportedanim/shambler_build.zip"),
	Asset("ANIM", "exportedanim/shambler_eat.zip"),
	Asset("ANIM", "exportedanim/shambler_approach.zip"),

	Asset("SOUND", "sound/merm.fsb"),
}

local function keeptargetfn(inst, target)
   return inst.components.agitation.value > 0
		  and target
          and target.components.combat
          and target.components.health
          and not target.components.health:IsDead()
end

local function NormalRetarget(inst)
	if inst.components.agitation.value <= 0 then
		return nil
	end
    local targetDist = TUNING.SHAMBLER_TARGET_DIST
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, targetDist, {"character", "prey"})
	local target = ents[1]
	return target

end

local function SmokeScreen(inst)
	local fx = SpawnPrefab("statue_transition_2")
	if fx then
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx.AnimState:SetScale(1,2,1)
	end
	fx = SpawnPrefab("statue_transition")
	if fx then
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx.AnimState:SetScale(1,1.5,1)
	end
end

local function Disappear(inst, disappear_sound)
	GetPlayer():PushEvent("unsawshambler")
	print(">>>disappearing")
	inst.SoundEmitter:KillSound("attackscreech")
    GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("colour_cubes/screecher_cc.tex"))
    inst.SoundEmitter:KillSound("screetch_approach")
   	GetPlayer():PushEvent("change_breathing", {intensity = 3, duration=5})

   	GetPlayer().HUD.shamblerblockmap = false

	--SmokeScreen(inst)
	local flashlightent = GetPlayer().FlashlightEnt()
	if flashlightent then
		local flicker = flashlightent.components.flicker
		if flicker then
			flicker:OneBlackFrame()
		end
	end

	if disappear_sound then
		inst.SoundEmitter:PlaySound(disappear_sound)
	end

	local encountermgr = GetPlayer().components.scarymodencountermanager
	if encountermgr then
		encountermgr:RemoveShambler(inst)
	end
	local flashlightent = GetPlayer().FlashlightEnt()
	if flashlightent then
		flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(1)
	end
end

local function Blink(inst, player, offset)
	GetPlayer():PushEvent("unsawshambler")
	print(">>>blinking")
	local o = offset or 10
	--SmokeScreen(inst)

	GetPlayer().HUD.shamblerblockmap = false

	local angle = inst:GetAngleToPoint(player:GetPosition())
	local pt = FindWalkableOffset(player:GetPosition(), angle*DEGREES, o, 20, true, true)
	inst.Transform:SetPosition((player:GetPosition()+pt):Get())
	if inst.sg:HasStateTag("canrotate") then
		inst:FacePoint(Point(player.Transform:GetWorldPosition()))
	end
end

local function TransformWorse(inst)
	inst.sg:GoToState("transform_to_meanie")
	inst.components.locomotor.runspeed = TUNING.SHAMBLER_RUN_SPEED
	inst.components.combat:TryRetarget()
end

local function TransformNicer(inst)
	inst.sg:GoToState("transform_to_shadow")
	inst.components.locomotor.runspeed = TUNING.SHAMBLER_APPROACH_SPEED
end

local function OnObserverTurnToPlayer(inst, override_timedelay, override_alerttime)
	if inst.has_turned_to_player then
		return
	end
	inst.has_turned_to_player = true
	
	--[[local flashlightent = GetPlayer().FlashlightEnt()
	if flashlightent then
		local flicker = flashlightent.components.flicker
		if flicker then
			flicker:OneBlackFrame()
		end
	end]]

	if inst.components.shamblermodes.mode ~= "observer" then
		inst:Remove()
		return
	end

	inst.sg:GoToState("idle_eating_spotted")
	local TIME_DELAY = override_timedelay or 30*FRAMES
	local ALERT_TIME = override_alerttime or TUNING.SHAMBLER_OBSERVER_ALERT_TIME
	inst:DoTaskInTime(TIME_DELAY, function()
		GetPlayer().HUD:ShowOwlFace(ALERT_TIME-TIME_DELAY)
	end)
	inst:DoTaskInTime(ALERT_TIME, function()
		local camper = SpawnPrefab("newly_eaten_camper")
		camper.Transform:SetPosition(inst.Transform:GetWorldPosition())
		Disappear(inst, "scary_mod/music/shamble_flash")
		local encountermgr = GetPlayer().components.scarymodencountermanager
		if encountermgr then
			encountermgr:AvoidedShambler(inst)
		end
	end)
end

local function ShamblerDistanceRatio(shambler)
	local playerpos = GetPlayer():GetPosition()
	local dist = playerpos:Dist(shambler:GetPosition())
	--if dist < 0 then dist = 0 end
	if dist > (TUNING.MAX_LIGHT_DISTANCE_FOR_CAM * 1.3) then dist = (TUNING.MAX_LIGHT_DISTANCE_FOR_CAM *1.3) end
	return dist / TUNING.MAX_LIGHT_DISTANCE_FOR_CAM
end
	
local function ShamblerAngleOffset(shambler)
	local player = GetPlayer()
	local angle = player:GetAngleToPoint(shambler:GetPosition())
	angle = angle - player.Transform:GetRotation()
	while angle > 180 do angle = angle - 360 end
	while angle < -180 do angle = angle + 360 end
	return angle
end


local modes = {
		["none"] = {
			flashed = function(inst, data)
			end,
			lit = function(inst, data)
				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SawShambler(inst)
				end
			end,
			unlit = function(inst, data)
			end,
			newlyagitated = function(inst, data)
			end,
			agitated = function(inst, data)
			end,
			calmed = function(inst, data)
			end,
			onnear = function(inst)
			end,
		},
		["observer"] = {
			flashed = function(inst, data)
				GetPlayer():PushEvent("sawshambler", ShamblerAngleOffset(inst))
			end,
			lit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = true
				inst.components.agitation:DoDelta(1*data.dt)

				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SawShambler(inst)
				end

				--pushes the camera up to look at him
				GetPlayer():PushEvent("seeingshambler", ShamblerDistanceRatio(inst))
			end,
			unlit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = false
				GetPlayer():PushEvent("unsawshambler")
				local flashlightent = GetPlayer().FlashlightEnt()
				if flashlightent then
					flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(1)
				end
			end,
			newlyagitated = function(inst, data)
				OnObserverTurnToPlayer(inst)
			end,
			agitated = function(inst, data)
			end,
			calmed = function(inst, data)
			end,
			onnear = function(inst)
				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					if encountermgr.want_shambler then
						-- we haven't seen a shambler yet, remove this guy coz he's too close.
						encountermgr:RemoveShambler(inst)
					else
						-- we've already seen a shambler, presumably this guy, so he should scare.
						OnObserverTurnToPlayer(inst, 5*FRAMES, 15*FRAMES)
					end
				end
			end,
		},
		["teaser"] = {
			flashed = function(inst, data)
				GetPlayer():PushEvent("sawshambler", ShamblerAngleOffset(inst))
			end,
			lit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = true
				inst.components.agitation:DoDelta(1*data.dt)

				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SawShambler(inst)
				end

				-- local flashlightent = GetPlayer().FlashlightEnt()
				-- if flashlightent then
				-- 	flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER)
				-- 	flashlightent.components.flicker:ForceStartFlicker(TUNING.SHAMBLER_FIRST_FLASH_FLICKER_CHANCE)
				-- end
				
				--pushes the camera up to look at him

				GetPlayer():PushEvent("seeingshambler", ShamblerDistanceRatio(inst))

				if not inst.components.shamblermodes.hasbeenlit then
					inst.SoundEmitter:PlaySound("scary_mod/music/shamble_flash")
				end
				inst.components.shamblermodes.hasbeenlit = true

			end,
			unlit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = false
				GetPlayer():PushEvent("unsawshambler")
				if inst.components.agitation:CanDisappear() then
					Disappear(inst)
					inst.SoundEmitter:KillSound("attackscreech")
					local encountermgr = GetPlayer().components.scarymodencountermanager
					if encountermgr then
						encountermgr:AvoidedShambler(inst)
					end
				else
					if math.random() > 0.5 then
						Blink(inst, GetPlayer(), 15)
					end
				end
				local flashlightent = GetPlayer().FlashlightEnt()
				if flashlightent then
					flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(1)
				end
			end,
			newlyagitated = function(inst, data)
				inst.components.agitation:BecomeCalm()
				inst.components.shamblermodes:SetKind("killer")

				--tell the manager we've seen a killer
				GetPlayer().components.scarymodencountermanager.hasseenkiller = true
			end,
			agitated = function(inst, data)
			end,
			calmed = function(inst, data)
			end,
			onnear = function(inst)

				local flashlightent = GetPlayer().FlashlightEnt()
				if flashlightent then
					local dimmer = flashlightent.components.lightfueldimmer
					if dimmer then
						local total_amount = TUNING.MAX_FUEL_LEVEL * TUNING.SHAMBLER_TEASE_FUEL_REMOVE_PCT
						local remain_amount = dimmer.fuellevel * TUNING.SHAMBLER_TEASE_FUEL_REMOVE_REMAIN_PCT
						dimmer:RemoveFuel(total_amount + remain_amount)
					end
				end
				Disappear(inst)
				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SufferedShambler(inst)
				end
				
			end,
		},
		["killer"] = {
			flashed = function(inst, data)
				local flashlight = data.flashlight_ent
				if not flashlight then return end

				local flicker = flashlight.components.flicker
				if not flicker then return end
				
				-- if data.forceflicker then
				-- 	if inst.components.agitation.value == 0 then
				-- 	else
				-- 		flicker:ForceStartFlicker(TUNING.SHAMBLER_FIRST_FLASH_FLICKER_CHANCE)
				-- 	end
				-- end

				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SawShambler(inst)
				end

				--inst.components.agitation:DoDelta(1)
				GetPlayer():PushEvent("sawshambler", ShamblerAngleOffset(inst))
			end,
			lit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = true
				inst.components.agitation:DoDelta(1*data.dt)
				local flashlight = data.flashlight_ent
				if not flashlight then return end

				local flicker = flashlight.components.flicker
				if not flicker then return end

				flicker:ForceStartFlicker(TUNING.SHAMBLER_FIRST_FLASH_FLICKER_CHANCE)

				if not inst.components.agitation:IsAgitated() and not inst.sg:HasStateTag("taunt") then
					inst.sg:GoToState("killer_taunt")
				end

				local encountermgr = GetPlayer().components.scarymodencountermanager
				if encountermgr then
					encountermgr:SawShambler(inst)
				end

				local flashlightent = GetPlayer().FlashlightEnt()
				if flashlightent then
					--flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER, 0.05)
					flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER)
				end

				GetPlayer():PushEvent("seeingshambler", ShamblerDistanceRatio(inst))

				if not inst.components.shamblermodes.hasbeenlit then
					inst.SoundEmitter:PlaySound("scary_mod/music/shamble_flash")
				end
				inst.components.shamblermodes.hasbeenlit = true

				-- Because we should only die to this guy if we can see him, we'll poll while lit for
				-- death instead of using the onnear event
				--
				if inst.components.playerprox:IsPlayerClose() then
					inst.inevitable_death = true
					local flashlight_ent = GetPlayer().FlashlightEnt()
					if flashlight_ent then
						local lightfueldimmer = flashlight_ent.components.lightfueldimmer
						if lightfueldimmer then
							lightfueldimmer:RemoveFuel(lightfueldimmer.fuellevel)
						end
					end
					
					GetPlayer().SoundEmitter:KillAllSounds()

					local player = GetPlayer()
					local x,y,z = player.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x,y,z, 200, {"finale"})
					for k, v in pairs(ents) do
						v.SoundEmitter:KillSound("attackscreech"..tostring(v.GUID))
						v:Remove()
					end
					inst.SoundEmitter:KillSound("attackscreech")

					local encountermgr = GetPlayer().components.scarymodencountermanager
					if encountermgr and encountermgr.isfinaldeath then
						encountermgr:DoFinaleDeath("killer near")
					elseif encountermgr then
						encountermgr:DoBeforeFinaleDeath("killer near")
					end
				end
			end,
			unlit = function(inst, data)
				GetPlayer().HUD.shamblerblockmap = false
				GetPlayer():PushEvent("unsawshambler")
				if not inst.inevitable_death and not inst:HasTag("finale") then
					Disappear(inst)
					inst.SoundEmitter:KillSound("attackscreech")
					local encountermgr = GetPlayer().components.scarymodencountermanager
					if encountermgr then
						encountermgr:AvoidedShambler(inst)
					end
					local flashlightent = GetPlayer().FlashlightEnt()
					if flashlightent then
						flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(1)
					end
				end
			end,
			newlyagitated = function(inst, data)
				inst.sg:GoToState("killer_approach")
			end,
			agitated = function(inst, data)
			end,
			calmed = function(inst, data)
			end,
			onnear = function(inst)
				if not inst.components.shamblermodes.hasbeenlit and not inst.inevitable_death then
					-- He's toooo close, the scare will be lame. Just abort
					local encountermgr = GetPlayer().components.scarymodencountermanager
					if encountermgr then
						encountermgr:RemoveShambler(inst)
					end
				end
			end,
			onupdate = function(inst, dt)
				if GetPlayer().components.health:IsDead() then
					return
				end
				
				if inst:HasTag("finale") then
					inst.components.agitation:DoDelta(dt)
				end

				if not inst.components.agitation:IsAgitated() then
					return
				end

				local offset = inst:GetPosition() - GetPlayer():GetPosition()
				local distance = offset:Length()
				distance = distance - TUNING.SHAMBLER_KILLER_APPROACH_SPEED*dt
				distance = distance > 0 and distance or 0
				offset = offset:GetNormalized() * distance
				local pos = GetPlayer():GetPosition() + offset
				inst.Transform:SetPosition( pos:Get() )
			end,
			flicker = function(inst, data)
				--[[
				if not inst.components.agitation:IsAgitated() or GetPlayer().components.health:IsDead() then
					return
				end
				if data.lit == false then
					local offset = inst:GetPosition() - GetPlayer():GetPosition()
					local distance = offset:Length()
					distance = distance - TUNING.SHAMBLER_KILLER_APPROACH_SPEED
					distance = distance > 0 and distance or 0
					offset = offset:GetNormalized() * distance
					local pos = GetPlayer():GetPosition() + offset
					inst.Transform:SetPosition( pos:Get() )
				elseif data.lit == true then
					-- Play the shambler flash sound
					inst.SoundEmitter:PlaySound("scary_mod/music/shamble_flash")
				end
				]]
			end,
		},

	}


local function create_shambler(Sim)
	local inst = CreateEntity()

	inst:AddTag("monster")
	inst:AddTag("shambler")
	inst:AddTag("scarytoprey")
	inst:AddTag("hostile")

	inst.entity:AddTransform()
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 10, .5)

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("shambler")
    inst.AnimState:SetBuild("shambler_build")

	inst.entity:AddSoundEmitter()
	
	if TUNING.IS_FPS then
		inst.Transform:SetScale(1.5,1.5,1.5)	
	end

	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(1.5, .5)	

	inst:AddComponent("locomotor")
	inst.components.locomotor:SetSlowMultiplier(1)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorecreep = true }
	inst.components.locomotor.walkspeed = TUNING.SHAMBLER_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.SHAMBLER_APPROACH_SPEED

	MakeMediumBurnableCharacter(inst, "body")
	--MakeMediumFreezableCharacter(inst, "body")
	inst:AddComponent("health")
	inst.components.health:SetInvincible(true)

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "body"
	inst.components.combat:SetDefaultDamage(TUNING.SHAMBLER_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.SHAMBLER_ATTACK_PERIOD)
	inst.components.combat:SetRange(TUNING.SHAMBLER_ATTACK_RANGE)
	inst.components.combat:SetKeepTargetFunction(keeptargetfn)
	inst.components.combat:SetRetargetFunction(0.1, NormalRetarget)
	inst:ListenForEvent("onattackother", function(inst, data)
		-- magic flag, treat with care!
		inst.justdidanattack = true
	end)


	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_MONSTER

	inst:AddComponent("knownlocations")


	inst:AddComponent("flashlightwatcher")
	inst.components.flashlightwatcher.makeflickeronlit = true

	inst:AddComponent("agitation")
	inst.components.agitation:SetThreshold(5)

	inst:AddComponent("shamblermodes")
	inst.components.shamblermodes:SetModeData(modes)
	
	-- gjans: Disabling this so we can precisely control the aggro timing of shamblers
	--[[
	inst:ListenForEvent("setminaggrolevel", function(player, data) --This event gets broadcasted every frame, so aggro will always be current
		inst.components.agitation.minvalue = data.aggro
		if inst.components.agitation.value < inst.components.agitation.minvalue then
			inst.components.agitation.value = inst.components.agitation.minvalue
		end
	end, GetPlayer())
	]]

	inst:AddComponent("playerprox")
	inst.components.playerprox.onnear = function()
		inst.components.shamblermodes:OnNear()
	end

	-- Set the intial guy into 'observer' mode
	-- inst.components.shamblermodes:Set_Observer()

	local brain = require "brains/shamblerbrain"
	inst:SetBrain(brain)
	inst:SetStateGraph("SGshambler")

	return inst
end

function create_shambler_teaser(Sim)
	local inst = create_shambler(Sim)
	inst.components.shamblermodes:SetKind("teaser")
	inst:SetPrefabName("shambler")
	return inst
end

function create_shambler_killer(Sim)
	local inst = create_shambler(Sim)
	inst.components.shamblermodes:SetKind("killer")
	inst:SetPrefabName("shambler")
	return inst
end

return Prefab("monsters/shambler", create_shambler, assets, nil),
	   Prefab("monsters/shambler_teaser", create_shambler_teaser, assets, nil),
	   Prefab("monsters/shambler_killer", create_shambler_killer, assets, nil)
