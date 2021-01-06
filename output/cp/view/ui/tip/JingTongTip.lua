

local JingTongTip = class("JingTongTip",function() return cc.Node:create() end)
function JingTongTip:create(systemTytpe)
    local ret = JingTongTip.new()
    ret:init(systemTytpe)
    return ret
end



function JingTongTip:init()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_jingtong_tips.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
        ["Image_bg"] = {name = "Image_bg" },
		["Image_bg.Button_close"] = {name = "Button_OK" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self["Image_bg"]:setTouchEnabled(true)
end


function JingTongTip:onCloseButtonClick(sender)
	cp.getManager("PopupManager"):removePopup(self)
end

return JingTongTip
