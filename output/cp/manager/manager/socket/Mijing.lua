local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    
    --獲取祕境挑戰次數
    [ProtoConst.GetMijingRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            --[[
                message MijingInfo {
                    required int32 mijingType           = 1;                    //祕境類型1~6
                    required int32 numLeft              = 2;                    //剩餘挑戰次數
                    required int32 numMax               = 3;                    //最大挑戰次數
                    required uint32 numBuy              = 4;                    //購買次數
                }
            ]]
            local mijingInfoList = {}
            if proto.info ~= nil and next(proto.info) ~= nil then
                for i=1,table.nums(proto.info) do
                    if proto.info[i].mijingType > 0 then
                        mijingInfoList[proto.info[i].mijingType] = proto.info[i]
                    end
                end
            end

            cp.getUserData("UserMijing"):setValue("mijingInfoList", mijingInfoList)
			self:dispatchViewEvent(cp.getConst("EventConst").GetMijingRsp)
        end
    end,

    --開始挑戰
    [ProtoConst.StartMijingRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            if proto.respond == 17 then  --次數不足
                cp.getManager("ViewManager").gameTip("剩餘挑戰次數不足，請先重置挑戰次數!")
            elseif proto.respond == 20 then  --體力不足
                cp.getManager("ViewManager").showBuyPhysicalUI()
            end
        else
            --[[
                message StartMijingRsp {
                    required int32 respond               = 1;                    //處理結果(消息錯誤碼)
                    repeated MijingItem items            = 2;
                    required int32 exp                   = 3;
                    required bool success                = 4;
                    required uint32 numLeft              = 5;                    //剩餘挑戰次數
                }
            ]]
            
            cp.getUserData("UserMijing"):setValue("fightResult", proto)

            local id = cp.getUserData("UserMijing"):getValue("fight_id")
            local str = string.split(id,"_")
            local mijingType = tonumber(str[1]) 
            if mijingType > 0 then
                local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
                mijingInfoList[mijingType].numLeft = proto.numLeft
                cp.getUserData("UserMijing"):setValue("mijingInfoList", mijingInfoList)
            end
			self:dispatchViewEvent(cp.getConst("EventConst").StartMijingRsp,proto)
        end
    end,

     --購買挑戰次數
     [ProtoConst.BuyMijingRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            if proto.respond == 17 then
				local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日可重置次數已達上限。" or "您的可重置挑戰次數不足，提升VIP等級可獲得更多重置次數。" 
                cp.getManager("ViewManager").gameTip(str)
				
			end
        else
            --[[
                message BuyMijingRsp {
                    required int32 respond               = 1;                    //處理結果(消息錯誤碼)
                    required MijingInfo info             = 2;
                }
            ]]
            
            if proto ~= nil and proto.info ~= nil then
                local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
                mijingInfoList[proto.info.mijingType] = proto.info
                cp.getUserData("UserMijing"):setValue("mijingInfoList", mijingInfoList)
            end
            
			self:dispatchViewEvent(cp.getConst("EventConst").BuyMijingRsp,proto)
        end
    end
}

return m