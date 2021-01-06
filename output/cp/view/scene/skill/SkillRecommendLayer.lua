local BLayer = require "cp.view.ui.base.BLayer"
local SkillRecommendLayer = class("SkillRecommendLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillRecommendLayer:create()
    local scene = SkillRecommendLayer.new()
    return scene
end

function SkillRecommendLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").UpdateSkillCombineRsp] = function(data)
            cp.getManager("ViewManager").gameTip("裝備成功")
		end,
		["GetCareerSkillRsp"] = function(data)
			self:updateArenaTopSkillView(data.info)
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillRecommendLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_recommend.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root.Image_101"] = {name = "Image_101"},
		["Panel_root.Image_102"] = {name = "Image_102"},
		["Panel_root.ListView_Recommend"] = {name = "ListView_Recommend"},
		["Panel_root.Image_Top.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1},
		["Panel_root.Image_Top.Button_AllSkill"] = {name = "Button_AllSkill", click="onBtnClick", clickScale=1},
		["Panel_root.Image_Top.Button_SkillCombine"] = {name = "Button_SkillCombine", click="onBtnClick", clickScale=1},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.ListView_Recommend, self.Image_101, self.Image_102})
	ccui.Helper:doLayout(self.rootView)
	
	self.recommendSkillList = self:getRecommendSkillList()
	self.mockSkillList = {}
	local req = {}
	self:doSendSocket(cp.getConst("ProtoConst").GetCareerSkillReq, req)
end

function SkillRecommendLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_AllSkill" then
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillMap}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
	elseif nodeName == "Button_SkillCombine" then
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillCombine}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
	elseif nodeName == "Button_Recommend" then
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillRecommend}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
	end
end

function SkillRecommendLayer:getRecommendSkillList()
	local combineEntryList = {}
	local combineSkillList = {}
	cp.getManager("ConfigManager").foreach("SkillUnits", function(entry)
		if cp.getUtils("DataUtils").skillUnitsTakeEffect(entry) then
			table.insert(combineEntryList, entry)
			table.insert(combineSkillList, entry:getValue("ID"))
			table.insertto(combineSkillList, cp.getUtils("DataUtils").split(entry:getValue("NeedSkills"), ";"))
		end
		return true
	end)
	
	local combineEntryPair = {}
	for _, combineEntry in ipairs(combineEntryList) do
		local combineSkills = cp.getUtils("DataUtils").splitBufferList(combineEntry:getValue("NeedSkills"))
		table.insert(combineSkills, combineEntry:getValue("ID"))
		table.sort(combineSkills, function(a, b)
			local entryA = cp.getManager("ConfigManager").getItemByKey("SkillEntry", a)
			local entryB = cp.getManager("ConfigManager").getItemByKey("SkillEntry", b)
			return entryA:getValue("Colour") > entryB:getValue("Colour") or (entryA:getValue("Colour")==entryB:getValue("Colour") and entryA:getValue("SkillID") < entryB:getValue("SkillID"))
		end)
		local k = table.concat(combineSkills, "")
		if not combineEntryPair[k] then
			combineEntryPair[k] = {}
			combineEntryPair[k].combineEntry = combineEntry
			combineEntryPair[k].skillEntryList = {}
			for i, skillID in ipairs(combineSkills) do
				local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
				table.insert(combineEntryPair[k].skillEntryList, skillEntry)
			end
			table.sort(combineEntryPair[k].skillEntryList, function(a,b)
				return a:getValue("Colour") > b:getValue("Colour") or (a:getValue("Colour")==b:getValue("Colour") and a:getValue("SkillID") < b:getValue("SkillID"))
			end)
		end
	end

	combineEntryList = table.values(combineEntryPair)
	table.sort(combineEntryList, function(a, b)
		local firstEntryA = a.skillEntryList[1]
		local firstEntryB = b.skillEntryList[1]
		local tempA, tempB = math.pow(10, firstEntryA:getValue("Colour")+3), math.pow(10, firstEntryB:getValue("Colour")+3)
		local flagA, flagB = true, true
		for i=1, 4 do
			local entryA = a.skillEntryList[i]
			local entryB = b.skillEntryList[i]
			if entryA then
				local skillInfoA = cp.getUserData("UserSkill"):getSkill(entryA:getValue("SkillID"))
				if skillInfoA then
					tempA = tempA + skillInfoA.skill_level
				else
					flagA = false
				end
			end
			if entryB then
				local skillInfoB = cp.getUserData("UserSkill"):getSkill(entryB:getValue("SkillID"))
				if skillInfoB then
					tempB = tempB + skillInfoB.skill_level
				else
					flagB = false
				end
			end
		end

		if flagA then
			tempA = tempA + math.pow(10, 10)
		end

		if flagB then
			tempB = tempB + math.pow(10, 10)
		end

		if tempA > tempB then
			return true
		elseif tempA == tempB then
			return #a.skillEntryList > #b.skillEntryList
		else
			return false
		end
	end)

	local forceSkillList = {}
	local bodySkillList = {}
	local otherSkillList = {}
	for i, skillInfo in ipairs(cp.getUserData("UserSkill"):getValue("SkillData").skill_list.skill_list) do
		local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillInfo.skill_id)
		skillInfo.Entry = skillEntry
		if table.indexof({1, 6}, skillEntry:getValue("Serise")) and skillEntry:getValue("SkillType") == 1 then
			if skillEntry:getValue("Serise") == 1 then
				table.insert(forceSkillList, skillInfo)
			elseif skillEntry:getValue("Serise") == 6 then
				table.insert(bodySkillList, skillInfo)
			end
		else
			table.insert(otherSkillList, skillInfo)
		end
	end

	cp.getUtils("DataUtils").quick_sort(forceSkillList, function(skillInfoA, skillInfoB)
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

	cp.getUtils("DataUtils").quick_sort(bodySkillList, function(skillInfoA, skillInfoB)
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

	cp.getUtils("DataUtils").quick_sort(otherSkillList, function(skillInfoA, skillInfoB)
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

	local skillList = {}
	local forceLoc = nil
	local bodyLoc = nil
	if #forceSkillList > 0 then
		table.insert(skillList, forceSkillList[1].skill_id)
		forceLoc = #skillList
	end

	if #bodySkillList > 0 then
		table.insert(skillList, bodySkillList[1].skill_id)
		bodyLoc = #skillList
	end

	for _, combineEntry in ipairs(combineEntryList) do
		local remainInsert = 6 - #skillList
		local needInsertSkill = {}
		for _, skillEntry in ipairs(combineEntry.skillEntryList) do
			local skillID = skillEntry:getValue("SkillID")
			if not table.indexof(skillList, skillID) then
				if skillEntry:getValue("Serise") == 1 and forceLoc then
					skillList[forceLoc] = skillID
				elseif skillEntry:getValue("Serise") == 6 and bodyLoc then
					skillList[bodyLoc] = skillID
				else
					table.insert(needInsertSkill, skillID)
				end
			end
		end
		if #needInsertSkill <= remainInsert then
			table.insertto(skillList, needInsertSkill)
		end
		
		if #skillList >= 6 then
			return skillList
		end
	end

	for _, skillInfo in ipairs(otherSkillList) do
		if not table.indexof(skillList, skillInfo.skill_id) then
			table.insert(skillList, skillInfo.skill_id)
		end
		
		if #skillList == 6 then
			return skillList
		end
	end

	return skillList
end

function SkillRecommendLayer:getMockSkillList()
	local index = cp.getManager("LocalDataManager"):getValue("", "mockskill", "index") or 1
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local entryList = {}
	cp.getManager("ConfigManager").foreach("SkillSpecial", function(entry)
		if entry:getValue("Hierarchy") == roleAtt.hierarchy and 
			entry:getValue("Career") == roleAtt.career then
			table.insert(entryList, entry)
		end
		return true
	end)

	local i = (index - 1)%#entryList + 1
	if not entryList[i] then
		return {}
	end

	local skillList = cp.getUtils("DataUtils").split(entryList[i]:getValue("Skills"), ";")
	return skillList
end

function SkillRecommendLayer:oneKeyEquip(skillList)
	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
    local req = {}
    req.combine_id = skillData.equip_combine
    req.skill_list = {skill_id_list = skillList}
    req.type = 0
    self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
end

function SkillRecommendLayer:updateRecommendSkillView()
	local panel = self.ListView_Recommend:getChildByName("Panel_Recommend")
	local btnEquip = panel:getChildByName("Button_Equip")
	local txtSpecial = panel:getChildByName("Image_Special"):getChildByName("Text_Special")
	for i=1,6 do
		local skillID = self.recommendSkillList[i]
		if not skillID or skillID == 0 then
			skillID = 11
		end
		local node = panel:getChildByName("Node_Skill"..i)
		if skillID then
			node:setVisible(true)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			local imgIcon = node:getChildByName("Image_Icon")
			local imgBox = node:getChildByName("Image_Box")
			local txtName = node:getChildByName("Text_Name")
			imgIcon:loadTexture(skillEntry:getValue("Icon"))
			imgBox:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
			txtName:setString(skillEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(txtName, skillEntry:getValue("Colour"))
			cp.getManager("ViewManager").initButton(imgBox, function()	
				local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
				if skillInfo then
					local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry)
					self:addChild(layer, 100)
				else
					local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
					self:addChild(layer, 100)
				end
			end, 1)
			if skillID == 11 then
				imgBox:setTouchEnabled(false)
			end
		else
			node:setVisible(false)
		end
	end
	cp.getManager("ViewManager").initButton(btnEquip, function()
		self:oneKeyEquip(self.recommendSkillList)
	end)

	local special = cp.getUtils("DataUtils").formatSkillSpecial(self.recommendSkillList)
	for k,v in ipairs(special) do
		special[k] = cp.getConst("CombatConst").SkillSpecial[v]
	end
	local txt = table.concat(special, "  ")
	txtSpecial:setString(txt)
end

function SkillRecommendLayer:updateMockSkillView()
	self.mockSkillList = self:getMockSkillList()
	local panel = self.ListView_Recommend:getChildByName("Panel_Mock")
	local btnChange = panel:getChildByName("Button_Change")
	local txtSpecial = panel:getChildByName("Image_Special"):getChildByName("Text_Special")
	for i=1,6 do
		local skillID = self.mockSkillList[i]
		if not skillID or skillID == 0 then
			skillID = 11
		end
		local node = panel:getChildByName("Node_Skill"..i)
		if skillID then
			node:setVisible(true)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			local imgIcon = node:getChildByName("Image_Icon")
			local imgBox = node:getChildByName("Image_Box")
			local txtName = node:getChildByName("Text_Name")
			imgIcon:loadTexture(skillEntry:getValue("Icon"))
			imgBox:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
			txtName:setString(skillEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(txtName, skillEntry:getValue("Colour"))
			cp.getManager("ViewManager").initButton(imgBox, function()	
				local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
				if skillInfo then
					local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry)
					self:addChild(layer, 100)
				else
					local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
					self:addChild(layer, 100)
				end
			end, 1)
			if skillID == 11 then
				imgBox:setTouchEnabled(false)
			end
		else
			node:setVisible(false)
		end
	end
	cp.getManager("ViewManager").initButton(btnChange, function()
		local index = cp.getManager("LocalDataManager"):getValue("", "mockskill", "index") or 1
		index = index + 1
		cp.getManager("LocalDataManager"):setValue("", "mockskill", "index", index)
		self:updateMockSkillView()
	end)
	
	local special = cp.getUtils("DataUtils").formatSkillSpecial(self.mockSkillList)
	for k,v in ipairs(special) do
		special[k] = cp.getConst("CombatConst").SkillSpecial[v]
	end
	local txt = table.concat(special, "  ")
	txtSpecial:setString(txt)
end

function SkillRecommendLayer:updateArenaTopSkillView(info)
	local panel = self.ListView_Recommend:getChildByName("Panel_God")
	local txtSpecial = panel:getChildByName("Image_Special"):getChildByName("Text_Special")
	local txtName = panel:getChildByName("Text_Name")
	local imgHead = panel:getChildByName("Image_Head")
	txtName:setString(info.name)
	imgHead:loadTexture(cp.DataUtils.getModelFace(info.face))
	for i=1,6 do
		local skillID = info.skill_list[i]
		if not skillID or skillID == 0 then
			skillID = 11
		end
		local node = panel:getChildByName("Node_Skill"..i)
		if skillID then
			node:setVisible(true)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			local imgIcon = node:getChildByName("Image_Icon")
			local imgBox = node:getChildByName("Image_Box")
			local txtName = node:getChildByName("Text_Name")
			imgIcon:loadTexture(skillEntry:getValue("Icon"))
			imgBox:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
			txtName:setString(skillEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(txtName, skillEntry:getValue("Colour"))
			cp.getManager("ViewManager").initButton(imgBox, function()	
				local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
				if skillInfo then
					local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry)
					self:addChild(layer, 100)
				else
					local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
					self:addChild(layer, 100)
				end
			end, 1)
			if skillID == 11 then
				imgBox:setTouchEnabled(false)
			end
		else
			node:setVisible(false)
		end
	end
	
	local special = cp.getUtils("DataUtils").formatSkillSpecial(info.skill_list)
	for k,v in ipairs(special) do
		special[k] = cp.getConst("CombatConst").SkillSpecial[v]
	end
	local txt = table.concat(special, "  ")
	txtSpecial:setString(txt)
end

function SkillRecommendLayer:updateSkillRecommendView()
	self:updateRecommendSkillView()
	self:updateMockSkillView()
end

function SkillRecommendLayer:onEnterScene()
	self:updateSkillRecommendView()
end

function SkillRecommendLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillRecommendLayer