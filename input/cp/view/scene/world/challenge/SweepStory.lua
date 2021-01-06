local BLayer = require "cp.view.ui.base.BLayer"
local SweepStory = class("SweepStory",BLayer)

function SweepStory:create(openInfo)
	local layer = SweepStory.new(openInfo)
	return layer
end

function SweepStory:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
			self:onEnterScene()
		end,
	}

end

-- local openInfo = {id = self.chapter*1000 + self.part, combat_type = cp.getConst("CombatConst").CombatType_Story, hard_level = 1}
function SweepStory:onInitView(openInfo)
	-- self.opneInfo = openInfo

	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_saodang.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_bg"] = {name = "Panel_bg"},

		["Panel_root.Panel_bg.Panel_bottom"] = {name = "Panel_bottom"}, 
		["Panel_root.Panel_bg.Panel_bottom.Image_level_bg.Text_name"] = {name = "Text_name"},

		["Panel_root.Panel_bg.Panel_bottom.Image_progress"] = {name = "Image_progress"},
      	["Panel_root.Panel_bg.Panel_bottom.Image_progress.LoadingBar_1"] = {name = "LoadingBar_1"},
		["Panel_root.Panel_bg.Panel_bottom.Image_progress.Text_exp"] = {name = "Text_exp"},  

		["Panel_root.Panel_bg.Panel_bottom.Image_Physical"] = {name = "Image_Physical"},
		["Panel_root.Panel_bg.Panel_bottom.Image_Physical.Text_Physical"] = {name = "Text_Physical"},
	    ["Panel_root.Panel_bg.Panel_bottom.Image_Physical.Button_AddPhysical"] = {name = "Button_AddPhysical", click = "onButtonClick"},  
		
		["Panel_root.Panel_bg.Panel_bottom.Button_one"] = {name = "Button_one", click = "onButtonClick"},  
		["Panel_root.Panel_bg.Panel_bottom.Button_more"] = {name = "Button_more", click = "onButtonClick"},
		["Panel_root.Panel_bg.Panel_bottom.Button_close"] = {name = "Button_close", click = "onButtonClick"},  

		["Panel_root.Panel_bg.Panel_top"] = {name = "Panel_top"},
		["Panel_root.Panel_bg.Panel_top.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Panel_bg.Panel_top.Image_light"] = {name = "Image_light"},
        ["Panel_root.Panel_bg.Panel_top.ScrollView_1"] = {name = "ScrollView_1"},  
        ["Panel_root.Panel_bg.Panel_top.Panel_reward"] = {name = "Panel_reward"},  
		   
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	if self.Button_more ~= nil then
		local hard_level = cp.getGameData("GameChallenge"):getValue("hard_level")
		local Text_1 = self.Button_more:getChildByName("Text_1")
		Text_1:setString(hard_level == 1 and "掃蕩三次" or  "掃蕩十次")
	end

	--分辨率適配
	self:adapterReslution()

end

--分辨率適配
function SweepStory:adapterReslution()	
	self.rootView:setContentSize(display.size)
	ccui.Helper:doLayout(self.rootView)
	self.Button_one:setVisible(false)
	self.Button_more:setVisible(false)
end



function SweepStory:onEnterScene()
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self.Text_Physical:setString(string.format("%d/%d", majorRole.physical, majorRole.physicalMax))

    -- local action = cc.RotateBy:create(3, 360)
	-- self.Image_light:runAction(action)
end


--[[

	message CombatReward {
		optional uint32 money = 1;
		optional uint32 gold = 2;
		optional uint32 skill = 3;
		optional uint32 exp = 4;
		repeated ItemInfo item_list = 5;
	}

]]
function SweepStory:refreshSweepResult(reward_list)
	log("SweepStory:refreshSweepResult 111")
	--1.關卡虛擬物品
	-- 銀兩;元寶;修為點;閱歷值

	-- 1:銀兩 2:元寶 3：修為點(技能點) 4：領悟點 5.門派聲望值 6：俠義令 7：鐵膽令  8:體力 9：閱歷值(exp) 
	-- local typeList = {
	-- 	cp.getConst("GameConst").VirtualItemType.gold,
	-- 	cp.getConst("GameConst").VirtualItemType.silver,
	-- 	cp.getConst("GameConst").VirtualItemType.trainPoint,
	-- 	cp.getConst("GameConst").VirtualItemType.exp
	-- }

	self.Panel_reward:removeAllChildren()
	local totalW = self.Panel_reward:getContentSize().width
	reward_list.currency_list = reward_list.currency_list or {}
	local beginPosX = 0 --起始X座標
	local space = 0
	local totalNum = table.nums(reward_list.currency_list)
	if totalNum == 1 then
		beginPosX = totalW/2
		space = 0
	elseif totalNum == 2 then
		beginPosX = 125
		space = 110
	elseif totalNum == 3 then
		beginPosX = 70
		space = 50
	elseif totalNum == 4 then
		beginPosX = 10
		space = 30
	end

	local distance = 0
	log("SweepStory:refreshSweepResult totalNum = " .. tostring(totalNum))
	for i=1, totalNum do
		local item = require("cp.view.ui.item.HuobiItem"):create(reward_list.currency_list[i].type,reward_list.currency_list[i].num,true)
		self.Panel_reward:addChild(item)
		item:setPosition(beginPosX+50,0)
		beginPosX = beginPosX + item:getTotalWidth() + space
	end

	--3.關卡物品掉落
	self.ScrollView_1:removeAllChildren()
	log("SweepStory:refreshSweepResult item_list total = " .. tostring(table.nums(reward_list.item_list)))
	if reward_list.item_list ~= nil and next(reward_list.item_list) ~= nil then
		self:initItemList(reward_list.item_list)
	end

	local expPool = 0
	for i=1,#reward_list.currency_list do
		if reward_list.currency_list[i].type == cp.getConst("GameConst").VirtualItemType.exp then
			expPool = reward_list.currency_list[i].num
		end
	end

	log("SweepStory:refreshSweepResult 3333")
	dump(reward_list)
	local old_attr = cp.getUserData("UserRole"):getValue("major_roleAtt_old")
	local new_attr = cp.getUserData("UserRole"):getValue("major_roleAtt")
	log("new_attr.exp = " .. tostring(new_attr.exp))
	log("new_attr.expMax = " .. tostring(new_attr.expMax))
	if old_attr then
		log("old_attr.exp = " .. tostring(old_attr.exp))
	end

	local roleAttr = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", new_attr.level)
	local maxExp = roleAttr:getValue("ExpMax")

	self.Text_name:setString(roleAttr:getValue("Realm"))
	if old_attr ~= nil and old_attr.level < new_attr.level then
		cp.getManager("ViewManager").showRoleLevelUpView(old_attr.level,new_attr.level,function()
			--人物升級界面返回操作，暫無
			
			cp.getUserData("UserRole"):setValue("major_roleAtt_old", nil)
		end)

		local exp = new_attr.exp
		self.LoadingBar_1:setPercent(100*exp/maxExp)
		self.Text_exp:setString(string.format("%d/%d",exp, maxExp))
	else
		local roleMaxLv = cp.getManager("GDataManager"):getRoleMaxLevel()
		if new_attr.level < roleMaxLv and new_attr.exp > 0 then
			self.LoadingBar_1:setPercent(100*(new_attr.exp-expPool)/maxExp)
			self.Text_exp:setString(string.format("%d/%d",(new_attr.exp-expPool), maxExp))

			self:addExp(expPool,new_attr.exp,maxExp,false)
		else
			self.LoadingBar_1:setPercent(100)
			self.Text_exp:setString(string.format("%d/%d",maxExp, maxExp))
		end
	end
end


function SweepStory:scaleEffect(dt)

	self.LoadingBar_1:setPercent(100*self.beginExp/self.maxExp)
	self.Text_exp:setString(string.format("%d/%d",self.beginExp, self.maxExp))
	local delta = 1
	if self.expPool >= 60 then
		delta = 5
	elseif self.expPool >= 40 then
		delta = 2
	end
	self.beginExp = self.beginExp + delta
	if self.beginExp > self.endExp then
		if self["var_schedule_exp"] then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self["var_schedule_exp"])
		end
		self["var_schedule_exp"] = nil
		self.beginExp = self.endExp
		self.LoadingBar_1:setPercent(100*self.endExp/self.maxExp)
		self.Text_exp:setString(string.format("%d/%d",self.endExp, self.maxExp))
		self.expPool = 0
	end
end

function SweepStory:addExp(expPool,curExp,maxExp,isLevelUp)
	if not expPool or expPool == 0 then
		self.LoadingBar_1:setPercent(100*curExp/maxExp)
		self.Text_exp:setString(string.format("%d/%d",curExp, maxExp))
		return
	end

	self.beginExp = curExp - expPool
	self.endExp = curExp
	self.expPool = expPool
	self.maxExp = maxExp

	if self["var_schedule_exp"] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self["var_schedule_exp"])
	end
	self["var_schedule_exp"] = nil
	self["var_schedule_exp"] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.scaleEffect),0,false)

end

-- 帶參數返回，參數(0:挑戰 1:掃蕩1次 2:掃蕩3次 3:關閉)
function SweepStory:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function SweepStory:onButtonClick(sender)
    local btnName = sender:getName()
    if "Button_close" == btnName then
        if self.closeCallBack ~= nil then
			self.closeCallBack(3)
		end
	elseif "Button_more" == btnName then
		cp.getGameData("GameChallenge"):setValue("times",3)
        if self.closeCallBack ~= nil then
			self.closeCallBack(2)
		end
	elseif "Button_one" == btnName then
		cp.getGameData("GameChallenge"):setValue("times",1)
        if self.closeCallBack ~= nil then
			self.closeCallBack(1)
		end
	elseif btnName == "Button_AddPhysical" then
		cp.getManager("ViewManager").showBuyPhysicalUI()
    end
end



function SweepStory:initItemList(itemList)
	if itemList == nil or #itemList == 0 then
		return
	end

	local scrollViewSize = self.ScrollView_1:getContentSize()

    local function createScrollItem(id,num,i,totalNum)
		local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
        if cfgItem == nil then
            log("cfgItem is nil id = " .. tostring(id))
        end
		local itemInfo = {id = id, num = num, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")}
        --itemInfo.shopModel = true  --控制物品icon數量的顯示規則
        local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
		item:setScale(1)
		item:setItemClickCallBack(nil)
		-- item:setItemClickCallBack(function(info)
		-- 	local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
		-- 	self:addChild(layer, 100)
		-- 	layer:hidePlaceAndButtons()
		-- end)
        self.ScrollView_1:addChild(item)
        
		local space = 0
		local sz = item:getContentSize()
        if totalNum <= 4 then --只有1行
            if totalNum == 1 then
                space = 0
            elseif totalNum == 2 then
                space = 90
            elseif totalNum == 3 then
                space = 60
            elseif totalNum == 4 then
                space = 35
            end
            local startX = scrollViewSize.width/2 - totalNum/2 * sz.width - (totalNum-1)*space/2
            startX = startX < 0 and 0 or startX
            local x = startX + (i-1)*sz.width + (i-1)*space
            item:setPosition(cc.p(x+sz.width/2,scrollViewSize.height - sz.height/2-20))
        else
            scrollViewSize = self.ScrollView_1:getInnerContainerSize()
            --每行4列
            local y = math.floor((i-1)/4)  -- 0開始
            local x = math.floor((i-1)%4)  -- 0,1,2,3
            item:setPosition(cc.p((sz.width+30)*x+sz.width,scrollViewSize.height - y*(sz.height+40 ) - (sz.height/2+20)))
        end
        item:setVisible(true)
    end
        
    local totalNum = #itemList
	local newHeight = 150
	local sz = cc.size(110,110) --一個物品框的大小
	if totalNum > 4 then
		local row = math.floor(totalNum / 4) + 1
		local newHeight = row * (sz.height+40)
		self.ScrollView_1:setInnerContainerSize(cc.size(scrollViewSize.width, newHeight))
	end
	for i=1,totalNum do
		local id = itemList[i].item_id
		local num = itemList[i].item_num
		createScrollItem(id,num,i,totalNum)
	end
	ccui.Helper:doLayout(self.rootView)
end


return SweepStory
