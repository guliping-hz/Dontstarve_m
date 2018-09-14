local easing = require "easing"

local wave_to_season = {
	["winter"] = SEASONS.WINTER,
	["spring"] = SEASONS.SPRING,
	["summer"] = SEASONS.SUMMER,
	["autumn"] = SEASONS.AUTUMN,
}
local season_to_wave = {
	[SEASONS.WINTER] = "winter",
	[SEASONS.SPRING] = "spring",
	[SEASONS.SUMMER] = "summer",
	[SEASONS.AUTUMN] = "autumn",
}
local wave_sound = { 
	["autumn"] = "dontstarve/ocean/waves",
	["winter"] = "dontstarve/winter/winterwaves",
	["spring"] = "dontstarve/ocean/waves",--"dontstarve_DLC001/spring/springwaves",
	["summer"] = "dontstarve_DLC001/summer/summerwaves",
}

local half_tiles = 5

local AmbientSoundMixer = Class(function(self, inst)
    self.inst = inst
    
    self.playing_waves = false
    self.num_waves = 0
    self.wave_volume = 0
    self.current_wave = "autumn"
    
	self.ambient_vol = 1
	self.daynightparam = 1.0
	self.playing_sounds = {}
	self.override = {}

	self.rainchange = false
	self.seasonchange = false
	
	self.ambient_sounds =
	{
		--[GROUND.IMPASSABLE] = {sound = "dontstarve/ocean/waves"},
		[GROUND.ROAD] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},--springsound="dontstarve_DLC001/spring/springrockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},
		[GROUND.ROCKY] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},--springsound="dontstarve_DLC001/spring/springrockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},
		[GROUND.DIRT] = {sound="dontstarve/badland/badlandAMB", wintersound="dontstarve/winter/winterbadlandAMB", springsound="dontstarve/badland/badlandAMB", summersound="dontstarve_DLC001/summer/summerbadlandAMB", rainsound="dontstarve/rain/rainbadlandAMB"},--springsound="dontstarve_DLC001/spring/springbadlandAMB", summersound="dontstarve_DLC001/summer/summerbadlandAMB", rainsound="dontstarve/rain/rainbadlandAMB"},
		[GROUND.WOODFLOOR] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},--springsound="dontstarve_DLC001/spring/springrockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},
		[GROUND.SAVANNA] = {sound="dontstarve/grassland/grasslandAMB", wintersound="dontstarve/winter/wintergrasslandAMB", springsound="dontstarve/grassland/grasslandAMB", summersound="dontstarve_DLC001/summer/summergrasslandAMB", rainsound="dontstarve/rain/raingrasslandAMB"},--springsound="dontstarve_DLC001/spring/springgrasslandAMB", summersound="dontstarve_DLC001/summer/summergrasslandAMB", rainsound="dontstarve/rain/raingrasslandAMB"},
		[GROUND.GRASS] = {sound="dontstarve/meadow/meadowAMB", wintersound="dontstarve/winter/wintermeadowAMB", springsound="dontstarve/meadow/meadowAMB", summersound="dontstarve_DLC001/summer/summermeadowAMB", rainsound="dontstarve/rain/rainmeadowAMB"},--springsound="dontstarve_DLC001/spring/springmeadowAMB", summersound="dontstarve_DLC001/summer/summermeadowAMB", rainsound="dontstarve/rain/rainmeadowAMB"},
		[GROUND.FOREST] = {sound="dontstarve/forest/forestAMB", wintersound="dontstarve/winter/winterforestAMB", springsound="dontstarve/forest/forestAMB", summersound="dontstarve_DLC001/summer/summerforestAMB", rainsound="dontstarve/rain/rainforestAMB"},--springsound="dontstarve_DLC001/spring/springforestAMB", summersound="dontstarve_DLC001/summer/summerforestAMB", rainsound="dontstarve/rain/rainforestAMB"},
		[GROUND.MARSH] = {sound="dontstarve/marsh/marshAMB", wintersound="dontstarve/winter/wintermarshAMB", springsound="dontstarve/marsh/marshAMB", summersound="dontstarve_DLC001/summer/summermarshAMB", rainsound="dontstarve/rain/rainmarshAMB"},--springsound="dontstarve_DLC001/spring/springmarshAMB", summersound="dontstarve_DLC001/summer/summermarshAMB", rainsound="dontstarve/rain/rainmarshAMB"},
		[GROUND.DECIDUOUS] = {sound="dontstarve/forest/forestAMB", wintersound="dontstarve/winter/winterforestAMB", springsound="dontstarve/forest/forestAMB", summersound="dontstarve_DLC001/summer/summerforestAMB", rainsound="dontstarve/rain/rainforestAMB"},
		[GROUND.DESERT_DIRT] = {sound="dontstarve/badland/badlandAMB", wintersound="dontstarve/winter/winterbadlandAMB", springsound="dontstarve/badland/badlandAMB", summersound="dontstarve_DLC001/summer/summerbadlandAMB", rainsound="dontstarve/rain/rainbadlandAMB"},
		[GROUND.CHECKER] = {sound="dontstarve/chess/chessAMB", wintersound="dontstarve/winter/winterchessAMB", springsound="dontstarve/chess/chessAMB", summersound="dontstarve_DLC001/summer/summerchessAMB", rainsound="dontstarve/rain/rainchessAMB"},--springsound="dontstarve_DLC001/spring/springchessAMB", summersound="dontstarve_DLC001/summer/summerchessAMB", rainsound="dontstarve/rain/rainchessAMB"},
		[GROUND.CAVE] = {sound="dontstarve/cave/caveAMB"},
		
		[GROUND.FUNGUS] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.FUNGUSRED] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.FUNGUSGREEN] = {sound="dontstarve/cave/fungusforestAMB"},
		
		[GROUND.SINKHOLE] = {sound="dontstarve/cave/litcaveAMB"},
		[GROUND.UNDERROCK] = {sound="dontstarve/cave/caveAMB"},
		[GROUND.MUD] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.UNDERGROUND] = {sound="dontstarve/cave/caveAMB"},
		[GROUND.BRICK] = {sound="dontstarve/cave/ruinsAMB"},
		[GROUND.BRICK_GLOW] = {sound="dontstarve/cave/ruinsAMB"},
		[GROUND.TILES] = {sound="dontstarve/cave/civruinsAMB"},
		[GROUND.TILES_GLOW] = {sound="dontstarve/cave/civruinsAMB"},
		[GROUND.TRIM] = {sound="dontstarve/cave/ruinsAMB"},
		[GROUND.TRIM_GLOW] = {sound="dontstarve/cave/ruinsAMB"},
		["ABYSS"] = {sound="dontstarve/cave/pitAMB"},
		["VOID"] = {sound="dontstarve/chess/void", wintersound="dontstarve/chess/void", springsound="dontstarve/chess/void", summersound="dontstarve/chess/void", rainsound="dontstarve/chess/void"},
		["CIVRUINS"] = {sound="dontstarve/cave/civruinsAMB"},
	}

	for k,v in pairs(self.ambient_sounds) do
		if v.sound and not self.playing_sounds[v.sound] then
			self.playing_sounds[v.sound] = {sound = v.sound, volume = 0, playing= false}
		end
		if v.wintersound and not self.playing_sounds[v.wintersound] then
			self.playing_sounds[v.wintersound] = {sound = v.wintersound, volume = 0, playing= false}
		end
		if v.springsound and not self.playing_sounds[v.springsound] then
			self.playing_sounds[v.springsound] = {sound = v.springsound, volume = 0, playing= false}
		end
		if v.summersound and not self.playing_sounds[v.summersound] then
			self.playing_sounds[v.summersound] = {sound = v.summersound, volume = 0, playing= false}
		end
		if v.rainsound and not self.playing_sounds[v.rainsound] then
			self.playing_sounds[v.rainsound] = {sound = v.rainsound, volume = 0, playing= false}
		end		
	end

    TheSim:SetReverbPreset("default")
    
    self.inst:ListenForEvent( "dusktime", function(it, data) 
			self:SetSoundParam(1.5)
        end, GetWorld())      

    self.inst:ListenForEvent( "daytime", function(it, data) 
			self:SetSoundParam(1.0)
        end, GetWorld())      

    self.inst:ListenForEvent( "nighttime", function(it, data) 
			self:SetSoundParam(2.0)
        end, GetWorld())      


    self.inst:ListenForEvent( "warnstart", function(it, data) 
			self:SetSoundParam(1.5)
        end, GetWorld())      

    self.inst:ListenForEvent( "calmstart", function(it, data) 
			self:SetSoundParam(1.0)
        end, GetWorld())      

    self.inst:ListenForEvent( "nightmarestart", function(it, data) 
			self:SetSoundParam(2.0)
        end, GetWorld())  

    self.inst:ListenForEvent( "dawnstart", function(it, data) 
		self:SetSoundParam(1.5)
    end, GetWorld())        


	self.inst:StartUpdatingComponent(self)
	
	self.inst.SoundEmitter:PlaySound( "dontstarve/sanity/sanity", "SANITY")
    
end)

function AmbientSoundMixer:SetOverride(src, target)
	self.override[src] = target
end

function AmbientSoundMixer:OnUpdate(dt)
	self:UpdateAmbientGeoMix()
	self:UpdateAmbientTimeMix(dt)	
	self:UpdateAmbientVolumes()
end

function AmbientSoundMixer:GetDebugString()
	local str = {}
	
	table.insert(str, "AMBIENT SOUNDS:\n")
	table.insert(str, string.format("atten=%2.2f, day=%2.2f, waves=%2.2f\n", self.ambient_vol, self.daynightparam, self.wave_volume))
	
	for k,v in pairs(self.playing_sounds) do
		local vol = v.volume
		if vol > 0 then
			table.insert(str, string.format("\t%s = %2.2f\n", v.sound, vol))
		end
	end
	return table.concat(str, "")
	
end



function AmbientSoundMixer:SetSoundParam(val)
	self.daynightparam = val
	for k,v in pairs(self.playing_sounds) do
		
		if v.playing then
			self.inst.SoundEmitter:SetParameter( v.sound, "daytime", val )
		end
	end
	
end

function AmbientSoundMixer:UpdateAmbientVolumes()
	local season = GetSeasonManager():GetSeason()
	
	local player = GetPlayer()
	local sanity_level = 1
	if player.components.sanity ~= nil then
		sanity_level = player.components.sanity:GetPercent()
	end

	self.inst.SoundEmitter:SetParameter( "SANITY", "sanity", 1-sanity_level )
	

	for k,v in pairs(self.playing_sounds) do
		local vol = self.ambient_vol * v.volume
		
		if vol > 0 ~= v.playing then
			if vol > 0 then
				self.inst.SoundEmitter:PlaySound( v.sound, v.sound)
				self.inst.SoundEmitter:SetParameter( v.sound, "daytime", self.daynightparam )
			else
				self.inst.SoundEmitter:KillSound(v.sound)
			end
			v.playing = vol > 0
		end
		
		if v.playing then
			self.inst.SoundEmitter:SetVolume(v.sound, vol)
		end
	end
	
	if self.num_waves > 0 then
		
		if self.playing_waves and season ~= wave_to_season[self.current_wave] then
			self.inst.SoundEmitter:KillSound("waves")
			self.playing_waves = false
		end
		
		if not self.playing_waves then
			self.current_wave = season_to_wave[season]
			self.inst.SoundEmitter:PlaySound(wave_sound[self.current_wave], "waves")
			self.playing_waves = true
		end
		
		self.wave_volume = math.max(0, math.min(1, self.num_waves / ((half_tiles*half_tiles*4)*.667)))
		self.inst.SoundEmitter:SetVolume("waves", self.wave_volume)
	else
		self.wave_volume = 0
		if self.playing_waves then
			self.inst.SoundEmitter:KillSound("waves")
			self.playing_waves = false
		end
	end
	
end


function AmbientSoundMixer:UpdateAmbientTimeMix(dt)
    --night/dusk ambient is attenuated in the light
    local player = nil
    local atten_vol = 1
    local fade_in_speed = 1/20
    
    local lowlight = .2
    local highlight = .9
    local lowvol = .5
    
	local player = GetPlayer()
	if player and player.LightWatcher then
		local isnight = not GetClock():IsDay()
		
		if isnight then
            local lightval = player.LightWatcher:GetLightValue()
            
            if lightval > highlight then
                atten_vol = lowvol
            elseif lightval < lowlight then
                self.ambient_vol = 1
            else
                self.ambient_vol = easing.outCubic( lightval - lowlight, 1, lowvol-1, highlight - lowlight) 
            end
            
        else
            if self.ambient_vol < 1 then
                self.ambient_vol = math.min(1, self.ambient_vol + fade_in_speed*dt)
            end
        end
    end
end

function AmbientSoundMixer:SetRainChanged()
	self.rainchange = true
end

function AmbientSoundMixer:SetSeasonChanged()
	self.seasonchange = true
end

--update the ambient mix based upon the player's surroundings
function AmbientSoundMixer:UpdateAmbientGeoMix()
	local season = GetSeasonManager():GetSeason()
	local MAX_AMB = 3
	local player = GetPlayer()
	local ground = GetWorld()
	if player and ground then
		local position = Vector3(player.Transform:GetWorldPosition())
		
		--only update if we've actually walked somewhere new
		if (self.lastpos and self.lastpos:DistSq(position) < 16) and not self.rainchange and not self.seasonchange then
			return
		end
		self.lastpos = position
		if self.rainchange then self.rainchange = false end
		if self.seasonchange then self.seasonchange = false end
				
		local x, y = ground.Map:GetTileCoordsAtPoint(position.x, position.y, position.z)
		
		local sound_mix = {}
		
		
		local num_waves = 0


		for xx = -half_tiles, half_tiles do
			for yy = -half_tiles, half_tiles do
				local tile = ground.Map:GetTile(x + xx, y +yy)
				-- HACK HACK HACK	
				if self.override[tile] ~= nil then
					tile = self.override[tile]
				end
				
				if tile and tile == GROUND.IMPASSABLE then
					num_waves = num_waves + 1
				elseif tile and self.ambient_sounds[tile] then
					local sound = nil
					
					if GetSeasonManager():IsHeavyRaining() and self.ambient_sounds[tile].rainsound then
						sound = self.ambient_sounds[tile].rainsound
					elseif season == SEASONS.WINTER and self.ambient_sounds[tile].wintersound then
						sound = self.ambient_sounds[tile].wintersound
					elseif season == SEASONS.SPRING and self.ambient_sounds[tile].springsound then
						sound = self.ambient_sounds[tile].springsound
					elseif season == SEASONS.SUMMER and self.ambient_sounds[tile].summersound then
						sound = self.ambient_sounds[tile].summersound
					else
						sound = self.ambient_sounds[tile].sound
					end

					if sound then
						if sound_mix[sound] then
							sound_mix[sound].count = sound_mix[sound].count + 1
						else
							sound_mix[sound] = {count = 1}
						end
					end
				end
			end
		end

		
		self.num_waves = num_waves
		if GetWorld():HasTag("cave") then self.num_waves = 0 end
		
		local sorted_mix = {}
		for k,v in pairs(sound_mix) do
			table.insert(sorted_mix, {sound=k, count=v.count})
		end
		
		table.sort(sorted_mix, function(a,b) return a.count > b.count end)
		
		local total = 0
		for k,v in ipairs(sorted_mix) do
			if k <= MAX_AMB then
				total = total + v.count
				sound_mix[v.sound].play = true
			else
				break
			end
		end
		
		for k,v in pairs(self.playing_sounds) do
			local sound_rec = sound_mix[v.sound]
			if sound_rec and sound_rec.play then
				v.volume = sound_rec.count/total
			else
				v.volume = 0
			end
		end
	end
end


function AmbientSoundMixer:SetReverbPreset(reverb)
	TheSim:SetReverbPreset(reverb)
end


return AmbientSoundMixer
