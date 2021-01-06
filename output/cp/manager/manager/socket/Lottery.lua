local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetLotteryDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):setValue("LotteryData", proto.lottery)
            self:dispatchViewEvent(cp.getConst("EventConst").GetLotteryDataRsp)
        end
    end,
    [ProtoConst.BuySkillLotteryRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):setSkillLottery(proto.skill_lottery)
            cp.getUserData("UserLottery"):addPoint(proto.gain_point)
            self:dispatchViewEvent(cp.getConst("EventConst").BuySkillLotteryRsp, proto.item_list)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("未到免費時間")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("今日購買次數已達上限")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        end
    end,
    [ProtoConst.BuyTreasureLotteryRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):setTreasureLottery(proto.treasure_lottery)
            cp.getUserData("UserLottery"):addPoint(proto.gain_point)
            self:dispatchViewEvent(cp.getConst("EventConst").BuyTreasureLotteryRsp, proto.item_list)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("未到免費時間")
        elseif proto.result == 2 then
            local GameConst = cp.getConst("GameConst")
            local contentTable = {
                {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="您的銀兩不足，是否前往招財界面兌換銀兩？", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"}
            }
            cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
                cp.getManager("ViewManager").showSilverConvertUI()
            end,nil)
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("今日免費次數已用完")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        end
    end,
    [ProtoConst.BuyLotteryPointShopRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):updateShopItem(proto.item_id, proto.num)
            cp.getUserData("UserLottery"):setPoint(proto.point)
            self:dispatchViewEvent(cp.getConst("EventConst").BuyLotteryPointShopRsp, proto)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("物品不存在")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("物品已被購買")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("藏寶積分不夠")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        end
    end,
    [ProtoConst.RefreshLotteryPointShopRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):setPointShop(proto.point_shop)
            self:dispatchViewEvent(cp.getConst("EventConst").RefreshLotteryPointShopRsp)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
        end
    end,
    [ProtoConst.GetLotteryRankRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserLottery"):setValue("LotteryRank", proto.rank_list)
            self:dispatchViewEvent(cp.getConst("EventConst").GetLotteryRankRsp)
        end
    end,
}

return m