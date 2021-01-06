local BNode = require "cp.view.ui.base.BNode"
local UpgradeGiftItem = class("UpgradeGiftItem",BNode)

function UpgradeGiftItem:create()
	local node = UpgradeGiftItem.new()
	return node
end

function UpgradeGiftItem:initListEvent()
	self.listListeners = {
        --[cp.getConst("EventConst").GetUpgradeGiftRsp] = function(data)	
        --end,
	}
end

function UpgradeGiftItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_upgrade_gift/uicsb_upgrade_gift_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Text_des_level"] = {name = "Text_level"},
        ["Panel_item.Node_item_1"] = {name = "Node_item_1"},
        ["Panel_item.Node_item_2"] = {name = "Node_item_2"},
        ["Panel_item.Image_finished"] = {name = "Image_finished"},
        ["Panel_item.Button_get"] = {name = "Button_get", click = "onUIButtonClick"},
        ["Panel_item.Button_get.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
end

function UpgradeGiftItem:onEnterScene()
end

function UpgradeGiftItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	--log(buttonName)
	--表現狀態 1 可領取，2 未開啟，3 已領取
	if self.info.show ==  1 then
		local req = {ID = self.info.id, idx = self.idx}
		self:doSendSocket(cp.getConst("ProtoConst").GetUpgradeGiftReq, req)
	elseif self.info.show == 2 then
		cp.getManager("ViewManager").gameTip("您的等級不足，無法領取")
		--點擊後會自動取消置灰，重設
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
	end
end

--[[info
	{
     "level"  = 7
     "show"   = 1
     "values" = {
         1 = {
             "id"  = 1
             "num" = 17500
         }
         2 = {
             "id"  = 2
             "num" = 35000
         }
         3 = {
             "id"  = 3
             "num" = 5
         }
     }
 ]]
function UpgradeGiftItem:resetInfo(info, idx)
	self.info = info
	self.idx = idx

	self.Text_level:setString(info.level .. "級")
	self:addIcon(self.Node_item_1, info.values[1].id, info.values[1].num)
	self:addIcon(self.Node_item_2, info.values[2].id, info.values[2].num)
	self:setButton(info.show)
end

function UpgradeGiftItem:addIcon(node, id, num)
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

--表現狀態 1 可領取，2 未開啟，3 已領取
function UpgradeGiftItem:setButton(state)
	cp.getManager("ViewManager").setShader(self.Button_get, nil)
	self.Button_get:setVisible(false)
	self.Button_get:setTouchEnabled(true)
	self.Image_finished:setVisible(false)

	if state == 1 then
		self.Button_get:setVisible(true)
		self.Text_1:setString("領  取")
		self.Text_1:setTextColor(cc.c4b(122,22,22,255))
	elseif state == 2 then
		self.Button_get:setVisible(true)
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
		self.Button_get:setTouchEnabled(false)
		self.Text_1:setString("未達到")
		self.Text_1:setTextColor(cc.c4b(52,52,52,255))
	elseif state == 3 then
		self.Image_finished:setVisible(true)
		self.Button_get:setTouchEnabled(false)
	end
end

return UpgradeGiftItem
