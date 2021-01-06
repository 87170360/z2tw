local BLayer = require "cp.view.ui.base.BLayer"
local GuildFightStartLayer = class("GuildFightStartLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildFightStartLayer:create(phase)
	local scene = GuildFightStartLayer.new()
    return scene
end

function GuildFightStartLayer:initListEvent()
    self.listListeners = {
        ["GuildPrepareFightRsp"] = function(data)
            self:updateGuildFightStartView()
		end,
        ["GuildSignFightRsp"] = function(data)
            self:updateGuildFightStartView()
		end,
        ["GetFightCityCountRsp"] = function(data)
            self.Text_GuildCount:setString(string.format("進攻%s幫派統計：%d", cp.getConst("GameConst").CityName[data.city], data.count))
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildFightStartLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_fight_start.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_1.Node_PhasePrepare.Image_Cost.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Node_PhaseFight"] = {name = "Node_PhaseFight"},
		["Panel_root.Image_1.Node_PhasePrepare"] = {name = "Node_PhasePrepare"},
		["Panel_root.Image_1.Node_PhaseFight.Text_Num"] = {name = "Text_Num"},
		["Panel_root.Image_1.Node_PhaseFight.Text_City"] = {name = "Text_City"},
		["Panel_root.Image_1.Node_PhaseFight.Text_FightCity"] = {name = "Text_FightCity"},
		["Panel_root.Image_1.Node_PhaseFight.Text_GuildCount"] = {name = "Text_GuildCount"},
		["Panel_root.Image_1.Node_PhaseFight.Text_SignReward"] = {name = "Text_SignReward"},
		["Panel_root.Image_1.Node_PhaseFight.Image_Remain.Text_Remain"] = {name = "Text_Remain"},
		["Panel_root.Image_1.Node_PhaseFight.Image_Remain"] = {name = "Image_Remain"},
		["Panel_root.Image_1.Node_PhaseFight.Image_Phase"] = {name = "Image_Phase"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rule"] = {name = "Button_Rule", click="onBtnClick"},
		["Panel_root.Image_1.Node_PhasePrepare.Button_Begin"] = {name = "Button_Begin", click="onBtnClick"},
		["Panel_root.Image_1.Node_PhaseFight.Button_List"] = {name = "Button_List", click="onBtnClick"},
		["Panel_root.Image_1.Node_PhaseFight.Button_Sign"] = {name = "Button_Sign", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
end

local phaseName = {
    "", "幫戰開始", "幫戰結束",
}

function GuildFightStartLayer:updateGuildFightStartView()
    if cp.getUtils("NotifyUtils").needNotifyGuildFightList() then
        cp.getManager("ViewManager").addRedDot(self.Button_List,cc.p(141,59))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_List)
    end

    if cp.getUtils("NotifyUtils").needNotifyGuildPrepare() then
        cp.getManager("ViewManager").addRedDot(self.Button_Begin,cc.p(141,59))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Begin)
    end

    if cp.getUtils("NotifyUtils").needNotifyGuildSign() then
        cp.getManager("ViewManager").addRedDot(self.Button_Sign,cc.p(141,59))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Sign)
    end

    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local DataUtils = cp.getUtils("DataUtils")
    local fightConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
	local phase, remainTime = cp.getUtils("DataUtils").getGuildFightPhase(weekDay, nowTab, fightConfig)
    local nearWD = DataUtils.convertWeekDay(DataUtils.getNearestWeekDay(weekDay, fightConfig[1]))
    
    if phase ~= 1 and phase ~= 4 and guildDetailData.fight_info.city > 0 then
        local req = {}
        req.city = guildDetailData.fight_info.city
        self:doSendSocket(cp.getConst("ProtoConst").GetFightCityCountReq, req)
    end
    --phase = 3
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(roleAtt.id)
    if phase == 2 and guildDetailData.fight_info.city == 0 and memberInfo.duty > 0 then
        self.Node_PhasePrepare:setVisible(true)
        self.Node_PhaseFight:setVisible(false)
        return
    end

    self.Node_PhaseFight:setVisible(true)
    self.Node_PhasePrepare:setVisible(false)

    if phase == 1 then
        self.Text_FightCity:setString(DataUtils.GetWeekDayZh_CN(nearWD).."凌晨開啟")
        self.Image_Phase:setVisible(false)
        self.Text_Num:setString("")
        self.Image_Remain:setVisible(false)
        self.Text_City:setString("")
        self.Text_GuildCount:setString("")
        cp.getManager("ViewManager").setEnabled(self.Button_Sign, false)
        return
    end

    if guildDetailData.fight_info.city > 0 and phase ~= 4 then
        self.Text_City:setString("當前進攻城市")
        self.Image_Remain:setVisible(true)
        self.Text_Remain:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            self.Text_Remain:setString(phaseName[phase].."剩餘時間："..cp.getUtils("DataUtils").formatTimeRemain(remainTime))
            remainTime = remainTime - 1
            if remainTime < 0 then
                self.Text_Remain:stopAllActions()
                self:updateGuildFightStartView()
            end
        end), cc.DelayTime:create(1))))
        self.Text_Num:setString(string.format("幫派參戰人數：%d人", cp.getUserData("UserGuild"):getPrepareFightNum()))
        self.Text_FightCity:setString(cp.getConst("GameConst").CityName[guildDetailData.fight_info.city])
    else
        self.Image_Remain:setVisible(false)
        self.Text_Num:setString("")
        self.Text_City:setString("")
        self.Text_FightCity:setString("幫派未報名攻掠戰")
    end

    if phase == 3 then
        self.Image_Phase:setVisible(true)
        self.Image_bg:loadTexture("img/bg/bg_guild/module_bangpai_30.png")
        self.Image_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.8, 200), cc.FadeTo:create(0.8, 255))))
    else
        self.Image_Phase:setVisible(false)
        self.Image_bg:loadTexture("img/bg/bg_guild/module_bangpai_29.png")
    end

    local signed = cp.getUserData("UserGuild"):isMemberSigned(roleAtt.id)
    if signed then
        self.Button_Sign:getChildByName("Text"):setString("已報名")
        cp.getManager("ViewManager").setEnabled(self.Button_Sign, false)
    else
        self.Button_Sign:getChildByName("Text"):setString("報    名")
        if guildDetailData.fight_info.city > 0 then
            cp.getManager("ViewManager").setEnabled(self.Button_Sign, true)
        else
            cp.getManager("ViewManager").setEnabled(self.Button_Sign, false)
        end
    end
    self.Text_SignReward:setString(string.format("報名獎勵：%d幫貢", fightConfig[6][1]))

    if phase == 4 then
        if guildDetailData.city > 0 then
            self.Text_City:setString("成功佔領")
            self.Text_FightCity:setString(cp.getConst("GameConst").CityName[guildDetailData.city])
            self.Text_GuildCount:setString("戰鬥詳情請查看對戰列表")
        else
            self.Text_City:setString("")
            self.Text_FightCity:setString("攻掠失敗")
            self.Text_GuildCount:setString("戰鬥詳情請查看對戰列表")
        end
    end
end

function GuildFightStartLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Begin" then
        local layer = require("cp.view.scene.guild.GuildFightCityLayer"):create()
        self:addChild(layer, 100)
	elseif nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_guild_fight_rule.xml")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("guild_fight_rule", desc)
        self:addChild(layer, 100)
	elseif nodeName == "Button_List" then
        local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
        local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
        local city = nil
        if guildDetailData.fight_info.city > 0 then
            city = guildDetailData.fight_info.city
        elseif guildDetailData.city > 0 then
            city = guildDetailData.city
        end
        local layer = require("cp.view.scene.guild.GuildFightGuildLayer"):create(city)
        self:addChild(layer, 100)
    elseif nodeName == "Button_Sign" then
        self:doSendSocket(cp.getConst("ProtoConst").GuildSignFightReq, {})
	end
end

function GuildFightStartLayer:onEnterScene()
	self:updateGuildFightStartView()
end

function GuildFightStartLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildFightStartLayer