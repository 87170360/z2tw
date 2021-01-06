local BLayer = require "cp.view.ui.base.BLayer"
local SkillStrategyLayer = class("SkillStrategyLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function SkillStrategyLayer:create(skillEntry, skillInfo)
	local scene = SkillStrategyLayer.new()
	scene.skillEntry = skillEntry
	scene.skillInfo = skillInfo or {
		skill_level = 0,
		boundary = 0
	}
	scene:updateSkillStrategyView()
    return scene
end

function SkillStrategyLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillStrategyLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_strategy.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.ListView_Effect"] = {name = "ListView_Effect"},
		["Panel_root.Image_1.Panel_Effect"] = {name = "Panel_Effect"},
		["Panel_root.Image_1.Image_Power.Text_Power"] = {name = "Text_Power"},
		["Panel_root.Image_1.Image_Cost.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Image_Skill"] = {name = "Image_Skill"},
		["Panel_root.Image_1.Image_SkillType"] = {name = "Image_SkillType"},
		["Panel_root.Image_1.Text_SkillName"] = {name = "Text_SkillName"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.ListView_Effect:setScrollBarEnabled(false)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
end

function SkillStrategyLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:getParent():removeChild(self)
	elseif nodeName == "Button_Go" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
    	--self:doSendSocket(cp.getConst("ProtoConst").ImproveSkillBoundaryReq, req)
	end
end

function SkillStrategyLayer:updateSkillStrategyView()
	self.Image_Skill:loadTexture(self.skillEntry:getValue("Icon"))
	self.Image_SkillType:loadTexture(CombatConst.SkillSerise_IconList[self.skillEntry:getValue("Serise")], ccui.TextureResType.plistType)
	local icon = self.Image_Skill:getChildByName("Image_Icon")
	local txtLevel = self.Image_Skill:getChildByName("Text_Level")
	icon:loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	txtLevel:setString("LV."..self.skillInfo.skill_level)

	self.Text_SkillName:setString(self.skillEntry:getValue("SkillName"))
	cp.getManager("ViewManager").setTextQuality(self.Text_SkillName, self.skillEntry:getValue("Colour"))
	local power = 0
	if self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Force and 
		self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Body and 
			self.skillEntry:getValue("Serise") ~= CombatConst.SkillSerise_Unorthodox then
		power = cp.getUtils("DataUtils").GetSkillPower(self.skillEntry:getValue("Colour"), self.skillInfo.skill_level, self.skillInfo.boundary)
	end
	self.Text_Power:setString(power)
	self.Text_Cost:setString(cp.getUtils("DataUtils").GetSkillForceCost(self.skillEntry:getValue("Colour"), self.skillInfo.skill_level))

	local totalHeight = 0
	if self.skillEntry:getValue("Comment"):len() > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_Comment")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_Comment")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("武學介紹")
			panel:setVisible(true)
			self.ListView_Effect:pushBackCustomItem(panel)

			local richText = cp.getUtils("DataUtils").formatSkillComment(self.skillEntry)
			local deltaHeight = richText:getContentSize().height - 20
			panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
			panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
			panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
			panel:setSize(cc.size(660, 90 + deltaHeight))
			local pos = cc.p(28, 37 + deltaHeight)
			richText:setPosition(pos)
			panel:addChild(richText)
			totalHeight = totalHeight + 90 + deltaHeight
		end
	end

	if self.skillEntry:getValue("GainWay"):len() > 0 then
		local panel = self.ListView_Effect:getChildByName("Panel_GainWay")
		if not panel then
			panel = self.Panel_Effect:clone()
			panel:setName("Panel_GainWay")
			panel:getChildByName("Image_EffectName"):getChildByName("Text"):setString("獲取途徑")
			panel:setVisible(true)
			self.ListView_Effect:pushBackCustomItem(panel)

			local richText = cp.getUtils("DataUtils").formatSkillGainWay(self.skillEntry)
			local deltaHeight = richText:getContentSize().height - 20
			panel:getChildByName("Image_EffectName"):setPosition(330, 72 + deltaHeight)
			panel:getChildByName("Image_Bg"):setSize(cc.size(660, 54 + deltaHeight))
			panel:getChildByName("Image_Bg"):setPosition(330, 54 + deltaHeight)
			panel:setSize(cc.size(660, 90 + deltaHeight))
			local pos = cc.p(28, 37 + deltaHeight)
			richText:setPosition(pos)
			panel:addChild(richText)
			totalHeight = totalHeight + 90 + deltaHeight
		end
	end

	cp.getManager("ViewManager").setWidgetAdapt(238, {self.Image_1, self.ListView_Effect}, totalHeight)
	ccui.Helper:doLayout(self.rootView)
end

function SkillStrategyLayer:onEnterScene()
end

function SkillStrategyLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function SkillStrategyLayer:onExitScene()
    self:unscheduleUpdate()
end

return SkillStrategyLayer