function GetWanderAwayPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = 40
    
    local ground = GetWorld()
    
    -- Walk the circle trying to find a valid spawn point
    local steps = 12
    for i = 1, 12 do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset
        
        if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE
           and ground.Pathfinder:IsClear(pt.x, pt.y, pt.z, wander_point.x, wander_point.y, wander_point.z, {ignorewalls = true} ) then
            return wander_point
        end
        theta = theta - (2 * PI / steps)
    end
end

local function onspawn_deerclops(inst)
    local target = GetClosestInstWithTag("structure", GetPlayer(), 40)
    if target then
        local targetPos = Vector3(target.Transform:GetWorldPosition() )
        inst.components.knownlocations:RememberLocation("targetbase", targetPos)
        local wanderAwayPoint = GetWanderAwayPoint(targetPos)
        if wanderAwayPoint then
            inst.components.knownlocations:RememberLocation("home", wanderAwayPoint)
        end
    else
        inst.components.combat:SetTarget(GetPlayer())
    end
end

local function spawncondition_deerclops()
	local snow_cover = GetSeasonManager() and GetSeasonManager():GetSnowPercent() or 0
	return snow_cover >= 0.2
end

local deerclops = 
{
	prefab = "deerclops",
	activeseason =  SEASONS.WINTER,
	attackduringoffseason = false,
	playerstring = "ANNOUNCE_DEERCLOPS",
	attacksperseason = 1,
	warnsound = "dontstarve/creatures/deerclops/distant",
	warnduration = 60,
	onspawnfn = onspawn_deerclops,
	spawnconditionfn = spawncondition_deerclops,
    minspawnday = TUNING.NO_BOSS_TIME,
}

local bearger = 
{
	prefab = "bearger",
	activeseason =  SEASONS.AUTUMN,
	attackduringoffseason = false,
	playerstring = "ANNOUNCE_DEERCLOPS",
	attacksperseason = 1,
	warnsound = "dontstarve_DLC001/creatures/bearger/distant",
    warnduration = 60,
    minspawnday = TUNING.NO_BOSS_TIME,
}

local function onspawn_moose(inst)
    local sound = CreateEntity()
    sound.entity:AddTransform()
    sound.entity:AddSoundEmitter()
    sound.persists = false
    local theta = inst:GetAngleToPoint(GetPlayer().Transform:GetWorldPosition())
    local radius = math.clamp(Lerp(5, 25, 1/90), 5, 25)
    local offset = GetPlayer():GetPosition() +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    sound.Transform:SetPosition(offset:Get())
    sound.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/distant")
    sound:DoTaskInTime(1.5, function() sound:Remove() end)

    inst:DoTaskInTime(2.5, function()
        GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_DEERCLOPS"))    
    end)
	inst.components.timer:StartTimer("WantsToLayEgg", TUNING.TOTAL_DAY_TIME + (TUNING.TOTAL_DAY_TIME * math.random()))
end

local NO_TAGS = {"FX", "NOCLICK","DECOR","INLIMBO"}
local BASE_TAGS = {"structure"}

local function spawnconditionfn_moose()
    local pt = GetPlayer():GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 30, BASE_TAGS, NO_TAGS)
    return #ents >= 3
end

local function spawnposfn_moose(inst)
    local base_offsets = function()
        local positions = {}
        for i = 1, 100 do
            local s = i/32.0--(num/2) -- 32.0
            local a = math.sqrt(s*512.0)
            local b = math.sqrt(s)
            table.insert(positions, Vector3(math.sin(a)*b, 0, math.cos(a)*b))
        end
        return positions
    end
    local playerpos = GetPlayer():GetPosition()
    local spots = {}
    if playerpos then
        local offsets = base_offsets()
        local ground = GetWorld()
        for k,v in pairs(offsets) do
            local try_pos = playerpos + (v * 30)
            if not (ground.Map and ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) == GROUND.IMPASSABLE or ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) > GROUND.UNDERGROUND ) and 
            #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 10) <= 0 and
            ground.Pathfinder:IsClear(playerpos.x, playerpos.y, playerpos.z, try_pos.x, try_pos.y, try_pos.z, {ignorewalls = true}) then
                table.insert(spots, try_pos)
            end 
        end
    end
    if #spots > 0 then
    	return spots[#spots]
    end
end

local function spawntime_moose()
	return TUNING.TOTAL_DAY_TIME + (math.random() * TUNING.TOTAL_DAY_TIME * 2)
end

local goosemoose = 
{
	prefab = "moose",
	activeseason =  SEASONS.SPRING,
	attackduringoffseason = false,
	--playerstring = "ANNOUNCE_DEERCLOPS",
	attacksperseason = 1,
	--warnsound = "dontstarve/creatures/deerclops/distant",
	warnduration = 0,
	spawntimefn = spawntime_moose,
	onspawnfn = onspawn_moose,
	spawnposfn = spawnposfn_moose,
	spawnconditionsfn = spawnconditionfn_moose,
    minspawnday = TUNING.NO_BOSS_TIME,
}

local dragonfly = 
{
    prefab = "dragonfly",
    activeseason =  SEASONS.SUMMER,
    attackduringoffseason = false,
    playerstring = "ANNOUNCE_DEERCLOPS",
    attacksperseason = 1,
    warnsound = "dontstarve_DLC001/creatures/dragonfly/distant",
    warnduration = 60,
    minspawnday = TUNING.NO_BOSS_TIME,    
}

return
{
	DEERCLOPS = deerclops,
	BEARGER = bearger,
	GOOSEMOOSE = goosemoose,
    DRAGONFLY = dragonfly,
}