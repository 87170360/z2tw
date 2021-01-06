
local BNode = require "cp.view.ui.base.BNode"
local NewGuideLayer = class("NewGuideLayer",BNode)

function NewGuideLayer:create(open_info)
    local node = NewGuideLayer.new(open_info)
    return node
end


function NewGuideLayer:initListEvent()
    self.listListeners = {

		[cp.getConst("EventConst").OnNewGuideDouCheng] = function(evt)
            if evt.idx > 1 then
				self:popTalk(evt.idx,nil,110)
            end
        end,
	}
end


function NewGuideLayer:onInitView(open_info)
	self.open_info = open_info
	open_info.stencil_mode = open_info.stencil_mode or "image"
    self.needCallBackWhileTouchOut = false
	
	self.isMove = false
	self.touchBeginPos = nil
	local function onTouchBegan(touch, event)
		local isSwallow = self.touchListener:isSwallowTouches()
		if isSwallow == true then --吞噬(伏擊)下層界面的事件，需判斷是否在指定區域內
			local location = touch:getLocation()
			local mouseX , mouseY = location.x , location.y
			--log("onTouchBegan x="..mouseX.. ",y="..mouseY)
			self.touchBeginPos = location
			self.isMove = false

			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")  --推動武學的步驟
			if (cur_guide_module_name == "wuxue" and (cur_step == 19 or cur_step == 20)) or
				(cur_guide_module_name == "wuxue_use" and (cur_step >= 4 and cur_step <= 7)) or
				(cur_guide_module_name == "wuxue_pos_change" and (cur_step >= 4 and cur_step <= 5)) then
				--判斷是否在裁剪範圍
				local layer1 = self.sprite_stencil:getChildByName("layer1")
				local boundbingBox = layer1:getBoundingBox()
				if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
					and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
				then
					return false --向下傳遞
				end
			end

			if (cur_guide_module_name == "lottery" and (cur_step == 27 or cur_step == 28)) then
				
				--判斷是否在裁剪範圍
				local layer1 = self.sprite_stencil:getChildByName("layer1")
				local boundbingBox = layer1:getBoundingBox()
				if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
					and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
				then
					return false --向下傳遞
				end
			end

			local boundbingBox = self.sprite_stencil:getBoundingBox()
			local cityPosition = self.sprite_stencil:convertToWorldSpace(cc.p(boundbingBox.x,boundbingBox.y))
			--log("cityPosition x="..cityPosition.x.. ",y="..cityPosition.y)
			if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
				and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
			then
				
				log("onTouchBegan touch in rect")

				return true --不向下傳遞
				
			end
		end
		return true
    end

    local function onTouchMoved(touch, event)
		log("onTouchMoved 111")
		self.isMove = true
    end

    local function onTouchEnded(touch, event)
		log("onTouchEnded 12112 ")
		local isSwallow = self.touchListener:isSwallowTouches()
		if isSwallow == true then --吞噬(伏擊)下層界面的事件，需判斷是否在指定區域內
			local location = touch:getLocation()
			local mouseX , mouseY = location.x , location.y
			
			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")  --推動武學的步驟
			if (cur_guide_module_name == "wuxue" and (cur_step == 19 or cur_step == 20)) or
				(cur_guide_module_name == "wuxue_use" and (cur_step >= 4 and cur_step <= 7)) or
				(cur_guide_module_name == "wuxue_pos_change" and (cur_step >= 4 and cur_step <= 5)) then
				
				--判斷是否在裁剪範圍
				local layer1 = self.sprite_stencil:getChildByName("layer1")
				local boundbingBox = layer1:getBoundingBox()
				if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
					and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
				then
					if self.touchCallBackFunc ~= nil then
						self.touchCallBackFunc()
					end
				end
			end

			local boundbingBox = self.sprite_stencil:getBoundingBox()
			local cityPosition = self.sprite_stencil:convertToWorldSpace(cc.p(boundbingBox.x,boundbingBox.y))
			if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
				and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
			then
				log("onTouchEnded in in in")
				if (self.touchBeginPos.x ~= mouseX and self.touchBeginPos.y ~= mouseY) or self.isMove then
					log("is Move...")
				end
				
				if self.touchCallBackFunc ~= nil then
					self.touchCallBackFunc()
				end
				
			else
				log("onTouchEnded out out out")

                log("onTouchEnded ,self.needCallBackWhileTouchOut=",self.needCallBackWhileTouchOut)
                if self.needCallBackWhileTouchOut == true then
                    if self.touchCallBackFunc ~= nil then
                       self.touchCallBackFunc()
                    end
				end
                if self.cancelGuideCallBack ~= nil then
                    self.cancelGuideCallBack()
                end
			end
		else
		
			log("onTouchEnded isSwallow is false.")

			local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
			if cur_guide_module_name == "wuxue" then
				local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step") --推動武學的步驟
				if cur_step == 19 then
					return
				end
			end

			if (cur_guide_module_name == "lottery" and (cur_step == 27 or cur_step == 28)) then
				
				--判斷是否在裁剪範圍
				local layer1 = self.sprite_stencil:getChildByName("layer1")
				local boundbingBox = layer1:getBoundingBox()
				if mouseX>=boundbingBox.x and mouseX<= boundbingBox.x+boundbingBox.width
					and mouseY>=boundbingBox.y and mouseY<= boundbingBox.y+boundbingBox.height
				then
					if self.touchCallBackFunc ~= nil then
						self.touchCallBackFunc()
					end
				end
			end

            log("onTouchEnded ,self.needCallBackWhileTouchOut=",self.needCallBackWhileTouchOut)
            if self.needCallBackWhileTouchOut == true then
                if self.touchCallBackFunc ~= nil then
                    self.touchCallBackFunc()
                end
            end
            if self.cancelGuideCallBack ~= nil then
                self.cancelGuideCallBack()
            end
		end
    end

	local function onTouchCancelled(touch, event)
		log("onTouchCancelled 12112 ")
		if self.cancelGuideCallBack ~= nil then
		    self.cancelGuideCallBack()
		end 
	end
	
    local listener = cc.EventListenerTouchOneByOne:create()
	local isSwallow = true
	if self.open_info ~= nil and self.open_info.isSwallow ~= nil then
		isSwallow = self.open_info.isSwallow
	end
    listener:setSwallowTouches(isSwallow)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
	
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    self.touchListener = listener
	
    local colorBg = cc.LayerColor:create(cc.c4b(0,0,0,0), display.width, display.height)
    colorBg:setPosition(cc.p(0,0))
	colorBg:setTouchEnabled(true)
	self.colorBg = colorBg
    
	
	local stencil_mode = ""
    if self.open_info.stencil_mode == nil then
        self.open_info.stencil_mode = stencil_mode
	end
    
    if self.open_info.stencil_mode ~= "image" then
	
		local color_stencil = cc.LayerColor:create(cc.c4b(0,0,0,0), 120, 120)
		color_stencil:setAnchorPoint(cc.p(0.5,0.5))
        color_stencil:setPosition(cc.p(-200,display.height/2-60)) --display.width/2-60
		self.sprite_stencil = color_stencil
		
	else	
		display.loadSpriteFrames("uiplist/ui_player_guide.plist")
		local sprite_stencil = cc.Sprite:create()
		sprite_stencil:setSpriteFrame("ui_player_guide_a.png")
		sprite_stencil:setAnchorPoint(cc.p(0.5,0.5))
		sprite_stencil:setPosition(cc.p(-200,display.height/2))
		self.sprite_stencil = sprite_stencil
		
	end

    local clipnode = cc.ClippingNode:create()
    clipnode:setAnchorPoint(cc.p(0,0))
    clipnode:setContentSize(cc.p(display.width,display.height))
    clipnode:setPosition(cc.p(0,0)) --display.width/2,display.height/2))
    clipnode:setInverted(true) --true顯示裁剪剩餘部分,false選擇裁剪的部分
    clipnode:setAlphaThreshold(0.5)
    clipnode:setStencil(self.sprite_stencil) --設置裁剪模板
    clipnode:addChild(self.colorBg)
    self:addChild(clipnode)
    self.clipnode = clipnode
    
	self.fingerGuideNode = require("cp.view.scene.newguide.FingerGuideNode"):create()
    self:addChild(self.fingerGuideNode,1)
    self.fingerGuideNode:setPosition(cc.p(0,0))
	
	self.gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create()
	local function closeCallBack()
		self.gamePopTalk:setVisible(false)
	
        if self.touchCallBackFunc ~= nil then
            self.touchCallBackFunc()
        end
	end
	self.gamePopTalk:setFinishedCallBack(closeCallBack)
	self.gamePopTalk:setName("gamePopTalk")
    self:addChild(self.gamePopTalk,2)
	self.gamePopTalk:setPosition(cc.p(display.width/2,0))
	self.gamePopTalk:resetBgOpacity(0)
	self.gamePopTalk:hideSkip()
	
	
	local status, gameStory = xpcall(function()
			return require("cp.story.GameStoryPlayerGuider")
		end, function(msg)
		--if not string.find(msg, string.format("'%s' not found:", packageName)) then
			print("load stroy error: ", msg)
		--end
	end)
	self.guidPopTalkTextList = gameStory

end

function NewGuideLayer:onEnterScene()
	self.fingerGuideNode:setVisible(false)
	self.gamePopTalk:setVisible(false)
	
end

function NewGuideLayer:resetGuideInfo(open_info)
	self.open_info = open_info
end

function NewGuideLayer:popTalk(textIndex,endIndex,opacity)
	local contentTable = {}
	if endIndex == nil then
		table.insert(contentTable,self.guidPopTalkTextList[textIndex]) 
	else
		for i=textIndex,endIndex,1 do
			table.insert(contentTable,self.guidPopTalkTextList[i]) 
		end
	end
	self.gamePopTalk:resetTalkText(contentTable)
	self.gamePopTalk:setVisible(true)
	self.gamePopTalk:resetBgOpacity(opacity or 120)
end

function NewGuideLayer:fingerGuide(finger_info)
	if finger_info ~= nil then
		self.fingerGuideNode:reset(finger_info)
		self.fingerGuideNode:setVisible(true)
		
		if finger_info.pos ~= nil then
		    self.sprite_stencil:setVisible(true)
            if finger_info.finger.guide_type == "move" then
				self.finger_info = finger_info
				self:changeStencil("block")
				
            else
				self.finger_info = nil
				self:changeStencil("image")
				self.sprite_stencil:setPosition(finger_info.pos)
				
            end
		end
	end
end

function NewGuideLayer:resetGuideTypeToPoint()
	self:changeStencil("image")
end

function NewGuideLayer:setSwallowTouches(isSwallow)
    self.touchListener:setSwallowTouches(isSwallow)
end

function NewGuideLayer:reset()
	self:setSwallowTouches(false)
	self.fingerGuideNode:setVisible(false)
    self.sprite_stencil:setVisible(false)
	self.gamePopTalk:setVisible(false)
	self.needCallBackWhileTouchOut = false
end


function NewGuideLayer:setTouchCallBack(touchCallBackFunc)
	self.touchCallBackFunc = touchCallBackFunc
end

function NewGuideLayer:resetBgColor(r,g,b,a)
	self.colorBg:initWithColor(cc.c4b(r,g,b,a))
end


function NewGuideLayer:resetStencilSize(width,height)
	-- self.sprite_stencil:setContentSize(cc.size(width,height))
end

function NewGuideLayer:changeStencil(stencil_mode,rect)
	if self.open_info.stencil_mode ~= stencil_mode then

		self.colorBg:removeFromParent()
		self.clipnode:removeFromParent()
		self.colorBg = nil
		self.clipnode = nil

		self.open_info.stencil_mode = stencil_mode

		local opacity = (stencil_mode == "block" and self.open_info.guide_name == "wuxue_pos_change") and 128 or 0
		local colorBg = cc.LayerColor:create(cc.c4b(0,0,0,opacity), display.width, display.height)
		colorBg:setPosition(cc.p(0,0))
		colorBg:setTouchEnabled(true)
		self.colorBg = colorBg

		if stencil_mode == "whole_block" then
			local layer1 = cc.LayerColor:create(cc.c4b(0,0,255,255), rect.width, rect.height)
			layer1:setName("layer1")
			layer1:setPosition(cc.p(rect.top,rect.bottom))
			local stencil = cc.Node:create() 
			stencil:addChild(layer1)
			self.sprite_stencil = stencil
		elseif stencil_mode == "block" then
			if self.open_info.guide_name == "wuxue_pos_change" then
				if rect == nil then
					rect = self.finger_info.rect
				end
				local layer1 = cc.LayerColor:create(cc.c4b(0,0,255,255), rect.width, rect.height)
				layer1:setName("layer1")
				layer1:setPosition(cc.p(rect.top,rect.bottom))
				local stencil = cc.Node:create() 
				stencil:addChild(layer1)
				self.sprite_stencil = stencil
			else
				local markWidth1 =  (self.open_info.guide_name == "wuxue_use") and 540 or 250
				local markWidth2 =  (self.open_info.guide_name == "wuxue_use") and 460 or 250
				local height1 = (self.open_info.guide_name == "wuxue_use") and 300 or 140
				local pos_delta1 = (self.open_info.guide_name == "wuxue_use") and 220 or 70
				local layer1 = cc.LayerColor:create(cc.c4b(0,0,0,0), markWidth1, height1)
				layer1:setName("layer1")
				layer1:setPosition(cc.p(self.finger_info.pos.x - 50,self.finger_info.pos.y-pos_delta1))
				local layer2 = cc.LayerColor:create(cc.c4b(0,0,0,0), markWidth2, 120)
				layer2:setPosition(cc.p(self.finger_info.finger.moveto.x - 50,self.finger_info.finger.moveto.y-60))--self.finger_info.finger.moveto)
				layer2:setName("layer2")
				local stencil = cc.Node:create() 
				stencil:addChild(layer1)
				stencil:addChild(layer2)
				self.sprite_stencil = stencil
			end
					
		elseif stencil_mode == "image" then	
			display.loadSpriteFrames("uiplist/ui_player_guide.plist")
			local sprite_stencil = cc.Sprite:create()
			sprite_stencil:setSpriteFrame("ui_player_guide_a.png")
			sprite_stencil:setAnchorPoint(cc.p(0.5,0.5))
			self.sprite_stencil = sprite_stencil
		
		end
		
		local clipnode = cc.ClippingNode:create()
		clipnode:setAnchorPoint(cc.p(0,0))
		clipnode:setContentSize(cc.p(display.width,display.height))
		clipnode:setPosition(cc.p(0,0)) --display.width/2,display.height/2))
		clipnode:setInverted(false) --true顯示裁剪剩餘部分,false選擇裁剪的部分
		if stencil_mode == "whole_block" or (self.open_info.guide_name == "wuxue_pos_change" and stencil_mode == "block")  then
			clipnode:setInverted(true) 
		end
		clipnode:setAlphaThreshold(0.5)
		clipnode:setStencil(self.sprite_stencil) --設置裁剪模板
		clipnode:addChild(self.colorBg)
		self:addChild(clipnode)
		self.clipnode = clipnode

	end
	if (self.open_info.guide_name == "wuxue" and stencil_mode == "block") then

	end

end

function NewGuideLayer:setNeedCallBackWhileTouchOut(needCallBackTouchOut)
    self.needCallBackWhileTouchOut = needCallBackTouchOut
end

function NewGuideLayer:setCancelGuideCallBack(cancelCallBack)
    self.cancelGuideCallBack = cancelCallBack
end

function NewGuideLayer:resetInverted(state)
	if self.clipnode then
		self.clipnode:setInverted(state)
	end
end

return NewGuideLayer