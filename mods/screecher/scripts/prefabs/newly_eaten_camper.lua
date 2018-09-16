
local assets = {
	Asset("ANIM", "exportedanim/shambler_eat.zip"),
	Asset("ANIM", "exportedanim/shambler_build.zip"),
}

local function OnActivate(inst)
	if inst.components.highlight then
		inst.components.highlight:UnHighlight()
	end
	inst:RemoveTag("CLICK")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("shambler")
    inst.AnimState:SetBuild("shambler_eat")
	inst.AnimState:PlayAnimation("shambler_eat_pst", false)
	inst.name = "Corpse"

	inst:AddTag("CLICK")
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.distance = TUNING.CAMPER_ACTIVATE_DISTANCE + 1.5

	inst:DoTaskInTime(0, function(inst)
		local bloods = {"blood1", "blood2", "blood3"}
		local blood = SpawnPrefab(GetRandomItem(bloods))
		blood.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)

	inst:ListenForEvent("removecampername", function(it, data) 
		if data.camper == inst then
			inst.name = ""
		end
	end, GetPlayer())

	return inst
end

local function create_camper_bloody_note(Sim)
	local inst = fn(Sim)
	return inst
end

return Prefab("newly_eaten_camper", fn, assets),
	Prefab("camper_bloody_note", create_camper_bloody_note, assets, nil)

