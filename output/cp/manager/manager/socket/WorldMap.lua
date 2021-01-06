local ProtoConst = cp.getConst("ProtoConst")

local m = {
	
	--獲取地圖上吃瓜群眾返回
	[ProtoConst.IdleStaffRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
        else
			local result = cp.getManager("ProtobufManager"):decode2Table("protocal.IdleStaffCompress", gzip.decompress(proto.data))
			local npc_list = {}
			if type(result.data) == "table" and next(result.data) ~= nil then
				for i=1,table.nums(result.data) do
					local info = result.data[i]
					if info.account ~= nil and string.trim(info.account) ~= "" then 
						npc_list[info.account] = info
					end
				end
			end 
			cp.getUserData("UserNpc"):setValue("npc_list", npc_list)
			self:dispatchViewEvent(cp.getConst("EventConst").IdleStaffRsp, npc_list)
		end
	end,
	
	--[[

	message ConductData {
    required string uuid                    = 1;                    //uuid
    required int32 confId                   = 2;                    //配置表id
    required int32 state                    = 3;                    //狀態 ConductState
    optional int64 startStamp               = 5;                    //事件開始時間戳
    optional string owner                   = 6;                    //擁有者帳號
    repeated BreakInfo breakInfo            = 7;                    //破壞訊息
    repeated uint32 ownerSkillId            = 8;                    //擁有者武學列表
    optional int32 ownerFight               = 9;                    //擁有者戰力
    optional string pos                     = 10;                   //位置索引
}
	]]
	--獲取地圖上的善惡事件列表
	[ProtoConst.GetConductRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			local result = cp.getManager("ProtobufManager"):decode2Table("protocal.ConductDataCompress", gzip.decompress(proto.data))
			
			result.data = result.data or {}
			dump(result.data)
			local map_event_list = {}
			if type(result.data) == "table" and next(result.data) ~= nil then
				for i=1,table.nums(result.data) do
					local info = result.data[i]
					if info.uuid ~= nil and string.trim(info.uuid) ~= "" then
						map_event_list[info.uuid] = info
					end
				end
			end 
			cp.getUserData("UserMapEvent"):clearMapEvent()
			cp.getUserData("UserMapEvent"):refreshMapEvent( map_event_list)

			self:dispatchViewEvent(cp.getConst("EventConst").GetConductRsp, map_event_list)
		end
	end,


	--切換善惡事件列表
	[ProtoConst.SwitchConductTypeRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
			local result = cp.getManager("ProtobufManager"):decode2Table("protocal.ConductDataCompress", gzip.decompress(proto.data))
			
			result.data = result.data or {}
			local map_event_list = {}
			if type(result.data) == "table" and next(result.data) ~= nil then
				for i=1,table.nums(result.data) do
					local info = result.data[i]
					if info.uuid ~= nil and string.trim(info.uuid) ~= "" then
						map_event_list[info.uuid] = info

					end
				end
			end 
			cp.getUserData("UserMapEvent"):clearMapEvent()
			cp.getUserData("UserMapEvent"):refreshMapEvent( map_event_list)
			
			if proto.conductType ~= majorRole.conductType then
				majorRole.conductType = proto.conductType
				majorRole.conductType = majorRole.conductType or 1
				majorRole.conductType = math.max(majorRole.conductType, 1) -- 善惡模式2 六扇門, 1 俠客堂
				local str = "切換到"
				str = str .. (majorRole.conductType == 1 and "俠客堂" or "六扇門")
				str = str .. "陣營"
				cp.getManager("ViewManager").gameTip(str)
			end

			self:dispatchViewEvent(cp.getConst("EventConst").GetConductRsp, map_event_list)
		end
	end,


	--請求開始掛機善惡事件
	[ProtoConst.StartHangConductRsp] = function( self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
			
		else
			if proto.data and  proto.data.uuid ~= nil and  proto.data.uuid ~= "" then
				
				local cur_uuid = proto.data.uuid
				local change_list = {}
				change_list[cur_uuid] = proto.data
				cp.getUserData("UserMapEvent"):refreshMapEvent(change_list)
				
				cp.getGameData("GameShane"):setValue("uuid",cur_uuid)
			end
			self:dispatchViewEvent(cp.getConst("EventConst").StartHangConductRsp,proto.data)
			
		end
	end,

	--請求開始戰鬥善惡事件
	[ProtoConst.StartFightConductRsp] = function( self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else

			self:dispatchViewEvent(cp.getConst("EventConst").StartFightConductRsp,proto)
		end
	end,
	

	--打斷別人的善惡掛機事件返回
	[ProtoConst.BreakHangConductRsp] = function( self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			dump(proto)
			self:dispatchViewEvent(cp.getConst("EventConst").BreakHangConductRsp,proto)
		end
	end,

	--更新善惡事件
	[ProtoConst.UpdateHangConductRsp] = function( self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			local result = cp.getManager("ProtobufManager"):decode2Table("protocal.ConductDataCompress", gzip.decompress(proto.data))
			dump(result)
			local change_list = {}
			if type(result.data) == "table" and next(result.data) ~= nil then
				for i=1,table.nums(result.data) do
					local info = result.data[i]
					if info.uuid ~= nil and string.trim(info.uuid) ~= "" then
						change_list[info.uuid] = info

						if info.breakInfo and next(info.breakInfo) and info.breakInfo[1].battleID and info.breakInfo[1].battleID > 0 then
							for j=1,table.nums(info.breakInfo) do
								local newBreakInfo = clone(info.breakInfo[j])
								newBreakInfo.confId = info.confId
								newBreakInfo.isNew = true
								newBreakInfo.type = "BreakHangConduct"
								cp.getUserData("UserVan"):addNewNotice(newBreakInfo)
							end
						end
					end
				end
			end 

			cp.getUserData("UserMapEvent"):refreshMapEvent(change_list)	
			
			self:dispatchViewEvent(cp.getConst("EventConst").UpdateHangConductRsp,change_list)
			
		end
	end,
	
	--結束善惡事件
	[ProtoConst.StopConductRsp] = function( self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			dump(proto)
			
			local map_event_list = cp.getUserData("UserMapEvent"):getValue("map_event_list")
			local eventInfoList = {}
			if proto.uuid and next(proto.uuid) then
				for i=1,#proto.uuid do
					table.insert(eventInfoList, map_event_list[proto.uuid[i]])
					cp.getUserData("UserMapEvent"):removeEvent(proto.uuid[i])	
				end
			end
			proto.eventInfoList = eventInfoList
			local event_list = cp.getUserData("UserMapEvent").map_event_list
			self:dispatchViewEvent(cp.getConst("EventConst").StopConductRsp,proto)
		end
	end,

	--挑戰吃瓜群眾返回
	[ProtoConst.StartFightIdleStaffRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			dump(proto)
			self:dispatchViewEvent(cp.getConst("EventConst").StartFightIdleStaffRsp,proto)
		end
	end,


	--獲取江湖大俠列表
	--[[
		//大俠數據
			message HeroInfo {
			required int32 x         = 1;    //座標 
			required int32 y         = 2;    //座標
			required int32 ID        = 3;    //NPC id
			required int32 state     = 4;    //狀態 0 正常， 1 已經打敗過， 2 已經收買過
			required string uuid     = 5;    //唯一索引
			}
	]]
	[ProtoConst.GetHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			-- dump(proto)	
			local hero_list = {}
			if type(proto.info) == "table" and next(proto.info) ~= nil then
				for i=1,table.nums(proto.info) do
					local info = proto.info[i]
					if info.ID > 0 and info.uuid ~= nil and string.trim(info.uuid) ~= "" then 
						hero_list[info.uuid] = info
					end
				end
			end 
			cp.getUserData("UserNpc"):setValue("hero_list", hero_list)

			cp.getUserData("UserNpc"):setValue("leftTime", proto.leftTime) -- 下次刷新時間
			cp.getUserData("UserNpc"):setValue("bribe", proto.bribe)  -- 一鍵收買需要元寶
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取
			
			self:dispatchViewEvent(cp.getConst("EventConst").GetHeroRsp,hero_list)
		end
	end,

	--挑戰江湖大俠
	[ProtoConst.StartFightHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
		else
			if proto.success then
				local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
				for uuid, info in pairs(hero_list) do
					if proto.uuid  == uuid then
						hero_list[proto.uuid].state = 1 --  //狀態 0 正常, 1 自己已經打敗過, 2 已經收買過, 3 邀請他人打敗過 
						-- cp.getUserData("UserNpc"):setValue("hero_list",hero_list)
					end
				end
			end
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取
			self:dispatchViewEvent(cp.getConst("EventConst").StartFightHeroRsp,proto)
		end
	end,

	--收買(結交)江湖大俠
	[ProtoConst.BribeHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
			for uuid, info in pairs(hero_list) do
				if proto.uuid  == uuid then
					hero_list[proto.uuid].state = 2 --  //狀態 0 正常, 1 自己已經打敗過, 2 已經收買過, 3 邀請他人打敗過 
					-- cp.getUserData("UserNpc"):setValue("hero_list",hero_list)
				end
			end
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取
			self:dispatchViewEvent(cp.getConst("EventConst").BribeHeroRsp,proto)
		end
	end,
	
	--求助幫忙挑戰大俠返回
	[ProtoConst.InviteHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getManager("ViewManager").gameTip("你已向江湖同道發起求助。")
		end
	end,
	
	--接受並幫助挑戰大俠
	[ProtoConst.AcceptHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			
			self:dispatchViewEvent(cp.getConst("EventConst").AcceptHeroRsp,proto)
		end
	end,

	--他人幫你擊敗大俠
	[ProtoConst.OtherDefeatRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
			for uuid, info in pairs(hero_list) do
				if proto.info.uuid  == uuid then
					hero_list[proto.uuid].state = 3 --  //狀態 0 正常, 1 自己已經打敗過, 2 已經收買過, 3 邀請他人打敗過 
					-- cp.getUserData("UserNpc"):setValue("hero_list",hero_list)
				end
			end
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取

			self:dispatchViewEvent(cp.getConst("EventConst").OtherDefeatRsp,proto)
		end
	end,
	

	--收買全部大俠
	[ProtoConst.BribeAllHeroRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
			for uuid, info in pairs(hero_list) do
				if hero_list[uuid].state == 0 then --  //狀態 0 正常, 1 自己已經打敗過, 2 已經收買過, 3 邀請他人打敗過 
					hero_list[uuid].state = 2
				end
				-- cp.getUserData("UserNpc"):setValue("hero_list",hero_list)
				
			end
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取

			local item_list = {}
			if proto.silver > 0 then
				table.insert(item_list, {id = 2,num = proto.silver })
			end
			if proto.items ~= nil and next(proto.items) ~= nil then
				for i=1,#proto.items do
					if proto.items[i] and proto.items[i].itemid > 0 and proto.items[i].itemnum > 0 then
						table.insert(item_list, {id = proto.items[i].itemid, num = proto.items[i].itemnum })
					end
				end
			end
			if table.nums(item_list) > 0 then
				cp.getManager("ViewManager").showGetRewardUI(item_list,"義結金蘭",true)
			end

			self:dispatchViewEvent(cp.getConst("EventConst").BribeAllHeroRsp,proto)
		end
	end,
	
	
	--領取累積獎勵
	[ProtoConst.GetAccuAwardRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getUserData("UserNpc"):setValue("award", proto.award)  -- 累積獎勵情況, 0 未達成， 1 可領取，2 已領取
			local item_list = {}
			if proto.items ~= nil and next(proto.items) ~= nil then
				for i=1,#proto.items do
					if proto.items[i] and proto.items[i].itemid > 0 and proto.items[i].itemnum > 0 then
						table.insert(item_list, {id = proto.items[i].itemid, num = proto.items[i].itemnum })
					end
				end
			end
			if table.nums(item_list) > 0 then
				cp.getManager("ViewManager").showGetRewardUI(item_list,"恭喜獲得",true)
			end
			
			self:dispatchViewEvent(cp.getConst("EventConst").GetAccuAwardRsp,proto)
		end
	end,

	--請求自己的鏢車訊息
	[ProtoConst.GetSelfVanRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			
			cp.getUserData("UserVan"):setValue("van_list",proto.vans)
			cp.getUserData("UserVan"):setValue("refreshStamp",proto.refreshStamp)
			cp.getUserData("UserVan"):setValue("refreshCount",proto.refreshCount)
			cp.getUserData("UserVan"):setValue("robCount",proto.robCount)
			cp.getUserData("UserVan"):setValue("escortCount",proto.escortCount)
			cp.getUserData("UserVan"):setValue("buyRobCount",proto.buyRobCount)
			
			self:dispatchViewEvent(cp.getConst("EventConst").GetSelfVanRsp,proto)
		end
	end,

	--刷新鏢車返回
	[ProtoConst.RefreshSelfVanRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getUserData("UserVan"):setValue("van_list",proto.vans)
			cp.getUserData("UserVan"):setValue("refreshStamp",proto.refreshStamp)
			cp.getUserData("UserVan"):setValue("refreshCount",proto.refreshCount)
			
			self:dispatchViewEvent(cp.getConst("EventConst").RefreshSelfVanRsp,proto)
		end
	end,

	--開始押鏢返回
	[ProtoConst.StartVanRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			local startStamp = proto.stamp
			if startStamp <= 0 then
				startStamp = cp.getManager("TimerManager"):getTime()
			end
			local vans = cp.getUserData("UserVan"):getValue("van_list")
			local idx = proto.vanIndex + 1
			vans[idx].uuid = proto.uuid
			vans[idx].startStamp = proto.stamp
			cp.getUserData("UserVan"):setValue("van_list",vans)
			cp.getUserData("UserVan"):setValue("escortCount",proto.escortCount)

			self:dispatchViewEvent(cp.getConst("EventConst").StartVanRsp,proto)
		end
	end,

	--[[
		message AllVanInfo {
			required string uuid                    = 1;                    //鏢車唯一ID 
			required int64 startStamp               = 2;                    //押鏢開始時間
			required int32 id                       = 3;                    //鏢車配置ID
			required int64 ownerRoleID              = 4;                    //
			required string ownerName               = 5;                    //
			required int32 ownerFight               = 6;                    // 
			required int32 ownerHierarchy           = 7;                    //階級 
			required int32 ownerCareer              = 8;                    //職業
			repeated RobInfo robInfo                = 9;                    //伏擊訊息
		}
	]]
	--獲取其他人的鏢車列表
	[ProtoConst.GetAllVanRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
			--錯誤處理
		else
			local now = cp.getManager("TimerManager"):getTime()
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

			local other_van_list = {}
			if proto.vans ~= nil and next(proto.vans) ~= nil then
				for i=1,#proto.vans do
					if proto.vans[i].id > 0 and proto.vans[i].uuid ~= nil and proto.vans[i].ownerRoleID ~= major_roleAtt.id and (table.nums(proto.vans[i].robInfo)<2) then
						local totalTime = cp.getManager("GDataManager"):getVanTotalTime(proto.vans[i].id)
						local lastTime = now - proto.vans[i].startStamp
						if lastTime <= totalTime then
							other_van_list[proto.vans[i].uuid] = proto.vans[i]
						end
					end
				end
			end
			cp.getUserData("UserVan"):setValue("other_van_list",other_van_list)
			self:dispatchViewEvent(cp.getConst("EventConst").GetAllVanRsp,proto)
		end
	end,

	--開始伏擊返回
	[ProtoConst.RobVanRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getUserData("UserVan"):setValue("robCount",proto.robCount)
			self:dispatchViewEvent(cp.getConst("EventConst").RobVanRsp,proto)
		end
	end,

	--被伏擊通知
	[ProtoConst.BeRobVanRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			
			proto.isNew = true
			proto.type = "BeRobVan"
			cp.getUserData("UserVan"):addNewNotice(proto)

			self:dispatchViewEvent(cp.getConst("EventConst").BeRobVanRsp,proto)
		end
	end,

	--購買伏擊次數
	[ProtoConst.BuyRobRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			cp.getUserData("UserVan"):setValue("buyRobCount",proto.buyRobCount)
			self:dispatchViewEvent(cp.getConst("EventConst").BuyRobRsp,proto)
		end
	end,

	--查看大俠狀態
	[ProtoConst.ViewHeroStateRsp] = function(self,key,proto,senddata)
		if proto.respond ~= 0 then
			--錯誤處理
		else
			if proto.state == 0 then
				self:dispatchViewEvent(cp.getConst("EventConst").ViewHeroStateRsp,proto)
			else
				cp.getManager("ViewManager").gameTip("該豪傑已被其他玩家擊敗。")
			end
			
		end
	end,
	
}

return m
