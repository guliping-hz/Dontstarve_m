local Fan = Class(function(self, inst)
	self.inst = inst

	self.canusefn = nil
	self.onusefn = nil
end)


function Fan:SetCanUseFn(fn)
	self.canusefn = fn
end

function Fan:SetOnUseFn(fn)
	self.onusefn = fn
end

function Fan:Fan(target)
	if self.onusefn and (not self.canusefn or (self.canusefn and self.canusefn(self.inst, target))) then
		self.onusefn(self.inst, target)
		return true
	end
end

function Fan:CollectInventoryActions(doer, actions)
    if doer.components.temperature then
        table.insert(actions, ACTIONS.FAN)
    end
end

function Fan:CollectUseActions(doer, target, actions)
    if target.components.temperature then
        table.insert(actions, ACTIONS.FAN)
    end
end

return Fan