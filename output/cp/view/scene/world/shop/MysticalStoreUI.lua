
local BLayer = require "cp.view.ui.base.BLayer"
local MysticalStoreUI = class("MysticalStoreUI",BLayer)

function MysticalStoreUI:create(openInfo)
	local layer = MysticalStoreUI.new(openInfo)
	return layer
end

function MysticalStoreUI:initListEvent()
	self.listListeners = {
     
        [cp.getConst("EventConst").StoreGoodsRsp] = function(data)	
			self:createCellItems()
            self:refreshMoney()
        end,
        
        --購買商品返回後，刷新商品的數量
        [cp.getConst("EventConst").StoreBuyRsp] = function(data)	
            if data.goodsID > 0 then
                for i,goodsInfo in ipairs(self.goodsItems) do
                    if goodsInfo.goodsID == data.goodsID then
                        self.goodsItems[i].leftNum = data.leftNum
                    end
                end                
            end
        end,
        
        --元寶銀兩更新
        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
            local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")  
            self["Text_1"]:setString(tostring(majorRole["gold"]))
            self["Text_2"]:setString(tostring(majorRole["silver"]))
        end,
        
	}
end

function MysticalStoreUI:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shop/uicsb_shop_mystical_store.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_title"] = {name = "Panel_title"},
        ["Panel_root.Panel_title.Panel_content"] = {name = "Panel_content"},
        ["Panel_root.Panel_title.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        
        ["Panel_root.Panel_title.Image_price_bg_1"] = {name = "Image_price_bg_1"},
        ["Panel_root.Panel_title.Image_price_bg_1.Image_price_type_1"] = {name = "Image_price_type_1"},
        ["Panel_root.Panel_title.Image_price_bg_1.Text_1"] = {name = "Text_1"},
        ["Panel_root.Panel_title.Image_price_bg_1.Button_add_1"] = {name = "Button_add_1",click = "onUIButtonClick"},

        ["Panel_root.Panel_title.Image_price_bg_2"] = {name = "Image_price_bg_2"},
        ["Panel_root.Panel_title.Image_price_bg_2.Image_price_type_2"] = {name = "Image_price_type_2"},
        ["Panel_root.Panel_title.Image_price_bg_2.Text_2"] = {name = "Text_2"},
        ["Panel_root.Panel_title.Image_price_bg_2.Button_add_2"] = {name = "Button_add_2",click = "onUIButtonClick"},

        ["Panel_root.Panel_refresh"] = {name = "Panel_refresh"},
        ["Panel_root.Panel_refresh.Text_time_1"] = {name = "Text_time_1"},
        ["Panel_root.Panel_refresh.Text_time"] = {name = "Text_time"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    self:setPosition(display.cx,display.cy)

    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_root)
end

function MysticalStoreUI:onEnterScene()
    local storeID = cp.getUserData("UserShop"):getValue("MysticalStore_storeID")
    local req = {}
    req.storeID = storeID --神祕商店
    cp.getUserData("UserShop"):setValue("current_storeID",req.storeID)
    self:doSendSocket(cp.getConst("ProtoConst").StoreGoodsReq, req)

end

function MysticalStoreUI:onExitScene()
    self:_stopUpdate()
end


function MysticalStoreUI:refreshItems()
    self.goodsItems = {}
    local GoodsList = cp.getUserData("UserShop"):getValue("GoodsList")
    for i=1,table.nums(GoodsList) do
        if GoodsList[i] ~= nil and GoodsList[i].goodsID > 0 then
            local goodsInfo = {}
            goodsInfo.goodsID = GoodsList[i].goodsID
            goodsInfo.leftNum = GoodsList[i].leftNum or 0
            
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("Goods",goodsInfo.goodsID)
            if cfgItem ~= nil then
                local Price = cfgItem:getValue("Price")
                local PriceType = cfgItem:getValue("Currency")
                local Rebate = cfgItem:getValue("Rebate")
                local ItemID = cfgItem:getValue("ItemID")
                goodsInfo.Price = Price
                goodsInfo.PriceType = PriceType
                goodsInfo.Rebate = Rebate
                goodsInfo.ItemID = ItemID
                if goodsInfo.ItemID > 0 then
                    local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameItem",goodsInfo.ItemID)
                    if cfgItem2 ~= nil then
                        local Name = cfgItem2:getValue("Name")
                        local Icon = cfgItem2:getValue("Icon")
                        local Colour = cfgItem2:getValue("Hierarchy")
                        goodsInfo.Name = Name
                        goodsInfo.Icon = Icon
                        goodsInfo.Colour = Colour
                    end
                end
            end
            table.insert(self.goodsItems, goodsInfo)
        end
    end
end

function MysticalStoreUI:createCellItems()
    self.Panel_content:removeAllChildren()
   
    self:refreshItems()

    local sz = self.Panel_content:getContentSize()
    self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width,sz.height))
    self.cellView:setCellSize(167,190)
    self.cellView:setColumnCount(3)
    self.cellView:setAnchorPoint(cc.p(0.5, 0))
    self.cellView:setPosition(cc.p(6, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.goodsItems)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1

        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.shop.SecondShopItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(3,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
    
        local data = self.goodsItems[idx]
        item:resetInfo(data)
        
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.cellView:reloadData()
    self["Panel_content"]:addChild(self.cellView)
    
end

function MysticalStoreUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        cp.getManager("PopupManager"):removePopup(self)
    elseif buttonName == "Button_add_1" then
        cp.getManager("ViewManager").showRechargeUI()
    elseif buttonName == "Button_add_2" then
        cp.getManager("ViewManager").showSilverConvertUI()
    end
end



function MysticalStoreUI:_startUpdate()
    self:_stopUpdate()
    if self.leftTime > 0 then
        self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),1,false)
    end
end

function MysticalStoreUI:_stopUpdate()
    if self._scheduleID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleID)
    end
    self._scheduleID = nil
  
end

function MysticalStoreUI:_update()
    if self.leftTime <= 0 then
        self:_stopUpdate()
        
        self:dispatchViewEvent(cp.getConst("EventConst").StoreTimeOut, {}) 
        cp.getManager("PopupManager"):removePopup(self)
    else
        local str =  cp.getUtils("DataUtils").formatTimeRemainWAllShow(self.leftTime)
        self.Text_time:setString(str)
        self.leftTime = self.leftTime - 1
    end
end



function MysticalStoreUI:refreshMoney()
    
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")  
    self["Text_1"]:setString(tostring(majorRole["gold"]))
    self["Text_2"]:setString(tostring(majorRole["silver"]))

    local now = cp.getManager("TimerManager"):getTime()
    local MysticalStore_closeStamp = cp.getUserData("UserShop"):getValue("MysticalStore_closeStamp")
    self.leftTime = MysticalStore_closeStamp - now
    self:_startUpdate()
end

return MysticalStoreUI
