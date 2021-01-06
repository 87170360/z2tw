local BLayer = require "cp.view.ui.base.BLayer"
local ActivitySignRewardLayer = class("ActivitySignRewardLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ActivitySignRewardLayer:create(itemEntry, num)
    local scene = ActivitySignRewardLayer.new()
    scene.itemEntry = itemEntry
    scene.num = num
    scene:updateSignRewardView()
    return scene
end

function ActivitySignRewardLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ActivitySignRewardLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_sign_reward.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Item"] = {name = "Button_Item", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
    end)
    
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function ActivitySignRewardLayer:updateSignRewardView()
    local icon = self.Button_Item:getChildByName("Image_Icon")
    local textNum = self.Button_Item:getChildByName("Text_Num")
    local textName = self.Button_Item:getChildByName("Text_Name")
    self.Button_Item:loadTextures(self.itemEntry:getValue("Icon"), self.itemEntry:getValue("Icon"), self.itemEntry:getValue("Icon"))
    icon:loadTexture(CombatConst.SkillBoxList[self.itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
    textName:setString(self.itemEntry:getValue("Name"))
    cp.getManager("ViewManager").setTextQuality(textName, self.itemEntry:getValue("Hierarchy"))
    textNum:setString("x"..self.num)
end

function ActivitySignRewardLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Item" then
	end
end

function ActivitySignRewardLayer:onEnterScene()
end

function ActivitySignRewardLayer:onExitScene()
    self:unscheduleUpdate()
end

return ActivitySignRewardLayer