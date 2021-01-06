local GameRewardPreView = class("GameRewardPreView",function() return cc.Node:create() end)
function GameRewardPreView:create(itemList,title,showGetButton)
    local ret = GameRewardPreView.new()
    ret:init(itemList,title,showGetButton)
    return ret
end

function GameRewardPreView:init(itemList,title,showGetButton)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_reward_preview.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Panel_title.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_bg.Panel_title.ScrollView_1"] = {name = "ScrollView_1" },
		["Panel_root.Image_bg.Panel_title.Image_title.Text_title"] = {name = "Text_title" },
		["Panel_root.Image_bg.Panel_title.Button_close"] = {name = "Button_close" ,click = "onCloseButtonClick"},
		["Panel_root.Image_bg.Button_get"] = {name = "Button_get" ,click = "onGetRewardButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
	
	self.Text_title:setString(title)
	if string.utf8len_m(string.trim(title)) > 6 then
		self.Text_title:setFontSize(24*self.Text_title.clearScale)
	end
	self.Button_get:setVisible(showGetButton)
	self:initItemList(itemList)
	
end

function GameRewardPreView:createScrollItem(itemInfo,i,totalNum)
	
	local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
	item:setItemClickCallBack(nil)
	if itemInfo.isActive then
		item:addFlag("huodong")
	end
	--item:setScale(0.8)
	local sz = item:getContentSize()
	self["ScrollView_1"]:addChild(item)
	
	local scrollViewSize = self["ScrollView_1"]:getContentSize()
	
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
		scrollViewSize = self["ScrollView_1"]:getInnerContainerSize()
		--每行4列
		local y = math.floor((i-1)/4)  -- 0開始
		local x = math.floor((i-1)%4)  -- 0,1,2,3
		item:setPosition(cc.p((sz.width+30)*x+sz.width-10,scrollViewSize.height - y*(sz.height+40 ) - (sz.height/2+20)))
	end
	item:setVisible(true)
	
end

function GameRewardPreView:initItemList(itemList)
	if itemList == nil or #itemList == 0 then
		return
	end
	local totalNum = #itemList
	self.itemList = itemList
	for i=1,totalNum do
		local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", self.itemList[i].id)
		if cfgItem == nil then
			log("itemInfo.id = " .. itemInfo.id)
		end
		self.itemList[i].Colour = cfgItem:getValue("Hierarchy")
		self.itemList[i].Name = cfgItem:getValue("Name") 
		self.itemList[i].Icon = cfgItem:getValue("Icon")
		self.itemList[i].Type = cfgItem:getValue("Type")
	end

	local function sort_by_Quality(a,b)
        if a.Colour == b.Colour then
            return a.id > b.id
        end
        return a.Colour > b.Colour
    end
	table.sort(self.itemList,sort_by_Quality)

	
	local scrollViewSize = self["ScrollView_1"]:getContentSize()
	local root_size = self.Panel_root:getContentSize()
	self.Panel_root:setContentSize(root_size.width,365)
	self.Image_bg:setContentSize(root_size.width,365)
	local sz = cc.size(100,100) --一個物品框的大小
	if totalNum > 4 then
		local row = math.ceil(totalNum / 4)
		local newHeight = row * (sz.height+40)
		local delta = newHeight - scrollViewSize.height 
		local showHeightMax = math.min(newHeight,450)
		self["ScrollView_1"]:setContentSize(cc.size(scrollViewSize.width, showHeightMax))
		self["ScrollView_1"]:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))

		self.Panel_root:setContentSize(root_size.width,365 + showHeightMax - sz.height)
		self.Image_bg:setContentSize(root_size.width,365 + showHeightMax - sz.height)
		self.Image_1:setContentSize(root_size.width-60,185 + showHeightMax - sz.height)
	
	end
	
	if not self.Button_get:isVisible() then
		local newSz = self.Panel_root:getContentSize()
		self.Panel_root:setContentSize(newSz.width,newSz.height - 65)
		self.Image_bg:setContentSize(newSz.width,newSz.height - 65)
		if totalNum > 4 then
			local sz2 = self["ScrollView_1"]:getContentSize()
			self["ScrollView_1"]:setContentSize(cc.size(sz2.width, sz2.height + 65))
		end
	end

	for i=1,totalNum do
		self:createScrollItem(itemList[i],i,totalNum)
	end

	
	ccui.Helper:doLayout(self.rootView)
end

function GameRewardPreView:onCloseButtonClick(sender)
	 cp.getManager("PopupManager"):removePopup(self)
end

function GameRewardPreView:onGetRewardButtonClick(sender)
    cp.getManager("PopupManager"):removePopup(self)
end


function GameRewardPreView:getDescription()
    return "GameRewardPreView"
end

function GameRewardPreView:setTitle(title)
	self.Text_title:setString(title)
end

return GameRewardPreView