--死亡不删档：
local save = GLOBAL.SaveIndex
local adventure = GetModConfigData("Die in Adventure")
local save_manually = GetModConfigData("Save Manually")
function save:EraseCurrent(cb)
	self:Save(cb)
	--[[
	GLOBAL.GetPlayer():DoTaskInTime(2.6, function()
	    GLOBAL.TheFrontEnd:Fade(false,1)
	end )
	GLOBAL.GetPlayer():DoTaskInTime(3.5, function()
		GLOBAL.StartNextInstance({reset_action=GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()}, true)
	end )
	--]]
end

function save:OnFailAdventure(cb)
	if adventure == "load" then
		local function loadcb()
			GLOBAL.TheFrontEnd:Fade(false, 2, function () 
				 GLOBAL.StartNextInstance({reset_action = GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()}, true)
			end )
		end
		self:Save(loadcb)
	else
		local filename = self.data.slots[self.current_slot].modes.adventure.file

		local function onsavedindex()
			GLOBAL.EraseFiles(cb, {filename})
		end
		self.data.slots[self.current_slot].current_mode = "survival"
		self.data.slots[self.current_slot].modes.adventure = {}
		self:Save(onsavedindex)
	end
end

--快捷键:
if save_manually == "f5" then
	GLOBAL.TheInput:AddKeyUpHandler(GLOBAL.KEY_F5, function()    --F5存档
		if GLOBAL.inGamePlay then
				GLOBAL.GetPlayer().HUD.controls.saving:StartSave()
				GLOBAL.GetPlayer():DoTaskInTime(.8, function() 
					GLOBAL.SaveGameIndex:SaveCurrent() 
				end )
				GLOBAL.GetPlayer():DoTaskInTime(2.8, function() 
					GLOBAL.GetPlayer().HUD.controls.saving:EndSave()
				end)
		end
	end)
end