local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalStrengthLayer = class("PrimevalStrengthLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function PrimevalStrengthLayer:create(pos)
    local scene = PrimevalStrengthLayer.new(pos)
    return scene
end

function PrimevalStrengthLayer:initListEvent()
    self.listListeners = {
		["StrengthMetaRsp"] = function(data)
			self.posList = {}
			self:updatePrimevalStrengthView()
			
			local model = self.Image_Icon:getChildByName("Effect")
			model:setAnimation(0, "bangpaishengji", false)
		end,
		["SelectQuality"] = function(quality)
			self:oneKeySelect(quality)
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalStrengthLayer:onInitView(pos)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_strength.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	self.width = 120
	self.height = 150
	self.maxColumn = 5
	self.metaList = {}
	self.pos = pos
	self.posList = {}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_18"] = {name = "Image_18"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Meta.Image_Icon"] = {name = "Image_Icon"},
		["Panel_root.Image_1.Image_Meta.Text_Name"] = {name = "Text_Name"},
		["Panel_root.Image_1.Text_LevelBefore"] = {name = "Text_LevelBefore"},
		["Panel_root.Image_1.Text_LevelAfter"] = {name = "Text_LevelAfter"},
		["Panel_root.Image_1.LoadingBar_Progress"] = {name = "LoadingBar_Progress"},
		["Panel_root.Image_1.Text_AttrName1"] = {name = "Text_AttrName1"},
		["Panel_root.Image_1.Text_AttrName2"] = {name = "Text_AttrName2"},
		["Panel_root.Image_1.Text_AttrName3"] = {name = "Text_AttrName3"},
		["Panel_root.Image_1.Text_AttrBefore1"] = {name = "Text_AttrBefore1"},
		["Panel_root.Image_1.Text_AttrBefore2"] = {name = "Text_AttrBefore2"},
		["Panel_root.Image_1.Text_AttrBefore3"] = {name = "Text_AttrBefore3"},
		["Panel_root.Image_1.Text_AttrAfter1"] = {name = "Text_AttrAfter1"},
		["Panel_root.Image_1.Text_AttrAfter2"] = {name = "Text_AttrAfter2"},
		["Panel_root.Image_1.Text_AttrAfter3"] = {name = "Text_AttrAfter3"},

		["Panel_root.Image_1.Panel_Meta"] = {name = "Panel_Meta"},
		["Panel_root.Image_1.Panel_Meta.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.Button_Select"] = {name = "Button_Select", click="onBtnClick"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Button_Strength"] = {name = "Button_Strength", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.Image_18, self.Panel_Meta})
    ccui.Helper:doLayout(self.rootView)
	self.Image_Model:setVisible(false)
	self.totalExp = 0
	
	local txt = self.LoadingBar_Progress:getChildByName("Text_Progress")
    self.DynamicBar_Exp_L = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Progress, txt, false)
	self:initCellView()
	
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local metaInfo = posMap[self.pos]
	if metaInfo.level == 30 then
		local maxExp = cp.getUtils("DataUtils").GetExpByLevel(metaInfo.color, 30)
		self.DynamicBar_Exp_L:initProgress(maxExp, maxExp)
	else
		local maxExp = cp.getUtils("DataUtils").GetExpByLevel(metaInfo.color, metaInfo.level+1)
		self.DynamicBar_Exp_L:initProgress(maxExp, metaInfo.exp)
	end

	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function PrimevalStrengthLayer:initCellView()
	local sz = self.Panel_Meta:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(sz)
	self.cellView:setCellSize(self.width, self.height)
	self.cellView:setColumnCount(self.maxColumn)
	self.cellView:setCountFunction(function() 
		return #self.metaList
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:setAnchorPoint(cc.p(0, 0))
	self.cellView:setPosition(cc.p(0,0))
	self.Panel_Meta:addChild(self.cellView)
end

function PrimevalStrengthLayer:cellFactory(cellview, idx)
	local model = nil
	local cell = cellview:dequeueCell()

    if nil == cell then
		cell = cc.TableViewCell:new()
		model = self.Image_Model:clone()
		model:setName("Image_Meta")
		local size = model:getContentSize()
		model:setPosition(size.width/2, size.height/2+20)
		cell:addChild(model)
	else
		model = cell:getChildByName("Image_Meta")
    end

	model:setVisible(true)
	local txtName = model:getChildByName("Text_Name")
	local txtLevel = model:getChildByName("Text_Level")
	local imgColor = model:getChildByName("Image_Color")
	local imgFlag = model:getChildByName("Image_Flag")

	local metaInfo = self.metaList[idx]
	model:loadTexture(metaInfo.entry:getValue("Icon"))
	cp.getManager("ViewManager").setTextQuality(txtName, metaInfo.color)
	txtName:setString(metaInfo.entry:getValue("Name"))
	txtLevel:setString("LV."..metaInfo.level)
	imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)
	if table.indexof(self.posList, metaInfo.pos) then
		imgFlag:setVisible(true)
	else
		imgFlag:setVisible(false)
	end

	model:addTouchEventListener(function(sender, event)
		if event == cc.EventCode.ENDED then
			local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
			if distance < 50 then
				if table.indexof(self.posList, metaInfo.pos) then
					self:onSelectOne(metaInfo, imgFlag, true)
				else
					self:onSelectOne(metaInfo, imgFlag, false)
				end
			end
		end
	end)
    return cell
end

function PrimevalStrengthLayer:onSelectOne(metaInfo, imgFlag, discard)
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local originMetaInfo = posMap[self.pos]
	if originMetaInfo.level == 30 then
		cp.getManager("ViewManager").gameTip("混元已經強化到最高等級")
		return
	end

	local maxExp = cp.getUtils("DataUtils").GetMetaStrengthExp(originMetaInfo.color, originMetaInfo.level, originMetaInfo.exp, 30)
	if self.totalExp >= maxExp and not discard then
		cp.getManager("ViewManager").gameTip("混元經驗已滿")
		return
	end

	if discard then
		self.totalExp = self.totalExp - cp.getUtils("DataUtils").GetMetaExp(metaInfo.color, metaInfo.level, metaInfo.exp)
		table.removebyvalue(self.posList, metaInfo.pos)
	else
		self.totalExp = self.totalExp + cp.getUtils("DataUtils").GetMetaExp(metaInfo.color, metaInfo.level, metaInfo.exp)
		table.insert(self.posList, metaInfo.pos)
	end

	imgFlag:setVisible(not discard)

	local totalSilver = cp.getUtils("DataUtils").GetStrengthNeedSilver(self.totalExp)
	local dstLevel, remainExp, maxExp = cp.getUtils("DataUtils").GetMetaUpgrade(originMetaInfo.color, originMetaInfo.level, originMetaInfo.exp, self.totalExp)
	if dstLevel == 30 then
		self.DynamicBar_Exp_L:initProgress(maxExp, maxExp)
	else
		self.DynamicBar_Exp_L:initProgress(maxExp, remainExp)
	end
	self.Text_LevelAfter:setString(dstLevel)
	self.Text_Cost:setString(totalSilver)
	
	for i, attrID in ipairs(originMetaInfo.attr_list) do
		local txtAttrName = self["Text_AttrName"..i]
		local txtAttrBefore = self["Text_AttrBefore"..i]
		local txtAttrAfter = self["Text_AttrAfter"..i]
		txtAttrName:setString(CombatConst.AttributeList[attrID])
		local valueBefore = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, originMetaInfo.color, originMetaInfo.level)
		local valueAfter = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, originMetaInfo.color, dstLevel)
		txtAttrBefore:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueBefore, 0.01))
		txtAttrAfter:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueAfter, 0.01))
		cp.getManager("ViewManager").setTextQuality(txtAttrBefore, 2)
		cp.getManager("ViewManager").setTextQuality(txtAttrAfter, 2)
	end
end

function PrimevalStrengthLayer:sortMetaList(metaList)
	self.metaList = {}
	for _, metaInfo in pairs(metaList) do
		if metaInfo.pack == 0 and metaInfo.place == 0 and not metaInfo.lock and metaInfo.pos ~= self.pos then
			table.insert(self.metaList, metaInfo)
		end
	end

	cp.getUtils("DataUtils").quick_sort(self.metaList, function(a, b)
		if a.color > b.color then
			return false
		elseif a.color < b.color then
			return true
		else
			if a.level > b.level then
				return false
			elseif a.level < b.level then
				return true
			else
				if a.id < b.id then
					return true
				elseif a.id < b.id then
					return false
				else
					return false
				end
			end
		end

		return false
	end)
end

function PrimevalStrengthLayer:updatePrimevalStrengthView()
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local metaInfo = posMap[self.pos]
	self.totalExp = 0

	self:sortMetaList(posMap)
	local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
	self.Image_Icon:loadTexture(metaEntry:getValue("Icon"))
	self.Text_Name:setString(metaEntry:getValue("Name"))
	cp.getManager("ViewManager").setTextQuality(self.Text_Name, metaInfo.color)
	
	local model = self.Image_Icon:getChildByName("Effect")
	if model == nil then
		local model = cp.getManager("ViewManager").createSpineAnimation("res/spine/bangpaishengji/bangpaishengji")
		model:setName("Effect")
		model:setTimeScale(2)
		self.Image_Icon:addChild(model)
		model:setPosition(61, -29)
	end

	for i, attrID in ipairs(metaInfo.attr_list) do
		local txtAttrName = self["Text_AttrName"..i]
		local txtAttrBefore = self["Text_AttrBefore"..i]
		local txtAttrAfter = self["Text_AttrAfter"..i]
		txtAttrName:setString(CombatConst.AttributeList[attrID])
		local valueBefore = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, metaInfo.color, metaInfo.level)
		local valueAfter = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, metaInfo.color, metaInfo.level)
		txtAttrBefore:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueBefore, 0.01))
		txtAttrAfter:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueAfter, 0.01))
		cp.getManager("ViewManager").setTextQuality(txtAttrBefore, 2)
		cp.getManager("ViewManager").setTextQuality(txtAttrAfter, 2)
	end
	self.Text_LevelBefore:setString(metaInfo.level)
	self.Text_LevelAfter:setString(metaInfo.level)
	self.cellView:reloadData()
end

function PrimevalStrengthLayer:oneKeySelect(quality)
	self.posList = {}
	for _, metaInfo in ipairs(self.metaList) do
		if metaInfo.color <= quality and metaInfo.level == 1 then
			table.insert(self.posList, metaInfo.pos)
		end
	end
	
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local originMetaInfo = posMap[self.pos]
	self.totalExp = 0
	self.highQuality = false
	local maxExp = cp.getUtils("DataUtils").GetMetaStrengthExp(originMetaInfo.color, originMetaInfo.level, originMetaInfo.exp, 30)
	for i, pos in ipairs(self.posList) do
		local sMetaInfo = posMap[pos]
		self.totalExp = self.totalExp + cp.getUtils("DataUtils").GetMetaExp(sMetaInfo.color, sMetaInfo.level, sMetaInfo.exp)
		if sMetaInfo.color >= 5 then
			self.highQuality = true
		end
		if self.totalExp >= maxExp then
			self.posList = table.arrSlice(self.posList, 1, i)
			break
		end
	end

	local totalSilver = cp.getUtils("DataUtils").GetStrengthNeedSilver(self.totalExp)
	local dstLevel, remainExp, maxExp = cp.getUtils("DataUtils").GetMetaUpgrade(originMetaInfo.color, originMetaInfo.level, originMetaInfo.exp, self.totalExp)
	if dstLevel == 30 then
		self.DynamicBar_Exp_L:initProgress(maxExp, maxExp)
	else
		self.DynamicBar_Exp_L:initProgress(maxExp, remainExp)
	end
	self.Text_LevelAfter:setString(dstLevel)
	self.Text_Cost:setString(totalSilver)
	
	for i, attrID in ipairs(originMetaInfo.attr_list) do
		local txtAttrName = self["Text_AttrName"..i]
		local txtAttrBefore = self["Text_AttrBefore"..i]
		local txtAttrAfter = self["Text_AttrAfter"..i]
		txtAttrName:setString(CombatConst.AttributeList[attrID])
		local valueBefore = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, originMetaInfo.color, originMetaInfo.level)
		local valueAfter = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, originMetaInfo.color, dstLevel)
		txtAttrBefore:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueBefore, 0.01))
		txtAttrAfter:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, valueAfter, 0.01))
		cp.getManager("ViewManager").setTextQuality(txtAttrBefore, 2)
		cp.getManager("ViewManager").setTextQuality(txtAttrAfter, 2)
	end

	self.cellView:reloadData()
end

function PrimevalStrengthLayer:onBtnClick(sender)
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
    local nodeName = sender:getName()
    if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_Select" then
		local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
		local metaInfo = posMap[self.pos]
		if metaInfo.level == 30 then
			cp.getManager("ViewManager").gameTip("混元已經強化到最高等級")
			return
		end
		
		local layer = require("cp.view.scene.public.PublicColorLayer"):create(mode, {4})
		self:addChild(layer, 100)
	elseif nodeName == "Button_Strength" then
		if #self.posList == 0 then
			cp.getManager("ViewManager").gameTip("未選中任何強化材料")
			return
		end
		
		local cost = tonumber(self.Text_Cost:getString())
        if cp.getManager("ViewManager").checkSilverEnough(cost) then
			if self.highQuality then
				local layer = require("cp.view.ui.messagebox.GameMessagePanel"):create("提示", 
					[[
						<t  fs="20"  tc="4C331FFF">
							消耗品種含有<t  fs="20"  t="高品質"  tc="6"  oc="6"  os="2"/>混元，是否繼續操作？
						</t>
					]])
				self:addChild(layer, 100)
				layer:setConfirmCallback(function()
					local req = {}
					req.pos_list = self.posList
					req.pos = self.pos
					self:doSendSocket(cp.getConst("ProtoConst").StrengthMetaReq, req)
				end)
				return
			end
			local req = {}
			req.pos_list = self.posList
			req.pos = self.pos
			self:doSendSocket(cp.getConst("ProtoConst").StrengthMetaReq, req)
        end
    end
end

function PrimevalStrengthLayer:onEnterScene()
    self:updatePrimevalStrengthView()
end

function PrimevalStrengthLayer:onExitScene()
end

return PrimevalStrengthLayer