local BLayer = require "cp.view.ui.base.BLayer"
local ActivityRewardPreviewLayer = class("ActivityRewardPreviewLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ActivityRewardPreviewLayer:create(mode, itemList)
    local scene = ActivityRewardPreviewLayer.new()
    scene.mode = mode
    scene.itemList = itemList
    scene:updateRewardPreviewView()
    return scene
end

function ActivityRewardPreviewLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ActivityRewardPreviewLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_reward_preview.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Item1"] = {name = "Button_Item1"},
		["Panel_root.Image_1.Button_Item2"] = {name = "Button_Item2"},
		["Panel_root.Image_1.Button_Item3"] = {name = "Button_Item3"},
		["Panel_root.Image_1.Button_Item4"] = {name = "Button_Item4"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_OK"] = {name = "Button_OK", click="onBtnClick"},
		["Panel_root.Image_1.Image_title.Text_Title"] = {name = "Text_Title"},
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

function ActivityRewardPreviewLayer:updateRewardPreviewView()
    for i, itemInfo in ipairs(self.itemList) do
        local item = self.Image_1:getChildByName("Item"..i)
        if item then
            item:removeFromParent()
        end
        
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo[1])
		item = require("cp.view.ui.icon.ItemIcon"):create({
            id = itemInfo[1], num = itemInfo[2], Name = cfgItem:getValue("Name") ,
            Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")
        })

        item:setItemClickCallBack(function()
            local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
            self:addChild(layer, 100)
        end)
        item:setPosition(cc.p(124.5+(i-1)*110, 189))
        self.Image_1:addChild(item)
    end

    --恭喜獲得
    if self.mode == 1 then
        self.Text_Title:setString("恭喜獲得")
    else --獎勵預覽
        self.Text_Title:setString("獎勵預覽")
    end
end

function ActivityRewardPreviewLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
    elseif nodeName == "Button_OK" then
		self:removeFromParent()
	end
end

function ActivityRewardPreviewLayer:onEnterScene()
end

function ActivityRewardPreviewLayer:onExitScene()
    self:unscheduleUpdate()
end

return ActivityRewardPreviewLayer