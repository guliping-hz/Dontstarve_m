local WALK_SPEED = 4
local RUN_SPEED = 7

local MOLE_PEEK_INTERVAL = 20
local MOLE_PEEK_VARIANCE = 5

require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.STEALMOLEBAIT, "steal_pre"),
    ActionHandler(ACTIONS.MAKEMOLEHILL, "make_molehill"),
    ActionHandler(ACTIONS.MOLEPEEK, "peek"),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst, data) 
        if data and data.weapon and data.weapon:HasTag("hammer") then
            inst.components.inventory:DropEverything(false, true) 
            if inst.components.health and not inst.components.health:IsDead() then
                inst.sg:GoToState("stunned", false)
            end
        elseif not inst.sg:HasStateTag("busy") and data and data.weapon then
            inst.flee = true
            inst:DoTaskInTime(math.random(3,6), function(inst) inst.flee = false end)
            if inst.components.health and not inst.components.health:IsDead() then
                inst.sg:GoToState("hit") 
            end
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("trapped", function(inst) 
        inst.flee = true
        inst:DoTaskInTime(math.random(3,6), function(inst) inst.flee = false end)
    end),
    EventHandler("locomote", 
        function(inst) 
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end
            
            if inst.components.locomotor:WantsToMoveForward() then
                if inst.State == "under" then
                    inst.sg:GoToState("walk_pre")
                else
                    inst.sg:GoToState("exit")
                end
            elseif inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("walk_pst")
            else
                inst.sg:GoToState("idle")
            end
        end),
}

function SpawnMoveFx(inst)
    SpawnPrefab("mole_move_fx").Transform:SetPosition(inst:GetPosition():Get())
end

local states=
{
 
    State{
        name = "enter",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
            inst:SetState("above")
            inst.SoundEmitter:KillSound("move")
        end,

        events =
        {
            EventHandler("animover", function(inst)          
                inst.sg:GoToState("idle") 
            end)
        }
    },

    State{
        name = "peek",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("enter")
            inst:SetState("above")

            inst.peek_interval = GetRandomWithVariance(MOLE_PEEK_INTERVAL, MOLE_PEEK_VARIANCE)
            inst.last_above_time = GetTime()
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("exit") 
            end)
        },

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge") end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice") end),
        },
    },

    State{
        name = "steal_pre",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            if inst.State == "under" then
                inst.AnimState:PlayAnimation("enter")
                inst:DoTaskInTime(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge") end)
                inst:DoTaskInTime(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice") end)
                inst:DoTaskInTime(26*FRAMES, function(inst)
                    if inst.State == "above" then
                        if not inst.SoundEmitter:PlayingSound("sniff") then
                            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                        end
                    end
                end)
                inst:DoTaskInTime(77*FRAMES, function(inst) inst.SoundEmitter:KillSound("sniff") end)
            else
                inst:DoTaskInTime(1*FRAMES, function(inst)
                    if inst.State == "above" then
                        if not inst.SoundEmitter:PlayingSound("sniff") then
                            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                        end
                    end
                end)
                inst:DoTaskInTime(52*FRAMES, function(inst) inst.SoundEmitter:KillSound("sniff") end)
            end
            inst:SetState("above")
            inst.AnimState:PushAnimation("idle", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)               
                inst.sg:GoToState("steal") 
            end)
        },
    },

    State{
        
        name = "steal",
        tags = {"busy", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action")
            inst.AnimState:PushAnimation("idle", false)
        end,

        timeline = 
        {
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/pickup") end),
            TimeEvent(12*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(27*FRAMES, function(inst)
                if inst.State == "above" then
                    if not inst.SoundEmitter:PlayingSound("sniff") then
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                    end
                end
            end),
            TimeEvent(78*FRAMES, function(inst) inst.SoundEmitter:KillSound("sniff") end),
        },

        events = 
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("steal_pst") end)
        },
    },

    State{
        
        name = "steal_pst",
        tags = {"busy"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("exit")
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst:SetState("under")
                -- if inst.components.burnable:IsBurning() then
                --     inst.components.burnable:Extinguish()
                -- end           
                inst.last_above_time = GetTime()
                inst.sg:GoToState("idle") 
            end)
        },

        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/jump") end),
            TimeEvent(24*FRAMES, function(inst) inst:SetState("exittransition") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end),
            TimeEvent(43*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end),
        },
    },



    State{
        name = "exit",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("exit")
            -- if inst.components.burnable:IsBurning() then
            --     inst.components.burnable:Extinguish()
            -- end
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst:SetState("under")

                inst.last_above_time = GetTime()
                inst.sg:GoToState("idle") 
            end)
        },

        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/jump") end),
            TimeEvent(24*FRAMES, function(inst) inst:SetState("exittransition") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end),
            TimeEvent(43*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end),
        },
    },

    State{
        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                if inst.State == "above" then
                    inst.AnimState:PushAnimation("idle", true)
                elseif inst.State == "under" then
                    inst.AnimState:PushAnimation("idle_under", true)
                end
            else
                if inst.State == "above" then
                    inst.AnimState:PlayAnimation("idle", true)
                elseif inst.State == "under" then
                    inst.AnimState:PlayAnimation("idle_under", true)
                end
            end       
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst)
                if inst.State == "above" then
                    if not inst.SoundEmitter:PlayingSound("sniff") then
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                    end
                end
            end),
            TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:KillSound("sniff") end),
        }
    },

    State {
        name = "walk_pre",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
            if not inst.SoundEmitter:PlayingSound("move") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/move", "move")
            end
            inst.components.locomotor:WalkForward()
        end,

        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        }
    },
    State {
        name = "walk",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES,  SpawnMoveFx),
            TimeEvent(5*FRAMES,  SpawnMoveFx),
            TimeEvent(10*FRAMES, SpawnMoveFx),
            TimeEvent(15*FRAMES, SpawnMoveFx),
            TimeEvent(20*FRAMES, SpawnMoveFx),
            TimeEvent(25*FRAMES, SpawnMoveFx),

        },

        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        }
    },
    State {
        name = "walk_pst",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            local should_softstop = false
            if should_softstop then
                inst.AnimState:PushAnimation("walk_pst")
            else
                inst.AnimState:PlayAnimation("walk_pst")
            end

            inst.SoundEmitter:KillSound("move")
        end,

        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        }
    },
    
    State{
        
        name = "gohome",
        tags = {"canrotate"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst, data) 
                inst.sg:GoToState("idle")
            end),
        }
    },      
 
    State{
        
        name = "make_molehill",
        tags = {"busy"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mound")
        end,
        events=
        {
            EventHandler("animover", function(inst, data) 
                inst.last_above_time = GetTime()
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
        timeline=
        {
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice") end),
        },
    },      

    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)        
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))     
            inst.components.inventory:DropEverything(false, true) 
        end,
    },  

    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0,-20+math.random()*10,0)
            inst.AnimState:PlayAnimation("stunned_loop", true)
        end,
        
        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
                inst.Physics:SetMotorVel(0,0,0)
            end
            
            if pt.y <= .1 then
                pt.y = 0

                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst:SetState("above")
                inst.sg:GoToState("stunned", true)
            end
        end,

        onexit = function(inst)
            local pt = inst:GetPosition()
            pt.y = 0
            inst.Transform:SetPosition(pt:Get())
        end,
    },      
    
    State{
        name = "stunned",
        tags = {"busy"},
        
        onenter = function(inst, skippre) 
            inst:ClearBufferedAction()
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.components.inventory:DropEverything(false, true) 
            inst.Physics:Stop()
            if skippre then
                inst.AnimState:PlayAnimation("stunned_loop", true)
                if not inst.SoundEmitter:PlayingSound("stunned") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "stunned")
                end
                inst.stunnedsleepsfxtask = inst:DoPeriodicTask(23*FRAMES, function(inst) 
                    if not inst.SoundEmitter:PlayingSound("stunned") then
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "stunned") 
                    end
                end)
                inst:DoTaskInTime(11*FRAMES, function(inst) 
                    inst.SoundEmitter:KillSound("stunned") 
                    inst.stunnedkillsleepsfxtask = inst:DoPeriodicTask(23*FRAMES, function(inst) inst.SoundEmitter:KillSound("stunned") end)
                end)
            else
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/hurt")
                inst.AnimState:PlayAnimation("stunned_pre", false)
                inst.AnimState:PushAnimation("stunned_loop", true)
                inst:DoTaskInTime(18*FRAMES, function(inst)
                    if not inst.SoundEmitter:PlayingSound("stunned") then
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "stunned")
                    end
                    inst.stunnedsleepsfxtask = inst:DoPeriodicTask(23*FRAMES, function(inst) 
                        if not inst.SoundEmitter:PlayingSound("stunned") then
                            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "stunned") 
                        end
                    end)
                    inst:DoTaskInTime(11*FRAMES, function(inst) 
                        inst.SoundEmitter:KillSound("stunned") 
                        inst.stunnedkillsleepsfxtask = inst:DoPeriodicTask(23*FRAMES, function(inst) inst.SoundEmitter:KillSound("stunned") end)
                    end)
                end)
            end
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2) )
            inst.last_above_time = GetTime()
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,
        
        ontimeout = function(inst) 
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = false
            end
            inst.AnimState:PushAnimation("stunned_pst", false)
            inst:DoTaskInTime(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end)
            inst.SoundEmitter:KillSound("stunned")
            if inst.stunnedkillsleepsfxtask then inst.stunnedkillsleepsfxtask:Cancel() inst.stunnedkillsleepsfxtask = nil end
            if inst.stunnedsleepsfxtask then inst.stunnedsleepsfxtask:Cancel() inst.stunnedsleepsfxtask = nil end
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/jump")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) 
                inst.sg:GoToState("idle") 
            end ),
        }, 
    },
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },   
    },

    State {
        name = "sleep",
        tags = {"busy", "sleeping"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            if inst.State == "under" then
                inst.AnimState:PlayAnimation("enter")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
                inst.AnimState:PushAnimation("sleep_pre", false)
            else
                inst.AnimState:PlayAnimation("sleep_pre")
            end
        end,

        events=
        {   
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("sleeping") end ),        
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },

        timeline=
        {
            TimeEvent(FRAMES, function(inst)
                inst:SetState("above")
                inst.SoundEmitter:KillSound("sniff")
                inst.SoundEmitter:KillSound("stunned")
            end)
        }
    },
        
    State{
        
        name = "sleeping",
        tags = {"busy", "sleeping"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("sleep_loop")
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),        
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },

        timeline =
        {
            TimeEvent(27*FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("sleep") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "sleep")
                end
            end),
            TimeEvent(42*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("sleep")
            end),
        },
    },        

    State{
        
        name = "wake",
        tags = {"busy", "waking"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_pst")
            if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end            
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:KillSound("sleep")
            end)
        },
    },
}
CommonStates.AddFrozenStates(states)

  
return StateGraph("mole", states, events, "idle", actionhandlers)