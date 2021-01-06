local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalEquipLayer = class("PrimevalEquipLayer", BLayer)

function PrimevalEquipLayer:create(pack)
    local scene = PrimevalEquipLayer.new(pack)
    return scene
end

local packName = {
	"氣府", "重樓", "黃庭"
}
function PrimevalEquipLayer:initListEvent()
    self.listListeners = {
		["PrimevalEquipMetaByPos"] = function(pos)
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
		end,
		["EquipMetaRsp"] = function(pos)
			self:updatePrimevalEquipView()
		end,
		["StrengthMetaRsp"] = function(data)
			self:updatePrimevalEquipView()
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalEquipLayer:onInitView(pack)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_equip.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
	pack = pack or 1
	self.place = 1

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_3"] = {name = "Image_3"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1.0},
		["Panel_root.Image_1.Button_Pack1"] = {name = "Button_Pack1", click="onPackClick", clickScale=1.0},
		["Panel_root.Image_1.Button_Pack2"] = {name = "Button_Pack2", click="onPackClick", clickScale=1.0},
		["Panel_root.Image_1.Button_Pack3"] = {name = "Button_Pack3", click="onPackClick", clickScale=1.0},
		["Panel_root.Image_1.Image_Place1"] = {name = "Image_Place1"},
		["Panel_root.Image_1.Image_Place2"] = {name = "Image_Place2"},
		["Panel_root.Image_1.Image_Place3"] = {name = "Image_Place3"},
		["Panel_root.Image_1.Image_Place4"] = {name = "Image_Place4"},
		["Panel_root.Image_1.Image_Place5"] = {name = "Image_Place5"},
		["Panel_root.Image_1.Image_Place6"] = {name = "Image_Place6"},
		["Panel_root.Image_1.Text_NoEffect"] = {name = "Text_NoEffect"},
		["Panel_root.Image_1.Text_SingleEffect"] = {name = "Text_SingleEffect"},
		["Panel_root.Image_1.Button_Map"] = {name = "Button_Map", click="onBtnClick"},
		["Panel_root.Image_1.Button_Effect"] = {name = "Button_Effect", click="onBtnClick"},
		["Panel_root.Image_1.Button_Main"] = {name = "Button_Main", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	self:onSelectPack(pack)
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)

	local imgBG = cc.Sprite:create()
	local size = self.Image_3:getSize()
	imgBG:setName("EffectBG")
	imgBG:setPosition(cc.p(size.width/2,size.height/2))
	self.Image_3:addChild(imgBG)

	for i=1, 6 do
		local imgPlace = self["Image_Place"..i]

        local primevalEffect = cc.Sprite:create()
        primevalEffect:setName("EffectIcon")
        local size = imgPlace:getSize()
        primevalEffect:setPosition(cc.p(size.width/2,size.height/2))
		imgPlace:addChild(primevalEffect)
		primevalEffect:setVisible(false)

		local primevalCircle = cc.Sprite:create()
        primevalCircle:setName("EffectCircle")
        primevalCircle:setPosition(cc.p(size.width/2,size.height/2))
		imgPlace:addChild(primevalCircle)
		primevalCircle:setVisible(false)
		
		local txtLevel = imgPlace:getChildByName("Text_Level")
		local txtName = imgPlace:getChildByName("Text_Name")
		txtLevel:setZOrder(100)
		txtName:setZOrder(100)
		
		cp.getManager("ViewManager").initButton(imgPlace, function()
			local equipMap = cp.getUserData("UserPrimeval"):getValue("EquipMap")
			self:onSelectPlace(i)
			local equipPos = bit.lshift(self.pack, 16) + i
			local metaInfo = equipMap[equipPos]
			if metaInfo then
				local layer = require("cp.view.scene.primeval.PrimevalMetaLayer"):create(metaInfo.pos)
				self:addChild(layer, 100)
			else
				local layer = require("cp.view.scene.primeval.PrimevalPackageLayer"):create()
				self:addChild(layer, 100)
			end
		end, 1.0)
	end
end

function PrimevalEquipLayer:onSelectPlace(place)
	for i=1, 6 do
		local imgPlace = self["Image_Place"..i]
		local imgFlag = imgPlace:getChildByName("Image_Flag")
		if i == place then
			imgFlag:setVisible(true)
		else
			imgFlag:setVisible(false)
		end
	end
	self.place = place
end

function PrimevalEquipLayer:onSelectPack(pack)
	for i=1, 3 do
		local nm = "Button_Pack"..i
		local btn = self[nm]
		if i == pack then
			btn:setEnabled(false)
		else
			btn:setEnabled(true)
			btn:getChildByName("Text_1"):setString(packName[i])
			btn:getChildByName("Text_1"):setFontSize(40)
		end
	end

	self.pack = pack
end

function PrimevalEquipLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_Map" then
		local layer = require("cp.view.scene.primeval.PrimevalMapLayer"):create(self.pack)
		self:addChild(layer, 100)
	elseif nodeName == "Button_Effect" then
		local layer = require("cp.view.scene.primeval.PrimevalEffectLayer"):create()
		self:addChild(layer, 100)
	elseif nodeName == "Button_Main" then
		self:dispatchViewEvent("GetPrimevalDataRsp", true)
		self:removeFromParent()
    end
end

function PrimevalEquipLayer:onPackClick(sender)
    local nodeName = sender:getName()
	for i=1, 3 do
		local nm = "Button_Pack"..i
		if nm == nodeName then
			self:onSelectPack(i)
			self:onSelectPlace(1)
			break
		end
	end
	self:updatePrimevalEquipView()
end
local posList = {
	cc.p(360,676),
	cc.p(221,591),
	cc.p(500,591),
	cc.p(221,449),
	cc.p(500,449),
	cc.p(360,388)
}

function PrimevalEquipLayer:runPackSuitAction(flag)
	local effectBG = self.Image_3:getChildByName("EffectBG")
	effectBG:stopAllActions()
	if not flag then
		effectBG:setVisible(false)
	else
		effectBG:setVisible(true)
		local animation = cp.getManager("ViewManager").createEffectAnimation("hunyuan_quan_da", 0.033333, 10000000000000)
		effectBG:runAction(cc.Animate:create(animation))
	end

	for i=1, 6 do
		local imgPlace = self["Image_Place"..i]
		local effectCircle = imgPlace:getChildByName("EffectCircle")
		effectCircle:stopAllActions()
		if flag then
			local animation = cp.getManager("ViewManager").createEffectAnimation("hunyuan_huoquan_xiao", 0.033333, 10000000000000)
			effectCircle:runAction(cc.Animate:create(animation))
			effectCircle:setVisible(true)
		else
			effectCircle:setVisible(false)
		end
	end
end

function PrimevalEquipLayer:updatePrimevalEquipView()
	local equipMap = cp.getUserData("UserPrimeval"):getValue("EquipMap")
	local count = 0
	local suitID = nil
	for place=1, 6 do
		local equipPos = bit.lshift(self.pack, 16) + place
		local metaInfo = equipMap[equipPos]
		local imgPlace = self["Image_Place"..place]
		local txtLevel = imgPlace:getChildByName("Text_Level")
		local txtName = imgPlace:getChildByName("Text_Name")
		local imgColor = imgPlace:getChildByName("Image_Color")
		local effectIcon = imgPlace:getChildByName("EffectIcon")
		local effectCircle = imgPlace:getChildByName("EffectCircle")
		if metaInfo then
			local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
			imgPlace:loadTexture(metaEntry:getValue("Icon"))
			if suitID and suitID > 0 and suitID ~= metaEntry:getValue("ID") then
				suitID = 0
			elseif not suitID then
				suitID = metaEntry:getValue("ID")
			end
			effectIcon:stopAllActions()
			if metaInfo.color >= 5 then
				effectIcon:setVisible(true)
				local animation = cp.getManager("ViewManager").createEffectAnimation(metaEntry:getValue("UI_Effect"), 0.033333, 10000000)
				effectIcon:runAction(cc.Animate:create(animation))
			else
				effectIcon:setVisible(false)
			end
			txtLevel:setString("LV."..metaInfo.level)
			txtName:setString(metaEntry:getValue("Name"))
			cp.getManager("ViewManager").setTextQuality(txtName, metaInfo.color)
			imgColor:setVisible(true)
			imgColor:loadTexture(cp.getConst("CombatConst").PrimevalColorList[metaInfo.color], ccui.TextureResType.plistType)
		else
			effectIcon:setVisible(false)
			effectCircle:setVisible(false)
			imgPlace:loadTexture("ui_primeval_module98_hunyuan_11.png", ccui.TextureResType.plistType)
			suitID = 0
			txtLevel:setString("")
			txtName:setString("")
			imgColor:setVisible(false)
		end
	end

	local richText = self.Image_1:getChildByName("RichText_PrimevalEffect")
	if richText then
		richText:removeFromParent()
	end

	if suitID and suitID > 0 then
		local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", suitID)
		local eventList = cp.getUtils("DataUtils").split(metaEntry:getValue("EventList"), ";")
		richText = cp.getUtils("DataUtils").formatPrimevalEffect(1, 1, eventList, nil, 430)
		richText:setPosition(cc.p(150,250))
		self.Image_1:addChild(richText, 100)
		self.Text_NoEffect:setVisible(false)
		self.Text_SingleEffect:setVisible(true)
		self:runPackSuitAction(true)
	else
		self.Text_NoEffect:setVisible(true)
		self.Text_SingleEffect:setVisible(false)
		self:runPackSuitAction(false)
	end
	
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	if roleAtt.hierarchy < 3 then
		cp.getManager("ViewManager").setShader(self.Button_Pack1, "GrayShader")
		cp.getManager("ViewManager").initButton(self.Button_Pack1, function()
			cp.getManager("ViewManager").gameTip("進階至三階後開啟")
			cp.getManager("ViewManager").setShader(self.Button_Pack1, "GrayShader")
		end, 1.0)
	end
	if roleAtt.hierarchy < 4 then
		cp.getManager("ViewManager").setShader(self.Button_Pack2, "GrayShader")
		cp.getManager("ViewManager").initButton(self.Button_Pack2, function()
			cp.getManager("ViewManager").gameTip("進階至四階後開啟")
			cp.getManager("ViewManager").setShader(self.Button_Pack2, "GrayShader")
		end, 1.0)
	end
	if roleAtt.hierarchy < 5 then
		cp.getManager("ViewManager").setShader(self.Button_Pack3, "GrayShader")
		cp.getManager("ViewManager").initButton(self.Button_Pack3, function()
			cp.getManager("ViewManager").gameTip("進階至五階後開啟")
			cp.getManager("ViewManager").setShader(self.Button_Pack3, "GrayShader")
		end, 1.0)
	end
end

function PrimevalEquipLayer:onEnterScene()
	self:updatePrimevalEquipView()
	
	local result,step = cp.getManager("GDataManager"):checkNeedGuide("primeval_equip")
	if result then
		cp.getManager("ViewManager").openNewPlayerGuide("primeval_equip",step)
	end
end

function PrimevalEquipLayer:onExitScene()
end

return PrimevalEquipLayer