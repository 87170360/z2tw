
local BNode = require "cp.view.ui.base.BNode"
local RechargeItem = class("RechargeItem",BNode)

function RechargeItem:create()
	local node = RechargeItem.new()
	return node
end

function RechargeItem:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").RechargeRsp] = function(evt)
            if self.itemInfo.ID == evt.rechargeID then
                self.Image_give_1:setVisible(false)
                self.Image_give_2:setVisible(false)
                self:updateItemState()
            end
        end,
	}
end

function RechargeItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_vip/uicsb_vip_recharge_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Image_bg_0"] = {name = "Image_bg_0"},
        ["Panel_item.Image_bg"] = {name = "Image_bg"},
        ["Panel_item.Text_gold"] = {name = "Text_gold"},
        ["Panel_item.Text_price"] = {name = "Text_price"},
        ["Panel_item.Image_price_type"] = {name = "Image_price_type"},

        ["Panel_item.Image_give_2"] = {name = "Image_give_2"},
        ["Panel_item.Image_give_2.Text_give_2"] = {name = "Text_give_2"},
        ["Panel_item.Image_give_2.Image_price_type_2"] = {name = "Image_price_type_2"},

        ["Panel_item.Image_give_1"] = {name = "Image_give_1"},
        ["Panel_item.Image_give_1.Text_give_1"] = {name = "Text_give_1"},
     
        ["Panel_item.Node_des"] = {name = "Node_des"},
        ["Panel_item.Node_des.Image_des"] = {name = "Image_des"},
        ["Panel_item.Node_des.Text_des_1"] = {name = "Text_des_1"},
        ["Panel_item.Node_des.Text_des_2"] = {name = "Text_des_2"},
        ["Panel_item.Node_des.Text_des_3"] = {name = "Text_des_3"},
        ["Panel_item.Node_des.Text_des_4"] = {name = "Text_des_4"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self.Node_des:setVisible(false)

    local function onTouch(sender, event)
		if event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                --購買
                dump(self.itemInfo)

                if self.itemInfo.Type == 2 then --終身卡需要判斷是否已經買過
                    local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(self.itemInfo.ID)
                    if not isFirst then
                        cp.getManager("ViewManager").gameTip("終身卡已購買，不能重複購買。")
                        return
                    end
                end

                if self.itemInfo.Type == 5 then --江湖基金需要判斷是否已經買過
                    -- local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(self.itemInfo.ID)
                    local fund = cp.getUserData("UserActivity"):getValue("fund")
                    if fund then
                        cp.getManager("ViewManager").gameTip("江湖基金已購買，不能重複購買。")
                        return
                    end
                end
                
                local channelName = cp.getManualConfig("Channel").channel
                if channelName == "xiaomi" or channelName == "xiaomi1" then  --小米首次測試不開儲值
                    cp.getManager("ViewManager").gameTip("本次測試不開放儲值，謝謝大俠。")
                    return
                elseif channelName == "lunplay" then
                    cp.getManager("ChannelManager"):goRecharge(self.itemInfo,handler(self,self.refreshItem))
                    return
                end
                
                local req = {}
                req.rechargeID = self.itemInfo.ID
                self:doSendSocket(cp.getConst("ProtoConst").RechargeReq, req)
                
                sender:setTouchEnabled(false)
                sender:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() sender:setTouchEnabled(true) end)))
            end
        end
	end

    self.Panel_item:setTouchEnabled(true)
	self.Panel_item:addTouchEventListener(onTouch)
    
    self.Image_give_2:setVisible(false)
end

function RechargeItem:onEnterScene()
    
end

--[[
    itemInfo.ID = cfg:getValue("ID") 
        itemInfo.Money = cfg:getValue("Money")
        itemInfo.BuyItem = cfg:getValue("BuyItem")
        itemInfo.GiftItem = cfg:getValue("GiftItem")
        itemInfo.Icon = cfg:getValue("Icon")
        itemInfo.Type = cfg:getValue("Type")
        itemInfo.ItemCode = cfg:getValue("ItemCode")
]]
function RechargeItem:resetInfo(itemInfo)
    self.itemInfo = itemInfo

    local spriteFrame1 = cc.SpriteFrameCache:getInstance():getSpriteFrameByName("ui_common_yuanbao.png")
    local spriteFrame2 = cc.SpriteFrameCache:getInstance():getSpriteFrameByName("ui_common_module40_shizhuang_8.png")
	if (not spriteFrame1) or (not spriteFrame2) then
        display.loadSpriteFrames("uiplist/ui_common.plist")
    end

    self.Image_give_1:setVisible(false)
    self.Image_give_2:setVisible(false)
    
    local channelName = cp.getManualConfig("Channel").channel
    if channelName == "lunplay" then
        self.Text_price:setString("$".. tostring(itemInfo.Money))
    else
        self.Text_price:setString(tostring(itemInfo.Money) .. "元")
    end

    if itemInfo.Type > 0 then
        self.Image_bg_0:loadTexture(itemInfo.Icon,ccui.TextureResType.plistType)
        self.Image_bg:setVisible(false)
        self.Node_des:setVisible(true)
    else
        self.Image_bg:loadTexture(itemInfo.Icon,ccui.TextureResType.plistType)
        self.Image_bg:ignoreContentAdaptWithSize(true)
        self.Image_bg:setVisible(true)
        self.Node_des:setVisible(false)
    end

    local BuyItemArr = string.split(itemInfo.BuyItem,"-")
    local buyItemId = tonumber(BuyItemArr[1])
    local buyItemNum = tonumber(BuyItemArr[2])
    local lastDays = 0  --持續天數
    if itemInfo.Type >= 1 and itemInfo.SustainedEarnings ~= "" then  --月卡,終身卡，年卡，季卡額外處理
        local arr = string.split(itemInfo.SustainedEarnings,"-")
        lastDays = tonumber(arr[1])
        buyItemId = tonumber(arr[2])
        buyItemNum = tonumber(arr[3]) 
    end

    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", buyItemId)
    if conf ~= nil then
        local subType = conf:getValue("SubType")
        local itemIcon = cp.getManager("ViewManager").getVirtualItemIcon(subType)
        if itemIcon then
            self.Image_price_type:loadTexture(itemIcon,ccui.TextureResType.plistType)
        end
    end
    self.Text_gold:setString(tostring(buyItemNum))

    if itemInfo.Type > 0 then
        self.Text_gold:setVisible(false)
        self.Image_price_type:setVisible(false)

        if itemInfo.Type == 5 then --江湖基金
            self.Text_des_1:setString("一次儲值,持續受益")
            self.Text_des_3:setString("將累計獲得")
            self.Text_des_4:setString(tostring(9280))
            self.Text_des_2:setVisible(false)
            self.Image_des:setPosition(cc.p(30,-25))
            self.Text_des_3:setPosition(cc.p(-60,-25))
            self.Text_des_4:setPosition(cc.p(-33,-25))

        else-- 月卡,終身卡，年卡，季卡 顯示每日獎勵
        
            self.Text_des_2:setString(tostring(buyItemNum))
            self.Text_des_4:setString(tostring(lastDays))
            self.Text_des_3:setString("持續        天")
        end
    end
    
    --是否首儲
    local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(itemInfo.ID)

    local gift_items = {}
    local arr1 = {}
    if itemInfo.Type >= 1 then  --月卡,季卡，年卡，終身卡
        if itemInfo.First ~= "" then
            local arrTemp = string.split(itemInfo.First,"-")
            table.insert(arr1,arrTemp)
        end
    else
        if itemInfo.GiftItem ~= "" then
            string.loopSplit(itemInfo.GiftItem,"|-",arr1)
        end
    end
    local haveGift = arr1 and next(arr1) and table.nums(arr1) > 0

    if isFirst and haveGift then
        for i=1,table.nums(arr1) do
            local id = tonumber(arr1[i][1])
            local num = tonumber(arr1[i][2])
            if id and num and id > 0 and num > 0 then
                table.insert(gift_items, {item_id = id, item_num = num})
            end
        end
        
        if table.nums(gift_items) > 0 then
            if gift_items[1] then
                self.Image_give_1:setVisible(true)
                self.Text_give_1:setString(tostring(gift_items[1].item_num))
                self.Image_give_1:loadTexture("ui_vip_module33_vipshouchong.png",ccui.TextureResType.plistType)
            end
        
            if gift_items[2] then
                self.Image_give_2:setVisible(true)
                self.Text_give_2:setString(tostring(gift_items[2].item_num))
                local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", gift_items[2].item_id)
                if conf ~= nil then
                    local subType = conf:getValue("SubType")
                    local itemIcon = cp.getManager("ViewManager").getVirtualItemIcon(subType)
                    if itemIcon then
                        self.Image_price_type_2:loadTexture(itemIcon,ccui.TextureResType.plistType)
                    end
                end
            end
        end
    else
        self:updateItemState()
    end
    
end

function RechargeItem:getItemSize()
    return self.Panel_item:getContentSize()
end

function RechargeItem:refreshItem(callback_param)
    log("RechargeItem:refreshItem() 11, callback_param = " .. callback_param)

    self.Image_give_1:setVisible(false)
    self.Image_give_2:setVisible(false)
    self:updateItemState()
    
    if callback_param and callback_param ~= "" then
        local strList = string.split(callback_param,"|")
        local backType = strList[1]
        local itemCode,serverCode,glevel,extraParam = strList[2],strList[3],strList[4],strList[5]
        dump(strList)
        self:dispatchViewEvent(cp.getConst("EventConst").UpdateCurrencyRsp, nil)
    end
end

function RechargeItem:updateItemState()

    if self.itemInfo.More == "" then
        self.Text_give_1:setVisible(false)
        self.Image_give_1:setVisible(true)
        self.Image_give_1:loadTexture("ui_vip_module33_vipyigoumai.png",ccui.TextureResType.plistType)
        local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(self.itemInfo.ID)  -- isFirst未false表示已經購買過
        if self.itemInfo.Type == 5 and (isFirst) then
            self.Image_give_1:setVisible(false)
        end
    else

        local arrTemp = string.split(self.itemInfo.More,"-")
        local id = tonumber(arrTemp[1])
        local num = tonumber(arrTemp[2])
        if id and num and id > 0 and num > 0 then
            self.Image_give_1:setVisible(true)
            self.Text_give_1:setString(arrTemp[2])
            self.Image_give_1:loadTexture("ui_vip_module33_vipzengsong.png",ccui.TextureResType.plistType)
        else
            self.Text_give_1:setVisible(false)
            self.Image_give_1:setVisible(false)
        end
    end

    if self.itemInfo.Type > 0 and self.itemInfo.Type ~= 5 then

        local Cards = cp.getUserData("UserVip"):getValue("Cards")
        if Cards and next(Cards) then
            local cfgItem = cp.getManager("ConfigManager").getItemByMatch("Card",{RechargeID = self.itemInfo.ID})
            local itemId = cfgItem:getValue("ID")
            local addDays = cfgItem:getValue("Day")
            local days = 0
            if Cards then
                days = Cards[tostring(itemId)] or 0
                days = math.max(days,0)
            end
            if days > 0 then
                self.Text_des_4:setString(tostring(days))
                self.Text_des_3:setString("當前剩餘        天")
            end
        end
    end
    
end

return RechargeItem
