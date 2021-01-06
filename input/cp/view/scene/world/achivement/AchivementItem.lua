local BNode = require "cp.view.ui.base.BNode"
local AchivementItem = class("AchivementItem",BNode)

function AchivementItem:create()
	local node = AchivementItem.new()
	return node
end

function AchivementItem:initListEvent()
	self.listListeners = {

	}
end

function AchivementItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_achievement/uicsb_achievement_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        
		["Panel_item.Image_type"] = {name = "Image_type"},
		["Panel_item.Image_finished"] = {name = "Image_finished"},
		["Panel_item.Image_quality"] = {name = "Image_quality"},
		["Panel_item.Image_current"] = {name = "Image_current"},
		["Panel_item.Text_quality"] = {name = "Text_quality"},
		["Panel_item.Panel_reward"] = {name = "Panel_reward"},
		["Panel_item.Panel_reward.Node_item_1"] = {name = "Node_item_1"},
		["Panel_item.Panel_reward.Node_item_2"] = {name = "Node_item_2"},
		["Panel_item.Panel_reward.Node_item_3"] = {name = "Node_item_3"},
        ["Panel_item.Text_name"] = {name = "Text_name"},
        ["Panel_item.Text_des"] = {name = "Text_des"},
        ["Panel_item.Text_attribute"] = {name = "Text_attribute"},
		["Panel_item.Button_go"] = {name = "Button_go"},
		["Panel_item.Button_equip"] = {name = "Button_equip"},
		["Panel_item.Image_view"] = {name = "Image_view"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
    ccui.Helper:doLayout(self["rootView"])
end

function AchivementItem:onEnterScene()

end

function AchivementItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	if "Button_go" == buttonName then
		if self.info.state == 1 then
			--領取成就獎勵
			local req = {}
			req.id = self.info.ID
			self:doSendSocket(cp.getConst("ProtoConst").GetAchieveReq, req)
		else
			--前往
			self:dispatchViewEvent( cp.getConst("EventConst").achive_goto, self.info)
		end
	elseif "Button_equip" == buttonName then
		if self.info.state > 1 then
			--log("發消息更換稱號")
			local req = {}
			req.id = self.info.ID
			self:doSendSocket(cp.getConst("ProtoConst").SetAchieveTitleReq, req)
			
		else
			cp.getManager("ViewManager").gameTip("您尚未完成此成就")
		end
	elseif "Image_view" == buttonName then
		--查看成就加成的屬性
		self:dispatchViewEvent( cp.getConst("EventConst").open_all_achive_attribute )
	end
end

function AchivementItem:resetInfo(info)
	self.info = info

	local quality_icon = {"ui_achivement_module96_chengjiu_white.png","ui_achivement_module96_chengjiu_green.png","ui_achivement_module96_chengjiu_blue.png",
						"ui_achivement_module96_chengjiu_purplr.png","ui_achivement_module96_chengjiu_gold.png","ui_achivement_module96_chengjiu_red.png"}
	self.Image_quality:loadTexture(quality_icon[info.Quality] or "ui_achivement_module96_chengjiu_white.png",ccui.TextureResType.plistType)
	self.Image_type:loadTexture(info.Icon or "ui_achivement_module96_chengjiu_shouji.png",ccui.TextureResType.plistType)
	self.Text_quality:setString(info.QualityText)
	self.Text_quality:enableOutline(cp.getConst("CombatConst").QualityOutlineC4b[info.Quality], 2)
	self.Text_name:setString(info.Title)
	cp.getManager("ViewManager").setTextQuality(self.Text_name, info.Quality)
	self.Text_des:setString(info.Desc)
	self.Image_current:setVisible(false)

	--設置屬性
	local attStr = ""
	local arrAttribute = {}
	if info.Att ~= "" then
		local strArr = {}
		string.loopSplit(info.Att,"|-",strArr)
		for i=1,table.nums(strArr) do
			if strArr[i][1] and strArr[i][2] and tonumber(strArr[i][1]) and tonumber(strArr[i][2]) then
				local type = tonumber(strArr[i][1])
				-- local value = tonumber(strArr[i][2])
				local baseTitle = cp.getConst("CombatConst").AttributeList[type]
				attStr = attStr .. baseTitle .. "+" .. strArr[i][2] .. " "
			end
		end
	end
	if attStr == nil or attStr == "" then 
		attStr = "無加成屬性"
	end
	self.Text_attribute:setString(attStr)
	
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local achieveID = majorRole.achieveID
	self.Button_equip:getChildByName("Text_1"):setString(achieveID == self.info.ID and "已裝備" or "裝備")
	self.Image_current:setVisible(achieveID == self.info.ID)
	
	self.Image_finished:setVisible(false)
	self.Button_go:setVisible(true)
	local Text_1 = self.Button_go:getChildByName("Text_1")
	Text_1:setString(self.info.state == 1 and "領  取" or "前  往")
	Text_1:setTextColor(self.info.state == 1 and cc.c4b(4,79,11,255) or cc.c4b(122,22,22,255))
	local pic = self.info.state == 1 and "ui_common_module60_rechang7.png" or "ui_common_newbtn.png"
	self.Button_go:loadTextures(pic,pic,pic,ccui.TextureResType.plistType)
	if self.info.state == 2 then
		self.Button_go:setVisible(false)
		self.Image_finished:setVisible(true)
	end

	--設置獎勵物品
	for i=1,3 do
		self["Node_item_" .. tostring(i)]:removeAllChildren()
	end
	local itemList = {}
	if info.Items ~= "" then
		local strArr = {}
		string.loopSplit(info.Items,"|-",strArr)
		for i=1,table.nums(strArr) do
			if strArr[i][1] and strArr[i][2] and tonumber(strArr[i][1]) and tonumber(strArr[i][2]) and tonumber(strArr[i][1]) > 0 and tonumber(strArr[i][2]) > 0  then
				table.insert(itemList, {id=tonumber(strArr[i][1]),num=tonumber(strArr[i][2])})
			end
		end
	end
	
	if itemList and next(itemList) then
		for i=1,table.nums(itemList) do
			self:addIcon(self["Node_item_" .. tostring(i)], itemList[i].id, itemList[i].num)
		end
	end


	local function onTouch(sender, event)
        if event == cc.EventCode.BEGAN then
            sender:setScaleX(0.9)
            sender:setScaleY(0.9)
        elseif event == cc.EventCode.ENDED then
            sender:setScaleX(1)
            sender:setScaleY(1)
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
			if distance < 50 then
				self:onUIButtonClick(sender)
			end
        elseif event == cc.EventCode.CANCELLED then
            sender:setScaleX(1)
            sender:setScaleY(1)
        end
	end
	
	if self.Button_go:isVisible() then
		self.Button_go:addTouchEventListener(onTouch)
	end

	if self.Button_equip:isVisible() then
		self.Button_equip:addTouchEventListener(onTouch)
	end

	if self.Image_view:isVisible() then
		self.Image_view:addTouchEventListener(onTouch)
	end
end

function AchivementItem:addIcon(node, id, num)
	if node == nil then
		return
	end

	local itemInfo = {id = id}
	local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
	if not conf then
		log("item not exist in [GameItem], id =" .. tostring(id))
		return
	end

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


return AchivementItem