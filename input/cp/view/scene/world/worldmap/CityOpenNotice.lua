
local CityOpenNotice = class("CityOpenNotice",function() return cc.Node:create() end)


function CityOpenNotice:create(cityName)
    local ret = CityOpenNotice.new()
    ret:init(cityName)
    return ret
end

function CityOpenNotice:init(cityName)
	
    self:setPosition(cc.p(display.cx,display.cy))

    display.loadSpriteFrames("uiplist/ui_mapbuild.plist")   

    self.image_bg = ccui.ImageView:create()
	self.image_bg:loadTexture("img/bg/bg_mapbuild/module6_jianghushi_jiesuo_v.png")
    self.image_bg:setAnchorPoint(cc.p(0.5,0.5))
    self.image_bg:setPosition(cc.p(0,0))
	self:addChild(self.image_bg,1)

    self.image_bg_1 = ccui.ImageView:create()
	self.image_bg_1:loadTexture("img/bg/bg_mapbuild/module6_jianghushi_jiesuo_a.png")
    self.image_bg_1:setAnchorPoint(cc.p(0.5,0.5))
    self.image_bg_1:setPosition(cc.p(0,0))
	self:addChild(self.image_bg_1,0)

    self.text_1 = ccui.Text:create()
    self.text_1:setString("恭喜解鎖")
    self.text_1:setFontName("fonts/msyh.ttf")
    self.text_1:setFontSize(20)
    self.text_1:setTextColor(cc.c3b(203, 203, 203))
    self.text_1:setAnchorPoint(cc.p(0.5,0.5))
    self.text_1:setPosition(cc.p(0,30))
    self:addChild(self.text_1,2)

    self.text_name = ccui.Text:create()
    self.text_name:setString(cityName)
    self.text_name:setFontName("fonts/msyh.ttf")
    self.text_name:setFontSize(50)
    self.text_name:setTextColor(cc.c3b(255, 253, 214))
    self.text_name:setAnchorPoint(cc.p(0.5,0.5))
    self.text_name:setPosition(cc.p(0,-20))
    self:addChild(self.text_name,2)


    --觸摸層
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5,0.5)
    layout:setPosition(cc.p(0,0))
    layout:setContentSize(cc.size(720,1600))
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)--solid)
    layout:setBackGroundColor(cc.c3b(0,0,0))
    layout:setBackGroundColorOpacity(160)
    layout:setTouchEnabled(true)
    self:addChild(layout,-1)
    layout:onTouch(handler(self, self.onBgClick))

    -- self.image_bg_1:runAction(cc.RepeatForever:create(
    --     cc.RotateBy:create(10,360)))
        
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(
        function ()
            if self.clickCallBack then
                self.clickCallBack()
            end
        end
    )))
end

function CityOpenNotice:onEnterScene()
	
end


function CityOpenNotice:onExitScene()

end

function CityOpenNotice:onBgClick(event)
    if event.name == "ended" then
        if self.clickCallBack then
            self.clickCallBack()
        end
    end
end

function CityOpenNotice:setClickCallBack(cb)
    self.clickCallBack = cb
end

return CityOpenNotice