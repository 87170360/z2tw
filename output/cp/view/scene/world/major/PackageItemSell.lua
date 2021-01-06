
local BNode = require "cp.view.ui.base.BNode"
local PackageItemSell = class("PackageItemSell",BNode) 
function PackageItemSell:create()
    local node = PackageItemSell.new()
    return node
end


function PackageItemSell:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").ItemUpdateRsp] = function(evt)
			self:changePackageType()
		  end,
	}
end

function PackageItemSell:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_package_sell.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_type_select"] = {name = "Panel_type_select"},
		["Panel_root.Panel_type_select.Image_left"] = {name = "Image_left" ,click = "onUIItemClick"},
		["Panel_root.Panel_type_select.Image_right"] = {name = "Image_right" ,click = "onUIItemClick"},

		["Panel_root.Panel_type_select.Text_title"] = {name = "Text_title" },

		["Panel_root.Panel_type_select.Image_index_1"] = {name = "Image_index_1" },
		["Panel_root.Panel_type_select.Image_index_2"] = {name = "Image_index_2" },
		["Panel_root.Panel_type_select.Image_index_3"] = {name = "Image_index_3" },
		["Panel_root.Panel_type_select.Image_index_4"] = {name = "Image_index_4" },
		["Panel_root.Panel_type_select.Image_index_5"] = {name = "Image_index_5" },
		["Panel_root.Panel_type_select.Image_index_6"] = {name = "Image_index_6" },
		["Panel_root.Panel_type_select.Image_index_7"] = {name = "Image_index_7" },
		

		["Panel_root.Panel_1"] = {name = "Panel_1" },
		["Panel_root.Panel_1.Text_num_1"] = {name = "Text_num_1" },
		["Panel_root.Panel_1.Button_sell_1"] = {name = "Button_sell_1",click = "onSellClick" },

		["Panel_root.Panel_2"] = {name = "Panel_2" },
		["Panel_root.Panel_2.Text_num_2"] = {name = "Text_num_2" },
		["Panel_root.Panel_2.Button_sell_2"] = {name = "Button_sell_2",click = "onSellClick" },

		["Panel_root.Panel_3"] = {name = "Panel_3" },
		["Panel_root.Panel_3.Text_num_3"] = {name = "Text_num_3" },
		["Panel_root.Panel_3.Button_sell_3"] = {name = "Button_sell_3",click = "onSellClick" },

		["Panel_root.Panel_4"] = {name = "Panel_4" },
		["Panel_root.Panel_4.Text_num_4"] = {name = "Text_num_4" },
		["Panel_root.Panel_4.Button_sell_4"] = {name = "Button_sell_4",click = "onSellClick" },

		["Panel_root.Panel_5"] = {name = "Panel_5" },
		["Panel_root.Panel_5.Text_num_5"] = {name = "Text_num_5" },
		["Panel_root.Panel_5.Button_sell_5"] = {name = "Button_sell_5",click = "onSellClick" },

		["Panel_root.Panel_6"] = {name = "Panel_6" },
		["Panel_root.Panel_6.Text_num_6"] = {name = "Text_num_6" },
		["Panel_root.Panel_6.Button_sell_6"] = {name = "Button_sell_6",click = "onSellClick" },
		

		["Panel_root.Button_close"] = {name = "Button_close" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self["Image_left"]:setTouchEnabled(false)
	self["Image_right"]:setTouchEnabled(false)
	self["Image_left"]:setVisible(false)
	self["Image_right"]:setVisible(false)
	
	for i=1,7 do
		self["Image_index_" .. tostring(i)]:setVisible(false)
	end
end

function PackageItemSell:onEnterScene()
	self.currentPackType = 1
	self.Text_title:setString("全部裝備")
	self:changePackageType()	
end

function PackageItemSell:changePackageType()
	
	log("packType", self.currentPackType)
	
	self.itemList = {{num=0,items={}},{num=0,items={}},{num=0,items={}},{num=0,items={}},{num=0,items={}},{num=0,items={}}}
	local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
	for _, v in pairs(roleItem) do
		if v.using == 0 then
			local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
			if conf ~= nil then
				local Colour = conf:getValue("Hierarchy")
				if self.currentPackType == 0 or (conf:getValue("Package") == self.currentPackType and self.currentPackType > 0) then
					self.itemList[Colour].num = self.itemList[Colour].num + v.num
					local item = {uuid = v.uuid, num = v.num}
					table.insert(self.itemList[Colour].items, item)
				end
			end
		end
	end

	local textList = {"白色","綠色","藍色","紫色","金色","紅色"}
	for i=1,6 do
		self["Text_num_" .. tostring(i)]:setString( textList[i] .. "裝備 X " .. tostring(self.itemList[i].num))
	end
	-- self:refreshDot()
	
end

-- function PackageItemSell:refreshDot()
-- 	for i=1,7 do
-- 		local pic = self.currentPackType == i-1 and "ui_item_auto_sell_module31_backpack_xuanzekuang_b.png" or "ui_item_auto_sell_module31_backpack_xuanzekuang_a.png"
-- 		self["Image_index_" .. tostring(i)]:ignoreContentAdaptWithSize(true)
-- 		self["Image_index_" .. tostring(i)]:loadTexture(pic,ccui.TextureResType.plistType)
-- 	end
-- 	local txt = {"全  部","裝  備","武  學","材  料","道  具","碎  片","服  飾"}
-- 	self.Text_title:setString(txt[self.currentPackType + 1])
-- end

function PackageItemSell:onSellClick(sender)
	local buttonName = sender:getName()
    log("click button: " .. buttonName)
	local index = string.sub(buttonName,string.len( "Button_sell_" )+1)
	log("click button index: " .. tostring(index))
	local idx = tonumber(index)
	if self.itemList[idx].num > 0 and self.itemList[idx].items ~= nil and next(self.itemList[idx].items) ~= nil then
		if idx >= 5 then
			local function comfirmFunc()
				--發送批量出售物品的協議
				local req = {items = self.itemList[idx].items}
				self:doSendSocket(cp.getConst("ProtoConst").SellItemReq,req)
			end
			local txt = {[5]="金色品質",[6] = "紅色品質"}
			local contentTable = {
				{type="ttf", fontSize=24, text="是否確定出售", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
				{type="ttf", fontSize=24, text=txt[idx], textColor=cp.getConst("GameConst").QualityTextColor[idx], outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
				{type="ttf", fontSize=24, text="物品？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			}
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
		else
			--發送批量出售物品的協議
			local req = {items = self.itemList[idx].items}
			self:doSendSocket(cp.getConst("ProtoConst").SellItemReq,req)
		end
	end
	
end

function PackageItemSell:onCloseButtonClick(sender)
	cp.getManager("PopupManager"):removePopup(self)
end

function PackageItemSell:onUIItemClick(sender)
	local buttonName = sender:getName()
    log("click button : " .. buttonName)
	if "Image_left" == buttonName then
		if self.currentPackType == 0 then
			return
		end 
		self.currentPackType = self.currentPackType - 1
		self.currentPackType = math.max(self.currentPackType,0)
	elseif "Image_right" == buttonName then
		if self.currentPackType == 6 then
			return
		end 
		self.currentPackType = self.currentPackType + 1
		self.currentPackType = math.min(self.currentPackType,6)
	end
	self:changePackageType()
end

function PackageItemSell:getDescription()
    return "PackageItemSell"
end

return PackageItemSell
