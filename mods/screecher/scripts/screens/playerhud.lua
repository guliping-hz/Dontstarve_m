local Screen = require "widgets/screen"
local ContainerWidget = require("widgets/containerwidget")
local Controls = require("widgets/controls")
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TutorialText = require "widgets/tutorialtext"
local Credits = require "widgets/credits"
local BatteryIndicator = require "widgets/batteryindicator"
local ImageNote = require "widgets/imagenote"
local IceOver = require "widgets/iceover"
local FireOver = require "widgets/fireover"
local BloodOver = require "widgets/bloodover"
local FollowText = require "widgets/followtext"
local easing = require("easing")

local ConsoleScreen = require "screens/consolescreen"
local MapScreen = require "screens/mapscreen"
local PauseScreen = require "screens/pausescreen"

local MapWidget = require("widgets/mapwidget")

local PlayerHud = Class(Screen, function(self)
	Screen._ctor(self, "HUD")
    

    self.under_root = self:AddChild(Widget("under_root"))
    self.root = self:AddChild(Widget("root"))
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetVAnchor(ANCHOR_TOP)
    self.imagenoteroot = self:AddChild(Widget("imagenoteroot"))
	self.imagenoteroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.imagenoteroot:SetHAnchor(ANCHOR_MIDDLE)
	self.imagenoteroot:SetVAnchor(ANCHOR_MIDDLE)
    self.overlayroot = self:AddChild(Widget("overlays"))

    self.flashlightoff = true
    self.fuellow = false
    self.firstfirelit = false
    self.darkblockmap = false
    self.externalblockmap = false
    
    self.controller_attached = TheInput:ControllerAttached()

	--self.minimap = self:AddChild(MapWidget(self.owner))    
	--self.minimap:Offset( -20, -20, 0 )
	
end)

function PlayerHud:CreateWidgets(owner)
	
	local hudelementscale = 0.75

	self.tutorialtext = self.root:AddChild(TutorialText(self.owner))
	self.tutorialtext:SetScale(hudelementscale, hudelementscale)
	self.tutorialtext:SetPosition(0, -230, 0)
	--self.tutorialtext:SetTutorialText("testing")

	self.notetext = self.root:AddChild(TutorialText(self.owner))
	self.notetext:SetPosition(0, -330, 0)
	self.notetext:SetColour(0.8, 0.8, 0.8, 1)
	self.notetext:SetScale(hudelementscale, hudelementscale)
	--self.notetext:SetTutorialText("NOTES FOUND: 1/10")

	self.batteryindicator = self.root:AddChild(BatteryIndicator(self.owner))
	self.batteryindicator:SetScale(hudelementscale, hudelementscale)
	self.batteryindicator:SetPosition(0, -100, 0)

    self.playeractionhint = self.root:AddChild(FollowText(UIFONT, 25))
	self.playeractionhint:SetScale(hudelementscale, hudelementscale)
	self.playeractionhint.text:SetColour(0.5, 0.5, 0.5, 1.0)
    self.playeractionhint:SetOffset(Vector3(0, -100, 0))
    self.playeractionhint:Hide()

    self.note = self.imagenoteroot:AddChild(ImageNote(self.owner))
	self.note:SetScale(hudelementscale, hudelementscale)
	self.note:SetPosition(0,0,0)

	self.overlayroot:KillAllChildren()

    self.vig = self.overlayroot:AddChild(UIAnim())
    self.vig:GetAnimState():SetBuild("vig")
    self.vig:GetAnimState():SetBank("vig")
    self.vig:GetAnimState():PlayAnimation("basic", true)

    self.vig:SetHAnchor(ANCHOR_MIDDLE)
    self.vig:SetVAnchor(ANCHOR_MIDDLE)
    self.vig:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
    self.vig:SetClickable(false)

    self.blackoverlay = Image("images/global.xml", "square.tex")
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:SetTint(0,0,0,1)
	self.blackoverlay:Hide()
	self.overlayroot:AddChild(self.blackoverlay)
	
    self.faceoverlay = Image("images/hud/owl_face_2.xml", "owl_face_2.tex")
    self.faceoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.faceoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.faceoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.faceoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.faceoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.faceoverlay:SetClickable(false)
	self.faceoverlay:SetTint(1,1,1,1)
	self.faceoverlay:Hide()
	self.overlayroot:AddChild(self.faceoverlay)
    
    self.nofaceoverlay = Image("images/hud/faceless.xml", "faceless.tex")
    self.nofaceoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.nofaceoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.nofaceoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.nofaceoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.nofaceoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.nofaceoverlay:SetClickable(false)
	self.nofaceoverlay:SetTint(1,1,1,1)
	self.nofaceoverlay:Hide()
	self.overlayroot:AddChild(self.nofaceoverlay)

    self.screetchfaceoverlay1 = Image("images/hud/owl_face_1.xml", "owl_face_1.tex")
    self.screetchfaceoverlay1:SetVRegPoint(ANCHOR_MIDDLE)
    self.screetchfaceoverlay1:SetHRegPoint(ANCHOR_MIDDLE)
    self.screetchfaceoverlay1:SetVAnchor(ANCHOR_MIDDLE)
    self.screetchfaceoverlay1:SetHAnchor(ANCHOR_MIDDLE)
    self.screetchfaceoverlay1:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.screetchfaceoverlay1:SetClickable(false)
	self.screetchfaceoverlay1:SetTint(1,1,1,1)
	self.screetchfaceoverlay1:Hide()
	self.overlayroot:AddChild(self.screetchfaceoverlay1)

    self.screetchfaceoverlay2 = Image("images/hud/owl_face_2.xml", "owl_face_2.tex")
    self.screetchfaceoverlay2:SetVRegPoint(ANCHOR_MIDDLE)
    self.screetchfaceoverlay2:SetHRegPoint(ANCHOR_MIDDLE)
    self.screetchfaceoverlay2:SetVAnchor(ANCHOR_MIDDLE)
    self.screetchfaceoverlay2:SetHAnchor(ANCHOR_MIDDLE)
    self.screetchfaceoverlay2:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.screetchfaceoverlay2:SetClickable(false)
	self.screetchfaceoverlay2:SetTint(1,1,1,1)
	self.screetchfaceoverlay2:Hide()
	self.overlayroot:AddChild(self.screetchfaceoverlay2)

    self.bloodover = self.overlayroot:AddChild(BloodOver(owner))
    -- self.iceover = self.overlayroot:AddChild(IceOver(owner))
    -- self.fireover = self.overlayroot:AddChild(FireOver(owner))
    -- self.iceover:Hide()
    -- self.fireover:Hide()

    self.clouds = self.overlayroot:AddChild(UIAnim())
    self.clouds:SetClickable(false)
    self.clouds:SetHAnchor(ANCHOR_MIDDLE)
    self.clouds:SetVAnchor(ANCHOR_MIDDLE)
    self.clouds:GetAnimState():SetBank("clouds_ol")
    self.clouds:GetAnimState():SetBuild("clouds_ol")
    self.clouds:GetAnimState():PlayAnimation("idle", true)
    self.clouds:GetAnimState():SetMultColour(1,1,1,0)
    self.clouds:Hide()

end

function PlayerHud:OnLoseFocus()
	Screen.OnLoseFocus(self)
	TheInput:EnableMouse(true)
end

function PlayerHud:StartCredits()
	self.credits = self.overlayroot:AddChild(Credits(self.owner))
	self.credits:SetHAnchor(ANCHOR_MIDDLE)
	self.credits:SetVAnchor(ANCHOR_MIDDLE)
	self.credits:SetPosition(0, 0, 0)
end

function PlayerHud:Blackout()
	self.faceoverlay:Hide()
	self.blackoverlay:Show()
	self.bloodover:KillOverlay()
end

function PlayerHud:EndSequence()
	GetPlayer().components.playercontroller.enabled = false
	GetPlayer().components.health:SetInvincible(true)
	self.blackoverlay:Hide()
	--self.faceoverlay:Show()
	self.inst:DoTaskInTime(0.3, function(inst)
		self:Blackout()
	end)
	self.inst:DoTaskInTime(3.5, function(inst)
		self:StartCredits()
	end)
end

function PlayerHud:ShowNoFace()
	self.nofaceoverlay:Show()
	GetPlayer().SoundEmitter:PlaySound("scary_mod/music/end", "noface")
	self.inst:DoTaskInTime(5*FRAMES, function(inst)
		self.nofaceoverlay:Hide()
		self.inst:DoTaskInTime(12*FRAMES, function(inst)
			GetPlayer().SoundEmitter:KillSound("noface")
		end)
	end)
end

function PlayerHud:ShowOwlFace(duration)
	self.screetchfaceoverlay1:Show()
	GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream_long_2d", "screetchfaceoverlay1")
	GetPlayer().SoundEmitter:PlaySound("scary_mod/music/hit")
	self.inst:DoTaskInTime(5*FRAMES, function(inst)
		self.screetchfaceoverlay1:Hide()
		self.screetchfaceoverlay2:Show()
		self.inst:DoTaskInTime(duration, function(inst)
			self.screetchfaceoverlay2:Hide()
			GetPlayer().SoundEmitter:KillSound("screetchfaceoverlay1")
		end)
	end)
end

function PlayerHud:ShowOwlFaceShort()
	self.screetchfaceoverlay1:Show()
	--GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream_long_2d", "screetchfaceoverlay1")
	GetPlayer().SoundEmitter:PlaySound("scary_mod/music/hit")
	self.inst:DoTaskInTime(5*FRAMES, function(inst)
		self.screetchfaceoverlay1:Hide()
	end)
end

function PlayerHud:OnGainFocus()
	Screen.OnGainFocus(self)
	if TheInput:ControllerAttached() then
		TheInput:EnableMouse(false)
	end
	
	if self.controls then
		self.controls:SetHUDSize()
	end
end
	
function PlayerHud:Toggle()
	self.shown = not self.shown
	if self.shown then
		self.root:Show()
	else
		self.root:Hide()
	end
end

function PlayerHud:Hide()
	self.shown = false
	self.root:Hide()
end

function PlayerHud:Show()
	self.shown = true
	self.root:Show()
end


function PlayerHud:CloseContainer(container)
    for k,v in pairs(self.controls.containers) do
		if v.container == container then
			v:Close()
		end
    end
end

function PlayerHud:GetFirstOpenContainerWidget()
	
	local k,v = next(self.controls.containers)
	return v
end

function PlayerHud:OpenContainer(container, side)

	if side and self.controller_attached then
		return
	end

	if container then
		local containerwidget = nil
		if side then
			containerwidget = self.controls.containerroot_side:AddChild(ContainerWidget(self.owner))
		else
			containerwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
		end
		containerwidget:Open(container, self.owner)
	    
		for k,v in pairs(self.controls.containers) do
			if v.container then
				if v.container.prefab == container.prefab then
					v:Close()
				end
			else
				self.controls.containers[k] = nil
			end
		end
	    
		self.controls.containers[container] = containerwidget
	end
	    
end

function PlayerHud:GoSane()
    --self.vig:GetAnimState():PlayAnimation("basic", true)
end

function PlayerHud:GoInsane()
    --self.vig:GetAnimState():PlayAnimation("insane", true)
end

function PlayerHud:SetMainCharacter(maincharacter)
    if maincharacter then
		maincharacter.HUD = self
		self.owner = maincharacter

		self:CreateWidgets(self.owner)

		self.inst:ListenForEvent("initpainfx", function()
			self.firstfirelit = true
		end, self.owner)
		self.inst:ListenForEvent("flashlighton", function() 
			self.flashlightoff = false
			self.timeinthedark = 0
		end, self.owner)
    	self.inst:ListenForEvent("flashlightoff", function() 
    		self.flashlightoff = true
    	end, self.owner)
    	self.inst:ListenForEvent("fuellow", function()
    		self.fuellow = true
    	end, self.owner)
    	self.inst:ListenForEvent("fuelnotlow", function()
    		self.fuellow = false
    	end, self.owner)

		-- self.inst:ListenForEvent("badaura", function(inst, data) return self.bloodover:Flash() end, self.owner)
		-- self.inst:ListenForEvent("attacked", function(inst, data) return self.bloodover:Flash() end, self.owner)
		-- self.inst:ListenForEvent("startstarving", function(inst, data) self.bloodover:TurnOn() end, self.owner)
		-- self.inst:ListenForEvent("stopstarving", function(inst, data) self.bloodover:TurnOff() end, self.owner)
		-- self.inst:ListenForEvent("gosane", function(inst, data) self:GoSane() end, self.owner)
		-- self.inst:ListenForEvent("goinsane", function(inst, data) self:GoInsane() end, self.owner)
		
	end
end

function PlayerHud:OnUpdate(dt)
	self:UpdateClouds(dt)

	local player = GetPlayer()
	if player then
		local playerpos = player:GetPosition()
		if playerpos then 
			if self.bloodover and self.bloodover.enabled then

				local hasflashlight = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil
				local indarkarea = TheSim:GetLightAtPoint(playerpos.x,playerpos.y,playerpos.z) < TUNING.SCARY_MOD_DARKNESS_CUTOFF

				if self.firstfirelit and not hasflashlight and indarkarea then -- No flashlight, in dark: pain FX on
					self.bloodover:TurnOn()
					self.darkblockmap = true
				elseif self.firstfirelit and not hasflashlight and not indarkarea then -- No flashlight, not in dark: pain FX off 
					self.bloodover:TurnOff()
					self.darkblockmap = false
				elseif self.firstfirelit and hasflashlight and self.flashlightoff and indarkarea then -- Flashlight, light off and in dark: pain FX on
					self.bloodover:TurnOn()
					self.darkblockmap = true
				elseif self.firstfirelit and hasflashlight and self.fuellow and indarkarea then -- Flashlight, low fuel in a dark area (light on doesn't matter): pain FX on
					self.bloodover:TurnOn()
					self.darkblockmap = true
				else -- Otherwise, assume that either the light is on and has enough fuel or we're in the light
					self.bloodover:TurnOff()
					self.darkblockmap = false
				end
			end
		end
	end

	if self.credits then
		self.credits:OnUpdate(dt)
	end
	
	if self.tutorialtext then
		self.tutorialtext:OnUpdate(dt)
	end

	if self.notetext then
		self.notetext:OnUpdate(dt)
	end

	if self.batteryindicator then
		self.batteryindicator:OnUpdate(dt)
	end

	if self.note then
		self.note:OnUpdate(dt)
	end

	self:UpdatePlayerActionHint()

	if Profile and self.vig then
		if RENDER_QUALITY.LOW == Profile:GetRenderQuality() or TheConfig:IsEnabled("hide_vignette") then
			self.vig:Hide()
		else
			self.vig:Show()
		end
	end
end

function PlayerHud:UpdatePlayerActionHint()
	if self.owner then
		local target = self.owner.components.playercontroller.controller_target
		if target then
			self.playeractionhint:Show()
			self.playeractionhint:SetTarget(target)
			self.playeractionhint.text:SetString(target:GetDisplayName())
			
			local offset = target.nameoffset or 0
			self.playeractionhint:SetOffset(Vector3(0, -100-offset, 0))
		else
			self.playeractionhint:Hide()
		end
	end
end



function PlayerHud:OpenControllerInventory()
	--TheFrontEnd:StopTrackingMouse()
	--self:CloseControllerCrafting()
	--self.controls.inv:OpenControllerInventory()
end

function PlayerHud:CloseControllerInventory()
	--self.controls.inv:CloseControllerInventory()
end

function PlayerHud:IsControllerInventoryOpen()
	return false--self.controls.inv.open
end

function PlayerHud:IsNoteShowing()
	if self.note == nil then
		return false
	end
	return self.note:IsShowing()
end

function PlayerHud:OpenControllerCrafting()
	--TheFrontEnd:StopTrackingMouse()
	--self:CloseControllerInventory()
	--self.controls.crafttabs:OpenControllerCrafting()
end

function PlayerHud:CloseControllerCrafting()
	--self.controls.crafttabs:CloseControllerCrafting()	
end

function PlayerHud:IsControllerCraftingOpen()
	return false --self.controls.crafttabs.controllercraftingopen
end


function PlayerHud:OnControl(control, down)
	if PlayerHud._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_PAUSE then
		if not self.externalblockmap and not self.shamblerblockmap and not self.darkblockmap then
			TheFrontEnd:PushScreen(PauseScreen())
		elseif not self.credits then 
			GetPlayer():PushEvent("triedtopause")
		end
		return true
	end

	if not self.note:IsShowing() and not down and control == CONTROL_MAP and not self.credits then
		if (not self.owner:HasTag("beaver") and self.owner:HasTag("mapowner")) or (DEBUGGING_MOD and TheInput:IsKeyDown(KEY_SHIFT)) then
			if not self.externalblockmap and not self.shamblerblockmap then
				if not self.darkblockmap then
					if GetWorld().minimap.MiniMap:IsVisible() then --Okay to map
						TheFrontEnd:PopScreen()
					else
						GetPlayer():PushEvent("openmap")
						TheFrontEnd:PushScreen(MapScreen())
					end
					return true
				else -- Too dark for map
					GetPlayer():PushEvent("triedtomapindark")
				end
			else -- Other cause for blocking map
				GetPlayer():PushEvent("triedtomapinstress")
			end
		end
	end
	
end

function PlayerHud:OnRawKey( key, down )
	if PlayerHud._base.OnRawKey(self, key, down) then return true end
end

function PlayerHud:UpdateClouds(dt)
 --   if not GetWorld():IsCave() then
	--     --this is kind of a weird place to do all of this, but the anim *is* a hud asset...
	--     if TheCamera and TheCamera.distance and not TheCamera.dollyzoom then
	--         local dist_percent = (TheCamera.distance - TheCamera.mindist) / (TheCamera.maxdist - TheCamera.mindist)
	--         local cutoff = .6
	--         if dist_percent > cutoff then
	--             if not self.clouds_on then
	-- 				TheCamera.should_push_down = true
	--                 self.clouds_on = true
	--                 self.clouds:Show()
	--                 self.owner.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")
	--                 TheMixer:PushMix("high")
	--             end
	            
	--             local p = easing.outCubic( dist_percent-cutoff , 0, 1, 1 - cutoff) 
	--             self.clouds:GetAnimState():SetMultColour(1,1,1, p )
	--             self.owner.SoundEmitter:SetVolume("windsound",p)
	--         else
	--             if self.clouds_on then
	-- 				TheCamera.should_push_down = false
	--                 self.clouds_on = false
	--                 self.clouds:Hide()
	--                 self.owner.SoundEmitter:KillSound("windsound")
	--                 TheMixer:PopMix("high")
	--             end
	--         end
	--     end
	-- end
end


return PlayerHud

