
local BLayer = require "cp.view.ui.base.BLayer"
local FundsGiftMain = class("FundsGiftMain",BLayer)

function FundsGiftMain:create(openInfo)
	local layer = FundsGiftMain.new(openInfo)
	return layer
end

function FundsGiftMain:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").OtherRsp] = function(data)	

			if self:isVisible() == false then
				return
			end
			
			self:createCellItems()
			
		end,

		[cp.getConst("EventConst").FundConfRsp] = function(data)	
			
			if self:isVisible() == false then
				return
			end
			
			self:createCellItems()
			
		end,
		
		[cp.getConst("EventConst").RechargeRsp] = function(evt)
			if self:isVisible() == false then
				return
			end
			local Config = cp.getManager("ConfigManager").getItemByMatch("Recharge", {ItemCode = self.ItemCode})
			local ID = Config:getValue("ID")
			if evt.rechargeID == ID then
				cp.getManager("ViewManager").gameTip("江湖基金已購買，趕緊升級領取更多獎勵吧。")
				self.Button_buy:setVisible(false)
			end
		end,

		[cp.getConst("EventConst").GetFundRsp] = function(data)	
			
			if data.element and next(data.element) then
				local itemList = {}
				for i=1,table.nums(data.element) do
					table.insert(itemList, {id = data.element[i].id, num=data.element[i].num, hideName = false})
				end
				if next(itemList) then
					cp.getManager("ViewManager").showGetRewardUI(itemList, "恭喜獲得", true, function() 
					end)
				end
			end
			
		end,
	}
end

function FundsGiftMain:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_funds_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
		["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Button_buy"] = {name = "Button_buy", click = "onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Button_buy.Text_1"] = {name = "Text_price"},

        ["Panel_root.Panel_1.Panel_2.Panel_3"] = {name = "Panel_3"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content"] = {name = "Panel_content"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Image_bg"] = {name = "Panel3_bg"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Image_around_bar"] = {name = "Panel3_bar"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    --cp.getManager("ViewManager").popUpView(self.Panel_root)
    self:setPosition(display.cx,display.cy)
	self.Panel_root:setContentSize(display.size)

	--動態調整panel3的節點width height
	local panel1Size = self.Panel_1:getContentSize()
	local panel2Size = self.Panel_2:getContentSize()
	local panel3Size = self.Panel_3:getContentSize()
	local changeHeight = display.size.height - panel1Size.height - panel2Size.height 
	self.Panel_3:setContentSize(cc.size(panel3Size.width, changeHeight))
	self.Panel3_bg:setContentSize(cc.size(panel3Size.width, changeHeight + 20))
	self.Panel3_bar:setContentSize(cc.size(panel3Size.width + 15, changeHeight + 20))
	self.Panel_content:setContentSize(cc.size(panel3Size.width, changeHeight-160))
	self.Panel_content:setPositionY(self.Panel_3:getContentSize().height-40)

	ccui.Helper:doLayout(self["rootView"])
	
	self.ItemCode = "nzljh_gold_11"  --江湖基金的ItemCode，詳細見 Recharge.xlsx
end

function FundsGiftMain:onEnterScene()
	self:createCellItems()

	local Config = cp.getManager("ConfigManager").getItemByMatch("Recharge", {ItemCode = self.ItemCode})
	local ID = Config:getValue("ID")
	-- local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(ID)
	local fund = cp.getUserData("UserActivity"):getValue("fund")
	if fund then
		self.Button_buy:setVisible(false)
	else
		local channelName = cp.getManualConfig("Channel").channel
		if channelName == "lunplay" then 
			self.Text_price:setString("$" .. tostring(Config:getValue("Money")))
		else
			self.Text_price:setString( tostring(Config:getValue("Money")) .. "元")
		end
	end
end

function FundsGiftMain:onExitScene()
    
end

function FundsGiftMain:createCellItems()
    self.Panel_content:removeAllChildren()
   
	self:refreshCellInfo()

    local contentSize = self.Panel_content:getContentSize()
	local cellSize = cc.size(695,140)
    self.cellView = cp.getManager("ViewManager").createCellView(contentSize)
    self.cellView:setCellSize(cellSize)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p((contentSize.width - cellSize.width)/2, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.cellInfo)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1
        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.fundsGift.FundsGiftItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        item:resetInfo(self.cellInfo[idx])
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.cellView:reloadData()
    self.Panel_content:addChild(self.cellView)
end

function FundsGiftMain:refreshCellInfo()
	local tb = {}

	local fundGift = cp.getUserData("UserActivity"):getValue("fundGift")
	local fund_config = cp.getUserData("UserActivity"):getValue("fund_config")
	-- local cnt = cp.getManager("ConfigManager").getItemCount("FundsGift")
    for i,info in pairs (fund_config) do

		local item = {}
		item.id = info.ID
		item.level = info.level
		
		item.values = {}
		if info.item and next(info.item) then
			for i1, v1 in pairs(info.item) do
				if v1.id and v1.id > 0 and v1.num and v1.num > 0 then
					table.insert(item.values, info.item[i1])
				end
			end
		end

		
		--領取狀態
		item.state = 0  --0 未達到條件  1 可領取，2 已領取
		if fundGift and fundGift[item.id] then
			item.state = fundGift[item.id]
		end
		
		table.insert(tb, item)
		
	end


	--排序
    local function cmp(a,b)
		if a.state == b.state then
			return a.level < b.level
		else
			return a.state < b.state	
		end
    end
    table.sort(tb, cmp)

	local tb2 = {}
	local tb3 = {}
	for _, v in ipairs(tb) do
		if v.state == 1 then
			table.insert(tb3, v)
		else
			table.insert(tb2, v)
		end
	end

	if table.nums(tb2) > 0 then
		for i = 1, table.nums(tb2) do
			table.insert(tb3, tb2[i])
		end
	end

	self.cellInfo = tb3
end


function FundsGiftMain:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log(buttonName)

	local Config = cp.getManager("ConfigManager").getItemByMatch("Recharge", {ItemCode = self.ItemCode})
	local ID = Config:getValue("ID")
	-- local isFirst = cp.getUserData("UserVip"):getFirstRechargeState(ID)
	local fund = cp.getUserData("UserActivity"):getValue("fund")
	if fund then
		cp.getManager("ViewManager").gameTip("江湖基金已購買，不能重複購買。")
		self.Button_buy:setVisible(false)
		return
	end
	
	local itemInfo = {ItemCode = self.ItemCode}
	local channelName = cp.getManualConfig("Channel").channel
	if channelName == "xiaomi" or channelName == "xiaomi1" then  --小米首次測試不開儲值
		cp.getManager("ViewManager").gameTip("本次測試不開放儲值，謝謝大俠。")
		return
	elseif channelName == "lunplay" then
		cp.getManager("ChannelManager"):goRecharge(itemInfo,handler(self,self.refreshButton))
		return
	end
	
	local req = {}
	req.rechargeID = ID
	self:doSendSocket(cp.getConst("ProtoConst").RechargeReq, req)
	
	sender:setTouchEnabled(false)
	sender:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() sender:setTouchEnabled(true) end)))
end

function FundsGiftMain:refreshButton()

end

return FundsGiftMain
