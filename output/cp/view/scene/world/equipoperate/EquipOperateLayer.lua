local BLayer = require "cp.view.ui.base.BLayer"
local EquipOperateLayer = class("EquipOperateLayer",BLayer)

function EquipOperateLayer:create(openInfo)
	local layer = EquipOperateLayer.new(openInfo)
	return layer
end

function EquipOperateLayer:initListEvent()
	self.listListeners = {
		--一鍵選擇強化材料
		[cp.getConst("EventConst").EquipStrengthenQuickSelectRsp] = function(evt)
			--重新評估
			self:onMaterialItemSelected()
			if self.MaterialSelectList then
				self.MaterialSelectList:reloadItems()
			end
		end,

		--強化評估
		[cp.getConst("EventConst").EquipStrengthenEvaluateRsp] = function(evt)
			self:onEquipStrengthenEvaluate(evt)
		end,

		--確認強化結果返回 
		[cp.getConst("EventConst").EquipStrengthenRsp] = function(evt)
			self:onEquipStrengthenResult(evt)
		end,

		--傳承結果返回
		[cp.getConst("EventConst").EquipInheritedRsp] = function(evt)
			self:onEquipInheritedResult(evt)
		end,

		--裝備熔鍊返回
		[cp.getConst("EventConst").EquipMeltRsp] = function(evt)
			self:onEquipMeltResult(evt)
		end,

		--新手指引獲取按鈕位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "EquipOperateLayer" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					if evt.target_name == "material_1" then
						
						local posX,posY = self.MaterialSelectList:getPosition()
						local sz = self.MaterialSelectList:getContentSize()
						local pos = self.MaterialSelectList:getParent():convertToWorldSpace(cc.p(posX+100/2+40,posY + sz.height-100/2 - 70)) -- 70為材料禮包的標題高度
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
						return
					elseif evt.target_name == "Button_confirm" or evt.target_name == "Button_close" or evt.target_name == "Image_ronglian" then

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
			if evt.classname == "EquipOperateLayer" then
				if evt.guide_name == "character" or evt.guide_name == "equip" then
					if evt.target_name == "Button_confirm" or evt.target_name == "Button_close" then
						self:onUIButtonClick(self[evt.target_name])
					elseif evt.target_name == "Image_ronglian" then
						self:onTabItemClick(self[evt.target_name])
					end
					
				end
			end
		end
		
	}
end

-- openInfo = {type = 1}
function EquipOperateLayer:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_equip_operate/uicsb_equip_operate_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_chuancheng"] = {name = "Image_chuancheng",click = "onTabItemClick",clickScale=1},
		["Panel_root.Image_ronglian"] = {name = "Image_ronglian",click = "onTabItemClick",clickScale=1},
		["Panel_root.Image_qianghua"] = {name = "Image_qianghua",click = "onTabItemClick",clickScale=1},

		["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},		
		["Panel_root.Panel_bg.Button_quick_select"] = {name = "Button_quick_select",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Button_confirm"] = {name = "Button_confirm",click = "onUIButtonClick"},

		["Panel_root.Panel_bg.Image_bg_price"] = {name = "Image_bg_price"},
		["Panel_root.Panel_bg.Image_bg_price.Text_price"] = {name = "Text_price"},
		["Panel_root.Panel_bg.Image_bg_price.Image_price_type"] = {name = "Image_price_type"},

		["Panel_root.Panel_bg.Panel_public"] = {name = "Panel_public"},
		["Panel_root.Panel_bg.Panel_public.Image_bg_content"] = {name = "Image_bg_content"},

		["Panel_root.Panel_bg.Panel_public.Panel_qianghua"] = {name = "Panel_qianghua"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Image_progress_1"] = {name = "Image_progress_1"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Image_progress_2"] = {name = "Image_progress_2"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Image_item_mark"] = {name = "Image_item_mark"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Node_item"] = {name = "Node_item"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Text_value_1"] = {name = "Text_value_1"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Text_value_2"] = {name = "Text_value_2"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Text_level"] = {name = "Text_level"},
		["Panel_root.Panel_bg.Panel_public.Panel_qianghua.Text_max_level"] = {name = "Text_max_level"},

		["Panel_root.Panel_bg.Panel_public.Panel_cc_rl"] = {name = "Panel_cc_rl"},
		["Panel_root.Panel_bg.Panel_public.Panel_cc_rl.Node_item_1"] = {name = "Node_item_1"},
		["Panel_root.Panel_bg.Panel_public.Panel_cc_rl.Node_item_2"] = {name = "Node_item_2"},
		["Panel_root.Panel_bg.Panel_public.Panel_cc_rl.Image_item_mark_1"] = {name = "Image_item_mark_1"},
		["Panel_root.Panel_bg.Panel_public.Panel_cc_rl.Image_mark_all"] = {name = "Image_mark_all"},

	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	local openInfo1 ={operateType = 1}
	local EquipPropertyList = require("cp.view.scene.world.equipoperate.EquipPropertyList"):create(openInfo1)
	self.Panel_bg:addChild(EquipPropertyList)
	self.EquipPropertyList = EquipPropertyList
	
	--調整分辨率適配
	self.rootView:setContentSize(display.size)

	local newHeight = display.height
	if newHeight > 1100 then
		newHeight = newHeight - 200
	else
		newHeight = newHeight - 10
	end
	self.Panel_root:setContentSize(cc.size(display.width,newHeight))
	self.Image_chuancheng:setPositionY(newHeight/2)
	self.Image_qianghua:setPositionY(newHeight/2 + 215)
	self.Image_ronglian:setPositionY(newHeight/2 - 215)
	self.Panel_public:setPositionY(newHeight - 18)
	self.Button_close:setPositionY(newHeight - 40)

	self.EquipPropertyList:setPosition(cc.p(72, self.Panel_public:getPositionY() - self.Panel_public:getContentSize().height))

	cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b)
	ccui.Helper:doLayout(self["rootView"])

	local h = self:generageMaterialSelectListHeight()
	local openInfo2 = {operateType = 1,height = h}
	local MaterialSelectList = require("cp.view.scene.world.equipoperate.MaterialSelectList"):create(openInfo2)
	self.Panel_bg:addChild(MaterialSelectList)
	MaterialSelectList:setItemSelectedCallBack(handler(self,self.onMaterialItemSelected))
	self.MaterialSelectList = MaterialSelectList
	self.MaterialSelectList:setPosition(cc.p(40,100))


	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

end

function EquipOperateLayer:generageMaterialSelectListHeight()

	local height = self.Panel_public:getPositionY() - self.Panel_public:getContentSize().height
	height = height - self.EquipPropertyList:getContentSize().height - self.Button_confirm:getContentSize().height - 40
	return height
end

function EquipOperateLayer:onEnterScene()
	self.tabItems = {self["Image_qianghua"],self["Image_chuancheng"],self["Image_ronglian"]}
	local type = self.openInfo.type or 1

	local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
	if uuid == nil or uuid == "" then
		return
	end

	cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})

	cp.getUserData("UserEquipOperate"):refreshAllMaterialItems()

	self:onTabItemClick(self.tabItems[type])

	
	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "character" or cur_guide_module_name == "equip" then

		local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "equip" then
			if step >= 19 and step <= 25 then  --進入熔鍊階段
                cp.getGameData("GameNewGuide"):setValue("cur_step",22)
            end
		end
		
		local seq = cc.Sequence:create(
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(
				function()
					local info = 
					{
						classname = "EquipOperateLayer",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end
			)
		)
		self:runAction(seq)
	end
end

function EquipOperateLayer:onExitScene()
	cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})
	cp.getUserData("UserEquipOperate"):setValue("evaluate_result",nil)
	if self["var_schedule_exp"] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self["var_schedule_exp"])
	end
	self["var_schedule_exp"] = nil
end

function EquipOperateLayer:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log("click button : " .. buttonName)
	if "Button_quick_select"  == buttonName then
		if self.tabIndex == 1 then 
			local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
			local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
			if itemInfo == nil then
				log("物品數據出錯，uuid = " .. uuid)
				return
			end
			if itemInfo.PlayerHierarchy  == nil then
				local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
				if cfg ~= nil then
					itemInfo.PlayerHierarchy = cfg:getValue("PlayerHierarchy")
					itemInfo.PlayerHierarchy = itemInfo.PlayerHierarchy or 1
				end
			end
			local StrengthenMaxLevel = cp.getConst("GameConst").EquipStrengthenMaxLevel[itemInfo.PlayerHierarchy][itemInfo.Colour]
			if StrengthenMaxLevel == itemInfo.strengthenLevel then
				cp.getManager("ViewManager").gameTip("該物品已達最高強化等級！")
				return
			end

			local material_list = cp.getUserData("UserEquipOperate"):getValue("material_list")
			local itemInfoList = material_list[1]
			local materialUID = {}
			for i=1,#itemInfoList do
				materialUID[i] = itemInfoList[i].uuid
			end
			local req = {targetUID = uuid, materialUID = materialUID}
			self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenQuickSelectReq,req)
		end
	elseif "Button_confirm"  == buttonName then
		local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
		local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
		if itemInfo == nil then
			log("物品數據出錯，uuid = " .. uuid)
			return
		end
		local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
		if table.nums(select_item_list) <= 0 then
			cp.getManager("ViewManager").gameTip("請選擇一個消耗裝備!")
			return
		end

		if self.tabIndex == 3 then
			--熔鍊需判斷附加屬性的位置
			local select_property_pos = cp.getUserData("UserEquipOperate"):getValue("select_property_pos") -- 附加屬性位置(0,1,2,3,4,5)
			if select_property_pos == -1 then
				cp.getManager("ViewManager").gameTip("請選擇熔鍊覆蓋屬性!")
				return
			end
		end

		local money_need = cp.getUserData("UserEquipOperate"):getValue("money_need")
		local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
		if money_need > majorRole.silver then
			local contentTable = {
                {type="ttf", fontSize=24, text="您的銀兩不足，是否前往招財界面兌換銀兩？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            }
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
				--打開招財界面
				cp.getManager("ViewManager").showSilverConvertUI()
			end,nil)
			return
		end

		if self.tabIndex == 1 then

			for i=1,table.nums(select_item_list) do
				local item_select = cp.getUserData("UserItem"):getItem(select_item_list[i])
				local conf2 = cp.getManager("ConfigManager").getItemByKey("GameItem", item_select.id)
				local Colour2 = conf2:getValue("Hierarchy")
				if Colour2 >= 6 then -- 只提示紅色
					local contentTable = {
						{type="ttf", fontSize=24, text="消耗品中包含", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
						{type="ttf", fontSize=24, text="紅色品質", textColor=cc.c4b(255,0,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
						{type="ttf", fontSize=24, text="裝備,是否繼續操作？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
					}
					cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
						
						local req = {targetUID = uuid, materialUID = select_item_list}
						self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenReq,req)
					end,nil)
					return
				end
			end
			
			local req = {targetUID = uuid, materialUID = select_item_list}
			self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenReq,req)
			
		elseif self.tabIndex == 2 then
			
			local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
			local Colour1 = conf:getValue("Hierarchy")

			local item_select = cp.getUserData("UserItem"):getItem(select_item_list[1])
			log("confirm select_item_list[1] = " .. tostring(select_item_list[1]))
			dump(item_select)
			local conf2 = cp.getManager("ConfigManager").getItemByKey("GameItem", item_select.id)
			local Colour2 = conf2:getValue("Hierarchy")
			if Colour2 > Colour1 then
				local contentTable = {
					{type="ttf", fontSize=24, text="你選擇的傳承消耗裝備", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
					{type="ttf", fontSize=24, text="品質高於", textColor=cc.c4b(255,0,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
					{type="ttf", fontSize=24, text="目標裝備，是否確認傳承？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
				}
				cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
					
					local req = {targetUID = uuid, materialUID = select_item_list[1]}
					self:doSendSocket(cp.getConst("ProtoConst").EquipInheritedReq,req)
				end,nil)
				return
			else
				
				local req = {targetUID = uuid, materialUID = select_item_list[1]}
				self:doSendSocket(cp.getConst("ProtoConst").EquipInheritedReq,req)
			end
			

		elseif self.tabIndex == 3 then
			--熔鍊需判斷附加屬性的位置
			local select_property_pos = cp.getUserData("UserEquipOperate"):getValue("select_property_pos") -- 附加屬性位置(0,1,2,3,4,5)
			
			--判斷物品是否有強化等級
			local itemInfo = cp.getUserData("UserItem"):getItem(select_item_list[1])
			if itemInfo.strengthenLevel > 0 then
				local contentTable = {
					{type="ttf", fontSize=24, text="你選擇的熔鍊消耗裝備", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
					{type="ttf", fontSize=24, text="具備強化等級，", textColor=cc.c4b(255,0,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
					{type="ttf", fontSize=24, text="是否繼續熔鍊？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
				}
				cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
					
					local req = {targetUID = uuid, materialUID = select_item_list[1],pos = select_property_pos}
					self:doSendSocket(cp.getConst("ProtoConst").EquipMeltReq,req)
				end,nil)
				return
			else
				
				local req = {targetUID = uuid, materialUID = select_item_list[1],pos = select_property_pos}
				self:doSendSocket(cp.getConst("ProtoConst").EquipMeltReq,req)
			end
			cp.getManager("GDataManager"):setFightDelay(true)
		end
		self.MaterialSelectList:setMarkVisible(true)
	elseif "Button_close"  == buttonName then
		if self.closeCallBack then
			local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
			self.closeCallBack(uuid)
			cp.getUserData("UserEquipOperate"):setValue("target_item_uuid","")
		end
		
		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		if (cur_guide_module_name == "character" and cur_step == 18) or --強化完成後關閉界面
			(cur_guide_module_name == "equip" and cur_step == 29) then
			local info = 
			{
				classname = "EquipOperateLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info)
		end
		cp.getManager("PopupManager"):removePopup(self)
	end
end

function EquipOperateLayer:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function EquipOperateLayer:switchTo(index)
	local tab = {self.Image_qianghua,self.Image_chuancheng,self.Image_ronglian}
	self:onTabItemClick(tab[index])
end

function EquipOperateLayer:onTabItemClick(sender)
	local buttonName = sender:getName()
	local oldTab = self.tabIndex
	if "Image_qianghua"  == buttonName then
		self.tabIndex = 1
	elseif "Image_chuancheng"  == buttonName then
		self.tabIndex = 2
	elseif "Image_ronglian"  == buttonName then
		self.tabIndex = 3
	end
	if oldTab == self.tabIndex then
		return
	end
	local needSetTargetItem = true
	if oldTab ~= nil and oldTab ~= self.tabIndex then --與上一次的不同
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})
		if self.tabIndex == 1 then
			needSetTargetItem = self:resetToNoMaterials()
		else 
			cp.getUserData("UserEquipOperate"):setValue("select_property_pos",-1)
			self:onMaterialItemSelected()
		end
	end

	self:onOperateTypeChange()
	self:refreshMaterialList()
	if needSetTargetItem then
		self:initTargetItem()
	end
	
	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "equip" then
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		if cur_step == 22  then --熔鍊選擇材料
			local info = 
			{
				classname = "EquipOperateLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
	end
end


function EquipOperateLayer:onOperateTypeChange()

	--確定按鈕的圖片
	local confirmImagelist = {
		{"ui_equip_operate_qianghua02_b.png","ui_equip_operate_qianghua02_a.png"},
		{"ui_equip_operate_chuancheng02_a.png","ui_equip_operate_chuancheng02_b.png"},
		{"ui_equip_operate_ronglian02_a.png","ui_equip_operate_ronglian02_b.png"}
	}
	
	--左邊tab按鈕的圖片
	local imagelist = {
		{"ui_equip_operate_module13_qianghuadeng_qianghua_a.png","ui_equip_operate_module13_qianghuadeng_qianghua_b.png"},
		{"ui_equip_operate_module13_qianghuadeng_chuancheng_a.png","ui_equip_operate_module13_qianghuadeng_chuancheng_b.png"},
		{"ui_equip_operate_module13_qianghuadeng_ronglian_a.png","ui_equip_operate_module13_qianghuadeng_ronglian_b.png"}
	}

	local bgImage = {"ui_equip_operate_module13_qianghuadeng_qianghuawen.png","ui_equip_operate_module13_qianghuadeng_chuanchengwen.png","ui_equip_operate_module13_qianghuadeng_ronglianwen.png"}
	local bgImagePos = {cc.p(283,263), cc.p(286,295), cc.p(286,266)}
	self.Panel_bg:setLocalZOrder(1)
	for i=1,table.nums(self.tabItems) do
		if self.tabIndex == i then
			self.tabItems[i]:setLocalZOrder(2)
			self.tabItems[i]:loadTexture(imagelist[i][1], ccui.TextureResType.plistType)
			--self.Button_confirm:loadTextures(confirmImagelist[i][1],confirmImagelist[i][2],confirmImagelist[i][2],ccui.TextureResType.plistType)
			self.Image_bg_content:loadTexture(bgImage[i], ccui.TextureResType.plistType)		
			self.Image_bg_content:ignoreContentAdaptWithSize(true)
			self.Image_bg_content:setPosition(bgImagePos[i])	
		else
			self.tabItems[i]:setLocalZOrder(1)
			self.tabItems[i]:loadTexture(imagelist[i][2], ccui.TextureResType.plistType)
		end
		self.tabItems[i]:ignoreContentAdaptWithSize(true)
	end


	self.Panel_qianghua:setVisible(self.tabIndex == 1)
	self.Panel_cc_rl:setVisible(self.tabIndex ~= 1)
	self.Button_quick_select:setVisible(self.tabIndex == 1)

	local h = self:generageMaterialSelectListHeight()
	self.MaterialSelectList:changeOperateType(self.tabIndex,h)
	self.EquipPropertyList:changeOperateType(self.tabIndex)
	
	local y = self.Panel_public:getPositionY() - self.Panel_public:getContentSize().height
	y = self.tabIndex == 1 and y - 40 or y + 20
	self.EquipPropertyList:setPositionY(y)
	

	ccui.Helper:doLayout(self["Panel_root"])
end

function EquipOperateLayer:getTargetItemInfo()

	local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
	if uuid == nil or uuid == "" then
		return nil
	end
	local info = cp.getUserData("UserItem"):getItem(uuid)
	local itemInfo = clone(info)
	local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
	if cfg == nil then
		return nil
	end
	local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
	if conf == nil then
		return nil
	end

	if itemInfo.Pos == nil then
		itemInfo.Pos = cfg:getValue("Pos")
	end
	if itemInfo.PlayerHierarchy == nil then
		itemInfo.PlayerHierarchy = cfg:getValue("PlayerHierarchy")
		itemInfo.PlayerHierarchy = itemInfo.PlayerHierarchy or 1
	end
	
    itemInfo.Name = conf:getValue("Name")
    itemInfo.Icon = conf:getValue("Icon")
	itemInfo.Type = conf:getValue("Type")
	itemInfo.SubType = conf:getValue("SubType")
	itemInfo.Package = conf:getValue("Package")
	itemInfo.Colour = conf:getValue("Hierarchy")
	itemInfo.showNum = false
	return itemInfo
end

function EquipOperateLayer:initTargetItem()
	local itemInfo = self:getTargetItemInfo()
	
	if itemInfo == nil then
		return
	end
	
	--設置裝備屬性數據
	if self.tabIndex == 1 then -- 強化
		self:resetQianghuaInfo(itemInfo)
	elseif self.tabIndex == 2 or self.tabIndex == 3 then -- 傳承/熔鍊
		self:resetChuanChengRongLian(itemInfo)
	end

end


function EquipOperateLayer:resetChuanChengRongLian(itemInfo)
	itemInfo.hideName = false
	self.Image_item_mark_1:setVisible(true)
	self.Image_mark_all:setVisible(false)

	--消耗
	local needCoin = 0
	-- if self.tabIndex == 2 then
	-- 	needCoin = itemInfo.Colour * 1000 + itemInfo.strengthenLevel * 500
	-- elseif self.tabIndex == 3 then
	-- 	needCoin = itemInfo.Colour * 500 + itemInfo.PlayerHierarchy * 500
	-- end
	self.Text_price:setString(tostring(needCoin))
	cp.getUserData("UserEquipOperate"):setValue("money_need",needCoin)

	local itemIcon_1 = self.Node_item_1:getChildByName("itemIcon_1")
	if itemIcon_1 == nil then
		itemIcon_1 = require("cp.view.ui.icon.ItemIcon"):create(nil)
		self["Node_item_1"]:addChild(itemIcon_1)
		itemIcon_1:setAnchorPoint(cc.p(0.5,0.5))
		itemIcon_1:setPosition(cc.p(0,0))
		itemIcon_1:setName("itemIcon_1")
	end
	if itemIcon_1 ~= nil then
		itemIcon_1:reset(itemInfo)
		itemIcon_1:resetNamePosY(-5)
	end
	self.itemIcon_1 = itemIcon_1

	local itemIcon_2 = self.Node_item_2:getChildByName("itemIcon_2")
	if itemIcon_2 == nil then
		itemIcon_2 = require("cp.view.ui.icon.ItemIcon"):create(nil)
		self["Node_item_2"]:addChild(itemIcon_2)
		itemIcon_2:setAnchorPoint(cc.p(0.5,0.5))
		itemIcon_2:setPosition(cc.p(0,0))
		itemIcon_2:setName("itemIcon_2")
		itemIcon_2:resetNamePosY(-5)
	end
	self.itemIcon_2 = itemIcon_2
	self.itemIcon_2:reset(nil)

	--附加屬性
	self.EquipPropertyList:resetPropertyInfoList(self.tabIndex,itemInfo, nil)

end

function EquipOperateLayer:resetQianghuaInfo(itemInfo)
	itemInfo.hideName = true
	
	local itemIcon = self.Node_item:getChildByName("itemIcon")
	if itemIcon == nil then
		itemIcon = require("cp.view.ui.icon.ItemIcon"):create(nil) 
		self["Node_item"]:addChild(itemIcon)
		itemIcon:setAnchorPoint(cc.p(0.5,0.5))
		itemIcon:setPosition(cc.p(0,0))
		itemIcon:setName("itemIcon")
	end
	if itemIcon ~= nil then
		itemIcon:reset(itemInfo)
	end
	
	local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
	self.Text_price:setString(tostring(evaluate_result.silver))
	cp.getUserData("UserEquipOperate"):setValue("money_need",evaluate_result.silver)
	--local StrengthenMaxLevel = cp.getConst("GameConst").EquipStrengthenMaxLevel[itemInfo.PlayerHierarchy][itemInfo.Colour]
	
	local StrengthenMaxLevel = evaluate_result.maxLevel --當前裝備的強化等級上限
	local afterLevel = evaluate_result.level
	self.Text_level:setString(tostring(afterLevel))
	self.Text_level:setTextColor(cc.c4b(255,255,255,255))
	self.Text_max_level:setString( "/" .. tostring(StrengthenMaxLevel))
	local cfgItem = cp.getManager("ConfigManager").getItemByKey("EquipStrengthen", itemInfo.strengthenLevel)
	local curLevelMaxExp = cfgItem:getValue("Exp")
	curLevelMaxExp = curLevelMaxExp or 0

	local beginExp = curLevelMaxExp
	local endExp = curLevelMaxExp
	if itemInfo.strengthenLevel == StrengthenMaxLevel then
		self.Text_value_1:setString( tostring(curLevelMaxExp) .. "/" .. tostring(curLevelMaxExp) )
		self.Text_value_2:setVisible(false)
		self.Image_progress_2:setContentSize(cc.size(245*1,20))
		self.Image_progress_1:setVisible(false)
	else
		self.Text_value_1:setString( tostring(itemInfo.strengthenExp) .. "/" .. tostring(curLevelMaxExp) )
		self.Text_value_2:setString( "+" .. tostring(evaluate_result.exp) )
		self.Text_value_2:setVisible(evaluate_result.exp > 0)
		local curScale = itemInfo.strengthenExp/curLevelMaxExp
		curScale = math.min(1,curScale)
		self.Image_progress_2:setContentSize(cc.size(245*curScale,20)) --黃色，強化前的

		beginExp = itemInfo.strengthenExp
		endExp = itemInfo.strengthenExp + evaluate_result.exp
	end
	

	if self["var_schedule_exp"] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self["var_schedule_exp"])
	end
	self["var_schedule_exp"] = nil
	self.beginExp = beginExp
	self.endExp = endExp
	self.curLevelMaxExp = curLevelMaxExp
	self["var_schedule_exp"] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.scaleEffect) ,0,false)


	local fight = tonumber(itemInfo.fight) or 0
	local qiangHuaInfo = {fight=fight,afterFight=evaluate_result.afterFight,beforAtt = evaluate_result.beforAtt,afterAtt = evaluate_result.afterAtt}
	self.EquipPropertyList:resetQianghuaPropertyInfoList(qiangHuaInfo)
	
end

function EquipOperateLayer:scaleEffect(dt)
	if self.beginExp >= self.endExp then
		self.beginExp = self.endExp
		if self["var_schedule_exp"] then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self["var_schedule_exp"])
		end
		self["var_schedule_exp"] = nil
	end
	local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
	local scale = math.min(1,self.beginExp/self.curLevelMaxExp)
	self.Image_progress_1:setContentSize(cc.size(245*scale,20))
	self.beginExp = self.beginExp + math.max((evaluate_result.exp)*0.25,1)
end

function EquipOperateLayer:refreshMaterialList()

	if self.MaterialSelectList then
		local h = self:generageMaterialSelectListHeight()
		self.MaterialSelectList:changeOperateType(self.tabIndex,h)
		self.MaterialSelectList:reloadItems()
	end
	
end

function EquipOperateLayer:onMaterialItemSelected()
	
	if self.tabIndex == 1 then --強化
		local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
		local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
		
		local req = {targetUID = uuid, materialUID = select_item_list}
		self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenEvaluateReq,req)
	else
		self:setMaterialItemSelectedResult()
	end
end

function EquipOperateLayer:onEquipStrengthenEvaluate(evt)
	--刷新結果
	self:initTargetItem()

	local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
	self.Text_level:setTextColor(cc.c4b(24,174,42,255))

	--[[
	local itemIcon = self.Node_item:getChildByName("itemIcon")
	if itemIcon then
		itemIcon:resetNumColor(cc.c4b(24,204,42,255))
		itemIcon:resetNum( "+" .. tostring(evaluate_result.level))
	end
	]]

	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "character" then
		local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
		if cur_step == 14  then --指引選擇了第一個材料
			local info = 
			{
				classname = "EquipOperateLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end
	end
end

--強化結果返回
function EquipOperateLayer:onEquipStrengthenResult(evt)
	
	local function refreshUI()
			
		self.MaterialSelectList:setMarkVisible(false)

		-- local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
		cp.getUserData("UserEquipOperate"):removeSelectedMaterialList()
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})
		local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
		local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
		local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
		if evaluate_result then
			evaluate_result.beforAtt = evaluate_result.afterAtt 
			evaluate_result.exp = 0
			evaluate_result.silver = 0
			evaluate_result.level = itemInfo.strengthenLevel
			evaluate_result.afterFight = itemInfo.fight
		end
		self:initTargetItem()
		if self.MaterialSelectList then
			self.MaterialSelectList:reloadItems()
		end


		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "character" then
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if cur_step == 16  then --強化完成
				local info = 
				{
					classname = "EquipOperateLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end
		end
	end

	if self.attackEffect then
		self.attackEffect:removeFromParent()
		self.attackEffect = nil
	end
	local attackEffect = cp.getManager("ViewManager").createSpineEffect("qianghua")
	attackEffect:setAnimation(0, "qianghua", false)
	attackEffect:registerSpineEventHandler(function(tbl)
		self.attackEffect:setVisible(false)
		refreshUI()
	end, sp.EventType.ANIMATION_COMPLETE)
	self.Panel_qianghua:addChild(attackEffect)
	attackEffect:setPosition(cc.p(278,123))
	self.attackEffect = attackEffect
	cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_2) --突破音效/裝備強化

end

function EquipOperateLayer:resetToNoMaterials()
	
	local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
	local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
	local evaluate_result = cp.getUserData("UserEquipOperate"):getValue("evaluate_result")
	if evaluate_result == nil then
		local select_item_list = {}
		local req = {targetUID = uuid, materialUID = select_item_list}
		self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenEvaluateReq,req)
		return false
	else
		evaluate_result.afterAtt = evaluate_result.beforAtt 
		evaluate_result.exp = 0
		evaluate_result.silver = 0
		evaluate_result.level = itemInfo.strengthenLevel
		evaluate_result.afterFight = itemInfo.fight
		return true
	end
	return true
end

function EquipOperateLayer:setMaterialItemSelectedResult()
	self.Text_price:setString(tostring(0))
	cp.getUserData("UserEquipOperate"):setValue("money_need",0)
	local select_item_list = cp.getUserData("UserEquipOperate"):getValue("select_item_list")
	local uuid = select_item_list[1]
	if uuid == "" or uuid == nil then
		
		self.Image_item_mark_1:setVisible(true)
		self.Image_mark_all:setVisible(false)
		if self.itemIcon_2 then
			self.itemIcon_2:reset(nil)
		end

		self.EquipPropertyList:resetPropertyInfoListForRight(nil)
	else

		local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
		local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
		if cfg == nil then
			self.EquipPropertyList:resetPropertyInfoListForRight(nil)
			return
		end
		local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
		if conf == nil then
			self.EquipPropertyList:resetPropertyInfoListForRight(nil)
			return
		end

		if itemInfo.Pos == nil then
			itemInfo.Pos = cfg:getValue("Pos")
		end
		if itemInfo.PlayerHierarchy == nil then
			itemInfo.PlayerHierarchy = cfg:getValue("PlayerHierarchy")
			itemInfo.PlayerHierarchy = itemInfo.PlayerHierarchy or 1
		end
		
		itemInfo.Name = conf:getValue("Name")
		itemInfo.Icon = conf:getValue("Icon")
		itemInfo.Type = conf:getValue("Type")
		itemInfo.SubType = conf:getValue("SubType")
		itemInfo.Package = conf:getValue("Package")
		itemInfo.Colour = conf:getValue("Hierarchy")
		itemInfo.showNum = false
		if self.itemIcon_2 then
			self.itemIcon_2:reset(itemInfo)
		end
		self.Image_item_mark_1:setVisible(false)
		self.Image_mark_all:setVisible(true)

		--附加屬性
		self.EquipPropertyList:resetPropertyInfoListForRight(itemInfo)

		local needCoin = 0
		if self.tabIndex == 2 then
			needCoin = itemInfo.Colour * 1000 + itemInfo.strengthenLevel * 500
		elseif self.tabIndex == 3 then
			needCoin = itemInfo.Colour * 500 + itemInfo.PlayerHierarchy * 500
		end
		self.Text_price:setString(tostring(needCoin))
		cp.getUserData("UserEquipOperate"):setValue("money_need",needCoin)
		
		-- if self.MaterialSelectList then
		-- 	self.MaterialSelectList:reloadItems()
		-- end

		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "equip" then
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if cur_step == 17 or cur_step == 23  then --傳承或熔鍊選擇材料
				local info = 
				{
					classname = "EquipOperateLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end
		end
	end
end

--傳承結果返回
function EquipOperateLayer:onEquipInheritedResult(evt)
	local function refreshUI()
		self.MaterialSelectList:setMarkVisible(false)
		--刷新結果
		self:initTargetItem()

		cp.getUserData("UserEquipOperate"):removeSelectedMaterialList()
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})
		self:onMaterialItemSelected()
		if self.MaterialSelectList then
			self.MaterialSelectList:reloadItems()
		end

		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "equip" then
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if cur_step == 19  then --確認傳承並返回後
				local info = 
				{
					classname = "EquipOperateLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end
		end
	end

	
	if self.attackEffect then
		self.attackEffect:removeFromParent()
		self.attackEffect = nil
	end
	local attackEffect = cp.getManager("ViewManager").createSpineEffect("chuancheng")
	attackEffect:setAnimation(0, "chuancheng", false)
	attackEffect:registerSpineEventHandler(function(tbl)
		self.attackEffect:setVisible(false)
		refreshUI()
	end, sp.EventType.ANIMATION_COMPLETE)
	self.Panel_cc_rl:addChild(attackEffect)
	attackEffect:setPosition(cc.p(280,94))
	self.attackEffect = attackEffect
	cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_chuancheng) --裝備傳承

end

--熔鍊結果
function EquipOperateLayer:onEquipMeltResult(evt)
	dump(evt)

	--播放隨機選擇動畫，
	local function onAnimPlayFinished()
		--彈出熔鍊恢復界面
		local uuid = cp.getUserData("UserEquipOperate"):getValue("target_item_uuid")
		local openInfo = {uuid = uuid,revert_need = 50, revertInfo = evt}
		local EquipMeltRevertUI = require("cp.view.scene.world.equipoperate.EquipMeltRevertUI"):create(openInfo)
		EquipMeltRevertUI:setCloseCallBack(handler(self,self.onEquipMeltCallBack))
		EquipMeltRevertUI:setPosition(cc.p(display.cx,display.cy))
		self:addChild(EquipMeltRevertUI,1)
	end
	local property_idx = evt.materialPos + 1
	self.EquipPropertyList:playMeltSelectAnimation(property_idx,onAnimPlayFinished)

end

function EquipOperateLayer:onEquipMeltCallBack()

	local function refreshUI()
		cp.getUserData("UserEquipOperate"):removeSelectedMaterialList()
		cp.getUserData("UserEquipOperate"):setValue("select_item_list",{})
		cp.getUserData("UserEquipOperate"):setValue("select_property_pos",-1)
		--刷新結果
		self:initTargetItem()
		
		self.MaterialSelectList:setMarkVisible(false)
		self:onMaterialItemSelected()
		if self.MaterialSelectList then
			self.MaterialSelectList:reloadItems()
		end

		local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
		if cur_guide_module_name == "equip" then
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if cur_step == 27  then --確認傳承並返回後
				local info = 
				{
					classname = "EquipOperateLayer",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end
		end
	end
	if self.attackEffect then
		self.attackEffect:removeFromParent()
		self.attackEffect = nil
	end
	local attackEffect = cp.getManager("ViewManager").createSpineEffect("ronglian")
	attackEffect:setAnimation(0, "ronglian", false)
	attackEffect:registerSpineEventHandler(function(tbl)
		self.attackEffect:setVisible(false)
		refreshUI()
	end, sp.EventType.ANIMATION_COMPLETE)
	self.Panel_cc_rl:addChild(attackEffect)
	attackEffect:setPosition(cc.p(292,92))
	self.attackEffect = attackEffect

end

function EquipOperateLayer:getDescription()
	return "EquipOperateLayer"
end
return EquipOperateLayer
