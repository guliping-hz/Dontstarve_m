local assets = 
{
	Asset("ANIM", "anim/mossling_spin_fx.zip")
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("mossling_spin_fx")
	inst.AnimState:SetBuild("mossling_spin_fx")
	inst.AnimState:PlayAnimation("spin_loop")

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
	inst:DoTaskInTime(24*FRAMES, function(inst)
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
		inst:DoTaskInTime(24*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
		end)
	end)

	inst:AddTag("fx")

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.persists = false

	inst:ListenForEvent("animover", function() inst:Remove() end)

	return inst
end

return Prefab("mossling_spin_fx", fn, assets)