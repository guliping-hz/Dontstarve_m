require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
	CommonHandlers.OnStep(),
	EventHandler("locomote", function(inst)
        local is_busy = inst.sg:HasStateTag("busy")
        if is_busy then return end
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
	CommonHandlers.OnAttacked(), -- Might want to make camper panic here. Maybe for other camper attacked?
	EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states = 
{
 
    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst)
            if inst.campertype == 1 then
                --run_pre doesn't have movement for camper 1
                inst.AnimState:PlayAnimation("camper2_run_pre", true)
            elseif inst.campertype == 2 then
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("leader_run_pre", true)
            elseif inst.campertype == 3 then
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("camper2_run_pre", true)
            end
        end,

        onupdate = function(inst)
            if inst.campertype ~= 1 then
                inst.components.locomotor:WalkForward()
            end
        end,


        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },      
    
    State{
        
        name = "walk",
        tags = {"moving", "canrotate"},
        
        onupdate = function(inst)
            inst.components.locomotor:WalkForward()
            local x, y, z = inst.Transform:GetWorldPosition()
            if inst.campertype == 1 and TheSim:GetLightAtPoint(x, y, z) < TUNING.SCARY_MOD_DARKNESS_CUTOFF - 0.05 then
                inst.components.talker:Say("", 3.0, false) 
                inst:Remove()
            end
        end,
        
        onenter = function(inst)
            if inst.campertype == 1 then
                local player = GetPlayer()
                local px, py, pz = player.Transform:GetWorldPosition()
                local playerfacing = player.Transform:GetRotation()
                local ang = 60
                local offset = FindWalkableOffset(Vector3(px, py, pz), playerfacing*DEGREES, 80, ang, true, true)
                while offset == nil do
                    ang = ang + 10
                    offset = FindWalkableOffset(Vector3(px, py, pz), playerfacing*DEGREES, 80, ang, true, true)
                end
                local dest = Point(px + offset.x, py + offset.y, pz + offset.z)
                inst.components.locomotor:GoToPoint(dest)
                inst.AnimState:PlayAnimation("camper2_run_loop", true)
            elseif inst.campertype == 2 then
                inst.AnimState:PlayAnimation("leader_run_loop", true)
            elseif inst.campertype == 3 then
                inst.AnimState:PlayAnimation("camper2_run_loop", true)
            end
            inst.components.locomotor:WalkForward()
        end,
    },
 
    State{
        
        name = "walk_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.components.locomotor:Stop()
            if inst.campertype == 1 then
                inst.AnimState:PlayAnimation("camper2_run_pst", true)
            elseif inst.campertype == 2 then
                inst.AnimState:PlayAnimation("leader_run_pst", true)
            elseif inst.campertype == 3 then
                inst.AnimState:PlayAnimation("camper2_run_pst", true)
            end
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },  

    State{
        name = "run_start",
        tags = {"moving", "canrotate", "running"},
        
        onenter = function(inst)
            if inst.campertype == 1 then
                --run_pre doesn't have movement for camper 1
                inst.AnimState:PlayAnimation("camper2_run_pre", true)
            elseif inst.campertype == 2 then
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("leader_run_pre", true)
            elseif inst.campertype == 3 then
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("camper2_run_pre", true)
            end
        end,

        onupdate = function(inst)
            if inst.campertype ~= 1 then
                inst.components.locomotor:RunForward()
            end
        end,


        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },      
    
    State{
        
        name = "run",
        tags = {"moving", "canrotate", "running"},
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
            local x, y, z = inst.Transform:GetWorldPosition()
            if inst.campertype == 1 and TheSim:GetLightAtPoint(x, y, z) < TUNING.SCARY_MOD_DARKNESS_CUTOFF - 0.05 then
                inst.components.talker:Say("", 3.0, false) 
                inst:Remove()
            end
        end,
        
        timeline = 
        {
            TimeEvent(5*FRAMES, PlayFootstep ),
            TimeEvent(15*FRAMES, PlayFootstep ),
        },

        onenter = function(inst)
            if inst.campertype == 1 then
				-- gjans: She was running sideways really often and we don't have an anim for that
				-- so for now she only runs straight away from you
				inst.Transform:SetRotation(GetPlayer().Transform:GetRotation())
				--[[
                local player = GetPlayer()
                local px, py, pz = player.Transform:GetWorldPosition()
                local playerfacing = player.Transform:GetRotation()
                local ang = 60
                local offset = FindWalkableOffset(Vector3(px, py, pz), playerfacing*DEGREES, 80, ang, true, true)
                while offset == nil do
                    ang = ang + 10
                    offset = FindWalkableOffset(Vector3(px, py, pz), playerfacing*DEGREES, 80, ang, true, true)
                end
                local dest = Point(px + offset.x, py + offset.y, pz + offset.z)
                inst.components.locomotor:GoToPoint(dest)
				]]
                inst.AnimState:PlayAnimation("camper2_run_loop", true)
            elseif inst.campertype == 2 then
                inst.AnimState:PlayAnimation("leader_run_loop", true)
            elseif inst.campertype == 3 then
                inst.AnimState:PlayAnimation("camper2_run_loop", true)
            end
            inst.components.locomotor:RunForward()
        end,
    },
 
    State{
        
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.components.locomotor:Stop()
            if inst.campertype == 1 then
                inst.AnimState:PlayAnimation("camper2_run_pst", true)
            elseif inst.campertype == 2 then
                inst.AnimState:PlayAnimation("leader_run_pst", true)
            elseif inst.campertype == 3 then
                inst.AnimState:PlayAnimation("camper2_run_pst", true)
            end
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },  
    
	State {
		name = "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst, start_anim)
			inst.components.locomotor:Stop()

			local idle_anim = nil
            if inst.campertype == 1 then
                idle_anim = "camper2_idle"
            elseif inst.campertype == 2 then
                idle_anim = "camper1_idle"
            elseif inst.campertype == 3 then
                idle_anim = "camper2_idle"
            end

			if start_anim then
				inst.AnimState:PlayAnimation(start_anim)
				inst.AnimState:PushAnimation(idle_anim, true)
			else
				inst.AnimState:PlayAnimation(idle_anim, true)
			end
		end,
	},

	State {
		name = "echolocate",
		tags = {"busy"},

		onenter = function(inst)
            if inst.campertype == 1 then
			    inst.AnimState:PlayAnimation("camper2_cower_idle", true)
            elseif inst.campertype == 2 then
                inst.AnimState:PlayAnimation("camper1_cower", true)
                inst:DoTaskInTime(38*FRAMES, function(inst) inst.idlefinished = true end)
            elseif inst.campertype == 3 then
                inst.AnimState:PlayAnimation("camper2_cower_idle", true)
            end

			if inst.components.activatable.inactive then
				inst.sg:SetTimeout(math.random(TUNING.MIN_CAMPER_ECHOLOCATION_TIME, TUNING.MAX_CAMPER_ECHOLOCATION_TIME))
			end
		end,

		ontimeout = function(inst)
			if inst.components.activatable and inst.components.activatable.inactive then
                if inst.campertype == 1 then
                    inst.SoundEmitter:PlaySound("scary_mod/kid/cower_female", "cowerfemale")
                elseif inst.campertype == 2 and not inst.reveal then 
                    inst.SoundEmitter:PlaySound("scary_mod/kid/cower", "cowermale")
                elseif inst.campertype == 3 then
                    inst.SoundEmitter:PlaySound("scary_mod/kid/cower")
                end
				inst.sg:SetTimeout(math.random(TUNING.MIN_CAMPER_ECHOLOCATION_TIME, TUNING.MAX_CAMPER_ECHOLOCATION_TIME))
			end
		end,
	},

	State { 
		name = "show_noface",

		onenter = function(inst)
            GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
			inst.AnimState:PlayAnimation("camper1_reveal2")
			GetPlayer().HUD:ShowNoFace()
			inst.SoundEmitter:PlaySound("scary_mod/kid/camper_chair_death")
		end,
	},

    State {
        name = "continuecower",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("camper2_cower_idle", true)
        end,
    },

    State {
        name = "reachedcampsite",
        tags = {"busy"},

        onenter = function(inst)
            -- Temp anim til we get the huddle by fire anim
            inst.AnimState:SetPercent("leader_search_pst", 0)
        end,
    },

	State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.components.locomotor:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },   

	State {
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
		end,
	},
}

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})

return StateGraph("camper", states, events, "idle", actionhandlers)
