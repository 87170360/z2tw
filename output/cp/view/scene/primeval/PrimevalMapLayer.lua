local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalMapLayer = class("PrimevalMapLayer", BLayer)

function PrimevalMapLayer:create(pack)
    local scene = PrimevalMapLayer.new(pack)
    return scene
end

function PrimevalMapLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalMapLayer:onInitView(pack)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_map.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	self.width = 576
	self.height = 150
	self.maxColumn = 1
	self.pack = pack

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_OK"] = {name = "Button_OK", click="onBtnClick"},
		["Panel_root.Image_1.ScrollView_Meta"] = {name = "ScrollView_Meta"},
		["Panel_root.Image_1.ScrollView_Meta.Image_Model"] = {name = "Image_Model"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_8, self.Image_1, self.ScrollView_Meta})
    ccui.Helper:doLayout(self.rootView)
    self.Image_Model:setVisible(false)
	self.ScrollView_Meta:setScrollBarEnabled(false)
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)

	self:initCellView()
	self.metaList = {}
	cp.getManager("ConfigManager").foreach("PrimevalChaos", function(entry)
		table.insert(self.metaList, entry)
		return true
	end)

	self.metaCount = cp.getUserData("UserPrimeval"):getMetaIDCount()
end

function PrimevalMapLayer:initCellView()
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

function PrimevalMapLayer:sortMeta(id)
	local metaList = {}
	local temp = cp.getUserData("UserPrimeval"):getMetaByID(id)
	for _, metaInfo in pairs(temp) do
		if metaInfo.pack == 0 and metaInfo.place == 0 then
			table.insert(metaList, metaInfo)
		end
	end
	
	cp.getUtils("DataUtils").quick_sort(metaList, function(a, b)
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
				return false
			end
		end

		return false
	end)
	return metaList
end

function PrimevalMapLayer:cellFactory(cellview, idx)
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
	local richText = model:getChildByName("RichText_PrimevalEffect")
	local btnEquip = model:getChildByName("Button_Equip")
	local txtCount = model:getChildByName("Text_Count")

	cp.getManager("ViewManager").setTextQuality(txtCount, 2)
	if self.pack then
		btnEquip:setVisible(true)
	else
		btnEquip:setVisible(false)
	end
	local metaEntry = self.metaList[idx]
	imgIcon:loadTexture(metaEntry:getValue("Icon"))
	txtName:setString(metaEntry:getValue("Name"))

	local id = metaEntry:getValue("ID")
	if self.metaCount[id] then
		txtCount:setString(self.metaCount[id])
	else
		txtCount:setString("0")
	end

	if richText then
		richText:removeFromParent()
	end

	local eventList = cp.getUtils("DataUtils").split(metaEntry:getValue("EventList"), ";")
	local richText = cp.getUtils("DataUtils").formatPrimevalEffect(1, 1, eventList, "", 250)
	richText:setPosition(cc.p(156,77))
	model:addChild(richText, 100)

	cp.getManager("ViewManager").initButton(btnEquip, function()
		local metaList = self:sortMeta(metaEntry:getValue("ID"))
		if #metaList == 0 then
			return
		end

		local equipMap = cp.getUserData("UserPrimeval"):getValue("EquipMap")
		local equipList = {}
		local placeList = {}
		for i=1, 6 do
			local equipPos = bit.lshift(self.pack, 16) + i
			local metaInfo = equipMap[equipPos]
			if not metaInfo or metaInfo.id ~= metaEntry:getValue("ID") then
				table.insert(placeList, i)
			end
		end

		for i, place in ipairs(placeList) do
			local metaInfo = metaList[i]
			local equipInfo = {
				pos = 0,
				pack = self.pack,
				place = place,
			}

			if metaInfo then
				equipInfo.pos = metaInfo.pos
				table.insert(equipList, equipInfo)
			end
		end
		local req = {}
		req.equip_list = equipList
		self:doSendSocket(cp.getConst("ProtoConst").EquipMetaReq, req)
	end)

    return cell
end

function PrimevalMapLayer:updatePrimevalMapView()
	self.cellView:reloadData()
end

function PrimevalMapLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" or nodeName == "Button_OK" then
		self:removeFromParent()
    end
end

function PrimevalMapLayer:onEnterScene()
    self:updatePrimevalMapView()
end

function PrimevalMapLayer:onExitScene()
end

return PrimevalMapLayer