
local BNode = require "cp.view.ui.base.BNode"
local AutoSellSettings = class("AutoSellSettings",BNode)  --function() return cc.Node:create() end)
function AutoSellSettings:create()
    local node = AutoSellSettings.new()
    return node
end


function AutoSellSettings:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").AutoSellRsp] = function(data)
            cp.getManager("PopupManager"):removePopup(self)
        end,
	}
end

function AutoSellSettings:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_auto_sell_setting.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_select_1"] = {name = "Image_select_1" },
		["Panel_root.Image_bg.Image_select_2"] = {name = "Image_select_2" },
		["Panel_root.Image_bg.Image_select_3"] = {name = "Image_select_3" },
		["Panel_root.Image_bg.Image_select_4"] = {name = "Image_select_4" },
		
		["Panel_root.Image_bg.Image_bg_1"] = {name = "Image_bg_1" ,click = "onItemClick", clickScale = 1},
		["Panel_root.Image_bg.Image_bg_2"] = {name = "Image_bg_2" ,click = "onItemClick", clickScale = 1},
		["Panel_root.Image_bg.Image_bg_3"] = {name = "Image_bg_3" ,click = "onItemClick", clickScale = 1},
		["Panel_root.Image_bg.Image_bg_4"] = {name = "Image_bg_4" ,click = "onItemClick", clickScale = 1},
		
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onOKButtonClick"},
		["Panel_root.Image_bg.Button_close"] = {name = "Button_close" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	for i=1,4 do
		self["Image_bg_" .. tostring(i)]:setTouchEnabled(true)
	end
	
end

function AutoSellSettings:onEnterScene()
	--根據伺服器數據初始化當前選中的物品品質種類
	self.selectedState = cp.getManager("GDataManager"):getAutoSellState()
	
	for i=1,4 do
		self["Image_select_" .. tostring(i)]:setVisible(self.selectedState[i] == 1)
	end
end

function AutoSellSettings:onItemClick(sender)
	local buttonName = sender:getName()
    log("click button : " .. buttonName)
	local index = string.sub(buttonName,string.len( "Image_bg_" )+1)
	log("click button index: " .. tostring(index))
	local idx = tonumber(index)
	self.selectedState[idx] = 1 - self.selectedState[idx]
	self.selectedState[idx] = math.max(self.selectedState[idx],0)
	self.selectedState[idx] = math.min(self.selectedState[idx],1)
	self["Image_select_" .. tostring(index)]:setVisible(self.selectedState[idx] == 1)
	
end

function AutoSellSettings:onCloseButtonClick(sender)
	cp.getManager("PopupManager"):removePopup(self)
end

function AutoSellSettings:onOKButtonClick(sender)
	--檢測選中的，同步給伺服器
	local state=0
	for i=0,3 do
		if self.selectedState[i+1] == 1 then
			local ss = bit.lshift(1, i)
			state = bit.bor(ss, state)
		
		end
	end
	
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	if state == majorRole.exerciseAuto then
		cp.getManager("ViewManager").gameTip("該設置已保存")
		return
	end

	local req = {state = state}
	self:doSendSocket(cp.getConst("ProtoConst").AutoSellReq, req)
end

function AutoSellSettings:getDescription()
    return "AutoSellSettings"
end

return AutoSellSettings