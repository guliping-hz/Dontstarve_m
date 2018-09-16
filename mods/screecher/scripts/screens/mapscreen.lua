local Screen = require "widgets/screen"
local MAX_HUD_SCALE = 1.25

local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local MapControls = require "widgets/mapcontrols"

local MapScreen = Class(Screen, function(self)
	Screen._ctor(self, "HUD")

	self.minimap = self:AddChild(MapWidget(GetPlayer()))    
	
	--[[self.mapcontrols = self.bottomright_root:AddChild(MapControls())
	self.mapcontrols:SetPosition(-60,70,0)
	self.mapcontrols.pauseBtn:Hide()]]
	self.repeat_time = 0

	self.showing = false

end)

function MapScreen:OnBecomeInactive()
	MapScreen._base.OnBecomeInactive(self)

    if GetWorld().minimap.MiniMap:IsVisible() then
    	self.minimap:OnHide()
    	GetWorld().minimap.MiniMap:ToggleVisibility()
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

function MapScreen:OnBecomeActive()
	MapScreen._base.OnBecomeActive(self)

    if not GetWorld().minimap.MiniMap:IsVisible() then
    	self.minimap:OnShow()
    	GetWorld().minimap.MiniMap:ToggleVisibility()
    end
	self.minimap:UpdateTexture()
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

function MapScreen:OnUpdate(dt)

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

	--[[local s = -2.5
	
	if self.repeat_time <= 0 then
		
		if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
			self.minimap:Offset( -s, 0 )
		elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)then
			self.minimap:Offset( s, 0 )
		end
		
		if TheInput:IsControlPressed(CONTROL_MOVE_DOWN)then
			self.minimap:Offset( 0, -s )
		elseif TheInput:IsControlPressed(CONTROL_MOVE_UP)then
			self.minimap:Offset( 0, s )
		end
		
		if TheInput:IsControlPressed(CONTROL_MAP_ZOOM_IN ) then
			self.minimap:OnZoomIn()
		elseif TheInput:IsControlPressed(CONTROL_MAP_ZOOM_OUT ) then
			self.minimap:OnZoomOut()
		end
		
		self.repeat_time = .025
		
	else
		self.repeat_time = self.repeat_time - dt
	end]]
end

function MapScreen:OnControl(control, down)

	if MapScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_MAP then
		TheFrontEnd:PopScreen()
		return true
	end

	return false
	--[[

	if not down then return false end
	if not self.shown then return false end
	
	if control == CONTROL_ROTATE_LEFT then
		GetPlayer().components.playercontroller:RotLeft()
	elseif control == CONTROL_ROTATE_RIGHT then
		GetPlayer().components.playercontroller:RotRight()
	else
		return false
	end]]

end

return MapScreen
