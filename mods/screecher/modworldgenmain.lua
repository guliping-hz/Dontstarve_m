local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

local function landmark(opts)
	local o = opts or {}
	o.fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
	o.layout_position = GLOBAL.LAYOUT_POSITION.CENTER
	return o
end
-- Give your layout an in-code name and point it to the exported file
Layouts["ChildLayout"] = StaticLayout.Get("map/static_layouts/child")
Layouts["MainCampsiteLayout"] = StaticLayout.Get("map/static_layouts/main_campsite", landmark())
Layouts["Camp1_to_2Layout"] = StaticLayout.Get("map/static_layouts/camp1_to_2", landmark())
Layouts["Camp2_to_3Layout"] = StaticLayout.Get("map/static_layouts/camp2_to_3", landmark())
Layouts["Camp3_to_4Layout"] = StaticLayout.Get("map/static_layouts/camp3_to_4", landmark())
Layouts["Camp2Layout"] = StaticLayout.Get("map/static_layouts/camp2", landmark())
Layouts["Camp3Layout"] = StaticLayout.Get("map/static_layouts/camp3", landmark())
Layouts["Camp4Layout"] = StaticLayout.Get("map/static_layouts/camp4", landmark())
Layouts["TouristBloodLayout"] = StaticLayout.Get("map/static_layouts/tourist_blood", landmark())
Layouts["Tourist1Layout"] = StaticLayout.Get("map/static_layouts/tourist_1", landmark())
Layouts["Tourist2Layout"] = StaticLayout.Get("map/static_layouts/tourist_2", landmark())
Layouts["BigrockLayout"] = StaticLayout.Get("map/static_layouts/bigrock", landmark())
Layouts["Camp5Layout"] = StaticLayout.Get("map/static_layouts/camp5", landmark())
Layouts["Minicamp1"] = StaticLayout.Get("map/static_layouts/minicamp_1")
Layouts["Minicamp2"] = StaticLayout.Get("map/static_layouts/minicamp_2")
Layouts["Minicamp3"] = StaticLayout.Get("map/static_layouts/minicamp_3")
Layouts["Minicamp4"] = StaticLayout.Get("map/static_layouts/minicamp_4")
Layouts["Minicamp5"] = StaticLayout.Get("map/static_layouts/minicamp_5")
Layouts["Minicamp6"] = StaticLayout.Get("map/static_layouts/minicamp_6")

Layouts["RadioLayout"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"radio_stand"}}}))
--Layouts["Sign_Campsite"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"sign_campsite"}}}))
--Layouts["Sign_To_Totem"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"sign_to_totem"}}}))
--Layouts["Sign_To_Scoutcamp"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"sign_to_scoutcamp"}}}))
--Layouts["Sign_To_Bigrock"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"sign_to_bigrock"}}}))
--Layouts["Sign_To_Ritual"] = StaticLayout.Get("map/static_layouts/singular_item", landmark({defs={item={"sign_to_ritual"}}}))


GLOBAL.require("map/lockandkey") -- for LOCKS and KEYS
local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS

GLOBAL.require("constants") -- for GROUND
local GROUND = GLOBAL.GROUND

GLOBAL.require("map/level") -- for LEVELTYPE
local LEVELTYPE = GLOBAL.LEVELTYPE


-- Make sure our new doodads don't spawn on the roads
GLOBAL.require("map/terrain")
GLOBAL.terrain.filter["evergreen_border"] = {GLOBAL.GROUND.ROAD}
GLOBAL.terrain.filter["ground_grass"] = {GLOBAL.GROUND.ROAD}

-- How many loot containers in each room
local NUM_LOOT_CONTAINERS_PER_ROOM = 0--function() if math.random() > 0.75 then return 2 else return 1 end end

AddRoom("WorldBG", {
	type = "background",
	value = GROUND.CHECKER,
	contents = {
		distributepercent = 1,
		distributeprefabs = {
			evergreen_border = 1,
		},
	},
	colour = {r=0,g=0.25,b=0,a=0.25},
})

local function random_lootroom()
	return math.random() < 0.1 and 1 or 0
end

local loot_setpieces = {
	Minicamp1 = random_lootroom,
	Minicamp2 = random_lootroom,
	Minicamp3 = random_lootroom,
	Minicamp4 = random_lootroom,
	Minicamp5 = random_lootroom,
	Minicamp6 = random_lootroom,
}

AddRoom("Scary_Trees_Dense", {
	tags={"ExitPiece"},
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
			--mistarea = 1,
		},
		distributepercent = 0.5,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=4,
			--pond=0.01,
			--houndbone=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Gross_Trees_Dense", {
	tags={"ExitPiece"},
	value = GROUND.CHECKER,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
			--mistarea = 1,
		},
		distributepercent = 0.4,
		distributeprefabs = {
			--evergreen_sparse=1,
			--pond=0.01,
			--houndbone=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Meadow", {
	tags={"ExitPiece"},
	value = GROUND.GRASS,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
		},
		distributepercent = 0.2,
		distributeprefabs = {
			fireflies=0.1,
			--berrybush2=0.2,
			--sapling=0.5,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Campsite", {
	tags={"ExitPiece"},
	value = GROUND.CARPET,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			--camper = 1, -- This is the start node, don't want to pollute the initial soundscape with whimpering
			pighead  = 1,
			firepit  = 1,
		},
		distributepercent = 0.2,
		distributeprefabs = {
			--berrybush2=0.2,
			--sapling=0.5,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Trees", {
	--tags={"RoadPoison"},
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper = 0,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass = 3,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Gross_Trees", {
	--tags={"RoadPoison"},
	value = GROUND.CHECKER,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
		},
		distributepercent = 0.3,
		distributeprefabs = {
			--evergreen_sparse=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Cliffs", {
	--tags={"RoadPoison"},
	value = GROUND.CHECKER,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
		},
		distributepercent = 0.25,
		distributeprefabs = {
			rock1=0.2,
			rock2=0.5,
			--houndbone=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Badlands", {
	--tags={"RoadPoison"},
	value = GROUND.CHECKER,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
		},
		distributepercent = 0.2,
		distributeprefabs = {
			--houndbone=0.05,
			rock_flintless=0.5,
			marsh_tree=0.2,
			--marsh_bush=0.2,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Dead_Forest_Dense", {
	--tags={"RoadPoison"},
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
			--mistarea = 1,
		},
		distributepercent = 0.4,
		distributeprefabs = {
			marsh_tree=0.5,
			--marsh_bush=0.2,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Scary_Dead_Forest", {
	--tags={"RoadPoison"},
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = loot_setpieces,
		countprefabs = {
			lootcontainer = NUM_LOOT_CONTAINERS_PER_ROOM,
			camper= 0,
		},
		distributepercent = 0.3,
		distributeprefabs = {
			marsh_tree=0.5,
			--marsh_bush=0.2,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

----------------------------------------------------------------------------------------
-- BLOCKERS ----------------------------------------------------------------------------
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- LANDMARKS AND CAMPSITES -------------------------------------------------------------
----------------------------------------------------------------------------------------

AddRoom("Main_Campsite_Room", {
	value = GROUND.CARPET,
	contents = {
		countstaticlayouts = {
			MainCampsiteLayout = 1,
		},
		countprefabs = {
			lootcontainer = 0,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=1.0,g=1.0,b=0.5,a=0.25},
})


AddRoom("Camp1_to_2_Room", {
	value = GROUND.GRASS,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp1_to_2Layout = 1
		},
		countprefabs = {
			heli_sign = 1,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=1.0,g=0.5,b=1.0,a=0.25},
})
AddRoom("Camp2_Room", {
	value = GROUND.FOREST,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp2Layout = 1
		},
		countprefabs = {
			heli_sign = 1,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen_sparse=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
		},
	},
	colour = {r=0.5,g=1.0,b=0.5,a=0.25},
})

AddRoom("Camp2_to_3_Room", {
	value = GROUND.GRASS,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp2_to_3Layout = 1
		},
		countprefabs = {
			heli_sign = 1,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=1.0,b=1.0,a=0.25},
})
AddRoom("Camp3_Room", {
	value = GROUND.FOREST,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp3Layout = 1
		},
		countprefabs = {
			heli_sign = 1,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=0.5,g=0.5,b=1.0,a=0.25},
})

AddRoom("Camp3_to_4_Room", {
	value = GROUND.GRASS,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			--Camp3_to_4Layout = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=0.0,g=1.0,b=1.0,a=0.25},
})

AddRoom("Tourist1_Room", {
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = {
			["Tourist1Layout"] = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass = 3,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Tourist2_Room", {
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = {
			["Tourist2Layout"] = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass = 3,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("TouristBlood_Room", {
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = {
			["TouristBloodLayout"] = 1,
		},
		countprefabs = {
			heli_sign = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass = 3,
		},
	},
	colour = {r=0.5,g=0.5,b=0.5,a=0.25},
})

AddRoom("Camp4_Room", {
	value = GROUND.FOREST,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp4Layout = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--houndbone=0.05,
			rock_flintless=0.5,
			marsh_tree=0.2,
			--marsh_bush=0.2,
		},
	},
	colour = {r=0.0,g=1.0,b=0.0,a=0.25},
})

AddRoom("Camp4_to_5_Room", {
	value = GROUND.GRASS,
	tags={"ForceConnected"},
	contents = {
		countstaticlayouts = {
			Camp3_to_4Layout = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--evergreen=1,
			--berrybush=0.2,
			--sapling=0.2,
			--houndbone=0.01,
			--pond=0.01,
		},
	},
	colour = {r=1.0,g=0.0,b=0.0,a=0.25},
})

AddRoom("Radio_Room", {
	tags={"ForceConnected"},
	value = GROUND.FOREST,
	contents = {
		countstaticlayouts = {
			RadioLayout = 1,
		},
		countprefabs = {
			heli_sign = 1,
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			rock1=0.2,
			rocks=0.3,
		},
	},
	colour = {r=1.0,g=1.0,b=0.0,a=0.25},
})

AddRoom("Camp5_Room", {
	value = GROUND.FOREST,
	tags={"RoadPoison"},
	contents = {
		countstaticlayouts = {
			Camp5Layout = 1
		},
		distributepercent = 1.0,
		distributeprefabs = {
			ground_grass=4,
			--houndbone=0.05,
			rock_flintless=0.5,
			marsh_tree=0.2,
			--marsh_bush=0.2,
		},
	},
	colour = {r=1.0,g=1.0,b=0.0,a=0.25},
})


----------------------------------------------------------------------------------------
-- TASKS -------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

AddTask("Main_Campsite_Task", {
	locks = LOCKS.NONE,
	keys_given = {KEYS.TIER1},
	room_choices = {
		["Scary_Trees"] = 2,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.8,g=0.8,b=0.5,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp1_to_2", {
	locks = LOCKS.TIER1,
	keys_given = {KEYS.TIER2},
	entrance_room = "Camp1_to_2_Room",
	room_choices = {
		--["Camp1_to_2_Room"] = 1,
		["Scary_Trees"] = 5,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.8,g=0.5,b=0.8,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp2_Task", {
	locks = LOCKS.TIER2,
	keys_given = {KEYS.TIER3},
	entrance_room = "Camp2_Room",
	room_choices = {
		--["Camp2_Room"] = 1,
		["Scary_Trees"] = 5,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.5,g=0.8,b=0.5,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp2_to_3", {
	locks = LOCKS.TIER3,
	keys_given = {KEYS.TIER4},
	entrance_room="Camp2_to_3_Room",
	room_choices = {
		--["Camp2_to_3_Room"] = 1,
		["Scary_Trees"] = 4,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.5,g=0.8,b=0.8,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp3_Task", {
	locks = LOCKS.TIER4,
	keys_given = {KEYS.TIER5},
	entrance_room="Camp3_Room",
	room_choices = {
		--["Camp3_Room"] = 1,
		["Scary_Trees"] = 5,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.5,g=0.5,b=0.8,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp3_to_4", {
	locks = LOCKS.TIER5,
	keys_given = {KEYS.CAVE},
	entrance_room="TouristBlood_Room",
	room_choices = {
		["Tourist1_Room"] = 1,
		["Tourist2_Room"] = 1,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.0,g=0.5,b=0.5,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp4_Task", {
	locks = LOCKS.CAVE,
	keys_given = {KEYS.BEEHAT},
	room_choices = {
		["Camp4_Room"] = 1,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.0,g=0.5,b=0.0,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp4_to_5", {
	locks = LOCKS.KILLERBEES,
	keys_given = {KEYS.POOP},
	room_choices = {
		["Scary_Trees"] = 3,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.5,g=0.0,b=0.0,a=1},
	crosslink_factor = 0,
	make_loop = true,
})

AddTask("Camp5_Task", {
	locks = LOCKS.FARM,
	keys_given = {},
	entrance_room="Radio_Room",
	room_choices = {
		["Camp5_Room"] = 1,
		--["Scary_Dead_Forest_Dense"] = 2,
	},
	room_bg = GROUND.FOREST,
	background_room = "WorldBG",
	colour = {r=0.5,g=0.5,b=0.0,a=1},
})

local levels = GLOBAL.require("map/levels")
local default_idx = -1
for i,level in ipairs(levels.sandbox_levels) do
	if level.id == "SURVIVAL_DEFAULT" then
		default_idx = i
	end
end
table.remove(levels.sandbox_levels, default_idx)

AddLevel(LEVELTYPE.SURVIVAL, {
	id="SURVIVAL_DEFAULT",
	name="Scary Mod Level",
	desc="This is the island generator for the scary mod.",
	overrides={
		{"start_setpeice",   "MainCampsiteLayout"},
		{"day",              "onlynight"},
		{"world_size",       "tiny"},
		{"waves",			 "off"},
		{"start_node",       "Main_Campsite_Room"},

		-- We don't want any of the Don't Starve random setpieces appearing
		{"boons",            "never"},
		{"traps",            "never"},
		{"poi",              "never"},
		{"protected",        "never"},

		-- hub and spoke
		--{"branching",        "most"},

		-- ring
		--{"branching",        "never"},
		--{"loop",             "always"},

		-- line
		{"branching",        "never"},
		{"loop",             "never"},
	},
	tasks = {
		"Main_Campsite_Task",
		"Camp1_to_2",
		"Camp2_Task",
		"Camp2_to_3",
		"Camp3_Task",
		"Camp3_to_4",
		"Camp4_Task",
		"Camp4_to_5",
		"Camp5_Task",
	},
	nomaxwell = true,
	numoptionaltasks = 0,
	optionaltasks = {},
	set_pieces = {},
	ordered_story_setpieces = {},
	required_prefabs = {
		"flashlightloot",
		"batteries",
		"note1",
		"note3",
		"note_diary1",
		"note_diary2",
		"note_diary3",
		"camper_runner",
		"camper_fake",
		"tourist1",
		"tourist2",
		"radio_stand",
		"helipad",
		"generator",
	},
	background_node_range = {2, 2},
	blocker_blank_room_name = "WorldBG",
})

-- This makes it so that when the world loops, it is a whole loop instead of just a crescent.
AddGlobalClassPostConstruct("map/storygen", "Story", function(self, id, tasks, terrain, gen_params, level)
	function self:SeperateStoryByBlanks(startnode, endnode)
		self.rootNode:LockGraph(startnode.id..'->'..endnode.id, startnode, endnode, {type="none", keys = KEYS.NONE, node=nil})
	end
end)
