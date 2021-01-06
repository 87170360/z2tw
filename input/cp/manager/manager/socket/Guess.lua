local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetGuessFingerDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):setValue("GuessFingerData", proto.guess_finger_data)
        end
    end,
    [ProtoConst.GetGuessOpponentRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
            guessFingerData.opponent_info = proto.opponent_info
            self:dispatchViewEvent(cp.getConst("EventConst").GetGuessOpponentRsp, proto.opponent_info)
        end
    end,
    [ProtoConst.GuessFingerRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            local guessFingerData = cp.getUserData("UserGuess"):updateGuessFinger(proto.self_finger, proto.opponent_finger)
            self:dispatchViewEvent(cp.getConst("EventConst").GuessFingerRsp, proto)
        end
    end,
    [ProtoConst.PickWineRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):updateDrinkPoint(proto.wine_point, proto.total_point, proto.wine_index)
            self:dispatchViewEvent(cp.getConst("EventConst").PickWineRsp, proto.wine_point)
        end
    end,
    [ProtoConst.WantFightRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
            local guessConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuessFinger"), ":;=")
            guessFingerData.is_over = true
            guessFingerData.day = cp.getManager("TimerManager"):getTime() + guessConfig[5][1][1]*60
            local combatReward = {
                gold = 0,
                item_list = {}
            }
            cp.getUserData("UserCombat"):setCombatReward(combatReward)
            self:dispatchViewEvent(cp.getConst("EventConst").WantFightRsp, proto)
        end
    end,
    --鬥老千
    [ProtoConst.GetRollDiceDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):setValue("RollDiceData", proto.roll_dice_data)
        end
    end,
    [ProtoConst.RollDiceRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):updateDiceList(proto.dice_list)
            self:dispatchViewEvent(cp.getConst("EventConst").RollDiceRsp, proto)
        end
    end,
    [ProtoConst.ChangeDiceRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):changeDice(proto.dice_index+1, proto.dice_point)
            self:dispatchViewEvent(cp.getConst("EventConst").ChangeDiceRsp, proto)
        end
    end,
    [ProtoConst.ResetDiceStateRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):resetDiceState(proto.roll_point)
            cp.getManager("ViewManager").gameTip("獲得積分*"..proto.roll_point)
            cp.getManager("ViewManager").gameTip("獲得銀幣*"..proto.silver)
            self:dispatchViewEvent(cp.getConst("EventConst").ResetDiceStateRsp, proto)
        end
    end,
    [ProtoConst.GetMonthRewardRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuess"):updateMonthReward(proto.roll_point)
            self:dispatchViewEvent(cp.getConst("EventConst").GetMonthRewardRsp, proto)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("添加物品失敗")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("獎勵已領取")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("月積分不夠")
        end
    end,
    [ProtoConst.UpdateGuessGuideStepRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserGuess"):updateGuessStep(proto.module, proto.step)
        self:dispatchViewEvent("UpdateGuessGuideStepRsp", proto)
    end,
}

return m