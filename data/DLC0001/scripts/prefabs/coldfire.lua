require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/coldfire.zip"),
}

local prefabs =
{
    "coldfirefire",
    "collapse_small",
}    

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	local ash = SpawnPrefab("ash")
	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end


local function onextinguish(inst)
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function destroy(inst)
    local time_to_wait = 1
    local time_to_erode = 1
    local tick_time = TheSim:GetTickTime()

    if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

    inst:StartThread( function()
        local ticks = 0
        while ticks * tick_time < time_to_wait do
            ticks = ticks + 1
            Yield()
        end

        ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
            ticks = ticks + 1
            Yield()
        end
        inst:Remove()
    end)
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "coldfire.png" )
	minimap:SetPriority( 1 )

    anim:SetBank("coldfire")
    anim:SetBuild("coldfire")
    anim:PlayAnimation("idle_loop",false)
    inst:AddTag("campfire")
    inst:AddTag("structure")
  
    MakeObstaclePhysics(inst, .3)    

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("coldfirefire", Vector3(0,0,0) )
    inst:ListenForEvent("onextinguish", onextinguish)
    
    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.COLDFIRE_FUEL_MAX
    inst.components.fueled.secondaryfueltype = "CHEMICAL"
    inst.components.fueled.accepting = true    
    inst.components.fueled:SetSections(4)
    inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") end
    
    inst.components.fueled:SetUpdateFn( function()
        if GetSeasonManager() and GetSeasonManager():IsRaining() then
            inst.components.fueled.rate = 1 + TUNING.COLDFIRE_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
        else
            inst.components.fueled.rate = 1
        end
        
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                inst.components.burnable:Extinguish() 
                anim:PlayAnimation("dead") 
                RemovePhysicsColliders(inst)             
                local ash = SpawnPrefab("ash")
                ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
                -- if math.random() < .5 then
                --     local gold = SpawnPrefab("goldnugget")
                --     gold.Transform:SetPosition(inst.Transform:GetWorldPosition())
                -- end
                inst.components.fueled.accepting = false
                destroy(inst)
            else

                if not inst.components.burnable:IsBurning() then
                    inst.components.burnable:Ignite()
                end           

                anim:PlayAnimation("idle_loop") 
                inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent() )
                inst.components.fueled.rate = 1

            end
        end)
        
    inst.components.fueled:InitializeFuelLevel(TUNING.COLDFIRE_FUEL_START)
    
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
        anim:PushAnimation("idle_loop",false)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end)
    
    return inst
end

return Prefab( "common/objects/coldfire", fn, assets, prefabs),
MakePlacer( "common/coldfire_placer", "coldfire", "coldfire", "preview" )
