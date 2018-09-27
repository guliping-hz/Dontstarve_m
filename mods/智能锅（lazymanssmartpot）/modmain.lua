Assets = {}
PrefabFiles = {}

local IsDST = GLOBAL.TheSim.GetGameID and GLOBAL.TheSim:GetGameID() == "DST"
local IsServer = not IsDST or GLOBAL.TheNet:GetIsServer()

local IsDLC1 = not IsDST and GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS)
local IsDLC2 = false
local status, temp = GLOBAL.pcall(function()
    return not IsDST and GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC)
end);
if (status) then
    IsDLC2 = temp
end

local IsMainGame = not (IsDLC1 or IsDLC2)

local TheInput = GLOBAL.TheInput
local function getworld()
    return IsDST and GLOBAL.TheWorld or GLOBAL.GetWorld()
end
local function getplayer()
    return IsDST and GLOBAL.ThePlayer or GLOBAL.GetPlayer()
end


local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local ST = GLOBAL.STRINGS
local unpack = GLOBAL.unpack

local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Image = require "widgets/image"
local cooking = require 'cooking'

local LAN = GetModConfigData("LANGUAGE")

if LAN then require 'smtck_Ch'
else require 'smtck_En' end
local textfont = GLOBAL.DIALOGFONT --GetModConfigData("LANGUAGE") and GLOBAL.BUTTONFONT or GLOBAL.DIALOGFONT

--基础
local function isnormalchest(chest, client)
    if client then return chest and (chest:HasTag('A_AEdit_Container') or chest:HasTag('A_AEdit_Pet') or chest:HasTag('A_AEdit_Fridge')) end
    local cpn_ctn = chest and chest.components.container
    return cpn_ctn and cpn_ctn.acceptsstacks ~= false and not (chest.components.equippable or chest.components.stewer or chest.components.drivable)
end
local function isfreezer(chest, client)
    return chest and chest:HasTag('fridge')
end
local function ispet(chest, client)
    if client then return chest and chest:HasTag('A_AEdit_Pet') end
    return chest and chest.components.locomotor
end
local function getbackpack(player)
    local pack = nil
    local cpn_inv = player.components.inventory
    for c, b in pairs(cpn_inv.opencontainers) do
        if b and c and c.components.equippable then
            local cpn_ctn_pack = pack and pack.components.container
            local cpn_ctn_c = c.components.container
            pack = pack and cpn_ctn_pack.numslots >= cpn_ctn_c.numslots and pack or c
        end
    end
    return pack
end
local function getopenchest(player)
    local chest = nil
    local cpn_inv = player.components.inventory
    for c, b in pairs(cpn_inv.opencontainers) do
        if b and c and isnormalchest(c) then
            local cpn_ctn_chest = chest and chest.components.container
            local cpn_ctn_c = c.components.container
            chest = chest and cpn_ctn_chest.numslots >= cpn_ctn_c.numslots and chest or c
        end
    end
    return chest
end

local function Pot_PI(inst)
    inst:AddComponent('smtck')
end
local function Stewer_PI(self, inst)
    local oldfn = self.StartCooking
    function self:StartCooking(...)
        if not inst.components.smtck then return oldfn(self, ...) end
        local cpn_cp = inst.components.smtck
        local prefablist = {}
        if inst.components.container and inst.components.container:IsFull() then
            for k, v in pairs(inst.components.container.slots) do
                prefablist[v.prefab] = 1 + (prefablist[v.prefab] or 0)
            end
        end
        --真实材料
        if not inst:HasTag('A_Acasual_ing') then
            oldfn(self, ...)
            cpn_cp:AddNewRecipe(prefablist, self.product)
            return
        end
        --虚拟材料
        local player = getplayer()
        local result = nil
        if cpn_cp:ShouldStart({ player, getbackpack(player), getopenchest(player) }) then
            cpn_cp:ClearCookpot()
            player.components.talker:Say(ST.smtckstr.warning1)--('我 想 我 应 该 重 新 整 理 下 食 材')
            return
        end --填充后关闭背包或冰箱
        --虚拟填充材料 重新检测是否可以填满锅  可以的话就删除容器中相应物品
        if cpn_cp:CanStuffCookpot(prefablist) then
            cpn_cp:RemoveItemsFromInvs(prefablist)
            result = oldfn(self, ...)
        else --填充后把背包或箱子中材料放地上 或 拿起
            cpn_cp:ClearCookpot()
            player.components.talker:Say(ST.smtckstr.warning2)--('好 坏 啊 你 ！  差 点 游 戏 就 崩 溃 了 ！')
            return
        end
        cpn_cp:AddNewRecipe(prefablist, self.product)
        return result --nil
    end
end
AddPrefabPostInit('cookpot', Pot_PI)
AddPrefabPostInit('portablecookpot', Pot_PI)
AddComponentPostInit('stewer', Stewer_PI)

local function CTN_PC(self)
    self.smtckbuttons = {}
    local function kill_children(tb)
        for k, v in pairs(tb) do
            if type(k) == 'string' then
                kill_children(v)
            else
                v:Kill()
                tb[k] = nil
            end
        end
    end
    --开锅盖
    local OldO = self.Open
    function self:Open(container, doer, ...)
        OldO(self, container, doer, ...)
        if container.components.smtck then
            local function predict_food(button, productinfo)
                if not button then return end
                if button.item then button.item:Remove() button.item = nil end
                if productinfo then
                    button.item = GLOBAL.SpawnPrefab(productinfo.name)
                    if button.item then
                        local stringinfo = container.components.smtck:GetStringInfo() or ''
                        local stringinfo1 = ST.smtckstr.page .. (ST.NAMES[string.upper(productinfo.name)] or ST.smtckstr.unknown)
                        local stringinfo2 = ST.smtckstr.chance .. (productinfo.chance * 100) .. '%  |  ' .. ST.smtckstr.product_spoilage .. (productinfo.product_spoilage * 100) .. '%'
                        button:SetTextures(button.item.components.inventoryitem:GetAtlas(), button.item.components.inventoryitem:GetImage())
                        button:SetText(stringinfo1 .. '\n' .. stringinfo .. '\n' .. stringinfo2)
                        return
                    end
                end
                button:SetText(ST.smtckstr.book_open)
                button:SetTextures("images/inventoryimages.xml", "waxwelljournal.tex")
            end
            self.smtckbuttons[1] = self:AddChild(ImageButton("images/inventoryimages.xml", "waxwelljournal.tex"))
            self.smtckbuttons[1]:SetPosition(Vector3(0, 220, 0))
            self.smtckbuttons[1]:SetText(ST.smtckstr.book_open)
            self.smtckbuttons[1]:SetFont(textfont) --BUTTONFONT
            self.smtckbuttons[1]:SetTextSize(40)
            self.smtckbuttons[1].text:SetPosition(0, 100, 0)
            self.smtckbuttons[1]:SetTextColour(unpack(ST.smtckcolours[3]))
            self.smtckbuttons[1]:SetTextFocusColour(unpack(ST.smtckcolours[1]))
            self.smtckbuttons[1]:SetOnClick(function()
                container.components.smtck:ClearCookpot()
            end)
            self.smtckbuttons[2] = self.smtckbuttons[1]:AddChild(ImageButton(GLOBAL.HUD_ATLAS, "turnarrow_icon.tex"))
            self.smtckbuttons[2]:SetScale(-0.85, 0.85, 0.85)
            self.smtckbuttons[2]:SetPosition(-66, 0, 0)
            self.smtckbuttons[2]:SetOnClick(function()
                container.components.smtck:ClearCookpot()
                container.components.smtck:PreviousRecipe()
                container.components.smtck:StuffCookpot({ doer, getbackpack(doer), getopenchest(doer) })
            end)
            self.smtckbuttons[3] = self.smtckbuttons[1]:AddChild(ImageButton(GLOBAL.HUD_ATLAS, "turnarrow_icon.tex"))
            self.smtckbuttons[3]:SetScale(0.85, 0.85, 0.85)
            self.smtckbuttons[3]:SetPosition(66, 0, 0)
            self.smtckbuttons[3]:SetOnClick(function()
                container.components.smtck:ClearCookpot()
                container.components.smtck:NextRecipe()
                container.components.smtck:StuffCookpot({ doer, getbackpack(doer), getopenchest(doer) })
            end)
            --bg
            self.smtckbuttons[4] = self.smtckbuttons[1]:AddChild(Image(GLOBAL.HUD_ATLAS, "tab_researchable.tex"))
            self.smtckbuttons[4]:SetScale(0.63, 0.63, 0.63)
            self.smtckbuttons[4]:MoveToBack()
            --food_method   
            self.smtckbuttons.imagebuttons = {}
            local B_M = {
                { atlasname = nil, imagename = 'bonestew.tex', fn = function() container.components.smtck:SetMethod('hunger') container.components.smtck.currentkey = 0 self.smtckbuttons[3].onclick() end }, --饱食度
                { atlasname = nil, imagename = 'dragonpie.tex', fn = function() container.components.smtck:SetMethod('health') container.components.smtck.currentkey = 0 self.smtckbuttons[3].onclick() end }, --血量
                { atlasname = nil, imagename = 'taffy.tex', fn = function() container.components.smtck:SetMethod('sanity') container.components.smtck.currentkey = 0 self.smtckbuttons[3].onclick() end }, --精神
            }

            local function B_I_C(num)
                for k, v in ipairs(self.smtckbuttons.imagebuttons) do
                    local cl = k == num and 1 or 0
                    v.image:SetTint(cl, cl, cl, 1)
                end
            end
            for k, v in ipairs(B_M) do
                self.smtckbuttons.imagebuttons[k] = self:AddChild(ImageButton((v['atlasname'] or 'images/inventoryimages.xml'), v['imagename'], v['imagename']))
                local button = self.smtckbuttons.imagebuttons[k]
                local pt = {-100, 175, 0 }
                button.fn = v['fn']
                button:SetScale(0.75, 0.75, 0.75)
                button:SetPosition(Vector3(pt[1], pt[2] - k * 50, pt[3]))
                button:SetOnClick(function() if button.fn then button.fn() end B_I_C(k) end)
            end
            local zhyx = { hunger = 1, health = 2, sanity = 3,}
            B_I_C(zhyx[container.components.smtck:GetMethod()])
            --event
            --快速定位食谱按钮
            self.smtckbuttons.textbuttons = {}
            if not self.A_Atextbuttonchangefn then
                self.A_Atextbuttonchangefn = function()
                    local names = {}
                    for k, v in pairs(self.smtckbuttons.textbuttons) do
                        if v then
                            v:Kill()
                            self.smtckbuttons.textbuttons[k] = nil
                        end
                    end
                    local valid_recipes = container.components.smtck:GetValidRecipes()
                    for k, v in ipairs(valid_recipes) do
                        if not GLOBAL.table.contains(names, v.name) then
                            table.insert(names, v.name)
                        end
                    end
                    for i, foodname in ipairs(names) do
                        self.smtckbuttons.textbuttons[i] = self:AddChild(TextButton())
                        local button = self.smtckbuttons.textbuttons[i]
                        local pt = { 150, 175, 0 }
                        local size = i == 1 and 36 or i == 2 and 35 or i == 3 and 34 or 33
                        button:SetTextSize(size)
                        button:SetFont(textfont)
                        local cl = i == 1 and ST.smtckcolours[5] or i == 2 and ST.smtckcolours[6] or i == 3 and ST.smtckcolours[7] or ST.smtckcolours[3]
                        button:SetColour(unpack(cl))--(32/255,252/255,242/255,1)
                        button:SetOverColour(unpack(ST.smtckcolours[8]))--(255/255,20/255,147/255,1)--(252/255,  2/255,  102/255, 1)
                        button:SetPosition(Vector3(pt[1], pt[2] - i * 33, pt[3]))
                        button:SetText(ST.NAMES[string.upper(foodname)] or 'unknown')
                        button:SetOnClick(function()
                            container.components.smtck:ToRecipes(foodname)
                            container.components.smtck:ClearCookpot()
                            container.components.smtck:StuffCookpot()
                        end)
                    end
                end
            end
            self.inst:ListenForEvent("permute_tx_bt", self.A_Atextbuttonchangefn, container)
            if not self.A_Aonitemgetfn then
                self.A_Aonitemgetfn = function(container, data)
                    local productinfo = container.components.smtck:GetProductInfo()
                    if productinfo then
                        predict_food(self.smtckbuttons[1], productinfo)
                    end
                end
            end
            self.inst:ListenForEvent("itemget", self.A_Aonitemgetfn, container)
            if not self.A_Aonitemlosefn then
                self.A_Aonitemlosefn = function(container)
                    predict_food(self.smtckbuttons[1], nil)
                end
            end
            self.inst:ListenForEvent("itemlose", self.A_Aonitemlosefn, container)
            self.A_Aonitemgetfn(container)
        end
    end
    --
    local OldC = self.Close
    function self:Close(...)
        kill_children(self.smtckbuttons)
        if self.A_Atextbuttonchangefn and self.container then
            self.inst:RemoveEventCallback("permute_tx_bt", self.A_Atextbuttonchangefn, self.container)
        end
        if self.A_Aonitemgetfn and self.container then
            self.inst:RemoveEventCallback("itemget", self.A_Aonitemgetfn, self.container)
        end
        if self.A_Aonitemlosefn and self.container then
            self.inst:RemoveEventCallback("itemget", self.A_Aonitemlosefn, self.container)
        end
        if self.container and self.container.components.smtck then self.container.components.smtck:OnCookpotClose() end
        return OldC(self, ...)
    end
end
AddClassPostConstruct("widgets/containerwidget", CTN_PC)
--[[if not IsDST then

	
else --=================ds---------dst===================-------


	--AddReplicableComponent("smatck")

-----------------------------------------------ModRPCHandler----------------------------------------------

	AddModRPCHandler("smart_cooker","set_tosaysth", function(player)		--
		player.components.talker:Say("Someone is editing..I should wait")
	end)
	AddModRPCHandler("smart_cooker","set_editing_totrue", function(player, tar)
		if tar and tar.replica.ctninfo then 
			tar.replica.smatck._editing:set(true)
		end	
	end)
-----------------------------------------------ModRPCHandler end----------------------------------------------
end
--]]