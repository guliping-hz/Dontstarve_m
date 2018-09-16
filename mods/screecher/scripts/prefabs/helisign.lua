
local assets = {
	Asset("ANIM", "exportedanim/heli_sign.zip"),
}

local seen_a_sign = false

local function OnActivate(inst, doer)
	inst:DoTaskInTime(0, function(inst)
		inst.components.activatable.inactive = true
	end)

	local anglediff = inst.Transform:GetRotation() - doer.Transform:GetRotation()
	while anglediff > 180 do anglediff = anglediff - 360 end
	while anglediff < -180 do anglediff = anglediff + 360 end
	if math.abs(anglediff) > 90 then
		if not seen_a_sign then
			doer.components.talker:Say("I can follow these signs to the helipad.", 2.5, false)
		else
			doer.components.talker:Say("The helipad is that way.", 2.5, false)
		end
		seen_a_sign = true
	else
		doer.components.talker:Say("There's nothing on this side of the sign.", 2.5, false)
	end
end

local function MoveToStoryPositionAndRotation(inst)
	local topo = GetWorld().topology

	local pos = inst:GetPosition()

	local mynode = -1
	for i,node in ipairs(topo.nodes) do
		if TheSim:WorldPointInPoly(pos.x, pos.z, node.poly) then
			mynode = i
			break
		end
	end

	--print("I'm in node",mynode,":",topo.ids[mynode],"depth",topo.story_depths[mynode])
	--dumptable(topo.nodes[mynode])

	local backnode = nil
	for i,edge in ipairs(topo.edges) do
		local back = nil
		if edge.n1 == mynode then
			back = edge.n2
		end
		if edge.n2 == mynode then
			back = edge.n1
		end
		if back and topo.story_depths[mynode] > topo.story_depths[back] then
			backnode = back
			break
		end
	end


	if backnode then
		--print("Backnode is",backnode,":",topo.ids[backnode],"depth",topo.story_depths[backnode])
		--dumptable(topo.nodes[backnode])
		local mypos = Vector3(topo.nodes[mynode].cent[1], 0, topo.nodes[mynode].cent[2])
		local backpos = Vector3(topo.nodes[backnode].cent[1], 0, topo.nodes[backnode].cent[2])
		local diff = backpos - mypos
		inst.Transform:SetPosition( (mypos + (diff*0.75)):Get() )
		inst.Transform:SetRotation( inst:GetAngleToPoint(backpos) )
	else
		print("WARNING: Heli sign in "..topo.ids[mynode].." had no backnode, must place in entrance room!... removing")
		-- remove this because it won't point in the right direction.
		inst:Remove()
	end
end

local function create_sign(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.nameoffset = 170

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("sign")
    inst.AnimState:SetBuild("heli_sign")
	inst.AnimState:PlayAnimation("idle", false)

	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize(0.5, 0.5)

	-- Have to wait until we are transformed
	inst:DoTaskInTime(0, function(inst)
		MoveToStoryPositionAndRotation(inst)
	end)

	inst.name = "Sign"

	inst:AddTag("CLICK")
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.distance = TUNING.SIGN_READ_DISTANCE

	inst:DoPeriodicTask(0, function(inst)
		local anglediff = -TheCamera:GetHeading() - inst.Transform:GetRotation() -- This is crazy subtractions! But it works??
		anglediff = anglediff + 90 -- account for animation offset
		while anglediff < 0 do anglediff = anglediff + 360 end
		while anglediff > 360 do anglediff = anglediff - 360 end
		local p = anglediff/360
		inst.AnimState:SetPercent("idle", p)
	end)
	
	inst.Transform:SetScale(1.4, 1.4, 1.4)
	
	return inst
end

return Prefab("heli_sign", create_sign, assets, nil)
