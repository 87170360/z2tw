
local BLayer = require "cp.view.ui.base.BLayer"
local FirstRechargeGift = class("FirstRechargeGift",BLayer)

function FirstRechargeGift:create(openInfo)
	local layer = FirstRechargeGift.new(openInfo)
	return layer
end

function FirstRechargeGift:initListEvent()
	self.listListeners = {
		
		[cp.getConst("EventConst").GetFirstRechargeRsp] = function(data)	
			
			if data.element and next(data.element) then
				local itemList = {}
				for i=1,table.nums(data.element) do
					table.insert(itemList, {id = data.element[i].id, num=data.element[i].num, hideName = false})
				end
				if next(itemList) then
					cp.getManager("ViewManager").showGetRewardUI(itemList, "恭喜獲得", true, function() 
						-- 刪除首儲活動頁面
						self:dispatchViewEvent(cp.getConst("EventConst").ChangeFirstRechargeState,nil)
					end)
				end
			end
		end,

		[cp.getConst("EventConst").OtherRsp] = function(data)
			if self:isVisible() == false then
				return
			end
			if data.firstRecharge == 1 then
				self.Text_get:setString("領  取")
			end
		end,

		[cp.getConst("EventConst").FirstRechargeConfRsp] = function(data)
			if self:isVisible() == false then
				return
			end
			self:onEnterScene()
		end,
	}
end

function FirstRechargeGift:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_first_recharge.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
		["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},

        ["Panel_root.Panel_1.Panel_2.Panel_3"] = {name = "Panel_3"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Image_bg"] = {name = "Panel3_bg"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Image_around_bar"] = {name = "Panel3_bar"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content"] = {name = "Panel_content"},
		["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item"] = {name = "Panel_item"},
		["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Button_get"] = {name = "Button_get" ,click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Button_get.Text_1"] = {name = "Text_get"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Node_item_1"] = {name = "Node_item_1"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Node_item_2"] = {name = "Node_item_2"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Node_item_3"] = {name = "Node_item_3"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content.Panel_item.Node_item_4"] = {name = "Node_item_4"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    --cp.getManager("ViewManager").popUpView(self.Panel_root)
    self:setPosition(display.cx,display.cy)
	self.Panel_root:setContentSize(display.size)

	--動態調整panel3的節點width height
	local panel1Size = self.Panel_1:getContentSize()
	local panel2Size = self.Panel_2:getContentSize()
	local panel3Size = self.Panel_3:getContentSize()
	local changeHeight = display.size.height - panel1Size.height - panel2Size.height 
	self.Panel_3:setContentSize(cc.size(panel3Size.width, changeHeight))
	self.Panel3_bg:setContentSize(cc.size(panel3Size.width, changeHeight + 20))
	self.Panel3_bar:setContentSize(cc.size(panel3Size.width + 15, changeHeight + 20))
	self.Panel_content:setContentSize(cc.size(panel3Size.width, changeHeight-160))
	self.Panel_content:setPositionY(self.Panel_3:getContentSize().height-30)

    ccui.Helper:doLayout(self["rootView"])
end

function FirstRechargeGift:onEnterScene()
	
	--設置首衝獎勵物品 (百寶書匣紫 177 x1， 橙色1階武器 ， 銀兩 2 x20萬，時裝券 1467 x100)

	local first_recharge_config = cp.getUserData("UserActivity"):getValue("first_recharge_config")
	
	for i=1,4 do
		if first_recharge_config[i] and first_recharge_config[i].id > 0 and first_recharge_config[i].num > 0 then
			self:addIcon(self["Node_item_" .. tostring(i)], first_recharge_config[i].id ,first_recharge_config[i].num )
		end
	end
	
	local firstRecharge = cp.getUserData("UserActivity"):getValue("firstRecharge")
	if firstRecharge == 1 then
		self.Text_get:setString("領  取")
	elseif firstRecharge == 0 then
		self.Text_get:setString("去儲值")
	end
end


function FirstRechargeGift:addIcon(node, id, num)
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

function FirstRechargeGift:onExitScene()
    
end

function FirstRechargeGift:onUIButtonClick(sender)
	local firstRecharge = cp.getUserData("UserActivity"):getValue("firstRecharge")
	if firstRecharge == 0 then
		cp.getManager("ViewManager").showRechargeUI()
	elseif firstRecharge == 1 then
		--領取首儲獎勵
		local req = {}
		self:doSendSocket(cp.getConst("ProtoConst").GetFirstRechargeReq, req)
	end
end

return FirstRechargeGift
