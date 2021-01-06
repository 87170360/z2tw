local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalCombatLayer = class("PrimevalCombatLayer", BLayer)

function PrimevalCombatLayer:create(primevalList)
    local scene = PrimevalCombatLayer.new(primevalList)
    return scene
end

function PrimevalCombatLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalCombatLayer:onInitView(primevalList)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_combat.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
	
	self.primevalList = primevalList

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Primeval1"] = {name = "Image_Primeval1"},
		["Panel_root.Image_1.Image_Primeval2"] = {name = "Image_Primeval2"},
		["Panel_root.Image_1.Image_Primeval3"] = {name = "Image_Primeval3"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    ccui.Helper:doLayout(self.rootView)
	
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)

	self.metaList = {}
	for _, primevalID in ipairs(primevalList) do
		local primevalEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", primevalID)
		table.insert(self.metaList, primevalEntry)
	end
end

function PrimevalCombatLayer:updatePrimevalMapView()
	for i=1,3 do
		local metaEntry = self.metaList[i]
		local model = self["Image_Primeval"..i]
		if not metaEntry then
			break
		end
		model:setVisible(true)
		local txtName = model:getChildByName("Text_Name")
		local imgIcon = model:getChildByName("Image_Icon")
		local richText = model:getChildByName("RichText_PrimevalEffect")
		
		cp.getManager("ViewManager").setTextQuality(txtName, 6)
		imgIcon:loadTexture(metaEntry:getValue("Icon"))
		txtName:setString(metaEntry:getValue("Name"))

		if richText then
			richText:removeFromParent()
		end

		local eventList = cp.getUtils("DataUtils").split(metaEntry:getValue("EventList"), ";")
		local richText = cp.getUtils("DataUtils").formatPrimevalEffect(1, 1, eventList, "", 350)
		richText:setPosition(cc.p(144,77))
		model:addChild(richText, 100)
	end
end

function PrimevalCombatLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
    end
end

function PrimevalCombatLayer:onEnterScene()
    self:updatePrimevalMapView()
end

function PrimevalCombatLayer:onExitScene()
end

return PrimevalCombatLayer