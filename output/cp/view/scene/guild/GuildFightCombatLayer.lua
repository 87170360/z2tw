local BLayer = require "cp.view.ui.base.BLayer"
local GuildFightCombatLayer = class("GuildFightCombatLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildFightCombatLayer:create(fightGuildInfo)
    local scene = GuildFightCombatLayer.new()
    scene.fightGuildInfo = fightGuildInfo
    return scene
end

function GuildFightCombatLayer:initListEvent()
    self.listListeners = {
        ["GetGuildFightCombatListRsp"] = function(data)
            self:updateGuildFightCombatView()
		end,
        [cp.getConst("EventConst").GetCombatListRsp] = function(proto)
            local layer = require("cp.view.scene.world.shaneevent.RiverCombatListLayer"):create(proto.combat_list, CombatConst.CombatType_Arena)
            self:addChild(layer, 100)
        end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildFightCombatLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_fight_combat.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Left.Text"] = {name = "Text_LeftName"},
		["Panel_root.Image_1.Image_Right.Text"] = {name = "Text_RightName"},
		["Panel_root.Image_1.ListView_List"] = {name = "ListView_List"},
		["Panel_root.Image_1.Panel_Model"] = {name = "Panel_Model"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
		["Panel_root.Image_1.Button_Mine"] = {name = "Button_Mine", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
end

function GuildFightCombatLayer:updateOneCombatInfo(i, info, img)
    local txtIndex = img:getChildByName("Text_Index")
    local txtName = img:getChildByName("Text_Name")
    local txtCount = img:getChildByName("Text_Count")
    
    txtIndex:setString(i)
    if info.name == "" then
        txtName:setString("幫派守衛")
    else
        txtName:setString(info.name)
    end
    txtCount:setString(info.count)
end

function GuildFightCombatLayer:updateGuildFightCombatView()
    self.Text_LeftName:setString(self.fightGuildInfo.left_name)
    self.Text_RightName:setString(self.fightGuildInfo.right_name)

    local key = ""
    if self.fightGuildInfo.left_guild < self.fightGuildInfo.right_guild then
        key = string.format( "%d_%d",self.fightGuildInfo.left_guild, self.fightGuildInfo.right_guild)
    else
        key = string.format( "%d_%d",self.fightGuildInfo.right_guild, self.fightGuildInfo.left_guild)
    end
    
    local listView = self.ListView_List
    listView:removeAllItems()
    local combatBothInfo = cp.getUserData("UserGuild"):getFightCombatList(key)
    if combatBothInfo == nil then
        local req = {}
        req.left = self.fightGuildInfo.left_guild
        req.right = self.fightGuildInfo.right_guild
        self:doSendSocket(cp.getConst("ProtoConst").GetGuildFightCombatListReq, req)
        return
    end

    local panelModel = self.Panel_Model
    local leftCountList, rightCountList = self:getCombatCount(combatBothInfo.left_fight_record.combat_list, combatBothInfo.right_fight_record.combat_list)
    local count = 0
    if table.nums(rightCountList) > table.nums(leftCountList) then
        count = table.nums(rightCountList)
    else
        count = table.nums(leftCountList)
    end

    for i = 1, count do
        local panel = panelModel:clone()
        listView:pushBackCustomItem(panel)
        panel:setVisible(true)

        local img = panel:getChildByName("Image_Left")
        if leftCountList[i] then
            self:updateOneCombatInfo(i, leftCountList[i], img)
        else
            img:setVisible(false)
        end
        
        local img = panel:getChildByName("Image_Right")
        if rightCountList[i] then
            self:updateOneCombatInfo(i, rightCountList[i], img)
        else
            img:setVisible(false)
        end
    end
end

function GuildFightCombatLayer:getCombatCount(leftCombatList, rightCombatList)
    local leftCountList = {}
    local rightCountList = {}
    local mineList = {}
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    for i, combatInfo in ipairs(leftCombatList) do
        if not leftCountList[combatInfo.id] then
            leftCountList[combatInfo.id] = {
                count = 0,
                name = combatInfo.name,
                id = combatInfo.id,
            }
        end

        if combatInfo.combat_id ~= 0 then
            leftCountList[combatInfo.id].count = leftCountList[combatInfo.id].count + 1
        end

        if combatInfo.id == roleAtt.id then
            if combatInfo.combat_id ~=0 then
                table.insert(mineList, combatInfo.combat_id)
            else
                table.insert(mineList, rightCombatList[i].combat_id)
            end
        end
    end

    for _, combatInfo in ipairs(rightCombatList) do
        if not rightCountList[combatInfo.id] then
            rightCountList[combatInfo.id] = {
                count = 0,
                name = combatInfo.name,
                id = combatInfo.id,
            }
        end

        if combatInfo.combat_id ~= 0 then
            rightCountList[combatInfo.id].count = rightCountList[combatInfo.id].count + 1
        end
    end

    self.mineList = mineList
    return table.values(leftCountList), table.values(rightCountList)
end

function GuildFightCombatLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Back" then
        self:removeFromParent()
    elseif nodeName == "Button_Mine" then
        if #self.mineList == 0 then
            cp.getManager("ViewManager").gameTip("沒有你的對戰記錄")
            return
        end
        local req = {}
        req.combat_type = CombatConst.CombatType_GuildFight
        req.time = cp.getManager("TimerManager"):getTime()-24*3600*100
        req.max_num = 40
        req.combat_list = self.mineList
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatListReq, req)
	end
end

function GuildFightCombatLayer:onEnterScene()
	self:updateGuildFightCombatView()
end

function GuildFightCombatLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildFightCombatLayer