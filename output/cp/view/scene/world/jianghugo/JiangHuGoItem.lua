local BNode = require "cp.view.ui.base.BNode"
local JiangHuGoItem = class("JiangHuGoItem",BNode)

function JiangHuGoItem:create()
	local node = JiangHuGoItem.new()
	return node
end

function JiangHuGoItem:initListEvent()
	self.listListeners = {

	}
end

function JiangHuGoItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_jianghu_go_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        
        ["Panel_item.Node_item_1"] = {name = "Node_item_1"},
        ["Panel_item.Node_item_2"] = {name = "Node_item_2"},
        ["Panel_item.Node_item_3"] = {name = "Node_item_3"},
        ["Panel_item.Node_item_4"] = {name = "Node_item_4"},
        ["Panel_item.AtlasLabel_value"] = {name = "AtlasLabel_value"},
        ["Panel_item.Text_title"] = {name = "Text_title"},
        ["Panel_item.Text_num"] = {name = "Text_num"},
		["Panel_item.Text_max"] = {name = "Text_max"},
		["Panel_item.Text_can"] = {name = "Text_can"},
        ["Panel_item.Button_get"] = {name = "Button_get", click = "onUIButtonClick"},
        ["Panel_item.Button_get.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
    ccui.Helper:doLayout(self["rootView"])
end

function JiangHuGoItem:onEnterScene()
end

function JiangHuGoItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	if self.info.state == 1 then
		local req = {id=self.info.id}
		self:doSendSocket(cp.getConst("ProtoConst").InviteGiftReq, req)
		sender:setTouchEnabled(false)
		
	end
end

function JiangHuGoItem:resetInfo(info)
	self.info = info

	--[[
message InviteGiftState {
    required int32 id                         = 1;                  //配置id
    required int32 getCount                   = 2;                  //已經領取次數
    required int32 openCount                  = 3;                  //已經開啟次數
}
	]]

	local curGiftState = cp.getManager("GDataManager"):getInviteGiftState(tonumber(info.id))
	for i=1,4 do
		self["Node_item_" .. tostring(i)]:removeAllChildren()
	end
	if info.open_type == "online_time" then
		self.Text_title:setString(info.Type == 1 and "好友累計登錄天數達到       天" or "好友累計儲值金額達到")
		self.AtlasLabel_value:setString(tostring(info.Value))
		self.AtlasLabel_value:setAnchorPoint(cc.p(info.Type == 1 and 0.5 or 0,0.5))
		self.AtlasLabel_value:setPositionX(info.Type == 1 and 330 or 305)
		
	elseif info.open_type == "fights" then
		self.Text_title:setString("好友戰力達到")
		self.AtlasLabel_value:setString(tostring(info.Value))
		self.AtlasLabel_value:setAnchorPoint(cc.p(0,0.5))
		self.AtlasLabel_value:setPositionX(220)
	end
	self.Text_max:setString("/" .. tostring(info.max))
	self.Text_num:setString(tostring(curGiftState and curGiftState.getCount or 0))
	self.Text_can:setString(tostring(curGiftState and (curGiftState.openCount-curGiftState.getCount) or 0))

	if info.item_list and next(info.item_list) then
		for i=1,table.nums(info.item_list) do
			self:addIcon(self["Node_item_" .. tostring(i)], info.item_list[i].id, info.item_list[i].num)
		end
	end
	
	self:setButtonState(info.state)
end

function JiangHuGoItem:addIcon(node, id, num)
	if node == nil then
		return
	end
	local itemInfo = {id = id}
	local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
	if not conf then
		log("item not exist in [GameItem], id =" .. tostring(id))
		return
	end

	node:removeAllChildren()
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

function JiangHuGoItem:setButtonState(state)
	
	if state == 1 then --還有可以領取的次數
		self.Button_get:setTouchEnabled(true)
		cp.getManager("ViewManager").setShader(self.Button_get, nil)
	else
		cp.getManager("ViewManager").setShader(self.Button_get, "GrayShader")
		self.Button_get:setTouchEnabled(false)
	end
	
end

return JiangHuGoItem
