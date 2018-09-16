local baba = GetModConfigData("BaBa")
local baba_key = GetModConfigData("BaBa_Key")

local health = GLOBAL.require('components/health')
----------------------------------------
-- Do the stuff
----------------------------------------
-- local require = GLOBAL.require
-- local baba = true
local CallOrNocallDaddy = function()
	baba = not baba
	health.SetNoDie(baba)
end

health.SetNoDie(baba)
GLOBAL.TheInput:AddKeyUpHandler(baba_key, CallOrNocallDaddy)
