require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/wilsonstatue.zip"),
}

local prefabs =
{
	"collapse_small",
}


local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if inst.components.lootdropper and (not inst.components.resurrector or not inst.components.resurrector.used) then
		inst.components.lootdropper:DropLoot()
	end
	if inst:HasTag("burnt") then
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	else	
		SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

	-- Remove from save index
	SaveGameIndex:DeregisterResurrector(inst)

	if inst.components.resurrector then 
		inst.components.resurrector.penalty = 0 
		if not inst.components.resurrector.used then
			local player = GetPlayer()
			if player then
				player.components.health:RecalculatePenalty()
			end
		end
	end
	
	inst:Remove()
end

local function onburnt(inst)
	inst:AddTag("burnt")
    inst.components.burnable.canlight = false
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    -- Remove from save index
	SaveGameIndex:DeregisterResurrector(inst)
	-- Remove penalty if not used
	if inst.components.resurrector then
		inst.components.resurrector.penalty = 0
		if not inst.components.resurrector.used then
			local player = GetPlayer()
			if player and player.components.health then
				player.components.health:RecalculatePenalty()
			end
		end
	end
	if inst.AnimState and inst.components.resurrector and not inst.components.resurrector.used then
        inst.AnimState:PlayAnimation("burnt", true)
        inst.components.resurrector.active = false
        inst.components.resurrector.used = true
        inst:RemoveComponent("resurrector")
    else
    	local ash = SpawnPrefab("ash")
    	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    	inst:Remove()
    end
end

local function makeused(inst)
	if inst.components.resurrector and not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("debris")
		inst.components.resurrector.penalty = 0	
	end
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		if not inst.components.resurrector.used then
			inst.AnimState:PlayAnimation("hit")
			inst.AnimState:PushAnimation("idle")
		end
	end
end

local function doresurrect(inst, dude)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst:AddTag("busy")	
	inst.persists = false
    inst:RemoveComponent("lootdropper")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("inspectable")
	inst.MiniMapEntity:SetEnabled(false)
    if inst.Physics then
		RemovePhysicsColliders(inst)
    end

	GetClock():MakeNextDay()
    dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
    dude:Hide()
    dude:ClearBufferedAction()

    if dude.HUD then
        dude.HUD:Hide()
    end
    if dude.components.playercontroller then
        dude.components.playercontroller:Enable(false)
    end

    TheCamera:SetDistance(12)
	dude.components.hunger:Pause()
	
    scheduler:ExecuteInTime(3, function()
        dude:Show()

        inst:Hide()
        inst.AnimState:PlayAnimation("debris")
		inst.components.resurrector.penalty = 0                
		
        dude.sg:GoToState("rebirth")
        
        --SaveGameIndex:SaveCurrent()
        dude:DoTaskInTime(3, function() 
            if dude.HUD then
                dude.HUD:Show()
            end
            if dude.components.hunger then
                dude.components.hunger:SetPercent(2/3)
            end
			
            if dude.components.health then
				dude.components.health:RecalculatePenalty()
                dude.components.health:Respawn(TUNING.RESURRECT_HEALTH)
                dude.components.health:SetInvincible(true)
            end

            if dude.components.moisture then
            	dude.components.moisture.moisture = 0
            end

            if dude.components.temperature then
            	dude.components.temperature:SetTemperature(TUNING.STARTING_TEMP)
            end
            
            if dude.components.sanity then
			    dude.components.sanity:SetPercent(.5)
            end
            if dude.components.playercontroller then
                dude.components.playercontroller:Enable(true)
            end
            
            dude.components.hunger:Resume()
            
            TheCamera:SetDefault()
            inst:RemoveTag("busy")
        end)
        inst:DoTaskInTime(4, function() 
            dude.components.health:SetInvincible(false)
			inst:Show()
        end)
		inst:DoTaskInTime(7, function()
		    local tick_time = TheSim:GetTickTime()
		    local time_to_erode = 4
		    inst:StartThread( function()
			    local ticks = 0
			    while ticks * tick_time < time_to_erode do
				    local erode_amount = ticks * tick_time / time_to_erode
				    inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
				    ticks = ticks + 1
				    Yield()
			    end
			    inst:Remove()
		    end)
		end)
        
    end)

end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
    
    MakeObstaclePhysics(inst, .3)

	inst.MiniMapEntity:SetIcon( "resurrect.png" )
    inst:AddTag("structure")
    
    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("resurrector")
    inst.components.resurrector.active = true
	inst.components.resurrector.doresurrect = doresurrect
	inst.components.resurrector.makeusedfn = makeused
	inst.components.resurrector.penalty = 1
	
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	MakeSnowCovered(inst, .01)    
	inst:ListenForEvent( "onbuilt", onbuilt)

	inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0) )
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

	inst.OnSave = onsave 
    inst.OnLoad = onload
   
    return inst
end




return Prefab( "common/objects/resurrectionstatue", fn, assets, prefabs),
		MakePlacer( "common/resurrectionstatue_placer", "wilsonstatue", "wilsonstatue", "idle" ) 
