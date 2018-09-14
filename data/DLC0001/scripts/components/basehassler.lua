local function OnSeasonChange(inst, data)
	local hassler = inst.components.basehassler
	hassler:DoSeasonChange(data)
end

local BaseHassler = Class(function(self, inst) 
	self.inst = inst
	self.season = nil --The last season I heard about
	self.hassler_states =
	{
		DORMANT = "DORMANT", --Will not attack again this season.
		WAITING = "WAITING", --Waiting for time to attack.
		WARNING = "WARNING", --Currently doing warning sounds. (state ends on hassler spawn)
	}
	self.hasslers = {}

	self.inst:ListenForEvent("seasonChange", OnSeasonChange)
	self.inst:StartUpdatingComponent(self)
end)

function BaseHassler:GetDebugString()
	local str = string.format(" SEASON: %s \n", self.season or "NIL")
		for k,v in pairs(self.hasslers) do
			str = str..string.format("	--"..k..": %s\n", self:GetHasslerState(k) or "NIL")
			if self:GetHasslerState(k) ~= "DORMANT" then
				str = str..string.format("		--Number of Spawn Attempts: %i / %i \n", self.hasslers[k].numspawnattempts or 0, self.hasslers[k].spawnconditionoverride)
				str = str..string.format("		--Attacks Left: %i \n", self.hasslers[k].attacks_left or 0)
				str = str..string.format("		--Time to State Advance: %i \n", self.hasslers[k].timer or 0)
				str = str..string.format("		--Done For Season: %s \n", tostring(self.hasslers[k].done_for_season) or "NIL")
			end
		end
	return str
end

function BaseHassler:AddHassler(name, data)
	local t = {}

	t.prefab = data.prefab
	t.activeseason = data.activeseason
	t.attackduringoffseason = data.attackduringoffseason
	t.playerstring = data.playerstring
	t.attacksperseason = data.attacksperseason
	t.warnsound = data.warnsound
	t.warnduration = data.warnduration
	t.chance = data.chance or 0.67

	--Custom functions, not required.
	t.spawntimefn = data.spawntimefn --Custom spawn time logic
	t.spawnconditionsfn = data.spawnconditionsfn --Must return true for hassler to spawn
	t.spawnconditionoverride = data.spawnconditionoverride or 5 --Number of attempts until hassler just spawns.
	t.spawnposfn = data.spawnposfn --Custom spawn position logic
	t.onspawnfn = data.onspawnfn --On spawn callback
	t.minspawnday = data.minspawnday
	--

	t.timer = 0
	t.warnsound_timer = 0
	t.playerannounce_timer = 0
	t.attacks_left = 0
	t.time_between_attacks = nil
	t.done_for_season = false
	t.HASSLER_STATE = "DORMANT"
	t.numspawnattempts = 0

	self.hasslers[name] = t

	self:OnAddHassler(name)
end

function BaseHassler:OnAddHassler(name)
	local currentseason = GetWorld().components.seasonmanager:GetSeason()
	local h = self.hasslers[name]
	--print("BaseHassler:OnAddHassler -", name)

	if h.activeseason == currentseason or h.attackduringoffseason then
		self:SetUpAttacks(name)
	end
end

function BaseHassler:ResetHasslers()
	for k,v in pairs(self.hasslers) do
		v.done_for_season = false
	end
end

function BaseHassler:DoSeasonChange(data)
	--print("BaseHassler:DoSeasonChange")
	local currentseason = (data and data.season) or GetWorld().components.seasonmanager:GetSeason()

	if not self.season then
		self.season = currentseason
	else
		if self.season ~= currentseason then
			self:ResetHasslers()
			self.season = currentseason
		end
	end
	
	for k,v in pairs(self.hasslers) do
		local validtime = true

		if v.minspawnday then
			validtime = GetClock():GetNumCycles() >= v.minspawnday
		end

		if (v.activeseason == currentseason or v.attackduringoffseason) and not v.done_for_season and validtime then
			self:SetUpAttacks(k)
		else
			v.done_for_season = true
			if not self:IsHasslerState(k, "DORMANT") then
				self:CancelAttacks(k)
			end
		end
	end
end

function BaseHassler:SetUpAttacks(name)
	local h = self.hasslers[name]
	--print("SetUpAttacks -", name)
	h.done_for_season = false
	h.attacks_left = h.attacksperseason
	h.time_between_attacks = nil
	if self:IsHasslerState(name, "DORMANT") then
		self:AdvanceHasslerState(name)
	end
end

function BaseHassler:CancelAttacks(name)
	local h = self.hasslers[name]
	--print("CancelAttacks -",name)
	h.time_between_attacks = nil
	h.attacks_left = 0
	self:AdvanceHasslerState(name)
end

function BaseHassler:OverrideAttacksPerSeason(name, num)
	local h = self.hasslers[name]	
	h.attacksperseason = num
end

function BaseHassler:OverrideAttackDuringOffSeason(name, bool)
	local h = self.hasslers[name]
	h.attackduringoffseason = bool
end

function BaseHassler:OverrideAttackChance(name, chance)
	local h = self.hasslers[name]
	h.chance = chance
end

function BaseHassler:OverrideMinSpawnDay(name, day)
	local h = self.hasslers[name]
	h.minspawnday = day
end

----STATE MANAGEMENT----

function BaseHassler:AdvanceHasslerState(name)

	--print("AdvanceHasslerState -", name)

	local h = self.hasslers[name]

	if h.attacks_left <= 0 then
		self:SetHasslerState(name, "DORMANT")
		return
	end

	if self:IsHasslerState(name, "DORMANT") or
	self:IsHasslerState(name, "WARNING") then
		h.timer = self:GetWaitingTime(name)	
		if h.timer < 0 then h.timer = 0 end
		self:SetHasslerState(name, "WAITING")
	elseif self:IsHasslerState(name, "WAITING") then
		h.timer = self:GetWarningTime(name)
		self:SetHasslerState(name, "WARNING")
		if math.random() >= h.chance then
			self:SkipHasslerSpawn(name)
		end	
	end
end

function BaseHassler:GetHasslerState(name)
	return self.hasslers[name].HASSLER_STATE
end

function BaseHassler:SetHasslerState(name, state)
	--print("SetHasslerState -", name, state)
	self.hasslers[name].HASSLER_STATE = self.hassler_states[state]
end

function BaseHassler:IsHasslerState(name, state)
	return self:GetHasslerState(name) == self.hassler_states[state]
end

-------------------------------

function BaseHassler:GetWaitingTime(name)
	local h = self.hasslers[name]

	if h.spawntimefn then
		return h.spawntimefn(h)
	end

	if h.time_between_attacks then
		return h.time_between_attacks
	end

	local timeLeftInSeason = GetSeasonManager():GetDaysLeftInSeason() * TUNING.TOTAL_DAY_TIME

	if h.attacksperseason == 1 then
		return timeLeftInSeason * math.clamp(math.random(), .7, .85)
	elseif h.attacksperseason > 1 then
		h.time_between_attacks = (timeLeftInSeason * 0.75) / h.attacksperseason
		return h.time_between_attacks
	end
end

function BaseHassler:GetWarningTime(name)
	return self.hasslers[name].warnduration
end

function BaseHassler:GetSpawnLocation(name)
	local h = self.hasslers[name]

	if h.spawnposfn then
		return h.spawnposfn()
	end

	local pt = GetPlayer():GetPosition()
    local theta = math.random() * 2 * PI
    local radius = 35

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

function BaseHassler:PlayWarningSound(name)
	local h = self.hasslers[name]

	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.persists = false
	local theta = math.random() * 2 * PI
	local radius = math.clamp(Lerp(5, 25, h.timer/90), 5, 25)
	local offset = GetPlayer():GetPosition() +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

	inst.Transform:SetPosition(offset:Get())
	inst.SoundEmitter:PlaySound(h.warnsound)
	inst:DoTaskInTime(1.5, function() inst:Remove() end)
end

function BaseHassler:PlayerAnnounce(name)
	local h = self.hasslers[name]
	GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, h.playerstring))	
end

function BaseHassler:SkipHasslerSpawn(name)
	local h = self.hasslers[name]

	h.attacks_left = h.attacks_left - 1

	if h.attacks_left <= 0 then
		h.done_for_season = true
	end

	self:AdvanceHasslerState(name)
end

function BaseHassler:SpawnHassler(name)
	local h = self.hasslers[name]

	local conditionsmet = true

	if h.spawnconditionsfn then
		conditionsmet = h.spawnconditionsfn(self.inst)
	end

	if not conditionsmet and h.numspawnattempts < h.spawnconditionoverride then
		h.numspawnattempts = h.numspawnattempts + 1
		return false
	end

	local pos = self:GetSpawnLocation(name)

	if not pos then		
		return false
	end

	local hassler = SpawnPrefab(h.prefab)
	hassler.Transform:SetPosition(pos:Get())


	if h.onspawnfn then
		h.onspawnfn(hassler)
	end

	h.attacks_left = h.attacks_left - 1
	h.numspawnattempts = 0

	if h.attacks_left <= 0 then
		h.done_for_season = true
	end

	return true
end

function BaseHassler:OnUpdate(dt)

	for k,v in pairs(self.hasslers) do
		local h = self.hasslers[k]
		if self:IsHasslerState(k, "WAITING") then
			h.timer = h.timer - dt
			
			if h.timer <= 0 then
				self:AdvanceHasslerState(k)
			end

		elseif self:IsHasslerState(k, "WARNING") then

			h.warnsound_timer = math.max(0, h.warnsound_timer - dt)
			h.timer = math.max(0, h.timer - dt)
			h.playerannounce_timer = math.max(0, h.playerannounce_timer - dt)

			if h.warnsound_timer <= 0 and h.warnsound then
				self:PlayWarningSound(k)
				h.warnsound_timer = h.warnduration/6
				--Reset warnsound timer
			end

			if h.playerannounce_timer <= 0 and h.playerstring then
				self:PlayerAnnounce(k)
				h.playerannounce_timer = h.warnduration/3
			end

			if h.timer <= 0 then
				--Spawn hassler
				if self:SpawnHassler(k) then
					--Only advance state once hassler has spawned.
					self:AdvanceHasslerState(k)
				else
					h.timer = 5
				end
			end

		end
	end

end

function BaseHassler:LongUpdate(dt)
	self:OnUpdate(dt)
end

function BaseHassler:OnSave()
	local data = {}
	data.season = self.season
	for k,v in pairs(self.hasslers) do
		if not data.hasslers then
			data.hasslers = {}
		end

		local t = {}

		t.timer = v.timer
		t.warnsound_timer = v.warnsound_timer
		t.playerannounce_timer = v.playerannounce_timer
		t.attacks_left = v.attacks_left
		t.time_between_attacks = v.time_between_attacks
		t.HASSLER_STATE = v.HASSLER_STATE
		t.done_for_season = v.done_for_season
		t.attacksperseason = v.attacksperseason
		t.attackduringoffseason = v.attackduringoffseason
		t.chance = v.chance
		t.numspawnattempts = v.numspawnattempts
		t.spawnconditionoverride = v.spawnconditionoverride

		data.hasslers[k] = t
	end

	return data
end

function BaseHassler:OnLoad(data)
	if data and data.hasslers then
		
		self.season = data.season

		for k,v in pairs(data.hasslers) do
			local h = self.hasslers[k]

			h.timer = v.timer
			h.warnsound_timer = v.warnsound_timer
			h.playerannounce_timer = v.playerannounce_timer
			h.attacks_left = v.attacks_left
			h.time_between_attacks = v.time_between_attacks
			h.HASSLER_STATE = v.HASSLER_STATE
			h.done_for_season = v.done_for_season
			h.attacksperseason = v.attacksperseason
			h.attackduringoffseason = v.attackduringoffseason
			h.chance = v.chance
			h.numspawnattempts = v.numspawnattempts or 0
			h.spawnconditionoverride = v.spawnconditionoverride or 5

			self:SetHasslerState(k, v.HASSLER_STATE)
			--print(k, "Setting Hassler State: OnLoad -", v.HASSLER_STATE)

			if self:IsHasslerState(k, "DORMANT") then
				self:CancelAttacks(k)
			end

		end
	end
end

return BaseHassler