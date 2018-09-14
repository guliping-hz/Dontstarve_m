local rock_ice_assets =
{
	Asset("ANIM", "anim/ice_boulder.zip"),
}

local prefabs =
{
    "ice",
    "rocks",
    "flint",
    "ice_puddle",
    "ice_splash",
}    

SetSharedLootTable( 'rock_ice_tall',
{
    {'ice',  1.00},
    {'ice',  1.00},
    {'ice',  1.00},
    {'ice',  1.00},
    {'rocks',  1.00}, --or flint?
})

SetSharedLootTable( 'rock_ice_medium',
{
    {'ice',  1.00},
    {'ice',  1.00},
    {'rocks',  1.00},
})

SetSharedLootTable( 'rock_ice_short',
{
    {'ice',  1.00},
    {'rocks',  1.00},
})

local function SetLoot(inst, size)
	inst.components.lootdropper:SetLoot(nil)
	if size == "short" then
		inst.components.lootdropper:SetChanceLootTable('rock_ice_short')
		inst.components.lootdropper:AddChanceLoot("ice", .5)
		inst.components.lootdropper:AddChanceLoot("ice", .25)
	elseif size == "medium" then
		inst.components.lootdropper:SetChanceLootTable('rock_ice_medium')
		inst.components.lootdropper:AddChanceLoot("ice", .5)
	else
		inst.components.lootdropper:SetChanceLootTable('rock_ice_tall')
	end
end

local function SetStage(inst, stage, source)
	if not stage or not source then return end

	local target_workleft = TUNING.ICE_MINE

	if stage == "empty" then
		if source == "melt" and inst.stage ~= "short" and inst.stage ~= "empty" then
			SetStage(inst, "short", "melt")
			return
		else
			if inst.stage ~= "empty" then
				inst.puddle.AnimState:PlayAnimation("melted")
				inst:DoTaskInTime(math.random(27*FRAMES, 50*FRAMES), function(inst) inst.puddle.AnimState:PushAnimation("idle") end)
				if source == "melt" then inst.splash.AnimState:PlayAnimation("melted") end
			end
			inst.stage = "empty"
			inst.AnimState:Hide("rock")
			target_workleft = -1
			inst.MiniMapEntity:SetEnabled(false)
			if GetSeasonManager().ground_snow_level >= SNOW_THRESH then
				inst.AnimState:Hide("snow")
			end
			RemovePhysicsColliders(inst)
		end
	elseif stage == "short" then
		if source == "melt" and inst.stage ~= "medium" and inst.stage ~= "short" then
			SetStage(inst, "medium", "melt")
			return
		elseif source == "grow" and inst.stage ~= "empty" and inst.stage ~= "short" then
			SetStage(inst, "empty", "grow")
			return
		else
			if inst.stage ~= "short" then
				inst.AnimState:PlayAnimation("low")
				inst.puddle.AnimState:PlayAnimation("low")
				if source == "melt" then inst.splash.AnimState:PlayAnimation("low") end
			end
			inst.AnimState:Show("rock")
			if source ~= "work" then SetLoot(inst, "short") end
			inst.stage = "short" 
			target_workleft = TUNING.ICE_MINE*(1/3)
			inst.MiniMapEntity:SetEnabled(true)
			if GetSeasonManager().ground_snow_level >= SNOW_THRESH then
				inst.AnimState:Show("snow")
			end
			ChangeToObstaclePhysics(inst)
		end
	elseif stage == "medium" then
		if source == "melt" and inst.stage ~= "tall" and inst.stage ~= "medium" then
			SetStage(inst, "tall", "melt")
			return
		elseif source == "grow" and inst.stage ~= "short" and inst.stage ~= "medium" then
			SetStage(inst, "short", "grow")
			return
		else
			if inst.stage ~= "medium" then
				inst.AnimState:PlayAnimation("med")
				inst.puddle.AnimState:PlayAnimation("med")
				if source == "melt" then inst.splash.AnimState:PlayAnimation("med") end
			end
			if source ~= "work" then SetLoot(inst, "medium") end
			inst.stage = "medium"
			target_workleft = TUNING.ICE_MINE*(2/3)
		end
	elseif stage == "tall" then --kelly picked a medium one in fall and it grew. probably a bad state with workleft or maybe just < vs <= offbyone error
		if source == "grow" and inst.stage ~= "medium" and inst.stage ~= "tall" then
			SetStage(inst, "medium", "grow")
			return
		else
			if inst.stage ~= "tall" then
				inst.AnimState:PlayAnimation("full")
				inst.puddle.AnimState:PlayAnimation("full")
				if source == "melt" then inst.splash.AnimState:PlayAnimation("full") end
			end
			if source ~= "work" then SetLoot(inst, "tall") end
			inst.stage = "tall"
			target_workleft = TUNING.ICE_MINE
		end
	end

	local workable = inst and inst.components.workable or nil
	if workable and source ~= "work" then
		if target_workleft < 0 then
			workable:SetWorkable(false)
			inst.components.named:SetName(STRINGS.NAMES["ROCK_ICE_MELTED"])
		else
			inst.components.named:SetName(STRINGS.NAMES["ROCK_ICE"])
			workable:SetWorkLeft(target_workleft)
		end
	end
end

local function TryStageChange(inst)
	if inst.components.workable and inst.components.workable.lastworktime and GetTime() - inst.components.workable.lastworktime < 10 then
		inst:DoTaskInTime(30, function(inst) 
			inst:PushEvent("retrystatechange")
		end)
	end

	local seasonmgr = GetSeasonManager()
	if seasonmgr then
		local pct = seasonmgr:GetPercentSeason() 
		if seasonmgr:IsSpring() then
			if pct < inst.threshold1 then
				SetStage(inst, "tall", "melt")
			elseif pct < inst.threshold2 then
				SetStage(inst, "medium", "melt")
			elseif pct < inst.threshold3 then
				SetStage(inst, "short", "melt")
			else
				SetStage(inst, "empty", "melt")
			end
		elseif seasonmgr:IsSummer() then--and pct > .1 then
			SetStage(inst, "empty", "melt")
		elseif seasonmgr:IsAutumn() then
			if pct > inst.threshold1 then
				SetStage(inst, "short", "grow")
			elseif pct > inst.threshold2 then
				SetStage(inst, "medium", "grow")
			else
				SetStage(inst, "tall", "grow")
			end
		elseif seasonmgr:IsWinter() then--and pct > .1 then
			SetStage(inst, "tall", "grow")
		end
	end
end

local function onsave(inst, data)
	data.stage = inst.stage
end

local function onload(inst, data)
	if data and data.stage then
		while inst.stage ~= data.stage do
			SetStage(inst, data.stage, "melt")
		end
	end
end

local function baserock_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeObstaclePhysics(inst, 1.)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "iceboulder.png" )

	inst:AddComponent("lootdropper") 
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ICE_MINE)
	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash")
				inst.components.lootdropper:DropLoot(pt)
				inst:Remove() 
			else
				if workleft <= TUNING.ICE_MINE*(1/3) then
					SetStage(inst, "short", "work")
				elseif workleft <= TUNING.ICE_MINE*(2/3) then
					SetStage(inst, "medium", "work")
				else
					SetStage(inst, "tall", "work")
				end
			end
		end)     

    inst:AddComponent("named")
	inst.components.named:SetName(STRINGS.NAMES["ROCK_ICE"])

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = function(inst, viewer)
		if inst.stage == "empty" then
			return "MELTED"
		end
	end

	MakeSnowCovered(inst, .01)        
	return inst
end

local function rock_ice_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("ice_boulder")
	inst.AnimState:SetBuild("ice_boulder")

	SetLoot(inst, "tall")

	inst.OnSave = onsave
	inst.OnLoad = onload

	inst:AddTag("frozen")

	inst.puddle = SpawnPrefab("ice_puddle")
	inst.splash = SpawnPrefab("ice_splash")
	inst:AddChild(inst.puddle)    
    inst.puddle.Transform:SetPosition(0,0,0)
    inst:AddChild(inst.splash)    
    inst.splash.Transform:SetPosition(0,0,0)

    SetStage(inst, "tall", "melt")

    local seasonmgr = GetSeasonManager()
	if seasonmgr then -- Make sure we start at a good height for starting in a season when it shouldn't start as full
		if seasonmgr:IsSummer() then
			while inst.stage ~= "empty" do
				SetStage(inst, "empty", "melt")
			end
		elseif seasonmgr:IsAutumn() then
			while inst.stage ~= "empty" do--inst.stage ~= "short" do
				SetStage(inst, "empty", "melt")--SetStage(inst, "short", "melt")
			end
		end
	end

	inst.threshold1 = math.random(.25,.4)
	inst.threshold2 = math.random(.6,.75)
	inst.threshold3 = math.random(.9,1.1)

	inst:ListenForEvent("firemelt", function(inst)
		if inst.firemelttask then return end

		inst.firemelttask = inst:DoTaskInTime(4, function(inst)
			SetStage(inst, "empty", "melt")
			inst.firemelttask = nil
		end)
	end)
	inst:ListenForEvent("stopfiremelt", function(inst)
		if inst.firemelttask then 
			inst.firemelttask:Cancel()
			inst.firemelttask = nil
		end
	end)

	inst:ListenForEvent("daycomplete", function(it, data)
		inst:DoTaskInTime(math.random(TUNING.SEG_TIME*5), function(inst)
			TryStageChange(inst)
		end)
	end, GetWorld())

	inst:ListenForEvent("retrystatechange", function(inst)
		TryStageChange(inst)
	end)

	return inst
end


return Prefab("forest/objects/rocks/rock_ice", rock_ice_fn, rock_ice_assets, prefabs)
