local BNode = require "cp.view.ui.base.BNode"
local MaterialSelectList = class("MaterialSelectList",BNode)

function MaterialSelectList:create(openInfo)
	local node = MaterialSelectList.new(openInfo)
	return node
end

function MaterialSelectList:initListEvent()
	self.listListeners = {
		
	}
end



-- openInfo ={operateType = 1} width,height
function MaterialSelectList:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_equip_operate/uicsb_equip_material_list.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_material_select"] = {name = "Panel_material_select"},
		["Panel_material_select.Image_bg_title"] = {name = "Image_bg_title"},
		["Panel_material_select.Image_bg_material"] = {name = "Image_bg_material"},
		["Panel_material_select.Image_bg_material.Panel_content"] = {name = "Panel_content"},
		["Panel_material_select.Image_bg_material.Image_tips"] = {name = "Image_tips"},
		["Panel_material_select.Image_bg_material.Panel_mark"] = {name = "Panel_mark"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	self.Panel_mark:setVisible(false)

	self:changeOperateType(self.openInfo.operateType,self.openInfo.height)
	local sz = self.Panel_content:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width,sz.height))
	self.cellView:setCellSize(140,140)
	self.cellView:setColumnCount(4)
	self.cellView:setAnchorPoint(cc.p(0, 0)) -- 靠頂部對齊
	self.cellView:setPosition(cc.p(10, 0)) 
	self.cellView:setCountFunction(function()
		local material_list = cp.getUserData("UserEquipOperate"):getValue("material_list")
		return table.nums(material_list[self.openInfo.operateType])
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.Panel_content:addChild(self.cellView)
	self.offset = self.cellView:getContentOffset()

	self.Panel_material_select:setPosition(cc.p(0,0))
	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
end

function MaterialSelectList:onEnterScene()
end

function MaterialSelectList:changeOperateType(operateType,newHeight)
	self.openInfo.operateType = operateType

	self.Panel_material_select:setContentSize(cc.size(self.Panel_material_select:getContentSize().width,newHeight))
	self.Image_bg_title:setPositionY(newHeight- 6)
	self.Image_bg_material:setContentSize(cc.size(self.Image_bg_material:getContentSize().width,newHeight - 50))
	self.Panel_content:setContentSize(cc.size(self.Panel_content:getContentSize().width,newHeight - 50 - 35))
	self.Panel_mark:setContentSize(cc.size(self.Panel_mark:getContentSize().width,newHeight - 50 - 20))

	if self.cellView then
		local ScrollView = tolua.cast(self.cellView, "cc.ScrollView")
		local sz1 = self.Panel_content:getContentSize()
		ScrollView:setViewSize(cc.size(sz1.width,sz1.height))
		self.offset = nil
		self.cellView:reloadData()
	end

	ccui.Helper:doLayout(self["rootView"])
	
	self.Image_tips:setVisible(false)
	if self.openInfo.operateType == 2 then
		local material_list = cp.getUserData("UserEquipOperate"):getValue("material_list")
		if table.nums(material_list[self.openInfo.operateType]) == 0 then
			self.Image_tips:setVisible(true)
		end
	end
end


function MaterialSelectList:cellFactory(cellview, idx)
	local item = nil
	local cell = cellview:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
		item = require("cp.view.ui.icon.MaterialIcon"):create() 
		if item ~= nil then
			item:setAnchorPoint(cc.p(0,0))
			item:setPosition(cc.p(0,0))
			item:setName("item")
			item:setItemClickCallBack(handler(self,self.onItemSelected))
			cell:addChild(item)
		end
	else
		item = cell:getChildByName("item")
	end

	local material_list = cp.getUserData("UserEquipOperate"):getValue("material_list")
	local itemInfo = material_list[self.openInfo.operateType][idx]
	
	local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
	local idx =  table.indexof(select_item_list, itemInfo.uuid, 1)
	local isSelected = idx and true or false
	item:reset(itemInfo,isSelected)
	return cell
end
	
function MaterialSelectList:onItemSelected(item,itemInfo)
	dump(itemInfo.uuid)
	local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
	if self.openInfo.operateType == 1 then
		local idx =  table.indexof(select_item_list, itemInfo.uuid, 1)
		if idx then --已經存在
			table.remove(select_item_list, idx)
			item:setItemSelected(false)
		else

			local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
			local target_itemInfo = cp.getUserData("UserItem"):getItem(uuid)
			if target_itemInfo then
				local selectConf = cp.getManager("ConfigManager").getItemByKey("GameEquip", target_itemInfo.id)
				if target_itemInfo.PlayerHierarchy == nil then
					target_itemInfo.PlayerHierarchy = selectConf:getValue("PlayerHierarchy")
					target_itemInfo.PlayerHierarchy = target_itemInfo.PlayerHierarchy or 1
				end
			end
			local StrengthenMaxLevel = cp.getConst("GameConst").EquipStrengthenMaxLevel[target_itemInfo.PlayerHierarchy][target_itemInfo.Colour]
			if StrengthenMaxLevel == target_itemInfo.strengthenLevel then
				cp.getManager("ViewManager").gameTip("該物品已達最高強化等級！")
				return
			else

				local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
				if evaluate_result and evaluate_result.maxLevel <= evaluate_result.level then
					cp.getManager("ViewManager").gameTip("消耗裝備提供的強化經驗已達最大！")
					return
				end
				select_item_list[#select_item_list + 1] = itemInfo.uuid
				item:setItemSelected(true)
			end
		end
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",select_item_list)
	else
		local uuid = select_item_list[1]
		if uuid then --已經存在
			if uuid == itemInfo.uuid then
				select_item_list[1] = nil	
				item:setItemSelected(false)
			else
				--切換
				select_item_list[1] = itemInfo.uuid

				--需要重置上個物品的狀態,直接重新載入所有物品
				self.offset = self.cellView:getContentOffset()
				self:reloadItems()
				if self.offset then
					self.cellView:setContentOffset(self.offset,false)
				end
			end
			
		else --當前未選中任何材料
			select_item_list[1] = itemInfo.uuid
			item:setItemSelected(true)
		end
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",select_item_list)
	end
	self.offset = self.cellView:getContentOffset()

	if self.itemSelectedCallBack ~= nil then
		self.itemSelectedCallBack()
	end
	
end

function MaterialSelectList:setItemSelectedCallBack(cb)
	self.itemSelectedCallBack = cb
end

function MaterialSelectList:reloadItems()
	if self.cellView ~= nil then
		self.cellView:reloadData()
		if self.openInfo.operateType ~= 1 then
			if self.offset then
				self.cellView:setContentOffset(self.offset, false)
			end
		end
	end
	
end

function MaterialSelectList:setMarkVisible(isVisibled)
	self.Panel_mark:setVisible(isVisibled)
end

function MaterialSelectList:getContentSize()
	return self.Panel_material_select:getContentSize()
end

function MaterialSelectList:changeSize(newSize)
	self.Panel_material_select:setContentSize()
end

return MaterialSelectList
