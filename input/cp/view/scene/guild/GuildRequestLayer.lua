local BLayer = require "cp.view.ui.base.BLayer"
local GuildRequestLayer = class("GuildRequestLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildRequestLayer:create()
	local scene = GuildRequestLayer.new()
    return scene
end

function GuildRequestLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetRoleSimpleRsp] = function(data)
			self:updateGuildRequestView()
		end,
		["JoinGuildNotifyRsp"] = function(data)
			self:updateGuildRequestView()
		end,
		["HandleJoinGuildRsp"] = function(data)
			self:updateGuildRequestView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildRequestLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_request.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_List.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.Image_List.ListView_List"] = {name = "ListView_List"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
    self.ListView_List:setScrollBarEnabled(false)
	
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local req = {}
    req.player_list = {}
    for _, requestID in ipairs(guildDetailData.request_list.request_list) do
        local playerInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(requestID)
        if not playerInfo then
            table.insert(req.player_list, {
                id = requestID
            })
        end
	end
	if #req.player_list > 0 then
		self:doSendSocket(cp.getConst("ProtoConst").GetRoleSimpleReq, req)
	end
end

function GuildRequestLayer:updateOneGuildRequest(id, img)
    local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(id)
    local imgHead = img:getChildByName("Image_Head")
    local txtName = img:getChildByName("Text_Name")
    local txtFight = img:getChildByName("Text_Fight")
    local txtLevel = img:getChildByName("Text_Level")
    local txtCareer = img:getChildByName("Text_Career")
    local btnAgree = img:getChildByName("Button_Agree")
    local btnDeline = img:getChildByName("Button_Deline")
    if not playerSimpleInfo then return end
    imgHead:loadTexture(cp.DataUtils.getModelFace(playerSimpleInfo.face))
    txtName:setString(playerSimpleInfo.name)
    txtFight:setString("戰力   "..playerSimpleInfo.fight)
    txtLevel:setString("LV."..playerSimpleInfo.level)
    txtCareer:setString(playerSimpleInfo.career)

	cp.getManager("ViewManager").initButton(btnAgree, function()
		local req = {}
		req.id = id
		req.agree = true
		self:doSendSocket(cp.getConst("ProtoConst").HandleJoinGuildReq, req)
	end)
	
    cp.getManager("ViewManager").initButton(btnDeline, function()
		local req = {}
		req.id = id
		req.agree = false
		self:doSendSocket(cp.getConst("ProtoConst").HandleJoinGuildReq, req)
    end)
end

function GuildRequestLayer:updateGuildRequestView()
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
	local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()

	local listView = self.ListView_List
	local imgModel = self.Image_Model
    local children = listView:getItems()
    for i=#guildDetailData.request_list.request_list, #children-1 do
        listView:removeItem(i)
	end

    for i, id in ipairs(guildDetailData.request_list.request_list) do
        local img = listView:getItem(i-1)
        if not img then
            img = imgModel:clone()
            listView:pushBackCustomItem(img)
            img:setVisible(true)
        end
        self:updateOneGuildRequest(id, img)
    end
end

function GuildRequestLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Cancel" then
        self:removeFromParent()
	end
end

function GuildRequestLayer:onEnterScene()
	self:updateGuildRequestView()
end

function GuildRequestLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildRequestLayer