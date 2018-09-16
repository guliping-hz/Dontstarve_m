
local assets = {
	Asset("ANIM", "exportedanim/brazilian_tourists.zip"),
	Asset("ANIM", "exportedanim/guide_basic.zip"),
	Asset("ANIM", "exportedanim/guide_build.zip"),
}

local function OnActivate(inst, doer)
	if inst.components.highlight then
		inst.components.highlight:UnHighlight()
	end
	inst.SoundEmitter:PlaySound("scary_mod/stuff/bloodyground")
	
	if math.random() > 0.5 then
		doer:DoTaskInTime(0.5, function()
			doer.components.talker:Say("Oh god.", 4, false)
		end)
	else
		doer:DoTaskInTime(0.5, function()
			doer.components.talker:Say("Oh no.", 4, false)
		end)
	end
	inst:RemoveTag("CLICK")
end

local function create_tourist1(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("brazilian_tourists")
    inst.AnimState:SetBuild("brazilian_tourists")
	inst.AnimState:PlayAnimation("tourist1", false)

	inst.name = "Corpse"

	inst:AddTag("CLICK")
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.distance = TUNING.CAMPER_ACTIVATE_DISTANCE

	inst:DoTaskInTime(0, function(inst)
		local bloods = {"blood1", "blood2", "blood3"}
		for i=1,3 do
			local blood = SpawnPrefab(GetRandomItem(bloods))
			blood.Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
	end)
	
	return inst
end

local function create_tourist2(Sim)
	local inst = create_tourist1(Sim)
	inst.AnimState:PlayAnimation("tourist2", false)	

	return inst
end

local function create_guide(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("Guide")
    inst.AnimState:SetBuild("guide_build")
	inst.AnimState:PlayAnimation("guide_dead", false)

	inst.name = "Corpse"

	inst:AddTag("CLICK")
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.distance = TUNING.CAMPER_ACTIVATE_DISTANCE

	inst:DoTaskInTime(0, function(inst)
		local bloods = {"blood1", "blood2", "blood3"}
		local blood = SpawnPrefab(GetRandomItem(bloods))
		blood.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)
	
	return inst
end


return Prefab("tourist1", create_tourist1, assets, nil),
	Prefab("tourist2", create_tourist2, assets, nil),
	Prefab("tour_guide", create_guide, assets, nil)
