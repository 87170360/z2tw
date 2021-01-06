
local BLayer = require "cp.view.ui.base.BLayer"
local Layerframe = class("Layerframe",BLayer)  --function() return cc.Node:create() end)
function Layerframe:create(openInfo)
    local layer = Layerframe.new(openInfo)
    return layer
end


function Layerframe:initListEvent()
	self.listListeners = {
	}
end

function Layerframe:onInitView(openInfo)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_frame.csb")
    self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_bg.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bottom"] = {name = "Image_bottom"},  
		["Panel_root.Image_top"] = {name = "Image_top"}, 
		["Panel_root.Image_top.Image_title"] = {name = "Image_title"},
		["Panel_root.Image_top.Image_title.Text_title"] = {name = "Text_title"},
		["Panel_root.Button_close"] = {name = "Button_close", click = "onCloseButtonClick"}, 
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	
	self.Image_title:setVisible(false)
	self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
	self:adjustFrame(openInfo.title, openInfo.closeCallBack, openInfo.dynamicHeight)
	ccui.Helper:doLayout(self.rootView)
end

function Layerframe:onEnterScene()
	
end

function Layerframe:adjustFrame(title, closeCallBack, dynamicHeight)
	local newHeight = display.height
	if dynamicHeight then
		if display.height > 1080 then
			newHeight = 903
		elseif display.height > 960 then
			newHeight = 825
		else
			newHeight = 710
		end
	end
	local width = self.Panel_root:getContentSize().width
	self.Panel_root:setContentSize(width,newHeight)

	self.Image_title:setVisible(title ~= nil and string.len(title) > 0)
	self.Text_title:setString(tostring(title))
	if closeCallBack ~= nil then
		self.closeCallBack = closeCallBack
	end

	local y = self.Panel_root:getPositionY()
	self.Button_close:setPosition(cc.p(650, y + newHeight/2 - 225))  --x不變，y值離Panel_root上端差185
	
end

function Layerframe:onCloseButtonClick(sender)
	if self.closeCallBack ~= nil then
		self.closeCallBack()
	end
end

function Layerframe:setCloseCallBack(cb)
	self.closeCallBack = cb
end

return Layerframe