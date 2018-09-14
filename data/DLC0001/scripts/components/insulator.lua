local easing = require("easing")

local Insulator = Class(function(self, inst)
    self.inst = inst

    self.insulation = 0
    self.cooling = 0

    self.type = "WINTER"
end)

function Insulator:SetSummer()
	self.type = "SUMMER"
end

function Insulator:SetWinter()
	self.type = "WINTER"
end

function Insulator:GetType()
	return self.type
end

function Insulator:IsType(type)
	return self.type == type
end

function Insulator:SetInsulation(val)
	self.insulation = val	
end

function Insulator:GetInsulation()
	return self.insulation, self:GetType()
end

return Insulator