table.insert(GLOBAL.STRINGS, "DFV_LANG")
table.insert(GLOBAL.STRINGS, "DFV_HUNGER")
table.insert(GLOBAL.STRINGS, "DFV_HEALTH")
table.insert(GLOBAL.STRINGS, "DFV_SANITY")
table.insert(GLOBAL.STRINGS, "DFV_SPOILSOON")
table.insert(GLOBAL.STRINGS, "DFV_SPOILIN")
table.insert(GLOBAL.STRINGS, "DFV_SPOILDAY")
table.insert(GLOBAL.STRINGS, "DFV_MIN")

local DFV_LANG = GetModConfigData("DFV_Language")
local DFV_MIN = not (GetModConfigData("DFV_MinimalMode")=="default")

GLOBAL.STRINGS.DFV_MIN = DFV_MIN
GLOBAL.STRINGS.DFV_LANG = DFV_LANG

if DFV_LANG == "FR" then
	GLOBAL.STRINGS.DFV_HUNGER = "Points de faim"
	GLOBAL.STRINGS.DFV_HEALTH = "Points de vie"
	GLOBAL.STRINGS.DFV_SANITY = "Sante mentale"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Pourrira bientot"
	GLOBAL.STRINGS.DFV_SPOILIN = "Pourrira dans"
	GLOBAL.STRINGS.DFV_SPOILDAY = "jour"
elseif DFV_LANG == "GR" then
	GLOBAL.STRINGS.DFV_HUNGER = "Hunger"
	GLOBAL.STRINGS.DFV_HEALTH = "Gesundheit"
	GLOBAL.STRINGS.DFV_SANITY = "Verstand"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Verdirbt sehr bald"
	GLOBAL.STRINGS.DFV_SPOILIN = "Verdirbt in"
	GLOBAL.STRINGS.DFV_SPOILDAY = "Tag"
elseif DFV_LANG == "RU" then
	GLOBAL.STRINGS.DFV_HUNGER = "Голод"
	GLOBAL.STRINGS.DFV_HEALTH = "Здоровье"
	GLOBAL.STRINGS.DFV_SANITY = "Рассудок"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Скоро испортится"
	GLOBAL.STRINGS.DFV_SPOILIN = "Испортится через"
	GLOBAL.STRINGS.DFV_SPOILDAY = "дней"
elseif DFV_LANG == "SP" then
	GLOBAL.STRINGS.DFV_HUNGER = "Hambre"
	GLOBAL.STRINGS.DFV_HEALTH = "Salud"
	GLOBAL.STRINGS.DFV_SANITY = "Cordura"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Echara a perder muy pronto"
	GLOBAL.STRINGS.DFV_SPOILIN = "Echara a perder en"
	GLOBAL.STRINGS.DFV_SPOILDAY = "dia"
elseif DFV_LANG == "IT" then
	GLOBAL.STRINGS.DFV_HUNGER = "Fame"
	GLOBAL.STRINGS.DFV_HEALTH = "Vita"
	GLOBAL.STRINGS.DFV_SANITY = "Sanita'"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Marcira' molto presto"
	GLOBAL.STRINGS.DFV_SPOILIN = "Marcira' tra"
	GLOBAL.STRINGS.DFV_SPOILDAY = "giorn"
elseif DFV_LANG == "NL" then
	GLOBAL.STRINGS.DFV_HUNGER = "Honger"
	GLOBAL.STRINGS.DFV_HEALTH = "Gezondheid"
	GLOBAL.STRINGS.DFV_SANITY = "Geestelijke Gezondheid"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Verderft binnenkort"
	GLOBAL.STRINGS.DFV_SPOILIN = "Aan het bederven"
	GLOBAL.STRINGS.DFV_SPOILDAY = "dag"
elseif DFV_LANG == "TR" then
	GLOBAL.STRINGS.DFV_HUNGER = "Aclik"
	GLOBAL.STRINGS.DFV_HEALTH = "Saglik"
	GLOBAL.STRINGS.DFV_SANITY = "Akil"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Cok yakinda bozulacak"
	GLOBAL.STRINGS.DFV_SPOILIN = "Bozulmasina"
	GLOBAL.STRINGS.DFV_SPOILDAY = "gun"
elseif DFV_LANG == "CN" then
	GLOBAL.STRINGS.DFV_HUNGER = "???"
	GLOBAL.STRINGS.DFV_HEALTH = "???"
	GLOBAL.STRINGS.DFV_SANITY = "???"
	GLOBAL.STRINGS.DFV_SPOILSOON = "????????"
	GLOBAL.STRINGS.DFV_SPOILIN = "?????"
	GLOBAL.STRINGS.DFV_SPOILDAY = "?"
else
	GLOBAL.STRINGS.DFV_HUNGER = "Hunger"
	GLOBAL.STRINGS.DFV_HEALTH = "Health"
	GLOBAL.STRINGS.DFV_SANITY = "Sanity"
	GLOBAL.STRINGS.DFV_SPOILSOON = "Will spoil very soon"
	GLOBAL.STRINGS.DFV_SPOILIN = "Will spoil in"
	GLOBAL.STRINGS.DFV_SPOILDAY = "day"
end

require = GLOBAL.require
require("constants")

local TheInput=GLOBAL.TheInput
local GetPlayer=GLOBAL.GetPlayer
local GetSeasonManager=GLOBAL.GetSeasonManager
local ACTIONS=GLOBAL.ACTIONS
local CONTROL_INSPECT=GLOBAL.CONTROL_INSPECT
local CONTROL_FORCE_INSPECT=GLOBAL.CONTROL_FORCE_INSPECT
local CONTROL_FORCE_TRADE=GLOBAL.CONTROL_FORCE_TRADE
local CONTROL_FORCE_STACK=GLOBAL.CONTROL_FORCE_STACK
local STRINGS=GLOBAL.STRINGS
local TIP_YFUDGE = 16
local CURSOR_STRING_DELAY = 10
local W = 68

local Inv = require "widgets/inventorybar"
local Inv_UpdateCursorText_base = Inv.UpdateCursorText or function() return "" end

function Inv:UpdateCursorText()
	
	local tmp = Inv_UpdateCursorText_base(self)

	local inv_item = self:GetCursorItem()
	local active_item = self.cursortile and self.cursortile.item 
	local item = active_item or inv_item
	
	if item then
		if self.open then
			if not is_equip_slot then
				local actionpicker = self.owner and self.owner.components.playeractionpicker or GetPlayer().components.playeractionpicker
				local realfood = nil
				local actions = actionpicker:GetInventoryActions(inv_item)

				if actions then
				    for k,v in pairs(actions) do							
						if v.action == ACTIONS.EAT or v.action == ACTIONS.HEAL then
						    realfood = true
						    break
						end
				    end
				end
				
				local str = {}
				table.insert(str, self.actionstringbody:GetString())
				local show_spoil = TheInput:IsControlPressed(CONTROL_INSPECT)
				
				if inv_item and inv_item.components.edible and realfood then
				    local hungervalue = 0
				    local healthvalue = 0
				    local sanityhvalue = 0
				    
				    local plr = GetPlayer()
				    if plr.components.eater and plr.components.eater.monsterimmune then--GetPlayer().prefab == "webber" then
						if inv_item.components.edible.hungervalue < 0 and plr.components.eater:DoFoodEffects(inv_item) or inv_item.components.edible.hungervalue > 0 then
						    hungervalue = math.floor(inv_item.components.edible:GetHunger(plr) * 10 + 0.5) / 10
						end
						if inv_item.components.edible.healthvalue < 0 and plr.components.eater:DoFoodEffects(inv_item) or inv_item.components.edible.healthvalue > 0 then
						    healthvalue = math.floor(inv_item.components.edible:GetHealth(plr) * 10 + 0.5) / 10
						end
						if inv_item.components.edible.sanityvalue < 0 and plr.components.eater:DoFoodEffects(inv_item) or inv_item.components.edible.sanityvalue > 0 then
						    sanityhvalue = math.floor(inv_item.components.edible:GetSanity(plr) * 10 + 0.5) / 10
						end
					else
						hungervalue = math.floor(inv_item.components.edible:GetHunger(plr) * 10 + 0.5) / 10
						healthvalue = math.floor(inv_item.components.edible:GetHealth(plr) * 10 + 0.5) / 10
						sanityhvalue = math.floor(inv_item.components.edible:GetSanity(plr) * 10 + 0.5) / 10
					end
					
					if STRINGS.DFV_MIN then		
						local tmp_str = ""		
					    if hungervalue ~= 0 then
							tmp_str = tmp_str .. "\153" .. " " .. hungervalue .. " "
					    end
					    if healthvalue ~= 0 then
							tmp_str = tmp_str .. "\151" .. " " .. healthvalue .. " "
					    end
					    if sanityhvalue ~= 0 then
							tmp_str = tmp_str .. "\152" .. " " .. sanityhvalue .. " "
					    end
					    
					    table.insert(str, tmp_str)
					else
					    if hungervalue ~= 0 then
							table.insert(str, STRINGS.DFV_HUNGER .. " " .. hungervalue)
					    end
					    if healthvalue ~= 0 then
							table.insert(str, STRINGS.DFV_HEALTH .. " " .. healthvalue)
					    end
					    if sanityhvalue ~= 0 then
							table.insert(str, STRINGS.DFV_SANITY .. " " .. sanityhvalue)
					    end					
					end	
					
				elseif inv_item and inv_item.components.healer and realfood then
				    table.insert(str, STRINGS.DFV_HEALTH .. " " .. inv_item.components.healer.health)
				end
				
				if inv_item and inv_item.components.perishable and realfood and show_spoil then
				    local inv_item_owner = inv_item.components.inventoryitem and inv_item.components.inventoryitem.owner  or nil
				    local modifier = 1

				    if inv_item_owner then				    	
						if inv_item_owner:HasTag("fridge") then
							if inv_item:HasTag("frozen") then
								modifier = TUNING.PERISH_COLD_FROZEN_MULT
							else
								modifier = TUNING.PERISH_FRIDGE_MULT 
							end 
						elseif inv_item_owner:HasTag("spoiler") then
							modifier = TUNING.PERISH_GROUND_MULT 
						end
					else
						modifier = TUNING.PERISH_GROUND_MULT 
					end						
						
					if GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() < 0 then
						if inv_item:HasTag("frozen") and not inv_item.components.perishable.frozenfiremult then
							modifier = TUNING.PERISH_COLD_FROZEN_MULT
						else
							modifier = modifier * TUNING.PERISH_WINTER_MULT
						end
					end
						
					if inv_item.components.perishable.frozenfiremult then
						modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
					end
					
					if TUNING.OVERHEAT_TEMP ~= nil and GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() > TUNING.OVERHEAT_TEMP then
						modifier = modifier * TUNING.PERISH_SUMMER_MULT
					end
							
				    modifier = modifier * TUNING.PERISH_GLOBAL_MULT
				
				    local str_DFV = ""
					if modifier ~= 0 then
					    local perishremainingtime = math.floor((inv_item.components.perishable.perishremainingtime / TUNING.TOTAL_DAY_TIME / modifier) * 10 + 0.5) / 10
					    
					    if perishremainingtime < 1 then
							str_DFV = STRINGS.DFV_SPOILSOON
					    elseif STRINGS.DFV_LANG ~= "RU" then
					    	str_DFV = STRINGS.DFV_SPOILIN .. " " .. perishremainingtime .. " " .. STRINGS.DFV_SPOILDAY
							if perishremainingtime >=2 then
								if STRINGS.DFV_LANG == "GR" or STRINGS.DFV_LANG == "NL" then
									str_DFV = str_DFV .. "en"
								elseif STRINGS.DFV_LANG == "IT" then
									str = str .. "i"						
								else
									str_DFV = str_DFV .. "s"
								end
							elseif perishremainingtime >= 1 and STRINGS.DFV_LANG == "IT" then
									str = str .. "o"											
							end						
					    else
							str_DFV = STRINGS.DFV_SPOILIN .. " " .. perishremainingtime .. " " .. STRINGS.DFV_SPOILDAY
							local plural_days = {"день", "дня", "дней"}
							local plural_type = function(n)
								if n%10==1 and n%100~=11 then
									return 1
								elseif n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) then
									return 2
								else
									return 3
								end
							end
							str_DFV = str_DFV .. plural_days[plural_type(math.modf(perishremainingtime))]
					    end
						local prep_foods = require("preparedfoods")
						if prep_foods[inv_item.prefab] ~= nil and prep_foods[inv_item.prefab].temperature ~= nil then
							str_DFV = str_DFV .. " / t "
							if prep_foods[inv_item.prefab].temperature < 0 then
								str_DFV = str_DFV .. "-"
							else
								str_DFV = str_DFV .. "+"
							end											
							str_DFV = str_DFV .. prep_foods[inv_item.prefab].temperatureduration
						elseif inv_item.prefab == "ice" then
							str_DFV = str_DFV .. " / t "
							if inv_item.components.edible.temperaturedelta < 0 then
								str_DFV = str_DFV .. "-"
							else
								str_DFV = str_DFV .. "+"
							end											
							str_DFV = str_DFV .. inv_item.components.edible.temperatureduration
						end
				    else
				    	str_DFV = str_DFV .. "\n"
						local prep_foods = require("preparedfoods")
						if prep_foods[inv_item.prefab] ~= nil and prep_foods[inv_item.prefab].temperatureduration ~= nil then
							str_DFV = str_DFV .. "t "
							if prep_foods[inv_item.prefab].temperature < 0 then
								str_DFV = str_DFV .. "-"
							else
								str_DFV = str_DFV .. "+"
							end											
							str_DFV = str_DFV .. prep_foods[inv_item.prefab].temperatureduration
						elseif inv_item.prefab == "ice" and inv_item.components.edible.temperatureduration ~= nil then
							str_DFV = str_DFV .. "t "
							if inv_item.components.edible.temperaturedelta < 0 then
								str_DFV = str_DFV .. "-"
							else
								str_DFV = str_DFV .. "+"
							end											
							str_DFV = str_DFV .. inv_item.components.edible.temperatureduration
						end
					end				    
					
					table.insert(str, str_DFV)					    
				end	
				
				local was_shown = self.actionstring.shown
			    local was_shown = self.actionstring.shown
			    local old_string = self.actionstringbody:GetString()
			    local new_string = table.concat(str, '\n')
			    if old_string ~= new_string then
				    self.actionstringbody:SetString(new_string)
				    self.actionstringtime = CURSOR_STRING_DELAY
				    self.actionstring:Show()
				end
		
				local w0, h0 = self.actionstringtitle:GetRegionSize()
				local w1, h1 = self.actionstringbody:GetRegionSize()
		
				local wmax = math.max(w0, w1)
		
				local dest_pos = self.active_slot:GetWorldPosition()
		
				local yscale = self.root:GetScale().y
				local xscale = self.root:GetScale().x
		
				if self.active_slot.side_align_tip then
					-- in-game containers, chests, fridge
					self.actionstringtitle:SetPosition(wmax/2, h0/2)
					self.actionstringbody:SetPosition(wmax/2, -h1/2)
		
					dest_pos = dest_pos + GLOBAL.Vector3(self.active_slot.side_align_tip * xscale, 0, 0)
				elseif self.active_slot.top_align_tip then
					-- main inventory
					self.actionstringtitle:SetPosition(0, h0/2 + h1)
					self.actionstringbody:SetPosition(0, h1/2)
		
					dest_pos = dest_pos + GLOBAL.Vector3(0, (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale, 0)
				else
					-- old default as fallback ?
					self.actionstringtitle:SetPosition(0, h0/2 + h1)
					self.actionstringbody:SetPosition(0, h1/2)
		
					dest_pos = dest_pos + GLOBAL.Vector3(0, (W/2 + TIP_YFUDGE) * yscale, 0)
				end
		
				if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
					self.actionstringtime = CURSOR_STRING_DELAY
					if was_shown then
						self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
					else
						self.actionstring:SetPosition(dest_pos)
						self.actionstring:Show()
					end
				end				
			end
		end
	end

end

local ItemTile = require "widgets/itemtile"
local ItemTile_GetDescriptionString_base = ItemTile.GetDescriptionString or function() return "" end

function ItemTile:GetDescriptionString()
	
	local str = ItemTile_GetDescriptionString_base(self)
	
    if self.item and self.item.components.inventoryitem then
		local realfood = nil
		show_spoil = TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
	
        if not active_item then
         
            local owner = self.item.components.inventoryitem and self.item.components.inventoryitem.owner
            local actionpicker = owner and owner.components.playeractionpicker or GetPlayer().components.playeractionpicker
            local inventory = owner and owner.components.inventory or GetPlayer().components.inventory
            if owner and inventory and actionpicker then
	
                local actions = nil
                if inventory:GetActiveItem() then
                    actions = actionpicker:GetUseItemActions(self.item, inventory:GetActiveItem(), true)
                end
                
                if not actions then
                    actions = actionpicker:GetInventoryActions(self.item)
                end
                
                if actions then
				    for k,v in pairs(actions) do
						if v.action == ACTIONS.EAT or v.action == ACTIONS.HEAL then
						    realfood = true
						    break
						end
				    end
                end
			end
        end
	
		if self.item.components.edible and realfood then
		    local hungervalue = 0
		    local healthvalue = 0
		    local sanityhvalue = 0
		    
		    local plr = GetPlayer()
		    if plr.components.eater and plr.components.eater.monsterimmune then--GetPlayer().prefab == "webber" then
				if self.item.components.edible.hungervalue < 0 and plr.components.eater:DoFoodEffects(self.item) or self.item.components.edible.hungervalue > 0 then
				    hungervalue = math.floor(self.item.components.edible:GetHunger(plr) * 10 + 0.5) / 10
				end
				if self.item.components.edible.healthvalue < 0 and plr.components.eater:DoFoodEffects(self.item) or self.item.components.edible.healthvalue > 0 then
				    healthvalue = math.floor(self.item.components.edible:GetHealth(plr) * 10 + 0.5) / 10
				end
				if self.item.components.edible.sanityvalue < 0 and plr.components.eater:DoFoodEffects(self.item) or self.item.components.edible.sanityvalue > 0 then
				    sanityhvalue = math.floor(self.item.components.edible:GetSanity(plr) * 10 + 0.5) / 10
				end
			else
				hungervalue = math.floor(self.item.components.edible:GetHunger(plr) * 10 + 0.5) / 10
				healthvalue = math.floor(self.item.components.edible:GetHealth(plr) * 10 + 0.5) / 10
				sanityhvalue = math.floor(self.item.components.edible:GetSanity(plr) * 10 + 0.5) / 10
			end
			
			if STRINGS.DFV_MIN then			
				if hungervalue ~= 0 or healthvalue ~= 0 or sanityhvalue ~= 0 then
					str = str .. "\n"
				end
						
			    if hungervalue ~= 0 then
					str = str .. "\153" .. " " .. hungervalue .. " "
			    end
			    if healthvalue ~= 0 then
					str = str .. "\151" .. " " .. healthvalue .. " "
			    end
			    if sanityhvalue ~= 0 then
					str = str .. "\152" .. " " .. sanityhvalue .. " "
			    end
			else
			    if hungervalue ~= 0 then
					str = str.."\n" .. STRINGS.DFV_HUNGER .. " " .. hungervalue
			    end
			    if healthvalue ~= 0 then
					str = str.."\n" .. STRINGS.DFV_HEALTH .. " " .. healthvalue
			    end
			    if sanityhvalue ~= 0 then
					str = str.."\n" .. STRINGS.DFV_SANITY .. " " .. sanityhvalue
			    end
			
			end
						
		elseif self.item.components.healer and realfood then
		    str = str.."\n" .. STRINGS.DFV_HEALTH .. " " .. self.item.components.healer.health
		end
	
		if self.item.components.perishable and realfood and show_spoil then
		    local owner = self.item.components.inventoryitem and self.item.components.inventoryitem.owner
		    local modifier = 1
		    
		    if owner then				    	
				if owner:HasTag("fridge") then
					if self.item:HasTag("frozen") then
						modifier = TUNING.PERISH_COLD_FROZEN_MULT
					else
						modifier = TUNING.PERISH_FRIDGE_MULT 
					end 
				elseif owner:HasTag("spoiler") then
					modifier = TUNING.PERISH_GROUND_MULT 
				end
			else
				modifier = TUNING.PERISH_GROUND_MULT 
			end						
				
			if GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() < 0 then
				if self.item:HasTag("frozen") and not self.item.components.perishable.frozenfiremult then
					modifier = TUNING.PERISH_COLD_FROZEN_MULT
				else
					modifier = modifier * TUNING.PERISH_WINTER_MULT
				end
			end
				
			if self.item.components.perishable.frozenfiremult then
				modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
			end
			
			if TUNING.OVERHEAT_TEMP ~= nil and GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() > TUNING.OVERHEAT_TEMP then
				modifier = modifier * TUNING.PERISH_SUMMER_MULT
			end
				
		    modifier = modifier * TUNING.PERISH_GLOBAL_MULT
			
			if modifier ~= 0 then
			    local perishremainingtime = math.floor((self.item.components.perishable.perishremainingtime / TUNING.TOTAL_DAY_TIME / modifier) * 10 + 0.5) / 10
			    if perishremainingtime < 1 then
					str = str.."\n" .. STRINGS.DFV_SPOILSOON
			    elseif STRINGS.DFV_LANG ~= "RU" then
					str = str.."\n" .. STRINGS.DFV_SPOILIN .. " " .. perishremainingtime .. " " .. STRINGS.DFV_SPOILDAY
			    else
					str = str.."\n" .. STRINGS.DFV_SPOILIN .. " " .. perishremainingtime .. " "
			    end
			    if STRINGS.DFV_LANG == "RU" then
					local plural_days = {"день", "дня", "дней"}
					local plural_type = function(n)
						if n%10==1 and n%100~=11 then
							return 1
						elseif n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) then
							return 2
						else
							return 3
						end
					end
					str = str .. plural_days[plural_type(math.modf(perishremainingtime))]
			    else
					if perishremainingtime >=2 then
						if STRINGS.DFV_LANG == "GR" or STRINGS.DFV_LANG == "NL" then
							str = str .. "en"
						elseif STRINGS.DFV_LANG == "IT" then
							str = str .. "i"						
						else
							str = str .. "s"
						end
					elseif perishremainingtime >= 1 and STRINGS.DFV_LANG == "IT" then
							str = str .. "o"											
					end
			    end
				local prep_foods = require("preparedfoods")
				if prep_foods[self.item.prefab] ~= nil and prep_foods[self.item.prefab].temperatureduration ~= nil then
					str = str .. " / t "
					if prep_foods[self.item.prefab].temperature < 0 then
						str = str .. "-"
					else
						str = str .. "+"
					end					
					str = str .. prep_foods[self.item.prefab].temperatureduration
				elseif self.item.prefab == "ice" and self.item.components.edible.temperatureduration ~= nil then
					str = str .. " / t "
					if self.item.components.edible.temperaturedelta < 0 then
						str = str .. "-"
					else
						str = str .. "+"
					end					
					str = str .. self.item.components.edible.temperatureduration
				end		    
			else
				str = str .. "\n"
				local prep_foods = require("preparedfoods")
				if prep_foods[self.item.prefab] ~= nil and prep_foods[self.item.prefab].temperatureduration ~= nil then
					str = str .. "t "
					if prep_foods[self.item.prefab].temperature < 0 then
						str = str .. "-"
					else
						str = str .. "+"
					end					
					str = str .. prep_foods[self.item.prefab].temperatureduration
				elseif self.item.prefab == "ice" and self.item.components.edible.temperatureduration ~= nil then
					str = str .. "t "
					if self.item.components.edible.temperaturedelta < 0 then
						str = str .. "-"
					else
						str = str .. "+"
					end					
					str = str .. self.item.components.edible.temperatureduration
				end		    
		    end		    
		end	
	end	
    
    return str or ""
end

local IsDLCEnabled = GLOBAL.IsDLCEnabled
local ItemTile_UpdateTooltip_base = ItemTile.UpdateTooltip or function() return "" end

function ItemTile:UpdateTooltip()

	local tmp = ItemTile_UpdateTooltip_base(self)
		
	if IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
	    if self:IsWet() then
	    	local WET_TEXT_COLOUR = GLOBAL.WET_TEXT_COLOUR
	        self:SetTooltipColour(WET_TEXT_COLOUR[1], WET_TEXT_COLOUR[2], WET_TEXT_COLOUR[3], WET_TEXT_COLOUR[4])
	    else
	    	local NORMAL_TEXT_COLOUR = GLOBAL.NORMAL_TEXT_COLOUR
	        self:SetTooltipColour(NORMAL_TEXT_COLOUR[1], NORMAL_TEXT_COLOUR[2], NORMAL_TEXT_COLOUR[3], NORMAL_TEXT_COLOUR[4])
	    end
	end
	
end

--local ItemTile_OnControl_base = ItemTile.OnControl or function() return "" end
--
--function ItemTile:OnControl(control, down)
--
--	local tmp = ItemTile_OnControl_base(self, control, down)
--
--	return false
--end