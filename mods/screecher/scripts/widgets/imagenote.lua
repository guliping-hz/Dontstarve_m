local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local easing = require("easing")

-------------------------------------------------------------------------------------------------------

local FADEDIRECTION = 
{
	FADEIN = 1,
	FADEOUT = 2,
}

local FADEOUT_TIME = 0.9
local FADEIN_TIME = 0.5
local DELAY_TIME = 0.8

local ImageNote = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "ImageNote")

	self.showing = false

	self.image = self:AddChild(Image())
	self.image:SetPosition(0,0,0)

	self.currentnote = 0
	self.isnote = nil

	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = -1
	self.fadeout_timeleft = -1
	self.delay_time = 0
    self:OnUpdate(0)

	self.old_default_focus = nil

    self.transparentoverlay = Image("images/global.xml", "square.tex")
    self.transparentoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.transparentoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.transparentoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.transparentoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.transparentoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.transparentoverlay:SetClickable(true)
	self.transparentoverlay:SetTint(0,0,0,0.01)
	self.transparentoverlay:Hide()
	self:AddChild(self.transparentoverlay)

end)

function ImageNote:DisplayImage(atlas, image, data)
	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME
	self.delay_time = DELAY_TIME

	self.image:SetTexture(atlas, image)
	if data.notenum then
		self.currentnote = data.notenum
	else
		self.currentnote = nil
	end

	self.imagetype = data.imagetype

	self:OnUpdate(0)

	self.old_default_focus = self.parent.default_focus
	self.parent.default_focus = self

	self.transparentoverlay:Show()

	if self.imagetype == "note" then
		self.owner:PushEvent("shownote", {note=self.currentnote})
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")
	elseif self.imagetype == "flashlight" then
		self.owner:PushEvent("showflashlight")
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/battery_pickup")
	elseif self.imagetype == "batteries" then
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/battery_pickup")
	elseif self.imagetype == "map" then
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")
	end

	self.owner.components.talker:Say("", 0.1, false)
	local player = GetPlayer()
	if not player.paused then
		player.paused = true
		TheSim:SetTimeScale(0)
		-- if PlayerPauseCheck then   -- probably don't need this check
  --           PlayerPauseCheck(val,reason)  -- must be done after SetTimeScale
  --       end
	end

	self.showing = true
end

function ImageNote:HideImage()
	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = FADEOUT_TIME
	self.fadeout_timeleft = FADEOUT_TIME

	self.default_focus = self.parent.old_default_focus

	self.transparentoverlay:Hide()

	if self.imagetype == "note" then
		self.owner:PushEvent("hidenote", {note=self.currentnote})
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")
	elseif self.imagetype == "flashlight" then
		--
	elseif self.imagetype == "batteries" then
		--
	elseif self.imagetype == "map" then
		self.owner:PushEvent("hidemap")
		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")
	end

	local player = GetPlayer()
    if player.paused then
		player.paused = false
		TheSim:SetTimeScale(1)
        -- if PlayerPauseCheck then   -- probably don't need this check
        --     PlayerPauseCheck(val,reason)  -- must be done after SetTimeScale
        -- end
	end

	-- prevent the camera from snapping when the map closes
	GetPlayer().components.playercontroller:CancelDeltas()
	self.showing = false
end

function ImageNote:IsShowing()
	return self.fadedirection == FADEDIRECTION.FADEIN
		or (self.fadedirection == FADEDIRECTION.FADEOUT and self.fadeout_timeleft < self.fadeout)
end


function ImageNote:OnUpdate(dt)

	-- lock the cursor to the screen
	if self.showing then
		local screenwidth, screenheight = TheSim:GetWindowSize()

		local os_x, os_y = TheInputProxy:GetOSCursorPos() 
		--print("TheInputProxy:GetOSCursorPos()", os_x, os_y)
		os_x = os_x or screenwidth/2
		os_y = os_y or screenheight/2

		local pt = Vector3(os_x, os_y, 0)

		local dx = pt.x/screenwidth
		local dy = pt.y/screenheight
		if dx < 0.2 or dx > 0.8 or dy < 0.2 or dy > 0.8 then
			TheInputProxy:SetOSCursorPos(screenwidth/2, screenheight/2)
		end
	end


	local player = GetPlayer()

	if self.fadedirection == FADEDIRECTION.FADEIN then
		self:SetFocus()
		self.delay_time = math.max(self.delay_time - dt, 0)

	end

	if self.fadeout ~= -1 then
		self.fadeout_timeleft = self.fadeout_timeleft - dt
		if self.fadeout_timeleft < 0 then
			self.fadeout = -1
			self.fadeout_timeleft = 0
		end

		local t = easing.inQuad(self.fadeout_timeleft / self.fadeout, 0, 1, 1)

		local screenwidth, screenheight = TheSim:GetWindowSize()
		local width, height = self.image:GetSize()

		if self.fadedirection == FADEDIRECTION.FADEOUT then
			t = 1-t
			self.image:SetPosition(0, t * (-screenheight-height), 0)
			self.image:SetRotation(t * 30 + 15)
		else
			self.image:SetPosition(0, t * (-screenheight-height), 0)
			self.image:SetRotation(t * 30 + 15)
		end
	end

end

function ImageNote:OnControl(control, down)
	if ImageNote._base.OnControl(self, control, down) then return true end
	if self.delay_time == 0 and self.fadeout == -1 and self.fadedirection == FADEDIRECTION.FADEIN 
		and (control == CONTROL_ACCEPT or control == CONTROL_PRIMARY or control == CONTROL_INSPECT or control == CONTROL_ACTION) then
		self:HideImage()
		return true
	end
end

return ImageNote
