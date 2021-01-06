local BNode = require "cp.view.ui.base.BNode"
local FaceUnlockNotice = class("FaceUnlockNotice",BNode)
function FaceUnlockNotice:create(fashionID)
    local ret = FaceUnlockNotice.new(fashionID)
    return ret
end

function FaceUnlockNotice:initListEvent()
	self.listListeners = {
	}

end

function FaceUnlockNotice:onInitView(fashionID)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_unlock_face.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Panel_model.Image_icon"] = {name = "Image_icon" },
		["Panel_root.Image_bg.Panel_model.Text_name"] = {name = "Text_name" },
		["Panel_root.Image_bg.Button_change"] = {name = "Button_change", click = "onChangeButtonClick"},
		["Panel_root.Image_bg.Button_back"] = {name = "Button_back", click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
	self.unlock_face = ""

	local cfgItem = cp.getManager("ConfigManager").getItemByKey("Fashion",fashionID)
	if cfgItem then
		local fashionName = cfgItem:getValue("Name") 
		self.Text_name:setString(fashionName)
	end

	local cfgItem = cp.getManager("ConfigManager").getItemByMatch("Face",{FashionID = fashionID})
	if cfgItem then
		local face = cfgItem:getValue("ID") 
		if face and face ~= "" then
			self["Image_icon"]:loadTexture("img/model/head/" .. face .. ".png", UI_TEX_TYPE_LOCAL)
			self["Image_icon"]:setScale(0.76)
			self.unlock_face = face
			self["Image_icon"]:ignoreContentAdaptWithSize(true)
		end
	end
	
	self:setPosition(cc.p(display.cx,display.cy))
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
		if self.closeCallBack then
			self.closeCallBack(nil)
		end
		cp.getManager("PopupManager"):removePopup(self)
	end)

	cp.getManager("ViewManager").popUpView(self.Panel_root)
	
end

function FaceUnlockNotice:onEnterScene()
end

function FaceUnlockNotice:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function FaceUnlockNotice:onChangeButtonClick(sender)
	if self.closeCallBack then
		self.closeCallBack(self.unlock_face)
	end
	cp.getManager("PopupManager"):removePopup(self)
end



function FaceUnlockNotice:onCloseButtonClick(sender)
	if self.closeCallBack then
		self.closeCallBack(nil)
	end
	cp.getManager("PopupManager"):removePopup(self)
end

function FaceUnlockNotice:getDescription()
    return "FaceUnlockNotice"
end

return FaceUnlockNotice