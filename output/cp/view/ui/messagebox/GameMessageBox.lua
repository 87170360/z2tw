local BNode = require "cp.view.ui.base.BNode"
local GameMessageBox = class("GameMessageBox",BNode)
function GameMessageBox:create(params)
    local ret = GameMessageBox.new(params)
    return ret
end

function GameMessageBox:initListEvent()
	self.listListeners = {
		
		 --新手指引點擊目標點
		 [cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "GameMessageBox" then
                if evt.guide_name == "lilian" then
                    self:onOKButtonClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "GameMessageBox" then
                if evt.guide_name == "lilian" then
                    local boundbingBox = self[evt.target_name]:getBoundingBox()
                    local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                end
            end
		end,
		
	}
end

function GameMessageBox:onInitView(params)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_messagebox.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_title.Text_title"] = {name = "Text_title" },
		["Panel_root.Image_bg.Text_content"] = {name = "Text_content" },
		["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel" ,click = "onCancelButtonClick"},
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onOKButtonClick"},
		
		["Panel_root.Image_bg.Button_cancel.Text_1"] = {name = "Text_cancel" },
		["Panel_root.Image_bg.Button_OK.Text_1"] = {name = "Text_OK"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
	
	self.params = params
	
	-- params = {title = "標題" , content  = "顯示內容" , ok_cancel_mode = 2, OKCallBack, CancelCallBack,Text_OK = "好的", Text_cancel = "太客氣了"}
	-- OKCANCELMODE 取值 1:只顯示OK按鈕，2: 顯示OK和CANCEL2個按鈕
	if params.title ~= nil then
		self["Text_title"]:setString(params.title)
		--self["Text_title"]:setVisible(true)
	else
		--self["Text_title"]:setVisible(false)
		self["Text_title"]:setString("系統消息")
	end
	
	if params.content ~= nil then
		if type(params.content) == "table" then
			self["Text_content"]:setVisible(false)
			local posX,posY = self["Text_content"]:getPosition()
			local sz = self["Text_content"]:getContentSize()
			local richText = self:createRichText(params.content)
			richText:setPosition(cc.p(posX,posY))
			self["Image_bg"]:addChild(richText)
		else
			self["Text_content"]:setString(params.content)
			self["Text_content"]:setVisible(true)
		end
	end
	
	if params.Text_OK ~= nil then
		self["Text_OK"]:setText(params.Text_OK )
	end
	if params.Text_cancel ~= nil then
		self["Text_cancel"]:setText(params.Text_cancel )
	end
	
	local layout = ccui.LayoutComponent:bindLayoutComponent(self["Button_OK"])
	layout:setPositionPercentXEnabled(true)
	if params.ok_cancel_mode == 1 then
		self["Button_cancel"]:setVisible(false)
		layout:setPositionPercentX(0.500)
	elseif params.ok_cancel_mode == 2 then
		self["Button_cancel"]:setVisible(true)
		layout:setPositionPercentX(0.700)
	end
	self.return_code = -1
end

function GameMessageBox:onEnterScene()

end
 
function GameMessageBox:createRichText(contentTable)
	--[[
		contentTable = {
			{type="ttf", fontSize=27, text="是否遺忘", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="魚躍龍門", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="回憶", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="水濺躍", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text=",需要消耗一枚:", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="心之鱗片", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
	]]
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(510,80))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(231,120))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    richText:setLineGap(1)
    return richText

end

function GameMessageBox:onCancelButtonClick(sender)
	self.return_code = 1
	if self.params.CancelCallBack ~= nil then
		self.params.CancelCallBack()
	end
	if self.params.title == "網路斷開提示" then
		self:removeFromParent()
	else
		cp.getManager("PopupManager"):removePopup(self)
	end
end

function GameMessageBox:onOKButtonClick(sender)
	self.return_code = 0
	if self.params.OKCallBack ~= nil then
		self.params.OKCallBack()
	end
	if self.params.title == "網路斷開提示" or self.params.title == "連接斷開提示" then
		self:removeFromParent()
	else
		cp.getManager("PopupManager"):removePopup(self)
	end
end

function GameMessageBox:getReturnCode()
    return self.return_code
end

function GameMessageBox:getDescription()
    return "GameMessageBox"
end

return GameMessageBox