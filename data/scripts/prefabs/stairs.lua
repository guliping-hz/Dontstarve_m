
local function onsave(inst, data)
end

local function onload(inst, data)
end

local function makestairs()
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        return inst
    end
    return fn
end
   
return Prefab("forest/objects/cave_stairs", makestairs(), assets) 

