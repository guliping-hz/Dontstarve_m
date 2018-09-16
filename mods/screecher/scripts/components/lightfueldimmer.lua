local LightFuelDimmer = Class(function(self, inst)
    self.inst = inst

    --The list of lights to dim with this component
    self.lightlist = {}

    --Parameters for controlling how fuel consumption and effects thereof
    self.fuelburnrate = TUNING.MAX_FUEL_LEVEL
    self.fuellevel = TUNING.STARTING_FUEL_LEVEL

    --Parameters that control the burn rate
    self.modburntimeremaining = 0
    self.modburnmultiplier = 1
    self.timedmodification = false

    --Parameters that determine the colour based on fuel burn rate
    self.maxcolour = {255/255,255/255,255/255}
    self.currentcolour = {self.maxcolour[1], self.maxcolour[2], self.maxcolour[3]}
	self.intensity = 1 -- a final multiplier on the colour
    self.prevpct = TUNING.STARTING_FUEL_LEVEL / TUNING.MAX_FUEL_LEVEL

    self.ison = true

    self.inst:ListenForEvent("flashlighton", function() 
        self.ison = true
    end)

    self.inst:ListenForEvent("flashlightoff", function() 
        self.ison = false
    end)    

    self.inst:StartUpdatingComponent(self)
end)

function LightFuelDimmer:SetIntensity(intensity)
	self.intensity = intensity
	self:UpdateLights()
end


--Add a light to flicker
function LightFuelDimmer:AddLight(light)
    table.insert(self.lightlist, light)
end

--Remove a light to flicker
function LightFuelDimmer:RemoveLight(light)
    table.remove(self.lightlist, light)
end

function LightFuelDimmer:UpdateLights()
	local pct = self.ison and self.fuellevel / TUNING.MAX_FUEL_LEVEL or 0
    if pct > TUNING.MIN_REASONABLE_FUEL then
        pct = Remap(pct, TUNING.MIN_REASONABLE_FUEL, 1, TUNING.MIN_REASONABLE_BRIGHTNESS, 1)
    else
        pct = Remap(pct, 0, TUNING.MIN_REASONABLE_FUEL, 0, TUNING.MIN_REASONABLE_BRIGHTNESS)
    end
	self.currentcolour = {self.maxcolour[1] * pct * self.intensity, self.maxcolour[2] * pct * self.intensity, self.maxcolour[3] * pct * self.intensity}
	for i, l in ipairs(self.lightlist) do
		l.Light:SetColour(self.currentcolour[1], self.currentcolour[2], self.currentcolour[3])
	end
end


--Set the normal colour for the lights
function LightFuelDimmer:SetMaxColour(colour)
    if colour and #colour == 3 then
        self.maxcolour = {colour[1], colour[2], colour[3]}

		self:UpdateLights()
    end
end

--Got some fuel, need to update the colour and fuel level
function LightFuelDimmer:AddFuel(amount)
    if amount and amount >= 0 then
        if self.fuellevel <= 0 then
            self.inst:PushEvent("fuelrefilled")
        end
        self.fuellevel = self.fuellevel + amount
        if self.fuellevel > TUNING.MAX_FUEL_LEVEL then self.fuellevel = TUNING.MAX_FUEL_LEVEL end

		self:UpdateLights()

        if self.fuellevel >= TUNING.LOW_FUEL_LEVEL then
            self.inst:PushEvent("fuelnotlow")
        end
    end
end

--Remove some amount of fuel, update colour and fuel level
function LightFuelDimmer:RemoveFuel(amount)
    if amount and amount >= 0 then
        self.fuellevel = self.fuellevel - amount
        if self.fuellevel < 0 then self.fuellevel = 0 end

		self:UpdateLights()
    end
end

--Modify the fuel use rate
function LightFuelDimmer:ModifyFuelConsumptionRate(multiplier, duration)
    if multiplier and multiplier > 0 then
        self.modburnmultiplier = multiplier
        if duration and duration > 0 then
            self.modburntimeremaining = duration
            self.timedmodification = true
        else
            self.timedmodification = false
        end
    end
end

function LightFuelDimmer:OnUpdate(dt)
    if self.ison then
        if self.timedmodification then
            self.modburntimeremaining = self.modburntimeremaining - dt
            if self.modburntimeremaining <= 0 then
                self.modburnmultiplier = 1
            end
        end

        self.fuellevel = self.fuellevel - (1 * self.modburnmultiplier)

        if self.fuellevel <= TUNING.LOW_FUEL_LEVEL then 
            if self.fuellevel <= 0 then
                self.fuellevel = 0
                self.ison = false
                self.inst:PushEvent("fuelempty")
            end
            self.inst:PushEvent("fuellow")
        end

        if self.fuellevel <= 0 then
            --lose game stuff
        end
    else
        if self.timedmodification then
            self.modburntimeremaining = self.modburntimeremaining - dt
            if self.modburntimeremaining <= 0 then
                self.modburnmultiplier = 1
            end
        end
    end


	if self.currentcolour  and #self.currentcolour == 3 then
		self:UpdateLights()
	end
end

function LightFuelDimmer:GetDebugString()
	return string.format("on: %s", tostring(self.ison))
end

return LightFuelDimmer
