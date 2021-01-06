local BNode = require "cp.view.ui.base.BNode"
local FingerGuideNode = class("FingerGuideNode",BNode)

function FingerGuideNode:create()
    local node = FingerGuideNode.new()
    return node
end

-- function FingerGuideNode:initListEvent()
    -- self.listListeners = {}
-- end

-- open_info參數說明 
-- guide_type (press:點擊動畫,point:靜態手指)
-- dir (left:手指指向左邊,right:手指指向右邊,top:手指指向上邊,bottom:手指指向下邊)

-- 示例1：open_info = {text = {content = "請點擊", pos = cc.p(50,6)}, finger = {guide_type = "press" ,pos = cc.p(50,6)},circle ={pos = cc.p(50,6)}}
-- 示例2：open_info = {text = {content = "狀態欄可以查看精靈的狀態訊息", pos = cc.p(50,6)}, finger = {guide_type = "point" ,pos = cc.p(50,6),dir = "left"}}
function FingerGuideNode:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_finger_guide.csb")
	self:addChild(self.rootView)
	local childConfig = {
		["Node_text"] = {name = "Node_text"},
		["Image_finger_point"] = {name = "Image_finger_point"},
		["Node_press"] = {name = "Node_press"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self.Node_press:setVisible(false)
	self.Image_finger_point:setVisible(false)
	self.Node_text:setVisible(false)
	self:createPressAnim()
	self.needChangeAnim = false
end


function FingerGuideNode:setFingerPointDir(dir)
	
	if self.Image_finger_point ~= nil and dir ~= nil then
		if dir == "left" then
			self.Image_finger_point:setFlippedX(true)
		elseif dir == "right" then
			--不變
		elseif dir == "top" then
			self.Image_finger_point:setRotation(270)
		elseif dir == "bottom" then
			self.Image_finger_point:setRotation(270)
			self.Image_finger_point:setFlippedX(true)
		end
	end
	
end

function FingerGuideNode:onEnterScene()
    
end

function FingerGuideNode:createPressAnim()
    
	-- local armature = cp.getManager("ViewManager").createArmature("spine/guangbiao/guangbiao.csb")
    -- if not armature then 
	-- 	return
	-- end

    -- self.Node_press:addChild(armature)
    -- armature:setAnchorPoint(cc.p(0.5, 0.5))
	-- --armature:getAnimation():playWithIndex(0)
	-- armature:setPosition(cc.p(-20,0))
	-- self.armature = armature

	-- local frames = display.newFrames("ui_player_guide_%d.png",1,8)
	-- local animation = display.newAnimation(frames,1/8)     --2 秒播放 8 楨
	-- local animate = cc.Animate:create(animation)
    -- local action = cc.RepeatForever:create(animate)
	-- self.Sprite_1:runAction(action)

	self:stopAllActions()
	display.loadSpriteFrames("uiplist/ui_player_guide.plist")
    self.Image_1 = ccui.ImageView:create()
    self.Image_1:setAnchorPoint(0.5,0.5)
    self.Image_1:loadTexture("ui_player_guide_1.png",ccui.TextureResType.plistType)
    self.Image_1:setPosition(0,0)
	self.Node_press:addChild(self.Image_1)
	self.image_index = 1
	
	local action = cc.RepeatForever:create(cc.Sequence:create( 
		cc.CallFunc:create(function()
			display.loadSpriteFrames("uiplist/ui_player_guide.plist")
			self.image_index = self.image_index + 1
			self.image_index = self.image_index > 8 and 1 or self.image_index
			self.Image_1:loadTexture(string.format("ui_player_guide_%d.png",self.image_index),ccui.TextureResType.plistType)
		 end),
		 cc.DelayTime:create(0.1)))
	self.Image_1:runAction(action)
	

	self.Image_finger_point:setPosition(cc.p(80,-90))
	local move = cc.MoveTo:create(1, cc.p(55,-70))
	-- local func = cc.CallFunc:create(function()
	-- 	self.Image_finger_point:setPosition(cc.p(80,-90))
	-- end)
	local move2 = cc.MoveTo:create(0.5, cc.p(80,-90))
	local delay1 = cc.DelayTime:create(0.3)
	local delay2 = cc.DelayTime:create(0.5)
	local action2 = cc.RepeatForever:create(cc.Sequence:create(move,delay1,move2,delay2))
	self.Image_finger_point:runAction(action2)

end

function FingerGuideNode:createMoveAnim(beginPos,endPos)
	--self.Node_press:setVisible(false)
	self:stopAllActions()
	self.Image_1:stopAllActions()
	self.Image_finger_point:stopAllActions()
	self.Image_finger_point:setPosition(cc.p(55,-70))
	self:setPosition(beginPos)
	local move = cc.MoveTo:create(2, endPos)
	local move2 = cc.MoveTo:create(0.5, beginPos)
	local delay1 = cc.DelayTime:create(0.2)
	local delay2 = cc.DelayTime:create(0.5)
	local action2 = cc.RepeatForever:create(cc.Sequence:create(move,delay1,move2,delay2))
	self:runAction(action2)

	self.needChangeAnim = true
end

function FingerGuideNode:onExitScene()
end


function FingerGuideNode:init(open_info)
	self.open_info = open_info
	
	--文字
	-- self.Node_text:setVisible(self.open_info.text ~= nil)
	-- if self.open_info.text ~= nil and self.open_info.text.content ~= nil then
		
	-- 	local textTiper = require("cp.view.scene.newguide.NewGuideTiper"):create()
	-- 	textTiper:setName("textTiper")
	-- 	self.Node_text:addChild(textTiper)
		
	-- 	textTiper:setText(self.open_info.text.content)
	-- 	textTiper:setPosition(self.open_info.text.pos)

	-- end
	
	--手指
	if self.open_info.finger ~= nil then
		self.Node_press:setVisible(false)
		if self.open_info.pos ~= nil then
			self:setPosition(self.open_info.pos)
		end
		if self.open_info.finger.guide_type == "point" then
			self.Image_finger_point:setVisible(true)
			self:setFingerPointDir(self.open_info.finger.dir)
			self.Node_press:setVisible(true)
			if self.needChangeAnim then
				self:createPressAnim()
				self.needChangeAnim = false
			end
		elseif self.open_info.finger.guide_type == "move" then
			self.Image_finger_point:setVisible(true)
			self:createMoveAnim(self.open_info.pos, self.open_info.finger.moveto)
		end
		
		
	end
	
end

function FingerGuideNode:reset(open_info)
	
	-- if self.Node_text ~= nil and self.Node_text:getChildByName("textTiper") ~= nil then
	-- 	self.Node_text:removeChildByName("textTiper")
	-- end
	
	self.Node_press:setVisible(false)
	self.Image_finger_point:setVisible(false)
	self.Node_text:setVisible(false)
	
	self:init(open_info)
end

return FingerGuideNode