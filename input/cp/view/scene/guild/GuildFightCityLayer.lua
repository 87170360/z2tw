local BLayer = require "cp.view.ui.base.BLayer"
local GuildFightCityLayer = class("GuildFightCityLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildFightCityLayer:create(phase)
	local scene = GuildFightCityLayer.new()
    return scene
end

function GuildFightCityLayer:initListEvent()
    self.listListeners = {
        ["GuildPrepareFightRsp"] = function(data)
            self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildFightCityLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_fight_city.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.city = 1
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Desc"] = {name = "Image_Desc"},
		["Panel_root.Image_1.Button_City1"] = {name = "Button_City1"},
		["Panel_root.Image_1.Button_City2"] = {name = "Button_City2"},
		["Panel_root.Image_1.Button_City3"] = {name = "Button_City3"},
		["Panel_root.Image_1.Button_City4"] = {name = "Button_City4"},
		["Panel_root.Image_1.Button_City5"] = {name = "Button_City5"},
		["Panel_root.Image_1.Button_City6"] = {name = "Button_City6"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Attack"] = {name = "Button_Attack", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
    self.Button_City1:setEnabled(false)
    self:setCitySelected(1)
end

function GuildFightCityLayer:setCitySelected(city)
    local cityConfig = cp.getManager("ConfigManager").getItemByKey("GuildCity", city)
    self.Image_Desc:removeChildByName("RichText_Desc")
    local richText = cp.getUtils("RichTextUtils").ParseRichText(cityConfig:getValue("Desc"))
    richText:setPosition(56, 212)
    richText:setName("RichText_Desc")
    richText:setContentSize(cc.size(580,164))
    richText:setScale(1.1)
    self.Image_Desc:addChild(richText)
end

function GuildFightCityLayer:updateGuildFightCityView()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    for i=1, 6 do
        local cityConfig = cp.getManager("ConfigManager").getItemByKey("GuildCity", i)
        local btn = self["Button_City"..i]
        if cityConfig:getValue("Level") > guildDetailData.level then
            cp.getManager("ViewManager").setEnabled(btn, false)
        end
        cp.getManager("ViewManager").initButton(btn, function()
            self["Button_City"..self.city]:setEnabled(true)
            btn:setEnabled(false)
            self.city = i
            self:setCitySelected(i)
        end)
    end
end

function GuildFightCityLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Attack" then
        local req = {}
        req.city = self.city
        self:doSendSocket(cp.getConst("ProtoConst").GuildPrepareFightReq, req)
	end
end

function GuildFightCityLayer:onEnterScene()
	self:updateGuildFightCityView()
end

function GuildFightCityLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildFightCityLayer