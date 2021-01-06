local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    
    --門派進階挑戰返回
    [ProtoConst.GangEnhanceRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
        else
           
			self:dispatchViewEvent(cp.getConst("EventConst").GangEnhanceRsp,proto)
        end
    end,

	--門派請求地位排名訊息
	[ProtoConst.GangRankInfoRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
        else
           --[[
		   message GangRankInfoRsp {
				required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
				repeated GangRankInfo rankInfo              = 2;                    //地位訊息 
				required int32 maxCount                 = 4;                    //最大挑戰次數
			}
		   ]]

			local rankInfoList = {} -- 門派排名列表
			if proto.rankInfo ~= nil and next(proto.rankInfo) ~= nil then
				for i=1, table.nums(proto.rankInfo) do
					local info = proto.rankInfo[i]
					info.uid = info.uid ~= nil and string.trim(info.uid) or ""
					if info.npc > 0 then
						info.uid = ""

						local name,face = cp.getManager("GDataManager"):getGangNpcNameIcon(info.npc,info.rank,info.career)
						info.name = name
						info.face = face
					elseif info.uid ~= "" then
						info.npc = 0
					end
					
					if (info.npc > 0 or info.uid ~= "") and info.rank > 0 then
						-- rankInfoList[info.rank] = info
						table.insert(rankInfoList,info)
					end
				end
			end

			table.sort(rankInfoList,function(a, b)
				return a.rank < b.rank
			end)

			cp.getUserData("UserMenPai"):setValue("rankInfoList", rankInfoList)
			cp.getUserData("UserMenPai"):setValue("maxCount", proto.maxCount)

			-- cp.getUserData("UserMenPai"):setValue("leftCount", proto.leftCount)
			-- cp.getUserData("UserMenPai"):setValue("selfRank", proto.selfRank)
			self:dispatchViewEvent(cp.getConst("EventConst").GangRankInfoRsp,proto)
        end
    end,
    
	--刷新門派地位挑戰對象
	[ProtoConst.GangRankRefreshRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
        else
           --[[
		   message GangRankRefreshRsp {
				required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
				repeated GangRank rankInfo              = 2;                    //地位訊息 
			}
		   ]]

		   local fight_list_cache = {}
		   if proto.rankInfo ~= nil and next(proto.rankInfo) ~= nil then
				for i=1, table.nums(proto.rankInfo) do
					local info = proto.rankInfo[i]
					info.uid = info.uid ~= nil and string.trim(info.uid) or ""
					if info.npc > 0 then
						info.uid = ""
						local name,face = cp.getManager("GDataManager"):getGangNpcNameIcon(info.npc,info.rank,info.career)
						info.name = name
						info.face = face
					elseif info.uid ~= "" then
						info.npc = 0
					end
					
					if (info.npc > 0 or info.uid ~= "") and info.rank > 0 then
						table.insert(fight_list_cache,info)
					end
				end
		   end
		   cp.getUserData("UserMenPai"):setValue("fight_list_cache", fight_list_cache) 
		   
			self:dispatchViewEvent(cp.getConst("EventConst").GangRankRefreshRsp,proto)
        end
    end,
	
	--門派比武進入戰鬥
	[ProtoConst.GangRankFightRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
			if proto.respond == 17 then
				--"是否花費元寶購買挑戰次數？"
				--彈框購買？
			end
		end
		--錯誤和失敗都轉發
		self:dispatchViewEvent(cp.getConst("EventConst").GangRankFightRsp,proto)
    end,
	
	--門派請求排名獎勵
	[ProtoConst.GangRankAwardRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
			if proto.respond == 22 or proto.respond == 2 then --已經領取過了,或還未結算
				local now = cp.getManager("TimerManager"):getTime()
				local str = os.date("%Y-%m-%d", now)
				cp.getManager("LocalDataManager"):setUserValue("redpoint","GangRankAward_getDate",str)
				self:dispatchViewEvent(cp.getConst("EventConst").GangRankAwardRsp,proto)
			end
        else
           --[[
		   message GangRankAwardRsp {
				required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
				required int32 gold                     = 2;                    //元寶
				required int32 prestige                 = 3;                    //聲望
			}

		   ]]
		    local now = cp.getManager("TimerManager"):getTime()
		    local str = os.date("%Y-%m-%d", now)
		    cp.getManager("LocalDataManager"):setUserValue("redpoint","GangRankAward_getDate",str)
			self:dispatchViewEvent(cp.getConst("EventConst").GangRankAwardRsp,proto)
        end
    end,
	
	--重置門派挑戰次數
	[ProtoConst.GangRankBuyCountRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
			if proto.respond == 17 then
                local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日可重置次數已達上限。" or "您的可重置挑戰次數不足，提升VIP等級可獲得更多重置次數。" 
                cp.getManager("ViewManager").gameTip(str)
            end
		else

			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			major_roleAtt.gangRankCount = proto.count
			major_roleAtt.gangRankCountBuy = proto.buy

			self:dispatchViewEvent(cp.getConst("EventConst").GangRankBuyCountRsp,proto)
        end
	end,
	

	--請求門派修煉訊息返回
	[ProtoConst.GangPracticeInfoRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
		else
			local practiceLevelInfo = {}
			if proto.levelInfo ~= nil and next(proto.levelInfo) ~= nil then
				--practiceType: 0 刀， 1 劍， 2 棍， 3 奇, 4 拳， 5 聚
				
				for i=1,table.nums(proto.levelInfo) do
					practiceLevelInfo[proto.levelInfo[i].practiceType+1] = proto.levelInfo[i] 
				end
			end
			cp.getUserData("UserMenPai"):setValue("practiceLevelInfo", practiceLevelInfo)
			cp.getUserData("UserMenPai"):setValue("goldCount", proto.goldCount)
			cp.getUserData("UserMenPai"):setValue("silverCount", proto.silverCount)
		
			self:dispatchViewEvent(cp.getConst("EventConst").GangPracticeInfoRsp,proto)
        end
	end,

	--門派元寶修煉返回
	[ProtoConst.GangPracticeGoldRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
			
		else

			local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
			if proto.levelInfo ~= nil and next(proto.levelInfo) ~= nil then
				--practiceType: 0 刀， 1 劍， 2 棍， 3 奇, 4 拳， 5 聚
				practiceLevelInfo[proto.practiceType+1] = proto.levelInfo 
				
			end
			cp.getUserData("UserMenPai"):setValue("practiceLevelInfo", practiceLevelInfo)
			cp.getUserData("UserMenPai"):setValue("goldCount", proto.goldCount)
		
			self:dispatchViewEvent(cp.getConst("EventConst").GangPracticeGoldRsp,proto)
        end
	end,

	--門派銀兩修煉返回
	[ProtoConst.GangPracticeSilverRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
			
		else

			local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
			if proto.levelInfo ~= nil and next(proto.levelInfo) ~= nil then
				--practiceType: 0 刀， 1 劍， 2 棍， 3 奇, 4 拳， 5 聚
				practiceLevelInfo[proto.practiceType+1] = proto.levelInfo 
				
			end
			cp.getUserData("UserMenPai"):setValue("practiceLevelInfo", practiceLevelInfo)
			cp.getUserData("UserMenPai"):setValue("silverCount", proto.silverCount)
		
			self:dispatchViewEvent(cp.getConst("EventConst").GangPracticeSilverRsp,proto)
        end
	end,

	--門派道具修煉返回
	[ProtoConst.GangPracticeItemRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
			--彈錯誤提示
		else

			local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
			if proto.levelInfo ~= nil and next(proto.levelInfo) ~= nil then
				--practiceType: 0 刀， 1 劍， 2 棍， 3 奇, 4 拳， 5 聚
				practiceLevelInfo[proto.practiceType+1] = proto.levelInfo 
				
			end
			cp.getUserData("UserMenPai"):setValue("practiceLevelInfo", practiceLevelInfo)
		
			self:dispatchViewEvent(cp.getConst("EventConst").GangPracticeItemRsp,proto)
        end
	end,
}

return m