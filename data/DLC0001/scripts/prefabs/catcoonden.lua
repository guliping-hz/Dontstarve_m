local assets =
{
    Asset("ANIM", "anim/catcoon_den.zip"),
}

local prefabs =
{
	"catcoon",
    "log",
    "rope",
    "twigs",
    "collapse_small",
}

local loots =
{
    {'log', 1.00},
    {'twigs',   1.00},
    {'rope',    0.05},
    {'boneshard', 0.2},
    {'feather', 0.05},
    {'feather_robin', 0.05},
    {'feather_robin_winter', 0.05},
    {'crow', 0.02},
    {'robin', 0.02},
    {'robin_winter', 0.02},
    {'rabbit', 0.02},
    {'mole', 0.02},
    {'smallmeat', 0.3},
}

local function onhammered(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
    end
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst.playing_dead_anim then
        inst.AnimState:PlayAnimation("hit", false)
    end
end

local function OnEntityWake(inst)
    if inst.components.childspawner then
        inst.components.childspawner:StartSpawning()
    end
    if inst.lives_left <= 0 then
        inst.playing_dead_anim = true
        inst.AnimState:PlayAnimation("dead", true)
    end
end

local function OnEntitySleep(inst)
end

local function onsave(inst, data)
    data.lives = inst.lives_left
end

local function onload(inst, data)
    if data and data.lives then
        inst.lives_left = data.lives
        if inst.lives_left <= 0 then
            if #inst.components.childspawner.childrenoutside > 0 then
                for i,v in pairs(inst.components.childspawner.childrenoutside) do
                    v:Remove()
                end
            end
            inst.components.childspawner:StopRegen()
            inst.components.childspawner:StopSpawning()
            inst:RemoveComponent("childspawner")
            inst.playing_dead_anim = true
            inst.AnimState:PlayAnimation("dead", true)
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "catcoonden.png" )

	anim:SetBank("catcoon_den")
	anim:SetBuild("catcoon_den")
	anim:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("catcoonden")

    -------------------
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)       

    -------------------
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "catcoon"
	inst.components.childspawner:SetRegenPeriod(TUNING.CATCOONDEN_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.CATCOONDEN_RELEASE_TIME)
	inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.canspawnfn = function(inst)
        if GetSeasonManager() and GetSeasonManager():IsRaining() then
            return false
        end
    end

    inst.lives_left = 9
    inst.components.childspawner.onchildkilledfn = function(inst, child)
        inst.lives_left = inst.lives_left - 1
        if inst.lives_left <= 0 then
            inst.components.childspawner:StopRegen()
            inst.components.childspawner:StopSpawning()
            inst:RemoveComponent("childspawner")
        end
    end
 
    ---------------------
    inst:AddComponent("lootdropper")
    for i,v in pairs(loots) do
        inst.components.lootdropper:AddRandomLoot(v[1], v[2])
    end
    inst.components.lootdropper.numrandomloot = 4

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    ---------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst, viewer)
        if inst.lives_left <= 0 then
            return "EMPTY"
        end
    end

    MakeSnowCovered(inst)

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
    
    inst.OnSave = onsave
    inst.OnLoad = onload

	return inst
end

return Prefab( "forest/monsters/catcoonden", fn, assets, prefabs ) 

