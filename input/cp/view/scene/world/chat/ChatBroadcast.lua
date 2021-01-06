
local BNode = require "cp.view.ui.base.BNode"
local ChatBroadcast = class("ChatBroadcast",BNode)


function ChatBroadcast:create()
    local node = ChatBroadcast.new()
    return node
end

function ChatBroadcast:initListEvent()
    self.listListeners = {}
end

function ChatBroadcast:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_chat_broadcast.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Image_bg"] = {name = "Image_bg"},
		["Image_bg.Panel_content"] = {name = "Panel_content"},
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	ccui.Helper:doLayout(self.rootView)

	self.TAG_RICHTEXT = 1000
end

function ChatBroadcast:onEnterScene()

end


function ChatBroadcast:show()
	if self["Panel_content"]:getActionByTag(self.TAG_RICHTEXT) == nil then
		local rep = cc.RepeatForever:create(
			cc.Sequence:create(
				cc.CallFunc:create(handler(self,self.autoMoveRichText)),
				cc.DelayTime:create(0.01)
			)
		)
		rep:setTag(self.TAG_RICHTEXT)
		self["Panel_content"]:runAction(rep)
	end
end



function ChatBroadcast:createRichText(contentTable)
	if table.nums(contentTable) == 0 then
		return nil,cc.size(0,0)
	end
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	local height = self.Panel_content:getContentSize().height
    richText:setContentSize(cc.size(10000,height))
    richText:setAnchorPoint(cc.p(0,0.5))
	richText:ignoreContentAdaptWithSize(false)
    richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
	richText:setLineGap(0)
	richText:setName("richText")
	richText:formatText()
    local txtSize = richText:getTextSize()
	richText:setContentSize(cc.size(txtSize.width,height))
	richText:setTouchEnabled(false)
	txtSize = richText:getTextSize()
    return richText,txtSize
end

function ChatBroadcast:autoMoveRichText()
	local richText = self["Panel_content"]:getChildByName("richText")
	if not richText then
		local broadcast_msg_list = cp.getUserData("UserChatData"):getValue("broadcast_msg_list")
		local message = broadcast_msg_list[1] 
		if message then
			local size = self["Panel_content"]:getContentSize()
			local contentTable = cp.getUtils("RichTextUtils").ParseRichText(message,true)
			local richText = self:createRichText(contentTable)
			if richText then
				self["Panel_content"]:addChild(richText)
				richText:setPosition(cc.p(size.width, size.height / 2))
			end
		else
			self["Panel_content"]:stopActionByTag(self.TAG_RICHTEXT)
			self:removeFromParent()
		end
	end
	local textSize = richText:getTextSize()
	richText:setPositionX(richText:getPositionX() - 1)
	if richText:getPositionX() <= -textSize.width - 3 then
		local broadcast_msg_list = cp.getUserData("UserChatData"):getValue("broadcast_msg_list")
		table.remove(broadcast_msg_list, 1)
		richText:removeFromParent()
	end
end


function ChatBroadcast:getDescription()
	return "ChatBroadcast"
end

return ChatBroadcast