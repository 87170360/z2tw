local BLayer = require "cp.view.ui.base.BLayer"
local SkillUseLayer = class("SkillUseLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillUseLayer:create(combineID)
	local scene = SkillUseLayer.new()
	scene.combineID = combineID
	scene.combatTypeList = cp.getUserData("UserSkill"):getCombatTypeList(combineID)
    return scene
end

function SkillUseLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		["UseCombineReq"] = function(data)
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillUseLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_use.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Save"] = {name = "Button_Save", click="onBtnClick"},
		["Panel_root.Image_1.Button_10"] = {name = "Button_10", click="onBtnClick"},
		["Panel_root.Image_1.Button_14"] = {name = "Button_14", click="onBtnClick"},
		["Panel_root.Image_1.Button_8"] = {name = "Button_8", click="onBtnClick"},
		["Panel_root.Image_1.Button_6"] = {name = "Button_6", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
end

function SkillUseLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_Save" then
		local req = {
			combine_info = {
				combine_id = self.combineID,
				combat_type_list = self.combatTypeList
			}
		}
		self:doSendSocket(cp.getConst("ProtoConst").UseCombineReq, req)
	else
		local combatType = tonumber(string.sub(nodeName, 8))
		if table.indexof(self.combatTypeList, combatType) then
			table.removebyvalue(self.combatTypeList, combatType)
		else
			table.insert(self.combatTypeList, combatType)
		end
		self:updateSkillUseView()
	end
end

function SkillUseLayer:updateSkillUseView()
	for i=1, 20 do
		local btn = self["Button_"..i]
		if btn then
			if table.indexof(self.combatTypeList, i) then
				local textureName = "ui_common_module_bangpai_7.png"
				btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
			else
				local textureName = "ui_common_module_bangpai_6.png"
				btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
			end
		end
	end
end

function SkillUseLayer:onEnterScene()
	self:updateSkillUseView()
end

function SkillUseLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillUseLayer