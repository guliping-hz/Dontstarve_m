require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true,false),
}

local function SpawnHound(inst)
	local maxNum = Lerp(2, 4, GetClock():GetNumCycles()/ 100)
	maxNum = math.clamp(maxNum, 2, 4)
	local num = math.random(1,maxNum)
	if GetWorld().components.hounded then
		for i = 1, num do
			local hound =GetWorld().components.hounded:SummonHound()
			if hound then
				hound.components.follower:SetLeader(inst)
			end
		end
	end
end

local states=
{
	State
	{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_loop")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/idle")
		end,

		events = 
		{
			EventHandler("animover", function(inst) 
				inst.sg:GoToState("idle") 
			end)
		},
	},

	State
	{
		name = "howl",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("howl")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/howl")
		end,

		timeline = 
		{
			TimeEvent(10*FRAMES, SpawnHound),
		},

		events = 
		{
			EventHandler("animover", function(inst) 
				inst.sg:GoToState("idle") 
			end)
		},
	},
}

CommonStates.AddCombatStates(states,
{
	hittimeline = 
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/hit") end)
	},
	attacktimeline = 
	{
		TimeEvent(12*FRAMES, function(inst) inst.components.combat:DoAttack() end),
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/attack") end)
	},
	deathtimeline = 
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/death") end)
	},
})
CommonStates.AddRunStates(states, 
{	
	starttimeline = {},
    runtimeline = 
    { 
        TimeEvent(5*FRAMES, 
        function(inst) 
        	PlayFootstep(inst)
        	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/idle")
        end),
    },
	endtimeline = {},
})
CommonStates.AddSleepStates(states,
{
	starttimeline = {},
	sleeptimeline = 
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/sleep") end)
	},
	endtimeline = {},
})
CommonStates.AddFrozenStates(states)
  
return StateGraph("warg", states, events, "idle", actionhandlers)