local assets = 
{
	Asset("ANIM", "anim/firefighter.zip"),
	Asset("ANIM", "anim/firefighter_placement.zip"),
	Asset("ANIM", "anim/firefighter_meter.zip"),

}

local projectile_assets = 
{
	Asset("ANIM", "anim/firefighter_projectile.zip"),
}

local prefabs = 
{
	"firesuppressorprojectile",
	"splash_snow_fx",
	"collapse_small",
}


local YESTAGS = {"burnable"}
local NOTAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}

local function LaunchProjectile(inst, targetpos)
	--if not inst.canFire then return end
	local projectile = SpawnPrefab("firesuppressorprojectile")
	projectile.owner = inst
	projectile.Transform:SetPosition(inst:GetPosition():Get())
	projectile.components.complexprojectile:Launch(targetpos)
	--inst.canFire = false
	--inst.components.timer:StartTimer("Reload", TUNING.FIRESUPPRESSOR_RELOAD_TIME)
end

local function OnFindFire(inst, firePos)
	inst:PushEvent("putoutfire", {firePos = firePos})
end

local function ontimerdone(inst, data)
    if data.name == "Reload" then
        inst.canFire = true
    end
end

local function TurnOff(inst, instant)
	inst.on = false
	inst.components.firedetector:Deactivate()
	inst.components.fueled:StopConsuming()
	if instant then
		inst.sg:GoToState("idle_off")
	else
		inst.sg:GoToState("turn_off")
	end
end

local function TurnOn(inst, instant)
	inst.on = true
	local randomizedStartTime = POPULATING
	inst.components.firedetector:Activate(randomizedStartTime)
	inst.components.fueled:StartConsuming()
	if instant then
		inst.sg:GoToState("idle_on")
	else
		inst.sg:GoToState("turn_on")
	end
end

local function OnFuelEmpty(inst)
	inst.components.machine:TurnOff()
end

local function OnFuelSectionChange(old, new, inst)
	local fuelAnim = inst.components.fueled:GetCurrentSection()
	inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", fuelAnim)
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function RemoveAllWitherProtection(inst)
	if #inst.protected_plants > 0 then
		for k,v in pairs(inst.protected_plants) do
			if v then
				if v.components.crop then
					v.makewitherabletask = v:DoTaskInTime(TUNING.WITHER_BUFFER_TIME, function(v) 
						v.components.crop:MakeWitherable() 
						v.components.crop.protected = false
						v:RemoveTag("protected")
					end)
				end
				if v.components.pickable then
					v.makewitherabletask = v:DoTaskInTime(TUNING.WITHER_BUFFER_TIME, function(v) 
						v.components.pickable:MakeWitherable()
						v.components.pickable.protected = false 
						v:RemoveTag("protected")
					end)
				end
			end
		end
	end
	inst.protected_plants = {}
end

local function UnprotectPlant(inst, plant)
	if plant then
		local index = -1
		if plant and #inst.protected_plants > 0 then
			for k,v in ipairs(inst.protected_plants) do
				if v and v == plant then
					inst:RemoveEventCallback("picked", v.UnprotectPlant, v)
					v:RemoveTag("protected")
					v.components.pickable.protected = false
					v.makewitherabletask = v:DoTaskInTime(TUNING.WITHER_BUFFER_TIME, function(v) 
						v.components.pickable:MakeWitherable()
					end)
					index = k
					break
				end
			end
		end
		if index > 0 then
			table.remove(inst.protected_plants, index)
		end
	end
end

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.SoundEmitter:KillSound("idleloop")
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

	RemoveAllWitherProtection(inst)

	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("hit")
		end
	end
end



local function getstatus(inst, viewer)
	if inst.on then
		if inst.components.fueled and (inst.components.fueled.currentfuel / inst.components.fueled.maxfuel) <= .25 then
			return "LOWFUEL"
		else
			return "ON"
		end
	else
		return "OFF"
	end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("firesuppressor_idle")
end

local function HitPlants(inst, dist, noextinguish)
	
	local protector = inst.owner or inst
	dist = dist or 4

	local x,y,z = inst:GetPosition():Get()

	local ents = TheSim:FindEntities(x,y,z, dist, YESTAGS, NOTAGS)

	for k,v in pairs(ents) do
		if v then
			if v.makewitherabletask then
				v.makewitherabletask:Cancel()
				v.makewitherabletask = nil
				table.insert(protector.protected_plants, v)
				v:AddTag("protected")
				if v.components.pickable then
					v.UnprotectPlant = function(v)
						protector:UnprotectPlant(v)
					end
					protector:ListenForEvent("picked", v.UnprotectPlant, v)
				end
				if v.components.crop then
					v.components.crop.protected = true
				elseif v.components.pickable then
					v.components.pickable.protected = true
				end
			elseif v.components.crop and v.components.crop.witherable then
				v.components.crop.protected = true
				table.insert(protector.protected_plants, v)
				v:AddTag("protected")
			elseif v.components.pickable and v.components.pickable.witherable then
				v.components.pickable.protected = true
				if v.components.pickable.withered or v.components.pickable.shouldwither then
					if v.components.pickable.cycles_left and v.components.pickable.cycles_left <= 0 then
		    			v.components.pickable:MakeBarren()
		    		else
		    			v.components.pickable:MakeEmpty()
		    		end
		    		v.components.pickable.withered = false
		    		v.components.pickable.shouldwither = false
		    		v:RemoveTag("withered")
				end
				table.insert(protector.protected_plants, v)
				v:AddTag("protected")
				v.UnprotectPlant = function(v)
					protector:UnprotectPlant(v)
				end
				protector:ListenForEvent("picked", v.UnprotectPlant, v)
			end

			if not noextinguish then
				if v.components.burnable then
					if v.components.burnable:IsBurning() then
						v.components.burnable:Extinguish(true, TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT)
					elseif v.components.burnable:IsSmoldering() then
						v.components.burnable:Extinguish(true)
					end
				end
				if v.components.freezable then
					v.components.freezable:AddColdness(2) 
				end
				if v.components.temperature then
					local temp = v.components.temperature:GetCurrent()
	        		v.components.temperature:SetTemperature(temp - TUNING.FIRE_SUPPRESSOR_TEMP_REDUCTION)
				end
			end
		end
	end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
    data.on = inst.on
end

local function onload(inst, data)
	if data and data.burnt and inst.components.burnable and inst.components.burnable.onburnt then
        inst.components.burnable.onburnt(inst)
    end
    inst.on = data.on and data.on or false
end

local function OnLoadPostPass(inst, data)
	if not inst.components.fueled:IsEmpty() then
		HitPlants(inst, TUNING.FIRE_DETECTOR_RANGE, true)
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetPriority( 5 )
	minimap:SetIcon( "firesuppressor.png" )

	MakeObstaclePhysics(inst, 1)

	anim:SetBank("firefighter")
	anim:SetBuild("firefighter")
	anim:PlayAnimation("idle_off")
	inst.on = false

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.caninteractfn = CanInteract
	inst.components.machine.cooldowntime = 0.5

	inst:AddComponent("fueled")
	inst.components.fueled:SetDepletedFn(OnFuelEmpty)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(10)
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	inst.components.fueled:InitializeFuelLevel(TUNING.FIRESUPPRESSOR_MAX_FUEL_TIME)
	inst.components.fueled.bonusmult = 5
	inst.components.fueled.secondaryfueltype = "CHEMICAL"

	inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", 10)

	inst:AddComponent("firedetector")
	inst.components.firedetector:SetOnFindFireFn(OnFindFire)
	inst.protected_plants = {}
	inst.UnprotectPlant = UnprotectPlant
	
	inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
	--inst.canFire = true

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst.LaunchProjectile = LaunchProjectile
	inst:SetStateGraph("SGfiresuppressor")

	inst.OnSave = onsave 
    inst.OnLoad = onload
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep

	return inst
end


local function OnHit(inst, dist)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_impact")
	SpawnPrefab("splash_snow_fx").Transform:SetPosition(inst:GetPosition():Get())	
	HitPlants(inst)
	inst:Remove()
end

local function projectile_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    
    local physics = inst.entity:AddPhysics()
    physics:SetMass(1)
    physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)

	anim:SetBank("firefighter_projectile")
	anim:SetBuild("firefighter_projectile")
	anim:PlayAnimation("spin_loop", true)

    inst.persists = false

	inst:AddComponent("locomotor")
	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetOnHit(OnHit)
	inst.components.complexprojectile.yOffset = 2.5

	return inst
end
require "prefabutil"
return Prefab("firesuppressor", fn, assets, prefabs), 
Prefab("firesuppressorprojectile", projectile_fn, projectile_assets),
MakePlacer( "common/firesuppressor_placer", "firefighter_placement", "firefighter_placement", "idle", true, nil, nil, 1.55)