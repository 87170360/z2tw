local BNode = require "cp.view.ui.base.BNode"
local MajorRolePublic = class("MajorRolePublic",BNode)

function MajorRolePublic:create(openInfo)
	local node = MajorRolePublic.new(openInfo)
	return node
end

function MajorRolePublic:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "MajorRolePublic" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MajorRolePublic" then
				if evt.guide_name == "character" or evt.guide_name == "equip"  then
					if evt.target_name == "Panel_wuqi" then
						local itemInfo = self.CellInfo[1]
						local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
						if cur_step == 5 and evt.guide_name == "character" then
							if itemInfo.uuid ~= nil then --已裝備了武器，則直接跳轉到11步打開強化界面
								cp.getGameData("GameNewGuide"):setValue("cur_step",11)
							end
						end
						self:onCellItemClickCallBack(itemInfo)
					end
					
				end
			end
		end,
	}
end

function MajorRolePublic:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_role_public.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_public"] = {name = "Panel_public"},
		["Panel_public.Panel_wuqi"] = {name = "Panel_wuqi"},
		["Panel_public.Panel_shangyi"] = {name = "Panel_shangyi"},
		["Panel_public.Panel_xianglian"] = {name = "Panel_xianglian"},
		["Panel_public.Panel_huwan"] = {name = "Panel_huwan"},
		["Panel_public.Panel_shouzhuo"] = {name = "Panel_shouzhuo"},
		["Panel_public.Panel_yaodai"] = {name = "Panel_yaodai"},
		["Panel_public.Panel_jiezhi"] = {name = "Panel_jiezhi"},
		["Panel_public.Panel_xielv"] = {name = "Panel_xielv"},
		["Panel_public.Image_bg_chenghao.Image_chenghao"] = {name = "Image_chenghao"},
		["Panel_public.Button_jingjie"] = {name = "Button_jingjie",click = "onUIButtonClick"},
	
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	ccui.Helper:doLayout(self.rootView)

	self.Image_chenghao:loadTexture("img/icon/chenghao/chenghao_1.png",ccui.TextureResType.localType)
	self.EquipIcon = { 
		self["Panel_wuqi"],
		self["Panel_shangyi"],
		self["Panel_xianglian"],
		self["Panel_huwan"],
		self["Panel_shouzhuo"],
		self["Panel_yaodai"],
		self["Panel_jiezhi"],
		self["Panel_xielv"]
	}

	self.EquipDefaultName = { "武器", "上衣", "項鍊", "護腕", "手鐲", "腰帶", "戒指", "鞋履"}

	self:initScene()
end

function MajorRolePublic:autoAdjust()
	--log(display.height)

	if display.height > 1280 then
		local scale = display.height / 1280
		if math.abs(scale) - 1 > 0.1 then  
			for _, v in pairs(self.EquipIcon) do
				v:setPositionY(v:getPositionY() * scale)  
			end
		end
	else
		local diff = display.height - 1280 + self:specialDiff()
		if diff ~= 0 then
			for _, v in pairs(self.EquipIcon) do
				v:setPositionY(v:getPositionY() + diff)  
			end
		end
	end
end

function MajorRolePublic:specialDiff()
	height = display.height
	if height <= 960 then
		return 160
	end
	return 0
end

function MajorRolePublic:getWuqiPosY()
	return self["Panel_wuqi"]:getPositionY()
end

function MajorRolePublic:setJingjieClickCallBack(cb)
	self.onJingjieBtnClickCallBack = cb
end

function MajorRolePublic:onUIButtonClick(sender)
	local buttonName = sender:getName()
	if "Button_jingjie"  == buttonName then
		if self.onJingjieBtnClickCallBack ~= nil then
			self.onJingjieBtnClickCallBack(sender)
		end
	end
end

function MajorRolePublic:createEquipItems()
	for i, v in ipairs(self.EquipIcon) do
		local cellInfo = {id = nil, Name = self.EquipDefaultName[i], Icon = nil, num = 1, hideName = false}

		local item = require("cp.view.ui.icon.ItemIcon"):create(nil)
		item:setScale(1)
		item:setAnchorPoint(cc.p(0.5, 0.5))
		item:setPosition(cc.p(50, 50)) 
		item:setName("item" .. tostring(i))
		v:addChild(item, 1)
		item:setItemClickCallBack(handler(self,self.onCellItemClickCallBack))
		item:reset(cellInfo)

		if self.openInfo.type == "MajorRoleSelf" then
			--載入加號
			local imgPlus = ccui.ImageView:create("ui_common_add.png", ccui.TextureResType.plistType)
			imgPlus:setAnchorPoint(cc.p(0.5,0.5))
			imgPlus:setPosition(cc.p(50, 50)) 
			imgPlus:setScale(1)
			imgPlus:setName("imgPlus")
			v:addChild(imgPlus, 1)

			--載入提示點
			local imgTip = ccui.ImageView:create("ui_common_tishi_a.png", ccui.TextureResType.plistType)
			imgTip:setAnchorPoint(cc.p(0.5,0.5))
			imgTip:setPosition(cc.p(87, 86)) 
			imgTip:setScale(1)
			imgTip:setName("imgTip")
			v:addChild(imgTip, 1)
			imgTip:setVisible(false)
		end
	end
end

function MajorRolePublic:onItemUpdate()
	local roleItem = nil
	if self.openInfo.type == "MajorRoleSelf" then
		roleItem = {}
		local ids = cp.getUserData("UserItem"):getValue("role_equip_ids")
		for pos,uuid in pairs(ids) do
			if uuid then
				local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
				if itemInfo then
					table.insert(roleItem,itemInfo)
				end
			end
		end
	else
		roleItem = self.openInfo.equipList
	end

	self.CellInfo = {}
	for _, v in pairs(roleItem) do
		if  v.using == 1 then
			if v.Pos == nil then
				local equipconf = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
				-- local itemconf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
				v.Pos = equipconf:getValue("Pos")

			end
			if self.openInfo.type == "MajorRoleSelf" then
				self.CellInfo[v.Pos] = v
			else
				local itemconf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
				if itemconf ~= nil then
					v.Name = itemconf:getValue("Name")
					v.Icon = itemconf:getValue("Icon")
					v.Colour = itemconf:getValue("Hierarchy")
					v.Type = itemconf:getValue("Type") 
					v.hideName = false
				else
					log("onItemUpdate err itemconf nil", v.id)
				end
				self.CellInfo[v.Pos] = v
				
			end
		end
	end

	for i, v in ipairs(self.EquipIcon) do
		if self.CellInfo[i] == nil then
			self.CellInfo[i] = {Pos = i, id = nil, Name = self.EquipDefaultName[i], Icon = nil, num = 1, hideName = false}
		end

		local item = v:getChildByName("item" .. tostring(i))
		item:reset(self.CellInfo[i])	

		local imgPlus = v:getChildByName("imgPlus")
		if imgPlus ~= nil then
			local equips = cp.getManager("GDataManager"):pickEquip(i)
			imgPlus:setVisible((table.nums(equips) > 0) and (self.CellInfo[i].uuid == nil))
		end

		--顯示提示點
		local imgTip = v:getChildByName("imgTip")
		if imgTip ~= nil then
			imgTip:setVisible(false)
		end
		if self.CellInfo[i].uuid ~= nil and imgTip ~= nil then
			local showChangeTip = self:showChangeTip(self.CellInfo[i].id)
			local showUpdateTip = false
			local showInheritedTip = false
			if showChangeTip == false then
				local canStrengthen, canInherited, canMelt = self:showUpdateTip(self.CellInfo[i].uuid)
				showUpdateTip = canStrengthen or canInherited or canMelt
				showInheritedTip = canInherited
			end
			if showUpdateTip == true then
				if showInheritedTip == true then
					imgTip:loadTexture("ui_common_chuancheng.png", ccui.TextureResType.plistType)
				else
					imgTip:loadTexture("ui_common_tishi_a.png", ccui.TextureResType.plistType)
				end
			end

			if showChangeTip == true then
				imgTip:loadTexture("ui_common_tip_green.png", ccui.TextureResType.plistType)
			end

			imgTip:setVisible(showUpdateTip or showChangeTip)
		end
	end
end

--各位置可使用裝備存在情況
function MajorRolePublic:existEquip()
end

function MajorRolePublic:onEnterScene()
	log("MajorRolePublic:onEnterScene()")

	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "character" or cur_guide_module_name == "equip" then
		local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "equip" then
			if step >= 11 and step <= 19 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",11)
            end
        end

		local info = 
		{
			classname = "MajorRolePublic",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
	end
end

function MajorRolePublic:initScene()
	log("MajorRolePublic:initScene()")
	self:createEquipItems()
	self:onItemUpdate()
end


-- 直接關閉，使用，出售，傳承，強化，熔鍊，分解,合成
function MajorRolePublic:onItemTipClosedCallBack(closeType,itemInfo)
	if self.openInfo.type ~= "MajorRoleSelf" then
		return
	end

	if closeType == "Button_use" then
		local data = {uuid=itemInfo.uuid}
		self:doSendSocket(cp.getConst("ProtoConst").UseEquipReq,data)
	elseif closeType == "Button_chushou" then  --更換
		
		local info = 
		{
			itemInfo = itemInfo,
		}
		self:dispatchViewEvent( cp.getConst("EventConst").onEnterSelectTips, info )

	elseif closeType == "Button_qianghua" then
		if self.onEquipOperate then
			self.onEquipOperate(1,itemInfo)
		end
	elseif closeType == "Button_chuancheng" then
		if self.onEquipOperate then
			self.onEquipOperate(2,itemInfo)
		end
	elseif closeType == "Button_ronglian" then
		if self.onEquipOperate then
			self.onEquipOperate(3,itemInfo)
		end
	elseif closeType == "Button_close" then
		--不做任何處理
	end

end

function MajorRolePublic:setEquipOperateCallBack(cb)
	self.onEquipOperate = cb
end

function MajorRolePublic:onCellItemClickCallBack(itemInfo)

	--顯示換裝界面
	if itemInfo == nil or itemInfo.id == nil or itemInfo.uuid == nil then

		local v = self.EquipIcon[itemInfo.Pos]
		local imgPlus = v:getChildByName("imgPlus")
		local show = imgPlus:isVisible()

		if self.openInfo.type == "MajorRoleSelf" and show then
			local info = 
			{
				itemInfo = itemInfo,
			}
			self:dispatchViewEvent( cp.getConst("EventConst").onEnterSelectTips, info )
		end
	else
	--顯示物品提示
		itemInfo.openType = self.openInfo.type
		cp.getManager("ViewManager").showItemTip(itemInfo,handler(self,self.onItemTipClosedCallBack))
	end
	
end


function MajorRolePublic:reSetRoleItem(roleItem)
	if self.openInfo.type ~= "MajorRoleSelf" then
		return
	end
	self.openInfo.roleItem = roleItem
	
	--刷新界面
	self:onItemUpdate()
end

function MajorRolePublic:showChangeTip(id)
	local roleItem
	if self.openInfo.type == "MajorRoleSelf" then
		roleItem = self.openInfo.roleItem
	else
		return false
	end
	
	return cp.getManager("GDataManager"):canChange(id)
end

function MajorRolePublic:showUpdateTip(uuid)
	local canStrengthen, canInherited, canMelt = cp.getManager("GDataManager"):canUpdate(uuid)
	return canStrengthen , canInherited , canMelt
end


return MajorRolePublic
