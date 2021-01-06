local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalPackageLayer = class("PrimevalPackageLayer", BLayer)

function PrimevalPackageLayer:create(pack, place)
    local scene = PrimevalPackageLayer.new(pack, place)
    return scene
end

function PrimevalPackageLayer:initListEvent()
    self.listListeners = {
		["LearnMetalRsp"] = function(data)
			if #data.meta_list == 1 then
				self:showLearnOnceEffect(data.meta_list[1], data.master_list[1])
			else
				self:showLearnTenthEffect(data.meta_list, data.master_list)
			end
		end,
		["ExpandSpaceRsp"] = function(data)
			local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
			local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
			self.Text_Space:setString(string.format("%d/%d", table.nums(posMap), primevalData.space))
		end,
		["FilterPrimeval"] = function(data)
			if data.parent == "PrimevalPackageLayer" then
				self.color = data.color
				self.id = data.id
				self:updatePrimevalPackageView()
			end
		end,
		["SellMetaRsp"] = function(data)
			self:updatePrimevalPackageView()
		end,
		["EquipMetaRsp"] = function(data)
			self:removeFromParent()
			--self:updatePrimevalPackageView()
		end,
		["PrimevalEquipMetaByPos"] = function(pos)
			if self.pack and self.place then
				local req = {
					equip_list = {
						{
							pos = pos,
							pack = self.pack,
							place = self.place,
						}
					}
				}
				self:doSendSocket(cp.getConst("ProtoConst").EquipMetaReq, req)
			end
		end,
		["StrengthMetaRsp"] = function(data)
			self:updatePrimevalPackageView()
		end
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalPackageLayer:onInitView(pack, place)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_package.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	self.width = 144
	self.height = 178
	self.maxColumn = 4
	self.modelList = {}
	self.id = {}
	self.color = {1, 2, 3, 4, 5, 6}
	self.metaList = {}

	self.pack = pack
	self.place = place

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_8"] = {name = "Image_8"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Panel_Meta"] = {name = "Panel_Meta"},
		["Panel_root.Image_1.Panel_Meta.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.Button_Type"] = {name = "Button_Type", click="onBtnClick"},
		["Panel_root.Image_1.Button_Sell"] = {name = "Button_Sell", click="onBtnClick"},
		["Panel_root.Image_1.Button_Expand"] = {name = "Button_Expand", click="onBtnClick"},
		["Panel_root.Image_1.Text_Space"] = {name = "Text_Space"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.Image_8, self.Panel_Meta})
    ccui.Helper:doLayout(self.rootView)
    self.Image_Model:setVisible(false)

	cp.getManager("ConfigManager").foreach("PrimevalChaos", function(entry)
		table.insert(self.id, entry:getValue("ID"))
		return true
	end)
	
	self:initCellView()
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function PrimevalPackageLayer:initCellView()
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

function PrimevalPackageLayer:cellFactory(cellview, idx)
	local model = nil
	local cell = cellview:dequeueCell()

    if nil == cell then
		cell = cc.TableViewCell:new()
		model = self.Image_Model:clone()
		model:setName("Image_Meta")
		local size = model:getContentSize()
		model:setPosition(size.width/2, size.height/2)
		cell:addChild(model)
	else
		model = cell:getChildByName("Image_Meta")
    end

	model:setVisible(true)
	local txtName = model:getChildByName("Text_Name")
	local imgIcon = model:getChildByName("Image_Icon")
	local txtLevel = model:getChildByName("Text_Level")
	local imgTag = model:getChildByName("Image_Tag")
	local imgColor = model:getChildByName("Image_Color")

	local metaInfo = self.metaList[idx]
	imgIcon:loadTexture(metaInfo.entry:getValue("Icon"))
	cp.getManager("ViewManager").setTextQuality(txtName, metaInfo.color)
	txtName:setString(metaInfo.entry:getValue("Name"))
	txtLevel:setString("LV."..metaInfo.level)
    imgTag:ignoreContentAdaptWithSize(true)
	imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)

	imgTag:setVisible(false)
	if metaInfo.pack > 0 and metaInfo.place > 0 then
		imgTag:setVisible(true)
		imgTag:loadTexture("ui_primeval_module14_wuxue_yizhuangbei.png", ccui.TextureResType.plistType)
	end

	if metaInfo.idx ~= 0 then
		imgTag:setVisible(true)
		imgTag:loadTexture("ui_common_xin.png", ccui.TextureResType.plistType)
	end

	imgIcon:addTouchEventListener(function(sender, event)
		if event == cc.EventCode.ENDED then
			local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
			if distance < 50 then
				if metaInfo.pack == 0 or metaInfo.place == 0 then
					imgTag:setVisible(false)
				end
				if metaInfo.pack > 0 and metaInfo.place > 0 and not self.pack and not self.place then
					cp.getManager("ViewManager").gameTip("該混元已裝備")
					return
				end
				metaInfo.idx = 0
				local layer = require("cp.view.scene.primeval.PrimevalMetaLayer"):create(metaInfo.pos)
				self:addChild(layer, 100)
			end
		end
	end)
    return cell
end

function PrimevalPackageLayer:sortMetaList(metaList)
	self.metaList = {}
	for _, metaInfo in pairs(metaList) do
		if metaInfo.id > 0 and table.indexof(self.color, metaInfo.color) and table.indexof(self.id, metaInfo.id) then
			table.insert(self.metaList, metaInfo)
		end
	end
	cp.getUtils("DataUtils").quick_sort(self.metaList, function(a, b)
		if a.level > b.level then
			return true
		elseif a.level < b.level then
			return false
		else	
			if a.color > b.color then
				return true
			elseif a.color < b.color then
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

function PrimevalPackageLayer:updatePrimevalPackageView()
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	self:sortMetaList(posMap)
	
	self.cellView:reloadData()

	self.Text_Space:setString(string.format("%d/%d", table.nums(posMap), primevalData.space))
end

function PrimevalPackageLayer:onBtnClick(sender)
	local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
    local nodeName = sender:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
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
	elseif nodeName == "Button_Type" then
		local layer = require("cp.view.scene.primeval.PrimevalTypeLayer"):create(self.color, self.id, "PrimevalPackageLayer")
		self:addChild(layer, 100)
	elseif nodeName == "Button_Sell" then
		local layer = require("cp.view.scene.primeval.PrimevalSellLayer"):create()
		self:addChild(layer, 100)
    end
end

function PrimevalPackageLayer:onEnterScene()
    self:updatePrimevalPackageView()
end

function PrimevalPackageLayer:onExitScene()
end

return PrimevalPackageLayer