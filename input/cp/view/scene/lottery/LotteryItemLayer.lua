local BLayer = require "cp.view.ui.base.BLayer"
local LotteryItemLayer = class("LotteryItemLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function LotteryItemLayer:create(mode, itemList)
    local scene = LotteryItemLayer.new(itemList)
    scene.itemList = itemList
    scene.mode = mode
	scene:updateLotteryItemView()
    return scene
end

function LotteryItemLayer:initListEvent()
    self.listListeners = {
         --新手指引獲取目標點位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "LotteryItemLayer" then
                if evt.guide_name == "lottery" then
                    local pos = nil
                    if evt.target_name == "close_result" then
                        local boundbingBox = self["Image_1"]:getBoundingBox()
                        pos = self["Image_1"]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                        pos.y = pos.y - 300 
                    else
					    local boundbingBox = self[evt.target_name]:getBoundingBox()
					    pos =   self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					end
					--此步指引為向右的手指
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "LotteryItemLayer" then
                if evt.guide_name == "lottery" then
                    if evt.target_name == "close_result" then
                        
                    end
				end
			end
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function LotteryItemLayer:onInitView(itemList)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_lottery_item.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    self.deltaY = 30
    self.deltaX = 10
    self.boxSize = 100
    self.beginX = self.boxSize/2
    self.beginY = 0
    self.maxCol = 5

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_BuyOnce"] = {name = "Button_BuyOnce", click="onBtnClick"},
		["Panel_root.Image_1.Button_BuyTenth"] = {name = "Button_BuyTenth", click="onBtnClick"},
		["Panel_root.Image_1.Text_OnceCost"] = {name = "Text_OnceCost"},
		["Panel_root.Image_1.Text_TenthCost"] = {name = "Text_TenthCost"},
		["Panel_root.Image_1.Image_MoneyType1"] = {name = "Image_MoneyType1"},
		["Panel_root.Image_1.Image_MoneyType2"] = {name = "Image_MoneyType2"},
		["Panel_root.Image_1.ScrollView_ItemList"] = {name = "ScrollView_ItemList"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    self.ScrollView_ItemList:setScrollBarEnabled(false)
    self.Image_1:setVisible(false)

    local rowNum = math.floor((#itemList-1)/self.maxCol)+1
    local height = self.boxSize + self.deltaY
    if rowNum <= 2 then
        height = height * rowNum
        self.ScrollView_ItemList:setTouchEnabled(false)
    else
        height = height * 2
    end

    local size = self.ScrollView_ItemList:getSize()
    size.height = height
    self.ScrollView_ItemList:setSize(size)
    self.ScrollView_ItemList:setInnerContainerSize(cc.size(size.width, rowNum*(self.boxSize+self.deltaY)))

    size = self.Image_1:getSize()
    size.height = size.height + (rowNum - 1)*(self.boxSize+self.deltaY)
    self.Image_1:setSize(size)
    self.beginY = rowNum*(self.boxSize+self.deltaY) - self.boxSize/2
    ccui.Helper:doLayout(self.rootView)
    
    self.model = cp.getManager("ViewManager").createSpineAnimation("res/spine/lottery/choujiang")
    self.rootView:addChild(self.model)
    self.model:setPosition(cc.p(display.width/2, display.height/2))
    self.model:setVisible(false)
    self.model:setScale(1.5)

    cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_get_reward)
    self.model:setVisible(true)
    self.model:setAnimation(0, "Start", false)
    self.model:addAnimation(0, "Choose", false)
    self.model:addAnimation(0, "Loop", true)

    self.model:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
        self.Image_1:setPosition(display.width/2, display.height/2)
        cp.getManager("ViewManager").popUpViewEx(self.Image_1)
        self.Image_1:setVisible(true)
        self.model:setVisible(false)
        self.Panel_root:onTouch(function(event)
            if event.name == "ended" then
                self:delayNewGuide(0)
                self:removeFromParent()
            end
        end)
    end)))
end

function LotteryItemLayer:updateLotteryItemView()
    local beginX, beginY = self.beginX, self.beginY
    if #self.itemList == 1 then
        beginX = beginX + 2*(self.boxSize+self.deltaX)
    end
    for i=1, #self.itemList do
        local row = math.floor((i - 1) / self.maxCol) + 1
        local col = math.floor((i - 1) % self.maxCol) + 1

        local itemInfo = {id = self.itemList[i].item_id, num=self.itemList[i].item_num}
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
        if cfgItem == nil then
            log("cfgItem is nil id = " .. tostring(itemInfo.id))
        end
        itemInfo.Colour = cfgItem:getValue("Hierarchy")
        itemInfo.Name = cfgItem:getValue("Name") 
        itemInfo.Icon = cfgItem:getValue("Icon")
        itemInfo.Type = cfgItem:getValue("Type")
        itemInfo.shopModel = true  --控制物品icon數量的顯示規則
        local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
        item:setItemClickCallBack(function()
            local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
            self:addChild(layer, 100)
        end)
        item:setPosition(cc.p(beginX +(col - 1) * (self.boxSize+self.deltaX), beginY - (row - 1) * (self.boxSize+self.deltaY))) 
        self.ScrollView_ItemList:addChild(item)
        
    end

    if self.mode == 1 then
        local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("SkillLottery"), ":")
        self.Text_OnceCost:setString(info[1])
        self.Text_TenthCost:setString(info[2])
        local itemNum = cp.getUserData("UserItem"):getItemNum(614)
        if itemNum > 0 then
            self.Text_OnceCost:setString("1  ")
            self.Image_MoneyType1:loadTexture("ui_common_01_chouijangquan.png", ccui.TextureResType.plistType)
        else
            self.Image_MoneyType1:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        end

        if itemNum >= 10 then
            self.Text_TenthCost:setString("10")
            self.Image_MoneyType2:loadTexture("ui_common_01_chouijangquan.png", ccui.TextureResType.plistType)
        else
            self.Image_MoneyType2:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        end
    else
        local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("TreasureLottery"), ":")
        self.Text_OnceCost:setString(info[1])
        self.Text_TenthCost:setString(info[2])
        self.Image_MoneyType1:loadTexture("ui_common_yinliang.png", ccui.TextureResType.plistType)
        self.Image_MoneyType2:loadTexture("ui_common_yinliang.png", ccui.TextureResType.plistType)
    end
end

function LotteryItemLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function LotteryItemLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_BuyTenth" then
        local req = {}
        req.buy_count = 10
        req.buy_type = 2
        if self.mode == 1 then
            local itemNum = cp.getUserData("UserItem"):getItemNum(614)
            if itemNum >= 10 then
                req.buy_type = 3
            else
                req.buy_type = 2
            end
            self:doSendSocket(cp.getConst("ProtoConst").BuySkillLotteryReq, req)
        else
            self:doSendSocket(cp.getConst("ProtoConst").BuyTreasureLotteryReq, req)
        end
		self:removeFromParent()
    elseif nodeName == "Button_BuyOnce" then
        local req = {}
        req.buy_count = 1
        req.buy_type = 2
        if self.mode == 1 then
            local itemNum = cp.getUserData("UserItem"):getItemNum(614)
            if itemNum > 1 then
                req.buy_type = 3
            else
                req.buy_type = 2
            end
            self:doSendSocket(cp.getConst("ProtoConst").BuySkillLotteryReq, req)
        else
            self:doSendSocket(cp.getConst("ProtoConst").BuyTreasureLotteryReq, req)
        end
        self:removeFromParent()
    -- elseif nodeName == "Panel_root" then

    --     self:delayNewGuide(0)
    --     self:removeFromParent()
	end
end

function LotteryItemLayer:onEnterScene()
    self:delayNewGuide(3)
end

function LotteryItemLayer:onExitScene()
    self:unscheduleUpdate()
end

function LotteryItemLayer:delayNewGuide(delayTime)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lottery" then
        if delayTime > 0 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(delayTime))
            table.insert(sequence,cc.CallFunc:create(function()
                -- local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
                local info = 
                {
                    classname = "LotteryItemLayer",
                }
                self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
            end))
            self:runAction(cc.Sequence:create(sequence))
        else
            local info = 
            {
                classname = "LotteryItemLayer",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end
    end
end



return LotteryItemLayer