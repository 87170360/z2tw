
local BLayer = require "cp.view.ui.base.BLayer"
local RechargeGiftMain = class("RechargeGiftMain",BLayer)

function RechargeGiftMain:create(openInfo)
	local layer = RechargeGiftMain.new(openInfo)
	return layer
end

function RechargeGiftMain:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").GetRechargeGiftRsp] = function(data)	
			
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
		
		[cp.getConst("EventConst").OtherRsp] = function(data)
			if self:isVisible() == false then
				return	
			end
			self:createCellItems()
			local rechargeGold = cp.getUserData("UserActivity"):getValue("rechargeGold")
			self.Text_value:setString(tostring(rechargeGold))
		end,
		
		[cp.getConst("EventConst").RechargeGiftConfRsp] = function(data)
			if self:isVisible() == false then
				return	
			end
			self.cellInfo = nil
			self:onEnterScene()

		end,
		
		
	}
end

function RechargeGiftMain:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_recharge_award_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
		["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Text_value"] = {name = "Text_value"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Text_time"] = {name = "Text_time"},

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
end

function RechargeGiftMain:onEnterScene()
	self:createCellItems()

	local rechargeGold = cp.getUserData("UserActivity"):getValue("rechargeGold")
   	self.Text_value:setString(tostring(rechargeGold))
   
	local endTime = cp.getUserData("UserActivity"):getValue("rechargeGift_time_end")
	local date = os.date("*t",endTime)  -- {year=2016, month=7, day=13, hour=10,min=51,sec=7,isdst=false,wday=4,yday=195}
	local showStr = string.format("%s年%s月%s日%s時%s分%s秒",date.year,date.month,date.day,date.hour,date.min,date.sec)
   	self.Text_time:setString(showStr)
end

function RechargeGiftMain:onExitScene()
    
end

function RechargeGiftMain:createCellItems()
    self.Panel_content:removeAllChildren()
   
	self:refreshAllItem()

    local contentSize = self.Panel_content:getContentSize()
	local cellSize = cc.size(695,214)
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
            item = require("cp.view.scene.world.rechargeGift.RechargeGiftItem"):create()
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

function RechargeGiftMain:getCellInfo()
	self.cellInfo = {}

	--從伺服器下發配置載入數據
	local rechargeGift_config = cp.getUserData("UserActivity"):getValue("rechargeGift_config")
	for i, info in pairs(rechargeGift_config) do
		
		local item = {}
		item.id = info.ID
		item.gold = info.gold
		item.state = 0 -- 0:條件還未達到 1:可領取 2:已領取
		item.values = {}
		if info.item and next(info.item) then
			for i1, v1 in pairs(info.item) do
				if v1.id and v1.id > 0 and v1.num and v1.num > 0 then
					table.insert(item.values, info.item[i1])
				end
			end
		end

		table.insert(self.cellInfo, item)
	end
end


function RechargeGiftMain:refreshAllItem()
	if self.cellInfo == nil then
		self:getCellInfo()
	end

	local rechargeGift = cp.getUserData("UserActivity"):getValue("rechargeGift")
	for i, item in pairs(self.cellInfo) do
		if rechargeGift and rechargeGift[item.id] and tonumber(rechargeGift[item.id]) then
			self.cellInfo[i].state = rechargeGift[item.id]  -- 0:條件還未達到 1:可領取 2:已領取
		end	
	end

	self:sortAllItem()
end

function RechargeGiftMain:sortAllItem() 
	
	local tb2 = {}
	local tb3 = {}
	for i, item in pairs(self.cellInfo) do
		if item.state == 2 then
			table.insert( tb3, item )
		else
			table.insert( tb2, item )
		end
	end

	--排序
    local function cmp(a,b)
		if a.state == b.state then
			return a.gold < b.gold
		else
			return a.state > b.state
		end
	end
	if table.nums(tb2) > 1 then
		table.sort(tb2, cmp)
	end

	local function cmp3(a,b)
		return a.gold < b.gold
	end
	if table.nums(tb3) > 0 then
		if table.nums(tb3) > 1 then
			table.sort(tb3, cmp3)
		end

		for i = 1, table.nums(tb3) do
			table.insert(tb2, tb3[i])
		end
	end

	self.cellInfo = tb2
end

return RechargeGiftMain
