local BLayer = require "cp.view.ui.base.BLayer"
local SkillMapLayer = class("SkillMapLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillMapLayer:create(openInfo)
    local scene = SkillMapLayer.new()
    return scene
end

function SkillMapLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function SkillMapLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_all_skill.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.selectType = {3}
	self.dragSkill = false
	self.deltaX = 44
	self.deltaY = 78
	self.skillSize = 100
	self.maxCol = 4
	self.skillModelList = {}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_101"] = {name = "Image_101"},
		["Panel_root.Image_102"] = {name = "Image_102"},
		["Panel_root.Image_SkillList"] = {name = "Image_SkillList"},
		["Panel_root.ScrollView_Skill"] = {name = "ScrollView_Skill"},
		["Panel_root.ScrollView_Skill.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_Top.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_Top.Button_Recommend"] = {name = "Button_Recommend", click="onBtnClick", clickScale=1},
		["Panel_root.Image_Top.Button_SkillCombine"] = {name = "Button_SkillCombine", click="onBtnClick", clickScale=1},
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
	self.Image_Model:setVisible(false)

	for i=1, 8 do
		local btn = self["Button_"..i]
		btn:ignoreContentAdaptWithSize(true)
		cp.getManager("ViewManager").initButton(btn, function()
			local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
			local skillType = tonumber(extensionData:getCustomProperty())
			self.selectType = {skillType}
			self:updateMapListView(true)
		end, 1)
	end

	self.ScrollView_Skill:setScrollBarEnabled(false)
	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_SkillList, self.ScrollView_Skill,self.Image_101,self.Image_102})

	ccui.Helper:doLayout(self.rootView)
	self:updateMapListView(true)
	if cp.getManualConfig("Channel").channel == "lunplay" then
		self.Button_Recommend:setVisible(false)
	end
end

function SkillMapLayer:getSkillByPos(posX, posY)
	posY = posY-self.ScrollView_Skill:getPositionY()-self.Image_1:getPositionY()
	posY=self.ScrollView_Skill:getSize().height-posY
	posX = posX - 120
	local deltaY = self.ScrollView_Skill:getInnerContainerSize().height - self.ScrollView_Skill:getSize().height
	posY = posY + deltaY + self.ScrollView_Skill:getInnerContainerPosition().y
	local row = math.ceil(posY/(self.deltaY+self.skillSize))
	local col = math.ceil(posX/(self.deltaX+self.skillSize))

	if math.abs(posX - (col-1)*(self.deltaX+self.skillSize)) > self.skillSize or math.abs(posY - (row-1)*(self.deltaY+self.skillSize)) > self.skillSize then
		return nil
	end

	return (row-1)*self.maxCol+col
end

function SkillMapLayer:onBtnClick(btn)
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

function SkillMapLayer:sortSkillList(skillList)
	table.sort(skillList, function(a, b)
		local leftSkillInfo = cp.getUserData("UserSkill"):getSkill(a:getValue("SkillID"))
		local rightSkillInfo = cp.getUserData("UserSkill"):getSkill(b:getValue("SkillID"))
		if leftSkillInfo and not rightSkillInfo then
			return true
		elseif not leftSkillInfo and rightSkillInfo then
			return false
		else
			return a:getValue("Colour") > b:getValue("Colour")
		end
	end)
end

function SkillMapLayer:updateOneSkillView(skillEntry, img)
	if not img then
		img = self.ScrollView_Skill:getChildByName(skillEntry:getValue("SkillID"))
	end

	if not img then
		return
	end

	--img:removeAllChildren()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
	local model = img:getChildByName("Panel_Model")
	cp.getManager("ViewManager").initSkillNode(model, skillEntry)

	local btnBox = model:getChildByName("Button_Box")
	local imgIcon = model:getChildByName("Image_Icon")

	if not skillInfo then
		cp.getManager("ViewManager").setShader(imgIcon, "GrayShader")
	else
		cp.getManager("ViewManager").setShader(imgIcon, nil)
	end

	cp.getManager("ViewManager").initButton(btnBox, function()
		self:showSkillDetail(skillEntry)
	end, 1.0)
end

function SkillMapLayer:updateMapListView(flag)
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
	if flag then
		self.skillList = cp.getManager("GDataManager"):getSkillByType(self.selectType)
		self:sortSkillList(self.skillList)
		local totalRow = math.floor((#self.skillList-1)/self.maxCol)+1
		self.ScrollView_Skill:setInnerContainerSize(cc.size(576, totalRow*178))
	end

	local beginX = 72
	local beginY = self.ScrollView_Skill:getInnerContainerSize().height - 89

	local index = 30
	for i=1, index do
		local skillEntry = self.skillList[i]
		if not skillEntry then
			break
		end
		local model = nil
		if self.skillModelList[i] == nil then
			model = self.Image_Model:clone()
			self.ScrollView_Skill:addChild(model)
			self.skillModelList[i] = model
		else
			model = self.skillModelList[i]
		end

		model:setVisible(true)
		self:updateOneSkillView(skillEntry, model)
		local row = math.floor((i-1)/self.maxCol)+1
		local col = math.floor((i-1)%self.maxCol)+1
		model:setPosition(cc.p(beginX+(self.deltaX+self.skillSize)*(col-1), beginY - (row-1)*(self.deltaY+self.skillSize)))
	end

	self.ScrollView_Skill:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
		for i=index+1, index+30 do
			local skillEntry = self.skillList[i]
			if not skillEntry then
				break
			end
			local model = nil
			if self.skillModelList[i] == nil then
				model = self.Image_Model:clone()
				self.ScrollView_Skill:addChild(model)
				self.skillModelList[i] = model
			else
				model = self.skillModelList[i]
			end

			model:setVisible(true)
			self:updateOneSkillView(skillEntry, model)
			local row = math.floor((i-1)/self.maxCol)+1
			local col = math.floor((i-1)%self.maxCol)+1
			model:setPosition(cc.p(beginX+(self.deltaX+self.skillSize)*(col-1), beginY - (row-1)*(self.deltaY+self.skillSize)))
		end
		index=index+30
	end), cc.DelayTime:create(0.2))))

	for i=#self.skillList+1, #self.skillModelList do
		self.skillModelList[i]:setVisible(false)
	end
end

function SkillMapLayer:showSkillDetail(skillEntry)
	if not skillEntry then
		return
	end
	local skillInfo = cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID"))
	if skillInfo then
		local layer = require("cp.view.scene.skill.SkillDetailLearnLayer"):create(skillEntry, self.combineID)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateOneSkillView(skillEntry)
		end)
	else
		local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateOneSkillView(skillEntry)
		end)
	end
end

function SkillMapLayer:onEnterScene()
end

function SkillMapLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillMapLayer