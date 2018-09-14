local assets =
{
	Asset("ANIM", "anim/mole_build.zip"),
	Asset("ANIM", "anim/mole_basic.zip"),
}

local prefabs = 
{
	"mole",
}

local function GetChild(inst)
	return "mole"
end

local function dig_up(inst, chopper)
	if inst.components.spawner.child and not inst.components.spawner.child:HasTag("INLIMBO") then
		inst.components.spawner.child.needs_home_time = GetTime()
	end
	if inst.components.spawner:IsOccupied() then
		inst.components.spawner:ReleaseChild()
		inst.components.spawner.child.needs_home_time = GetTime()
	end
	inst.components.lootdropper:DropLoot()
	inst.components.inventory:DropEverything(false, true)
	inst:Remove()
end

local function startspawning(inst)
    if inst.components.spawner and not inst.components.spawner:IsSpawnPending() then
        inst.components.spawner:SpawnWithDelay(5 + math.random(15))
    end
end

local function stopspawning(inst)
    if inst.components.spawner then
        inst.components.spawner:CancelSpawning()
    end
end

local function onoccupied(inst)
	if not GetClock():IsDay() then
        startspawning(inst)
    end
end

local function confignewhome(inst, data)
	if inst.spawner_config_task then inst.spawner_config_task:Cancel() end
	if data.mole then inst.components.spawner:TakeOwnership(data.mole) end
	inst.components.spawner:Configure( "mole", TUNING.MOLE_RESPAWN_TIME) 
end
 
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("mole")
    anim:SetBuild("mole_build")
    anim:PlayAnimation("mound_idle", true)
	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
    
	inst:AddComponent("lootdropper")
	inst.components.lootdropper.numrandomloot = 1
	inst.components.lootdropper:AddRandomLoot("rocks", 4)
	inst.components.lootdropper:AddRandomLoot("nitre", 1.5)
	inst.components.lootdropper:AddRandomLoot("goldnugget", .5)
	inst.components.lootdropper:AddRandomLoot("flint", 1.5)

	inst:AddComponent("inventory")
	inst.components.inventory.maxslots = 50

	inst:AddComponent( "spawner" )
	inst.components.spawner:SetOnOccupiedFn(onoccupied)
	inst.components.spawner:SetOnVacateFn(stopspawning)
	inst.components.spawner.childfn = GetChild
	inst:ListenForEvent("confignewhome", confignewhome)
	inst.spawner_config_task = inst:DoTaskInTime(1, function(inst)
		inst.components.spawner:Configure( "mole", TUNING.MOLE_RESPAWN_TIME) 
		inst.spawner_config_task = nil
	end)
	
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)
    
	inst:ListenForEvent( "daytime", function() stopspawning(inst) end, GetWorld())
	inst:ListenForEvent( "dusktime", function() startspawning(inst) end, GetWorld())

	inst.OnSave = function(inst, data)
        
    end        
    
    inst.OnLoad = function(inst, data)

    end
	
    inst:AddComponent("inspectable")
	
    return inst
end

return Prefab( "common/objects/molehill", fn, assets, prefabs ) 
