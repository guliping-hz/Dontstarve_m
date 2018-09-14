local FlowerSpawner = Class(function(self, inst)
    self.inst = inst

    self.minDist = 35
    self.maxDist = 50

    self.timetospawn_variation = TUNING.FLOWER_SPAWN_TIME_VARIATION
    self.timetospawn = TUNING.FLOWER_SPAWN_TIME
    self.active = true
    
    self.spawntimer = self:GetSpawnTime()

    self.prefab = "flower"

    self.validTileTypes = {4,5,6,7,30}

    if self.inst.components.seasonmanager:IsRaining() then
    	self:Enable(true)
    end

    self.inst:ListenForEvent("rainstart", function() self:Enable(true) end)
    self.inst:ListenForEvent("rainstop", function() self:Enable(false) end)
end)

function FlowerSpawner:Enable(enable)
	if enable then
		self.inst:StartUpdatingComponent(self)
	else
		self.inst:StopUpdatingComponent(self)
	end
end

function FlowerSpawner:GetSpawnTime()
	return self.timetospawn + (math.random() * self.timetospawn_variation)
end

function FlowerSpawner:CheckTileCompatibility(tile)
	for k,v in pairs(self.validTileTypes) do
		if v == tile then
			return true
		end
	end
end

function FlowerSpawner:GetSpawnPoint(player)
	local pt = player:GetPosition()
    local theta = math.random() * 2 * PI
    local radius = math.random(self.minDist, self.maxDist)
    local steps = 40
    local ground = GetWorld()
    local validpos = {}
    for i = 1, steps do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local try_pos = pt + offset
        local tile = ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z)
        if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND ) and
        self:CheckTileCompatibility(tile) and 
		#TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 1) <= 0 then
			table.insert(validpos, try_pos)
        end
        theta = theta - (2 * PI / steps)
    end
    if #validpos > 0 then
    	local num = math.random(#validpos)
    	return validpos[num]
    else
    	return nil
    end
end

function FlowerSpawner:SpawnFlower(pt)
	local flower = SpawnPrefab(self.prefab)
	flower.Transform:SetPosition(pt:Get())
end

function FlowerSpawner:OnUpdate( dt )
    if self.active then
    	local player = GetPlayer()    
        if not player then return end

        self.spawntimer = self.spawntimer - dt

        if self.spawntimer <= 0 then
            -- Make sure we're not crowded on flowers before we actually spawn one
            local x,y,z = player.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y ,z , 50, {"flower"}) < TUNING.MAX_FLOWERS_PER_AREA then
            	local pt = self:GetSpawnPoint(player)

            	if pt then
            		self:SpawnFlower(pt)
            	end
            end

        	self.spawntimer = self:GetSpawnTime()
        end
    else
        self.inst:StopUpdatingComponent(self)
    end
end

function FlowerSpawner:GetDebugString()
	return "Next spawn: "..tostring(self.spawntimer)
end

function FlowerSpawner:OnSave()
    local data = {}
        data.spawntimer = self.spawntimer
        data.timetospawn = self.timetospawn
        data.timetospawn_variation = self.timetospawn_variation
        data.active = self.active
    return data
end

function FlowerSpawner:OnLoad(data)
    if data then
        self.spawntimer = data.spawntimer
        self.timetospawn = data.timetospawn or TUNING.FLOWER_SPAWN_TIME
        self.timetospawn_variation = data.timetospawn_variation or TUNING.FLOWER_SPAWN_TIME_VARIATION
        self.active = data.active or true
        if not self.active then
            self.inst:StopUpdatingComponent(self)
        end
    end
end

function FlowerSpawner:SpawnModeNever()
    self.timetospawn_variation = -1
    self.timetospawn = -1
    self.active = false
    self.inst:StopUpdatingComponent(self)
end

function FlowerSpawner:SpawnModeHeavy()
    self.timetospawn_variation = 5
    self.timetospawn = 10
end

function FlowerSpawner:SpawnModeMed()
    self.timetospawn_variation = 10
    self.timetospawn = 20
end

function FlowerSpawner:SpawnModeLight()
    self.timetospawn_variation = 15
    self.timetospawn = 60
end


return FlowerSpawner
