
assets = {
	Asset("ANIM", "exportedanim/waterfaucet.zip"),
}

local function make_faucet(Sim)
	local inst = CreateEntity()
	inst:AddTag("CLICK")

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	--We'll want to randomize the sprite on this at some point
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("waterfaucet")
	inst.AnimState:SetBuild("waterfaucet")
	inst:AddTag("faucet")

	inst:AddComponent("activatable")
	inst.components.activatable.distance = 2
	inst.components.activatable.OnActivate = function(inst)
		inst:PushEvent("onactivate")
		-- handled by SGwaterfaucet.lua
	end

	inst:ListenForEvent("killallsounds", function()
        inst.SoundEmitter:KillSound("drip")
        inst.SoundEmitter:KillSound("faucet_run")
        inst.SoundEmitter:KillSound("fauceton")
        inst.SoundEmitter:KillSound("faucetoff")
    end, GetPlayer())

	inst:SetStateGraph("SGwaterfaucet")

	inst.name = "Water Faucet"
	
	return inst
end

return Prefab("waterfaucet", make_faucet, assets)
