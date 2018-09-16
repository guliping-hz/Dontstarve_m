
local assets =
{
    Asset("ANIM", "anim/evergreen_new.zip"), --build
    Asset("ANIM", "anim/evergreen_new_2.zip"), --build
    Asset("ANIM", "anim/evergreen_tall_old.zip"),
    Asset("ANIM", "anim/evergreen_short_normal.zip"),
    Asset("ANIM", "anim/dust_fx.zip"),
    -- Asset("SOUND", "sound/forest.fsb"),
}

local function makeanims(stage)
    return {
        idle="idle_"..stage,
        sway1="sway1_loop_"..stage,
        sway2="sway2_loop_"..stage,
        chop="chop_"..stage,
        fallleft="fallleft_"..stage,
        fallright="fallright_"..stage,
        stump="stump_"..stage,
        burning="burning_loop_"..stage,
        burnt="burnt_"..stage,
        chop_burnt="chop_burnt_"..stage,
        idle_chop_burnt="idle_chop_burnt_"..stage
    }
end

local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local normal_anims = makeanims("normal")

local builds = 
{
	normal = {
		file="evergreen_new",
		normal_loot = {"log", "log", "pinecone"},
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "pinecone", "pinecone"},
		drop_pinecones=true,
		leif="leif",
    },
	sparse = {
		file="evergreen_new_2",
		normal_loot = {"log","log"},
		short_loot = {"log"},
		tall_loot = {"log", "log","log"},
		drop_pinecones=false,
		leif="leif_sparse",
    },
}


local function GetBuild(inst)
	local build = builds[inst.build]
	if build == nil then
		return builds["normal"]
	end
	return build
end


local function PushSway(inst)
    if math.random() > .5 then
        inst.AnimState:PushAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PushAnimation(inst.anims.sway2, true)
    end
end

local function Sway(inst)
    if math.random() > .5 then
        inst.AnimState:PlayAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PlayAnimation(inst.anims.sway2, true)
    end
end

local function SetShort(inst)
    inst.anims = short_anims
    Sway(inst)
end


local function SetNormal(inst)
    inst.anims = normal_anims
    Sway(inst)
end

local function SetTall(inst)
    inst.anims = tall_anims
    Sway(inst)
end

 local growth_stages =
 {
	 {name="short", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[1].base, TUNING.EVERGREEN_GROW_TIME[1].random) end, fn = function(inst) SetShort(inst) end,  growfn = function(inst) GrowShort(inst) end , leifscale=.7 },
	 {name="normal", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[2].base, TUNING.EVERGREEN_GROW_TIME[2].random) end, fn = function(inst) SetNormal(inst) end, growfn = function(inst) GrowNormal(inst) end, leifscale=1 },
	 {name="tall", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[3].base, TUNING.EVERGREEN_GROW_TIME[3].random) end, fn = function(inst) SetTall(inst) end, growfn = function(inst) GrowTall(inst) end, leifscale=1.25 },
	 {name="old", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[4].base, TUNING.EVERGREEN_GROW_TIME[4].random) end, fn = function(inst) SetOld(inst) end, growfn = function(inst) GrowOld(inst) end },
 }


local function makefn(build, stage, data)
	
    local function fn(Sim)
		local l_stage = stage
		if l_stage == 0 then
			l_stage = math.random(1,3)
		end

        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        
        -- local sound = inst.entity:AddSoundEmitter()

        MakeObstaclePhysics(inst, 3.0)   

		local minimap = inst.entity:AddMiniMapEntity()
		if build == "normal" then
			minimap:SetIcon("evergreen.png")
		elseif build == "sparse" then
			minimap:SetIcon("evergreen_lumpy.png")
		end
		minimap:SetPriority(-1)
       
        inst:AddTag("tree")
        inst:AddTag("workable")
		inst:AddTag("visblocker")
        
        inst.build = build
        anim:SetBuild(GetBuild(inst).file)
        anim:SetBank("evergreen_short")
        local color = 0.5 + math.random() * 0.5
        anim:SetMultColour(color, color, color, 1)
        inst.default_color = color
        
        
        ---------------------        
        --PushSway(inst)
        inst.AnimState:SetTime(math.random()*2)

		growth_stages[l_stage].fn(inst)

        ---------------------        
        -- inst:AddComponent("growable")
        -- inst.components.growable.stages = growth_stages
        -- inst.components.growable:SetStage(l_stage)
     

		inst.Transform:SetScale(2.0, 2.0, 2.0)

        return inst
    end
    return fn
end    

local function tree(name, build, stage, data)
    return Prefab("forest/objects/trees/"..name, makefn(build, stage, data), assets, nil)
end

return tree("evergreen_border", "normal", 0),
       tree("evergreen_border_sparse", "sparse", 0)
