local BLayer = require "cp.view.ui.base.BLayer"
local GuildUpgradeLayer = class("GuildUpgradeLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildUpgradeLayer:create()
	local scene = GuildUpgradeLayer.new()
    return scene
end

function GuildUpgradeLayer:initListEvent()
    self.listListeners = {
		["UpgradeGuildRsp"] = function(data)
			self:updateGuildUpgradeView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildUpgradeLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_upgrade.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_GuildExp.LoadingBar_Exp"] = {name = "LoadingBar_Exp"},
		["Panel_root.Image_1.Image_GuildExp.Image_Level"] = {name = "Image_Level"},
		["Panel_root.Image_1.Image_GuildMoney.LoadingBar_Money"] = {name = "LoadingBar_Money"},
		["Panel_root.Image_1.Image_LevelIntro"] = {name = "Image_LevelIntro"},
		["Panel_root.Image_1.Image_Desc"] = {name = "Image_Desc"},
		["Panel_root.Image_1.Image_Desc.Text_Desc"] = {name = "Text_Desc"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Cancel"] = {name = "Button_Cancel", click="onBtnClick"},
		["Panel_root.Image_1.Button_Upgrade"] = {name = "Button_Upgrade", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)

	self.LoadingBar_Exp = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Exp, self.LoadingBar_Exp:getChildByName("Text_Progress"), true)
	self.LoadingBar_Money = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Money, self.LoadingBar_Money:getChildByName("Text_Progress"), true)
end

function GuildUpgradeLayer:updateGuildUpgradeView()
	local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
	local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
	local level = guildDetailData.level + 1
	if level > 5 then
		level = 5
	end
	
    local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level)
	self.LoadingBar_Exp:initProgress(guildLevelConfig:getValue("LevelUpCostExp"), guildDetailData.exp)
	self.LoadingBar_Money:initProgress(guildLevelConfig:getValue("LevelUpCostMoney"), guildDetailData.money)
	self.Image_Level:getChildByName("Text_Level"):setString("幫派等級LV."..guildDetailData.level)

	guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", level)
	self.Image_LevelIntro:getChildByName("Text"):setString(level.."級幫派介紹")
	local richText = self.Image_Desc:getChildByName("RichText")
	if richText then
		richText:removeFromParent()
	end
	richText = cp.getUtils("RichTextUtils").ParseRichText(guildLevelConfig:getValue("Intro"))
	richText:setPosition(8, 258)
	richText:setContentSize(cc.size(505,184))
	richText:setName("RichText")
	self.Image_Desc:addChild(richText)
	--self.Text_Desc:setString(guildLevelConfig:getValue("Intro"))
end

function GuildUpgradeLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Cancel" then
        self:removeFromParent()
    elseif nodeName == "Button_Upgrade" then
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(roleAtt.id)
        self:doSendSocket(cp.getConst("ProtoConst").UpgradeGuildReq, {})
	end
end

function GuildUpgradeLayer:onEnterScene()
	self:updateGuildUpgradeView()
end

function GuildUpgradeLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildUpgradeLayer