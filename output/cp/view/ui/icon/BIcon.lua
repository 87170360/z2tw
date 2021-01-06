local BIcon = class("BIcon",function() return ccui.Layout:create() end)

function BIcon:create( cid)
    local ret = BIcon.new()
    ret:init()
    ret:reset(cid)
    return ret
end

function BIcon:init()
    --寫一下變量免得忘了有啥東西
    self["img_bg"] = nil                   --icon底
    self["img_icon"] = nil                   --icon
    self["img_icon_stencil"] = nil      --icon遮罩裁剪層
    self["img_top"] = nil                     --icon框

    --開搞
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(cc.size(100,100))

    display.loadSpriteFrames("uiplist/ui_icon.plist")
    
    --icon底
    self["img_bg"]  = ccui.ImageView:create()
    self["img_bg"] :setAnchorPoint(cc.p(0,0))
    self["img_bg"] :setName("img_bg")
    self:addChild(self["img_bg"])

    --icon
    self["img_icon_stencil"] = cc.Sprite:create()
    self["img_icon_stencil"]:setAnchorPoint(cc.p(0.5,0.5))
    self["img_icon"] = ccui.ImageView:create()
    self["img_icon"]:setAnchorPoint(cc.p(0.5,0.5))
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0.5)
    clipnode:addChild(self["img_icon"])
    clipnode:setStencil(self["img_icon_stencil"])
    clipnode:setPosition(cc.p(50,50))
    self["img_icon"]:setName("img_icon")
    self:addChild(clipnode)

    --icon框
    self["img_top"]  = ccui.ImageView:create()
    self["img_top"] :setAnchorPoint(cc.p(0,0))
    self["img_top"] :setName("img_top")
    self:addChild(self["img_top"])
end

function BIcon:reset(cid)
    self.cid = cid
    self.cfg = nil
    self.gtype = nil
    if self.cid then
        self.cfg,self.gtype = cp.getManager("GDataManager").getItemTableInfo(cid)
    end

    display.loadSpriteFrames("uiplist/ui_icon.plist")

    local iconPath = self:_getIconPath()
    local stencilPath = self:_getStencilPath()
    local bpath,tpath = self:_getQualPath()
    self["img_icon"]:loadTexture( iconPath  , ccui.TextureResType.localType)
	self["img_icon"]:setVisible(true)
    self["img_icon_stencil"]:setSpriteFrame(stencilPath) 
    self["img_bg"]:loadTexture(bpath, ccui.TextureResType.plistType)
    self["img_top"]:loadTexture(tpath, ccui.TextureResType.plistType)
end


function BIcon:resetIconTexture(texturePath,resType)
	if self["img_icon"] ~= nil then
		self["img_icon"]:loadTexture(texturePath, resType)
		self["img_icon"]:setVisible(true)
	end
end

function BIcon:resetQuality()
    display.loadSpriteFrames("uiplist/ui_icon.plist")
    local bpath,tpath =  "ui_icon_k10.png","ui_icon_k11.png"
    self["img_bg"]:loadTexture(bpath, ccui.TextureResType.plistType)
    self["img_top"]:loadTexture(tpath, ccui.TextureResType.plistType)
end

function BIcon:setIconShader(shadername)
	if self["img_icon"] ~= nil then
		cp.getManager("ViewManager").setShader(self["img_icon"], shadername)
	end
end

function BIcon:_getStencilPath()
    local GameConst = cp.getConst("GameConst")
    local path 
    if self.gtype == GameConst.gift_type_g1 
      or self.gtype == GameConst.gift_type_g2
      or self.gtype == GameConst.gift_type_g3
      or self.gtype == GameConst.gift_type_g4
      or self.gtype == GameConst.gift_type_g5
      or self.gtype == GameConst.gift_type_g6
      or self.gtype == GameConst.gift_type_g8
      or self.gtype == GameConst.gift_type_g9
    then
        path = "ui_icon_k0.png"
    elseif self.gtype == GameConst.gift_type_g7 then
        path = "ui_icon_k2.png"
    else
        path = "ui_icon_k0.png"
    end
    return path
end

function BIcon:_getIconPathByCid(cid)
    local cfg,gtype = cp.getManager("GDataManager").getItemTableInfo(cid)
    local GameConst = cp.getConst("GameConst")
    local path = nil
    if gtype == GameConst.gift_type_g1 then
        path = "img/icon/item/jinglingqiu/"..cid..".png"
    elseif gtype == GameConst.gift_type_g2 then
        path = "img/icon/item/huifu/"..cid..".png"
    elseif gtype == GameConst.gift_type_g3 then
        path = "img/icon/item/xiedai/"..cid..".png"
    elseif gtype == GameConst.gift_type_g4 then
        path = "img/icon/item/teshu/"..cid..".png"
    elseif gtype == GameConst.gift_type_g5 then
        path = "img/icon/item/jinhua/"..cid..".png"
    elseif gtype == GameConst.gift_type_g6 then
        local propId = cfg:getValue("prop")
        path = "img/icon/item/michuanji/"..propId..".png"
    elseif gtype == GameConst.gift_type_g7 then
        local tcid = cfg:getValue("compose")
        path = self:_getIconPathByCid(tcid)
        -- path = "img/icon/item/suipian/"..cid..".png"
    elseif gtype == GameConst.gift_type_g8 then
        path = "img/icon/sprite/sprite_icon/"..cid..".png"
    elseif gtype == GameConst.gift_type_g9 then
        path = "img/icon/item/huobi/"..cid..".png"
    end
    return path
end

function BIcon:_getIconPath()
    return self:_getIconPathByCid(self.cid)
end

function BIcon:_getQualPath()
    local GameConst = cp.getConst("GameConst")
    local bpath = nil
    local tpath = nil
    if self.cfg == nil then
        --self.cfg,self.gtype = cp.getManager("GDataManager").getItemTableInfo(cid)
        return "ui_icon_k10.png","ui_icon_k11.png"
    end
    local qual = self.cfg:getValue("qual")
    
    if self.gtype == GameConst.gift_type_g1 
      or self.gtype == GameConst.gift_type_g2
      or self.gtype == GameConst.gift_type_g3
      or self.gtype == GameConst.gift_type_g4
      or self.gtype == GameConst.gift_type_g5
      or self.gtype == GameConst.gift_type_g6
      or self.gtype == GameConst.gift_type_g8
      or self.gtype == GameConst.gift_type_g9
    then
        if  qual == GameConst.qual_s1 then
            bpath = "ui_icon_k10.png"
            tpath = "ui_icon_k11.png"
        elseif qual==GameConst.qual_s2 then
            bpath = "ui_icon_k20.png"
            tpath = "ui_icon_k21.png"
        elseif qual==GameConst.qual_s3 then
            bpath = "ui_icon_k30.png"
            tpath = "ui_icon_k31.png"
        elseif qual==GameConst.qual_s4 then
            bpath = "ui_icon_k40.png"
            tpath = "ui_icon_k41.png"
        elseif qual==GameConst.qual_s5 then
            bpath = "ui_icon_k50.png"
            tpath = "ui_icon_k51.png"
        elseif qual==GameConst.qual_s6 then
            bpath = "ui_icon_k60.png"
            tpath = "ui_icon_k61.png"
        elseif qual==GameConst.qual_s7 then
            bpath = "ui_icon_k70.png"
            tpath = "ui_icon_k71.png"
        elseif qual==GameConst.qual_s8 then
            bpath = "ui_icon_k80.png"
            tpath = "ui_icon_k81.png"
        else
            bpath = "ui_icon_k10.png"
            tpath = "ui_icon_k11.png"
        end
    elseif self.gtype == GameConst.gift_type_g7 then
        if  qual == GameConst.qual_s1 then
            bpath = "ui_icon_k12.png"
            tpath = "ui_icon_k13.png"
        elseif qual==GameConst.qual_s2 then
            bpath = "ui_icon_k22.png"
            tpath = "ui_icon_k23.png"
        elseif qual==GameConst.qual_s3 then
            bpath = "ui_icon_k32.png"
            tpath = "ui_icon_k33.png"
        elseif qual==GameConst.qual_s4 then
            bpath = "ui_icon_k42.png"
            tpath = "ui_icon_k43.png"
        elseif qual==GameConst.qual_s5 then
            bpath = "ui_icon_k52.png"
            tpath = "ui_icon_k53.png"
        elseif qual==GameConst.qual_s6 then
            bpath = "ui_icon_k62.png"
            tpath = "ui_icon_k63.png"
        elseif qual==GameConst.qual_s7 then
            bpath = "ui_icon_k72.png"
            tpath = "ui_icon_k73.png"
        elseif qual==GameConst.qual_s8 then
            bpath = "ui_icon_k82.png"
            tpath = "ui_icon_k83.png"
        else
            bpath = "ui_icon_k12.png"
            tpath = "ui_icon_k13.png"
        end
    end
    return bpath,tpath
end

function BIcon:getImgBg()
    return self["img_bg"]
end

function BIcon:getImgIcon()
    return self["img_icon"]
end

function BIcon:getImgStencil()
    return self["img_icon_stencil"]
end

function BIcon:getImgTop()
    return self["img_top"]
end

function BIcon:resetToNotFoundState()
	self:resetQuality()
    display.loadSpriteFrames("uiplist/ui_pokedex.plist")
    self:resetIconTexture("ui_pokedex_13.png",ccui.TextureResType.plistType)

	--icon:setIconShader(cp.getConst("ShaderConst").GrayShader)
end

function BIcon:resetToNone()
	self:resetQuality()
    if self["img_icon"] ~= nil then
		self["img_icon"]:setVisible(false)
	end
	--icon:setIconShader(cp.getConst("ShaderConst").GrayShader)
end

return BIcon