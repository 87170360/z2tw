local BLayer = require "cp.view.ui.base.BLayer"
local MajorPackage = class("MajorPackage",BLayer)
local socket = require "socket"
function MajorPackage:create()
	local layer = MajorPackage.new()
	return layer
end

function MajorPackage:initListEvent()
	self.listListeners = {
		--更新物品
		[cp.getConst("EventConst").ItemUpdateRsp] = function(evt)
			self:onItemUpdate()
			self:delayNewGuide(23)
			self:updateTabRedPoint()
		end,

		[cp.getConst("EventConst").ExpandPackSizeRsp] = function(evt)
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			majorRole.packSize = evt.packSize
			self:updatePackNum()
			cp.getManager("ViewManager").gameTip("恭喜您獲得了新的揹包空間")
		end,
	
		[cp.getConst("EventConst").EquipStrengthenEvaluateRsp] = function(evt)
			-- if self.EquipOperateLayer == nil then  --只有第一次創建的時候進入
				self:onEquipStrengthenEvaluate(evt)
			-- end
		end,
	
		--碎片合成
		[cp.getConst("EventConst").FragMergeRsp] = function(evt)
			
		end,
		
		[cp.getConst("EventConst").on_major_down_btn_clicked] = function(evt)
			if evt.name == cp.getConst("SceneConst").MODULE_MajorPackage then
				self:onVisibleStateChanged(evt.visible)
			end
		end,

		--新手指引獲取目標點位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "MajorPackage" then
				if evt.guide_name == "lottery" then
					local pos = nil
					if evt.target_name == "cell_item_1" then
						local posX,posY = self.Panel_cellviewbg:getPosition()
						pos = self.Panel_cellviewbg:getParent():convertToWorldSpace(cc.p(posX- self.Panel_cellviewbg:getContentSize().width/2 + 100/2+20,posY-100/2-20))
					else
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					end
					--此步指引為向右的手指
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MajorPackage" then
				if evt.guide_name == "lottery" then
					if evt.target_name == "cell_item_1" then
						local uuid = self:getData()[1]
						local itemInfo = nil
						if uuid then
							itemInfo = cp.getUserData("UserItem"):getItem(uuid)
						end
						if itemInfo then
							self:onCellItemClickCallBack(itemInfo)
						end
					else
						self:onUIButtonClick(self[evt.target_name])
					end
				end
			end
		end,
		["UsePrimevalChestRsp"] = function(data)
			local iconList = {}
			for _, metaInfo in ipairs(data.meta_list) do
				local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
				local iconInfo = {
					Colour = metaInfo.color,
					Name = metaEntry:getValue("Name"),
					Icon = metaEntry:getValue("CombatIcon"),
					iconType = "primeval",
				}
				table.insert(iconList, iconInfo)
			end
			local layer = require("cp.view.ui.messagebox.ShowIconListView"):create(iconList, nil, nil, nil)
			self:addChild(layer, 100)
		end
	}
end

function MajorPackage:onInitView(openInfo)
	-- self.beginTime = socket.gettime()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_package.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_top"] = {name = "Panel_top"},
		["Panel_root.Panel_top.Image_box"] = {name = "Image_box"},
		["Panel_root.Panel_top.Panel_head"] = {name = "Panel_head"},

		["Panel_root.Panel_top.Panel_head.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_top.Panel_head.Panel_bg.Panel_cellviewbg"] = {name = "Panel_cellviewbg"},
		["Panel_root.Panel_top.Panel_head.Panel_bg.Button_sold"] = {name = "Button_sold",click = "onSoldButtonClick"},
		["Panel_root.Panel_top.Panel_head.Panel_bg.Image_add"] = {name = "Image_add"},
		["Panel_root.Panel_top.Panel_head.Panel_bg.Image_add.Text_current_nums"] = {name = "Text_current_nums"},
		["Panel_root.Panel_top.Panel_head.Panel_bg.Image_add.Button_add"] = {name = "Button_add",click = "onAddButtonClick"},

		["Panel_root.Panel_top.Panel_head.Panel_quanbu"] = {name = "Panel_quanbu",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_zhuangbei"] = {name = "Panel_zhuangbei",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_wuxue"] = {name = "Panel_wuxue",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_cailiao"] = {name = "Panel_cailiao",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_daoju"] = {name = "Panel_daoju",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_suipian"] = {name = "Panel_suipian",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Panel_top.Panel_head.Panel_fushi"] = {name = "Panel_fushi",click = "onUIButtonClick",clickScale=1},

		["Panel_root.Panel_top.Panel_head.Panel_quanbu.Image_array"] = {name = "Image_quanbu_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_zhuangbei.Image_array"] = {name = "Image_zhuangbei_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_wuxue.Image_array"] = {name = "Image_wuxue_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_cailiao.Image_array"] = {name = "Image_cailiao_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_suipian.Image_array"] = {name = "Image_suipian_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_fushi.Image_array"] = {name = "Image_fushi_arrow"},
		["Panel_root.Panel_top.Panel_head.Panel_daoju.Image_array"] = {name = "Image_daoju_arrow"},
		
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)


	--調整分辨率適配
	self.rootView:setContentSize(display.size)
	
	self:adapterReslution()

	cp.getManager("ViewManager").addModalByDefaultImage(self)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self["Image_quanbu_arrow"]:setVisible(false)
    self["Image_zhuangbei_arrow"]:setVisible(false)
    self["Image_wuxue_arrow"]:setVisible(false)
    self["Image_cailiao_arrow"]:setVisible(false)
    self["Image_suipian_arrow"]:setVisible(false)
    self["Image_fushi_arrow"]:setVisible(false)
	self["Image_daoju_arrow"]:setVisible(false)
	
	self:firstInit()
	ccui.Helper:doLayout(self["rootView"])
	-- log(string.format("MajorPackage:initView 11 totaltime = %.6f",socket.gettime() - self.beginTime))
	self:setupAchivementGuide()
end

function MajorPackage:setupAchivementGuide()
	local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
	if guideType == 40 then
		guideBtn = self.Panel_wuxue
		cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
	end
    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function MajorPackage:adapterReslution()
	if display.height > 1280 then -- 1280,1440,1518
		local newHeight = display.height-85-100
		self.Image_box:setContentSize(736,newHeight)
		self.Panel_bg:setContentSize(650,newHeight-130)
		self.Panel_cellviewbg:setPositionY(newHeight - 130 - 15)
        self.Panel_cellviewbg:setContentSize(624,newHeight - 130 - 105)
        
	elseif display.height > 1080 then -- 1280
		local newHeight = display.height-85-80
		self.Image_box:setContentSize(736, newHeight)--display.height-85-80)
		self.Panel_bg:setContentSize(650, newHeight - 130)
		self.Panel_cellviewbg:setPositionY( newHeight - 130 - 15)
		self.Panel_cellviewbg:setContentSize(624, newHeight - 130 - 105)

	elseif display.height > 960 then --1080
		local newHeight = display.height-85-80
		self.Image_box:setContentSize(736, newHeight)--display.height-85-80)
		self.Panel_bg:setContentSize(650, newHeight - 130)
		self.Panel_cellviewbg:setPositionY( newHeight - 130 - 15)
		self.Panel_cellviewbg:setContentSize(624, newHeight - 130 - 105)
	else --960
		local newHeight = display.height-85-80
		self.Image_box:setContentSize(736, newHeight)--display.height-85-80)
		self.Panel_bg:setContentSize(650, newHeight - 130)
		self.Panel_cellviewbg:setPositionY( newHeight - 130 - 15)
		self.Panel_cellviewbg:setContentSize(624, newHeight - 130 - 105)
	end

	-- ccui.Helper:doLayout(self["rootView"])
	
end

function MajorPackage:onSoldButtonClick(sender)
	-- log("onSoldButtonClick 111")
	cp.getManager("ViewManager").showPackageItemSellUI()
end

function MajorPackage:onAddButtonClick(sender)
	local config1 = cp.getManager("ConfigManager").getItemByKey("Other", "package_max_num")
	local package_max_num = config1:getValue("IntValue") 
	
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")

	if majorRole.packSize >= package_max_num then
		cp.getManager("ViewManager").gameTip("揹包已經到達擴展上限")
		return
	end

	local config2 = cp.getManager("ConfigManager").getItemByKey("Other", "package_cost")
	local pack_cost = config2:getValue("IntValue") 
	if not cp.getManager("ViewManager").checkGoldEnough(pack_cost) then
		return
	end

	local config3 = cp.getManager("ConfigManager").getItemByKey("Other", "package_expand_num")
	local package_expand_num = config3:getValue("IntValue") 

	local function comfirmFunc()
		cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ExpandPackSizeReq, {})
	end

	
	local contentTable = {

		{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(pack_cost), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="增加", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="ttf", fontSize=24, text=tostring(package_expand_num), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="ttf", fontSize=24, text="個揹包格子", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
	}
	cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

end


function MajorPackage:onUIButtonClick(sender)
	local buttonName = sender:getName()
	--log("click button : " .. buttonName)
	local packType = 0
	if "Panel_quanbu"  == buttonName then
		packType = 0
	elseif "Panel_zhuangbei"  == buttonName then
		packType = 1
	elseif "Panel_wuxue"  == buttonName then
		packType = 2
	elseif "Panel_cailiao"  == buttonName then
		packType = 3
	elseif "Panel_daoju"  == buttonName then
		packType = 4
	elseif "Panel_suipian"  == buttonName then
		packType = 5
	elseif "Panel_fushi"  == buttonName then
		packType = 6
	end

	cp.getUserData("UserItem"):resetNewlyAcquired(packType)
	self:setPackageSpecial(packType)
	self:refreshButtonStatus(packType)

	self:updateTabRedPoint()
		
	if "Panel_wuxue"  == buttonName then
		self:delayNewGuide()
	end
end

function MajorPackage:refreshButtonStatus(packType)
	local buttonList = {"Panel_quanbu","Panel_zhuangbei","Panel_wuxue","Panel_cailiao","Panel_daoju","Panel_suipian","Panel_fushi"}
	for i=1,table.nums(buttonList) do
		local btn_item_name = buttonList[i]
		local icon = "ui_common_module14_wuxue_fenxianganniu03.png"
		local Text_1 = self[btn_item_name]:getChildByName("Text_1")
		if packType == i-1 then
			icon = "ui_common_module14_wuxue_fenxianganniu04.png"
			Text_1:setTextColor(cp.getConst("GameConst").TabTextColor[1])
		else
			Text_1:setTextColor(cp.getConst("GameConst").TabTextColor[2])
		end
		local Image_bg = self[btn_item_name]:getChildByName("Image_bg")
		Image_bg:loadTexture(icon, ccui.TextureResType.plistType) 
	end
end

function MajorPackage:onEnterScene()
	self:delayNewGuide()
end

function MajorPackage:onExitScene()
	
end


function MajorPackage:delayNewGuide(beginStep)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "lottery" then
		local needSend = true
		if beginStep then
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if cur_step < beginStep then
				needSend = false
			end
		end
		if needSend then
			local sequence = {}
			table.insert(sequence, cc.DelayTime:create(0.3))
			table.insert(sequence,cc.CallFunc:create(function()
				
				local info = 
				{
					classname = "MajorPackage",
				}
				self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
			end))
			self:runAction(cc.Sequence:create(sequence))
		end
    end
end

function MajorPackage:firstInit()
	self.currentPackType = nil
	
	local packType = 0
	self:setPackageSpecial(packType)
	self:refreshButtonStatus(packType)

	self:setItemView()


	cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_main,true)

	self:updateTabRedPoint()
	self:updatePackNum()
end

function MajorPackage:updatePackNum()
	local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem") or {}
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self["Text_current_nums"]:setString(tostring(table.nums(roleItem)) .. "/" .. tostring(majorRole.packSize))
end

--設置顯示的內容
function MajorPackage:setItemView()
	-- local curTime = socket.gettime()

	local sz = self.Panel_cellviewbg:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(sz)
	self.cellView:setCellSize(154, 178)
	self.cellView:setColumnCount(4)
	self.cellView:setCountFunction(
		function() 
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			majorRole.packSize = majorRole.packSize or 400
			return majorRole.packSize or 400
		end)
	-- log(string.format("MajorPackage:setItemView 11 totaltime = %.6f",socket.gettime() - curTime))
	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	
	-- log(string.format("MajorPackage:setItemView 22 totaltime = %.6f",socket.gettime() - curTime))
	-- curTime = socket.gettime()
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()       --刷新數據
	-- log(string.format("MajorPackage:setItemView 33 totaltime = %.6f",socket.gettime() - curTime))
	-- curTime = socket.gettime()
	self.cellView:setAnchorPoint(cc.p(0, 0))
	self.cellView:setPosition(cc.p(5, 0))
	self["Panel_cellviewbg"]:addChild(self.cellView)
	-- log(string.format("MajorPackage:setItemView 44 totaltime = %.6f",socket.gettime() - curTime))
end

function MajorPackage:cellFactory(cellview, idx)
	-- local curTime = socket.gettime()
	local item = nil
	local cell = cellview:dequeueCell()
	local uuid = self:getData()[idx]
	local data = cp.getUserData("UserItem"):getItem(uuid)

	-- log(string.format("cellFactory 1111 time = %.6f",socket.gettime() - curTime))
	-- curTime = socket.gettime()
    if nil == cell then
		cell = cc.TableViewCell:new()
	
		item = require("cp.view.ui.item.BagItem"):create(nil)
		-- log(string.format("cellFactory 2222 time = %.6f",socket.gettime() - curTime))
		-- curTime = socket.gettime()

		item:setScale(1)
		item:setName("BagItem")
		cell:addChild(item)

		local sz = item:getContentSize()
		item:setPosition(cc.p(sz.width/2, sz.height/2)) --加20修正位置

		item:setItemClickCallBack(handler(self,self.onCellItemClickCallBack))
    else
		item = cell:getChildByName("BagItem")
    end

	item:reset(data,true)	
	-- log(string.format("cellFactory 4444 time = %.6f",socket.gettime() - curTime))
    return cell
end

function MajorPackage:reloadData()
	self.cellView:reloadData()
end

function MajorPackage:getData()
	local items_for_package = cp.getUserData("UserItem"):getValue("items_for_package")
	return items_for_package[self.currentPackType] 
end

function MajorPackage:setPackageSpecial(packType,needKeepOffset)
	log("packType", packType)
	
	-- if self.currentPackType and self.currentPackType == packType then
	-- 	log("packType same")
	-- 	return
	-- end

	self.currentPackType = packType
	if self.cellView then
		self:reloadData()
		if self.offset and needKeepOffset then
			self.cellView:setContentOffset(self.offset, false)
		end
	end
	

end

function MajorPackage:onUsePrimevalBox(itemInfo)
	local openInfo = {
		itemInfo = itemInfo,
		contentType = "useItem",
		callback = function(num,itemInfo)
			if num < 1 then
				return
			end
			local req = {}
			req.id = itemInfo.id
			req.num = num
			self:doSendSocket(cp.getConst("ProtoConst").UsePrimevalChestReq, req)
		end
	}
	cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
end

-- 直接關閉，使用，出售，傳承，強化，熔鍊，分解,合成
function MajorPackage:onItemTipClosedCallBack(closeType,itemInfo,skillEntry)

	log("onItemTipClosedCallBack closeType=" .. closeType)


	if closeType == "Button_use" then
		if itemInfo.SubType == 2 then
			self:onUsePrimevalBox(itemInfo)
		else
			self:onUseItem(itemInfo)
		end
	elseif closeType == "Button_chushou" then
		self:onSellItem(itemInfo)
	elseif closeType == "Button_qianghua" then
		self:onOperateItem(1,itemInfo)
	elseif closeType == "Button_chuancheng" then
		self:onOperateItem(2,itemInfo)
	elseif closeType == "Button_ronglian" then
		self:onOperateItem(3,itemInfo)
	elseif closeType == "Button_fenjie" then
		self:onFenJie(itemInfo)

	elseif closeType == "Button_hecheng" then
		self:doSendSocket(cp.getConst("ProtoConst").FragMergeReq,{uuid = itemInfo.uuid})
		cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_item_hecheng)
	elseif closeType == "Button_study" then
		self:onSkillItem(itemInfo)
	elseif closeType == "Button_xiulian" then
		--打開境界提升界面
		local SkillBoundaryLayer = require("cp.view.scene.skill.SkillBoundaryLayer"):create(skillEntry)
		self:addChild(SkillBoundaryLayer, 100)
		SkillBoundaryLayer:setCloseCallback(function()
			self.SkillBoundaryLayer = nil
		end)
		self.SkillBoundaryLayer = SkillBoundaryLayer
	elseif closeType == "Button_close" then
		--不做任何處理
	end

end

--點擊物品後彈出tips
function MajorPackage:onCellItemClickCallBack(itemInfo)

	if itemInfo == nil or itemInfo.id == nil or itemInfo.uuid == nil then
		return
	end

	local newItemInfo = clone(itemInfo)
	cp.getManager("ViewManager").showItemTip(newItemInfo,handler(self,self.onItemTipClosedCallBack))
	self.offset = self.cellView:getContentOffset()

end

function MajorPackage:onUseKey(itemInfo)

	
	local cfgItem = cp.getManager("ConfigManager").getItemByMatch("GameChest",{Key = itemInfo.id})
	if cfgItem then
		local baoxiang_itemID = cfgItem:getValue("ItemID")
		if baoxiang_itemID then
			local uuid, itemInfo2 = cp.getUserData("UserItem"):getItemPackMax(baoxiang_itemID)
			if uuid then
				local data = {uuid=uuid}
				if itemInfo.num == 1 then
					data.num = 1
					self:doSendSocket(cp.getConst("ProtoConst").ChestItemReq,data)
					
				elseif itemInfo.num > 1 then
					local openInfo = {
						itemInfo = itemInfo2,
						contentType = "useItem",
						callback = function(num,itemInfo)
							if num < 1 then
								return
							end
							data.num = num
							self:doSendSocket(cp.getConst("ProtoConst").ChestItemReq,data)
						end
					}
					cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
				end
			else
				local itemConf = cp.getManager("ConfigManager").getItemByKey("GameItem", baoxiang_itemID)
				local Colour = itemConf:getValue("Hierarchy")
				local function comfirmFunc()
					self:openShop(3)  --雜貨鋪
				end
		
				local contentTable = {
					{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=itemConf:getValue("Name"), textColor=cp.getConst("CombatConst").SkillQualityColor4b[Colour]},
					{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="不足,是否前往雜貨商店購買？", textColor=cc.c4b(255,255,255,255)},
				}
				cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

			end
		end
	end
end

function MajorPackage:onUseItem(itemInfo)
	dump(itemInfo)

	--鑰匙特殊處理
	if itemInfo.id == 611 or itemInfo.id == 612 or itemInfo.id == 613 then -- 銅鑰匙，銀鑰匙，金鑰匙
		self:onUseKey(itemInfo)
		return 
	end
	if itemInfo.id == 10 then  --天書殘頁特殊處理
		self:openShop(7) -- 天書商店
		return
	end

	if itemInfo.id == 614 then
        local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
		return
	end
	
	local data = {uuid=itemInfo.uuid}
	local Type = itemInfo.Type
	if Type == 3 then  --使用寶箱
		local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameChest",itemInfo.id)
		--if itemInfo.id == 608 or itemInfo.id == 609 or itemInfo.id == 610 then -- 銅寶箱，銀寶箱，金寶箱
		if cfgItem then
			-- local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameChest",itemInfo.id)
			local key_id = cfgItem:getValue("Key")
			if key_id and key_id > 0 then
				local uuid, itemInfo2 = cp.getUserData("UserItem"):getItemPackMax(key_id)
				if uuid == nil then
					local itemConf = cp.getManager("ConfigManager").getItemByKey("GameItem", key_id)
					local Colour = itemConf:getValue("Hierarchy")
					local function comfirmFunc()
						self:openShop(3)  --雜貨鋪
					end
			
					local contentTable = {
						{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=itemConf:getValue("Name"), textColor=cp.getConst("CombatConst").SkillQualityColor4b[Colour]},
						{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="不足,是否立即前往商城進行購買？", textColor=cc.c4b(255,255,255,255)},
					}
					cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
					return
				end
			end
		end
		if itemInfo.num == 1 then
			data.num = itemInfo.num
			self:doSendSocket(cp.getConst("ProtoConst").ChestItemReq,data)
			
		elseif itemInfo.num > 1 then
			local openInfo = {
				itemInfo = itemInfo,
				contentType = "useItem",
				callback = function(num,itemInfo)
					if num < 1 then
						return
					end
					data.num = num
					self:doSendSocket(cp.getConst("ProtoConst").ChestItemReq,data)
				end
			}
			cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
		end
		
	elseif Type == 5  then -- 消耗品
		if itemInfo.num == 1 then
			data.num = itemInfo.num
			self:doSendSocket(cp.getConst("ProtoConst").UseConsumeReq,data)
			cp.getManager("GDataManager"):setFightDelay(true)
		elseif itemInfo.num > 1 then
			
			local openInfo = {
				itemInfo = itemInfo,
				contentType = "useItem",
				callback = function(num,itemInfo)
					if num < 1 then
						return
					end
					local data = {uuid=itemInfo.uuid, num=num}
					self:doSendSocket(cp.getConst("ProtoConst").UseConsumeReq,data)
				end
			}
			cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
			cp.getManager("GDataManager"):setFightDelay(true)
		end
		
	elseif Type == 1 then --裝備
		local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
		if itemInfo.PlayerHierarchy > majorRole.hierarchy then
            cp.getManager("ViewManager").gameTip("請升至" .. itemInfo.PlayerHierarchy .. "階才可裝備")
			return
		end
		self:doSendSocket(cp.getConst("ProtoConst").UseEquipReq,data)
		cp.getManager("ViewManager").gameTip("已裝備上" .. itemInfo.Name)
	else
		log("item can't use, type = " .. tostring(Type))
	end
	
end

--使用武學書		
function MajorPackage:onSkillItem(itemInfo)
	log("MajorPackage:onSkillItem uuid=" .. itemInfo.uuid)
	local data = {uuid=itemInfo.uuid, num=1}
	self:doSendSocket(cp.getConst("ProtoConst").SkillItemReq,data)

end

function MajorPackage:onFenJie(itemInfo)
	log("MajorPackage:onFenJie uuid=" .. itemInfo.uuid)
	if itemInfo.num == 1 then
		local data = {uuid=itemInfo.uuid,num=1}
		self:doSendSocket(cp.getConst("ProtoConst").CrushSkillReq,data)
	elseif itemInfo.num > 1 then
		
		local openInfo = {
			itemInfo = itemInfo,
			contentType = "fenjieItem",
			callback = function(num,itemInfo)
				if num < 1 then
					return
				end
				local data = {uuid=itemInfo.uuid, num=num}
				self:doSendSocket(cp.getConst("ProtoConst").CrushSkillReq,data)
			end
		}
		cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
	end

end

function MajorPackage:onSellItem(curItemInfo)
	log("MajorPackage:onSellItem uuid=" .. curItemInfo.uuid)
	if curItemInfo.num < 1 then
		return
	end

	local function sellImmidiatly(num,itemInfo)
		if num < 1 then
			return
		end
    	if itemInfo.Colour >= 4 then -- 紫色以上提醒
    		local function comfirmFunc()
				local item = {uuid=itemInfo.uuid, num=num}
				local req = {items = {}}
				table.insert(req.items,item)
    			self:doSendSocket(cp.getConst("ProtoConst").SellItemReq,req)
    		end
			local color = cp.getConst("GameConst").QualityTextColor[itemInfo.Colour]
			local nameStr = itemInfo.Name
			if num > 1 then
				nameStr = nameStr .. " x " ..tostring(num)
			end
    		local contentTable = {
    			{type="ttf", fontSize=24, text="是否確定出售", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
    			{type="ttf", fontSize=24, text=nameStr, textColor=color, outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
    			{type="ttf", fontSize=24, text=" ？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
    		}
    		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    	
    	else
			local item = {uuid=itemInfo.uuid, num=num}
			local req = {items = {}}
			table.insert(req.items,item)
			self:doSendSocket(cp.getConst("ProtoConst").SellItemReq,req)
    	end
	end
	if curItemInfo.num == 1 then
		sellImmidiatly(1,curItemInfo)
	else
		local openInfo = {
			itemInfo = curItemInfo,
			contentType = "sellItem",
			callback = function(num,itemInfo)
				if num < 1 then
					return
				end
				local item = {uuid=itemInfo.uuid, num=num}
				local req = {items = {}}
				table.insert(req.items,item)
    			self:doSendSocket(cp.getConst("ProtoConst").SellItemReq,req)
			end
		}
		cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
		
	end
end
      
function MajorPackage:onItemUpdate()
	log("onItemUpdate")
	packtype = self.currentPackType
	self.currentPackType = nil
	self:setPackageSpecial(packtype,true)
	self:updatePackNum()
end

function MajorPackage:onOperateItem(index,itemInfo)

	cp.getUserData("UserEquipOperate"):setValue("target_item_uuid",itemInfo.uuid)
	
	if index == 1 then --強化需求先預估強化後的基礎屬性及消耗
		local req = {targetUID = itemInfo.uuid, materialUID = {}}  --第一次不傳入材料
		self:doSendSocket(cp.getConst("ProtoConst").EquipStrengthenEvaluateReq,req)
	else
		-- if self.EquipOperateLayer == nil then
		-- 	local openInfo = {type = index}
		-- 	local EquipOperateLayer = require("cp.view.scene.world.equipoperate.EquipOperateLayer"):create(openInfo)
		-- 	EquipOperateLayer:setCloseCallBack(handler(self,self.refreshItem))
		-- 	self:addChild(EquipOperateLayer,1)
		-- 	self.EquipOperateLayer = EquipOperateLayer
		-- end

		cp.getManager("ViewManager").ShowEquipOperateLayer(index,handler(self,self.refreshItem))
	end
end

function MajorPackage:onEquipStrengthenEvaluate(evt)
	-- if self.EquipOperateLayer == nil then
	-- 	local openInfo = {type = 1}
	-- 	local EquipOperateLayer = require("cp.view.scene.world.equipoperate.EquipOperateLayer"):create(openInfo)
	-- 	EquipOperateLayer:setCloseCallBack(handler(self,self.refreshItem))
	-- 	self:addChild(EquipOperateLayer,1)
	-- 	self.EquipOperateLayer = EquipOperateLayer
	-- end
	cp.getManager("ViewManager").ShowEquipOperateLayer(1,handler(self,self.refreshItem))
end

function MajorPackage:refreshItem(uuid)

	-- if self.EquipOperateLayer then
	-- 	self.EquipOperateLayer:removeFromParent()
	-- end
	-- self.EquipOperateLayer = nil

	--刷新揹包界面
	self:reloadData()
	self:updatePackNum()
end

function MajorPackage:updateTabRedPoint()
	local arrows = {
		self["Image_zhuangbei_arrow"],
		self["Image_wuxue_arrow"],
		self["Image_cailiao_arrow"],
		self["Image_daoju_arrow"],
		self["Image_suipian_arrow"],
		self["Image_fushi_arrow"]
	}

	local packageNeedRedPoint = cp.getUserData("UserItem"):checkPackageItemCanOperate()
	for i=1,#packageNeedRedPoint do
		arrows[i]:setVisible(packageNeedRedPoint[i] == 1)
	end
end

function MajorPackage:openShop(storeID)
	if self.ShopMainUI ~= nil then
		self.ShopMainUI:removeFromParent()
	end
	self.ShopMainUI = nil
	
	local openInfo = {storeID = storeID, closeCallBack = function()
		self.ShopMainUI:removeFromParent()
		self.ShopMainUI = nil
	end}
	local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
	self.rootView:addChild(ShopMainUI,2)
	self.ShopMainUI = ShopMainUI

end


function MajorPackage:onVisibleStateChanged(isVisible)
	if isVisible then
		cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_main,true)
		self:updateTabRedPoint()
		ccui.Helper:doLayout(self["rootView"])
	else
		if self.ShopMainUI ~= nil then
			-- self.ShopMainUI:removeFromParent()
			self.ShopMainUI = nil
		end

		if self.SkillBoundaryLayer ~= nil then
			-- self.SkillBoundaryLayer:removeFromParent()
			self.SkillBoundaryLayer = nil
		end
		
		-- if self.EquipOperateLayer then
		-- 	self.EquipOperateLayer:removeFromParent()
		-- 	self.EquipOperateLayer = nil
		-- end

	end
end


return MajorPackage
