local BLayer = require "cp.view.ui.base.BLayer"
local GuildCityInfoLayer = class("GuildCityInfoLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildCityInfoLayer:create(city, id, owner)
    local scene = GuildCityInfoLayer.new()
    scene.city = city
    scene.id = id
    scene.owner = owner
    return scene
end

function GuildCityInfoLayer:initListEvent()
    self.listListeners = {
        ["GuildPrepareFightRsp"] = function(data)
            self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildCityInfoLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_city_info.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Owner.Text"] = {name = "Text_Owner"},
		["Panel_root.Image_1.Text_Intro"] = {name = "Text_Intro"},
		["Panel_root.Image_1.Text_Desc"] = {name = "Text_Desc"},
		["Panel_root.Image_1.Text_City"] = {name = "Text_City"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Record"] = {name = "Button_Record", click="onBtnClick"},
		["Panel_root.Image_1.Button_Join"] = {name = "Button_Join", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
end

function GuildCityInfoLayer:updateGuildCityInfoView()
    local cityConfig = cp.getManager("ConfigManager").getItemByKey("GuildCity", self.city)
    self.Text_City:setString(cityConfig:getValue("Name"))
    self.Text_Intro:setString(cityConfig:getValue("Intro"))
    
	local richText = cp.getUtils("RichTextUtils").ParseRichText(cityConfig:getValue("Desc"))
	richText:setPosition(82, 312)
    richText:setContentSize(cc.size(462,123))
    self.Image_1:addChild(richText)
    
    --self.Text_Desc:setString("幫派收益\n"..cityConfig:getValue("Desc"))


    if self.id == 0 then
        self.Text_Owner:setString("無幫派佔領")
    else
        self.Text_Owner:setString("佔領者 "..self.owner)
    end
end

function GuildCityInfoLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Record" then
        local layer = require("cp.view.scene.guild.GuildFightGuildLayer"):create(self.city)
        self:addChild(layer, 100)
    elseif nodeName == "Button_Join" then
        if self.id == 0 then
            cp.getManager("ViewManager").gameTip("當前城市無幫派佔領")
            return 
        end
        local req = {}
        req.id = self.id
        self:doSendSocket(cp.getConst("ProtoConst").JoinGuildReq, req)
	end
end

function GuildCityInfoLayer:onEnterScene()
	self:updateGuildCityInfoView()
end

function GuildCityInfoLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildCityInfoLayer