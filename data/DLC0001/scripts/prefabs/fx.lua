

local function MakeFx(t)
    local assets = 
        {
            Asset("ANIM", "anim/"..t.build..".zip")
        }

    local function fn()
        --print ("SPAWN", debugstack())
    	local inst = CreateEntity()
    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()

        if not t.twofaced then
            inst.Transform:SetFourFaced()
        else
            inst.Transform:SetTwoFaced()
        end

        if type(t.anim) ~= "string" then
            t.anim = t.anim[math.random(#t.anim)]
        end

        if t.sound or t.sound2 then
            inst.entity:AddSoundEmitter()
        end
        
        if t.fnc and t.fntime then
            inst:DoTaskInTime(t.fntime, t.fnc)
        end

        if t.sound then
            inst:DoTaskInTime(t.sounddelay or 0, function() inst.SoundEmitter:PlaySound(t.sound) end)
        end

        if t.sound2 then
            inst:DoTaskInTime(t.sounddelay2 or 0, function() inst.SoundEmitter:PlaySound(t.sound2) end)
        end

        inst.AnimState:SetBank(t.bank)
        inst.AnimState:SetBuild(t.build)
        inst.AnimState:PlayAnimation(t.anim, false)
        if t.tint or t.tintalpha then
            inst.AnimState:SetMultColour((t.tint and t.tint.x) or (t.tintalpha or 1),(t.tint and t.tint.y)  or (t.tintalpha or 1),(t.tint and t.tint.z)  or (t.tintalpha or 1), t.tintalpha or 1)
        end
        --print(inst.AnimState:GetMultColour())
        if t.transform then
            inst.AnimState:SetScale(t.transform:Get())
        end

        if t.nameoverride then
            inst:AddComponent("inspectable")
            inst.components.inspectable.nameoverride = t.nameoverride
            inst.name = t.nameoverride
        end

        if t.description then
            if not inst.components.inspectable then inst:AddComponent("inspectable") end
            inst.components.inspectable.description = t.description
        end

        if t.bloom then
            inst.bloom = true
            inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
        end

        inst:AddTag("FX")
        inst.persists = false
        inst:ListenForEvent("animover", function() 
            if inst.bloom then inst.AnimState:ClearBloomEffectHandle() end
            inst:Remove() 
        end)

        return inst
    end
    return Prefab("common/fx/"..t.name, fn, assets)
end

local prefs = {}
local fx = require("fx") 
for k,v in pairs(fx) do
    table.insert(prefs, MakeFx(v))
end

return unpack(prefs)
