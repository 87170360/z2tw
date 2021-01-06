local BLayer = require "cp.view.ui.base.BLayer"
local ActivityResignLayer = class("ActivityResignLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ActivityResignLayer:create(day)
    local scene = ActivityResignLayer.new()
    scene.day = day
    scene:updateResignView()
    return scene
end

function ActivityResignLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ActivityResignLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_resign.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Item"] = {name = "Button_Item"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Cancel"] = {name = "Button_Cancel", click="onBtnClick"},
		["Panel_root.Image_1.Button_Buy"] = {name = "Button_Buy", click="onBtnClick"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
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

function ActivityResignLayer:updateResignView()
    local signData = cp.getUserData("UserSign"):getValue("SignData")
    local itemInfo = string.split(cp.getManager("ConfigManager").getItemByKey("GameSign", self.day):getValue("RewardList"), "=")
    local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", tonumber(itemInfo[1]))
    local itemNum = tonumber(itemInfo[2])
    local cost = (#signData.resign_day_list + 1)*20
    self.Text_Cost:setString(string.format("是否花費%d元寶進行補籤，獲得簽到獎勵物品？", cost))
    
    local item = self.Image_1:getChildByName("ResignItem")
    if not item then
        item = require("cp.view.ui.icon.ItemIcon"):create({
            id = tonumber(itemInfo[1]), num = itemNum, Name = itemEntry:getValue("Name") ,
            Icon = itemEntry:getValue("Icon") , Colour = itemEntry:getValue("Hierarchy"),Type = itemEntry:getValue("Type")
        })
        item:setName("ResignItem")
        self.Image_1:addChild(item)
        item:setPosition(cc.p(287.5, 202))
    end
end

function ActivityResignLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
    elseif nodeName == "Button_Cancel" then
		self:removeFromParent()
    elseif nodeName == "Button_Buy" then
        local req = {} 
        req.sign_day = self.day
        self:doSendSocket(cp.getConst("ProtoConst").SignReq, req)
		self:removeFromParent()
	end
end

function ActivityResignLayer:onEnterScene()
end

function ActivityResignLayer:onExitScene()
    self:unscheduleUpdate()
end

return ActivityResignLayer