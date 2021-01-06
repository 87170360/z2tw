local BLayer = require "cp.view.ui.base.BLayer"
local PublicColorLayer = class("PublicColorLayer", BLayer)
--mode=1單選，mode=2多選
function PublicColorLayer:create(mode, colorList)
	local scene = PublicColorLayer.new(mode or 1, colorList or {})
    return scene
end

function PublicColorLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function PublicColorLayer:onInitView(mode, colorList)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_color.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.mode = mode
	self.colorList = colorList

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_OK"] = {name = "Button_OK", click="onBtnClick"},
		["Panel_root.Image_1.Button_1"] = {name = "Button_1", click="onBtnClick"},
		["Panel_root.Image_1.Button_2"] = {name = "Button_2", click="onBtnClick"},
		["Panel_root.Image_1.Button_3"] = {name = "Button_3", click="onBtnClick"},
		["Panel_root.Image_1.Button_4"] = {name = "Button_4", click="onBtnClick"},
		["Panel_root.Image_1.Button_5"] = {name = "Button_5", click="onBtnClick"},
		["Panel_root.Image_1.Button_6"] = {name = "Button_6", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
end

function PublicColorLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_OK" then
		if #self.colorList == 0 then
			return
		end

		local v
		if self.mode == 1 then
			v = self.colorList[1]
		else
			v = self.colorList
		end

		self:dispatchViewEvent("SelectQuality" , v)
		self:removeFromParent()
	else
		local color = tonumber(string.sub(nodeName, 8))
		if table.indexof(self.colorList, color) then
			if mode == 1 then
				return
			end
			table.removebyvalue(self.colorList, color)
		else
			self.colorList = {}
			table.insert(self.colorList, color)
		end
		self:updateSkillUseView()
	end
end

function PublicColorLayer:updateSkillUseView()
	for i=1, 6 do
		local btn = self["Button_"..i]
		if btn then
			if table.indexof(self.colorList, i) then
				local textureName = "ui_common_module_bangpai_7.png"
				btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
			else
				local textureName = "ui_common_module_bangpai_6.png"
				btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
			end
		end
	end
end

function PublicColorLayer:onEnterScene()
	self:updateSkillUseView()
end

function PublicColorLayer:onExitScene()
    self:unscheduleUpdate()
end

return PublicColorLayer