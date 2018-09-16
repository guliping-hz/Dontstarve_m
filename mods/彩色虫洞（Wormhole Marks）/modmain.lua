-- _Q_ -- Wormhole Marks 1.2

function OnActivate_Wormhole(inst, doer)
	if  not inst.components.wormhole_marks:CheckMark() then
		inst.components.wormhole_marks:MarkEntrance()
	end
		
	if doer:HasTag("player") then
		GLOBAL.ProfileStatsSet("wormhole_used", true)
		doer.components.health:SetInvincible(true)
		doer.components.playercontroller:Enable(false)
			
		if inst.components.teleporter.targetTeleporter ~= nil then
			local other = inst.components.teleporter.targetTeleporter
			if not other.components.wormhole_marks:CheckMark() then
				other.components.wormhole_marks:MarkExit()
			end
			GLOBAL.DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
		end

		GLOBAL.GetPlayer().HUD:Hide()
		TheFrontEnd:SetFadeLevel(1)
		doer:DoTaskInTime(4, function() 
			TheFrontEnd:Fade(true,2)
			GLOBAL.GetPlayer().HUD:Show()
			doer.sg:GoToState("wakeup")
			if doer.components.sanity then
				doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
		end)
		doer:DoTaskInTime(5, function()
			doer:PushEvent("wormholespit")
			doer.components.health:SetInvincible(false)
			doer.components.playercontroller:Enable(true)
		end)		
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow", "wormhole_swallow")
	end
end

local function OnActivate_Triangle(inst, doer, target)
	if  not inst.components.triangle_marks:CheckMark() then
		inst.components.triangle_marks:MarkEntrance()
	end
	
	if doer:HasTag("player") then
		doer.components.health:SetInvincible(true)
		if TUNING.DO_SEA_DAMAGE_TO_BOAT and (doer.components.driver and doer.components.driver.vehicle and doer.components.driver.vehicle.components.boathealth) then
			doer.components.driver.vehicle.components.boathealth:SetInvincible(true)
		end
		doer.components.playercontroller:Enable(false)
		
		if inst.components.teleporter.targetTeleporter ~= nil then
			local other = inst.components.teleporter.targetTeleporter
			if not other.components.triangle_marks:CheckMark() then
				other.components.triangle_marks:MarkExit()
			end
			GLOBAL.DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
		end

		GLOBAL.GetPlayer().HUD:Hide()
        GLOBAL.TheCamera:SetTarget(inst)
		TheFrontEnd:Fade(false, 0.5)
		doer:DoTaskInTime(2, function()
            GLOBAL.TheCamera:SetTarget(target)
            GLOBAL.TheCamera:Snap()
			TheFrontEnd:Fade(true, 0.5)
			GLOBAL.GetPlayer().HUD:Show()
			if doer.components.sanity then
				doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
		end)
		doer:DoTaskInTime(3.5, function()
			GLOBAL.TheCamera:SetTarget(GLOBAL.GetPlayer())
			doer:PushEvent("bermudatriangleexit")
			doer.components.health:SetInvincible(false)
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (doer.components.driver and doer.components.driver.vehicle and doer.components.driver.vehicle.components.boathealth) then
				doer.components.driver.vehicle.components.boathealth:SetInvincible(false)
			end
			doer.components.playercontroller:Enable(true)
		end)
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_spark", "wormhole_swallow")
	end
end

local DLC = GLOBAL.rawget(GLOBAL, "CAPY_DLC") and GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC)

if DLC then
	Assets = 
	{
		Asset("ATLAS", "images/wormhole/mark_1.xml"),
		Asset("ATLAS", "images/wormhole/mark_2.xml"),
		Asset("ATLAS", "images/wormhole/mark_3.xml"),
		Asset("ATLAS", "images/wormhole/mark_4.xml"),
		Asset("ATLAS", "images/wormhole/mark_5.xml"),
		Asset("ATLAS", "images/wormhole/mark_6.xml"),
		Asset("ATLAS", "images/wormhole/mark_7.xml"),
		Asset("ATLAS", "images/wormhole/mark_8.xml"),
		Asset("ATLAS", "images/wormhole/mark_9.xml"),
		Asset("ATLAS", "images/wormhole/mark_10.xml"),
		Asset("ATLAS", "images/wormhole/mark_11.xml"),
		Asset("ATLAS", "images/wormhole/mark_12.xml"),
		Asset("ATLAS", "images/wormhole/mark_13.xml"),
		Asset("ATLAS", "images/wormhole/mark_14.xml"),
		Asset("ATLAS", "images/wormhole/mark_15.xml"),
		Asset("ATLAS", "images/wormhole/mark_16.xml"),
		Asset("ATLAS", "images/wormhole/mark_17.xml"),
		Asset("ATLAS", "images/wormhole/mark_18.xml"),
		Asset("ATLAS", "images/wormhole/mark_19.xml"),
		Asset("ATLAS", "images/wormhole/mark_20.xml"),
		Asset("ATLAS", "images/wormhole/mark_21.xml"),
		Asset("ATLAS", "images/wormhole/mark_22.xml"),
		----------------------------------------------
		Asset("ATLAS", "images/triangle/triangle_1.xml"),
		Asset("ATLAS", "images/triangle/triangle_2.xml"),
		Asset("ATLAS", "images/triangle/triangle_3.xml"),
		Asset("ATLAS", "images/triangle/triangle_4.xml"),
		Asset("ATLAS", "images/triangle/triangle_5.xml"),
		Asset("ATLAS", "images/triangle/triangle_6.xml"),
		Asset("ATLAS", "images/triangle/triangle_7.xml"),
		Asset("ATLAS", "images/triangle/triangle_8.xml"),
	}

	AddMinimapAtlas("images/wormhole/mark_1.xml")
	AddMinimapAtlas("images/wormhole/mark_2.xml")
	AddMinimapAtlas("images/wormhole/mark_3.xml")
	AddMinimapAtlas("images/wormhole/mark_4.xml")
	AddMinimapAtlas("images/wormhole/mark_5.xml")
	AddMinimapAtlas("images/wormhole/mark_6.xml")
	AddMinimapAtlas("images/wormhole/mark_7.xml")
	AddMinimapAtlas("images/wormhole/mark_8.xml")
	AddMinimapAtlas("images/wormhole/mark_9.xml")
	AddMinimapAtlas("images/wormhole/mark_10.xml")
	AddMinimapAtlas("images/wormhole/mark_11.xml")
	AddMinimapAtlas("images/wormhole/mark_12.xml")
	AddMinimapAtlas("images/wormhole/mark_13.xml")
	AddMinimapAtlas("images/wormhole/mark_14.xml")
	AddMinimapAtlas("images/wormhole/mark_15.xml")
	AddMinimapAtlas("images/wormhole/mark_16.xml")
	AddMinimapAtlas("images/wormhole/mark_17.xml")
	AddMinimapAtlas("images/wormhole/mark_18.xml")
	AddMinimapAtlas("images/wormhole/mark_19.xml")
	AddMinimapAtlas("images/wormhole/mark_20.xml")
	AddMinimapAtlas("images/wormhole/mark_21.xml")
	AddMinimapAtlas("images/wormhole/mark_22.xml")
	----------------------------------------------
	AddMinimapAtlas("images/triangle/triangle_1.xml")
	AddMinimapAtlas("images/triangle/triangle_2.xml")
	AddMinimapAtlas("images/triangle/triangle_3.xml")
	AddMinimapAtlas("images/triangle/triangle_4.xml")
	AddMinimapAtlas("images/triangle/triangle_5.xml")
	AddMinimapAtlas("images/triangle/triangle_6.xml")
	AddMinimapAtlas("images/triangle/triangle_7.xml")
	AddMinimapAtlas("images/triangle/triangle_8.xml")
	
	function WormholePrefabPostInit(inst)
		inst:AddComponent("wormhole_marks")
		if inst and inst.components.teleporter then
			inst.components.teleporter.onActivate = OnActivate_Wormhole
		end
	end

	AddPrefabPostInit("wormhole", WormholePrefabPostInit)

	function ForestPrefabPostInit(inst)
		inst:AddComponent("wormhole_counter")
	end

	AddPrefabPostInit("forest", ForestPrefabPostInit)
	
	function TrianglePrefabPostInit(inst)
		inst:AddComponent("triangle_marks")
		if inst and inst.components.teleporter then
			inst.components.teleporter.onActivate = OnActivate_Triangle
		end
	end

	AddPrefabPostInit("bermudatriangle", TrianglePrefabPostInit)

	function ShipwreckedPrefabPostInit(inst)
		inst:AddComponent("triangle_counter")
	end

	AddPrefabPostInit("shipwrecked", ShipwreckedPrefabPostInit)
else
	Assets = 
	{
		Asset("ATLAS", "images/wormhole/mark_1.xml"),
		Asset("ATLAS", "images/wormhole/mark_2.xml"),
		Asset("ATLAS", "images/wormhole/mark_3.xml"),
		Asset("ATLAS", "images/wormhole/mark_4.xml"),
		Asset("ATLAS", "images/wormhole/mark_5.xml"),
		Asset("ATLAS", "images/wormhole/mark_6.xml"),
		Asset("ATLAS", "images/wormhole/mark_7.xml"),
		Asset("ATLAS", "images/wormhole/mark_8.xml"),
		Asset("ATLAS", "images/wormhole/mark_9.xml"),
		Asset("ATLAS", "images/wormhole/mark_10.xml"),
		Asset("ATLAS", "images/wormhole/mark_11.xml"),
		Asset("ATLAS", "images/wormhole/mark_12.xml"),
		Asset("ATLAS", "images/wormhole/mark_13.xml"),
		Asset("ATLAS", "images/wormhole/mark_14.xml"),
		Asset("ATLAS", "images/wormhole/mark_15.xml"),
		Asset("ATLAS", "images/wormhole/mark_16.xml"),
		Asset("ATLAS", "images/wormhole/mark_17.xml"),
		Asset("ATLAS", "images/wormhole/mark_18.xml"),
		Asset("ATLAS", "images/wormhole/mark_19.xml"),
		Asset("ATLAS", "images/wormhole/mark_20.xml"),
		Asset("ATLAS", "images/wormhole/mark_21.xml"),
		Asset("ATLAS", "images/wormhole/mark_22.xml"),
	}

	AddMinimapAtlas("images/wormhole/mark_1.xml")
	AddMinimapAtlas("images/wormhole/mark_2.xml")
	AddMinimapAtlas("images/wormhole/mark_3.xml")
	AddMinimapAtlas("images/wormhole/mark_4.xml")
	AddMinimapAtlas("images/wormhole/mark_5.xml")
	AddMinimapAtlas("images/wormhole/mark_6.xml")
	AddMinimapAtlas("images/wormhole/mark_7.xml")
	AddMinimapAtlas("images/wormhole/mark_8.xml")
	AddMinimapAtlas("images/wormhole/mark_9.xml")
	AddMinimapAtlas("images/wormhole/mark_10.xml")
	AddMinimapAtlas("images/wormhole/mark_11.xml")
	AddMinimapAtlas("images/wormhole/mark_12.xml")
	AddMinimapAtlas("images/wormhole/mark_13.xml")
	AddMinimapAtlas("images/wormhole/mark_14.xml")
	AddMinimapAtlas("images/wormhole/mark_15.xml")
	AddMinimapAtlas("images/wormhole/mark_16.xml")
	AddMinimapAtlas("images/wormhole/mark_17.xml")
	AddMinimapAtlas("images/wormhole/mark_18.xml")
	AddMinimapAtlas("images/wormhole/mark_19.xml")
	AddMinimapAtlas("images/wormhole/mark_20.xml")
	AddMinimapAtlas("images/wormhole/mark_21.xml")
	AddMinimapAtlas("images/wormhole/mark_22.xml")
	
	function WormholePrefabPostInit(inst)
		inst:AddComponent("wormhole_marks")
		if inst and inst.components.teleporter then
			inst.components.teleporter.onActivate = OnActivate_Wormhole
		end
	end

	AddPrefabPostInit("wormhole", WormholePrefabPostInit)

	function ForestPrefabPostInit(inst)
		inst:AddComponent("wormhole_counter")
	end

	AddPrefabPostInit("forest", ForestPrefabPostInit)
end