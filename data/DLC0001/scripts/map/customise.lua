local freqency_descriptions
if PLATFORM ~= "PS4" then
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
else
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" }
	}
	freqency_descriptions_ps4_exceptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
end

local speed_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local day_descriptions = {

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "longday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "longdusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "longnight" },

	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "noday" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "nodusk" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "nonight" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "onlyday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "onlydusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "onlynight" },
}

local season_length_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "noseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSHORT, data = "veryshortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHORT, data = "shortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG, data = "longseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYLONG, data = "verylongseason" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},
}

-- local season_mode_descriptions = {
-- 	{ text = STRINGS.UI.SANDBOXMENU.ALLSEASONS, data = "default" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.CLASSIC, data = "classic" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.DLC, data = "dlc" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXTREMETEMPS, data = "extreme" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.STATICTEMPS, data = "static" },	

-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "onlyautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "onlywinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "onlyspring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "onlysummer" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "noautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "nowinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "nospring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "nosummer" },	
-- }

local season_start_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DEFAULT, data = "default"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.AUTUMN, data = "autumn"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER, data = "winter"},-- 	image = "season_start_winter.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SPRING, data = "spring"},-- 	image = "season_start_spring.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SUMMER, data = "summer"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},-- 	image = "season_start_summer.tex" },
}

local size_descriptions = nil
if PLATFORM == "PS4" then
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
	}
else
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
	}
end


local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
}

local loop_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.LOOPNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPRANDOM, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPALWAYS, data = "always" },
}

local complexity_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSIMPLE, data = "verysimple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESIMPLE, data = "simple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDECOMPLEX, data = "complex" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYCOMPLEX, data = "verycomplex" },	
}

-- Read this from the levels.lua
local preset_descriptions = {
}

-- TODO: Read this from the tasks.lua
local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.YES, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.NO, data = "never" },
}

local GROUP = {
	["monsters"] = 	{	-- These guys come after you	
						order = 5,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMONSTERS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["spiders"] = {value = "default", enable = false, spinner = nil, image = "spiders.tex", order = 1}, 
							["tentacles"] = {value = "default", enable = false, spinner = nil, image = "tentacles.tex", order = 5}, 
							["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", order = 7}, 
							["walrus"] = {value = "default", enable = false, spinner = nil, image = "mactusk.tex", order = 8}, 
							["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex", order = 2}, 
							["houndmound"] = {value = "default", enable = false, spinner = nil, image = "houndmound.tex", order = 3}, 
							["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex", order = 9}, 
							["merm"] = {value = "default", enable = false, spinner = nil, image = "merms.tex", order = 4}, 
							["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", order = 11},
							["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", order = 13},
							["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", order = 12},
							["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", order = 14},
							["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", order = 15},
							["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", order = 10},
							["chess"] = {value = "default", enable = false, spinner = nil, image = "chess_monsters.tex", order = 6},
							--["mactusk"] = {value = "default", enable = false, spinner = nil, image = "mactusk.tex"}, 
						}
					},
	["animals"] =  	{	-- These guys live and let live
						order= 4,
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["pigs"] = {value = "default", enable = false, spinner = nil, image = "pigs.tex", order = 9}, 
							["tallbirds"] = {value = "default", enable = false, spinner = nil, image = "tallbirds.tex", order = 19}, 
							["rabbits"] = {value = "default", enable = false, spinner = nil, image = "rabbits.tex", order = 2}, 
							["beefalo"] = {value = "default", enable = false, spinner = nil, image = "beefalo.tex", order = 11}, 
							["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", order = 12}, 
							["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", order = 13}, 
							["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", order = 14}, 
							["bees"] = {value = "default", enable = false, spinner = nil, image = "beehive.tex", order = 17}, 
							["angrybees"] = {value = "default", enable = false, spinner = nil, image = "wasphive.tex", order = 18}, 
							["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", order = 5}, 
							["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex", order = 8}, 
							["ponds"] = {value = "default", enable = false, spinner = nil, image = "ponds.tex", order = 16}, 
							["moles"] = {value = "default", enable = false, spinner = nil, image = "mole.tex", order = 3}, 
							["lightninggoat"] = {value = "default", enable = false, spinner = nil, image = "lightning_goat.tex", order = 10}, 
							["catcoon"] = {value = "default", enable = false, spinner = nil, image = "catcoon.tex", order = 7}, 
							["buzzard"] = {value = "default", enable = false, spinner = nil, image = "buzzard.tex", order = 6}, 
							["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", order = 4}, 
							["penguins"] = {value = "default", enable = false, spinner = nil, image = "pengull.tex", order = 15}, 
							["mandrake"] = {value = "default", enable = false, spinner = nil, image = "mandrake.tex", order = 1}, 
						}
					},
	["resources"] = {
						order= 2,
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["grass"] = {value = "default", enable = false, spinner = nil, image = "grass.tex", order = 2}, 
							["rock"] = {value = "default", enable = false, spinner = nil, image = "rock.tex", order = 9}, 
							["rock_ice"] = {value = "default", enable = false, spinner = nil, image = "iceboulder.tex", order = 10}, 
							["sapling"] = {value = "default", enable = false, spinner = nil, image = "sapling.tex", order = 3}, 
							["reeds"] = {value = "default", enable = false, spinner = nil, image = "reeds.tex", order = 6}, 
							["trees"] = {value = "default", enable = false, spinner = nil, image = "trees.tex", order = 7}, 
							["tumbleweed"] = {value = "default", enable = false, spinner = nil, image = "tumbleweeds.tex", order = 5}, 
							["marshbush"] = {value = "default", enable = false, spinner = nil, image = "marsh_bush.tex", order = 4}, 
							["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", order = 1},
							["flint"] = {value = "default", enable = false, spinner = nil, image = "flint.tex", order = 8},
							-- ["rocks"] = {value = "default", enable = false, spinner = nil, image = "rocks.tex", order = 9},
						}
					},
	["unprepared"] ={
						order= 3,
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = freqency_descriptions,
						enable = true,
						items={
							["carrot"] = {value = "default", enable = true, spinner = nil, image = "carrot.tex", order = 2
--											images ={
--												"carrot_never.tex",
--												"carrot_rare.tex",
--												"carrot_default.tex",
--												"carrot_often.tex",
--												"carrot_always.tex",
--											}
										}, 
							["berrybush"] = {value = "default", enable = true, spinner = nil, image = "berrybush.tex", order = 1}, 
							["mushroom"] = {value = "default", enable = false, spinner = nil, image = "mushrooms.tex", order = 3}, 
							["cactus"] = {value = "default", enable = false, spinner = nil, image = "cactus.tex", order = 4}, 
						}
					},
	["misc"] =		{
						order= 1,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
							["day"] = {value = "default", enable = false, spinner = nil, image = "day.tex", desc = day_descriptions, order = 9}, 
							["autumn"] = {value = "default", enable = true, spinner = nil, image = "autumn.tex", desc = season_length_descriptions, order = 4},
							["winter"] = {value = "default", enable = true, spinner = nil, image = "winter.tex", desc = season_length_descriptions, order = 5},
							["spring"] = {value = "default", enable = true, spinner = nil, image = "spring.tex", desc = season_length_descriptions, order = 6},
							["summer"] = {value = "default", enable = true, spinner = nil, image = "summer.tex", desc = season_length_descriptions, order = 7},
							["season_start"] = {value = "default", enable = false, spinner = nil, image = "season_start.tex", desc = season_start_descriptions, order = 8}, 
							["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions, order = 11}, 
							["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions, order = 12}, 
							["world_size"] = {value = "default", enable = false, spinner = nil, image = "world_size.tex", desc = size_descriptions, order = 1}, 
							["branching"] = {value = "default", enable = false, spinner = nil, image = "world_branching.tex", desc = branching_descriptions, order = 2}, 
							["loop"] = {value = "default", enable = false, spinner = nil, image = "world_loop.tex", desc = loop_descriptions, order = 3}, 
--							["world_complexity"] = {value = "default", enable = false, spinner = nil, image = "world_complexity.tex", desc = complexity_descriptions}, 
							["boons"] = {value = "default", enable = false, spinner = nil, image = "skeletons.tex", desc = freqency_descriptions, order = 16}, 
							["touchstone"] = {value = "default", enable = false, spinner = nil, image = "resurrection.tex", desc = freqency_descriptions, order = 15}, 
							["cave_entrance"] = {value = "default", enable = false, spinner = nil, image = "caves.tex", desc = yesno_descriptions, order = 10},
							["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions, order = 13}, 
							["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions, order = 14}, 
						}
					},
}

-- Fixup for frequency spinners that are _actually_ frequency (not density)
if PLATFORM == "PS4" then
	-- GROUP["monsters"].items["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", desc = freqency_descriptions_ps4_exceptions, order = 7} 
	-- GROUP["monsters"].items["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex", desc = freqency_descriptions_ps4_exceptions, order = 2}
	GROUP["monsters"].items["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex", desc = freqency_descriptions_ps4_exceptions, order = 9}
	GROUP["monsters"].items["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["monsters"].items["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["monsters"].items["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["monsters"].items["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	GROUP["monsters"].items["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}
	GROUP["monsters"].items["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", desc = freqency_descriptions_ps4_exceptions, order = 10}

	-- GROUP["animals"].items["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["animals"].items["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["animals"].items["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	-- GROUP["animals"].items["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", desc = freqency_descriptions_ps4_exceptions, order = 5}
	-- GROUP["animals"].items["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex", desc = freqency_descriptions_ps4_exceptions, order = 8}
	-- GROUP["animals"].items["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 4}
	-- GROUP["animals"].items["penguins"] = {value = "default", enable = false, spinner = nil, image = "pengull.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}

	-- GROUP["resources"].items["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", desc = freqency_descriptions_ps4_exceptions, order = 1}

	GROUP["misc"].items["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["misc"].items["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["misc"].items["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 13} 
	GROUP["misc"].items["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
end

local function GetGroupForItem(target)
	for area,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == target then
				return area
			end
		end
	end
	return "misc"
end

return {GetGroupForItem=GetGroupForItem, GROUP=GROUP, preset_descriptions=preset_descriptions}
