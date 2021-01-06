local BNode = require "cp.view.ui.base.BNode"
local GameRewardReceiveUI = class("GameRewardReceiveUI",BNode)
function GameRewardReceiveUI:create(openInfo) -- itemList,title,showGetButton,cb
	local ret = GameRewardReceiveUI.new(openInfo)
    return ret
end
function GameRewardReceiveUI:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)	
			if evt.classname == "GameRewardReceiveUI" then
				if evt.guide_name == "mail" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
				
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "GameRewardReceiveUI" then
				if evt.guide_name == "mail" then
					self:onGetRewardButtonClick(self[evt.target_name])
				end
			end
		end,
	}
end

function GameRewardReceiveUI:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_reward.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Panel_title.Image_1"] = {name = "Image_1"},
		["Panel_root.Panel_title.Image_4"] = {name = "Image_4"},
		["Panel_root.Image_bg.ScrollView_1"] = {name = "ScrollView_1" },
		-- ["Panel_root.Image_bg.Panel_title.Text_title"] = {name = "Text_title" },
		["Panel_root.Image_bg.Button_get"] = {name = "Button_get" ,click = "onGetRewardButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
	
	self:initItemList(self.openInfo.itemList)
	-- self.Text_title:setString(self.openInfo.title)
	self.Button_get:setVisible(self.openInfo.showGetButton)
end

function GameRewardReceiveUI:createScrollItem(itemInfo,i,totalNum)
	
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
	item:setItemClickCallBack(nil)
	--item:setScale(0.8)
	local sz = item:getContentSize()
	self.ScrollView_1:addChild(item)
	
	local scrollViewSize = self.ScrollView_1:getContentSize()
	
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
		item:setPosition(cc.p(x+sz.width/2,scrollViewSize.height - sz.height/2-20))

	else
		scrollViewSize = self.ScrollView_1:getInnerContainerSize()
		--每行4列
		local y = math.floor((i-1)/4)  -- 0開始
		local x = math.floor((i-1)%4)  -- 0,1,2,3
		item:setPosition(cc.p((sz.width+30)*x+sz.width,scrollViewSize.height - y*(sz.height+40 ) - (sz.height/2+20)))
	end
	item:setVisible(true)
	
end

function GameRewardReceiveUI:initItemList(itemList)
	if itemList == nil or #itemList == 0 then
		return
	end
	local totalNum = #itemList
	self.itemList = itemList
	if totalNum > 50 then
		totalNum = 50
		self.itemList = table.arrSlice(itemList,1,50)
	end
    
	
	local scrollViewSize = self.ScrollView_1:getContentSize()
	local newHeight = 173
	local sz = cc.size(110,110) --一個物品框的大小
	if totalNum > 4 then
		local row = math.floor(totalNum / 4) + 1
		local newHeight = row * (sz.height+40)
		local showHeightMax = math.min(newHeight,450)
		self.ScrollView_1:setContentSize(cc.size(scrollViewSize.width, showHeightMax))
		self.ScrollView_1:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))

		self.Image_bg:setContentSize(699,showHeightMax + 80)
		self.Panel_root:setContentSize(720,showHeightMax + 90)
	else
		self.ScrollView_1:setContentSize(cc.size(scrollViewSize.width,newHeight))
		self.ScrollView_1:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))
		self.Image_bg:setContentSize(699,newHeight+80)
		self.Panel_root:setContentSize(720,newHeight+90)
	end
	
	for i=1,totalNum do
		self:createScrollItem(self.itemList[i],i,totalNum)
	end
	ccui.Helper:doLayout(self.rootView)
end

function GameRewardReceiveUI:onGetRewardButtonClick(sender)
	if self.openInfo and self.openInfo.cb then
		self.openInfo.cb()
	end
	self:delayNewGuide(0)
	cp.getManager("GDataManager"):showFightBuff()
	cp.getManager("PopupManager"):removePopup(self)
end

function GameRewardReceiveUI:getDescription()
    return "GameRewardReceiveUI"
end

function GameRewardReceiveUI:hideGetButton()
	self.Button_get:setVisible(false)
end

function GameRewardReceiveUI:setTitle(title)
	self.Image_1:loadTexture(title)
end

function GameRewardReceiveUI:onEnterScene()
	self:delayNewGuide(0.3)
end


function GameRewardReceiveUI:delayNewGuide(delayTime)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "mail" then
		if delayTime > 0 then
			local sequence = {}
			table.insert(sequence, cc.DelayTime:create(delayTime))
			table.insert(sequence,cc.CallFunc:create(function()
				local info = 
				{
					classname = "GameRewardReceiveUI",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end))
			self:runAction(cc.Sequence:create(sequence))
		else
			local info = 
			{
				classname = "GameRewardReceiveUI",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
    end
end

return GameRewardReceiveUI
