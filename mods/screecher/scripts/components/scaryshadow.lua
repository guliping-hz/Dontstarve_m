local ScaryShadow = Class(function(self, inst, activcb)
    self.inst = inst
end)

function ScaryShadow:SpawnShadow(doer, scale)
    local x,y,z = doer.Transform:GetWorldPosition()
    local scary_shadow = SpawnPrefab("scary_shadow")
    if scary_shadow then
        scary_shadow.Transform:SetPosition(x,y,z)
        scary_shadow.Transform:SetScale(scale, scale, scale)
    end
end


return ScaryShadow