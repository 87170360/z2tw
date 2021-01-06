local BLayer = require "cp.view.ui.base.BLayer"
local NumberInputLayer = class("NumberInputLayer", BLayer)

function NumberInputLayer:create(pos, cb)
    local scene = NumberInputLayer.new()
	scene.callback = cb
	scene.pos = pos
    return scene
end

function NumberInputLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function NumberInputLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_number_input.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_input"] = {name = "Panel_input"},
		["Panel_root.Panel_input.Button_Del"] = {name = "Panel_root.Button_Del", click="onBtnClick"},
		["Panel_root.Panel_input.Button_0"] = {name = "Panel_root.Button_0", click="onBtnClick"},
		["Panel_root.Panel_input.Button_1"] = {name = "Panel_root.Button_1", click="onBtnClick"},
		["Panel_root.Panel_input.Button_2"] = {name = "Panel_root.Button_2", click="onBtnClick"},
		["Panel_root.Panel_input.Button_3"] = {name = "Panel_root.Button_3", click="onBtnClick"},
		["Panel_root.Panel_input.Button_4"] = {name = "Panel_root.Button_4", click="onBtnClick"},
		["Panel_root.Panel_input.Button_5"] = {name = "Panel_root.Button_5", click="onBtnClick"},
		["Panel_root.Panel_input.Button_6"] = {name = "Panel_root.Button_6", click="onBtnClick"},
		["Panel_root.Panel_input.Button_7"] = {name = "Panel_root.Button_7", click="onBtnClick"},
		["Panel_root.Panel_input.Button_8"] = {name = "Panel_root.Button_8", click="onBtnClick"},
		["Panel_root.Panel_input.Button_9"] = {name = "Panel_root.Button_9", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
end

function NumberInputLayer:setCloseCallback(cb)
	cp.getManager("ViewManager").setTouchHide(self, self.Panel_root, cb)
end

function NumberInputLayer:updateNumberInputView()
	self.Panel_input:setPosition(self.pos)
end

function NumberInputLayer:onBtnClick(btn)
    local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
    self.callback(tonumber(extensionData:getCustomProperty()))
end

function NumberInputLayer:onEnterScene()
	self:updateNumberInputView()
end

function NumberInputLayer:onExitScene()
end

return NumberInputLayer