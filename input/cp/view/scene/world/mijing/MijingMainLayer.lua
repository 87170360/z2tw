
local BLayer = require "cp.view.ui.base.BLayer"
local MijingMainLayer = class("MijingMainLayer",BLayer)

function MijingMainLayer:create(openInfo)
	local layer = MijingMainLayer.new(openInfo)
	return layer
end

function MijingMainLayer:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
        [cp.getConst("EventConst").GetMijingRsp] = function(data)
			self:refreshUI()
		end,
        
        [cp.getConst("EventConst").BuyMijingRsp] = function(data)
			self:refreshUI()
		end,
        
	}
end

function MijingMainLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_mijing/uicsb_mijing_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        
        ["Panel_root.Image_bg.Image_selected"] = {name = "Image_selected"},
        ["Panel_root.Image_bg.Image_1"] = {name = "Image_1",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Image_2"] = {name = "Image_2",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Image_3"] = {name = "Image_3",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Image_4"] = {name = "Image_4",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Image_5"] = {name = "Image_5",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Image_6"] = {name = "Image_6",click = "onUIButtonClick"},

        ["Panel_root.Image_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    

    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    
    self.rootView:setContentSize(display.size)
    if display.height < 1080 then
        self.Panel_root:setPositionY(display.height/2 + 30)
    else
        self.Panel_root:setPositionY(display.height/2 + 110/2)
    end
    ccui.Helper:doLayout(self.rootView)
    
end

function MijingMainLayer:onEnterScene()
    
    local req = {}
	self:doSendSocket(cp.getConst("ProtoConst").GetMijingReq, req)
    
    cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_fuben_1,true)

    self.Image_selected:setVisible(false)

	for i=1,6 do
        local ID = tostring(i) .. "_1"
        local isInActive = cp.getManager("GDataManager"):isMijingInActivityTime(ID)
        local Image_huodong = self["Image_" .. tostring(i)]:getChildByName("Image_huodong")
        Image_huodong:setVisible(isInActive)
    end

    local result,step = cp.getManager("GDataManager"):checkNeedGuide("mijing")
    if result then
        cp.getManager("ViewManager").openNewPlayerGuide("mijing",step)
    end
end

function MijingMainLayer:refreshUI()

    --local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
    -- for i=1,6 do
    --     self.items[i]:refreshUI(mijingInfoList[i])
    -- end
end

function MijingMainLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack ~= nil then
            self.closeCallBack(0)
        else
            self:removeFromParent()
        end
    else
        local idx = string.sub(buttonName,string.len("Image_")+1)
        if tonumber(idx) ~= nil then
            local posX,posY = sender:getPosition()
            self.Image_selected:setPosition(cc.p(posX,posY+20))
            self.Image_selected:setVisible(true)
            if self.closeCallBack ~= nil then
                self.closeCallBack(tonumber(idx))  --打開npc界面
            end
        end
    end
end

function MijingMainLayer:addMijingItems()

	-- local function itemClicked(info,btnName)
    --     dump(info)
    --     log(btnName)
    --     if "Button_view_drop" == btnName then
    --         if info.items ~= nil then
    --             if #info.items > 0 then
    --                 local itemList = {}
    --                 for i=1,#info.items do
    --                     table.insert(itemList, {id = info.items[i], num=1,hideName = false})
    --                 end
    --                 cp.getManager("ViewManager").showGameRewardPreView(itemList,info.name,false)
    --             end
    --         end
            
    --     elseif "Panel_item" == btnName then
    --         local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    --         local hierarchy = major_roleAtt.hierarchy
    --         if self.closeCallBack ~= nil then
    --             self.closeCallBack()
    --         end
    --     end
	-- end
    
    self.items = {}
    local itemSize = cc.size(524,128)
    local totalHeight = itemSize.height*6
    local sz = self.ScrollView_1:getContentSize()
    self.ScrollView_1:setInnerContainerSize(cc.size(sz.width,totalHeight))
	for i=1,6 do
		local openInfo = {id = i}
		local item  = require("cp.view.scene.world.mijing.MijingMainItem"):create(openInfo)
        item:setItemClickCallBack(
            function(itemInfo,buttonName)
                if "Button_add" == buttonName then
                    --購買祕境的挑戰次數
                    self:onBuyFightNums(i)
                elseif "Panel_item" == buttonName then
                    if self.closeCallBack ~= nil then
                        self.closeCallBack(i)  --打開npc界面
                    end
                end
            end
        )
		self.ScrollView_1:addChild(item)
        local pos = cc.p(0, totalHeight-(i-1)*itemSize.height)
        dump(pos)
        item:setPosition(pos)
        self.items[i] = item
	end
end



function MijingMainLayer:onBuyFightNums(i)
    local mijing_id = tostring(i) .. "_1"
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
    if cfg ~= nil then

        local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
        local mijingInfo = mijingInfoList[i]
        if mijingInfo.numLeft > 0  then
            cp.getManager("ViewManager").gameTip("尚剩餘挑戰次數，勿需重置挑戰次數!")
            return
        end


        local PriceList = cfg:getValue("Price")
        local priceTable = string.split(PriceList,"|")
        local index = mijingInfo.numBuy + 1
        index = math.min(index, table.nums(priceTable)) 
        local price = tonumber(priceTable[index])
        
        local function comfirmFunc()
            --檢測是否元寶足夠
            if cp.getManager("ViewManager").checkGoldEnough(price) then
				local req = {}
                req.id = mijing_id
                self:doSendSocket(cp.getConst("ProtoConst").BuyMijingReq, req)
			end
        end

        local contentTable = {
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="提升VIP等級可獲得額外挑戰次數，是否消耗", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(priceTable[index]), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，來重置挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        }
        if price == 0 then
            contentTable = {
                {type="ttf", fontSize=24, text="是否重置挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
                {type="blank", blankSize=1},
                {type="ttf", fontSize=24, text="(本次免費)", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            }
        end
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    end
end

function MijingMainLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

return MijingMainLayer
