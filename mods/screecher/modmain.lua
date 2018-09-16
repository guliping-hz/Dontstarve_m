PrefabFiles = {
	-- The basic monster wandering the island. It loves to eat campers.
	"shambler",
	-- The campers that the player must save from the island. might become a fake camper on activate.
	"camper",
	"newly_eaten_camper",
	--"tourists",
	-- An flashlight based on the torch
	"flashlight",
	-- An instance of a circle of light. Flashlight prefab uses a series of these to approx a beam.
	"flashlight_lightpiece",
	-- Some particles to play at the flashlight source.
	"flashlight_particles",
	-- The player character
	"counselor",
	-- Loot container (chance to drop battery (fuel for the flashlight), story item, or nothing
	"lootcontainer",
	-- Markers in the world to help you find your way
	"signpost",
	-- The sound of screecher hunting in the dark
	"stalking_noise",
	-- Drip drip drip!
	"waterfaucet",
	-- Poor saps
	"tourists",
	-- Where are we going?
	"helisign",

	"firepit",

	"shambler_spawner",

	-- Doodads
	"evergreen_border",
	"big_rock",
	"junk",
	"blood",
	"letters",
	"ground_grass",
	"scary_shadow",
	"generator",
	"helipad",
	"helicopter_beacon",
	"radio_stand",
	"creaksound",
	"tent_cone",
	"log_chunk"
}

Assets =
{
	Asset("SOUNDPACKAGE", "sound/scary_mod.fev"),
	Asset("SOUND", "sound/scary_mod.fsb"),  

	-- Note textures
	Asset("IMAGE", "images/hud/note1.tex"),
	Asset("ATLAS", "images/hud/note1.xml"),
	Asset("IMAGE", "images/hud/note2.tex"),
	Asset("ATLAS", "images/hud/note2.xml"),
	Asset("IMAGE", "images/hud/note3.tex"),
	Asset("ATLAS", "images/hud/note3.xml"),
	Asset("IMAGE", "images/hud/note4.tex"),
	Asset("ATLAS", "images/hud/note4.xml"),
	Asset("IMAGE", "images/hud/note5.tex"),
	Asset("ATLAS", "images/hud/note5.xml"),
	Asset("IMAGE", "images/hud/note9.tex"),
	Asset("ATLAS", "images/hud/note9.xml"),

	Asset("IMAGE", "images/hud/note_flashlight.tex"),
	Asset("ATLAS", "images/hud/note_flashlight.xml"),
	Asset("IMAGE", "images/hud/note_helicopter.tex"),
	Asset("ATLAS", "images/hud/note_helicopter.xml"),
	Asset("IMAGE", "images/hud/note_frequency.tex"),
	Asset("ATLAS", "images/hud/note_frequency.xml"),

	Asset("IMAGE", "images/hud/note_Jan09.tex"),
	Asset("ATLAS", "images/hud/note_Jan09.xml"),
	Asset("IMAGE", "images/hud/note_Jan12.tex"),
	Asset("ATLAS", "images/hud/note_Jan12.xml"),
	Asset("IMAGE", "images/hud/note_Jan14.tex"),
	Asset("ATLAS", "images/hud/note_Jan14.xml"),

	Asset("IMAGE", "images/hud/faceless.tex"),
	Asset("ATLAS", "images/hud/faceless.xml"),
	Asset("IMAGE", "images/hud/owl_face_1.tex"),
	Asset("ATLAS", "images/hud/owl_face_1.xml"),
	Asset("IMAGE", "images/hud/owl_face_2.tex"),
	Asset("ATLAS", "images/hud/owl_face_2.xml"),

	Asset("IMAGE", "images/hud/flashlight.tex"),
	Asset("ATLAS", "images/hud/flashlight.xml"),
	Asset("IMAGE", "images/hud/battery.tex"),
	Asset("ATLAS", "images/hud/battery.xml"),
	Asset("IMAGE", "images/hud/map.tex"),
	Asset("ATLAS", "images/hud/map.xml"),

	Asset("IMAGE", "images/hud/youdied.tex"),
	Asset("ATLAS", "images/hud/youdied.xml"),
	Asset("IMAGE", "images/shadow1.tex"),
	Asset("IMAGE", "images/screecher_main_menu.tex"),
	Asset("ATLAS", "images/screecher_main_menu.xml"),
	Asset("IMAGE", "images/screecher_logo.tex"),
	Asset("ATLAS", "images/screecher_logo.xml"),

	Asset("IMAGE", "colour_cubes/screecher_cc.tex"),
	Asset("IMAGE", "colour_cubes/screecher_cc_red_cc.tex"),

	Asset("IMAGE", "images/leader.tex"),
	Asset("ATLAS", "images/leader.xml"),
	Asset("IMAGE", "images/helipad.tex"),
	Asset("ATLAS", "images/helipad.xml"),
}

-- Set up some tuning values which will be used be our custom creatures and
-- components.

local DEBUGGING_MOD = false
GLOBAL.DEBUGGING_MOD = DEBUGGING_MOD
if DEBUGGING_MOD then

	GLOBAL.require("debugkeys")
	GLOBAL.require("consolecommands")
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_1, function(down)
		local shamb = GLOBAL.DebugSpawn("shambler")
		shamb.components.shamblermodes:SetKind("observer")
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_2, function(down)
		local shamb = GLOBAL.DebugSpawn("shambler")
		shamb.components.shamblermodes:SetKind("teaser")
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_3, function(down)
		local shamb = GLOBAL.DebugSpawn("shambler")
		shamb.components.shamblermodes:SetKind("killer")
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_4, function(down)
		local camper = GLOBAL.DebugSpawn("camper_runner")
		print("spawned a camper", camper)
	end, true)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_5, function(down)
		local camper = GLOBAL.DebugSpawn("camper_fake")
		print("spawned a camper", camper)
	end, true)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_0, function(down)
		GLOBAL.DebugSpawn("lootcontainer")
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_F, function(down)
		local player = GLOBAL.GetPlayer()
		local flashlight_ent = player.FlashlightEnt()
		if flashlight_ent == nil then
			flashlight_ent = GLOBAL.SpawnPrefab("flashlight")
			player.components.inventory:Equip(flashlight_ent)
			player:ListenForEvent("flashlighton", function() player:PushEvent("flashlighton") end, player.FlashlightEnt())
			player:ListenForEvent("flashlightoff", function() player:PushEvent("flashlightoff") end, player.FlashlightEnt())
			player:ListenForEvent("fuellow", function() player:PushEvent("fuellow") end, player.FlashlightEnt())
			player:ListenForEvent("fuelnotlow", function() player:PushEvent("fuelnotlow") end, player.FlashlightEnt())
			flashlight_ent.components.flicker:ToggleFlashlight()
			flashlight_ent.components.flicker:ToggleFlashlight()
		end
		flashlight_ent.components.lightfueldimmer:AddFuel(10000)
		--GLOBAL.c_select(flashlight_ent)
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_N, function(down)
		GLOBAL.GetPlayer().components.scarymodencountermanager:NextBeat()
	end)
	GLOBAL.AddGameDebugKey(GLOBAL.KEY_L, function(down)
		if not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) then
			local inst = GLOBAL.GetPlayer()
			inst.entity:AddLight()
		    inst.Light:Enable(true)
		    inst.Light:SetIntensity(1)
		    inst.Light:SetColour(1,1,1)
		    inst.Light:SetFalloff( 0.5 )
		    inst.Light:SetRadius( 40 )
		end	
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_B, function(down)
		if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) then
			GLOBAL.GetPlayer():PushEvent("change_breathing", {intensity = 3, duration=4})
		else
			GLOBAL.GetPlayer():PushEvent("change_breathing", {intensity = 2, duration=4})
		end
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_I, function(down)
		print("generator key pressed!")
		GLOBAL.GetPlayer().components.scarymodencountermanager:ChangeBeat(9)
		GLOBAL.c_gonext("generator")
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_9, function(down)
		GLOBAL.GetPlayer().HUD:StartCredits()
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_8, function(down)
		GLOBAL.GetPlayer():PushEvent("darknessdeath")
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_7, function(down)
		local center = GLOBAL.GetPlayer():GetPosition()
		local angle = math.random()*360
		local distance = GLOBAL.TUNING.INVISIBLE_STALK_SPAWN_DIST
		local result_offset = GLOBAL.FindValidPositionByFan(angle*GLOBAL.DEGREES, distance, 60, function(offset)
			local spawn_point = center + offset
			if (GLOBAL.TheSim:GetLightAtPoint(spawn_point:Get()) > GLOBAL.TUNING.DARK_CUTOFF) then
				return false
			end
			return true
		end)

		if result_offset then
			local soundent = GLOBAL.SpawnPrefab("stalking_noise")
			soundent.Transform:SetPosition( (center + result_offset):Get() )
			soundent.StartMoving()
		end
	end)

	GLOBAL.AddGameDebugKey(GLOBAL.KEY_P, function(down)
		GLOBAL.SetPause(not GLOBAL.IsPaused())
	end)

else
	GLOBAL.handlers = {}
end

local testtuning = false -- set this to quickly toggle to alternate values

-- GAMEPLAY values
GLOBAL.TUNING.CAMPERS_TO_FIND = 8
GLOBAL.TUNING.STARTING_BEAT = testtuning and 9 or 1
GLOBAL.TUNING.TIME_TO_TEACH_ROAD = 30
GLOBAL.TUNING.DIST_TO_CANCEL_TEACH_ROAD = 20

-- PLAYER values
GLOBAL.TUNING.WILSON_WALK_SPEED = 3
GLOBAL.TUNING.WILSON_RUN_SPEED = 5
GLOBAL.TUNING.COUNSELOR_HEALTH = 1000
GLOBAL.TUNING.ABOUT_FACE_REPEAT_TIME = 0.75
GLOBAL.TUNING.XDIR_CONTROLLER_VECTOR_MOD = 0.15
GLOBAL.TUNING.XDIR_TURN_IN_PLACE_MOD = 6
GLOBAL.TUNING.BEGIN_INTERACTION_RADIUS = 10
GLOBAL.TUNING.SCARY_MOD_DARKNESS_CUTOFF = 0.1--TUNING.LOW_FUEL_LEVEL / TUNING.MAX_FUEL_LEVEL
GLOBAL.TUNING.SCARY_MOD_INTERACT_ALWAYS_RADIUS = 4
GLOBAL.TUNING.SEARCH_CONTAINER_DURATION = 1.5
GLOBAL.TUNING.INTERACT_FIRST_CAMPER_DURATION = 48*GLOBAL.FRAMES
GLOBAL.TUNING.INTERACT_SECOND_CAMPER_DURATION = 5
GLOBAL.TUNING.INTERACT_THIRD_CAMPER_DURATION = 2
GLOBAL.TUNING.INTERACT_DEAD_CAMPER_DURATION = 1.2
GLOBAL.TUNING.START_FIRE_DURATION = 3
GLOBAL.TUNING.START_FIRE_DURATION_LONG = 5.5

-- CAMERA values
GLOBAL.TUNING.MOUSE_SENSITIVITY = 0.15 --Was originally 1.5
GLOBAL.TUNING.PITCH_ADJUSTMENT_MULTIPLIER = 5
GLOBAL.TUNING.DEFAULT_CAM_DISTANCE = 13
GLOBAL.TUNING.ZOOMED_CAM_DISTANCE = 10
GLOBAL.TUNING.PITCH_ADDITIONAL_OFFSET = 0.2
GLOBAL.TUNING.CAMERAY_OFFSET = 2

GLOBAL.TUNING.IS_FPS = false
if GLOBAL.TUNING.IS_FPS then
	GLOBAL.TUNING.DEFAULT_CAM_DISTANCE = 8
	GLOBAL.TUNING.ZOOMED_CAM_DISTANCE = 8
	GLOBAL.TUNING.CAMERAY_OFFSET = 4.5
end

-- SANITY values
GLOBAL.TUNING.SANITYAURA_MONSTER = 50
GLOBAL.TUNING.DAPPERNESS_FREE = 2

-- CAMPER values
GLOBAL.TUNING.CAMPER_WALK_SPEED = 6.7*1.5 --following
GLOBAL.TUNING.CAMPER_RUN_SPEED = 6.7*1.5 --panicking
GLOBAL.TUNING.CAMPER_HEALTH = 1
GLOBAL.TUNING.MIN_CAMPER_ECHOLOCATION_TIME = 2
GLOBAL.TUNING.MAX_CAMPER_ECHOLOCATION_TIME = 4
GLOBAL.TUNING.CAMPER_ACTIVATE_DISTANCE = 2
GLOBAL.TUNING.CAMPER_PROX_NEAR_DISTANCE = 25
GLOBAL.TUNING.CAMPER_PROX_FAR_DISTANCE = 32.5
GLOBAL.TUNING.TREE_ALPHA_AMOUNT = 0.25

-- SHAMBLER values
GLOBAL.TUNING.SHAMBLER_TARGET_DIST = 20
GLOBAL.TUNING.SHAMBLER_WALK_SPEED = 1
GLOBAL.TUNING.SHAMBLER_RUN_SPEED = 10.0
GLOBAL.TUNING.SHAMBLER_APPROACH_SPEED = 1.5
GLOBAL.TUNING.SHAMBLER_DAMAGE = 1
GLOBAL.TUNING.SHAMBLER_ATTACK_PERIOD = 0.5
GLOBAL.TUNING.SHAMBLER_ATTACK_RANGE = 1.0
GLOBAL.TUNING.SHAMBLER_FIRST_FLASH_FLICKER_CHANCE = 1
GLOBAL.TUNING.SHAMBLER_SUBSEQ_FLASH_FLICKER_CHANCE = 0.5
GLOBAL.TUNING.SHAMBLER_OBSERVER_AGGRO = 1.5
GLOBAL.TUNING.SHAMBLER_OBSERVER_ALERT_TIME = 1.2
GLOBAL.TUNING.SHAMBLER_OBSERVER_POOF_RANGE = 8
GLOBAL.TUNING.SHAMBLER_OBSERVER_DESPAWN_DISTANCE = 35
GLOBAL.TUNING.SHAMBLER_TEASER_AGGRO = 1.5
GLOBAL.TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER = 20
GLOBAL.TUNING.SHAMBLER_KILLER_AGGRO = 0.8
GLOBAL.TUNING.SHAMBLER_KILLER_APPROACH_SPEED = 22
GLOBAL.TUNING.SHAMBLER_LOCKON_RANGE = 9
GLOBAL.TUNING.SHAMBLER_KILL_RANGE = 8

-- INVISIBLE STALKER values
GLOBAL.TUNING.INVISIBLE_STALK_SPAWN_DIST = 20
GLOBAL.TUNING.INVISIBLE_STALK_MIN_DELAY = 15
GLOBAL.TUNING.INVISIBLE_STALK_MAX_DELAY = 25

-- FLASHLIGHT values
GLOBAL.TUNING.MIN_TIME_BETWEEN_FLICKER = 20
GLOBAL.TUNING.MAX_TIME_BETWEEN_FLICKER = 30
GLOBAL.TUNING.MIN_FLICKER_DURATION = 0.5
GLOBAL.TUNING.MAX_FLICKER_DURATION = 2.5
GLOBAL.TUNING.OFF_SUBFLICKER_TICKS = 6
GLOBAL.TUNING.ON_SUBFLICKER_TICKS = 1
GLOBAL.TUNING.FLICKER_DIM_AMOUNT = 0.5
GLOBAL.TUNING.MIN_REASONABLE_FUEL = 0.12
GLOBAL.TUNING.MIN_REASONABLE_BRIGHTNESS = 0.45
GLOBAL.TUNING.LOW_FUEL_LEVEL = 100 --This is the value at which we start to consider the player to be in darkness while flashlight is on
GLOBAL.TUNING.STARTING_FUEL_LEVEL = 3000 --How much fuel is in the battery the player starts with
GLOBAL.TUNING.MAX_FUEL_LEVEL = 10000 --this is also how many ticks it takes for the light to go to colour 0,0,0
-- The following two 'remove' amounts are added together, so that players lose fuel based on their current amount, but also can lose all their fuel
GLOBAL.TUNING.SHAMBLER_TEASE_FUEL_REMOVE_PCT = 0.2 -- percent of total fuel removed on shambler hit
GLOBAL.TUNING.SHAMBLER_TEASE_FUEL_REMOVE_REMAIN_PCT = 0.3 -- percent of remaining fuel removed on shambler hit
GLOBAL.TUNING.MIN_BATTERY_FUEL_AMOUNT = 5500
GLOBAL.TUNING.MAX_BATTERY_FUEL_AMOUNT = 8500
GLOBAL.TUNING.MAX_LIGHT_DISTANCE_FOR_CAM = 20 -- used to calcuate a snap ratio for shambler distance
GLOBAL.TUNING.HORIZ_SNAP_FORCE_FOR_CAM = 0.25 -- used to calcuate a snap ratio for shambler angle
-- DARKNESS/DEATH values
GLOBAL.TUNING.BLOOD_OVERLAY_VALUE_FOR_DEATH = 7.5
GLOBAL.TUNING.DARKNESS_STALKTIME = 4.5
GLOBAL.TUNING.DARKNESS_STALKTIME2 = 5

-- ENCOUNTER MANAGER and (FAKE) CAMPER values
GLOBAL.TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER = testtuning and 5 or 10
GLOBAL.TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER = testtuning and 7 or 25
GLOBAL.TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER2 = 40
GLOBAL.TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER2 = 50
GLOBAL.TUNING.SHAMBLER_SPAWN_DIST = {
	observer = 20,
	teaser = 20,
	killer = 16,
}
GLOBAL.TUNING.SHAMBLER_DESPAWN_DIST = 28
GLOBAL.TUNING.MIN_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE = 50
GLOBAL.TUNING.MAX_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE = 65
GLOBAL.TUNING.SHAMBLER_AGGRO_INCREASE_DELTA = 0.5
GLOBAL.TUNING.CAMPER_PANIC_COOLDOWN = 10
GLOBAL.TUNING.CAMPER_ALARM_REACTION_DELAY = 2
GLOBAL.TUNING.MIN_TIME_BETWEEN_NOTES = 60

-- MUSIC values
GLOBAL.TUNING.FIRST_MUSIC_INCREASE = 0.2
GLOBAL.TUNING.SECOND_MUSIC_INCREASE = 0.4
GLOBAL.TUNING.THIRD_MUSIC_INCREASE = 0.6
GLOBAL.TUNING.FOURTH_MUSIC_INCREASE = 0.8
GLOBAL.TUNING.FIFTH_MUSIC_INCREASE = 1.0

-- MISC OBJECTS
GLOBAL.TUNING.FAUCET_DRIP_RATE = 1.7
GLOBAL.TUNING.SIGN_READ_DISTANCE = 4

-- Allow the custom minimap icon for the main character
AddMinimapAtlas("images/leader.xml")
AddMinimapAtlas("images/helipad.xml")
-- Note that we still overwrite the minimap atlas because we need to stomp the
-- "reveal" shape for aesthetic reasons.

function PreparePlayerCharacter(player)
	-- The player entity isn't quite ready to equip items yet, so wait one frame
	player:DoTaskInTime(0, function()
        
		--Grab a reference to the home campfire
		local x, y, z = player.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 20, {"campfire"})
	    player.homefirepit = ents[1]

	    --Make sure the player is facing it
		player.Transform:SetRotation(player:GetAngleToPoint(Point(player.homefirepit.Transform:GetWorldPosition())))

		--Start being area-aware
		player.components.area_aware:StartCheckingPosition()

		GLOBAL.GetWorld().components.ambientsoundmixer:SetReverbPreset("woods")
	end)

	player:DoPeriodicTask(0, function()
		local playerfacing = player.Transform:GetRotation()
		GLOBAL.TheCamera:SetHeadingTarget(-playerfacing+180)
	end)

	-- debugging help
	GLOBAL.require("consolecommands")
	GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)

AddGlobalClassPostConstruct("saveindex", "SaveIndex", function(self)
	function self:GetSlotCharacter(saveslot)
		return "counselor"
	end
end)

local function PartiallyRevealMap(player)
	player:DoTaskInTime(0, function(inst)
		local ground = GLOBAL.GetWorld()
		for i=1,#ground.topology.nodes do
			local bg = string.find( ground.topology.ids[i], ":BG_" )
					or string.find( ground.topology.ids[i], ":BLOCKER_BLANK")
			if not bg then
				--print(">revealing",ground.topology.ids[i])
				local cent = ground.topology.nodes[i].cent
				ground.minimap.MiniMap:ShowArea(cent[1], 0, cent[2], 95)
			else
				--print("<ignoring",ground.topology.ids[i])
			end
		end
	end)
end
AddSimPostInit(PartiallyRevealMap)

local function FixMusicLevel()
	-- A lot of the atmosphere of the game comes from the music, so heck, it's forced to on!
	
	local fxvolume = GLOBAL.TheMixer:GetLevel( "set_sfx" )
	local musicvolume = GLOBAL.TheMixer:GetLevel( "set_music" )
	local ambientvolume = GLOBAL.TheMixer:GetLevel( "set_ambience" )

	if musicvolume < fxvolume then musicvolume = fxvolume end
	if ambientvolume < fxvolume then ambientvolume = fxvolume end

	GLOBAL.TheMixer:SetLevel("set_sfx", fxvolume  )
	GLOBAL.TheMixer:SetLevel("set_music", musicvolume  )
	GLOBAL.TheMixer:SetLevel("set_ambience", ambientvolume  )
end
AddGamePostInit(FixMusicLevel)

local function ForceDisableController()
	--If the controller is enabled, it locks out mouse input and handled keyboard input poorly
	--So we disable all controllers and then re-enable the mouse
	GLOBAL.TheInput:DisableAllControllers()
	GLOBAL.TheInput:EnableMouse(true)
end
AddGamePostInit(ForceDisableController)

-- Add the action and action handler for toggling the flashlight
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
local toggleflashlightact = Action(4, true, true)
toggleflashlightact.str = "Toggle Flashlight"
toggleflashlightact.id = "TOGGLEFLASHLIGHT"
toggleflashlightact.fn = function(act)
    local flashlight = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if flashlight and flashlight.components.flicker then
        flashlight.components.flicker:ToggleFlashlight()
        return true
    end
end
AddAction(toggleflashlightact)
AddStategraphActionHandler("counselor", GLOBAL.ActionHandler(toggleflashlightact, "doflashlighttoggle"))

-------------------------------------------------------------------------------
-- Sanity auras are simplified and changed:
-- * Changes to Recalc
--   * Ignore time of day
--   * Ignore light ? (May add this back in)
--   * Linear falloff for sanity auras instead of exponential. I might make this 
--     constant, even. The goal is for shamblers to make you crazy when you are
--     near by them.
--   * Ignore weather
-- * Changes to OnUpdate
--   * Make the effects play more frequently, rather than just when you are
--     really insane.
-------------------------------------------------------------------------------
AddComponentPostInit("sanity", function(component)

	GLOBAL.require("mathutil")


	--component.debugger = component.inst.entity:AddDebugRender()

	function component:Recalc(dt)
		local total_dapperness = self.dapperness or 0
		local mitigates_rain = false
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.dapperness then
				total_dapperness = total_dapperness + v.components.dapperness:GetDapperness(self.inst)
			end		
		end
		local dapper_delta = total_dapperness*GLOBAL.TUNING.SANITY_DAPPERNESS

		local aura_delta = 0
		local x,y,z = self.inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x,y,z, GLOBAL.TUNING.SANITY_EFFECT_RANGE)
--component.debugger:Flush()
		for k,v in pairs(ents) do 
			if v.components.sanityaura and v ~= self.inst and not v:IsInLimbo() then
				local dist = math.sqrt(self.inst:GetDistanceSqToInst(v))
				local aura_pct = GLOBAL.Lerp(0, 1, (GLOBAL.TUNING.SANITY_EFFECT_RANGE-dist)/GLOBAL.TUNING.SANITY_EFFECT_RANGE)
				local aura_val = aura_pct * v.components.sanityaura:GetAura(self.inst)
				if aura_val < 0 then
					aura_val = aura_val * self.neg_aura_mult
				end

				local p2 = v:GetPosition()
--component.debugger:Line(x, z, p2.x, p2.z, aura_pct, 1-aura_pct, 0, 1)
--component.debugger:String(aura_val, p2.x, p2.z, 0.5)

				aura_delta = aura_delta + aura_val
			end
		end

		--if delta < 0 then
			--if delta*dt < TUNING.SANITY_DECAY_RATE*dt then
				--self:DoDelta(TUNING.SANITY_DECAY_RATE*dt, true)
			--else
				--self:DoDelta(delta*dt, true)
			--end
		--elseif delta > 0 then
			--if delta*dt > TUNING.SANITY_RESTORE_RATE*dt then
				--self:DoDelta(TUNING.SANITY_RESTORE_RATE*dt, true)
			--else
				--self:DoDelta(delta*dt, true)
			--end
		--end

		self.rate = (dapper_delta + aura_delta)

		--print (string.format("dapper: %2.2f light: %2.2f TOTAL: %2.2f", dapper_delta, light_delta, self.rate*dt))
		self:DoDelta(self.rate*dt, true)
	end

	local easing = GLOBAL.require("easing")
	
	function component:OnUpdate(dt)
		
		local speed = easing.outQuad( 1 - self:GetPercent(), 0, .2, 1) 
		self.fxtime = self.fxtime + dt*speed
		
		GLOBAL.PostProcessor:SetEffectTime(self.fxtime)
		
		local distortion_value = easing.inQuad( self:GetPercent(), 0, 1, 1) 
		--local colour_value = 1 - easing.outQuad( self:GetPercent(), 0, 1, 1) 
		--PostProcessor:SetColourCubeLerp( 1, colour_value )
		GLOBAL.PostProcessor:SetDistortionFactor(distortion_value)
		GLOBAL.PostProcessor:SetDistortionRadii( 0.5, 0.685 )

		if self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
			return
		end
		
		self:Recalc(dt)	
	end
end)

-- Rename the stinger played on "goinsane" to null. Throws an FMOD error in log
-- But it prevents the stinger from playing.  Hacky, but works...
RemapSoundEvent("dontstarve/sanity/gonecrazy_stinger", "")

-- Make things not inspectable anymore without having to hack every prefab
--AddComponentPostInit("inspectable", function(component)
--	function component:CollectSceneActions(doer, actions)
--		return
--	end
--end)

-- Make things not glow when you mouseover them, except for a few special cases
AddComponentPostInit("highlight", function(component)
	function component:ApplyColour()
		if self.inst.AnimState and self.inst:HasTag("CLICK") then
			self.inst.AnimState:SetAddColour((self.highlight_add_colour_red or 0) + (self.base_add_colour_red or 0), (self.highlight_add_colour_green or 0) + (self.base_add_colour_green or 0), (self.highlight_add_colour_blue or 0) + (self.base_add_colour_blue or 0), 0)
		end
	end

	function component:UnHighlight()
	    self.highlit = nil
		self.highlight_add_colour_red = nil
	    self.highlight_add_colour_green = nil
	    self.highlight_add_colour_blue = nil
		self:ApplyColour()   

		-- Get rid of this garbage behavior. WHY DOES IT DO THIS?
		-- if not self.flashing then
		-- 	self.inst:RemoveComponent("highlight")
		-- end
	end
end)

-- Fix the combat so that shamblers will always pick the best target between the player and the campers
AddComponentPostInit("combat", function(component)
	function component:SuggestTarget(target)
		self:SetTarget(target)
		return true
	end
end)

local GROUND = GLOBAL.GROUND
-- We are overrideing CHECKER and CARPET graphically with grass and forest in order to get more ambient variations
local tiledefs = GLOBAL.require('worldtiledefs')
for i,v in ipairs(tiledefs.ground) do
	if v[1] == GROUND.CHECKER then
		v[2].name = "grass"
		v[2].noise_texture = "levels/textures/Ground_noise.tex"
		v[2].runsound = "dontstarve/movement/run_grass"
		v[2].walksound = "dontstarve/movement/walk_grass"
	elseif v[1] == GROUND.CARPET then
		v[2].name = "forest"
		v[2].noise_texture = "levels/textures/Ground_noise.tex"
		v[2].runsound = "dontstarve/movement/run_woods"
		v[2].walksound = "dontstarve/movement/walk_woods"
	end
end

-- Redefine the ambient sound mixer's update volume function to not pass along sanity param
AddComponentPostInit("ambientsoundmixer", function(component)

	function component:UpdateAmbientVolumes()
		local is_winter = GLOBAL.GetSeasonManager():IsWinter()

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
			
			if self.playing_waves and is_winter ~= self.winter_waves then
				self.inst.SoundEmitter:KillSound("waves")
				self.playing_waves = false
			end
			
			if not self.playing_waves then
				self.inst.SoundEmitter:PlaySound("dontstarve/ocean/waves", "waves")
				self.playing_waves = true
				self.winter_waves = is_winter
			end
			
			-- 5 in the last bit of math is for the local half_tiles var in the orig file
			self.wave_volume = math.max(0, math.min(1, self.num_waves / ((5*5*4)*.667)))
			self.inst.SoundEmitter:SetVolume("waves", self.wave_volume)
		else
			self.wave_volume = 0
			if self.playing_waves then
				self.inst.SoundEmitter:KillSound("waves")
				self.playing_waves = false
			end
		end
	end
end)

local alwaysonobjects = 
{
	"campfirefire",
	"gravestone",
	"rock1",
	"rock2",
	"marsh_tree",
	"marsh_bush",
	"rock_flintless",
	"evergreen",
	"evergreen_sparse",
	"tent_cone",
	"lootcontainer",
	"note1",
	"note2",
	"note3",
	"generator",
	"radio_stand",
	"helipad",
	"helicopter_beacon",
	"camper_runner",
	"camper_fake",
	"camper_cowerer",
	"big_rock",
	"stalking_noise",
	"totem_pole",
	"sign_to_ritual",
	"sign_to_totem",
	"sign_to_scoutcamp",
	"sign_to_bigrock",
	"sign_campsite",
}

local function AlwayOn(inst)
	inst.entity:SetCanSleep(false) 
end

for k, v in pairs(alwaysonobjects) do
	AddPrefabPostInit(v, AlwayOn)	
end

local tofadein = {
	"camper",
	"grass",
	"berrybush",
	"berrybush2",
	"rocks",
}

local function FadeFromSleep(inst)
	local task = nil
	local t = 0
	local function fadein(inst)
		t = t+0.01
		if t >= 1 then
			t = 1
			task:Cancel()
		end
		inst.AnimState:SetMultColour(t,t,t,t)
		
	end

	inst.OnEntityWake = function()
		t = 0
		inst.AnimState:SetMultColour(0,0,0,0)
		task = inst:DoPeriodicTask(0, fadein)
	end
end

for k, v in pairs(tofadein) do
	AddPrefabPostInit(v, FadeFromSleep)
end

local function Shrinken(inst)
	local scale = 0.5 + math.random()*4/10
	inst.Transform:SetScale(scale, scale, scale)
end

local function RandomSize(inst)
	local scale = 0.75 + math.random()/2
	inst.Transform:SetScale(scale, scale, scale)

end

AddPrefabPostInit("rock1", Shrinken)
AddPrefabPostInit("rock2", Shrinken)
AddPrefabPostInit("rock_flintless", Shrinken)
AddPrefabPostInit("log_chunk", RandomSize)

GLOBAL.require "screens/popupdialog"
GLOBAL.require "screens/newgamescreen"
GLOBAL.require "widgets/statusdisplays"
local Widget = GLOBAL.require "widgets/widget"
local TextButton = GLOBAL.require "widgets/textbutton"
local ImageButton = GLOBAL.require "widgets/imagebutton"
local Image = GLOBAL.require "widgets/image"
local easing = GLOBAL.require("easing")

RemapSoundEvent("dontstarve/music/music_FE", "")
RemapSoundEvent("dontstarve/HUD/click_move", "scary_mod/stuff/blood_drip_HUD")
RemapSoundEvent("dontstarve/HUD/click_mouseover", "")

-- Update Main screen to not have all the junk
local function UpdateMainScreen(self)
	self.updatename:SetString("Don't Starve: The Screecher")

	--remove buttons
	if self.motd then
		if self.motd.button then
			self.motd.button:Kill()
		end
		self.motd:Kill()
	end
	if self.wilson then
		self.wilson:Kill()
	end
	if self.shield then
		self.shield:Kill()
	end
	if self.banner then
		self.banner:Kill()
	end
	if self.submenu then
		self.submenu:Kill()
	end
	if self.promo then
		self.promo:Kill()
	end
	if self.screecher then
		self.screecher:Kill()
	end
	if self.beta_reg then
		self.beta_reg:Kill()
	end

	-- the images have a 1-unit offset to get rid of the black line that sometimes appears
	self.bg:SetTexture("images/screecher_main_menu.xml", "screecher_main_menu.tex")

	self.logo = self.fixed_root:AddChild(Image("images/screecher_logo.xml", "screecher_logo.tex"))
    self.logo:SetVRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.logo:SetHRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.logo:SetPosition(400-70, 210-50, 0)

    local logoscale = 0.5
    self.logo:SetScale(logoscale,logoscale,logoscale)

	-- this prevents stale component errors
	function self:SetMOTD(str, cache)
		return
	end

	local function StartGame()
		GLOBAL.DisableAllDLC() --Screecher does not work with DLC. Disable all of it.
		GLOBAL.TheFrontEnd:GetSound():KillSound("FEMusic")
		--GLOBAL.TheFrontEnd:GetSound():PlaySound("scary_mod/stuff/bloodyground_HUD")
		GLOBAL.TheFrontEnd:Fade(false, 3, function()
			-- IMPORTANT!! We use a slot named "screecher" here, so that we don't clobber any of
			-- the player's Don't Starve saves.
			GLOBAL.StartNextInstance({reset_action=GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot = "screecher"})
			GLOBAL.SaveGameIndex:StartSurvivalMode("screecher", "wilson", {}, onsaved)
		end)
		-- As soon as they click, eat the cursor
		GLOBAL.TheInputProxy:SetCursorVisible(false)
	end

	local function DisableScreecherMod()
		local PopupDialogScreen = GLOBAL.require("screens/popupdialog")

		GLOBAL.require("strings")

		GLOBAL.STRINGS.UI.MAINSCREEN.SCREECHER_QUIT_DIALOG_TITLE = "Wilson Awaits"
		GLOBAL.STRINGS.UI.MAINSCREEN.SCREECHER_QUIT_DIALOG_TEXT = "The game has to be restarted to return to Don't Starve."

		local function DoDisable()
			GLOBAL.KnownModIndex:Disable("screecher")
			GLOBAL.KnownModIndex:Save()
			TheSim:Quit()
		end
		TheFrontEnd:PushScreen(PopupDialogScreen(GLOBAL.STRINGS.UI.MAINSCREEN.SCREECHER_QUIT_DIALOG_TITLE, GLOBAL.STRINGS.UI.MAINSCREEN.SCREECHER_QUIT_DIALOG_TEXT,
		{
			{text=GLOBAL.STRINGS.UI.MODSSCREEN.RESTART, cb = function() DoDisable() end },
			{text=GLOBAL.STRINGS.UI.MODSSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
		}))
	end

	local STRINGS = GLOBAL.STRINGS
	local Vector3 = GLOBAL.Vector3

	--self.menu.horizontal = true
	self.menu.offset = 50
	self.MainMenu = function(self)		
		local menu_items = {}
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.EXIT, cb= function() self:OnExitButton() end})
		table.insert( menu_items, {text="Don't Starve", cb= DisableScreecherMod })
		table.insert(menu_items, {text="Settings", cb= function() self:Settings() end})
		table.insert(menu_items, {text="Begin", cb=StartGame, offset = Vector3(0,0,0)})
		self:ShowMenu(menu_items)
		self.main_menu = true
	end

	self.fxtime = 0
	self.OnUpdate = function(self, dt)
		local sin = math.sin
		local gettime = GLOBAL.GetTime
		local clock = GLOBAL.GetClock()

	    local time = gettime()*20
		local flicker = ( sin( time ) + sin( time + 2 ) + sin( time + 0.7777 ) ) / 2.0 -- range = [-1 , 1]
		flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
		flicker = flicker / 10 -- range = 0:0.1
		flicker = math.min(flicker,0.1)
		self.bg:SetTint(0.9+flicker,0.85,0.85,1)
	end
	self.ShowMenu = function(self, menu_items)
		self.mainmenu = false
		self.menu:Clear()
		
		for k,v in ipairs(menu_items) do
			self.menu:AddItem(v.text, v.cb, v.offset)
		end

		self.menu:SetPosition(
				-110,--320,--GLOBAL.RESOLUTION_X/2,-- -200 + self.menu.offset * (#menu_items-1),
				-270,-- -GLOBAL.RESOLUTION_Y/2,
				0
			)
		self.menu:SetFocus()
	end

	self.menu.AddItem = function(self, text, cb, offset)
		local pos = Vector3(0,0,0)
		pos.y = pos.y + self.offset * #self.items
		
		if offset then
			pos = pos + offset	
		end
		
		local button = self:AddChild(TextButton())
		button:SetPosition(pos)
		button:SetText(text)

		button:SetTextColour(0.9,0.8,0.6,1)
		button:SetOnClick( cb )
		button:SetFont(GLOBAL.BUTTONFONT)
		button:SetTextSize(40)    

		table.insert(self.items, button)

		self:DoFocusHookups()
		return button
	end

	self:MainMenu()
	self.menu:SetFocus()

	--GLOBAL.TheFrontEnd:GetSound():KillSound("FEMusic")
	GLOBAL.TheFrontEnd:GetSound():PlaySound("scary_mod/music/gamemusic", "FEMusic")
	--GLOBAL.TheFrontEnd:GetSound():PlaySound("scary_mod/stuff/bloodyground_HUD")
end

AddClassPostConstruct("screens/mainscreen", UpdateMainScreen)

