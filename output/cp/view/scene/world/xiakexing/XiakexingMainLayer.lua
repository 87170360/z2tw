
local BLayer = require "cp.view.ui.base.BLayer"
local XiakexingMainLayer = class("XiakexingMainLayer",BLayer)

function XiakexingMainLayer:create(openInfo)
	local layer = XiakexingMainLayer.new(openInfo)
	return layer
end

function XiakexingMainLayer:initListEvent()
	self.listListeners = {
		-- [cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
		-- 	self:removeFromParent()
		-- end,
	}
end

function XiakexingMainLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_xkx/uicsb_xkx_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
		
		["Panel_root.ScrollView_1"] = {name = "ScrollView_1"},
        
        ["Panel_root.Image_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.rootView:setContentSize(display.size)
    local sz = self.ScrollView_1:getContentSize()
    self.ScrollView_1:setContentSize(cc.size(sz.width,display.height - 1280 + sz.height))
    self.ScrollView_1:setScrollBarEnabled(false)

    ccui.Helper:doLayout(self["rootView"])
    
end

function XiakexingMainLayer:onEnterScene()

    local current = cp.getUserData("UserXiakexing"):getValue("current")

    self.ScrollView_1:removeAllChildren()
    local infoList = cp.getManager("GDataManager"):getHeroStroyInfo()
    local totalHeight = table.nums(infoList) * 230 --每個高230
    local sz = self.ScrollView_1:getContentSize()
    local newHeight = math.max(sz.height, totalHeight)  
    self.ScrollView_1:setInnerContainerSize(cc.size(sz.width,newHeight))

    -- self.ScrollView_1:getInnerContainer():setLocalZOrder(-1)
    for i,info in pairs(infoList) do
        local item = require("cp.view.scene.world.xiakexing.XiakexingChapterItem"):create(info)
        item:setPosition(cc.p(0, newHeight - i*230))
        item:setItemClickCallBack(handler(self,self.onItemClicked))
        self.ScrollView_1:addChild(item)
        item:resetState()
    end
end

function XiakexingMainLayer:onExitScene()
   
end

function XiakexingMainLayer:onItemClicked(itemInfo,btnName)
    dump(itemInfo)
    if btnName == "Image_icon" then
        local info = {ID = itemInfo.ID,Name=itemInfo.Name, openState = "open"}
        self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_heroselect_view, info)
    elseif btnName == "Image_primeval" then
        local layer = require("cp.view.scene.primeval.PrimevalMapLayer"):create()
		self:addChild(layer, 100)
    end
end

 
function XiakexingMainLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack then
            self.closeCallBack()
        end
        self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_view, false)
    end
end

function XiakexingMainLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end


return XiakexingMainLayer
