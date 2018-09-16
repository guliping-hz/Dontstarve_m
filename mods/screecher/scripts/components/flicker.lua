local Flicker = Class(function(self, inst)
    self.inst = inst

    --The list of lights to flicker with this component
    self.lightlist = {}

    --Parameters for controlling light intensity when flickering
    self.normalintensity = 1

    --Parameters for controlling how frequently flickering occurs
    self.timetonextflicker = math.random(TUNING.MIN_TIME_BETWEEN_FLICKER, TUNING.MAX_TIME_BETWEEN_FLICKER)

    --Parameters for controlling how long an instance of flickering lasts
    self.flickerdurationleft = 0

    self.isflickering = false

	self.nextframeblack = 0

	self.islit = true
    self.ison = true

    self.cantoggle = true

    self.inst:ListenForEvent("fuelempty", function()
        self.ison = false
        self.cantoggle = false
        self.inst:PushEvent("flashlightoff")
    end)

    self.inst:ListenForEvent("fuelrefilled", function()
        self.cantoggle = true
    end)
 
    self.inst:StartUpdatingComponent(self)
end)

function Flicker:SetIntensity(intensity)
	local dimmer = self.inst.components.lightfueldimmer
	if dimmer then
		dimmer:SetIntensity(intensity)
	end
end

--Populate the equipped item action
function Flicker:CollectInventoryActions(doer, actions, right)
    if right then
        table.insert(actions, ACTIONS.TOGGLEFLASHLIGHT)
    end
end

--Populate the equipped item action
function Flicker:CollectEquippedActions(doer, target, actions, right)
    if right then
        table.insert(actions, ACTIONS.TOGGLEFLASHLIGHT)
    end
end

--Do toggle
function Flicker:ToggleFlashlight()
    if self.ison and self.cantoggle then
        self.ison = false
        self.isflickering = false
		self:SetIntensity(0)
        self.inst.SoundEmitter:PlaySound("scary_mod/stuff/flashlight_off")
        self.inst:PushEvent("flashlightoff")
    elseif not self.ison and self.cantoggle then
        self.ison = true
		self:SetIntensity(self.normalintensity)
        self.inst.SoundEmitter:PlaySound("scary_mod/stuff/flashlight_on")
        self.inst:PushEvent("flashlighton")
        self.inst:PushEvent("flashlighttoggleon")
    end
end

--Toggle func
function Flicker:SetOnToggleFlashlightFn(fn)
    self.ontoggleflashlight = fn
end

--Add a light to flicker
function Flicker:AddLight(light)
    table.insert(self.lightlist, light)
end

--Remove a light to flicker
function Flicker:RemoveLight(light)
    table.remove(self.lightlist, light)
end

--A way to make the light start flickering on command and an option to override how long it will last
function Flicker:ForceStartFlicker(percent, mindur, maxdur)
    --Don't start if we're not on or already flickering. May want to extend current flicker instead.
    if self.ison then
        --Check if we want a percentage chance to flicker
        if percent then
            if math.random() <= percent then --If so, only flicker that % of the time
                self.isflickering = true
                if mindur and maxdur then --And for specified duration, if provided
                    self.flickerdurationleft = math.random(mindur * 10, maxdur * 10) / 10
                else
                    self.flickerdurationleft = math.random(TUNING.MIN_FLICKER_DURATION * 10, TUNING.MAX_FLICKER_DURATION * 10) / 10
                end
            end
        else --If no percent was given, assume 100%
            self.isflickering = true
		end

		-- flicker for the specified duration. This will extend the current duration if
		-- already flickering
		if mindur and maxdur then --And for specified duration, if provided
			self.flickerdurationleft = math.random(mindur * 10, maxdur * 10) / 10
		else
			self.flickerdurationleft = math.random(TUNING.MIN_FLICKER_DURATION * 10, TUNING.MAX_FLICKER_DURATION * 10) / 10
		end
    end
end

function Flicker:OneBlackFrame()
	self.nextframeblack = 3
	self:SetIntensity(0)
end

function Flicker:OnUpdate(dt)
		-- The black frame supersedes all other behaviour
    local encountermgr = GetPlayer().components.scarymodencountermanager
    if encountermgr and not encountermgr.gameover then
    	if self.ison and self.nextframeblack > 0 then
    		self.nextframeblack = self.nextframeblack -1
    		self:SetIntensity(0)

    	-- Are we on and flickering?
    	elseif self.ison and self.isflickering then
            self.flickerdurationleft = self.flickerdurationleft - dt --Tick the flicker timer
            if self.flickerdurationleft > 0 then
    			--if self.subflicker_ticks <= 0 then
    			if math.random() < 0.5 then
    				if self.islit then
    					local dimintensity = self.normalintensity - TUNING.FLICKER_DIM_AMOUNT
    					if dimintensity < 0 then dimintensity = 0 end
    					self:SetIntensity(dimintensity)
    					self.islit = false
    					--self.subflicker_ticks = math.ceil(math.random()*TUNING.OFF_SUBFLICKER_TICKS)
    					self.inst:PushEvent("flicker", {lit=false})
                        --self.inst:PushEvent("flashlightoff")
                        --Turned off one of the flicker sounds to make it a little less crowded.  I think it sounds better, feel free to undo.
    					--self.inst.SoundEmitter:PlaySound("scary_mod/stuff/flickers")
    				else
    					self:SetIntensity(self.normalintensity)
    					self.islit = true
    					--self.subflicker_ticks = math.ceil(math.random()*TUNING.ON_SUBFLICKER_TICKS)
    					self.inst:PushEvent("flicker", {lit=true})
                        --self.inst:PushEvent("flashlighton")
    					self.inst.SoundEmitter:PlaySound("scary_mod/stuff/flickers")
    				end
    			else
    				--self.subflicker_ticks = self.subflicker_ticks - 1
    			end
            else
                self.isflickering = false
    			self:SetIntensity(self.normalintensity)
    			self.islit = true
    			self.inst:PushEvent("flicker", {lit=true})
                self.inst:PushEvent("flashlighton")
    			self.inst.SoundEmitter:PlaySound("scary_mod/stuff/flickers")
                self.timetonextflicker = math.random(TUNING.MIN_TIME_BETWEEN_FLICKER, TUNING.MAX_TIME_BETWEEN_FLICKER)
            end
        elseif self.ison then --Are we just on (not flickering)?
    		self:SetIntensity(self.normalintensity)
            self.timetonextflicker = self.timetonextflicker - dt --Tick the time to next flicker
            if self.timetonextflicker <= 0 then
                self.isflickering = true
                self.flickerdurationleft = math.random(TUNING.MIN_FLICKER_DURATION * 10, TUNING.MAX_FLICKER_DURATION * 10) / 10
            end
        end
    end
end

function Flicker:GetDebugString()
	return string.format("on: %s flickering: %s Next: %2.2f Duration: %2.2f", tostring(self.ison), tostring(self.isflickering), self.timetonextflicker, self.flickerdurationleft)
end

return Flicker
