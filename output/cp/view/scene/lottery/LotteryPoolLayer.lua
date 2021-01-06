local BLayer = require "cp.view.ui.base.BLayer"
local LotteryPoolLayer = class("LotteryPoolLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function LotteryPoolLayer:create(commonItemList, limitItemList)
    local scene = LotteryPoolLayer.new()
    scene.commonItemList = commonItemList
    scene.limitItemList = limitItemList
	scene:updateLotteryPoolView()
    return scene
end

function LotteryPoolLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function LotteryPoolLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_lottery_pool.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.ceilWidth = 144
    self.ceilHeight = 178
    self.deltaY = 0
    self.deltaX = 0

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Time"] = {name = "Text_Time"},
		["Panel_root.Image_1.Image_ItemBG"] = {name = "Image_ItemBG"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.ScrollView_Common"] = {name = "ScrollView_Common"},
		["Panel_root.Image_1.ScrollView_Common.Image_Model"] = {name = "Image_Model"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
	end)

    self.ScrollView_Common:setScrollBarEnabled(false)
    self.Image_Model:setVisible(false)
end

function LotteryPoolLayer:updateLotteryPoolView()
    self.commonItemList = cp.getManager("ConfigManager").getItemList("GameItem", "Shop", function(shop)
        if bit.band(shop, 8) > 0 then
            return true
        end

        return false
    end)

    table.sort(self.commonItemList, function(a,b)
		return a:getValue("Hierarchy") > b:getValue("Hierarchy")
    end)

    local rowNum = math.floor((#self.commonItemList-1)/4)+1
    local height = rowNum*self.ceilHeight+(rowNum-1)*self.deltaY
    self.ScrollView_Common:setInnerContainerSize(cc.size(576, height))
    local beginX, beginY = self.ceilWidth/2, height-self.ceilHeight/2
    for i=1, #self.commonItemList do
        local row = math.floor((i-1)/4)+1
        local col = math.floor((i-1)%4)+1
        local itemEntry = self.commonItemList[i]
        local img = self.Image_Model:clone()
        img:setVisible(true)
        local btn = img:getChildByName("Button_Model")
        btn:loadTextures(itemEntry:getValue("Icon"), itemEntry:getValue("Icon"), itemEntry:getValue("Icon"))
        btn:setVisible(true)
        cp.getManager("ViewManager").initButton(btn, function()
				local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
				self:addChild(layer, 100)
        end, 1.0)
        local icon = btn:getChildByName("Image_Icon")
        local name = btn:getChildByName("Text_Name")
        icon:loadTexture(CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
        name:setString(itemEntry:getValue("Name"))
        cp.getManager("ViewManager").setTextQuality(name, itemEntry:getValue("Hierarchy"))
        local posX = beginX + (col-1)*self.ceilWidth
        local posY = beginY - (row-1)*self.ceilHeight
        img:setPosition(cc.p(posX, posY))
        self.ScrollView_Common:addChild(img)
        cp.getManager("ViewManager").addWidgetBottom(btn, itemEntry:getValue("Hierarchy"))
    end
end

function LotteryPoolLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function LotteryPoolLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	end
end

function LotteryPoolLayer:onEnterScene()
end

function LotteryPoolLayer:onExitScene()
    self:unscheduleUpdate()
end

return LotteryPoolLayer