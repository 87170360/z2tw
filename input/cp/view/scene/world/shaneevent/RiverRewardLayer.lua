local BLayer = require "cp.view.ui.base.BLayer"

local RiverRewardLayer = class("RiverRewardLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverRewardLayer:create(proto)
	local layer = RiverRewardLayer.new()
	layer.combatList = proto.battleID
    layer.itemList = proto.items or {}

	if proto.bad ~= 0 then
		table.insert(layer.itemList, {itemid=1094, itemnum=proto.bad})
	end
	if proto.good ~= 0 then
		table.insert(layer.itemList, {itemid=1095, itemnum=proto.good})
	end
	if proto.silver ~= 0 then
		table.insert(layer.itemList, {itemid=2, itemnum=proto.silver})
	end

	if proto.eventInfoList[1] ~= nil and proto.eventInfoList[1].state ~= nil then
    	layer.isWin = proto.eventInfoList[1].state == 3
	end
    layer:updateRiverRewardView()
    
    return layer
end

function RiverRewardLayer:initListEvent()
    self.listListeners = {
    }
end

function RiverRewardLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Record" then
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local req = {}
		req.mode = "break"
		req.combat_list = self.combatList
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatListReq, req)
    elseif btnName == "Button_Close" then
        self:removeFromParent()
    end
end

--初始化界面，以及設定界面元素標籤
function RiverRewardLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_reward.csb")
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_1.Panel_Mask.Panel_Flash.Image_Flash"] = {name = "Image_Flash"},
        ["Panel_root.Image_1.Panel_Mask.Image_Result"] = {name = "Image_Result"},
        ["Panel_root.Image_1.Panel_Mask.Text_Words"] = {name = "Text_Words"},
        ["Panel_root.Image_1.Panel_Mask.ScrollView_ItemList"] = {name = "ScrollView_ItemList"},
        ["Panel_root.Image_1.Button_Record"] = {name = "Button_Record", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(0,0))
	
end

function RiverRewardLayer:updateRiverRewardView()
	-- self.Image_Flash:stopAllActions()
    if self.isWin then
        -- self.Image_Flash:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 60)))
        self.Image_Result:loadTexture("ui_mapbuild_module6_jianghushi_jiesuan_c.png", ccui.TextureResType.plistType)  --獎勵
        self.Text_Words:setString("大俠為民除害，真是大快人心，這是我們的小小心意，請笑納！")
    else
        self.Image_Result:loadTexture("ui_mapbuild_module6_jianghushi_jiesuan_b.png", ccui.TextureResType.plistType)  --失敗
        self.Text_Words:setString("少俠力有不逮，被打成重傷。這是我們的小小心意，聊以安慰！")
    end

	self:initItemList()
	
	ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpViewEx(self.Panel_root)
end


function RiverRewardLayer:createScrollItem(itemInfo,i,totalNum)
    itemInfo.id = itemInfo.itemid
    itemInfo.num = itemInfo.itemnum
	local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
	if cfgItem == nil then
        log("cfgItem is nil id = " .. tostring(itemInfo.id))
        return
	end
	itemInfo.Colour = cfgItem:getValue("Hierarchy")
	itemInfo.Name = cfgItem:getValue("Name") 
	itemInfo.Icon = cfgItem:getValue("Icon")
	itemInfo.Type = cfgItem:getValue("Type")
	itemInfo.shopModel = true  --控制物品icon數量的顯示規則
	local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
	item:setItemClickCallBack(nil)
	local sz = item:getContentSize()
	self.ScrollView_ItemList:addChild(item)
	
	local scrollViewSize = self.ScrollView_ItemList:getContentSize()
	
	local space = 0
	if totalNum <= 4 then --只有1行
		if totalNum == 1 then
			space = 0
		elseif totalNum == 2 then
			space = 90
		elseif totalNum == 3 then
			space = 60
		elseif totalNum == 4 then
			space = 35
		end
		local startX = scrollViewSize.width/2 - totalNum/2 * sz.width - (totalNum-1)*space/2
		startX = startX < 0 and 0 or startX
		local x = startX + (i-1)*sz.width + (i-1)*space
		item:setPosition(cc.p(x+sz.width/2,scrollViewSize.height - sz.height/2-10))

	else
		local scrollViewSize2 = self.ScrollView_ItemList:getInnerContainerSize()
		--每行4列
		local y = math.floor((i-1)/4)  -- 0開始
		local x = math.floor((i-1)%4)  -- 0,1,2,3
		item:setPosition(cc.p((sz.width+30)*x+sz.width,scrollViewSize2.height - y*(sz.height + 40 ) - sz.height/2))  -- - (sz.height/2+20)))
	end
	item:setVisible(true)
	
end

function RiverRewardLayer:initItemList()
	-- self.itemList = {{itemid=11,itemnum=1},{itemid=12,itemnum=2},{itemid=13,itemnum=1},{itemid=14,itemnum=1},{itemid=15,itemnum=2}}
	if self.itemList == nil or #self.itemList == 0 then
		return
	end
	local totalNum = #self.itemList
	
	local scrollViewSize = self.ScrollView_ItemList:getContentSize()
	local newHeight = 140
	local sz = cc.size(100,100) --一個物品框的大小
	if totalNum > 4 then
		local row = math.floor(totalNum / 4) + 1
		local newHeight = row * (sz.height+40)
		self.ScrollView_ItemList:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))
		self.ScrollView_ItemList:setContentSize(cc.size(scrollViewSize.width, 280))
		self.Panel_root:setContentSize(cc.size(display.width, 640))
	else
		self.ScrollView_ItemList:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))
		self.ScrollView_ItemList:setContentSize(cc.size(scrollViewSize.width, newHeight))
		self.Panel_root:setContentSize(cc.size(display.width, 510))
	end
	
	for i=1,totalNum do
		self:createScrollItem(self.itemList[i],i,totalNum)
	end
	if totalNum > 4 then
		self.ScrollView_ItemList:jumpToTop()
	end
end


function RiverRewardLayer:onEnterScene()
end

function RiverRewardLayer:onExitScene()
end

return RiverRewardLayer
