require "class"
require "util"

local easing = require "easing"

local trace = function() end

--Making the START_DRAG_TIME stupidly large is the easiest way to (effectively) disable it
local START_DRAG_TIME = (1/120)*8
--local START_DRAG_TIME = 9999999


local PlayerController = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
	self.canmove = true
    
    self.handler = TheInput:AddGeneralControlHandler(function(control, value) self:OnControl(control, value) end)
    self.inst:StartUpdatingComponent(self)
    self.draggingonground = false
    self.startdragtestpos = nil
    self.startdragtime = nil

	self.inst:ListenForEvent("buildstructure", function(inst, data) self:OnBuild() end, GetPlayer())

    self.LMBaction = nil
    self.RMBaction = nil

    self.mousetimeout = 10
	--TheInput:AddMoveHandler(function(x,y) self.using_mouse = true self.mousetimeout = 3 end)

	self.pitchoffset = 0

	self.normalcam = true
	self.transitioning = false
	self.transitionduration = 0.3
	self.timetransitioning = self.transitionduration -- we start out "there"
	self.startingpitch = 0.7
	self.locked_pitchoffset = 0
	self.turn_nudge = 0

	local screenwidth, screenheight = TheSim:GetWindowSize()

	-- lets get things started off on the right ... pixel
	self.screen_y = screenheight/2
	self.prevpt = Vector3(screenwidth/2, screenheight/2, 0)
	TheInputProxy:SetOSCursorPos(self.prevpt.x, self.prevpt.y)

	self.inst:ListenForEvent("sawshambler", function(inst, angle) 
		print("PC> saw a shambler")
		self.normalcam = false
		self.transitioning = true
		self.timetransitioning = 0
		self.turn_nudge = angle*TUNING.HORIZ_SNAP_FORCE_FOR_CAM
		self.inst.seeingshambler = true
		
		--jcheng: last minute hack to make sure we don't break the game on the player
		-- after a while, if we don't see another shambler, then just reset the bools
		if self.resetseeingtask then
			self.resetseeingtask:Cancel()
			self.resetseeingtask = nil
		end

		self.resetseeingtask = self.inst:DoTaskInTime(3, function()
			print("HIT THE HACK FOR RESETTING SEEING")
			self.resetseeingtask:Cancel()
			self.resetseeingtask = nil
			self.inst.seeingshambler = false
			self.inst.HUD.shamblerblockmap = false
		end)

		self.inst:ClearBufferedAction()
		self.inst.components.locomotor:SetBufferedAction(nil)
		self.controller_target = nil
	end, GetPlayer())
	self.inst:ListenForEvent("seeingshambler", function(inst, ratio)
		self.locked_pitchoffset = ratio
		self.inst:ClearBufferedAction()
		self.inst.components.locomotor:SetBufferedAction(nil)
		self.controller_target = nil
	end, GetPlayer())
	self.inst:ListenForEvent("unsawshambler", function(inst) 
		print("PC> unsaw a shambler")
		if self.inst.seeingshambler then
			self.screen_y = self.locked_pitchoffset * screenheight
			self.normalcam = true
			self.transitioning = true
			self.timetransitioning = 0
			self.inst.seeingshambler = false
		end
	end, GetPlayer())
	self.inst:ListenForEvent("searchingcontainer", function() 
		self.startingpitch = self.screen_y
		TheCamera:SetControllable(false)
		TheCamera:SetDistance(TUNING.ZOOMED_CAM_DISTANCE)
		self.normalcam = false
		self.transitioning = true
		self.timetransitioning = 0
		self.locked_pitchoffset = 0
		self.canmove = false
	end, GetPlayer())
	self.inst:ListenForEvent("finishedsearchingcontainer", function() 
		self.screen_y = self.startingpitch
		self.normalcam = true
		self.transitioning = true
		self.timetransitioning = 0
		self.locked_pitchoffset = 0
		TheCamera:SetDistance(TUNING.DEFAULT_CAM_DISTANCE)
		self.canmove = true
	end, GetPlayer())
	self.inst:ListenForEvent("playermoving", function() 
		if not self.normalcam then
			self.normalcam = true
			self.transitioning = true
			self.timetransitioning = 0
			TheCamera:SetDistance(TUNING.DEFAULT_CAM_DISTANCE)
			self.canmove = true
		end
	end, GetPlayer())
end)

function PlayerController:OnBuild()
	self:CancelPlacement()
end

function PlayerController:IsEnabled()
	return self.enabled and self.inst.HUD
		and not self.inst.components.health:IsDead()
		and not self.inst.HUD:IsControllerCraftingOpen() 
		and not self.inst.HUD:IsControllerInventoryOpen()
		and not self.inst.HUD:IsNoteShowing()
end

function PlayerController:OnControl(control, down)

	if not self:IsEnabled() then return end
	if not IsPaused() then

		if control == CONTROL_PRIMARY then
			if down then
				self:DoActionButton() -- Fake using the space bar
			end
			--self:OnLeftClick(down)
			return 
		elseif control == CONTROL_SECONDARY then
			self:OnRightClick(down)
			return 
		end
		
		if down then
			if self.placer_recipe and control == CONTROL_CANCEL then
				self:CancelPlacement()
			else
				if control == CONTROL_INSPECT then
					self:DoInspectButton()
				elseif control == CONTROL_ACTION then
					self:DoActionButton()  -- THIS one happens when spacebar is pressed.
				elseif control == CONTROL_ATTACK then
					self:DoAttackButton()
				elseif control == CONTROL_CONTROLLER_ALTACTION then
					self:DoControllerAltAction()
				elseif control == CONTROL_CONTROLLER_ACTION then
					self:DoControllerAction()
				elseif control == CONTROL_CONTROLLER_ATTACK then
					self:DoControllerAttack()
				end
				
				local inv_obj = self:GetCursorInventoryObject()
				
				if inv_obj then
					local is_equipped = (inv_obj.components.equippable and inv_obj.components.equippable:IsEquipped())
					if control == CONTROL_INVENTORY_DROP then
						self.inst.components.inventory:DropItem(inv_obj)
					elseif control == CONTROL_INVENTORY_EXAMINE then
						self.inst.components.locomotor:PushAction( BufferedAction(self.inst, inv_obj, ACTIONS.LOOKAT))
					elseif control == CONTROL_INVENTORY_USEONSELF and not is_equipped then
						self.inst.components.locomotor:PushAction(self:GetItemSelfAction(inv_obj), true)
					elseif control == CONTROL_INVENTORY_USEONSCENE and not is_equipped then
						if inv_obj.components.inventoryitem:GetGrandOwner() ~= self.inst then
							self.inst.components.inventory:GiveItem(inv_obj)
						else
							self.inst.components.locomotor:PushAction(self:GetItemUseAction(inv_obj), true)									
						end
					end
				end
			end
		end
	end
end

function PlayerController:GetCursorInventoryObject()
	if self.inst.HUD and self.inst.HUD.controls and self.inst.HUD.controls.inv  then
		return self.inst.HUD.controls.inv:GetCursorItem()
	end
end

function PlayerController:DoControllerAction()

	if self.placer then
		if self.placer.components.placer.can_build then
			self.inst.components.builder:MakeRecipe(self.placer_recipe, Vector3(self.placer.Transform:GetWorldPosition()))
			return true
		end
	elseif self.deployplacer then
		if self.deployplacer.components.placer.can_build then
			local act = self.deployplacer.components.placer:GetDeployAction()
			act.distance = 1
			self:DoAction(act)
		end
	elseif self.controller_target then
		print("doing action", self:GetSceneItemControllerAction(self.controller_target) )
		self:DoAction( self:GetSceneItemControllerAction(self.controller_target) )
	end
end

function PlayerController:DoControllerAltAction()
	if self.deployplacer then
		return
	end
	
	local l, r = self:GetGroundUseAction()
	if r then
		self:DoAction(r)
		return
	end
	
	if self.controller_target then
		local l, r = self:GetSceneItemControllerAction(self.controller_target)
		self:DoAction( r )
	end
end


function PlayerController:DoControllerAttack()
	local attack_target = self.controller_attack_target
	
	if attack_target and self.inst.components.combat.target ~= attack_target then
		local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
		self.inst.components.locomotor:PushAction(action, true)
	elseif not attack_target and not self.inst.components.combat.target then
		local action = BufferedAction(self.inst, nil, ACTIONS.FORCEATTACK)
		self.inst.components.locomotor:PushAction(action, true)
	else
		return -- already doing it!
	end
end


function PlayerController:RotLeft()
	-- local rotamount = 45 ---90-- GetWorld():IsCave() and 22.5 or 45
	-- if TheCamera:CanControl() then  
		
	-- 	if IsPaused() then
	-- 		if GetWorld().minimap.MiniMap:IsVisible() then
	-- 			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
	-- 			TheCamera:Snap()
	-- 		end
	-- 	else
	-- 		TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
	-- 		--UpdateCameraHeadings() 
	-- 	end
	-- end
end

function PlayerController:RotRight()
	-- local rotamount = 45 --90--GetWorld():IsCave() and 22.5 or 45
	-- if TheCamera:CanControl() then  
		
	-- 	if IsPaused() then
	-- 		if GetWorld().minimap.MiniMap:IsVisible() then
	-- 			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
	-- 			TheCamera:Snap()
	-- 		end
	-- 	else
	-- 		TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
	-- 		--UpdateCameraHeadings() 
	-- 	end
	-- end
end

function PlayerController:OnRemoveEntity()
    self.handler:Remove()
end

function PlayerController:GetHoverTextOverride()
	if self.placer_recipe then
		return STRINGS.UI.HUD.BUILD.. " " .. ( STRINGS.NAMES[string.upper(self.placer_recipe.name)] or STRINGS.UI.HUD.HERE )
	end
end

function PlayerController:CancelPlacement()
	if self.placer then
		self.placer:Remove()
		self.placer = nil
	end
	self.placer_recipe = nil
end



function PlayerController:StartBuildPlacementMode(recipe, testfn)
	self.placer_recipe = recipe
	if self.placer then
		self.placer:Remove()
		self.placer = nil
	end
	self.placer = SpawnPrefab(recipe.placer)
	self.placer.components.placer:SetBuilder(self.inst, recipe)
	self.placer.components.placer.testfn = testfn
end


function PlayerController:Enable(val)
    self.enabled = val
end


function PlayerController:GetAttackTarget(force_attack)

	local x,y,z = self.inst.Transform:GetWorldPosition()
	
	local rad = self.inst.components.combat:GetAttackRange()
	
	
	if not self.directwalking then rad = rad + 6 end --for autowalking
	
	--To deal with entity collision boxes we need to pad the radius.
	local nearby_ents = TheSim:FindEntities(x,y,z, rad + 5)
	local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local has_weapon = tool and tool.components.weapon 
	
	local playerRad = self.inst.Physics:GetRadius()
	
	for k,guy in ipairs(nearby_ents) do

		if guy ~= self.inst and
		   guy:IsValid() and 
		   not guy:IsInLimbo() and
		   not (guy.sg and guy.sg:HasStateTag("invisible")) and
		   guy.components.health and not guy.components.health:IsDead() and 
		   guy.components.combat and guy.components.combat:CanBeAttacked(self.inst) and
		   not (guy.components.follower and guy.components.follower.leader == self.inst) and
		   --Now we ensure the target is in range.
		   distsq(guy:GetPosition(), self.inst:GetPosition()) <= math.pow(rad + playerRad + guy.Physics:GetRadius() + 0.1 , 2) then
				if (guy:HasTag("monster") and has_weapon) or
					guy:HasTag("hostile") or
					self.inst.components.combat:IsRecentTarget(guy) or
					guy.components.combat.target == self.inst or
					force_attack then
						return guy
				end
		end
	end

end

--

function PlayerController:DoAttackButton()
	local attack_target = self:GetAttackTarget(TheInput:IsControlPressed(CONTROL_FORCE_ATTACK)) 			
	if attack_target and self.inst.components.combat.target ~= attack_target then
		local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
		self.inst.components.locomotor:PushAction(action, true)
	else
		return -- already doing it!
	end
	
	
end

function PlayerController:GetActionButtonAction()
	if self.actionbuttonoverride then
		return self.actionbuttonoverride(self.inst)
	end

	if self:IsEnabled() and not (self.inst.sg:HasStateTag("working") or self.inst.sg:HasStateTag("doing")) then

		local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--gjans: make this use the controller target instead of figuring out a new target
		local pickup = self.controller_target
--[[
		--bug catching (has to go before combat)
		if tool and tool.components.tool and tool.components.tool:CanDoAction(ACTIONS.NET) then
			local target = FindEntity(self.inst, 5, 
				function(guy) 
					return  guy.components.health and not guy.components.health:IsDead() and 
							guy.components.workable and
							guy.components.workable.action == ACTIONS.NET
				end)
			if target then
			    return BufferedAction(self.inst, target, ACTIONS.NET, tool)
			end
		end
			
		
		--catching
		local rad = 8
		local projectile = FindEntity(self.inst, rad, function(guy)
		    return guy.components.projectile
		           and guy.components.projectile:IsThrown()
		           and self.inst.components.catcher
		           and self.inst.components.catcher:CanCatch()
		end)
		if projectile then
			return BufferedAction(self.inst, projectile, ACTIONS.CATCH)
		end
		
		rad = TUNING.BEGIN_INTERACTION_RADIUS
		--pickup
		local pickup = FindEntity(self.inst, rad, function(guy) return guy:HasTag("CLICK") and 
																	(   (guy.components.inventoryitem and guy.components.inventoryitem.canbepickedup) or
																		(tool and tool.components.tool and guy.components.workable and tool.components.tool:CanDoAction(guy.components.workable.action)) or
																		(guy.components.pickable and guy.components.pickable:CanBePicked() and guy.components.pickable.caninteractwith) or
																		(guy.components.crop and guy.components.crop:IsReadyForHarvest()) or
																		(guy.components.harvestable and guy.components.harvestable:CanBeHarvested()) or
																		(guy.components.trap and guy.components.trap.issprung) or
																		(guy.components.stewer and guy.components.stewer.done) or
																		(guy.components.activatable and guy.components.activatable.inactive) or
																		(guy.components.inspectable)
																	)
																		 end)
]]
		local has_active_item = self.inst.components.inventory:GetActiveItem() ~= nil
		if pickup and not has_active_item then
			local action = nil
			
			if (tool and tool.components.tool and pickup.components.workable and tool.components.tool:CanDoAction(pickup.components.workable.action)) then
				action = pickup.components.workable.action
			elseif pickup.components.trap and pickup.components.trap.issprung then
				action = ACTIONS.CHECKTRAP
			elseif pickup.components.activatable and pickup.components.activatable.inactive then
				action = ACTIONS.ACTIVATE
			elseif pickup.components.inventoryitem and pickup.components.inventoryitem.canbepickedup then 
				action = ACTIONS.PICKUP 
			elseif pickup.components.pickable and pickup.components.pickable:CanBePicked() then 
				action = ACTIONS.PICK 
			elseif pickup.components.harvestable and pickup.components.harvestable:CanBeHarvested() then
				action = ACTIONS.HARVEST
			elseif pickup.components.inspectable then
				action = ACTIONS.LOOKAT
			end
			
			if action then
			    local ba = BufferedAction(self.inst, pickup, action, tool)
			    --ba.distance = self.directwalking and rad or 1
			    return ba
			end
		end
	end	
end


function PlayerController:DoActionButton()
	--do the placement
	if self.placer then
		if self.placer.components.placer.can_build then
			self.inst.components.builder:MakeRecipe(self.placer_recipe, Vector3(self.placer.Transform:GetWorldPosition()))
			return true
		end
	else
		local ba = self:GetActionButtonAction()
		if ba then
			local x, y, z = ba.target.Transform:GetWorldPosition()
			local dark_okay_dist_sq = TUNING.SCARY_MOD_INTERACT_ALWAYS_RADIUS * TUNING.SCARY_MOD_INTERACT_ALWAYS_RADIUS
			if self:IsEnabled() and not self.inst.seeingshambler then
				if (ba.target:HasTag("CLICK") and TheSim:GetLightAtPoint(x, y, z) > TUNING.SCARY_MOD_DARKNESS_CUTOFF) 
					or (ba.target:HasTag("CLICK") and distsq(Vector3(x,y,z), GetPlayer():GetPosition()) < dark_okay_dist_sq) then
					self.inst.components.locomotor:PushAction(ba, true)
				end
			end
		end
		return true
	end
end

function PlayerController:DoInspectButton()
	if self.controller_target then
		self.inst.components.locomotor:PushAction( BufferedAction(self.inst, self.controller_target, ACTIONS.LOOKAT))
	end
	return true
end


function PlayerController:UsingMouse()
	if TheInput:ControllerAttached() then
		return false
	else
		return true
	end
end

--jcheng: do you want to see the cursor?
local DEBUG_CONTROLLER = false

function PlayerController:CancelDeltas()
	local screenwidth, screenheight = TheSim:GetWindowSize()
	self.prevpt = Vector3(screenwidth/2, screenheight/2, 0)
	TheInputProxy:SetOSCursorPos(self.prevpt.x, self.prevpt.y)
end

function PlayerController:OnUpdate(dt)

	if TheSim:HasWindowFocus() == false or IsPaused() == true then
		TheInputProxy:SetCursorVisible(true)
		return
	end

	if GetPlayer().components.health and GetPlayer().components.health:IsDead() then
		return
	end

	TheInputProxy:SetCursorVisible(DEBUG_CONTROLLER)
	local screenwidth, screenheight = TheSim:GetWindowSize()

	--print("PAUSED?", IsPaused())
	local controller_mode = TheInput:ControllerAttached()

	if self:IsEnabled() then    
	    local new_highlight = nil
		-- SCARY_MOD: We want to use controller behaviour for choosing action targets
	   	self:UpdateControllerInteractionTarget(dt)
	   	new_highlight = self.controller_target
	   	self.LMBaction, self.RMBaction = self.inst.components.playeractionpicker:DoGetMouseActions()

		if new_highlight and not new_highlight.components.highlight then
			new_highlight = nil
		end

	    if new_highlight ~= self.highlight_guy then
	    	if self.highlight_guy and self.highlight_guy:IsValid() then
	    		self.highlight_guy.components.highlight:UnHighlight()
	    	end
	    	self.highlight_guy = new_highlight
	    end

	    if self.attack_highlight ~= self.controller_attack_target then
	    	
	    	if self.attack_highlight then
				self.attack_highlight.components.highlight:UnHighlight()
	    	end

	    	self.attack_highlight = self.controller_attack_target
	    end

		if self.highlight_guy and self.highlight_guy:IsValid() then
			self.highlight_guy.components.highlight:Highlight()
		else
			self.highlight_guy = nil
		end

	    if self.attack_highlight and self.attack_highlight:IsValid() then
			self.attack_highlight.components.highlight:Highlight(1,0,0)
	    else
			self.attack_highlight = nil
	    end
	end

	self:DoCameraControl()    

	local active_item = self.inst.components.inventory:GetActiveItem()
	
	
	local terraform = false
	if controller_mode then
		local l, r = self:GetGroundUseAction()
		terraform = r and r.action == ACTIONS.TERRAFORM and r
	else
		local action_r = self:GetRightMouseAction()	
		terraform = action_r and action_r.action == ACTIONS.TERRAFORM and action_r
	end
		
	local placer_item = nil
	if controller_mode then
		placer_item = self:GetCursorInventoryObject()
	else
		placer_item = active_item
	end
	
	local show_deploy_placer = placer_item and placer_item.components.deployable and self.placer == nil
	
	if show_deploy_placer then
		local placer_name = placer_item.components.deployable.placer or ((placer_item.prefab or "") .. "_placer")
		if self.deployplacer and self.deployplacer.prefab ~= placer_name then
			self.deployplacer:Remove()
			self.deployplacer = nil
		end
		
		if not self.deployplacer then
			self.deployplacer = SpawnPrefab(placer_name)
			if self.deployplacer then
				self.deployplacer.components.placer:SetBuilder(self.inst, nil, placer_item)
				
				self.deployplacer.components.placer.testfn = function(pt) 
					return placer_item.components.deployable:CanDeploy(pt)
				end
				
				self.deployplacer.components.placer:OnUpdate(0)  --so that our position is accurate on the first frame
			end
		end
	else
		if self.deployplacer then
			self.deployplacer:Remove()
			self.deployplacer = nil
		end
	end

    if self.startdragtime and not self.draggingonground then
        local now = GetTime()
        if now - self.startdragtime > START_DRAG_TIME then
			TheFrontEnd:LockFocus(true)
            self.draggingonground = true
        end
    end

	if self.draggingonground and TheFrontEnd:GetFocusWidget() ~= self.inst.HUD then
		TheFrontEnd:LockFocus(false)
		self.draggingonground = false
		
		self.inst.components.locomotor:Stop()
	end
	--jcheng: FPS controls

	-- GetOSCursorPos() returns the current hardware cursor position, not the buffered input position
	-- values clipped to game window
	-- returns nil if the game doesn't have focus
	local os_x, os_y = TheInputProxy:GetOSCursorPos() 
	--print("TheInputProxy:GetOSCursorPos()", os_x, os_y)
	os_x = os_x or self.prevpt.x
	os_y = os_y or self.prevpt.y

	local pt = Vector3(os_x, os_y, 0)

	if not self.prevpt then
		self.prevpt = pt
	end

	local diff = pt - self.prevpt
	if not self:IsEnabled() then
		diff = Vector3(0,0,0)
	end
	--jcheng: this is for mouse acceleration if we want it
	--INTERSECT = 30 
	--LINEARITY = 40
	--diff.x = (1/(INTERSECT + LINEARITY))*diff.x*(math.abs(diff.x)+LINEARITY)

	self.screen_y = math.clamp(self.screen_y + diff.y, 0, screenheight)

	self.prevpt = pt

	local dx = pt.x/screenwidth
	local dy = pt.y/screenheight
	if dx < 0.2 or dx > 0.8 or dy < 0.2 or dy > 0.8 then
		self.prevpt = Vector3(screenwidth/2, screenheight/2, 0)
		TheInputProxy:SetOSCursorPos(self.prevpt.x, self.prevpt.y)
		--print("warp to", self.prevpt.x, self.prevpt.y)
	end

	local rotateby = diff.x*360*TUNING.MOUSE_SENSITIVITY / (screenwidth/2)

	--[[
	if diff.x ~= 0 then
	 	print( "diff.x: "..diff.x)
	end

	if diff.y ~= 0 then
	 	print( "diff.y: "..diff.y)
	end
	]]

	-- Fancy camera stuff for when interacting with a container or camper
	if self.transitioning then
		self.timetransitioning = self.timetransitioning + dt 
        if self.timetransitioning >= self.transitionduration then --Check if the transition is over
			self.timetransitioning = self.transitionduration
        	self.transitioning = false
			if self.normalcam then
				TheCamera:SetControllable(true)
			end
        end
	end

	local ratio = 0
	local normal_pitchoffset = self.screen_y/screenheight + TUNING.PITCH_ADDITIONAL_OFFSET
	if self.normalcam then
		-- animate up when transitioning to normal
		ratio = self.timetransitioning / self.transitionduration
	else
		-- animate down when transitioning to down
		ratio = 1 - (self.timetransitioning / self.transitionduration)
	end

	self.pitchoffset = Lerp(self.locked_pitchoffset, normal_pitchoffset, ratio)

    self.inst:PushEvent("camerapitch", {pitch=self.pitchoffset})

    --print("pitchoffset: "..self.pitchoffset.." normalcam: "..tostring(self.normalcam).." transitioning: "..tostring(self.transitioning))
	TheCamera:SetPitchPercent(self.pitchoffset)

	if self.canmove then
		local angle = self.inst.Transform:GetRotation() + rotateby
		angle = angle + self.turn_nudge
		self.turn_nudge = self.turn_nudge * 0.5
		self.inst.Transform:SetRotation(angle)
		local player = GetPlayer()

		local speedmult = 1
		if player.indarkness then
			speedmult = 0.3
		end

		if self:WalkButtonDown() then
			if not TheInput:IsKeyDown(KEY_SHIFT) then
				self.inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*speedmult
			else
				self.inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.2*speedmult
				self.inst:PushEvent("change_breathing", {intensity=2, duration=3})
			end
			self.inst.components.locomotor:RunInDirection(angle)
		elseif self:WalkBackwardDown() and player and not player.sg:HasStateTag("busy") then

			self.inst.components.locomotor.walkspeed = -TUNING.WILSON_WALK_SPEED*0.7
			self.inst.components.locomotor:WalkInDirection(angle)
				
		--elseif self:AboutFaceButtonDown() then
		--	self:DoAboutFace()
		elseif GetPlayer().components.locomotor.bufferedaction == nil then
			self.inst.components.locomotor:Stop()
			self.directwalking = false
		end	
	end


end

--CAM HACK
function PlayerController:GetShouldMoveFromController()
	local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
	local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	local deadzone = .3

	if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
		return true
	end
	return false
end

function PlayerController:GetWorldControllerVector()
	local xdir = TUNING.XDIR_CONTROLLER_VECTOR_MOD * (TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT))
	local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	local deadzone = .3

	if math.abs(xdir) < deadzone and math.abs(ydir) < deadzone then xdir = 0 ydir = 0 end
	if xdir ~= 0 or ydir ~= 0 then
	    local CameraRight = TheCamera:GetRightVec()
		local CameraDown = TheCamera:GetDownVec()
		local dir = CameraRight * xdir - CameraDown * ydir
		dir = dir:GetNormalized()
		return dir
	end

	--CAM HACK
	-- local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
	-- local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	-- local deadzone = .3

	-- if math.abs(xdir) < deadzone and math.abs(ydir) < deadzone then xdir = 0 ydir = 0 end
	-- if xdir ~= 0 or ydir ~= 0 then
	--     local CameraRight = TheCamera:GetRightVec()
	-- 	local CameraDown = TheCamera:GetDownVec()
	-- 	local dir = CameraRight * xdir - CameraDown * ydir
	-- 	dir = dir:GetNormalized()
	-- 	return dir
	-- end
end


function PlayerController:CanAttackWithController(target)
	return target ~= self.inst and
			target:IsValid() and 
			not target:IsInLimbo() and
			not (target.sg and target.sg:HasStateTag("invisible")) and
			target.components.health and not target.components.health:IsDead() and 
			target.components.combat and target.components.combat:CanBeAttacked(self.inst)
end

function PlayerController:UpdateControllerAttackTarget(dt)
	if self.controllerattacktargetage then
		self.controllerattacktargetage = self.controllerattacktargetage + dt
	end
	
	if self.controller_attack_target and self.controllerattacktargetage and self.controllerattacktargetage < .3 then return end

	local heading_angle = -(self.inst.Transform:GetRotation())
	local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
	
	local me_pos = Vector3(self.inst.Transform:GetWorldPosition())
	local rad = 8
	local x,y,z = me_pos:Get()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad)

	local target = nil
	local target_score = nil
	local target_action = nil

	local min_rad = 4

	for k,v in pairs(nearby_ents) do
	
		local canattack = self:CanAttackWithController(v)

		if canattack then

			local pos = Vector3(v.Transform:GetWorldPosition())
			local offset = pos - me_pos
			local norm = offset:GetNormalized()
			local dot = norm:Dot(dir)
			local dsq = offset:LengthSq()
			
			if dsq < min_rad*min_rad or dot > 0 then
				local score = dot* (1 / math.max(1, dsq))
				if not target or target_score < score then
					target = v
					target_score = score
				end
			end
		end
	end

	if not target and self.controller_attack_target and self:CanAttackWithController(self.controller_attack_target) then
		target = self.controller_attack_target
	end

	if target ~= self.controller_attack_target then
		self.controller_attack_target = target
		self.controllerattacktargetage = 0
	end

end

function PlayerController:UpdateControllerInteractionTarget(dt)

	if self.placer or self.deployplacer then
		self.controller_target = nil
		self.controllertargetage = 0
		return
	end

	if self.controllertargetage then
		self.controllertargetage = self.controllertargetage + dt
	end

	if self.controllertargetage and self.controllertargetage < .2 then return end

	local heading_angle = -(self.inst.Transform:GetRotation())
	local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
	
	local me_pos = Vector3(self.inst.Transform:GetWorldPosition())
	local rad = TUNING.BEGIN_INTERACTION_RADIUS
	local x,y,z = me_pos:Get()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad)

	local target = nil
	local target_score = nil
	local target_action = nil

	local min_rad = 1.5

	for k,v in pairs(nearby_ents) do

		if v then
			local x, y, z = v.Transform:GetWorldPosition()		
			local dark_okay_dist_sq = TUNING.SCARY_MOD_INTERACT_ALWAYS_RADIUS * TUNING.SCARY_MOD_INTERACT_ALWAYS_RADIUS
			if self:IsEnabled() and not self.inst.seeingshambler then
				if (v ~= self.inst and not v:HasTag("FX") and v:HasTag("CLICK") and not v:IsInLimbo() and TheSim:GetLightAtPoint(x, y, z) > TUNING.SCARY_MOD_DARKNESS_CUTOFF) 
					or (v:HasTag("CLICK") and distsq(Vector3(x,y,z), GetPlayer():GetPosition()) < dark_okay_dist_sq) then

				
					local pos = Vector3(v.Transform:GetWorldPosition())
					local offset = pos - me_pos
					local norm = offset:GetNormalized()
					local dot = norm:Dot(dir)
					local dsq = offset:LengthSq()
					local action = self:GetSceneItemControllerAction(v)
					--if dsq < min_rad*min_rad or dot > 0.4 then
					if dot > 0.4 then
						local score = dot* (1 / math.max(1, dsq))
						if not target or (action and not target_action) or ( action and (target_score < score) ) then
							target = v
							target_score = score
							target_action = action
						end
					end
				end
			end
		end
	end

	if target ~= self.controller_target then

		self.controller_target = target
		self.controllertargetage = 0
	end
end

function PlayerController:DoAboutFace()
	local dir = self:GetWorldControllerVector()
	local time = GetTime()
	if not self.lastaboutfacetime or time - self.lastaboutfacetime > TUNING.ABOUT_FACE_REPEAT_TIME then
		local ang = -math.atan2(dir.z, dir.x)/DEGREES
		self.lastaboutfacetime = time
		self.inst:ClearBufferedAction()
		self.inst.components.locomotor:SetBufferedAction(nil)
		self.inst.components.locomotor:RunInDirection(ang)
		self.inst.components.locomotor:Stop()
		--self.directwalking = false
	end
end

function PlayerController:DoDirectWalking()
	local dir = self:GetWorldControllerVector()
	if self:GetShouldMoveFromController() then
		local player = GetPlayer()
		local facing = player.Transform:GetRotation()
		if dir then
			local ang = -math.atan2(dir.z, dir.x)/DEGREES
			self.inst:ClearBufferedAction()
			self.inst.components.locomotor:SetBufferedAction(nil)
			self.inst.components.locomotor:RunInDirection(ang)
			self.directwalking = true
		else
			self.inst.components.locomotor:Stop()
			local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
			local deadzone = .3
			if math.abs(xdir) >= deadzone then
				player.Transform:SetRotation(facing + (xdir * TUNING.XDIR_TURN_IN_PLACE_MOD))
			end
		end
	else
		if self.directwalking then
			self.inst.components.locomotor:Stop()
			self.directwalking = false
		end
	end
	--CAM HACK
	-- local dir = self:GetWorldControllerVector()
	-- if dir then
	-- 	local ang = -math.atan2(dir.z, dir.x)/DEGREES
		
	-- 	self.inst:ClearBufferedAction()
	-- 	self.inst.components.locomotor:SetBufferedAction(nil)
	-- 	self.inst.components.locomotor:RunInDirection(ang)
	-- 	self.directwalking = true
		
	-- 	--if not self.inst.sg:HasStateTag("attack") then
	-- 		--self.inst.components.combat:SetTarget(nil)
	-- 	--end
	-- else
	-- 	if self.directwalking then
	-- 		self.inst.components.locomotor:Stop()
	-- 		self.directwalking = false
	-- 	end
	-- end
end

function PlayerController:WalkButtonDown()
	-- local walkbutton = false
	-- local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
	-- local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	-- if math.abs(xdir) > 0.3 or math.abs(ydir) > 0.3 then
	-- 	walkbutton = true
	-- end
	-- return walkbutton
	--CAM HACK
	-- COMMENT OUT NON-FORWARD BUTTONS FOR CONTROLS
	return TheInput:IsControlPressed(CONTROL_MOVE_UP) --or TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
end

function PlayerController:AboutFaceButtonDown()
	return TheInput:IsControlPressed(CONTROL_MOVE_DOWN)
end

function PlayerController:WalkBackwardDown()
	return TheInput:IsControlPressed(CONTROL_MOVE_DOWN)
end

function PlayerController:DoCameraControl()
	--camera controls
	local time = GetTime()

	local ROT_REPEAT = .25
	local ZOOM_REPEAT = .1

	if TheCamera:CanControl() then
		
		if not self.lastrottime or time - self.lastrottime > ROT_REPEAT then
			
			if TheInput:IsControlPressed(CONTROL_ROTATE_LEFT) then
				self:RotLeft()
				self.lastrottime = time
			elseif TheInput:IsControlPressed(CONTROL_ROTATE_RIGHT) then
				self:RotRight()
				self.lastrottime = time
			end
		end

		if not self.lastzoomtime or time - self.lastzoomtime > ZOOM_REPEAT then
			if TheInput:IsControlPressed(CONTROL_ZOOM_IN) then
				TheCamera:ZoomIn()
				self.lastzoomtime = time
			elseif TheInput:IsControlPressed(CONTROL_ZOOM_OUT) then
				TheCamera:ZoomOut()
				self.lastzoomtime = time
			end
		end
	end

end


function PlayerController:OnLeftUp()
    
    if not self:IsEnabled() then return end    

	if self.draggingonground then
		
		if not self:WalkButtonDown() then
			self.inst.components.locomotor:Stop()
		end
		self.draggingonground = false
		TheFrontEnd:LockFocus(false)
	end
	self.startdragtime = nil
	
end



function PlayerController:DoAction(buffaction)
    if buffaction then
    
        if self.inst.bufferedaction then
            if self.inst.bufferedaction.action == buffaction.action and self.inst.bufferedaction.target == buffaction.target then
                return;
            end
        end
        
        if buffaction.target and buffaction.target.components.highlight then
            buffaction.target.components.highlight:Flash(.2, .125, .1)
        end
		
        if  buffaction.invobject and 
            buffaction.invobject.components.equippable and 
            buffaction.invobject.components.equippable.equipslot == EQUIPSLOTS.HANDS and 
            (buffaction.action ~= ACTIONS.DROP and buffaction.action ~= ACTIONS.STORE) then
            
                if not buffaction.invobject.components.equippable.isequipped then 
                    self.inst.components.inventory:Equip(buffaction.invobject)
                end
                
                if self.inst.components.inventory:GetActiveItem() == buffaction.invobject then
                    self.inst.components.inventory:SetActiveItem(nil)
                end
        end
        
        self.inst.components.locomotor:PushAction(buffaction, true)
    end    

end


function PlayerController:OnLeftClick(down)
    
    if not self:UsingMouse() then return end
    
	if not down then return self:OnLeftUp() end

    self.startdragtime = nil

    if not self:IsEnabled() then return end
    
    if TheInput:GetHUDEntityUnderMouse() then 
		self:CancelPlacement()
		return 
    end

	if self.placer_recipe then
		--do the placement
		if self.placer.components.placer.can_build then
			self.inst.components.builder:MakeRecipe(self.placer_recipe, TheInput:GetWorldPosition())
			self:CancelPlacement()
		end
		return
	end
    
    
    self.inst.components.combat.target = nil
    
    if self.inst.inbed then
        self.inst.inbed.components.bed:StopSleeping()
        return
    end
    
    local action = self:GetLeftMouseAction()
    if action then
	    self:DoAction( action )
	else
		--Get rid of the normal do action on click
		--self:DoAction( BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition()) ) 		

		--And use a version that doesn't walk the player to the click point and 
		--lets you click-drag when you start on non-camper entities
		GetPlayer().Transform:SetRotation(self.inst:GetAngleToPoint(TheInput:GetWorldPosition()))		
	    local clicked = TheInput:GetWorldEntityUnderMouse()
	    local actionable = false
	    if clicked then 
	    	actionable = clicked:HasTag("CLICK")
	    end
	    if not actionable then
	        self.startdragtime = GetTime()
	    end
    end
    
end


function PlayerController:OnRightClick(down)

 --    if not self:UsingMouse() then return end

	if not down then return end

 --    self.startdragtime = nil

	-- if self.placer_recipe then 
	-- 	self:CancelPlacement()
	-- end

 --    if not self:IsEnabled() then return end
    
 --    if TheInput:GetHUDEntityUnderMouse() then return end

 --    if not self:GetRightMouseAction() then
 --        self.inst.components.inventory:ReturnActiveItem()
 --    end
    
 --    if self.inst.inbed then
 --        self.inst.inbed.components.bed:StopSleeping()
 --        return
 --    end
    
    local action = self:GetRightMouseAction()
    if action then
		self:DoAction(action )
	end
		
    
end

function PlayerController:ShakeCamera(inst, shakeType, duration, speed, maxShake, maxDist)
    local distSq = self.inst:GetDistanceSqToInst(inst)
    local t = math.max(0, math.min(1, distSq / (maxDist*maxDist) ) )
    local scale = easing.outQuad(t, maxShake, -maxShake, 1)
    if scale > 0 then
        TheCamera:Shake(shakeType, duration, speed, scale)
    end
end


function PlayerController:GetLeftMouseAction( )
    return self.LMBaction
end

function PlayerController:GetRightMouseAction( )
    return self.RMBaction
end

function PlayerController:GetItemSelfAction(item)
	if not item then
		return
	end
	local lmb = self.inst.components.playeractionpicker:GetInventoryActions(item, false)
	local rmb = self.inst.components.playeractionpicker:GetInventoryActions(item, true)
	
	local action = (rmb and rmb[1]) or (lmb and lmb[1])		
	if action.action ~= ACTIONS.LOOKAT then
		return action
	end
end

function PlayerController:GetSceneItemControllerAction(item)
	local l, r = self.inst.components.playeractionpicker:DoGetMouseActions(item)
	if l and (l.action == ACTIONS.WALKTO) then
		l = nil
	end
	if r and (r.action == ACTIONS.WALKTO) then
		r = nil
	end
	--if l and (l.action == ACTIONS.LOOKAT or l.action == ACTIONS.ATTACK or l.action == ACTIONS.WALKTO) then
		--l = nil
	--end
	--if r and (r.action == ACTIONS.LOOKAT or r.action == ACTIONS.ATTACK or r.action == ACTIONS.WALKTO) then
		--r = nil
	--end
	
	return l, r
end


function PlayerController:GetGroundUseAction()

	local position = Vector3(self.inst.Transform:GetWorldPosition())
	 
	local tile = GetWorld().Map:GetTileAtPoint(position.x, position.y, position.z)
    local passable = tile ~= GROUND.IMPASSABLE
	if passable then
	    local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equipitem then
			local l, r = self.inst.components.playeractionpicker:GetPointActions(position, equipitem, false), self.inst.components.playeractionpicker:GetPointActions(position, equipitem, true)
			l = l and l[1]
			r = r and r[1]
			
			if l and l.action == ACTIONS.DROP then
				l = nil
			end
			if l or r then
				return l, r
			end
		
		end
	end
	    
end

function PlayerController:GetItemUseAction(active_item, target)
	if not active_item then
		return
	end
	target = target or self.controller_target
	if self.controller_target then
		local lmb = self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, false)
		local rmb = self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, true)
		local act= (rmb and rmb[1]) or (lmb and lmb[1])
		
		
		if act and active_item.components.tool and active_item.components.equippable and active_item.components.tool:CanDoAction(act.action)then
			return
		end
		
		if act and act.action ~= ACTIONS.COMBINESTACK then
			return act
		end



	end	
end

return PlayerController
