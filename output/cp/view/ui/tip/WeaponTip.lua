local BNode = require "cp.view.ui.base.BNode"
local WeaponTip = class("WeaponTip",BNode)
function WeaponTip:create(itemInfo)
    local ret = WeaponTip.new(itemInfo)
    return ret
end


function WeaponTip:initListEvent()
	self.listListeners = {

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "WeaponTip" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					-- if evt.target_name == "Button_qianghua" then

						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					-- end
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "WeaponTip" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					-- if evt.target_name == "Button_qianghua" then
						self:onUIButtonClick(self[evt.target_name])
					-- end
					
				end
			end
		end
	}
end


function WeaponTip:onInitView(itemInfo)
	self.itemInfo = itemInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_weapon_tips.csb")
	self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Node_icon"] = {name = "Node_icon"},
		["Panel_root.Image_jieshu.Text_jieshu"] = {name = "Text_jieshu"},
		["Panel_root.Panel_public"] = {name = "Panel_public"},
		
		["Panel_root.Panel_public.Image_price_type"] = {name = "Image_price_type"},
		["Panel_root.Panel_public.Text_content"] = {name = "Text_content"},
		["Panel_root.Panel_public.Text_name"] = {name = "Text_name"},
		["Panel_root.Panel_public.Text_price"] = {name = "Text_price"},
		["Panel_root.Panel_public.Text_zhanli"] = {name = "Text_zhanli"},
		["Panel_root.Panel_public.Text_weapon_type"] = {name = "Text_weapon_type"},

	    ["Panel_root.Panel_public.Panel_base.Text_base_1"] = {name = "Text_base_1"},
		["Panel_root.Panel_public.Panel_base.Text_base_2"] = {name = "Text_base_2"},
		["Panel_root.Panel_public.Panel_base.Text_base_3"] = {name = "Text_base_3"},
		["Panel_root.Panel_public.Panel_base.Text_base_4"] = {name = "Text_base_4"},
		["Panel_root.Panel_public.Panel_base.Text_value_1"] = {name = "Text_value_1"},
		["Panel_root.Panel_public.Panel_base.Text_value_2"] = {name = "Text_value_2"},
		["Panel_root.Panel_public.Panel_base.Text_value_3"] = {name = "Text_value_3"},
		["Panel_root.Panel_public.Panel_base.Text_value_4"] = {name = "Text_value_4"},

		["Panel_root.Panel_extra_property"] = {name = "Panel_extra_property"},
		["Panel_root.Panel_extra_property.Text_property_1"] = {name = "Text_property_1"},
		["Panel_root.Panel_extra_property.Text_property_2"] = {name = "Text_property_2"},
		["Panel_root.Panel_extra_property.Text_property_3"] = {name = "Text_property_3"},
		["Panel_root.Panel_extra_property.Text_property_4"] = {name = "Text_property_4"},
		["Panel_root.Panel_extra_property.Text_property_5"] = {name = "Text_property_5"},
		["Panel_root.Panel_extra_property.Text_property_6"] = {name = "Text_property_6"},
		["Panel_root.Panel_extra_property.Text_property_value_1"] = {name = "Text_property_value_1"},
		["Panel_root.Panel_extra_property.Text_property_value_2"] = {name = "Text_property_value_2"},
		["Panel_root.Panel_extra_property.Text_property_value_3"] = {name = "Text_property_value_3"},
		["Panel_root.Panel_extra_property.Text_property_value_4"] = {name = "Text_property_value_4"},
		["Panel_root.Panel_extra_property.Text_property_value_5"] = {name = "Text_property_value_5"},
		["Panel_root.Panel_extra_property.Text_property_value_6"] = {name = "Text_property_value_6"},

		["Panel_root.Panel_extra_effect"] = {name = "Panel_extra_effect"},
		["Panel_root.Panel_extra_effect.Text_effect"] = {name = "Text_effect"},

		["Panel_root.Button_close"] = {name = "Button_close", click = "onUIButtonClick"},
		["Panel_root.Button_chushou"] = {name = "Button_chushou", click = "onUIButtonClick"},
		["Panel_root.Button_qianghua"] = {name = "Button_qianghua", click = "onUIButtonClick"},
		["Panel_root.Button_chuancheng"] = {name = "Button_chuancheng", click = "onUIButtonClick"},
		["Panel_root.Button_ronglian"] = {name = "Button_ronglian", click = "onUIButtonClick"},
		["Panel_root.Button_use"] = {name = "Button_use", click = "onUIButtonClick"},

		["Panel_root.Button_chushou.Image_notice"] = {name = "Image_notice_chushou"},
		["Panel_root.Button_use.Image_notice"] = {name = "Image_notice_equip"},

		["Panel_root.Button_buy"] = {name = "Button_buy", click = "onUIButtonClick"},
		["Panel_root.Button_cancel"] = {name = "Button_cancel", click = "onUIButtonClick"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	-- cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
	-- 	if self.closedCallBack ~= nil then
	-- 		self.closedCallBack("Button_close",self.itemInfo)
	-- 	end
	-- end)

	self.Button_buy:setVisible(false)
	self.Button_cancel:setVisible(false)
	
	self["Text_name"]:setString("")
	self["Text_weapon_type"]:setString("")
	self["Text_content"]:setString("")
	self["Text_price"]:setString("")
	self["Text_zhanli"]:setString("")
	self["Text_jieshu"]:setString("")
	
	local needShowBtnBg = true
	if (self.itemInfo.openType == "ViewShopItem") then
		needShowBtnBg = false
	end
	for i=1,5 do
		self.Panel_root:getChildByName("Image_" .. tostring(i)):setVisible(needShowBtnBg)
	end

	if itemInfo == nil then
		return
	end

	if itemInfo.using == 1 then
		self["Button_chushou"]:loadTextures("ui_equip_tips_genghuan_a.png", "ui_equip_tips_genghuan_b.png", "ui_equip_tips_genghuan_b.png", ccui.TextureResType.plistType)
	end

	--itemInfo.num = 1
	itemInfo.hideName = true
	--[[
    local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
	if itemIcon ~= nil then
		self["Node_icon"]:addChild(itemIcon)
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setPosition(cc.p(0,0))
	end
	]]

	local weaponImg = ccui.ImageView:create(itemInfo.WeaponIcon, ccui.TextureResType.localType)
	self["Node_icon"]:addChild(weaponImg)

	self["Text_name"]:setString(itemInfo.Name)
	-- self.Text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[itemInfo.Colour])
	cp.getManager("ViewManager").setTextQuality(self.Text_name,itemInfo.Colour)

	self["Text_content"]:setString(itemInfo.Tips)
	self["Text_price"]:setString("售價:" .. tostring(itemInfo.Price))
		--self["Image_price_type"]:loadTexture("ui_common_yinliang.png",,ccui.TextureResType.plistType)  -- 出售都是銀兩
	
	--基礎屬性
	local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
	if cfg == nil then
		return
	end

	for i=1,4 do
		self["Text_base_" .. tostring(i)]:setVisible(false)
		self["Text_value_" .. tostring(i)]:setVisible(false)
	end

	local arrAttribute = {}
	if itemInfo.strengthenAtt ~= nil and next(itemInfo.strengthenAtt) ~= nil then
		arrAttribute = itemInfo.strengthenAtt
		table.sort(arrAttribute,function(a,b)
			return a.type < b.type
		end)
	else
		local Attribute = cfg:getValue("Attribute")
		local strArr = {}
		string.loopSplit(Attribute,";=",strArr)
		for i=1,table.nums(strArr) do
			table.insert(arrAttribute, {type = tonumber(strArr[i][1]), value= tonumber(strArr[i][2])})
		end
	end

	-- local typeList = {[0]="生命",[1]="內力",[2]="攻擊",[3]="防禦",[4]="命中",[5]="閃避",[6]="連擊",[7]="暴擊","招架","聚氣","修養","調息"}
	for i=1,table.nums(arrAttribute) do
		local type = arrAttribute[i].type
		if not (type >= 12 and type <= 16) then  --12 到 16 為各種武器精通,不算在基礎屬性裡
			local baseTitle = cp.getConst("CombatConst").AttributeList[type] .. ":"
			local baseValue = arrAttribute[i].value
			self["Text_base_" .. tostring(i)]:setString(baseTitle)
			self["Text_base_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setString(tostring(baseValue))
		end
	end

	--戰力
	local fight = (itemInfo.fight ~= nil) and tonumber(itemInfo.fight) or 0
	if (self.itemInfo.openType == "ViewShopItem") then
		fight = "購買後顯示"
	end
	self["Text_zhanli"]:setString("戰力:" .. tostring(fight))

	--附加屬性
	for i=1,6 do
		self["Text_property_" .. tostring(i)]:setVisible(false)
		self["Text_property_value_" .. tostring(i)]:setVisible(false)
	end
	local attachAtt = itemInfo.attachAtt or {}
	if attachAtt ~= nil and next(attachAtt) ~= nil and table.nums(attachAtt) > 0 then
		-- local function sortByType(a,b)
		-- 	return a.type < b.type
		-- end
		-- table.sort( attachAtt,sortByType)
		for i=1,table.nums(attachAtt) do
			local title = cp.getConst("CombatConst").AttributeList[tonumber(attachAtt[i].type)]
			title = title or "none"
			title = title .. ":"
			self["Text_property_" .. tostring(i)]:setString(title)
			self["Text_property_" .. tostring(i)]:setVisible(true)
			self["Text_property_value_" .. tostring(i)]:setVisible(true)
			self["Text_property_value_" .. tostring(i)]:setString(tostring(attachAtt[i].value))
			local colorText,colorOutline = cp.getManager("GDataManager"):getEquipAttachAttributeColor(itemInfo.id,attachAtt[i].type,attachAtt[i].value)
			self["Text_property_value_" .. tostring(i)]:setTextColor(colorText)
			self["Text_property_value_" .. tostring(i)]:enableOutline(colorOutline, 2)
		end
	else
		self["Text_property_value_3"]:setVisible(true)
		self["Text_property_value_3"]:setString((self.itemInfo.openType == "ViewShopItem") and "附加屬性在購買後隨機生成。" or "該裝備無附加屬性")
		self["Text_property_value_3"]:setPositionX((self.itemInfo.openType == "ViewShopItem") and 35 or 75)
	end

	--附加效果
	local idList = itemInfo.eventID
	local effectText = ""
	if itemInfo.weaponAtt and next(itemInfo.weaponAtt) then --武器有附加效果屬性
		if not (itemInfo.weaponAtt.type == 0 and itemInfo.weaponAtt.value == 0) then
			local title = cp.getConst("CombatConst").AttributeList[tonumber(itemInfo.weaponAtt.type)]
			if itemInfo.weaponAtt.type >= 12 and itemInfo.weaponAtt.type <= 16 then
				title = title .. "精通"
			end
			local value = itemInfo.weaponAtt.value
			if itemInfo.weaponAtt.type >= 50 then
				value = value / 100
				effectText = "裝備武器後" .. title .. "+" .. tostring(value) .. "%\n"
			else
				effectText = "裝備武器後" .. title .. "+" .. tostring(value) .."\n"
			end
		end
	end
	if idList and next(idList) then
		for i=1,table.nums(idList) do
			local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", tonumber(idList[i]))
			if eventEntry then
				local Comment = eventEntry:getValue("Comment")
				if Comment ~= "" then
					effectText = effectText .. Comment .. "\n" 
				end
			end
		end
	else
		if effectText == "" then
			effectText = (self.itemInfo.openType == "ViewShopItem") and "附加效果在購買後隨機生成。" or "該裝備無附加效果"
			self["Text_effect"]:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			self["Text_effect"]:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			self["Text_effect"]:setFontSize(24*self["Text_effect"].clearScale)
		end
	end
	self["Text_effect"]:setString(effectText)
	
	local typeText = {"刀","劍","雙刃","拳套","棍"} 
	self["Text_weapon_type"]:setString("武器-" .. typeText[itemInfo.SubType])

	self["Text_jieshu"]:setString(cp.getConst("CombatConst").NumberZh_Cn[itemInfo.PlayerHierarchy] .. "\n階")

	local textureName = {
		{"ui_equip_tips_xiexia_a.png","ui_equip_tips_xiexia_b.png","ui_equip_tips_xiexia_b.png"},
		{"ui_equip_tips_chuandai_a.png","ui_equip_tips_chuandai_b.png","ui_equip_tips_chuandai_b.png"}
	}
	if itemInfo.using == 1 then
		self.Button_use:loadTextures(textureName[1][1], textureName[1][2], textureName[1][3], ccui.TextureResType.plistType)
	else
		self.Button_use:loadTextures(textureName[2][1], textureName[2][2], textureName[2][3], ccui.TextureResType.plistType)
	end
	
	if self.itemInfo.openType == "MajorRoleOther" or self.itemInfo.openType == "ViewOtherItem" or self.itemInfo.openType == "ViewShopItem" then
		self["Button_chushou"] :setVisible(false)
		self["Button_qianghua"]:setVisible(false)
		self["Button_chuancheng"]:setVisible(false)
		self["Button_ronglian"]:setVisible(false)
		self["Button_use"]:setVisible(false)
		if self.itemInfo.openType == "ViewShopItem" then
			self.Button_buy:setVisible(true)
			self.Button_cancel:setVisible(true)
		end
	else
		--tip point
		local canStrengthen, canInherited, canMelt = cp.getManager("GDataManager"):canUpdate(self.itemInfo.uuid)
		if canStrengthen then
			self:addImg(self["Button_qianghua"], "ui_common_tishi_a.png")
		end
		if canInherited then
			self:addImg(self["Button_chuancheng"], "ui_common_chuancheng.png")
		end
		if canMelt then
			self:addImg(self["Button_ronglian"], "ui_common_tishi_a.png")
		end
		local canChange = cp.getManager("GDataManager"):canChange(self.itemInfo.id)
		if canChange then
			self:addImg(self["Button_chushou"], "ui_common_tip_green.png")
		end
	end
end

function WeaponTip:addImg(node, imgname)
	local imgTip = ccui.ImageView:create(imgname, ccui.TextureResType.plistType)
	imgTip:setAnchorPoint(cc.p(0.5,0.5))
	imgTip:setPosition(cc.p(99, 83)) 
	imgTip:setScale(1)
	--imgTip:setName("imgTip")
	imgTip:setVisible(true)
	node:addChild(imgTip, 1)
end

function WeaponTip:onUIButtonClick(sender)
	local name = sender:getName()
	if self.closedCallBack ~= nil then
		self.closedCallBack(name,self.itemInfo)
	end
	cp.getManager("PopupManager"):removePopup(self)
end

function WeaponTip:setClosedCallBack(cb)
	self.closedCallBack = cb
end

function WeaponTip:getTiperSize()
    return self.Panel_root:getContentSize()
end

function WeaponTip:getDescription()
    return "WeaponTip"
end


function WeaponTip:onEnterScene()
	
	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "character" or cur_guide_module_name == "equip" then
		
		local seq = cc.Sequence:create(
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(
				function()
					local info = 
					{
						classname = "WeaponTip",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end
			)
		)
		self:runAction(seq)
	end
end

return WeaponTip
