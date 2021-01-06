local BLayer = require "cp.view.ui.base.BLayer"
local ActivitySignLayer = class("ActivitySignLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ActivitySignLayer:create()
    local scene = ActivitySignLayer.new()
    return scene
end

function ActivitySignLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").SignRsp] = function(itemList)
            self:updateActivitySignView()
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
        [cp.getConst("EventConst").GetSummarySignRewardRsp] = function(itemList)
            self:updateActivitySignView()
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
        [cp.getConst("EventConst").SignAllRsp] = function(itemList)
            self:updateActivitySignView()
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
        [cp.getConst("EventConst").GetUpgradeGiftRsp] = function(itemList)
            self:checkNeedNoticeUpgradeGift()
		end,
        [cp.getConst("EventConst").GetFightGiftRsp] = function(itemList)
            self:checkNeedNoticeFightGift()
		end,
        [cp.getConst("EventConst").GetPhysicalRsp] = function(itemList)
            self:checkNeedNoticePhysicalGift()
        end,
        
        [cp.getConst("EventConst").InviteRsp] = function(data)	
			self:checkNeedNoticeInviteGift()
        end,
        
        [cp.getConst("EventConst").ChangeFirstRechargeState] = function(evt)
            if self.FirstRechargeGift ~= nil then
                self.FirstRechargeGift:setVisible(false)
                self.FirstRechargeGift:removeFromParent()
            end 
            self.FirstRechargeGift = nil
            if self["Panel_8"] then
                self.ListView_Activity:removeChild(self["Panel_8"])
                self["Panel_8"] = nil
            end
            self.Image_bg:setVisible(true)
            self:updateActiveType(1)
            self:updateActivitySignView()
            local today = cp.getUserData("UserSign"):getToday()
            local signFlag = cp.getUserData("UserSign"):getSignFlag(today)
            if signFlag == 0 then
                local req = {}
                self:doSendSocket(cp.getConst("ProtoConst").SignReq, {})
            end

        end
    }
end

--初始化界面，以及設定界面元素標籤
function ActivitySignLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_sign.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Panel_SignModel"] = {name = "Panel_SignModel"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_content_bg"] = {name = "Image_content_bg"},
        ["Panel_root.Image_bg.Image_4"] = {name = "Image_4"},
        ["Panel_root.Image_bg.ScrollView_Sign"] = {name = "ScrollView_Sign"},
        ["Panel_root.Image_bg.Panel_reward"] = {name = "Panel_reward"},
        ["Panel_root.Image_bg.Panel_reward.Node_Reward5"] = {name = "Node_Reward5", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Node_Reward10"] = {name = "Node_Reward10", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Node_Reward15"] = {name = "Node_Reward15", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Node_Reward20"] = {name = "Node_Reward20", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Node_Reward30"] = {name = "Node_Reward30", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Button_Sign"] = {name = "Button_Sign", click="onBtnClick"},
		["Panel_root.Image_bg.Panel_reward.Panel_Progress"] = {name = "Panel_Progress"},


        
        ["Panel_root.Image_1.Button_Prev"] = {name = "Button_Prev"},
        ["Panel_root.Image_1.Button_Next"] = {name = "Button_Next"},
        ["Panel_root.Image_1.ListView_Activity"] = {name = "ListView_Activity"},
        ["Panel_root.Image_1.ListView_Activity"] = {name = "ListView_Activity"},
        ["Panel_root.Image_1.ListView_Activity.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Image_1.ListView_Activity.Panel_2"] = {name = "Panel_2"},
        ["Panel_root.Image_1.ListView_Activity.Panel_3"] = {name = "Panel_3"},
        ["Panel_root.Image_1.ListView_Activity.Panel_4"] = {name = "Panel_4"},
        ["Panel_root.Image_1.ListView_Activity.Panel_5"] = {name = "Panel_5"},
        ["Panel_root.Image_1.ListView_Activity.Panel_6"] = {name = "Panel_6"},
        ["Panel_root.Image_1.ListView_Activity.Panel_7"] = {name = "Panel_7"},
        ["Panel_root.Image_1.ListView_Activity.Panel_8"] = {name = "Panel_8"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_bg, self.Image_4, self.Image_content_bg, self.ScrollView_Sign})
    self.ScrollView_Sign:setInnerContainerSize(self.ScrollView_Sign:getSize())
    self.ScrollView_Sign:setScrollBarEnabled(false)
    self.ListView_Activity:setScrollBarEnabled(false)

    for i=1,8 do
        self["Panel_" .. tostring(i)]:setTag(i)
    end

	ccui.Helper:doLayout(self.rootView)

    local function listViewEvent(sender, eventType)
		if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            self:onItemSelected(sender)
        end
	end
    self.ListView_Activity:addEventListener(listViewEvent)
    self.Button_Prev:setVisible(false)
    self.Button_Next:setVisible(true)

    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrolling then
            -- log("scrolling")
            local pos = sender:getInnerContainerPosition()
            -- log("x=" .. pos.x)
            if pos.x <= -(self.Panel_1:getContentSize().width*(self.ListView_Activity:getChildrenCount()/2 - 1)-50) then
                self.Button_Next:setVisible(false)
            elseif pos.x >= -50 then
                self.Button_Prev:setVisible(false)
            else
                self.Button_Prev:setVisible(true)
                self.Button_Next:setVisible(true)
            end
        end
    end
    self.ListView_Activity:addScrollViewEventListener(scrollViewEvent)

    self.cellWidth = 104
    self.cellHeight = 145
	
    self.Panel_SignModel:setVisible(false)
    self.ScrollView_Sign:setScrollBarEnabled(false)

    local endTime = cp.getUserData("UserActivity"):getValue("rechargeGift_time_end")
    if cp.getManager("TimerManager"):getTime() > endTime then  -- 活動時間已過，需要刪除相應界面按鈕
        if self["Panel_6"] then
            self.ListView_Activity:removeChild(self["Panel_6"])
            self["Panel_6"] = nil
        end
    end

    local apple_test_version = cp.getManualConfig("Net").apple_test_version
    if apple_test_version == true then
        if self["Panel_5"] then
            self.ListView_Activity:removeChild(self["Panel_5"])
            self["Panel_5"] = nil
        end
    end

    --設置初始打開界面
    local firstRecharge = cp.getUserData("UserActivity"):getValue("firstRecharge")
    if firstRecharge <= 1 then
        self:updateActiveType(8)
        if self.FirstRechargeGift == nil then
            self.FirstRechargeGift = require("cp.view.scene.world.rechargeGift.FirstRechargeGift"):create()
            self.FirstRechargeGift:setVisible(false)
            self.rootView:addChild(self.FirstRechargeGift, -10)
        end
        self.FirstRechargeGift:setVisible(true)
        self.Image_bg:setVisible(false)
    else
        
        if self["Panel_8"] then
            self.ListView_Activity:removeChild(self["Panel_8"])
            self["Panel_8"] = nil
        end
        self:updateActiveType(1)
        self.Image_bg:setVisible(true)

        self:updateActivitySignView()
        local today = cp.getUserData("UserSign"):getToday()
        local signFlag = cp.getUserData("UserSign"):getSignFlag(today)
        if signFlag == 0 then
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").SignReq, {})
        end
    end
    


    self.ListView_Activity:scrollToItem(0,cc.p(0.5,0.5),cc.p(0.5,0.5),0.1)
  
    cp.getManager("ViewManager").initButton(self.Button_Prev, function()
        local index = self.ListView_Activity:getCurSelectedIndex()
        if index > 0 then
            self.ListView_Activity:jumpToItem(index-1,cc.p(0.5,0.5),cc.p(0.5,0.5))
        end
    end, 0.9)
    cp.getManager("ViewManager").initButton(self.Button_Next, function()
        local index = self.ListView_Activity:getCurSelectedIndex()
        if index < self.ListView_Activity:getChildrenCount()+1 then
            self.ListView_Activity:jumpToItem(index+1,cc.p(0.5,0.5),cc.p(0.5,0.5))
        end
    end, 0.9)
    self:setupAchivementGuide()
end

function ActivitySignLayer:setupAchivementGuide()
    local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
    if guideType == 17 then
        local index = self.ListView_Activity:getIndex(self.Panel_2)
        self.ListView_Activity:jumpToItem(index, cc.p(0,0), cc.p(0,0))
        guideBtn = self.Panel_2:getChildByName("Image_1")
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end

    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function ActivitySignLayer:onItemSelected(sender)
    self.Image_bg:setVisible(false)
    if self.UpgradeGiftMain ~= nil then
        self.UpgradeGiftMain:setVisible(false)
    end
    if self.FightGiftMain ~= nil then
        self.FightGiftMain:setVisible(false)
    end
    if self.Physical ~= nil then
        self.Physical:setVisible(false)
    end
    if self.JiangHuGOMain ~= nil then
        self.JiangHuGOMain:setVisible(false)
    end
    if self.RechargeGiftMain ~= nil then
        self.RechargeGiftMain:setVisible(false)
    end
    if self.FundsGiftMain ~= nil then
        self.FundsGiftMain:setVisible(false)
    end
    if self.FirstRechargeGift ~= nil then
        self.FirstRechargeGift:setVisible(false)
    end

    --print("select child index = ", sender:getCurSelectedIndex())
    local index = sender:getCurSelectedIndex()
    local item = sender:getItem(index)
    local tag = item:getTag()
    self:updateActiveType(tag)
    if tag == 1 then
        self.Image_bg:setVisible(true)
        self:updateActivitySignView()
        local today = cp.getUserData("UserSign"):getToday()
        local signFlag = cp.getUserData("UserSign"):getSignFlag(today)
        if signFlag == 0 then
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").SignReq, {})
        end
    elseif tag == 2 then
        if self.Physical == nil then
            self.Physical = require("cp.view.scene.world.physical.Physical"):create()
            self.Physical:setVisible(false)
            self.rootView:addChild(self.Physical, -10)
        end
        self.Physical:setVisible(true)
    elseif tag == 3 then
        if self.UpgradeGiftMain == nil then
            self.UpgradeGiftMain = require("cp.view.scene.world.upgradeGift.UpgradeGiftMain"):create()
            self.UpgradeGiftMain:setVisible(false)
            self.rootView:addChild(self.UpgradeGiftMain, -10)
        end
        self.UpgradeGiftMain:setVisible(true)
    elseif tag == 4 then
        if self.FightGiftMain == nil then
            self.FightGiftMain = require("cp.view.scene.world.fightGift.FightGiftMain"):create()
            self.FightGiftMain:setVisible(false)
            self.rootView:addChild(self.FightGiftMain, -10)
        end
        self.FightGiftMain:setVisible(true)
    elseif tag == 5 then --江湖行
        if self.JiangHuGOMain == nil then
            self.JiangHuGOMain = require("cp.view.scene.world.jianghugo.JiangHuGoMain"):create()
            self.JiangHuGOMain:setVisible(false)
            self.rootView:addChild(self.JiangHuGOMain, -10)
        end
        self.JiangHuGOMain:setVisible(true)
    elseif tag == 6 then --儲值獎勵
        if self.RechargeGiftMain == nil then
            self.RechargeGiftMain = require("cp.view.scene.world.rechargeGift.RechargeGiftMain"):create()
            self.RechargeGiftMain:setVisible(false)
            self.rootView:addChild(self.RechargeGiftMain, -10)
        end
        self.RechargeGiftMain:setVisible(true)
    elseif tag == 7 then --江湖基金
        if self.FundsGiftMain == nil then
            self.FundsGiftMain = require("cp.view.scene.world.fundsGift.FundsGiftMain"):create()
            self.FundsGiftMain:setVisible(false)
            self.rootView:addChild(self.FundsGiftMain, -10)
        end
        self.FundsGiftMain:setVisible(true)
    elseif tag == 8 then --首衝獎勵
        if self.FirstRechargeGift == nil then
            self.FirstRechargeGift = require("cp.view.scene.world.rechargeGift.FirstRechargeGift"):create()
            self.FirstRechargeGift:setVisible(false)
            self.rootView:addChild(self.FirstRechargeGift, -10)
        end
        self.FirstRechargeGift:setVisible(true)
    end

    -- if tag <= 5 then
    --     self.Button_Prev:setVisible(false)
    --     self.Button_Next:setVisible(true)
    -- else
    --     self.Button_Prev:setVisible(true)
    --     self.Button_Next:setVisible(false)
    -- end
end

function ActivitySignLayer:updateActivitySignView()
    local rowNum = 5
    local height = rowNum*self.cellHeight
    local size = self.ScrollView_Sign:getSize()
    if size.height < height then
        self.ScrollView_Sign:setInnerContainerSize(cc.size(624, height))
    else
        height = size.height
    end
    local beginX, beginY = self.cellWidth/2, height-self.cellHeight/2
    local signDay = cp.getUserData("UserSign"):getSignDay()
    for i=1, 30 do
        local row = math.floor((i-1)/6)+1
        local col = math.floor((i-1)%6)+1
        local model = self.ScrollView_Sign:getChildByName(i)
        if not model then
            model = self.Panel_SignModel:clone()
            self.ScrollView_Sign:addChild(model)
            model:setName(i)
            local posX = beginX + (col-1)*self.cellWidth
            local posY = beginY - (row-1)*self.cellHeight
            model:setPosition(cc.p(posX, posY))
            model:setVisible(true)
        end

        local imgSign = model:getChildByName("Image_SignModel")
        local imgBottom = imgSign:getChildByName("Image_Bottom")
        local imgIcon = imgSign:getChildByName("Image_Model")
        local textDay = imgSign:getChildByName("Text_Day")
        local imgFlag = imgSign:getChildByName("Image_Flag")
        local imgDouble = imgSign:getChildByName("Image_Double")
        local imgResign = imgSign:getChildByName("Image_Resign")
        local textNum = imgIcon:getChildByName("Text_Num")
        local imgBox = imgIcon:getChildByName("Image_Icon")
        local imgType = imgIcon:getChildByName("Image_ItemType")
        
        textDay:setString(string.format("第%d天", i))
        imgSign:setTag(i)
        imgSign:setTouchEnabled(true)
        cp.getManager("ViewManager").initButton(imgSign, function()
            local touchSign = imgSign:getTag()
            self:showSignDetail(touchSign)
        end, 0.9)
        imgResign:setVisible(false)
        imgFlag:setVisible(false)
        local signFlag = cp.getUserData("UserSign"):getSignFlag(i)
        if signFlag == 1 or signFlag == 2 then
            imgFlag:setVisible(true)
        elseif signFlag == 0 and signDay ~= i then
            imgResign:setVisible(true)
        end

        local signEntry = cp.getManager("ConfigManager").getItemByKey("GameSign", i)
        local itemInfo = string.split(signEntry:getValue("RewardList"), "=")
        local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", tonumber(itemInfo[1]))
        if itemEntry:getValue("Type") == 2 then
            imgType:setVisible(true)
        else
            imgType:setVisible(false)
        end
        imgBox:loadTexture(CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
        imgIcon:loadTexture(itemEntry:getValue("Icon"))
        textNum:setString(itemInfo[2])
        local doubleLevel = signEntry:getValue("DoubleLevel")
        if doubleLevel > 0 then
            imgDouble:setVisible(true)
            local textureName = string.format("ui_sign_module33_qiandao_jiaobiao%02d.png", doubleLevel)
            imgDouble:loadTexture(textureName, ccui.TextureResType.plistType)
        else
            imgDouble:setVisible(false)
        end

        imgBottom:loadTexture(CombatConst.QualityBottomList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
    end

    local signData = cp.getUserData("UserSign"):getValue("SignData")
    local signList = cp.getManager("ConfigManager").getItemList("GameSign", "TotalReward", function(totalReward)
        if string.len(totalReward) > 0 then
            return true
        end

        return false
    end)
    local today = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())
    local progress_size = {94,196,297,399,500}  --美術圖片節點分佈不均勻，只能手動設置進度點
    self.Panel_Progress:setSize(cc.size(progress_size[signData.sign_days], 28))
    --signData.sign_days = 0
    local lastDays = 0
    local lastX = 0
    local flag = true
    for i, signEntry in ipairs(signList) do
        local id = signEntry:getValue("Day")
        if signData.sign_days <= signEntry:getValue("Day") and flag then
            local width = (progress_size[i] - lastX) * (signData.sign_days - lastDays)/(id - lastDays) + lastX
            self.Panel_Progress:setSize(cc.size(width, 28))
            flag = false
        else
            lastDays = id
            lastX = progress_size[i]
        end
        local index = table.indexof(signData.summary_days, id)
        local node = self["Node_Reward"..id]
        local imgFlag = node:getChildByName("Image_Flag")
        local btn = node:getChildByName("Button_Reward")
        local imgBG = node:getChildByName("Image_bg")
        local textureName = ""
        if index then
            imgFlag:setVisible(true)
            textureName = "ui_common_module33_qiandao_baoxiangdakai0" .. tostring(i) .. ".png"
            cp.getManager("ViewManager").initButton(btn, function()
                local itemList = cp.getUtils("DataUtils").splitAttr(signEntry:getValue("TotalReward"))
                local signRewardLayer = require("cp.view.scene.activity.ActivityRewardPreviewLayer"):create(2, itemList)
                self:addChild(signRewardLayer, 100)
            end, 0.9)
            btn:stopAllActions()
            imgBG:stopAllActions()
            imgBG:setVisible(false)
        else
            imgFlag:setVisible(false)
            imgBG:setVisible(false)
            textureName = "ui_common_module33_qiandao_baoxiang0" .. tostring(i) .. ".png"
            if signData.sign_days < id then
                cp.getManager("ViewManager").initButton(btn, function()
                    local itemList = cp.getUtils("DataUtils").splitAttr(signEntry:getValue("TotalReward"))
                    local signRewardLayer = require("cp.view.scene.activity.ActivityRewardPreviewLayer"):create(2, itemList)
                    self:addChild(signRewardLayer, 100)
                end, 0.9)
            else
                imgBG:setVisible(true)
                self:addCanRewardAnimation(btn, imgBG)
                cp.getManager("ViewManager").initButton(btn, function()
                    local req = {}
                    req.total_day = id
                    self:doSendSocket(cp.getConst("ProtoConst").GetSummarySignRewardReq, req)
                end, 0.9)
            end
        end
        btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
    end
end

function ActivitySignLayer:addCanRewardAnimation(btn, imgbg)
    btn:stopAllActions()
    btn:setRotation(0)
    if btn then
        local act = {}
        local act1 = cc.EaseSineOut:create(cc.RotateTo:create(0.1,-15))
        local act2 = cc.EaseSineIn:create(cc.RotateTo:create(0.1,0))
        local act3 = cc.EaseSineOut:create(cc.RotateTo:create(0.1,15))
        local act4 = cc.EaseSineIn:create(cc.RotateTo:create(0.1,0))
        local act5 = cc.DelayTime:create(0.5)

        local acts = {act1,act2,act3,act4,act5}
        local seq = cc.Sequence:create(acts)
        local action = cc.RepeatForever:create(seq)
        btn:runAction(action)
    end

    imgbg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 30)))
end

function ActivitySignLayer:getSignByPos(posX, posY)
	posY = posY-self.ScrollView_Sign:getPositionY()-self.Image_1:getPositionY()
	posY=self.ScrollView_Sign:getSize().height-posY
	posX = posX - 44
	local deltaY = self.ScrollView_Sign:getInnerContainerSize().height - self.ScrollView_Sign:getSize().height
	posY = posY + deltaY + self.ScrollView_Sign:getInnerContainerPosition().y
	local row = math.ceil(posY/(self.cellHeight))
	local col = math.ceil(posX/(self.cellWidth))

	return (row-1)*6+col
end

function ActivitySignLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Sign" then
        local signData = cp.getUserData("UserSign"):getValue("SignData")
        if #signData.unsign_day_list == 0 then
            cp.getManager("ViewManager").gameTip("不需要補籤")
            return
        end
        local d = 20                                                                              
        local a1 = (#signData.resign_day_list + 1)*d
        local n = #signData.unsign_day_list
        local need = n*a1 + n*(n-1)*d/2

		local contentTable = {
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text="全部補籤？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		}

		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2, function()
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").SignAllReq, req)
        end,nil)
	end
end

function ActivitySignLayer:showSignDetail(day)
    local signData = cp.getUserData("UserSign"):getValue("SignData")
    local stat = cp.getUserData("UserSign"):getSignFlag(day)
    if stat == 0 and cp.getUserData("UserSign"):getToday() ~= day then
        self:showResignReward(day)
    else
        if cp.getUserData("UserSign"):getToday() == day and stat == 0 then
            local req = {}
            req.sign_day = touchSign
            self:doSendSocket(cp.getConst("ProtoConst").SignReq, req)
        else
            self:showUnsignReward(day)
        end
    end
end

function ActivitySignLayer:showUnsignReward(day)
    local signEntry = cp.getManager("ConfigManager").getItemByKey("GameSign", day)
    local itemInfo = string.split(signEntry:getValue("RewardList"), "=")
    local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", tonumber(itemInfo[1]))
    local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
    self:addChild(layer, 100)
end

function ActivitySignLayer:showResignReward(day)
    local resignRewardLayer = require("cp.view.scene.activity.ActivityResignLayer"):create(day)
    self:addChild(resignRewardLayer, 100)
end

function ActivitySignLayer:onEnterScene()
	self:checkNeedNotice()
end

function ActivitySignLayer:onExitScene()
    self:unscheduleUpdate()
end

function ActivitySignLayer:checkNeedNotice()
    self:checkNeedNoticeUpgradeGift()
    self:checkNeedNoticeFightGift()
    self:checkNeedNoticePhysicalGift()
    self:checkNeedNoticeInviteGift()  
end

function ActivitySignLayer:checkNeedNoticeUpgradeGift()
    if cp.getUtils("NotifyUtils").needNotifyUpgradeGift() then
        cp.getManager("ViewManager").addRedDot(self.Panel_3, cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Panel_3)
    end
end

function ActivitySignLayer:checkNeedNoticeFightGift()
    if cp.getUtils("NotifyUtils").needNotifyFightGift() then
        cp.getManager("ViewManager").addRedDot(self.Panel_4, cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Panel_4)
    end
end

function ActivitySignLayer:checkNeedNoticePhysicalGift()
    if cp.getUtils("NotifyUtils").needNotifyPhysicalGift() then
        cp.getManager("ViewManager").addRedDot(self.Panel_2, cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Panel_2)
    end
end

function ActivitySignLayer:checkNeedNoticeInviteGift()
    local apple_test_version = cp.getManualConfig("Net").apple_test_version
    if apple_test_version == true then
        return
    end
    
    local noticeGift,noticeType = cp.getManager("GDataManager"):checkInviteGiftStateNotice()
    if noticeType[1] == 1 or noticeType[2] == 1  then
        cp.getManager("ViewManager").addRedDot(self.Panel_5, cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Panel_5)
    end
end

function ActivitySignLayer:updateActiveType(tag)
    local images = {
        {"ui_sign_module33_qiandao_meiriqiandao1.png","ui_sign_module33_qiandao_meiriqiandao2.png"},
        {"ui_upgrade_gift_module33_bctl_5.png","ui_upgrade_gift_module33_bctl_6.png"},
        {"ui_upgrade_gift_module33_zljl_9.png","ui_upgrade_gift_module33_zljl_10.png"},
        {"ui_upgrade_gift_module33_zljl_15.png","ui_upgrade_gift_module33_zljl_16.png"},
        {"ui_upgrade_gift_module33_jhx_6.png","ui_upgrade_gift_module33_jhx_5.png"},
        {"ui_upgrade_gift_module95_yunyinghuodong_czjl_2.png","ui_upgrade_gift_module95_yunyinghuodong_czjl_3.png"},
        {"ui_upgrade_gift_module95_yunyinghuodong_jhjj_6.png","ui_upgrade_gift_module95_yunyinghuodong_jhjj_5.png"},
        {"ui_upgrade_gift_module95_yunyinghuodong_scjl_2.png","ui_upgrade_gift_module95_yunyinghuodong_scjl_1.png"},
    }

    for i=1,8 do
        local panel = self.ListView_Activity:getChildByTag(i)
        if panel then
            local Image_1 = panel:getChildByName("Image_1") 
            if panel:getTag() == tag then
                Image_1:loadTexture(images[i][2],ccui.TextureResType.plistType)
            else
                Image_1:loadTexture(images[i][1],ccui.TextureResType.plistType)
            end
        end
    end
end

return ActivitySignLayer
