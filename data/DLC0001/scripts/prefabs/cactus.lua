local assets =
{
    Asset("ANIM", "anim/cactus.zip"),
	Asset("ANIM", "anim/cactus_flower.zip"),
}

local prefabs = 
{
    "cactus_meat",
    "cactus_flower",
}

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
end


local function onpickedfn(inst, picker)
    inst.Physics:SetActive(false)
    if inst.has_flower then
        inst.AnimState:PlayAnimation("picked_flower") 
    else
        inst.AnimState:PlayAnimation("picked") 
    end
    inst.AnimState:PushAnimation("empty", true)
    if picker.components.combat then
        picker.components.combat:GetAttacked(inst, TUNING.CACTUS_DAMAGE)
        picker:PushEvent("thorns")
    end
    
    if inst.has_flower then -- You get a cactus flower, yay.
        if picker and picker.components.inventory then
            local loot = SpawnPrefab("cactus_flower")
            if loot then
                local targetMoisture = 0
                if inst.components.moisturelistener then
                    targetMoisture = inst.components.moisturelistener:GetMoisture()
                elseif inst.components.moisture then
                    targetMoisture = inst.components.moisture:GetMoisture()
                else
                    targetMoisture = GetWorld().components.moisturemanager:GetWorldMoisture()
                end
                loot.targetMoisture = targetMoisture
                loot:DoTaskInTime(2*FRAMES, function()
                    if loot.components.moisturelistener then 
                        loot.components.moisturelistener.moisture = loot.targetMoisture
                        loot.targetMoisture = nil
                        loot.components.moisturelistener:DoUpdate()
                    end
                end)
                picker.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
            end
        end
    end
    inst.has_flower = false
end

local function onregenfn(inst)
    if GetSeasonManager() and GetSeasonManager():IsSummer() then
        inst.AnimState:PlayAnimation("grow_flower") 
        inst.AnimState:PushAnimation("idle_flower", true)
        inst.has_flower = true
    else
        inst.AnimState:PlayAnimation("grow") 
        inst.AnimState:PushAnimation("idle", true)
        inst.has_flower = false
    end
    inst.Physics:SetActive(true)
end

local function makeemptyfn(inst)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation("empty", true)
    inst.has_flower = false
end

local function OnEntityWake(inst)
    if GetSeasonManager() and GetSeasonManager():IsSummer() then
        if inst.components.pickable and inst.components.pickable.canbepicked then
            inst.AnimState:PlayAnimation("idle_flower", true)
            inst.has_flower = true
        else
            inst.AnimState:PlayAnimation("empty", true)
            inst.has_flower = false
        end
    else
        if inst.components.pickable and inst.components.pickable.canbepicked then
            inst.AnimState:PlayAnimation("idle", true)
        else
            inst.AnimState:PlayAnimation("empty", true)
        end
        inst.has_flower = false
    end
end

local function cactusfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "cactus.png" )

    anim:SetBuild("cactus")
    anim:SetBank("cactus")
    anim:PlayAnimation("idle", true)
    anim:SetTime(math.random()*2)

    MakeObstaclePhysics(inst, .3)
    
    inst:AddTag("thorny")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    
    inst.components.pickable:SetUp("cactus_meat", TUNING.CACTUS_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.ontransplantfn = ontransplantfn

    inst:AddComponent("inspectable")
    
    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    inst.OnEntityWake = OnEntityWake

    return inst
end

local function cactusflowerfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("cactusflower")
    anim:SetBuild("cactus_flower")
    anim:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_TINY
    inst.components.edible.foodtype = "VEGGIE"
    
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    return inst
end

return Prefab( "cactus", cactusfn, assets, prefabs),
Prefab("cactus_flower", cactusflowerfn, assets)
