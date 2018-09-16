-- This information tells other players more about the mod
name = "Regeneration"
description = "Regenerate Sanity when healthy and Health while full."
author = "Broken Valkyrie"
version = "1.3B"
--No forum thread
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 6

-- Can specify a custom icon for this mod!
icon_atlas = "Regen.xml"
icon = "Regen.tex"

-- Compatability
dont_starve_compatible = true
reign_of_giants_compatible = true

--Do not port this to DST! Not that it would cause crash, but it won't work.
dst_compatible = false
--Only the host requires this mod
--all_clients_require_mod = false

-- ModConfiguration option
configuration_options =
{
	{
		name = "HUNGER_PERCENT_NEEDED",
		label = "Hunger needed for health regen ",
		options =	{
						{description = "None", data = 0},
						{description = "1/10 hunger", data = 0.1},
						{description = "2/10 hunger", data = 0.2},
						{description = "3/10 hunger", data = 0.3},
						{description = "4/10 hunger", data = 0.4},
						{description = "5/10 hunger", data = 0.5},
						{description = "6/10 hunger", data = 0.6},
						{description = "7/10 hunger", data = 0.7},
						{description = "8/10 hunger", data = 0.8},
						{description = "9/10 hunger", data = 0.9},
					},

		default = 0.7,
	},
	
	{
		name = "HEALTH_BASE_REGEN",
		label = "Health Regen Rate ",
		options =	{
						{description = "0", data = 0},
						{description = "0.002", data = 0.002},
						{description = "0.005", data = 0.005},
						{description = "0.01", data = 0.01},
						{description = "0.02", data = 0.02},
						{description = "0.035", data = 0.035},
						{description = "0.05", data = 0.05},
						{description = "0.10", data = 0.10},
						{description = "0.15", data = 0.15},
						{description = "0.20", data = 0.20},
						{description = "0.25", data = 0.25},
						{description = "0.30", data = 0.30},
						{description = "0.35", data = 0.35},
						{description = "0.5", data = 0.5},
						{description = "0.75", data = 0.75},
						{description = "1.0", data = 1},
						{description = "Insanely High(5)", data = 5},
						{description = "Godly(100)", data = 100},
					},

		default = 0.02,
	},
	
	{
		name = "HEALTH_MIN_REGEN_PERCENT",
		label = "Minimum Health rate",
		options = {
					{description = "0", data = 0},
					{description = "1/10", data = 0.1},
					{description = "2/10", data = 0.2},
					{description = "3/10", data = 0.3},
					{description = "4/10", data = 0.4},
					{description = "5/10", data = 0.5},
					{description = "6/10", data = 0.6},
					{description = "7/10", data = 0.7},
					{description = "8/10", data = 0.8},
					{description = "9/10", data = 0.9},
					{description = "Flat Rate", data = 1},
				  },
		default = 0.1,
	},
	
	{
		name = "HEALTH_PERCENT_NEEDED",
		label = "Sanity Regen at ",
		options =	{
						{description = "No Health Required", data = 0},
						{description = "1/10 Health", data = 0.1},
						{description = "2/10 Health", data = 0.2},
						{description = "3/10 Health", data = 0.3},
						{description = "4/10 Health", data = 0.4},
						{description = "5/10 Health", data = 0.5},
						{description = "6/10 Health", data = 0.6},
						{description = "7/10 Health", data = 0.7},
						{description = "8/10 Health", data = 0.8},
						{description = "9/10 Health", data = 0.9},
					},

		default = 0.7,
	},
	
	{
		name = "SANITY_BASE_REGEN",
		label = "Sanity Regen Rate ",
		options =	{
						{description = "0", data = 0},
						{description = "0.002", data = 0.002},
						{description = "0.005", data = 0.005},
						{description = "0.01", data = 0.01},
						{description = "0.02", data = 0.02},
						{description = "0.035", data = 0.035},
						{description = "0.05", data = 0.05},
						{description = "0.10", data = 0.10},
						{description = "0.15", data = 0.15},
						{description = "0.20", data = 0.20},
						{description = "0.25", data = 0.25},
						{description = "0.30", data = 0.30},
						{description = "0.35", data = 0.35},
						{description = "0.5", data = 0.5},
						{description = "0.75", data = 0.75},
						{description = "1.0", data = 1},
						{description = "Insanely High(5)", data = 5},
						{description = "Godly(100)", data = 100},
					},
		default = 0.01,
	},
	
	{
		name = "SANITY_MIN_REGEN_PERCENT",
		label = "Minimum Sanity rate",
		options = {
					{description = "0", data = 0},
					{description = "1/10", data = 0.1},
					{description = "2/10", data = 0.2},
					{description = "3/10", data = 0.3},
					{description = "4/10", data = 0.4},
					{description = "5/10", data = 0.5},
					{description = "6/10", data = 0.6},
					{description = "7/10", data = 0.7},
					{description = "8/10", data = 0.8},
					{description = "9/10", data = 0.9},
					{description = "Flat Rate", data = 1},
				  },
		default = 0.1,
	},
	{
		name = "AoS",
		label = "Always on Status",
		options = {
					{description = "Do nothing", data = false},
					{description = "Force Widget", data = true},
				  },
		default = false,
	},
}