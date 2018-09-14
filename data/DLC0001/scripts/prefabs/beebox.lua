require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/bee_box.zip"),
}

local prefabs = 
{
	"bee",
    "honey",
    "honeycomb",
    "collapse_small",
}

local levels = 
{
    { amount=6, idle="honey3", hit="hit_honey3" },
    { amount=3, idle="honey2", hit="hit_honey2" },
    { amount=1, idle="honey1", hit="hit_honey1" },
    { amount=0, idle="bees_loop", hit="hit_idle" },
}

local function StartSpawningFn(inst)
	local fn = function(world)
		if not inst:HasTag("burnt") then
		    if inst.components.harvestable and inst.components.harvestable.growtime and not world.components.seasonmanager:IsWinter() then
		        inst.components.harvestable:StartGrowing()
		    end
			if inst.components.childspawner and not world.components.seasonmanager:IsWinter() then
				inst.components.childspawner:StartSpawning()
			end
		end
	end
	return fn
end

local function StopSpawningFn(inst)
	local fn = function(world)
	    if inst.components.harvestable and inst.components.harvestable.growtime then
	        inst.components.harvestable:StopGrowing()
	    end
		if inst.components.childspawner then
			inst.components.childspawner:StopSpawning()
		end
	end
	return fn
end


local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.SoundEmitter:KillSound("loop")
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation(inst.anims.hit)
		inst.AnimState:PushAnimation(inst.anims.idle, false)
	end
end

local function setlevel(inst, level)
	if not inst:HasTag("burnt") then
	    if not inst.anims then
	        inst.anims = {idle = level.idle, hit = level.hit}
	    else
	        inst.anims.idle = level.idle
	        inst.anims.hit = level.hit
	    end
	    inst.AnimState:PlayAnimation(inst.anims.idle)
	end
end

local function updatelevel(inst)
	if not inst:HasTag("burnt") then
	    for k,v in pairs(levels) do
	        if inst.components.harvestable.produce >= v.amount then
	            setlevel(inst, v)
	            break
	        end
	    end
	end
end

local function onharvest(inst, picker)
	--print(inst, "onharvest")
	if not inst:HasTag("burnt") then
	    updatelevel(inst)
		if inst.components.childspawner and not GetSeasonManager():IsWinter() then
		    inst.components.childspawner:ReleaseAllChildren(picker)
		end
	end
end

local function onchildgoinghome(inst, data)
	if not inst:HasTag("burnt") then
	    	if data.child and data.child.components.pollinator and data.child.components.pollinator:HasCollectedEnough() then
	        if inst.components.harvestable then
	            inst.components.harvestable:Grow()
	        end
	    end
	end
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
	--print(inst, "OnLoad")
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
		updatelevel(inst)
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
end


local function OnEntityWake(inst)
	if not inst:HasTag("burnt") then
    	inst.SoundEmitter:PlaySound("dontstarve/bee/bee_box_LP", "loop")
        if inst.components.harvestable and inst.sleep_time and ((GetTime() - inst.sleep_time) >= TUNING.BEEBOX_HONEY_TIME) then
        	inst.components.harvestable:Grow()
	    end
	end
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
	if not inst:HasTag("burnt") and inst.components.harvestable then
		inst.sleep_time = GetTime()
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "beebox.png" )
	
    MakeObstaclePhysics(inst, .5)

	anim:SetBank("bee_box")
	anim:SetBuild("bee_box")
	anim:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("playerowned")
    inst:AddTag("beebox")
    
    ---------------------  

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp("honey", 6, nil, onharvest, updatelevel)
    inst:ListenForEvent("childgoinghome", onchildgoinghome)
    -------------------
    
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "bee"
	inst:ListenForEvent("seasonChange", function(it, data)
        if data.season == SEASONS.SPRING and inst.components.childspawner then
            inst.components.childspawner:SetRegenPeriod(math.ceil(TUNING.BEEBOX_REGEN_TIME / TUNING.SPRING_COMBAT_MOD))
            inst.components.childspawner:SetSpawnPeriod(math.ceil(TUNING.BEEBOX_RELEASE_TIME / TUNING.SPRING_COMBAT_MOD))
            inst.components.childspawner:SetMaxChildren(math.ceil(TUNING.BEEBOX_BEES * TUNING.SPRING_COMBAT_MOD))
        elseif inst.components.childspawner then
            inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME)
            inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME)
            inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES)
        end
    end, GetWorld())
	inst.components.childspawner:SetRegenPeriod( TUNING.BEEBOX_REGEN_TIME )
	inst.components.childspawner:SetSpawnPeriod( TUNING.BEEBOX_RELEASE_TIME )
	inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES)
	if not GetWorld().components.seasonmanager:IsWinter() then
		inst.components.childspawner:StartSpawning()
	end
	inst:ListenForEvent( "dusktime", StopSpawningFn(inst), GetWorld())
	inst:ListenForEvent( "daytime", StartSpawningFn(inst), GetWorld())

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.harvestable and inst.components.harvestable:CanBeHarvested() then
            return "READY"
        end
    end
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
    updatelevel(inst)
    
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent( "onbuilt", onbuilt)

	MakeMediumBurnable(inst, nil, nil, true)
	MakeLargePropagator(inst)
	inst:ListenForEvent("onignite", function(inst)
        if inst.components.childspawner then
            inst.components.childspawner:ReleaseAllChildren()
            inst.components.childspawner:StopSpawning()
        	inst:RemoveComponent("childspawner")
        end
    end)

	inst.OnSave = OnSave 
	inst.OnLoad = OnLoad
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	return inst
end

return Prefab( "common/objects/beebox", fn, assets, prefabs ),
	   MakePlacer( "common/beebox_placer", "bee_box", "bee_box", "idle" ) 

