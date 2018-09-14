local assets =
{
	Asset("ANIM", "anim/gravestones.zip"),
}

local prefabs = 
{
	"ghost",
	"amulet",
	"redgem",
	"gears",
	"bluegem",
	"nightmarefuel",
}

for k= 1,NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k) )
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		child.sg:GoToState("dissipate")
	end
end

local function onfinishcallback(inst, worker)

    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")
    inst.components.hole.canbury = true

	if worker then
		if worker.components.sanity then
			worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
		end		
		if math.random() < .1 then
			local ghost = SpawnPrefab("ghost")
			local pos = Point(inst.Transform:GetWorldPosition())
			pos.x = pos.x -.3
			pos.z = pos.z -.3
			if ghost then
				ghost.Transform:SetPosition(pos.x, pos.y, pos.z)
			end
		elseif worker.components.inventory then
			local item = nil
			if math.random() < .5 then
				local loots = 
				{
					nightmarefuel = 1,
					amulet = 1,
					gears = 1,
					redgem = 5,
					bluegem = 5,
				}
				item = weighted_random_choice(loots)
			else
				item = "trinket_"..tostring(math.random(NUM_TRINKETS))
			end

			
			if item then
				inst.components.lootdropper:SpawnLootPrefab(item)
			end
		end
	end	
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		child.components.health:Kill()

		if child:IsAsleep() then
			child:Remove()
		end
	end
end

local function ResetGrave(inst)
	inst.AnimState:PlayAnimation("gravedirt")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.hole.canbury = false
    inst.dug = false
    inst.components.workable:SetOnFinishCallback(onfinishcallback) 
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("gravestone")
    anim:SetBuild("gravestones")
    anim:PlayAnimation("gravedirt")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.workable then        	
            return "DUG"
        end
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ghost"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(10, 3)

    inst:ListenForEvent("fullmoon", function() 
    	inst.components.childspawner:StartSpawning()
    	inst.components.childspawner:StopRegen()
    end, GetWorld())

    inst:ListenForEvent("daytime", function()
    	inst.components.childspawner:StopSpawning()
    	inst.components.childspawner:StartRegen()
    	ReturnChildren(inst) 
    end, GetWorld())
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst:AddComponent("lootdropper")
        
    inst.components.workable:SetOnFinishCallback(onfinishcallback)    

    inst:AddComponent("hole")  
    inst.ResetGrave = ResetGrave
    inst.OnSave = function(inst, data)
        if not inst.components.workable then
            data.dug = true
        end
    end        
    
    inst.OnLoad = function(inst, data)
        if data and data.dug or not inst.components.workable then
            inst:RemoveComponent("workable")
            inst.AnimState:PlayAnimation("dug")
            inst.components.hole.canbury = true
        end

        inst:DoTaskInTime(0, function(inst)
        	if inst.components.childspawner then
		        if GetClock():IsNight() and GetClock():GetMoonPhase() == "full" then
		        	inst.components.childspawner:StartSpawning()
		    		inst.components.childspawner:StopRegen()
		        else
		        	inst.components.childspawner:StopSpawning()
			    	inst.components.childspawner:StartRegen()
			    	ReturnChildren(inst) 
	        	end
	        end
	    end)
    end           
    
    
    return inst
end

return Prefab( "common/objects/mound", fn, assets, prefabs ) 
