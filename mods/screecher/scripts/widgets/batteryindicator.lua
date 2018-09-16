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

local BatteryIndicator = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "BatteryIndicator")
    
    local font = UIFONT
    
    self.text = self:AddChild(Text(NUMBERFONT, 30))
    self.text:SetString("")
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetVAlign(ANCHOR_MIDDLE)
	self.text:SetRegionSize( 1500, 50 )
	self.text:SetPosition( 0, 0, 0 )

	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = -1
	self.fadeout_timeleft = -1
	self.text:SetAlpha(0)
    self:OnUpdate(0)
end)

function BatteryIndicator:FadeIn()
	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME
	self.text:SetAlpha(0)
end

function BatteryIndicator:FadeOut()
	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME
	self.text:SetAlpha(0)
end

function BatteryIndicator:OnUpdate(dt)
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

	local player = GetPlayer()
	if player then 
		local flashlight_ent = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if flashlight_ent then
			local percent = flashlight_ent.components.lightfueldimmer.fuellevel / TUNING.MAX_FUEL_LEVEL
			local str = string.format("BATTERY REMAINING: %d%%", percent*100)
			self.text:SetString( str )

			if flashlight_ent.components.lightfueldimmer.modburnmultiplier > 1 then --Accelerated fuel burn/text color
				self.text:SetColour(1, 0, 0, 1)
				self.text:SetScale(1.1)
			elseif percent <= TUNING.MIN_REASONABLE_FUEL then -- Low fuel color
				self.text:SetColour(1, 1, 0.5, 1)
				self.text:SetScale(1.05)
			elseif flashlight_ent.components.lightfueldimmer.modburnmultiplier == 1 then --Default mutliplier/text color
				self.text:SetColour(0.7, 0.7, 0.7, 1)
				self.text:SetScale(1)
			else --Multiplier is between 0 and 1 and not super low: deccelerated fuel burn/color
				self.text:SetColour(0.6, 0.6, 0.9, 1)
				self.text:SetScale(1.1)
			end
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

return BatteryIndicator