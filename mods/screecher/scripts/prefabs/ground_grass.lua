local assets =
{
	Asset("ANIM", "exportedanim/ground_grass.zip"), 
}

local function blade(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()

	--We'll want to randomize the sprite on this at some point
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("ground_grass")
    inst.AnimState:SetBuild("ground_grass")
	local anims = {"frame_1", "frame_2", "frame_3", "frame_4", "frame_5"}
    inst.AnimState:PlayAnimation(anims[math.random(1, #anims)])

	inst.AnimState:SetMultColour(0.6, 0.6, 0.6, 1)

	return inst
end

local function spawner(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()

	if not TheSim:IsNetbookMode() then
		inst:DoTaskInTime(0, function()
			for i=1,10 do
				local blade = SpawnPrefab("ground_grass_blade")
				local x,y,z = inst.Transform:GetWorldPosition()
				local theta = math.random()*math.pi*2
				local d = math.random()+math.random() -- oooh distribution fancyness!
				if d > 1 then d = 2-d end
				local dist = d * 3
				local scale = (1-d) * 3
				blade.Transform:SetScale(scale,scale,scale)
				blade.Transform:SetPosition(x + math.cos(theta)*dist, y, z + math.sin(theta)*dist)
				blade.grassyparent = inst
			end
		end)
	end

	return inst
end

return Prefab("common/ground_grass", spawner, assets, nil),
       Prefab("common/ground_grass_blade", blade, assets, nil)
