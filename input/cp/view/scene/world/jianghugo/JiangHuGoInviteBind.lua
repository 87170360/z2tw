local BNode = require "cp.view.ui.base.BNode"
local JiangHuGoInviteBind = class("JiangHuGoInviteBind",BNode)

function JiangHuGoInviteBind:create()
	local node = JiangHuGoInviteBind.new()
	return node
end

function JiangHuGoInviteBind:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").InviteBindRsp] = function(data)
			cp.getManager("ViewManager").gameTip("綁定邀請碼成功")
			cp.getManager("PopupManager"):removePopup(self)
        end,
	}
end

function JiangHuGoInviteBind:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_exchange_input.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_title.Text_title"] = {name = "Text_title"},
        ["Panel_root.Image_bg.Text_content"] = {name = "Text_content"},
		["Panel_root.Image_bg.TextField_input"] = {name = "TextField_input" },
		["Panel_root.Image_bg.Button_close"] = {name = "Button_close" ,click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onUIButtonClick"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
    
    local extraInfo = {pos = cc.p(-display.cx,-display.cy)}
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_input,"cdkeyInputBox",extraInfo)
	
	self.TextField_input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.TextField_input:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

    self.Text_title:setString("綁定好友")
    self.Text_content:setString("請輸入您好友的邀請碼")
    
    ccui.Helper:doLayout(self["rootView"])
end

function JiangHuGoInviteBind:onEnterScene()
end

function JiangHuGoInviteBind:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	
	if buttonName == "Button_close" or buttonName == "Button_cancel" then
		cp.getManager("PopupManager"):removePopup(self)
	elseif buttonName == "Button_OK" then
        local yaoqingma = self.TextField_input:getString()
		if self:checkRules(yaoqingma) then
            --發送綁定邀請碼消息
            local req = {}
			req.code = yaoqingma
			self:doSendSocket(cp.getConst("ProtoConst").InviteBindReq, req)
        end
	end
end

function JiangHuGoInviteBind:checkRules(str)
    if string.len(string.trim(str)) == 0 then
        cp.getManager("ViewManager").gameTip("輸入的邀請碼不能為空")
        return false
    end
    
    return true
end


function JiangHuGoInviteBind:getDescription()
    return "JiangHuGoInviteBind"
end

return JiangHuGoInviteBind
