local ProtoConst = cp.getConst("ProtoConst")

local m = {
	--獲取角色屬性返回
	[ProtoConst.GetRoleRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			local old_attr = cp.getUserData("UserRole"):getValue("major_roleAtt")
    		cp.getManager("GDataManager"):showFightChange(old_attr.fight, proto.roleAtt.fight)
    		cp.getManager("GDataManager"):hierarchyChange(old_attr.hierarchy, proto.roleAtt.hierarchy)

			if old_attr.level ~= proto.roleAtt.level then
				cp.getUserData("UserRole"):setValue("major_roleAtt_old", old_attr)
				TDGAAccount:setLevel(proto.roleAtt.level)

				local channelName = cp.getManualConfig("Channel").channel
				if channelName == "lunplay" then
					local platform = device.platform
					if LunPlay and platform == "ios" then
						local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
						local server = lastServerInfo.name
						local server_id = "nzljh" .. tostring(lastServerInfo.id)
						local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
						
						-- local passport = cp.getUserData("UserLogin"):getValue("user_token")
						LunPlay:baoCunServer(server_id,major_roleAtt.id,proto.roleAtt.level)
					end
					if platform == "android" then
						local params = {level = proto.roleAtt.level}
						cp.getManager("ChannelManager"):onExtraFunction("upLevel",params,nil)
					end
				end
			end
			
			cp.getUserData("UserRole"):setValue("major_roleAtt", proto.roleAtt)
			cp.getUserData("UserRole"):setValue("guildAtt", proto.guildAtt) -- 幫派屬性
			self:dispatchViewEvent(cp.getConst("EventConst").GetRoleRsp, proto)

			if proto.roleAtt.gangRank > 0 then
				local str = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
				if str == "0-0-0" then
					local now = cp.getManager("TimerManager"):getTime()
					local str = os.date("%Y-%m-%d", now)
					cp.getManager("LocalDataManager"):setUserValue("redpoint","GangRankAward_firstGetDate",str)
				end
			end

			if old_attr.level ~= proto.roleAtt.level then
				self:dispatchViewEvent(cp.getConst("EventConst").onRoleLevelChange, proto.roleAtt.level)
			end
		end
	end,
	
	--更改虛擬貨幣
	[ProtoConst.UpdateCurrencyRsp] = function(self,key,proto,senddata)

			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

			for _, currencyInfo in ipairs(proto.currency_list) do
				if currencyInfo.currency_type == 1 then
					roleAtt.silver = currencyInfo.number
				elseif currencyInfo.currency_type == 2 then
					roleAtt.gold = currencyInfo.number
				elseif currencyInfo.currency_type == 3 then
					cp.getUserData("UserSkill"):updateTrainPoint(currencyInfo.number)
				elseif currencyInfo.currency_type == 4 then
					cp.getUserData("UserSkill"):updateLearnPoint(currencyInfo.number)
				elseif currencyInfo.currency_type == 5 then
					roleAtt.prestige = currencyInfo.number
				elseif currencyInfo.currency_type == 6 then
					roleAtt.conductGood = currencyInfo.number
				elseif currencyInfo.currency_type == 7 then
					roleAtt.conductBad = currencyInfo.number
				elseif currencyInfo.currency_type == 8 then
					roleAtt.physical = currencyInfo.number
				elseif currencyInfo.currency_type == 9 then
					if cp.getUserData("UserRole"):getValue("major_roleAtt_old") == nil then
						cp.getUserData("UserRole"):setValue("major_roleAtt_old", table.simpleClone(roleAtt))
					end
					roleAtt.exp = currencyInfo.number
				elseif currencyInfo.currency_type == 10 then
					roleAtt.sins = currencyInfo.number
				elseif currencyInfo.currency_type == 11 then
					roleAtt.guild_money = currencyInfo.number
				elseif currencyInfo.currency_type == 12 then
					roleAtt.totalGood = currencyInfo.number
				elseif currencyInfo.currency_type == 13 then
					roleAtt.totalBad = currencyInfo.number
				elseif currencyInfo.currency_type == 14 then --時裝券
					local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
					fashion_data.coin = currencyInfo.number
				elseif currencyInfo.currency_type == 15 then --善惡事件剩餘次數
					roleAtt.normalEvent = currencyInfo.number
				elseif currencyInfo.currency_type == 16 then --vip經驗
					cp.getUserData("UserVip"):setValue("exp",currencyInfo.number or 0) 
				elseif currencyInfo.currency_type == 17 then --vip等級
					cp.getUserData("UserVip"):setValue("level",currencyInfo.number or 0) 
				elseif currencyInfo.currency_type == 18 then --玄玉
					roleAtt.jade = currencyInfo.number
				elseif currencyInfo.currency_type == 19 then --精力(俠客行)
					roleAtt.vigor = currencyInfo.number
				end
			end
		    self:dispatchViewEvent(cp.getConst("EventConst").UpdateCurrencyRsp, proto)
	end,

	--獲取角色物品返回(暫時沒有用了，以後看要不要刪除)
	[ProtoConst.GetRoleItemRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
        else
		    self:dispatchViewEvent(cp.getConst("EventConst").GetRoleItemRsp, proto)
		end
	end,

	--查看玩家訊息返回
	[ProtoConst.ViewPlayerRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			--[[
			message ViewPlayerRsp {
				required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
				optional RoleAtt roleAtt                = 2;                    //角色屬性
				repeated ItemData equipList             = 3;                    //裝備
				required int64 roleID                   = 4;
				required int32 zoneID                   = 5;
				repeated SkillSummary skill             = 6;                    //武學
			}
			]]
			if proto.roleAtt and proto.roleAtt.gangRank and proto.roleAtt.gangRank < 0 then
				proto.roleAtt.gangRank = 0 --門派地位
			end

		    self:dispatchViewEvent(cp.getConst("EventConst").ViewPlayerRsp, proto)
		end
	end,


	--查看物品詳情訊息返回
	[ProtoConst.ViewItemRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			--[[
			message ViewItemRsp {
				required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
				required ItemData item                  = 2;                    
			}
			]]
		    self:dispatchViewEvent(cp.getConst("EventConst").ViewItemRsp, proto)
		end
	end,

	--物品更新
	[ProtoConst.ItemUpdateRsp] = function(self,key,proto,senddata)
		
		cp.getUserData("UserItem"):updateItems(proto.itemNew,proto.itemDelID,proto.itemChange)

		self:dispatchViewEvent(cp.getConst("EventConst").ItemUpdateRsp, proto)
		self:dispatchViewEvent(cp.getConst("EventConst").refreshRedPoint, {})
	end,
	
	--使用裝備返回
	[ProtoConst.UseEquipRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_equip) --穿戴更換裝備
			self:dispatchViewEvent(cp.getConst("EventConst").UseEquipRsp, proto)
		end
	end,

	--開啟寶箱
	[ProtoConst.ChestItemRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
			if proto.respond == 10 then
				cp.getManager("ViewManager").gameTip("鑰匙不足") 
			end
		else
			cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_open_box)
			if proto.itemList ~= nil and next(proto.itemList) ~= nil then
				local itemList = {}
				for i=1,table.nums(proto.itemList) do
					table.insert(itemList, {id = proto.itemList[i].id, num=proto.itemList[i].num, hideName = false})
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"獲得物品",true)
			end
		end
	end,

	--分解武學書或武學碎片返回
	[ProtoConst.CrushSkillRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			if proto.ItemID ~= nil and proto.ItemNum ~= nil and proto.ItemID > 0 and proto.ItemNum > 0 then
				local itemList = {}
				table.insert(itemList, {id = proto.ItemID, num = proto.ItemNum, hideName = false})
				cp.getManager("ViewManager").showGetRewardUI(itemList,"分解獲得物品",true)
			end
			if proto.Savvy > 0 then
				cp.getManager("ViewManager").gameTip("獲得" .. tostring(proto.Savvy) .. "領悟點")
			end
		end
	end,

	--使用消耗品返回
	[ProtoConst.UseConsumeRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			if proto.ele ~= nil and next(proto.ele) then
				local itemList = {}
				for i=1,table.nums(proto.ele) do
					if proto.ele[i] and proto.ele[i].id > 0 and proto.ele[i].num > 0 then 
						table.insert(itemList, {id = proto.ele[i].id, num = proto.ele[i].num, hideName = false})
					end
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
			end

			--[[
			local silver = proto.silver
			local trainPoint = proto.trainPoint
			local physical = proto.physical
			local exp = proto.exp
			local guildGold = proto.guildGold
			if silver > 0 then
				cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_open_money_package)
				local str = "獲得" .. tostring(silver) .. "銀兩"
				cp.getManager("ViewManager").gameTip(str)
			end
			if trainPoint > 0 then
				local str = "獲得" .. tostring(trainPoint) .. "修為點"
				cp.getManager("ViewManager").gameTip(str)
			end
			if physical > 0 then
				local str = "獲得" .. tostring(physical) .. "體力"
				cp.getManager("ViewManager").gameTip(str)
			end
			if exp > 0 then
				local str = "獲得" .. tostring(exp) .. "閱歷值"
				cp.getManager("ViewManager").gameTip(str)
			end
			if guildGold > 0 then
				local str = "獲得" .. tostring(guildGold) .. "幫派個人資金"
				cp.getManager("ViewManager").gameTip(str)
			end
			]]
			
		end
	end,

	--出售物品返回
	[ProtoConst.SellItemRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			cp.getManager("ViewManager").gameTip("獲得"..proto.silver.."銀兩")
			cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_open_money_package)
			self:dispatchViewEvent(cp.getConst("EventConst").SellItemRsp, proto)
		end
	end,

	--使用武學書返回
	[ProtoConst.SkillItemRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			local skillId = proto.skillId --武學id
			local cfgItem = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillId)
			if cfgItem ~= nil then
            	local name = cfgItem:getValue("SkillName")
				cp.getManager("ViewManager").gameTip("學會了新的武學：" .. name)
			end

			self:dispatchViewEvent(cp.getConst("EventConst").SkillItemRsp, proto)
		end
	end,

	--碎片合成
	[ProtoConst.FragMergeRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
		    self:dispatchViewEvent(cp.getConst("EventConst").FragMergeRsp, proto)
			if proto.id  ~= nil and proto.num ~= nil and proto.id  > 0 and proto.num > 0 then
				local itemList = {}
				table.insert(itemList, {id = proto.id , num = proto.num, hideName = false})
				cp.getManager("ViewManager").showGetRewardUI(itemList,"合成碎片獲得",true)
			end
			
			self:dispatchViewEvent(cp.getConst("EventConst").FragMergeRsp, proto)
		end
	end,
	

	--開始歷練
	[ProtoConst.StartExerciseRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
        else
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			major_roleAtt.exerciseId = proto.exerciseId
            cp.getUserData("UserRole"):setValue("major_roleAtt",major_roleAtt)
			
		    self:dispatchViewEvent(cp.getConst("EventConst").StartExerciseRsp, proto)
		end
	end,

	--快速歷練
	[ProtoConst.QuickExerciseRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
			if proto.respond == 17 then
				local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日購買次數已達上限。" or "提升VIP等級可獲得更多快速歷練次數" 
                cp.getManager("ViewManager").gameTip(str)
				
			end
        else
			
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			major_roleAtt.exerciseQuick = proto.exerciseQuick
            cp.getUserData("UserLilian"):setValue("fast_result_list",proto.exerCompress)
			
		    self:dispatchViewEvent(cp.getConst("EventConst").QuickExerciseRsp, proto)
		end
	end,
	
	--獲取歷練
	[ProtoConst.GetExerciseRsp] = function(self,key,proto,senddata)

		if proto.respond ~= 0 then
            --錯誤處理
		else
			cp.getUserData("UserLilian"):addNewResult(proto)
		    self:dispatchViewEvent(cp.getConst("EventConst").GetExerciseRsp, proto)
		end

	end,

	--歷練物品自動出售
	[ProtoConst.AutoSellRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			majorRole.exerciseAuto = proto.state
			self:dispatchViewEvent(cp.getConst("EventConst").AutoSellRsp, proto)
		end
	end,
	

	--聊天訊息接收
	[ProtoConst.ChatChannelRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
			 if proto.respond == 26 then
				local text = cp.getManager("GDataManager"):getTextFormat("forbit_speech")
				text = string.gsub(text, 'a', ""..proto.forbitTime)
				cp.getManager("ViewManager").gameTip(text)    
			 end
		else
			local broadcast_msg = nil
			if proto.channel == 5 then --廣播消息
				broadcast_msg = proto.content[1]
				local broadcast_msg_list = cp.getUserData("UserChatData"):getValue("broadcast_msg_list")
				broadcast_msg_list = broadcast_msg_list or {}
				table.insert(broadcast_msg_list,broadcast_msg)
				proto.channel = 0  --廣播消息加到系統頻道
			end
			cp.getUserData("UserChatData"):addNewMsg(proto)
			self:dispatchViewEvent(cp.getConst("EventConst").ChatChannelRsp, proto)

		end
	end,

	--分享返回
	[ProtoConst.ChatShareRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getManager("ViewManager").gameTip("已成功分享至世界頻道。")
		end
	end,

	--獲取已購買頭像列表返回
	[ProtoConst.GetFaceRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
	
		else
			if proto.face then
				local face_list = {}
				for i=1,#proto.face do
					if string.len(proto.face[i]) > 0 then
						table.insert( face_list, proto.face[i])
					end
				end
				cp.getUserData("UserRole"):setValue("buyface_list",face_list)
			end
			
			self:dispatchViewEvent(cp.getConst("EventConst").GetFaceRsp, proto)
		end
	end,

	--購買頭像返回
	[ProtoConst.BuyFaceRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			
		else
			if proto.face and string.len(proto.face) > 0 then
				local buyface_list = cp.getUserData("UserRole"):getValue("buyface_list")
				if table.arrIndexOf(buyface_list, proto.face) == -1 then
					table.insert(buyface_list, proto.face)
					cp.getUserData("UserRole"):setValue("buyface_list",buyface_list)
				end
			end
			self:dispatchViewEvent(cp.getConst("EventConst").BuyFaceRsp, proto)
		end
	end,

	--更換頭像返回
	[ProtoConst.ChangeFaceRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			
		else
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			roleAtt.face = proto.face
			self:dispatchViewEvent(cp.getConst("EventConst").ChangeFaceRsp, proto)
		end
	end,

	--購買體力返回
	[ProtoConst.BuyPhysicalRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			if proto.respond == 17 then
                local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日可購買次數已達上限。" or "提升VIP等級可獲得更多購買次數。" 
                cp.getManager("ViewManager").gameTip(str)
            end
		else
			local DefaultPhysical = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("DefaultPhysical")
			cp.getManager("ViewManager").gameTip("獲得" .. tostring(DefaultPhysical) .. "體力")
			local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			roleAtt.buyPhysical = proto.buyPhysical 
			-- cp.getUserData("UserRole"):setValue("major_roleAtt",roleAtt)
			self:dispatchViewEvent(cp.getConst("EventConst").BuyPhysicalRsp, proto)
		end
	end,

	--請求更新體力(6分鐘一次)
	[ProtoConst.UpdatePhysicalRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			
		else
			
			-- self:dispatchViewEvent(cp.getConst("EventConst").UpdatePhysicalRsp, proto)
		end
	end,
	
	--在線跨天數據同步
	[ProtoConst.OnlineCrossDayRsp] = function(self,key,proto,senddata)
		log("OnlineCrossDayRsp respond = " .. proto.respond)
		if proto.respond ~= 0 then
			
		else
			if proto.timeStamp and proto.timeStamp > 0 then
                cp.getManager("TimerManager"):resetTime(proto.timeStamp,true) --伺服器時間
			end
			if next(proto.roleAtt) then
				cp.getUserData("UserRole"):setValue("major_roleAtt", proto.roleAtt) -- 角色屬性
			end
			if next(proto.vipInfo) then
				cp.getUserData("UserVip"):resetVipInfo(proto.vipInfo)  --vip訊息
			end
			if next(proto.dailyData) then
				cp.getUserData("UserDailyData"):resetAllDailyData(proto.dailyData) --日常任務數據
			end
			self:dispatchViewEvent(cp.getConst("EventConst").OnlineCrossDayRsp, proto)
		end
	end,

	--同步指引進度
	[ProtoConst.ChangeLeadRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		
		else
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			major_roleAtt.lead = proto.lead
			--cp.getUserData("UserRole"):resetNewplayerguiderList(proto.lead)  --不需要再次同步數據，先改的UserRole數據，再向伺服器請求的同步

			local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
			local i,j = string.find(listStr.finished,"equip")
			if i and j and tonumber(j) then
				local channelName = cp.getManualConfig("Channel").channel
				if channelName == "lunplay" then
					local platform = device.platform
					local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
					local server = lastServerInfo.name
					local server_id = "nzljh" .. tostring(lastServerInfo.id)
					local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
					local passport = cp.getUserData("UserLogin"):getValue("user_token")

					if LunPlay and platform == "ios" then
						LunPlay:addTutorialCompletionPassport(passport,server_id,major_roleAtt.id)
					end
					if platform == "android" then
						local params = {roleId = tostring(major_roleAtt.id), serverCode = tostring(server_id)}
						cp.getManager("ChannelManager"):onExtraFunction("tutorialCompletion",params,nil)
					end
				end
			end
			
			self:dispatchViewEvent(cp.getConst("EventConst").ChangeLeadRsp, proto)
		end
	end,
	
	--特性解鎖
	[ProtoConst.FeatureRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then

		else
			cp.getUserData("UserRole"):setValue("major_feature", proto.data or {}) -- 角色屬性
			self:dispatchViewEvent(cp.getConst("EventConst").FeatureRsp, proto)
		end
	end,
		
	--玩家邀請好友數據同步
	[ProtoConst.InviteRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then

		else
			-- dump(proto)
			cp.getUserData("UserInvite"):setValue("invite_code", proto.code or "") 
			cp.getUserData("UserInvite"):setValue("inviteeCount", proto.inviteeCount or 0) 
			cp.getUserData("UserInvite"):setValue("giftState", proto.giftState or {}) 

			self:dispatchViewEvent(cp.getConst("EventConst").InviteRsp,proto)
		end
	end,

	--綁定邀請碼
	[ProtoConst.InviteBindRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			-- dump(proto)
			self:dispatchViewEvent(cp.getConst("EventConst").InviteBindRsp, proto)
		end
	end,

	--領取江湖行的獎勵
	[ProtoConst.InviteGiftRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			self:dispatchViewEvent(cp.getConst("EventConst").InviteGiftRsp, proto)
		end
	end,

	--禮包兌換
	[ProtoConst.FulfillGiftRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			if proto.gift ~= nil and next(proto.gift) ~= nil then
				local itemList = {}
				for i=1,table.nums(proto.gift) do
					table.insert(itemList, {id = proto.gift[i].type, num=proto.gift[i].value, hideName = false})
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"獲得物品",true)
			end
			self:dispatchViewEvent(cp.getConst("EventConst").FulfillGiftRsp, proto)
		end
	end,
	

	--俠客行訊息
	[ProtoConst.HeroStoryInfoRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			-- proto.extra = {{id=1001,num=1},{id=1002,num=1},{id=1003,num=2},{id=1004,num=1},{id=1005,num=1},{id=2001,num=0}}
			proto.current = (proto.current == 0 or proto.current == nil) and 1001 or proto.current
			cp.getUserData("UserXiakexing"):setValue("current", proto.current or 1001)
			local newStateList = {}
			if proto.extra and next(proto.extra) then  -- 額外寶箱獎勵
				for i,info in pairs(proto.extra) do
					table.insert(newStateList,info)
				end
			end
			cp.getUserData("UserXiakexing"):updateBoxStateList(newStateList)
			self:dispatchViewEvent(cp.getConst("EventConst").HeroStoryInfoRsp, proto)
		end
	end,
	

	--領取俠客行關卡的額外獎勵
	[ProtoConst.HeroStoryExtraRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			if proto.award and next(proto.award) then
				local itemList = {}
				for i=1,table.nums(proto.award) do
					if proto.award[i].id > 0 and proto.award[i].num > 0 then
						table.insert(itemList, {id = proto.award[i].id, num=proto.award[i].num, hideName = false})
					end
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
			end

			self:dispatchViewEvent(cp.getConst("EventConst").HeroStoryExtraRsp, proto)
		end
	end,

	--俠客行關卡挑戰1次
	[ProtoConst.HeroStoryChallengeRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			cp.getUserData("UserXiakexing"):setValue("current", proto.current or 1001)
			cp.getUserData("UserCombat"):setID(proto.id)
			self:dispatchViewEvent(cp.getConst("EventConst").HeroStoryChallengeRsp, proto)
		end
	end,

	--俠客行關卡掃蕩多次
	[ProtoConst.HeroStorySweepRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			
			if proto.award and next(proto.award) then
				local itemList = {}
				for i=1,table.nums(proto.award) do
					table.insert(itemList, {id = proto.award[i].id, num=proto.award[i].num, hideName = false})
				end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
			end

			self:dispatchViewEvent(cp.getConst("EventConst").HeroStorySweepRsp, proto)
		end
	end,
	
    --同步成就狀態列表
    [ProtoConst.AchieveRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
		else
			
            cp.getUserData("UserAchivement"):updateAchieveList(proto.element)
			
			self:dispatchViewEvent(cp.getConst("EventConst").AchieveRsp, proto)
		end
	end,
	
    --領取成就達成的獎勵
    [ProtoConst.GetAchieveRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

			self:dispatchViewEvent(cp.getConst("EventConst").GetAchieveRsp, proto)
        end
    end,
	
	--裝備成就稱號
	[ProtoConst.SetAchieveTitleRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

			self:dispatchViewEvent(cp.getConst("EventConst").SetAchieveTitleRsp, proto)
        end
    end,
	
	
	
}

return m
