local assets = 
{
	Asset("ANIM", "anim/glommer_statue.zip"),
	Asset("ANIM", "anim/glommer_swap_flower.zip")
}

local prefabs = 
{
	"glommer",
	"glommerflower",
	"marble",
}

SetSharedLootTable( 'statueglommer',
{
    {'marble',  1.00},
    {'marble',  1.00},
    {'marble',  1.00},
    {'bell_blueprint', 1.00},
})

local lightColour = {180/255, 195/255, 150/255}

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local offset = FindWalkableOffset(pt, theta, 35, 12, true)
    if offset then
        return pt+offset
    end
end

local function OnMakeEmpty(inst)
	inst.AnimState:ClearOverrideSymbol("swap_flower")
	inst.AnimState:Hide("swap_flower")
    inst.components.lighttweener:StartTween(inst.Light, 0, .9, .3, nil, FRAMES*6, function(inst) inst.Light:Enable(false) end)

end

local function OnMakeFull(inst)
	inst.AnimState:OverrideSymbol("swap_flower", "glommer_swap_flower", "swap_flower")
	inst.AnimState:Show("swap_flower")
end

local function SpawnGlommer(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())        
    local spawn_pt = GetSpawnPoint(pt)

    if spawn_pt then
        local glommer = SpawnPrefab("glommer")
        if glommer then
	        if glommer.components.follower.leader ~= inst then
	            glommer.components.follower:SetLeader(inst)
	        end
            glommer.Physics:Teleport(spawn_pt:Get())
            glommer:FacePoint(pt.x, pt.y, pt.z)
            return glommer
        end 
    end
end

local function SpawnGland(inst)
	local gland = TheSim:FindFirstEntityWithTag("glommerflower")
	if (gland and gland:IsActive()) or inst.cooldown then
		return
	end

	inst.components.lighttweener:StartTween(inst.Light, 0, .9, .3, nil, 0, function(inst) inst.Light:Enable(true) end)    
    inst.components.lighttweener:StartTween(inst.Light, .75, nil, nil, nil, FRAMES*6)

    local glommer = TheSim:FindFirstEntityWithTag("glommer")
    if not glommer then glommer = SpawnGlommer(inst) end
    glommer.ShouldLeaveWorld = false
	inst.components.pickable:Regen()
end

local function RemoveGland(inst)	
	inst.components.pickable:MakeEmpty()
	
	local gland = TheSim:FindFirstEntityWithTag("glommerflower")
	if not gland or (gland and not gland:IsActive()) then
	    local glommer = TheSim:FindFirstEntityWithTag("glommer")
	    if glommer then
	    	glommer.ShouldLeaveWorld = true
	    end
	end
end

local function OnLoseChild(inst, child)
	inst.components.pickable:MakeEmpty()
end

local function OnTimerDone(inst, data)
    if data.name == "Cooldown" then
        inst.cooldown = nil
    end
end

local function OnPicked(inst, picker, loot)
    local glommer = TheSim:FindFirstEntityWithTag("glommer")
    if glommer then
        if glommer.components.follower.leader ~= loot then
        	glommer.components.follower:StopFollowing()
            glommer.components.follower:SetLeader(loot)
        end
    end

	inst.components.timer:StartTimer("Cooldown", TUNING.TOTAL_DAY_TIME * 3)
	inst.cooldown = true

end

local function MakeWorkable(inst)
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
				inst.components.lootdropper:DropLoot(pt)
				inst.worked = true
				inst.AnimState:PlayAnimation("low")
				inst:RemoveComponent("workable")
			else			
				if workleft < TUNING.ROCKS_MINE*(1/2) then
					inst.AnimState:PlayAnimation("med")
				else
					inst.AnimState:PlayAnimation("full")
				end
			end
		end)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("statueglommer")
end

local function MakeWorked(inst)
	inst.AnimState:PlayAnimation("low")
end

local function OnSave(inst, data)
	data.cooldown = inst.cooldown
	data.worked = inst.worked
end

local function OnLoad(inst, data)
	if data then
		inst.cooldown = data.cooldown
		inst.worked = data.worked
	end

	if not inst.worked then
		MakeWorkable(inst)
	else
		MakeWorked(inst)
	end

	inst:DoTaskInTime(0, function(inst)
		if (GetClock():IsNight() and GetClock():GetMoonPhase() == "full") then
			if not inst.components.pickable.canbepicked then -- If it can't be picked, we don't have a flower on the shelf
				SpawnGland(inst) -- SpawnGland will handle the case where it has been picked recently
			end
		else
			RemoveGland(inst) -- RemoveGland will handle the case where the flower isn't on the shelf any longer
		end
	end)
end

local function fn() 
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, .75)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("statue_glommer.png")
	minimap:SetPriority(5)

	anim:SetBank("glommer_statue")
	anim:SetBuild("glommer_statue")
	anim:PlayAnimation("full")

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = function(inst, viewer)
		if inst.worked then
			return "EMPTY"
		end
	end

	inst:AddComponent("timer")	
	inst:AddComponent("leader")
    inst.components.leader.onremovefollower = OnLoseChild

	inst:AddComponent("pickable")
	inst.components.pickable.product = "glommerflower"
	inst.components.pickable:SetOnPickedFn(OnPicked)
	inst.components.pickable:SetMakeEmptyFn(OnMakeEmpty)
	inst.components.pickable.makefullfn = OnMakeFull

	local light = inst.entity:AddLight()
	light:SetRadius(5)
	light:SetIntensity(0.9)
	light:SetFalloff(0.3)
	light:SetColour(lightColour[1], lightColour[2], lightColour[3])
	light:Enable(false)

	inst:AddComponent("lighttweener")

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	inst:ListenForEvent("timerdone", OnTimerDone)
	inst:ListenForEvent("fullmoon", function() SpawnGland(inst) end, GetWorld())
	inst:ListenForEvent("daytime", function() RemoveGland(inst) end, GetWorld())
	return inst
end

return Prefab("statueglommer", fn, assets, prefabs)
