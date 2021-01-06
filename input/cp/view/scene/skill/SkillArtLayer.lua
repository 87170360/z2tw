local BLayer = require "cp.view.ui.base.BLayer"
local SkillArtLayer = class("SkillArtLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
local DataUtils = cp.getUtils("DataUtils")

function SkillArtLayer:create(skillEntry, index)
	local scene = SkillArtLayer.new()
	scene.skillEntry = skillEntry
	scene.artIndex = index
	scene:initSkillInfoView()
    return scene
end

function SkillArtLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").ArtLevelUpRsp] = function(data)
			self:updateSkillArtView()
		end,
		[cp.getConst("EventConst").UseSkillArtRsp] = function(data)
			self:updateSkillArtView()
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillArtLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_art.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Skill"] = {name = "Image_Skill"},
		["Panel_root.Image_1.Button_Art1"] = {name = "Button_Art1", click="onBtnClick", clickScale=1},
		["Panel_root.Image_1.Button_Art2"] = {name = "Button_Art2", click="onBtnClick", clickScale=1},
		["Panel_root.Image_1.Button_Art3"] = {name = "Button_Art3", click="onBtnClick", clickScale=1},
		["Panel_root.Image_1.Button_Art4"] = {name = "Button_Art4", click="onBtnClick", clickScale=1},
		["Panel_root.Image_1.Button_Matiral1"] = {name = "Button_Matiral1"},
		["Panel_root.Image_1.Button_Matiral2"] = {name = "Button_Matiral2"},
		["Panel_root.Image_1.Button_Matiral3"] = {name = "Button_Matiral3"},
		["Panel_root.Image_1.Button_Go"] = {name = "Button_Go", click="onBtnClick"},
		["Panel_root.Image_1.Text_Desc"] = {name = "Text_Desc"},
		["Panel_root.Image_1.Text_SkillName"] = {name = "Text_SkillName"},
		["Panel_root.Image_1.Text_LearnPoint"] = {name = "Text_LearnPoint"},
		["Panel_root.Image_1.Button_AddLearnPoint"] = {name = "Button_AddLearnPoint", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Equip"] = {name = "Button_Equip", click="onBtnClick"},
		["Panel_root.Image_1.Text_Effect1"] = {name = "Text_Effect1"},
		["Panel_root.Image_1.Text_Effect2"] = {name = "Text_Effect2"},
		["Panel_root.Image_1.Text_EffectName1"] = {name = "Text_EffectName1"},
		["Panel_root.Image_1.Text_EffectName2"] = {name = "Text_EffectName2"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
end

function SkillArtLayer:initSkillInfoView()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	self.Image_Skill:loadTexture(self.skillEntry:getValue("Icon"))
	self.Image_Skill:getChildByName("Image_Icon"):loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	self.Text_SkillName:setString(self.skillEntry:getValue("SkillName"))
	cp.getManager("ViewManager").setTextQuality(self.Text_SkillName, self.skillEntry:getValue("Colour"))
	self.artList = cp.getUtils("DataUtils").splitBufferList(self.skillEntry:getValue("Arts"))
	for i=1, 4 do
		local btn = self["Button_Art"..i]
		local icon = btn:getChildByName("Image_Icon")
		local textName = btn:getChildByName("Text_Name")
		icon:loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)

		local artEntry = nil
		if self.artList and self.artList[i] then
			artEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", self.artList[i])
		end

		if artEntry then
			btn:loadTextures(artEntry:getValue("Icon"), artEntry:getValue("Icon"), artEntry:getValue("Icon"))
			textName:setString(artEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(textName, self.skillEntry:getValue("Colour"))
			btn:setVisible(true)
			textName:setVisible(true)
		else
			btn:setVisible(false)
			textName:setVisible(false)
		end
	end

	if #self.artList > 0 then
		if skillInfo and #skillInfo.art_list >= 0 and not self.artIndex then
			if skillInfo.art_index == -1 then
				self.artIndex = 1
			else
				self.artIndex = skillInfo.art_index+1
			end
		end
	end
	self:updateSkillArtView()
end

function SkillArtLayer:updateSkillArtView()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	for i=1, 4 do
		local btn = self["Button_Art"..i]
		local imgFlag = btn:getChildByName("Image_Flag")
		local imgIcon = btn:getChildByName("Image_Icon")
		local imgEquip = btn:getChildByName("Image_Equip")
		local imgMask = btn:getChildByName("Image_Mask")
		local txtLevel = btn:getChildByName("Text_Level")
		local artInfo = skillInfo.art_list[i]
		if artInfo then
			imgMask:setOpacity(0)
			txtLevel:setVisible(true)
			txtLevel:setString("LV."..artInfo.art_level+1)
		else
			txtLevel:setVisible(false)
			imgMask:setOpacity(150)
		end
		if i == self.artIndex then
			imgFlag:setVisible(true)
		else
			imgFlag:setVisible(false)
		end
		if i == skillInfo.art_index+1 then
			imgEquip:setVisible(true)
		else
			imgEquip:setVisible(false)
		end
	end

	self.itemList = cp.getUserData("UserItem"):getItemList()
	local artInfo = nil
	if skillInfo then
		artInfo = skillInfo.art_list[self.artIndex]
		if not self.artIndex or skillInfo.art_index + 1 == self.artIndex then
			cp.getManager("ViewManager").setEnabled(self.Button_Equip, false)
		else
			cp.getManager("ViewManager").setEnabled(self.Button_Equip, true)
		end
	end

	local artEntry = nil
	if self.artIndex then
		artEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", self.artList[self.artIndex])
	end

	local artLevel = 1
	if artInfo then
		--self.Button_Go:setEnabled(true)
		artLevel = artInfo.art_level + 1
	else
		--self.Button_Go:setEnabled(false)
	end

	local artLevelUpEntry = cp.getManager("ConfigManager").getItemByKey("SkillArtLevelUp", artLevel)
	local matiralList = {}
	if artLevelUpEntry then
		matiralList = cp.getUtils("DataUtils").splitAttr(artLevelUpEntry:getValue(CombatConst.SeriseColor[self.skillEntry:getValue("Colour")]))
	end

	for i=1, 3 do
		local button = self["Button_Matiral"..i]
		local name = button:getChildByName("Text_Name")
		local icon = button:getChildByName("Image_Icon")
		local num = button:getChildByName("Text_Num")
		if artEntry and matiralList[i] then
			button:setVisible(true)
			local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", matiralList[i][1])
			local textureName = CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")]
			cp.getManager("ViewManager").addWidgetBottom(button, itemEntry:getValue("Hierarchy"))
			button:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
			cp.getManager("ViewManager").initButton(button, function()
				local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
				layer:setCloseCallback(function()
					self:updateSkillArtView()
				end)
				self:addChild(layer, 100)
			end, 0.9)
			icon:loadTexture(itemEntry:getValue("Icon"))
			name:setString(itemEntry:getValue("Name"))
			cp.getManager("ViewManager").setTextQuality(name, itemEntry:getValue("Hierarchy"))
			local itemNum = self.itemList[matiralList[i][1]] or 0
			num:setString(string.format("%d/%d", itemNum, matiralList[i][2]))
			if itemNum < matiralList[i][2] then
				cp.getManager("ViewManager").setTextQuality(num, 6)
				--self.Button_Go:setEnabled(false)
			else
				cp.getManager("ViewManager").setTextQuality(num, 2)
				--self.Button_Go:setEnabled(true)
			end
			name:setVisible(true)
			icon:setVisible(true)
			num:setVisible(true)
		else
			name:setVisible(false)
			icon:setVisible(false)
			num:setVisible(false)
		end
	end
	
	if self.artIndex then
		self.Text_Desc:setString(string.format("該武學完成第%d次突破", self.artIndex))
		if skillInfo and (skillInfo.skill_level > self.artIndex*20 or (skillInfo.skill_level == self.artIndex*20 and skillInfo.is_break)) then
			cp.getManager("ViewManager").setTextQuality(self.Text_Desc, 2)
		else
			cp.getManager("ViewManager").setTextQuality(self.Text_Desc, 6)
		end
		local needPoint = cp.getUtils("DataUtils").GetArtLevelUpCost(self.skillEntry:getValue("Colour"), artLevel)
		if needPoint <= cp.getUserData("UserSkill"):getLearnPoint() then
			cp.getManager("ViewManager").setTextQuality(self.Text_LearnPoint, 2)
		else
			cp.getManager("ViewManager").setTextQuality(self.Text_LearnPoint, 6)
		end
		self.Text_LearnPoint:setString(string.format("%d/%d", needPoint, cp.getUserData("UserSkill"):getLearnPoint()))
		
		if artInfo then
			local nextLevel = artInfo.art_level+1
			if artInfo.art_level >= 6 then
				nextLevel = artInfo.art_level
			end
		end
	else
		self.Text_Desc:setString("")
		self.Text_LearnPoint:setString("")
	end

	local level1 = 0
	if artInfo then
		level1 = artInfo.art_level
	end
	local level2 = level1 + 1

	local artEffectDesc1 = ""
	local attrList1 = {}
	local artEffectDesc2 = ""
	local attrList2 = {}
	local bufferList = cp.getUtils("DataUtils").splitBufferList(artEntry:getValue("BufferList"))
	for i=1, #bufferList do
		local skillStatusEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferList[i])
		if skillStatusEntry then
			self.Text_EffectName1:setString(skillStatusEntry:getValue("Name").."：")
			self.Text_EffectName2:setString(skillStatusEntry:getValue("Name").."：")
			cp.getManager("ViewManager").setTextQuality(self.Text_EffectName1, 2)
			cp.getManager("ViewManager").setTextQuality(self.Text_EffectName2, 2)
			local eventList = cp.getUtils("DataUtils").splitBufferList(skillStatusEntry:getValue("EventList"))
			for i=1, #eventList do
				local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", eventList[i])
				if eventEntry then
					local list1 = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
					table.insertto(list1, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
					local list2 = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
					table.insertto(list2, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
					local conditionInfo = DataUtils.split(eventEntry:getValue("Rate"), "=")
					if conditionInfo[1] == 0 then
						table.insert(list1, {
							CombatConst.GameElement_ConditionRate, 0, conditionInfo[2] or 10000
						})
						table.insert(list2, {
							CombatConst.GameElement_ConditionRate, 0, conditionInfo[2] or 10000
						})
					else
						table.insert(list1, {
							CombatConst.GameElement_ConditionRate, 2, conditionInfo[1] or 10000
						})
						table.insert(list2, {
							CombatConst.GameElement_ConditionRate, 2, conditionInfo[1] or 10000
						})
					end

					cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), level1, list1)
					cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), level2, list2)
					for k, v in ipairs(list1) do
						table.insert(attrList1, v)
					end

					for k, v in ipairs(list2) do
						table.insert(attrList2, v)
					end
				end
			end

			local desc1 = skillStatusEntry:getValue("Comment")
			local desc2 = skillStatusEntry:getValue("Comment")
			local list1 = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("Elements"))
			local list2 = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("Elements"))
			local boolStatusList = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("BoolStatus"))
			for _, boolStatusInfo in ipairs(boolStatusList) do
				table.insert(list1, {
					CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
				})
				table.insert(list2, {
					CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
				})
			end
			
			cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), level2, list2)
			cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), level1, list1)
			
			for k, v in ipairs(list1) do
				table.insert(attrList1, v)
			end
			for k, v in ipairs(list2) do
				table.insert(attrList2, v)
			end
			desc1 = cp.getUtils("DataUtils").formatSkillEffect(nil, desc1, attrList1)
			desc2 = cp.getUtils("DataUtils").formatSkillEffect(nil, desc2, attrList2)
			artEffectDesc1 = artEffectDesc1..desc1
			artEffectDesc2 = artEffectDesc2..desc2
		end
	end

	self.Text_Effect1:setString("           "..artEffectDesc1)
	if level2 > 6 then
		self.Text_Effect2:setString("當前已達最高等級")
		self.Text_EffectName2:setVisible(false)
	else
		self.Text_Effect2:setString("           "..artEffectDesc2)
		self.Text_EffectName2:setVisible(true)
	end
end

function SkillArtLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function SkillArtLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_AddLearnPoint" then
		local layer = require("cp.view.scene.skill.SkillPieceDecomposeLayer"):create()
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateSkillArtView()
		end)
	elseif nodeName == "Button_Art1" then
		if #self.artList >= 1 then
			self.artIndex = 1
			self:updateSkillArtView()
		end
	elseif nodeName == "Button_Art2" then
		if #self.artList >= 2 then
			self.artIndex = 2
			self:updateSkillArtView()
		end
	elseif nodeName == "Button_Art3" then
		if #self.artList >= 3 then
			self.artIndex = 3
			self:updateSkillArtView()
		end
	elseif nodeName == "Button_Art4" then
		if #self.artList >= 4 then
			self.artIndex = 4
			self:updateSkillArtView()
		end
	elseif nodeName == "Button_Equip" then
		local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
		local artInfo = skillInfo.art_list[self.artIndex]
		if not self.artIndex or not artInfo then
			cp.getManager("ViewManager").gameTip(string.format("武學完成第%d次突破激活該招式", self.artIndex))
			return
		end
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
		req.index = self.artIndex-1
    	self:doSendSocket(cp.getConst("ProtoConst").UseSkillArtReq, req)
	elseif nodeName == "Button_Go" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
		req.index = self.artIndex-1
    	self:doSendSocket(cp.getConst("ProtoConst").ArtLevelUpReq, req)
	end
end

function SkillArtLayer:onEnterScene()
	local result,step = cp.getManager("GDataManager"):checkNeedGuide("skill_art")
	if result then
		cp.getManager("ViewManager").openNewPlayerGuide("skill_art",step)
	end
end

function SkillArtLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillArtLayer