local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalMainLayer = class("PrimevalMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

local masterWordsList = {
	"武道一途，勤能補拙。",
	"天行健，君子以自強不息。",
	"士不可以不弘毅，任重而道遠。",
	"天之道，損有餘而補不足。",
	"變動不居，周流六虛，上下無常，剛柔相易。"
}
function PrimevalMainLayer:create()
    local scene = PrimevalMainLayer.new()
    return scene
end

function PrimevalMainLayer:initListEvent()
    self.listListeners = {
		["PrimevalData"] = function(data)
			self.Button_Once:setEnabled(true)
			self.Button_Tenth:setEnabled(true)
		end,
		["LearnMetalRsp"] = function(data)
			if data.result ~= 0 then
				self.Button_Once:setEnabled(true)
				self.Button_Tenth:setEnabled(true)
				return
			end
			if #data.meta_list == 1 then
				self:showLearnOnceEffect(data.meta_list[1], data.master_list[1])
			else
				self:showLearnTenthEffect(data.meta_list, data.master_list)
			end
		end,
		["ExpandSpaceRsp"] = function(data)
			local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
			local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
			self.Text_Space:setString(string.format("%d/%d", table.nums(posMap), primevalData.space))
		end,
		["FilterPrimeval"] = function(data)
			if data.parent == "PrimevalMainLayer" then
				self.color = data.color
				self.id = data.id
				self:updatePrimevalMainView()
			end
		end,
		["SellMetaRsp"] = function(data)
			self:updatePrimevalMainView()
		end,
		["StrengthMetaRsp"] = function(data)
			self:updatePrimevalMainView()
		end,
		["EquipMetaRsp"] = function(data)
			self:updatePrimevalMainView()
		end
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalMainLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_main.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	self.height = 160
	self.width = 127
	self.maxColumn = 5
	self.modelList = {}
	self.id = {}
	self.color = {1, 2, 3, 4, 5, 6}
	self.metaList = {}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Node_Pos"] = {name = "Node_Pos"},
		["Panel_root.Image_1.Text_Words"] = {name = "Text_Words"},
		["Panel_root.Image_1.Image_2"] = {name = "Image_2"},
		["Panel_root.Image_1.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rule"] = {name = "Button_Rule", click="onBtnClick"},
		["Panel_root.Image_1.Image_2.Panel_Meta"] = {name = "Panel_Meta"},
		["Panel_root.Image_1.Image_2.Panel_Meta.Image_MetaModel"] = {name = "Image_MetaModel"},
		["Panel_root.Image_1.Image_2.Button_Type"] = {name = "Button_Type", click="onBtnClick"},
		["Panel_root.Image_1.Image_2.Button_Sell"] = {name = "Button_Sell", click="onBtnClick"},
		["Panel_root.Image_1.Image_2.Button_Expand"] = {name = "Button_Expand", click="onBtnClick"},
		["Panel_root.Image_1.Image_2.Text_Space"] = {name = "Text_Space"},
		["Panel_root.Image_1.Image_Master1"] = {name = "Image_Master1"},
		["Panel_root.Image_1.Image_Master2"] = {name = "Image_Master2"},
		["Panel_root.Image_1.Image_Master3"] = {name = "Image_Master3"},
		["Panel_root.Image_1.Image_Master4"] = {name = "Image_Master4"},
		["Panel_root.Image_1.Image_Master5"] = {name = "Image_Master5"},
		["Panel_root.Image_1.Button_Tenth"] = {name = "Button_Tenth", click="onBtnClick"},
		["Panel_root.Image_1.Button_Once"] = {name = "Button_Once", click="onBtnClick"},
		["Panel_root.Image_1.Button_Equip"] = {name = "Button_Equip", click="onBtnClick"},
		["Panel_root.Image_1.Text_TenthCost"] = {name = "Text_TenthCost"},
		["Panel_root.Image_1.Text_OnceCost"] = {name = "Text_OnceCost"},
		["Panel_root.Image_1.Text_FreeCount"] = {name = "Text_FreeCount"},
		["Panel_root.Image_1.Image_TenthCost"] = {name = "Image_TenthCost"},
		["Panel_root.Image_1.Image_OnceCost"] = {name = "Image_OnceCost"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.Image_2, self.Panel_Meta})
    ccui.Helper:doLayout(self.rootView)
    self.Image_MetaModel:setVisible(false)

	cp.getManager("ConfigManager").foreach("PrimevalChaos", function(entry)
		table.insert(self.id, entry:getValue("ID"))
		return true
	end)
	
	self.primevalConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("PrimevalConfig"), ";")
	self:initCellView()
end

function PrimevalMainLayer:initCellView()
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

function PrimevalMainLayer:cellFactory(cellview, idx)
	local model = nil 
	local cell = cellview:dequeueCell()

    if nil == cell then
		cell = cc.TableViewCell:new()
		model = self.Image_MetaModel:clone()
		model:setName("Image_Meta")
		local size = model:getContentSize()
		model:setPosition(size.width/2, size.height/2+25)
		cell:addChild(model)
	else
		model = cell:getChildByName("Image_Meta")
    end

	model:setVisible(true)
	local txtLevel = model:getChildByName("Text_Level")
	local txtName = model:getChildByName("Text_Name")
	local imgTag = model:getChildByName("Image_Tag")
	local imgColor = model:getChildByName("Image_Color")

	local metaInfo = self.metaList[idx]
	model:loadTexture(metaInfo.entry:getValue("Icon"))
	cp.getManager("ViewManager").setTextQuality(txtName, metaInfo.color)
	txtName:setString(metaInfo.entry:getValue("Name"))
	txtLevel:setString("LV."..metaInfo.level)
	imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)

    imgTag:ignoreContentAdaptWithSize(true)

	imgTag:setVisible(false)
	if metaInfo.pack > 0 and metaInfo.place > 0 then
		imgTag:setVisible(true)
		imgTag:loadTexture("ui_primeval_module14_wuxue_yizhuangbei.png", ccui.TextureResType.plistType)
	end

	if metaInfo.idx ~= 0 then
		imgTag:setVisible(true)
		imgTag:loadTexture("ui_common_xin.png", ccui.TextureResType.plistType)
	end

	model:addTouchEventListener(function(sender, event)
		if event == cc.EventCode.ENDED then
			local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
			if distance < 50 then
				local layer = require("cp.view.scene.primeval.PrimevalMetaLayer"):create(metaInfo.pos, true)
				self:addChild(layer, 100)
			end
		end
	end)

    return cell
end

function PrimevalMainLayer:showLearnOnceEffect(metaInfo, master)
	local posX, posY = self.Node_Pos:getPosition()
	local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
	local imgMeta = ccui.ImageView:create()
	imgMeta:loadTexture(metaEntry:getValue("Icon"))
	local imgColor = ccui.ImageView:create()
	imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)
	imgColor:setPosition(cc.p(63.5,68.5))
	imgMeta:addChild(imgColor)
	local imgMaster = self["Image_Master"..master]
	imgMeta:setPosition(360, 452)
	imgMeta:addTo(self.Image_1, 100)
	imgMeta:setVisible(false)
	self.Text_Words:setVisible(true)
	self.Text_Words:setString(masterWordsList[master])
	local spriteEffect = imgMaster:getChildByName("Sprite_Effect")
	spriteEffect:setPosition(79, 93.5)
	spriteEffect:stopAllActions()
	local animation1 = cp.getManager("ViewManager").createEffectAnimation("hunyuan_click", 0.016666666, 1)
	local animation2 = cp.getManager("ViewManager").createEffectAnimation("hunyuan_bloomup", 0.0333333, 1)
	local effectPosX, effectPosY = 360 - imgMaster:getPositionX() + 82, 452 - imgMaster:getPositionY() + 93.5
	spriteEffect:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(effectPosX, effectPosY)), cc.Animate:create(animation1)),
		cc.Animate:create(animation2), cc.CallFunc:create(function()
			spriteEffect:setVisible(false)
			imgMeta:runAction(cc.Sequence:create(cc.CallFunc:create(function()
				imgMeta:setVisible(true)
			end),cc.DelayTime:create(0.3), cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(posX,posY)), cc.ScaleTo:create(0.4, 0.5, 0.5)),
				cc.CallFunc:create(function()
					imgMeta:removeFromParent()
					self.Text_Words:setVisible(false)
					self:updatePrimevalMainView(metaInfo.idx)
					self.Button_Once:setEnabled(true)
					self.Button_Tenth:setEnabled(true)
			end)))
	end)))
	spriteEffect:setVisible(true)
end

function PrimevalMainLayer:updateMaster(master)
	for i=1,5 do
		local imgMaster = self["Image_Master"..i]
		if i == master then
			imgMaster:loadTexture("ui_primeval_module98_hunyuan_2.png", ccui.TextureResType.plistType)
		else
			local tname = string.format("ui_primeval_module98_hunyuan_3_%d.png", i)
			imgMaster:loadTexture(tname, ccui.TextureResType.plistType)
		end
	end
end

function PrimevalMainLayer:showLearnTenthEffect(metaList, masterList)
	local posX, posY = self.Node_Pos:getPosition()
	local imgMeta = ccui.ImageView:create()
	imgMeta:addTo(self.Image_1, 100)
	
	local imgColor = ccui.ImageView:create()
	imgColor:setPosition(cc.p(63.5,68.5))
	imgColor:setName("Image_Color")
	imgMeta:addChild(imgColor)

	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local sequence = {}
	for i, metaInfo in ipairs(metaList) do
		local master = masterList[i]
		local action1 = cc.CallFunc:create(function()
			local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
			local imgColor = imgMeta:getChildByName("Image_Color")
			imgMeta:loadTexture(metaEntry:getValue("Icon"))
			imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)
			imgMeta:setScale(1)
			local imgMaster = self["Image_Master"..master]
			local spriteEffect = imgMaster:getChildByName("Sprite_Effect")
			spriteEffect:setPosition(79, 93.5)
			spriteEffect:stopAllActions()
			spriteEffect:setVisible(true)
			imgMeta:setVisible(false)
			
			imgMeta:setPosition(360, 452)
			self:updateMaster(master)
			self.Text_Space:setString(string.format("%d/%d", table.nums(posMap), primevalData.space))

			local animation1 = cp.getManager("ViewManager").createEffectAnimation("hunyuan_click", 0.016666666, 1)
			local animation2 = cp.getManager("ViewManager").createEffectAnimation("hunyuan_bloomup", 0.0333333, 1)
			local effectPosX, effectPosY = 360 - imgMaster:getPositionX() + 82, 452 - imgMaster:getPositionY() + 93.5
			spriteEffect:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(effectPosX, effectPosY)), cc.Animate:create(animation1)),
				cc.Animate:create(animation2), cc.CallFunc:create(function()
					spriteEffect:setVisible(false)
					imgMeta:setVisible(true)
			end)))
		end)
		local action2 = cc.DelayTime:create(1.3)
		local action3 = cc.Spawn:create(cc.MoveTo:create(0.4, cc.p(posX, posY)), cc.ScaleTo:create(0.4, 0.5, 0.5))
		local action4 = cc.CallFunc:create(function()
			self:updatePrimevalMainView(metaInfo.idx)
		end)
		table.insert(sequence, action1)
		table.insert(sequence, action2)
		table.insert(sequence, action3)
		table.insert(sequence, action4)
	end

	table.insert(sequence, cc.CallFunc:create(function()
		imgMeta:removeFromParent()
		self.Button_Once:setEnabled(true)
		self.Button_Tenth:setEnabled(true)
	end))
	imgMeta:runAction(cc.Sequence:create(sequence))
end

function PrimevalMainLayer:sortMetaList(metaList)
	self.metaList = {}
	for _, metaInfo in pairs(metaList) do
		if metaInfo.id > 0 and table.indexof(self.color, metaInfo.color) and table.indexof(self.id, metaInfo.id) and (metaInfo.idx <= self.idx or self.idx == 0) then
			table.insert(self.metaList, metaInfo)
		end
	end
	cp.getUtils("DataUtils").quick_sort(self.metaList, function(a, b)
		if a.idx > b.idx then
			return true
		elseif a.idx < b.idx then
			return false
		end
		if a.color > b.color then
			return true
		elseif a.color < b.color then
			return false
		else
			if a.level > b.level then
				return true
			elseif a.level < b.level then
				return false
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

function PrimevalMainLayer:updatePrimevalMainView(idx)
	if idx then
		self.idx = idx
	else
		self.idx = 0
	end
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	self:sortMetaList(posMap)
	
	self.cellView:reloadData()

	self.Text_Space:setString(string.format("%d/%d", table.nums(posMap), primevalData.space))
	self.Text_TenthCost:setString(self.primevalConfig[6])
	if primevalData.free_learn < self.primevalConfig[7] then
		self.Text_FreeCount:setString(string.format("每日免費次數:%d/%d", self.primevalConfig[7] - primevalData.free_learn, self.primevalConfig[7]))
		self.Text_OnceCost:setString("")
		self.Image_OnceCost:setVisible(false)
	else
		self.Text_FreeCount:setString("")
		self.Text_OnceCost:setString(self.primevalConfig[5])
		self.Image_OnceCost:setVisible(true)
	end

	self:updateMaster(primevalData.master)
	self.selectMaster = primevalData.master

	if cp.getUtils("NotifyUtils").needNotifyPrimevalEquip() then
        cp.getManager("ViewManager").addRedDot(self.Button_Equip,cc.p(187,62))
	else
        cp.getManager("ViewManager").removeRedDot(self.Button_Equip)
	end
	
	if cp.getUtils("NotifyUtils").needNotifyPrimevalFreeBuy() then
        cp.getManager("ViewManager").addRedDot(self.Button_Once,cc.p(187,62))
	else
        cp.getManager("ViewManager").removeRedDot(self.Button_Once)
	end
end

function PrimevalMainLayer:onBtnClick(sender)
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
    local nodeName = sender:getName()
    if nodeName == "Button_Back" then
        self:dispatchViewEvent("GetPrimevalDataRsp", false)
    elseif nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_primeval_rule.txt")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("primeval_rule", desc)
        self:addChild(layer, 100)
	elseif nodeName == "Button_Once" then
		self.Button_Once:setEnabled(false)
		self.Button_Tenth:setEnabled(false)
		local req = {}
		if primevalData.free_learn < self.primevalConfig[7] then
			req.count = 0
		else
			req.count = 1
		end
		self:doSendSocket(cp.getConst("ProtoConst").LearnMetalReq, req)
    elseif nodeName == "Button_Tenth" then
		self.Button_Once:setEnabled(false)
		self.Button_Tenth:setEnabled(false)
		local req = {}
		req.count = 10
		self:doSendSocket(cp.getConst("ProtoConst").LearnMetalReq, req)
	elseif nodeName == "Button_Expand" then
        local need = 200
		local function comfirmFunc()
			--檢測是否元寶足夠
			if cp.getManager("ViewManager").checkGoldEnough(need) then
				local req = {}
				self:doSendSocket(cp.getConst("ProtoConst").ExpandSpaceReq, req)
			end
		end

		local contentTable = {
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=20, text="增加50個混元寶卷空間？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		}

		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2, comfirmFunc)
    elseif nodeName == "Button_Equip" then
		local layer = require("cp.view.scene.primeval.PrimevalEquipLayer"):create(1)
		self:addChild(layer, 100)
	elseif nodeName == "Button_Type" then
		local layer = require("cp.view.scene.primeval.PrimevalTypeLayer"):create(self.color, self.id, "PrimevalMainLayer")
		self:addChild(layer, 100)
    elseif nodeName == "Button_Sell" then
		local layer = require("cp.view.scene.primeval.PrimevalSellLayer"):create()
		self:addChild(layer, 100)
    end
end

function PrimevalMainLayer:onEnterScene()
	self:updatePrimevalMainView()
	
	local result,step = cp.getManager("GDataManager"):checkNeedGuide("primeval_main")
	if result then
		cp.getManager("ViewManager").openNewPlayerGuide("primeval_main",step)
	end
end

function PrimevalMainLayer:onExitScene()
end

return PrimevalMainLayer