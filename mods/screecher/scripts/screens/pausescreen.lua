local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local TextButton = require "widgets/textbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local ControlsScreen = nil
local OptionsScreen = nil
if PLATFORM == "PS4" then
    ControlsScreen = require "screens/controlsscreen_ps4"
    OptionsScreen = require "screens/optionsscreen_ps4"
else
    ControlsScreen = require "screens/controlsscreen"
    OptionsScreen = require "screens/optionsscreen"
end

local function dorestart()
	local player = GetPlayer()
	local purchased = IsGamePurchased()
	
	local postfadefn = function()
		if purchased then
			local player = GetPlayer()
			if player then
				player:PushEvent("quit", {})
			else
				StartNextInstance()
			end
		else
			ShowUpsellScreen(true)
			DEMO_QUITTING = true
		end
		
		inGamePlay = false
	end
	
	TheFrontEnd:Fade(false, 1, postfadefn)
end

local function FakePause(pause)
    local player = GetPlayer()
	if pause and player then
		if not player.paused then
			player.paused = true
			TheSim:SetTimeScale(0)
		end
	else
	    if player.paused then
			player.paused = false
			TheSim:SetTimeScale(1)
			player.components.playercontroller:CancelDeltas()
		end
	end
end

local PauseScreen = Class(Screen, function(self)
	Screen._ctor(self, "PauseScreen")

	self.active = true
	FakePause(true)
	
	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
 --    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
 --    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
 --    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	-- self.bg:SetScale(1.5,1.2,1.2)
	
	--title	
    -- self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    -- self.title:SetPosition(0, 50, 0)
    -- self.title:SetString(STRINGS.UI.PAUSEMENU.TITLE)


	--create the menu itself
	local player = GetPlayer()
	local can_save = false --player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
	local button_w = 160
	
	local buttons = {}
    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.QUIT, cb=function() self:doconfirmquit() end})
    table.insert(buttons, {text=STRINGS.UI.MAINSCREEN.SETTINGS, cb=function() TheFrontEnd:PushScreen( OptionsScreen(true))	end })
	table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.CONTINUE, cb=function() TheFrontEnd:PopScreen(self) if not self.was_paused then FakePause(false) end end, offset = Vector3(0,0,0) })
    
	self.menu = self.proot:AddChild(Menu(nil, button_w))
	self.menu.offset = 50
	self.menu.AddItem = function(self, text, cb, offset)
		local pos = Vector3(0,0,0)
		pos.y = pos.y + self.offset * #self.items
		
		if offset then
			pos = pos + offset	
		end
		
		local button = self:AddChild(TextButton())
		button:SetPosition(pos)
		button:SetText(text)

		button:SetTextColour(0.9,0.8,0.6,1)
		button:SetOnClick( cb )
		button:SetFont(BUTTONFONT)
		button:SetTextSize(40)    

		table.insert(self.items, button)

		self:DoFocusHookups()
		return button
	end

	for k,v in ipairs(buttons) do
		self.menu:AddItem(v.text, v.cb, v.offset)
	end

	self.menu:SetPosition(360, -65, 0) 

	TheInputProxy:SetCursorVisible(true)
	self.default_focus = self.menu
end)

 function PauseScreen:doconfirmquit()
 	self.active = false
	local function doquit()
		self.parent:Disable()
		self.menu:Disable()
		dorestart()
	end

	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.PAUSEMENU.QUITTITLE, STRINGS.UI.PAUSEMENU.QUITBODY, 
		{
			{text=STRINGS.UI.PAUSEMENU.QUITYES, cb = doquit},
			{text=STRINGS.UI.PAUSEMENU.QUITNO, cb = function() TheFrontEnd:PopScreen() end}  
		}))
end

function PauseScreen:OnControl(control, down)
	if PauseScreen._base.OnControl(self,control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then	
		self.active = false
		TheFrontEnd:PopScreen() 
		FakePause(false)
		return true
	end

end

function PauseScreen:OnUpdate(dt)
	-- if self.active then
	-- 	FakePause(true)
	-- end
end

return PauseScreen
