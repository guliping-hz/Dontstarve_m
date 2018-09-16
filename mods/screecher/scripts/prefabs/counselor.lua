local function OnSane(inst)
	print ("SANE!")
end

local function OnInsane(inst)
	inst.SoundEmitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
end

local function giveupstring(combat, target)
    local str = ""
    if target and target:HasTag("prey") then
        str = GetString(combat.inst.prefab, "COMBAT_QUIT", "prey")
    else
        str = GetString(combat.inst.prefab, "COMBAT_QUIT")
    end
    return str
end

local function MakeCounselor(name, starting_inventory)

    local font = TALKINGFONT
    local fontsize = 20
    local assets =
    {
        Asset("ANIM", "exportedanim/camp_leader_basic.zip"),
        Asset("ANIM", "exportedanim/camp_leader_build.zip"),

		Asset("ANIM", "anim/shadow_hands.zip"),

		Asset("ANIM", "anim/wilson.zip"),

        Asset("SOUND", "sound/sfx.fsb"),
        Asset("SOUND", "sound/wilson.fsb"),

        Asset("ANIM", "anim/fish01.zip"),   --These are used for the fishing animations.
        Asset("ANIM", "anim/eel01.zip"),
    }

    local prefabs =
    {
        "beardhair",
        "brokentool",
        "abigail",
        "gridplacer",
        "terrorbeak",
        "crawlinghorror",
        "creepyeyes",
        "shadowskittish",
        "shadowwatcher",
        "shadowhand",
		"frostbreath",
        "book_birds",
        "book_tentacles",
        "book_gardening",
        "book_sleep",
        "book_brimstone",
        "pine_needles"
    }

    if starting_inventory then
		for k,v in pairs(starting_inventory) do
			table.insert(prefabs, v)
		end
    end
    
    local fn = function(Sim)  

        local inst = CreateEntity()
        inst.entity:SetCanSleep(false)
        
        
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local sound = inst.entity:AddSoundEmitter()

        if not TUNING.IS_FPS then
            local shadow = inst.entity:AddDynamicShadow()
            shadow:SetSize( 1.3, .6 )
        else
            anim:SetMultColour(0,0,0,0)
        end

        local minimap = inst.entity:AddMiniMapEntity()

        --commenting this locks the char to side view... :::: use walk look up (whatever it is called--specifying that one will make it use that >> need new SG)
        inst.Transform:SetFourFaced()
        
        inst.persists = false --handled in a special way
        
        MakeCharacterPhysics(inst, 75, .5)

        
		-- This uses a custom atlas, which has been set in modmain using AddMinimapAtlas()
        minimap:SetIcon( "leader.tex" )
        minimap:SetPriority( 10 )
        
        local lightwatch = inst.entity:AddLightWatcher()
        lightwatch:SetLightThresh(.2)
        lightwatch:SetDarkThresh(.05)
		
        inst:AddTag("player")
        inst:AddTag("character")
		inst:AddTag("prey")

        anim:SetBank("Camper")
        -- anim:SetBuild(name)
        -- anim:PlayAnimation("idle")
        anim:SetBuild("camp_leader_build")
        anim:PlayAnimation("leader_run_loop_up")
        
        anim:Hide("ARM_carry")
        anim:Hide("hat")
        anim:Hide("hat_hair")
        anim:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
        anim:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
		anim:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
		
        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:SetSlowMultiplier( 0.6 )
        inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
        inst.components.locomotor.fasteronroad = true

        inst:AddComponent("inventory")
        inst.components.inventory.starting_inventory = starting_inventory
        
        inst:AddComponent("playercontroller")
        
        inst:AddComponent("health")
		inst.components.health:SetMaxHealth(TUNING.COUNSELOR_HEALTH)
        inst.components.health.nofadeout = true
        -------
        
        inst:AddComponent("sanity")
        inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
        inst.components.sanity.onSane = OnSane
        inst.components.sanity.onInsane = OnInsane
        
        -------
        
        inst:AddComponent("talker")
        inst.components.talker.colour = Vector3(0.5, 0.5, 0.5)
        inst.components.talker.font = TALKINGFONT
        inst.components.talker.fontsize = 28
        inst.components.talker.offset = Vector3(0,-520,0)

        inst.lastnothingdialog = -1
        inst.lastbatterydialog = -1
        inst.pickedline = false

        inst:AddComponent("distancetracker")
        
        inst:AddComponent("temperature")

		inst:AddComponent("scarymodmusic")

        inst:AddComponent("scarymodencountermanager")

        inst:AddComponent("characterbreathing")

        inst:AddComponent("transparentobstacles")
        
        inst:AddComponent("playeractionpicker")
        inst:AddComponent("leader")
		inst:AddComponent("frostybreather")
		inst:AddComponent("age")
		inst:AddComponent("overseer")
        inst:AddComponent("builder")

		inst:AddComponent("hunger")
		inst:DoPeriodicTask(1, function(inst)
			inst.components.hunger:SetPercent(1)
		end)

		inst:AddComponent("combat")
		inst.components.combat:SetRetargetFunction(10000, nil)
        
        inst:AddInherentAction(ACTIONS.PICK)
        inst:AddInherentAction(ACTIONS.SLEEPIN)

        inst:SetStateGraph("SGcounselor")

		-- Helper function to find the flashlight component externally
		inst.FlashlightEnt = function()
			return inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		end

        inst.homefirepit = nil

        inst.paused = false

        inst:AddComponent("area_aware")
        
        GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("colour_cubes/screecher_cc.tex"))
        --set up the UI root entity
        --HUD:SetMainCharacter(inst)
        
		-- TESTING, prevents crashes
		inst.soundsname = "wilson"

        inst:ListenForEvent( "triedtopause", function()
            if inst.components.talker.widget == nil then
                inst.components.talker:Say("I need to get out of here!", 2.5, false)
            end
            inst:PushEvent("change_breathing", {intensity = 2, duration=3})
        end)

        inst:ListenForEvent( "triedtomapindark", function()
            if inst.components.talker.widget == nil then
                inst.components.talker:Say("It's too dark!", 2.5, false)
            end
        end)

        inst:ListenForEvent( "triedtomapinstress", function()
            if inst.components.talker.widget == nil then
                inst.components.talker:Say("I can't look now!", 2.5, false)
            end
        end)

		function inst:CanExamine() return true end

        return inst
    end
    
    return Prefab( "characters/counselor", fn, assets, prefabs) 
end


return MakeCounselor("wilson", {})
