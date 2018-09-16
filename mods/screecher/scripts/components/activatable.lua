local Activatable = Class(function(self, inst, activcb)
    self.inst = inst
    self.OnActivate = activcb
    self.inactive = true
    self.distance = nil
end)

function Activatable:CollectSceneActions(doer, actions)
	if self.inactive then 
		local action = ACTIONS.ACTIVATE
		action.distance = self.distance
		table.insert(actions, action)
	end
end

function Activatable:DoActivate(doer)
	if self.OnActivate ~= nil then
		self.OnActivate(self.inst, doer)
		self.inactive = false
	end
end

return Activatable