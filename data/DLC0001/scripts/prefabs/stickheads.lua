local pig_assets =
{
	Asset("ANIM", "anim/pig_head.zip")
}

local merm_assets =
{
	Asset("ANIM", "anim/merm_head.zip")
}

local pig_prefabs =
{
	"flies",
	"pigskin",
	"twigs",
	"collapse_small",
}

local merm_prefabs =
{
	"flies",
	"spoiled_food",
	"twigs",
	"collapse_small",
}


local function OnFinish(inst)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	if GetClock() and GetClock():GetMoonPhase() == "full" and GetClock():IsNight() then
		inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
	end
	inst.components.lootdropper:DropLoot()
	inst:Remove()
end

local function OnFullMoon(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("wake")
		inst.AnimState:PushAnimation("idle_awake", false)
		inst.awake = true
	end
end

local function OnDayTime(inst)
	if not inst:HasTag("burnt") then
		if inst.awake then
			inst.awake = false
			inst.AnimState:PlayAnimation("sleep")
			inst.AnimState:PushAnimation("idle_asleep", false)
		end
	end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
    	inst:DoTaskInTime(0, function(inst) 
		    if (GetClock():IsNight() and GetClock():GetMoonPhase() == "full") then
		    	OnFullMoon(inst)
		    else
		    	OnDayTime(inst)
		    end
		end)
	end
end

local function create_common(inst)
	inst.entity:AddSoundEmitter()

	inst.AnimState:PlayAnimation("idle_asleep")

	inst:AddComponent("lootdropper")

	inst:AddComponent("inspectable")

	inst.flies = inst:SpawnChild("flies")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnWorkCallback(function(inst) 
		if not inst:HasTag("burnt") then
			inst.AnimState:PlayAnimation("hit")
			inst.AnimState:PushAnimation("idle_asleep")
		end
	end)

	inst:ListenForEvent("fullmoon", function() OnFullMoon(inst) end, GetWorld())
	inst:ListenForEvent("daytime", function() OnDayTime(inst) end, GetWorld())

	inst.components.workable.onfinish = OnFinish

	inst:AddTag("structure")
	MakeSmallBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

local function create_pighead()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("pig_head")
	inst.AnimState:SetBuild("pig_head")

	create_common(inst)

	inst.components.lootdropper:SetLoot({"pigskin", "pigskin", "twigs", "twigs"})

	return inst
end

local function create_mermhead()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("merm_head")
	inst.AnimState:SetBuild("merm_head")

	create_common(inst)

	inst.components.lootdropper:SetLoot({"spoiled_food", "spoiled_food", "twigs", "twigs"})

	return inst
end

return Prefab("forest/objects/pighead", create_pighead, pig_assets, pig_prefabs),
	   Prefab("forest/objects/mermhead", create_mermhead, merm_assets, merm_prefabs) 
