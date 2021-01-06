
local BLayer = require "cp.view.ui.base.BLayer"
local MenPaiMockFights = class("MenPaiMockFights",BLayer)

function MenPaiMockFights:create(openInfo)
	local layer = MenPaiMockFights.new(openInfo)
	return layer
end

function MenPaiMockFights:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
		--門派比武返回
		[cp.getConst("EventConst").GangRankFightRsp] = function(proto)	
			if proto.respond == 0 then

				cp.getUserData("UserMenPai"):setValue("fight_grade",0)
				
				cp.getUserData("UserCombat"):resetFightInfo()
				cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)

				if self.Panel_one:isVisible() then
					self:checkFightRedDot(self.Button_fight_1)
				else
					self:checkFightRedDot(self.Button_fight)
				end

				local rewardList = {}
				rewardList.currency_list = {} 
				rewardList.item_list = {}
				if proto.prestige and proto.prestige > 0 then
					table.insert(rewardList.currency_list,{type=cp.getConst("GameConst").VirtualItemType.prestige, num = proto.prestige})
				end

				cp.getUserData("UserCombat"):setCombatReward(rewardList)
				cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
				
				if self.closeCallBack then
					self.closeCallBack("fight")
				end


			elseif proto.respond == 21 then
				-- proto.rankInfo
			end
		end,

		-- --刷新挑戰對象返回
		-- [cp.getConst("EventConst").GangRankRefreshRsp] = function(data)	

		-- 	local fight_list_cache = cp.getUserData("UserMenPai"):getValue("fight_list_cache") 
		-- 	local totalNum = table.nums(fight_list_cache)

		-- 	local current_fight_List = {}
		-- 	local idxList = {}
		-- 	while(table.nums(idxList) < 5) do
		-- 		local idx =  math.random(1,totalNum)
		-- 		if table.arrIndexOf(idxList,idx) == -1 then
		-- 			table.insert(idxList,idx)
		-- 		end
		-- 	end
		-- 	for i=1,table.nums(idxList) do
		-- 		table.insert(current_fight_List,fight_list_cache[idxList[i]])
		-- 	end
		-- 	table.sort(current_fight_List,function(a, b)
		-- 		return a.rank < b.rank
		-- 	end)

		-- 	cp.getUserData("UserMenPai"):setValue("current_fight_List", current_fight_List)
		-- 	self:refreshItems()
		-- end, 

		--重置挑戰次數
		[cp.getConst("EventConst").GangRankBuyCountRsp] = function(data)	
			
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			local maxCount = cp.getUserData("UserMenPai"):getValue("maxCount")
			self.Text_num:setString(tostring(major_roleAtt.gangRankCount) .. "/" .. tostring(maxCount) )

			if self.Panel_one:isVisible() then
				self:checkFightRedDot(self.Button_fight_1)
			else
				self:checkFightRedDot(self.Button_fight)
			end
		end, 
		
		--領取挑戰獎勵
		[cp.getConst("EventConst").GangRankAwardRsp] = function(data)
			if data.respond == 0 then
				local prestige = data.prestige
				local gold = data.gold
				local itemList = {}
				if prestige > 0 then
					table.insert(itemList, {id = 1096, num = prestige})
				end
				if gold > 0 then
					table.insert(itemList, {id = 3, num = gold})
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
			end
			self:checkRedDot()
		end,

		--查看門派比武記錄
		[cp.getConst("EventConst").GetCombatListRsp] = function(proto)
            -- if proto.mode == "combat" then
                local layer = require("cp.view.scene.world.shaneevent.RiverCombatListLayer"):create(proto.combat_list)
                self:addChild(layer, 100)
            -- end
		end,
	}
end

function MenPaiMockFights:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_mockfights.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		
		["Panel_root.Panel_bg.Panel_content"] = {name = "Panel_content"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self"] = {name = "Panel_rank_self"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Image_rank"] = {name = "Image_rank"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Image_rank.Text_rank_self"] = {name = "Text_rank_self"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Image_shengwang"] = {name = "Image_shengwang"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Image_shengwang.Text_shengwang"] = {name = "Text_shengwang"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Panel_shengyu_num"] = {name = "Panel_shengyu_num"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Panel_shengyu_num.Button_buy"] = {name = "Button_buy",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Panel_shengyu_num.Text_num"] = {name = "Text_num"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Text_tip"] = {name = "Text_tip"},
		
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Button_rank_reward"] = {name = "Button_rank_reward",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Button_shop"] = {name = "Button_shop",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Panel_content.Panel_rank_self.Button_record"] = {name = "Button_record",click = "onUIButtonClick"},

		["Panel_root.Panel_bg.Panel_content.Panel_five"] = {name = "Panel_five"},
		["Panel_root.Panel_bg.Panel_content.Panel_five.Button_fight"] = {name = "Button_fight",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Panel_content.Panel_five.Button_refresh"] = {name = "Button_refresh",click = "onUIButtonClick"},

		["Panel_root.Panel_bg.Panel_content.Panel_one"] = {name = "Panel_one"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Node_role"] = {name = "Node_role"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Button_fight_1"] = {name = "Button_fight_1",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Image_bg.Text_fight"] = {name = "Text_fight"},
		
		["Panel_root.Panel_bg.Panel_content.Panel_one.Panel_one_top.Text_name"] = {name = "Text_name"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Panel_one_top.Text_level"] = {name = "Text_level"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Panel_one_top.Text_rank"] = {name = "Text_rank"},

		["Panel_root.Panel_bg.Panel_content.Panel_one.Panel_one_top.Image_rank_reward.Image_1"] = {name = "Image_1"},
		["Panel_root.Panel_bg.Panel_content.Panel_one.Panel_one_top.Image_rank_reward.Image_2"] = {name = "Image_2"},

		["Panel_root.Panel_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
 

	self.rootView:setContentSize(display.size)

	if display.height < 1000 then
		self.Panel_bg:setPositionY(925)
		self.Panel_rank_self:setPositionY(183)
		self.Image_rank:setPositionY(232)
		self.Image_shengwang:setPositionY(232)
		self.Text_rank_self:setPositionY(-15)
		self.Text_shengwang:setPositionY(-15)
		self.Text_tip:setPositionY(95)
		self.Button_record:setPositionY(140)
		self.Button_shop:setPositionY(140)
		self.Button_rank_reward:setPositionY(140)
		self.Panel_content:setPositionY(845)
	end
	
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").popUpView(self.Panel_root)
	self["fight_items"] = {}
end


function MenPaiMockFights:onEnterScene()

	-- local openInfo = { grade = grade}
	
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local maxCount = cp.getUserData("UserMenPai"):getValue("maxCount")
	self.Text_num:setString(tostring(major_roleAtt.gangRankCount) .. "/" .. tostring(maxCount) )

	self.Text_rank_self:setString(tostring(major_roleAtt.gangRank))
	self.Text_shengwang:setString(tostring(major_roleAtt.prestige))

	
	local curInfoList = cp.getUserData("UserMenPai"):getValue("current_fight_List")
	local num = table.nums(curInfoList)
	if num == 0 then
		local req = {}
		req.grade = self.openInfo.grade
		self:doSendSocket(cp.getConst("ProtoConst").GangRankRefreshReq, req)
		return
	elseif num == 1 then
		self:resetOne(curInfoList[1])
	else
		self:refreshItems()
		if display.height < 1000 then
			self.Panel_five:getChildByName("Node_4"):setPositionY(138)
			self.Panel_five:getChildByName("Node_5"):setPositionY(138)
		end
	end

	self:checkRedDot()

	if self.Panel_one:isVisible() then
		self:checkFightRedDot(self.Button_fight_1)
	else
		self:checkFightRedDot(self.Button_fight)
	end
end

function MenPaiMockFights:refreshItems()
	local function onItemClick(info)
		if info then
			for i=1,5 do
				if self["fight_items"][i]:getRank() == info.rank then
					self["fight_items"][i]:setSelected(true)
					self.curSelectIndex = i
				else 
					self["fight_items"][i]:setSelected(false)
				end
			end
		end
		
	end

	local curInfoList = cp.getUserData("UserMenPai"):getValue("current_fight_List")
	local num = table.nums(curInfoList)
	for i=1,num do
		if self["fight_items"][i] ~= nil then
			self["fight_items"][i]:setSelected(false)
		else
			local node = self["Panel_five"]:getChildByName("Node_" .. tostring(i))
			local item = require("cp.view.scene.world.menpai.MenPaiMockFightsItem"):create()
			item:setItemClickCallBack(onItemClick)
			node:addChild(item)
			self["fight_items"][i] = item 
		end
		local rankInfo = curInfoList[i]
		self["fight_items"][i]:reset(rankInfo)
	end

	self.Panel_five:setVisible(num > 1)
	self.Panel_one:setVisible(num == 1)
	self.Panel_shengyu_num:setPosition(cc.p(650,320))
end

function MenPaiMockFights:onExitScene()
   
end


function MenPaiMockFights:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
		cp.getUserData("UserMenPai"):setValue("fight_grade",0)
		if self.closeCallBack then
			self.closeCallBack("close")
		end
		
		
	elseif buttonName == "Button_buy" then

		self:checkTimes()

	elseif buttonName == "Button_rank_reward" then
		self:doSendSocket(cp.getConst("ProtoConst").GangRankAwardReq, req)
		
	elseif buttonName == "Button_shop" then
		self:openShengWangShop()
	elseif buttonName == "Button_record" then

		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local req = {}
        req.combat_type = cp.getConst("CombatConst").CombatType_MenPai
        req.time = os.time()-24*3600
        req.max_num = 40
        req.uid = major_roleAtt.account
        req.mode = "break"
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatListReq, req)
	elseif buttonName == "Button_refresh" then
		
		-- local req = {}
		-- req.grade = self.openInfo.grade or 7
		-- self:doSendSocket(cp.getConst("ProtoConst").GangRankRefreshReq, req)
		self:dispatchViewEvent(cp.getConst("EventConst").GangRankRefreshRsp,proto)
	elseif buttonName == "Button_fight_1" then

		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local maxCount = cp.getUserData("UserMenPai"):getValue("maxCount")
		if major_roleAtt.gangRankCount == 0 then
			self:checkTimes("挑戰次數不足,")			
			return
		end
		local curInfoList = cp.getUserData("UserMenPai"):getValue("current_fight_List")

		local retValue = self:checkLevelDistance(curInfoList[1].rank) 
		if retValue ~= "" then
			cp.getManager("ViewManager").gameTip(retValue)
			return
		end

		self.fightInfo = {name = curInfoList[1].name,rank = curInfoList[1].rank,career=major_roleAtt.career} 

		local req = {}
		req.npc = curInfoList[1].npc
		req.uid = curInfoList[1].uid
		req.rank = curInfoList[1].rank
		self:doSendSocket(cp.getConst("ProtoConst").GangRankFightReq, req)
	elseif buttonName == "Button_fight" then
		local curInfoList = cp.getUserData("UserMenPai"):getValue("current_fight_List")
		if self.curSelectIndex and self.curSelectIndex > 0 and curInfoList[self.curSelectIndex] ~= nil then

			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			local maxCount = cp.getUserData("UserMenPai"):getValue("maxCount")
			if major_roleAtt.gangRankCount == 0 then
				self:checkTimes("挑戰次數不足,")			
				return
			end

			local retValue = self:checkLevelDistance(curInfoList[self.curSelectIndex].rank) 
			if retValue ~= "" then
				cp.getManager("ViewManager").gameTip(retValue)
				return
			end

			self.fightInfo = {name = curInfoList[self.curSelectIndex].name,rank = curInfoList[self.curSelectIndex].rank,career=major_roleAtt.career} 

			local req = {}
			req.npc = curInfoList[self.curSelectIndex].npc
			req.uid = curInfoList[self.curSelectIndex].uid
			req.rank = curInfoList[self.curSelectIndex].rank
			self:doSendSocket(cp.getConst("ProtoConst").GangRankFightReq, req)
		else
			cp.getManager("ViewManager").gameTip("請先選擇一個挑戰對象。")
		end
    
    end
end

function MenPaiMockFights:resetOne(info)
	-- local info = {level = math.random(1,50), name = "司徒雷登" .. tostring(i), fight = math.random(1000,99999), rank = i ,career = math.random(0,7), gender = math.random(0,1),uid=0}
	
	self.Panel_five:setVisible(false)
	self.Panel_one:setVisible(true)

	self.Text_fight:setString("戰力: " .. tostring(info.fight))
	self.Text_name:setString(tostring(info.name))
	self.Text_level:setString("LV." .. tostring(info.level))
	self.Text_rank:setString(tostring(info.rank))
	
	self.Panel_shengyu_num:setPosition(cc.p(650,318))

	local gold,sw = 0,0
	if info.rank <= 1530 then
		local gangConf = cp.getManager("ConfigManager").getItemByKey("GangRank", "" .. info.rank)
		if gangConf ~= nil then	
			gold = gangConf:getValue("DailyGold")
			sw = gangConf:getValue("DailyPrestige")
		else
			--區間需查找具體位置
			local cnt = cp.getManager("ConfigManager").getItemCount("GangRank")
			for i=1, cnt do
				local item = cp.getManager("ConfigManager").getItemAt("GangRank",i)
				local ID = item:getValue("ID")
				local ids = string.split(ID,"-") 
				if table.nums(ids) == 2 then
					if tonumber(ids[1]) <= info.rank and info.rank <= tonumber(ids[2]) then
						gold = item:getValue("DailyGold")
						sw = item:getValue("DailyPrestige")
						break
					end
				end
			end

		end
	end
	--元寶獎勵
	self.Image_1:getChildByName("Text_value"):setString(tostring(gold))
	--聲望獎勵
	self.Image_2:getChildByName("Text_value"):setString(tostring(sw))

	self.Node_role:removeAllChildren()

	local WholeDraw = nil
	if info.npc > 0 then
		local npcCfg = cp.getManager("ConfigManager").getItemByKey("GameNpc", info.npc)
		WholeDraw = npcCfg:getValue("WholeDraw")
		local modelId = npcCfg:getValue("ModelID")
		if WholeDraw == "" or WholeDraw == nil then
			local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
			WholeDraw = itemCfg:getValue("WholeDraw")
		end
	else
		local cfg, _ = cp.getManager("GDataManager"):getMajorRoleIamge(info.fashionid or 0,info.career,info.gender) 
		WholeDraw = cfg:getValue("WholeDraw")
		
	end

	if WholeDraw ~= nil and WholeDraw ~= "" then
		self.Node_role:setPosition(cc.p(110,160))
		cp.getManager("ViewManager").addImage(self.Node_role, 0.65, WholeDraw)
	end

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local isSelf = major_roleAtt.account == info.uid
	if isSelf then
		self.Button_fight_1:setVisible(false)
		self.Panel_shengyu_num:setVisible(false)
	end

	--[[
	local model = nil
	if info.npc > 0 then
		model = cp.getManager("ViewManager").createNpc(info.npc)
	else
		local modelId = cp.getManager("GDataManager"):getModelId(info.career,info.gender)
		if modelId ~= nil and modelId > 0 then
			local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
			local modelFile = itemCfg:getValue("ModelFile")
			local weaponList = {[0] = "club", [1] = "blade", [2] = "blade", [3] = "blade", [4] = "knife", [5] = "blade", [6] = "dagger", [7] = "fist"}
			local weapon = weaponList[info.career]
			model = cp.getManager("ViewManager").createSpineAnimation(modelFile, weapon)
			model:setScale(1)
			model:setToSetupPose()
			model:setAnimation(0, weapon .. "_Win_start", false)
			model:addAnimation(0, weapon .. "_Win_loop", true)
		end
	end
	if model ~= nil then
		self.Node_role:addChild(model)
	end
	]]
end

function MenPaiMockFights:checkLevelDistance(rank)
	-- 你還沒有成為“*”！
	local retValue = ""
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local canFight = true
	if rank == 1 or rank == 2 or rank == 3 then
		if major_roleAtt.gangRank >= 8 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【鎮派高手】！"
		end
	elseif rank >= 4 and rank <= 7 then
		if major_roleAtt.gangRank >= 16 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【天下行走】！"
		end
	elseif rank >= 8 and rank <= 15 then
		if major_roleAtt.gangRank >= 31 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【真傳弟子】！"
		end
	elseif rank >= 16 and rank <= 30 then
		if major_roleAtt.gangRank >= 531 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【內門弟子】！"
		end
	elseif rank >= 31 and rank <= 530 then
		if major_roleAtt.gangRank >= 1531 or major_roleAtt.gangRank == 0  then
			canFight = false
			retValue = "你還沒有成為【外門弟子】！"
		end
	end

	return retValue
end


function MenPaiMockFights:openShengWangShop()
    if self.ShopMainUI ~= nil then
        self.ShopMainUI:removeFromParent()
    end
    self.ShopMainUI = nil
    
    local storeID = 6  --聲望商店
    local openInfo = {storeID = storeID, closeCallBack = function()
        self.ShopMainUI:removeFromParent()
        self.ShopMainUI = nil
    end}
    local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
    self.rootView:addChild(ShopMainUI)
    self.ShopMainUI = ShopMainUI

end

function MenPaiMockFights:checkTimes(extraTxt)
	extraTxt = extraTxt or ""
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local gangRankCountBuy = major_roleAtt.gangRankCountBuy

	local Config = cp.getManager("ConfigManager").getItemByKey("Other", "gang_rank_reset_cost")
	local str = Config:getValue("StrValue")
	local priceArr = string.split(str,"|")
	local price = tonumber(priceArr[math.min(gangRankCountBuy+1,table.nums(priceArr))])
   
	local function comfirmFunc()
		--檢測是否元寶足夠
		if cp.getManager("ViewManager").checkGoldEnough(price) then
			local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").GangRankBuyCountReq, req)
		end
	end
	
	local contentTable = {
		{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=extraTxt .. "是否消耗", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，來重置挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
	}
	cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
end

function MenPaiMockFights:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function MenPaiMockFights:checkRedDot()
	local now = cp.getManager("TimerManager"):getTime()
	local str = os.date("%Y-%m-%d", now)
	local saveValue = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_getDate","")
	local firstGetDate = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
	self.Button_rank_reward:getChildByName("Image_notice"):setVisible(saveValue ~= str and firstGetDate ~= str and firstGetDate ~= "0-0-0")

end

function MenPaiMockFights:checkFightRedDot(parent)

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local canGet = major_roleAtt.gangRankCount > 0
	if canGet then
		local sz = parent:getContentSize()
        cp.getManager("ViewManager").addRedDot(parent, cc.p(sz.width-5,sz.height-5))
    else
        cp.getManager("ViewManager").removeRedDot(parent)
    end
end

return MenPaiMockFights
