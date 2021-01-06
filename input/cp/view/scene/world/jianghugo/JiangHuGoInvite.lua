local BNode = require "cp.view.ui.base.BNode"
local JiangHuGoInvite = class("JiangHuGoInvite",BNode)

function JiangHuGoInvite:create()
	local node = JiangHuGoInvite.new()
	return node
end

function JiangHuGoInvite:initListEvent()
	self.listListeners = {
	}
end

function JiangHuGoInvite:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_share.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Panel_1.Image_head"] = {name = "Image_head" },
        ["Panel_root.Image_bg.Text_content"] = {name = "Text_content" },
		["Panel_root.Image_bg.Text_Invite_Number"] = {name = "Text_Invite_Number" },
        ["Panel_root.Image_bg.Button_close"] = {name = "Button_close" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onUIButtonClick"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	local channelName = cp.getManualConfig("Channel").channel
	local name = "逐鹿江湖"
	if channelName == "xiaomi" or channelName == "xiaomi1" then
		name = "佛系武俠"
	end

	self.Text_content:setString(string.format([[
親愛的俠友:

        您的邀請碼是：
        點擊按鈕，邀請小夥伴一起來玩《%s》吧！小夥伴登錄遊戲，在江湖行界面輸入俠友的邀請碼，即可與俠友達成攜手關係，記得小夥伴20級以內才可攜手哦！隨著小夥伴的成長，攜手雙方都將獲得豐厚獎勵，邀請的夥伴越多，獎勵越給力哦！
	]],name))

    ccui.Helper:doLayout(self["rootView"])
end

function JiangHuGoInvite:onEnterScene()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    self.Image_head:loadTexture("img/model/head/" .. majorRole.face .. ".png", UI_TEX_TYPE_LOCAL)
	
	local invite_code = cp.getUserData("UserInvite"):getValue("invite_code") 
    self.Text_Invite_Number:setString(invite_code or "")
end

function JiangHuGoInvite:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	
	if buttonName == "Button_close" then
		cp.getManager("PopupManager"):removePopup(self)
	elseif buttonName == "Button_OK" then
		local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local name = majorRole.name
		local strNum = self.Text_Invite_Number:getString()
		local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
		local server = lastServerInfo.name
		local server_id = lastServerInfo.id
		local channelName = cp.getManualConfig("Channel").channel	
		local shareUrl = cp.getManager("GDataManager"):getGameConfigByChannel(channelName, "shareUrl")

		local name = "逐鹿江湖"
		if channelName == "xiaomi" or channelName == "xiaomi1" then
			name = "佛系武俠"
		end
		
		local str = string.format("橫刀立馬，捨我其誰！策略型武俠回合制手遊《" .. name .. "》，等你來戰！我是 %s ,我在 %d服【%s】等你！\n我的邀請碼是：%s 在遊戲界面裡輸入即可與我攜手江湖哦！",name,server_id,server,strNum)
		local str = str .. shareUrl
		--if device.platform == "windows" then
			--cp.getManager("ViewManager").gameTip("暫不支持，請在Android或ios設備分享。")
		--else
			local ret = cc.Device:copyToClipboard(str)
			if ret == 0 then
				cp.getManager("ViewManager").gameTip("複製成功，請大俠去粘貼分享吧！")
			end
		--end
		
	end
end


function JiangHuGoInvite:getDescription()
    return "JiangHuGoInvite"
end

return JiangHuGoInvite
