local assets = 
{
	Asset("ANIM", "anim/goosemoose_nest_fx.zip")
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("goosemoose_nest_fx")
	inst.AnimState:SetBuild("goosemoose_nest_fx")
	inst.AnimState:PlayAnimation("idle")

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_electric")

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.persists = false

	inst:AddTag("fx")

	inst:ListenForEvent("animover", function() inst:Remove() end)

	return inst
end

return Prefab("moose_nest_fx", fn, assets)