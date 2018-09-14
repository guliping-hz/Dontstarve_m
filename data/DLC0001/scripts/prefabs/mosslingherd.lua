local function AddMember(inst, member)

end

local function CanSpawn(inst)
    return inst.components.herd and not inst.components.herd:IsFull()
end

local function OnEmpty(inst)
    inst:Remove()
end

local function OnFull(inst)

end
   
local function OnSummonMoose(inst, guardian)



end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("pig_house")
    anim:SetBuild("pig_house")
    anim:PlayAnimation("idle")

    inst:AddTag("herd")
    
    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("mossling")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(OnEmpty)
    inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd:SetAddMemberFn(AddMember)

    inst:AddComponent("guardian")
    inst.components.guardian.prefab = "moose"
    inst.components.guardian.onsummonfn = OnSummonMoose
    
    return inst
end

return Prefab( "forest/animals/mosslingherd", fn) 
