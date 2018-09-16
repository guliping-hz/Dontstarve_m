local Widget = require "widgets/widget"
local Image = require "widgets/image"
local easing = require("easing")

local FADEDIRECTION = 
{
	FADEIN = 1,
	FADEOUT = 2,
}

local FADEOUT_TIME = 0.9
local FADEIN_TIME = 0.5

local MapWidget = Class(Widget, function(self)
    Widget._ctor(self, "MapWidget")
	self.owner = GetPlayer()

	self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.bg = self:AddChild(Image("images/hud/note9.xml", "note9.tex"))
    --self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg.inst.ImageWidget:SetBlendMode( BLENDMODE.Premultiplied )
    
    self.minimap = GetWorld().minimap.MiniMap
    
    self.img = self:AddChild(Image())
    self.img.inst.ImageWidget:SetBlendMode( BLENDMODE.Additive )
    
	self.lastpos = nil
	self.minimap:ResetOffset()	
	self:StartUpdating()

	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = -1
	self.fadeout_timeleft = -1
    self:OnUpdate(0)

	self.minimap:Zoom(-4)

    self.bg:SetPosition(0,0,0)
end)


function MapWidget:SetTextureHandle(handle)
	self.img.inst.ImageWidget:SetTextureHandle( handle )
end

function MapWidget:OnZoomIn(  )
	if self.shown then
		self.minimap:Zoom( -1 )
	end
end

function MapWidget:OnZoomOut( )
	if self.shown then
		self.minimap:Zoom( 1 )
	end
end

function MapWidget:UpdateTexture()
	local handle = self.minimap:GetTextureHandle()
	self:SetTextureHandle( handle )
end

function MapWidget:OnUpdate(dt)

	--if not self.shown then return end
	
	--[[
	if TheInput:IsControlPressed(CONTROL_PRIMARY) then
		local pos = TheInput:GetScreenPosition()
		if self.lastpos then
			local scale = 0.25
			local dx = scale * ( pos.x - self.lastpos.x )
			local dy = scale * ( pos.y - self.lastpos.y )
			self.minimap:Offset( dx, dy )
		end
		
		self.lastpos = pos
	else
		self.lastpos = nil
	end]]

	local player = GetPlayer()

	if self.fadedirection == FADEDIRECTION.FADEIN then
		self:SetFocus()
	end

	if self.fadeout ~= -1 then
		self.fadeout_timeleft = self.fadeout_timeleft - dt
		if self.fadeout_timeleft < 0 then
			self.fadeout = -1
			self.fadeout_timeleft = 0
		end

		local t = easing.inQuad(self.fadeout_timeleft / self.fadeout, 0, 1, 1)

		local screenwidth, screenheight = TheSim:GetWindowSize()
		local width, height = self.bg:GetSize()
		self.img:SetSize(width, height)

		if self.fadedirection == FADEDIRECTION.FADEOUT then
			t = 1-t
			self:SetPosition(0, t * (-screenheight-height), 0)
			self:SetRotation(t * 30 + 15)
		else
			self:SetPosition(0, t * (-screenheight-height), 0)
			self:SetRotation(t * 30 + 15)
		end
	end

end

function MapWidget:Offset(dx,dy)
	self.minimap:Offset(dx,dy)
end


function MapWidget:OnShow()

	print("on show")

	GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")

	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME

	self:OnUpdate(0)

	self.minimap:ResetOffset()
end

function MapWidget:OnHide()
	GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/paper_note")
	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = FADEOUT_TIME
	self.fadeout_timeleft = FADEOUT_TIME

	self.lastpos = nil
end

function MapWidget:IsShowing()
	return self.fadedirection == FADEDIRECTION.FADEIN
		or (self.fadedirection == FADEDIRECTION.FADEOUT and self.fadeout_timeleft < self.fadeout)
end

return MapWidget
