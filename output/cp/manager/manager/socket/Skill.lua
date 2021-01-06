local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetAllSkillRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):setSkillData(proto.skill_data)
            
            --技能數據下發後更新揹包物品可操作的狀態
            cp.getUserData("UserItem"):updatePackageItemOperateState()

            self:dispatchViewEvent(cp.getConst("EventConst").GetAllSkillRsp)
        end
    end,
    [ProtoConst.LearnSkillRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateSkillInfo(proto.skill_info)
            cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_1) --升級音效
            self:dispatchViewEvent(cp.getConst("EventConst").LearnSkillRsp)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("武學已經擁有了")
            --新手指引時，仍然轉發事件，以便繼續指引
            local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
            local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
            if cur_guide_module_name == "menpai_wuxue" then
                self:dispatchViewEvent(cp.getConst("EventConst").LearnSkillRsp)
            end
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("您的等階不足")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("不能學習其他門派武學")
        elseif proto.result == 4 then
            local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", proto.skill_info.skill_id)
            local notice = string.format("您的門派%s階武學未升至%d級", cp.getConst("CombatConst").SeriseColorZhCN[skillEntry:getValue("Colour")], skillEntry:getValue("Colour")*20)
            cp.getManager("ViewManager").gameTip(notice)
        end
    end,
    [ProtoConst.SkillBreakOutRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateSkillInfo(proto.skill_info)
            cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_2) --突破音效
            self:dispatchViewEvent(cp.getConst("EventConst").SkillBreakOutRsp)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("武學未學習")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("武學等級不夠")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("突破材料不足")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("武學等級不夠")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("武學已到最高等級")
        elseif proto.result == 6 then
            cp.getManager("ViewManager").gameTip("武學已經突破過了")
        end
    end,
    [ProtoConst.SkillLevelUpRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        elseif proto.result == 1 then
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateSkillInfo(proto.skill_info)
            cp.getUserData("UserSkill"):updateTrainPoint(proto.train_point)
            cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_1) --升級音效
            self:dispatchViewEvent(cp.getConst("EventConst").SkillLevelUpRsp)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("修為點不夠")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("武學不存在")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("武學未突破")
        end
    end,
    [ProtoConst.ResetSkillRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateSkillInfo(proto.skill_info)
            cp.getUserData("UserSkill"):updateTrainPoint(proto.train_point)
            cp.getUserData("UserSkill"):updateLearnPoint(proto.learn_point)
            self:dispatchViewEvent(cp.getConst("EventConst").ResetSkillRsp)
            cp.getManager("ViewManager").showGetRewardUI(proto.item_list,"恭喜獲得",true)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("武學未學習")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("重置需要的領悟點不夠")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("武學未突破")
        end
    end,
    [ProtoConst.DecomposeSkillPiecesRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):addLearnPoint(proto.learn_point)
            cp.getManager("ViewManager").gameTip("獲得領悟點x"..proto.learn_point)
            if proto.savvy_num > 0 then
                cp.getManager("ViewManager").gameTip("獲得天書殘頁x"..proto.savvy_num)
            end
            self:dispatchViewEvent(cp.getConst("EventConst").DecomposeSkillPiecesRsp)
        end
    end,
    [ProtoConst.ArtLevelUpRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("招式升級成功")
            cp.getUserData("UserSkill"):updateLearnPoint(proto.learn_point)
            cp.getUserData("UserSkill"):updateSkillInfo(proto.skill_info)
            self:dispatchViewEvent(cp.getConst("EventConst").ArtLevelUpRsp, proto)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("武學未學習")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("招式未解鎖")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("領悟點不足")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("升級所需的材料不足")
        elseif proto.result == 5 then
            cp.getManager("ViewManager").gameTip("已升級到最大等級")
        end
    end,
    [ProtoConst.UseSkillArtRsp] = function(self,key,proto,senddata)
        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateUseArt(proto.skill_id, proto.index)
            self:dispatchViewEvent(cp.getConst("EventConst").UseSkillArtRsp)
        end
    end,
    [ProtoConst.UpdateSkillCombineRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            if proto.type == 0 then
                cp.getUserData("UserSkill"):updateSkillCombine(proto.combine_id+1, proto.skill_list.skill_id_list)
            else
                cp.getUserData("UserSkill"):updateEquipCombine(proto.combine_id)
            end
            self:dispatchViewEvent(cp.getConst("EventConst").UpdateSkillCombineRsp,proto)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("不能裝備未學習的武學")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("內功最多隻能同時裝備一個")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("身法最多隻能同時裝備一個")
        elseif proto.result == 4 then
            cp.getManager("ViewManager").gameTip("雜學最多隻能同時裝備一個")
        end
    end,
    [ProtoConst.ImproveSkillBoundaryRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserSkill"):updateSkillBoundary(proto.skill_id, proto.boundary)
            cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_3) --武學境界提升
            self:dispatchViewEvent(cp.getConst("EventConst").ImproveSkillBoundaryRsp, proto.boundary)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("武學未學習")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("提升需要的材料不足")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("該武學已修煉至最高境界")
        end
    end,
    [ProtoConst.BuyTrainPointRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end
        
        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip(string.format("獲得%d修為點", proto.train_point))
            cp.getUserData("UserSkill"):addTrainPoint(proto.train_point)
            cp.getUserData("UserSkill"):updateBuyInfo(proto.buy_train_point)
            self:dispatchViewEvent(cp.getConst("EventConst").BuyTrainPointRsp)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("沒有足夠的元寶")
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("購買次數不足，提升VIP等級可獲得更多購買次數")
        end
    end,
    [ProtoConst.UseCombineRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end
        
        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("保存成功")
            cp.getUserData("UserSkill"):updateSkillUseList(proto.use_list)
            self:dispatchViewEvent("UseCombineRsp")
        end
    end,
    [ProtoConst.GetCareerSkillRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end
        
        if proto.result == 0 then
            self:dispatchViewEvent("GetCareerSkillRsp", proto)
        end
    end,
}

return m