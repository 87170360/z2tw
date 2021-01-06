local BLayer = require "cp.view.ui.base.BLayer"
local GuildManageLayer = class("GuildManageLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildManageLayer:create(id)
	local scene = GuildManageLayer.new()
	scene.id = id
    return scene
end

function GuildManageLayer:initListEvent()
    self.listListeners = {
		["AppointGuildManagerRsp"] = function(data)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildManageLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_manage.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Name.Text_Name"] = {name = "Text_Name"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Owner"] = {name = "Button_Owner", click="onBtnClick"},
		["Panel_root.Image_1.Button_Deputy"] = {name = "Button_Deputy", click="onBtnClick"},
		["Panel_root.Image_1.Button_Elder"] = {name = "Button_Elder", click="onBtnClick"},
		["Panel_root.Image_1.Button_Abort"] = {name = "Button_Abort", click="onBtnClick"},
		["Panel_root.Image_1.Button_Expel"] = {name = "Button_Expel", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    ccui.Helper:doLayout(self.rootView)
end

function GuildManageLayer:updateGuildManageView()
	local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.id)
	if memberInfo.duty == 0 then
		cp.getManager("ViewManager").setEnabled(self.Button_Abort, false)
	else
		cp.getManager("ViewManager").setEnabled(self.Button_Abort, true)
	end
	--local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(self.id)
	--self.Text_Name:setString(string.format("任命 %s 為", playerSimpleInfo.name))
end

function GuildManageLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
	elseif nodeName == "Button_Owner" or nodeName == "Button_Deputy" or nodeName == "Button_Elder" or nodeName == "Button_Abort" or nodeName == "Button_Expel" then
		local req = {}
		req.id = self.id
        local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
		req.duty = tonumber(extensionData:getCustomProperty())

		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local myMemberInfo = cp.getUserData("UserGuild"):getMemberInfo(roleAtt.id)
		if myMemberInfo.duty <= req.duty and myMemberInfo.duty ~= 3 then
			cp.getManager("ViewManager").gameTip("沒有操作權限")
			return
		end
		local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(self.id)
		local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.id)
		if memberInfo.duty == req.duty then
			cp.getManager("ViewManager").gameTip("無法重複任命同一個職位")
			return
		end

		if nodeName == "Button_Owner" or nodeName == "Button_Expel" then
			local contentTable = {}
			if nodeName == "Button_Owner" then
				table.insert(contentTable, {
					type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否將幫主轉讓給 ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2
				})
				table.insert(contentTable, {
					type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=playerSimpleInfo.name.." ?", textColor=cc.c4b(117,233,90,255), outLineColor=cc.c4b(39,118,37,255), outLineSize=2
				})
			else
				table.insert(contentTable, {
					type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否將 ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2
				})
				table.insert(contentTable, {
					type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=playerSimpleInfo.name, textColor=cc.c4b(117,233,90,255), outLineColor=cc.c4b(39,118,37,255), outLineSize=2
				})
				table.insert(contentTable, {
					type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=" 踢出幫派?", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2
				})
			end

			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
				self:doSendSocket(cp.getConst("ProtoConst").AppointGuildManagerReq, req)
			end,nil)
		else
			self:doSendSocket(cp.getConst("ProtoConst").AppointGuildManagerReq, req)
		end
	end
end

function GuildManageLayer:onEnterScene()
	self:updateGuildManageView()
end

function GuildManageLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildManageLayer