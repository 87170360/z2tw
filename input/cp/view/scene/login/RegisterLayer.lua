local BNode = require "cp.view.ui.base.BNode"
local RegisterLayer = class("RegisterLayer",BNode)

function RegisterLayer:create()
	local scene = RegisterLayer.new()
	return scene
end

function RegisterLayer:initListEvent()
	self.listListeners = {}
end

function RegisterLayer:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/register.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_1"] = {name = "Panel_1"},
		["Panel_1.Button_close"] = {name = "Button_close",click = "onCloseClick"},
		["Panel_1.Button_register"] = {name = "Button_register",click = "onRegisterClick"},
		["Panel_1.TextField_ac"] = {name = "TextField_ac" },
		["Panel_1.TextField_pwd"] = {name = "TextField_pwd" },
		["Panel_1.Image_tipac"] = {name = "Image_tipac" },
		["Panel_1.Image_tippwd"] = {name = "Image_tippwd" },
		["Panel_1.Image_agree_flag"] = {name = "Image_agree_flag",click = "onAgreeClick"},
		["Panel_1.Image_show_protocal"] = {name = "Image_show_protocal",click = "onShowProtocal"},
		["Panel_1.Image_showpwd_flag"] = {name = "Image_showpwd_flag",click = "onPasswordShowStateClick"},
		["Panel_1.Image_wrongac"] = {name = "Image_wrongac"},
		["Panel_1.Image_wrongpwd"] = {name = "Image_wrongpwd"},
		["Panel_1.Image_wrongpro"] = {name = "Image_wrongpro"},
		["Panel_1.Text_red_agree"] = {name = "Text_red_agree"},
		["Panel_1.Image_protocal"] = {name = "Image_protocal"},
		["Panel_1.Image_protocal.Button_close"] = {name = "Button_protocal_close", click = "onButtonProtocalClose"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	self.rootView:setContentSize(display.size)
	cp.getManager("ViewManager").addModalByDefaultImage(self)
	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)


	self["Image_wrongac"]:setVisible(false)
	self["Image_wrongpwd"]:setVisible(false)
	self["Image_wrongpro"]:setVisible(false)
	self["Text_red_agree"]:setVisible(false)


	local dtext = cp.getManager("GDataManager"):getTextFormat("default_input")
	self["TextField_ac"]:setPlaceHolder(dtext)	
	self["TextField_pwd"]:setPlaceHolder(dtext)

	--TextField 
	--[[
	local function textFieldEvent(sender,eventType)
		local sendername = sender:getName()
		local wrongname 
		if sendername == "TextField_ac" then
			wrongname = "Image_wrongac"
		elseif sendername == "TextField_pwd" then
			wrongname = "Image_wrongpwd"
		end

		if eventType == ccui.TextFiledEventType.insert_text or eventType == ccui.TextFiledEventType.delete_backward then
			if string.match(sender:getString(), "%W") then
				--log("input not vaild")
				self[wrongname]:setVisible(true)
			else
				--log("input vaild")
				self[wrongname]:setVisible(false)
			end
		end
	end

	self["TextField_ac"]:addEventListener(textFieldEvent)	
	self["TextField_pwd"]:addEventListener(textFieldEvent)
	]]

	local function changeFunc()
		local str = self.TextField_pwd:getString() 
		if string.match(str, "%W") then
			self.Image_wrongpwd:setVisible(true)
		else
			self.Image_wrongpwd:setVisible(false)
		end
	end
	local function changeFunc2()
		local str = self.TextField_ac:getString() 
		if string.match(str, "%W") then
			self.Image_wrongac:setVisible(true)
		else
			self.Image_wrongac:setVisible(false)
		end
	end

	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_ac,"accountInputBox",{hideCallBack = changeFunc2})
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_pwd,"passwordInputBox",{hideCallBack = changeFunc})
end

function RegisterLayer:onPasswordShowStateClick(sender)
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

function RegisterLayer:onShowProtocal(sender)
	self["Image_protocal"]:setVisible(true)
end

function RegisterLayer:onButtonProtocalClose(sender)
	self["Image_protocal"]:setVisible(false)
end

function RegisterLayer:onAgreeClick(sender)
	self["Text_red_agree"]:setVisible(not self["Text_red_agree"]:isVisible())
	local flag = self["Text_red_agree"]:isVisible()
	self["Image_wrongpro"]:setVisible(flag)

	local filePath 
	if flag then
		filePath = "ui_login_module01_log_miss_b.png"
	else
		filePath = "ui_login_module01_log_miss_a.png"
	end
	self["Image_agree_flag"]:loadTexture(filePath, ccui.TextureResType.plistType)

end

function RegisterLayer:onCloseClick(sender)
	--log("onCloseClick")
	if self.showLoginUICallback ~= nil then
  	self.showLoginUICallback()
	end
end

function RegisterLayer:onRegisterClick(sender)
	--log("onRegisterClick")
	local msg = {}
	msg.account = self["TextField_ac"]:getString()
	msg.password = self["TextField_pwd"]:getString()

	if self["Text_red_agree"]:isVisible() then
		cp.getManager("ViewManager").gameTip("請同意九魔遊戲用戶協議")
		return
	end

	if string.len(msg.account) == 0 then
		cp.getManager("ViewManager").gameTip("請輸入賬號")
		return
	end

	if string.len(msg.password) == 0 then
		cp.getManager("ViewManager").gameTip("請輸入密碼")
		return
	end

	if string.len(msg.account) < 6 then
		cp.getManager("ViewManager").gameTip("帳號使用字母與數字, 最少6個")
		return
	end

	if string.len(msg.password) < 6 then
		cp.getManager("ViewManager").gameTip("密碼使用字母與數字, 最少6個")
		return
	end

	cp.getManager("SocketManager"):doConnectLogin()  --連接登錄伺服器
	cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").RegisterReq, msg)
end

function RegisterLayer:setShowLoginUICallback(cb)
	self.showLoginUICallback = cb
end

-- function RegisterLayer:onCreateTextField(node, changeFun)
-- 	local function editboxHandle(strEventName,sender)

-- 		if strEventName == "began" then   		--光標進入，清空內容/選擇全部
-- 			log("begin")												    
-- 			sender:setText(node:getString())               
-- 		elseif strEventName == "ended" then		--當編輯框失去焦點並且鍵盤消失的時候被調用
-- 			log("ended")												    
-- 			log(sender:getText())												    
-- 			node:setString(sender:getText())
-- 		elseif strEventName == "return" then 	--當用戶點擊編輯框的鍵盤以外的區域，或者鍵盤的Return按鈕被點擊時所調用
-- 			log("return")												    
-- 			log(sender:getText())												    
-- 			node:setString(sender:getText())
-- 		elseif strEventName == "changed" then 	--輸入內容改變時調用 
-- 			log("changed")												    
-- 			log(sender:getText())												    
-- 			node:setString(sender:getText())

-- 			if changeFun ~= nil then
-- 				changeFun(sender:getText())
-- 			end
-- 		end
-- 	end

-- 	local editTxt = ccui.EditBox:create(node:getContentSize(), ccui.Scale9Sprite:create())

-- 	--local editTxt= ccui.EditBox:create(cc.size(350,100), "D:\\ui_chat_module33_liaotian_di01.png")  --輸入框尺寸，背景圖片
--     editTxt:setName("inputTxt")
--     editTxt:setAnchorPoint(0,0)
--     editTxt:setPosition(0,0)                        	--設置輸入框的位置
--     editTxt:setFontSize(30)                            	--設置輸入設置字體的大小
--     editTxt:setMaxLength(10)                           	--設置輸入最大長度為6
--     editTxt:setFontColor(cc.c4b(255,255,255,0))       --設置輸入的字體顏色
--     editTxt:setFontName("fonts/msyh.ttf")               --設置輸入的字體為simhei.ttf
-- --  editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) --設置數字符號鍵盤
--  	--editTxt:setPlaceHolder(node:getString())                		--設置預製提示文本
--     editTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)  --輸入鍵盤返回類型，done，send，go等KEYBOARD_RETURNTYPE_DONE
--     editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 	--輸入模型，如整數類型，URL，電話號碼等，會檢測是否符合
--     editTxt:registerScriptEditBoxHandler(function(eventname,sender) editboxHandle(eventname,sender) end) --輸入框的事件，主要有光標移進去，光標移出來，以及輸入內容改變等
-- 	node:addChild(editTxt,5)
-- 	self.editTxt = editTxt
-- --  editTxt:setHACenter() --輸入的內容錨點為中心，與anch不同，anch是用來確定控件位置的，而這裡是確定輸入內容向什麼方向展開(。。。說不清了。。自己測試一下)
-- end

return RegisterLayer
