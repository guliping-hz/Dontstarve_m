assets = {
	Asset("ANIM", "anim/rock.zip"),
}

local sounds = {
	{"scary_mod/stuff/screetch_steps", 0.2, 3},
	{"scary_mod/stuff/screetch_rustle_single", 0.2, 3},
	{"scary_mod/stuff/screetch_scream", 4, 3},
	{"scary_mod/stuff/screetch_moan", 7, 6},
	--{"scary_mod/music/piano_LP", 7, 6},
	--{"scary_mod/music/anticipate_7sec", 8, 7},
	--{"dontstarve/movement/run_dirt", 0.1},
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

--[[
	local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("rock")
    inst.AnimState:SetBuild("rock")
	inst.AnimState:PlayAnimation("full")
]]
    local physics = inst.entity:AddPhysics()
    physics:SetMass(1)
    physics:SetCapsule(0.5, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:ClearCollisionMask()

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = 25
	inst.components.locomotor.walkspeed = 25

	inst.soundid = math.random(1, #sounds)
	inst.soundname = tostring(inst) .. "_scarysound"
	inst.nextsoundtime = sounds[inst.soundid][2] == 0 and 0 or GetTime() + sounds[inst.soundid][2]
	inst.stopsound = false

	inst.SoundEmitter:PlaySound(sounds[inst.soundid][1], inst.soundname)
	inst:DoTaskInTime(sounds[inst.soundid][3], function(inst)
		print("DEspawning a sound ent with sound", sounds[inst.soundid][1], inst.soundname)
		inst.SoundEmitter:KillSound(inst.soundname)
		inst:Remove()
	end)

	inst.StartMoving = function()
		inst.Transform:SetRotation(inst:GetAngleToPoint(GetPlayer():GetPosition()))
		inst:DoPeriodicTask(0, function(inst)
			if inst.nextsoundtime ~= 0 and GetTime() > inst.nextsoundtime and not inst.stopsound then
				inst.SoundEmitter:PlaySound(sounds[inst.soundid][1], inst.soundname)
				inst.nextsoundtime = GetTime() + sounds[inst.soundid][2]
			end
			inst.components.locomotor:RunForward()
		end)
	end

	inst:ListenForEvent("killallsounds", function()
        inst.stopsound = true
    end, GetPlayer())

	print("spawning a sound ent with sound", sounds[inst.soundid][1], inst.soundname)
	return inst
end

return Prefab("stalking_noise", fn, assets)
