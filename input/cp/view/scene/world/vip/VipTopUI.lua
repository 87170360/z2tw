
local BNode = require "cp.view.ui.base.BNode"
local VipTopUI = class("VipTopUI",BNode)

function VipTopUI:create(openType)
	local node = VipTopUI.new(openType)
	return node
end

function VipTopUI:initListEvent()
	self.listListeners = {
        --請求VIP訊息返回
        [cp.getConst("EventConst").GetVipInfoRsp] = function(evt)
            self:resetInfo()
        end,

        --儲值返回
        [cp.getConst("EventConst").RechargeRsp] = function(evt)
            self:resetInfo()
        end,

        [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
            self:resetInfo()
        end,

        [cp.getConst("EventConst").GetVipGiftRsp] = function(evt)
            self:updateRedDot()
        end,
       
        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:updateRedDot()
        end,
	}
end

function VipTopUI:onInitView(openType)
    self.openType = openType
    
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_vip/uicsb_vip_top.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Panel_1"] = {name = "Panel_1"},
        ["Panel_item.Panel_1.Image_vip"] = {name = "Image_vip"},
        ["Panel_item.Panel_1.Image_progress_bg.Image_progress"] = {name = "Image_progress"},
        ["Panel_item.Panel_1.Text_next_vip"] = {name = "Text_next_vip"},
        ["Panel_item.Panel_1.Text_money"] = {name = "Text_money"},
        ["Panel_item.Panel_1.Text_value"] = {name = "Text_value"},
        ["Panel_item.Button_tequan"] = {name = "Button_tequan", click = "onUIButtonClick"},
        ["Panel_item.Button_chongzhi"] = {name = "Button_chongzhi", click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
	if "VIPMainUI" == self.openType then
        self.Button_tequan:setVisible(false)
        self.Button_chongzhi:setVisible(true)
        self.Panel_1:setPositionX(0)
    elseif "Recharge" == self.openType then
        self.Button_tequan:setVisible(false)
        self.Button_chongzhi:setVisible(false)
        self.Panel_1:setPositionX(60)
    end
end

function VipTopUI:onEnterScene()
    self:resetInfo()
    if "Recharge" == self.openType then
        self:updateRedDot()
    end
end

function VipTopUI:resetInfo()

    local vip = cp.getUserData("UserVip"):getValue("level")
    local current_exp = cp.getUserData("UserVip"):getValue("exp")
    -- local gold = cp.getUserData("UserVip"):getValue("gold")

    local file = string.format("ui_vip_module33_viptubiao%02d.png",vip)
    self.Image_vip:loadTexture(file, ccui.TextureResType.plistType)

    
    local config_other = cp.getManager("ConfigManager").getItemByKey("Other", "exp_per_yuan")
    local exp_per_yuan = config_other:getValue("IntValue")

    local nextVip = vip + 1
    if nextVip <= 15 then
        local config = cp.getManager("ConfigManager").getItemByKey("Vip", nextVip)
        local next_exp = config:getValue("Exp")

        self.Text_next_vip:setString("VIP" .. tostring(nextVip))
        self.Text_value:setString(tostring(current_exp) .. "/" .. tostring(next_exp))
        self.Text_money:setString( tostring((next_exp - current_exp)) )

        local percent = current_exp / next_exp
        self.Image_progress:setContentSize(319*percent,30)

    else
        self.Text_next_vip:setString("VIP" .. tostring(15))
        self.Text_value:setString( "" )
        self.Text_money:setString("0")
        self.Image_progress:setContentSize(319*1,30)
    end
end


function VipTopUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if "Button_tequan" == buttonName then
        if self.btnClickCallBack then
            self.btnClickCallBack()
        end
    elseif "Button_chongzhi" == buttonName then
        if self.btnClickCallBack then
            self.btnClickCallBack()
        end
    end
end

function VipTopUI:setButtonClickCallBack(cb)
    self.btnClickCallBack = cb
end


function VipTopUI:updateRedDot()
    local canGet = false
    local vip = cp.getUserData("UserVip"):getValue("level")
    if vip > 0 then
        canGet = cp.getUserData("UserVip"):getLibaoState(3,vip) == false
    end
    if canGet then
        cp.getManager("ViewManager").addRedDot(self.Button_tequan, cc.p(110,60))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_tequan)
    end
end


return VipTopUI
