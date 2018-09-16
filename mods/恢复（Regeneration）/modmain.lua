
local require = GLOBAL.require


--[[
    
***************************************************************
Created by: BrokenValyrie
Date: 18/12/2013
Description: Regenerates health while full and sanity when healthy
***************************************************************

]]

-- Get data from configuration
local HUNGER_PERCENT_NEEDED = GetModConfigData("HUNGER_PERCENT_NEEDED")
local HEALTH_BASE_REGEN = GetModConfigData("HEALTH_BASE_REGEN")
local HEALTH_MIN_REGEN_PERCENT = GetModConfigData("HEALTH_MIN_REGEN_PERCENT")
local HEALTH_PERCENT_NEEDED = GetModConfigData("HEALTH_PERCENT_NEEDED")
local SANITY_BASE_REGEN = GetModConfigData("SANITY_BASE_REGEN")
local SANITY_MIN_REGEN_PERCENT = GetModConfigData("SANITY_MIN_REGEN_PERCENT")
local AoS_OPTION = GetModConfigData("AoS")

--This is derived from the thirst mod 1.2 but the proper credit goes to simplex
--Feel free to use.
--This adds the function to the world, at the time this function is called Active character list will be updated including mod character.

AddPrefabPostInit("world", function(inst)
		GLOBAL.assert( GLOBAL.GetPlayer() == nil )
		local player_prefab = GLOBAL.SaveGameIndex:GetSlotCharacter()
		GLOBAL.TheSim:LoadPrefabs( {player_prefab} )
		local oldfn = GLOBAL.Prefabs[player_prefab].fn
		--Get the character and add the component.
		GLOBAL.Prefabs[player_prefab].fn = function()
			local inst = oldfn()
			inst:AddComponent("regeneration")
			inst.components.regeneration:SetHealthRegenData(HUNGER_PERCENT_NEEDED, HEALTH_BASE_REGEN, HEALTH_MIN_REGEN_PERCENT)
			inst.components.regeneration:SetSanityRegenData(HEALTH_PERCENT_NEEDED, SANITY_BASE_REGEN, SANITY_MIN_REGEN_PERCENT)
			if (player_prefab == "wolfgang") then
				inst.components.regeneration:Wolfgang()
			end
			return inst
		end
end)


--Check for always on status
local _G = _G or GLOBAL
local AlwaysOnStatusActive = false
 
for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
    if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Always On Status" then
		 AlwaysOnStatusActive = true
    end
end

--Above code is failing to detect Always on Status
if AoS_option then
	 AlwaysOnStatusActive = true
end
 


--Add the arrow indicator.
local require = GLOBAL.require
local HealthArrowWidget = require("widgets/healtharrow")
local SanityArrowWidget = require("widgets/sanityarrow")


local function AddHealthArrow(self)
	local statusdisplay = self
	--At the moment this doesn't benefit from owner, but passing owner may have uses later.
	statusdisplay.HealthArrow = statusdisplay:AddChild(HealthArrowWidget(statusdisplay.owner))
	if ( AlwaysOnStatusActive == true) then
		statusdisplay.HealthArrow:SetPosition(62,35,0)
	else
		statusdisplay.HealthArrow:SetPosition(40,20,0)
	end
end

local function AddSanityArrow(self)
	local statusdisplay = self
	statusdisplay.SanityArrow = statusdisplay:AddChild(SanityArrowWidget(statusdisplay.owner))
	--This does not disable the process calculating the arrow, its kinda wasting process.
	statusdisplay.brain.sanityarrow:GetAnimState():SetBank("")
	statusdisplay.brain.sanityarrow:GetAnimState():SetBuild("")
	if ( AlwaysOnStatusActive == true) then
		statusdisplay.SanityArrow:SetPosition(0,10,0)
	else
		statusdisplay.SanityArrow:SetPosition(0,-40,0)
	end
end

AddClassPostConstruct( "widgets/statusdisplays", AddHealthArrow)
AddClassPostConstruct( "widgets/statusdisplays", AddSanityArrow)
