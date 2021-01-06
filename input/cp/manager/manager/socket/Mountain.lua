local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetMountainPlayerListRsp] = function(self,key,proto,senddata)
        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("活動尚未開始")
        end

        cp.getUserData("UserMountain"):setValue("PhaseStateList", proto.player_list)
        cp.getUserData("UserMountain"):setValue("ShowPhase", proto.show_phase)
        cp.getUserData("UserMountain"):setValue("CurrentPhase", proto.current_phase)
        cp.getUserData("UserMountain"):setValue("CurrentState", proto.current_state)
        self:dispatchViewEvent(cp.getConst("EventConst").GetMountainPlayerListRsp, true)
    end,
    [ProtoConst.GetMountainDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("獲取錯誤")
        end

        cp.getUserData("UserMountain"):setValue("MountainData", proto.mountain_data)
        self:dispatchViewEvent(cp.getConst("EventConst").GetMountainDataRsp)
    end,
    [ProtoConst.MountainGuessRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("獲取錯誤")
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("本輪已結束")
        end

        if proto.result == 2 then
            cp.getManager("ViewManager").gameTip("本輪助威已結束")
        end

        if proto.result == 3 then
            cp.getManager("ViewManager").gameTip("本輪助威次數已達上限")
        end

        if proto.result == 4 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        end

        if proto.result == 5 then
            cp.getManager("ViewManager").gameTip("已經助威對手")
        end

        if proto.result == 6 then
            cp.getManager("ViewManager").gameTip("已經助威過了")
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("助威成功")
            cp.getUserData("UserMountain"):updatePhaseStateGuess(proto.phase_state, proto.id)
            self:dispatchViewEvent(cp.getConst("EventConst").MountainGuessRsp)
        end
    end,
    [ProtoConst.SignUpMountainRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("獲取錯誤")
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("已經報名了")
        end

        if proto.result == 2 then
            cp.getManager("ViewManager").gameTip("報名人數已滿")
        end

        if proto.result == 3 then
            cp.getManager("ViewManager").gameTip("動尚未開始")
        end

        if proto.result == 4 then
            cp.getManager("ViewManager").gameTip("報名已結束")
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("報名成功")
            cp.getUserData("UserMountain"):updateSignState()
            self:dispatchViewEvent(cp.getConst("EventConst").SignUpMountainRsp)
        end
    end,
    [ProtoConst.GetMountainPhaseStateRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("獲取錯誤")
        end

        if #proto.player_list.player_list == 0 then
            cp.getUserData("UserMountain"):updatePhaseStatePairInfo(proto.player_list)
        else
            cp.getUserData("UserMountain"):updatePhaseState(proto.player_list)
            cp.getUserData("UserMountain"):setValue("CurrentState", proto.player_list.phase_state)
        end
        self:dispatchViewEvent(cp.getConst("EventConst").GetMountainPhaseStateRsp)
    end,
    [ProtoConst.UpdateMountainGuideRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserMountain"):updateGuideStep(proto.step)
        self:dispatchViewEvent("UpdateMountainGuideRsp")
    end,
}

return m