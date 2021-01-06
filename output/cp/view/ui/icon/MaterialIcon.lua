
local MaterialIcon = class("MaterialIcon",function() return ccui.Layout:create() end)

function MaterialIcon:create(itemInfo)
    local ret = MaterialIcon.new()
    ret:init(itemInfo)
    return ret
end

function MaterialIcon:init(itemInfo)
	self.itemInfo = itemInfo

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_material.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_item"] = {name = "Panel_item"}, --click = "onItemClick", clickScale = 1},
        ["Panel_item.Image_bg"] = {name = "Image_bg"},
        ["Panel_item.Image_icon"] = {name = "Image_icon"},
		["Panel_item.Image_quality"] = {name = "Image_quality"},
		["Panel_item.Text_name"] = {name = "Text_name"},
		["Panel_item.Text_level"] = {name = "Text_level"},
		["Panel_item.Image_select"] = {name = "Image_select"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	--local sz = self.Panel_item:getContentSize()
    self:setContentSize(cc.size(140,140))--sz.width,sz.height))
    self:setAnchorPoint(0,0)
    self:setPosition(0,0)
    -- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- self:setBackGroundColor(cc.c3b(0,255,0))
    -- self:setBackGroundColorOpacity(104)
    self.Panel_item:setPosition(cc.p(0,140))

	self.Image_icon:ignoreContentAdaptWithSize(true)
	self.Image_select:setLocalZOrder(1)
	self.Image_select:setVisible(false)
	self.Text_level:setVisible(false)
    
    if self.itemInfo ~= nil then
		self:setItemInfo()
	end

	local function onTouch(sender, event)
        if event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onItemClick(sender)
                --cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效    
            end
        end
    end
    if self.Panel_item.addTouchEventListener ~= nil then
        self.Panel_item:addTouchEventListener(onTouch)
    end
end

function MaterialIcon:reset(itemInfo,isSelected)
    self.itemInfo = itemInfo
    self.Image_select:setVisible(false)
    self.Text_level:setVisible(false)
    self.Image_icon:setVisible(false)

    local Image_hierarchy = self.Panel_item:getChildByName("Image_hierarchy")  
    if Image_hierarchy ~= nil then
        Image_hierarchy:setVisible(false)
    end

	if itemInfo ~= nil then
        self:setItemInfo()
        self:setItemSelected(isSelected)
	end 
end

function MaterialIcon:setItemInfo()
	local iii = cp.getUserData("UserItem"):getItem(self.itemInfo.uuid)
	if self.itemInfo.Name == nil or self.itemInfo.Name == "" then
		self.itemInfo.Name = self.itemInfo.name
	end
	if self.itemInfo.Icon == nil or self.itemInfo.Icon == "" then
		self.itemInfo.Icon = self.itemInfo.icon
	end

	if self.itemInfo.Icon ~= nil and self.itemInfo.Icon ~= "" then
		self.Image_icon:loadTexture(self.itemInfo.Icon, ccui.TextureResType.localType) --"img/icon/item/1.png"
		
		self.Image_icon:setVisible(true)
		if not cc.FileUtils:getInstance():isFileExist(self.itemInfo.Icon) then
			self.Image_icon:setVisible(false)
		end
	else
		self.Image_icon:setVisible(false)
	end
    
    self.Text_level:setTextColor(cp.getConst("GameConst").QualityTextColor[1])
    self.Text_level:setVisible(self.itemInfo.strengthenLevel > 0)
    if self.itemInfo.strengthenLevel > 0 then
        self.Text_level:setString("LV." .. tostring(self.itemInfo.strengthenLevel))
    end
    if self.itemInfo.id >= 602 and self.itemInfo.id <= 607 then 
        self.Text_level:setVisible(false)
        -- self.Text_level:setString(tostring(self.itemInfo.num))
    end

    self.Text_name:setString(self.itemInfo.Name) -- "物品名字1"
	-- 品級(6、紅色   5、金色   4、紫色   3、藍色   2、綠色   1、白色)
	if self.itemInfo.Colour == nil or tonumber(self.itemInfo.Colour) == nil then
		self.itemInfo.Colour = 1 
	end 
	self.itemInfo.Colour = math.min(self.itemInfo.Colour,6)
	self.itemInfo.Colour  = math.max(self.itemInfo.Colour,1)
	
	-- display.loadSpriteFrames("uiplist/ui_common.plist")
	self.Text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[self.itemInfo.Colour])
	local path = cp.getConst("GameConst").QualityItemFrame[self.itemInfo.Colour]
    self.Image_quality:loadTexture(path, ccui.TextureResType.plistType)
    self.Image_select:setVisible(false)

    if self.itemInfo.Type == 1 then --裝備 顯示強化等級
        
        local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", self.itemInfo.id)
        local PlayerHierarchy = conf2:getValue("PlayerHierarchy")
        PlayerHierarchy = PlayerHierarchy or 0
        
        local Image_hierarchy = self.Panel_item:getChildByName("Image_hierarchy")
        local Text_hierarchy = nil
        if Image_hierarchy == nil then
            Image_hierarchy = ccui.ImageView:create()
            Image_hierarchy:setAnchorPoint(cc.p(0.5,0.5))
            Image_hierarchy:setPosition(20,84)
            Image_hierarchy:loadTexture("ui_common_tishi_jiaobiao.png", ccui.TextureResType.plistType)
            Image_hierarchy:setName("Image_hierarchy")
        
            Text_hierarchy = ccui.Text:create()
            
            Text_hierarchy:setFontName("fonts/msyh.ttf") 
            Text_hierarchy:setAnchorPoint(cc.p(0.5, 0.5))
            Text_hierarchy:setTextColor(cc.c3b(212, 198, 132))
            Text_hierarchy:setFontSize(14)
            -- Text_hierarchy:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            Text_hierarchy:setPosition(cc.p(18, 36))
            Image_hierarchy:addChild(Text_hierarchy)
            Text_hierarchy:setName("Text_hierarchy")
            self.Panel_item:addChild(Image_hierarchy)
        else
            Text_hierarchy = Image_hierarchy:getChildByName("Text_hierarchy")
        end
        if Text_hierarchy then
            Text_hierarchy:setString(cp.getConst("CombatConst").NumberZh_Cn[PlayerHierarchy] .. "\n階")
        end
        if Image_hierarchy then
            Image_hierarchy:setVisible(true)
        end
    else
        local Image_hierarchy = self.Panel_item:getChildByName("Image_hierarchy")  
        if Image_hierarchy ~= nil then
            if Image_hierarchy then
                Image_hierarchy:setVisible(false)
            end
            -- self.Panel_item:removeChildByName("Image_hierarchy")
        end
    end
end

function MaterialIcon:setItemSelected(isSelected)
    self["Image_select"]:setVisible(isSelected)
    
    if self.animNode == nil then
        self.animNode = cp.getManager("ViewManager").createSpineEffect("xiaohao")
        self.animNode:setAnimation(0, "xiaohao", true)
        -- self.animNode:registerSpineEventHandler(function(tbl)
        -- end, sp.EventType.ANIMATION_COMPLETE)
        local sz = self.Panel_item:getContentSize()
        self.animNode:setPosition(cc.p(sz.width/2,-10))
        self.Panel_item:addChild(self.animNode, 1)
        self.Image_select:setLocalZOrder(2)        
    end

    self.animNode:setVisible(isSelected)
end


function MaterialIcon:setItemClickCallBack(cb)
	self.itemClickCallBack = cb
	self["Panel_item"]:setTouchEnabled(cb ~= nil)
end

function MaterialIcon:onItemClick(sender)
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self,self.itemInfo)
    end
    -- self:setItemSelected(not self["Image_select"]:isVisible())
end

return MaterialIcon
