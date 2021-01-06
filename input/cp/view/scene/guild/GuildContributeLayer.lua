local BLayer = require "cp.view.ui.base.BLayer"
local GuildContributeLayer = class("GuildContributeLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildContributeLayer:create()
	local scene = GuildContributeLayer.new()
    return scene
end

function GuildContributeLayer:initListEvent()
    self.listListeners = {
		["ContributeGuildRsp"] = function(data)
			self:updateGuildContributeView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildContributeLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_contribute.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.type = 0
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_GuildMoney.LoadingBar_Money"] = {name = "LoadingBar_Money"},
		["Panel_root.Image_1.Image_Type"] = {name = "Image_Type"},
		["Panel_root.Image_1.Text_Type"] = {name = "Text_Type"},
		["Panel_root.Image_1.Text_Number"] = {name = "Text_Number"},
		["Panel_root.Image_1.Text_Desc"] = {name = "Text_Desc"},
		["Panel_root.Image_1.Text_Contribute"] = {name = "Text_Contribute"},
		["Panel_root.Image_1.Text_ContributeNum"] = {name = "Text_ContributeNum"},
		["Panel_root.Image_1.Text_Salary"] = {name = "Text_Salary"},
		["Panel_root.Image_1.Text_SalaryNum"] = {name = "Text_SalaryNum"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Node_Input"] = {name = "Node_Input"},
		["Panel_root.Image_1.Button_Silver"] = {name = "Button_Silver", click="onBtnClick"},
		["Panel_root.Image_1.Button_Gold"] = {name = "Button_Gold", click="onBtnClick"},
		["Panel_root.Image_1.Button_Salary"] = {name = "Button_Salary", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Cancel"] = {name = "Button_Cancel", click="onBtnClick"},
		["Panel_root.Image_1.Button_Contribute"] = {name = "Button_Contribute", click="onBtnClick"},
		["Panel_root.Image_1.Button_Sub"] = {name = "Button_Sub", click="onBtnClick"},
		["Panel_root.Image_1.Button_Add"] = {name = "Button_Add", click="onBtnClick"},
		["Panel_root.Image_1.Button_Min"] = {name = "Button_Min", click="onBtnClick"},
		["Panel_root.Image_1.Button_Max"] = {name = "Button_Max", click="onBtnClick"},
		["Panel_root.Image_1.Image_CostPer.Text_CostPer"] = {name = "Text_CostPer"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Cancel"] = {name = "Button_Cancel", click="onBtnClick"},
		["Panel_root.Image_1.Button_Contribute"] = {name = "Button_Contribute", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)

	self.LoadingBar_Money = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Money, self.LoadingBar_Money:getChildByName("Text_Progress"), true)
	self.Button_Silver:setEnabled(false)
	local pos = self.Node_Input:convertToWorldSpace(cc.p(0,0))
	self.InputLayer = require("cp.view.ui.base.NumberInputLayer"):create(pos, function(value)
		local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

		local contributeConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:=")[2][self.type+1]
		local cost = self.Text_Cost:getString()
		if value < 0 then
			cost = tonumber(cost:sub(1, #cost-1)) or 0
		else
			cost = cost*10+value
		end
		local maxValue = 0
		if self.type == 0 then
			maxValue = roleAtt.silver
		elseif self.type == 1 then
			maxValue = roleAtt.gold
		elseif self.type == 2 then
			local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
			maxValue = playerGuildData.money
		end

		if cost > maxValue then
			cost = maxValue
		end

		self.Text_Cost:setString(cost)
		self:updateEarn(tonumber(cost), contributeConfig)
	end)
	self:addChild(self.InputLayer, 100)
	self.InputLayer:setPosition(0, 0)
	self.InputLayer:setVisible(false)
    ccui.Helper:doLayout(self.rootView)

	cp.getManager("ViewManager").initButton(self.Text_Cost, function()
		local contributeConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:=")[2][self.type+1]
		local cost = tonumber(self.Text_Cost:getString())
		cost = math.floor(cost / contributeConfig[1])*contributeConfig[1]
		self.InputLayer:setVisible(not self.InputLayer:isVisible())
		self.Text_Cost:setString(tostring(cost))
		self:updateEarn(cost, contributeConfig)
	end, 1.0)

	self.InputLayer:setCloseCallback(function()
		local contributeConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:=")[2][self.type+1]
		local cost = tonumber(self.Text_Cost:getString())
		cost = math.floor(cost / contributeConfig[1])*contributeConfig[1]
		self.InputLayer:setVisible(not self.InputLayer:isVisible())
		self.Text_Cost:setString(tostring(cost))
		self:updateEarn(cost, contributeConfig)
	end)
end

function GuildContributeLayer:updateEarn(cost, contributeConfig)
	local num = math.ceil(cost/contributeConfig[1])
	self.Text_ContributeNum:setString(tostring(num*contributeConfig[2]))
	self.Text_SalaryNum:setString(tostring(num*contributeConfig[3]))
end

function GuildContributeLayer:updateGuildContributeView()
	local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
	local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
	local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level)
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local contributeConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:=")[2]
	
	cp.getManager("ViewManager").initButton(self.Button_Sub, function()
		local cost = tonumber(self.Text_Cost:getString()) - contributeConfig[self.type+1][1]
		if cost >= contributeConfig[self.type+1][1] then
			self.Text_Cost:setString(cost)
			self:updateEarn(cost, contributeConfig[self.type+1])
		end
	end)

	local cost = contributeConfig[self.type+1][1]
	self.Text_Cost:setString(cost)
	self:updateEarn(cost, contributeConfig[self.type+1])
	self.Text_CostPer:setString(guildLevelConfig:getValue("DailyCost"))

	self.LoadingBar_Money:initProgress(guildLevelConfig:getValue("LevelUpCostMoney"), guildDetailData.money)
	if self.type == 0 then
		self.Image_Type:getChildByName("Text"):setString("捐獻銀兩")
		self.Text_Desc:setString("請選擇捐獻銀兩數量\n可獲得以下獎勵：")
		self.Text_Number:setString(roleAtt.silver)
		self.Text_Type:setString("擁有銀兩")
		cp.getManager("ViewManager").initButton(self.Button_Max, function()
			local cost = math.floor(roleAtt.silver / contributeConfig[self.type+1][1])*contributeConfig[self.type+1][1]
			self.Text_Cost:setString(cost)
			self:updateEarn(cost, contributeConfig[self.type+1])
		end)
		cp.getManager("ViewManager").initButton(self.Button_Add, function()
			local cost = tonumber(self.Text_Cost:getString()) + contributeConfig[self.type+1][1]
			if cost <= roleAtt.silver then
				self.Text_Cost:setString(cost)
				self:updateEarn(cost, contributeConfig[self.type+1])
			end
		end)
	elseif self.type == 1 then
		self.Image_Type:getChildByName("Text"):setString("捐獻元寶")
		self.Text_Desc:setString("請選擇捐獻元寶數量\n可獲得以下獎勵：")
		self.Text_Number:setString(roleAtt.gold)
		self.Text_Type:setString("擁有元寶")
		cp.getManager("ViewManager").initButton(self.Button_Max, function()
			local cost = math.floor(roleAtt.gold / contributeConfig[self.type+1][1])*contributeConfig[self.type+1][1]
			self.Text_Cost:setString(cost)
			self:updateEarn(cost, contributeConfig[self.type+1])
		end)
		cp.getManager("ViewManager").initButton(self.Button_Add, function()
			local cost = tonumber(self.Text_Cost:getString()) + contributeConfig[self.type+1][1]
			if cost <= roleAtt.gold then
				self.Text_Cost:setString(cost)
				self:updateEarn(cost, contributeConfig[self.type+1])
			end
		end)
	elseif self.type == 2 then
		self.Image_Type:getChildByName("Text"):setString("捐獻資金")
		self.Text_Desc:setString("請選擇捐獻資金\n可獲得以下獎勵：")
		self.Text_Number:setString(playerGuildData.money)
		self.Text_Type:setString("擁有資金")
		cp.getManager("ViewManager").initButton(self.Button_Max, function()
			local cost = math.floor(playerGuildData.money / contributeConfig[self.type+1][1])*contributeConfig[self.type+1][1]
			self.Text_Cost:setString(cost)
			self:updateEarn(cost, contributeConfig[self.type+1])
		end)
		cp.getManager("ViewManager").initButton(self.Button_Add, function()
			local cost = tonumber(self.Text_Cost:getString()) + contributeConfig[self.type+1][1]
			if cost <= playerGuildData.money then
				self.Text_Cost:setString(cost)
				self:updateEarn(cost, contributeConfig[self.type+1])
			end
		end)
	end

	cp.getManager("ViewManager").initButton(self.Button_Min, function()
		local cost = contributeConfig[self.type+1][1]
		self.Text_Cost:setString(cost)
		self:updateEarn(cost, contributeConfig[self.type+1])
	end)
end

function GuildContributeLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Cancel" then
        self:removeFromParent()
    elseif nodeName == "Button_Contribute" then
		local req = {}
		req.type = self.type
		req.num = tonumber(self.Text_Cost:getString())
		if req.num == 0 then
			cp.getManager("ViewManager").gameTip("捐獻數量不能為0")
			return
		end
		self:doSendSocket(cp.getConst("ProtoConst").ContributeGuildReq, req)
	elseif nodeName == "Button_Silver" or nodeName == "Button_Gold" or nodeName == "Button_Salary" then
		self.Button_Silver:setEnabled(true)
		self.Button_Gold:setEnabled(true)
		self.Button_Salary:setEnabled(true)
        local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
		self.type = tonumber(extensionData:getCustomProperty())
		self:updateGuildContributeView()
		btn:setEnabled(false)
	end
end

function GuildContributeLayer:onEnterScene()
	self:updateGuildContributeView()
end

function GuildContributeLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildContributeLayer