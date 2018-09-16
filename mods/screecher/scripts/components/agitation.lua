local Agitation = Class(function(self, inst)
	self.inst = inst
	self.value = 0
	self.minvalue = 0
	self.multiplier = 1

	self.decaytime = 10

	self.threshold = 1
	self.minimum_agitation = 1

	self.decaytask = nil

	self.debug_decaytime = 0
end)

function Agitation:SetMultiplier(x)
	self.multiplier = x
end

function Agitation:SetThreshold(t)
	self.threshold = t
end

function Agitation:DoDelta(delta)
	local oldvalue = self.value
	self.value = self.value + (delta * self.multiplier)
	if self.value < self.minvalue then self.value = self.minvalue end

	if self:IsAgitated() then
		if oldvalue < self.threshold then
			self.inst:PushEvent("newlyagitated", {value=self.value})
		end
		self.inst:PushEvent("agitated", {value=self.value})
	end

	if self.decaytask then
		self.decaytask:Cancel()
	end

	self.debug_decaytime = GetTime() + self.decaytime
	self.decaytask = self.inst:DoTaskInTime(self.decaytime, function(inst)
		self:BecomeCalm()
	end)
end

function Agitation:CanDisappear()
	if self.value > self.minimum_agitation then
		return true
	end

	return false
end

function Agitation:BecomeAgitated()
	if not self:IsAgitated() then
		self:DoDelta(self.threshold - self.value)
	end
end

function Agitation:BecomeCalm()
	if self:IsAgitated() then
		self.inst:PushEvent("calm", {value=0})
	end
	self.value = 0
	if self.decaytask then
		self.decaytask:Cancel()
		self.decaytask = nil
	end
end

function Agitation:IsAgitated()
	return self.value >= self.threshold
end

function Agitation:GetDebugString()
	return string.format("value: %2.2f/%2.2f, decay: %2.2f",
		self.value,
		self.threshold,
		self.decaytask and self.debug_decaytime - GetTime() or 0
		)
end

return Agitation
