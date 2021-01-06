local BNode = require "cp.view.ui.base.BNode"
local FightGiftItem = class("FightGiftItem",BNode)

function FightGiftItem:create()
	local node = FightGiftItem.new()
	return node
end

function FightGiftItem:initListEvent()
	self.listListeners = {
        --[cp.getConst("EventConst").GetUpgradeGiftRsp] = function(data)	
        --end,
	}
end

function FightGiftItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_fight_gift/uicsb_fight_gift_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Node_item_1"] = {name = "Node_item_1"},
        ["Panel_item.Node_item_2"] = {name = "Node_item_2"},
        ["Panel_item.Node_item_3"] = {name = "Node_item_3"},
        ["Panel_item.Node_item_4"] = {name = "Node_item_4"},
        ["Panel_item.Image_finished"] = {name = "Image_finished"},
        ["Panel_item.Image_fight_bg.AtlasLabel_fight"] = {name = "AtlasLabel_fight"},
        ["Panel_item.Button_get"] = {name = "Button_get", click = "onUIButtonClick"},
        ["Panel_item.Button_get.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
end

function FightGiftItem:onEnterScene()
end

function FightGiftItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	--表現狀態 1 可領取，2 未開啟，3 已領取
	if self.info.show ==  1 then
		local req = {ID = self.info.id, idx = self.idx}
		self:doSendSocket(cp.getConst("ProtoConst").GetFightGiftReq, req)
	elseif self.info.show == 2 then
		cp.getManager("ViewManager").gameTip("您的戰力不足，無法領取")
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
function FightGiftItem:resetInfo(info, idx)
	self.info = info
	self.idx = idx

	self.AtlasLabel_fight:setString("" .. info.fight)
	self:addIcon(self.Node_item_1, info.values[1].id, info.values[1].num)
	self:addIcon(self.Node_item_2, info.values[2].id, info.values[2].num)
	self:addIcon(self.Node_item_3, info.values[3].id, info.values[3].num)
	self:addIcon(self.Node_item_4, info.values[4].id, info.values[4].num)
	self:setButton(info.show)
end

function FightGiftItem:addIcon(node, id, num)
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
function FightGiftItem:setButton(state)
	self.Image_finished:setVisible(false)
	self.Button_get:setVisible(false)
	self.Button_get:setTouchEnabled(true)
	cp.getManager("ViewManager").setShader(self.Button_get, nil)

	if state == 1 then
		self.Button_get:setVisible(true)
	elseif state == 2 then
		self.Button_get:setVisible(true)
		self.Button_get:setTouchEnabled(false)
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
	elseif state == 3 then
		self.Button_get:setTouchEnabled(false)
		self.Image_finished:setVisible(true)
	end
end

return FightGiftItem
