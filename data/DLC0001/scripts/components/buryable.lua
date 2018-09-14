local Buryable = Class(function(self, inst)
    
    self.inst = inst
    self.onBury = nil
    
end)

function Buryable:OnBury(hole, doer)
	if self.onBury then
		self.onBury(self.inst, hole, doer)
	end
end

function Buryable:SetOnBury(fn)
	self.onBury = fn
end

function Buryable:CollectUseActions(doer, target, actions)
    if target.components.hole and target.components.hole.canbury then
        table.insert(actions, ACTIONS.BURY)
    end
end

return Buryable