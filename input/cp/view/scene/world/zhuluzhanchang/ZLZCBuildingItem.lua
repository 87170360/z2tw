
local BNode = require "cp.view.ui.base.BNode"
local ZLZCBuildingItem = class("ZLZCBuildingItem",BNode)

function ZLZCBuildingItem:create()
	local node = ZLZCBuildingItem.new()
	return node
end

function ZLZCBuildingItem:initListEvent()
	self.listListeners = {
	}
end

function ZLZCBuildingItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_build_info_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_build"] = {name = "Image_build",click="onBuildClicked"},
        ["Panel_root.Text_name"] = {name = "Text_name"},
        ["Panel_root.Image_process_bg"] = {name = "Image_process_bg"},
        ["Panel_root.Image_process_bg.Image_process"] = {name = "Image_process"},
        ["Panel_root.Image_process_bg.Text_process"] = {name = "Text_process"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
    self.Text_process:setVisible(false)
    
    ccui.Helper:doLayout(self["rootView"])
end


function ZLZCBuildingItem:onEnterScene()
    
end

function ZLZCBuildingItem:onExitScene()

end

function ZLZCBuildingItem:onBuildClicked(sender)
    if self.clickCallBack then
        self.clickCallBack(self.openInfo)
    end
end

function ZLZCBuildingItem:setClickCallBack(cb)
    self.clickCallBack = cb
end

function ZLZCBuildingItem:resetInfo(info)
    self.openInfo = info

    local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat")
    local defeat_times = math.min(self.openInfo.Hp, buildings_defeat[self.openInfo.ID] or 0)

    local scale = defeat_times/self.openInfo.Hp
    self.Image_process:setContentSize(cc.size(154*scale,23))
    
    if self.openInfo.Name then
        self.Text_name:setString(self.openInfo.Name)
    end
    if scale >= 1 then
        self.Image_build:loadTexture(self.openInfo.IconBroken,ccui.TextureResType.plistType)
    else
        self.Image_build:loadTexture(self.openInfo.IconNormal,ccui.TextureResType.plistType) 
    end
    self.Image_build:ignoreContentAdaptWithSize(true)
end

function ZLZCBuildingItem:resetPos(pos)
    self.rootView:setPosition(pos)
end

return ZLZCBuildingItem
