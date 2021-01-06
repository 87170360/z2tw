local BNode = require "cp.view.ui.base.BNode"
local EquipPropertyItem = class("EquipPropertyItem",BNode)

function EquipPropertyItem:create()
	local node = EquipPropertyItem.new()
	return node
end

function EquipPropertyItem:initListEvent()
	self.listListeners = {
	}
end

function EquipPropertyItem:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_equip_operate/uicsb_equip_property_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg_left"] = {name = "Image_bg_left"},
		["Panel_root.Image_select"] = {name = "Image_select",click = "onUIButtonClick",clickScale=1},
		["Panel_root.Image_select.Image_select_mark"] = {name = "Image_select_mark"},

		["Panel_root.Text_left"] = {name = "Text_left"},
		["Panel_root.Text_right"] = {name = "Text_right"},
		["Panel_root.Text_left_value"] = {name = "Text_left_value"},
		["Panel_root.Text_right_value"] = {name = "Text_right_value"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	-- self.Image_select:setTouchEnabled(false)
	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
end

function EquipPropertyItem:onEnterScene()
	
end

-- info = {
-- 	left = {text="戰力  " .. tostring(oldValue), color=cc.c4b(255,255,255,255)},
-- 	right = {text=tostring(oldValue + math.random(0,100)), color=cc.c4b(0,255,0,255)},
-- 	isMelt = false, --  是否是熔鍊
-- 	index = i,
--  }
function EquipPropertyItem:reset(info)

	self.Text_left:setString(info.left.text)
	if info.left.text and info.left.text ~= "無" then
		self.Text_left_value:setString(tostring(info.left.value))
		self.Text_left_value:setTextColor(info.left.color)
		self.Text_left_value:setVisible(true)
		self.Text_left:setPositionX(100)

		if info.left.outline then
			self.Text_left_value:enableOutline(info.left.outline, 2)
		else
			self.Text_left_value:disableEffect(cc.LabelEffect.OUTLINE)
		end
	else
		self.Text_left_value:setVisible(false)
		self.Text_left:setPositionX(150)
	end
	
	self.Text_right:setString(info.right.text)
	if info.right.text and info.right.text ~= "無" then
		self.Text_right_value:setString(tostring(info.right.value))
		self.Text_right_value:setTextColor(info.right.color)
		self.Text_right_value:setVisible(true)

		if info.right.outline then
			self.Text_right_value:enableOutline(info.right.outline, 2)
		else
			self.Text_right_value:disableEffect(cc.LabelEffect.OUTLINE)
		end
		self.Text_right:setPositionX(349)
		self.Text_right:setVisible( not info.isQiangHua)

		self.Text_right_value:setAnchorPoint(info.isQiangHua and cc.p(0.5,0.5) or cc.p(0,0.5))
		self.Text_right_value:setPositionX(400)
		
	else
		self.Text_right_value:setVisible(false)
		self.Text_right:setPositionX(389)
		self.Text_right:setVisible( not info.isQiangHua)
	end
	
	self.Image_select:setVisible(info.needSelect or false)
	self.Image_select_mark:setVisible(info.isSelected or false)
	self.index = info.index
	
	if info.index == 1 then
		if info.isQiangHua then
			self.Image_bg_left:loadTexture("ui_equip_operate_module13_qianghuadeng_zhanli.png", ccui.TextureResType.plistType)
			self.Image_bg_left:setScale9Enabled(false)
			self.Image_bg_left:setPosition(65, 18)
			self.Image_bg_left:setSize(212,54)
			self.Text_left:setVisible(false)
		else
			self.Image_bg_left:loadTexture("ui_common_frame_3.png", ccui.TextureResType.plistType)
			self.Image_bg_left:setScale9Enabled(true)
			self.Image_bg_left:setCapInsets({x = 7, y = 11, width = 15, height = 7})
			self.Image_bg_left:setPosition(84, 18)
			self.Image_bg_left:setSize(158,31)
			self.Text_left:setVisible(true)
		end
	end

end

function EquipPropertyItem:onUIButtonClick(sender)
	local buttonName = sender:getName()
	if "Image_select"  == buttonName then
		if self.selectCallBack then
			self.selectCallBack(self)
		end
	end
end

function EquipPropertyItem:setClickCallBack(cb)
	self.selectCallBack = cb
end

function EquipPropertyItem:setSelectedState(isSelected)
	self.Image_select_mark:setVisible(isSelected or false)
end

return EquipPropertyItem
