local BNode = require "cp.view.ui.base.BNode"
local LoginLayer = class("LoginLayer",BNode)

function LoginLayer:create(openInfo)
    local scene = LoginLayer.new(openInfo)
    return scene
end

--該界面UI註冊的事件偵聽
function LoginLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function LoginLayer:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/login_channel.csb") 
	self:addChild(self.rootView)

	local childConfig = {
	  ["Panel_1"] = {name = "Panel_1"},
	  ["Panel_1.Panel_2"] = {name = "Panel_2"},
	  ["Panel_1.Panel_2.Button_login"] = {name = "Button_login",click = "onLoginClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	
	self.rootView:setContentSize(display.size)
	cp.getManager("ViewManager").addModalByDefaultImage(self)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
end

function LoginLayer:onEnterScene()

end

--點擊登錄按鈕,重新登錄
function LoginLayer:onLoginClick(sender)
	local function login_callback( )
		log("login call back..")
	end
	cp.getManager("ChannelManager"):goLogin(login_callback)
end

function LoginLayer:setShowRegisterUICallback(cb)
	
end

return LoginLayer
