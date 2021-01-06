local BLayer = require "cp.view.ui.base.BLayer"
local NoticeLayer = class("NoticeLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function NoticeLayer:create()
    local scene = NoticeLayer.new()
    return scene
end

function NoticeLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function NoticeLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/uicsb_login_notice.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.ScrollView_1"] = {name = "ScrollView_1"},
		["Panel_root.Image_1.Text_Content"] = {name = "Text_Content"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
end

function NoticeLayer:updateNoticeView()
    local richText = self.ScrollView_1:getChildByName("RichText_Desc")
    if richText then
        richText:removeFromParent()
    end

    local sz = self.ScrollView_1:getContentSize()
    local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_notice.txt")
    local richText = cp.getUtils("RichTextUtils").ParseRichText(desc)
    richText:setName("RichText_Desc")

	richText:setContentSize(cc.size(sz.width-20,9000))
    --richText:setLineGap( tonumber(linegap) ~= nil and tonumber(linegap) or 1)
	
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(sz.width-20,tsize.width),math.max(sz.height,tsize.height)))

    local sz2 = richText:getContentSize()
    richText:setPosition(0, sz2.height+10)
    self.ScrollView_1:setInnerContainerSize(cc.size(sz.width, sz2.height+10))
    self.ScrollView_1:addChild(richText)
    self.ScrollView_1:setScrollBarEnabled(false)
end

function NoticeLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
	end
end

function NoticeLayer:onEnterScene()
    self:updateNoticeView()
end

function NoticeLayer:onExitScene()
    cp.updated = false
end

return NoticeLayer