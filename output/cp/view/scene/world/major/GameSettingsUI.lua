local BLayer = require "cp.view.ui.base.BLayer"
local GameSettingsUI = class("GameSettingsUI",BLayer)

function GameSettingsUI:create()
	local layer = GameSettingsUI.new()
	return layer
end

function GameSettingsUI:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,

	}
end

function GameSettingsUI:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_fight_record.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
        ["Panel_root.Panel_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Button_BackLogin"] = {name = "Button_BackLogin",click = "onUIButtonClick"},
        
        ["Panel_root.Panel_bg.Image_title.Text_title"] = {name = "Text_title"},
        ["Panel_root.Panel_bg.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.Panel_bg.ScrollView_1.Text_content"] = {name = "Text_content"},
        ["Panel_root.Panel_bg.ScrollView_1.CheckBox_music"] = {name = "CheckBox_music"},
        ["Panel_root.Panel_bg.ScrollView_1.CheckBox_effect"] = {name = "CheckBox_effect"},
        ["Panel_root.Panel_bg.ScrollView_1.TextField_Command"] = {name = "TextField_Command"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self:setPosition(cc.p(display.cx,display.cy))

    self.CheckBox_music:setTouchEnabled(true)
    self.CheckBox_music:addEventListener(
        function(sender,eventType)
            if eventType == ccui.CheckBoxEventType.selected then
                cp.getManager("AudioManager"):setSoundSwitch(true)
            elseif eventType == ccui.CheckBoxEventType.unselected then
                cp.getManager("AudioManager"):setSoundSwitch(false)
            end
        end
    )

    self.CheckBox_effect:setTouchEnabled(true)
    self.CheckBox_effect:addEventListener(
        function(sender,eventType)
            if eventType == ccui.CheckBoxEventType.selected then
                cp.getManager("AudioManager"):setEffectSwitch(true)
            elseif eventType == ccui.CheckBoxEventType.unselected then
                cp.getManager("AudioManager"):setEffectSwitch(false)
            end
        end
    )

    ccui.Helper:doLayout(self.rootView)

    self.TextField_Command:addEventListener(function(tf, event)
        if event == 1 then
            local command = self.TextField_Command:getString()
            if command == "" then return end
            local commandInfo = cp.getUtils("DataUtils").splitString(command, " :")
            
            local req = {}
            for i=2, #commandInfo do
                req[commandInfo[i][1]] = tonumber(commandInfo[i][2])
            end
            self:doSendSocket(cp.getConst("ProtoConst")[commandInfo[1][1]], req)
        end
    end)
end

function GameSettingsUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)

    if "Button_close"  == buttonName then
        if self.closeCallBack then
            self.closeCallBack()
        end
    elseif "Button_BackLogin" == buttonName then

        local function exitCallBack(params)
            if not (cp.getManualConfig("Channel").channel == "xiaomi" or cp.getManualConfig("Channel").channel == "xiaomi1") then
                cp.getManager("ViewManager").showGameMessageBox("系統消息","是否返回重新登錄",1,function()
                    cp.getManager("ViewManager").gameTip("返回到登錄界面")
                    cp.getManager("AppManager"):reLogin()
                end,nil)
            else
                cp.getManager("ViewManager").gameTip("返回到登錄界面")
                cp.getManager("AppManager"):reLogin()
            end
        end
        
        if device.platform == "android" and (cp.getManualConfig("Channel").channel == "xiaomi" or cp.getManualConfig("Channel").channel == "xiaomi1") then
        --cp.getManager("ViewManager").showGameMessageBox("系統消息","是否退出當前遊戲？",2,function()
            local args = {exitCallBack}
            local sig = "(I)V"
            local luaj = require("cocos.cocos2d.luaj")
            local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/MiSDK","miExit",args,sig) 
        --end,nil)
        else
            exitCallBack(nil)
        end
    end
end

function GameSettingsUI:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function GameSettingsUI:onEnterScene()
    local str = self:generateStrings()


    local txtSize = self.Text_content:getContentSize()
    local scale = self.Text_content.clearScale
    self.Text_content:setContentSize(cc.size(txtSize.width,0))
    self.Text_content:ignoreContentAdaptWithSize(false)
    self.Text_content:setString(str)
    self.Text_content:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
    local szNew = self.Text_content:getVirtualRendererSize()
    self.Text_content:setContentSize(cc.size(szNew.width,szNew.height))
    
    local sz = self["ScrollView_1"]:getInnerContainerSize()
    self.Text_content:setPositionY(sz.height)
    if szNew.height > 655 then
        self["ScrollView_1"]:setInnerContainerSize(cc.size(560,szNew.height+500))
        self.Text_content:setPositionY(szNew.height+500)
    end
    self["ScrollView_1"]:setTouchEnabled(true)
    self["ScrollView_1"]:jumpToTop()
    
    

    self.CheckBox_effect:setSelectedState(cp.getManager("AudioManager"):getEffectSwitch())
    self.CheckBox_music:setSelectedState(cp.getManager("AudioManager"):getSoundSwitch())

end

function GameSettingsUI:generateStrings()
    local str = ""
    str = str .. (string.format("當前分辨率: %0.2f x %0.2f", display.sizeInPixels.width, display.sizeInPixels.height))
    --[[
    str = str .. (string.format("# display.sizeInPixels(view:getFrameSize())         = {width = %0.2f, height = %0.2f}", display.sizeInPixels.width, display.sizeInPixels.height))
    str = str .. "\n" .. (string.format("# display.size(viewsize)       = {width = %0.2f, height = %0.2f}", display.size.width, display.size.height))

    str = str .. "\n"  .. (string.format("# display.visiblesize          = {width = %0.2f, height = %0.2f}", display.visiblesize.width, display.visiblesize.height))
    str = str .. "\n" .. (string.format("# display.viewsizeInPixel      = {width = %0.2f, height = %0.2f}", display.viewsizeInPixel.width, display.viewsizeInPixel.height))

    str = str .. "\n" .. (string.format("# display.old_size      = (%0.2f,%0.2f)", display.old_size.width,display.old_size.height))
    str = str .. "\n" .. (string.format("# display.old_framesize     = (%0.2f,%0.2f)", display.old_framesize.width,display.old_framesize.height))
    str = str .. "\n" .. (string.format("# display.bili               = %0.3f", display.bili))
    str = str .. "\n" .. (string.format("# display.scale2               = %0.3f", display.scale2))

    if device.platform == "android" then
        -- local screenSize = device:getDPI()
        -- str = str .. "\n" .. " dpi = " .. tostring(screenSize)

        local args = {}
        local luaj = require "cocos.cocos2d.luaj"
        local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
        local ok, ipStr = luaj.callStaticMethod(className,"getIp", args, "()Ljava/lang/String;")
     
        str = str .. "\n" .. " ipStr = " .. tostring(ipStr)

    end

    str = str .. "\n" .. (string.format("# display.width(viewsize)      = %0.2f", display.width))
    str = str .. "\n" .. (string.format("# display.height(viewsize)     = %0.2f", display.height))
    str = str .. "\n" .. (string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))

    str = str .. "\n" .. (string.format("# display.scaleX               = %0.2f", display.scaleX))
    str = str .. "\n" .. (string.format("# display.scaleY               = %0.2f", display.scaleY))

    str = str .. "\n" .. (string.format("# display.cx                   = %0.2f", display.cx))
    str = str .. "\n" .. (string.format("# display.cy                   = %0.2f", display.cy))
    str = str .. "\n" .. (string.format("# display.left                 = %0.2f", display.left))
    str = str .. "\n" .. (string.format("# display.right                = %0.2f", display.right))
    str = str .. "\n" .. (string.format("# display.top                  = %0.2f", display.top))
    str = str .. "\n" .. (string.format("# display.bottom               = %0.2f", display.bottom))
    
    str = str .. "\n" .. (string.format("# display.center               = {x = %0.2f, y = %0.2f}", display.center.x, display.center.y))
    ]]
	--str = str .. "\n" 
	return str
end

return GameSettingsUI
