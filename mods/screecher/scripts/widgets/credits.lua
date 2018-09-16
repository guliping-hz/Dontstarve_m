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

local Credits = Class(Widget, function(self, owner)
    self.owner = owner

    local nameduration = 3.5
    self.all_names = 
    {
    	{ "Seth Rosen", nameduration },
    	{ "Graham Jans", nameduration },
    	{ "Jamie Cheng", nameduration },
    	{ "Aaron Bouthillier", nameduration },
    	{ "Allan Cortez", nameduration },
    	{ "Jeff Agala", nameduration },
    	{ "Matthew Marteinsson", nameduration },
    	{ "Brook Miles", nameduration }
	}

	self.names = 
	{
		{ "The Screecher", nameduration },
		{ "A Don't Starve mod by Klei Entertainment", nameduration },
	}

	if GetPlayer() and GetPlayer().components.scarymodencountermanager then
		local notesfound = GetPlayer().components.scarymodencountermanager.total_notes_found
		local notesfoundstr = string.format("You collected %d out of 9 notes", notesfound)
		table.insert( self.names, { notesfoundstr, 6 } )
	end

	while #self.all_names > 0 do
		local nextname = table.remove(self.all_names, math.random(1, #self.all_names))
		table.insert( self.names, nextname )
	end

    self.timetonextname = 0.3
    self.nameduration = 3.5
    self.namechange = true
    self.finished = false

    Widget._ctor(self, "DemoTimer")
    
    local font = UIFONT
    
    self.text = self:AddChild(Text(NUMBERFONT, 45))
    self.text:SetString("")
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetVAlign(ANCHOR_MIDDLE)
	self.text:SetRegionSize( 1500, 100 )
	self.text:SetPosition( 0, 0, 0 )

	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = -1
	self.fadeout_timeleft = -1
    self:OnUpdate(0)
    self.text:SetAlpha(0)
    self:FadeIn()
end)

function Credits:FadeOut()
	self.fadedirection = FADEDIRECTION.FADEOUT
	self.fadeout = FADEOUT_TIME
	self.fadeout_timeleft = FADEOUT_TIME
	self.text:SetAlpha(1)
end

function Credits:FadeIn()
	self.fadedirection = FADEDIRECTION.FADEIN
	self.fadeout = FADEIN_TIME
	self.fadeout_timeleft = FADEIN_TIME
	self.text:SetAlpha(0)
end

function Credits:SetName(txt)
	self.text:SetString( txt )
end

function Credits:SetColour(r,g,b,a)
	self.text:SetColour(r,g,b,a)
end

function Credits:OnUpdate(dt)
	local player = GetPlayer()

	if self.namechange and not self.finished then
		self.timetonextname = self.timetonextname - dt
		if self.timetonextname <= 0 then
			if #self.names == 0 then
				TheFrontEnd:Fade(false, 2, function()
	        		SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function() 
		                StartNextInstance()
	    	    	end)
	    		end)
	    		self.finished = true
			else
				local nextname = table.remove(self.names, 1)
				self:SetName(nextname[1])
				self:FadeIn()
				self.namechange = false
				self.nameduration = nextname[2]
			end
		end
	elseif not self.finished then
		self.nameduration = self.nameduration - dt
		if self.nameduration <= 0 then
			self:FadeOut()
			self.namechange = true
			self.timetonextname = 0.8
		end
	end

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
end

return Credits