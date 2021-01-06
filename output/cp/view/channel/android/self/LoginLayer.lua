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
	self:loadCSB()
	self:initTextField()
end

--初始化UI控件
function LoginLayer:loadCSB()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/login.csb") 
	self:addChild(self.rootView)

	local childConfig = {
	  ["Panel_1"] = {name = "Panel_1"},
	  ["Panel_1.Panel_2"] = {name = "Panel_2"},
	  
	  ["Panel_1.Panel_2.Button_login"] = {name = "Button_login",click = "onLoginClick"},
	  ["Panel_1.Panel_2.Button_register"] = {name = "Button_register",click = "onRegisterClick"},
	  ["Panel_1.Panel_2.Button_guest"] = {name = "Button_guest",click = "onGuestClick"},
	  ["Panel_1.Panel_2.TextField_ac"] = {name = "TextField_ac" },
	  ["Panel_1.Panel_2.TextField_pwd"] = {name = "TextField_pwd" },
	  ["Panel_1.Panel_2.Image_showpwd_flag"] = {name = "Image_showpwd_flag",click = "onPasswordShowStateClick"},
	  ["Panel_1.Panel_2.Image_showpwd"] = {name = "Image_showpwd",click = "onPasswordShowStateClick"},
	  ["Panel_1.Panel_2.Button_down"] = {name = "Button_down",click = "onDownClick"},
	  ["Panel_1.Panel_2.ListView_account"] = {name = "ListView_account"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_pwd,"pwdInputBox",nil)
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_ac,"pwdInputBox",nil)
	
	self.rootView:setContentSize(display.size)
	cp.getManager("ViewManager").addModalByDefaultImage(self)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self["Button_down"]:setVisible(false)
	self["ListView_account"]:setVisible(false)

	local dtext = cp.getManager("GDataManager"):getTextFormat("default_input")
	self["TextField_ac"]:setPlaceHolder(dtext)	
	self["TextField_pwd"]:setPlaceHolder(dtext)
end

function LoginLayer:onEnterScene()

end

function LoginLayer:onPasswordShowStateClick(sender)
	local flag = self["TextField_pwd"]:isPasswordEnabled()
	self["TextField_pwd"]:setPasswordEnabled(not flag)

	local text = self["TextField_pwd"]:getStringValue()
	self["TextField_pwd"]:setString(text)

	local filePath = "ui_login_module01_log_miss_b.png"
	if flag then
		filePath = "ui_login_module01_log_miss_a.png"
	end
	self["Image_showpwd_flag"]:loadTexture(filePath, ccui.TextureResType.plistType)

end

-- if have account,set it
function LoginLayer:initTextField()

	local accountArr = cp.getManager("GDataManager"):getAccountList()
	if table.nums(accountArr) > 0 then
		self["Button_down"]:setVisible(true)
	end	

	local lastAccount = cp.getManager("GDataManager"):getLastAccount()
	if lastAccount then
		self["TextField_ac"]:setString(lastAccount[1])
		self["TextField_pwd"]:setString(lastAccount[2])
	else
		if table.nums(accountArr) > 0 then
			self["TextField_ac"]:setString(accountArr[1][1])
			self["TextField_pwd"]:setString(accountArr[1][2])
		end	
	end

end

--點擊登錄按鈕
function LoginLayer:onLoginClick(sender)

	local account = self["TextField_ac"]:getString()
	local password = self["TextField_pwd"]:getString()
	
	if string.len(account) == 0 then
		cp.getManager("ViewManager").gameTip("請輸入賬號")
		return
	end
	if string.len(password) == 0 then
		cp.getManager("ViewManager").gameTip("請輸入密碼")
		return
	end
	
	cp.getManager("GDataManager"):saveLastAccount({ account, password })

	local msg = {}
	msg.account = account
	msg.password = password
	cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").LoginReq, msg)

	if self.onBtnClickCallback ~= nil then
		local info = {account = account, password = password}
		self.onBtnClickCallback("Button_login",info)
	end
end

function LoginLayer:onRegisterClick(sender)
	if self.onBtnClickCallback ~= nil then
		local info = {}
		self.onBtnClickCallback("Button_register",info)
	end
end

--點擊遊客登錄按鈕
function LoginLayer:onGuestClick(sender)
	if self.onBtnClickCallback ~= nil then
		local info = {}
		self.onBtnClickCallback("Button_guest",info)
	end
end

--帳號下拉列表
function LoginLayer:onDownClick(sender)
	
	self["ListView_account"]:setVisible(not self["ListView_account"]:isVisible())
	self["ListView_account"]:removeAllItems()

	local accountList = cp.getManager("GDataManager"):getAccountList()
	for _, v in pairs(accountList) do
		local layout = ccui.Layout:create()
		layout:setAnchorPoint(0,0)
		layout:setContentSize(cc.size(362, 36))
		--layout:setBackGroundImage("ui_login_module01_logo_box03.png", ccui.TextureResType.plistType)
		layout:setTouchEnabled(true)
		local function touchEvent(touch, etype)
			if etype == ccui.TouchEventType.ended then
				--選擇帳號
				self["TextField_ac"]:setString(v[1])
				self["TextField_pwd"]:setString(v[2])
				self["ListView_account"]:setVisible(false)
			end
		end
		layout:addTouchEventListener(touchEvent)

		local textLabel = ccui.Text:create()
		textLabel:setText(v[1])
		textLabel:setFontName("fonts/msyh.ttf") 
		textLabel:setAnchorPoint(cc.p(0, 0.5))
		textLabel:setTextColor(cc.c3b(255, 255, 255))
		textLabel:setFontSize(25)
		textLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		textLabel:setPosition(cc.p(10, 15))

		layout:addChild(textLabel)
		self["ListView_account"]:pushBackCustomItem(layout)

	end

end

function LoginLayer:setBtnClickCallBack(cb)
  	self.onBtnClickCallback = cb
end

return LoginLayer
