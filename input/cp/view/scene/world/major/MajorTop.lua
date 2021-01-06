local BLayer = require "cp.view.ui.base.BLayer"
local MajorTop = class("MajorTop",BLayer)

function MajorTop:create()
	local layer = MajorTop.new()
	return layer
end

function MajorTop:initListEvent()
	self.listListeners = {
	  --更新虛擬貨幣
        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
            self:onUpdateCurrencyRsp()
        end,

        --更新人物全屬性
        [cp.getConst("EventConst").GetRoleRsp] = function(evt)
            self:onEnterScene()
        end,

        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:onEnterScene()
        end,

        [cp.getConst("EventConst").ChangeFaceRsp] = function(evt)
            self["Image_TouXiang"]:loadTexture("img/model/head/" .. evt.face .. ".png", UI_TEX_TYPE_LOCAL)
        end,

        [cp.getConst("EventConst").RechargeRsp] = function(evt)
            self.Text_Vip:setString(evt.vipLevel)
        end,
        
        [cp.getConst("EventConst").GetVipGiftRsp] = function(evt)
            self:vipShow(true)
        end,
    
        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:vipShow(true)
        end,
    
	}
end

function MajorTop:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_top.csb") 
	self:addChild(self.rootView)

	local childConfig = {
    ["Panel_top"] = {name = "Panel_top"},
    
    ["Panel_top.Text_ZhanLi"] = {name = "Text_ZhanLi"},
    ["Panel_top.Text_JinBi"] = {name = "Text_JinBi"},
    ["Panel_top.Text_YinBi"] = {name = "Text_YinBi"},
    ["Panel_top.Text_TiLi"] = {name = "Text_TiLi"},
    ["Panel_top.Text_TiLi_Max"] = {name = "Text_TiLi_Max"},
    
    ["Panel_top.Text_Name"] = {name = "Text_Name"},
    ["Panel_top.Text_level"] = {name = "Text_level"},
    ["Panel_top.Text_JieJi"] = {name = "Text_JieJi"},
    ["Panel_top.Image_jingjie"] = {name = "Image_jingjie"},

    ["Panel_top.Image_TouXiang"] = {name = "Image_TouXiang",click = "onTouXiangClick",clickScale=1},
    
    ["Panel_top.Button_vip"] = {name = "Button_vip",click = "onUIButtonClick"},
    ["Panel_top.Button_vip.Text_Vip"] = {name = "Text_Vip"},
    ["Panel_top.Button_JinBi"] = {name = "Button_JinBi",click = "onUIButtonClick"},
    ["Panel_top.Button_YinBi"] = {name = "Button_YinBi",click = "onUIButtonClick"},
    ["Panel_top.Button_TiLi"] = {name = "Button_TiLi",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
  
    local csbSize = cc.size(720,1280)
    cp.getManager("ViewManager").adapterCSNode(self["Panel_top"] , csbSize, display.center_top)
end

function MajorTop:vipShow(show)
    self["Button_vip"]:setVisible(show)

    local function updateRedDot()
        local canGet = false
        local vip = cp.getUserData("UserVip"):getValue("level")
        if vip > 0 then
            canGet = cp.getUserData("UserVip"):getLibaoState(3,vip) == false
        end
        if canGet then
            cp.getManager("ViewManager").addRedDot(self.Button_vip, cc.p(145,45))
        else
            cp.getManager("ViewManager").removeRedDot(self.Button_vip)
        end
    end

    updateRedDot()
end

function MajorTop:onEnterScene()
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local roleconf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", majorRole["level"])
    --log("MajorTop:onEnterScene() 111")
    --dump(majorRole)
    --log("MajorTop:onEnterScene() 222")
	--dump(roleconf)
	self["Text_ZhanLi"]:setString("" .. majorRole["fight"])
	self["Text_JinBi"]:setString("" .. majorRole["gold"])
	self["Text_YinBi"]:setString("" .. majorRole["silver"])
	self["Text_TiLi"]:setString("" .. majorRole["physical"])
	self["Text_TiLi_Max"]:setString("" .. roleconf:getValue("PhysicalMax"))
    self["Text_Name"]:setString(majorRole["name"])
    local vip = cp.getUserData("UserVip"):getValue("level")
    self["Text_Vip"]:setString("" .. vip)

	--階級訊息
	local hierarchyInfo = cp.getManager("GDataManager"):getHierarchyInfo(majorRole.career, majorRole.gangRank, majorRole.hierarchy)
  	self["Text_JieJi"]:setString(hierarchyInfo)
    local jingjie = math.min(majorRole.level,50)
	self["Image_jingjie"]:loadTexture("img/icon/jingjie/jingjie_" .. tostring(jingjie) ..".png", ccui.TextureResType.localType)
    self["Text_level"]:setString("LV."..majorRole["level"])
  
    majorRole.face = majorRole.face or "head_1001"
    self["Image_TouXiang"]:loadTexture("img/model/head/" .. majorRole.face .. ".png", UI_TEX_TYPE_LOCAL)
  
    self:vipShow(true)
end

function MajorTop:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if "Button_vip"  == buttonName then
        self:dispatchViewEvent(cp.getConst("EventConst").open_vip_view,true)
    elseif "Button_JinBi"  == buttonName then
        cp.getManager("ViewManager").showRechargeUI()
    elseif "Button_YinBi"  == buttonName then
        cp.getManager("ViewManager").showSilverConvertUI()
    elseif "Button_TiLi"  == buttonName then
        cp.getManager("ViewManager").showBuyPhysicalUI()
    end
end

function MajorTop:onUpdateCurrencyRsp()
    self:onEnterScene()
end

function MajorTop:onTouXiangClick()
    self:dispatchViewEvent(cp.getConst("EventConst").open_face_change_view,true)
end

return MajorTop
