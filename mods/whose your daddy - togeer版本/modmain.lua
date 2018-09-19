local baba = GetModConfigData("BaBa")
local babaKey = GetModConfigData("BaBa_Key")
local babaDieCnt = 0

local health = GLOBAL.require('components/health')

local SayTip = function(tip)
    --提示用户当前的状态
    local status, thePlayer = GLOBAL.pcall(function() return GLOBAL.ThePlayer end)
    if not status then
        thePlayer = GLOBAL.GetPlayer()
    end

    if thePlayer then
        thePlayer.components.talker:Say(tip)
    end
end

local CallOrNocallDaddy = function()
    baba = not baba

    if baba then
        SayTip("I will no die when health = 0")
    else
        SayTip("I will die when health = 0")
    end
end

local setValOld = health.SetVal--(val, cause)
health.SetVal = function(self, val, cause)

    local old_health = self.currenthealth

    if self.inst:HasTag("player") then
        -- print("old_health=", old_health, "val=", val)
        local judge = old_health > 0 and val <= 0 and baba
        -- print("judge=", judge)
        if judge then
            if baba then
                babaDieCnt = babaDieCnt + 1
                self.currenthealth = self.maxhealth--重新赋值为满
                SayTip("dead " .. babaDieCnt .. " time(s)")
                return
            else
                --死了的话，就重新赋值为0
                babaDieCnt = 0
            end
        end
    end

    setValOld(self, val, cause)
end

GLOBAL.TheInput:AddKeyUpHandler(babaKey, CallOrNocallDaddy)