local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    ["GetPlayerGuildDataRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):setValue("PlayerGuildData", proto.guild_data)
            cp.getUserData("UserGuild"):setValue("GuildDetailData", proto.guild_detail_data)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["CreateGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("幫派訊息不完整")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("元寶不夠")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("只可加入一個幫派")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("派名已被佔用")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派訊息中有敏感字符")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派宗旨字數上限")
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildDetailData(proto.guild_detail_data)
            self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
            self:dispatchViewEvent("GetPlayerGuildDataRsp", true)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GetJoinGuildListRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            self:dispatchViewEvent("GetJoinGuildListRsp", proto.guild_list)
        end
    end,
    ["JoinGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("只可加入一個幫派")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("該幫派成員已滿")
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("申請成功")
            self:dispatchViewEvent("JoinGuildRsp", proto.id)
        end
    end,
    ["JoinGuildNotifyRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):addRequest(proto.id)
        self:dispatchViewEvent("JoinGuildNotifyRsp", proto.id)
        self:dispatchViewEvent("checkNeedNoticeGuild")
    end,
    ["HandleJoinGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("沒有權限")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("不在申請列表")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("已經是幫派成員")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("該玩家已加入其它幫派")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("成員已達到上限，升級幫派可提高成員人數上限")
        end
        
        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuilRequestList(proto.id, proto.agree)
            self:dispatchViewEvent("HandleJoinGuildRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["HandleJoinGuildNotifyRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):updateGuildDetailData(proto.guild_detail_data)
        self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
        self:dispatchViewEvent("GetPlayerGuildDataRsp", true)
        self:dispatchViewEvent("checkNeedNoticeGuild")
    end,
    ["GetGuildSalaryRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("今日俸祿已領取")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("不在申請列表")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("已經是幫派成員")
        end
        
        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if roleAtt.id == proto.id then
                --cp.getUserData("UserGuild"):addPersonalMoney(proto.money)
                local today = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())
                cp.getUserData("UserGuild"):updateSalaryDay(today)
                local itemList = {
                    {
                        id = 1465,num = proto.contribute
                    },
                    {
                        id = 1464, num = proto.money
                    }
                }
                cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得獎勵", true)
            end
            cp.getUserData("UserGuild"):changeGuildCurrency(proto.id, proto.contribute, proto.money, 0)
            self:dispatchViewEvent("GetGuildSalaryRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["ContributeGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("銀幣不足")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("元寶不足")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("資金不足")
        end
        
        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if roleAtt.id == proto.id then
                if proto.guild_money > 0 then
                    cp.getManager("ViewManager").gameTip("幫派資金+"..proto.guild_money)
                end
                cp.getManager("ViewManager").gameTip("幫貢+"..proto.contribute)
            end
            --cp.getUserData("UserGuild"):addGuildMoney(proto.guild_money)
            cp.getUserData("UserGuild"):changeGuildCurrency(proto.id, proto.contribute, -proto.money, proto.guild_money)
            self:dispatchViewEvent("ContributeGuildRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GetGuildRankRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):setValue("GuildRankList", proto)
            cp.getUserData("UserGuild"):updateGuildFight(proto.fight)
            self:dispatchViewEvent("GetGuildRankRsp", proto)
        end
    end,
    ["AppointGuildManagerRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("對方不在幫派裡")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("沒有操作權限")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("職位人數達到上限")
        end
        
        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildDuty(proto.id, proto.duty)
            if proto.flag then
                cp.getManager("ViewManager").gameTip("操作成功")
            end
            self:dispatchViewEvent("AppointGuildManagerRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["UpgradeGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("沒有操作權限")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("幫派資金不夠")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派經驗不夠")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildLevel(proto.level, proto.money, proto.exp)
            self:dispatchViewEvent("UpgradeGuildRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["QuitGuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("幫主不能直接退出")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("幫派資金不夠")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派經驗不夠")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildDuty(proto.id, -1)
            self:dispatchViewEvent("QuitGuildRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["ModifyGuildNoticeRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("沒有權限")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("字數上限")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派經驗不夠")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildNotice(proto.notice)
            self:dispatchViewEvent("ModifyGuildNoticeRsp", proto)
        end
    end,
    ["GuildActivitySweepRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("已經到最大次數了")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("未到完成時間")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派經驗不夠")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        elseif proto.result == 10 then
            cp.getManager("ViewManager").gameTip("幫派等級不夠")
        end
        
        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if proto.id == roleAtt.id then
                cp.getUserData("UserGuild"):updateGuildSweepStatus(proto.start_time)
                if proto.start_time == 0 then
                    cp.getManager("ViewManager").gameTip("幫派經驗+"..proto.exp)
                    cp.getManager("ViewManager").gameTip("個人資金+"..proto.money)
                    cp.getUserData("UserGuild"):addPersonalMoney(proto.money)
                end
            end
            cp.getUserData("UserGuild"):updateGuildExp(proto.exp)
            self:dispatchViewEvent("GuildActivitySweepRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GuildActivityExpelRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("已經到最大次數了")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("在活動範圍內")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫派經驗不夠")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        elseif proto.result == 10 then
            cp.getManager("ViewManager").gameTip("幫派等級不夠")
        end
        
        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            cp.getUserData("UserGuild"):updateGuildExpelStatus(proto.exp)
            if proto.id == roleAtt.id then
                cp.getUserData("UserGuild"):addPersonalMoney(proto.money)
            end
            self:dispatchViewEvent("GuildActivityExpelRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GuildBuildRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("幫派等級不夠")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("金幣不夠")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("今日建造次數已滿")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派等級已達上限")
        elseif proto.result == 10 then
            cp.getManager("ViewManager").gameTip("幫派等級不夠")
        end
        
        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if roleAtt.id == proto.id then
                cp.getManager("ViewManager").gameTip("幫貢+"..proto.contribute.."、建設度+10")
            end
            cp.getUserData("UserGuild"):updateGuildBuildStatus(proto.id, proto.contribute, proto.building)
            self:dispatchViewEvent("GuildBuildRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GetGuildWantedListRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        elseif proto.result == 10 then
            --cp.getManager("ViewManager").gameTip("幫派等級不夠")
        end

        if proto.result == 0 then
            cp.getUserData("UserGuild"):updateGuildWantedList(proto.npc_list, proto.count, proto.success)
            self:dispatchViewEvent("GetGuildWantedListRsp", proto.npc_list)
        end
    end,
    ["FightGuildWantedRsp"] = function(self,key,proto,senddata)
        if proto.result ~= 0 then
            if proto.result == -1 then
                cp.getManager("ViewManager").gameTip("伺服器請求超時")
                return
            end
            local txt = {"沒有加入幫派","幫派不存在","npc已被擊殺"}
            cp.getManager("ViewManager").gameTip(txt[proto.result])
        else
            local reward = {
                currency_list = {
                    {
                        type = 100, num = proto.exp,
                    },
                    {
                        type = 11, num = proto.money,
                    },
                }
            }
            cp.getUserData("UserCombat"):setCombatReward(reward)
            cp.getUserData("UserGuild"):updateGuildWantedStatus(proto.npc, proto.count, proto.success, proto.exp)
            cp.getUserData("UserGuild"):addPersonalMoney(proto.money)
            self:dispatchViewEvent("FightGuildWantedRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GuildPrepareFightRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("幫派等級不夠")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("幫戰已經開啟")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("幫戰報名時間已截止")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("幫派資金不足")
        elseif proto.result == 7 then
            cp.getManager("ViewManager").gameTip("沒有開啟權限")
        end

        if proto.result == 0 then
            local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if roleAtt.id == proto.id then
                cp.getManager("ViewManager").gameTip("報名成功")
            end
            cp.getUserData("UserGuild"):updateGuildFightStatus(proto.city)
            self:dispatchViewEvent("GuildPrepareFightRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GuildSignFightRsp"] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不在一個幫派裡")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("幫派不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("幫戰報名時間已截止")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("管理員未開啟幫戰")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("已經報名了")
        end

        if proto.result == 0 then
            --local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            --if roleAtt.id == proto.id then
            --    cp.getManager("ViewManager").gameTip("報名成功")
            --end
            cp.getUserData("UserGuild"):changeGuildCurrency(proto.id, proto.contribute, 0, 0)
            cp.getUserData("UserGuild"):updateGuildMemberSign(proto.id)
            self:dispatchViewEvent("GuildSignFightRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GuildFightOverRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):updateGuildFightOver(proto.city, proto.money, proto.exp)
        self:dispatchViewEvent("GuildFightOverRsp", proto)
        self:dispatchViewEvent("checkNeedNoticeGuild", proto)
        self:dispatchViewEvent("checkNeedNoticeGuild")
    end,
    ["GetGuildFightCityRsp"] = function(self,key,proto,senddata)
        if proto.result ~= -1 then
            cp.getUserData("UserGuild"):updateGuildFightCity(proto.city, proto.guild_list, proto.name)
            self:dispatchViewEvent("GetGuildFightCityRsp", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild", proto)
            self:dispatchViewEvent("checkNeedNoticeGuild")
        end
    end,
    ["GetGuildFightCombatListRsp"] = function(self,key,proto,senddata)
        if proto.result ~= -1 then
            cp.getUserData("UserGuild"):updateGuildFightCombat(proto.left, proto.right, proto.combat_list)
            self:dispatchViewEvent("GetGuildFightCombatListRsp", proto)
        end
    end,
    ["ShowCityOwnerRsp"] = function(self,key,proto,senddata)
        self:dispatchViewEvent("ShowCityOwnerRsp", proto)
    end,
    ["GetGuildByNameRsp"] = function(self,key,proto,senddata)
        self:dispatchViewEvent("GetGuildByNameRsp", proto)
    end,
    ["GuildEventNotifyRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):addNewGuildEvent(proto.event)
        self:dispatchViewEvent("GuildEventNotifyRsp", proto)
    end,
    ["GetFightCityCountRsp"] = function(self,key,proto,senddata)
        self:dispatchViewEvent("GetFightCityCountRsp", proto)
    end,
    ["NotifyMemberContributeRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):changeGuildCurrency(proto.id, proto.contribute, proto.money, 0)
        self:dispatchViewEvent("NotifyMemberContributeRsp", proto)
    end,
    ["UpdateMemberDailyRewardRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):addMemberDailyReward(proto.contribute, proto.money)
        self:dispatchViewEvent("UpdateMemberDailyRewardRsp", proto)
    end,
    ["GetFightCityStateRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):setValue("FightCityState", proto)
        self:dispatchViewEvent("GetFightCityStateRsp", proto.state_list)
    end,
    ["AddGuildCurrencyRsp"] = function(self,key,proto,senddata)
        cp.getUserData("UserGuild"):changeGuildCurrency(0, 0, proto.money, proto.exp)
    end,
}

return m