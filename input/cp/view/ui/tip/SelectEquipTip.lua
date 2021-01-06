local BNode = require "cp.view.ui.base.BNode"
local SelectEquipTip = class("SelectEquipTip",BNode)
function SelectEquipTip:create(selectInfo)
    local ret = SelectEquipTip.new(selectInfo)
    return ret
end


function SelectEquipTip:initListEvent()
	self.listListeners = {

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "SelectEquipTip" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					if evt.target_name == "weapon_1" then
						
						local posX,posY = self.Panel_equip:getPosition()
						local pos = self.Panel_equip:getParent():convertToWorldSpace(cc.p(posX+100/2+10,posY-100/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
						return
					elseif evt.target_name == "Button_confirm" then

						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					end
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "SelectEquipTip" then
				if evt.guide_name == "character" or evt.guide_name == "equip"  then
					if evt.target_name == "weapon_1" then
						local itemInfo = self.equips[1]
						self:onCellItemClick(itemInfo)
						local info = 
						{
							classname = "SelectEquipTip",
						}
						self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
					elseif evt.target_name == "Button_confirm" then
						self:onUIButtonClick(self[evt.target_name])
					end
					
				end
			end
		end
	}
end

function SelectEquipTip:onInitView(openInfo)
	self.selectInfo = openInfo
	--equip_type (1武器 ，   2上衣 ，    3項鍊 ，    4護腕 ，    5手鐲 ，    6腰帶 ，    7戒指 ，    8鞋履 )
	dump(self.selectInfo)

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_select_equip_tips.csb")
	self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Button_close"] = {name = "Button_close", click = "onUIButtonClick"},
		["Panel_root.Button_confirm"] = {name = "Button_confirm", click = "onUIButtonClick"},
		["Panel_root.Panel_equip"] = {name = "Panel_equip"},
		["Panel_root.Panel_public.Panel_base.Text_base_1"] = {name = "Text_base_1"},
		["Panel_root.Panel_public.Panel_base.Text_base_2"] = {name = "Text_base_2"},
		["Panel_root.Panel_public.Panel_base.Text_base_3"] = {name = "Text_base_3"},
		["Panel_root.Panel_public.Panel_base.Text_base_4"] = {name = "Text_base_4"},
		["Panel_root.Panel_public.Panel_base.Text_value_1"] = {name = "Text_value_1"},
		["Panel_root.Panel_public.Panel_base.Text_value_2"] = {name = "Text_value_2"},
		["Panel_root.Panel_public.Panel_base.Text_value_3"] = {name = "Text_value_3"},
		["Panel_root.Panel_public.Panel_base.Text_value_4"] = {name = "Text_value_4"},
		["Panel_root.Panel_public.Panel_base.Text_change_1"] = {name = "Text_change_1"},
		["Panel_root.Panel_public.Panel_base.Text_change_2"] = {name = "Text_change_2"},
		["Panel_root.Panel_public.Panel_base.Text_change_3"] = {name = "Text_change_3"},
		["Panel_root.Panel_public.Panel_base.Text_change_4"] = {name = "Text_change_4"},
		["Panel_root.Panel_public.Panel_base.Image_arrow_1"] = {name = "Image_arrow_1"},
		["Panel_root.Panel_public.Panel_base.Image_arrow_2"] = {name = "Image_arrow_2"},
		["Panel_root.Panel_public.Panel_base.Image_arrow_3"] = {name = "Image_arrow_3"},
		["Panel_root.Panel_public.Panel_base.Image_arrow_4"] = {name = "Image_arrow_4"},
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
		["Panel_root.Panel_extra_effect.Text_effect_1"] = {name = "Text_effect_1"},
		["Panel_root.Panel_extra_effect.Text_effect_2"] = {name = "Text_effect_2"},
		["Panel_root.Panel_extra_effect.Text_effect_3"] = {name = "Text_effect_3"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	self.equips = cp.getManager("GDataManager"):pickEquip(self.selectInfo.Pos)
	self:setItemView()
	self:defaultItemClick()

	cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
		if self.closedCallBack ~= nil then
			self.closedCallBack("Button_close",nil)
		end
	end)

	cp.getManager("ViewManager").popUpView(self.Panel_root)
end

--獲取物品基礎屬性
function SelectEquipTip:getItemBaseAtt(id)
	local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", id)
	if cfg == nil then
		return nil, nil
	end

	local att = {}
	string.loopSplit(cfg:getValue("Attribute"), ";=", att)
	return self:getAttTitle(att) 
end

--獲取物品附加屬性
function SelectEquipTip:getItemExtraAtt(uuid)
	local item = cp.getUserData("UserItem"):getItem(uuid)
	local att = {} 
	for _, v in pairs(item.attachAtt) do
		table.insert(att, {v.type, v.value})
	end
	return self:getAttTitle(att) 
end

--獲取屬性名稱+數值
function SelectEquipTip:getAttTitle(att)
	local title = {}
	local value = {}
	local typeValue = {}

	for i=1,table.nums(att) do
		local name_type = tonumber(att[i][1])
		if not (name_type >= 12 and name_type <= 16) then  --12 到 16 為各種武器精通,不算在基礎屬性裡
			local baseTitle = cp.getConst("CombatConst").AttributeList[name_type]
			local baseValue = att[i][2]
			table.insert(title, baseTitle)
			table.insert(value, baseValue)
			table.insert(typeValue, name_type)
		end
	end

	return title, value,typeValue
end

--設置基礎屬性
function SelectEquipTip:setBaseAtt()
	for i=1,4 do
		self["Text_base_" .. tostring(i)]:setVisible(false)
		self["Text_value_" .. tostring(i)]:setVisible(false)
		self["Text_change_" .. tostring(i)]:setVisible(false)
		self["Image_arrow_" .. tostring(i)]:setVisible(false)
		self["Text_change_" .. tostring(i)]:setString("(0)")
		self["Text_value_" .. tostring(i)]:setString("0")
	end

	--沒有使用中裝備，也沒有選擇裝備
	if self.selectInfo.uuid == nil and self.clickEquip == nil then
		for i=1,4 do
			self["Image_arrow_" .. tostring(i)]:loadTexture("ui_major_role_module11_rwsx_yueli_shangsheng.png", ccui.TextureResType.plistType)
			self["Text_base_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setVisible(true)
			self["Text_change_" .. tostring(i)]:setVisible(true)
			self["Image_arrow_" .. tostring(i)]:setVisible(true)
		end
	end

	--有使用中裝備, 沒有選擇裝備
	if self.selectInfo.uuid ~= nil and self.clickEquip == nil then
		local selectTitle, selectValue = self:getItemBaseAtt(self.selectInfo.id)
		for i=1, table.nums(selectTitle) do
			self["Text_base_" .. tostring(i)]:setString(selectTitle[i])
			self["Text_value_" .. tostring(i)]:setString(selectValue[i])
			self["Text_change_" .. tostring(i)]:setString("(0)")
			self["Text_base_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setVisible(true)
			self["Text_change_" .. tostring(i)]:setVisible(true)
			self["Image_arrow_" .. tostring(i)]:setVisible(true)
		end
	end

	--沒有使用中裝備, 有選擇裝備
	if self.selectInfo.uuid == nil and self.clickEquip ~= nil then
		--log("aaaaaaaaaaaaaaaaaaaaaaaaaaa!!!!!!!!!!!!")
		local clickTitle, clickValue = self:getItemBaseAtt(self.clickEquip.id)
		for i=1, table.nums(clickTitle) do
			self["Text_base_" .. tostring(i)]:setString(clickTitle[i])
			self["Text_change_" .. tostring(i)]:setString("(+" .. clickValue[i] .. ")")
			self["Text_change_" .. tostring(i)]:setTextColor(cc.c4b(107,213,82,255))
			self["Image_arrow_" .. tostring(i)]:loadTexture("ui_major_role_module11_rwsx_yueli_shangsheng.png", ccui.TextureResType.plistType)
			self["Text_base_" .. tostring(i)]:setVisible(true)
			self["Text_change_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setString(clickValue[i])
			self["Text_value_" .. tostring(i)]:setVisible(true)
			self["Image_arrow_" .. tostring(i)]:setVisible(true)
		end
	end
	
	--有使用中裝備, 有選擇裝備
	if self.selectInfo.uuid ~= nil and self.clickEquip ~= nil then
		local clickTitle, clickValue = self:getItemBaseAtt(self.clickEquip.id)
		local _, selectValue = self:getItemBaseAtt(self.selectInfo.id)
		if table.nums(clickValue) ~= table.nums(selectValue) then
			log("equip attribute num not equal.!!!!!!!!!!!!")
			return
		end
		for i=1, table.nums(clickTitle) do
			self["Text_base_" .. tostring(i)]:setString(clickTitle[i])
			self["Text_value_" .. tostring(i)]:setString(clickValue[i])
			local changeValue = tonumber(clickValue[i]) - tonumber(selectValue[i])
			local changeString = ""
			local changeColor
			local filename
			if changeValue >= 0 then
				changeString = "(+" .. changeValue .. ")"
				changeColor = cc.c4b(107,213,82,255)
				filename = "ui_major_role_module11_rwsx_yueli_shangsheng.png"
			else
				changeString = "(" .. changeValue .. ")"
				changeColor = cc.c4b(255,0,0,255)
				filename = "ui_major_role_module11_rwsx_yueli_xiajiang.png"
			end
			self["Text_change_" .. tostring(i)]:setString(changeString)
			self["Text_change_" .. tostring(i)]:setTextColor(changeColor)
			self["Image_arrow_" .. tostring(i)]:loadTexture(filename, ccui.TextureResType.plistType)
			self["Text_base_" .. tostring(i)]:setVisible(true)
			self["Text_change_" .. tostring(i)]:setVisible(true)
			self["Text_value_" .. tostring(i)]:setVisible(true)
			self["Image_arrow_" .. tostring(i)]:setVisible(true)
		end
	end
end

--設置額外屬性
function SelectEquipTip:setExtraAtt()
	for i=1,6 do
		self["Text_property_" .. tostring(i)]:setVisible(false)
		self["Text_property_value_" .. tostring(i)]:setVisible(false)
	end

	if self.clickEquip ~= nil then
		local title, value,typeValue = self:getItemExtraAtt(self.clickEquip.uuid)
		for i=1,#title do
			self["Text_property_" .. tostring(i)]:setString(title[i])
			self["Text_property_value_" .. tostring(i)]:setString(value[i])
			self["Text_property_" .. tostring(i)]:setVisible(true)
			self["Text_property_value_" .. tostring(i)]:setVisible(true)

			local colorText,colorOutline = cp.getManager("GDataManager"):getEquipAttachAttributeColor(self.clickEquip.id,typeValue[i],value[i])
			self["Text_property_value_" .. tostring(i)]:setTextColor(colorText)
			self["Text_property_value_" .. tostring(i)]:enableOutline(colorOutline, 2)
		end
	end
end

--設置特殊效果
function SelectEquipTip:setExtraEffect()
	for i=1,3 do
		self["Text_effect_" .. tostring(i)]:setVisible(false)
	end

	if self.clickEquip ~= nil then
		local beginIdx = 1
		if self.clickEquip.weaponAtt and next(self.clickEquip.weaponAtt) then --武器有附加效果屬性
			local effectText = ""
			if not (self.clickEquip.weaponAtt.type == 0 and self.clickEquip.weaponAtt.value == 0) then
				local title = cp.getConst("CombatConst").AttributeList[tonumber(self.clickEquip.weaponAtt.type)]
				if self.clickEquip.weaponAtt.type >= 12 and self.clickEquip.weaponAtt.type <= 16 then
					title = title .. "精通"
				end
				
				local value = self.clickEquip.weaponAtt.value
				if title and title ~= "" then
					if self.clickEquip.weaponAtt.type >= 50 then
						value = value / 100
						effectText = "裝備武器後" .. title .. "+" .. tostring(value) .. "%\n"
					else
						effectText = "裝備武器後" .. title .. "+" .. tostring(value) .."\n"
					end
				end
			end
			if effectText ~= "" then
				self["Text_effect_1"]:setString(effectText)
				self["Text_effect_1"]:setVisible(true)
				beginIdx = beginIdx + 1
			end
		end

		local idList = self.clickEquip.eventID
		if idList and next(idList) then
			for i=1,table.nums(idList) do
				local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", tonumber(idList[i]))
				if eventEntry and i <= 3 then
					local comment = eventEntry:getValue("Comment")
					if comment ~= "" then
						self["Text_effect_" .. tostring(beginIdx)]:setString(comment)
						self["Text_effect_" .. tostring(beginIdx)]:setVisible(true)
						beginIdx = beginIdx + 1
					end
				end
			end
		end
		if beginIdx == 1 then
			--沒有任何附加效果
			self["Text_effect_" .. tostring(beginIdx)]:setString("該裝備無附加效果")
			self["Text_effect_" .. tostring(beginIdx)]:setVisible(true)
		end
	end
end

--顯示裝備
function SelectEquipTip:setItemView()
	self.cellView = cp.getManager("ViewManager").createCellView(cc.size(600.00, 310.00))
	self.cellView:setCellSize(120, 150)
	self.cellView:setColumnCount(5)
	self.cellView:setCellCount(table.nums(self.equips))

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()       --刷新數據
	self.cellView:setAnchorPoint(cc.p(0, 0))
	self.cellView:setPosition(cc.p(10, 0))
	self["Panel_equip"]:addChild(self.cellView)
end

function SelectEquipTip:cellFactory(cellview, idx)
    local item = nil
    local cell = cellview:dequeueCell()
    local data = self:getData()[idx]

    if nil == cell then
		cell = cc.TableViewCell:new()
	
		item = require("cp.view.ui.icon.ItemIcon"):create(nil)
		item:setScale(1)
		local sz = item:getContentSize()
		item:setPosition(cc.p(sz.width/2, sz.height))
		item:setName("item")
		cell:addChild(item)
	
		item:setItemClickCallBack(handler(self,self.onCellItemClick))
    else
		item = cell:getChildByName("item")
		--item:refreshData(data)
    end

	item:setItemSelected(data.selected)
	item:reset(data)	

    return cell
end

function SelectEquipTip:reloadData()
	self.cellView:reloadData()
end

function SelectEquipTip:getData()
	return self.equips 
end


function SelectEquipTip:onCellItemClick(info)
	--log("ItemClick")
	self.clickEquip = info
	for i, _ in pairs(self.equips) do
		self.equips[i].selected = self.equips[i].uuid == info.uuid
	end
	self:updateUI()
end

function SelectEquipTip:defaultItemClick()
	self.clickEquip = self.equips[1]
	for i, _ in pairs(self.equips) do
		self.equips[i].selected = i == 1
	end
	self:updateUI()
end

function SelectEquipTip:updateUI()
	if self.cellView then
		local offset = self.cellView:getContentOffset()
		self:reloadData()
		self.cellView:setContentOffset(offset, false)
	end

	self:setBaseAtt()
	self:setExtraAtt()
	self:setExtraEffect()
end

function SelectEquipTip:onUIButtonClick(sender)
	local name = sender:getName()
	if self.closedCallBack ~= nil then
		self.closedCallBack(name,self.clickEquip)
	end
end

function SelectEquipTip:setClosedCallBack(cb)
	self.closedCallBack = cb
end

function SelectEquipTip:getTiperSize()
    return self.Panel_root:getContentSize()
end

function SelectEquipTip:getDescription()
    return "SelectEquipTip"
end

function SelectEquipTip:onEnterScene()
	
	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "character" or cur_guide_module_name == "equip" then
		
		local seq = cc.Sequence:create(
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(
				function()
					local info = 
					{
						classname = "SelectEquipTip",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end
			)
		)
		self:runAction(seq)
	end
end

return SelectEquipTip
