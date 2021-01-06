local BLayer = require "cp.view.ui.base.BLayer"
local SkillBoundaryLayer = class("SkillBoundaryLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillBoundaryLayer:create(skillEntry)
	local scene = SkillBoundaryLayer.new()
	scene.skillEntry = skillEntry
    return scene
end

function SkillBoundaryLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").ImproveSkillBoundaryRsp] = function(data)
			self:updateSkillBoundaryView()
			self:updateSkillBoundaryLight(data-1, data)
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillBoundaryLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_boundary.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Boundary"] = {name = "Text_Boundary"},
		["Panel_root.Image_1.Button_B1"] = {name = "Button_B1"},
		["Panel_root.Image_1.Button_B2"] = {name = "Button_B2"},
		["Panel_root.Image_1.Button_B3"] = {name = "Button_B3"},
		["Panel_root.Image_1.Button_B4"] = {name = "Button_B4"},
		["Panel_root.Image_1.Button_B5"] = {name = "Button_B5"},
		["Panel_root.Image_1.Button_B6"] = {name = "Button_B6"},
		["Panel_root.Image_1.Button_B7"] = {name = "Button_B7"},
		["Panel_root.Image_1.Button_B8"] = {name = "Button_B8"},
		["Panel_root.Image_1.Button_B9"] = {name = "Button_B9"},
		["Panel_root.Image_1.Button_B10"] = {name = "Button_B10"},
		["Panel_root.Image_1.Image_Line1"] = {name = "Image_Line1"},
		["Panel_root.Image_1.Image_Line2"] = {name = "Image_Line2"},
		["Panel_root.Image_1.Image_Line3"] = {name = "Image_Line3"},
		["Panel_root.Image_1.Image_Line4"] = {name = "Image_Line4"},
		["Panel_root.Image_1.Image_Line5"] = {name = "Image_Line5"},
		["Panel_root.Image_1.Image_Line6"] = {name = "Image_Line6"},
		["Panel_root.Image_1.Image_Line7"] = {name = "Image_Line7"},
		["Panel_root.Image_1.Image_Line8"] = {name = "Image_Line8"},
		["Panel_root.Image_1.Image_Line9"] = {name = "Image_Line9"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Go"] = {name = "Button_Go", click="onBtnClick"},
		["Panel_root.Image_1.Text_NeedBook"] = {name = "Text_NeedBook"},
		["Panel_root.Image_1.Text_NeedSilver"] = {name = "Text_NeedSilver"},
		["Panel_root.Image_1.Node_Matiral1"] = {name = "Node_Matiral1"},
		["Panel_root.Image_1.Node_Matiral2"] = {name = "Node_Matiral2"},
		["Panel_root.Image_1.Node_Matiral3"] = {name = "Node_Matiral3"},
		["Panel_root.Image_1.Button_Model"] = {name = "Button_Model"},
		["Panel_root.Image_1.Text_Power"] = {name = "Text_Power"},
		["Panel_root.Image_1.Text_Attr1"] = {name = "Text_Attr1"},
		["Panel_root.Image_1.Text_Attr2"] = {name = "Text_Attr2"},
		["Panel_root.Image_1.Text_Attr3"] = {name = "Text_Attr3"},
		["Panel_root.Image_1.Text_AttrPercent1"] = {name = "Text_AttrPercent1"},
		["Panel_root.Image_1.Text_AttrPercent2"] = {name = "Text_AttrPercent2"},
		["Panel_root.Image_1.Text_AttrPercent3"] = {name = "Text_AttrPercent3"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1, self)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
end

function SkillBoundaryLayer:updateSelectBoundary()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	if skillInfo.boundary < 10 then
		self.selectBoundary = skillInfo.boundary + 1
	else
		self.selectBoundary = 10
	end

	self:updateSkillBoundaryView()
end

function SkillBoundaryLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	elseif nodeName == "Button_Go" then
		local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
		if skillInfo.boundary == 10 then
			cp.getManager("ViewManager").gameTip("該武學已修煉至最高境界")
			return
		end

		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
		req.item_list = self.itemList
		self:doSendSocket(cp.getConst("ProtoConst").ImproveSkillBoundaryReq, req)
	end
end

function SkillBoundaryLayer:initSkillBoundaryView()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	if not skillInfo then
		self.selectBoundary = 1
	else
		self.selectBoundary = skillInfo.boundary+1
	end

	if self.selectBoundary > 10 then
		self.selectBoundary = 10
	end

	self.Text_Boundary:setString(string.format("境界 %s 層", CombatConst.NumberZh_Cn[skillInfo.boundary]))

	for i=1, 10 do
		local button = self["Button_B"..i]
		cp.getManager("ViewManager").initButton(button, function(sender)
			self["Button_B"..self.selectBoundary]:loadTextures("ui_skill_module14_wuxue_jingjie01.png",
				"ui_skill_module14_wuxue_jingjie01.png", "ui_skill_module14_wuxue_jingjie01.png",ccui.TextureResType.plistType)
			self.selectBoundary = i
			self:updateSkillBoundaryView()
		end, 1)
	end

	self:updateSkillBoundaryLight1(skillInfo.boundary)
	self:updateSkillBoundaryView()
end

function SkillBoundaryLayer:lightBoundary(boundary)
	log("light boundary="..boundary)
	local button = self["Button_B"..boundary]
	local model = button:getChildByName("light")
	if not model then
		model = cp.getManager("ViewManager").createSpineEffect("jingjie_light")
		model:setName("light")
		button:addChild(model)
	end
	model:setAnimation(0, "jingjie_light", true)
	model:setPosition(cc.p(23,23.5))
end

function SkillBoundaryLayer:lightLine(lineIndex, flag)
	local scale = self["Image_Line"..lineIndex]:getSize().width / 84
	local model = cp.getManager("ViewManager").createSpineEffect("effect_line")
	model:setAnimation(0, "effect_line", true)
	self["Image_Line"..lineIndex]:addChild(model)
	model:setPosition(cc.p(5,8))
	if not flag then
		model:runAction(cc.ScaleTo:create(0.25, scale, 1))
	else
		model:setScaleX(scale)
	end
end

function SkillBoundaryLayer:itemLight()
	for i=1, 3 do
		local node = self["Node_Matiral"..i]
		local button = node:getChildByName("Button_Model")
		if button then
			local model = button:getChildByName("ItemLight")
			model:setAnimation(0, "jingjie", false)
			model:setPosition(cc.p(45, -5))
		end
	end
end

function SkillBoundaryLayer:updateSkillBoundaryLight(from, to)
	self.Text_Boundary:setString(string.format("境界 %s 層", CombatConst.NumberZh_Cn[to]))
	local sequence = {}
	for i=from+1, to do
		local btnIndex = i
		local lineIndex = i - 1
		log("index="..i)
		if lineIndex > 0 and lineIndex < 10 then
			table.insert(sequence, cc.CallFunc:create(function()
				self:lightLine(lineIndex)
			end))

			table.insert(sequence, cc.DelayTime:create(0.25))
		end

		if btnIndex >= 1 and btnIndex <= 10 then
			table.insert(sequence, cc.CallFunc:create(function()
				self:lightBoundary(i)
			end))
		end
	end

	if #sequence > 0 then
		table.insert(sequence, cc.CallFunc:create(function()
			self:itemLight()
		end))

		table.insert(sequence, cc.DelayTime:create(0.8))
		table.insert(sequence, cc.CallFunc:create(function()
			self:updateSelectBoundary()
		end))
		self:runAction(cc.Sequence:create(sequence))
	end
end

function SkillBoundaryLayer:updateSkillBoundaryLight1(to)
	self.Text_Boundary:setString(string.format("境界 %s 層", CombatConst.NumberZh_Cn[to]))
	local sequence = {}
	for i=1, to do
		local btnIndex = i
		local lineIndex = i - 1
		if lineIndex > 0 and lineIndex < 10 then
			self:lightLine(lineIndex, true)
		end

		if btnIndex >= 1 and btnIndex <= 10 then
			self:lightBoundary(i)
		end
	end
end

function SkillBoundaryLayer:updateSkillBoundaryView()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	local needBook = 0
	self["Button_B"..self.selectBoundary]:loadTextures("ui_skill_module14_wuxue_jingjie02.png",
		"ui_skill_module14_wuxue_jingjie02.png", "ui_skill_module14_wuxue_jingjie02.png",ccui.TextureResType.plistType)

	if self.selectBoundary >= 1 and self.selectBoundary < 5 then
		needBook = 1
		self.Node_Matiral1:setPositionX(360)
		self.Node_Matiral1:setVisible(true)
		self.Node_Matiral2:setVisible(false)
		self.Node_Matiral3:setVisible(false)
	elseif self.selectBoundary >= 5 and self.selectBoundary < 9 then
		needBook = 2
		self.Node_Matiral1:setPositionX(260)
		self.Node_Matiral2:setPositionX(460)
		self.Node_Matiral1:setVisible(true)
		self.Node_Matiral2:setVisible(true)
		self.Node_Matiral3:setVisible(false)
	elseif self.selectBoundary >= 9 and self.selectBoundary <= 10 then
		needBook = 3
		self.Node_Matiral1:setPositionX(197)
		self.Node_Matiral2:setPositionX(360)
		self.Node_Matiral3:setPositionX(526)
		self.Node_Matiral1:setVisible(true)
		self.Node_Matiral2:setVisible(true)
		self.Node_Matiral3:setVisible(true)
	end

	local ownBook = 0
	local itemList = {}
	local itemBookID = self.skillEntry:getValue("ItemID")
	if itemBookID and itemBookID > 0 then
		local itemNum = cp.getUserData("UserItem"):getItemNum(itemBookID)
		ownBook = ownBook + itemNum
		for i=1, itemNum do
			table.insert(itemList, itemBookID)
			if #itemList == needBook then
				break
			end
		end
	end

	if #itemList ~= needBook then
		local itemID = cp.getUtils("DataUtils").splitBufferList(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BoundaryMatiral"))[self.skillEntry:getValue("Colour")]
		local itemNum = cp.getUserData("UserItem"):getItemNum(itemID)
		ownBook = ownBook + itemNum
		for i=1, itemNum do
			table.insert(itemList, itemID)
			if #itemList == needBook then
				break
			end
		end
	end

	if ownBook >= needBook then
		cp.getManager("ViewManager").setTextQuality(self.Text_NeedBook, 2)
	else
		cp.getManager("ViewManager").setTextQuality(self.Text_NeedBook, 6)
	end
	self.Text_NeedBook:setString(string.format("修煉需求 %d 本", needBook))
	
	local boundaryEntry = cp.getManager("ConfigManager").getItemByKey("SkillBoundaryUpgrade", self.selectBoundary)
	local userData = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local needSilver = tonumber(boundaryEntry:getValue(CombatConst.SeriseColor[self.skillEntry:getValue("Colour")]))
	if userData.silver >= needSilver then
		cp.getManager("ViewManager").setTextQuality(self.Text_NeedSilver, 2)
	else
		cp.getManager("ViewManager").setTextQuality(self.Text_NeedSilver, 6)
	end
	self.Text_NeedSilver:setString(string.format("修煉銀兩%d", needSilver))

	self.itemList = itemList
	for i=1, needBook do
		local node = self["Node_Matiral"..i]
		node:setVisible(true)
		local button = node:getChildByName("Button_Model")
		if not button then
			button = self.Button_Model:clone()
			node:addChild(button)
			button:setPosition(0, 0)
			local model = cp.getManager("ViewManager").createSpineEffect("jingjie")
			model:setName("ItemLight")
			button:addChild(model)
		end
		button:setVisible(true)
		local icon = button:getChildByName("Image_Icon")
		local imgMask = button:getChildByName("Image_Mask")
		local name = button:getChildByName("Text_Name")
		local itemEntry = nil
		if itemList[i] then
			itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemList[i])
			cp.getManager("ViewManager").addWidgetBottom(button, itemEntry:getValue("Hierarchy"))
			cp.getManager("ViewManager").initButton(button, function()
				local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
				layer:setCloseCallback(function()
					self:updateSkillBoundaryView()
				end)
				self:addChild(layer, 100)
			end)
			imgMask:setOpacity(0)
		else
			itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemBookID)
			cp.getManager("ViewManager").addWidgetBottom(button, itemEntry:getValue("Hierarchy"))
			cp.getManager("ViewManager").initButton(button, function()
				local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
				layer:setCloseCallback(function()
					self:updateSkillBoundaryView()
				end)
				self:addChild(layer, 100)
			end)
			imgMask:setOpacity(150)
		end

		icon:loadTexture( CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
		name:setString(itemEntry:getValue("Name"))
		button:loadTextures(itemEntry:getValue("Icon"), itemEntry:getValue("Icon"), itemEntry:getValue("Icon"))
		cp.getManager("ViewManager").setTextQuality(name, itemEntry:getValue("Hierarchy"))
	end

	for i=needBook + 1, 3 do
		local node = self["Node_Matiral"..i]
		node:setVisible(false)
	end

	local attrList = cp.getUtils("DataUtils").splitAttr(self.skillEntry:getValue("AttrList"))
	local index = 1
	if self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
		self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
		self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
		local power = cp.getUtils("DataUtils").GetSkillPower(self.skillEntry:getValue("Colour"), skillInfo.skill_level, self.selectBoundary)
		self.Text_Attr1:setString(string.format("威力＋%d", power))
		self.Text_AttrPercent1:setString(string.format("威力提升至%d%%", cp.getUtils("DataUtils").GetSkillPowerByBoundary(self.selectBoundary)*100))
		cp.getManager("ViewManager").setTextQuality(self.Text_Attr1, 2)
		index = 2
	end
	local j = 1
	for i=index, 3 do
		local txtAttr = self["Text_Attr"..i]
		local txtAttrPercent = self["Text_AttrPercent"..i]
		if attrList[j] then
			txtAttr:setVisible(true)
			local id = attrList[j][1]
			local value = cp.getUtils("DataUtils").GetSkillExtraEffect(self.skillEntry:getValue("Colour"), skillInfo.skill_level, self.selectBoundary, id, self.skillEntry:getValue("Serise"))
			if #attrList == 1 then
				value = value * 2
			end
			local desc = cp.getUtils("DataUtils").formatSkillAttribute(id, value)
			txtAttr:setString(desc)
			txtAttrPercent:setString(string.format("%s提升至%d%%", CombatConst.AttributeList[id], cp.getUtils("DataUtils").GetSkillExtraEffectByBoundary(self.selectBoundary, self.skillEntry:getValue("Serise"))*100))
			cp.getManager("ViewManager").setTextQuality(txtAttr, 2)
		else
			txtAttr:setVisible(false)
			txtAttrPercent:setVisible(false)
		end
		j = j + 1
	end
end

function SkillBoundaryLayer:onEnterScene()
	self:initSkillBoundaryView()

	local result,step = cp.getManager("GDataManager"):checkNeedGuide("skill_boundary")
	if result then
		cp.getManager("ViewManager").openNewPlayerGuide("skill_boundary",step)
	end
end

function SkillBoundaryLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function SkillBoundaryLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillBoundaryLayer