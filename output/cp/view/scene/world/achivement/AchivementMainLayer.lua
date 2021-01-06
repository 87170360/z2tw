
local BLayer = require "cp.view.ui.base.BLayer"
local AchivementMainLayer = class("AchivementMainLayer",BLayer)

function AchivementMainLayer:create(openInfo)
	local layer = AchivementMainLayer.new(openInfo)
	return layer
end

function AchivementMainLayer:initListEvent()
	self.listListeners = {
		
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:dispatchViewEvent(cp.getConst("EventConst").open_achivement_view, false) 
		end,
		
		[cp.getConst("EventConst").open_all_achive_attribute] = function(evt)
			self:showAllAttribute()
		end,

		--同步成就狀態列表
		[cp.getConst("EventConst").AchieveRsp] = function(data)
			
			self:refreshCellView()
			
		end,

		--成就跳轉
		[cp.getConst("EventConst").achive_goto] = function(data)
			self:achiveGoto(data)
		end,

		--領取成就獎勵
		[cp.getConst("EventConst").GetAchieveRsp] = function(data)
			local achive_config = cp.getUserData("UserAchivement"):getAchivementConfig()
			local info = achive_config[data.id]
				
			local itemList = {}
			if info.Items ~= "" then
				local strArr = {}
				string.loopSplit(info.Items,"|-",strArr)
				for i=1,table.nums(strArr) do
					if strArr[i][1] and strArr[i][2] and tonumber(strArr[i][1]) and tonumber(strArr[i][2]) and tonumber(strArr[i][1]) > 0 and tonumber(strArr[i][2]) > 0  then
						table.insert(itemList, {id=tonumber(strArr[i][1]),num=tonumber(strArr[i][2])})
					end
				end
			end

			if next(itemList) then
				cp.getManager("ViewManager").showGetRewardUI(itemList, "恭喜獲得", true, function() 
				end)
			end
			
			if self.cellView then
				self.cellView:reloadData()
			end
		end,

		
		--裝備成就稱號
		[cp.getConst("EventConst").SetAchieveTitleRsp] = function(data)
			local achive_config = cp.getUserData("UserAchivement"):getAchivementConfig()
			-- local info = achive_config[data.id]
				
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			local achieveID = majorRole.achieveID
			-- self.Button_equip:getChildByName("Text_1"):setString(achieveID == self.info.ID and "已裝備" or "裝備")

			cp.getManager("ViewManager").gameTip( achive_config[achieveID].Title .. " 稱號已裝備")
		
			if self.cellView then
				self.cellView:reloadData()
			end
		end,
		
	}
end

function AchivementMainLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_achievement/uicsb_achievement_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_border"] = {name = "Image_border"},
		
		["Panel_root.ScrollView_tab"] = {name = "ScrollView_tab"},
		["Panel_root.ScrollView_tab.Panel_tab_1"] = {name = "Panel_tab_1", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_2"] = {name = "Panel_tab_2", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_3"] = {name = "Panel_tab_3", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_4"] = {name = "Panel_tab_4", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_5"] = {name = "Panel_tab_5", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_6"] = {name = "Panel_tab_6", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_7"] = {name = "Panel_tab_7", click="onTabChange", clickScale=1},
		["Panel_root.ScrollView_tab.Panel_tab_8"] = {name = "Panel_tab_8", click="onTabChange", clickScale=1},

        ["Panel_root.Panel_cell"] = {name = "Panel_cell"},
        ["Panel_root.Image_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"}, -- clickScale = 1},
		["Panel_root.Image_top.Text_title"] = {name = "Text_title"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self:setPosition(0,0)
	self.rootView:setContentSize(display.size)

	self.TabButtons = {}
	for i=1,8 do
		self.TabButtons[i] = self["Panel_tab_" .. tostring(i)]
		self.TabButtons[i]:setTouchEnabled(true)
	end

	--動態調整panel3的節點width height
	local panel2Size = self.ScrollView_tab:getContentSize()
	local panel3Size = self.Panel_cell:getContentSize()
	local changeHeight = display.size.height - (1280 - self.Panel_cell:getPositionY())  - 130
	self.Panel_cell:setContentSize(cc.size(panel3Size.width, changeHeight))

	self.achiveShowList = {}
	self:createCellItems()

    ccui.Helper:doLayout(self["rootView"])
end

function AchivementMainLayer:onEnterScene()
	self.ShowType = 1

	self:switchToNewAchiveType()
end


function AchivementMainLayer:resetShowListData()
	local achive_list = cp.getUserData("UserAchivement"):getValue("achive_list")
	local achive_config = cp.getUserData("UserAchivement"):getAchivementConfig()
	self.achiveShowList = {}
	local listFinished = {}
	self.redStateList = {}
	for ID,info in pairs(achive_config) do
		if info.ShowType == self.ShowType then
			info.state = 0
			if achive_list and achive_list[ID] then
				info.state = achive_list[ID]
			end
			if info.state < 2 then
				table.insert( self.achiveShowList, info )
			else
				table.insert( listFinished, info )
			end
		end
	end

	--排序
	local function cmp(a,b)
		if a.state == b.state then
			return a.ID < b.ID
		else
			return a.state > b.state
		end
	end
		
	if table.nums(self.achiveShowList) > 1 then
		table.sort(self.achiveShowList, cmp)
	end
		
	if table.nums(listFinished) > 0 then
		if table.nums(listFinished) > 1 then
			table.sort(listFinished, cmp)
		end

		for i = 1, table.nums(listFinished) do
			table.insert(self.achiveShowList, listFinished[i])
		end
	end
	
	for ID,num in pairs(achive_list) do
		if num == 1 then
			local ShowType = achive_config[ID].ShowType
			if self.redStateList[ShowType] == nil then
				self.redStateList[ShowType] = 1
			end
		end
	end
	
	self:updateRedDot()
end

function AchivementMainLayer:onExitScene()
    
end

function AchivementMainLayer:onTabChange(sender)
	local name = sender:getName()
	log(name)
	self.ShowType = tonumber(string.sub(name,string.len("Panel_tab_") + 1))

	self:switchToNewAchiveType()
	
end

function AchivementMainLayer:switchToNewAchiveType()
	self:refreshTabButton()
	self:refreshCellView()
end

function AchivementMainLayer:refreshTabButton()
	
	for i=1,table.nums(self.TabButtons) do
		if self.TabButtons[i] then
			local Image_tab = self.TabButtons[i]:getChildByName("Image_tab")
			if Image_tab then
				local icon = "ui_achivement_module96_chengjiu_4.png"
				if i == self.ShowType then
					icon = "ui_achivement_module96_chengjiu_1.png"
				end
				Image_tab:loadTexture(icon, ccui.TextureResType.plistType) 
			end
		end
	end
end

function AchivementMainLayer:createCellItems()
    self.Panel_cell:removeAllChildren()

    local contentSize = self.Panel_cell:getContentSize()
	local cellSize = cc.size(720,340)
    self.cellView = cp.getManager("ViewManager").createCellView(contentSize)
    self.cellView:setCellSize(cellSize)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p((contentSize.width - cellSize.width)/2, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.achiveShowList)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1
        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
			cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.achivement.AchivementItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
		item:resetInfo(self.achiveShowList[idx])
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.Panel_cell:addChild(self.cellView)
end

function AchivementMainLayer:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log(buttonName)
	if buttonName == "Button_close" then
		self:dispatchViewEvent(cp.getConst("EventConst").open_achivement_view, false) 
	elseif buttonName == "Image_invite_frend" then 
	elseif buttonName == "Image_invite_bind" then
	elseif buttonName == "Image_days" then 
	elseif buttonName == "Image_fights" then
	end
end


function AchivementMainLayer:refreshCellView()
	
	self:resetShowListData()
	if self.cellView then
		self.cellView:reloadData()
	end
	
end

function AchivementMainLayer:setCloseCallBack(closeCallBack)
	self.closeCallBack = closeCallBack
end

function AchivementMainLayer:showAllAttribute()
	
	local AchivementEffectLayer = require("cp.view.scene.world.achivement.AchivementEffectLayer"):create()
	AchivementEffectLayer:initAllAttribute()
	self:addChild(AchivementEffectLayer, 2)
end

--成就界面快速跳轉到各個功能界面
function AchivementMainLayer:achiveGoto(data)
    
	dump(data)
	
	--[[...
	功能類型：
--前往藏寶閣
購買（）次江湖奇珍 8
收集（）套武學組合 9
收集（）套紫色武學 10
收集（）套金色武學 11
收集（）套紅色武學 12
購買（）次武林祕籍 30

--前往江湖界面
通關（）層修羅塔 18
掃蕩（）次副本 19
完成（）章劇情 20
完成（）次快速歷練 21
挑戰（）次祕境 22
華山論劍排名第（） 31

--前往大地圖界面
擊敗（）次江湖豪俠 13
完成（）次江湖事件 14

--進入幫派界面 
完成（）掃除 2
獲得（）幫貢 3
完成（）次緝拿 4
完成（）次掠奪戰 6
完成（）次幫派修築 5
加入幫會 37

比武場排名第（） 7
完成（）次比武 24
排行榜戰力排名第（） 25

成為VIP（） 1

--前往風雨樓
獲取（）次混元 15

--打開好友界面
添加（）個好友 16

--打開活動界面
食用（）次包子 17


收集（）套時裝 23


購買（）次體力 26
完成（）次長樂坊 27
完成（）次斗酒 28
完成（）次招財 29

--門派界面
門派地位 32
完成（）次門派修煉 33

--武學界面
完成（）次武學境界 34
完成（）次武學招式 35
完成（）次武學突破 36

完成其他成就 38
	
通過（）次困難本 39
學習（）本武學書 40

	]]
    
	if data.ShowType == 1 then
		cp.getUserData("UserAchivement"):setValue("GuideType", data.Type)
	end
	
    if data.Type == 18  or data.Type == 19 or data.Type == 20 or data.Type == 21 or data.Type == 22 or data.Type == 31 or data.Type == 39 then --劇情闖關,掃蕩副本,歷練,祕境,修羅塔,華山論劍,困難本
        local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif data.Type == 8 or data.Type == 9 or data.Type == 10 or data.Type == 11 or data.Type == 12 or data.Type == 30 then --藏寶閣抽獎
        local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif data.Type == 34 or data.Type == 35 or data.Type == 36 then  --武學相關
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillSummary}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif data.Type == 32 or data.Type == 33 then  --門派相關
        local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai,auto_open_name = "MenPaiXiuLian"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif data.Type == 7 or data.Type == 24 or data.Type == 25 then  --比武場
        self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, true)
	elseif data.Type == 13 or data.Type == 14 then -- 大地圖
        local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
	
	elseif data.Type == 2 or data.Type == 3 or data.Type == 4 or data.Type == 5 or data.Type == 6 or data.Type == 37 then --幫派界面
		self:dispatchViewEvent("GetPlayerGuildDataRsp", true)
	elseif data.Type == 15 then --混元
		self:dispatchViewEvent("GetPrimevalDataRsp", true)
	elseif data.Type == 16 then --好友
		self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,true)
	elseif data.Type == 17 then --包子
		self:dispatchViewEvent(cp.getConst("EventConst").open_activity_view,true)
	elseif data.Type == 23 then --時裝
		cp.getManager("ViewManager").showFashionMainLayer(nil)
	elseif data.Type == 26 then --體力購買
		cp.getManager("ViewManager").showBuyPhysicalUI()
	elseif data.Type == 27 then --鬥老千
        self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, true)
    elseif data.Type == 28 then  --斗酒
        self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, true)
    elseif data.Type == 29 then --招財
        cp.getManager("ViewManager").showSilverConvertUI()
    elseif data.Type == 1 then --儲值成為vip
		 cp.getManager("ViewManager").showRechargeUI()
	elseif data.Type == 40 then --學習武學書
		local info = {classname = "MajorDown",button_name="Button_BeiBao"}
		self:dispatchViewEvent(cp.getConst("EventConst").click_view_button, info)
		
	else
		-- 38  
		cp.getManager("ViewManager").gameTip("請大俠自行前往")
    end
	
	if data.Type > 0 and data.Type ~= 38 and data.Type ~= 40 then
		self:dispatchViewEvent("open_achivement_view", false)
	end
end

function AchivementMainLayer:updateRedDot()
	for i=1,8 do
		if self.redStateList[i] and self.redStateList[i] == 1 then
			cp.getManager("ViewManager").addRedDot(self.TabButtons[i],cc.p(54,125))
		else
			cp.getManager("ViewManager").removeRedDot(self.TabButtons[i])
		end
	end
end

return AchivementMainLayer
