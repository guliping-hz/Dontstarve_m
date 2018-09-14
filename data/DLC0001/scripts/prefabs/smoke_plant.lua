local assets =
{
	Asset("ANIM", "anim/smoke_plants.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	--local light = inst.entity:AddLight()

	--anim:SetBloomEffectHandle( "shaders/anim.ksh" )
	
    anim:SetBank("smoke_out")
    anim:SetBuild("smoke_plants")
    anim:PlayAnimation("smoke_loop", true)
    --inst.AnimState:SetRayTestOnBB(true)

    inst.entity:AddLight()
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,165/255,12/255)
	inst.Light:Enable(true)

    sound:PlaySound("dontstarve_DLC001/summer/smolder", "smolder")
    
    inst:AddTag("fx")
    
    anim:SetFinalOffset(2)

    return inst
end

return Prefab( "common/fx/smoke_plant", fn, assets) 
