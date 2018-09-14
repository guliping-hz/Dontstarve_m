local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local WorldGenScreen = require "screens/worldgenscreen"
local CustomizationScreen = require "screens/customizationscreen"
local CharacterSelectScreen = require "screens/characterselectscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"

local REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD = 20*32 --20 xp per day, 32 days

local NewGameScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "LoadGameScreen")
    self.profile = Profile
    self.saveslot = slotnum
    self.character = "wilson"

   	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)

    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))
    
	--[[self.cancelbutton = self.root:AddChild(ImageButton())
	self.cancelbutton:SetScale(.8,.8,.8)
    self.cancelbutton:SetText(STRINGS.UI.NEWGAMESCREEN.CANCEL)
    self.cancelbutton:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(35)
    self.cancelbutton.text:SetVAlign(ANCHOR_MIDDLE)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetPosition( 0, -235, 0)
    --]]

    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 75, 135, 0)
    self.title:SetRegionSize(250,60)
    self.title:SetHAlign(ANCHOR_LEFT)
	self.title:SetString(STRINGS.UI.NEWGAMESCREEN.TITLE)

	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, self.character..".tex")
	self.portrait:SetPosition(-120, 135, 0)
  
  	local menuitems = {}
  	if IsDLCInstalled(REIGN_OF_GIANTS) then
		self:MakeReignOfGiantsButton()

	    menuitems = 
	    {
			{text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)},
			{widget = self.RoGbutton},
			{text = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, cb = function() self:ChangeCharacter() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen(self) end},
	    }
  	else
  		menuitems = 
	    {
			{text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)},
			{text = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, cb = function() self:ChangeCharacter() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen(self) end},
	    }
  	end

    self.menu = self.root:AddChild(Menu(menuitems, -70))
	self.menu:SetPosition(0, 30, 0)

	self.default_focus = self.menu
    
end)

function NewGameScreen:OnGainFocus()
	NewGameScreen._base.OnGainFocus(self)
	self.menu:SetFocus()
end

function NewGameScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function NewGameScreen:Customize( )
	
	local function onSet(options, dlc)
		TheFrontEnd:PopScreen()
		if options then
			self.customoptions = options
		end
	end

	if self.prevworldcustom ~= self.RoG and IsDLCInstalled(REIGN_OF_GIANTS) then
		local prev = self.prevcustomoptions
		self.prevcustomoptions = self.customoptions
		self.customoptions = prev
		package.loaded["map/customise"] = nil
	end
	self.prevworldcustom = self.RoG

	-- Clean up the preset setting since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.actualpreset then
		self.customoptions.preset = self.customoptions.actualpreset
		self.customoptions.actualpreset = nil
	end
	-- Clean up the tweak table since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
		for i,v in pairs(self.customoptions.faketweak) do
			for m,n in pairs(self.customoptions.tweak) do
				for j,k in pairs(n) do
					if v == j then -- Found the fake tweak setting, now remove it from the table
						self.customoptions.tweak[m][j] = nil
						break
					end
				end
			end
		end
	end

	TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG))--self.customization)
end

function NewGameScreen:ChangeCharacter(  )
	
	local function onSet(character, random)
		TheFrontEnd:PopScreen()
		if character and IsDLCInstalled(REIGN_OF_GIANTS) then
			package.loaded["map/customise"] = nil
			self.prevworldcustom = self.RoG
			--self.customoptions = nil
			self.prevcharacter = nil
			self.characterreverted = false
			self.character = character

			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		elseif character then
			self.character = character			
			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		end
	end

	TheFrontEnd:PushScreen(CharacterSelectScreen(Profile, onSet, false, self.character))--, self.RoG))
end



function NewGameScreen:Start()
	local function onsaved()
	    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot})
	end

	local function GetEnabledDLCs()
		local dlc = {REIGN_OF_GIANTS = self.RoG}
		return dlc
	end

	local xp = Profile:GetXP()
	if IsDLCInstalled(REIGN_OF_GIANTS) and self.RoG and xp <= REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD and not Profile:HaveWarnedDifficultyRoG() then
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_TITLE, STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_BODY, 
			{{text=STRINGS.UI.NEWGAMESCREEN.YES, 
				cb = function() 
					Profile:SetHaveWarnedDifficultyRoG()
					TheFrontEnd:PopScreen()
					self:Start()
				end},
			{text=STRINGS.UI.NEWGAMESCREEN.NO, 
				cb = function() 
					TheFrontEnd:PopScreen() 
				end}  
			})
		)
	else
		if self.prevworldcustom ~= self.RoG then
			self.customoptions = self.prevcustomoptions
		end

		-- Clean up the tweak table since we don't want "default" overrides
		if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
			for i,v in pairs(self.customoptions.faketweak) do
				for m,n in pairs(self.customoptions.tweak) do
					for j,k in pairs(n) do
						if v == j and k == "default" then -- Found the fake tweak setting for "default", now remove it from the table
							self.customoptions.tweak[m][j] = nil
							break
						end
					end
				end
			end
		end

		self.root:Disable()
		TheFrontEnd:Fade(false, 1, function() SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved, GetEnabledDLCs()) end )
	end
end


function NewGameScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

function NewGameScreen:MakeReignOfGiantsButton()
	EnableAllDLC()
	self.RoG = IsDLCEnabled(REIGN_OF_GIANTS)
	self.prevworldcustom = true

	self.RoGbutton = self:AddChild(Widget("option"))
	self.RoGbutton.image = self.RoGbutton:AddChild(Image("images/ui.xml", "DLCicontoggle.tex"))
	self.RoGbutton.image:SetPosition(25,0,0)
	self.RoGbutton.checkbox = self.RoGbutton:AddChild(Image("images/ui.xml", "button_checkbox2.tex"))
	self.RoGbutton.checkbox:SetPosition(-35,0,0)
	self.RoGbutton.checkbox:SetScale(0.5,0.5,0.5)

	self.RoGbutton.bg = self.RoGbutton:AddChild(UIAnim())
	self.RoGbutton.bg:GetAnimState():SetBuild("savetile_small")
	self.RoGbutton.bg:GetAnimState():SetBank("savetile_small")
	self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
	self.RoGbutton.bg:SetPosition(-75,0,0)
	self.RoGbutton.bg:SetScale(1.12,1,1)

	self.RoGbutton.OnGainFocus = function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			self.RoGbutton:SetScale(1.1,1.1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("over")
		end

	self.RoGbutton.OnLoseFocus = function()
			self.RoGbutton:SetScale(1,1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
		end

	self.RoGbutton.OnControl = function(_, control, down) 
		if Widget.OnControl(self.RoGbutton, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self.RoG = not self.RoG
			if self.RoG == true then
				self.RoGbutton.checkbox:SetTint(1,1,1,1)
				self.RoGbutton.image:SetTint(1,1,1,1)
				if self.characterreverted == true and self.prevcharacter ~= nil then --Switch back to DLC character if possible
					self.character = self.prevcharacter
					self.prevcharacter = nil
					self.characterreverted = false
					local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
					self.portrait:SetTexture(atlas, self.character..".tex")
				end
				self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
				EnableDLC(REIGN_OF_GIANTS)
			elseif self.RoG == false then
				self.RoGbutton.checkbox:SetTint(1.0,0.5,0.5,1)
				self.RoGbutton.image:SetTint(1,1,1,.3)
				if self.character == "wathgrithr" or self.character == "webber" then --Switch to Wilson if currently have DLC char selected
					self.characterreverted = true
					self.prevcharacter = self.character
					self.character = "wilson"
					local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
					self.portrait:SetTexture(atlas, self.character..".tex")
				end
				self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
				DisableDLC(REIGN_OF_GIANTS)
			end
			return true
		end
	end

	self.RoGbutton.GetHelpText = function()
		local controller_id = TheInput:GetControllerID()
		local t = {}
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)	
		return table.concat(t, "  ")
	end
end

return NewGameScreen