
local BLayer = require "cp.view.ui.base.BLayer"
local FashionMainLayer = class("FashionMainLayer",BLayer)
function FashionMainLayer:create(openInfo)
	local layer = FashionMainLayer.new(openInfo)
	return layer
end

function FashionMainLayer:initListEvent()
	self.listListeners = {
        --購買時裝返回
        [cp.getConst("EventConst").BuyFashionRsp] = function(data)	

            self:refreshCoin()
            self:refreshUI()

            cp.getManager("ViewManager").showFaceUnlockNotice(data.fashionID,handler(self,self.onFaceUnlockNoticeClosed))
        end,
        --使用時裝
        [cp.getConst("EventConst").UseFashionRsp] = function(data)	
            self:refreshUI()
        end,

        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(data)	
            self:refreshCoin()
        end,

        
	}
end

function FashionMainLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_fashion/uicsb_fashion_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg_top"] = {name = "Image_bg_top"},
        ["Panel_root.Button_back"] = {name = "Button_back",click = "onUIButtonClick"},
        ["Panel_root.Button_buy"] = {name = "Button_buy",click = "onUIButtonClick"},
        ["Panel_root.Button_buy.Text_buy"] = {name = "Text_buy"},
        ["Panel_root.Image_price"] = {name = "Image_price"},
        ["Panel_root.Image_price.Text_value"] = {name = "Text_value"},
		
        ["Panel_root.Image_bg_top.Image_top.Image_add_bg.Image_add"] = {name = "Image_add",click = "onUIButtonClick"},
        ["Panel_root.Image_bg_top.Image_top.Image_add_bg.Text_owned_value"] = {name = "Text_owned_value"},
        ["Panel_root.Image_bg_top.Image_top.Button_attribute"] = {name = "Button_attribute",click = "onUIButtonClick"},

        ["Panel_root.Image_bg_top.Image_bg_bottom"] = {name = "Image_bg_bottom"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_page"] = {name = "Panel_page"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top"] = {name = "Panel_top"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_prev"] = {name = "Image_prev",click = "onUIButtonClick"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_next"] = {name = "Image_next",click = "onUIButtonClick"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_owned"] = {name = "Image_owned"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_owned.Image_state"] = {name = "Image_state"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_limited"] = {name = "Image_limited"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_name"] = {name = "Image_name"},

        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_attribute_1"] = {name = "Image_attribute_1"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_attribute_2"] = {name = "Image_attribute_2"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_attribute_3"] = {name = "Image_attribute_3"},
        ["Panel_root.Image_bg_top.Image_bg_bottom.Panel_top.Image_attribute_4"] = {name = "Image_attribute_4"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self:adapterReslution()
    
    self:setItemView()
    local apple_test_version = cp.getManualConfig("Net").apple_test_version
    if apple_test_version == true then
        self["Image_add"]:setVisible(false)
    end
    ccui.Helper:doLayout(self["rootView"])
end

function FashionMainLayer:onEnterScene()
    
    self.currentIndex = 1
    self:changeToPage( self.currentIndex )
    
    self:refreshCoin()
end

function FashionMainLayer:onExitScene()
   
end

function FashionMainLayer:refreshCoin()
    local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
    self.Text_owned_value:setString(tostring(fashion_data.coin))
end

function FashionMainLayer:adapterReslution()
    self.Panel_page:setPositionY(1070)
    self.Button_back:setPositionY(48)
    if display.height > 1500 then
        self.Image_bg_bottom:setPositionY(-1120)
        self.Panel_page:setPositionY(1000)
        self.Button_back:setPositionY(128)
    elseif display.height > 1400 then
        self.Image_bg_bottom:setPositionY(-1120)
        self.Panel_page:setPositionY(1000)
        self.Button_back:setPositionY(88)
    elseif display.height > 1200 then
        self.Image_bg_bottom:setPositionY(-1050)
    elseif display.height > 1000 then
        self.Image_bg_bottom:setPositionY(-870)
    else
        self.Image_bg_bottom:setPositionY(-762)
    end
    
    local _,backPosY = self.Button_back:getPosition()
    self.Image_price:setPositionY(backPosY-4 )
    self.Button_buy:setPositionY(backPosY)

	-- ccui.Helper:doLayout(self["rootView"])

end

function FashionMainLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function FashionMainLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_back" then
        if self.closeCallBack then
            self.closeCallBack()
        end
        cp.getManager("PopupManager"):removePopup(self)
    elseif buttonName == "Image_prev" then
        self.currentIndex = self.currentIndex - 1
        if self.currentIndex >= 1 then
            self:changeToPage( self.currentIndex )
        else
            self.currentIndex = 1
        end
        self.Image_prev:setTouchEnabled(false)
        self.Image_prev:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 
            self.Image_prev:setTouchEnabled(true)
        end)))
    elseif buttonName == "Image_next" then
        self.currentIndex = self.currentIndex + 1
        if self.currentIndex <= self.totalPage then
            self:changeToPage( self.currentIndex )
        else
            self.currentIndex = self.totalPage
        end
        self.Image_next:setTouchEnabled(false)
        self.Image_next:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 
            self.Image_next:setTouchEnabled(true)
        end)))
    elseif buttonName == "Image_add" then
        local apple_test_version = cp.getManualConfig("Net").apple_test_version
        if apple_test_version == true then
            return
        end
        cp.getManager("ViewManager").showRechargeUI()
    elseif buttonName == "Button_attribute" then
		local layer = require("cp.view.scene.world.fashion.FashionAttributeLayer"):create()
		self:addChild(layer, 100)
    elseif buttonName == "Button_buy" then
        local fashionInfo = self.fashionList[self.currentIndex]
        local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
        local isOwned = table.arrIndexOf(fashion_data.own,fashionInfo.ID) ~= -1

        if not isOwned then
            if fashion_data.coin >= fashionInfo.Price then
                
                local function comfirmFunc()
                    local req = {}
                    req.fashionID = fashionInfo.ID
                    self:doSendSocket(cp.getConst("ProtoConst").BuyFashionReq, req)
                end
                
                local contentTable = {
                    {type="ttf", fontName="fonts/msyh.ttf", fontSize=24, text="是否花費 ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
                    {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(fashionInfo.Price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
                    {type="image",filePath="ui_common_module40_shizhuang_8.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
                    {type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text="，購買時裝【" .. fashionInfo.Name .. "】？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
                }
                cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

            else
				-- cp.getManager("ViewManager").showGameMessageBox("系統消息","時裝券不足，是否前往儲值界面購買？",2,function()
                --         --打開儲值界面
                --         cp.getManager("ViewManager").showRechargeUI()
                --     end,nil)
                cp.getManager("ViewManager").gameTip("時裝券不足")
            end
        else
            local req = {}
            local isUsed = fashion_data.use == fashionInfo.ID
            req.fashionID = isUsed and 0 or fashionInfo.ID  --使用的時候則卸下
            self:doSendSocket(cp.getConst("ProtoConst").UseFashionReq, req)
        end
    end
end

function FashionMainLayer:refreshUI(idx)
    idx = idx or self.currentIndex
	
    local fashionInfo = self.fashionList[idx]
    if fashionInfo == nil then
        return
    end

    local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
    local isUsed = fashion_data.use == fashionInfo.ID
    local isOwned = table.arrIndexOf(fashion_data.own,fashionInfo.ID) ~= -1

    self.Image_owned:setVisible(isOwned)
    if isOwned then
        local img = isUsed and "ui_fashion_module40_shizhuang_16.png" or "ui_fashion_module40_shizhuang_17.png"
        self.Image_state:loadTexture(img, ccui.TextureResType.plistType)
    end
    self.Image_limited:setVisible(fashionInfo.Condition>0)
    if fashionInfo.Condition>0 then
        self.Image_limited:loadTexture("ui_fashion_module40_shizhuang_10.png", ccui.TextureResType.plistType)
    end
    self.Image_name:setVisible(true)
    self.Image_name:loadTexture(fashionInfo.NameImg,ccui.TextureResType.plistType)
    self.Image_name:ignoreContentAdaptWithSize(true)

    self.Image_price:setVisible(not isOwned and fashionInfo.Price > 0)
    if self.Image_price:isVisible() then
        self.Image_price:getChildByName("Text_value"):setString(tostring(fashionInfo.Price))
    end

    for i=1,4 do
        if fashionInfo.att_list ~= nil and fashionInfo.att_list[i] ~= nil then
            self["Image_attribute_" .. tostring(i)]:setVisible(true)
            local type = fashionInfo.att_list[i].type
            local value = fashionInfo.att_list[i].value 
            local str = cp.getConst("CombatConst").AttributeList[type] .. "+"
            if type >= 50 then
                str = str .. tostring(math.floor(value/100)) .. "%"
            else
                str = str .. tostring(value) 
            end
            self["Image_attribute_" .. tostring(i)]:getChildByName("Text_value"):setString(str)
        else
            self["Image_attribute_" .. tostring(i)]:setVisible(false)
        end
    end
    
    self.Text_buy:setString(isUsed and "卸 下" or ( isOwned and "裝 備" or "購 買"))
end



function FashionMainLayer:setItemView()
    self.fashionList =  cp.getManager("GDataManager"):getAllFashionConfigInfo()
    self.totalPage = table.nums(self.fashionList)

	self.cellView = cp.getManager("ViewManager").createCellView(cc.size(700, 850))
	self.cellView:setCellSize(700, 850)
    self.cellView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	self.cellView:setCountFunction(function()
	 	return self.totalPage
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()
    self.cellView:setPosition(cc.p(0, 0))
    self.cellView:setTouchEnabled(false)
    self.Panel_page:addChild(self.cellView,1)

end

function FashionMainLayer:cellFactory(cellview, idx)
    local item = nil
    local cell = cellview:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
		item = ccui.Layout:create()
        item:setContentSize(cc.size(700,850))
        -- item:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        -- item:setBackGroundColor(cc.c3b(0,128,64))
        -- item:setBackGroundColorOpacity(128)
        item:setTouchEnabled(false)
        item:setClippingEnabled(true)
		item:setAnchorPoint(cc.p(0, 0))
		item:setPosition(cc.p(0, 0))
		item:setName("CellItem")
		cell:addChild(item)
    else
		item = cell:getChildByName("CellItem")
    end

	self:resetCellInfo(item,idx)	
    return cell
end

 
function FashionMainLayer:resetCellInfo(item,idx)
    if idx < 1 or idx > self.totalPage then
        return
    end
    item:removeAllChildren()
    local ModelID = self.fashionList[idx].ModelID

    local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameModel", ModelID)
    local wholeDraw = nil
    if cfgItem2 ~= nil then
        wholeDraw = cfgItem2:getValue("WholeDraw")
    end
    if wholeDraw and wholeDraw ~= "" then
        local Image_role = ccui.ImageView:create()
        Image_role:loadTexture(wholeDraw, ccui.TextureResType.localType)
        Image_role:ignoreContentAdaptWithSize(false)
        Image_role:setAnchorPoint(cc.p(0.5,0.5))
        Image_role:setPosition(cc.p(230,408))
        item:addChild(Image_role)
    end

end

function FashionMainLayer:changeToPage(idx)

    local offsetX = (idx-1) * 700 * (-1) 
    offsetX = math.min(offsetX,0)
    offsetX = math.max(offsetX,-14*700)
    self.cellView:setContentOffsetInDuration(cc.p(offsetX,0), 0.25)

    self:refreshUI(idx)

    self.Image_prev:setVisible(idx>1)
    self.Image_next:setVisible(idx<self.totalPage)
end


function FashionMainLayer:onFaceUnlockNoticeClosed(select_face)
    if select_face == nil or select_face == "" then
        return
    end
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local openInfo = {type = "fashion",face = select_face, gender = majorRole.gender}
    local PlayerHeadChangeUI = require("cp.view.ui.messagebox.PlayerHeadChangeUI"):create(openInfo)
    PlayerHeadChangeUI:setCloseCallBack(function (faceID)
        if majorRole.face ~= faceID then
            --發送協議更換頭像
            local req = {face = faceID}
            self:doSendSocket(cp.getConst("ProtoConst").ChangeFaceReq, req)
        end
    end)
    self.rootView:addChild(PlayerHeadChangeUI, 2)
end

return FashionMainLayer
