
local BNode = require "cp.view.ui.base.BNode"
local NewGuideTypeWriter = class("NewGuideTypeWriter",BNode)

function NewGuideTypeWriter:create(talkText)
    local node = NewGuideTypeWriter.new(talkText)
    return node
end


function NewGuideTypeWriter:initListEvent()
    self.listListeners = {}
end


function NewGuideTypeWriter:onInitView(talkText)
	self.talkText = talkText

    local colorBg = cc.LayerColor:create(cc.c4b(0,0,0,255), display.width, display.height)
    colorBg:setPosition(cc.p(0,0))
	colorBg:setTouchEnabled(true)
	self.colorBg = colorBg
	self:addChild(colorBg)

	local Text_show = ccui.Text:create()
    Text_show:setText(tostring(self.talkText))
    Text_show:setFontName("fonts/msyh.ttf") 
    Text_show:setAnchorPoint(cc.p(0.5, 0.5))
    Text_show:setTextColor(cc.c4b(255, 255, 255,255))
    Text_show:setFontSize(24)
	Text_show:enableOutline(cc.c4b(64, 64, 64, 255), 2)
	Text_show:ignoreContentAdaptWithSize(true)
	Text_show:setTextAreaSize({width = 0, height = 0})
	colorBg:addChild(Text_show)
	Text_show:setPosition(cc.p(display.cx,display.cy))
	Text_show:getAutoRenderSize()
	local sz = Text_show:getVirtualRendererSize()
	self.Text_show = Text_show
	self.totalSize = sz
	self.Text_show:setVisible(false)
end

function NewGuideTypeWriter:onEnterScene()
	self.Text_show:getAutoRenderSize()
	local sz = self.Text_show:getVirtualRendererSize()
	self.Text_show:setAnchorPoint(cc.p(0, 1))
	self.Text_show:setPosition(cc.p(display.cx-sz.width/2,display.cy+sz.height))
	self.totalSize = sz
	
	local total = string.utf8len_m(self.talkText)
	log("NewGuideTypeWriter:onEnterScene total = " .. tostring(total))

	self.curIndex = 1
	self.total = total
	self.Text_show:stopAllActions()
	self.Text_show:setOpacity(255)
	local oneAction = cc.Sequence:create(cc.CallFunc:create(handler(self,self.showWords)), cc.DelayTime:create(0.1))
	self.Text_show:runAction(cc.Sequence:create(
		cc.Repeat:create(oneAction, self.total),
		cc.FadeOut:create(3),
		cc.CallFunc:create(handler(self,self.closeTypeWriter))
	))
end

function NewGuideTypeWriter:showWords()
	if self.curIndex > self.total then
		return
	end
	local str = string.msubstr(self.talkText,self.curIndex)
	log("i=%d,%s",self.curIndex,str)
	self.curIndex = self.curIndex + 1
	
	self.Text_show:setVisible(true)
	self.Text_show:setString(str)

end

function NewGuideTypeWriter:closeTypeWriter()
	if self.callBack then
		self.callBack()
	end
end

function NewGuideTypeWriter:setFinishedCallBack(cb)
	self.callBack = cb
end

return NewGuideTypeWriter