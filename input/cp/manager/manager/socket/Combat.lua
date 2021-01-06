local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.CombatFinishRsp] = function(self,key,proto,senddata)
        local manager = cp.getManager("ProtobufManager")
        local result = manager:decode2Table("protocal.CombatResult", gzip.decompress(proto.combat_result))

        local path = cc.FileUtils:getInstance():getWritablePath().."latest_combat"
        cc.FileUtils:getInstance():writeStringToFile(proto.combat_result, path)

        log("--------------COMBAT ID========="..result.combat_iD)
        cp.getUserData("UserCombat"):setCombatResult(result)
        cp.getUserData("UserCombat"):setCombatType(proto.combat_type)
        cp.getUserData("UserCombat"):setCombatScene(proto.scene_id)
        cp.getUserData("UserCombat"):setValue("Mode", 0)
        --cp.getUserData("UserCombat"):reverseCombatResult()
    end,
    [ProtoConst.EnterStoryLevelRsp] = function(self,key,proto,data)
        if proto.result == 0 then
            local DataUtils = cp.getUtils("DataUtils")
            local nextID = cp.getUserData("UserCombat"):getNextID(proto.difficulty, proto.id)
            cp.getUserData("UserCombat"):setValue("IsFirst", proto.is_first)
            if cp.getUserData("UserCombat"):isLeftWin() then
                if proto.is_first then
                    TDGAMission:onBegin(DataUtils.formatStoryInfo(nextID, proto.difficulty))
                    TDGAMission:onCompleted(DataUtils.formatStoryInfo(proto.id, proto.difficulty))
                end
            else
                --TDGAMission:onFailed(DataUtils.formatStoryInfo(proto.id, proto.difficulty), "角色死亡")
            end
            cp.getUserData("UserCombat"):setCombatReward(proto.combat_reward)
            cp.getUserData("UserCombat"):setID(proto.id)
            cp.getUserData("UserCombat"):setValue("Mode", 0)
            cp.getUserData("UserCombat"):setCombatDifficulty(proto.difficulty)
            self:dispatchViewEvent(cp.getConst("EventConst").EnterStoryLevelRsp , proto)
        end

        if proto.result == 5 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        elseif proto.result == 1 then
            cp.getManager("ViewManager").showBuyPhysicalUI()
        elseif proto.result == 2 then
            --挑戰次數不足，提示購買困難本挑戰次數

            --放到具體界面處理
            self:dispatchViewEvent(cp.getConst("EventConst").EnterStoryLevelRsp , proto)

        elseif proto.result == 3 then
            -- //1:體力不足,2:挑戰次數不足,3:前置關卡未通過,
            cp.getManager("ViewManager").gameTip("前置關卡未通過")
        elseif proto.result == 4 then
            local level = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", cp.getUserData("UserCombat"):getNextID(0)):getValue("Level")
            cp.getManager("ViewManager").gameTip(string.format("達到%d階才可挑戰，可通過“掃蕩關卡”提升閱歷", level))
        end
    end,
    [ProtoConst.GetStoryInfoRsp] = function(self,key,proto,senddata)
       
        local story_info = proto.story_info
       
        cp.getUserData("UserCombat"):setValue("normal_chapter_part_id",story_info.normal  or 1000)
        cp.getUserData("UserCombat"):setValue("hard_chapter_part_id",story_info.hard or 1000)
        cp.getUserData("UserCombat"):setValue("buy_count",story_info.buy_count or 0) --已購買的掃蕩次數
        cp.getUserData("UserCombat"):setValue("sweep_count",story_info.sweep_count or 0)

        -- 普通模式沒有挑戰次數限制，困難模式有挑戰次數限制
        local challengeCountList = {}
        if story_info.challenge_count ~= nil then
            for i=1,table.nums(story_info.challenge_count) do
                local sweep = story_info.challenge_count[i]
                challengeCountList[sweep.key] = {value = sweep.value,reset_count = sweep.reset_count}
            end
        end
        cp.getUserData("UserCombat"):setValue("challengeCountList", challengeCountList)

        self:dispatchViewEvent(cp.getConst("EventConst").GetStoryInfoRsp, proto) 
    end,
    
    --掃蕩返回
    --[[
        message CombatReward {
        optional uint32 money = 1;
        optional uint32 gold = 2;
        optional uint32 skill = 3;
        optional uint32 exp = 4;
        repeated ItemInfo item_list = 5;
        }

        message ItemInfo {
            required uint32 item_id = 1;
            optional string item_name = 2;
            optional uint32 item_num = 3 [default=1];
        }

        message SweepStoryRsp {
            //1:體力不足,2:次數不足,3:關卡未通過
            required int32 result = 1;
            repeated CombatReward reward_list = 2;
        }
    ]]
    [ProtoConst.SweepStoryRsp] = function(self,key,proto,senddata)
        local info = {result = proto.result}
        if proto.result == 5 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
            return
        end
        if proto.result == 0 then
            local current_id = cp.getGameData("GameChallenge"):getValue("current_id")
	        local hard_level = cp.getGameData("GameChallenge"):getValue("hard_level")
            local times = cp.getGameData("GameChallenge"):getValue("times")
            
            local currencyMap = {}
            local itemMap = {}
            for _, rewardInfo in ipairs(proto.reward_list) do
                for _, currencyInfo in ipairs(rewardInfo.currency_list) do
                    if not currencyMap[currencyInfo.type] then
                        currencyMap[currencyInfo.type] = {
                            type = currencyInfo.type,
                            num = currencyInfo.num
                        }
                    else
                        currencyMap[currencyInfo.type].num = currencyMap[currencyInfo.type].num + currencyInfo.num
                    end
                end
                for _, itemInfo in ipairs(rewardInfo.item_list) do
                    if not itemMap[itemInfo.item_id] then
                        itemMap[itemInfo.item_id] = {
                            item_id = itemInfo.item_id,
                            item_num = itemInfo.item_num
                        }
                    else
                        itemMap[itemInfo.item_id].item_num = itemMap[itemInfo.item_id].item_num + itemInfo.item_num
                    end
                end
            end

            local data_list = {
                currency_list = table.values(currencyMap),
                item_list = table.values(itemMap),
            }

            --修改關卡進度與掃蕩次數
            cp.getUserData("UserCombat"):updateChapterPartInfo("sweep", current_id, hard_level, times)
            info.data_list = data_list
        end
        
        self:dispatchViewEvent(cp.getConst("EventConst").SweepStoryRsp, info)
    end,

    --購買掃蕩次數及重置挑戰次數
    [ProtoConst.ResetStoryRsp] = function(self,key,proto,senddata)
        if proto.result == 0 then
            if proto.mode == 0 then  --購買掃蕩次數
                local BuySaodangTimes = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BuySaodangTimes")
                local buy_count = cp.getUserData("UserCombat"):getValue("buy_count")
                cp.getUserData("UserCombat"):setValue("buy_count", buy_count + BuySaodangTimes)
            elseif proto.mode == 1 then -- 重置挑戰次數
                local challengeCountList = cp.getUserData("UserCombat"):getValue("challengeCountList")
                challengeCountList = challengeCountList or {}
                local current_id = cp.getGameData("GameChallenge"):getValue("current_id")
                if challengeCountList[current_id] == nil then
                    challengeCountList[current_id] = {value = 0, reset_count = 0}
                end
                challengeCountList[current_id].value = 0
                challengeCountList[current_id].reset_count = challengeCountList[current_id].reset_count + 1
            end
            self:dispatchViewEvent(cp.getConst("EventConst").ResetStoryRsp,proto)
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("重置次數已達上限，提升VIP等級可獲得更多重置挑戰次數")
        end
    end,
    [ProtoConst.GetCombatDataRsp] = function(self,key,proto,senddata)
        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("戰鬥數據不存在")
            return
        end
        if proto.result == 0 then
            if proto.side ~= 0 then
                cp.getUserData("UserCombat"):reverseCombatResult()
            end
            cp.getUserData("UserCombat"):setValue("Mode", 1)
            self:dispatchViewEvent(cp.getConst("EventConst").GetCombatDataRsp,proto)
        end
    end,

    [ProtoConst.GetCombatListRsp] = function(self,key,proto,senddata)
        if proto.result == 0 then
            self:dispatchViewEvent(cp.getConst("EventConst").GetCombatListRsp, proto)
        end
    end,
    [ProtoConst.FirstEnterGameRsp] = function(self,key,proto,senddata)
        if proto.result == 0 then
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
            --self:dispatchViewEvent(cp.getConst("EventConst").FirstEnterGameRsp)
        end
    end,
}

return m