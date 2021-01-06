local BLayer = require "cp.view.ui.base.BLayer"
local MenPaiSkillLayer = class("MenPaiSkillLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function MenPaiSkillLayer:create(openInfo)
    local scene = MenPaiSkillLayer.new()
    return scene
end

function MenPaiSkillLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		[cp.getConst("EventConst").LearnSkillRsp] = function(data)
			self:updateMenPaiSkillView()
		end,

		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MenPaiSkillLayer" then
				if evt.guide_name == "menpai_wuxue" then
					if evt.target_name == "menpai_skill_1" then
						self:onSillItemClicked(self.skillList[1])
					elseif evt.target_name == "menpai_skill_2" then
						self:onSillItemClicked(self.skillList[2])
					elseif evt.target_name == "Button_close" then
						self:onBtnClick(self[evt.target_name])
					end
				end
			end
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "MenPaiSkillLayer" then
				if evt.guide_name == "menpai_wuxue" then
					if evt.target_name == "menpai_skill_1" then
						
						local skill_btn1 = self:getSkillButtonFromListView(1,1)
						local boundbingBox = skill_btn1:getBoundingBox()
						local pos = skill_btn1:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info

					elseif evt.target_name == "menpai_skill_2" then
						local skill_btn1 = self:getSkillButtonFromListView(1,2)
						local boundbingBox = skill_btn1:getBoundingBox()
						local pos = skill_btn1:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					elseif evt.target_name == "Button_close" then
						
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						pos.y = pos.y
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
function MenPaiSkillLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_skill.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_Model"] = {name = "Panel_Model"},
		-- ["Panel_root.Button_SkillModel"] = {name = "Button_SkillModel"},
		-- ["Panel_root.Panel_Basic"] = {name = "Panel_Basic"},
		["Panel_root.Image_top"] = {name = "Image_top"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_border"] = {name = "Image_border"},
		["Panel_root.ListView_Skill"] = {name = "ListView_Skill"},
		["Panel_root.Image_top.Button_close"] = {name = "Button_close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	
	self.Panel_Model:setVisible(false)
	self.ListView_Skill:setScrollBarEnabled(false)
	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_bg, self.Image_border, self.ListView_Skill})
	
	ccui.Helper:doLayout(self.rootView)
	
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance", major_roleAtt.career)
	self.Image_top:getChildByName("Text_title"):setString(cfgItem:getValue("Name") .. "武學")

	self:updateMenPaiSkillView()
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
			end
		end
	end)
end

function MenPaiSkillLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_close" then
		if self.closeCallBack then
			self.closeCallBack()
		end
		self:removeFromParent()
	end
end

function MenPaiSkillLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function MenPaiSkillLayer:getSortSkillList()
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

	local gang = cp.getUserData("UserRole"):getValue("major")
	local skillEntryList = cp.getManager("ConfigManager").getItemListByMatch("SkillEntry", {Gang = {major_roleAtt.career}, SkillType=1})
	table.sort(skillEntryList, function(a, b)
		if a:getValue("Colour") < b:getValue("Colour") then
			return true
		elseif a:getValue("Colour") == b:getValue("Colour") and a:getValue("SkillID") < b:getValue("SkillID") then
			return true
		end
		return false
	end)

	return skillEntryList
end

function MenPaiSkillLayer:updateOneMenPaiSkillView(level, skillList)
	local model = self.ListView_Skill:getChildByName("Panel_Model_" .. tostring(level))
	if model == nil then
		model = self.Panel_Model:clone()
		model:setName("Panel_Model_" .. tostring(level))
		self.ListView_Skill:pushBackCustomItem(model)
		model:setVisible(true)
	end

	local textLevel = model:getChildByName("Text_Level")
	local Image_Level_bg = model:getChildByName("Image_Level_bg")
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	if level == 1 then
		Image_Level_bg:setVisible(false)
		textLevel:setVisible(false)
	end

	textLevel:setString(cp.getConst("CombatConst").NumberZh_Cn[level] .. "階")
	if major_roleAtt.hierarchy < level then
		Image_Level_bg:loadTexture("ui_menpai_skill_module19_menpai_38.png", ccui.TextureResType.plistType)
	else
		Image_Level_bg:loadTexture("ui_menpai_skill_module19_menpai_37.png", ccui.TextureResType.plistType)
	end

	for i, skillEntry in ipairs(skillList) do
		local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
		local iconCfg = {}
		iconCfg.icon = skillEntry:getValue("Icon")
		iconCfg.color = skillEntry:getValue("Colour")
		iconCfg.name = skillEntry:getValue("SkillName")
		iconCfg.level = skillInfo and skillInfo.skill_level or 0
		iconCfg.showPendant = true
		local btn = model:getChildByName("SkillIcon_"..i)
		if not btn then
			btn = require("cp.view.ui.icon.SkillIcon"):create(iconCfg)
			btn:setName("SkillIcon_"..i)
			btn:addTo(model, 100)
			if level == 1 then
				btn:setPosition(124 + (i-1)*146, 83)
			else
				btn:setPosition(222 + (i-1)*146, 83)
			end
		end
		
		if skillInfo then
			btn:reset(iconCfg)
			btn:setIconColor(cc.c4b(255,255,255,255))
			btn:setSkillClicked(function()
				local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry)
				layer:setCloseCallback(function()
					self:updateOneMenPaiSkillView(level, skillList)
				end)
				self:addChild(layer, 100)
			end)
		else
			btn:setIconColor(cc.c4b(127,127,127,255))
			btn:setSkillClicked(function()
				self:onSillItemClicked(skillEntry)
			end)

			if major_roleAtt.hierarchy >= level then
				cp.getManager("ViewManager").addRedDot(btn,cc.p(40,40))
			else
				cp.getManager("ViewManager").removeRedDot(btn)
			end
		end
	end
end

function MenPaiSkillLayer:onSillItemClicked(skillEntry)
	local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry, nil, true)
	self:addChild(layer, 100)
	layer:setCloseCallback(handler(self,self.delayNewGuide))
end

function MenPaiSkillLayer:delayNewGuide()

	local sequence = {}
	table.insert(sequence, cc.DelayTime:create(0.3))
	table.insert(sequence,cc.CallFunc:create(function()
		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		if cur_guide_module_name == "menpai_wuxue" then
			local info = 
			{
				classname = "MenPaiSkillLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
	end))

	self:runAction(cc.Sequence:create(sequence))
end

function MenPaiSkillLayer:updateMenPaiSkillView()
	self.skillList = self:getSortSkillList()
	local skillList = {}
	local level = 1
	for i, skillEntry in ipairs(self.skillList) do
		if  skillEntry:getValue("Colour") <= 2 and level == 1 then
			table.insert(skillList, skillEntry)
		else
			if skillEntry:getValue("Colour") == level + 1 and level ~= 1 then
				table.insert(skillList, skillEntry)
			else
				self:updateOneMenPaiSkillView(level, skillList)
				level = level + 1
				skillList = {}
				table.insert(skillList, skillEntry)
			end
		end
	end
	self:updateOneMenPaiSkillView(level, skillList)
end

function MenPaiSkillLayer:onEnterScene()
	self:delayNewGuide()
end

function MenPaiSkillLayer:onExitScene()
    self:unscheduleUpdate()
end

function MenPaiSkillLayer:getSkillButtonFromListView(level,index)
	local model = self.ListView_Skill:getChildByName("Panel_Model_" .. tostring(level))
	if model then
		return model:getChildByName("SkillIcon_" .. tostring(index))
	end
	return nil
end


return MenPaiSkillLayer