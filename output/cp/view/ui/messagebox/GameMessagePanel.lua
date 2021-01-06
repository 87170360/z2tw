local BLayer = require "cp.view.ui.base.BLayer"
local GameMessageBoxPanel = class("GameMessageBoxPanel", BLayer)

function GameMessageBoxPanel:create(title, txt)
	local scene = GameMessageBoxPanel.new(txt)
    return scene
end

function GameMessageBoxPanel:initListEvent()
	self.listListeners = {
	}
end

function GameMessageBoxPanel:onInitView(txt)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_messagebox_panel.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_bg.Node_Place"] = {name = "Node_Place"},
        ["Panel_root.Image_bg.Image_title.Text_title"] = {name = "Text_title" },
		["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel" ,click = "onBtnClick"},
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onBtnClick"},
		["Panel_root.Image_bg.Button_cancel.Text_1"] = {name = "Text_cancel" },
		["Panel_root.Image_bg.Button_OK.Text_1"] = {name = "Text_OK"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	local richText, sz = self:createRichText(txt)

	cp.getManager("ViewManager").setWidgetAdapt(50, {self.Image_bg, self.Image_1}, sz.height)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root, function()
		if self.closeCallback then
			self.closeCallback()
		end
	end)
	ccui.Helper:doLayout(self.rootView)

	richText:setPosition(self.Node_Place:getPosition())
	cp.getManager("ViewManager").popUpViewEx(self.Image_bg)
end

function GameMessageBoxPanel:createRichText(txt)
    local sz = cc.size(500, 9000)
    local richText = cp.getUtils("RichTextUtils").ParseRichText(txt)
    richText:setName("RichText_Desc")

	richText:setContentSize(cc.size(sz.width-20,9000))
	
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(tsize.width,tsize.height))

    self.Image_bg:addChild(richText)

    richText:setAnchorPoint(cc.p(0.5,1))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(231,120))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    --richText:setLineGap(1)
    return richText, tsize
end

function GameMessageBoxPanel:setCloseCallback(cb, txt)
	self.closeCallback = cb
	if txt and txt:len() > 0 then
		self.Text_cancel:setString(txt)
	end
end

function GameMessageBoxPanel:setConfirmCallback(cb, txt)
	self.confirmCallback = cb
	if txt and txt:len() > 0 then
		self.Text_OK:setString(txt)
	end
end

function GameMessageBoxPanel:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_cancel" then
		if self.closeCallback then
			self.closeCallback()
		end

		self:removeFromParent()
	elseif nodeName == "Button_OK" then
		if self.confirmCallback then
			self.confirmCallback()
		end

		self:removeFromParent()
	end
end

return GameMessageBoxPanel