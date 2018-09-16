-- _Q_ -- Ice Fling Range Check 1.1

PrefabFiles = 
{
	"range"
}

if GetModConfigData("Range Check Time") == "short" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 10
end

if GetModConfigData("Range Check Time") == "default" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 30
end

if GetModConfigData("Range Check Time") == "long" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 60
end

if GetModConfigData("Range Check Time") == "longer" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 240
end

if GetModConfigData("Range Check Time") == "longest" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 480
end

if GetModConfigData("Range Check Time") == "always" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 1
end

function IceFlingOnRemove(inst)
	local pos = GLOBAL.Point(inst.Transform:GetWorldPosition())
	local range_indicators = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"})
	for i,v in ipairs(range_indicators) do
		if v:IsValid() then
			v:Remove()
		end
	end
end

function getstatus_mod(inst, viewer)

	local pos = Point(inst.Transform:GetWorldPosition())
	local range_indicators = TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"} )
	if #range_indicators < 1 then
	local range = GLOBAL.SpawnPrefab("range_indicator")
	range.Transform:SetPosition(pos.x, pos.y, pos.z)
	end
	
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

function IceFlingPostInit(inst)
	if inst and inst.components.inspectable then
		inst.components.inspectable.getstatus = getstatus_mod
	end
	inst:ListenForEvent("onremove", IceFlingOnRemove)
end

AddPrefabPostInit("firesuppressor", IceFlingPostInit)