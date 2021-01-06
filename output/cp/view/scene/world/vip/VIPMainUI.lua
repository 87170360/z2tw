
local BLayer = require "cp.view.ui.base.BLayer"
local VIPMainUI = class("VIPMainUI",BLayer)
local socket = require "socket"
function VIPMainUI:create(openInfo)
	local layer = VIPMainUI.new(openInfo)
	return layer
end

function VIPMainUI:initListEvent()
	self.listListeners = {
        
        --領取或購買禮包後刷新
        [cp.getConst("EventConst").GetVipGiftRsp] = function(evt)
            self:setLiBaoButtonState()
        end,
       
        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:setLiBaoButtonState()
        end,
        
	}
end

function VIPMainUI:onInitView(openInfo)
    self.beginTime = socket.gettime()
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_vip/uicsb_vip_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_top"] = {name = "Panel_top"},
        
        ["Panel_root.Panel_top.FileNode_1"] = {name = "FileNode_1"},
        ["Panel_root.Panel_top.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Panel_top.Image_bg_1"] = {name = "Image_bg_1"},
        
        ["Panel_root.Panel_top.ListView_1"] = {name = "ListView_1"},
        ["Panel_root.Panel_top.ListView_1.Panel_tequan"] = {name = "Panel_tequan"},
        ["Panel_root.Panel_top.ListView_1.Panel_tequan.Image_1"] = {name = "Image_1"},
        ["Panel_root.Panel_top.ListView_1.Panel_tequan.Panel_list"] = {name = "Panel_list"},
        ["Panel_root.Panel_top.ListView_1.Panel_tequan.Panel_title.Image_title_1.Text_title_tequan"] = {name = "Text_title_tequan"},
        
        ["Panel_root.Panel_top.ListView_1.Panel_tequan.Button_prev"] = {name = "Button_prev", click = "onUIButtonClick"},
        ["Panel_root.Panel_top.ListView_1.Panel_tequan.Button_next"] = {name = "Button_next", click = "onUIButtonClick"},
        
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1"] = {name = "Panel_libao_1"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1.Image_title_1.Text_title_1"] = {name = "Text_title_1"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1.Button_buy_1"] = {name = "Button_buy_1",click = "onUIButtonClick"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1.Image_discount"] = {name = "Image_discount"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1.Image_discount.Text_discount"] = {name = "Text_discount"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_1.Text_price_1"] = {name = "Text_price_1"},
        
        ["Panel_root.Panel_top.ListView_1.Panel_libao_2"] = {name = "Panel_libao_2"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_2.Image_title_2.Text_title_2"] = {name = "Text_title_2"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_2.Button_buy_2"] = {name = "Button_buy_2",click = "onUIButtonClick"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_2.Text_price_old_2"] = {name = "Text_price_old_2"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_2.Text_price_2"] = {name = "Text_price_2"},
        
        ["Panel_root.Panel_top.ListView_1.Panel_libao_3"] = {name = "Panel_libao_3"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_3.Image_title_3.Text_title_3"] = {name = "Text_title_3"},
        ["Panel_root.Panel_top.ListView_1.Panel_libao_3.Button_free_get"] = {name = "Button_free_get",click = "onUIButtonClick"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
   
    local VipTopUI = require("cp.view.scene.world.vip.VipTopUI"):create("VIPMainUI")
    VipTopUI:setButtonClickCallBack(function()
        cp.getManager("ViewManager").showRechargeUI()
    end)
    self.FileNode_1:addChild(VipTopUI)
    
    self:adapterReslution()

    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self["rootView"])
    -- cp.getManager("ViewManager").popUpView(self.Panel_root)

    log(string.format("VIPMainUI:initView 11 totaltime = %.6f",socket.gettime() - self.beginTime))
end

function VIPMainUI:adapterReslution()
    self.rootView:setContentSize(display.size)
    self.Panel_root:setContentSize(display.size)
    self.Panel_root:setPositionY(display.height/2)

    self.Image_bg:setContentSize(732,display.height-160)
    self.Image_bg_1:setContentSize(733,display.height-160- 143)
    self.ListView_1:setContentSize(680,display.height-160 - 143 - 80)
    
    
end

function VIPMainUI:onEnterScene()
    self.beginTime = socket.gettime()

    self:setItemView()

    log(string.format("VIPMainUI:onEnterScene 11 totaltime = %.6f",socket.gettime() - self.beginTime))
    self.beginTime = socket.gettime()
    local vip = cp.getUserData("UserVip"):getValue("level")
    self.currentIndex = math.max(math.min(vip,15),1)
    self:changeToPage( self.currentIndex )

    log(string.format("VIPMainUI:onEnterScene 22 totaltime = %.6f",socket.gettime() - self.beginTime))
    self.beginTime = socket.gettime()
end

function VIPMainUI:onExitScene()
    
end

function VIPMainUI:setItemView()
	local sz = self["Panel_list"]:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width, sz.height))
	self.cellView:setCellSize(sz.width, sz.height)
    -- self.cellView:setColumnCount(15)
    self.cellView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	self.cellView:setCountFunction(function()
		return 15
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()       --刷新數據
	self.cellView:setAnchorPoint(cc.p(0, 0.5))
    self.cellView:setPosition(cc.p(5, 10))
    self.cellView:setTouchEnabled(false)
    self["Panel_list"]:addChild(self.cellView,1)
    
    -- self.cellView:setScrollFunction(function ( ... )
    --     local offset = self.cellView:getContentOffset()
    -- end)
end

function VIPMainUI:cellFactory(cellview, idx)
    local item = nil
    local cell = cellview:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local sz = self["Panel_list"]:getContentSize()
        local info = {width = sz.width,height = sz.height}
		item = require("cp.view.scene.world.vip.VipCellItem"):create(info)
		item:setAnchorPoint(cc.p(0, 0))
		item:setPosition(cc.p(0, 0))
		item:setName("VipCellItem")
		cell:addChild(item)
    else
		item = cell:getChildByName("VipCellItem")
    end

	item:resetInfo(idx)	

    return cell
end


function VIPMainUI:changeToPage( idx )
    self.beginTime = socket.gettime()
    log(string.format("VIPMainUI:changeToPage 11 totaltime  = %.6f",socket.gettime() - self.beginTime))
    
    idx = math.max(idx,1)
    idx = math.min(idx,15)

    self.Text_title_tequan:setString("VIP" .. tostring(idx) .. "專屬特權")
    self.Text_title_1:setString("VIP" .. tostring(idx) .. "專屬禮包")
    self.Text_title_2:setString("VIP" .. tostring(idx) .. "每日禮包")
    self.Text_title_3:setString("VIP" .. tostring(idx) .. "每日好康")

    self:initLiBao(idx)

    self.Button_prev:setVisible(idx > 1)
    self.Button_next:setVisible(idx < 15)
   

    log(string.format("VIPMainUI:changeToPage idx=" .. idx .. " totaltime = %.6f",socket.gettime() - self.beginTime))
    self.beginTime = socket.gettime()
    log("changeToPage idx= " .. tostring(idx))
    local offsetX = (idx-1) * 500 * (-1) 
    
    self.cellView:setContentOffsetInDuration(cc.p(offsetX,0), 0.15)
end


function VIPMainUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if "Button_prev" == buttonName then
        self.currentIndex = self.currentIndex - 1
        if self.currentIndex >= 1 then
            self:changeToPage( self.currentIndex )
        else
            self.currentIndex = 1
        end
    elseif "Button_next" == buttonName then
        self.currentIndex = self.currentIndex + 1
        if self.currentIndex <= 15 then
            local vip = cp.getUserData("UserVip"):getValue("level")
            -- if self.currentIndex > vip + 1 then
            --     cp.getManager("ViewManager").gameTip("尚未達到VIP" .. tostring(vip + 1) .. "級")
            -- else
                
                self:changeToPage( self.currentIndex )
            -- end
        else
            self.currentIndex = 15
        end
    elseif "Button_buy_1" == buttonName then
        local price = self.giftInfoList[1].price
        
        local function comfirmFunc()
            --檢測是否元寶足夠
            if cp.getManager("ViewManager").checkGoldEnough(price) then
                -- cp.getUserData("UserVip"):setValue("current_buy_type",1)
                local req = {}
                req.giftType = 1  -- // 1 專屬禮包， 2 特權禮包， 3 日常禮包
                req.vipLevel = self.currentIndex
                self:doSendSocket(cp.getConst("ProtoConst").GetVipGiftReq, req)
            end
        end
        local contentTable = {
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="購買該禮包？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        }
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    elseif "Button_buy_2" == buttonName then
        local price = self.giftInfoList[2].price
        
        local function comfirmFunc()
            --檢測是否元寶足夠
            if cp.getManager("ViewManager").checkGoldEnough(price) then
                -- cp.getUserData("UserVip"):setValue("current_buy_type",2)
                local req = {}
                req.giftType = 2  -- // 1 專屬禮包， 2 特權禮包， 3 日常禮包
                req.vipLevel = self.currentIndex
                self:doSendSocket(cp.getConst("ProtoConst").GetVipGiftReq, req)
            end
        end
        local contentTable = {
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="購買該禮包？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        }
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    elseif "Button_free_get" == buttonName then
        local vip = cp.getUserData("UserVip"):getValue("level")
        local daily = cp.getUserData("UserVip"):getValue("daily")
        local needGet = true
        if vip > 0 then
            local state = bit.band(bit.lshift(1, vip), daily)
            needGet = (state == 0)
        end
        if needGet then
            -- cp.getUserData("UserVip"):setValue("current_buy_type",3)
            local req = {}
            req.giftType = 3  -- // 1 專屬禮包， 2 特權禮包， 3 日常禮包
            req.vipLevel = self.currentIndex
            self:doSendSocket(cp.getConst("ProtoConst").GetVipGiftReq, req)
        else
            cp.getManager("ViewManager").gameTip("禮包今日已領取過")
        end
    end
end

function VIPMainUI:initLiBao(idx)

    local config = cp.getManager("ConfigManager").getItemByKey("Vip", idx)
    local ExclusiveGift = config:getValue("ExclusiveGift")
    local ExclusiveGold = config:getValue("ExclusiveGold")
    local PrivilegeGift = config:getValue("PrivilegeGift")
    local PrivilegeGold = config:getValue("PrivilegeGold")
    local DailyGift = config:getValue("DailyGift")
    local PriceOff = config:getValue("PriceOff")  --專屬禮包折扣

    local arr1 = {}
    string.loopSplit(ExclusiveGift,"|-",arr1)
    local arr2 = {}
    string.loopSplit(PrivilegeGift,"|-",arr2)
    local arr3 = {}
    string.loopSplit(DailyGift,"|-",arr3)

    self.giftInfoList = {
        [1] = {gift = arr1, price=ExclusiveGold, off = PriceOff},
        [2] = {gift = arr2, price=PrivilegeGold},
        [3] = {gift = arr3},
    }

    self.Text_price_old_2:setString(config:getValue("PrivilegeGoldOriginal"))

    self:initOneLiBao( 1)  --專屬禮包
    self:initOneLiBao( 2)  --特權禮包
    self:initOneLiBao( 3)  --每日禮包

    self:setLiBaoButtonState()
end

function VIPMainUI:initOneLiBao( idx)
    local parent = self["Panel_libao_" .. tostring(idx)]
    local Node_1 = parent:getChildByName("Node_1")
    local Node_2 = parent:getChildByName("Node_2")
    local Node_3 = parent:getChildByName("Node_3")
    Node_1:removeAllChildren()
    Node_2:removeAllChildren()
    Node_3:removeAllChildren()
    local nodeList = {Node_1,Node_2,Node_3}

    local state = cp.getUserData("UserVip"):getLibaoState(idx,self.currentIndex)

    local giftInfo = self.giftInfoList[idx].gift
    local arrNum = table.nums(giftInfo)
    for i=1,arrNum do
        local id,num = tonumber(giftInfo[i][1]), tonumber(giftInfo[i][2])
        if id ==nil then
            log("cfgItem is nil id = " .. tostring(id))
        end
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
        
        local itemInfo = {id = id, num = num, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")}
		local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
		item:setScale(0.9)
        nodeList[i]:addChild(item)
        
        -- self:addSoldOutMark(state, nodeList[i])
    end
    if arrNum == 1 then
        nodeList[1]:setPositionX(235)
    elseif arrNum == 2 then
        nodeList[1]:setPositionX(175)
        nodeList[2]:setPositionX(305)
    elseif arrNum == 3 then
        nodeList[1]:setPositionX(120)
        nodeList[2]:setPositionX(250)
        nodeList[3]:setPositionX(390)
    end

    if idx == 1 then
        self.Text_price_1:setString( tostring(self.giftInfoList[idx].price) )
        self.Image_discount:setVisible(self.giftInfoList[idx].off<100)
        self.Text_discount:setString( tostring(self.giftInfoList[idx].off/10) .. " 折")
    elseif idx == 2 then
        self.Text_price_2:setString( tostring(self.giftInfoList[idx].price) )
    end

end

function VIPMainUI:setLiBaoButtonState()
    local vip = cp.getUserData("UserVip"):getValue("level")

    local state = {true,true,true}  -- true 表示已購買過或已領取過
    state[1] = cp.getUserData("UserVip"):getLibaoState(1,self.currentIndex)
    if self.currentIndex >= vip then
        state[2] = cp.getUserData("UserVip"):getLibaoState(2,self.currentIndex)
    end
    if self.currentIndex >= vip then
        state[3] = cp.getUserData("UserVip"):getLibaoState(3,self.currentIndex)
    end

    self.Button_buy_1:setTouchEnabled(not state[1] and self.currentIndex <= vip)
    self.Button_buy_1:getChildByName("Text_1"):setString(state[1] and "已購買" or "購  買")
    local aa = (state[1] or self.currentIndex > vip) and cp.getConst("ShaderConst").GrayShader or nil
    cp.getManager("ViewManager").setShader(self.Button_buy_1, aa)

    
    self.Button_buy_2:setTouchEnabled(not state[2] and self.currentIndex == vip)
    self.Button_buy_2:getChildByName("Text_1"):setString(state[2] and "已購買" or "購  買")
    local bb = (state[2] or self.currentIndex > vip) and cp.getConst("ShaderConst").GrayShader or nil
    cp.getManager("ViewManager").setShader(self.Button_buy_2, bb)

    self.Button_free_get:setTouchEnabled(not state[3] and self.currentIndex == vip)
    self.Button_free_get:getChildByName("Text_1"):setString(state[3] and "已領取" or "領  取")
    local cc = (state[3] or self.currentIndex > vip) and cp.getConst("ShaderConst").GrayShader or nil
    cp.getManager("ViewManager").setShader(self.Button_free_get, cc)
 
    self:updateRedDot(self.currentIndex)
end

function VIPMainUI:updateRedDot(idx)
    local canGet = false
    local vip = cp.getUserData("UserVip"):getValue("level")
    if idx == vip and vip > 0 then
        canGet = cp.getUserData("UserVip"):getLibaoState(3,idx) == false
    end

    if canGet then
        cp.getManager("ViewManager").addRedDot(self.Button_free_get, cc.p(140,60))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_free_get)
    end
end

function VIPMainUI:addSoldOutMark(isSoldOut,parent)
    local Image_soldout = parent:getChildByName("Image_soldout")
    if Image_soldout == nil then
        Image_soldout = ccui.ImageView:create()
        Image_soldout:loadTexture("ui_common_module19_menpai_shouqing.png", ccui.TextureResType.plistType)
        Image_soldout:setPosition(cc.p(0, 0))
        parent:addChild(Image_soldout,2)
    end
    Image_soldout:setVisible(isSoldOut)
end

return VIPMainUI
