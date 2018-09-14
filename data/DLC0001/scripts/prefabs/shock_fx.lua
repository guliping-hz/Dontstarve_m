local assets =
{
	Asset("ANIM", "anim/shock_fx.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local snd = inst.entity:AddSoundEmitter()
    inst.Transform:SetFourFaced()
    anim:SetBank("shock_fx")
    anim:SetBuild("shock_fx")
    anim:PlayAnimation("shock")
    snd:PlaySound("dontstarve_DLC001/common/shocked")
    inst:AddTag("fx")
    inst:ListenForEvent( "animover", function(inst) inst:Remove() end )
    return inst
end

return Prefab("common/fx/shock_fx", fn, assets) 
