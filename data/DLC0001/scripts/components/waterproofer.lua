local WaterProofer = Class(function(self, inst)
	self.inst = inst

	self.effectiveness = 1
end)

function WaterProofer:GetEffectiveness()
	return self.effectiveness
end

function WaterProofer:SetEffectiveness(val)
	self.effectiveness = val
end

return WaterProofer