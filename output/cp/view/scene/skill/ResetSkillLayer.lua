local BLayer = require "cp.view.ui.base.BLayer"
local ResetSkillLayer = class("ResetSkillLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ResetSkillLayer:create(skillEntry)
	local scene = ResetSkillLayer.new()
	scene.skillEntry = skillEntry
	scene:updateResetSkillView()
    return scene
end

function ResetSkillLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").ResetSkillRsp] = function(data)
			self:updateResetSkillView()
			if self.closeCallback then
				self.closeCallback()
			end
			self:removeFromParent()
		end,
		[cp.getConst("EventConst").DecomposeSkillPiecesRsp] = function(data)
			self:updateResetSkillView()
		end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function ResetSkillLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_skill_reset.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_TrainPoint"] = {name = "Text_TrainPoint"},
		["Panel_root.Image_1.Text_LearnPoint"] = {name = "Text_LearnPoint"},
		["Panel_root.Image_1.Button_AddLearnPoint"] = {name = "Button_AddLearnPoint", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Reset"] = {name = "Button_Reset", click="onBtnClick"},
		["Panel_root.Image_1.Text_SkillLevel"] = {name = "Text_SkillLevel"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Text_Gain"] = {name = "Text_Gain"},
		["Panel_root.Image_1.Text_AttrName1"] = {name = "Text_AttrName1"},
		["Panel_root.Image_1.Text_AttrName2"] = {name = "Text_AttrName2"},
		["Panel_root.Image_1.Text_AttrBefore1"] = {name = "Text_AttrBefore1"},
		["Panel_root.Image_1.Text_AttrBefore2"] = {name = "Text_AttrBefore2"},
		["Panel_root.Image_1.Text_AttrAfter1"] = {name = "Text_AttrAfter1"},
		["Panel_root.Image_1.Text_AttrAfter2"] = {name = "Text_AttrAfter2"},
		["Panel_root.Image_1.Image_Attr1"] = {name = "Image_Attr1"},
		["Panel_root.Image_1.Image_Attr2"] = {name = "Image_Attr2"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
end

function ResetSkillLayer:updateResetSkillView()
	local skillInfo = cp.getUserData("UserSkill"):getSkill(self.skillEntry:getValue("SkillID"))
	if not skillInfo then
		return
	end

	if skillInfo.skill_level == 1 then
		cp.getManager("ViewManager").setEnabled(self.Button_Reset, false)
	else
		cp.getManager("ViewManager").setEnabled(self.Button_Reset, true)
	end
	
	self.Text_TrainPoint:setString(tostring(cp.getUserData("UserSkill"):getTrainPoint()))
	self.Text_LearnPoint:setString(tostring(cp.getUserData("UserSkill"):getLearnPoint()))
	self.Text_SkillLevel:setString("LV."..skillInfo.skill_level)
	local cost, gain = cp.getUtils("DataUtils").GetResetSkillPoint(self.skillEntry:getValue("Colour"), skillInfo.skill_level)
	self.Text_Cost:setString(tostring(cost))
	self.Text_Gain:setString(tostring(gain))
	if cp.getUserData("UserSkill"):getLearnPoint() < cost then
		cp.getManager("ViewManager").setTextQuality(self.Text_Cost, 6)
	else
		cp.getManager("ViewManager").setTextQuality(self.Text_Cost, 2)
	end

	local attrList = cp.getUtils("DataUtils").splitAttr(self.skillEntry:getValue("AttrList"))
	for i=1, 2 do
		if attrList[i] then
			local id = attrList[i][1]
			local beforeValue = cp.getUtils("DataUtils").GetSkillExtraEffect(self.skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.boundary, id, self.skillEntry:getValue("Serise"))
			local afterValue = cp.getUtils("DataUtils").GetSkillExtraEffect(self.skillEntry:getValue("Colour"), 1, skillInfo.boundary, id, self.skillEntry:getValue("Serise"))
			if #attrList == 1 then
				beforeValue = beforeValue * 2
				afterValue = afterValue * 2
			end
			
			self["Text_AttrBefore"..i]:setString(beforeValue)
			self["Text_AttrAfter"..i]:setString(afterValue)
			self["Text_AttrName"..i]:setString(CombatConst.AttributeList[id].."+")

			self["Text_AttrBefore"..i]:setVisible(true)
			self["Text_AttrAfter"..i]:setVisible(true)
			self["Image_Attr"..i]:setVisible(true)
		else
			self["Text_AttrBefore"..i]:setVisible(false)
			self["Text_AttrAfter"..i]:setVisible(false)
			self["Image_Attr"..i]:setVisible(false)
		end
	end
end

function ResetSkillLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function ResetSkillLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:getParent():removeChild(self)
	elseif nodeName == "Button_Reset" then
		local req = {}
		req.skill_id = self.skillEntry:getValue("SkillID")
    	self:doSendSocket(cp.getConst("ProtoConst").ResetSkillReq, req)
	elseif nodeName == "Button_AddLearnPoint" then
		local layer = require("cp.view.scene.skill.SkillPieceDecomposeLayer"):create()
		self:addChild(layer, 100)
		layer:setCloseCallback(function()
			self:updateResetSkillView()
		end)
	end
end

function ResetSkillLayer:onEnterScene()
end

function ResetSkillLayer:onExitScene()
    self:unscheduleUpdate()
end

return ResetSkillLayer