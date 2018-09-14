local MakePlayerCharacter = require "prefabs/player_common"

local assets = 
{
    Asset("ANIM", "anim/wathgrithr.zip"),
	Asset("SOUND", "sound/wathgrithr.fsb"),
}

local prefabs = 
{
	"spear_wathgrithr",	
	"wathgrithrhat",
	"wathgrithr_spirit",
}

local start_inv = 
{
	"spear_wathgrithr",	
	"wathgrithrhat",
	"meat",
	"meat",
	"meat",
	"meat",
}

local smallScale = 0.5
local medScale = 0.7
local largeScale = 1.1

local function onkill(inst, data)
	if data.cause == inst.prefab 
		and not data.inst:HasTag("prey") 
		and not data.inst:HasTag("veggie") 
		and not data.inst:HasTag("structure") then
		local delta = (data.inst.components.combat.defaultdamage) * 0.25
        inst.components.health:DoDelta(delta, false, "battleborn")
        inst.components.sanity:DoDelta(delta)

        if math.random() < .1 and not data.inst.components.health.nofadeout then
        	local time = data.inst.components.health.destroytime or 2
        	inst:DoTaskInTime(time, function()
        		local s = medScale
        		if data.inst:HasTag("smallcreature") then
        			s = smallScale
    			elseif data.inst:HasTag("largecreature") then
    				s = largeScale
    			end
        		local fx = SpawnPrefab("wathgrithr_spirit")
        		fx.Transform:SetPosition(data.inst:GetPosition():Get())
        		fx.Transform:SetScale(s,s,s)
    		end)
        end

	end
end

local function custom_init(inst)
	inst.soundsname = "wathgrithr"
	inst.talker_path_override = "dontstarve_DLC001/characters/"

	inst.components.eater:SetCarnivore(true)

	inst.components.health:SetMaxHealth(TUNING.WATHGRITHR_HEALTH)
	inst.components.hunger:SetMax(TUNING.WATHGRITHR_HUNGER)
	inst.components.sanity:SetMax(TUNING.WATHGRITHR_SANITY)
	inst.components.combat.damagemultiplier = TUNING.WATHGRITHR_DAMAGE_MULT
	inst.components.health:SetAbsorptionAmount(TUNING.WATHGRITHR_ABSORPTION)

	if Profile:IsWathgrithrFontEnabled() then
		inst.components.talker.font = TALKINGFONT_WATHGRITHR
	else
		inst.components.talker.font = TALKINGFONT
	end
	inst:ListenForEvent("continuefrompause", function()
		if Profile:IsWathgrithrFontEnabled() then
			inst.components.talker.font = TALKINGFONT_WATHGRITHR
		else
			inst.components.talker.font = TALKINGFONT
		end
	end, GetWorld())

	local spear_recipe = Recipe("spear_wathgrithr", {Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("goldnugget", 2)}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil, true)
	local helm_recipe = Recipe("wathgrithrhat", {Ingredient("goldnugget", 2), Ingredient("rocks", 2)}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil, true)
	spear_recipe.sortkey = 1
	helm_recipe.sortkey = 2

    inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end, GetWorld())
	
end

return MakePlayerCharacter("wathgrithr", prefabs, assets, custom_init, start_inv) 
