local BLayer = require "cp.view.ui.base.BLayer"
local SkillPieceDecomposeLayer = class("SkillPieceDecomposeLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillPieceDecomposeLayer:create(openInfo)
    local scene = SkillPieceDecomposeLayer.new()
    return scene
end

function SkillPieceDecomposeLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").DecomposeSkillPiecesRsp] = function(data)
			self.selectList = {}
			self.learnPoint = 0
			self:updateDecomposeSkillPiecesView()
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillPieceDecomposeLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_decompose_item.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.selectList = {}
	self.deltaX = 28
	self.deltaY = 30
	self.itemSize = 90
	self.itemModelList = {}
	self.learnPoint = 0

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_LearnPoint"] = {name = "Text_LearnPoint"},
		["Panel_root.Image_1.Text_GainPoint"] = {name = "Text_GainPoint"},
		["Panel_root.Image_1.ScrollView_Item"] = {name = "ScrollView_Item"},
		["Panel_root.Image_1.ScrollView_Item.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Decompose"] = {name = "Button_Decompose", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root, function()
		if self.closeCallback then
			self.closeCallback()
		end
	end)
	
	self.Image_Model:setVisible(false)
	self:setTouchEnabled(true)
    self.ScrollView_Item:setScrollBarEnabled(false)
    self.ScrollView_Item:onTouch(function(event)
		if event.name == "ended" then
			local touchItem = self:getItemByPos(event.x, event.y)
			if touchItem and touchItem <= #self.itemList then
				self:onSelectItem(touchItem)
			end
		end
	end)
	
	self:updateDecomposeSkillPiecesView()
end

function SkillPieceDecomposeLayer:getItemByPos(posX, posY)
	posY = posY-self.ScrollView_Item:getPositionY()-(self.Image_1:getPositionY()-self.Image_1:getSize().height/2)
	posY=self.ScrollView_Item:getSize().height-posY
	posX = posX - self.ScrollView_Item:getPositionX()-(self.Image_1:getPositionX()-self.Image_1:getSize().width/2)
	local deltaY = self.ScrollView_Item:getInnerContainerSize().height - self.ScrollView_Item:getSize().height
	posY = posY + deltaY + self.ScrollView_Item:getInnerContainerPosition().y
	local row = math.ceil(posY/(self.deltaY+self.itemSize))
	local col = math.ceil(posX/(self.deltaX+self.itemSize))

	if math.abs(posX - (col-1)*(self.deltaX+self.itemSize)) > self.itemSize or math.abs(posY - (row-1)*(self.deltaY+self.itemSize)) > self.itemSize then
		return nil
	end

	return (row-1)*5+col
end

function SkillPieceDecomposeLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:getParent():removeChild(self)
	elseif nodeName == "Button_Decompose" then
		local req = {}
		req.item_list = {}
		for _, itemID in ipairs(self.selectList) do
			table.insert(req.item_list, {
				item_id = itemID,
				item_num = self.itemNumList[itemID]
			})
		end
		if #req.item_list == 0 then
            cp.getManager("ViewManager").gameTip("請選擇要分解的物品")
			return
		end
		self:doSendSocket(cp.getConst("ProtoConst").DecomposeSkillPiecesReq, req)
	end
end

function SkillPieceDecomposeLayer:sortItemList(itemList)
	table.sort(itemList, function(a, b)
		return a:getValue("Hierarchy") > b:getValue("Hierarchy")
	end)
end

function SkillPieceDecomposeLayer:updateDecomposeSkillPiecesView()
	self.itemList = {}
	self.itemNumList = cp.getUserData("UserItem"):getItemList()
	for itemID, itemNum in pairs(self.itemNumList) do
		local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
		if (itemEntry and itemEntry:getValue("Type") == 2 and itemEntry:getValue("SubType") == 1) or
			(itemEntry and itemEntry:getValue("Type") == 4 and itemEntry:getValue("SubType") == 1) then
			table.insert(self.itemList, itemEntry)
		end
	end

	self.Text_LearnPoint:setString(tostring(cp.getUserData("UserSkill"):getLearnPoint()))

	self:sortItemList(self.itemList)

	local totalRow = math.floor((#self.itemList-1)/5)+1
	self.ScrollView_Item:setInnerContainerSize(cc.size(446, totalRow*self.itemSize+totalRow*self.deltaY))

	local beginX = self.itemSize/2
	local beginY = self.ScrollView_Item:getInnerContainerSize().height - self.itemSize/2

	for i, itemEntry in ipairs(self.itemList) do
		local model = nil
		if self.itemModelList[i] == nil then
			model = self.Image_Model:clone()
			self.ScrollView_Item:addChild(model)
			self.itemModelList[i] = model
		else
			model = self.itemModelList[i]
		end

		model:setVisible(true)
		local hierarchy = itemEntry:getValue("Hierarchy")
		local imgIcon = model:getChildByName("Image_Icon")
		local imgBox = model:getChildByName("Image_Box")
		local imgMask = model:getChildByName("Image_Mask")
		local textNumber = model:getChildByName("Text_Number")
		local textName = model:getChildByName("Text_Name")
		local imgSelect = model:getChildByName("Image_Select")
		imgIcon:loadTexture(itemEntry:getValue("Icon"))
		imgMask:setVisible(false)
		textNumber:setString(cp.getUserData("UserItem"):getItemNum(itemEntry:getValue("ID")))
		textName:setString(itemEntry:getValue("Name"))
		cp.getManager("ViewManager").setTextQuality(textName, itemEntry:getValue("Hierarchy"))
		imgSelect:setVisible(false)
		imgBox:loadTexture(CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
		model:loadTexture(CombatConst.QualityBottomList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)

		local row = math.floor((i-1)/5)+1
		local col = math.floor((i-1)%5)+1
		model:setPosition(cc.p(beginX+(self.deltaX+self.itemSize)*(col-1), beginY - (row-1)*(self.deltaY+self.itemSize)))
	end

	for i=#self.itemList+1, #self.itemModelList do
		self.itemModelList[i]:setVisible(false)
	end
	self.Text_GainPoint:setString(self.learnPoint)
end

function SkillPieceDecomposeLayer:onSelectItem(index)
	local model = self.itemModelList[index]
	local select = model:getChildByName("Image_Select")

	local itemEntry = self.itemList[index]
	for _, itemID in ipairs(self.selectList) do
		if itemID == itemEntry:getValue("ID") then
			select:setVisible(false)
			table.removebyvalue(self.selectList, itemEntry:getValue("ID"))
			if itemEntry:getValue("Type") == 2 then
				self.learnPoint = self.learnPoint - cp.getUtils("DataUtils").GetDecomposePiecesPoint(itemEntry:getValue("Hierarchy"))*self.itemNumList[itemID]
			else
				self.learnPoint = self.learnPoint - cp.getUtils("DataUtils").GetDecomposeBookPoint(itemEntry:getValue("Hierarchy"))*self.itemNumList[itemID]
			end
			self.Text_GainPoint:setString(self.learnPoint)
			return
		end
	end

	select:setVisible(true)

	if itemEntry:getValue("Type") == 2 then
		self.learnPoint = self.learnPoint + cp.getUtils("DataUtils").GetDecomposePiecesPoint(itemEntry:getValue("Hierarchy"))*self.itemNumList[itemEntry:getValue("ID")]
	else
		self.learnPoint = self.learnPoint + cp.getUtils("DataUtils").GetDecomposeBookPoint(itemEntry:getValue("Hierarchy"))*self.itemNumList[itemEntry:getValue("ID")]
	end

	self.Text_GainPoint:setString(self.learnPoint)
	table.insert(self.selectList, itemEntry:getValue("ID"))
end

function SkillPieceDecomposeLayer:onEnterScene()
end

function SkillPieceDecomposeLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function SkillPieceDecomposeLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillPieceDecomposeLayer