local BigFooter = Class(function(self, inst)

	self.inst = inst
	self.directions = 
	{
		90, --right to left
		-90, --left to right
		-135, --bottom left to top right
		-45 --top left to bottom right
	}
	self.footRotations =
	{
		["90"] = 90,
		["-90"] = -90,
		["-135"] = 180,
		["-45"] = 0,
	}
	self.travelDirection = 0
	self.targetPos = nil

	self.stepTimer = 0
	self.stepTime = 2
	
	self.stepNum = -4

	self.stepDistance = 25
	self.numWarnings = 3
	self.footOffset = 15 -- Foot offset must be zero @ targetPos
end)

function BigFooter:SetFootRotation(foot)
	return self.footRotations[tostring(self.travelDirection)] - self:GetCameraAngle()
end

function BigFooter:GetDebugString()
	local str = ""
	str = str..string.format("Step Num: %2.2f, Step Timer: %2.2f", self.stepNum, self.stepTimer)
	return str
end

function BigFooter:SetTravelDirection()
	self.travelDirection = self.directions[math.random(#self.directions)] 
end

function BigFooter:IsOnScreen(pos)
	local player = GetPlayer()
	return pos:Dist(player:GetPosition()) < 50
end

function BigFooter:CheckForWater(pos)
	local test = function(offset)
		local testPoint = pos + offset
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(testPoint.x, testPoint.y, testPoint.z)
		if tile == GROUND.IMPASSABLE then
			return true
		end
	end

	return FindValidPositionByFan(0, 4, 4, test)
end

function BigFooter:FindNearbyLand(pos)
	local test = function(offset)
		local testPoint = pos + offset
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(testPoint.x, testPoint.y, testPoint.z)
		if tile ~= GROUND.IMPASSABLE then
			return self:CheckForWater(testPoint) == nil
		end
	end

	return FindValidPositionByFan(0, 6, 8, test)
end

function BigFooter:FootStep(pos)
	local onScreen = self:IsOnScreen(pos)
	local inWater = self:CheckForWater(pos)

	if inWater then
		local offset = self:FindNearbyLand(pos)
		if offset then inWater = false end
		pos = pos + (offset or Vector3(0,0,0))	
	end

	local foot = SpawnPrefab("bigfoot")	
	foot.Transform:SetRotation(self:SetFootRotation())
	foot.Transform:SetPosition(pos:Get())
	if not inWater then
		if not onScreen then
			foot:SimulateStep()
		else
			foot:DoTaskInTime(10*FRAMES, function() foot:StartStep() end)
		end
	else
		foot.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/foot_water")
		foot:Remove()
	end
end

function BigFooter:GetCameraAngle()
	local roundToNearest = function(numToRound, multiple)
		local half = multiple/2
		return numToRound+half - (numToRound+half) % multiple
	end

	local cameraVec = TheCamera:GetDownVec()
	local cameraAngle =  math.atan2(cameraVec.z, cameraVec.x)
	cameraAngle = cameraAngle * (180/math.pi)
	return roundToNearest(cameraAngle, 45)
end

function BigFooter:GetFootPos()
	local angle = self.travelDirection - self:GetCameraAngle()
	angle = angle * (PI/180)

	local stepOffset = Vector3(0,0,0)
	if not IsNumberEven(self.stepNum) then --Apply step offset
		stepOffset = Vector3(self.footOffset * math.cos(angle + (PI * 0.5)), 0, -self.footOffset * math.sin(angle + (PI * 0.5)))
	end

	local dist = self.stepDistance * self.stepNum
	local travelOffset = Vector3(dist * math.cos(angle), 0, -dist * math.sin(angle)) + stepOffset
	return self.targetPos + travelOffset
end

function BigFooter:SummonFoot(pos)
	local world = GetWorld()
	if world:IsCave() then
		if world.components.quaker then
			world:DoTaskInTime(2, function(world)
				world.components.quaker:ForceQuake(5)
			end)
		end
	else
		self:SetTravelDirection()
		self.targetPos = pos
		self.stepNum = -self.numWarnings
		self.inst:StartUpdatingComponent(self)
	end
end

function BigFooter:Reset()
	self.stepNum = -self.numWarnings
	self.stepTimer = 0
	self.inst:StopUpdatingComponent(self)
end

function BigFooter:OnUpdate(dt)
	self.stepTimer = self.stepTimer - dt

	if self.stepTimer <= 0 then
		self:FootStep(self:GetFootPos())
		self.stepNum = self.stepNum + 1
		self.stepTimer = self.stepTime
	end

	if self.stepNum > self.numWarnings then
		self:Reset()
	end
end

return BigFooter