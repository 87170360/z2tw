local BLayer = require "cp.view.ui.base.BLayer"
local SkillEffectLayer = class("SkillEffectLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillEffectLayer:create()
	local scene = SkillEffectLayer.new()
	scene:updateSkillEffectView()
	cp.getUtils("NotifyUtils").notifySkillAttr = false
    return scene
end

function SkillEffectLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillEffectLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_effect.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Text_SkillNum"] = {name = "Text_SkillNum"},
		["Panel_root.Image_1.Text_Attr0"] = {name = "Text_Attr0"},
		["Panel_root.Image_1.Text_Attr1"] = {name = "Text_Attr1"},
		["Panel_root.Image_1.Text_Attr2"] = {name = "Text_Attr2"},
		["Panel_root.Image_1.Text_Attr3"] = {name = "Text_Attr3"},
		["Panel_root.Image_1.Text_Attr4"] = {name = "Text_Attr4"},
		["Panel_root.Image_1.Text_Attr5"] = {name = "Text_Attr5"},
		["Panel_root.Image_1.Text_Attr6"] = {name = "Text_Attr6"},
		["Panel_root.Image_1.Text_Attr7"] = {name = "Text_Attr7"},
		["Panel_root.Image_1.Text_Attr10"] = {name = "Text_Attr10"},
		["Panel_root.Image_1.Text_Attr11"] = {name = "Text_Attr11"},
		["Panel_root.Image_1.Text_Attr12"] = {name = "Text_Attr12"},
		["Panel_root.Image_1.Text_Attr13"] = {name = "Text_Attr13"},
		["Panel_root.Image_1.Text_Attr14"] = {name = "Text_Attr14"},
		["Panel_root.Image_1.Text_Attr15"] = {name = "Text_Attr15"},
		["Panel_root.Image_1.Text_Attr16"] = {name = "Text_Attr16"},
		["Panel_root.Image_1.Text_Attr17"] = {name = "Text_Attr17"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
    --self.Image_1:setScale(0.5)
    --self.Image_1:runAction(cc.ScaleTo:create(0.1, 1.0))
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
	cp.getUtils("NotifyUtils").notifySkillAttr = false
end

function SkillEffectLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	elseif nodeName == "Button_Go" then
	end
end

function SkillEffectLayer:updateSkillEffectView()
	local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
	if not skillData or not skillData.skill_list then
		return
	end

	self.Text_SkillNum:setString(#skillData.skill_list.skill_list)
	local attribute = {}
	for _, skillInfo in ipairs(skillData.skill_list.skill_list) do
		local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillInfo.skill_id)
		if skillEntry then
			local attrList = cp.getUtils("DataUtils").splitAttr(skillEntry:getValue("AttrList"))
			for i=1, #attrList do
				local id = attrList[i][1]
				local value = cp.getUtils("DataUtils").GetSkillExtraEffect(skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.boundary, id, skillEntry:getValue("Serise"))
				if #attrList == 1 then
					value = value * 2
				end
				if attribute[id] then
					attribute[id] = attribute[id] + value
				else
					attribute[id] = value
				end
			end
		end
	end

	for i=0, 17 do
		local txt = self["Text_Attr"..i]
		if txt then
			local id = i
			local value = attribute[i] or 0
			local tempStr = cp.getUtils("DataUtils").formatSkillAttribute(id, value)
			txt:setString(tempStr)
		end
	end
end

function SkillEffectLayer:onEnterScene()
end

function SkillEffectLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function SkillEffectLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillEffectLayer