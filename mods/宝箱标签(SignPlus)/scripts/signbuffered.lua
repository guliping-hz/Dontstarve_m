print ("SignPlus : BufferedAction patch")

require "bufferedaction"
--require "rincewind/craputil"

local oldGetActionString = GetActionString

STRINGS.ACTIONS.SIGNREAD = "Read"
STRINGS.ACTIONS.SIGNEDIT = "Edit"

ACTIONS.SIGNREAD = Action(2,true)
ACTIONS.SIGNREAD.str = "Read"
ACTIONS.SIGNREAD.id = "SIGNREAD"
ACTIONS.SIGNREAD.fn = function(act)
	local tar = act.target
	if tar and tar.components.signdata then
        	tar.components.signdata:OnLeftClick(tar)
        	return true
	end
end

ACTIONS.SIGNEDIT = Action(2,true,true)
ACTIONS.SIGNEDIT.str = "Edit"
ACTIONS.SIGNEDIT.id = "SIGNEDIT"
ACTIONS.SIGNEDIT.fn = function(act)
	local tar = act.target
	if tar and tar.components.signdata then
		tar.components.signdata:OnRightClick(tar)
		return true
	end
end

function GetActionString(action, modifier, target)
	local s = oldGetActionString(action,modifier)
	if target and action and (type(action)=="string") and action == "SIGNEDIT" then
		if target.components and  target.components.signdata and target.components.signdata.data and
			target.components.signdata.data.str and (type(target.components.signdata.data.str)=="string") then
			if string.len(target.components.signdata.data.str) > 0 then 
--				s = "("..string.gsub(target.components.signdata.data.str, "%s+", " ")..") " 
				s = string.gsub(target.components.signdata.data.str, "%s+", " ")
			end
		end
		
	end
	return s
end

function BufferedAction:GetActionString()
	if self.doer and self.doer.ActionStringOverride then
        	local str = self.doer.ActionStringOverride(self.doer, self)
        	if str then return str end
    	end
    	local modifier = nil
	if self.action.strfn then modifier = self.action.strfn(self) end
    	return GetActionString(self.action.id, modifier, self.target)
end

