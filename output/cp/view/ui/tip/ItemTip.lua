local BNode = require "cp.view.ui.base.BNode"
local ItemTip = class("ItemTip",BNode)
function ItemTip:create(itemInfo)
    local ret = ItemTip.new(itemInfo)
    return ret
end


function ItemTip:initListEvent()
    self.listListeners = {

		--新手指引獲取目標點位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "ItemTip" then
				if evt.guide_name == "lottery" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					--此步指引為向右的手指
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "ItemTip" then
				if evt.guide_name == "lottery" then
					self:onUIButtonClick(self[evt.target_name])
				end
			end
		end,
	}
end


function ItemTip:onInitView(itemInfo)
	self.itemInfo = itemInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_item_tips.csb")
	self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Node_icon"] = {name = "Node_icon"},
		
		["Panel_root.Button_preview"] = {name = "Button_preview",click = "onPreviewButtonClick"},
		["Panel_root.Button_close"] = {name = "Button_close", click = "onUIButtonClick"},
		
		["Panel_root.Image_bg_type"] = {name = "Image_bg_type"},
		["Panel_root.Image_bg_type.Image_wuxue_type"] = {name = "Image_wuxue_type"}, --武學或武學碎片的分類(刀系,劍系...)

		["Panel_root.Image_price_type"] = {name = "Image_price_type"},
		["Panel_root.Image_bg_price"] = {name = "Image_bg_price"},

		["Panel_root.Text_type"] = {name = "Text_type"},
		["Panel_root.Text_price"] = {name = "Text_price"},
        ["Panel_root.Text_content"] = {name = "Text_content"},
		["Panel_root.Text_name"] = {name = "Text_name" },

		["Panel_root.Image_Place"] = {name = "Image_Place" },
		["Panel_root.Image_Place.Text_Place"] = {name = "Text_Place" },

		["Panel_root.Button_chushou"] = {name = "Button_chushou", click = "onUIButtonClick"},
		["Panel_root.Button_fenjie"] = {name = "Button_fenjie", click = "onUIButtonClick"},
		["Panel_root.Button_hecheng"] = {name = "Button_hecheng", click = "onUIButtonClick"},
		["Panel_root.Button_use"] = {name = "Button_use", click = "onUIButtonClick"},
		["Panel_root.Button_study"] = {name = "Button_study", click = "onUIButtonClick"},
		["Panel_root.Button_xiulian"] = {name = "Button_xiulian", click = "onUIButtonClick"},
		["Panel_root.Button_buy"] = {name = "Button_buy", click = "onUIButtonClick"},
		["Panel_root.Button_Add"] = {name = "Button_Add", click = "onUIButtonClick"},
		["Panel_root.Button_Go"] = {name = "Button_Go", click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	-- cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
	-- 	if self.closedCallBack ~= nil then
	-- 		self.closedCallBack("Button_close",self.itemInfo)
	-- 	end
	-- end)

	self.Text_name:setString("")
	self.Text_type:setString("")
	self.Text_content:setString("")
	self.Text_price:setString("")

	self.skillEntry = nil
	self.Button_preview:setVisible(false)
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
	
	-- itemInfo.num = 1
	itemInfo.hideName = true
    local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
	if itemIcon ~= nil then
		self.Node_icon:addChild(itemIcon)
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setPosition(cc.p(0,0))
	end
	self.Text_name:setString(itemInfo.Name)
	cp.getManager("ViewManager").setTextQuality(self.Text_name,itemInfo.Colour)
	self.Text_name:enableOutline(cp.getConst("CombatConst").QualityOutlineC4b[itemInfo.Colour], 3)
	self.Text_name:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
	local szNew1 = self.Text_name:getVirtualRendererSize()
	self.Text_name:setContentSize(cc.size(szNew1.width,szNew1.height))


	self.Text_content:setString(itemInfo.Tips)
	self.Text_price:setString("售價：" .. tostring(itemInfo.Price))
	self.Text_price:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
	local szNew = self.Text_price:getVirtualRendererSize()
	self.Text_price:setContentSize(cc.size(szNew.width,szNew.height))
	local posx,_ = self.Text_price:getPosition()
	local newX = posx + self.Text_price:getContentSize().width/self.Text_price.clearScale
	self.Image_price_type:setPositionX(newX)
	
	local typeText = {"裝備", "武學", "材料", "道具", "碎片", "服飾"} 
	self.Text_type:setString(typeText[itemInfo.Package])
	
	
	local haveStudied = false
	if itemInfo.Package == 2 or (itemInfo.Package == 5 and itemInfo.SubType == 1) then--武學書或武學碎片
		self.Button_preview:setVisible(true)
		self.Image_bg_type:setVisible(true)
		local posx,_ = self.Text_name:getPosition()
		self.Image_bg_type:setPositionX(posx + self.Text_name:getContentSize().width/self.Text_name.clearScale + 30)

		local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
		local str = string.split(conf:getValue("Extra"),"=")
		if str ~= nil and tonumber(str[1]) ~= nil then
			local skillID = tonumber(str[1])
			if itemInfo.Package == 5 then  --碎片需要先找出合成後的物品，所學習後能獲得的技能
				local conf2 = cp.getManager("ConfigManager").getItemByKey("GameItem", skillID)
				local str2 = string.split(conf2:getValue("Extra"),"=")
				skillID = tonumber(str2[1])
			end
			local skillInfo = cp.getUserData("UserSkill"):getSkill(skillID)
			if skillInfo ~= nil then
				haveStudied = true
			end
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
			self.skillEntry = skillEntry
			local Serise = skillEntry:getValue("Serise")
			self.Image_wuxue_type:loadTexture(cp.getConst("CombatConst").SkillSerise_IconList[Serise], ccui.TextureResType.plistType)
		end
	end

	if itemInfo.Package == 5 and itemInfo.SubType == 4 then --裝備碎片或武器碎片
		self.Button_preview:setVisible(true)
		self.Button_preview:getChildByName("Text_1"):setString("裝備預覽")

		local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
		local str = string.split(conf:getValue("Extra"),"=")
		if str ~= nil and tonumber(str[1]) ~= nil then
			local equipID = tonumber(str[1])
			local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", equipID)
			itemInfo.Pos = conf2:getValue("Pos")
			if itemInfo.Pos == 1 then
				self.Button_preview:getChildByName("Text_1"):setString("武器預覽") 
			end
			self.equipEntry = conf2
		end
	
	end
	
	if itemInfo.Package == 4 or itemInfo.Package == 2 then
		self.Image_bg_price:setVisible(false)
		self.Image_price_type:setVisible(false)
		self.Text_price:setVisible(false)
	end

	if itemInfo.openType == "ViewShopItem" then
		self.Button_buy:setVisible(true)
		self.Image_bg_price:setVisible(false)
		self.Image_price_type:setVisible(false)
		self.Text_price:setVisible(false)
	else
		-- 裝備有其他的tips
		if itemInfo.Package == 2 then--武學書
			self.Button_fenjie:setVisible(true)
			self.Button_fenjie:setPositionX(180) 
			
			if haveStudied then
				self.Button_xiulian:setVisible(true)
				self.Button_xiulian:setPositionX(475)
			else
				self.Button_study:setVisible(true)
				self.Button_study:setPositionX(475)
			end

		elseif itemInfo.Package == 3 then -- 材料
			self.Button_chushou:setVisible(true)
			self.Button_chushou:setPositionX(328) -- 50%
		elseif itemInfo.Package == 4 then -- 道具
			-- self.Button_chushou:setVisible(true)
			-- self.Button_chushou:setPositionX(180) 
			self.Button_use:setVisible(true)
			self.Button_use:setPositionX(328) 
		elseif itemInfo.Package == 5 then --碎片
			--分武學碎片和其他碎片
			self.Button_chushou:setVisible(true)
			self.Button_hecheng:setVisible(true)
			self.Button_chushou:setPositionX(180) 
			self.Button_hecheng:setPositionX(475)
			if itemInfo.SubType == 1 then
				self.Button_fenjie:setVisible(true)
				self.Button_chushou:setPositionX(328) 
				self.Button_hecheng:setPositionX(534) 
				self.Button_fenjie:setPositionX(120)
			end
		elseif itemInfo.Package == 6 then  -- 服飾
			--暫無此類型
			self.Button_chushou:setVisible(true)
			self.Button_chushou:setPositionX(328)  -- 50%
		end
		
	end

	
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpView(self.Panel_root)
	
end

function ItemTip:onPreviewButtonClick(sender)
	log("Button_preview")
	if self.itemInfo.Package == 2 or (self.itemInfo.Package == 5 and self.itemInfo.SubType == 1) then
		if self.skillEntry then
			local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(self.skillEntry)
			self:addChild(layer, 100)
			layer:setPosition(cc.p(-display.cx,-display.cy))
		end
	elseif self.itemInfo.Package == 5 and self.itemInfo.SubType == 4 then
	
		local equipId = self.equipEntry:getValue("ItemID")
		local info = {id = equipId,openType = "ViewShopItem"}
		local layer = cp.getManager("ViewManager").showEquipPreview(info,closeCallBack)
		self:addChild(layer, 100)
		layer:setPosition(cc.p(0,0))

		if layer ~= nil then
			layer:setClosedCallBack(function (buttonName,Info,config)
				if "Button_buy" == buttonName then
					if self.closedCallBack ~= nil then
						self.closedCallBack(buttonName,self.itemInfo,nil)
					end
					layer:removeFromParent()
					cp.getManager("PopupManager"):removePopup(self)
				else
					layer:removeFromParent()
				end
			end)
		end
		
	end
end

function ItemTip:onUIButtonClick(sender)
	local name = sender:getName()
	if self.closedCallBack ~= nil then
		self.closedCallBack(name,self.itemInfo,self.skillEntry)
	end
	cp.getManager("PopupManager"):removePopup(self)
end

function ItemTip:setClosedCallBack(cb)
	self.closedCallBack = cb
end

function ItemTip:getTiperSize()
    return self.Panel_root:getContentSize()
end

function ItemTip:getDescription()
    return "ItemTip"
end

function ItemTip:onEnterScene()
	self:delayNewGuide()
end

function ItemTip:delayNewGuide()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "lottery" then
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		if cur_step >= 23 then
			local sequence = {}
			table.insert(sequence, cc.DelayTime:create(0.3))
			table.insert(sequence,cc.CallFunc:create(function()
				local info = 
				{
					classname = "ItemTip",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end))
			self:runAction(cc.Sequence:create(sequence))
		end
    end
end


return ItemTip