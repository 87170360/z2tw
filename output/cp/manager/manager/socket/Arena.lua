local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetArenaDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserArena"):setValue("ArenaData", proto.arena_data)
            self:dispatchViewEvent(cp.getConst("EventConst").GetArenaDataRsp, true)
        end
    end,
    [ProtoConst.RefreshOpponentRankRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserArena"):updateOpponentList(proto.opponent_list)
            self:dispatchViewEvent(cp.getConst("EventConst").RefreshOpponentRankRsp)
        end
    end,
    [ProtoConst.GetArenaRankListRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            self:dispatchViewEvent(cp.getConst("EventConst").GetArenaRankListRsp, proto.opponent_rank)
        end
    end,
    [ProtoConst.ArenaFightRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("今日挑戰次數已用完")
        end

        if proto.result == 3 then
            cp.getManager("ViewManager").gameTip("排名已發生變更")
        end

        if proto.result == 0 then
            cp.getUserData("UserCombat"):setCombatReward({
                item_list = {},
                currency_list={{type=cp.getConst("GameConst").VirtualItemType.prestige, num=20}}
            })
            cp.getUserData("UserArena"):setValue("ArenaData", proto.arena_data)
            self:dispatchViewEvent(cp.getConst("EventConst").ArenaFightRsp)
        end
    end,
    [ProtoConst.BuyBufferRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("購買次數已達上限")
        end

        if proto.result == 2 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("購買成功")
            cp.getUserData("UserArena"):updateBuffer(proto.buffer)
            self:dispatchViewEvent(cp.getConst("EventConst").BuyBufferRsp)
        end
    end,
    [ProtoConst.BuyChallengeRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        end

        if proto.result == 0 then
            cp.getUserData("UserArena"):updateBuyCount()
            self:dispatchViewEvent(cp.getConst("EventConst").BuyChallengeRsp)
        end
    end,
    [ProtoConst.GetLastRankAwardRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("沒有未領取獎勵")
        end

        if proto.result == 2 then
            cp.getManager("ViewManager").gameTip("昨日未上榜")
        end

        if proto.result == 0 then
            cp.getUserData("UserArena"):updateLastRankReward()
            self:dispatchViewEvent(cp.getConst("EventConst").GetLastRankAwardRsp, proto)
        end
    end,
    [ProtoConst.ArenaRankChangeRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserArena"):updatePlayerRank(proto.rank)
        cp.getUserData("UserArena"):updateOpponentList(proto.opponent_list)
        self:dispatchViewEvent("ArenaRankChangeRsp", proto)
    end,
    [ProtoConst.UpdateArenaGuideRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserArena"):updateGuideStep(proto.step)
        self:dispatchViewEvent("UpdateArenaGuideRsp")
    end,
}

return m