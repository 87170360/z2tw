local GameEditBox = class("GameEditBox",function() return cc.Layer:create() end)
function GameEditBox:create(openInfo)
    local ret = GameEditBox.new()
    ret:init(openInfo)
    return ret
end

function GameEditBox:init(openInfo)
	self.openInfo = openInfo or {}
	display.loadSpriteFrames("uiplist/ui_common.plist")
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_input.csb")
	self:addChild(self.rootView)
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.TextField_1"] = {name = "TextField_1"},
		["Panel_root.Button_ok"] = {name = "Button_ok", click = "onUIButtonClick"},
		["Panel_root.Button_cancel"] = {name = "Button_cancel", click = "onUIButtonClick"},

	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.rootView:setContentSize(display.size)
	self.Panel_root:setPositionY(display.height-10)
	if self.openInfo.editBoxName == "InputBox_Spirit" then  --輸入幫派宗旨
		self.Panel_root:setContentSize(cc.size(700,160))
	end
	
	self.TextField_1:setContentSize(cc.size(688,self.Panel_root:getContentSize().height-4))

	cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b)
	
    local function editboxHandle(strEventName,sender)
		if strEventName == "began" then   		--光標進入，清空內容/選擇全部
			log("begin")              
		elseif strEventName == "ended" then		--當編輯框失去焦點並且鍵盤消失的時候被調用
			log("ended")											    
			log(sender:getText())
		elseif strEventName == "return" then 	--當用戶點擊編輯框的鍵盤以外的區域，或者鍵盤的Return按鈕被點擊時所調用
			log("return")												    
			log(sender:getText())
		elseif strEventName == "changed" then 	--輸入內容改變時調用 
			log("changed")												    
			log(sender:getText())
		end
	end

	-- local editTxt = ccui.EditBox:create(self.Image_bg:getContentSize(), ccui.Scale9Sprite:create())

	-- --local editTxt= ccui.EditBox:create(cc.size(350,100), "D:\\ui_chat_module33_liaotian_di01.png")  --輸入框尺寸，背景圖片
    -- editTxt:setName("inputTxt")
    -- editTxt:setAnchorPoint(0,0)
    -- editTxt:setPosition(0,0)                        	                            --設置輸入框的位置
    -- editTxt:setFontSize(self.openInfo.fontSize or 30)                            	--設置輸入設置字體的大小
    -- editTxt:setMaxLength(self.openInfo.maxLength or 100)                           	--設置輸入最大長度為6
    -- editTxt:setFontColor(self.openInfo.textColor or cc.c4b(128,128,128,255))        --設置輸入的字體顏色
    -- editTxt:setFontName("fonts/msyh.ttf")                                           --設置輸入的字體為simhei.ttf
    -- editTxt:setInputMode(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS) --設置數字符號鍵盤
 	-- --editTxt:setPlaceHolder(node:getString())                		--設置預製提示文本
    -- editTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)  --輸入鍵盤返回類型，done，send，go等KEYBOARD_RETURNTYPE_DONE
    -- editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 	--輸入模型，如整數類型，URL，電話號碼等，會檢測是否符合
    -- editTxt:registerScriptEditBoxHandler(function(eventname,sender) editboxHandle(eventname,sender) end) --輸入框的事件，主要有光標移進去，光標移出來，以及輸入內容改變等
	-- self.Image_bg:addChild(editTxt,5)
	-- self.editTxt = editTxt

--  editTxt:setHACenter() --輸入的內容錨點為中心，與anch不同，anch是用來確定控件位置的，而這裡是確定輸入內容向什麼方向展開(。。。說不清了。。自己測試一下)

	self.TextField_1:addEventListener(
		function(sender, eventType)
			local event = {}
			if eventType == 0 then
				event.name = "ATTACH_WITH_IME"
			elseif eventType == 1 then
				event.name = "DETACH_WITH_IME"
			elseif eventType == 2 then
				event.name = "INSERT_TEXT"
			elseif eventType == 3 then
				event.name = "DELETE_BACKWARD"
			end
			event.target = sender
			
		end)

	ccui.Helper:doLayout(self["rootView"])

end

function GameEditBox:setInitText(txt)
	-- self.editTxt:setText(txt)
	self.TextField_1:setString(txt)
end

function GameEditBox:showKeyBoard()
	-- self.editTxt:touchDownAction(self.editTxt, ccui.TouchEventType.ended)
	-- cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(true)
	self.TextField_1:attachWithIME()
end

function GameEditBox:hideKeyBoard()
	-- self.editTxt:touchDownAction(self.editTxt, ccui.TouchEventType.ended)
	if self.TextField_1.detachWithIME then
		self.TextField_1:detachWithIME()
	else
		cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
	end
end


function GameEditBox:onUIButtonClick(sender)
	local name = sender:getName()
	-- local text = self.editTxt:getText()
	local text = self.TextField_1:getString()
	if self.closeCallBack then
		self.closeCallBack(name,text)
	end
end

function GameEditBox:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function GameEditBox:getDescription()
    return "GameEditBox"
end

return GameEditBox