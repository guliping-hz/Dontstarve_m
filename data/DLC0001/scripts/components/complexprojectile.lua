local ComplexProjectile = Class(function(self, inst)
	self.inst = inst

	self.velocity = Vector3(0,0,0)
	self.gravity = -9.81

	self.hoizontalSpeed = 6

	self.yOffset = 3

	self.maxRange = 10

	self.onlaunchfn = nil
	self.onhitfn = nil
	self.onmissfn = nil

end)

function ComplexProjectile:GetDebugString()
	return tostring(self.velocity)
end

function ComplexProjectile:SetOnLaunch(fn)
	self.onlaunchfn = fn
end

function ComplexProjectile:SetOnHit(fn)
	self.onhitfn = fn
end

function ComplexProjectile:GetHorizontalSpeed(distance)
	return Lerp(3, 12, distance/self.maxRange)
end

function ComplexProjectile:GetVerticalVelocity(distance)
	return ((self.gravity * distance)/2)/self:GetHorizontalSpeed(distance)
end

function ComplexProjectile:Launch(targetPos)
	local pos = self.inst:GetPosition()

	pos.y = pos.y + self.yOffset

	self.inst.Transform:SetPosition(pos:Get())

	--We assume that the pos.y - targetPos.y == 0.
	pos.y = 0
	targetPos.y = 0

	local toTarget = targetPos - pos
	local dist = pos:Dist(targetPos)
	dist = math.clamp(dist, 0, self.maxRange)
	local vertVel = self:GetVerticalVelocity(dist)

	toTarget = toTarget:Normalize()
	self.velocity = toTarget * self:GetHorizontalSpeed(dist)
	self.velocity.y = -vertVel

	if self.onlaunchfn then
		self.onlaunchfn(self.inst)
	end

	self.inst:StartUpdatingComponent(self)
end

function ComplexProjectile:Hit()
	self.inst:StopUpdatingComponent(self)

	self.inst.Physics:SetMotorVel(0,0,0)
	self.inst.Physics:Stop()
	self.velocity = Vector3(0,0,0)

	if self.onhitfn then
		self.onhitfn(self.inst)
	end
end

function ComplexProjectile:OnUpdate(dt)
	self.inst.Physics:SetMotorVel(self.velocity.x, self.velocity.y, self.velocity.z)
	self.velocity.y = self.velocity.y + (self.gravity * dt)
	local pos = self.inst:GetPosition()
	if pos.y <= 0.25 and self.velocity.y < 0 then
		self:Hit()
	end
end

return ComplexProjectile