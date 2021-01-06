local BLayer = require "cp.view.ui.base.BLayer"
local SkillItemLayer = class("SkillItemLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

--如果有該物品，則傳入index，否則index為nil
function SkillItemLayer:create(itemEntry, cost)
	local scene = SkillItemLayer.new()
	scene.itemEntry = itemEntry
	scene.cost = cost
	scene:updateSkillItemView()
    return scene
end

function SkillItemLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").BuyLotteryPointShopRsp] = function(data)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillItemLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shop/uicsb_shop_skill_item.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Buy"] = {name = "Button_Buy", click="onBtnClick"},
		["Panel_root.Image_1.Button_View"] = {name = "Button_View", click="onBtnClick"},
		["Panel_root.Image_1.Image_Matiral"] = {name = "Image_Matiral"},
		["Panel_root.Image_1.Text_MatiralName"] = {name = "Text_MatiralName"},
		["Panel_root.Image_1.Text_MatiralType"] = {name = "Text_MatiralType"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Text_Desc"] = {name = "Text_Desc"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").popUpView(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
	end)
end

function SkillItemLayer:updateSkillItemView()
	self.Image_Matiral:loadTexture(self.itemEntry:getValue("Icon"))
	cp.getManager("ViewManager").addWidgetBottom(self.Image_Matiral, self.itemEntry:getValue("Hierarchy"))
	local icon = self.Image_Matiral:getChildByName("Image_Icon")
	icon:loadTexture(CombatConst.SkillBoxList[self.itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
	self.Text_MatiralName:setString(self.itemEntry:getValue("Name"))
	cp.getManager("ViewManager").setTextQuality(self.Text_MatiralName, self.itemEntry:getValue("Hierarchy"))
	self.Text_MatiralType:setString(CombatConst.ItemTypeName[self.itemEntry:getValue("Type")])
	if self.cost then
		self.Text_Cost:setTextColor(cc.c4b(254,245,202,255))
		self.Text_Cost:setString(self.cost.."積分")
	else
		self.Text_Cost:setTextColor(cc.c4b(255,0,0,255))
		self.Text_Cost:setString("已購買")
	end
	self.Text_Desc:setString(self.itemEntry:getValue("Tips"))
	self.Button_Buy:setVisible(true)
end

function SkillItemLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_Buy" then
		local req = {}
		req.item_id = self.itemEntry:getValue("ID")
        self:doSendSocket(cp.getConst("ProtoConst").BuyLotteryPointShopReq, req)
	elseif nodeName == "Button_View" then
		if (self.itemEntry:getValue("Type") == 2 and self.itemEntry:getValue("SubType") == 1) then
			local bookID = tonumber(string.split(self.itemEntry:getValue("Extra"), "=")[1])
			local bookEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", bookID)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", tonumber(bookEntry:getValue("Extra")))
			if skillEntry then
				local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
				self:addChild(layer, 100)
			end
		elseif (self.itemEntry:getValue("Type") == 4 and self.itemEntry:getValue("SubType") == 1) then
			local skillID = tonumber(self.itemEntry:getValue("Extra"))
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			if skillEntry then
				local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
				self:addChild(layer, 100)
			end
		else
			self.Button_Preview:setVisible(false)
		end
	end
end

function SkillItemLayer:onEnterScene()
end

function SkillItemLayer:onExitScene()
    self:unscheduleUpdate()
end

function SkillItemLayer:setBuyCallback(callback)
	self.buyCallback = callback
end

return SkillItemLayer