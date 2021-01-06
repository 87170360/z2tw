
local BNode = require "cp.view.ui.base.BNode"
local SecondShopItem = class("SecondShopItem",BNode)

function SecondShopItem:create()
	local node = SecondShopItem.new()
	return node
end

function SecondShopItem:initListEvent()
	self.listListeners = {

        --購買商品返回
        [cp.getConst("EventConst").StoreBuyRsp] = function(data)	
            if data.goodsID > 0 and self.goodsInfo.goodsID == data.goodsID then
                self.goodsInfo.leftNum = data.leftNum
                if self.ItemIcon ~= nil then 
                    self.ItemIcon:resetNum(data.leftNum)
                end
                if data.leftNum == 0 then
                    self.Panel_soldout:setVisible(true)
                    self.Text_name:setOpacity(128)
                    self.Image_price_type:setOpacity(128)
                    self.Text_price:setOpacity(128)
                end
            end
        end,
	}
end

function SecondShopItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shop/uicsb_shop_mystical_store_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"}, -- click = "onItemClick", clickScale=1},
        ["Panel_item.Image_bg_1"] = {name = "Image_bg_1"},
        ["Panel_item.Image_bg_2"] = {name = "Image_bg_2"},
        ["Panel_item.Image_price_off"] = {name = "Image_price_off"},
        ["Panel_item.Image_price_off.Text_off"] = {name = "Text_off"},
        ["Panel_item.Image_price_off.Image_tuijian"] = {name = "Image_tuijian"},
        
        ["Panel_item.Text_price"] = {name = "Text_price"},
        ["Panel_item.Text_name"] = {name = "Text_name"},
        ["Panel_item.Image_price_type"] = {name = "Image_price_type"},
        ["Panel_item.Node_icon"] = {name = "Node_icon"},
        ["Panel_item.Panel_soldout"] = {name = "Panel_soldout"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)


    local function onTouch(sender, event)
        if event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onItemClick(sender)
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效    
            end
            
        end
    end
    if self.Panel_item.addTouchEventListener ~= nil then
        self.Panel_item:addTouchEventListener(onTouch)
    end
	
end

function SecondShopItem:onEnterScene()
    
end

function SecondShopItem:resetInfo(goodsInfo)
    self.goodsInfo = goodsInfo
    self.Text_price:setString(tostring(goodsInfo.Price))
    -- 元寶1， 銀兩2， 聲望3，俠義令4，鐵膽令5，天書殘頁6，幫派個人資金7，幫貢8， 玄玉9

	local image = {[1] = "ui_common_yuanbao.png",[2] = "ui_common_yinliang.png",[3] = "ui_common_swz.png",[4]="ui_common_sz.png",[5]="ui_common_ez.png",[6]="ui_common_06tscy.png",[7]="ui_common_bpzj.png",[8]="ui_common_bg.png",[9]="ui_common_module33_vip_goumai_yu.png"}
    self.Image_price_type:loadTexture(image[goodsInfo.PriceType],ccui.TextureResType.plistType)
    local x,y = self.Text_price:getPosition()
    local szWidth = self.Text_price:getContentSize().width / self.Text_price.clearScale
    -- self.Image_price_type:setScale(self.Text_price.clearScale)
    self.Image_price_type:setPositionX(x - szWidth/2)
    if self.Node_icon:getChildByName("ItemIcon") ~= nil then
        self.Node_icon:removeAllChildren()
    end

    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", goodsInfo.ItemID)
    
    local itemInfo = {shopModel = true,hideName = true, Name = goodsInfo.Name,id = goodsInfo.ItemID, num = goodsInfo.leftNum,Icon = goodsInfo.Icon,Colour = goodsInfo.Colour,Type = conf:getValue("Type")}
    local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
    item:setName("ItemIcon")
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:resetNamePosY(-12)
    item:setItemClickCallBack(nil)
    self.Node_icon:addChild(item)
    self.ItemIcon = item
    self.Panel_soldout:setVisible(goodsInfo.leftNum <= 0)
    self.Text_name:setString( goodsInfo.Name)
    -- self.Text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[goodsInfo.Colour])
    cp.getManager("ViewManager").setTextQuality(self.Text_name,goodsInfo.Colour)
        
    self.Text_name:setOpacity(255)
    self.Image_price_type:setOpacity(255)
    self.Text_price:setOpacity(255)
    if goodsInfo.leftNum <= 0 then
        self.Text_name:setOpacity(128)
        self.Image_price_type:setOpacity(128)
        self.Text_price:setOpacity(128)
    end

    local off = goodsInfo.Rebate/10.0
    local needTuijian = off <= 6.0
    self.Image_bg_1:setVisible(needTuijian)
    self.Image_bg_2:setVisible(not needTuijian)

    self.Image_price_off:setVisible(off < 10.0)
    if self.Image_price_off:isVisible() then
        self.Image_price_off:setContentSize(cc.size(needTuijian and 120 or 84,31))
        self.Image_price_off:setPosition(needTuijian and cc.p(22,170) or cc.p(0,160))
        self.Text_off:setString(string.format("%0.1f",off) .. "折")
        self.Text_off:setPositionX(needTuijian and 50 or 10)
        self.Image_tuijian:setVisible(needTuijian)
    end
end

function SecondShopItem:getItemSize()
    return self.Panel_item:getContentSize()
end

function SecondShopItem:onItemClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if self.goodsInfo.leftNum <= 0 then
        cp.getManager("ViewManager").gameTip(self.goodsInfo.Name .. "已經售罄，請選其他的吧！")
        return
    end

    local function openBuyMessageBox()
        
        -- 元寶1， 銀兩2， 聲望3，善4，惡5，天書殘頁6，幫派個人資金7
        local VirtualItemType = cp.getConst("GameConst").VirtualItemType
        local types = {
            [1] = VirtualItemType.gold, 
            [2]=VirtualItemType.silver, 
            [3]=VirtualItemType.prestige, 
            [4]=VirtualItemType.goodPoint, 
            [5]=VirtualItemType.badPoint,
            [6]=VirtualItemType.tscy,
            [7]=VirtualItemType.guildGold,
            [8]=VirtualItemType.guildContribute
        }

        local function comfirmFunc(num,goodsInfo)
            local needValue = num * self.goodsInfo.Price

            local result = true
            if self.goodsInfo.PriceType == 6 then --天書殘頁
                local have_num = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").TianShuCanYe_ItemID) --天書殘頁的物品id為10
                result = have_num >= needValue
                if not result then
                    cp.getManager("ViewManager").gameTip("天書殘頁數量不足")
                end
            else
                local itemType = types[self.goodsInfo.PriceType]
                result = cp.getManager("ViewManager").checkVirtualItemEnough(needValue,itemType)
            end
            
            if result then
                local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID")
                local data = {goodsID=self.goodsInfo.goodsID}
                data.buyNum = num
                data.storeID = current_storeID
                self:doSendSocket(cp.getConst("ProtoConst").StoreBuyReq,data)
            end
        end

        if self.goodsInfo.leftNum >= 1 then
            local itemInfo = {Name = self.goodsInfo.Name, Colour = self.goodsInfo.Colour, num = self.goodsInfo.leftNum, goodsID = self.goodsInfo.goodsID, id = self.goodsInfo.ItemID,PriceType = types[self.goodsInfo.PriceType],Price = self.goodsInfo.Price}
            local openInfo = {
                itemInfo = itemInfo,
                contentType = "buyItem",
                callback = function(num,itemInfo)
                    if num < 1 then
                        return
                    end
                    comfirmFunc(num,itemInfo)
                end
            }
            cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
        else
            cp.getManager("ViewManager").gameTip(self.goodsInfo.Name .. "已經售罄，請選其他的吧！")
        end
    end

    local function closeCallBack(buttonName,Info)
        if "Button_buy" == buttonName then
            openBuyMessageBox()
        end
    end

    local buyItemInfo = {id = self.goodsInfo.ItemID,openType = "ViewShopItem"}
    cp.getManager("ViewManager").showItemTip(buyItemInfo,closeCallBack)
end


return SecondShopItem
