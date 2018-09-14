
local MakePlayerCharacter = require "prefabs/player_common"

local assets = 
{
    Asset("ANIM", "anim/webber.zip"),
	Asset("SOUND", "sound/webber.fsb"),
	Asset("ANIM", "anim/beard_silk.zip"),
}

local prefabs = 
{
	"silk"
}

local start_inv = 
{
	"spidereggsack",
	"monstermeat",
	"monstermeat",
}

local function custom_init(inst)
	inst.soundsname = "webber"
	inst.talker_path_override = "dontstarve_DLC001/characters/"

	inst:AddTag("spiderwhisperer")
	inst:AddTag("monster")
	inst.components.locomotor.triggerscreep = false

	inst.components.eater.monsterimmune = true

	inst.components.health:SetMaxHealth(TUNING.WEBBER_HEALTH)
	inst.components.hunger:SetMax(TUNING.WEBBER_HUNGER)
	inst.components.sanity:SetMax(TUNING.WEBBER_SANITY)

	local nest_recipe = Recipe("spidereggsack", {Ingredient("silk", 12), Ingredient("spidergland", 6), Ingredient("papyrus", 6)}, RECIPETABS.TOWN, TECH.NONE)
	nest_recipe.sortkey = 1
	STRINGS.RECIPE_DESC.SPIDEREGGSACK = "Get a little help from your friends."

    inst:AddComponent("beard")
    inst.components.beard.insulation_factor = TUNING.WEBBER_BEARD_INSULATION_FACTOR
    inst.components.beard.onreset = function()
        inst.AnimState:ClearOverrideSymbol("beard")
    end
    inst.components.beard.prize = "silk"

    
	local beard_days = {3, 6, 9}
	local beard_bits = {1, 3, 6}
    
    inst.components.beard:AddCallback(beard_days[1], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_short")
        inst.components.beard.bits = beard_bits[1]
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_medium")
        inst.components.beard.bits = beard_bits[2]
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_long")
        inst.components.beard.bits = beard_bits[3]
    end)
end

return MakePlayerCharacter("webber", prefabs, assets, custom_init, start_inv) 
