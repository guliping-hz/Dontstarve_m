require "prefabutil"

local assets =
{
	Asset("ANIM", "exportedanim/campfire1.zip"),
    Asset("ANIM", "exportedanim/barrel.zip"),
}

local prefabs =
{
    "campfirefire",
    "scary_shadow",
}    

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	local ash = SpawnPrefab("ash")
	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function onignite(inst)
    if not inst.components.cooker then
        inst:AddComponent("cooker")
    end
end

local function onextinguish(inst)
    if inst.components.cooker then
        inst:RemoveComponent("cooker")
    end
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function OnActivate(inst)
    inst.components.burnable:Ignite()
    inst:RemoveTag("CLICK")
end

local function firepit_lit(Sim, bankname)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 10, 10 )

    inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "firepit.png" )
	minimap:SetPriority( 1 )

    anim:SetBank(bankname)
    anim:SetBuild(bankname)
    anim:PlayAnimation("idle",false)
    inst:AddTag("campfire")
    inst:AddTag("scarymod_campfire")
    inst:AddTag("structure")
  
    MakeObstaclePhysics(inst, .3)   

    inst.entity:SetCanSleep(false) 

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0,.4,0) )
    inst:ListenForEvent("onextinguish", onextinguish)
    inst:ListenForEvent("onignite", onignite)
    
    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)    

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = 999999999
    inst.components.fueled.accepting = true
    
    inst.components.fueled:SetSections(1)
    inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT
    inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") end
    
    inst.components.fueled:SetUpdateFn( function()
        if GetSeasonManager() and GetSeasonManager():IsRaining() then
            inst.components.fueled.rate = 1 + TUNING.FIREPIT_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
        else
            inst.components.fueled.rate = 1
        end
        
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section)
        if section == 0 then
            inst.components.burnable:Extinguish() 
        else
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
            
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            
        end
    end)
        
    --inst.components.fueled:InitializeFuelLevel(TUNING.FIREPIT_FUEL_START)
    inst.components.fueled:InitializeFuelLevel(inst.components.fueled.maxfuel)
    
    -----------------------------
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        local sec = inst.components.fueled:GetCurrentSection()
        if sec == 0 then 
            return "OUT"
        elseif sec <= 4 then
            local t = {"EMBERS","LOW","NORMAL","HIGH"}
            return t[sec]
        end
    end
    
    inst:ListenForEvent( "onbuilt", function()
        anim:PlayAnimation("place")
        anim:PushAnimation("idle",false)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end)

    inst.components.burnable:Ignite()

    inst:AddComponent("scaryshadow")
    inst:DoTaskInTime(0, function()
        inst.components.scaryshadow:SpawnShadow(inst, 1.5)
    end)

    return inst
end

local function firepit_unlit(Sim,bankname)
    local inst = firepit_lit(Sim,bankname)
    inst.components.burnable:Extinguish()

    inst:AddTag("CLICK")
    inst:AddComponent("activatable")
    inst.components.activatable.distance = nil
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.quickaction = false

    return inst
end

return Prefab( "common/objects/firepit", function(Sim) return firepit_unlit(Sim,"campfire1") end, assets, prefabs),
        Prefab( "common/objects/firepit_lit", function(Sim) return firepit_lit(Sim,"campfire1") end, assets, prefabs),
        Prefab( "common/objects/barrel", function(Sim) return firepit_unlit(Sim,"barrel") end, assets, prefabs),
		MakePlacer( "common/firepit_placer", "firepit", "firepit", "preview" ) 
