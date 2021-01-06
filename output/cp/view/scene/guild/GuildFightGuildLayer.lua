local BLayer = require "cp.view.ui.base.BLayer"
local GuildFightGuildLayer = class("GuildFightGuildLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildFightGuildLayer:create(city)
    local scene = GuildFightGuildLayer.new()
    scene.city = city or 1
    return scene
end

function GuildFightGuildLayer:initListEvent()
    self.listListeners = {
        ["GetGuildFightCityRsp"] = function(data)
            self.owner = data.name
            self:updateGuildFightGuildView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildFightGuildLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_fight_guild.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    self.owner = ""
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Result"] = {name = "Text_Result"},
		["Panel_root.Image_1.Text_Empty"] = {name = "Text_Empty"},
		["Panel_root.Image_1.Image_Phase.Text_Phase"] = {name = "Text_Phase"},
		["Panel_root.Image_1.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.ListView_List"] = {name = "ListView_List"},
		["Panel_root.Image_1.Button_City1"] = {name = "Button_City1"},
		["Panel_root.Image_1.Button_City2"] = {name = "Button_City2"},
		["Panel_root.Image_1.Button_City3"] = {name = "Button_City3"},
		["Panel_root.Image_1.Button_City4"] = {name = "Button_City4"},
		["Panel_root.Image_1.Button_City5"] = {name = "Button_City5"},
		["Panel_root.Image_1.Button_City6"] = {name = "Button_City6"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)

    local DataUtils = cp.getUtils("DataUtils")
    local TimeUtils = cp.getUtils("TimeUtils")
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local now = cp.getManager("TimerManager"):getTime()
    local weekDay = tonumber(os.date("%w", now))
    local nowTab = os.date("*t", now)
    local phase, _ = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
    if phase == 2 or phase == 3 then
        nextTime = TimeUtils.GetTime(now, fightConfig[2][1], fightConfig[2][2], 0)
    else
        nextTime = TimeUtils.GetTime(DataUtils.getNextWeekDayTime(now, fightConfig[1]), fightConfig[2][1], fightConfig[2][2], 0)
    end
    
    cp.getManager("LocalDataManager"):setValue("", "red_notify", "fight_list", nextTime)
    --self:dispatchViewEvent("GuildPrepareFightRsp")
    self:dispatchViewEvent("updateFightActivity")
	self.ListView_List:setScrollBarEnabled(false)
end

function GuildFightGuildLayer:updateOneFightCity(fightGuildInfo, img)
    local txtLeftCount = img:getChildByName("Text_LeftCount")
    local txtLeftName = img:getChildByName("Text_LeftName")
    local imgLeftWin = img:getChildByName("Image_LeftWin")
    local imgRightWin = img:getChildByName("Image_RightWin")
    local btn = img:getChildByName("Button_Detail")
    local txtRightCount = img:getChildByName("Text_RightCount")
    local txtRightName = img:getChildByName("Text_RightName")

    txtLeftCount:setString(fightGuildInfo.left_score)
    txtRightCount:setString(fightGuildInfo.right_score)
    txtLeftName:setString(fightGuildInfo.left_name)
    txtRightName:setString(fightGuildInfo.right_name)
    if fightGuildInfo.left_win then
        imgLeftWin:loadTexture("ui_guild_module_bangpai_38.png", ccui.TextureResType.plistType)
        imgRightWin:loadTexture("ui_guild_module_bangpai_37.png", ccui.TextureResType.plistType)
    else
        imgLeftWin:loadTexture("ui_guild_module_bangpai_37.png", ccui.TextureResType.plistType)
        imgRightWin:loadTexture("ui_guild_module_bangpai_38.png", ccui.TextureResType.plistType)
    end

    cp.getManager("ViewManager").initButton(btn, function()
        local layer = require("cp.view.scene.guild.GuildFightCombatLayer"):create(fightGuildInfo)
        self:addChild(layer, 100)
    end)
end

function GuildFightGuildLayer:updateGuildFightGuildView()
    local DataUtils = cp.getUtils("DataUtils")
    for i=1, 6 do
        local btn = self["Button_City"..i]
        cp.getManager("ViewManager").initButton(btn, function()
            self["Button_City"..self.city]:setEnabled(true)
            btn:setEnabled(false)
            self.city = i

            local guildList = cp.getUserData("UserGuild"):getFightGuildList(self.city)
            if guildList == nil then
                local req = {}
                req.city = self.city
                self:doSendSocket(cp.getConst("ProtoConst").GetGuildFightCityReq, req)
            else
                self:updateGuildFightGuildView()
            end
        end)

        if i == self.city then
            btn:setEnabled(false)
        else
            btn:setEnabled(true)
        end
    end

    local listView = self.ListView_List
    local guildList = cp.getUserData("UserGuild"):getFightGuildList(self.city)
    if guildList == nil then
        local req = {}
        req.city = self.city
        self:doSendSocket(cp.getConst("ProtoConst").GetGuildFightCityReq, req)
        listView:removeAllItems()
        return
    end

    local imgModel = self.Image_Model
    listView:removeAllItems()

    for i, fightGuildInfo in ipairs(guildList) do
        local img = imgModel:clone()
        listView:pushBackCustomItem(img)
        img:setVisible(true)
        self:updateOneFightCity(fightGuildInfo, img)
    end

    if self.owner:len() > 0 then    
        local cityName = cp.getConst("GameConst").CityName[self.city]
        self.Text_Result:setString(string.format("恭喜 %s 成功佔領%s", self.owner, cityName))
    else
        self.Text_Result:setString("")
    end

    if #guildList == 0 then
        local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
        local fightConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
        local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
        local phase, remainTime = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
        if phase == 2 or phase == 3 then
            local nearWD = DataUtils.convertWeekDay(DataUtils.getNearestWeekDay(weekDay, fightConfig[1]))
            self.Text_Empty:setString(string.format("攻掠戰正在籌備階段\n結果將在%s21點30分揭曉\n敬請期待...", DataUtils.GetWeekDayZh_CN(nearWD, weekDay)))
        else
            if self.owner:len() > 0 then
                self.Text_Empty:setString("該城市無其他幫派爭奪，被唯一進攻方直接佔領！")
            else
                self.Text_Empty:setString("無戰鬥記錄")
            end
        end
        return
    end

    self.Text_Empty:setString("")
    
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
    local phase, remainTime = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
    if phase == 4 then
        self.Text_Phase:setString("本次攻掠戰")
    else
        self.Text_Phase:setString("上次攻掠戰")
    end
end

function GuildFightGuildLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Back" then
        self:removeFromParent()
    elseif nodeName == "Button_Begin" then
        --local layer = require("cp.view.scene.guild.GuildFightGuildLayer"):create()
        --self:addChild(layer, 100)
	end
end

function GuildFightGuildLayer:onEnterScene()
	self:updateGuildFightGuildView()
end

function GuildFightGuildLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildFightGuildLayer