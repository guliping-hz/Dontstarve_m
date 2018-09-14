require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/dragonfly_chest.zip"),
    Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end 

local function onclose(inst)
	inst.AnimState:PlayAnimation("close") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end 

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", false)
	if inst.components.container then 
		inst.components.container:DropEverything() 
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local slotpos = {}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(slotpos, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
    end
end
		
local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("dragonflychest.png")

	local s = 1
	inst.Transform:SetScale(s,s,s)

	inst:AddTag("structure")
	inst:AddTag("chest")
	inst.AnimState:SetBank("dragonfly_chest")
	inst.AnimState:SetBuild("dragonfly_chest")
	inst.AnimState:PlayAnimation("closed")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose
	
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
    inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"	
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

	return inst
end

return Prefab( "common/dragonflychest", fn, assets),
		MakePlacer("common/dragonflychest_placer", "dragonfly_chest", "dragonfly_chest", "closed")