require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{

}

local states=
{
	State{
		name = "hide",

		tags = {"busy"},

		onenter = function(inst)
			
		end,
		
		onexit = function(inst)
			inst:Show()
		end,
	},

	State{
		name = "stomp",

		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("stomp")
		end,
		
		events =
		{
			EventHandler("playernear", function(inst) inst.sg:GoToState("stomp_pst") end),
			EventHandler("animover", function(inst) inst.sg:GoToState("stomp_pst") end)
		},

		timeline =
		{
			TimeEvent(5*FRAMES, function(inst) 
				inst:DoStep()
				inst:SpawnPrint()
			end)
		},
	},

	State{
		name = "stomp_pst",
		
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("stomp_pst")
		end,

		onexit = function(inst)

		end,

		events =
		{
			EventHandler("animover", function(inst) inst:Remove() end)
		},

		timeline =
		{

		},
	},
}
  
return StateGraph("bigfoot", states, events, "hide", actionhandlers)