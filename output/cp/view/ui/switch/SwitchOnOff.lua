
local SwitchOnOff = class("SwitchOnOff",function() return ccui.Layout:create() end)

function SwitchOnOff:create(id,state)
    local ret = SwitchOnOff.new()
    ret:init(id,state)
    return ret
end

function SwitchOnOff:init(id,state)
    display.loadSpriteFrames("uiplist/ui_player_system.plist")

    self:setContentSize(cc.size(80,24))
	self:setAnchorPoint(cc.p(0,0))

    self.bg = ccui.ImageView:create()
    self.bg:setAnchorPoint(cc.p(0.5,0.5))
    self.bg:loadTexture("ui_player_system_setting_2.png", ccui.TextureResType.plistType)
	self:addChild(self.bg)
	
	self.onoff = ccui.ImageView:create()
    self.onoff:setAnchorPoint(cc.p(0.5,0.5))
    self.onoff:loadTexture("ui_player_system_setting_5.png", ccui.TextureResType.plistType)
	self.bg:addChild(self.onoff)
	
	self.onoffText = ccui.Text:create()
    self.onoffText:setAnchorPoint(cc.p(0.5,0.5))
	self.onoffText:setPosition(cc.p(33,12))
	self.bg:addChild(self.onoffText)
	
	self:changEnabled(true)
	cp.getManager("ViewManager").initButton(self.bg,handler(self,self.onOffChangClicked),1)
	
	self.id = id  -- id標識
	self.state = state == nil and 0 or state -- 0:off,1:on
    self.onoff:setPosition(cc.p( self.state == 0 and 5.35 or 62,11))  --左邊，關閉
    self.onoffText:setString(self.state == 0 and "OFF" or "ON")
end

function SwitchOnOff:On()
	self.onoffText:setString("ON")
	self.onoff:setPosition(cc.p(62,11))
	self.state = 1
end

function SwitchOnOff:Off()
	self.onoffText:setString("OFF")
	self.onoff:setPosition(cc.p(5.35,11))
	self.state = 0
end

function SwitchOnOff:onOffChangClicked(sender)
	if self.state == 0 then
		self:On()
	elseif self.state == 1 then
		self:Off()
	end
	if self.stateChangeCallback ~= nil then
		self.stateChangeCallback(self)
	end
end


function SwitchOnOff:changEnabled(enabled)
	self.bg:setTouchEnabled(enabled)
end

--獲取當前狀態
function SwitchOnOff:getState()
	return self.state
end

--獲取id標識
function SwitchOnOff:getid()
	return self.id
end

function SwitchOnOff:setStateChangeCallback(callback)
	self.stateChangeCallback = callback
end

return SwitchOnOff