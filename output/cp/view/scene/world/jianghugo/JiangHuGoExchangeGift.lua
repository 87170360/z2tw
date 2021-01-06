local BNode = require "cp.view.ui.base.BNode"
local JiangHuGoExchangeGift = class("JiangHuGoExchangeGift",BNode)

function JiangHuGoExchangeGift:create()
	local node = JiangHuGoExchangeGift.new()
	return node
end

function JiangHuGoExchangeGift:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").FulfillGiftRsp] = function(data)	
			cp.getManager("ViewManager").closeExchangeGiftUI()
        end,
	}
end

function JiangHuGoExchangeGift:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_exchange_input.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
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
    
    ccui.Helper:doLayout(self["rootView"])
end

function JiangHuGoExchangeGift:onEnterScene()
end

function JiangHuGoExchangeGift:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	
	if buttonName == "Button_close" or buttonName == "Button_cancel" then
		cp.getManager("ViewManager").closeExchangeGiftUI()
	elseif buttonName == "Button_OK" then
		local code = self.TextField_input:getString()
		if self:checkRules(code) then
            --發送兌換消息
            local req = {}
			req.code = code
			self:doSendSocket(cp.getConst("ProtoConst").FulfillGiftReq, req)
        end
	end
end

function JiangHuGoExchangeGift:checkRules(str)
    if string.len(string.trim(str)) == 0 then
        cp.getManager("ViewManager").gameTip("輸入cdkey不能為空")
        return false
    end
    
    return true
end


function JiangHuGoExchangeGift:getDescription()
    return "JiangHuGoExchangeGift"
end

return JiangHuGoExchangeGift
