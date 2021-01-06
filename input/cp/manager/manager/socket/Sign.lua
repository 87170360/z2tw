local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetSignInfoRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSign"):setValue("SignData", proto.sign)
        end
    end,
    [ProtoConst.SignRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserSign"):setValue("SignData", proto.sign)
        local param = nil
        if proto.result == 0 then
            self:dispatchViewEvent(cp.getConst("EventConst").SignRsp, proto.item_list)
        elseif proto.result == 1 then
            --cp.getManager("ViewManager").gameTip("已經簽到過了")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("已經補簽過了")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("補籤失敗，元寶不足")
        end
    end,
    [ProtoConst.GetSummarySignRewardRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip(string.format("當月簽到未滿%d天", proto.total_day))
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("已經領取過了")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        end

        if proto.result == 0 then
            cp.getUserData("UserSign"):updateSummaryReward(proto.total_day)
            self:dispatchViewEvent(cp.getConst("EventConst").GetSummarySignRewardRsp, proto.item_list)
        end
    end,
    [ProtoConst.SignAllRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSign"):updateResignAll()
            self:dispatchViewEvent(cp.getConst("EventConst").SignAllRsp, proto.item_list)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("補籤失敗，元寶不足")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        end
    end,
}

return m