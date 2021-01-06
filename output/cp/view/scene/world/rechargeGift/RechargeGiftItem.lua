local BNode = require "cp.view.ui.base.BNode"
local RechargeGiftItem = class("RechargeGiftItem",BNode)

function RechargeGiftItem:create()
	local node = RechargeGiftItem.new()
	return node
end

function RechargeGiftItem:initListEvent()
	self.listListeners = {
        --[cp.getConst("EventConst").GetUpgradeGiftRsp] = function(data)	
        --end,
	}
end

function RechargeGiftItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_recharge_award_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
		-- ["Panel_item.Image_1"] = {name = "Image_1"},
		["Panel_item.AtlasLabel_value"] = {name = "AtlasLabel_value"},
		["Panel_item.Text_max"] = {name = "Text_max"},
		["Panel_item.Text_num"] = {name = "Text_num"},

        ["Panel_item.Node_item_1"] = {name = "Node_item_1"},
		["Panel_item.Node_item_2"] = {name = "Node_item_2"},
		["Panel_item.Node_item_3"] = {name = "Node_item_3"},
		["Panel_item.Node_item_4"] = {name = "Node_item_4"},
        ["Panel_item.Image_finished"] = {name = "Image_finished"},
        ["Panel_item.Button_get"] = {name = "Button_get", click = "onUIButtonClick"},
        ["Panel_item.Button_get.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
end

function RechargeGiftItem:onEnterScene()
end

function RechargeGiftItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	--表現狀態 0 未達到 1 可領取 2 已領取
	if self.info.state ==  1 then
		local req = {ID = self.info.id}
		self:doSendSocket(cp.getConst("ProtoConst").GetRechargeGiftReq, req)
	elseif self.info.state == 0 then
		cp.getManager("ViewManager").gameTip("累計儲值金額未達到，無法領取。")
		
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
	end
end

function RechargeGiftItem:resetInfo(info)
	self.info = info

	self.AtlasLabel_value:setString(tostring(info.gold))
	if info.values and next(info.values) then
		for i=1,table.nums(info.values) do
			self:addIcon(self["Node_item_" .. tostring(i)], info.values[i].id, info.values[i].num)
		end
	end
	local rechargeGold = cp.getUserData("UserActivity"):getValue("rechargeGold")
	self.Text_num:setString(tostring(rechargeGold))
	self.Text_max:setString( "/" .. tostring(info.gold))
	self:setButton(info.state)
end

function RechargeGiftItem:addIcon(node, id, num)
	node:removeAllChildren()
	local itemInfo = {id = id}
	local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
	itemInfo.Name = conf:getValue("Name")
	itemInfo.Icon = conf:getValue("Icon")
	itemInfo.Type = conf:getValue("Type")
	itemInfo.SubType = conf:getValue("SubType")
	itemInfo.Package = conf:getValue("Package")
	itemInfo.Colour = conf:getValue("Hierarchy")
	itemInfo.num = num
	local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
	if itemIcon ~= nil then
		node:addChild(itemIcon)
	end
end

--表現狀態 0 未達到 1 可領取，2 已領取
function RechargeGiftItem:setButton(state)
	cp.getManager("ViewManager").setShader(self.Button_get, nil)
	self.Button_get:setVisible(false)
	self.Button_get:setTouchEnabled(true)
	self.Image_finished:setVisible(false)

	if state == 1 then
		self.Button_get:setVisible(true)
		self.Text_1:setString("領  取")
		self.Text_1:setTextColor(cc.c4b(122,22,22,255))
	elseif state == 0 then
		self.Button_get:setVisible(true)
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
		self.Button_get:setTouchEnabled(false)
		self.Text_1:setString("未達到")
		self.Text_1:setTextColor(cc.c4b(52,52,52,255))
	elseif state == 2 then
		self.Image_finished:setVisible(true)
		self.Button_get:setTouchEnabled(false)
	end
end

return RechargeGiftItem
