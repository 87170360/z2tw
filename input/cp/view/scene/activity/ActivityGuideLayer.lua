local BLayer = require "cp.view.ui.base.BLayer"
local ActivityGuideLayer = class("ActivityGuideLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ActivityGuideLayer:create(openInfo)
	local scene = ActivityGuideLayer.new(openInfo.type)
    return scene
end

function ActivityGuideLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:dispatchViewEvent("ActivityGuide", {flag=false})
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function ActivityGuideLayer:onInitView(type)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_guide.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.type = type or 1

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
		["Panel_root.Image_1.Image_3.Button_Type1"] = {name = "Button_Type1", click="onBtnTypeClick"},
		["Panel_root.Image_1.Image_3.Button_Type2"] = {name = "Button_Type2", click="onBtnTypeClick"},
		["Panel_root.Image_1.Image_3.Button_Type3"] = {name = "Button_Type3", click="onBtnTypeClick"},
		["Panel_root.Image_1.Image_3.Button_Type4"] = {name = "Button_Type4", click="onBtnTypeClick"},
		["Panel_root.Image_1.Image_3.Button_Type5"] = {name = "Button_Type5", click="onBtnTypeClick"},
		["Panel_root.Image_1.Image_3.Button_Type6"] = {name = "Button_Type6", click="onBtnTypeClick"},
		["Panel_root.Image_1.ListView_Effect"] = {name = "ListView_Effect"},
		["Panel_root.Image_1.Panel_Effect"] = {name = "Panel_Effect"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    self.ListView_Effect:setScrollBarEnabled(false)

	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.ListView_Effect, self.Image_bg})
	ccui.Helper:doLayout(self.rootView)
	self["Button_Type"..self.type]:setEnabled(false)
end

function ActivityGuideLayer:updateActivityGuideView()
	local entryList = {}
	cp.getManager("ConfigManager").foreach("GameGuide", function(entry)
		if entry:getValue("Type") == self.type then
			table.insert(entryList, entry)
		end
		return true
	end)

	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self.ListView_Effect:removeAllChildren()
	for i, entry in ipairs(entryList) do
		if roleAtt.hierarchy >= entry:getValue("Hierarchy") and roleAtt.hierarchy >= entry:getValue("Level") then
			local panel = self.Panel_Effect:clone()
			panel:setVisible(true)
			panel:getChildByName("Image_Name"):getChildByName("Text_Name"):setString(entry:getValue("SubTypeName"))
			local btn = panel:getChildByName("Button_GO")
			local imgName = panel:getChildByName("Image_Name")
			local richText = cp.getUtils("RichTextUtils").ParseRichText(entry:getValue("Desc"))
			richText:setContentSize(cc.size(400,9000))
			richText:formatText()
			local tsize = richText:getTextSize()
			richText:setContentSize(cc.size(math.max(400,tsize.width),tsize.height))
			richText:setAnchorPoint(cc.p(0,1))
			local height = 84 + richText:getContentSize().height
			panel:setSize(cc.size(660, height))
			imgName:setPosition(cc.p(164,height-34))
			local pos = cc.p(28, height - 62)
			richText:setPosition(pos)
			panel:addChild(richText)
			cp.getManager("ViewManager").initButton(btn, function()
				self:onBtnGoClick(entry:getValue("Type"), entry:getValue("SubType"))
			end)
			self.ListView_Effect:pushBackCustomItem(panel)
		end
	end
end

function ActivityGuideLayer:onBtnGoClick(type, subType)
	local needClose = true
	if type == 1 then
		if subType == 1 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_MajorRole}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 2 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_SkillSummary}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 4 then
			self:dispatchViewEvent("GetPrimevalDataRsp", true)
		elseif subType == 5 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_MajorRole}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 6 then
			local ChapterPartLayer = require("cp.view.scene.world.major.ChapterPartLayer"):create()
			self:getParent():addChild(ChapterPartLayer, 1)
		end
	elseif type == 2 then
		if subType == 1 then
			cp.getManager("ViewManager").showSilverConvertUI()
		elseif subType == 2 then
			self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, true)
		elseif subType == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 4 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 5 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		end
	elseif type == 3 then
		if subType == 1 then
			local layer = require("cp.view.scene.skill.BuyTrainPointLayer"):create()
			self:addChild(layer, 100)
			needClose = false
		elseif subType == 2 then
			if self.ShopMainUI ~= nil then
				self.ShopMainUI:removeFromParent()
			end
			self.ShopMainUI = nil
			
			local storeID = 10  --幫派商店
			local openInfo = {storeID = storeID, closeCallBack = function()
				self.ShopMainUI:removeFromParent()
				self.ShopMainUI = nil
			end}
			local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
			self.rootView:addChild(ShopMainUI)
			self.ShopMainUI = ShopMainUI
			needClose = false
		elseif subType == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		end
	elseif type == 4 then
		if subType == 1 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 2 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 4 then
			if self.ShopMainUI ~= nil then
				self.ShopMainUI:removeFromParent()
			end
			self.ShopMainUI = nil
			
			local storeID = 6  --幫派商店
			local openInfo = {storeID = storeID, closeCallBack = function()
				self.ShopMainUI:removeFromParent()
				self.ShopMainUI = nil
			end}
			local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
			self.rootView:addChild(ShopMainUI)
			self.ShopMainUI = ShopMainUI
			needClose = false
		end
	elseif type == 5 then
		if subType == 1 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 2 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 3 then
			local ChapterPartLayer = require("cp.view.scene.world.major.ChapterPartLayer"):create()
			self:getParent():addChild(ChapterPartLayer, 1)
		elseif subType == 4 then
			if self.ShopMainUI ~= nil then
				self.ShopMainUI:removeFromParent()
			end
			self.ShopMainUI = nil
			
			local storeID = 7  --幫派商店
			local openInfo = {storeID = storeID, closeCallBack = function()
				self.ShopMainUI:removeFromParent()
				self.ShopMainUI = nil
			end}
			local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
			self.rootView:addChild(ShopMainUI)
			self.ShopMainUI = ShopMainUI
			needClose = false
		end
	elseif type == 6 then
		if subType == 1 then
			local ChapterPartLayer = require("cp.view.scene.world.major.ChapterPartLayer"):create()
			self:getParent():addChild(ChapterPartLayer, 1)
		elseif subType == 2 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif subType == 4 then
			if self.ShopMainUI ~= nil then
				self.ShopMainUI:removeFromParent()
			end
			self.ShopMainUI = nil
			
			local storeID = 3  --幫派商店
			local openInfo = {storeID = storeID, closeCallBack = function()
				self.ShopMainUI:removeFromParent()
				self.ShopMainUI = nil
			end}
			local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
			self.rootView:addChild(ShopMainUI)
			self.ShopMainUI = ShopMainUI
			needClose = false
		end
	end
	if needClose then
		self:dispatchViewEvent("ActivityGuide", {flag=false})
	end
end

function ActivityGuideLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Back" then
		self:dispatchViewEvent("ActivityGuide", {flag=false})
	end
end

function ActivityGuideLayer:onBtnTypeClick(btn)
	local nodeName = btn:getName()
	for i=1, 6 do
		local name = "Button_Type"..i
		if nodeName == name then
			self.type = i
			self[name]:setEnabled(false)
		else	
			self[name]:setEnabled(true)
		end
	end

	self:updateActivityGuideView()
end

function ActivityGuideLayer:onEnterScene()
	self:updateActivityGuideView()
end

function ActivityGuideLayer:onExitScene()
end

return ActivityGuideLayer