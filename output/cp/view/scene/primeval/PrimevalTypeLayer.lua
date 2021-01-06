local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalTypeLayer = class("PrimevalTypeLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function PrimevalTypeLayer:create(color, id, parent)
    local scene = PrimevalTypeLayer.new(color, id, parent)
    return scene
end

function PrimevalTypeLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalTypeLayer:onInitView(color, id, parent)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_type.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	self.width = 144
	self.height = 178
	self.maxColumn = 4
	self.id = {}
	self.color = {1,2,3,4,5,6}
	self.parent = parent

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_8"] = {name = "Image_8"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_OK"] = {name = "Button_OK", click="onBtnClick"},
		["Panel_root.Image_1.Button_Color1"] = {name = "Button_Color1", click="onColorClick"},
		["Panel_root.Image_1.Button_Color2"] = {name = "Button_Color2", click="onColorClick"},
		["Panel_root.Image_1.Button_Color3"] = {name = "Button_Color3", click="onColorClick"},
		["Panel_root.Image_1.Button_Color4"] = {name = "Button_Color4", click="onColorClick"},
		["Panel_root.Image_1.Button_Color5"] = {name = "Button_Color5", click="onColorClick"},
		["Panel_root.Image_1.Button_Color6"] = {name = "Button_Color6", click="onColorClick"},
		["Panel_root.Image_1.ScrollView_Meta"] = {name = "ScrollView_Meta"},
		["Panel_root.Image_1.ScrollView_Meta.Image_Model"] = {name = "Image_Model"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_8, self.Image_1, self.ScrollView_Meta})
    ccui.Helper:doLayout(self.rootView)
    self.Image_Model:setVisible(false)
	self.ScrollView_Meta:setScrollBarEnabled(false)
	
	self:initCellView()
	self.metaList = {}
	cp.getManager("ConfigManager").foreach("PrimevalChaos", function(entry)
		table.insert(self.metaList, entry)
		table.insert(self.id, entry:getValue("ID"))
		return true
	end)

	for i=1, 6 do
		local nm = "Button_Color"..i
		local btn = self[nm]
		if table.indexof(self.color, i) then
			local textureName = "ui_common_module_bangpai_7.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		else
			local textureName = "ui_common_module_bangpai_6.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		end
	end
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function PrimevalTypeLayer:initCellView()
	local sz = self.ScrollView_Meta:getContentSize()
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
	self.cellView:setPosition(cc.p(self.ScrollView_Meta:getPositionX(), self.ScrollView_Meta:getPositionY()))
	self.Image_1:addChild(self.cellView)
end

function PrimevalTypeLayer:cellFactory(cellview, idx)
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
	local imgFlag = model:getChildByName("Image_Flag")

	local metaEntry = self.metaList[idx]
	imgIcon:loadTexture(metaEntry:getValue("Icon"))
	txtName:setString(metaEntry:getValue("Name"))
	if table.indexof(self.id, metaEntry:getValue("ID")) then
		imgFlag:setVisible(true)
	else
		imgFlag:setVisible(false)
	end

	cp.getManager("ViewManager").initButton(imgIcon, function()
		self.id = {metaEntry:getValue("ID")}
		self:updatePrimevalTypeView()
	end, 1.0)

    return cell
end

function PrimevalTypeLayer:updatePrimevalTypeView()
	self.cellView:reloadData()
end

function PrimevalTypeLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_OK" then
		local filterInfo = {
			color = self.color,
			id = self.id,
			parent = self.parent
		}
		self:dispatchViewEvent("FilterPrimeval", filterInfo)
		self:removeFromParent()
    end
end

function PrimevalTypeLayer:onColorClick(sender)
    local nodeName = sender:getName()
	for i=1, 6 do
		local nm = "Button_Color"..i
		local btn = self[nm]
		if nm == nodeName then
			self.color = {i}
			local textureName = "ui_common_module_bangpai_7.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		else
			local textureName = "ui_common_module_bangpai_6.png"
			btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		end
	end
end


function PrimevalTypeLayer:onEnterScene()
    self:updatePrimevalTypeView()
end

function PrimevalTypeLayer:onExitScene()
end

return PrimevalTypeLayer