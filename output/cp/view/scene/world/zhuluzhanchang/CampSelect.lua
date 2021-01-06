
local BNode = require "cp.view.ui.base.BNode"
local CampSelect = class("CampSelect",BNode)

function CampSelect:create()
	local node = CampSelect.new()
	return node
end

function CampSelect:initListEvent()
	self.listListeners = {       
	}
end

function CampSelect:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_camp_select.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_1.Image_random"] = {name = "Image_random",click="onButtonClicked"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
    self.Panel_root:setContentSize(display.size)
    ccui.Helper:doLayout(self["rootView"])
end


function CampSelect:onEnterScene()
    
end

function CampSelect:onExitScene()

end

function CampSelect:onButtonClicked(sender)
    
    cp.getManager("PvpSocketManager"):doSend(cp.getConst("ProtoConst").DeerSignReq, {})
end

return CampSelect
