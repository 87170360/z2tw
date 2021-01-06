local BLayer = require "cp.view.ui.base.BLayer"
local GuildListLayer = class("GuildListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildListLayer:create()
	local scene = GuildListLayer.new()
    return scene
end

function GuildListLayer:initListEvent()
    self.listListeners = {
        ["GetJoinGuildListRsp"] = function(guildList)
            self.guildList = guildList
			self:updateGuildListView()
		end,
        ["GetGuildByNameRsp"] = function(data)
            self.searchGuild = data.data
			self:updateSearchListView()
		end,
        ["JoinGuildRsp"] = function(id)
            for _, guildInfo in ipairs(self.guildList) do
                if guildInfo.id == id then
                    guildInfo.joining = true
                    break
                end
            end
            if self.searchGuild then
                self.searchGuild.joining = true
                self:updateSearchListView()
            else
                self:updateGuildListView()
            end
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.selectGuild = 0
    
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GetJoinGuildListReq, {})
    self.guildList = {}
    local childConfig = {
		["Panel_root.Image_top.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_bottom"] = {name = "Image_bottom"},
		["Panel_root.Image_bottom.Image_List"] = {name = "Image_List"},
		["Panel_root.Image_bottom.Image_List.ScrollView_GuildList"] = {name = "ScrollView_GuildList"},
		["Panel_root.Image_bottom.Image_List.ScrollView_GuildList.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_bottom.Image_Spirit.Text_Spirit"] = {name = "Text_Spirit"},
		["Panel_root.Image_bottom.Image_Search.TextField_Search"] = {name = "TextField_Search"},
		["Panel_root.Image_bottom.Button_Create"] = {name = "Button_Create", click="onBtnClick"},
		["Panel_root.Image_bottom.Button_Search"] = {name = "Button_Search", click="onBtnClick"},
		["Panel_root.Image_bottom.Button_Refresh"] = {name = "Button_Refresh", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.TextField_Search,"InputBox_Search",nil)
    local deltaY = display.height - 1280
    local size = self.ScrollView_GuildList:getSize()
    size.height = size.height + deltaY
    self.ScrollView_GuildList:setSize(size)

    local size = self.Image_List:getSize()
    size.height = size.height + deltaY
    self.Image_List:setSize(size)

    local size = self.Image_bottom:getSize()
    size.height = size.height + deltaY
    self.Image_bottom:setSize(size)

    self.ScrollView_GuildList:setScrollBarEnabled(false)
    ccui.Helper:doLayout(self.rootView)
end

function GuildListLayer:updateOneGuildInfo(index, model, guildInfo)
    local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildInfo.level)
    local txtName = model:getChildByName("Text_Name")
    local txtLevel = model:getChildByName("Text_Level")
    local txtMember = model:getChildByName("Text_Member")
    local txtOwner = model:getChildByName("Text_Owner")
    local btnRequest = model:getChildByName("Button_Request")
    local imgFlag = model:getChildByName("Image_Flag")
    txtName:setString(guildInfo.name)
    txtLevel:setString(guildInfo.level)
    txtMember:setString(string.format("%d/%d", guildInfo.member,guildLevelConfig:getValue("MaxMember")))
    txtOwner:setString(guildInfo.owner)
    cp.getManager("ViewManager").setEnabled(btnRequest, not guildInfo.joining)
    cp.getManager("ViewManager").initButton(btnRequest, function()
        local req = {}
        req.id = guildInfo.id
        self:doSendSocket(cp.getConst("ProtoConst").JoinGuildReq, req)
    end)

    cp.getManager("ViewManager").initButton(model, function()
        if self.selectGuild ~= 0 then
            self.ScrollView_GuildList:getChildByName("Image_Model"..self.selectGuild):getChildByName("Image_Flag"):setVisible(false)
        end

        imgFlag:setVisible(true)
        self.selectGuild = index
        self.Text_Spirit:setString(guildInfo.spirit)
    end, 1)
end

function GuildListLayer:updateSearchListView()
    local size = self.ScrollView_GuildList:getSize()
    local innerSize = size
    if 80 + 4 > size.height then
        innerSize.height = #self.guildList*80 + 4
    end
    
    self.ScrollView_GuildList:setInnerContainerSize(innerSize)
    ccui.Helper:doLayout(self.ScrollView_GuildList)

    for i=1, 20 do
        local model = self.ScrollView_GuildList:getChildByName("Image_Model"..i)
        if not model then
            model = self.Image_Model:clone()
            self.ScrollView_GuildList:addChild(model)
            model:setName("Image_Model"..i)
        end

        model:setPosition(326, innerSize.height - 44 -(i-1)*80)
        if self.searchGuild.id > 0 and i == 1 then
            model:setVisible(true)
            self:updateOneGuildInfo(i, model, self.searchGuild)
        else
            model:setVisible(false)
        end
    end

    self.Button_Search:getChildByName("Text"):setString("清  除")
end

function GuildListLayer:updateGuildListView()
    local size = self.ScrollView_GuildList:getSize()
    local innerSize = size
    if #self.guildList*80 + 4 > size.height then
        innerSize.height = #self.guildList*80 + 4
    end
    
    self.ScrollView_GuildList:setInnerContainerSize(innerSize)
    ccui.Helper:doLayout(self.ScrollView_GuildList)
    
    for i=1, 20 do
        local model = self.ScrollView_GuildList:getChildByName("Image_Model"..i)
        if not model then
            model = self.Image_Model:clone()
            self.ScrollView_GuildList:addChild(model)
            model:setName("Image_Model"..i)
        end

        model:setPosition(326, innerSize.height - 44 -(i-1)*80)
        if self.guildList[i] then
            model:setVisible(true)
            self:updateOneGuildInfo(i, model, self.guildList[i])
        else
            model:setVisible(false)
        end
    end
    self.Button_Search:getChildByName("Text"):setString("搜  索")
end

function GuildListLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
    elseif nodeName == "Button_Create" then
        local layer = require("cp.view.scene.guild.GuildCreateLayer"):create()
        self:addChild(layer, 100)
    elseif nodeName == "Button_Search" then
        if self.searchGuild ~= nil then
            self.searchGuild = nil
            self.TextField_Search:setString("")
            self:updateGuildListView()
            return
        end
        local name = self.TextField_Search:getString()
        local createGuildConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:")[4]
        local hanzCount, nhzCount = cp.getUtils("DataUtils").getHanziNum(name)
        if hanzCount < createGuildConfig[1] or hanzCount > createGuildConfig[2] then
            cp.getManager("ViewManager").gameTip(string.format("幫派名為%d~%d個漢字", createGuildConfig[1], createGuildConfig[2]))
            return
        end
        local req = {}
        req.name = name
        self:doSendSocket(cp.getConst("ProtoConst").GetGuildByNameReq, req)
    elseif nodeName == "Button_Refresh" then
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GetJoinGuildListReq, {})
	end
end

function GuildListLayer:onEnterScene()
	self:updateGuildListView()
end

function GuildListLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildListLayer