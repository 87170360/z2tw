local BLayer = require "cp.view.ui.base.BLayer"
local SkillSummaryLayer = class("SkillSummaryLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillSummaryLayer:create(openInfo)
    local scene = SkillSummaryLayer.new()
    return scene
end

function SkillSummaryLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").UpdateSkillCombineRsp] = function(data)
			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")  --推動武學的步驟
			if (cur_guide_module_name == "wuxue_pos_change" and (cur_step >= 4 and cur_step <= 5)) then
				self:delayNewGuide()
			end
			
			if cur_guide_module_name == "wuxue" then 
				if data.skill_list and data.skill_list.skill_id_list then
					if (data.skill_list.skill_id_list[1] > 0 and cur_step == 19) or (data.skill_list.skill_id_list[2] > 0 and cur_step == 20) then
						self:delayNewGuide()
					end
				end
			end

			self:updateSkillCombineView()
		end,
		[cp.getConst("EventConst").game_world_to_open_module] = function(data)
			if cp.getConst("SceneConst").MODULE_SkillSummary == data.open_info.name then
				self:setupAchivementGuide()
			end
		end,
		[cp.getConst("EventConst").LearnSkillRsp] = function(data)
			cp.getUtils("NotifyUtils").notifySkillAttr = true
			self:updateSkillListView(true, false)
		end,
		[cp.getConst("EventConst").SkillLevelUpRsp] = function(data)
			cp.getUtils("NotifyUtils").notifySkillAttr = true
			self:updateSkillListView(false, false)
		end,
		[cp.getConst("EventConst").ImproveSkillBoundaryRsp] = function(data)
			cp.getUtils("NotifyUtils").notifySkillAttr = true
			self:updateSkillListView(false, false)
		end,
		--新手指引模擬點擊按鈕
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "SkillSummaryLayer" then
				if evt.guide_name == "wuxue" then
					if "Skill_1" == evt.target_name then
						self:showSkillDetail(self.skillList[1].Entry)
					elseif "Skill_2" == evt.target_name then
						self:showSkillDetail(self.skillList[2].Entry)
					end							
				end
			end
		end,
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "SkillSummaryLayer" then
				-- if evt.guide_name == "wuxue" then
					if evt.target_name == "Skill_1" then
						
						local boundbingBox = self.skillModelList[1]:getBoundingBox()
						local pos = self.skillModelList[1]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info

					elseif evt.target_name == "Skill_2" then
						local boundbingBox = self.skillModelList[2]:getBoundingBox()
						local pos = self.skillModelList[2]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
						
					elseif evt.target_name == "Move_Skill_1" then
						
						local boundbingBox = self.skillModelList[1]:getBoundingBox()
						local pos = self.skillModelList[1]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS1:getBoundingBox()
						local pos2 = self.Button_CS1:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info
					elseif evt.target_name == "Move_Skill_2" then
						local boundbingBox = self.skillModelList[2]:getBoundingBox()
						local pos = self.skillModelList[2]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS2:getBoundingBox()
						local pos2 = self.Button_CS2:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info
					elseif evt.target_name == "Move_Skill_3" then
						local boundbingBox = self.skillModelList[1]:getBoundingBox()
						local pos = self.skillModelList[1]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS3:getBoundingBox()
						local pos2 = self.Button_CS3:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info
					elseif evt.target_name == "Move_Skill_4" then
						local boundbingBox = self.skillModelList[2]:getBoundingBox()
						local pos = self.skillModelList[2]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS4:getBoundingBox()
						local pos2 = self.Button_CS4:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info
					elseif evt.target_name == "Move_Skill_5" then
						local boundbingBox = self.skillModelList[5]:getBoundingBox()
						local pos = self.skillModelList[5]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS5:getBoundingBox()
						local pos2 = self.Button_CS5:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info
					elseif evt.target_name == "Move_Skill_6" then
						local boundbingBox = self.skillModelList[6]:getBoundingBox()
						local pos = self.skillModelList[6]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS6:getBoundingBox()
						local pos2 = self.Button_CS6:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2} }
						evt.ret = finger_info

					elseif evt.target_name == "Change_Pos_1" then
						
						local boundbingBox = self.Button_CS4:getBoundingBox()
						local pos = self.Button_CS4:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS1:getBoundingBox()
						local pos2 = self.Button_CS1:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2}, rect={top=pos2.x-60,bottom=pos2.y-70,width=boundbingBox.width*7+70,height=boundbingBox.height+30} }
						evt.ret = finger_info
					elseif evt.target_name == "Change_Pos_2" then
						
						local boundbingBox = self.Button_CS5:getBoundingBox()
						local pos = self.Button_CS5:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						boundbingBox = self.Button_CS2:getBoundingBox()
						local pos2 = self.Button_CS2:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "move", moveto = pos2},rect={top=pos2.x-60,bottom=pos2.y-70,width=boundbingBox.width*7+70 ,height=boundbingBox.height+30} }
						evt.ret = finger_info
					end
				-- end
			end
		end
    }
end

--初始化界面，以及設定界面元素標籤
function SkillSummaryLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_summary.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.selectType = {1,2,3,4,5,6,7,8}
	self.dragSkill = nil
	self.draging = false
	self.deltaX = 44
	self.originDeltaY = 70
	self.skillSize = 100
	self.maxCol = 4
	self.skillModelList = {}
	self.combineID = cp.getUserData("UserSkill"):getValue("SkillData").equip_combine + 1
	self.page = 1
	self.beginX = 72
	self.orderType = 0
	self.typeTexture = {
		[0] = "ui_skill_module14_wuxue_fenleikuang",
		[1] = "ui_skill_module14_wuxue_neigong",
		[2] = "ui_skill_module14_wuxue_jianxi",
		[3] = "ui_skill_module14_wuxue_daoxi",
		[4] = "ui_skill_module14_wuxue_quanzhang",
		[5] = "ui_skill_module14_wuxue_qimen",
		[6] = "ui_skill_module14_wuxue_shenfa",
		[7] = "ui_skill_module14_wuxue_gunxi",
		[8] = "ui_skill_module14_wuxue_zaxue",
	}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_DragSkill"] = {name = "Image_DragSkill"},
		["Panel_root.Image_1.Panel_Skill.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.Panel_Skill"] = {name = "Panel_Skill"},
		["Panel_root.Image_1.Button_PrevPage"] = {name = "Button_PrevPage", click="onBtnClick"},
		["Panel_root.Image_1.Button_NextPage"] = {name = "Button_NextPage", click="onBtnClick"},
		["Panel_root.Image_1.Text_Page"] = {name = "Text_Page"},
		["Panel_root.Image_2.Text_Number"] = {name = "Text_Number"},
		["Panel_root.Image_2.Button_Prev"] = {name = "Button_Prev", click="onBtnClick"},
		["Panel_root.Image_2.Button_Next"] = {name = "Button_Next", click="onBtnClick"},
		["Panel_root.Image_2.Button_Defend"] = {name = "Button_Defend", click="onBtnClick"},
		["Panel_root.Image_2.Button_AllSkill"] = {name = "Button_AllSkill", click="onBtnClick"},
		["Panel_root.Image_2.Button_CS1"] = {name = "Button_CS1",clickScale=1},
		["Panel_root.Image_2.Button_CS2"] = {name = "Button_CS2",clickScale=1},
		["Panel_root.Image_2.Button_CS3"] = {name = "Button_CS3",clickScale=1},
		["Panel_root.Image_2.Button_CS4"] = {name = "Button_CS4",clickScale=1},
		["Panel_root.Image_2.Button_CS5"] = {name = "Button_CS5",clickScale=1},
		["Panel_root.Image_2.Button_CS6"] = {name = "Button_CS6",clickScale=1},
		["Panel_root.Button_OrderLevel"] = {name = "Button_OrderLevel",click="onBtnClick", clickScale=1},
		["Panel_root.Button_OrderPower"] = {name = "Button_OrderPower",click="onBtnClick", clickScale=1},
		["Panel_root.Button_OrderAll"] = {name = "Button_OrderAll",click="onBtnClick", clickScale=1},
		["Panel_root.Button_1"] = {name = "Button_1"},
		["Panel_root.Button_2"] = {name = "Button_2"},
		["Panel_root.Button_3"] = {name = "Button_3"},
		["Panel_root.Button_4"] = {name = "Button_4"},
		["Panel_root.Button_5"] = {name = "Button_5"},
		["Panel_root.Button_6"] = {name = "Button_6"},
		["Panel_root.Button_7"] = {name = "Button_7"},
		["Panel_root.Button_8"] = {name = "Button_8"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)

	cp.getManager("ViewManager").setWidgetAdapt(1280, {
		self.Image_1, self.Panel_Skill, self.Image_bg
	})
	ccui.Helper:doLayout(self.rootView)

	local panelHeight = self.Panel_Skill:getSize().height
	self.beginY = panelHeight - (self.skillSize+self.originDeltaY)/2
	self.maxRow = math.floor(panelHeight / (self.skillSize+self.originDeltaY))
	self.deltaY = self.originDeltaY + (panelHeight-self.maxRow*(self.skillSize+self.originDeltaY))/(self.maxRow)
	for i=1, 8 do
		local btn = self["Button_"..i]
		btn:ignoreContentAdaptWithSize(true)
		cp.getManager("ViewManager").initButton(btn, function()
			local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
			local skillType = tonumber(extensionData:getCustomProperty())
			self.selectType = {skillType}

			self.page = 1
			self:updateSkillListView(true, true)
		end, 1)
	end

	for i=1, self.maxRow do
		for j=1, self.maxCol do
			local img = self.Image_Model:clone()
			local posX = (self.skillSize+self.deltaX)*(j-1)+self.beginX
			local posY = self.beginY-(self.skillSize+self.deltaY)*(i-1)
			img:setPosition(cc.p(posX, posY))
			self.Panel_Skill:addChild(img)
			img:setVisible(false)
			local Panel_Model = img:getChildByName("Panel_Model")
			local Image_Icon = Panel_Model:getChildByName("Image_Icon")
			table.insert(self.skillModelList, img)
		end
	end

	for i=1, 6 do
		local btn = self["Button_CS"..i]
		btn:onTouch(function(event)
			if event.name == "ended" then
				local distance = cc.pGetDistance(cc.p(event.x, event.y),self.touchBeganPos)
				if distance < 40 and not self.draging then
					local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
					local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step") --推動武學的步驟
					if (cur_guide_module_name == "wuxue" and (cur_step == 19 or cur_step == 20)) or
						(cur_guide_module_name == "wuxue_use" and (cur_step >= 4 and cur_step <= 7)) or
						(cur_guide_module_name == "wuxue_pos_change" and (cur_step >= 4 and cur_step <= 5))  then
						
						self.Image_DragSkill:setVisible(false)
						self.draging = false
						self.dragSkill = nil
						return
					end

					local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", self.dragSkill)
					if skillEntry then
						self:showSkillDetail(skillEntry)
					end
				end
				self.Image_DragSkill:setVisible(false)
				self.draging = false
				self.dragSkill = nil
				self.touchBeganPos = nil
			elseif event.name == "cancelled" then
				if self.dragSkill and self.draging then
					local idx = self:dragSkillToPos(i, self.dragSkill, event.x, event.y)
					local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
				end
	
				self.Image_DragSkill:setVisible(false)
				self.dragSkill = nil
				self.draging = false
				self.touchBeganPos = nil
				self:updateSkillCombineView()
			elseif event.name == "began" then
				self.touchBeganPos = cc.p(event.x,event.y)
				self.dragSkill = cp.getUserData("UserSkill"):getSkillCombine(self.combineID, i)
				if self.dragSkill then
					btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
						if not self.draging then
							local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", self.dragSkill)
							if skillEntry then
								self.draging = true
								self.Image_DragSkill:loadTexture(skillEntry:getValue("Icon"))
								local icon = self.Image_DragSkill:getChildByName("Image_Icon")
								icon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
								self.Image_DragSkill:setVisible(true)
								self.Image_DragSkill:setPosition(cc.p(event.x, event.y))
							end
						end
					end)))
				end
			elseif event.name == "moved" then
				local distance = cc.pGetDistance(cc.p(event.x, event.y),self.touchBeganPos)
				if distance > 40 and not self.draging then
					local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", self.dragSkill)
					if skillEntry then
						self.draging = true
						self.Image_DragSkill:loadTexture(skillEntry:getValue("Icon"))
						local icon = self.Image_DragSkill:getChildByName("Image_Icon")
						icon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
						self.Image_DragSkill:setVisible(true)
					end
				end

				if self.draging then
					self.Image_DragSkill:setPosition(cc.p(event.x, event.y))
				end
			end
		end)
	end

	self:setTouchEnabled(true)

    self.Panel_Skill:onTouch(function(event)
		if event.name == "ended" then
			local distance = cc.pGetDistance(cc.p(event.x, event.y),self.touchBeganPos)
			if distance < 40 and not self.draging then
				local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
				local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
				if (cur_guide_module_name == "wuxue" and (cur_step == 19 or cur_step == 20)) or
					(cur_guide_module_name == "wuxue_use" and (cur_step >= 4 and cur_step <= 7))  then
					return
				end
				
				local touchSkill = self:getSkillByPos(event.x, event.y)
				if touchSkill then
					self:showSkillDetail(self.skillList[touchSkill].Entry)
				end
			end
			
			self.Image_DragSkill:setVisible(false)
			self.draging = false
			self.dragSkill = nil
			self.touchBeganPos = nil
			self.Panel_Skill:stopAllActions()
		elseif event.name == "cancelled" then
			if self.dragSkill then
				self:dragSkillToPos(nil, self.skillList[self.dragSkill].Entry:getValue("SkillID"), event.x, event.y)

				--進行下一步
				local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
				local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
				if (cur_guide_module_name == "wuxue_use" and (cur_step >= 4 and cur_step <= 7))  then
					local info = 
					{
						classname = "SkillDetailLearnLayer",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end

			end

			self.Image_DragSkill:setVisible(false)
			self.dragSkill = nil
			self.draging = false
			self.touchBeganPos = nil
			self.Panel_Skill:stopAllActions()
		elseif event.name == "began" then
			self.touchBeganPos = cc.p(event.x,event.y)
			self.Panel_Skill:stopAllActions()

			self.dragSkill = self:getSkillByPos(event.x, event.y)
			if self.dragSkill and self.dragSkill <= #self.skillList then
				local skillInfo = self.skillList[self.dragSkill]
				if self.dragSkill and skillInfo then
					self.Panel_Skill:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
						if not self.draging then
							self.draging = true
							local skillEntry = skillInfo.Entry
							self.Image_DragSkill:loadTexture(skillEntry:getValue("Icon"))
							local icon = self.Image_DragSkill:getChildByName("Image_Icon")
							icon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
							self.Image_DragSkill:setVisible(true)
							if self.touchBeganPos then
								self.Image_DragSkill:setPosition(self.touchBeganPos)
							end
						end
					end)))
				end
			end
		elseif event.name == "moved" then
			local distance = cc.pGetDistance(cc.p(event.x, event.y),self.touchBeganPos)
			if distance > 40 and not self.draging then
				local skillEntry = self.skillList[self.dragSkill].Entry
				if skillEntry then
					self.draging = true
					self.Image_DragSkill:loadTexture(skillEntry:getValue("Icon"))
					local icon = self.Image_DragSkill:getChildByName("Image_Icon")
					icon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
					self.Image_DragSkill:setVisible(true)
					self.Panel_Skill:stopAllActions()
				end
			end

			if self.draging then
				self.Image_DragSkill:setPosition(cc.p(event.x, event.y))
			end
		end
	end)
end

function SkillSummaryLayer:setupAchivementGuide()
	local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
    if guideType == 36 then
        guideBtn = self.skillModelList[1]
    else
        return
    end

    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function SkillSummaryLayer:unloadSeriseSkill(skillList, serise)
	local num = 0
	if not skillList then
		return 0
	end

	for i, skillID in pairs(skillList) do
		local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
		if skillEntry and skillEntry:getValue("Serise") == serise then
			skillList[i] = 0
			num = num + 1
		end
	end

	return num
end

function SkillSummaryLayer:dragSkillToPos(srcIdx, dragSkill, posX, posY)
	local beginX = 20 
	local beginY = 157
	local idx = math.ceil((posX-beginX)/117)

	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
	if not skillData then
		return
	end
	if not skillData.skill_combine_list then
		skillData.skill_combine_list = {}
	end

	if not skillData.skill_combine_list[self.combineID] then
		skillData.skill_combine_list[self.combineID] = {}
	end

	if not skillData.skill_combine_list[self.combineID].skill_id_list then
		skillData.skill_combine_list[self.combineID].skill_id_list = {0,0,0,0,0,0}
	end

	local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", dragSkill)
	local combineList = skillData.skill_combine_list[self.combineID].skill_id_list
	for i, skillID in pairs(combineList) do
		if skillID == dragSkill then
			combineList[i] = 0
		end
	end

	if posY < 157 or posY > 278 then
		if srcIdx then
			combineList[srcIdx] = 0
		end
		
		local req = {}
		req.combine_id = skillData.equip_combine
		req.skill_list = skillData.skill_combine_list[self.combineID]
		req.type = 0
		self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
		return
	end
	
	if skillEntry:getValue("Serise") == CombatConst.SkillSerise_Force then
		if self:unloadSeriseSkill(combineList, CombatConst.SkillSerise_Force) > 0 then
            cp.getManager("ViewManager").gameTip("內功最多隻能上陣1個")
		end
	elseif skillEntry:getValue("Serise") == CombatConst.SkillSerise_Body then
		if self:unloadSeriseSkill(combineList, CombatConst.SkillSerise_Body) > 0 then
            cp.getManager("ViewManager").gameTip("身法最多隻能上陣1個")
		end
	elseif	skillEntry:getValue("Serise") == CombatConst.SkillSerise_Unorthodox then
		if self:unloadSeriseSkill(combineList, CombatConst.SkillSerise_Unorthodox) > 0 then
            cp.getManager("ViewManager").gameTip("雜學最多隻能上陣1個")
		end
	end

	local repSkillID = combineList[idx]
	combineList[idx] = dragSkill
	if srcIdx then
		combineList[srcIdx] = 0
		combineList[srcIdx] = repSkillID
	end

    local req = {}
    req.combine_id = skillData.equip_combine
    req.skill_list = skillData.skill_combine_list[self.combineID]
    req.type = 0
	self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
end

function SkillSummaryLayer:getSkillByPos(posX, posY)
	local pos = self.Panel_Skill:convertToWorldSpace(cc.p(0,0))
	local height = self.Panel_Skill:getSize().height
	posY = height-(posY-pos.y)
	posX = posX-pos.x

	log("PosX="..posX..",PosY="..posY)
	local row = math.ceil(posY/(self.deltaY+self.skillSize))
	local col = math.ceil(posX/(self.deltaX+self.skillSize))

	local aPosX = (self.skillSize+self.deltaX)*(col-1)
	local aPosY = (self.skillSize + self.deltaY)*(row-1)

	log("row="..row..",col="..col)
	--if posX - aPosX <= self.deltaX+self.skillSize and posY - aPosY <= self.originDeltaY then
		return (row-1)*self.maxCol+col+self.maxRow*self.maxCol*(self.page-1)
	--end

	--return nil
end

function SkillSummaryLayer:updateOneSkillView(skillEntry, img)
	if not img then
		img = self.Panel_Skill:getChildByName(skillEntry:getValue("SkillID"))
	end

	if not img then
		return
	end

	local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
	local model = img:getChildByName("Panel_Model")
	cp.getManager("ViewManager").initSkillNode(model, skillEntry,skillInfo.skill_level)

	local btnBox = model:getChildByName("Button_Box")
	btnBox:setTouchEnabled(false)

	local TopSkillEffect = btnBox:getChildByName("TopSkillEffect")
	if skillInfo.boundary == 10 then
		if not TopSkillEffect then
			TopSkillEffect = cc.Sprite:create()
			TopSkillEffect:setName("TopSkillEffect")
			btnBox:addChild(TopSkillEffect)
            TopSkillEffect:setPosition(cc.p(50,50))
            TopSkillEffect:setScale(cp.getConst("GameConst").EffectScale)
        end
        TopSkillEffect:stopAllActions()
        local animation = cp.getManager("ViewManager").createEffectAnimation("SkillSpecial", 0.045, 1000000)
        TopSkillEffect:runAction(cc.Animate:create(animation))
        TopSkillEffect:setVisible(true)
    elseif TopSkillEffect then
		TopSkillEffect:setVisible(false)
	end

	if cp.getUtils("NotifyUtils").needNotifySkill(skillInfo, skillEntry) then
	    cp.getManager("ViewManager").addRedDot(btnBox,cc.p(90,90))
	else
		cp.getManager("ViewManager").removeRedDot(btnBox)
	end

	self:updateSkillCombineView()
end

function SkillSummaryLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Prev" then
		if self.combineID == 1 then
			self.combineID = 5
		else
			self.combineID = self.combineID-1
		end
		local req = {}
		req.type = 1
		req.combine_id = self.combineID - 1
		self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
	elseif nodeName == "Button_Next" then
		if self.combineID == 5 then
			self.combineID = 1
		else
			self.combineID = self.combineID+1
		end
		local req = {}
		req.type = 1
		req.combine_id = self.combineID - 1
		self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
		self:updateSkillCombineView()
	elseif nodeName == "Button_PrevPage" then
		if self.maxPage == 0 then return end
		if self.page == 1 then
			self.page = self.maxPage
		else
			self.page = self.page-1
		end
		self:updateSkillListView(false, false)
	elseif nodeName == "Button_NextPage" then
		if self.maxPage == 0 then return end
		if self.page == self.maxPage then
			self.page = 1
		else
			self.page = self.page+1
		end
		self:updateSkillListView(false, false)
	elseif nodeName == "Button_OrderAll" then
		--if self.orderType == 0 then return end
		self.orderType = 0
		self.selectType = {1,2,3,4,5,6,7,8}
		self:updateSkillListView(true, true)
	elseif nodeName == "Button_OrderLevel" then
		--if self.orderType == 1 then return end
		self.orderType = 1
		self:updateSkillListView(false, true)
	elseif nodeName == "Button_OrderPower" then
		--if self.orderType == 2 then return end
		self.orderType = 2
		self:updateSkillListView(false, true)
	elseif nodeName == "Button_AllSkill" then
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillRecommend}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
	elseif nodeName == "Button_Defend" then
		local layer = require("cp.view.scene.skill.SkillUseLayer"):create(self.combineID-1)
		self:addChild(layer, 100)
	end
end

function SkillSummaryLayer:hasCombine(skillEntry)
	local unitEntry = cp.getManager("ConfigManager").getItemByKey("SkillUnits", skillEntry:getValue("SkillID"))
	if not unitEntry then
		return false
	end

	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
	if not skillData or not skillData.skill_combine_list
		or not skillData.skill_combine_list[self.combineID] 
		or not skillData.skill_combine_list[self.combineID].skill_id_list then
		return false
	end

	local skillIDList = skillData.skill_combine_list[self.combineID].skill_id_list
	local skillList = string.split(unitEntry:getValue("NeedSkills"), ";")
	for _, skillID in ipairs(skillList) do
		if not table.indexof(skillIDList, tonumber(skillID)) then
			return false
		end
	end

	return true
end

function SkillSummaryLayer:updateSkillCombineView()
	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
	self.Text_Number:setString("武學組合  "..CombatConst.NumberZh_Cn[self.combineID])
	for i=1, 6 do
		local btn = self["Button_CS"..i]
		local imgIcon = btn:getChildByName("Image_Icon")
		--local imgMask = btn:getChildByName("Image_Mask")
		local textName = btn:getChildByName("Text_Name")
		local textLevel = btn:getChildByName("Text_Level")
		local SkillCombineEffect = imgIcon:getChildByName("SkillCombineEffect")
		local TopSkillEffect = imgIcon:getChildByName("TopSkillEffect")

		if not skillData or not skillData.skill_combine_list
			or not skillData.skill_combine_list[self.combineID] 
			or not skillData.skill_combine_list[self.combineID].skill_id_list
			or not skillData.skill_combine_list[self.combineID].skill_id_list[i]
			or skillData.skill_combine_list[self.combineID].skill_id_list[i] == 0 then
			imgIcon:setVisible(false)
			--imgMask:setVisible(false)
			textName:setVisible(false)
			textLevel:setVisible(false)
			local textureName = CombatConst.SkillBoxList[1]
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		else
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillData.skill_combine_list[self.combineID].skill_id_list[i])
			local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
			local textureName = CombatConst.SkillBoxList[skillEntry:getValue("Colour")]
			btn:loadTextures(skillEntry:getValue("Icon"), skillEntry:getValue("Icon"), skillEntry:getValue("Icon"))
			textName:setString(skillEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(textName, skillEntry:getValue("Colour"))
			textLevel:setString("LV."..skillInfo.skill_level)
			imgIcon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
			imgIcon:setVisible(true)
			--imgMask:setVisible(true)
			textName:setVisible(true)
			textLevel:setVisible(true)

			if skillInfo.boundary == 10 then
				if not TopSkillEffect then
					TopSkillEffect = cc.Sprite:create()
					TopSkillEffect:setName("TopSkillEffect")
					imgIcon:addChild(TopSkillEffect)
                    TopSkillEffect:setPosition(cc.p(49,51))
                    TopSkillEffect:setScale(cp.getConst("GameConst").EffectScale)
                end
                TopSkillEffect:stopAllActions()
                local animation = cp.getManager("ViewManager").createEffectAnimation("SkillSpecial", 0.045, 1000000)
                TopSkillEffect:runAction(cc.Animate:create(animation))
                TopSkillEffect:setVisible(true)
			elseif TopSkillEffect then
				TopSkillEffect:setVisible(false)
			end

			if self:hasCombine(skillEntry) then
				if not SkillCombineEffect then
					SkillCombineEffect = cc.Sprite:create()
					SkillCombineEffect:setName("SkillCombineEffect")
					imgIcon:addChild(SkillCombineEffect)
                    SkillCombineEffect:setPosition(cc.p(49,51))
                    SkillCombineEffect:setScale(cp.getConst("GameConst").EffectScale)
                end
                SkillCombineEffect:stopAllActions()
                local animation = cp.getManager("ViewManager").createEffectAnimation("SkillCombine", 0.045, 1000000)
                SkillCombineEffect:runAction(cc.Animate:create(animation))
                SkillCombineEffect:setVisible(true)
			elseif SkillCombineEffect then
				SkillCombineEffect:setVisible(false)
			end
		end
	end
end

local nTexture = "ui_skill_module14_wuxue_4.png"
local sTexture = "ui_skill_module14_wuxue_3.png"
local nColor = cc.c4b(220,184,169,255)
local sColor = cc.c4b(80,44,8,255)

function SkillSummaryLayer:updateSkillListView(list, order)
	for i=1, 8 do
		local btn = self["Button_"..i]
		local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
		local skillType = tonumber(extensionData:getCustomProperty())
		if table.indexof(self.selectType, skillType) then
			local textureName = "ui_common_module_bangpai_5.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		else
			local textureName = "ui_common_module_bangpai_4.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		end
	end

	--是否全部刷新
	if list then
		self.skillList = {}
		local learnSkillList = cp.getUserData("UserSkill"):getValue("SkillData").skill_list.skill_list
		for i, skillInfo in ipairs(learnSkillList) do
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillInfo.skill_id)
			if table.indexof(self.selectType, skillEntry:getValue("Serise")) and skillEntry:getValue("SkillType") == 1 then
				skillInfo.Entry = skillEntry
				table.insert(self.skillList, skillInfo)
			end
		end
	end

	if order then
		--等級排序
		if self.orderType == 1 then
			cp.getUtils("DataUtils").quick_sort(self.skillList, function(skillInfoA, skillInfoB)
				if skillInfoA.skill_level > skillInfoB.skill_level then
					return true
				elseif skillInfoA.skill_level < skillInfoB.skill_level then
					return false
				else
					if skillInfoA.Entry:getValue("Colour") > skillInfoB.Entry:getValue("Colour") then
						return true
					elseif skillInfoA.Entry:getValue("Colour") < skillInfoB.Entry:getValue("Colour") then
						return false
					else
						return skillInfoA.Entry:getValue("SkillID") <= skillInfoB.Entry:getValue("SkillID")
					end
				end
			end)
			self.Button_OrderAll:loadTextures(nTexture, nTexture, nTexture, ccui.TextureResType.plistType)
			self.Button_OrderPower:loadTextures(nTexture, nTexture, nTexture, ccui.TextureResType.plistType)
			self.Button_OrderLevel:loadTextures(sTexture, sTexture, sTexture, ccui.TextureResType.plistType)
			self.Button_OrderAll:getChildByName("Text"):setTextColor(nColor)
			self.Button_OrderPower:getChildByName("Text"):setTextColor(nColor)
			self.Button_OrderLevel:getChildByName("Text"):setTextColor(sColor)
		--威力排序
		elseif self.orderType == 2 then
			cp.getUtils("DataUtils").quick_sort(self.skillList, function(skillInfoA, skillInfoB)
				local powerA, powerB = 0, 0
				if skillInfoA.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
					skillInfoA.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
					skillInfoA.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
					powerA = cp.getUtils("DataUtils").GetSkillPower(skillInfoA.Entry:getValue("Colour"), skillInfoA.skill_level, skillInfoA.boundary)
				end

				if skillInfoB.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
					skillInfoB.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
					skillInfoB.Entry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
					powerB = cp.getUtils("DataUtils").GetSkillPower(skillInfoB.Entry:getValue("Colour"), skillInfoB.skill_level, skillInfoB.boundary)
				end

				if powerA > powerB then
					return true
				elseif powerA < powerB then
					return false
				else
				    if skillInfoA.Entry:getValue("Colour") > skillInfoB.Entry:getValue("Colour") then
						return true
					elseif skillInfoA.Entry:getValue("Colour") < skillInfoB.Entry:getValue("Colour") then
						return false
					else
						return skillInfoA.Entry:getValue("SkillID") <= skillInfoB.Entry:getValue("SkillID")
					end
				end
			end)
			self.Button_OrderAll:loadTextures(nTexture, nTexture, nTexture, ccui.TextureResType.plistType)
			self.Button_OrderPower:loadTextures(sTexture, sTexture, sTexture, ccui.TextureResType.plistType)
			self.Button_OrderLevel:loadTextures(nTexture, nTexture, nTexture, ccui.TextureResType.plistType)
			self.Button_OrderAll:getChildByName("Text"):setTextColor(nColor)
			self.Button_OrderPower:getChildByName("Text"):setTextColor(sColor)
			self.Button_OrderLevel:getChildByName("Text"):setTextColor(nColor)
		else
			cp.getUtils("DataUtils").quick_sort(self.skillList, function(skillInfoA, skillInfoB)
				if skillInfoA.Entry:getValue("Colour") > skillInfoB.Entry:getValue("Colour") then
					return true
				elseif skillInfoA.Entry:getValue("Colour") < skillInfoB.Entry:getValue("Colour") then
					return false
				else
					if skillInfoA.skill_level > skillInfoB.skill_level then
						return true
					elseif skillInfoA.skill_level < skillInfoB.skill_level then
						return false
					else
						return skillInfoA.Entry:getValue("SkillID") <= skillInfoB.Entry:getValue("SkillID")
					end
				end
			end)
			if self.orderType == 0 then
				self.Button_OrderAll:loadTextures(sTexture, sTexture, sTexture, ccui.TextureResType.plistType)
				self.Button_OrderPower:loadTextures(nTexture, nTexture, nTexture, ccui.TextureResType.plistType)
				self.Button_OrderLevel:loadTextures(nTexture, nTexture, sTexture, ccui.TextureResType.plistType)
				self.Button_OrderAll:getChildByName("Text"):setTextColor(sColor)
				self.Button_OrderPower:getChildByName("Text"):setTextColor(nColor)
				self.Button_OrderLevel:getChildByName("Text"):setTextColor(nColor)
			end
		end

		self.maxPage = math.ceil(#self.skillList/(self.maxRow*self.maxCol))
		if self.maxPage == 0 then self.maxPage = 1 end
	end

	self.Text_Page:setString(string.format("%d/%d", self.page, self.maxPage))
	for i=(self.page-1)*self.maxRow*self.maxCol+1, self.page*self.maxRow*self.maxCol do
		local index = (i-1)%(self.maxRow*self.maxCol)+1
		local model = self.skillModelList[index]
		local skillInfo = self.skillList[i]
		if not skillInfo then
			model:setVisible(false)
		else
			model:setVisible(true)
			model:setName(skillInfo.Entry:getValue("SkillID"))
			self:updateOneSkillView(skillInfo.Entry, model)
		end
	end

	self:setupAchivementGuide()
	self:updateSkillCombineView()
end

function SkillSummaryLayer:showSkillDetail(skillEntry)
	if not skillEntry then
		return
	end
	local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
	if skillInfo then
		local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry, self.combineID)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			--點擊關閉後，進行下一步
			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			if cur_guide_module_name == "wuxue" then
				local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
				if cur_step == 11 or cur_step == 17 then
					local info = 
					{
						classname = "SkillDetailLearnLayer",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end
			end
		end)
	else
		local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateOneSkillView(skillEntry)
		end)
		log("PosX=", layer:getPositionX()..",PosY="..layer:getPositionY())
	end
end

function SkillSummaryLayer:onEnterScene()
	display.loadSpriteFrames("uiplist/ui_common.plist")
	cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_main,true)
	
	self:updateSkillListView(true, true)
	self:updateSkillCombineView()

	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "wuxue_pos_change" then
		local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "wuxue_pos_change" then
			if step == 5 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",4)
            end
        end
	end
	self:delayNewGuide()

end

function SkillSummaryLayer:delayNewGuide()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "wuxue" or cur_guide_module_name == "wuxue_use"  or cur_guide_module_name == "wuxue_pos_change" then
		local needSend = true
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		--修正指引步驟

		if needSend then
			local sequence = {}
			table.insert(sequence, cc.DelayTime:create(0.3))
			table.insert(sequence,cc.CallFunc:create(function()
				
				local info = 
				{
					classname = "SkillSummaryLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end))
			self:runAction(cc.Sequence:create(sequence))
		end
    end
end

function SkillSummaryLayer:onExitScene()
    self:unscheduleUpdate()
end

function SkillSummaryLayer:onSkillItemClicked()
	cp.getManager("ViewManager").gameTip("Panel_Skill:onTouch began 444 ")
	if self.dragSkill then
		self.draging = true
		cp.getManager("ViewManager").gameTip("Panel_Skill:onTouch began 555")
		local skillEntry = self.skillList[self.dragSkill].Entry
		self.Image_DragSkill:loadTexture(skillEntry:getValue("Icon"))
		local icon = self.Image_DragSkill:getChildByName("Image_Icon")
		icon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
		self.Image_DragSkill:setVisible(true)
		if self.touchBeganPos then
			self.Image_DragSkill:setPosition(self.touchBeganPos)
		end
	else
		-- dump(self.dragSkill)
	end
	
end

return SkillSummaryLayer
