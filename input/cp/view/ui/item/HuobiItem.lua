local HuobiItem = class("HuobiItem",function() return ccui.Layout:create() end)

function HuobiItem:create( type, num, signed)
    local ret = HuobiItem.new()
    ret:init(type, num, signed)
    return ret
end

function HuobiItem:init( type, num, signed)

    self["Image_icon"] = nil                   --icon(貨幣圖標)
    self["Text_num"] = nil                     --數量

    -- self:setContentSize(cc.size(120,40))
    -- self:setAnchorPoint(0,0)
    -- self:setPosition(0,0)
    -- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- self:setBackGroundColor(cc.c3b(0, 0, 0))
    -- self:setBackGroundColorOpacity(204)


    display.loadSpriteFrames("uiplist/ui_common.plist")
    
    --icon(貨幣圖標)
    self["Image_icon"] = ccui.ImageView:create()
    self["Image_icon"]:setAnchorPoint(cc.p(0,0))
    self["Image_icon"]:setContentSize(cc.size(54,54))
    self["Image_icon"]:setName("Image_icon")
    self["Image_icon"]:ignoreContentAdaptWithSize(true)
    self:addChild(self["Image_icon"])

    --Text_num
	self["Text_num"] = ccui.Text:create()
	self["Text_num"]:ignoreContentAdaptWithSize(true)
	self["Text_num"]:setTextAreaSize({width = 0, height = 0})
	self["Text_num"]:setFontName("fonts/msyh.ttf")
	self["Text_num"]:setFontSize(20)
	self["Text_num"]:setTextColor(cc.c3b(255, 255 ,255))
	self["Text_num"]:setString("0")
    cp.getManager("ViewManager").textClearEnableOutline(self["Text_num"],{r = 0, g = 0, b = 0, a = 255}, 1)
	
	self["Text_num"]:setLayoutComponentEnabled(true)
	self["Text_num"]:setName("Text_num")
	self["Text_num"]:setCascadeColorEnabled(true)
	self["Text_num"]:setCascadeOpacityEnabled(true)
	self["Text_num"]:setAnchorPoint(cc.p(0,0.5))

	self["Text_num"]:setPosition(cc.p(45, 27))
	self:addChild(self["Text_num"],1)

    self:reset( type, num, signed)
end


function HuobiItem:reset( type, num, signed)
    self.type = type
    self.num = num
    
    display.loadSpriteFrames("uiplist/ui_common.plist")

    local iconPath = cp.getManager("ViewManager").getVirtualItemIcon(self.type)
    self["Image_icon"]:loadTexture(iconPath, ccui.TextureResType.plistType)

    self["Image_icon"]:setVisible(true)
    
    local tx = tostring(self.num)
    if signed then
        tx = self.num >= 0 and (" +" .. tostring(self.num)) or (" -" .. tostring(self.num))
    end  
    self["Text_num"]:setString(tx)

    -- local sz = self["Image_icon"]:getContentSize()
    -- local scale = self["Image_icon"]:getScale()
	-- self["Text_num"]:setPosition(cc.p(sz.width*scale-10, sz.height*scale/2))
end


function HuobiItem:getTotalWidth()
    local sz = self["Image_icon"]:getContentSize()
    self.Text_num:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
    local sz2 = self.Text_num:getVirtualRendererSize()
    return sz.width-10 + sz2.width
end

return HuobiItem