local assets=
{
	Asset("ANIM", "anim/heat_rock.zip"),
}


local function HeatFn(inst, observer)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if owner and owner.components.temperature then
		return (inst.components.temperature:GetCurrent() - owner.components.temperature:GetCurrent()) * TUNING.HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR
	end

	local seasonmgr = GetSeasonManager()
	if seasonmgr then
		return inst.components.temperature:GetCurrent() - seasonmgr:GetCurrentTemperature() / TUNING.HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR
	end
end

local function GetStatus(inst)
	if inst.currentTempRange == 1 then
		return "FROZEN"
	elseif inst.currentTempRange == 2 then
		return "COLD"
	elseif inst.currentTempRange == 4 then
		return "WARM"
	elseif inst.currentTempRange == 5 then
		return "HOT"
	end
end

-- These represent the boundaries between the images
local base_temperature_thresholds = { 5, 20, 50, 65 }--{ 0, 25, 40, 50 } was original
local winter_temperature_thresholds = { -5, 12, 20, 35 }
local summer_temperature_thresholds = { 35, 50, 58, 75 }

local function GetCurrentTemperatureThresholds(inst)
	local seasonmgr = GetSeasonManager()
	if seasonmgr and (seasonmgr:IsSummer() or (seasonmgr:IsSpring() and seasonmgr:GetPercentSeason() > .8) or (seasonmgr:IsAutumn() and seasonmgr:GetPercentSeason() < .2)) then
		return summer_temperature_thresholds, 0
	elseif seasonmgr and (seasonmgr:IsWinter() or (seasonmgr:IsSpring() and seasonmgr:GetPercentSeason() < .2) or (seasonmgr:IsAutumn() and seasonmgr:GetPercentSeason() > .8)) then
		return winter_temperature_thresholds, TUNING.MIN_ENTITY_TEMP
	else
		return base_temperature_thresholds, TUNING.MIN_ENTITY_TEMP
	end
end

local function GetRangeForTemperature(inst, temp)
	local range = 1
	local temp_thresh, mintemp = GetCurrentTemperatureThresholds(inst)
	for i,v in ipairs(temp_thresh) do
		if temp > v then
			range = range + 1
		end
	end

	return range
end

local function UpdateImages(inst, range)
	inst.currentTempRange = range
	inst.AnimState:PlayAnimation(tostring(range), true)
	inst.components.inventoryitem:ChangeImageName("heat_rock"..tostring(range))
	if range == 5 then
		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
		-- inst.Light:Enable(true)
	else
		inst.AnimState:ClearBloomEffectHandle()
		-- inst.Light:Enable(false)
	end
end

local function AdjustLighting(inst)
	local temp_thresh = GetCurrentTemperatureThresholds(inst)
	local hottest = inst.components.temperature.maxtemp - temp_thresh[#temp_thresh]
	local current = inst.components.temperature.current - temp_thresh[#temp_thresh]
	local ratio = current/hottest
	inst.Light:SetIntensity(0.5 * ratio)
end

local function TemperatureChange(inst, data)
	-- AdjustLighting(inst)
	local range = GetRangeForTemperature(inst, inst.components.temperature.current)
	if range ~= inst.currentTempRange then
		UpdateImages(inst, range)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("heat_rock")
    inst.AnimState:SetBuild("heat_rock")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("bait")
    inst:AddTag("molebait")

	inst:AddComponent("temperature")
	-- inst.components.temperature.maxtemp = 70
	-- inst.components.temperature.mintemp = -5
	inst.components.temperature.current = GetSeasonManager() and GetSeasonManager():GetTemperature() or 30
	inst.components.temperature.inherentinsulation = TUNING.INSULATION_MED
	inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED

	inst:AddComponent("heater")
	inst.components.heater.heatfn = HeatFn
	inst.components.heater.carriedheatfn = HeatFn
	
 --    inst.entity:AddLight()
	-- inst.Light:SetRadius(.6)
 --    inst.Light:SetFalloff(1)
 --    inst.Light:SetIntensity(.5)
 --    inst.Light:SetColour(235/255,165/255,12/255)
	-- inst.Light:Enable(false)
	-- inst.Light:SetDisableOnSceneRemoval(false)

	inst:ListenForEvent("seasonChange", function(it, data)
		if data.season == SEASONS.SUMMER then
			inst.components.heater.iscooler = true
		elseif data.season == SEASONS.WINTER then
			inst.components.heater.iscooler = false
		end
	end, GetWorld())

	inst:ListenForEvent("temperaturedelta", TemperatureChange)
	inst.currentTempRange = GetRangeForTemperature(inst, inst.components.temperature.current)
	UpdateImages(inst, inst.currentTempRange)

	-- InventoryItems automatically enable their lights when dropped, so we need to counteract that
	-- inst:ListenForEvent("ondropped", function(inst)
	-- 	if inst.currentTempRange ~= 5 then
	-- 		inst.Light:Enable(false)
	-- 	end
	-- end)

	return inst
end

return Prefab( "common/inventory/heatrock", fn, assets) 
