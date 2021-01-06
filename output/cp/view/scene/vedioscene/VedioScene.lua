local BScene = require "cp.view.ui.base.BScene"
local VedioScene = class("VedioScene",BScene)

function VedioScene:create()
    local scene = VedioScene.new()
	
	return scene
end


function VedioScene:initListEvent()
    self.listListeners = { }
end

function VedioScene:onEnterScene()
    local cid = "cj0001"
    cp.getManager("GDataManager"):sendChangjingRecord(cid)
end

function VedioScene:onInitView()
    self:init()
end

function VedioScene:init()
    local layer = ccui.Layout:create()
	layer:setContentSize(display.size)

    self:addChild(layer)
	
	
	log("VedioScene:init 11111")
	local function callback(sender)
		self.videoPlayer:setVisible(true)
		self.videoPlayer:resume()
    end
	local function callback2(sender)
		self.videoPlayer:setVisible(true)
		self.videoPlayer:play()
    end

    local act1 = cc.DelayTime:create(0.5)
    local act2 = cc.CallFunc:create(callback)
	local act3 = cc.CallFunc:create(callback2)
    local actseq = cc.Sequence:create(act1,act2)
    local actseq2 = cc.Sequence:create(act1,act3)
    	
	self.count = 0
	local function onTouch(sender, event)
		if event == cc.EventCode.ENDED  then
			log("VedioScene:onTouch")
			
			if self.count < 10 then
				self.videoPlayer:setFullScreenEnabled(not self.videoPlayer:isFullScreenEnabled())
			elseif self.count < 20 then
				self.videoPlayer:setKeepAspectRatioEnabled(not self.videoPlayer:isKeepAspectRatioEnabled())
			
			elseif self.count < 30 then
				if self.videoPlayer:isPlaying() then
					self.videoPlayer:pause()
					self.videoPlayer:setVisible(false)
					self.videoPlayer:runAction(actseq)
				end
			elseif self.count < 40 then
				if self.videoPlayer:isPlaying() then
					self.videoPlayer:stop()
					self.videoPlayer:setVisible(false)
					self.videoPlayer:runAction(actseq2)
				end
			elseif self.count == 50 then
				self.count = 0
			end
			
			self.count = self.count + 1
			log("VedioScene:init self.count = " .. tostring(self.count))

		end
	end
	layer:setTouchEnabled(true)
	layer:addTouchEventListener(onTouch)
	
	local videoPlayer = ccexp.VideoPlayer:create()
	self.isCOMPLETED = 0
    local function onVideoEventCallback(sener, eventType)
        if eventType == ccexp.VideoPlayerEvent.PLAYING then
            log("PLAYING")
        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            log("PAUSED")
            self:changeScene()
        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            log("STOPPED")
        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            log("COMPLETED")
			self.isCOMPLETED = self.isCOMPLETED + 1 
			if self.isCOMPLETED == 2 then			
				--self:changeScene()
				log("VedioScene:init 33333")
			end
			self:changeScene()
        end
    end
        
    videoPlayer:setPosition(display.center)
    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
    videoPlayer:setPosition(cc.p(display.width / 2, display.height / 2))
    videoPlayer:setContentSize(cc.size(display.width,display.height))
    videoPlayer:addEventListener(onVideoEventCallback)
    layer:addChild(videoPlayer)
	videoPlayer:setFullScreenEnabled(true)
	videoPlayer:setVisible(true)
	
	-- local keepAspect = videoPlayer:isKeepAspectRatioEnabled()
	videoPlayer:setKeepAspectRatioEnabled(true)
	
	local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename("video/start.mp4")
	videoPlayer:setFileName(videoFullPath)   
	videoPlayer:play()
	self.videoPlayer = videoPlayer
	-- videoPlayer:setURL("http://benchmark.cocos2d-x.org/cocosvideo.mp4")
	-- videoPlayer:play()
	
	--cp.getManager("ViewManager").addModalByDefaultImage(layer,"img/bg/bg_newguide/bg_newguide_1.jpg")
	
	log("VedioScene:init 2222")

	return layer
end

function VedioScene:changeScene()
	cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_HOTUP)
end

return VedioScene