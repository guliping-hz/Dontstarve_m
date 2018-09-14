require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/siesta_canopy.zip"),
}


local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", true)
	end
end

local function onfinished(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("destroy")
		inst:ListenForEvent("animover", function(inst, data) inst:Remove() end)
		inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
		inst.persists = false
		inst:DoTaskInTime(16*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl") end)
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)
end


local function onsleep(inst, sleeper)

	if GetClock():IsDusk() or GetClock():IsNight() then
		local tosay = "ANNOUNCE_NONIGHTSIESTA"
		if GetWorld():IsCave() then
			tosay = "ANNOUNCE_NONIGHTSIESTA_CAVE"
		end
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
			return
		end
	end

	if inst:HasTag("fire") then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOSLEEPONFIRE"))
		end
		return
	end
	
	local hounded = GetWorld().components.hounded

	local danger = FindEntity(inst, 10, function(target, inst) 
		return 
			(target:HasTag("monster") and not target:HasTag("player") and not sleeper:HasTag("spiderwhisperer"))
			or (target:HasTag("monster") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer") and not target:HasTag("spider"))
			or (target:HasTag("pig") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer"))
			or (target.components.combat and target.components.combat.target == sleeper)
	end)
	
	if hounded and (hounded.warning or hounded.timetoattack <= 0) then
		danger = true
	end
	
	if danger then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSIESTA"))
		end
		return
	end

	if sleeper.components.hunger.current < TUNING.CALORIES_MED then
		sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOHUNGERSIESTA"))
		return
	end
	
	sleeper.components.health:SetInvincible(true)
	sleeper.components.playercontroller:Enable(false)

	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)

	inst:DoTaskInTime(1.2, function() 
		
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		
		if GetClock():IsDusk() or GetClock():IsNight() then
			local tosay = "ANNOUNCE_NONIGHTSIESTA"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NONIGHTSIESTA_CAVE"
			end
			if sleeper.components.talker then
				sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
				sleeper.components.health:SetInvincible(false)
				sleeper.components.playercontroller:Enable(true)
				return
			end
		end
		
		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE)
		end
		
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_MED, false, true)
		end
		
		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "siestahut", true)
		end
		
		if sleeper.components.temperature and sleeper.components.temperature.current > TUNING.TARGET_SLEEP_TEMP then
			sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP - 20)
		end

		local moisture_start = nil
		if sleeper.components.moisture and sleeper.components.moisture:GetMoisture() > 0 then
			moisture_start = sleeper.components.moisture.moisture
		end
		
		inst.components.finiteuses:Use()
		GetClock():MakeNextDusk()

		if moisture_start then
			sleeper.components.moisture.moisture = moisture_start - TUNING.SLEEP_MOISTURE_DELTA
			if sleeper.components.moisture.moisture < 0 then sleeper.components.moisture.moisture = 0 end
		end
		
		sleeper.components.health:SetInvincible(false)
		sleeper.components.playercontroller:Enable(true)
		sleeper.sg:GoToState("wakeup")	
	end)
	
	
	
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst:AddTag("tent")    
    
    MakeObstaclePhysics(inst, 1)    

    inst:AddTag("structure")
    anim:SetBank("siesta_canopy")
    anim:SetBuild("siesta_canopy")
    anim:PlayAnimation("idle", true)
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "siestahut.png" )
    
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SIESTA_CANOPY_USES)
    inst.components.finiteuses:SetUses(TUNING.SIESTA_CANOPY_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
	    
		    
	inst:AddComponent("sleepingbag")
	inst.components.sleepingbag.onsleep = onsleep
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent( "onbuilt", onbuilt)

	MakeLargeBurnable(inst, nil, nil, true)
	MakeLargePropagator(inst)

	inst.OnSave = onsave 
    inst.OnLoad = onload

    return inst
end

return Prefab( "common/objects/siestahut", fn, assets),
		MakePlacer( "common/siestahut_placer", "siesta_canopy", "siesta_canopy", "idle" ) 
