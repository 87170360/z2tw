
local BNode = require "cp.view.ui.base.BNode"
local ZLZCBuildDefender = class("ZLZCBuildDefender",BNode)

function ZLZCBuildDefender:create(openInfo)
	local node = ZLZCBuildDefender.new(openInfo)
	return node
end

function ZLZCBuildDefender:initListEvent()
	self.listListeners = {
	}
end

function ZLZCBuildDefender:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_build_defender.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Text_name_server"] = {name = "Text_name_server"},
        ["Panel_root.Text_lv"] = {name = "Text_lv"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
    ccui.Helper:doLayout(self["rootView"])
end


function ZLZCBuildDefender:onEnterScene()
    local model = cp.getManager("ViewManager").createRoleModel(self.openInfo.career, self.openInfo.gender,self.openInfo.fashionid,0.5)
    self.Panel_root:addChild(model,-1)
    local sz = self.Panel_root:getContentSize()
    model:setPosition(cc.p(sz.width/2,30))
    self.Text_name_server:setString("【伺服器" .. self.openInfo.zoneid .. "】" .. self.openInfo.name)
    self.Text_lv:setString(tostring(self.openInfo.level))
end

function ZLZCBuildDefender:onExitScene()

end

return ZLZCBuildDefender
