SaveIndex = Class(function(self)
	self:Init()
end)

function SaveIndex:Init()
	self.data =
	{
		slots=
		{
		}
	}
	for k = 1, NUM_SAVE_SLOTS do

		local filename = "latest_" .. tostring(k)

		if BRANCH ~= "release" then
			filename = filename .. "_" .. BRANCH
		end

		self.data.slots[k] = 
		{
			current_mode = nil,
			modes = {survival= {file = filename}},
			resurrectors = {},
			dlc = {},
			mods = {},
		}
	end
	self.current_slot = 1
end

function SaveIndex:GuaranteeMinNumSlots(numslots)
	if #self.data.slots < numslots then
		local filename = nil
		for i = 1, numslots do
			if self.data.slots[i] == nil then
				filename = "latest_" .. tostring(i)
				if BRANCH ~= "release" then
					filename = filename .. "_" .. BRANCH
				end
				self.data.slots[i] = 
				{
					current_mode = nil,
					modes = {survival= {file = filename}},
					resurrectors = {},
					dlc = {},
					mods = {},
				}
			end
		end
	end
end

function SaveIndex:GetSaveGameName(type, slot)

	local savename = nil
	type = type or "unknown"

	if type == "cave" then
		local cavenum = self:GetCurrentCaveNum(slot)
		local levelnum = self:GetCurrentCaveLevel(slot, cavenum)
		savename = type .. "_" .. tostring(cavenum) .. "_" .. tostring(levelnum) .. "_" .. tostring(slot)
	else
		savename = type.."_"..tostring(slot)
	end

	
	if BRANCH ~= "release" then
		savename = savename .. "_" .. BRANCH
	end
	return savename
end

function SaveIndex:GetSaveIndexName()
	local name = "saveindex" 
	if BRANCH ~= "release" then
		name = name .. "_"..BRANCH
	end
	return name
end

function SaveIndex:Save(callback)

	local data = DataDumper(self.data, nil, false)
    local insz, outsz = TheSim:SetPersistentString(self:GetSaveIndexName(), data, ENCODE_SAVES, callback)
end

function SaveIndex:Load(callback)
	--This happens on game start.
	local filename = self:GetSaveIndexName()
    TheSim:GetPersistentString(filename,
        function(load_success, str) 
			local success, savedata = RunInSandbox(str)

			-- If we are on steam cloud this will stop a currupt saveindex file from 
			-- ruining everyones day.. 
			if success and string.len(str) > 0 and savedata ~= nil then
				self.data = savedata
				print ("loaded "..filename)
			else
				print ("Could not load "..filename)
			end
			
	        if PLATFORM == "PS4" then 
                -- PS4 doesn't need to verify files. If they're missing then the save was damaged and wouldn't have been loaded.
                -- Just fire the callback and keep going.
                callback()  
            else
			    self:VerifyFiles(callback)                
			end
        end)    
end

--this also does recovery of pre-existing save files (sort of)
function SaveIndex:VerifyFiles(completion_callback)

	local pending_slots = {}
	for k,v in ipairs(self.data.slots) do
		pending_slots[k] = true
	end
	
	for k,v in ipairs(self.data.slots) do
		local dirty = false
		local files = {}
		if v.current_mode == "empty" then
			v.current_mode = nil
		end
		if v.modes then
			v.modes.empty = nil
			for k, v in pairs(v.modes) do
				table.insert(files, v.file)
			end
		end
		if not v.save_id then
			v.save_id = self:GenerateSaveID(k)
		end

		CheckFiles(function(status) 

			if v.modes then
				for kk,vv in pairs (v.modes) do
					if vv.file and not status[vv.file] then
						vv.file = nil
					end
				end

			 	if v.current_mode == nil then
			 		if v.modes.survival and v.modes.survival.file then
			 			v.current_mode = "survival"
			 		end
			 	end
			 end

		 	pending_slots[k] = nil

		 	if not next(pending_slots) then
		 		self:Save(completion_callback)
		 	end

		 end, files)
	end
end

function SaveIndex:GetModeData(slot, mode)
	if slot and mode and self.data.slots[slot] then
		if not self.data.slots[slot].modes then
			self.data.slots[slot].modes = {}
		end
		if not self.data.slots[slot].modes[mode] then
			self.data.slots[slot].modes[mode] = {}
		end
		return self.data.slots[slot].modes[mode]
	end

	return {}
end

function SaveIndex:SetSaveSeasonData()
	local seasondata = {}

	local seasonmgr = GetSeasonManager()
	if seasonmgr then
		seasondata["targetseason"] = seasonmgr.current_season
		seasondata["targetpercent"] = seasonmgr.percent_season
		seasondata["autumnlen"] = seasonmgr.autumnlength
		seasondata["winterlen"] = seasonmgr.winterlength
		seasondata["springlen"] = seasonmgr.springlength
		seasondata["summerlen"] = seasonmgr.summerlength
		seasondata["autumnenabled"] = seasonmgr.autumnenabled
		seasondata["winterenabled"] = seasonmgr.winterenabled
		seasondata["springenabled"] = seasonmgr.springenabled
		seasondata["summerenabled"] = seasonmgr.summerenabled
		seasondata["initialevent"] = seasonmgr.initialevent
	end

	if self.data~= nil and self.data.slots ~= nil and self.data.slots[self.current_slot] ~= nil then
	 	self.data.slots[self.current_slot].seasondata = seasondata
	end	
end

function SaveIndex:LoadSavedSeasonData()
	local seasonmgr = GetSeasonManager()
	local seasondata = self.data.slots[self.current_slot].seasondata
	if seasonmgr and seasondata then
		seasonmgr.target_season = seasondata["targetseason"]
		seasonmgr.target_percent = seasondata["targetpercent"]
		seasonmgr.autumnlength = seasondata["autumnlen"]
		seasonmgr.winterlength = seasondata["winterlen"]
		seasonmgr.springlength = seasondata["springlen"]
		seasonmgr.summerlength = seasondata["summerlen"]
		seasonmgr.autumnenabled = seasondata["autumnenabled"]
		seasonmgr.winterenabled = seasondata["winterenabled"]
		seasonmgr.springenabled = seasondata["springenabled"]
		seasonmgr.summerenabled = seasondata["summerenabled"]
		seasonmgr.initialevent = seasondata["initialevent"]
	end
	self.data.slots[self.current_slot].seasondata = nil
	self:Save(function () print("LoadSavedSeasonData CB") end)
end

function SaveIndex:GetSaveFollowers(doer)
	local followers = {}

	if doer.components.leader then
		for follower,v in pairs(doer.components.leader.followers) do
			-- Make sure the follower is alive
			if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
				local ent_data = follower:GetPersistData()
				table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
				follower:Remove()
			elseif follower then -- Otherwise remove it from the list and world
				doer.components.leader:RemoveFollower(follower)
				follower:Remove()
			end
		end
	end

	local eyebone = nil
	local queued_remove = {}

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
						local ent_data = follower:GetPersistData()
						table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
						if follower.components.container then
							table.insert(queued_remove, follower)
						else
							follower:Remove()
						end
					elseif follower then
						item.components.leader:RemoveFollower(follower)
						follower:Remove()
					end
				end
			end
		end

		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
								local ent_data = follower:GetPersistData()
								table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
								if follower.components.container then
									table.insert(queued_remove, follower)
								else
									follower:Remove()
								end
							elseif follower then
								item.components.leader:RemoveFollower(follower)
								follower:Remove()
							end
						end
					end
				end
			end
		end

		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower,v in pairs(eyebone.components.leader.followers) do
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then
					for j,item in pairs(follower.components.container.slots) do
						if item.components.leader then
							for follower,v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									local ent_data = follower:GetPersistData()
									table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
									follower:Remove()
								elseif follower then
									item.components.leader:RemoveFollower(follower)
									follower:Remove()
								end
							end
						end
					end
				end
			end
		end
	end

	for i,v in pairs(queued_remove) do
		v:Remove()
	end

	if self.data~= nil and self.data.slots ~= nil and self.data.slots[self.current_slot] ~= nil then
	 	self.data.slots[self.current_slot].followers = followers
	end	
end

function SaveIndex:LoadSavedFollowers(doer)
    local x,y,z = doer.Transform:GetWorldPosition()

	if doer.components.leader and self.data.slots[self.current_slot].followers then
		for idx,follower in pairs(self.data.slots[self.current_slot].followers) do
			local ent  = SpawnPrefab(follower.prefab)
			if ent ~= nil then
				ent:SetPersistData(follower.data)

		        local angle = TheCamera.headingtarget + math.random()*10*DEGREES-5*DEGREES
		        x = x + .5*math.cos(angle)
		        z = z + .5*math.sin(angle)
		 		ent.Transform:SetPosition(x,y,z)
		 		if ent.MakeFollowerFn then
		 			ent.MakeFollowerFn(ent, doer)
		 		end
		 		ent.components.follower:SetLeader(doer)
			end
		end
	end
end

function SaveIndex:GetResurrectorName( res )
	return self:GetSaveGameName(self.data.slots[self.current_slot].current_mode, self.current_slot)..":"..tostring(res.GUID)
end

function SaveIndex:GetResurrectorPenalty()
	if self.data.slots[self.current_slot].current_mode == "adventure" then
		return nil
	end

	local penalty = 0

	for k,v in pairs(self.data.slots[self.current_slot].resurrectors) do
		penalty = penalty + v
	end

	return penalty
end

function SaveIndex:ClearCavesResurrectors()
	if self.data.slots[self.current_slot].resurrectors == nil then
		self.data.slots[self.current_slot].resurrectors = {}
		return
	end

	for k,v in pairs(self.data.slots[self.current_slot].resurrectors) do
		if string.find(k, self:GetSaveGameName("cave", self.current_slot), 1, true) ~= nil then
			self.data.slots[self.current_slot].resurrectors[k] = nil
		end
	end

	if PLATFORM ~= "PS4" then 
	    self:Save(function () print("ClearCavesResurrectors CB") end)
    end	   
end

function SaveIndex:ClearCurrentResurrectors()
	if self.data.slots[self.current_slot].resurrectors == nil then
		self.data.slots[self.current_slot].resurrectors = {}
		return
	end

	for k,v in pairs(self.data.slots[self.current_slot].resurrectors) do
		if string.find(k, self:GetSaveGameName(self.data.slots[self.current_slot].current_mode, self.current_slot), 1, true) ~= nil then
			self.data.slots[self.current_slot].resurrectors[k] = nil
		end
	end

	if PLATFORM ~= "PS4" then 
	    self:Save(function () print("ClearCurrentResurrectors CB") end)
    end	   
end

function SaveIndex:RegisterResurrector(res, penalty)

	if self.data.slots[self.current_slot].resurrectors == nil then
		self.data.slots[self.current_slot].resurrectors = {}
	end
	print("RegisterResurrector", res)
	self.data.slots[self.current_slot].resurrectors[self:GetResurrectorName(res)] = penalty
	
	if PLATFORM ~= "PS4" then 
	    -- Don't need to save on each of these events as regular saveindex save will be enough to keep these consistent
	    self:Save(function () print("RegisterResurrector CB") end)
	end
end

function SaveIndex:DeregisterResurrector(res)

	if self.data.slots[self.current_slot].resurrectors == nil then
		self.data.slots[self.current_slot].resurrectors = {}
		return
	end

	print("DeregisterResurrector", res.inst)

	local name = self:GetResurrectorName(res)
	for k,v in pairs(self.data.slots[self.current_slot].resurrectors) do
		if k == name then
			print("DeregisterResurrector found", name)
			self.data.slots[self.current_slot].resurrectors[name] = nil
			
	        if PLATFORM ~= "PS4" then 
	            -- Don't need to save on each of these events as regular saveindex save will be enough to keep these consistent
			    self:Save(function () print("DeregisterResurrector CB") end)
			end
			return
		end
	end

	print("DeregisterResurrector", res.inst, "not found")
end

function SaveIndex:GetResurrector()
	if self.data.slots[self.current_slot].current_mode == "adventure" then
		return nil
	end
	if self.data.slots[self.current_slot].resurrectors == nil then
		return nil
	end
	for k,v in pairs(self.data.slots[self.current_slot].resurrectors) do
		return k
	end

	return nil
end

function SaveIndex:CanUseExternalResurector()
	return self.data.slots[self.current_slot].current_mode ~= "adventure"
end
function SaveIndex:GotoResurrector(cb)
	print ("SaveIndex:GotoResurrector()")

	if self.data.slots[self.current_slot].current_mode == "adventure" then
		assert(nil, "SaveIndex:GotoResurrector() In adventure mode! why are we here!!??")
		return
	end
	
	if self.data.slots[self.current_slot].resurrectors == nil then
		self.data.slots[self.current_slot].resurrectors = {}
		return
	end

	local file = string.split(self:GetResurrector(), ":")[1]
	local mode = string.split(file, "_")[1]

	print ("SaveIndex:GotoResurrector() File:", file, "Mode:", mode)
	if mode == "survival" then
		self:LeaveCave(cb)
	else
		local cavenum, level = string.match(file, "cave_(%d+)_(%d+)")
		cavenum = tonumber(cavenum)
		level = tonumber(level)
		print ("SaveIndex:GotoResurrector() File:", cavenum, "Mode:", level)
		self:EnterCave(cb, self.current_slot, cavenum, level)
	end

	print ("SaveIndex:GotoResurrector() done")
end

function SaveIndex:GetSaveData(slot, mode, cb)
	self.current_slot = slot
	local file = self:GetModeData(slot, mode).file
	TheSim:GetPersistentString(file, function(load_success, str)
		assert(load_success, "SaveIndex:GetSaveData: Load failed for file ["..file.."] please consider deleting this save slot and trying again.")

		assert(str, "SaveIndex:GetSaveData: Encoded Savedata is NIL on load ["..file.."]")
		assert(#str>0, "SaveIndex:GetSaveData: Encoded Savedata is empty on load ["..file.."]")

		local success, savedata = RunInSandbox(str)
		
		--[[
		if not success then
			local file = io.open("badfile.lua", "w")
			if file then
				str = string.gsub(str, "},", "},\n")
				file:write(str)
				
				file:close()
			end
		end--]]

		assert(success, "Corrupt Save file ["..file.."]")
		assert(savedata, "SaveIndex:GetSaveData: Savedata is NIL on load ["..file.."]")
		assert(GetTableSize(savedata)>0, "SaveIndex:GetSaveData: Savedata is empty on load ["..file.."]")

		cb(savedata)
	end)
end

function SaveIndex:GetPlayerData(slot, mode)
	local slot = slot or self.current_slot
	return self:GetModeData(slot, mode or self.data.slots[slot].current_mode).playerdata
end

function SaveIndex:DeleteSlot(slot, cb, save_options)
	local character = self.data.slots[slot].character
	local dlc = self.data.slots[slot].dlc
	local mods = self.data.slots[slot].mods
	local options = nil
	if  self.data.slots[slot] and  self.data.slots[slot].modes and self.data.slots[slot].modes.survival then
		options = self.data.slots[slot].modes.survival.options
	end

	local files = {}
	for k,v in pairs(self.data.slots[slot].modes) do
		local add_file = true
		if v.files then
			for kk, vv in pairs(v.files) do
				if vv == v.file then
					add_file = false
				end
				table.insert(files, vv)
			end
		end
		
		if add_file then
			table.insert(files, v.file)
		end
	end

	if next(files) then
		EraseFiles(nil, files)
	end

	local slot_exists = self.data.slots[slot] and self.data.slots[slot].current_mode
	if slot_exists then
		self.data.slots[slot] = { current_mode = nil, modes = {}}
		if save_options == true then
			self.data.slots[slot].character = character
			self.data.slots[slot].dlc = dlc
			self.data.slots[slot].mods = mods
			self.data.slots[slot].current_mode = "survival"
			self.data.slots[slot].modes["survival"] = {options = options}
		end
		self:Save(cb)		
	elseif cb then
		cb()
	end
end


function SaveIndex:ResetCave(cavenum, cb)
	
	local slot = self.current_slot

	if slot and cavenum and self.data.slots[slot] and self.data.slots[slot].modes.cave then
		
		local del_files = {}
		for k,v in pairs(self.data.slots[slot].modes.cave.files) do
			
			local cave_num = string.match(v, "cave_(%d+)_")
			if cave_num and tonumber(cave_num) == cavenum then
				table.insert(del_files, v)
			end
		end
		
		EraseFiles(cb, del_files)
	else
		if cb then
			cb()
		end
	end

end


function SaveIndex:EraseCaves(cb)
	local function onerased()
		self.data.slots[self.current_slot].modes.cave = {}
		self:Save(cb)
	end

	local files = {}
	
	if self.data.slots[self.current_slot] and self.data.slots[self.current_slot].modes and self.data.slots[self.current_slot].modes.cave then
		if self.data.slots[self.current_slot].modes.cave.file then
			table.insert(files, self.data.slots[self.current_slot].modes.cave.file)
		end
		if self.data.slots[self.current_slot].modes.cave.files then
			for kk, vv in pairs(self.data.slots[self.current_slot].modes.cave.files) do
				table.insert(files, vv)
			end
		end
	end
	EraseFiles(onerased, files)
end



function SaveIndex:EraseCurrent(cb)
	
	local current_mode = self.data.slots[self.current_slot].current_mode

	local function docaves()
		if current_mode == "survival" then
			self:EraseCaves(cb)
		else
			cb()
		end
	end

	local filename = ""
	local function onerased()	
		EraseFiles(docaves, {filename})
	end
	
	local data = self:GetModeData(self.current_slot, current_mode)
	filename = data.file
	data.file = nil
	data.playerdata = nil
	data.day = nil
	data.world = nil
	self:Save(onerased)
end

function SaveIndex:GetDirectionOfTravel()
	return self.data.slots[self.current_slot].direction,
			self.data.slots[self.current_slot].cave_num
end
function SaveIndex:GetCaveNumber()
	return  (self.data.slots[self.current_slot].modes and
			self.data.slots[self.current_slot].modes.cave and
			self.data.slots[self.current_slot].modes.cave.current_cave) or nil
end
function SaveIndex:SaveCurrent(onsavedcb, direction, cave_num)
	
	local ground = GetWorld()
	assert(ground, "missing world?")
	local level_number = ground.topology.level_number or 1
	local day_number = GetClock().numcycles + 1

	local function onsavedgame()
		self:Save(onsavedcb)
	end

	local current_mode = self.data.slots[self.current_slot].current_mode
	local data = self:GetModeData(self.current_slot, current_mode)
	local dlc = self.data.slots[self.current_slot].dlc
	local mods = ModManager:GetEnabledModNames() or self.data.slots[self.current_slot].mods

	self.data.slots[self.current_slot].character = GetPlayer().prefab
	self.data.slots[self.current_slot].direction = direction
	self.data.slots[self.current_slot].cave_num = cave_num
	self.data.slots[self.current_slot].dlc = dlc
	self.data.slots[self.current_slot].mods = mods
	if not direction then
		self.data.slots[self.current_slot].followers = nil
	end

	data.day = day_number
	data.playerdata = nil
	data.file = self:GetSaveGameName(current_mode, self.current_slot)
	SaveGame(self:GetSaveGameName(current_mode, self.current_slot), onsavedgame)
end

function SaveIndex:GetSlotDLC(slot)
	local dlc = self.data.slots[slot or self.current_slot].dlc 
	if not dlc then dlc = NO_DLC_TABLE end
	return dlc
end

function SaveIndex:SetSlotCharacter(saveslot, character, cb)
	self.data.slots[saveslot].character = character
	self:Save(cb)
end

function SaveIndex:SetCurrentIndex(saveslot)
	self.current_slot = saveslot
end

function SaveIndex:GetCurrentSaveSlot()
	return self.current_slot
end


--called upon relaunch when a new level needs to be loaded
function SaveIndex:OnGenerateNewWorld(saveslot, savedata, cb)
	--local playerdata = nil
	self.current_slot = saveslot
	local filename = self:GetSaveGameName(self.data.slots[self.current_slot].current_mode, self.current_slot)
	
	local function onindexsaved()
		cb()
		--cb(playerdata)
	end		

	local function onsavedatasaved()
		self.data.slots[self.current_slot].continue_pending = false
		local current_mode = self.data.slots[self.current_slot].current_mode
		local data = self:GetModeData(self.current_slot, current_mode)
		data.file = filename
		data.files = data.files or {}
		data.day = 1

		local found = false
		for k,v in pairs(data.files) do
			if v == filename then
				found = true
			end
		end

		if not found then 
			table.insert(data.files, filename)
		end


		
		--playerdata = data.playerdata
		--data.playerdata = nil

		self:Save(onindexsaved)
	end

	local insz, outsz = TheSim:SetPersistentString(filename, savedata, ENCODE_SAVES, onsavedatasaved)	
end


function SaveIndex:GetOrCreateSlot(saveslot)
	if self.data.slots[saveslot] == nil then
		self.data.slots[saveslot] = {}
	end
	return self.data.slots[saveslot]
end

function SaveIndex:PickRandomCharacter()
	local characters = GetActiveCharacterList()
	if not characters then return "wilson" end
	return characters[math.random(#characters)]
end

--call after you have worldgen data to initialize a new survival save slot
function SaveIndex:StartSurvivalMode(saveslot, character, customoptions, onsavedcb, dlc)
	self.current_slot = saveslot
--	local data = self:GetModeData(saveslot, "survival")
	local slot = self:GetOrCreateSlot(saveslot)

	if character == "random" then
		character = SaveIndex:PickRandomCharacter()
	end

	slot.character = character
	slot.current_mode = "survival"
	slot.save_id = self:GenerateSaveID(self.current_slot)
	slot.dlc = dlc and dlc or NO_DLC_TABLE
	slot.mods = ModManager:GetEnabledModNames() or {}
	print("SaveIndex:StartSurvivalMode!:", slot.dlc.REIGN_OF_GIANTS)

	slot.modes = 
	{
		survival = {
			--file = self:GetSaveGameName("survival", self.current_slot),
			day = 1,
			world = 1,
			options = customoptions
		},
	}
 	
    local starts = Profile:GetValue("starts") or 0
    Profile:SetValue("starts", starts+1)
	Profile:Save(function() self:Save(onsavedcb) end )
end

function SaveIndex:GenerateSaveID(slot)
	local now = os.time()
	return TheSim:GetUserID() .."-".. tostring(now) .."-".. tostring(slot)
end

function SaveIndex:GetSaveID(slot)
	slot = slot or self.current_slot
	return self.data.slots[slot].save_id
end

function SaveIndex:OnFailCave(onsavedcb)
	self.data.slots[self.current_slot].modes.cave.playerdata = nil
	self.data.slots[self.current_slot].current_mode = "survival"
	local playerdata = {}
    local player = GetPlayer()
    if player then
    	--remember our unlocked recipes
        playerdata.builder = player:GetSaveRecord().data.builder
        
        --set our meters to the standard resurrection amounts
        playerdata.health = {health = TUNING.RESURRECT_HEALTH}
		playerdata.hunger = {hunger = player.components.hunger.max*.66}
		playerdata.sanity = {current = player.components.sanity.max*.5}
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
		
   	end 

	if self.data.slots[self.current_slot].modes.survival then
		self.data.slots[self.current_slot].modes.survival.playerdata = playerdata
	end
	self:Save(onsavedcb)
end

function SaveIndex:LeaveCave(onsavedcb)
	local playerdata = {}
    local player = GetPlayer()
    if player then
        playerdata = player:GetSaveRecord().data
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
        
   	end 
	self.data.slots[self.current_slot].modes.cave.playerdata = nil
	self.data.slots[self.current_slot].current_mode = "survival"
	
	if self.data.slots[self.current_slot].modes.survival then
		self.data.slots[self.current_slot].modes.survival.playerdata = playerdata
	end
	self:Save(onsavedcb)
end


function SaveIndex:EnterCave(onsavedcb, saveslot, cavenum, level)
	self.current_slot = saveslot or self.current_slot

	--get the current player, and maintain his player data
 	local playerdata = {}
    local player = GetPlayer()
    if player then
        playerdata = player:GetSaveRecord().data
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
   	end  

	level = level or 1
	cavenum = cavenum or 1

	self.data.slots[self.current_slot].current_mode = "cave"
	
	if not self.data.slots[self.current_slot].modes.cave then
		self.data.slots[self.current_slot].modes.cave = {}
	end

	self.data.slots[self.current_slot].modes.cave.files = self.data.slots[self.current_slot].modes.cave.files or {}
	self.data.slots[self.current_slot].modes.cave.current_level = self.data.slots[self.current_slot].modes.cave.current_level or {}
	self.data.slots[self.current_slot].modes.cave.world = level or 1

	self.data.slots[self.current_slot].modes.cave.current_level[cavenum] = level
	self.data.slots[self.current_slot].modes.cave.current_cave = cavenum
	
	local savename = self:GetSaveGameName("cave", self.current_slot)
	self.data.slots[self.current_slot].modes.cave.playerdata = playerdata
	self.data.slots[self.current_slot].modes.cave.file = nil
	
	
	TheSim:CheckPersistentStringExists(savename, function(exists) 
		if exists then
			self.data.slots[self.current_slot].modes.cave.file = savename
		end
		self:Save(onsavedcb)
	 end)

end

function SaveIndex:OnFailAdventure(cb)
	local filename = self.data.slots[self.current_slot].modes.adventure.file

	local function onsavedindex()
		EraseFiles(cb, {filename})
	end
	self.data.slots[self.current_slot].current_mode = "survival"
	self.data.slots[self.current_slot].modes.adventure = {}
	self:Save(onsavedindex)
end

function SaveIndex:FakeAdventure(cb, slot, start_world)
	self.data.slots[slot].current_mode = "adventure"
	self.data.slots[slot].modes.adventure = {world = start_world, playlist = {1,2,3,4,5,6}}
 	self:Save(cb)
end

function SaveIndex:StartAdventure(cb)

	local function ongamesaved()
		local playlist = self.BuildAdventurePlaylist()
		self.data.slots[self.current_slot].current_mode = "adventure"
		self.data.slots[self.current_slot].modes.adventure = {world = 1, playlist = playlist}
	 	self:Save(cb)
	end

	self:SaveCurrent(ongamesaved)

end

function SaveIndex:BuildAdventurePlaylist()
	local levels = require("map/levels")

	local playlist = {}

	local remaining_keys = shuffledKeys(levels.story_levels)
	for i=1,levels.CAMPAIGN_LENGTH+1 do -- the end level is at position length+1
		for k_idx,k in ipairs(remaining_keys) do
			local level_candidate = levels.story_levels[k]
			if level_candidate.min_playlist_position <= i and level_candidate.max_playlist_position >= i then
				table.insert(playlist, k)
				table.remove(remaining_keys, k_idx)
				break
			end
		end
	end

	assert(#playlist == levels.CAMPAIGN_LENGTH+1)

	--debug
	print("Chosen levels:")
	for _,k in ipairs(playlist) do
		print("",levels.story_levels[k].name)
	end

	return playlist
end

--call when you have finished a survival or adventure level to increment the world number and save off the continue information
function SaveIndex:CompleteLevel(cb)
	local adventuremode = self.data.slots[self.current_slot].current_mode == "adventure"

    local playerdata = {}
    local player = GetPlayer()
    if player then
    	player:OnProgress()

		-- bottom out the player's stats so they don't start the next level and die
		local minhealth = 0.2
		if player.components.health:GetPercent() < minhealth then
			player.components.health:SetPercent(minhealth)
		end
		local minsanity = 0.3
		if  player.components.sanity:GetPercent() < minsanity then
			player.components.sanity:SetPercent(minsanity)
		end
		local minhunger = 0.4
		if  player.components.hunger:GetPercent() < minhunger then
			player.components.hunger:SetPercent(minhunger)
		end


        playerdata = player:GetSaveRecord().data
   	 end   

   	local function onerased()
   		if adventuremode then
   			self:Save(cb)
   		else
   			self:EraseCaves(cb)
   		end
   		--self:Save(cb)
   	end

	self.data.slots[self.current_slot].continue_pending = true
	self.data.slots[self.current_slot].direction = nil
	self.data.slots[self.current_slot].cave_num = nil
	self.data.slots[self.current_slot].followers = nil

	local current_mode = self.data.slots[self.current_slot].current_mode
	local data = self:GetModeData(self.current_slot, current_mode)

	data.day = 1
	data.world = data.world and (data.world + 1) or 2
 	data.playerdata = playerdata
	local file = data.file 
	data.file = nil
	EraseFiles( onerased, { file } )		
end

function SaveIndex:GetSlotDay(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.day or 1
end

-- The WORLD is the "depth" the player has traversed through the teleporters. 1, 2, 3, 4...
-- Contrast with the LEVEL, below.
function SaveIndex:GetSlotWorld(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.world or 1
end

-- The LEVEL is the index from levels.lua to load. This gets shuffled via the playlist.
function SaveIndex:GetSlotLevelIndexFromPlaylist(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	local world = data.world or 1
	if data.playlist and world <= #data.playlist then
		local level = data.playlist[world]
		return level
	else
		return world
	end
end

function SaveIndex:GetSlotCharacter(slot)
	local character = self.data.slots[slot or self.current_slot].character
	-- In case a file was saved with a mod character that has become disabled, fall back to wilson

	local charlist = GetActiveCharacterList()
	if not table.contains(charlist, character) and not table.contains(MODCHARACTERLIST, character) then
		character = "wilson"
	end
	return character
end

function SaveIndex:HasWorld(slot, mode)

	slot = slot or self.current_slot
	local current_mode = mode or self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.file ~= nil
end

function SaveIndex:GetSlotGenOptions(slot, mode)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.options
end

function SaveIndex:GetSlotMods(slot)
	slot = slot or self.current_slot
	if slot and self.data.slots[slot] and self.data.slots[slot].mods then
		return self.data.slots[slot].mods
	else
		return {}
	end
end

function SaveIndex:IsContinuePending(slot)
	return self.data.slots[slot or self.current_slot].continue_pending
end

function SaveIndex:GetCurrentMode(slot)
	return self.data.slots[slot or self.current_slot].current_mode
end

function SaveIndex:GetCurrentCaveLevel(slot, cavenum)
	slot = slot or self.current_slot
	cavenum = cavenum or self:GetModeData(slot, "cave").current_cave or cavenum or 1
	local cave_data = self:GetModeData(slot, "cave")
	if cave_data.current_level and cave_data.current_level[cavenum] then
		return cave_data.current_level[cavenum]
	end
	return 1
end

function SaveIndex:GetCurrentCaveNum(slot)
	slot = slot or self.current_slot
	return self:GetModeData(slot, "cave").current_cave or 1
end

function SaveIndex:GetNumCaves(slot)
	slot = slot or self.current_slot
	return self:GetModeData(slot, "cave").num_caves or 0
end


function SaveIndex:AddCave(slot, cb)
	slot = slot or self.current_slot
	
	self:GetModeData(slot, "cave").num_caves = self:GetModeData(slot, "cave").num_caves and self:GetModeData(slot, "cave").num_caves + 1 or 1
	self:Save(cb)
end


-- Global for saving game on Android focus lost event
function OnFocusLost()
	--check that we are in gameplay, not main menu
	if inGamePlay then
		SetPause(true)
		SaveGameIndex:SaveCurrent()
	end
end

function OnFocusGained()
	--check that we are in gameplay, not main menu
	if inGamePlay then
		SetPause(false)
	end
end
