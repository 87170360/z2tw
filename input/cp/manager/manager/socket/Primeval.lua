local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetPrimevalDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):setPrimevalData(proto.primeval_data)
            self:dispatchViewEvent("PrimevalData")
        end
    end,
    [ProtoConst.UsePrimevalChestRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):addMetaList(proto.meta_list)
            self:dispatchViewEvent("UsePrimevalChestRsp", proto)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("混元寶卷容量已滿")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("寶箱數量不足")
        end
    end,
    [ProtoConst.EquipMetaRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):equipMeta(proto.equip_list)
            cp.getManager("ViewManager").gameTip("操作成功")
            self:dispatchViewEvent("EquipMetaRsp")
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("將要裝備的混元不存在")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("將要裝備的混元已被裝備")
        end
    end,
    [ProtoConst.StrengthMetaRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):removeMetaPos(proto.pos_list)
            cp.getUserData("UserPrimeval"):updateMetaInfo(proto.meta_info)
            self:dispatchViewEvent("StrengthMetaRsp")
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("要強化的混元不存在")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("強化所需要的銀幣不足")
        end
    end,
    [ProtoConst.SellMetaRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):removeMetaPos(proto.pos_list)
            cp.getManager("ViewManager").gameTip(string.format("獲得%d銀幣", proto.silver))
            self:dispatchViewEvent("SellMetaRsp")
        end
    end,
    [ProtoConst.LearnMetalRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):addMetaList(proto.meta_list)
            cp.getUserData("UserPrimeval"):updateMasterLevel(proto.count, proto.master)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("免費次數不足")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("混元寶卷空間不足")
        end
        self:dispatchViewEvent("LearnMetalRsp", proto)
    end,
    [ProtoConst.UpdateMetaLockRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):updateMetaLock(proto.pos, proto.lock)
            self:dispatchViewEvent("UpdateMetaLockRsp")
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("混元不存在")
        end
    end,
    [ProtoConst.ExpandSpaceRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserPrimeval"):updatePrimevalSpace(proto.space)
            self:dispatchViewEvent("ExpandSpaceRsp")
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("混元寶卷空間已擴展至最大容量")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        end
    end,
}

return m