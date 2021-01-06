local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalEffectLayer = class("PrimevalEffectLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function PrimevalEffectLayer:create()
	local scene = PrimevalEffectLayer.new()
    return scene
end

function PrimevalEffectLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalEffectLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_effect.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.ListView_Effect"] = {name = "ListView_Effect"},
		["Panel_root.Image_1.Panel_Model"] = {name = "Panel_Model"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	self.ListView_Effect:setScrollBarEnabled(false)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
end

function PrimevalEffectLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	end
end

function PrimevalEffectLayer:updatePrimevalEffectView()
	self.ListView_Effect:removeAllChildren()
	local effectList = cp.getUserData("UserPrimeval"):summaryAllEffect()
	local count = 0
	local model = nil
	for id=0, 149 do
		local value = effectList[id]
		if value then
			if count == 0 then
				model = self.Panel_Model:clone()
				self.ListView_Effect:pushBackCustomItem(model)
			end
			count = count + 1
			local txt = cp.getUtils("DataUtils").formatSkillAttribute(id, value, 0.01)
			local txtAttr = model:getChildByName("Text_Attr"..count)
			txtAttr:setString(txt)
			txtAttr:setVisible(true)
			if count == 3 then
				count = 0
			end
		end
	end
end

function PrimevalEffectLayer:onEnterScene()
	self:updatePrimevalEffectView()
end

function PrimevalEffectLayer:onExitScene()
    self:unscheduleUpdate()
end

return PrimevalEffectLayer