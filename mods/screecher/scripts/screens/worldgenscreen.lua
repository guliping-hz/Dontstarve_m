local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local MIN_GEN_TIME = 5

local WorldGenScreen = Class(Screen, function(self, profile, cb, world_gen_options)
	Screen._ctor(self, "WorldGenScreen")
    self.profile = profile
	self.log = true

    self.center_root = self:AddChild(Widget("root"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.worldgentext = self.center_root:AddChild(Text(NUMBERFONT, 40))
    self.worldgentext:SetPosition(0, 100, 0)
    self.worldgentext:SetString("Pillet Creek, January 1986")
	Settings.save_slot = Settings.save_slot or 1
	local gen_parameters = {}
	
	gen_parameters.level_type = world_gen_options.level_type
	if gen_parameters.level_type == nil then
		gen_parameters.level_type = "free"
	end
		
	gen_parameters.world_gen_choices = world_gen_options.custom_options
	if gen_parameters.world_gen_choices == nil then
		gen_parameters.world_gen_choices = {
			 		monsters = "default", animals = "default", resources = "default",
	    			unprepared = "default", 
	    			--prepared = "default", day = "default"
    			}
	end
	
	gen_parameters.current_level = world_gen_options.level_world

	if gen_parameters.level_type == "adventure" then
		if gen_parameters.current_level == nil or gen_parameters.current_level < 1 then
			gen_parameters.current_level = 1
		end

		gen_parameters.adventure_progress = world_gen_options.adventure_progress or 1
	end

	gen_parameters.profiledata = world_gen_options.profiledata
	if gen_parameters.profiledata == nil then
		gen_parameters.profiledata = { unlocked_characters = {} }
	end
	
	local moddata = {}
	moddata.index = KnownModIndex:CacheSaveData()

    TheSim:GenerateNewWorld( json.encode(gen_parameters), json.encode(moddata), function(worlddata) 
    		self.worlddata = worlddata
			self.done = true
		end)
		
	self.total_time = 0
	self.cb = cb
    TheFrontEnd:DoFadeIn(2)

	self.inst:DoTaskInTime(0.5, function()    
    	TheFrontEnd:GetSound():PlaySound("scary_mod/music/hit_low_piano", "worldgensound")    
    end)
	-- self.verbs = shuffleArray(STRINGS.UI.WORLDGEN.VERBS)
	-- self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS)
	
    -- self.verbidx = 1
    -- self.nounidx = 1
    -- self:ChangeFlavourText()
    
 --    if world_gen_options.level_type == "cave" then
 --    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/caveGen", "worldgensound")    
	-- else
	-- 	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/worldGen", "worldgensound")    
	-- end
end)

function WorldGenScreen:OnLoseFocus()
	Screen.OnLoseFocus(self)
	--TheFrontEnd:GetSound():KillSound("worldgensound")    
end

function WorldGenScreen:OnUpdate(dt)
	self.total_time = self.total_time + dt
	if self.done then
		if string.match(self.worlddata,"^error") then
			self.done = false
			self.cb(self.worlddata)
		elseif self.total_time > MIN_GEN_TIME and self.cb then
			self.done = false
			
			TheFrontEnd:Fade(false, 1, function() 
				self.cb(self.worlddata)
				end)
		end
	end

end

-- function WorldGenScreen:ChangeFlavourText()

-- 	self.flavourtext:SetString(self.verbs[self.verbidx] .. " " .. self.nouns[self.nounidx])

-- 	self.verbidx = (self.verbidx == #self.verbs) and 1 or (self.verbidx + 1)
-- 	self.nounidx = (self.nounidx == #self.nouns) and 1 or (self.nounidx + 1)

-- 	local time = GetRandomWithVariance(2, 1)
-- 	self.inst:DoTaskInTime(time, function() self:ChangeFlavourText() end)
-- end

return WorldGenScreen