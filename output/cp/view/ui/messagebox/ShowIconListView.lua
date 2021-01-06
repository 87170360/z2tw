local BLayer = require "cp.view.ui.base.BLayer"
local ShowIconListView = class("ShowIconListView", BLayer)

function ShowIconListView:create(iconList,title,btnName,cb)
	local ret = ShowIconListView.new(iconList)
	ret.cb = cb
	if btnName and btnName ~= "" then
		ret.Button_get:getChildByName("Text_1"):setString(btnName)
	end
	
	if title and title ~= "" then
		ret.Image_1:loadTexture(title)
	end
    return ret
end

function ShowIconListView:onInitView(iconList)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_show_icon.csb")
    self:addChild(self.rootView)
	self.rootView:setPosition(cc.p(0,0))
	self.rootView:setContentSize(display.size)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Panel_Model.Image_4"] = {name = "Image_4"},
		["Panel_root.Image_bg.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_bg.ScrollView_1"] = {name = "ScrollView_1" },
		["Panel_root.Image_bg.Button_get"] = {name = "Button_get" ,click = "onGetRewardButtonClick"},
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_bg)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	
	self["Image_bg"]:setTouchEnabled(true)
	self:initItemList(iconList)
	self.Image_4:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2, 15)))
end

function ShowIconListView:createScrollIcon(iconInfo,i,totalNum)
	local item = require("cp.view.ui.icon.ItemIcon"):create(iconInfo)
	item:setItemClickCallBack(nil)
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

function ShowIconListView:initItemList(iconList)
	if iconList == nil or #iconList == 0 then
		return
	end
	local totalNum = #iconList
	self.iconList = iconList
	if totalNum > 50 then
		totalNum = 50
		self.iconList = table.arrSlice(iconList,1,50)
	end
	
	local scrollViewSize = self.ScrollView_1:getContentSize()
	local newHeight = 173
	local sz = cc.size(110,110) --一個物品框的大小
	if totalNum > 4 then
		local row = math.floor((totalNum - 1) / 4) + 1
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
		self:createScrollIcon(iconList[i],i,totalNum)
	end
	ccui.Helper:doLayout(self.rootView)
end

function ShowIconListView:onGetRewardButtonClick(sender)
	if self.cb then
		self.cb()
	end
	self:removeFromParent()
end

function ShowIconListView:getDescription()
    return "ShowIconListView"
end

function ShowIconListView:hideGetButton()
	self.Button_get:setVisible(false)
end

function ShowIconListView:setTitle(title)
	self.Image_1:loadTexture(title)
	-- self.Text_title:setString(title)
end

return ShowIconListView