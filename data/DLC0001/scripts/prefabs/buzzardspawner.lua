local assets =
{
	Asset("ANIM", "anim/buzzard_shadow.zip"),
	Asset("ANIM", "anim/buzzard_build.zip"),
}

local prefabs =
{
	"buzzard",
}

local FOOD_TAGS = {"edible", "prey"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO"}

local function RemoveShadow(inst, shadow)
	shadow.components.colourtweener:StartTween({1,1,1,0}, 3, function() shadow:Remove() inst.buzzards[shadow] = nil end)
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function SpawnBuzzardShadow(inst)
	local buzzard = SpawnPrefab("circlingbuzzard")
	buzzard.components.circler:SetCircleTarget(inst)
	buzzard.components.circler:Start()
	inst.buzzards[buzzard] = buzzard
end

local function OnAddChild(inst, num)
	for i = 1, num or 1 do
		SpawnBuzzardShadow(inst)
	end
end

local function OnSpawn(inst, child)
	for k,v in pairs(inst.buzzards) do
		if k and k:IsValid() then
			local dist = v.components.circler.distance
			local angle = v.components.circler.angleRad
			local offset = FindWalkableOffset(inst:GetPosition(), angle, dist, 8, false) or Vector3(0,0,0)
			offset.y = 30
			child.Transform:SetPosition((inst:GetPosition() + offset):Get())
			child.sg:GoToState("glide")
			RemoveShadow(inst, k)		
			break
		end
	end
end

local function BuzzardNearFood(inst, food)
    local x,y,z = food.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 3,  {"buzzard"}, {"FX", "NOCLICK", "DECOR","INLIMBO"})
    return #ents > 0
end

local function SpawnOnFood(inst, food)
	if food.buzzardHunted then return end
	if math.random() > 0.25 then
		local buzzard = inst.components.childspawner:SpawnChild()
		local foodPos = food:GetPosition()
		buzzard.Transform:SetPosition(foodPos.x + math.random(-1.5, 1.5), 30, foodPos.z + math.random(-1.5, 1.5))

		if food:HasTag("prey") then
			buzzard.sg.statemem.target = food
		end
		
		buzzard:FacePoint(food.Transform:GetWorldPosition())
		food:ListenForEvent("onpickup", function() food.buzzardHunted = nil end)
		food.buzzardHunted = true
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/distant")
	end
end

local function LookForFood(inst)
	if not inst.components.childspawner:CanSpawn() or GetClock():IsNight() then return end

	local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 25, nil, NO_TAGS)
    for k,v in pairs(ents) do
        if v and v:IsOnValidGround() and (v.components.edible and v.components.edible.foodtype == "MEAT" and not v.components.inventoryitem:IsHeld())
        or v:HasTag("prey") and not BuzzardNearFood(inst, v) and not v.buzzardHunted then
        	SpawnOnFood(inst, v)
            break
        end
    end
end

local function OnEntitySleep(inst)
	for k,v in pairs(inst.buzzards) do
		k:Remove()
		k = nil
	end
	if inst.foodTask then
		inst.foodTask:Cancel()
		inst.foodTask = nil
	end
end

local function OnEntityWake(inst)
	inst:DoTaskInTime(0.5, function() 
		if not inst:IsAsleep() then 
			for i = 1, inst.components.childspawner.childreninside do
				SpawnBuzzardShadow(inst)
			end
		end
	end)
	inst.foodTask = inst:DoPeriodicTask(math.random(20,40)*0.1, LookForFood)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "buzzard.png" )

	inst:AddTag("buzzardspawner")

	inst:AddComponent( "childspawner" )
	inst.components.childspawner.childname = "buzzard"
	inst.components.childspawner:SetSpawnedFn(OnSpawn)
	inst.components.childspawner:SetOnAddChildFn(OnAddChild)
	inst.components.childspawner:SetMaxChildren(math.random(1,2))
	inst.components.childspawner:SetSpawnPeriod(math.random(40, 50))
	inst.components.childspawner:SetRegenPeriod(20)

	inst:ListenForEvent("daytime", function()
	    if not GetSeasonManager() or not GetSeasonManager():IsWinter() then
		    inst.components.childspawner:StartSpawning()
			inst.components.childspawner:StopRegen()
		end
	end, GetWorld())

	inst:ListenForEvent("nighttime", function() 
		inst.components.childspawner:StopSpawning()
		inst.components.childspawner:StartRegen()
		ReturnChildren(inst)
	end, GetWorld())
	
	inst.buzzards = {}

	return inst
end

local function circlingbuzzardfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("buzzard")
    anim:SetBuild("buzzard_build")
    anim:PlayAnimation("shadow", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddComponent("circler")

	inst.AnimState:SetMultColour(1,1,1,0)
	inst:AddComponent("colourtweener")
	if not GetClock():IsNight() then
		inst.components.colourtweener:StartTween({1,1,1,1}, 3)
	end

	inst.persists = false

	inst:ListenForEvent("daytime", function()
	    if not GetSeasonManager() or not GetSeasonManager():IsWinter() then
			inst.components.colourtweener:StartTween({1,1,1,1}, 3)
		end
	end, GetWorld())

	inst:ListenForEvent("nighttime", function() 
			inst.components.colourtweener:StartTween({1,1,1,0}, 3)
	end, GetWorld())

	inst:DoPeriodicTask(math.random(3,5), function() 
		if math.random() > 0.66 then 
			local numFlaps = math.random(3, 6)
			inst.AnimState:PlayAnimation("shadow_flap_loop") 

			for i = 2, numFlaps do
				inst.AnimState:PushAnimation("shadow_flap_loop") 
			end

			inst.AnimState:PushAnimation("shadow") 
		end 
	end)

	return inst
end

return Prefab( "badlands/objects/buzzardspawner", fn, assets, prefabs),
Prefab("badlands/objects/circlingbuzzard", circlingbuzzardfn, assets, prefabs)