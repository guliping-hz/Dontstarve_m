function FindTag(tag) return TheSim:FindFirstEntityWithTag(tag) end

-- compare to floats with some precision
function cmp(x, y, prec)
	if not (x and y) then return false end
	if not (prec and type(prec)=="float") then prec = 0.001 end
	return ((x<(y+prec)) and (x>(y-prec)))
end

function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function ()
			i = i + 1
			if a[i] == nil then 
				return nil
			else 
				return a[i], t[a[i]]
	        	end
		end
	return iter
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function arraycount(a)
	local c = 0
	if a and (type(a)=="table") then
		for k,v in pairs(a) do c=c+1 end
	end
	return c
end

function GetCN(name)
	local p = GetPlayer()
	if p and p.components and p.components[name] and (type(p.components[name])=="table") then return p.components[name] else return nil end
end

function GetFreeKeyList(keycode) -- keycode = currently used key
	local keyslist = {}
	if not keycode then keycode = 0 end	
	local delta = KEY_A - string.byte("A")
	table.insert(keyslist, {text = "None", data = 0})
	if (keycode >= KEY_A) and (keycode <= KEY_Z) then
		table.insert(keyslist, {text = string.char(keycode-delta), data = keycode})
	end
	local function checkarray(a)
		for k,v in pairs(a) do 
			if k and (type(k)=="table") then return true end
		end
		return false
	end
	local kd = TheInput.onkeydown
	for i = KEY_A,KEY_Z,1 do
		local c = string.char(i-delta)
		if kd and kd.events and kd.events[i] and checkarray(kd.events[i]) then
			print ("GetKeys : key "..c.." is already used, skipping")
--			PrintArray(kd.events[i],"i["..c.."]")
		else
			table.insert(keyslist, {text = c, data = i})
		end
	end
	return keyslist
end

function tableMerge(t1, t2)
	if t2 then
		for k,v in pairs(t2) do
			if type(v) == "table" then
				if type(t1[k] or false) == "table" then
					tableMerge(t1[k] or {}, t2[k] or {})
				else
					t1[k] = v
				end
			else
				t1[k] = v
			end
		end
	end
	return t1
end

local arrayignore = {zinst=true, zparent=true, z_base=true,z__index=true, zHUD=true, zcomponents=true,zsg=true, zevent_listeners=true, 
			zevent_listening=true, zbrainfn=true, zbt=true, ztask=true}

function PrintArray(arr,name,tabcount)
	if not tabcount then tabcount = 0 end
	local tabs = string.rep("\t", tabcount) or ""
	tabs = ">"..tabs
	tabs = ""
	if not name then name = "a" end
	if (not arr) or (type(arr)~="table") then print (tabs..name.." = "..tostring(arr)) return end
	local r = {}
	for k, v in pairs(arr) do 
--	for k, v in ipairs(arr) do 
		local key = tostring(k)
		if type(v) == "table" then
			if (tabcount > 7) or arrayignore["z"..key] then
				table.insert(r,tabs..name.."["..key.."] = "..tostring(v))
			else
				r = tableMerge(r,PrintArray(arr[k],name.."["..key.."]",tabcount+1))
			end
		else
			table.insert(r,tabs..name.."["..key.."] = "..tostring(v))
		end
	end
	if tabcount == 0 then
		local function removespaces(v) return string.gsub(tostring(v), "^%s*", "") end
		table.sort(r,function (a, b) return string.lower(removespaces(a)) < string.lower(removespaces(b)) end)
		local c = 0
		for k, v in pairs(r) do 
			c = c + 1
			print(string.format("%03d",c).." "..tostring(v)) 
		end
	else
		return r
	end
end

function KillTask(inst,task)
	if inst and task and inst.pendingtasks and inst.pendingtasks[task] then
		if task.Cancel then task:Cancel() end
		if inst.pendingtasks[task] then inst.pendingtasks[task] = nil end
	end
end

function RemoveFNValue(t)
    local t2 = {}
    for k,v in pairs(t) do
        if type(v) == "table" then t2[k] = RemoveFNValue(v) else 
		if type(v)~="function" then t2[k] = v end
	end
    end
    return t2
end

--------------------------------------------------------------------------------------------------------------------------------------------

-- Very ugly solution of serialization:
-- must be replaced with proper

local serD1 = {"<01f9h9ef>","<02f03r20>","<03r2f22r>","<0422fe22>","<05f2f222>","<06sdv22f>","<07z234f3>"}
local serD2 = {"|01fdb3gf|","|023grg34|","|033gth63|","|0467j6h4|","|0543g336|","|06x454hg|","|07h35t3g|"}
local serMaxLvl = math.min(#serD1,#serD2)
local serTypes = {number = "N",string = "S", boolean = "B", table = "T"}

--simplified for debug
--serD1 = {"<1>","<2>","<3>","<4>","<5>","<6>","<7>"}
--serD2 = {"|1|","|2|","|3|","|4|","|5|","|6|","|7|"}

function splitstr(str, delim, maxNb)
	if string.find(str, delim) == nil then return {str} end
	if maxNb == nil or maxNb < 1 then maxNb = 0 end
	local result = {}
	local pat = "(.-)" .. delim .. "()"
	local nb = 0
	local lastPos
	for part, pos in string.gfind(str, pat) do
		nb = nb + 1
		result[nb] = part
		lastPos = pos
		if nb == maxNb then break end
	end
	if nb ~= maxNb then result[nb + 1] = string.sub(str, lastPos) end
	return result
end

function array2str(array,lvl)
	if not (lvl and (lvl > 0)) then lvl = 1 end
	if lvl > serMaxLvl then 
		print("array2str : max lvl limit reached!")
		return "" 
	end
	local s = ""
	local c = ""
	for k,v in pairs(array) do
		local tk = serTypes[type(k)]
		if not (tk and (type(tk)=="string") and string.len(tk) > 0 and (tk ~= "T")) then 
			print ("array2str("..tostring(array)..", "..tostring(lvl)..") : wrong type of `"..tostring(tk).."` key")
			return "" 
		end
		local tv = serTypes[type(v)]
		if not (tv and (type(tv)=="string") and string.len(tv) > 0) then 
			print ("array2str("..tostring(array)..", "..tostring(lvl)..") : wrong type of `"..tostring(tv).."` value")
			return "" 
		end
		if tv == "T" then c = array2str(v,lvl + 1) else c = tostring(v)	end
		if string.len(s) > 0 then s = s .. serD1[lvl] end
		s = s..tk..tostring(k)..serD2[lvl]..tv..c
	end
	return s
end

function str2array(str,lvl)
	if not (lvl and (lvl > 0)) then lvl = 1 end
	if lvl > serMaxLvl then 
		print("str2array : max lvl limit reached!")
		return {}
	end
	local arr={}
	local tmp=splitstr(str,serD1[lvl])
	local s = ""
	for k,v in pairs(tmp) do
		local a = splitstr(v,serD2[lvl])
		if (#a~=2) then
			print ("str2array : invalid number of fields")
			return {}
		end
		local kt = string.sub(a[1],1,1)
		if not (kt and (type(kt)=="string") and (string.len(kt)>0)) then
			print ("str2array : empty value")
			return {}
		end
		local kv = string.sub(a[1],2)
		local key = nil
		if kt == "S" then key = kv end
		if kt == "B" then key = (kv == "true") end
		if kt == "N" then key = tonumber(kv) end
		if not key then
			print ("str2array : invalid key type ("..tostring(kt)..")")
			return {}
		end
		local vv = string.sub(a[2],2)
		local vt = string.sub(a[2],1,1)
		arr[key] = nil
		if vt == "S" then arr[key] = vv end
		if vt == "B" then arr[key] = (vv == "true") end
		if vt == "N" then arr[key] = tonumber(vv) end
		if vt == "T" then arr[key] = str2array(vv,lvl+1) end
	end
	return arr
end

----------------------------------------------------------------------------------------------------------

function GoodString(s) -- returns true if string not empty
	return (s and (type(s)=="string") and (string.len(s)>0))
end

--from simplex code
function RemovePrefabHandler(inst,prefab,event)
	if not (inst and GoodString(prefab) and GoodString(event)) then 
		print ("RemovePrefabHandler - invalid parameters : "..tostring(inst)..", "..tostring(prefab)..", "..tostring(event))
		return false
	end
	if inst.event_listening[event] and inst.event_listening[event][inst] then
		for _, fn in ipairs(inst.event_listening[event][inst]) do
			local info = debug.getinfo(fn, "S")
			if info and info.source then
				if info.source:match("prefabs[/\\]"..prefab..".lua$") then
					inst:RemoveEventCallback(event, fn)
					return true
				end
			end
		end
	end
	return false
end

----------------------------------------------------------------------------------------------------------
--code by squeek
function GetMod(name_or_id)
    for _, mod in ipairs( _G.ModManager.mods ) do
        -- note: mod.modname is the mod directory name
        if mod.modinfo.name == name_or_id or mod.modinfo.id == name_or_id then
            return mod
        end
    end
    return nil
end
 
function IsModEnabled(name_or_id)
    return GetMod(name_or_id) ~= nil
end

function IsModLoaded(name_or_mod)
    local mod = type(name_or_mod) == "string" and GetMod(name_or_mod) or name_or_mod
    if mod then
        return table.contains( _G.ModManager:GetEnabledModNames(), mod.modname )
    end
    return false
end

----------------------------------------------------------------------------------------------------------

function ExecIfMod(modname,func)
	if func and type(func)=="function" and IsModEnabled(modname) then func() end
end

local function AOSFix(inst) 
	print ("AOS detected, adding switch support") 
	inst:AddComponent("switch") 
end

function PostAOSInit(prefab)
	if prefab and type(prefab)=="string" then 
		ExecIfMod("Always On Status",function() AddPrefabPostInit(prefab, AOSFix) end)
	end
end