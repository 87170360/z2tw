local FightTip = class("FightTip",function() return cc.Node:create() end)
function FightTip:create()
    local ret = FightTip.new()
    ret:init()
    return ret
end

function FightTip:init()
    display.loadSpriteFrames("uiplist/ui_common.plist")
    self.img_bg = ccui.ImageView:create()
    self.img_bg:setAnchorPoint(0.5,0.5)
    self.img_bg:loadTexture("ui_common_fight_change_bg.png",ccui.TextureResType.plistType)
    self.img_bg:setPosition(0,0)
    self:addChild(self.img_bg)

    self.base_text = ccui.TextAtlas:create()
	self.base_text:setProperty("1234567890", "img/number/fight_change_num1.png", 39, 45, "0")
	self.base_text:setString("")
	self.base_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.base_text:setPosition(cc.p(330, self.img_bg:getContentSize().height/2))
    self.img_bg:addChild(self.base_text)

    self.change_text = ccui.TextAtlas:create()
	self.change_text:setProperty("1234567890", "img/number/fight_change_num3.png", 39, 45, "0")
	self.change_text:setString("")
	self.change_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.change_text:setPosition(cc.p(460, self.img_bg:getContentSize().height/2 + 60))
    self.img_bg:addChild(self.change_text)

    self.img_sign = ccui.ImageView:create()
    self.img_sign:setAnchorPoint(0.5,0.5)
    self.img_sign:loadTexture("ui_common_fight_change_plus.png",ccui.TextureResType.plistType)
    self.img_sign:setPosition(cc.p(-self.img_sign:getContentSize().width/2, 22.5))
    self.change_text:addChild(self.img_sign)

	self.change_text:setVisible(false)

end

function FightTip:setText(oldFight, newFight)
	local changeFight = newFight - oldFight

    self.base_text:setString(oldFight)
	
	if changeFight > 0 then
		self.change_text:setProperty("1234567890", "img/number/fight_change_num3.png", 39, 45, "0")
    	self.img_sign:loadTexture("ui_common_fight_change_plus.png",ccui.TextureResType.plistType)
	else
		self.change_text:setProperty("1234567890", "img/number/fight_change_num2.png", 39, 45, "0")
    	self.img_sign:loadTexture("ui_common_fight_change_minus.png",ccui.TextureResType.plistType)
	end
	self.change_text:setString(math.abs(changeFight))
end

function FightTip:setNewFight(newFight)
	self.base_text:setString(newFight)
end

function FightTip:showChange()
	self.change_text:setVisible(true)
end

function FightTip:getTiperSize()
    return self.img_bg:getContentSize()
end

function FightTip:getDescription()
    return "FightTip"
end

return FightTip
