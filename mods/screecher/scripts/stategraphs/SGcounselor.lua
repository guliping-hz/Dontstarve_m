
local trace = function() end

local function DoFoleySounds(inst)

    for k,v in pairs(inst.components.inventory.equipslots) do
        if v.components.inventoryitem and v.components.inventoryitem.foleysound then
            inst.SoundEmitter:PlaySound(v.components.inventoryitem.foleysound)
        end
    end

    if inst.prefab == "wx78" then
        inst.SoundEmitter:PlaySound("dontstarve/movement/foley/wx78")
    end

end

local actionhandlers = 
{
    ActionHandler(ACTIONS.CHOP, 
        function(inst) 
            if not inst.sg:HasStateTag("prechop") then 
                if inst.sg:HasStateTag("chopping") then
                    return "chop"
                else
                    return "chop_start"
                end
            end 
        end),
    ActionHandler(ACTIONS.MINE, 
        function(inst) 
            if not inst.sg:HasStateTag("premine") then 
                if inst.sg:HasStateTag("mining") then
                    return "mine"
                else
                    return "mine_start"
                end
            end 
        end),
    ActionHandler(ACTIONS.HAMMER, 
        function(inst) 
            if not inst.sg:HasStateTag("prehammer") then 
                if inst.sg:HasStateTag("hammering") then
                    return "hammer"
                else
                    return "hammer_start"
                end
            end 
        end),
    ActionHandler(ACTIONS.TERRAFORM,
        function(inst)
            return "terraform"
        end), 
    
    ActionHandler(ACTIONS.DIG, 
        function(inst) 
            if not inst.sg:HasStateTag("predig") then 
                if inst.sg:HasStateTag("digging") then
                    return "dig"
                else
                    return "dig_start"
                end
            end 
        end),        
    ActionHandler(ACTIONS.NET, 
        function(inst)
            if not inst.sg:HasStateTag("prenet") then 
                if inst.sg:HasStateTag("netting") then
                    return "bugnet"
                else
                    return "bugnet_start"
                end
            end
        end),        
    ActionHandler(ACTIONS.FISH, "fishing_pre"),
        
    ActionHandler(ACTIONS.FERTILIZE, "doshortaction"),
    ActionHandler(ACTIONS.TRAVEL, "doshortaction"),
    ActionHandler(ACTIONS.LIGHT, "give"),
    ActionHandler(ACTIONS.UNLOCK, "give"),
    ActionHandler(ACTIONS.TURNOFF, "give"),
    ActionHandler(ACTIONS.TURNON, "give"),
    ActionHandler(ACTIONS.ADDFUEL, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR, "dolongaction"),
    
    ActionHandler(ACTIONS.READ, "book"),

    ActionHandler(ACTIONS.MAKEBALLOON, "makeballoon"),
    ActionHandler(ACTIONS.DEPLOY, "doshortaction"),
    ActionHandler(ACTIONS.STORE, "doshortaction"),
    ActionHandler(ACTIONS.DROP, "doshortaction"),
    ActionHandler(ACTIONS.MURDER, "dolongaction"),
    ActionHandler(ACTIONS.ACTIVATE, 
        function(inst, action)
            if action.target.components.activatable then
                if action.target.components.activatable.quickaction then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end),
    ActionHandler(ACTIONS.PICK, 
        function(inst, action)
            if action.target.components.pickable then
                if action.target.components.pickable.quickpick then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end),
        
    ActionHandler(ACTIONS.SLEEPIN, 
        function(inst, action)
            if action.invobject then
                if action.invobject.onuse then
                    action.invobject.onuse()
                end
                return "bedroll"
            else
                return "doshortaction"
            end
        
        end),

    ActionHandler(ACTIONS.TAKEITEM, "dolongaction" ),
    
    ActionHandler(ACTIONS.BUILD, "dolongaction"),
    ActionHandler(ACTIONS.SHAVE, "shave"),
    ActionHandler(ACTIONS.COOK, "dolongaction"),
    ActionHandler(ACTIONS.PICKUP, "doshortaction"),
    ActionHandler(ACTIONS.CHECKTRAP, "doshortaction"),
    ActionHandler(ACTIONS.RUMMAGE, "doshortaction"),
    ActionHandler(ACTIONS.BAIT, "doshortaction"),
    ActionHandler(ACTIONS.HEAL, "dolongaction"),
    ActionHandler(ACTIONS.SEW, "dolongaction"),
    ActionHandler(ACTIONS.TEACH, "dolongaction"),
    ActionHandler(ACTIONS.RESETMINE, "dolongaction"),
    ActionHandler(ACTIONS.EAT, 
        function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return nil
            end
            local obj = action.target or action.invobject
            if not (obj and obj.components.edible) then
                return nil
            end
            
            if obj.components.edible.foodtype == "MEAT" then
                return "eat"
            else
                return "quickeat"
            end
        end),
    ActionHandler(ACTIONS.GIVE, "give"),
    ActionHandler(ACTIONS.PLANT, "doshortaction"),
    ActionHandler(ACTIONS.HARVEST, "dolongaction"),
    ActionHandler(ACTIONS.PLAY, function(inst, action)
        if action.invobject then
            if action.invobject:HasTag("flute") then
                return "play_flute"
            elseif action.invobject:HasTag("horn") then
                return "play_horn"
            end
        end
    end),
    ActionHandler(ACTIONS.JUMPIN, "jumpin"),
    ActionHandler(ACTIONS.DRY, "doshortaction"),
    ActionHandler(ACTIONS.CASTSPELL, "castspell"),
    ActionHandler(ACTIONS.BLINK, "quicktele"),
    ActionHandler(ACTIONS.COMBINESTACK, "doshortaction"),
}

   
local events=
{

    EventHandler("locomote", function(inst)
        local is_attacking = inst.sg:HasStateTag("attack")
        local is_busy = inst.sg:HasStateTag("busy")
        if is_attacking or is_busy then return end
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        
        if is_moving and not should_move then
            if is_running then
                inst.sg:GoToState("run_stop")
            else
                inst.sg:GoToState("walk_stop")
            end
        elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
            if should_run then
                inst.sg:GoToState("run_start")
            else
                inst.sg:GoToState("walk_start")
            end
        end 
    end),
    
    EventHandler("blocked", function(inst, data)
        if not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("shell") then
                inst.sg:GoToState("shell_hit")
            end
        end
    end),

    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if data.attacker and data.attacker:HasTag("insect") then
                local is_idle = inst.sg:HasStateTag("idle")
                if not is_idle then
                    -- avoid stunlock when attacked by bees/mosquitos
                    -- don't go to full hit state, just play sounds

                    inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")        
                    
                    if inst.prefab ~= "wes" then
                        local sound_name = inst.soundsname or inst.prefab
                        local sound_event = "dontstarve/characters/"..sound_name.."/hurt"
                        inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
                    end
                    return
                end
            end
            if inst.sg:HasStateTag("shell") then
                inst.sg:GoToState("shell_hit")
            else
                inst.sg:GoToState("hit")
            end
        end
    end),

    EventHandler("doattack", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if weapon and weapon:HasTag("blowdart") then
                inst.sg:GoToState("blowdart")
            elseif weapon and weapon:HasTag("thrown") then
                inst.sg:GoToState("throw")
            else
                inst.sg:GoToState("attack")
            end
        end
    end),

    --[[EventHandler("dowhiff", function(inst)
        if not inst.components.health:IsDead() then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if weapon and weapon:HasTag("blowdart") then
                inst.sg:GoToState("blowdart")
            elseif weapon and weapon:HasTag("thrown") then
                inst.sg:GoToState("throw")
            else
                inst.sg:GoToState("attack")
            end
        end
    end),
--]]

    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if data.eslot == EQUIPSLOTS.HANDS then
                inst.sg:GoToState("item_out")
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),
    
    EventHandler("unequip", function(inst, data)
        
        if inst.sg:HasStateTag("idle") then
        
            if data.eslot == EQUIPSLOTS.HANDS then
                inst.sg:GoToState("item_in")
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),
    
    EventHandler("death", function(inst)
        inst.components.playercontroller:Enable(false)
        inst.sg:GoToState("death")
        --inst.SoundEmitter:PlaySound("dontstarve/wilson/death")    
        
        -- local sound_name = inst.soundsname or inst.prefab
        -- if inst.prefab ~= "wes" then
        --     inst.SoundEmitter:PlaySound("dontstarve/characters/"..sound_name.."/death_voice")    
        -- end
        
    end),

    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if inst.prefab == "wes" then
                inst.sg:GoToState("mime")
            else
                --inst.sg:GoToState("talk", data.noanim)
            end
        end
        
    end),

       
    EventHandler("wakeup",
        function(inst)
            inst.sg:GoToState("wakeup")
        end),        
    EventHandler("powerup",
        function(inst)
            inst.sg:GoToState("powerup")
        end),        
    EventHandler("powerdown",
        function(inst)
            inst.sg:GoToState("powerdown")
        end),        
       
    EventHandler("readytocatch",
        function(inst)
            inst.sg:GoToState("catch_pre")
        end),        
        
    EventHandler("toolbroke",
        function(inst, data)
            inst.sg:GoToState("toolbroke", data.tool)
        end),        

    EventHandler("torchranout",
        function(inst, data)
            if not inst.components.inventory:IsItemEquipped(data.torch) then
                local sameTool = inst.components.inventory:FindItem(function(item)
                    return item.prefab == data.torch.prefab
                end)
                if sameTool then
                    inst.components.inventory:Equip(sameTool)
                end
            end
        end),

    EventHandler("armorbroke",
        function(inst, data)
            inst.sg:GoToState("armorbroke", data.armor)
        end),        
        
    EventHandler("fishingcancel",
        function(inst)
            if inst.sg:HasStateTag("fishing") then
                inst.sg:GoToState("fishing_pst")
            end
        end),
}



local statue_symbols = 
{
    "ww_head",
    "ww_limb",
    "ww_meathand",
    "ww_shadow",
    "ww_torso",
    "frame",
    "rope_joints",
    "swap_grown"
}


local states= 
{
    State{
        name = "wakeup",
        
        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            --inst.AnimState:PlayAnimation("wakeup")
            inst.AnimState:SetPercent("leader_search_pst", 0)
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
            inst.components.health:SetInvincible(false)
        end,

		timeline = {
			TimeEvent(0, function(inst)
				inst.AnimState:PlayAnimation("leader_search_pst")
			end)
		},
        
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("startfire") end),
        },

    },

    State{
        name = "powerup",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerup")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "powerdown",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerdown")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    
    
    

    State{
        name = "sleep",
        
        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("sleep")
        end,

    },

    State{
        name = "sleepin",
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep")
            inst.components.locomotor:Stop()
            --inst.Controller:Enable(false)
            --inst.AnimState:Hide()
            inst:PerformBufferedAction()             
        end,
        
        onexit= function(inst)
            --inst.Controller:Enable(true)
            --inst.AnimState:Show()
        end,

    },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
            
            inst.components.locomotor:Stop()

            --local equippedArmor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

			 --if equippedArmor and equippedArmor:HasTag("shell") then
				 --inst.sg:GoToState("shell_enter")
				 --return
			 --end

			 --local equippedHat = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			 --if equippedHat and equippedHat:HasTag("hide") then
				 --inst.sg:GoToState("hide")
				 --return
			 --end

            local anims = {}

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                table.insert(anims, "leader_idle")
            else
                table.insert(anims, "leader_idle_nolight")
            end

            -- if not inst.components.sanity:IsSane() then
            --     table.insert(anims, "idle_sanity_pre")
            --     table.insert(anims, "idle_sanity_loop")
            -- elseif inst.components.temperature:IsFreezing() then
            --     table.insert(anims, "idle_shiver_pre")
            --     table.insert(anims, "idle_shiver_loop")
            -- else
            --     table.insert(anims, "idle_loop")
            -- end
            
			 if pushanim then
				 for k,v in pairs (anims) do
					 inst.AnimState:PushAnimation(v, k == #anims)
				 end
			 else
				 inst.AnimState:PlayAnimation(anims[1], #anims == 1)
				 for k,v in pairs (anims) do
					 if k > 1 then
						 inst.AnimState:PushAnimation(v, k == #anims)
					 end
				 end
			 end
            
        --     inst.sg:SetTimeout(math.random()*4+2)
        end,
        
        -- ontimeout= function(inst)
        --     inst.sg:GoToState("funnyidle")
        -- end,
    },

    State{
        
        name = "funnyidle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
        
            
            if inst.components.temperature:GetCurrent() < 5 then
                inst.AnimState:PlayAnimation("idle_shiver_pre")
                inst.AnimState:PushAnimation("idle_shiver_loop")
                inst.AnimState:PushAnimation("idle_shiver_pst", false)
            elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")    
            elseif inst.components.sanity:GetPercent() < .5 then
                inst.AnimState:PlayAnimation("idle_inaction_sanity")
            else
                inst.AnimState:PlayAnimation("idle_inaction")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
        
    },
    
    
   State{
        name = "talk",
        tags = {"idle", "talking"},
        
        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            if not noanim then
                --inst.AnimState:PlayAnimation("dial_loop", true)
            end
            
            if inst.talksoundoverride then
                 inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
            else
                local sound_name = inst.soundsname or inst.prefab
                inst.SoundEmitter:PlaySound("dontstarve/characters/"..sound_name.."/talk_LP", "talk")
            end

            inst.sg:SetTimeout(1.5 + math.random()*.5)
        end,
        
        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("talk")
            inst.sg:GoToState("idle")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
        end,
        
        events=
        {
            EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
        },
    }, 
    

    State{
        name = "doshortaction",
        tags = {"doing", "busy"},

        timeline=
        {
        },
            
        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
			inst:PushEvent("searchingcontainer")

			-- Camper business is handled here..
			if inst.bufferedaction and inst.bufferedaction.target.campertype then
				local camper = inst.bufferedaction.target
				local campertype = inst.bufferedaction.target.campertype
				inst:PushEvent("removecampername", {camper = camper})

				if campertype == 1 then --First camper
					inst.sg:GoToState("inspect_camper1")

				elseif campertype == 2 then --Second camper
					inst.sg:GoToState("inspect_camper2")

				elseif campertype == 3 then --Third camper (unused)
					inst.AnimState:PlayAnimation("leader_interact")
					inst.AnimState:PushAnimation("leader_interact_pst")
					inst.AnimState:PushAnimation("leader_idle")
					inst.sg:SetTimeout(TUNING.INTERACT_THIRD_CAMPER_DURATION)
					inst.components.talker:Say("Are... are you all right?", 2.5, false)

				else --dead campers
					inst.AnimState:PlayAnimation("leader_idle")
					inst.sg:SetTimeout(TUNING.INTERACT_DEAD_CAMPER_DURATION)
					if math.random() > 0.5 then
						inst:DoTaskInTime(1, function()
							inst.components.talker:Say("Oh god.", 4, false)
						end)
					else
						inst:DoTaskInTime(1, function()
							inst.components.talker:Say("Holy hell.", 4, false)
						end)
					end
					--inst.SoundEmitter:PlaySound("scary_mod/stuff/shamble_appear")
					inst:DoTaskInTime(TUNING.INTERACT_DEAD_CAMPER_DURATION, function()
						inst:PushEvent("finishedsearchingcontainer")
					end)
				end

			else
				-- This isn't a camper, do the usual thing
				inst.AnimState:PlayAnimation("leader_idle")
				inst:PerformBufferedAction()
				inst.sg:SetTimeout(TUNING.INTERACT_DEAD_CAMPER_DURATION)
			end
        end,
        
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
			inst:PushEvent("finishedsearchingcontainer")
        end,
        
        onexit = function(inst)
            --inst:PerformBufferedAction()
        end,

    },

	State{
		name = "inspect_camper1",
        tags = {"doing", "busy"},


        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
			inst:PushEvent("searchingcontainer") -- camera down

			inst.AnimState:PlayAnimation("leader_interact")
			inst.AnimState:PushAnimation("leader_interact_pst")
			inst.AnimState:PushAnimation("leader_idle")
			--inst.sg:SetTimeout(TUNING.INTERACT_FIRST_CAMPER_DURATION)
			--inst.SoundEmitter:PlaySound("scary_mod/music/anticipate")
			inst.components.talker:Say("Uh, hello?", 2.5, false) 
		end,

        timeline=
        {
			TimeEvent(27*FRAMES, function(inst) 
                if not inst.bufferedaction then return end
				local camper = inst.bufferedaction.target
				camper:RemoveTag("tbdcamper")
				camper:AddTag("runnercamper")

				camper.Transform:SetRotation(GetPlayer().Transform:GetRotation())
				camper.Transform:SetFourFaced()
				camper.sg:GoToState("run_start")
				camper.components.locomotor:WalkInDirection(GetPlayer().Transform:GetRotation())

				--Failsafe to remove her after a few seconds
				camper:DoTaskInTime(10, function() 
					camper.components.talker:Say("", 3.0, false) 
					camper:Remove()
				end)
			end),
			TimeEvent(30*FRAMES, function(inst)
                if not inst.bufferedaction then return end
				local camper = inst.bufferedaction.target
				inst.SoundEmitter:PlaySound("scary_mod/kid/scared_female")
			end),
			TimeEvent(42*FRAMES, function(inst) 
                if not inst.bufferedaction then return end
				local camper = inst.bufferedaction.target
				camper.components.talker:Say("Get that light away from me!", 3.0, false)
			end),
			TimeEvent(44*FRAMES, function(inst) 
                if inst.bufferedaction then 
    				local camper = inst.bufferedaction.target
    				
    				-- make her backpack accessible
    				local pack = FindEntity(camper,15,function(guy) return guy.prefab == "note_diary1" end)
    				if pack then
    					pack.components.activatable.inactive = true
    					pack:AddTag("CLICK")
    				end
                end
				inst:PerformBufferedAction() -- finish off the activate event
				inst:PushEvent("finishedsearchingcontainer") -- camera up
				inst.sg:GoToState("idle")
			end),
        },
	},

	State{
		name = "inspect_camper2",
        tags = {"doing", "busy"},


        onenter = function(inst, timeout)
			inst.AnimState:PlayAnimation("leader_interact")
			inst.AnimState:PushAnimation("leader_interact_pst")
			inst.AnimState:PushAnimation("leader_idle")
			--inst.sg:SetTimeout(TUNING.INTERACT_SECOND_CAMPER_DURATION)
			inst.components.talker:Say("What's going on here?", 2.0, false)
			inst:DoTaskInTime(27*FRAMES, function(inst) inst:PushEvent("startsecondcamperreaction") end)
		end,

        timeline=
        {
			TimeEvent(27*FRAMES, function(inst) 
                if not inst.bufferedaction then return end
				local camper = inst.bufferedaction.target
				camper.SoundEmitter:KillSound("blooddrip")
				camper:RemoveTag("tbdcamper")
				camper:AddTag("fakecamper")

				camper.SoundEmitter:PlaySound("scary_mod/music/anticipate")
			end),
			TimeEvent(65*FRAMES, function(inst)
                if not inst.bufferedaction then return end
				local camper = inst.bufferedaction.target
				camper.sg:GoToState("show_noface")
				GetPlayer():PushEvent("change_breathing", {intensity=3, duration=5})
			end),
			TimeEvent(107*FRAMES, function(inst) 
				inst:PerformBufferedAction() -- finish off the activate event
				inst:PushEvent("finishedsearchingcontainer") -- camera up
				inst.sg:GoToState("idle")
			end),
        },
	},
    
    
    State{
        name = "startfire",
        tags = {"doing", "busy"},
        
        timeline=
        {
            TimeEvent(TUNING.SEARCH_CONTAINER_DURATION, function(inst) inst.sg:RemoveStateTag("busy") end),
            --TimeEvent(4*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
        },
        
        onenter = function(inst, timeout)
            
            inst.components.playercontroller:Enable(false)
            inst.sg:SetTimeout(timeout or TUNING.START_FIRE_DURATION_LONG)
            inst.components.locomotor:Stop()
            --inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            
            inst.AnimState:PlayAnimation("leader_search_pre")
            inst.AnimState:PushAnimation("leader_search_loop", true)
            inst:PushEvent("searchingcontainer")
        end,
        
        ontimeout= function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                inst.AnimState:PlayAnimation("leader_search_pst")
            else
                inst.AnimState:PlayAnimation("leader_search_pst_nolight")
            end
            inst:DoTaskInTime(16*FRAMES, function(inst) inst.sg:GoToState("idle", true) end)
            inst:PerformBufferedAction()
            inst:PushEvent("finishedsearchingcontainer")
            inst:PushEvent("initpainfx")
        end,
        
        onexit= function(inst)
            inst.components.playercontroller:Enable(true)
            --inst.SoundEmitter:KillSound("make")
        end,
        
    },

    State{
        name = "dolongaction",
        tags = {"doing", "busy", "doinglong"},
        
        timeline=
        {
            --TimeEvent(TUNING.SEARCH_CONTAINER_DURATION, function(inst) 
                --inst.sg:RemoveStateTag("busy")
                --inst.sg:RemoveStateTag("doinglong")
            --end),
            --TimeEvent(4*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
        },
        
        onenter = function(inst, timeout)
            
            if not inst.bufferedaction then 
                inst.sg:GoToState("idle")
                return
            end
            
            local lootcontainer = inst.bufferedaction.target
            inst:PushEvent("removelootname", {loot = lootcontainer})
            inst.components.locomotor:Stop()
            inst:PushEvent("searchingcontainer")

            if lootcontainer.prefab ~= "generator" then
                inst.sg:SetTimeout(timeout or TUNING.SEARCH_CONTAINER_DURATION)
                inst.SoundEmitter:PlaySound("scary_mod/stuff/do_stuff", "make")
                inst.AnimState:PlayAnimation("leader_search_pre")
                inst.AnimState:PushAnimation("leader_search_loop", true)
                if lootcontainer.prefab == "radio_stand" then
                    inst:DoTaskInTime(16*FRAMES, function()
                        inst.components.talker:Say("Maybe I can raise somebody...", 3, false)
                    end)
                end
            else
                inst.sg:SetTimeout(34*FRAMES)
                inst:DoTaskInTime(18*FRAMES, function()
                    inst:PushEvent("pullinggeneratorcord")
                end)
                inst.AnimState:PlayAnimation("leader_pull_pre")
                inst.AnimState:PushAnimation("leader_pull", true)
            end

        end,
        
        ontimeout= function(inst)
            if inst.bufferedaction and inst.bufferedaction.target.prefab == "generator" then
                inst.AnimState:PlayAnimation("leader_pull_pst")
                inst:DoTaskInTime(12*FRAMES, function(inst) inst.sg:GoToState("idle", true) end)
            else
                if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                    inst.AnimState:PlayAnimation("leader_search_pst")
                else
                    inst.AnimState:PlayAnimation("leader_search_pst_nolight")
                end
                inst.SoundEmitter:KillSound("make")
                inst:DoTaskInTime(16*FRAMES, function(inst) inst.sg:GoToState("idle", true) end)
            end

            inst:PerformBufferedAction()
            inst:PushEvent("finishedsearchingcontainer")
        end,
        
        onexit= function(inst)
        end,
        
    },

    State{
        name = "attack",
        tags = {"attack", "notalking", "abouttoattack", "busy"},
        
        onenter = function(inst)
            --print(debugstack())
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local weapon = inst.components.combat:GetWeapon()
            local otherequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if weapon then
                inst.AnimState:PlayAnimation("atk")
                if weapon:HasTag("icestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
                elseif weapon:HasTag("shadow") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
                elseif weapon:HasTag("firestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                end
            elseif otherequipped and (otherequipped:HasTag("light") or otherequipped:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            else
                inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end
            
            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
            
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) inst.sg:RemoveStateTag("abouttoattack") end),
            TimeEvent(12*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),               
            TimeEvent(13*FRAMES, function(inst)
                if not inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),
            TimeEvent(24*FRAMES, function(inst)
                if inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),
            
            
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },    
    
    
    State{
        name = "walk_start",
        tags = {"moving", "walking", "canrotate"},

        onenter = function(inst)
            inst:PushEvent("playermoving")
            inst.components.locomotor:WalkForward()
			if inst.components.locomotor.walkspeed < 0 then
				if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
					inst.AnimState:PlayAnimation("leader_walk_pre_bk_nolight")
				else
					inst.AnimState:PlayAnimation("leader_walk_pre_bk")
				end
			end
            inst.sg.mem.foosteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:WalkForward()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
	},

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
            inst:PushEvent("playermoving")
            inst.components.locomotor:RunForward()
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                inst.AnimState:PlayAnimation("leader_run_pre")
            else
                inst.AnimState:PlayAnimation("leader_run_pre_up_nolight")
            end
            inst.sg.mem.foosteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        --timeline=
        --{
        
            --TimeEvent(4*FRAMES, function(inst)
                --PlayFootstep(inst)
                --DoFoleySounds(inst)
            --end),
        --},        
        
    },

    State{
        name = "walk",
        tags = {"moving", "walking", "canrotate"},

        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
			if inst.components.locomotor.walkspeed < 0 then
				if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
					inst.AnimState:PlayAnimation("leader_walk_loop_bk")
				else
					inst.AnimState:PlayAnimation("leader_walk_loop_bk")
				end
			end

        end,

        onupdate = function(inst)
            inst.components.locomotor:WalkForward()
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                DoFoleySounds(inst)
            end),
            TimeEvent(20*FRAMES, function(inst)
                inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                DoFoleySounds(inst)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
    },

	State{
        
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("leader_run_loop")
            
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst)
                if not inst.indarkness then
                    inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                    PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(20*FRAMES, function(inst)
                inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                DoFoleySounds(inst)
            end),
        },
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        
    },
    
    State{
    
        name = "walk_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.components.locomotor:Stop()
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                inst.AnimState:PlayAnimation("leader_walk_pst_bk_nolight")
            else
                inst.AnimState:PlayAnimation("leader_walk_pst_bk")
            end
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
        
    },    

    State{
    
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.components.locomotor:Stop()
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                inst.AnimState:PlayAnimation("leader_run_pst")
            else
                inst.AnimState:PlayAnimation("leader_run_pst_up_nolight")
            end
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
        
    },    

   
    State{
        name="item_hat",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    
    State{
        name="item_in",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    
    State{
        name="item_out",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("leader_idle")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    


    State{
        name = "give",
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give") 
        end,
        
        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },        

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },   
    
    State{
        name = "bedroll",
        
        --tags = {"busy"},

        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(true)
            if GetClock():IsDay() then

                local tosay = "ANNOUNCE_NODAYSLEEP"
                if GetWorld():IsCave() then
                    tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
                end

                inst.sg:GoToState("idle")
                inst.components.talker:Say(GetString(inst.prefab, tosay))
                return
            end
        
    
            local danger = FindEntity(inst, 10, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == inst end)
            local hounded = GetWorld().components.hounded

            if hounded and (hounded.warning or hounded.timetoattack <= 0) then
                danger = true
            end
            if danger then
                inst.sg:GoToState("idle")
                inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NODANGERSLEEP"))
                return
            end

            -- you can still sleep if your hunger will bottom out, but not absolutely
            if inst.components.hunger.current < TUNING.CALORIES_MED then
                inst.sg:GoToState("idle")
                inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NOHUNGERSLEEP"))
                return
            end
            
            inst.AnimState:PlayAnimation("bedroll")
             
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.components.playercontroller:Enable(true)
            inst.AnimState:ClearOverrideSymbol("bedroll")          
        end,
        
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bedroll")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                if GetClock():IsDay() then
                    local tosay = "ANNOUNCE_NODAYSLEEP"
                    if GetWorld():IsCave() then
                        tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
                    end
                    inst.sg:GoToState("wakeup")
                    inst.components.talker:Say(GetString(inst.prefab, tosay))
                    return
                elseif inst:GetBufferedAction() then
                    inst:PerformBufferedAction() 
                else
                    inst.sg:GoToState("wakeup")
                end

                end ),
        },
    },       

    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst:InterruptBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")        
            inst.AnimState:PlayAnimation("hit")
            
            if inst.prefab ~= "wes" then
                local sound_name = inst.soundsname or inst.prefab
                local sound_event = "dontstarve/characters/"..sound_name.."/hurt"
                inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
            end
            inst.components.locomotor:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        }, 
        
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },        
               
    },
    
    State{
        name = "toolbroke",
        tags = {"busy"},
        onenter = function(inst, tool)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal") 
            local brokentool = SpawnPrefab("brokentool")
            brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition() )
            inst.sg.statemem.tool = tool
        end,
        
        onexit = function(inst)
            local sameTool = inst.components.inventory:FindItem(function(item)
                return item.prefab == inst.sg.statemem.tool.prefab
            end)
            if sameTool then
                inst.components.inventory:Equip(sameTool)
            end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end

        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },
    
    State{
        name = "armorbroke",
        tags = {"busy"},
        onenter = function(inst, armor)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")
            inst.sg.statemem.armor = armor
        end,
        
        onexit = function(inst)
            local sameArmor = inst.components.inventory:FindItem(function(item)
                return item.prefab == inst.sg.statemem.armor.prefab
            end)
            if sameArmor then
                inst.components.inventory:Equip(sameArmor)
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },
    
        

    
}

    
return StateGraph("wilson", states, events, "idle", actionhandlers)

