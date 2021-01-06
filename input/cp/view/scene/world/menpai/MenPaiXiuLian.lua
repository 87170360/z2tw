
local BLayer = require "cp.view.ui.base.BLayer"
local MenPaiXiuLian = class("MenPaiXiuLian",BLayer)

function MenPaiXiuLian:create(openInfo)
	local layer = MenPaiXiuLian.new(openInfo)
	return layer
end

function MenPaiXiuLian:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
        [cp.getConst("EventConst").GangPracticeInfoRsp] = function(data)
            self:refreshTab()
            self:refreshPropertyIncrease()
            self:refreshConsume()
            self:refreshCurrentProgress()
        end,

        [cp.getConst("EventConst").GangPracticeGoldRsp] = function(data)
            self:refreshTab()
            self:refreshPropertyIncrease()
            self:refreshConsume()
            self:refreshCurrentProgress()
        end,

        [cp.getConst("EventConst").GangPracticeSilverRsp] = function(data)
            self:refreshTab()
            self:refreshPropertyIncrease()
            self:refreshConsume()
            self:refreshCurrentProgress()
        end,
        
        [cp.getConst("EventConst").GangPracticeItemRsp] = function(data)
            self:refreshTab()
            self:refreshPropertyIncrease()
            self:refreshConsume()
            self:refreshCurrentProgress()
            
            local itemNum = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").XiuLianDan_ItemID)
            local Text_value = self.Image_item_have:getChildByName("Text_value")
            Text_value:setString(tostring(itemNum))
        end,

        --更新虛擬貨幣
        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
            self:onUpdateCurrencyValue()
        end,

        --重連成功
        [cp.getConst("EventConst").ReconnectLoginOK] = function(evt)
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").GangPracticeInfoReq, req)
        end,

	}
end

function MenPaiXiuLian:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_xiulian.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_bg.Panel_tab"] = {name = "Panel_tab"},
		
		["Panel_root.Panel_bg.Panel_tab.Panel_1"] = {name = "Panel_1",click = "onTabButtonClick",clickScale=1},
		["Panel_root.Panel_bg.Panel_tab.Panel_2"] = {name = "Panel_2",click = "onTabButtonClick",clickScale=1},
		["Panel_root.Panel_bg.Panel_tab.Panel_3"] = {name = "Panel_3",click = "onTabButtonClick",clickScale=1},
        ["Panel_root.Panel_bg.Panel_tab.Panel_4"] = {name = "Panel_4",click = "onTabButtonClick",clickScale=1},
        ["Panel_root.Panel_bg.Panel_tab.Panel_5"] = {name = "Panel_5",click = "onTabButtonClick",clickScale=1},
        ["Panel_root.Panel_bg.Panel_tab.Panel_6"] = {name = "Panel_6",click = "onTabButtonClick",clickScale=1},
		
        ["Panel_root.Panel_bg.Panel_tab.Panel_content"] = {name = "Panel_content"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.Image_ceng.Image_progress"] = {name = "Image_progress"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.Image_ceng.Text_ceng"] = {name = "Text_ceng"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.Image_ceng.Text_progress"] = {name = "Text_progress"},
        
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.Image_property.Panel_type_1"] = {name = "Panel_type_1"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.Image_property.Panel_type_2"] = {name = "Panel_type_2"},
        
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Image_gold_need"] = {name = "Image_gold_need"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Image_gold_have"] = {name = "Image_gold_have"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Image_coin_need"] = {name = "Image_coin_need"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Image_coin_have"] = {name = "Image_coin_have"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Image_item_have"] = {name = "Image_item_have"},

        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Node_item"] = {name = "Node_item"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Node_gold"] = {name = "Node_gold"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Node_silver"] = {name = "Node_silver"},

        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Button_xiulian_item"] = {name = "Button_xiulian_item",click = "onUIButtonClick"},        
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Button_xiulian_gold"] = {name = "Button_xiulian_gold"},
        ["Panel_root.Panel_bg.Panel_tab.Panel_content.ScrollView_1.Button_xiulian_coin"] = {name = "Button_xiulian_coin"},
        
        ["Panel_root.Image_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").addModal(self, cc.c4b(0,0,0,128)) --cp.getManualConfig("Color").defaultModal_c4b)
    ccui.Helper:doLayout(self["rootView"])
    
    local function initButton(button, callFunc)
		local oscalex = 1
		local oscaley = 1
		local scalex =(scale or 0.9)*oscalex
		local scaley =(scale or 0.9)*oscaley
		local touchBeginTime = 0
		local function onTouch(sender, event)
			if event == cc.EventCode.BEGAN then
				sender:setScaleX(scalex)
				sender:setScaleY(scaley)
				--先執行一次
				cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
				if callFunc then
					callFunc()
				end
				schedule(sender,function()
						cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
						if callFunc then
							callFunc()
						end
					end,0.35)
					touchBeginTime = os.time()
			elseif event == cc.EventCode.ENDED then
				sender:setScaleX(oscalex)
				sender:setScaleY(oscaley)
				sender:stopAllActions()
				
			elseif event == cc.EventCode.CANCELLED then
				sender:setScaleX(oscalex)
				sender:setScaleY(oscaley)
				sender:stopAllActions()
			end
		end
		if button.addTouchEventListener ~= nil then
			button:addTouchEventListener(onTouch)
		end
    end
    
    initButton(self.Button_xiulian_gold,function( ... )
        
        local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
        if practiceLevelInfo and practiceLevelInfo[self.curSelectType] and practiceLevelInfo[self.curSelectType].level >= self.maxLv then
            self.Button_xiulian_gold:stopAllActions()
            cp.getManager("ViewManager").gameTip("已達最大修煉等級")
            return
        end

        if cp.getManager("ViewManager").checkGoldEnough(self.currentNeedGold) then
            local req = {}
            req.practiceType = self.curSelectType - 1
            self:doSendSocket(cp.getConst("ProtoConst").GangPracticeGoldReq, req)
        else
            self.Button_xiulian_gold:stopAllActions()
        end
    end)
    
    initButton(self.Button_xiulian_coin,function( ... )
        
        local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
        if practiceLevelInfo and practiceLevelInfo[self.curSelectType] and practiceLevelInfo[self.curSelectType].level >= self.maxLv then
            self.Button_xiulian_coin:stopAllActions()
            cp.getManager("ViewManager").gameTip("已達最大修煉等級")
            return
        end

        if cp.getManager("ViewManager").checkSilverEnough(self.currentNeedCoin) then
            local req = {}
            req.practiceType = self.curSelectType - 1
            self:doSendSocket(cp.getConst("ProtoConst").GangPracticeSilverReq, req)
        else
            self.Button_xiulian_coin:stopAllActions()
        end
	end)
end

function MenPaiXiuLian:onEnterScene()

    self.maxLv = cp.getManager("GDataManager"):getGangPracticeMaxLevel()


    -- self.Panel_root:setPositionY( display.height/2 + 110/2 - 40) -- 110為底部一排按鈕的高度
    self.ScrollView_1:setContentSize(cc.size(620,500))
    self.ScrollView_1:setTouchEnabled(false)
    if display.height > 1440 then --1518
        
    elseif display.height > 1280 then --1440
        -- self.Panel_root:setPositionY( display.height/2 + 110/2) -- 110為底部一排按鈕的高度 
    elseif display.height > 1080 then  --1280
        
    elseif display.height > 960 then  --1080
        self.ScrollView_1:setContentSize(cc.size(620,310))
        -- self.Panel_root:setPositionY( display.height/2 + 110/2 - 150)
        self.ScrollView_1:setTouchEnabled(true)
    else
        self.ScrollView_1:setContentSize(cc.size(620,190))
        -- self.Panel_root:setPositionY( display.height/2 + 110/2 - 210)
        self.ScrollView_1:setTouchEnabled(true)
    end
    ccui.Helper:doLayout(self["rootView"])

    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GangPracticeInfoReq, req)

    self.curSelectType = 1 --practiceType: 0 刀， 1 劍， 2 棍， 3 奇, 4 拳， 5 聚 伺服器保存0~5，客戶端保存1~6

	self.itemIcon = self:addNode(self["Node_item"], cp.getConst("GameConst").XiuLianDan_ItemID)
	self:addNode(self["Node_gold"], cp.getConst("GameConst").Gold_ItemID)
	self:addNode(self["Node_silver"], cp.getConst("GameConst").Silver_ItemID)

end

function MenPaiXiuLian:addNode(node, itemid)
    local itemNum = cp.getUserData("UserItem"):getItemNum(itemid)
    local itemInfo = {id = itemid}
    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
    itemInfo.Name = conf:getValue("Name")
    itemInfo.Icon = conf:getValue("Icon")
	itemInfo.Type = conf:getValue("Type")
	itemInfo.SubType = conf:getValue("SubType")
	itemInfo.Package = conf:getValue("Package")
    itemInfo.Colour = conf:getValue("Hierarchy")
    itemInfo.num = itemNum
    itemInfo.hideName = true
    itemInfo.showNum = false
    if cp.getConst("GameConst").XiuLianDan_ItemID == itemid then
        itemInfo.hideName = false
    end

    local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
    if itemIcon ~= nil then
		node:addChild(itemIcon)
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setPosition(cc.p(0,0))
	end
	return itemIcon
end

function MenPaiXiuLian:onExitScene()
   
end

function MenPaiXiuLian:refreshTab()
    
    local imageList = {
        [1] = {"ui_menpai_xiulian_module19_menpai_24.png","ui_menpai_xiulian_module19_menpai_23.png"},  --刀
        [2] = {"ui_menpai_xiulian_module19_menpai_29.png","ui_menpai_xiulian_module19_menpai_22.png"},  --劍
        [3] = {"ui_menpai_xiulian_module19_menpai_25.png","ui_menpai_xiulian_module19_menpai_21.png"},  --棍
        [4] = {"ui_menpai_xiulian_module19_menpai_26.png","ui_menpai_xiulian_module19_menpai_20.png"},  --奇門
        [5] = {"ui_menpai_xiulian_module19_menpai_27.png","ui_menpai_xiulian_module19_menpai_19.png"},  --拳掌
        [6] = {"ui_menpai_xiulian_module19_menpai_28.png","ui_menpai_xiulian_module19_menpai_18.png"},  --聚氣
    }

    local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
	for i=1,6 do
		local btn_item_name = "Panel_" .. tostring(i)
        local Image_1 = self[btn_item_name]:getChildByName("Image_1")
        Image_1:ignoreContentAdaptWithSize(true)
        local Text_1 = self[btn_item_name]:getChildByName("Text_1")
        practiceLevelInfo[i].level = math.min(practiceLevelInfo[i].level,self.maxLv)
        Text_1:setString(tostring(practiceLevelInfo[i].level) .. "層")
		if self.curSelectType == i then
			Image_1:loadTexture(imageList[i][1],ccui.TextureResType.plistType)
			--Text_1:setTextColor(cp.getConst("GameConst").QualityTextColor[1]) --灰色
		else
			Image_1:loadTexture(imageList[i][2],ccui.TextureResType.plistType)
			--Text_1:setTextColor(cp.getConst("GameConst").QualityTextColor[6]) --紅色
		end   
	end
end


function MenPaiXiuLian:refreshPropertyIncrease()
    local property_type = {
        [1] = {"提升刀系武學傷害","抵禦刀系武學傷害"},
        [2] = {"提升劍系武學傷害","抵禦劍系武學傷害"},
        [3] = {"提升棍系武學傷害","抵禦棍系武學傷害"},
        [4] = {"提升奇門武學傷害","抵禦奇門武學傷害"},
        [5] = {"提升拳掌武學傷害","抵禦拳掌武學傷害"},
        [6] = {"提升聚氣值"}
    }
    
    local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
    local curLevelInfo = practiceLevelInfo[self.curSelectType]
    curLevelInfo.level = math.min(curLevelInfo.level, self.maxLv) 
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangPractice", curLevelInfo.level)
    local needExp = cfgItem:getValue("Exp")
    local Attribute = cfgItem:getValue("Attribute")
    local AttributeStr = string.split(Attribute,"|")
    local AttributeList = string.split(AttributeStr[self.curSelectType],"=")
    local value = AttributeList[2]
    local valueNew = ""
    
    if self.maxLv > curLevelInfo.level then
        local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GangPractice", curLevelInfo.level+1)
        local AttributeStr2 = string.split(cfgItem2:getValue("Attribute"),"|")
        local AttributeList2 = string.split(AttributeStr2[self.curSelectType],"=")
        valueNew = AttributeList2[2] 
    else
        
        valueNew = value
    end
    
    if self.curSelectType ~= 6 then
        value = tonumber(value)/125 * 0.5
        value = tostring(value) .. "%"
        valueNew = tonumber(valueNew)/125 * 0.5
        valueNew = tostring(valueNew) .. "%"
    end

    local Text_type_1 = self.Panel_type_1:getChildByName("Text_type_1")
    Text_type_1:setString(property_type[self.curSelectType][1])
    local Text_value_old_1 = self.Panel_type_1:getChildByName("Text_value_old_1")
    Text_value_old_1:setString(value)
    local Text_value_new_1 = self.Panel_type_1:getChildByName("Text_value_new_1")
    Text_value_new_1:setString(valueNew)

    self.Panel_type_2:setVisible(true)
    if self.curSelectType == 6 then
        self.Panel_type_2:setVisible(false)
        self.Panel_type_1:setPositionY(33.75)
    else
        self.Panel_type_1:setPositionY(54.75)
        local Text_type = self.Panel_type_2:getChildByName("Text_type_1")
        Text_type:setString(property_type[self.curSelectType][2])
        local Text_value_old = self.Panel_type_2:getChildByName("Text_value_old_1")
        Text_value_old:setString(value)
        local Text_value_new = self.Panel_type_2:getChildByName("Text_value_new_1")
        Text_value_new:setString(valueNew)
    end
end

function MenPaiXiuLian:refreshCurrentProgress()
    local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
    self.Text_ceng:setString(tostring(practiceLevelInfo[self.curSelectType].level) .. "層")

    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangPractice", practiceLevelInfo[self.curSelectType].level)
    local needExp = cfgItem:getValue("Exp")
    if practiceLevelInfo[self.curSelectType].level >= self.maxLv then
        self.Text_progress:setString(tostring(needExp) .. "/" .. tostring(needExp) )
        self.Image_progress:setContentSize(cc.size(495*1,30))

        self.Button_xiulian_gold:stopAllActions()
        self.Button_xiulian_coin:stopAllActions()
    else
        local scale = practiceLevelInfo[self.curSelectType].exp/needExp
        self.Text_progress:setString(tostring(practiceLevelInfo[self.curSelectType].exp) .. "/" .. tostring(needExp) )
        scale = math.min(1,scale)
        self.Image_progress:setContentSize(cc.size(495*scale,30))
    end
    
    
end

function MenPaiXiuLian:refreshConsume()
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

    local goldCount = cp.getUserData("UserMenPai"):getValue("goldCount")
    local silverCount = cp.getUserData("UserMenPai"):getValue("silverCount")

    --元寶修煉
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "gang_practice_gold_cost")
	local str = Config:getValue("StrValue")
	local needGold = string.split(str,"|")
    -- local needGold = {0,0,0,0,0,20,20,20,20,20,40}
    local Text_value = self.Image_gold_need:getChildByName("Text_value")
    local gold_value = needGold[math.min(goldCount+1,table.nums(needGold))]
    Text_value:setString(tostring(gold_value))
    self.currentNeedGold = tonumber(gold_value)
    local Image_priceoff = self.Image_gold_need:getChildByName("Image_priceoff")
    Image_priceoff:setVisible(true)
    local Text_priceoff = self.Image_gold_need:getChildByName("Text_priceoff")
    --local img = {"ui_menpai_xiulian_module19_menpai_banjia.png","ui_menpai_xiulian_module19_menpai_mianfei.png"}
	local textPrice = {"5 折", "免 費"}
    
    local Text_tips = self.Image_gold_need:getChildByName("Text_tips")
    local leftFreeTimes = math.max(0,5 - goldCount) 
    local leftHalfGoldTimes = math.max(0,10 - goldCount)
    Text_tips:setVisible(true)
    if leftFreeTimes > 0 then
        Text_tips:setString("每日免費次數  " .. tostring(leftFreeTimes) .. "/5")
        --Image_priceoff:loadTexture(img[2],ccui.TextureResType.plistType)
		Text_priceoff:setString(textPrice[2])
    else
        if leftHalfGoldTimes > 0 then
            Text_tips:setString("每日半價次數  " .. tostring(leftHalfGoldTimes) .. "/5")
            --Image_priceoff:loadTexture(img[1],ccui.TextureResType.plistType)
			Text_priceoff:setString(textPrice[1])
        else
            Text_tips:setVisible(false)
        end
    end
    Image_priceoff:setVisible(leftHalfGoldTimes > 0)
	Text_priceoff:setVisible(leftHalfGoldTimes > 0)

    Text_value = self.Image_gold_have:getChildByName("Text_value")
    Text_value:setString(tostring(major_roleAtt.gold))

    --銀兩修煉
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "gang_practice_silver_cost")
	local str = Config:getValue("StrValue")
	local needCoin = string.split(str,"|")
    -- local needCoin = {25000,25000,25000,25000,25000,50000}
    local coin_value = needCoin[math.min(silverCount+1,table.nums(needCoin))]
    self.currentNeedCoin = tonumber(coin_value) 
    Text_value = self.Image_coin_need:getChildByName("Text_value")
    Text_value:setString(tostring(coin_value))
    Image_priceoff = self.Image_coin_need:getChildByName("Image_priceoff")
    Text_priceoff = self.Image_coin_need:getChildByName("Text_priceoff")
    Image_priceoff:setVisible(silverCount < 5 )
    Text_priceoff:setVisible(silverCount < 5 )
    local leftHalfCoinTimes = math.max(0,5 - silverCount) 
    Text_tips = self.Image_coin_need:getChildByName("Text_tips")
    if leftHalfCoinTimes > 0 then
        Text_tips:setString("每日半價次數  " .. tostring(leftHalfCoinTimes) .. "/5")
		Text_priceoff:setString(textPrice[1])
    else
        Text_tips:setVisible(false)
    end

    Text_value = self.Image_coin_have:getChildByName("Text_value")
    local coin_value_str = major_roleAtt.silver <= 100000 and tostring(major_roleAtt.silver) or (tostring(math.floor(major_roleAtt.silver/10000)) .. "萬")
    Text_value:setString(coin_value_str) --大於10萬特殊處理

    --加紅點
    if leftFreeTimes > 0 then
	    cp.getManager("ViewManager").addRedDot(self.Button_xiulian_gold,cc.p(135,48))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_xiulian_gold)
    end
    local itemNum = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").XiuLianDan_ItemID)
    if itemNum > 0 then
        cp.getManager("ViewManager").addRedDot(self.Button_xiulian_item,cc.p(135,48))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_xiulian_item)
    end

    Text_value = self.Image_item_have:getChildByName("Text_value")
    Text_value:setString(tostring(itemNum))
end

function MenPaiXiuLian:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        -- cp.getManager("PopupManager"):removePopup(self)
        if self.closeCallBack then
            self.closeCallBack()
        end
        self:removeFromParent()
    elseif buttonName == "Button_xiulian_item" then
        local itemNum = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").XiuLianDan_ItemID)
        if itemNum <= 0 then
            local function comfirmFunc()
                self:gotoXiuLuoTa()
            end

            local contentTable = {
                {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="您的修煉丹不足，請前往修羅塔獲取。", textColor=cc.c4b(255,255,255,255),verticalAlign="middle"},
            }
            cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
        else
            local req = {}
            req.practiceType = self.curSelectType - 1
            self:doSendSocket(cp.getConst("ProtoConst").GangPracticeItemReq, req)
        end
    end
end

function MenPaiXiuLian:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function MenPaiXiuLian:onTabButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    local idx = tonumber(string.sub(buttonName,string.len("Panel_") + 1))
    log("idx = " .. idx)
    
    self.curSelectType = idx
    self:refreshTab()
    self:refreshPropertyIncrease()
    self:refreshCurrentProgress()

end

function MenPaiXiuLian:gotoXiuLuoTa()
    self:dispatchViewEvent("GetTowerDataRsp", true)
end


function MenPaiXiuLian:onUpdateCurrencyValue( )
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local Text_value = self.Image_gold_have:getChildByName("Text_value")
    Text_value:setString(tostring(major_roleAtt.gold))

    Text_value = self.Image_coin_have:getChildByName("Text_value")
    local coin_value_str = major_roleAtt.silver <= 100000 and tostring(major_roleAtt.silver) or (tostring(math.floor(major_roleAtt.silver/10000)) .. "萬")
    Text_value:setString(coin_value_str) --大於10萬特殊處理
end


return MenPaiXiuLian
