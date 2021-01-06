local BLayer = require "cp.view.ui.base.BLayer"
local SkillSingleArtLayer = class("SkillSingleArtLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
local DataUtils = cp.getUtils("DataUtils")

function SkillSingleArtLayer:create(skillEntry, artLevel)
	local scene = SkillSingleArtLayer.new()
	scene.skillEntry = skillEntry
	scene.artLevel = artLevel or 0
	scene:updateSingleArtView()
    return scene
end

function SkillSingleArtLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillSingleArtLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_skill/uicsb_single_art.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Art"] = {name = "Image_Art"},
		["Panel_root.Image_1.Text_ArtName"] = {name = "Text_ArtName"},
		["Panel_root.Image_1.Text_Desc"] = {name = "Text_Desc"},
		["Panel_root.Image_1.Image_SkillType"] = {name = "Image_SkillType"},
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

function SkillSingleArtLayer:updateSingleArtView()
	self.Image_SkillType:loadTexture(CombatConst.SkillSerise_IconList[self.skillEntry:getValue("Serise")], ccui.TextureResType.plistType)
	self.Image_Art:loadTexture(self.skillEntry:getValue("Icon"))
	local icon = self.Image_Art:getChildByName("Image_Icon")
	local txtLevel = self.Image_Art:getChildByName("Text_Level")
	icon:loadTexture(CombatConst.SkillBoxList[self.skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
	cp.getManager("ViewManager").setTextQuality(self.Text_ArtName, self.skillEntry:getValue("Colour"))
	self.Text_ArtName:setString(self.skillEntry:getValue("SkillName"))
	txtLevel:setString("LV."..self.artLevel + 1)

	local artEffectDesc = ""
	local attrList = {}
	local bufferList = cp.getUtils("DataUtils").splitBufferList(self.skillEntry:getValue("BufferList"))
	for i=1, #bufferList do
		local skillStatusEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferList[i])
		if skillStatusEntry then
			local eventList = cp.getUtils("DataUtils").splitBufferList(skillStatusEntry:getValue("EventList"))
			for i=1, #eventList do
				local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", eventList[i])
				if eventEntry then
					local list = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
					table.insertto(list, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
					local conditionInfo = DataUtils.split(eventEntry:getValue("Rate"), "=")
					if conditionInfo[1] == 0 then
						table.insert(list, {
							CombatConst.GameElement_ConditionRate, 0, conditionInfo[2] or 10000
						})
					else
						table.insert(list, {
							CombatConst.GameElement_ConditionRate, 2, conditionInfo[1] or 10000
						})
					end
					cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), self.artLevel, list)
					for k, v in ipairs(list) do
						table.insert(attrList, v)
					end
				end
			end

			local desc = skillStatusEntry:getValue("Comment")
			local list = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("Elements"))
			local boolStatusList = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("BoolStatus"))
			for _, boolStatusInfo in ipairs(boolStatusList) do
				table.insert(list, {
					CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
				})
			end
			
			cp.getUtils("DataUtils").GetArtEffectValue(self.skillEntry:getValue("Colour"), self.artLevel, list)
			for k, v in ipairs(list) do
				table.insert(attrList, v)
			end
			desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
			artEffectDesc = artEffectDesc..desc
		end
	end
	self.Text_Desc:setString(artEffectDesc)
end

function SkillSingleArtLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	end
end

function SkillSingleArtLayer:onEnterScene()
end

function SkillSingleArtLayer:onExitScene()
    self:unscheduleUpdate()
end

function SkillSingleArtLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

return SkillSingleArtLayer