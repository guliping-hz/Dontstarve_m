local assets=
{
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
   
	inst.entity:AddSoundEmitter()
	inst.SoundEmitter:PlaySound("scary_mod/stuff/sign_creak_LP", "signcreak")
	inst:AddTag("creaksound")

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(2, 45)
	inst.components.playerprox.onnear = function()
		inst.SoundEmitter:KillSound("signcreak")
	end

	inst:ListenForEvent("killallsounds", function()
        inst.SoundEmitter:KillSound("signcreak")
    end, GetPlayer())

    return inst
end

return Prefab( "common/inventory/creaksound", fn, assets) 

