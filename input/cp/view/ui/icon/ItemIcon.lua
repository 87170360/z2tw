-- 物品(含裝備)及武學圖標框的基類，兩者共有屬性, 不包含點擊事件處理
local ItemIcon = class("ItemIcon",function() return cc.Node:create() end)

-- itemInfo = {Name = "表格中對應的Name", Icon = "表格中對應的Icon", num = "數量", Colour ="品質", hideName = "true/false 是否隱藏名字"}
function ItemIcon:create(itemInfo)
	local ret = ItemIcon.new()
	ret:init(itemInfo)
    return ret
end

function ItemIcon:init(itemInfo,isInBag)	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_item.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_item"] = {name = "Panel_item"}, --click = "onItemClick", clickScale = 1},
        ["Panel_item.Image_bg"] = {name = "Image_bg"},
        ["Panel_item.Image_icon"] = {name = "Image_icon"},
		["Panel_item.Image_quality"] = {name = "Image_quality"},
		["Panel_item.Text_name"] = {name = "Text_name"},
		["Panel_item.Text_lv"] = {name = "Text_lv"},
		["Panel_item.Image_num"] = {name = "Image_num"},
		["Panel_item.Image_num.Text_num"] = {name = "Text_num"},
		["Panel_item.Image_suipian"] = {name = "Image_suipian"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self.Image_icon:ignoreContentAdaptWithSize(true)
	
	self.Image_suipian:setVisible(false)
	self.Image_num:setVisible(false)
	self.Text_lv:setVisible(false)
	self.itemInfo = itemInfo
	
	local sz = self.Panel_item:getContentSize()
	self.Panel_item:setPosition(0,0)

	-- self.Panel_item:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	-- self.Panel_item:setBackGroundColor(cc.c3b(0,0,255))
	-- self.Panel_item:setBackGroundColorOpacity(200)

	self.isInBag = isInBag
	self:setItemInfo()
	
	local function onTouch(sender, event)
        if event == cc.EventCode.BEGAN then
	
        elseif event == cc.EventCode.MOVED then 
  
		elseif event == cc.EventCode.ENDED then
			local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onItemClick(sender)
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效    
            end
        elseif event == cc.EventCode.CANCELLED then

        end
    end
    if self.Panel_item.addTouchEventListener ~= nil then
        self.Panel_item:addTouchEventListener(onTouch)
    end
end


function ItemIcon:getContentSize()
	if self.isInBag then
		return self.bg:getContentSize()
	else
		return self.Panel_item:getContentSize()
	end
end

--留給繼承的類來調用
function ItemIcon:setItemInfo()
	self.Image_suipian:setVisible(false)
	self.Text_name:setVisible(false)
	self.Text_lv:setVisible(false)
	if self.isInBag then
		self:addBagItemBg()
	end
	if self.Image_hierarchy ~= nil then
		self.Image_hierarchy:removeFromParent()	
		self.Image_hierarchy = nil
	end
	if self.itemInfo == nil then
		return
	end
	
	display.loadSpriteFrames("uiplist/ui_common.plist")

	-- 有些界面使用了name和icon還未改過來。
	if self.itemInfo.Name == nil or self.itemInfo.Name == "" then
		self.itemInfo.Name = self.itemInfo.name
	end
	if self.itemInfo.Icon == nil or self.itemInfo.Icon == "" then
		self.itemInfo.Icon = self.itemInfo.icon
	end

	self.Text_name:setString(self.itemInfo.Name) -- "物品名字1"
	
	if self.itemInfo.Icon ~= nil and self.itemInfo.Icon ~= "" then
		self.Image_icon:loadTexture(self.itemInfo.Icon, ccui.TextureResType.localType) --"img/icon/item/1.png"
		
		self.Image_icon:setVisible(true)
		if not cc.FileUtils:getInstance():isFileExist(self.itemInfo.Icon) then
			self.Image_icon:setVisible(false)
		end
	else
		self.Image_icon:setVisible(false)
	end
	
	local num = nil
	if self.itemInfo ~= nil and self.itemInfo.num ~= nil then
		num = tonumber(self.itemInfo.num)
	end

	--物品有Type,技能沒有
	local needHierarchy = false
	local PlayerHierarchy = 0
	if self.itemInfo.Type == 2 then --碎片
		local needNum = 0
		local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", self.itemInfo.id)
		local str = string.split(conf:getValue("Extra"),"=")
		if str ~= nil and tonumber(str[2]) ~= nil then
			needNum = tonumber(str[2])
		end
		if self.itemInfo.SubType == nil then
			self.itemInfo.SubType = conf:getValue("SubType")
		end
		if self.itemInfo.SubType == 4 then
			needHierarchy = true
			local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", tonumber(str[1]))
			if conf2 == nil then 
				log("item not exist id = " .. self.itemInfo.id)
			end
			PlayerHierarchy = conf2:getValue("PlayerHierarchy")
			PlayerHierarchy = PlayerHierarchy or 0
		end
		
		self.Image_num:setVisible(num ~= nil)
		if num then
			if self.isInBag then
				self.Text_num:setString(tostring(num) .. "/" .. tostring(needNum))
				local color = num >= needNum and cp.getConst("GameConst").QualityTextColor[1] or cp.getConst("GameConst").QualityTextColor[6] 
				self.Text_num:setTextColor(color)
			else
				self.Text_num:setString(tostring(num))
			end
		end
	elseif self.itemInfo.Type == 1 then --裝備 顯示強化等級
		needHierarchy = true
		local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", self.itemInfo.id)
		if conf2 == nil then 
			log("item not exist id = " .. self.itemInfo.id)
		end
		PlayerHierarchy = conf2:getValue("PlayerHierarchy")
		PlayerHierarchy = PlayerHierarchy or 0
		local showStrengthenLevel = self.itemInfo.strengthenLevel ~= nil and self.itemInfo.strengthenLevel > 0
		if not showStrengthenLevel then
			self.itemInfo.showNum = nil
		end

		if self.itemInfo.shopModel then
			self.Image_num:setVisible(self.itemInfo.num>1)
			self.Text_num:setString(tostring(self.itemInfo.num))
			self.Text_num:setTextColor(cp.getConst("GameConst").QualityTextColor[1])
			self.Text_lv:setVisible(false)
		else
			self.Image_num:setVisible(false)
			self.Text_lv:setVisible(showStrengthenLevel)
			self.Text_lv:setString("LV." .. tostring(self.itemInfo.strengthenLevel or 0))
		end
		
	else
		self.Image_num:setVisible(num ~= nil and num > 1)
		self.Text_num:setString(tostring(num))
		self.Text_num:setTextColor(cp.getConst("GameConst").QualityTextColor[1])
	end

	if self.itemInfo.Type == 8 then --虛擬貨幣 通過SubType判斷是否是混元
		local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", self.itemInfo.id)
		if self.itemInfo.SubType == nil then
			self.itemInfo.SubType = conf:getValue("SubType")
		end
	end

	if needHierarchy and PlayerHierarchy > 0 then
		
		local image = ccui.ImageView:create()
		image:setAnchorPoint(cc.p(0.5,0.5))
		image:setPosition(20,76)
		image:loadTexture("ui_common_tishi_jiaobiao.png", ccui.TextureResType.plistType)
		self.Image_hierarchy = image
		self.Panel_item:addChild(self.Image_hierarchy,1)
		local Text_hierarchy = ccui.Text:create()
		Text_hierarchy:setText(cp.getConst("CombatConst").NumberZh_Cn[PlayerHierarchy] .. "\n階")
		Text_hierarchy:setFontName("fonts/msyh.ttf") 
		Text_hierarchy:setAnchorPoint(cc.p(0.5, 0.5))
		Text_hierarchy:setTextColor(cc.c3b(212, 198, 132))
		Text_hierarchy:setFontSize(14)
		-- Text_hierarchy:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		Text_hierarchy:setPosition(cc.p(18, 36))
		self.Image_hierarchy:addChild(Text_hierarchy)
	end

	if self.itemInfo.showNum ~= nil and num ~= nil then
		self.Image_num:setVisible(true)
	end
	if self.itemInfo.showNum ~= nil and self.itemInfo.showNum == false then
		self.Image_num:setVisible(false)
	end

	if self.itemInfo.level and self.itemInfo.level > 0 then --技能顯示技能等級
		self.Image_num:setVisible(false)
		self.Text_lv:setVisible(true)
		self.Text_lv:setString("LV." .. tostring(self.itemInfo.level))
	end

	-- 品級(6、紅色   5、金色   4、紫色   3、藍色   2、綠色   1、白色)
	if self.itemInfo.Colour == nil or tonumber(self.itemInfo.Colour) == nil then
		self.itemInfo.Colour = self.itemInfo.Hierarchy or 1 
	end 
	self.itemInfo.Colour = math.min(self.itemInfo.Colour,6)
	self.itemInfo.Colour  = math.max(self.itemInfo.Colour,1)
	
	-- self.Text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[self.itemInfo.Colour]) 
	cp.getManager("ViewManager").setTextQuality(self.Text_name,self.itemInfo.Colour)
	self.Text_name:enableOutline(cp.getConst("CombatConst").QualityOutlineC4b[self.itemInfo.Colour], 3)

	local path = cp.getConst("GameConst").QualityItemFrame[self.itemInfo.Colour]
	local path2 = cp.getConst("CombatConst").QualityBottomList[self.itemInfo.Colour]
	if self.itemInfo.iconType == "primeval" or (self.itemInfo.Type == 8 and self.itemInfo.SubType == 20) then
		display.loadSpriteFrames("uiplist/ui_primeval.plist")
		path = cp.getConst("CombatConst").PrimevalColorList[self.itemInfo.Colour]
		self.Image_quality:ignoreContentAdaptWithSize(true)
		path2 = ""
	end
	self.Image_quality:loadTexture(path, ccui.TextureResType.plistType)
	self.Image_bg:loadTexture(path2, ccui.TextureResType.plistType)
	self.Image_bg:setVisible(path2 ~= nil and path2 ~= "")
	if self.itemInfo.scale and tonumber(self.itemInfo.scale) > 0 then
		self.Image_quality:setScale(self.itemInfo.scale)
		self.Image_icon:setScale(self.itemInfo.scale)
		self:resetNamePosY(1)
	end
	if self.itemInfo.hideName then
		self.Text_name:setVisible(false)
	else
		self.Text_name:setVisible(true)
	end

	self.Image_suipian:setVisible(self.itemInfo.Type == 2)
end

--留給繼承的類來調用
function ItemIcon:reset(itemInfo,isInBag)
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self.itemInfo = itemInfo
	self.isInBag = isInBag
	if self.Image_flag ~= nil then
		self.Image_flag:removeFromParent()	
	end
	self.Image_flag = nil
	if self.Image_hierarchy ~= nil then
		self.Image_hierarchy:removeFromParent()	
	end
	self.Image_hierarchy = nil
	self:addFlagNew(nil)
	if itemInfo == nil then
		self.Text_name:setVisible(false)
		self.Image_num:setVisible(false)
		self.Image_icon:setVisible(false)
		self.Image_suipian:setVisible(false)
		self.Image_quality:loadTexture("ui_common_quality_whitebox.png", ccui.TextureResType.plistType)
		local path2 = cp.getConst("CombatConst").QualityBottomList[1]
		self.Image_bg:loadTexture(path2, ccui.TextureResType.plistType)
		self.Text_lv:setVisible(false)
	else
		self.Text_name:setVisible(true)
		self.Image_num:setVisible(true)
		self.Image_icon:setVisible(true)
		self:setItemInfo()
	end

	if self.isInBag then
		self:resetNamePosY(-18)
		self:setPositionY(18)
	end
end

function ItemIcon:setItemClickCallBack(cb)
	self.itemClickCallBack = cb
	self["Panel_item"]:setTouchEnabled(cb ~= nil)
end

function ItemIcon:onItemClick(sender)
	dump(self.itemInfo)
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self.itemInfo)
	end
end

function ItemIcon:addFlag(flagType)
	if flagType == nil then
		if self.Image_flag ~= nil then
			self.Image_flag:removeFromParent()	
		end
		self.Image_flag = nil
		return
	end
	if self.Image_flag == nil then
		local image = ccui.ImageView:create()
		image:setAnchorPoint(cc.p(0,1))
		image:ignoreContentAdaptWithSize(true)
		image:setPosition(1,101)
		self.Image_flag = image
		self.Panel_item:addChild(self.Image_flag,2)
	end

	local imagePic = {
		["kexuexi"] = "ui_common_kexue.png",
		["kehecheng"] = "ui_common_hecheng.png",
		["keshiyong"] = "ui_common_keyong.png",
		["shoutong"] = "ui_common_shoutong.png",
		["huodong"] = "ui_common_huodong2.png",
		["gailv"] = "ui_common_gailv.png",
		["yilingqu"] = "ui_common_yilingqu.png"
	}
	if imagePic[flagType] then
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(imagePic[flagType])
		if not spriteFrame then
			display.loadSpriteFrames("uiplist/ui_common.plist")
		end
		self.Image_flag:loadTexture(imagePic[flagType], UI_TEX_TYPE_PLIST)	
	end
end

function ItemIcon:resetNamePosY(posY)
	self.Text_name:setPositionY(posY)
end

function ItemIcon:resetNum(num)
	self.Text_num:setString(tostring(num))
end

function ItemIcon:resetNumColor(color)
	self.Text_num:setTextColor(color)
end

function ItemIcon:setPositionY(posY)
	self.Panel_item:setPositionY(posY)
end

function ItemIcon:setItemSelected(isSelected)
    if self.animNode == nil then
        self.animNode = cp.getManager("ViewManager").createSpineEffect("xiaohao")
        self.animNode:setAnimation(0, "xiaohao", true)
        
        local sz = self.Panel_item:getContentSize()
        self.animNode:setPosition(cc.p(sz.width/2,-10))
        self.Panel_item:addChild(self.animNode, 3)        
    end

    self.animNode:setVisible(isSelected)
end


function ItemIcon:addBagItemBg()
	if self.bg  == nil then
		local image = ccui.ImageView:create()
		image:setAnchorPoint(cc.p(0.5,0.5))
		image:loadTexture("ui_common_biankuangdi.png", ccui.TextureResType.plistType)
		self.rootView:addChild(image,-1)
		
		local sz = image:getContentSize()  -- 144,178
		image:setPosition(0,0)
		self.bg = image
	end
end

function ItemIcon:addFlagNew(newlyAcquired)
	if newlyAcquired then
		if self.newFlag == nil then
			local image = ccui.ImageView:create()
			image:setAnchorPoint(cc.p(0.5,0.5))
			image:setPosition(85,85)
			image:loadTexture("ui_common_xin.png", ccui.TextureResType.plistType)
			self.Panel_item:addChild(image,2)
			self.newFlag = image
		end
	else
		if self.newFlag then
			self.newFlag:removeFromParent()
			self.newFlag = nil
		end
	end
end



return ItemIcon
