local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()

	inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 2 )
    
    return inst
end

return Prefab( "common/fx/flashlight_lightpiece", fn, assets) 