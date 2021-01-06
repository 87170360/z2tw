local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalMetaLayer = class("PrimevalMetaLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function PrimevalMetaLayer:create(pos, flag)
    local scene = PrimevalMetaLayer.new(pos, flag)
    return scene
end

function PrimevalMetaLayer:initListEvent()
    self.listListeners = {
		["UpdateMetaLockRsp"] = function(data)
			self:updatePrimevalMetaView()
		end,
		["EquipMetaRsp"] = function(data)
			--self:updatePrimevalMetaView()
			self:removeFromParent()
		end,
		["SellMetaRsp"] = function(data)
			self:removeFromParent()
		end,
		["StrengthMetaRsp"] = function(data)
			self:updatePrimevalMetaView()
		end
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalMetaLayer:onInitView(pos, flag)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_meta.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
	--一開始顯示武學抽獎界面
	self.pos = pos
	self.flag = flag

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Meta"] = {name = "Image_Meta"},
		["Panel_root.Image_1.Button_Lock"] = {name = "Button_Lock", click="onBtnClick"},
		["Panel_root.Image_1.Text_Level"] = {name = "Text_Level"},
		["Panel_root.Image_1.Text_Price"] = {name = "Text_Price"},
		["Panel_root.Image_1.Text_AttrValue1"] = {name = "Text_AttrValue1"},
		["Panel_root.Image_1.Text_AttrValue2"] = {name = "Text_AttrValue2"},
		["Panel_root.Image_1.Text_AttrValue3"] = {name = "Text_AttrValue3"},
		["Panel_root.Image_1.Node_Effect"] = {name = "Node_Effect"},
		["Panel_root.Image_1.Button_Strength"] = {name = "Button_Strength", click="onBtnClick"},
		["Panel_root.Image_1.Button_Replace"] = {name = "Button_Replace", click="onBtnClick"},
		["Panel_root.Image_1.Button_Remove"] = {name = "Button_Remove", click="onBtnClick"},
		["Panel_root.Image_1.Button_Sell"] = {name = "Button_Sell", click="onBtnClick"},
		["Panel_root.Image_1.Button_Equip"] = {name = "Button_Equip", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function PrimevalMetaLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_Lock" then
		local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
		local metaInfo = posMap[self.pos]
		local req = {}
		req.pos = self.pos
		req.lock = not metaInfo.lock
		self:doSendSocket(cp.getConst("ProtoConst").UpdateMetaLockReq, req)
	elseif nodeName == "Button_Strength" then
		local layer = require("cp.view.scene.primeval.PrimevalStrengthLayer"):create(self.pos)
		self:addChild(layer, 100)
	elseif nodeName == "Button_Replace" then
		local layer = require("cp.view.scene.primeval.PrimevalPackageLayer"):create(self.pack, self.place)
		self:addChild(layer, 100)
	elseif nodeName == "Button_Remove" then
		local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
		local metaInfo = posMap[self.pos]
		local req = {
			equip_list = {
				{
					pos = 0,
					pack = metaInfo.pack,
					place = metaInfo.place,
				}
			}
		}
		self:doSendSocket(cp.getConst("ProtoConst").EquipMetaReq, req)
	elseif nodeName == "Button_Sell" then
		local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
		local metaInfo = posMap[self.pos]
		if metaInfo.pack > 0 and metaInfo.place > 0 then
            cp.getManager("ViewManager").gameTip("已裝備混元不能賣出")
			return
		end

		if metaInfo.lock then
            cp.getManager("ViewManager").gameTip("已鎖定混元不能賣出")
			return
		end
		local req = {}
		req.pos_list = {self.pos}
		self:doSendSocket(cp.getConst("ProtoConst").SellMetaReq, req)
	elseif nodeName == "Button_Equip" then
		self:dispatchViewEvent("PrimevalEquipMetaByPos", self.pos)
    end
end

function PrimevalMetaLayer:updatePrimevalMetaView()
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	local metaInfo = posMap[self.pos]
	metaInfo.idx = 0
	local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
	if metaInfo.pack > 0 and metaInfo.place > 0 then
		self.Button_Replace:setVisible(true)
		self.Button_Remove:setVisible(true)
		self.Button_Sell:setVisible(false)
		self.Button_Equip:setVisible(false)
	else
		self.Button_Replace:setVisible(false)
		self.Button_Remove:setVisible(false)
		self.Button_Sell:setVisible(true)
		self.Button_Equip:setVisible(true)
	end

	if self.flag then
		self.Button_Sell:setVisible(true)
		self.Button_Strength:setVisible(true)
		self.Button_Replace:setVisible(false)
		self.Button_Remove:setVisible(false)
		self.Button_Equip:setVisible(false)
		self.Button_Strength:setPositionX(200)
		self.Button_Sell:setPositionX(490)
	end
	
	for i, attrID in ipairs(metaInfo.attr_list) do
		local txtAttrValue = self["Text_AttrValue"..i]
		local value = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, metaInfo.color, metaInfo.level)
		txtAttrValue:setString(cp.getUtils("DataUtils").formatSkillAttribute(attrID, value, 0.01))
		cp.getManager("ViewManager").setTextQuality(txtAttrValue, 2)
	end

	local imgIcon = self.Image_Meta:getChildByName("Image_Icon")
	local imgColor = self.Image_Meta:getChildByName("Image_Color")
	local txtName = self.Image_Meta:getChildByName("Text_Name")
	imgIcon:loadTexture(metaEntry:getValue("Icon"))
	imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)
	txtName:setString(metaEntry:getValue("Name"))
	cp.getManager("ViewManager").setTextQuality(txtName, metaInfo.color)
	self.Text_Level:setString("等級"..metaInfo.level)
	local price = cp.getUtils("DataUtils").GetMetaSellSilver(metaInfo.color, metaInfo.level)
	self.Text_Price:setString("售價"..price)
	cp.getManager("ViewManager").setTextQuality(self.Text_Level, 5)
	cp.getManager("ViewManager").setTextQuality(self.Text_Price, 3)
	local eventList = cp.getUtils("DataUtils").split(metaEntry:getValue("EventList"), ";")
	
	local richText = self.Image_1:getChildByName("RichText_PrimevalEffect")
	if richText then
		richText:removeFromParent()
	end
	richText = cp.getUtils("DataUtils").formatPrimevalEffect(metaInfo.level, metaInfo.color, eventList, "六件套裝效果")
	local posX, posY = self.Node_Effect:getPosition()
	richText:setPosition(cc.p(posX,posY))
	self.Image_1:addChild(richText, 100)

	local textureName = ""
	if metaInfo.lock then
		textureName = "ui_primeval_module98_hunyuan_7.png"
	else
		textureName = "ui_primeval_module98_hunyuan_12.png"
	end
	self.Button_Lock:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
end

function PrimevalMetaLayer:onEnterScene()
    self:updatePrimevalMetaView()
end

function PrimevalMetaLayer:onExitScene()
end

return PrimevalMetaLayer