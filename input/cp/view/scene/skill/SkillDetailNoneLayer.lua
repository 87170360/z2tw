local BLayer = require "cp.view.ui.base.BLayer"
local SkillDetailNoneLayer = class("SkillDetailNoneLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
local DataUtils = cp.getUtils("DataUtils")

function SkillDetailNoneLayer:create(skillEntry, skillInfo, flag, equipList)
	local scene = SkillDetailNoneLayer.new(skillEntry, flag)
	if skillInfo == nil then 
		skillInfo = {}
	end
	skillInfo.skill_level = skillInfo.skill_level or 1
	skillInfo.boundary = skillInfo.boundary or 0
	skillInfo.art = skillInfo.art or 0
	skillInfo.art_level = skillInfo.art_level or 0
	scene.skillEntry = skillEntry
	scene.skillInfo = skillInfo
	scene.equipList = equipList or cp.getUserData("UserSkill"):getEquipSkillList()
    return scene
end

function SkillDetailNoneLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		[cp.getConst("EventConst").LearnSkillRsp] = function(data)
			if self.closeCallback then
				self.closeCallback()
			end
			self:removeFromParent()
		end,

		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "SkillDetailNoneLayer" then
				if evt.guide_name == "menpai_wuxue" then
					self:onBtnClick(self[evt.target_name])
				end
			end
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "SkillDetailNoneLayer" then
				if evt.guide_name == "menpai_wuxue" then
					if evt.target_name == "Button_Study" then
						
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					end
				end
			end
		end
    }
end

--初始化界面，以及設定界面元素標籤
function SkillDetailNoneLayer:onInitView(skillEntry, flag)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_detail_none.csb")
    self:addChild(self.rootView)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Skill"] = {name = "Image_Skill"},
		["Panel_root.Image_1.Image_SkillType"] = {name = "Image_SkillType"},
		["Panel_root.Image_1.Text_SkillName"] = {name = "Text_SkillName"},
		["Panel_root.Image_1.Image_Power.Text_Power"] = {name = "Text_Power"},
		["Panel_root.Image_1.Image_Cost.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Image_6.Text_Attr1"] = {name = "Text_Attr1"},
		["Panel_root.Image_1.Image_6.Text_Attr2"] = {name = "Text_Attr2"},
		["Panel_root.Image_1.ListView_Effect"] = {name = "ListView_Effect"},
		["Panel_root.Image_1.Panel_Effect"] = {name = "Panel_Effect"},
		["Panel_root.Image_1.Button_Strategy"] = {name = "Button_Strategy", click="onBtnClick"},
		["Panel_root.Image_1.Button_Study"] = {name = "Button_Study", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)

	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root, function()
		if self.closeCallback then
			self.closeCallback()
		end
	end)

	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.ListView_Effect:setScrollBarEnabled(false)

	if flag then
		self.Button_Study:setVisible(true)
		self.Button_Strategy:setVisible(true)
	else
		self.Button_Study:setVisible(false)
		self.Button_Strategy:setVisible(false)
		local size = self.Image_1:getSize()
		size.height = size.height - 50
		self.Image_1:setSize(size)
	end
	
	ccui.Helper:doLayout(self.rootView)
	local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
	if skillInfo then
		cp.getManager("ViewManager").setEnabled(self.Button_Study, false)
	else
		cp.getManager("ViewManager").setEnabled(self.Button_Study, true)
	end
end

function SkillDetailNoneLayer:updateSkillDetailView()
	local skillInfo = self.skillInfo
	self.Image_Skill:loadTexture(self.skillEntry:getValue("Icon"))
	self.Image_Skill:getChildByName("Text_Level"):setString("LV."..skillInfo.skill_level)
	self.Image_SkillType:loadTexture(CombatConst.SkillSerise_IconList[self.skillEntry:getValue("Serise")], ccui.TextureResType.plistType)
	local icon = self.Image_Skill:getChildByName("Image_Icon")
	icon:loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	cp.getManager("ViewManager").setTextQuality(self.Text_SkillName, self.skillEntry:getValue("Colour"))
	self.Text_SkillName:setString(self.skillEntry:getValue("SkillName"))
	
	local power = 0
	if self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
		self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
			self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
		power = cp.getUtils("DataUtils").GetSkillPower(self.skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.boundary)
	end
	self.Text_Power:setString(power)
	self.Text_Cost:setString(cp.getUtils("DataUtils").GetSkillForceCost(self.skillEntry:getValue("Colour"), skillInfo.skill_level))
	local attrList = cp.getUtils("DataUtils").splitAttr(self.skillEntry:getValue("AttrList"))
	for i=1, 2 do
		if attrList[i] then
			local id = attrList[i][1]
			local value = cp.getUtils("DataUtils").GetSkillExtraEffect(self.skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.boundary, id, self.skillEntry:getValue("Serise"))
			if #attrList == 1 then
				value = value * 2
			end
			local tempStr = cp.getUtils("DataUtils").formatSkillAttribute(id, value)
			self["Text_Attr"..i]:setString(tempStr)
			cp.getManager("ViewManager").setTextQuality(self["Text_Attr"..i], 2)
			self["Text_Attr"..i]:setVisible(true)
		else
			self["Text_Attr"..i]:setVisible(false)
		end
	end

	local panelIndex = 0
	local totalHeight = 0
	--上陣效果
	local eventList = cp.getUtils("DataUtils").splitBufferList(self.skillEntry:getValue("EventList"))
	if #eventList > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_EquipEffect")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_EquipEffect")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("上陣效果")
			panel:setVisible(true)
			self.ListView_Effect:insertCustomItem(panel, panelIndex)
			panelIndex = panelIndex + 1
		else
			panel:removeChildByName("RichText_EquipEffect")
		end

		local richText = cp.getUtils("DataUtils").formatEquipEffect(self.skillInfo.skill_level, self.skillEntry:getValue("Colour"), eventList)
		local deltaHeight = richText:getContentSize().height - 20
		panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
		panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
		panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
		panel:setSize(cc.size(660, 90 + deltaHeight))
		local pos = cc.p(28, 37 + deltaHeight)
		richText:setPosition(pos)
		panel:addChild(richText)
		totalHeight = totalHeight + 90 + deltaHeight
	end

	--出招效果
	local bufferList = cp.getUtils("DataUtils").splitBufferList(self.skillEntry:getValue("BufferList"))
	if #bufferList > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_UseEffect")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_UseEffect")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("出招效果")
			panel:setVisible(true)
			self.ListView_Effect:insertCustomItem(panel, panelIndex)
			panelIndex = panelIndex + 1
		else
			panel:removeChildByName("RichText_UseEffect")
		end

		local richText = cp.getUtils("DataUtils").formatUseEffect(self.skillInfo.skill_level, self.skillEntry:getValue("Colour"), bufferList)
		local deltaHeight = richText:getContentSize().height - 20
		panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
		panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
		panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
		panel:setSize(cc.size(660, 90 + deltaHeight))
		local pos = cc.p(28, 37 + deltaHeight)
		richText:setPosition(pos)
		panel:addChild(richText)
		totalHeight = totalHeight + 90 + deltaHeight
	end

	--組合效果
	local skillUnitsEntry = cp.getManager("ConfigManager").getItemByKey("SkillUnits", self.skillEntry:getValue("SkillID"))
	if skillUnitsEntry then
		local panel = self.ListView_Effect:getChildByName("Panel_CombineEffect")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_CombineEffect")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("組合效果")
			panel:setVisible(true)
			self.ListView_Effect:insertCustomItem(panel, panelIndex)
			panelIndex = panelIndex + 1
		else
			panel:removeChildByName("RichText_CombineEffect")
		end

		local richText = cp.getUtils("DataUtils").formatCombineEffect(self.skillEntry, skillUnitsEntry, self.equipList)
		local deltaHeight = richText:getContentSize().height - 20
		panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
		panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
		panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
		panel:setSize(cc.size(660, 90 + deltaHeight))
		local pos = cc.p(28, 37 + deltaHeight)
		richText:setPosition(pos)
		panel:addChild(richText)
		totalHeight = totalHeight + 90 + deltaHeight
	end

	local artList = cp.getUtils("DataUtils").splitBufferList(self.skillEntry:getValue("Arts"))
	if #artList > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_ArtList")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_ArtList")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("武學招式")
			panel:setVisible(true)
			self.ListView_Effect:insertCustomItem(panel, panelIndex)
			panelIndex = panelIndex + 1
		end

		local deltaHeight = 100
		panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
		panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
		panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
		panel:setSize(cc.size(660, 90 + deltaHeight))
		totalHeight = totalHeight + 90 + deltaHeight
		for i, artID in ipairs(artList) do
			local pos = cc.p(28, 37 + deltaHeight)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", artID)
			local iconCfg = {}
			iconCfg.icon = skillEntry:getValue("Icon")
			iconCfg.color = skillEntry:getValue("Colour")
			iconCfg.name = skillEntry:getValue("SkillName")
			if self.skillInfo.art == artID then
				iconCfg.level = self.skillInfo.art_level + 1
			else
				iconCfg.level = 0
			end
			
			local btn = panel:getChildByName("SkillIcon_"..i)
			if not btn then
				btn = require("cp.view.ui.icon.SkillIcon"):create(iconCfg)
				btn:setName("SkillIcon_"..i)
				btn:setPosition(100 + (i-1)*150, 90)
				btn:addTo(panel, 100)
			end

			btn:setSkillClicked(function()
				local artLevel = 0
				if skillEntry:getValue("SkillID") == self.skillInfo.art then
					artLevel = self.skillInfo.art_level
				end
				local layer = require("cp.view.scene.skill.SkillSingleArtLayer"):create(skillEntry, artLevel)
				self:addChild(layer, 100)
			end)
		end
	end

	if self.skillEntry:getValue("GainWay"):len() > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_GainWay")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_GainWay")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("獲取途徑")
			panel:setVisible(true)
			self.ListView_Effect:pushBackCustomItem(panel)
			panelIndex = panelIndex + 1

			local richText = cp.getUtils("DataUtils").formatSkillGainWay(self.skillEntry)
			local deltaHeight = richText:getContentSize().height - 20
			panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
			panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
			panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
			panel:setSize(cc.size(660, 90 + deltaHeight))
			local pos = cc.p(28, 37 + deltaHeight)
			richText:setPosition(pos)
			panel:addChild(richText)
			totalHeight = totalHeight + 90 + deltaHeight
		end
	end

	cp.getManager("ViewManager").setWidgetAdapt(443, {self.Image_1, self.ListView_Effect}, totalHeight)
	ccui.Helper:doLayout(self.rootView)
end

function SkillDetailNoneLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	elseif nodeName == "Button_Strategy" then
		local layer = require("cp.view.scene.skill.SkillStrategyLayer"):create(self.skillEntry)
		self:addChild(layer, 100)
	elseif nodeName == "Button_Study" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
    	self:doSendSocket(cp.getConst("ProtoConst").LearnSkillReq, req)
	end
end

function SkillDetailNoneLayer:onEnterScene()
	local newHeight = display.height/2 + 110/2
	self.Image_1:setPositionY(newHeight) -- 110為底部一排按鈕的高度
	
	local sequence = {}
	table.insert(sequence, cc.DelayTime:create(0.3))
	table.insert(sequence,cc.CallFunc:create(function()
		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "menpai_wuxue" then
	
			local info = 
			{
				classname = "SkillDetailNoneLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
	end))

	self:runAction(cc.Sequence:create(sequence))
	self:updateSkillDetailView()
end

function SkillDetailNoneLayer:onExitScene()
    self:unscheduleUpdate()
end

function SkillDetailNoneLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

return SkillDetailNoneLayer