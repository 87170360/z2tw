local BNode = require "cp.view.ui.base.BNode"
local FundsGiftItem = class("FundsGiftItem",BNode)

function FundsGiftItem:create()
	local node = FundsGiftItem.new()
	return node
end

function FundsGiftItem:initListEvent()
	self.listListeners = {
	}
end

function FundsGiftItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_funds_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
		["Panel_item.Image_1"] = {name = "Image_1"},
		["Panel_item.AtlasLabel_level"] = {name = "AtlasLabel_level"},
		["Panel_item.AtlasLabel_gold"] = {name = "AtlasLabel_gold"},
		["Panel_item.Image_finished"] = {name = "Image_finished"},
		["Panel_item.Text_title"] = {name = "Text_title"},
        ["Panel_item.Button_get"] = {name = "Button_get", click = "onUIButtonClick"},
        ["Panel_item.Button_get.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
end

function FundsGiftItem:onEnterScene()
end

function FundsGiftItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	dump(self.info)
	
	--表現狀態 1 可領取，2 未開啟，3 已領取
	if self.info.state ==  1 then
		local req = {id = self.info.id}
		self:doSendSocket(cp.getConst("ProtoConst").GetFundReq, req)
	end
end

function FundsGiftItem:resetInfo(info)
	self.info = info

	self.AtlasLabel_level:setString(info.level)
	local gold = 0
	for i=1,table.nums(info.values) do
		if info.values[i].id == cp.getConst("GameConst").Gold_ItemID then
			gold = info.values[i].num
		end
	end
	self.AtlasLabel_gold:setString(tostring(gold))
	self.Image_1:setPositionX(self.AtlasLabel_gold:getPositionX() + self.AtlasLabel_gold:getContentSize().width+3)
	self:setButton(info.state)
end

--表現狀態 1 可領取，2 未開啟，3 已領取
function FundsGiftItem:setButton(state)
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

return FundsGiftItem
