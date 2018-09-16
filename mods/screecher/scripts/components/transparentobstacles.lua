local TransparentObstacles = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
end)

function TransparentObstacles:OnUpdate(dt)

    local player = self.inst
    local x,y,z = player.Transform:GetWorldPosition()
    local p1 = Vector3(x,y,z)
    local heading_angle = -(player.Transform:GetRotation())
    local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))

    --check trees in a bigger radius and make them solid
    local ents = TheSim:FindEntities(x,y,z, 25, {"tree"})
    for k, v in pairs(ents) do
        if v.AnimState and v.default_color then
            v.AnimState:SetMultColour(v.default_color, v.default_color, v.default_color, 1)
        end
    end

    --check trees close by and make them transparent if they are behind the player
    local ents = TheSim:FindEntities(x,y,z, 20, {"tree"})
    for k, v in pairs(ents) do
        if v.AnimState then
            local x2,y2,z2 = v.Transform:GetWorldPosition()
            local p2 = Vector3(x2,y2,z2)
            local diff = p1-p2
            local dot = diff:Dot(dir)
            if dot > 0 then
                local alpha = TUNING.TREE_ALPHA_AMOUNT
                v.AnimState:SetMultColour(alpha, alpha, alpha, alpha)
            end
        end
    end

end

return TransparentObstacles