require("stategraphs/commonstates")

local actionhandlers = 
{
}


local events=
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
        local nstate = "attack"
        --if inst.sg:HasStateTag("running") and inst.components.agitation:IsAgitated() then
            --nstate = "runningattack"
        --end
        if inst.components.health and not inst.components.health:IsDead()
           and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState(nstate)
        end
    end),

    EventHandler("locomote", function(inst)
        local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("runningattack")
        local is_busy = inst.sg:HasStateTag("busy")
        local is_idling = inst.sg:HasStateTag("idle")
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("runningattack")

        if is_attacking or is_busy then return end

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        
        if is_moving and not should_move then
            inst.SoundEmitter:KillSound("charge")
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
}

local states=
{
    State{  name = "run_start",
            tags = {"moving", "running", "busy", "atk_pre", "canrotate"},
            
            onenter = function(inst)
				--inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/hurt")
				if inst.components.agitation:IsAgitated() then
					inst.AnimState:PlayAnimation("run_pre", true)
				else
					inst.AnimState:PlayAnimation("run_pre", true)
				end

            end,
            
            events=
            {   
                EventHandler("animover", function(inst)
					if inst.components.agitation:IsAgitated() then
						inst.sg:GoToState("run_charge")
					else
						inst.sg:GoToState("run")
					end
					inst:PushEvent("attackstart" )
				end ),        
            }, 

        },

    State{  name = "run",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("run_loop")
            end,
            
            timeline=
            {
				TimeEvent(0*FRAMES, PlayFootstep ),
				TimeEvent(10*FRAMES, PlayFootstep ),
            },
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
        },

    State{  name = "run_charge",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("run_loop")
            end,
            
            timeline=
            {
				TimeEvent(0*FRAMES, PlayFootstep ),
				TimeEvent(10*FRAMES, PlayFootstep ),
            },
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run_charge") end ),        
            },
        },
    
    State{  name = "run_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("charge")
                inst.components.locomotor:Stop()
				if inst.components.agitation:IsAgitated() then
					inst.AnimState:PlayAnimation("run_pst", true)
				else
					inst.AnimState:PlayAnimation("run_pst", true)
				end
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        },    

    State{
        name = "attack",
        tags = {"attack", "canrotate"},
        
        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline =
        {
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/attack") end),
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
            TimeEvent(3*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events =
        {
            EventHandler("animover", function(inst)
				if inst.justdidanattack then
					inst.components.agitation:BecomeCalm()
				else
					inst.components.combat:TryRetarget()
				end
				inst.sg:GoToState("idle")
			end),
        },
    },

	State{
		name = "transform_to_shadow",
		tags = {"busy"},

		onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("aggro_norm")
		end,

        events = {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },

	},
	State{
		name = "transform_to_meanie",
		tags = {"busy"},

		onenter = function(inst)
            inst.components.locomotor:StopMoving()
			inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/death")
            inst.AnimState:PlayAnimation("norm_aggro")
		end,

        events = {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },

	},

	State {
        name = "idle_eating",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
			print("state idle_eating")
            inst.components.locomotor:StopMoving()
			inst.AnimState:SetBuild("shambler_eat")
			inst.AnimState:PlayAnimation("shambler_eat_loop", true)
                inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_eat_LP", "shambeatloop"..tostring(inst.shambler_id))
		end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("shambeatloop"..tostring(inst.shambler_id))
        end,

        timeline = 
        {
        },
	},

	State {
        name = "idle_eating_spotted",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
			--print("state idle_eating_spotted")
            inst.components.locomotor:StopMoving()

            --camera shake
            GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)

            --play hit
            inst.SoundEmitter:PlaySound("scary_mod/music/reveal")

            --change to red
            GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("colour_cubes/screecher_cc_red_cc.tex"))

			inst.AnimState:SetBuild("shambler_eat")
			inst.AnimState:PlayAnimation("shambler_eat_observe", false)
            local flashlightent = GetPlayer().FlashlightEnt()
            if flashlightent then
                --flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER, 0.05)
                flashlightent.components.lightfueldimmer:ModifyFuelConsumptionRate(TUNING.SHAMBLER_FUEL_CONSUMPTION_MULTIPLIER)
            end
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_eat_last") end),
        },

		onexit = function(inst)
			inst.AnimState:SetBuild("shambler_build")
		end,
    },
	State {
        name = "idle_killer",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()

			inst.AnimState:PlayAnimation("shambler_idle", true)
        end,

		onexit = function(inst)
			TheCamera:SetDistance(TUNING.DEFAULT_CAM_DISTANCE)
		end,

    },

	State {
        name = "killer_taunt",
        tags = {"canrotate", "taunt"},
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()

			local anim = "shambler_taunt"
			inst.AnimState:PlayAnimation(anim, false)
        end,
		timeline = {
			TimeEvent(2*FRAMES, function(inst)
				--inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream")
                GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
                if not inst:HasTag("finale") then
                    inst.SoundEmitter:PlaySound("scary_mod/music/hit")
                end
                inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream_long_2d", "attackscreech"..tostring(inst.GUID))
                GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("colour_cubes/screecher_cc_red_cc.tex"))
			end),
            TimeEvent(TUNING.SHAMBLER_KILLER_AGGRO-4*FRAMES, function(inst)
                if not inst:HasTag("finale") then
                    GetPlayer().HUD:ShowOwlFaceShort()
                end
            end),
		},
    },

	State {
		name = "killer_approach",
		tags = {"canrotate"},
		onenter = function(inst)
			--inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream")
			inst.AnimState:PlayAnimation("shambler_approach_pre")
			inst.AnimState:PushAnimation("shambler_approach_loop", true)
		end,
		onupdate = function(inst, dt)
			local scale = 1
			local player = GetPlayer()
			if player then
				local dist = math.sqrt(inst:GetDistanceSqToInst(player))
				scale = dist > 16 and 1 or Lerp(0,1,dist/16.0)
				--if scale < 0.5 then
					--anim = "idle"
				--elseif scale < 1 then
					--anim = "idle"
				--end

				--inst.AnimState:SetPercent(anim, 1-scale)

				if scale < 1 then
					--local visualscale = Lerp(1.5, 1, scale)
					--inst.Transform:SetScale(visualscale, visualscale, visualscale)
					local camerascale = Lerp(4,15, scale)
					TheCamera:SetDistance(camerascale)
					TheCamera:Snap()
					--print(string.format("%2.4f, %2.4f, %2.4f, %2.4f", dist, scale, visualscale, camerascale))
				end
			end

		end,
	},

	State {
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
			print("SHAMBLER IS IDLE")
            inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("shambler_idle", true)
        end,
        
    },

}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
    },
}, nil,true)

return StateGraph("shambler", states, events, "idle", actionhandlers)
