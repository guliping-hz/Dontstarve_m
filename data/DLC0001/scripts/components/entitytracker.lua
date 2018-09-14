local EntityTracker = Class(function(self, inst)
	self.inst = inst
	self.entities = {}

end)

function EntityTracker:GetDebugString()
	local str = "\n"
		for k,v in pairs(self.entities) do
			str = str.."	--"..k.."\n"
			str = str..string.format("		--entity: %s \n", tostring(self.entities[k]))
		end
	return str
end

function EntityTracker:TrackEntity(name, inst)
	self.entities[name] = inst
	self.inst:ListenForEvent("onremove", function() self:ForgetEntity(name) end, inst)
end

function EntityTracker:ForgetEntity(name)
	self.entities[name] = nil
end

function EntityTracker:GetEntity(name)
	return self.entities[name]
end

function EntityTracker:OnSave()
	local data = {}
	local refs = {}

	for k,v in pairs(self.entities) do
		if k and v then
			if not data.entities then
				data.entities = {{name = k, GUID = v.GUID}}
			else
				table.insert(data.entities, {name = k, GUID = v.GUID})
			end

			table.insert(refs, v.GUID)
		end
	end

	return data, refs
end

function EntityTracker:LoadPostPass(ents, data)
	if data.entities then
		for k,v in pairs(data.entities) do
			if v then
				local ent = ents[v.GUID]
				if ent then
					ent = ent.entity
					self:TrackEntity(v.name, ent)
				end
			end
		end
	end
end

return EntityTracker