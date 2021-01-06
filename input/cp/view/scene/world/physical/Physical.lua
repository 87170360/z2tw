
local BLayer = require "cp.view.ui.base.BLayer"
local Physical = class("Physical",BLayer)

function Physical:create(openInfo)
	local layer = Physical.new(openInfo)
	return layer
end

function Physical:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").GetPhysicalRsp] = function(data)	
			dump(data)
			cp.getManager("ViewManager").showGetRewardUI({{id=1097, num=data.physical}}, "恭喜獲得", true, function()
				self.Image_baozi:setVisible(false)
			end)
        end,
	}
end

function Physical:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_physical/uicsb_physical.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},
        ["Panel_root.Panel_1.Panel_2.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_tmp_bg"] = {name = "Image_tmp_bg"},
        ["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_baozi"] = {name = "Image_baozi"},
        ["Panel_root.Panel_1.Panel_2.Panel_2_crop.Button_eat"] = {name = "Button_eat", click = "onButtonClick"},
        ["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_time"] = {name = "Image_time"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self:setPosition(display.cx,display.cy)
	self.Panel_root:setContentSize(display.size)

	local bx, by = self.Image_baozi:getPosition()
	if display.size.height <= 960 then
		by = by - 20
		self.Button_eat:setPositionY(by - 77)
		self.Image_time:setPositionY(by - 167)
	elseif display.size.height <= 1080 then
		by = by - 60
		self.Button_eat:setPositionY(by - 77)
		self.Image_time:setPositionY(by - 167)
	elseif display.size.height < 1280 then
		by = by - 60
		self.Button_eat:setPositionY(by-157)
		self.Image_time:setPositionY(by-290)
	elseif display.size.height == 1280 then
	elseif display.size.height > 1280 then
		self.Image_tmp_bg:setVisible(true)
		self.Image_bg:setPositionY(1402)
		by = by - 200
		self.Image_baozi:setPositionY(by-15)
		by = by - 180
		self.Button_eat:setPositionY(by - 97)
		by = by - 40
		
		if display.size.height < 1440 then
			self.Image_time:setPositionY(by - 137)
			self.Image_bg:setPositionY(1502)
		else
			self.Image_time:setPositionY(by - 167)
		end
	end
	local bgx, bgy = self.Image_bg:getPosition()

    ccui.Helper:doLayout(self["rootView"])
end

function Physical:onEnterScene()
    local show = cp.getUtils("NotifyUtils").needNotifyPhysicalGift() 
	self.Image_baozi:setVisible(true)
end

function Physical:onExitScene()
end

function Physical:onButtonClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_eat" then
		self:doSendSocket(cp.getConst("ProtoConst").GetPhysicalReq, {})
	end
end

return Physical
