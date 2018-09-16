local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"

-------------------------------------------------------------------------------------------------------

local FADEDIRECTION = 
{
	FADEIN = 1,
	FADEOUT = 2,
}

local FADEOUT_TIME = 0.5
local FADEIN_TIME = 0.5

local TutorialText = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "DemoTimer")
    
    local font = UIFONT
    
    self.text = self:AddChild(Text(NUMBERFONT, 40))
    self.text:SetString("")
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetVAlign(ANCHOR_MIDDLE)
	self.text:SetRegionSize( 1500, 100 )
	self.text:SetPosition( 0, 0, 0 )

	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = -1
	self.fadeout_timeleft = -1
    self:OnUpdate(0)
end)

function TutorialText:FadeOut()
	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = FADEOUT_TIME
	self.fadeout_timeleft = FADEOUT_TIME
	self.text:SetAlpha(1)
end

function TutorialText:FadeIn()
	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME
	self.text:SetAlpha(0)
end

function TutorialText:SetTutorialText(txt)
	self.text:SetString( txt )
end

function TutorialText:SetColour(r,g,b,a)
	self.text:SetColour(r,g,b,a)
end

function TutorialText:OnUpdate(dt)
	local player = GetPlayer()

	if self.fadeout ~= -1 then
		self.fadeout_timeleft = self.fadeout_timeleft - dt
		if self.fadeout_timeleft < 0 then
			self.fadeout_timeleft = 0
		end

		if self.fadedirection == FADEDIRECTION.FADEOUT then
			self.text:SetAlpha( self.fadeout_timeleft / self.fadeout )
		else
			self.text:SetAlpha( 1 - (self.fadeout_timeleft / self.fadeout) )
		end
	end
    --[[
    if self.owner and not IsGamePurchased() then
		local time = GetTimePlaying()
		local time_left = TUNING.DEMO_TIME - time
		
		if time_left > 0 then
			local minutes = math.floor(time_left / 60)
			local seconds = math.floor(time_left - minutes*60)
	        
			if minutes > 0 then
				self.text:SetString(string.format("Demo %d:%02d", minutes, seconds ))
			else
				self.text:SetString(string.format("Demo %02d", seconds ))
			end
		else
			self.text:SetString(string.format("Demo Over!"))
		end
    end
    --]]
end

return TutorialText