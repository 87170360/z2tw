local BLayer = require "cp.view.ui.base.BLayer"
local TowerMainLayer = class("TowerMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function TowerMainLayer:create()
	local scene = TowerMainLayer.new()
	scene:updateTowerMainView()
    return scene
end

function TowerMainLayer:initListEvent()
    self.listListeners = {
        ["FightTowerFloorRsp"] = function(data)
            local combatReward = {
                currency_list = {},
                item_list = data.item_list
            }
            cp.getUserData("UserCombat"):setValue("Floor", data.floor)
            cp.getUserData("UserCombat"):setCombatReward(combatReward)

            local fightInfo = {floor = data.floor}
            cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(fightInfo)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
        ["ResetTowerFightRsp"] = function(data)
            self:initTowerMainView()
            self:scrollToFloor(1, 0.5)
            self:updateTowerMainView()
		end,
        ["FightTowerQuickRsp"] = function(data)
            self:updateTowerMainView()
		end,
        ["QuickFightDoneRsp"] = function(data)
            self:updateTowerMainView()
            local towerData = cp.getUserData("UserTower"):getTowerData()
            self:scrollToFloor(towerData.floor+1, 0.5)
            if #data.item_list == 0 then return end
            local itemList = {}
			for _, itemInfo in ipairs(data.item_list) do
				itemInfo.id = itemInfo.item_id
                itemInfo.num = itemInfo.item_num
                table.insert(itemList, itemInfo)
			end
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
		["UpdateTowerGuideRsp"] = function(proto)
			self:runGuideStep()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function TowerMainLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_tower/uicsb_tower_main.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
		["Panel_root.Image_Finish"] = {name = "Image_Finish"},
		["Panel_root.ScrollView_bg"] = {name = "ScrollView_bg"},
		["Panel_root.ScrollView_front"] = {name = "ScrollView_front"},
		["Panel_root.ScrollView_front.Image_Floors"] = {name = "Image_Floors"},
		["Panel_root.ScrollView_front.Image_FloorModel"] = {name = "Image_FloorModel"},
		["Panel_root.ScrollView_front.Panel_Enemy"] = {name = "Panel_Enemy"},

        ["Panel_root.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
        ["Panel_root.Button_Rank"] = {name = "Button_Rank", click="onBtnClick"},
        ["Panel_root.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_1.Button_Rule"] = {name = "Button_Rule", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Reset"] = {name = "Button_Reset", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Done"] = {name = "Button_Done", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Begin"] = {name = "Button_Begin", click="onBtnClick"},
		["Panel_root.Image_1.Text_ResetCost"] = {name = "Text_ResetCost"},
		["Panel_root.Image_1.Image_ResetCost"] = {name = "Image_ResetCost"},
		["Panel_root.Image_1.Text_DoneCost"] = {name = "Text_DoneCost"},
		["Panel_root.Image_1.Image_DoneCost"] = {name = "Image_DoneCost"},
		["Panel_root.Image_1.Text_RemainTime"] = {name = "Text_RemainTime"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)

    self.towerConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("TowerConfig"), ";")
    self:initTowerMainView()
    ccui.Helper:doLayout(self.rootView)

    self.ScrollView_bg:jumpToBottom()
    self.ScrollView_front:jumpToBottom()

    self.ScrollView_front:addEventListenerScrollView(function(scrollView, event)
        if event == 4 then
            local pos = scrollView:getInnerContainerPosition()
            local deltaHeight = scrollView:getInnerContainerSize().height - scrollView:getSize().height
            local percent = (1-math.abs(pos.y)/deltaHeight)*100
            self.ScrollView_bg:scrollToPercentVertical(percent, 0.1, false)
        end
    end)

    --[[
    local floor = 1
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        if floor == 100 then
            return
        end
        log("scroll to floor "..floor)
        self:scrollToFloor(floor, 0.5)
        floor = floor + 1
    end), cc.DelayTime:create(2))))
    ]]
end

local npcName = {
    "", "守關大將", "守關BOSS", "終極boss"
}
function TowerMainLayer:scrollToFloor(floor, time)
    if floor > self.towerConfig[7] then
        floor = self.towerConfig[7]
    end
    local towerData = cp.getUserData("UserTower"):getTowerData()
    local imgFloor = self.Image_Floors:getChildByName("Image_Floor"..floor)
    local height = imgFloor:getPositionY()
    local deltaHeight = self.ScrollView_front:getInnerContainerSize().height - self.ScrollView_front:getSize().height
    local percent = 100
    if height > display.height / 2 then
        percent = (1-(height-display.height/2)/deltaHeight)*100
    end

    if percent < 0 then percent = 0 end
    if time == 0 then
        self.Panel_Enemy:setPosition(cc.p(720,height-50))
        self.ScrollView_bg:jumpToPercentVertical(percent)
        self.ScrollView_front:jumpToPercentVertical(percent)
    else
        self.Panel_Enemy:runAction(cc.MoveTo:create(time-0.05, cc.p(720,height-50)))
        self.ScrollView_bg:scrollToPercentVertical(percent, time, false)
        self.ScrollView_front:scrollToPercentVertical(percent, time, false)
    end
    local beginFloor = floor - 10
    local endFloor = floor + 10
    for i=beginFloor, endFloor do
        local imgFloor = self.Image_Floors:getChildByName("Image_Floor"..i)
        if imgFloor then
            if i ~= 1 then
                imgFloor:getChildByName("Image_Floor"):setVisible(false)
            else
                imgFloor:setVisible(true)
            end
            local index = 0
            if i == 1 then
                index = 1
            elseif i == self.towerConfig[7] then
                index = 6
            elseif i < floor then
                index = 2
            elseif i == floor then
                imgFloor:getChildByName("Image_Floor"):setVisible(true)
                index = 3
            else
                index = 4
            end
            
            if i <= towerData.floor and not towerData.began and towerData.quick_begin == 0 then
                imgFloor:loadTexture(string.format("ui_tower_module65_pata_tadianliang_%02d.png", index), ccui.TextureResType.plistType)
            elseif i ~= 1 then
                imgFloor:loadTexture(string.format("ui_tower_module65_pata_ta_%02d.png", index), ccui.TextureResType.plistType)
            elseif i == 1 then
                imgFloor:setVisible(false)
            end
        end
    end

    local floorConfig = cp.getManager("ConfigManager").getItemByKey("GameTower", floor)
    local npcEntry = cp.getManager("ConfigManager").getItemByKey("GameNpc", floorConfig:getValue("Npc"))
    local modelEntry = cp.getManager("ConfigManager").getItemByKey("GameModel", npcEntry:getValue("ModelID"))

    local imgName = self.Panel_Enemy:getChildByName("Image_Name")
    local txtName = imgName:getChildByName("Text_Name")
    local txtFight = self.Panel_Enemy:getChildByName("Text_Fight")
    local imgHead = self.Panel_Enemy:getChildByName("Image_Head")
    txtName:setString(npcEntry:getValue("Name"))
    txtFight:setString(npcEntry:getValue("Fight"))
    imgHead:loadTexture(cp.DataUtils.getModelFace(modelEntry:getValue("Face")))

    if floorConfig:getValue("Level") == 1 then
        imgName:setVisible(false)
    else
        imgName:setVisible(true)
        txtName:setString(npcName[floorConfig:getValue("Level")])
    end

    local itemList = {}
    
    for _, itemInfo in ipairs(cp.getUtils("DataUtils").split(floorConfig:getValue("FirstReward"), ";=")) do
        table.insert(itemList, {
            id = itemInfo[2], num = itemInfo[3], shoutong = true,
        })
    end
    
    for _, itemInfo in ipairs(cp.getUtils("DataUtils").split(floorConfig:getValue("NormalReward"), ";=")) do
        table.insert(itemList, {
            id = itemInfo[2], num = itemInfo[3], gailv = itemInfo[1] ~= 100,
        })
    end

    local pos = cc.p(120, 210)
    for i, itemInfo in ipairs(itemList) do
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
        self.Image_1:removeChildByName("Item_"..i)
		local item = require("cp.view.ui.icon.ItemIcon"):create({
            id = itemInfo.id, num = itemInfo.num, Name = cfgItem:getValue("Name") ,
            Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")
        })
        item:setName("Item_"..i)
        self.Image_1:addChild(item)
        item:setScale(1)
        if itemInfo.shoutong then
            item:addFlag("shoutong")
        elseif itemInfo.gailv then
            item:addFlag("gailv")
        end
        
		item:setItemClickCallBack(function(info)
		    local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
    		self:addChild(layer, 100)
			layer:hidePlaceAndButtons()
        end)
        item:setPosition(pos)
        pos.x = pos.x + 120
    end

    if towerData.floor == self.towerConfig[7] and not towerData.began and towerData.quick_begin == 0 then
        self.Image_Finish:setVisible(true)
        self.Panel_Enemy:setVisible(false)
    else
        self.Image_Finish:setVisible(false)
        self.Panel_Enemy:setVisible(true)
    end 
end

function TowerMainLayer:initTowerMainView()
    local towerData = cp.getUserData("UserTower"):getTowerData()
    local originScale = 1
    local dstScale = 0.7
    local height = 160
    local pos = cc.p(240, 598)
    for i=1, self.towerConfig[7] do
        local scale = 1 - ((originScale-dstScale)/(98 - 2))*(i-2)
        local img = self.Image_Floors:getChildByName("Image_Floor"..i)
        if not img then
            img = self.Image_FloorModel:clone()
            self.Image_Floors:addChild(img, i)
            img:setScale(scale)
            img:setName("Image_Floor"..i)
            img:setVisible(true)
        end

        if i <= towerData.floor and not towerData.began and towerData.quick_begin == 0 then
            if i == 1 then
                img:setVisible(true)
            elseif i == self.towerConfig[7] then
                img:loadTexture("ui_tower_module65_pata_tadianliang_06.png", ccui.TextureResType.plistType)
            else
                img:loadTexture("ui_tower_module65_pata_tadianliang_02.png", ccui.TextureResType.plistType)
            end
        end

        if i > 1 then
            img:setPosition(pos)
            pos.y = pos.y + height * scale
            img:getChildByName("Image_Floor"):setVisible(false)
            img:getChildByName("Image_Floor"):getChildByName("Text_Floor"):setString("第 "..i.." 層")
        end
    end
    
    local height = pos.y + 350
    self.ScrollView_front:setInnerContainerSize(cc.size(720, height))
    self.ScrollView_bg:setScrollBarEnabled(false)
    self.ScrollView_front:setScrollBarEnabled(false)
    self.Image_Finish:setVisible(false)
    self.Panel_Enemy:setVisible(true)
    if towerData.quick_begin == 0 then
        if towerData.floor ~= self.towerConfig[7] or towerData.quick_begin > 0 then
            self:scrollToFloor(towerData.floor + 1, 0)
        end
    else
        self:scrollToFloor(1, 0)
    end

end

function TowerMainLayer:updateTowerMainView()
    local towerData = cp.getUserData("UserTower"):getTowerData()
    local floorConfig = cp.getManager("ConfigManager").getItemByKey("GameTower", towerData.floor)
    if towerData.began then
        cp.getManager("ViewManager").setEnabled(self.Button_Reset, false)
        self.Text_ResetCost:setVisible(false)
        self.Image_ResetCost:setVisible(false)
    elseif towerData.count >= self.towerConfig[2] then
        cp.getManager("ViewManager").setEnabled(self.Button_Reset, false)
        self.Text_ResetCost:setVisible(true)
        self.Image_ResetCost:setVisible(false)
        self.Text_ResetCost:setString("今日重置次數已用完")
    else
        if towerData.count >= self.towerConfig[1] then
            self.Text_ResetCost:setVisible(true)
            self.Image_ResetCost:setVisible(true)
            self.Text_ResetCost:setString(self.towerConfig[3])
        else
            self.Text_ResetCost:setVisible(true)
            self.Image_ResetCost:setVisible(false)
            self.Text_ResetCost:setString("本次重置免費")
        end

        cp.getManager("ViewManager").setEnabled(self.Button_Reset, true)
    end

    local now = cp.getManager("TimerManager"):getTime()
    local quick_cost = self.towerConfig[4] * towerData.floor * 60
    if towerData.quick_begin + quick_cost < now then
        self.Button_Done:setVisible(false)
        self.Text_DoneCost:setVisible(false)
        self.Image_DoneCost:setVisible(false)
    else
        self.Button_Done:setVisible(true)
        self.Text_DoneCost:setVisible(true)
        self.Image_DoneCost:setVisible(true)
    end

    self.Text_RemainTime:setVisible(false)
    self.Text_RemainTime:stopAllActions()
    if towerData.began and towerData.floor > 0 then
        self.Button_Begin:getChildByName("Text"):setString("快速爬塔")
        cp.getManager("ViewManager").initButton(self.Button_Begin, function()
            self:doSendSocket(cp.getConst("ProtoConst").FightTowerQuickReq, {})
        end, 0.9)
    else
        self.Text_RemainTime:setVisible(true)
        if towerData.quick_begin + quick_cost < now then
            self.Text_RemainTime:setString(string.format( "可失敗次數%d/%d",self.towerConfig[6]-towerData.fail, self.towerConfig[6] ))
            self.Button_Begin:getChildByName("Text"):setString("挑    戰")

            cp.getManager("ViewManager").initButton(self.Button_Begin, function()
                if towerData.floor == self.towerConfig[7] and not towerData.began then
                    cp.getManager("ViewManager").gameTip("您已通關修羅塔，可通過重置快速爬塔")
                    return
                end
                self:doSendSocket(cp.getConst("ProtoConst").FightTowerFloorReq, {})
            end, 0.9)
        else
            cp.getManager("ViewManager").setEnabled(self.Button_Reset, false)
            self.Button_Begin:getChildByName("Text"):setString("進行中..")
            self.Text_RemainTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                local now = cp.getManager("TimerManager"):getTime()
                local remainTime = towerData.quick_begin + quick_cost - now
                local percent = remainTime / (self.towerConfig[4] * self.towerConfig[7] * 60)
                local cost = math.ceil(self.towerConfig[5] * percent)
                if cost == 0 then cost = 1 end
                if cost > self.towerConfig[5] then cost = self.towerConfig[5] end
                self.Text_DoneCost:setString(cost)
                if remainTime == 0 then
                    self:doSendSocket(cp.getConst("ProtoConst").QuickFightDoneReq, {})
                    self.Text_RemainTime:stopAllActions()
                end

                if remainTime < 0 then
                    remainTime = 0
                end
                self.Text_RemainTime:setString("剩餘時間："..cp.getUtils("DataUtils").formatTimeRemainEx(remainTime))
            end), cc.DelayTime:create(1))))
        end
    end

    if towerData.fail >= self.towerConfig[6] then
        cp.getManager("ViewManager").setEnabled(self.Button_Begin, false)
    else
        cp.getManager("ViewManager").setEnabled(self.Button_Begin, true)
    end
end

function TowerMainLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Back" then
        self:dispatchViewEvent("GetTowerDataRsp", false)
    elseif nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_tower_rule.txt")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("tower_rule", desc)
        self:addChild(layer, 100)
    elseif nodeName == "Button_Rank" then
        local layer = require("cp.view.scene.rank.RankMainLayer"):create(3)
        self:addChild(layer, 100)
    elseif nodeName == "Button_Reset" then
        self:doSendSocket(cp.getConst("ProtoConst").ResetTowerFightReq, {})
    elseif nodeName == "Button_Done" then
        self:doSendSocket(cp.getConst("ProtoConst").QuickFightDoneReq, {})
    end
end

function TowerMainLayer:onEnterScene()
    self:updateTowerMainView()
    local time = 0
    if self.enterAgain then
        time = 0.5
    end

    local towerData = cp.getUserData("UserTower"):getTowerData()
    if towerData.began or towerData.quick_begin > 0 then
        self:scrollToFloor(1, time)
    else
        self:scrollToFloor(towerData.floor + 1, time)
    end
    self.enterAgain = true
    
	self:runGuideStep()
end

function TowerMainLayer:onExitScene()
    self:unscheduleUpdate()
end

function TowerMainLayer:runGuideStep()
	self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
	local guideStep = cp.getUserData("UserTower"):getTowerData().guide_step
	local contentTable = require("cp.story.TowerGuide")[guideStep]
    if not contentTable then
        return
	else
		local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 1)
		gamePopTalk:setPosition(cc.p(display.width/2,0))
		gamePopTalk:resetTalkText(contentTable)
		gamePopTalk:resetBgOpacity(150)
		gamePopTalk:setFinishedCallBack(function()
			gamePopTalk:removeFromParent()
			local req = {}
			req.step = guideStep
			self:doSendSocket(cp.getConst("ProtoConst").UpdateTowerGuideReq, req)
		end)
		gamePopTalk:hideSkip()
		self:addChild(gamePopTalk, 100)
	end
end

return TowerMainLayer