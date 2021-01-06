local BLayer = require "cp.view.ui.base.BLayer"
local SkillCombineLayer = class("SkillCombineLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillCombineLayer:create(openInfo)
    local scene = SkillCombineLayer.new()
    return scene
end

function SkillCombineLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").UpdateSkillCombineRsp] = function(data)
            cp.getManager("ViewManager").gameTip("裝備成功")
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillCombineLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_combine.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.deltaY = 0
	self.width = 637
	self.height = 204
	self.maxColumn = 1

    local childConfig = {
		["Panel_root.Image_101"] = {name = "Image_101"},
		["Panel_root.Image_102"] = {name = "Image_102"},
		["Panel_root.Panel_Model"] = {name = "Panel_Model"},
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_Top.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1},
		["Panel_root.Image_Top.Button_AllSkill"] = {name = "Button_AllSkill", click="onBtnClick", clickScale=1},
		["Panel_root.Image_Top.Button_Recommend"] = {name = "Button_Recommend", click="onBtnClick", clickScale=1},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Panel_Model,self.Image_101,self.Image_102})
	ccui.Helper:doLayout(self.rootView)
	
	self.combineList = self:getSortCombineList()

	self:initCellView()
	
	if cp.getManualConfig("Channel").channel == "lunplay" then
		self.Button_Recommend:setVisible(false)
	end
end

function SkillCombineLayer:onBtnClick(btn)
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

function SkillCombineLayer:getSortCombineList()
	local combineEntryList = cp.getManager("ConfigManager").getItemList("SkillUnits", "ID", function(id)
		--[[
		local skillInfo = cp.getUserData("UserSkill"):getSkill(id)
		if not skillInfo then
			return false
		end
		]]

		local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", id)
		return skillEntry:getValue("SkillType") == 1
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
		local tempA, tempB = 0, 0
		for i=1, 5 do
			local entryA = a.skillEntryList[i]
			local entryB = b.skillEntryList[i]
			if entryA then
				tempA = tempA + math.pow(10, entryA:getValue("Colour"))
			end
			if entryB then
				tempB = tempB + math.pow(10, entryB:getValue("Colour"))
			end
		end

		if tempA < tempB then
			return true
		else
			return false
		end
	end)

	return combineEntryList
end

function SkillCombineLayer:updateOneSkillCombineView(i, model)
	local combineInfo = self.combineList[i]
	local canEquip = true
	model:setVisible(true)
	model:getChildByName("Text_CombineName"):setString(combineInfo.combineEntry:getValue("Name"))
	local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", combineInfo.combineEntry:getValue("ID"))
	for j=1, 4 do
		local skillEntry = combineInfo.skillEntryList[j]
		local btn = model:getChildByName("Button_Skill"..j)
		local imgIcon = btn:getChildByName("Image_Icon")
		local textName = btn:getChildByName("Text_Name")
		local imgMask = btn:getChildByName("Image_Mask")
		if skillEntry then
			local textureName = CombatConst.SkillBoxList[skillEntry:getValue("Colour")]
			btn:loadTextures(skillEntry:getValue("Icon"), skillEntry:getValue("Icon"), skillEntry:getValue("Icon"))
			imgIcon:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
			textName:setString(skillEntry:getValue("SkillName"))
			cp.getManager("ViewManager").setTextQuality(textName, skillEntry:getValue("Colour"))
			if cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID")) then
				imgMask:setOpacity(0)
				cp.getManager("ViewManager").initButton(btn, function()
					local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry)
					self:addChild(layer, 100)
				end)
			else
				imgMask:setOpacity(150)
				canEquip = false
				cp.getManager("ViewManager").initButton(btn, function()
					local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
					self:addChild(layer, 100)
				end)
			end
			imgIcon:setVisible(true)
			textName:setVisible(true)
			btn:setVisible(true)
		else
			btn:setVisible(false)
		end
	end

	local btn = model:getChildByName("Button_Equip")
	if canEquip then
		cp.getManager("ViewManager").initButton(btn, function()
			self:oneKeyEquip(combineInfo.skillEntryList)
		end)
		cp.getManager("ViewManager").setEnabled(btn, true)
	else
		cp.getManager("ViewManager").setEnabled(btn, false)
	end
end

function SkillCombineLayer:oneKeyEquip(skillEntryList)
	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")

    local combineID = skillData.equip_combine + 1
	if not skillData.skill_combine_list then
		skillData.skill_combine_list = {}
	end

	if not skillData.skill_combine_list[combineID] then
		skillData.skill_combine_list[combineID] = {}
	end

	if not skillData.skill_combine_list[combineID].skill_id_list then
		skillData.skill_combine_list[combineID].skill_id_list = {}
	end

	local combineList = skillData.skill_combine_list[combineID].skill_id_list
	local freeEquipNum = 0
	local valid = true
	for i = 1,6 do
		while true do
			skillID = combineList[i]
			if not skillID or skillID == 0 then
				freeEquipNum = freeEquipNum + 1
				break
			end

			local checkSerise = true
			skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			if skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Force and
				skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Body and
				skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
				checkSerise = false
			end

			for _, skillEntry2 in ipairs(skillEntryList) do
				if (checkSerise and skillEntry:getValue("Serise") == skillEntry2:getValue("Serise"))
					or skillEntry2:getValue("SkillID") == skillID then
					combineList[i] = nil
					freeEquipNum = freeEquipNum + 1
					break
				end
			end
			break
		end
	end

	local lastEquipNum, i = 1, 1
	for i = 1, 6 do
		local skillID = combineList[i] or 0
		if skillID == 0 then
			combineList[i] = skillEntryList[lastEquipNum]:getValue("SkillID")
			freeEquipNum = freeEquipNum - 1
			lastEquipNum = lastEquipNum + 1
		else
			if freeEquipNum <= #skillEntryList-lastEquipNum then
				combineList[i] = skillEntryList[lastEquipNum]:getValue("SkillID")
				lastEquipNum = lastEquipNum + 1
			end
		end

		if lastEquipNum > #skillEntryList then
			break
		end
	end

    local req = {}
    req.combine_id = skillData.equip_combine
    req.skill_list = skillData.skill_combine_list[combineID]
    req.type = 0
    self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req)
end

function SkillCombineLayer:initCellView()
	local sz = self.Panel_Model:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(sz)
	self.cellView:setCellSize(self.width, self.height)
	self.cellView:setColumnCount(self.maxColumn)
	self.cellView:setCountFunction(function() 
		return #self.combineList
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:setAnchorPoint(cc.p(0, 0))
	self.cellView:setPosition(cc.p(0, 0))
	self.Panel_Model:addChild(self.cellView)
end

function SkillCombineLayer:cellFactory(cellview, idx)
	local model = nil 
	local cell = cellview:dequeueCell()

    if nil == cell then
		cell = cc.TableViewCell:new()
		model = self.Image_Model:clone()
		model:setName("Image_Model")
		local size = model:getContentSize()
		model:setPosition(size.width/2, size.height/2)
		cell:addChild(model)
	else
		model = cell:getChildByName("Image_Model")
    end

	model:setVisible(true)
	self:updateOneSkillCombineView(idx, model)

    return cell
end

function SkillCombineLayer:updateSkillCombineView()
	self.cellView:reloadData()
end

function SkillCombineLayer:onEnterScene()
	self:updateSkillCombineView()
end

function SkillCombineLayer:setOneKeyEquipCB(cb)
	self.oneKeyEquipCB = cb
end

function SkillCombineLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillCombineLayer