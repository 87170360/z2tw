local BScene = require "cp.view.ui.base.BScene"
local SplashScene = class("SplashScene",BScene)

function SplashScene:create()
    	local scene = SplashScene.new()
	return scene
end

function SplashScene:onInitView()
	self:init()
end

function SplashScene:init()

	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0,0)
	layout:setPosition(0,0)
	layout:setContentSize(display.size)
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	layout:setBackGroundColor(cc.c3b(255, 255, 255))
	layout:setBackGroundColorOpacity(255)
	layout:setTouchEnabled(true)
	self:addChild(layout)

	local path = "img/bg/bg_login/jkyxzg.png"
	local image = ccui.ImageView:create()
	image:loadTexture(path,ccui.TextureResType.localType)
	image:ignoreContentAdaptWithSize(false)
	image:setCascadeOpacityEnabled(true)
	layout:addChild(image)
	image:setPosition(cc.p(display.cx,display.cy+150))

	--Create Text_3
	local Text_3 = ccui.Text:create()
	Text_3:ignoreContentAdaptWithSize(true)
	Text_3:setTextAreaSize({width = 0, height = 0})
	Text_3:setFontName("fonts/msyh.ttf")
	Text_3:setFontSize(20)
	Text_3:setString([[著作權人：深圳市九魔網路發展有限公司
出版單位：
批准文號：
出版物號：
備案文號：]])
	Text_3:setName("Text_3")
	Text_3:setCascadeColorEnabled(true)
	Text_3:setCascadeOpacityEnabled(true)
	Text_3:setAnchorPoint(cc.p(0.5,0))
	Text_3:setPosition(360.0000, 10)
	Text_3:setTextColor({r = 0, g = 0, b = 0})
	layout:addChild(Text_3)

	local seq1 =  cc.Sequence:create(
		cc.FadeIn:create(2),	
		cc.DelayTime:create(1), 
		cc.FadeOut:create(3)
	)
	image:runAction(seq1)
	
	local seq =  cc.Sequence:create(
		cc.FadeIn:create(1),	
		cc.DelayTime:create(3), 
		cc.FadeOut:create(1.5), 
		cc.CallFunc:create(handler(self,self.changeScene))
	)

	local channelName = cp.getManualConfig("Channel").channel
	if device.platform == "windows" and channelName == "test" then
		seq =  cc.Sequence:create(
			cc.DelayTime:create(0.1), 
			cc.CallFunc:create(handler(self,self.changeScene))
		)
	else
		layout:setOpacity(0)
		image:setOpacity(0)
	end
	layout:runAction(seq)
end

function SplashScene:changeScene()
	if device.platform == "ios" or device.platform == "android" then
		cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_HOTUP)
	else
		-- window mac 直接登錄
		cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_LOGIN)
	end

end

return SplashScene