local BLayer = require "cp.view.ui.base.BLayer"
local BuyTrainPointLayer = class("BuyTrainPointLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function BuyTrainPointLayer:create(openInfo)
    local scene = BuyTrainPointLayer.new()
    return scene
end

function BuyTrainPointLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").BuyTrainPointRsp] = function(data)
			self:updateBuyTrainPointView(true)
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function BuyTrainPointLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_earn_trainpoint.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.LoadingBar_Progress"] = {name = "LoadingBar_Progress"},
		["Panel_root.Image_1.Image_8.Text_Level"] = {name = "Text_Level"},
		["Panel_root.Image_1.LoadingBar_Progress.Text_Progress"] = {name = "Text_Progress"},
		["Panel_root.Image_1.Text_TrainPoint"] = {name = "Text_TrainPoint"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Buy"] = {name = "Button_Buy", click="onBtnClick"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Text_Count"] = {name = "Text_Count"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	
    self.DynamicBar_Progress = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Progress, self.Text_Progress, true)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)

	self:updateBuyTrainPointView()
end

function BuyTrainPointLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:getParent():removeChild(self)
	elseif nodeName == "Button_Buy" then
		local cost = tonumber(self.Text_Cost:getString())
		if not cp.getManager("ViewManager").checkGoldEnough(cost) then
			return
		end
		local req = {}
		self:doSendSocket(cp.getConst("ProtoConst").BuyTrainPointReq, req)
	end
end

function BuyTrainPointLayer:updateBuyTrainPointView(updated)
	local buySkillPoint = cp.getUserData("UserSkill"):getBuyInfo()
	local configItem = cp.getManager("ConfigManager").getItemByKey("BuyTrainPoint", buySkillPoint.level)
	self.Text_Level:setString("LV."..buySkillPoint.level)
	self.Text_TrainPoint:setString(configItem:getValue("TrainPoint"))
	local limitCount = cp.getUtils("DataUtils").GetVipEffect(3)
	self.Text_Count:setString(string.format("%d/%d", limitCount - buySkillPoint.buy_count, limitCount))
	if updated and buySkillPoint.level ~= 10 then
		self.DynamicBar_Progress:updateProgress(nil, 10, 0.2)
		self.Text_Progress:runAction(cc.Sequence:create(cc.DelayTime:create(0.21), cc.CallFunc:create(function()
			if configItem:getValue("Level") == 10 then
				self.Text_Progress:setString("已到滿級")
			else
				self.DynamicBar_Progress:initProgress(configItem:getValue("Exp"), buySkillPoint.exp)
			end
			local cost = 60
			if buySkillPoint.buy_count < 4 then
				cost = (math.floor(buySkillPoint.buy_count / 2) + 1)*20
			end
			self.Text_Cost:setString(cost)
		end)))
	else
		self.DynamicBar_Progress:initProgress(configItem:getValue("Exp"), buySkillPoint.exp)
		if configItem:getValue("Exp") == 0 then
			self.Text_Progress:setString("已到滿級")
		end
		self.Text_TrainPoint:setString(configItem:getValue("TrainPoint"))
		local cost = 60
		if buySkillPoint.buy_count < 4 then
			cost = (math.floor(buySkillPoint.buy_count / 2) + 1)*20
		end
		self.Text_Cost:setString(cost)
	end

end

function BuyTrainPointLayer:onEnterScene()
end

function BuyTrainPointLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function BuyTrainPointLayer:onExitScene()
    self:unscheduleUpdate()
end

return BuyTrainPointLayer