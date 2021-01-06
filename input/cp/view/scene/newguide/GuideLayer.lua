local BNode = require "cp.view.ui.base.BNode"
local GuideLayer = class("GuideLayer",BNode)

function GuideLayer:create(widget, delay)
	local node = GuideLayer.new(widget)
	if delay > 0 then
		node.delaying = true
		node.fingerGuideNode:setVisible(false)
		node.colorBg:initWithColor(cc.c4b(0,0,0,0))
		node.colorBg:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
			node.delaying = false
			node.fingerGuideNode:setVisible(true)
			node.colorBg:initWithColor(cc.c4b(0,0,0,100))
		end)))
	end
    return node
end

function GuideLayer:initListEvent()
    self.listListeners = {
		["GuideLayerCloseMsg"] = function()
			self:removeFromParent()
		end,
	}
end

function GuideLayer:setStencil(widget)
	local clone = widget:clone()
	self.widget = widget
	local boundingBox = widget:getBoundingBox()
	local anchorPoint = widget:getAnchorPoint()
	local pos = widget:getParent():convertToWorldSpace(cc.p(boundingBox.x + boundingBox.width*anchorPoint.x,boundingBox.y + boundingBox.height*anchorPoint.y))
	clone:setPosition(pos)
	local stencil = cc.Node:create()
	stencil:addChild(clone)

	local originPos = widget:getParent():convertToWorldSpace(cc.p(boundingBox.x, boundingBox.y))
	self.touchRect = cc.rect(originPos.x, originPos.y, boundingBox.width, boundingBox.height)
	self.clipnode:setStencil(stencil) --設置裁剪模板
	local dir = "right"
	-- local finger_info = {pos = cc.p(680,1060), finger = {guide_type = "point",dir="right"} }
	local fingerInfo = {
		pos = pos,
		finger = {
			guide_type = "point", dir = dir
		}
	}
	self.fingerGuideNode:reset(fingerInfo)
end

function GuideLayer:setTouchCallback(cb)
	self.touchCallback = cb
end

function GuideLayer:setClickCallback(cb)
	self.ClickCallback = cb
end

function GuideLayer:onInitView(widget)
	local colorBg = cc.LayerColor:create(cc.c4b(0,0,0,0), display.width, display.height)
	colorBg:setPosition(cc.p(0,0))
	self.colorBg = colorBg

    local clipnode = cc.ClippingNode:create()
    clipnode:setAnchorPoint(cc.p(0,0))
    clipnode:setContentSize(cc.p(display.width,display.height))
    clipnode:setPosition(cc.p(0,0)) --display.width/2,display.height/2))
    clipnode:setInverted(true) --true顯示裁剪剩餘部分,false選擇裁剪的部分
    clipnode:setAlphaThreshold(0.5)
	clipnode:addChild(self.colorBg)
    self:addChild(clipnode)
	self.clipnode = clipnode

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch, event)
		if self.delaying then
			return true
		end

		if self.touchCallback then
			self.touchCallback()
			return true
		end
		
		local location = touch:getLocation()
		if not cc.rectContainsPoint(self.touchRect, location) then
			return true
		end

		if self.ClickCallback then
			self.ClickCallback()
		end
		return false
		--[[
		if location.x>=self.boundingBox.x and location.x<= self.boundingBox.x+self.boundingBox.width
			and location.y>=self.boundingBox.y and location.y<= self.boundingBox.y+self.boundingBox.height
		then
			if self.ClickCallback then
				self.ClickCallback()
			end
			return false
		else
			return true
		end
		]]
	end,cc.Handler.EVENT_TOUCH_BEGAN )
	
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

	self.fingerGuideNode = require("cp.view.scene.newguide.FingerGuideNode"):create()
    self:addChild(self.fingerGuideNode,1)
	self.fingerGuideNode:setPosition(cc.p(0,0))
	
	self:setStencil(widget)
end

function GuideLayer:onEnterScene()
end

return GuideLayer