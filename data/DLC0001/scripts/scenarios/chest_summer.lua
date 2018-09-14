chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "firestaff",
        count = 1,
        chance = 0.33
    },
    {
        item = "cutgrass",
        count = 40,
        chance = 0.66
    },
    {
        item = "nitre",
        count = 40,
        chance = 0.66
    },
    {
        item = "rocks",
        count = 20,
        chance = 0.66
    },
    {
        item = "umbrella",
        count = 1,
        chance = 0.66
    },
    {
        item = "reflectivevest",
        count = 1,
        chance = 0.8
    },
    {
        item = "pickaxe",
        count = 1
    },
}

local function triggertrap(inst, scenariorunner)
    if not GetPlayer().summertrapped then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/distant")
        GetWorld().components.seasonmanager:StartSummer()
        GetWorld().components.seasonmanager:Advance()
        GetWorld().components.seasonmanager:Advance()
        GetPlayer().summertrapped = true
    else
        return true
    end
end

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end


local function OnLoad(inst, scenariorunner) 
    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end


return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}