local assets =
{
	Asset("ANIM", "anim/fan.zip"),
}

local function OnUse(inst, target)
	local coolingAmount = TUNING.FAN_COOLING
	if target.components.temperature then
		if target.components.temperature:GetCurrent() + coolingAmount <= 0 then
			coolingAmount = -target.components.temperature:GetCurrent() + 5
		end
		target.components.temperature:SetTemperature(target.components.temperature:GetCurrent() + coolingAmount)
		--target.components.temperature:DoDelta(coolingAmount)
	end
	local pos = target:GetPosition()
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 7, nil, {"FX", "NOCLICK","DECOR","INLIMBO"}, {"smolder", "fire"})
	for i,v in pairs(ents) do
		if v.components.burnable then 
			-- Extinguish smoldering/fire and reset the propagator to a heat of .2
			v.components.burnable:Extinguish(true, 0) 
		end
	end
end

local function CanUse(inst, target)
	return target.components.temperature and target.components.temperature.current > 0
end

local function OnFinished(inst)
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("fan")
	inst.AnimState:SetBuild("fan")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("fan")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fan")
    inst.components.fan:SetOnUseFn(OnUse)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FEATHER_FAN_USES)
    inst.components.finiteuses:SetUses(TUNING.FEATHER_FAN_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.FAN, 1)

	return inst
end

return Prefab("featherfan", fn, assets)