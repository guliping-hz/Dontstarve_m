
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wx78.zip"),
	Asset("SOUND", "sound/wx78.fsb")    
}

local prefabs = 
{
	"sparks"
}
--hunger, health, sanity
local function applyupgrades(inst)

	local max_upgrades = 15
	local upgrades = math.min(inst.level, max_upgrades)

	local hunger_percent = inst.components.hunger:GetPercent()
	local health_percent = inst.components.health:GetPercent()
	local sanity_percent = inst.components.sanity:GetPercent()

	inst.components.hunger.max = math.ceil(TUNING.WX78_MIN_HUNGER + upgrades* (TUNING.WX78_MAX_HUNGER - TUNING.WX78_MIN_HUNGER)/max_upgrades)
	inst.components.health.maxhealth = math.ceil(TUNING.WX78_MIN_HEALTH + upgrades* (TUNING.WX78_MAX_HEALTH - TUNING.WX78_MIN_HEALTH)/max_upgrades)
	inst.components.sanity.max = math.ceil(TUNING.WX78_MIN_SANITY + upgrades* (TUNING.WX78_MAX_SANITY - TUNING.WX78_MIN_SANITY)/max_upgrades)

	inst.components.hunger:SetPercent(hunger_percent)
	inst.components.health:SetPercent(health_percent)
	inst.components.sanity:SetPercent(sanity_percent)
	
end

local function oneat(inst, food)
	
	if food and food.components.edible and food.components.edible.foodtype == "GEARS" then
		--give an upgrade!
		inst.level = inst.level + 1
		applyupgrades(inst)	
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		inst.HUD.controls.status.heart:PulseGreen()
		inst.HUD.controls.status.stomach:PulseGreen()
		inst.HUD.controls.status.brain:PulseGreen()
		
		inst.HUD.controls.status.brain:ScaleTo(1.3,1,.7)
		inst.HUD.controls.status.heart:ScaleTo(1.3,1,.7)
		inst.HUD.controls.status.stomach:ScaleTo(1.3,1,.7)
	end
end

local function onupdate(inst, dt)
	inst.charge_time = inst.charge_time - dt
	if inst.charge_time <= 0 then
		inst.charge_time = 0
		if inst.charged_task then
			inst.charged_task:Cancel()
			inst.charged_task = nil
		end
		inst.SoundEmitter:KillSound("overcharge_sound")
		inst.charged_task = nil
		inst.Light:Enable(false)
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED 
		inst.AnimState:SetBloomEffectHandle( "" )
		inst.components.temperature.mintemp = -20
		inst.components.talker:Say(GetString("wx78", "ANNOUNCE_DISCHARGE"))
		--inst.SoundEmitter:KillSound("overcharge_sound")
	else
    	local runspeed_bonus = .5
    	local rad = 3
    	if inst.charge_time < 60 then
    		rad = math.max(.1, rad * (inst.charge_time / 60))
    		runspeed_bonus = (inst.charge_time / 60)*runspeed_bonus
    	end

    	inst.Light:Enable(true)
    	inst.Light:SetRadius(rad)
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*(1+runspeed_bonus)
		inst.components.temperature.mintemp = 10
	end

end

local function onpreload(inst, data)
	if data then
		if data.level then
			inst.level = data.level
			applyupgrades(inst)
			--re-set these from the save data, because of load-order clipping issues
			if data.health and data.health.health then inst.components.health.currenthealth = data.health.health end
			if data.hunger and data.hunger.hunger then inst.components.hunger.current = data.hunger.hunger end
			if data.sanity and data.sanity.current then inst.components.sanity.current = data.sanity.current end
			inst.components.health:DoDelta(0)
			inst.components.hunger:DoDelta(0)
			inst.components.sanity:DoDelta(0)
		end
	end

end

local function onload(inst, data)
	if data then

		if data.charge_time then
			inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

			onupdate(inst, 0)
			inst.charged_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
		end

	end
end

local function onsave(inst, data)
	data.level = inst.level
	data.charge_time = inst.charge_time
end

local function onlightingstrike(inst)
	if inst.components.health and not inst.components.health:IsDead() then
		local protected = false
	    if GetPlayer().components.inventory:IsInsulated() then
	        protected = true
	    end

	    if not protected then
			inst.charge_time = inst.charge_time + TUNING.TOTAL_DAY_TIME*(.5 + .5*math.random())

			inst.sg:GoToState("electrocute")
			inst.components.health:DoDelta(TUNING.HEALING_SUPERHUGE,false,"lightning")
			inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
			inst.components.talker:Say(GetString("wx78", "ANNOUNCE_CHARGE"))

			inst.SoundEmitter:KillSound("overcharge_sound")
			inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/charged", "overcharge_sound")
			inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
			
			if not inst.charged_task then
				onupdate(inst, 0)
				inst.charged_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
			end
		else
			inst:PushEvent("lightningdamageavoided")
		end
	end
end

local function dorainsparks(inst, dt)

    if (inst.components.moisture and inst.components.moisture:GetMoisture() > 0) then
    	inst.spark_time = inst.spark_time - dt

    	if inst.spark_time <= 0 then
    		
    		--GetClock():DoLightningLighting()
    		inst.spark_time = 3+math.random()*2

    		local pos = Vector3(inst.Transform:GetWorldPosition())
    		local damage = nil

    		-- Raining, no moisture-giving equipment on head, and moisture is increasing. Pro-rate damage based on waterproofness.
    		if GetSeasonManager():IsRaining() and inst.components.inventory:GetEquippedMoistureRate(EQUIPSLOTS.HEAD) <= 0 and inst.components.moisture:GetDelta() > 0 then
	    		local waterproofmult = (inst.components.moisture and inst.components.moisture.sheltered and inst.components.inventory) and (1 - (inst.components.inventory:GetWaterproofness() + inst.components.moisture.shelter_waterproofness)) or (inst.components.inventory and (1 - inst.components.inventory:GetWaterproofness()) or 1)
	    		damage = waterproofmult > 0 and math.min(TUNING.WX78_MIN_MOISTURE_DAMAGE, TUNING.WX78_MAX_MOISTURE_DAMAGE * waterproofmult) or 0
	    		inst.components.health:DoDelta(damage, false, "rain")
				pos.y = pos.y + 1 + math.random()*1.5
	    	else -- We have moisture-giving equipment on our head or it is not raining and we are just passively wet (but drying off). Do full damage.
	    		if inst.components.moisture:GetDelta() >= 0 then -- Moisture increasing (wearing something moisturizing)
	    			inst.components.health:DoDelta(TUNING.WX78_MAX_MOISTURE_DAMAGE, false, "water")
	    		else -- Drying damage
	    			inst.components.health:DoDelta(TUNING.WX78_MOISTURE_DRYING_DAMAGE, false, "water")
	    		end
				pos.y = pos.y + .25 + math.random()*2
	    	end
			
			if not damage or (damage and damage < 0) then
				local spark = SpawnPrefab("sparks")
				spark.Transform:SetPosition(pos:Get())
			end
    	end
    end

end

local fn = function(inst)
	inst.level = 0
	inst.charge_time = 0
	inst.spark_time = 3

	inst.components.eater.ignoresspoilage = true
	table.insert(inst.components.eater.foodprefs, "GEARS")
	table.insert(inst.components.eater.ablefoods, "GEARS")
	inst.components.eater:SetOnEatFn(oneat)
	applyupgrades(inst)

	inst.components.playerlightningtarget:SetHitChance(1)
	inst.components.playerlightningtarget:SetOnStrikeFn(onlightingstrike)
	inst:AddTag("electricdamageimmune") --This is for combat, not lightning strikes

    inst.Light:Enable(false)
	inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.75)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235/255,121/255,12/255)
	
	inst.OnLongUpdate = function(inst, dt) 
		inst.charge_time = math.max(0, inst.charge_time - dt)
	end

	inst:DoPeriodicTask(1/10, function() dorainsparks(inst, 1/10) end)
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
end


return MakePlayerCharacter("wx78", prefabs, assets, fn) 
