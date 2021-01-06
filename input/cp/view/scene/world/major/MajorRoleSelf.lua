local BLayer = require "cp.view.ui.base.BLayer"
local MajorRoleSelf = class("MajorRoleSelf",BLayer)

function MajorRoleSelf:create()
	local layer = MajorRoleSelf.new()
	return layer
end

function MajorRoleSelf:initListEvent()
	self.listListeners = {
		
		--更新物品
		[cp.getConst("EventConst").ItemUpdateRsp] = function(evt)
			if self.MajorRolePublic ~= nil then
				local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
				self.MajorRolePublic:reSetRoleItem(roleItem)
			end
		end,

		--更新人物全屬性
		[cp.getConst("EventConst").GetRoleRsp] = function(evt)
			self:refreshRoleInfo()
		end,

		[cp.getConst("EventConst").UseEquipRsp] = function(evt)
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			self.Text_fight:setString("戰力: " .. tostring(roleAtt.fight))
		end,

		[cp.getConst("EventConst").BuyFashionRsp] = function(evt)
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			self.Text_fight:setString("戰力: " .. tostring(roleAtt.fight))
		end,

		[cp.getConst("EventConst").UseFashionRsp] = function(evt)
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			self.Text_fight:setString("戰力: " .. tostring(roleAtt.fight))
		end,

		[cp.getConst("EventConst").EquipStrengthenEvaluateRsp] = function(evt)
			-- if self.EquipOperateLayer == nil then  --只有第一次創建的時候進入
				self:onEquipStrengthenEvaluate(evt)
			-- end
		end,

		[cp.getConst("EventConst").on_major_down_btn_clicked] = function(evt)
			if evt.name == cp.getConst("SceneConst").MODULE_MajorRole then

				if self.MajorRoleAttribute ~= nil then
					-- self.MajorRoleAttribute:removeFromParent() 
					self.MajorRoleAttribute = nil
				end
				if self.MajorRolejingjie ~= nil then
					-- self.MajorRolejingjie:removeFromParent() 
					self.MajorRolejingjie = nil
				end
				-- if self.EquipOperateLayer ~= nil then
				-- 	self.EquipOperateLayer:removeFromParent()
				-- 	self.EquipOperateLayer = nil
				-- end

				if self.selectEquipTip ~= nil then
					self.selectEquipTip:removeFromParent()
					self.selectEquipTip = nil
				end

				if evt.visible then
					self:refreshRoleInfo()
				end
			end
		end,

		[cp.getConst("EventConst").onEnterSelectTips] = function(evt)
			if evt.itemInfo then
				self:showSelectEquipTip(evt.itemInfo)
			end
		end,
        ["LearnMetalRsp"] = function(evt)
            self:checkNeedNoticePrimevalEquip()
        end,
        ["EquipMetaRsp"] = function(evt)
            self:checkNeedNoticePrimevalEquip()
        end,
	}
end

function MajorRoleSelf:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_role_self.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_Role"] = {name = "Panel_Role"},
		["Panel_Role.Panel_renwu"] = {name = "Panel_renwu"},
		["Panel_Role.Panel_renwu.Image_RenWu"] = {name = "Image_RenWu"},

		["Panel_Role.Text_id"] = {name = "Text_id"},
		["Panel_Role.Image_id"] = {name = "Image_id"},
		["Panel_Role.Text_sins"] = {name = "Text_sins"},
		["Panel_Role.Image_sins"] = {name = "Image_sins"},
		["Panel_Role.Button_help"] = {name = "Button_help",click = "onUIButtonClick",clickScale = 0.7},

		["Panel_Role.Image_name"] = {name = "Image_name"},
		["Panel_Role.Image_name.Text_name"] = {name = "Text_name"},
		["Panel_Role.Panel_info.Image_levelinfo"] = {name = "Image_levelinfo"},
		["Panel_Role.Panel_info.Image_levelinfo.Text_levelinfo"] = {name = "Text_levelinfo"},
		["Panel_Role.Panel_info.Image_gang.Text_gang"] = {name = "Text_gang"},
		["Panel_Role.Panel_info.Image_gang"] = {name = "Image_gang"},
		["Panel_Role.Panel_info.Image_title"] = {name = "Image_title"},
		["Panel_Role.Panel_info.Image_title.Text_title"] = {name = "Text_title"},
		["Panel_Role.Panel_info.Image_4"] = {name = "Image_4"},
		["Panel_Role.Panel_info.Text_fight"] = {name = "Text_fight"},
		["Panel_Role.Image_bg_0"] = {name = "Image_bg_0"},
		["Panel_Role.Image_bg_5"] = {name = "Image_bg_5"},
		["Panel_Role.Image_bg_6"] = {name = "Image_bg_6"},
		["Panel_Role.Image_left"] = {name = "Image_left"},
		["Panel_Role.Image_right"] = {name = "Image_right"},
		
		["Panel_Role.Button_shuxing"] = {name = "Button_shuxing",click = "onUIButtonClick"},
		["Panel_Role.Button_jingjie"] = {name = "Button_jingjie",click = "onUIButtonClick"},
		["Panel_Role.Button_zuoqi"] = {name = "Button_zuoqi",click = "onUIButtonClick"},
		["Panel_Role.Panel_shizhuang"] = {name = "Panel_shizhuang",click = "onUIButtonClick"},
		["Panel_Role.Panel_Primeval"] = {name = "Panel_Primeval",click = "onUIButtonClick"},

		["Panel_Role.FileNode_1"] = {name = "FileNode_1"},

		["Panel_Role.Image_top"] = {name = "Image_top"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	local openInfo = {roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt"),
					type = "MajorRoleSelf"}
	local MajorRolePublic = require("cp.view.scene.world.major.MajorRolePublic"):create(openInfo) 
	--MajorRolePublic:setJingjieClickCallBack(handler(self, self.onUIButtonClick))
	MajorRolePublic:setEquipOperateCallBack(handler(self, self.onOperateItem))
	self.MajorRolePublic = MajorRolePublic
	self.FileNode_1:addChild(self.MajorRolePublic)
	-- cp.getManager("ViewManager").addModalByDefaultImage(self)

	self.rootView:setContentSize(display.size)
	self.Panel_Role:setContentSize(display.size)
	--self.FileNode_1:setPositionY(display.height - 100)  --MajorTop人物頭像訊息框高度按170算
	
	self:autoAdjust()

	ccui.Helper:doLayout(self.rootView)
end

function MajorRoleSelf:checkNeedNoticePrimevalEquip()
	if cp.getUtils("NotifyUtils").needNotifyPrimevalEquip() then
        cp.getManager("ViewManager").addRedDot(self.Panel_Primeval,cc.p(88,90))
	else
        cp.getManager("ViewManager").removeRedDot(self.Panel_Primeval)
	end
end

function MajorRoleSelf:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log("click button : " .. buttonName)

	if "Button_shuxing"  == buttonName then
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local guildAtt = cp.getUserData("UserRole"):getValue("guildAtt")
		local fashion = cp.getUserData("UserRole"):getValue("fashion_data")
		local openInfo = {roleAtt = roleAtt ,type = "MajorRoleSelf", guildAtt = guildAtt, fashion=fashion}
		local MajorRoleAttribute = require("cp.view.scene.world.major.MajorRoleAttribute"):create(openInfo)
		self.rootView:addChild(MajorRoleAttribute,1)
		MajorRoleAttribute:setCloseCallBack(function()
			self.MajorRoleAttribute = nil
		end)
		self.MajorRoleAttribute = MajorRoleAttribute
	elseif "Button_jingjie"  == buttonName then
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local openInfo = {roleAtt = roleAtt}
		local MajorRolejingjie = require("cp.view.scene.world.major.MajorRolejingjie"):create(openInfo)
		self.rootView:addChild(MajorRolejingjie,1)
		MajorRolejingjie:setCloseCallBack(function()
			self.MajorRolejingjie = nil
		end)
		self.MajorRolejingjie = MajorRolejingjie
	elseif "Button_help" == buttonName then
		cp.getManager("ViewManager").showHelpTips("ZuiEValueRule")
	elseif "Panel_shizhuang" == buttonName then
		cp.getManager("ViewManager").showFashionMainLayer(function()
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

			local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
			local cfg, _ = cp.getManager("GDataManager"):getMajorRoleIamge(fashion_data.use,roleAtt["career"],roleAtt["gender"]) 
			local WholeDraw = cfg:getValue("WholeDraw")
			if WholeDraw ~= nil and WholeDraw ~= "" then
				self["Image_RenWu"]:loadTexture(WholeDraw, ccui.TextureResType.localType)
			end
		end)
		
	elseif "Panel_Primeval" == buttonName then
		local layer = require("cp.view.scene.primeval.PrimevalEquipLayer"):create(1)
		self:addChild(layer, 100)
	elseif "Button_zuoqi" == buttonName then
		cp.getManager("ViewManager").gameTip("您尚未獲得坐騎。")
	end
end

function MajorRoleSelf:setTitle(att)
	log(att.achieveID)
	if att.achieveID == 0 then
		self.Image_title:setVisible(false) 
		return
	end
	self.Image_title:setVisible(true) 

	local conf = cp.getManager("ConfigManager").getItemByKey("Achieve", att.achieveID)
	if conf == nil then
		return
	end

	local quality = conf:getValue("Quality")
	local title = conf:getValue("Title")


	self.Text_title:setString(title)
	cp.getManager("ViewManager").setTextQuality(self.Text_title, quality)
end

function MajorRoleSelf:refreshRoleInfo()
	
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData() --幫派數據
	self.Text_id:setString("ID " .. roleAtt.id)
	self.Text_name:setString(tostring(roleAtt.name))
	local hierarchyInfo = cp.getManager("GDataManager"):getHierarchyInfo(roleAtt.career, roleAtt.gangRank, roleAtt.hierarchy)
	self.Text_levelinfo:setString(tostring("LV." .. roleAtt.level .. "  " .. hierarchyInfo))
	self.Text_gang:setString(tostring("無幫派"))
	if guildDetailData.name and string.len(guildDetailData.name) > 0 then
		self.Text_gang:setString(tostring("幫派 【" .. guildDetailData.name .. "】"))
	end
	self.Text_fight:setString("戰力: " .. tostring(roleAtt.fight))
	local sins = roleAtt.sins or 0
	sins = math.min(sins,100)
	self.Text_sins:setString("罪惡值 " .. tostring(sins))

	self:setTitle(roleAtt)

	--self:autoContentSize2(self.Text_name, self.Image_name)
	--self:autoContentSize2(self.Text_gang, self.Image_gang)
	--self:autoContentSize2(self.Text_levelinfo, self.Image_levelinfo)

	self["Image_RenWu"]:setVisible(false)
	local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
	local cfg, _ = cp.getManager("GDataManager"):getMajorRoleIamge(fashion_data.use,roleAtt["career"],roleAtt["gender"]) 
	local WholeDraw = cfg:getValue("WholeDraw")
	if WholeDraw ~= nil and WholeDraw ~= "" then
		self["Image_RenWu"]:loadTexture(WholeDraw, ccui.TextureResType.localType)
		self["Image_RenWu"]:ignoreContentAdaptWithSize(true)
		self["Image_RenWu"]:setVisible(true)
	end

	ccui.Helper:doLayout(self.rootView)

	cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_main,true)
	
	if roleAtt.hierarchy < 3 then
		self.Panel_Primeval:setEnabled(false)
		self.Panel_Primeval:getChildByName("Image_1"):loadTexture("ui_major_role_module98_hunyuan_20.png", ccui.TextureResType.plistType)
	else
		self.Panel_Primeval:setEnabled(true)
		self.Panel_Primeval:getChildByName("Image_1"):loadTexture("ui_major_role_module98_hunyuan_9.png", ccui.TextureResType.plistType)
	end

	self:checkNeedNoticePrimevalEquip()
end

function MajorRoleSelf:onEnterScene()
	self:refreshRoleInfo()
	self:onNewGuideStory()
end

function MajorRoleSelf:autoAdjust()

	self.MajorRolePublic:autoAdjust()

	--等比拉伸
	local fun1 = function(v) 
		local height = self:getScaleSize(display.height, v:getContentSize().height)
		v:setContentSize(cc.size(v:getContentSize().width, height))
	end

	-- 等比平鋪
	local fun2 = function(v) 
		local scale = display.height / 1280
		v:setPositionY(v:getPositionY() * scale)  
	end

	local tb = {
		{self.Image_top, fun2},
		{self.Button_zuoqi, fun2},
		{self.Text_id, fun2},
		{self.Image_name, fun2},
		{self.Panel_renwu, fun2},
		{self.Image_bg_5, fun1},
		{self.Image_bg_6, fun2},
		{self.Image_left, fun2},
		{self.Image_right, fun2},
	}

	for _, v in pairs(tb) do
		v[2](v[1])
	end

	--manual adjust
	local height = display.height
	if height >= 1518 then
		self.Image_bg_0:setPositionY(self.Image_bg_0:getPositionY() + 150)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 100)
		self.Panel_shizhuang:setPosition(cc.p(620,360))
		self.Panel_Primeval:setPosition(cc.p(100,360))
		self.Image_bg_0:setPositionY(self.MajorRolePublic:getWuqiPosY() + 45)
		self.Image_RenWu:setPositionY(self.Image_RenWu:getPositionY() + 25)
	elseif height >= 1440 then
		self.Text_id:setPositionY(self.Text_id:getPositionY() + 25)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 90)
		self.Image_name:setPositionY(self.Image_name:getPositionY() + 25)
		self.Panel_shizhuang:setPosition(cc.p(620,360))
		self.Panel_Primeval:setPosition(cc.p(100,360))
		self.Image_bg_6:setPositionY(self.Image_bg_6:getPositionY() + 20)
		self.Image_bg_0:setPositionY(self.MajorRolePublic:getWuqiPosY() + 60)
		self.Image_RenWu:setPositionY(self.Image_RenWu:getPositionY() + 25)
	elseif height >= 1280 then
		self.Text_id:setPositionY(self.Text_id:getPositionY() + 25)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 90)
		self.Image_name:setPositionY(self.Image_name:getPositionY() + 25)
		self.Panel_shizhuang:setPosition(cc.p(620,360))
		self.Panel_Primeval:setPosition(cc.p(100,360))
		self.Image_bg_6:setPositionY(self.Image_bg_6:getPositionY() + 20)
		self.Image_bg_0:setPositionY(self.Image_bg_0:getPositionY() + 20)
	elseif height >= 1200 then
		self.Text_id:setPositionY(self.Text_id:getPositionY() + 25)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 90)
		self.Image_name:setPositionY(self.Image_name:getPositionY() + 25)
		self.Panel_shizhuang:setPosition(cc.p(620,360))
		self.Panel_Primeval:setPosition(cc.p(100,360))
		self.Image_bg_6:setPositionY(self.Image_bg_6:getPositionY() + 20)
		self.Image_bg_0:setPositionY(self.Image_bg_0:getPositionY() + 20)
	elseif height >= 1000 then
		self.Text_id:setPositionY(self.Text_id:getPositionY() + 25)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 50)
		self.Image_name:setPositionY(self.Image_name:getPositionY() + 25)
		self.Image_levelinfo:setPositionY(self.Image_levelinfo:getPositionY() - 50)
		self.Image_gang:setPositionY(self.Image_gang:getPositionY() - 40)
		self.Panel_shizhuang:setPosition(cc.p(510,740))
		self.Panel_shizhuang:getChildByName("Image_1"):setScale(0.8)
		self.Panel_Primeval:setPosition(cc.p(200,740))
		self.Panel_Primeval:getChildByName("Image_1"):setScale(0.8)
		self.Image_bg_0:setContentSize(cc.size(self.Image_bg_0:getContentSize().width, 660))
		self.Image_bg_0:setPositionY(self.MajorRolePublic:getWuqiPosY() + 99)
		self.Image_bg_6:setVisible(false)
	else
		self.Button_zuoqi:setPositionY(self.Button_zuoqi:getPositionY() + 35)
		self.Text_id:setPositionY(self.Button_zuoqi:getPositionY() - 97)
		self.Text_sins:setPositionY(self.Text_id:getPositionY() + 60)
		self.Image_name:setPositionY(self.Text_id:getPositionY() - 25)
		self.Panel_renwu:setScale(0.6)
		self.Panel_renwu:setPositionX(self.Panel_renwu:getPositionX())
		self.Panel_renwu:setPositionY(self.Panel_renwu:getPositionY() + 33)
		self.Image_bg_6:setVisible(false)
		self.Image_levelinfo:setPositionY(self.Image_levelinfo:getPositionY() - 32)
		self.Image_gang:setPositionY(self.Image_gang:getPositionY() - 32)
		self.Panel_shizhuang:setPosition(cc.p(510,780))
		self.Panel_shizhuang:getChildByName("Image_1"):setScale(0.8)
		self.Panel_Primeval:setPosition(cc.p(200,780))
		self.Panel_Primeval:getChildByName("Image_1"):setScale(0.8)
		self.Image_bg_0:setContentSize(cc.size(self.Image_bg_0:getContentSize().width, 600))
		self.Image_bg_0:setPositionY(self.MajorRolePublic:getWuqiPosY() + 10)
	end

	self.Image_id:setPositionY(self.Text_id:getPositionY() + 15)
	self.Image_sins:setPositionY(self.Text_sins:getPositionY() + 15)
	self.Button_help:setPositionY(self.Text_sins:getPositionY() + 15)
end

function MajorRoleSelf:autoContentSize(text, img)
	text:getAutoRenderSize()
	local textsz = text:getVirtualRendererSize()
	local imgsz = img:getContentSize()
	log("img width:" .. imgsz.width .. " text width:" .. textsz.width)
	img:setContentSize(cc.size(textsz.width - 80, imgsz.height))
end

function MajorRoleSelf:autoContentSize2(text, img)
	
	local delay = cc.DelayTime:create(0.2)
	local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
		text:getAutoRenderSize()
		local textsz = text:getVirtualRendererSize()
		local imgsz = img:getContentSize()
		--log("img width:" .. imgsz.width .. " text width:" .. textsz.width)
		local imgwidth = textsz.width/text.clearScale
		img:setContentSize(cc.size(imgwidth+40, imgsz.height))
		text:setPositionX((imgwidth+40) / 2 )
	end))
	text:runAction(sequence)
end

function MajorRoleSelf:onOperateItem(index,itemInfo)
	
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

function MajorRoleSelf:onEquipStrengthenEvaluate(evt)
	-- if self.EquipOperateLayer == nil then
	-- 	local openInfo = {type = 1}
	-- 	local EquipOperateLayer = require("cp.view.scene.world.equipoperate.EquipOperateLayer"):create(openInfo)
	-- 	EquipOperateLayer:setCloseCallBack(handler(self,self.refreshItem))
	-- 	self:addChild(EquipOperateLayer,1)
	-- 	self.EquipOperateLayer = EquipOperateLayer
	-- end
	cp.getManager("ViewManager").ShowEquipOperateLayer(1,handler(self,self.refreshItem))
end

function MajorRoleSelf:refreshItem(uuid)
	-- log(uuid)
	-- self.EquipOperateLayer:removeFromParent()
	-- self.EquipOperateLayer = nil
end

--以1280為基準，保持圖片上下端距離屏幕邊緣不變，進行Y拉伸，返回新的高度, 新的Y位置
function MajorRoleSelf:getScaleSize(scrHeight, imgHeight)
	if scrHeight < 1280 then
		return imgHeight - (1280 - scrHeight)
	elseif scrHeight == 1280 then
		return imgHeight
	elseif scrHeight > 1280 then
		return imgHeight + scrHeight - 1280
	end

end

function MajorRoleSelf:onSelectTipCallBack(buttonName, itemInfo)
	if itemInfo == nil then
		if self.selectEquipTip then
			self.selectEquipTip:removeFromParent()
			self.selectEquipTip = nil
		end
		return 
	end

	if buttonName == "Button_confirm" then
		local data = {uuid=itemInfo.uuid}
		self:doSendSocket(cp.getConst("ProtoConst").UseEquipReq,data)
		cp.getManager("ViewManager").gameTip("已裝備上" .. itemInfo.Name)
	elseif buttonName == "Button_close" then
		--不做任何處理
	end
	if self.selectEquipTip then
		self.selectEquipTip:removeFromParent()
		self.selectEquipTip = nil
	end
end


function MajorRoleSelf:showSelectEquipTip(itemInfo)
	if self.selectEquipTip then
		self.selectEquipTip:removeFromParent()
		self.selectEquipTip = nil
	end
	local selectEquipTip = require("cp.view.ui.tip.SelectEquipTip"):create(itemInfo)
    if selectEquipTip ~= nil then
        selectEquipTip:setClosedCallBack(handler(self,self.onSelectTipCallBack))
        selectEquipTip:setPosition(cc.p(display.cx,display.cy))

		self.rootView:addChild(selectEquipTip,2)
		self.selectEquipTip = selectEquipTip
	end
	
end

function MajorRoleSelf:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lilian" then
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        if cur_step == 10 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.3))
            table.insert(sequence,cc.CallFunc:create(
                function()
                    local info =
                    {
                        classname = "MajorRoleSelf",
                    }
                    self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                end)
            )
            self:runAction(cc.Sequence:create(sequence))
        end
    end
end

return MajorRoleSelf
