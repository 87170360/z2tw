local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    
    --請求日常任務數據
    [ProtoConst.GetDailyDataRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            cp.getUserData("UserDailyData"):resetAllDailyData(proto.dailyData)
            
			self:dispatchViewEvent(cp.getConst("EventConst").GetDailyDataRsp,proto)
        end
    end,


    -- 領取任務積分獎勵
    [ProtoConst.GetDailyPointRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            local AccuID = proto.AccuID --積分id
            cp.getUserData("UserDailyData"):updateTaskData(0,0,AccuID)
            
            if AccuID > 0 then
                local AccuList = cp.getManager("GDataManager"):getDailyTaskAccuList() 
                if AccuList[AccuID] and AccuList[AccuID].item_list then
                    cp.getManager("ViewManager").showGetRewardUI(AccuList[AccuID].item_list,"恭喜獲得",true)
                end
            end

			self:dispatchViewEvent(cp.getConst("EventConst").GetDailyPointRsp,proto)
        end
    end,


    -- 領取任務獎勵
     [ProtoConst.GetDailyTaskRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
        else
            local taskID = proto.taskID  --任務id
            local accu = proto.accu --任務獎勵積分
            cp.getUserData("UserDailyData"):updateTaskData(taskID,accu,0)

            self:dispatchViewEvent(cp.getConst("EventConst").GetDailyTaskRsp,proto)
        end
    end,

}

return m