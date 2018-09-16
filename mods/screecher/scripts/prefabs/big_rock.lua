
local rock1_assets =
{
	Asset("ANIM", "anim/rock.zip"),
}

local rock2_assets =
{
	Asset("ANIM", "anim/rock2.zip"),
}

local rock_flintless_assets =
{
	Asset("ANIM", "anim/rock_flintless.zip"),
}

local function baserock_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeObstaclePhysics(inst, 1.)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rock.png" )

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
				inst.components.lootdropper:DropLoot(pt)
				inst:Remove()
			else
				
				
				if workleft < TUNING.ROCKS_MINE*(1/3) then
					inst.AnimState:PlayAnimation("low")
				elseif workleft < TUNING.ROCKS_MINE*(2/3) then
					inst.AnimState:PlayAnimation("med")
				else
					inst.AnimState:PlayAnimation("full")
				end
			end
		end)     

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)    

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "ROCK"
	MakeSnowCovered(inst, .01)        
	return inst
end

local function rock1_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock")
	inst.AnimState:SetBuild("rock")
	inst.AnimState:PlayAnimation("full")
	inst.Transform:SetScale(2.0,2.0,2.0)
	return inst
end

return Prefab("big_rock", rock1_fn, rock1_assets)
