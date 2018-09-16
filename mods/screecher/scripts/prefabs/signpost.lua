
    
local assets =
{
	Asset("ANIM", "anim/sign_home.zip"),
}

local signdescriptions = {
	["campsite"] = '"Welcome to Hollow Pine campsite. No littering."',
	["to_totem"] = 'This way to the totem pole.',
	["to_scoutcamp"] = 'The local boys\' group has a camp down this way.',
	["to_bigrock"] = 'Some kind of natural wonder, a big rock, is up ahead.',
	["to_ritual"] = 'The sign has decayed so much I can\'t read it.',
}
    
local function makesign(string_id)
	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		   
		MakeObstaclePhysics(inst, .2)    
		
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "sign.png" )

		inst:AddTag("CLICK")
		
		anim:SetBank("sign_home")
		anim:SetBuild("sign_home")
		anim:PlayAnimation("idle")

		inst.name = "Sign"
		
		inst:AddComponent("inspectable")
		inst.components.inspectable:SetDescription(signdescriptions[string_id])
	   
		return inst
	end
	return fn
end

local prefabs = {}
for k,v in pairs(signdescriptions) do
	table.insert(prefabs, Prefab("common/objects/sign_"..k, makesign(k), assets))
end

return unpack(prefabs)
