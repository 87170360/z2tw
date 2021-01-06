local BLayer = require "cp.view.ui.base.BLayer"
local SkillMatiralLayer = class("SkillMatiralLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function SkillMatiralLayer:create(itemEntry)
	local scene = SkillMatiralLayer.new()
	scene.itemEntry = itemEntry
	scene:updateSkillMatiralView()
    return scene
end

function SkillMatiralLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		-- [cp.getConst("EventConst").GetAllSkillRsp] = function(data)
		-- end,
    }
end

--初始化界面，以及設定界面元素標籤
function SkillMatiralLayer:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_item_tips.csb")
	self.rootView:setPosition(cc.p(display.cx,display.cy))
	self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Node_icon"] = {name = "Node_icon"},
		
		["Panel_root.Button_preview"] = {name = "Button_Preview"},
		["Panel_root.Button_close"] = {name = "Button_close", click = "onBtnClick"},
		
		["Panel_root.Image_bg_type"] = {name = "Image_bg_type"},
		["Panel_root.Image_bg_type.Image_wuxue_type"] = {name = "Image_wuxue_type"}, --武學或武學碎片的分類(刀系,劍系...)

		["Panel_root.Image_price_type"] = {name = "Image_price_type"},
		["Panel_root.Image_bg_price"] = {name = "Image_bg_price"},

		
		["Panel_root.Text_price"] = {name = "Text_Price"},

		["Panel_root.Text_content"] = {name = "Text_Desc"},
		["Panel_root.Image_bg_content"] = {name = "Image_Desc"},

		["Panel_root.Text_name"] = {name = "Text_MatiralName" },
		["Panel_root.Text_type"] = {name = "Text_MatiralType"},

		["Panel_root.Image_Place"] = {name = "Image_Place" },
		["Panel_root.Image_Place.Text_Place"] = {name = "Text_Place" },

		
		["Panel_root.Button_Add"] = {name = "Button_Add", click = "onBtnClick"},
		["Panel_root.Button_Go"] = {name = "Button_Go", click = "onBtnClick"},

		["Panel_root.Button_chushou"] = {name = "Button_chushou"},
		["Panel_root.Button_fenjie"] = {name = "Button_fenjie"},
		["Panel_root.Button_hecheng"] = {name = "Button_hecheng"},
		["Panel_root.Button_use"] = {name = "Button_use"},
		["Panel_root.Button_study"] = {name = "Button_study"},
		["Panel_root.Button_xiulian"] = {name = "Button_xiulian"},
		["Panel_root.Button_buy"] = {name = "Button_buy"},

	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b, nil, function()
		self:removeFromParent()
	end)
	
	self.skillEntry = nil
	self.Button_Preview:setVisible(false)
	self.Button_chushou:setVisible(false)
	self.Button_fenjie:setVisible(false)
	self.Button_hecheng:setVisible(false)
	self.Button_use:setVisible(false)
	self.Button_study:setVisible(false)
	self.Button_xiulian:setVisible(false)
	self.Button_buy:setVisible(false)
	self.Image_bg_type:setVisible(false)

	self.Image_Place:setVisible(false)
	self.Button_Add:setVisible(false)
	self.Button_Go:setVisible(false)
	
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
    cp.getManager("ViewManager").popUpView(self.Panel_root)

end

function SkillMatiralLayer:updateSkillMatiralView()
	if (self.itemEntry:getValue("Type") == 2 and self.itemEntry:getValue("SubType") == 1) then
		self.Button_Preview:setVisible(true)
		cp.getManager("ViewManager").initButton(self.Button_Preview, function()
			local bookID = tonumber(string.split(self.itemEntry:getValue("Extra"), "=")[1])
			local bookEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", bookID)
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", tonumber(bookEntry:getValue("Extra")))
			if skillEntry then
				local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
				self:addChild(layer, 100)
				layer:setCloseCallback(function()
					self:updateSkillMatiralView(skillEntry)
				end)
			end
		end, 0.9)
	elseif (self.itemEntry:getValue("Type") == 4 and self.itemEntry:getValue("SubType") == 1) then
		self.Button_Preview:setVisible(true)
		cp.getManager("ViewManager").initButton(self.Button_Preview, function()
			local skillID = tonumber(self.itemEntry:getValue("Extra"))
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			if skillEntry then
				local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
				self:addChild(layer, 100)
				layer:setCloseCallback(function()
					self:updateSkillMatiralView(skillEntry)
				end)
			end
		end, 0.9)
	else
		self.Button_Preview:setVisible(false)
	end
	
	-- local imgIcon = self.Image_Matiral:getChildByName("Image_Icon")
	-- self.Image_Matiral:loadTexture(CombatConst.SkillBoxList[self.itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
	-- imgIcon:loadTexture(self.itemEntry:getValue("Icon"))

	local itemInfo = {id = self.itemEntry:getValue("ID")}
	itemInfo.Type = self.itemEntry:getValue("Type")
	itemInfo.SubType = self.itemEntry:getValue("SubType")
	itemInfo.Package = self.itemEntry:getValue("Package")
	itemInfo.Tips = self.itemEntry:getValue("Tips")
	itemInfo.Price = self.itemEntry:getValue("Price")
	itemInfo.Colour = self.itemEntry:getValue("Hierarchy")
	itemInfo.Package = math.max(itemInfo.Package,1)
	itemInfo.Package = math.min(itemInfo.Package,6)
    itemInfo.Price = math.max(itemInfo.Price,0)
    itemInfo.Extra = self.itemEntry:getValue("Extra") -- 對應的武學id
    if itemInfo.Name == nil then
        itemInfo.Name = self.itemEntry:getValue("Name")
    end
    if itemInfo.Icon == nil then
        itemInfo.Icon = self.itemEntry:getValue("Icon")
    end
	itemInfo.hideName = true
    local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
	if itemIcon ~= nil then
		self.Node_icon:addChild(itemIcon)
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setPosition(cc.p(0,0))
	end

	self.Text_MatiralName:setString(self.itemEntry:getValue("Name"))
	-- self.Text_MatiralName:setTextColor(CombatConst.SkillQualityColor4b[self.itemEntry:getValue("Hierarchy")])
	cp.getManager("ViewManager").setTextQuality(self.Text_MatiralName,itemInfo.Colour)
	self.Text_MatiralType:setString(CombatConst.ItemTypeName[self.itemEntry:getValue("Type")])
	self.Text_Price:setString("售價："..self.itemEntry:getValue("Price"))
	self.Text_Desc:setString(self.itemEntry:getValue("Tips"))
	local desc = cp.getUtils("DataUtils").formatGainWay(self.itemEntry:getValue("GainWay"))
	if desc[1] then
		self.Text_Place:setString(desc[1])
		cp.getManager("ViewManager").setEnabled(self.Button_Go, true)
	else
		self.Text_Place:setString("暫無獲取途徑")
		cp.getManager("ViewManager").setEnabled(self.Button_Go, false)
	end
	
	self.Button_Add:setVisible(false)
	self.Button_Go:setVisible(false)
	self.Image_Place:setVisible(false)
	--if (self.itemEntry:getValue("Type") == 6) then --材料才顯示來源
		self.Button_Go:setVisible(true)
		self.Image_Place:setVisible(true)
	--end

	local posx,_ = self.Text_MatiralName:getPosition()
	self.Image_bg_type:setPositionX(posx + self.Text_MatiralName:getContentSize().width + 30)
end

function SkillMatiralLayer:hidePlaceAndButtons()
	--[[
	self.Button_Add:setVisible(false)
	self.Button_Go:setVisible(false)
	self.Text_Place:setVisible(false)
	self.Image_Place:setVisible(false)
	self.Image_Desc:setContentSize(cc.size(571,190))
	]]
end

function SkillMatiralLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	elseif nodeName == "Button_Add" then
		-- self.useCallback(self.index)
		-- self:getParent():removeChild(self)
	elseif nodeName == "Button_Go" then
		local placeInfo = cp.getUtils("DataUtils").splitAttr(self.itemEntry:getValue("GainWay"))[1]
		if not placeInfo then
			return
		end

		if placeInfo[1] == 1 or placeInfo[1] == 2 then
			local difficulty = 0
			if placeInfo[1] == 2 then
				difficulty = 1
			end
			local function closeCallBack(retStr)
				cp.getManager("ViewManager").removeChallengeStory()
			end
			cp.getManager("ViewManager").showChallengeStory(1, placeInfo[2], difficulty,closeCallBack)
		elseif placeInfo[1] == 11 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu,auto_open_name = "MijingMainLayer"}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
		elseif placeInfo[1] == 3 then
			local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
			self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		elseif placeInfo[1] == 4 or placeInfo[1] == 5 or placeInfo[1] == 6 or placeInfo[1] == 7 or placeInfo[1] == 8 or placeInfo[1] == 9 then
			local storeID 
			if placeInfo[1] == 4 then
				storeID = 9
			elseif placeInfo[1] == 5 then
				storeID = 4
			elseif placeInfo[1] == 6 then
				storeID = 5
			elseif placeInfo[1] == 7 then
				storeID = 6
			elseif placeInfo[1] == 8 then
				storeID = 7
			elseif placeInfo[1] == 9 then
				storeID = 7
			else 
				return
			end
        	if self.ShopMainUI ~= nil then
            	self.ShopMainUI:removeFromParent()
        	end
        	self.ShopMainUI = nil
        
        	--local storeID = 6  --聲望商店
        	local openInfo = {storeID = storeID, closeCallBack = function()
            	self.ShopMainUI:removeFromParent()
            	self.ShopMainUI = nil
        	end}
        	local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
			ShopMainUI:setPosition(cc.p(-display.cx,-display.cy))
        	self.rootView:addChild(ShopMainUI)
			self.ShopMainUI = ShopMainUI
		else
			cp.getManager("ViewManager").gameTip("暫時無法前往")
		end
	end
end

function SkillMatiralLayer:onEnterScene()
end

function SkillMatiralLayer:onExitScene()
    self:unscheduleUpdate()
end

function SkillMatiralLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

return SkillMatiralLayer