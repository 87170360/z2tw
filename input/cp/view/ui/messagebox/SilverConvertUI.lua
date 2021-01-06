local BNode = require "cp.view.ui.base.BNode"
local SilverConvertUI = class("SilverConvertUI",BNode)
function SilverConvertUI:create()
    local ret = SilverConvertUI.new()
    return ret
end

function SilverConvertUI:initListEvent()
	self.listListeners = {
		--獲取兌換訊息
		[cp.getConst("EventConst").GetConvertInfoRsp] = function(evt)
			if evt then
				self:onConvertInfoUpdate(evt.base)
			end
		end,
		
		--兌換銀兩
		[cp.getConst("EventConst").ConvertSilverRsp] = function(evt)
			self:onConvertSilverCallBack(evt)
		end,
		
		--快速兌換
		[cp.getConst("EventConst").ConvertSilverExRsp] = function(evt)
			self:onConvertSilverExCallBack(evt)
		end,
		
	}
end

function SilverConvertUI:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_zhaocai.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Button_buy_quick"] = {name = "Button_buy_quick" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_buy"] = {name = "Button_buy" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_close"] = {name = "Button_close" ,click = "onUIButtonClick"},

		["Panel_root.Image_bg.Image_14.Text_scale"] = {name = "Text_scale" },
		["Panel_root.Image_bg.Text_gold_ext"] = {name = "Text_gold_ext" },
		["Panel_root.Image_bg.Text_silver_ext"] = {name = "Text_silver_ext" },
		["Panel_root.Image_bg.Text_gold"] = {name = "Text_gold" },
		["Panel_root.Image_bg.Text_silver"] = {name = "Text_silver" },
		["Panel_root.Image_bg.Text_num"] = {name = "Text_num" },	
		["Panel_root.Image_bg.Panel_tip"] = {name = "Panel_tip" },
		["Panel_root.Image_bg.ScrollView_1"] = {name = "ScrollView_1"},

		["Panel_item"] = {name = "Panel_item"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self["Panel_item"]:setVisible(false)
	self.ScrollView_1:setScrollBarEnabled(false)
	self.Panel_tip:setVisible(true)

	local req = {}
	self:doSendSocket(cp.getConst("ProtoConst").GetConvertInfoReq,req)

end

function SilverConvertUI:onEnterScene()
	self.itemList = {}

	local Config = cp.getManager("ConfigManager").getItemByKey("Other", "convert_ex_debate")
    local debate = Config:getValue("IntValue")
	local scale = string.format("%.1f",debate/10.0)
	self.Text_scale:setString(tostring(scale) .. "折")
end


function SilverConvertUI:addNewItems(infolist)
	local sz = self.Panel_item:getContentSize()
	local totalCount = table.nums(self.itemList) + table.nums(infolist)
	local totalHeight = totalCount*sz.height
	if totalHeight < self.ScrollView_1:getContentSize().height then
		totalHeight = self.ScrollView_1:getContentSize().height
	end
	self.ScrollView_1:setInnerContainerSize(cc.size(sz.width,totalHeight))
	self.Panel_tip:setVisible(false)	

	local Config = cp.getManager("ConfigManager").getItemByKey("Other", "convert_gold_cost")
    local priceStr = Config:getValue("StrValue")
	local priceArray = string.split(priceStr,"|")
	local beginBuyIndex = self.maxNum - self.leftNum - table.nums(infolist) + 1
	local index = 0

	local function createNewItem(info)
		local item = self.Panel_item:clone()
		local Text_use = item:getChildByName("Text_use")
		local idx = beginBuyIndex+index > #priceArray and #priceArray or beginBuyIndex+index
		Text_use:setString("使用" .. tostring(priceArray[idx]))
		local Text_silver = item:getChildByName("Text_silver")
		Text_silver:setString("獲得 " .. tostring(info.silver))
		local Text_prob = item:getChildByName("Text_prob")
		local Image_prob = item:getChildByName("Image_prob")
		if info.prob and info.prob > 0 then
			Text_prob:setString(tostring(info.prob) .. "倍")
		end
		Image_prob:setVisible(info.prob and info.prob > 0)
		Text_prob:setVisible(info.prob and info.prob > 0)
		return item
	end
	
	for i=1, totalCount do 
		local sz = self.Panel_item:getContentSize()
		if i > table.nums(self.itemList) then
			local item = createNewItem(infolist[index+1])
			self.ScrollView_1:addChild(item)
			item:setPosition(cc.p(-sz.width,totalHeight - (i-1)*sz.height))
			item:setVisible(true)
			self.itemList[i] = item
			index = index + 1
			
			local act0 = cc.DelayTime:create(index*0.1)
			local act1 = cc.MoveTo:create(0.3,cc.p(0, totalHeight - (i-1)*sz.height))
			local act2 = cc.EaseSineOut:create(act1)
			local action = cc.Sequence:create(act0,act2)
			self.itemList[i]:runAction(action)
			self.ScrollView_1:scrollToBottom(0.2,true)
		else
			self.itemList[i]:setPositionY(totalHeight - (i-1)*sz.height)
		end
	end
	
end

--[[
	message ConvertBase {
    required int32 leftNum                  = 2;                    //剩餘次數
    required int32 maxNum                   = 3;                    //最大次數
    required int32 gold1                    = 4;                    //普通兌換消耗元寶
    required int32 gold2                    = 5;                    //快速兌換消耗元寶
    required int32 silver1                  = 6;                    //普通兌換獲得銀兩
    required int32 silver2                  = 7;                    //快速兌換獲得銀兩
}
]]
function SilverConvertUI:onConvertInfoUpdate(base)
	-- 刷新並顯示界面
	if base then
		self.Text_gold_ext:setString(tostring(base.gold2))
		self.Text_silver_ext:setString(tostring(base.silver2))
		self.Text_gold:setString(tostring(base.gold1))
		self.Text_silver:setString(tostring(base.silver1))
		self.Text_num:setString(tostring(base.leftNum) .. "/" .. tostring(base.maxNum))
	end
	self.leftNum = base.leftNum
	self.maxNum = base.maxNum
end

--兌換返回
function SilverConvertUI:onConvertSilverCallBack(evt)
	self:onConvertInfoUpdate(evt.base)
	local list = {evt.info}
	self:addNewItems(list) 
end

--快速兌換返回
function SilverConvertUI:onConvertSilverExCallBack(evt)
	self:onConvertInfoUpdate(evt.base)
	self:addNewItems(evt.info)
end

function SilverConvertUI:checkLeftCount()
	if self.leftNum <= 0 then
		local vip = cp.getUserData("UserVip"):getValue("level")
		local str = vip >= 15 and "今日招財次數已達上限。" or "提升VIP等級可獲得更多招財次數!" 
		cp.getManager("ViewManager").gameTip(str)
		return false
	end
	return true
end

function SilverConvertUI:onUIButtonClick(sender)
	
	local buttonName = sender:getName()
	if buttonName == "Button_buy" then
		if self:checkLeftCount() then
			self:doSendSocket(cp.getConst("ProtoConst").ConvertSilverReq,{})
		end
		
	elseif buttonName == "Button_buy_quick" then
		if self:checkLeftCount() then
			self:doSendSocket(cp.getConst("ProtoConst").ConvertSilverExReq,{})
			self.Button_buy_quick:setTouchEnabled(false)
			cp.getManager("ViewManager").setShader(self.Button_buy_quick, "GrayShader")
			performWithDelay(self.Button_buy_quick,function()
				self.Button_buy_quick:setTouchEnabled(true)
				cp.getManager("ViewManager").setShader(self.Button_buy_quick, nil)
			end,2)
		end
	elseif buttonName == "Button_close" then
		cp.getManager("PopupManager"):removePopup(self)
	end
end


function SilverConvertUI:getDescription()
    return "SilverConvertUI"
end

return SilverConvertUI