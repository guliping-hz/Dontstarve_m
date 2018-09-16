local assets =
{
	Asset("ANIM", "anim/evergreen_living_wood.zip"),
}

local prefabs =
{
	"livinglog",
}

local function ondug(inst, worker)
	inst:Remove()
	inst.components.lootdropper:SpawnLootPrefab("livinglog")
end

local function makestump(inst, instant)
    inst:RemoveComponent("workable")
    RemovePhysicsColliders(inst)
    if instant then
    	inst.AnimState:PlayAnimation("stump")
    else
    	inst.AnimState:PushAnimation("stump")	
    end
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(ondug)
    inst.components.workable:SetWorkLeft(1)    
    inst:AddTag("stump")
end

local function onworked(inst, chopper, workleft)
	if chopper and chopper.components.beaverness and chopper.components.beaverness:IsBeaver() then
		-- inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/beaver_chop_tree")          
	else
		-- inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
	end

	inst.AnimState:PlayAnimation("chop")
	inst.AnimState:PushAnimation("idle")
end

local function onworkfinish(inst, chopper)
	-- inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local hispos = Vector3(chopper.Transform:GetWorldPosition())
    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0

    if he_right then
        inst.AnimState:PlayAnimation("fallleft")
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation("fallright")
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    inst:DoTaskInTime(.4, function() 
		GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.25, 0.03, .5, 6)
    end)

    makestump(inst)
end

local function onsave(inst, data)
	if inst:HasTag("stump") then
		data.stump = true
	end
end

local function onload(inst, data)
	if data and data.stump then
		makestump(inst, true)
	end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()        
    -- local sound = inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("rock.png")
	
	inst:AddTag("tree")
	inst:AddTag("workable")

	MakeObstaclePhysics(inst, .75)

	anim:SetBank("evergreen_living_wood")
	anim:SetBuild("evergreen_living_wood")
	anim:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"livinglog", "livinglog", "livinglog"})

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	inst.components.workable:SetWorkLeft(20)
	inst.components.workable:SetOnWorkCallback(onworked)
	inst.components.workable:SetOnFinishCallback(onworkfinish)

	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

return Prefab("common/livingtree", fn, assets, prefabs)