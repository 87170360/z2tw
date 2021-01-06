local GameTiper = class("GameTiper",function() return cc.Node:create() end)
function GameTiper:create()
    local ret = GameTiper.new()
    ret:init()
    return ret
end

function GameTiper:init()
    display.loadSpriteFrames("uiplist/ui_common.plist")
    self.img_bg = ccui.ImageView:create()
    self.img_bg:setAnchorPoint(0.5,0.5)
    --self.img_bg:setCapInsets({x = 15, y = 15, width = 20, height = 4})
    --self.img_bg:setScale9Enabled(true)
    self.img_bg:loadTexture("ui_common_tips_bg1.png",ccui.TextureResType.plistType)
    self.img_bg:setPosition(0,0)
    self:addChild(self.img_bg)
    self.txt = ccui.Text:create()
	self.txt:setFontName("fonts/msyh.ttf" ) 
	self.txt:setText("")
	self.txt:setAnchorPoint(cc.p(0.5, 0.5))
	self.txt:setTextColor(cc.c3b(199, 223, 255))
	self.txt:setFontSize(27)
	--self.txt:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self.txt:setPosition(cc.p(360, self.img_bg:getContentSize().height/2+2))
    self.img_bg:addChild(self.txt)
end

function GameTiper:setText(text)
    self.txt:setString(text)
end

function GameTiper:getTiperSize()
    return self.img_bg:getContentSize()
end

function GameTiper:getDescription()
    return "GameTiper"
end

return GameTiper