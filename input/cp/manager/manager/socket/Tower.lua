local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetTowerDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserTower"):setValue("TowerData", proto.tower_data)
        end
    end,
    [ProtoConst.FightTowerFloorRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserTower"):updateTowerFloor(proto)
            self:dispatchViewEvent("FightTowerFloorRsp", proto)
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("您的揹包已滿")
        end
    end,
    [ProtoConst.FightTowerQuickRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserTower"):updateTowerQuickBegin(proto)
            self:dispatchViewEvent("FightTowerQuickRsp")
        end
    end,
    [ProtoConst.QuickFightDoneRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        elseif proto.result == 0 then
            cp.getUserData("UserTower"):updateTowerQuickDone(proto)
            self:dispatchViewEvent("QuickFightDoneRsp", proto)
        end
    end,
    [ProtoConst.ResetTowerFightRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("重置次數已滿")
            return
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("元寶不足")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserTower"):updateTowerReset()
            self:dispatchViewEvent("ResetTowerFightRsp")
        end
    end,
    [ProtoConst.GetRankListRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            self:dispatchViewEvent("GetRankListRsp", proto)
        end
    end,
    [ProtoConst.UpdateTowerGuideRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserTower"):updateGuideStep(proto.step)
        self:dispatchViewEvent("UpdateTowerGuideRsp")
    end,
}

return m