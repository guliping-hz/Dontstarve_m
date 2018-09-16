local events=
{
}

local states=
{
    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
			inst.components.activatable.inactive = true
			inst.sg:SetTimeout(TUNING.FAUCET_DRIP_RATE)
        end,
		ontimeout = function(inst)
			inst.sg:GoToState("drip")
		end,

        events=
        {
            EventHandler("onactivate", function(inst) inst.sg:GoToState("on") end),
        }
    },

    State{
        name = "drip",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("drip")
        end,

		timeline = {
			TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("scary_mod/stuff/water_drip", "drip") end),
		},

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("onactivate", function(inst) inst.sg:GoToState("on") end),
        },
    },

	State{
        name = "on",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("on")
			inst.SoundEmitter:PlaySound("scary_mod/stuff/water_tap_run_LP", "faucet_run")
			inst.SoundEmitter:PlaySound("scary_mod/stuff/water_tap_on", "fauceton")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("on_loop") end),
        },
	},


	State{
        name = "on_loop",
        onenter = function(inst, target)
			inst.AnimState:PushAnimation("on_loop")
			inst.components.activatable.inactive = true
        end,

        events=
        {
            EventHandler("onactivate", function(inst) inst.sg:GoToState("off") end),
        },
    },

	State{
		name = "off",
		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("off")
			inst.SoundEmitter:KillSound("faucet_run")
			inst.SoundEmitter:PlaySound("scary_mod/stuff/water_tap_off", "faucetoff")
		end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
}


return StateGraph("waterfaucet", states, events, "idle")


