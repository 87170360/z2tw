local BLayer = require "cp.view.ui.base.BLayer"
local SkillDetailLearnLayer = class("SkillDetailLearnLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function SkillDetailLearnLayer:create(skillEntry, combineID)
	local scene = SkillDetailLearnLayer.new(skillEntry)
	scene.skillEntry = skillEntry
	scene.combineID = combineID
    return scene
end

function SkillDetailLearnLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		[cp.getConst("EventConst").ItemUpdateRsp] = function(data)
			self:updateBreakoutItem()
		end,
		[cp.getConst("EventConst").SkillBreakOutRsp] = function(data)
			self:updateSkillDetailView()
			self:showLearnNewArt()
		end,
		[cp.getConst("EventConst").UseSkillArtRsp] = function(data)
			self:updateSkillDetailView()
		end,
		[cp.getConst("EventConst").ArtLevelUpRsp] = function(data)
			self:updateEquipArtView(data.skill_info)
		end,
		[cp.getConst("EventConst").FragMergeRsp] = function(data)
			self:updateSkillDetailView()
		end,
		[cp.getConst("EventConst").SkillLevelUpRsp] = function(data)
			self:updateSkillDetailView()
			self.Image_Skill:getChildByName("SkillLight"):setAnimation(0, "jingjie", false)
			--升級後再發一次，觸摸下一步
			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			if cur_guide_module_name == "wuxue" then
				local info = 
				{
					classname = "SkillDetailLearnLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end

		end,

		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "SkillDetailLearnLayer" then
				if evt.guide_name == "wuxue" then
					self:onBtnClick(self[evt.target_name])
				end
			end
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "SkillDetailLearnLayer" then
				if evt.guide_name == "wuxue" then
						
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				
				end
			end
		end
    }
end

function SkillDetailLearnLayer:showLearnNewArt()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	local artID = cp.getUtils("DataUtils").split(self.skillEntry:getValue("Arts"), ";")[math.floor(skillInfo.skill_level/20)]
	if not artID or artID == 0 then return end
	local artEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", artID)
	if not artEntry then return end

	local iconList = {
		{
			Colour = self.skillEntry:getValue("Colour"),
			Name = artEntry:getValue("SkillName"),
			Icon = artEntry:getValue("Icon"),
		}
	}
	local layer = require("cp.view.ui.messagebox.ShowIconListView"):create(iconList, "img/bg/bg_common/jiesuozhaoshi.png", "查  看", function()
		local layer = require("cp.view.scene.skill.SkillArtLayer"):create(self.skillEntry, math.floor(skillInfo.skill_level/20))
		self:addChild(layer, 100)
	end)
	self:addChild(layer, 100)
end

--初始化界面，以及設定界面元素標籤
function SkillDetailLearnLayer:onInitView(skillEntry)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_detail_learn.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Break"] = {name = "Button_Break", click="onBtnClick"},
		["Panel_root.Image_1.Image_Skill"] = {name = "Image_Skill"},
		["Panel_root.Image_1.Image_SkillType"] = {name = "Image_SkillType"},
		["Panel_root.Image_1.Text_SkillType"] = {name = "Text_SkillType"},
		["Panel_root.Image_1.Text_SkillName"] = {name = "Text_SkillName"},
		["Panel_root.Image_1.Text_Power"] = {name = "Text_Power"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Text_Boundary"] = {name = "Text_Boundary"},
		["Panel_root.Image_1.Image_Attr.Text_Attr1"] = {name = "Text_Attr1"},
		["Panel_root.Image_1.Image_Attr.Text_Attr2"] = {name = "Text_Attr2"},
		["Panel_root.Image_1.Image_Attr.Button_Attr"] = {name = "Button_Attr", click="onBtnClick"},
		["Panel_root.Image_1.Image_Art"] = {name = "Image_Art"},
		["Panel_root.Image_1.Image_Art.Button_SkillArts"] = {name = "Button_SkillArts", click="onBtnClick"},
		["Panel_root.Image_1.Image_EffectList"] = {name = "Image_EffectList"},
		["Panel_root.Image_1.ListView_Effect"] = {name = "ListView_Effect"},
		["Panel_root.Image_1.Panel_Effect"] = {name = "Panel_Effect"},
		["Panel_root.Image_1.ListView_Effect.Panel_Break"] = {name = "Panel_Break"},
		["Panel_root.Image_1.ListView_Effect.Panel_Break.Text_BreakLevel"] = {name = "Text_BreakLevel"},
		["Panel_root.Image_1.ListView_Effect.Panel_Break.Text_SkillLevel"] = {name = "Text_SkillLevel"},
		["Panel_root.Image_1.ListView_Effect.Panel_Break.Text_NeedLevel"] = {name = "Text_NeedLevel"},
		["Panel_root.Image_1.Text_NeedTrainPoint"] = {name = "Text_NeedTrainPoint"},
		["Panel_root.Image_1.Text_TotalTrainPoint"] = {name = "Text_TotalTrainPoint"},
		["Panel_root.Image_1.Button_SkillLevelUp1"] = {name = "Button_SkillLevelUp1", click="onBtnClick"},
		["Panel_root.Image_1.Button_SkillLevelUp2"] = {name = "Button_SkillLevelUp2", click="onBtnClick"},
		["Panel_root.Image_1.Button_ResetSkill"] = {name = "Button_ResetSkill", click="onBtnClick"},
		["Panel_root.Image_1.Button_Boundary"] = {name = "Button_Boundary", click="onBtnClick"},
		["Panel_root.Image_1.Button_AddTrainPoint"] = {name = "Button_AddTrainPoint", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    self.ListView_Effect:setScrollBarEnabled(false)

	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.ListView_Effect, self.Image_EffectList, self.Image_bg})
	ccui.Helper:doLayout(self.rootView)
end

function SkillDetailLearnLayer:setupAchivementGuide(btnGuide)
	local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
	if guideType == 36 then
		if not btnGuide then
			btnGuide = self.Button_Break
		end
		cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end

    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, btnGuide, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

-- 直接關閉，使用，出售，傳承，強化，熔鍊，分解,合成
function SkillDetailLearnLayer:onItemTipClosedCallBack(closeType,itemInfo,skillEntry)

	log("onItemTipClosedCallBack closeType=" .. closeType)


	if closeType == "Button_use" then
		self:onUseItem(itemInfo)
	elseif closeType == "Button_chushou" then
		self:onSellItem(itemInfo)
	elseif closeType == "Button_qianghua" then
		self:onOperateItem(1,itemInfo)
	elseif closeType == "Button_chuancheng" then
		self:onOperateItem(2,itemInfo)
	elseif closeType == "Button_ronglian" then
		self:onOperateItem(3,itemInfo)
	elseif closeType == "Button_fenjie" then
		self:onFenJie(itemInfo)

	elseif closeType == "Button_hecheng" then
		self:doSendSocket(cp.getConst("ProtoConst").FragMergeReq,{uuid = itemInfo.uuid})
		cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_item_hecheng)
	elseif closeType == "Button_study" then
		self:onSkillItem(itemInfo)
	elseif closeType == "Button_xiulian" then
		--打開境界提升界面
		local SkillBoundaryLayer = require("cp.view.scene.skill.SkillBoundaryLayer"):create(skillEntry)
		self:addChild(SkillBoundaryLayer, 100)
	elseif closeType == "Button_close" then
		--不做任何處理
	end
end

function SkillDetailLearnLayer:checkNeedNotify()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	if cp.getUtils("NotifyUtils").needNotifySkillUpgrade(skillInfo, self.skillEntry) then
		cp.getManager("ViewManager").addRedDot(self.Button_SkillLevelUp1, cc.p(137,54))
		cp.getManager("ViewManager").addRedDot(self.Button_SkillLevelUp2, cc.p(137,54))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_SkillLevelUp1)
		cp.getManager("ViewManager").removeRedDot(self.Button_SkillLevelUp2)
	end

	if cp.getUtils("NotifyUtils").needNotifySkillBreak(skillInfo, self.skillEntry) then
		cp.getManager("ViewManager").addRedDot(self.Button_Break, cc.p(137,54))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_Break)
	end

	if #cp.getUtils("NotifyUtils").needNotifySkillArt(skillInfo, self.skillEntry) > 0 then
		cp.getManager("ViewManager").addRedDot(self.Button_SkillArts, cc.p(48,50))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_SkillArts)
	end
	
	if cp.getUtils("NotifyUtils").needNotifySkillBoundary(skillInfo, self.skillEntry) then
		cp.getManager("ViewManager").addRedDot(self.Button_Boundary, cc.p(48,50))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_Boundary)
	end
	
	if cp.getUtils("NotifyUtils").notifySkillAttr then
		cp.getManager("ViewManager").addRedDot(self.Button_Attr, cc.p(48,50))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_Attr)
	end
end

function SkillDetailLearnLayer:updateEquipArtView(skillInfo)
	local imgEquipArt = self.Image_Art:getChildByName("Image_EquipArt")
	local txtArtName = self.Image_Art:getChildByName("Text_ArtName")
	imgEquipArt:setVisible(false)
	txtArtName:setVisible(false)
	if skillInfo.art_index == -1 then
		return
	end

	local artInfo = skillInfo.art_list[skillInfo.art_index+1]
	local artEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", artInfo.art_id)
	imgEquipArt:getChildByName("Image_Icon"):loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	imgEquipArt:getChildByName("Text_Level"):setString("LV."..artInfo.art_level+1)
	imgEquipArt:loadTexture(artEntry:getValue("Icon"))
	txtArtName:setString(artEntry:getValue("SkillName"))
	imgEquipArt:setVisible(true)
	txtArtName:setVisible(true)
	cp.getManager("ViewManager").setTextQuality(txtArtName, self.skillEntry:getValue("Colour"))

	cp.getManager("ViewManager").initButton(imgEquipArt, function()
		local layer = require("cp.view.scene.skill.SkillSingleArtLayer"):create(artEntry, artInfo.art_level)
		self:addChild(layer, 100)
	end)
end

function SkillDetailLearnLayer:updateSkillDetailView()
	self:checkNeedNotify()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	self.Image_Skill:loadTexture(self.skillEntry:getValue("Icon"))
	self.Image_Skill:getChildByName("Text_Level"):setString("LV."..skillInfo.skill_level)
	self.Image_SkillType:loadTexture(CombatConst.SkillSerise_IconList[self.skillEntry:getValue("Serise")], ccui.TextureResType.plistType)
	self.Text_SkillType:setString(CombatConst.SkillTypeName[self.skillEntry:getValue("Serise")])
	local icon = self.Image_Skill:getChildByName("Image_Icon")
	icon:loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	self.Text_SkillName:setTextColor(CombatConst.SkillQualityColor4b[self.skillEntry:getValue("Colour")])
	self.Text_SkillName:setString(self.skillEntry:getValue("SkillName"))
	
	local power = 0
	if self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
		self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
			self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
		power = cp.getUtils("DataUtils").GetSkillPower(self.skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.boundary)
	end
	self.Text_Power:setString(string.format("%d", power))
	self.Text_Cost:setString(string.format("%d", cp.getUtils("DataUtils").GetSkillForceCost(self.skillEntry:getValue("Colour"), skillInfo.skill_level)))
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

	local TopSkillEffect = self.Image_Skill:getChildByName("TopSkillEffect")
	if skillInfo.boundary == 10 then
		if not TopSkillEffect then
			TopSkillEffect = cc.Sprite:create()
			TopSkillEffect:setName("TopSkillEffect")
			self.Image_Skill:addChild(TopSkillEffect)
            TopSkillEffect:setPosition(cc.p(47,51))
            TopSkillEffect:setScale(cp.getConst("GameConst").EffectScale)
        end
        TopSkillEffect:stopAllActions()
        local animation = cp.getManager("ViewManager").createEffectAnimation("SkillSpecial", 0.045, 1000000)
        TopSkillEffect:runAction(cc.Animate:create(animation))
        TopSkillEffect:setVisible(true)
    elseif TopSkillEffect then
		TopSkillEffect:setVisible(false)
	end

	local model = cp.getManager("ViewManager").createSpineEffect("jingjie")
	if model then
		model:setName("SkillLight")
		model:setPosition(cc.p(45,0))
		self.Image_Skill:addChild(model)
	end

	self.Text_Boundary:setString("境界"..cp.getUtils("DataUtils").formatZh_CN(skillInfo.boundary).."層")

	self:updateEquipArtView(skillInfo)

	local panelIndex = 0
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

		local richText = cp.getUtils("DataUtils").formatEquipEffect(skillInfo.skill_level, self.skillEntry:getValue("Colour"), eventList)
		local height = 81 + richText:getContentSize().height
		panel:getChildByName("Image_EffectName"):setPosition(cc.p(164, height - 35))
		panel:setSize(cc.size(660, height))
		local pos = cc.p(28, height - 60)
		richText:setPosition(pos)
		panel:addChild(richText)
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

		local richText = cp.getUtils("DataUtils").formatUseEffect(skillInfo.skill_level, self.skillEntry:getValue("Colour"), bufferList)
		local height = 81 + richText:getContentSize().height
		panel:getChildByName("Image_EffectName"):setPosition(cc.p(164, height - 35))
		panel:setSize(cc.size(660, height))
		local pos = cc.p(28, height - 60)
		richText:setPosition(pos)
		panel:addChild(richText)
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

		local equipList = cp.getUserData("UserSkill"):getEquipSkillList()
		local richText = cp.getUtils("DataUtils").formatCombineEffect(self.skillEntry, skillUnitsEntry, equipList)
		local height = 81 + richText:getContentSize().height
		panel:getChildByName("Image_EffectName"):setPosition(cc.p(164, height - 35))
		panel:setSize(cc.size(660, height))
		local pos = cc.p(28, height - 60)
		richText:setPosition(pos)
		panel:addChild(richText)
	end

	if self.skillEntry:getValue("Comment"):len() > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_Comment")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_Comment")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("武學介紹")
			panel:setVisible(true)
			self.ListView_Effect:insertCustomItem(panel, panelIndex)
			panelIndex = panelIndex + 1
		
			local richText = cp.getUtils("DataUtils").formatSkillComment(self.skillEntry)
			local height = 81 + richText:getContentSize().height
			panel:getChildByName("Image_EffectName"):setPosition(cc.p(164, height - 35))
			panel:setSize(cc.size(660, height))
			local pos = cc.p(28, height - 60)
			richText:setPosition(pos)
			panel:addChild(richText)
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
			local height = 81 + richText:getContentSize().height
			panel:getChildByName("Image_EffectName"):setPosition(cc.p(164, height - 35))
			panel:setSize(cc.size(660, height))
			local pos = cc.p(28, height - 60)
			richText:setPosition(pos)
			panel:addChild(richText)
		end
	end

	self:updateBreakoutItem()
end

function SkillDetailLearnLayer:updateBreakoutItem()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	local needNotifyBreak = cp.getUtils("NotifyUtils").needNotifySkillBreak(skillInfo, self.skillEntry)

	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	local breakLevel = math.ceil(skillInfo.skill_level/20)
	if breakLevel == 0 then
		breakLevel = 1
	end

	if breakLevel > 6 then
		breakLevel = 6
	end

	if skillInfo.is_break and breakLevel~=6 then
		breakLevel = breakLevel + 1
	end
	
	if breakLevel <= 6 then
		self.Text_BreakLevel:setString("LV."..(breakLevel*20+1).."-LV."..(breakLevel+1)*20)
	end
	self.Text_SkillLevel:setString(breakLevel*20)

	local breakEntry = cp.getManager("ConfigManager").getItemByKey("SkillBreakout", breakLevel)
	self.itemList = {}
	if breakEntry then
		self.itemList = cp.getUtils("DataUtils").splitAttr(breakEntry:getValue(CombatConst.SkillSeriseList[self.skillEntry:getValue("Serise")]))
	end

	local btnGuide = nil
	local tmp = nil
	for i, itemInfo in ipairs(self.itemList) do
		local item = self.Panel_Break:getChildByName("Item_"..i)
		if not item then
			item = require("cp.view.ui.icon.ItemIcon"):create(nil)
			item:setPosition(169+(i-1)*162, 100)
			item:setName("Item_"..i)
			
			tmp = ccui.ImageView:create()
			tmp:loadTexture("ui_common_p.png", ccui.TextureResType.plistType)
			tmp:setPosition(169+(i-1)*162, 100)
			self.Panel_Break:addChild(tmp)

			self.Panel_Break:addChild(item, 100)
		end

		local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo[1])
		item:setItemClickCallBack(function()
			local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
			self.rootView:addChild(layer, 100)
		end)

		local pieceNum = 0
		local flag = nil
		local itemID = itemInfo[1]
		local itemNum = cp.getUserData("UserItem"):getItemNum(itemID)
		if itemNum < itemInfo[2] then
			if not btnGuide then
				btnGuide = tmp
			end
			item.Image_icon:setColor(cc.c4b(127,127,127,255))
			local needPiece = tonumber(itemEntry:getValue("Extra"))
			if needPiece and needPiece > 0 then
				itemID = needPiece
				local uuid, pieceInfo = cp.getUserData("UserItem"):getItemPackMax(needPiece)
				if pieceInfo then
					itemNum = pieceInfo.num
				else
					itemNum = 0
				end

				pieceNum = itemNum
				if itemNum >= 5 then
					item:setItemClickCallBack(function()
						cp.getManager("ViewManager").showItemTip(pieceInfo, function(closeType)
							if closeType == "Button_hecheng" then
								self:doSendSocket(cp.getConst("ProtoConst").FragMergeReq,{uuid = uuid})
								cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_item_hecheng)
							end
						end)
					end)
					cp.getManager("ViewManager").setTextQuality(item.Text_num, 2)
					item.Image_icon:setColor(cc.c4b(255,255,255,255))
					flag = "kehecheng"
				else
					item.Image_icon:setColor(cc.c4b(127,127,127,255))
					cp.getManager("ViewManager").setTextQuality(item.Text_num, 6)
				end
			end
			self.canBreak = false
		else
			itemNum = 1
			item.Image_icon:setColor(cc.c4b(255,255,255,255))
		end

		local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
		itemInfo.id = itemID
		itemInfo.num = itemNum
		itemInfo.Colour = itemEntry:getValue("Hierarchy")
		itemInfo.Name = itemEntry:getValue("Name") 
		itemInfo.Icon = itemEntry:getValue("Icon")
		itemInfo.Type = itemEntry:getValue("Type")

		item:reset(itemInfo)
		item.Text_num:setString(tostring(pieceNum) .. "/5")
		item:addFlag(flag)

		local canBreakEffect = item:getChildByName("Effect")
		if needNotifyBreak then
			if not canBreakEffect then
				canBreakEffect = cc.Sprite:create()
				canBreakEffect:setName("Effect")
				item:addChild(canBreakEffect)
				canBreakEffect:setScale(cp.getConst("GameConst").EffectScale)
			end
			canBreakEffect:stopAllActions()
			local animation = cp.getManager("ViewManager").createEffectAnimation("RedBox", 0.045, 1000000)
			canBreakEffect:runAction(cc.Animate:create(animation))
			canBreakEffect:setVisible(true)
		elseif canBreakEffect then
			canBreakEffect:setVisible(false)
		end
	end

	local needPoint = cp.getUtils("DataUtils").GetSkillLevelUpCost(self.skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.skill_level+1)
	local totalPoint = cp.getUserData("UserSkill"):getTrainPoint()
	self.Text_NeedTrainPoint:setString(needPoint)
	self.Text_TotalTrainPoint:setString(cp.getUserData("UserSkill"):getTrainPoint())
	cp.getManager("ViewManager").setTextQuality(self.Text_NeedTrainPoint, 2)
	cp.getManager("ViewManager").setTextQuality(self.Text_TotalTrainPoint, 2)

	if skillInfo.skill_level < breakLevel*20 or (skillInfo.is_break and skillInfo.skill_level%20==0) then
		self.Text_SkillLevel:setTextColor(cc.c4b(255,0,0,255))
	else
		self.Text_SkillLevel:setTextColor(cc.c4b(52,32,17,255))
	end

	if skillInfo.skill_level == 140 then
		self.Text_NeedLevel:setString("已達最高等級")
		self.Text_SkillLevel:setVisible(false)
	else
		self.Text_SkillLevel:setVisible(true)
	end
	self:setupAchivementGuide(nil)
end

function SkillDetailLearnLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function SkillDetailLearnLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	elseif nodeName == "Button_Break" then
		--self.ListView_Effect:scrollToBottom(0.1, true)
		for i=1, #self.itemList do
			if cp.getUserData("UserItem"):getItemNum(self.itemList[i][1]) < self.itemList[i][2] then
				cp.getManager("ViewManager").gameTip("武學突破材料不足")
				return
			end
		end
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
    	self:doSendSocket(cp.getConst("ProtoConst").SkillBreakOutReq, req)
	elseif nodeName == "Button_SkillLevelUp1" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
		local skillInfo = cp.getUserData("UserSkill"):getSkill(req.skill_id)
		if skillInfo.skill_level == 140 then
            cp.getManager("ViewManager").gameTip("武學已達最高等級")
			return
		end
		req.level = cp.getUserData("UserSkill"):getSkill(req.skill_id).skill_level+1
    	self:doSendSocket(cp.getConst("ProtoConst").SkillLevelUpReq, req)
	elseif nodeName == "Button_SkillLevelUp2" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
		local skillInfo = cp.getUserData("UserSkill"):getSkill(req.skill_id)
		if skillInfo.skill_level == 140 then
            cp.getManager("ViewManager").gameTip("武學已達最高等級")
			return
		end
		if skillInfo.skill_level > 0 and skillInfo.skill_level%20 == 0 and not skillInfo.is_break then
            cp.getManager("ViewManager").gameTip("武學未突破")
			--test
			--升級後再發一次，觸摸下一步
			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			if cur_guide_module_name == "wuxue" then
				local info = 
				{
					classname = "SkillDetailLearnLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end

			return
		end
		local breakLevel = math.floor(skillInfo.skill_level/20)+1
		req.level = cp.getUtils("DataUtils").CalculateLevelup(self.skillEntry:getValue("Colour"), 
			skillInfo.skill_level, cp.getUserData("UserSkill"):getTrainPoint())
		if req.level == skillInfo.skill_level then
			cp.getManager("ViewManager").gameTip("當前修為點不足")
			return
		end
		
		if req.level > breakLevel*20 then
			req.level = breakLevel*20
		end
		
		self:doSendSocket(cp.getConst("ProtoConst").SkillLevelUpReq, req)
	elseif nodeName == "Button_ResetSkill" then
		local layer = require("cp.view.scene.skill.ResetSkillLayer"):create(self.skillEntry)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateSkillDetailView()
		end)
	elseif nodeName == "Button_SkillArts" then
		local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
		local layer = require("cp.view.scene.skill.SkillArtLayer"):create(self.skillEntry)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateSkillDetailView()
		end)
	elseif nodeName == "Button_Boundary" then
		local layer = require("cp.view.scene.skill.SkillBoundaryLayer"):create(self.skillEntry)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateSkillDetailView()
		end)
	elseif nodeName == "Button_SkillStrategy" then
		local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
		local layer = require("cp.view.scene.skill.SkillStrategyLayer"):create(self.skillEntry, skillInfo)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			--self:updateSkillDetailView()
		end)
	elseif nodeName == "Button_AddTrainPoint" then
		local layer = require("cp.view.scene.skill.BuyTrainPointLayer"):create()
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateSkillDetailView()
		end)
	elseif nodeName == "Button_Attr" then
		local layer = require("cp.view.scene.skill.SkillEffectLayer"):create()
		self:addChild(layer, 100)
		cp.getManager("ViewManager").removeRedDot(self.Button_Attr)
	end
end

function SkillDetailLearnLayer:onEnterScene()
	local sequence = {}
	table.insert(sequence, cc.DelayTime:create(0.3))
	table.insert(sequence,cc.CallFunc:create(function()
		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "wuxue" then
			local info = 
			{
				classname = "SkillDetailLearnLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
	end))

	self:runAction(cc.Sequence:create(sequence))
	self:updateSkillDetailView()
end

function SkillDetailLearnLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillDetailLearnLayer