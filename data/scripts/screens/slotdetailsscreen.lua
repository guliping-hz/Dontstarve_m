local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
require "os"

local function ShowLoading()
	if global_loading_widget then 
		global_loading_widget:SetEnabled(true)
	end
end

local SlotDetailsScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "LoadGameScreen")
    self.profile = Profile
    self.saveslot = slotnum

	local mode = SaveGameIndex:GetCurrentMode(slotnum)
	local day = SaveGameIndex:GetSlotDay(slotnum)
	local world = SaveGameIndex:GetSlotWorld(slotnum)
	local character = SaveGameIndex:GetSlotCharacter(slotnum) or "wilson"
	local DLC = SaveGameIndex:GetSlotDLC(slotnum)
	self.RoG = (DLC ~= nil and DLC.REIGN_OF_GIANTS ~= nil) and DLC.REIGN_OF_GIANTS or false
	self.character = character

    
	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetPosition(0,0,0)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)
    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))

    if JapaneseOnPS4() then
        self.text = self.root:AddChild(Text(TITLEFONT, 40))
    else
        self.text = self.root:AddChild(Text(TITLEFONT, 60))
    end
    self.text:SetPosition( 75, 135, 0)
    self.text:SetRegionSize(250,60)
    self.text:SetHAlign(ANCHOR_LEFT)


	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, character..".tex")
	self.portrait:SetPosition(-120, 135, 0)

	if character and mode and self.RoG then
		self.dlcindicator = self.root:AddChild(Image())
		self.dlcindicator:SetClickable(false)
		self.dlcindicator:SetTexture("images/ui.xml", "DLCicon.tex")
		self.dlcindicator:SetScale(.75,.75,1)
		self.dlcindicator:SetPosition(0, 60, 0)
	end
      
    self.menu = self.root:AddChild(Menu(nil, -70))
	self.menu:SetPosition(0, -50, 0)
	
	self.default_focus = self.menu
end)

function SlotDetailsScreen:OnBecomeActive()
	self:BuildMenu()
	SlotDetailsScreen._base.OnBecomeActive(self)
end

function SlotDetailsScreen:BuildMenu()


	local mode = SaveGameIndex:GetCurrentMode(self.saveslot)
	local day = SaveGameIndex:GetSlotDay(self.saveslot)
	local world = SaveGameIndex:GetSlotWorld(self.saveslot)
	local character = SaveGameIndex:GetSlotCharacter(self.saveslot) or "wilson"

    local menuitems = 
    {
		{name = STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, fn = function() self:Continue() end, offset = Vector3(0,20,0)},
		{name = STRINGS.UI.SLOTDETAILSSCREEN.DELETE, fn = function() self:Delete() end},
		{name = STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, fn = function() EnableAllDLC() TheFrontEnd:PopScreen(self) end},
	}

	if mode == "adventure" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
	elseif mode == "survival" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
	elseif mode == "cave" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.CAVE, world, day))
	else
		--This should only happen if the user has run a mod that created a new type of game mode.
		self.text:SetString(string.format("%s",STRINGS.UI.LOADGAMESCREEN.MODDED))
	end 
    
	self.menu:Clear()

    for k,v in pairs(menuitems) do
    	self.menu:AddItem(v.name, v.fn, v.offset)
    end

    if self.RoG and not IsDLCInstalled(REIGN_OF_GIANTS) then
		for i,j in pairs(self.menu.items) do
			if j:GetText() == STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE then
				j:SetTextColour(0,0,0,.5)
				j:SetTextFocusColour(1,0,0,.75)
				j:SetOnClick(function() self:PushCantContinueDialog(REIGN_OF_GIANTS) end)
			end
		end
	end
end

function SlotDetailsScreen:OnControl( control, down )
	if SlotDetailsScreen._base.OnControl(self, control, down) then return true end
	
	if control == CONTROL_CANCEL and not down then
		TheFrontEnd:PopScreen(self)
		return true
	end
end


function SlotDetailsScreen:Delete()

	local menu_items = 
	{
		-- ENTER
		{
			text=STRINGS.UI.MAINSCREEN.DELETE, 
			cb = function()
				EnableAllDLC()
				TheFrontEnd:PopScreen()
				SaveGameIndex:DeleteSlot(self.saveslot, function() TheFrontEnd:PopScreen() end)
			end
		},
		-- ESC
		{text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() self.menu:SetFocus() end},
	}

	TheFrontEnd:PushScreen(
		PopupDialogScreen(STRINGS.UI.MAINSCREEN.DELETE.." "..STRINGS.UI.MAINSCREEN.SLOT.." "..self.saveslot, STRINGS.UI.MAINSCREEN.SURE, menu_items ) )

end

function SlotDetailsScreen:PushCantContinueDialog(index)
	local menu_items = 
	{
		-- OK
		{text=STRINGS.UI.MAINSCREEN.OK, cb = function() TheFrontEnd:PopScreen() self.menu:SetFocus() end},
	}

	if index == REIGN_OF_GIANTS then
		TheFrontEnd:PushScreen(
			PopupDialogScreen(STRINGS.UI.MAINSCREEN.CANT_LOAD_TITLE, STRINGS.UI.MAINSCREEN.CANT_LOAD_ROG.." "..STRINGS.UI.MAINSCREEN.SLOT.." "..self.saveslot..".", menu_items ) )
	end
end

function SlotDetailsScreen:CheckForDisabledMods()

	local function isModEnabled(mod, enabledmods)
		for i,v in pairs(enabledmods) do
			if mod == v then
				return true
			end
		end
		return false
	end

	local disabled = {}

	local savedmods = SaveGameIndex:GetSlotMods(self.saveslot)
	local currentlyenabledmods = ModManager:GetEnabledModNames()

	for i,v in pairs(savedmods) do
		if not isModEnabled(v, currentlyenabledmods) and KnownModIndex:IsModCompatibleWithMode(v, self.RoG) then
			table.insert(disabled, v)
		end
	end

	return disabled
end

function SlotDetailsScreen:ShowModalModsDisabledWarning(disabledmods)	
	local maxlistlength = 185
	local maxnamelength = 25
	local message_body = STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_EXPLANATION.."\n"

	local truncated = false
	for i,v in ipairs(disabledmods) do
		local name = KnownModIndex:GetModFancyName(v) or v
		if string.len(name) > maxnamelength then
			name = string.sub(name, 0, maxnamelength)
		end
		if i == 1 then -- No comma for first mod in the list
			message_body = message_body..name
		elseif string.len(message_body..", "..name) <= maxlistlength then -- Subsequent mods get a comma and added, but only if they don't break max size
			message_body = message_body..", "..name
		else
			truncated = true
			break
		end
	end

	if truncated then
		message_body = message_body..STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_TRUNCATEDLIST
	end

	message_body = message_body.."\n\n"..STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_QUESTION

	TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGTITLE, message_body, 
			{{text=STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, 
				cb = function() 
					TheFrontEnd:PopScreen()
					self:Continue(true)
				end},
			{text=STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, 
				cb = function() 
					TheFrontEnd:PopScreen() 
				end}  
			})
		)
end

function SlotDetailsScreen:Continue(force)
	local disabledmods = self:CheckForDisabledMods()
	if #disabledmods == 0 or force then
		self.root:Disable()
		
	    ShowLoading()
		
		TheFrontEnd:Fade(false, 1, function() 
			StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot})
		 end)
	else
		self:ShowModalModsDisabledWarning(disabledmods)
	end
end

function SlotDetailsScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

return SlotDetailsScreen