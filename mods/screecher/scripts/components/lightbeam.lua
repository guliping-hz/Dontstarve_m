local LightBeam = Class(function(self, inst)
	self.inst = inst

	self.lightlist = {} -- list of lights to manage with this component
	self.lightradiuslist = {} -- list of the original radius of the various lights

	self.currentangle = 0 -- current angle beam is pointing
	self.delta = 0 -- difference between current angle and player facing
    self.margin = 0.6 -- consider current and target angle to be same at this margin
    self.frames = 4 -- number of frames to split the delta by when tweening
    self.first = true -- need to make sure values are initialized before doing math

	-- geometry of the "light detection zone" ellipse.
	self.lightlength = 12
	self.lightwidth = 8
	self.forwardoffset = 12

	self.standing = true
	self.transitioning = false
	self.timetransitioning = 0
	self.transitionduration = 0.3
	self.pitchadjustment = 0

	self.inst:ListenForEvent("searchingcontainer", function() 
		self.standing = false 
		self.transitioning = true
		self.timetransitioning = 0
	end, GetPlayer())
	self.inst:ListenForEvent("finishedsearchingcontainer", function() 
		self.standing = true
		self.transitioning = true
		self.timetransitioning = 0
		GetPlayer().components.scarymodencountermanager:SuggestShamblerLocation(GetPlayer():GetPosition(), self.forwardoffset + self.lightlength, GetPlayer().Transform:GetRotation())
	end, GetPlayer())
	self.inst:ListenForEvent("playermoving", function()
		if not self.standing then
			self.standing = true
			self.transitioning = true
			self.timetransitioning = 0
		end
	end, GetPlayer())

	self.inst:ListenForEvent("camerapitch", function(inst, data)  self.pitchadjustment = (-0.5 + data.pitch) * TUNING.PITCH_ADJUSTMENT_MULTIPLIER end, GetPlayer())

	self.inst:StartUpdatingComponent(self)

	self.debugger = self.inst.entity:AddDebugRender()
end)

--Add a light
function LightBeam:AddLight(light)
    table.insert(self.lightlist, light)
    table.insert(self.lightradiuslist, light.Light:GetRadius())
end

--Remove a light
function LightBeam:RemoveLight(light)
	local index = 1
	for i, k in self.lightlist do
		if k == light then index = i end
	end
    table.remove(self.lightlist, index)
    table.remove(self.lightradiuslist, index)
end

--Check if a point is lit up by this light beam
function LightBeam:IsPointLit(point)

	local player = GetPlayer()
	local flashlight_ent = player.FlashlightEnt()
	if flashlight_ent and flashlight_ent.components.flicker.ison then

		local playerpos = self.inst:GetPosition()

		for i, light in ipairs(self.lightlist) do
			local rad = light.Light:GetCalculatedRadius()
			local pos = Vector3(light.Transform:GetWorldPosition())
			if pos:DistSq(point) < rad*rad then
				self.debugger:Line(point.x, point.z, pos.x, pos.z, 0, 1, 0, 1)
				return true
			end
		end
		self.debugger:Line(point.x, point.z, playerpos.x, playerpos.z, 1, 0, 0, 1)
	end
	return false
end
		

--Transform managed lights to fake aiming the beam properly
function LightBeam:AimLights(x, z, dt)
	if self.transitioning then self.timetransitioning = self.timetransitioning + dt end
	local bendingdownoffset = 1.3
    local px, py, pz = GetPlayer().Transform:GetWorldPosition()
    for i, light in ipairs(self.lightlist) do

    	local d = 2.8 + i + (self.pitchadjustment * (0.5*i))
    	d = math.max(d, 2.9+(i*0.5)) --Clamp the minimum we can move the beam down
    	local dtrans = 0

    	local radius = light.Light:GetRadius() * (1 + (self.pitchadjustment/5)) --Scale the radius a bit based on pitch
    	radius = math.max(self.lightradiuslist[i]*0.75, radius)
    	radius = math.min(self.lightradiuslist[i]*1.1, radius)
    	light.Light:SetRadius(radius)

    	if self.standing and not self.transitioning then --Standing, not transitioning
    		light.Transform:SetPosition(px + (x*d), py + 0, pz + (z*d))
			self.lightextent = d
        elseif self.standing and self.transitioning then --Transitioning from bending down to standing: Lerp
        	dtrans = Lerp(d - bendingdownoffset, d, self.timetransitioning / self.transitionduration)
        	light.Transform:SetPosition(px + (x*dtrans), py + 0, pz + (z*dtrans))
			self.lightextent = dtrans
        	if i == #self.lightlist and self.timetransitioning >= self.transitionduration then --Check if the transition is over
        		self.transitioning = false
        	end
        elseif not self.standing and not self.transitioning then --Bending down, not transitioning
        	d = d - bendingdownoffset
        	light.Transform:SetPosition(px + (x*d), py + 0, pz + (z*d))
			self.lightextent = d
        elseif not self.standing and self.transitioning then --Transitioning from standing to bending down: Lerp
	       	dtrans = Lerp(d, d - bendingdownoffset, self.timetransitioning / self.transitionduration)
	        light.Transform:SetPosition(px + (x*dtrans), py + 0, pz + (z*dtrans))
			self.lightextent = dtrans
       		if i == #self.lightlist and self.timetransitioning >= self.transitionduration then --Check if the transition is over
        		self.transitioning = false
        	end
        end
    end
end

--Draw debug
function LightBeam:DrawDebug(dt, pposx, pposz, heading)
	self.debugger:Flush()
	for i, light in ipairs(self.lightlist) do
		local rad = light.Light:GetCalculatedRadius() * 0.8 -- the outer X% is too dark to see
		local lightpos = light:GetPosition()
		local lx = rad + lightpos.x
		local ly = 0 + lightpos.z
		for i=20,360,20 do
			local x = math.cos(i*DEGREES) * rad + lightpos.x
			local y = math.sin(i*DEGREES) * rad + lightpos.z
			self.debugger:Line(x,y,lx,ly, 1, 1, 0, 1)
			lx = x
			ly = y
		end
	end
end

-- Update the light to swing to player's facing, draw debug
function LightBeam:OnUpdate(dt)
	local playerpos = self.inst:GetPosition()
	local playerfacing = GetPlayer().Transform:GetRotation()

	if playerfacing then
    	if self.first then --Set current angle to an initial value
        	self.currentangle = playerfacing
        	self.first = false
    	end

    	self.delta = playerfacing - self.currentangle
    	while self.delta > 180 do self.delta = self.delta - 360 end
    	while self.delta < -180 do self.delta = self.delta + 360 end
    end

    --If delta is larger than margin, correct the current angle some
    if playerfacing and self.currentangle and self.delta and (math.abs(self.delta) > self.margin) then
    	--print("c"..self.currentangle, "t"..playerfacing.." ", "d"..self.delta)    	
    	self.currentangle = self.currentangle + (self.delta / self.frames)
    end
    self:AimLights(math.cos(self.currentangle * DEGREES), -math.sin(self.currentangle * DEGREES), dt)
	self.lightlength = self.lightextent/2 + 4.5 -- halve these because lightlength is a radius
	self.forwardoffset = self.lightlength

	self:DrawDebug(dt, playerpos.x, playerpos.z, self.currentangle)
end

return LightBeam
