require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/treasure_chest.zip"),
	Asset("ANIM", "anim/ui_chest_3x2.zip"),
	

	Asset("ANIM", "anim/pandoras_chest.zip"),
	Asset("ANIM", "anim/skull_chest.zip"),
	Asset("ANIM", "anim/pandoras_chest_large.zip"),
}

local prefabs =
{
	"collapse_small",
}

local chests = {
	treasure_chest = {
		bank="chest",
		build="treasure_chest",
	},
	skull_chest = {
		bank="skull_chest",
		build="skull_chest",
	},
	pandoras_chest = {
		bank="pandoras_chest",
		build="pandoras_chest",
	},
	minotaur_chest = {
		bank = "pandoras_chest_large",
		build = "pandoras_chest_large",
	},
}


local function onopen(inst) 
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open") 
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	end
end 

local function onclose(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close") 
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	end
end 

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", false)
		if inst.components.container then 
			inst.components.container:DropEverything() 
			inst.components.container:Close()
		end
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local slotpos = {}

for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
	end
end
		
local function chest(style)
	local fn = function(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()
		
		minimap:SetIcon( style..".png" )


		inst:AddTag("structure")
		inst:AddTag("chest")
		inst.AnimState:SetBank(chests[style].bank)
		inst.AnimState:SetBuild(chests[style].build)
		inst.AnimState:PlayAnimation("closed")
		
		inst:AddComponent("inspectable")
		inst:AddComponent("container")
		inst.components.container:SetNumSlots(#slotpos)
		
		inst.components.container.onopenfn = onopen
		inst.components.container.onclosefn = onclose
		
		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = "ui_chest_3x3"
		inst.components.container.widgetanimbuild = "ui_chest_3x3"
		inst.components.container.widgetpos = Vector3(0,200,0)
		inst.components.container.side_align_tip = 160
		
		inst:AddComponent("lootdropper")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(2)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit) 
		
		inst:ListenForEvent( "onbuilt", onbuilt)
		MakeSnowCovered(inst, .01)	

		MakeSmallBurnable(inst, nil, nil, true)
		MakeSmallPropagator(inst)

		inst.OnSave = onsave 
        inst.OnLoad = onload

		return inst
	end
	return fn
end



return Prefab( "common/treasurechest", chest("treasure_chest"), assets, prefabs),
		MakePlacer("common/treasurechest_placer", "chest", "treasure_chest", "closed"),
		Prefab( "common/pandoraschest", chest("pandoras_chest"), assets, prefabs),
		Prefab( "common/skullchest", chest("skull_chest"), assets, prefabs),
		Prefab("common/minotaurchest", chest("minotaur_chest"), assets, prefabs)

