
local BLayer = require "cp.view.ui.base.BLayer"
local FightGiftMain = class("FightGiftMain",BLayer)

function FightGiftMain:create(openInfo)
	local layer = FightGiftMain.new(openInfo)
	return layer
end

function FightGiftMain:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").GetFightGiftRsp] = function(data)	
			--dump(data)
			local cellInfo = self:getCellInfo()
			info = cellInfo[data.idx]
			cp.getManager("ViewManager").showGetRewardUI(info.values, "恭喜獲得", true, function() 
				self:refreshCellInfo()
				self:createCellItems()
			end)
        end,
	}
end

function FightGiftMain:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_fight_gift/uicsb_fight_gift_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},
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

function FightGiftMain:onEnterScene()
   self:createCellItems()
end

function FightGiftMain:onExitScene()
    
end

function FightGiftMain:createCellItems()
    self.Panel_content:removeAllChildren()
   
	local cellInfo = self:getCellInfo()

    local contentSize = self.Panel_content:getContentSize()
	local cellSize = cc.size(695,210)
    self.cellView = cp.getManager("ViewManager").createCellView(contentSize)
    self.cellView:setCellSize(cellSize)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p((contentSize.width - cellSize.width)/2, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(cellInfo)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1
        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.fightGift.FightGiftItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        item:resetInfo(cellInfo[idx], idx)
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.cellView:reloadData()
    self.Panel_content:addChild(self.cellView)
end

function FightGiftMain:refreshCellInfo()
	local tb = {}

	--從配置表載入數據
	--設置狀態
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local fightGift = cp.getUserData("UserRole"):getValue("fightGift")
	local conf = cp.getManager("ConfigManager").getConfig("FightGift")	
	for _, v in ipairs(conf.dataList) do
		local item = {}
		item.id = tonumber(v[1])
		item.fight = tonumber(v[2])
		item.values = {}
		item.show = 2
		--開啟狀態
		local open = false
		if item.fight <= roleAtt.fightTop then
			open = true
		end	
		--領取狀態
		local get = false
		if fightGift[item.id+1] then --伺服器數組下標從0開始，lua下標從1開始，數組第一個是等級0的狀態
			get = true
		end
		--表現狀態 1 可領取，2 未開啟，3 已領取
		if open then
			if get then
				item.show = 3
			else
				item.show = 1
			end
		end

		local values = {}
		string.loopSplit(v[3], "|-", values)
		for i1, v1 in pairs(values) do
			item.values[i1] = {id = tonumber(v1[1]), num = tonumber(v1[2])}
		end

		table.insert(tb, item)
	end

	--排序
    local function cmp(a,b)
		if a.show ~= b.show then
			return a.show < b.show
		else
			return a.fight < b.fight
		end
    end
    table.sort(tb, cmp)
	
	--篩選 去掉已領取，未開啟只保留10個
	local unopen = 0
	local tb2 = {}
	local tb3 = {}
	for _, v in ipairs(tb) do
		if v.show == 1 then
			table.insert(tb2, v)
		elseif v.show == 2 and unopen < 10 then
			table.insert(tb2, v)
			unopen = unopen + 1
		elseif v.show == 3 then
			table.insert(tb3, v)
		end
	end

	--保證顯示10條
	if table.nums(tb2) < 10 then
		local function cmp3(a,b)
			return a.fight > b.fight
		end
		table.sort(tb3, cmp3)
		local need = 10 - table.nums(tb2)
		for i = 1, need do
			if table.nums(tb3) > i then
				table.insert(tb2, tb3[i])
			end
		end
	end

	--dump(tb2)	
	self.cellInfo = tb2
end

function FightGiftMain:getCellInfo() 
	if self.cellInfo == nil then
		self:refreshCellInfo()
	end

	return self.cellInfo
end

return FightGiftMain
