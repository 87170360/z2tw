
local BLayer = require "cp.view.ui.base.BLayer"
local ShopMainUI = class("ShopMainUI",BLayer)

function ShopMainUI:create(openInfo)
	local layer = ShopMainUI.new(openInfo)
	return layer
end

function ShopMainUI:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,

        [cp.getConst("EventConst").StoreGoodsRsp] = function(data)	
			dump(data)
            local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            local idx = self:storeIDToTabIndex(storeID)
            self:switchToShopType(idx)
        end,
        
         --刷新商店物品列表
         [cp.getConst("EventConst").StoreRefreshRsp] = function(data)	
			local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            local idx = self:storeIDToTabIndex(storeID)
            self:switchToShopType(idx)
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
            if data.storeID == 7 or data.storeID == 10 then --天書殘頁,幫派商店
                self:refreshMoney()
            end
        end,

        --元寶銀兩更新
        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
            self:refreshMoney()
        end,

        ["NotifyMemberContributeRsp"] = function(evt)
            self:refreshMoney()
        end,

        [cp.getConst("EventConst").close_shop_view] = function(evt)
            if  self.openInfo ~= nil and self.openInfo.closeCallBack ~= nil then
                self.openInfo.closeCallBack()
            end
        end,
        
	}
end

function ShopMainUI:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shop/uicsb_shop_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Panel_top"] = {name = "Panel_top"},
        ["Panel_root.Panel_top.Text_title"] = {name = "Text_title"},
        ["Panel_root.Panel_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},

        ["Panel_root.Panel_top.Image_price_bg_1"] = {name = "Image_price_bg_1"},
        ["Panel_root.Panel_top.Image_price_bg_1.Image_price_type_1"] = {name = "Image_price_type_1"},
        ["Panel_root.Panel_top.Image_price_bg_1.Text_1"] = {name = "Text_1"},
        ["Panel_root.Panel_top.Image_price_bg_1.Button_add_1"] = {name = "Button_add_1",click = "onUIButtonClick"},

        ["Panel_root.Panel_top.Image_price_bg_2"] = {name = "Image_price_bg_2"},
        ["Panel_root.Panel_top.Image_price_bg_2.Image_price_type_2"] = {name = "Image_price_type_2"},
        ["Panel_root.Panel_top.Image_price_bg_2.Text_2"] = {name = "Text_2"},
        ["Panel_root.Panel_top.Image_price_bg_2.Button_add_2"] = {name = "Button_add_2",click = "onUIButtonClick"},

        ["Panel_root.Panel_top.ScrollView_1"] = {name = "ScrollView_1"},
        
        ["Panel_root.Panel_top.ScrollView_tab"] = {name = "ScrollView_tab"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_1"] = {name = "Image_1",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_2"] = {name = "Image_2",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_3"] = {name = "Image_3",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_4"] = {name = "Image_4",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_5"] = {name = "Image_5",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_6"] = {name = "Image_6",click = "onTabItemClick"},
        ["Panel_root.Panel_top.ScrollView_tab.Image_7"] = {name = "Image_7",click = "onTabItemClick"},

        ["Panel_root.Panel_top.Panel_tab"] = {name = "Panel_tab"},
        ["Panel_root.Panel_top.Panel_tab.Image_100"] = {name = "Image_100",click = "onTabItemClick"},
        ["Panel_root.Panel_top.Panel_tab.Image_101"] = {name = "Image_101",click = "onTabItemClick"},

        ["Panel_root.Panel_top.Panel_refresh"] = {name = "Panel_refresh"},
        ["Panel_root.Panel_top.Panel_refresh.Text_auto_refresh"] = {name = "Text_auto_refresh"},
        ["Panel_root.Panel_top.Panel_refresh.Text_time"] = {name = "Text_time"},
        ["Panel_root.Panel_top.Panel_refresh.Text_price_free"] = {name = "Text_price_free"},
        ["Panel_root.Panel_top.Panel_refresh.Image_price"] = {name = "Image_price"},
        ["Panel_root.Panel_top.Panel_refresh.Image_price.Text_price"] = {name = "Text_price"},
        ["Panel_root.Panel_top.Panel_refresh.Button_refresh"] = {name = "Button_refresh",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b)
    

    self.Panel_tab:setVisible(self.openInfo.storeID == 5 or self.openInfo.storeID == 11) --俠義商店 鐵膽商店
    self.ScrollView_tab:setVisible(not (self.openInfo.storeID == 5 or self.openInfo.storeID == 11)) --俠義商店 鐵膽商店
    self.ScrollView_tab:setScrollBarEnabled(false)
    self.ScrollView_1:setScrollBarEnabled(false)


    self.Text_title:setString( self.Panel_tab:isVisible() and "江湖商店" or  "商  城")
    
    self:adapterReslution()
    self:createItems()
    ccui.Helper:doLayout(self["rootView"])
    --cp.getManager("ViewManager").popUpView(self.Panel_root)
end


function ShopMainUI:adapterReslution()
    self.rootView:setContentSize(display.size)
    local sz_ScrollView_1 = self.ScrollView_1:getContentSize() 
    self.ScrollView_1:setPositionY(display.height > 1280 and -110 or -70)
    
    sz_ScrollView_1.height = display.height - self.Panel_top:getContentSize().height + self.ScrollView_1:getPositionY() - self.Panel_refresh:getContentSize().height - 150
    sz_ScrollView_1.height = math.min(800,sz_ScrollView_1.height)

    local height_Panel_refresh = self.ScrollView_1:getPositionY() - sz_ScrollView_1.height - 20
    
    --self.Image_bg:loadTexture("img/bg/bg_shop/module46_shangdian1.png",ccui.TextureResType.localType)
    self.Image_bg:ignoreContentAdaptWithSize(false)
    -- self.Image_bg:setPositionY(display.height == 960 and 320 or 440)
    self.Image_bg:setContentSize(cc.size(display.width, display.height > 1280 and display.height or 1280))
    self.ScrollView_1:setContentSize(cc.size(sz_ScrollView_1.width,sz_ScrollView_1.height))
    -- self.Panel_root:setPositionY(display.height) --110為底部一排按鈕的高度
    self.Panel_refresh:setPositionY(height_Panel_refresh)

    if self.ScrollView_tab:isVisible() then
        self.ScrollView_tab:setPositionY(display.height > 1280 and -75 or -35)
        local sz_ScrollView_tab = self.ScrollView_tab:getContentSize()
        sz_ScrollView_tab.height = display.height - self.Panel_top:getContentSize().height + self.ScrollView_tab:getPositionY() - 140
        sz_ScrollView_tab.height = math.min(960,sz_ScrollView_tab.height)
        self.ScrollView_tab:setContentSize(cc.size(sz_ScrollView_tab.width,sz_ScrollView_tab.height))
    end

    ccui.Helper:doLayout(self["rootView"])
end

function ShopMainUI:onEnterScene()

    local storeID = self.openInfo.storeID

    cp.getUserData("UserShop"):setValue("current_storeID",storeID)
    local idx = self:storeIDToTabIndex(storeID)
    
    self:onTabItemClick(self["Image_" .. tostring(idx)])
    
end

function ShopMainUI:onExitScene()
    self:_stopUpdate()
end

function ShopMainUI:createItems()

    self.shopItemList = {}
    local sz_root = self.ScrollView_1:getInnerContainerSize() 
    for i=1,12 do
        local shopItem = require("cp.view.scene.world.shop.ShopItem"):create()

        shopItem:setItemClickCallBack(handler(self,self.onShopItemClicked))
        local y = math.floor((i-1)/3)
        local x = math.floor((i-1)%3)
        local sz = shopItem:getItemSize()
        shopItem:setPosition(cc.p(x*sz.width+55, sz_root.height - y*sz.height))
        if x == 0 then
            shopItem:resetBG(true)
        end
        self.ScrollView_1:addChild(shopItem)
        self.shopItemList[i] = shopItem
    end
    self.ScrollView_1:jumpToTop()
end


function ShopMainUI:onTabItemClick(sender)
    local idx = tonumber(string.sub(sender:getName(),string.len("Image_")+1))
    log("onTabItemClick idx =" .. idx)

    local storeID = sender:getTag()
    if storeID == 2 then
        local now = cp.getManager("TimerManager"):getTime()
        local nowTimeTable = os.date("*t",now)  -- wday (weekday, Sunday is 1)
        if nowTimeTable.wday ~= 1 then --從週日開始算第一天，不是週日則顯示 商城(個人)
            storeID = 9
        end
    end
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("Store",storeID)
    if cfgItem then
        local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        if roleAtt.hierarchy < cfgItem:getValue("Hierarchy") then
            cp.getManager("ViewManager").gameTip("人物達到" .. tostring(cfgItem:getValue("Hierarchy")) .. "階後開啟!")
            return
        end
        if storeID == 1 then --門派商店
            local needRedPoint = cp.getManager("LocalDataManager"):getUserValue("redpoint","menpaishop",false)
            if not needRedPoint then
                cp.getManager("LocalDataManager"):setUserValue("redpoint","menpaishop",true)
            end
        end
    end


    local req = {}
    req.storeID = storeID
    cp.getUserData("UserShop"):setValue("current_storeID",req.storeID)
    self:doSendSocket(cp.getConst("ProtoConst").StoreGoodsReq, req)

    self:refreshMoney()
    
    self:refreshTabState(idx)

end


function ShopMainUI:storeIDToTabIndex(storeID)
    local storeid_tabIndex = {[1]=1,[2]=2,[3]=3,[4]=4,[5]=100,[6]=5,[7]=6,[9]=4,[10]=7,[11]=101}
    return storeid_tabIndex[storeID]
end

function ShopMainUI:refreshTabState(idx)

    local path_list = {
        [1]={"ui_shop_module46_shangdian3.png","ui_shop_module46_shangdian20.png"},
        [2]={"ui_shop_module46_shangdian7.png","ui_shop_module46_shangdian16.png"},
        [3]={"ui_shop_module46_shangdian8.png","ui_shop_module46_shangdian15.png"},
        [4]={"ui_shop_module46_shangdian9.png","ui_shop_module46_shangdian14.png"}, 
        [5]={"ui_shop_module46_shangdian5.png","ui_shop_module46_shangdian18.png"},
        [6]={"ui_shop_module46_shangdian4.png","ui_shop_module46_shangdian19.png"},
        [7]={"ui_shop_module46_shangdian24.png","ui_shop_module46_shangdian25.png"},

        [100]={"ui_shop_module46_smsd_4.png","ui_shop_module46_smsd_5.png"},
        [101]={"ui_shop_module46_smsd_2.png","ui_shop_module46_smsd_3.png"},

    }
    if idx <= 7 then
        for i=1,7 do
            local path = path_list[i][idx == i and 2 or 1]
            self["Image_" .. tostring(i)]:loadTexture(path, ccui.TextureResType.plistType)
        end
    else
        for i=100,101 do
            local path = path_list[i][idx == i and 2 or 1]
            self["Image_" .. tostring(i)]:loadTexture(path, ccui.TextureResType.plistType)
        end
    end
end

function ShopMainUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if  self.openInfo ~= nil and self.openInfo.closeCallBack ~= nil then
            self.openInfo.closeCallBack()
        end
    elseif buttonName == "Button_add_1" then
        local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
        if not (storeID == 5 or storeID == 6 or storeID == 7 or storeID == 10) then
            cp.getManager("ViewManager").showRechargeUI()
        end

    elseif buttonName == "Button_add_2" then
        cp.getManager("ViewManager").showSilverConvertUI()
        
    elseif buttonName == "Button_refresh" then
        local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
        local price = self.refresh_price
        local function comfirmFunc()
            local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            local req = {}
            req.storeID = storeID
            self:doSendSocket(cp.getConst("ProtoConst").StoreRefreshReq, req)
        end
        -- if self.refresh_price > 0 then
        --     local contentTable = {
        --         {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        --         {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(self.refresh_price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        --         {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
        --         {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="," ,textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        --         {type="blank", fontSize=1},
        --         {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="來立即刷新商店物品？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        --     }
        --     cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
        -- else
        --     comfirmFunc()
        -- end

        comfirmFunc()
        
    end
end

function ShopMainUI:refreshUI()  

    self:refreshItems()

    for i=1,table.nums(self.shopItemList) do
        self.shopItemList[i]:resetInfo(self.goodsItems[i]) 
    end
end


function ShopMainUI:refreshItems()
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
                    else
                        log("ItemID is not exist,id=" .. tostring(goodsInfo.ItemID))
                    end
                end

                table.insert(self.goodsItems, goodsInfo)
            else
                log("goodID is not exist,id=" .. tostring(goodsInfo.goodsID))
            end
            
        end
    end

    if #self.goodsItems > 0 then
        table.sort(self.goodsItems,function(a,b)
            return a.goodsID > b.goodsID
        end)
    end
end


function ShopMainUI:_startUpdate()
    self:_stopUpdate()
    if self.leftTime > 0 then
        self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),1,false)
    end
end

function ShopMainUI:_stopUpdate()
    if self._scheduleID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleID)
    end
    self._scheduleID = nil
  
end

function ShopMainUI:_update()
    if self.leftTime < 0 then
        self:_stopUpdate()
        self:setRefreshTimePrice()
    else
        
        local str =  cp.getUtils("DataUtils").formatTimeRemainWAllShow(self.leftTime)
        self.Text_time:setString(str)
        self.leftTime = self.leftTime - 1
    end
end

function ShopMainUI:refreshMoney()
    
    self["Image_price_bg_2"]:setVisible(false)
    self["Button_add_1"]:setVisible(true)
    self["Button_add_2"]:setVisible(true)
    
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local storeID = cp.getUserData("UserShop"):getValue("current_storeID")
    if storeID == 5 then  --俠義商店
        self["Text_1"]:setString(tostring(majorRole["conductGood"]))
        self["Image_price_type_1"]:loadTexture("ui_common_sz.png", ccui.TextureResType.plistType)
        self["Image_price_bg_2"]:setVisible(false)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    elseif storeID == 11 then  --鐵膽商店
        self["Text_1"]:setString(tostring(majorRole["conductBad"]))
        self["Image_price_type_1"]:loadTexture("ui_common_ez.png", ccui.TextureResType.plistType)
        self["Image_price_bg_2"]:setVisible(false)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    elseif storeID == 6 then --聲望
        self["Text_1"]:setString(tostring(majorRole["prestige"]))
        self["Image_price_type_1"]:loadTexture("ui_common_swz.png", ccui.TextureResType.plistType)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    elseif storeID == 7 then  --天書殘頁
        local num = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").TianShuCanYe_ItemID) --天書殘頁的物品id為10
        self["Text_1"]:setString(tostring(num))
        self["Image_price_type_1"]:loadTexture("ui_common_06tscy.png", ccui.TextureResType.plistType)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    elseif storeID == 10 then  --幫派商店
        local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(majorRole.id)
        local num = memberInfo and (memberInfo.contribute or 0) or 0
        self["Text_1"]:setString(tostring(num))
        self["Image_price_type_1"]:loadTexture("ui_common_bg.png", ccui.TextureResType.plistType)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    elseif storeID == 9 or storeID == 2 then --精品商店
        self["Text_1"]:setString(tostring(majorRole["jade"]))
        self["Image_price_type_1"]:loadTexture("ui_common_module33_vip_goumai_yu.png", ccui.TextureResType.plistType)
        self["Image_price_bg_1"]:setPositionX(460)
        self["Button_add_1"]:setVisible(false)
        self["Button_add_2"]:setVisible(false)
    else
        self["Text_1"]:setString(tostring(majorRole["gold"]))
        self["Text_2"]:setString(tostring(majorRole["silver"]))
        self["Image_price_type_1"]:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        self["Image_price_type_2"]:loadTexture("ui_common_yinliang.png", ccui.TextureResType.plistType)
        self["Image_price_bg_2"]:setVisible(true)
        self["Image_price_bg_1"]:setPositionX(340)
    end

end

function ShopMainUI:switchToShopType(type)
    self.type = type

    self:refreshUI()

    self:setRefreshTimePrice()

    self.ScrollView_1:jumpToTop()
end

function ShopMainUI:onShopItemClicked(goodsInfo)
    dump(goodsInfo)
    if goodsInfo.leftNum <= 0 then
        cp.getManager("ViewManager").gameTip(goodsInfo.Name .. "已經售罄，請選其他的吧！")
        return
    end


    local function openBuyMessageBox()

        local PriceType = goodsInfo.PriceType
        local Price = goodsInfo.Price
        local Name = goodsInfo.Name
        local leftNum = goodsInfo.leftNum
        
        -- 元寶1， 銀兩2， 聲望3，俠義令4，鐵膽令5，天書殘頁6,幫派個人資金7，幫貢8
        local VirtualItemType = cp.getConst("GameConst").VirtualItemType
        local types = {
            [1] = VirtualItemType.gold, 
            [2]=VirtualItemType.silver, 
            [3]=VirtualItemType.prestige, 
            [4]=VirtualItemType.goodPoint, 
            [5]=VirtualItemType.badPoint,
            [6]=VirtualItemType.tscy,
            [7]=VirtualItemType.guildGold,
            [8]=VirtualItemType.guildContribute,
            [9]=VirtualItemType.jade
        }

        local function comfirmFunc(num,goodsInfo)
            local needValue = num * Price

            local result = true
            if PriceType == 6 then --天書殘頁
                local have_num = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").TianShuCanYe_ItemID) --天書殘頁的物品id為10
                result = have_num >= needValue
                if not result then
                    cp.getManager("ViewManager").gameTip("天書殘頁數量不足")
                end
            else
                local itemType = types[PriceType]
                result = cp.getManager("ViewManager").checkVirtualItemEnough(needValue,itemType)
            end
            
            if result then
                local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID")
                local data = {goodsID=goodsInfo.goodsID}
                data.buyNum = num
                data.storeID = current_storeID
                self:doSendSocket(cp.getConst("ProtoConst").StoreBuyReq,data)
            end
        end

        if leftNum >= 1 then
            local itemInfo = {Name = goodsInfo.Name, Colour = goodsInfo.Colour, num = goodsInfo.leftNum, goodsID = goodsInfo.goodsID, id = goodsInfo.ItemID,PriceType = types[PriceType],Price = Price}
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
            cp.getManager("ViewManager").gameTip(Name .. "已經售罄，請選其他的吧！")
        end
    end

    local function closeCallBack(buttonName,Info,config)
        if "Button_buy" == buttonName then
            openBuyMessageBox()
        end
    end

    local buyItemInfo = {id = goodsInfo.ItemID,openType = "ViewShopItem"}
    cp.getManager("ViewManager").showItemTip(buyItemInfo,closeCallBack)
end


--刷新剩餘時間
function ShopMainUI:setRefreshTimePrice()
    local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID") 
    
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("Store",current_storeID)
    if cfgItem ~= nil then
        local RefreshType = cfgItem:getValue("RefreshType") -- 刷新類型 1定時，2手動, 3定時兼手動，4商店開啟
        self.Panel_refresh:setVisible(RefreshType ~= 4)
        if RefreshType == 4 then --開啟刷新
            return
        elseif RefreshType == 1 then --只能系統刷新
            self.Text_auto_refresh:setPositionY(55)
            self.Text_time:setPositionY(55)
            self.Image_price:setVisible(false)
            self.Button_refresh:setVisible(false)
            self.Text_price_free:setVisible(false)
        else
            self.Text_auto_refresh:setPositionY(15)
            self.Text_time:setPositionY(15)
            self.Image_price:setVisible(true)
            self.Button_refresh:setVisible(true)

        end

        --計算剩餘時間，開啟定時器
        self.Text_auto_refresh:setVisible(RefreshType == 1 or RefreshType == 3)
        self.Text_time:setVisible(RefreshType == 1 or RefreshType == 3)
        self.leftTime = 0
        if RefreshType == 1 or RefreshType == 3 then
            local RefreshTime = cfgItem:getValue("RefreshTime")
            local timeList = {}
            string.loopSplit(RefreshTime,"|:",timeList)
            local curDate = cp.getManager("TimerManager"):getDate()
            for i=1,table.nums(timeList) do
                local leftHour = tonumber(timeList[i][1]) - curDate.hour
                local leftMin = tonumber(timeList[i][2]) - curDate.min
                local leftSec = tonumber(timeList[i][3]) - curDate.sec
                if leftHour > 0 or (leftHour == 0 and leftMin > 0) or (leftHour == 0 and leftMin == 0 and leftSec > 0 ) then
                
                    self.leftTime = leftHour*3600
                    self.leftTime = self.leftTime + leftMin*60
                    self.leftTime = self.leftTime + leftSec  
                    break
                end
            end
            local cnt = #timeList
            local needNextDay = (tonumber(timeList[cnt][1])*3600 + tonumber(timeList[cnt][2])*60 + tonumber(timeList[cnt][3])) - (curDate.hour*3600+ curDate.min*60 + curDate.sec) < 0
            if self.leftTime == 0 and needNextDay then  --需要跨天
            
                local leftHour = tonumber(timeList[1][1])+24 - curDate.hour
                local leftMin = tonumber(timeList[1][2]) - curDate.min
                local leftSec = tonumber(timeList[1][3]) - curDate.sec
                self.leftTime = leftHour*3600
                self.leftTime = self.leftTime + leftMin*60
                self.leftTime = self.leftTime + leftSec

            end
        end
        self:_startUpdate()
    

        --計算手動刷新價格
        if RefreshType == 2 or RefreshType == 3 then
            local refreshCount = cp.getUserData("UserShop"):getValue("RefreshCount")
            local RefreshPrice = cfgItem:getValue("RefreshPrice")
            local priceList = string.split(RefreshPrice,"|")
            local idx = refreshCount+1
            idx = math.min(idx,table.nums(priceList))
            local price = priceList[idx]
            self.refresh_price = tonumber(price)
            self.Text_price_free:setVisible(self.refresh_price == 0)
            self.Image_price:setVisible(self.refresh_price ~= 0)
            if self.refresh_price ~= 0 then
                self.Text_price:setString("花費 " .. tostring(price))
            end
        end
    end
end

return ShopMainUI
