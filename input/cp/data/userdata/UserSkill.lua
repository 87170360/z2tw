local BaseData = require("cp.data.BaseData")
local UserSkill = class("UserSkill", BaseData)

function UserSkill:create()
    local ret = UserSkill.new() 
    ret:init()
    return ret
end

function UserSkill:init()
end

function UserSkill:setSkillData(skillData)
    local skillSortLevel = {}
    local skillSortPower = {}
    for _, skillInfo in ipairs(skillData.skill_list.skill_list) do
        table.insert(skillSortLevel, skillInfo)
        table.insert(skillSortPower, skillInfo)
    end

    self:setValue("SkillData", skillData)
    self:setValue("SkillSortLevel", skillSortLevel)
    self:setValue("SkillSortPower", skillSortPower)
end

--獲取修為點
function UserSkill:getTrainPoint()
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.train_point then
        return 0
    end

    return skillData.train_point
end

function UserSkill:updateTrainPoint(trainPoint)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.train_point = trainPoint
end

function UserSkill:addTrainPoint(trainPoint)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.train_point = skillData.train_point + trainPoint
end

--獲取參悟訊息
function UserSkill:getBuyInfo()
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    if skillData.buy_train_point.day ~= today then
        skillData.buy_train_point.day = today
        skillData.buy_train_point.buy_count = 0
    end
    return skillData.buy_train_point
end

--更新參悟訊息
function UserSkill:updateBuyInfo(buyInfo)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.buy_train_point = buyInfo
end

--獲取領悟點
function UserSkill:getLearnPoint()
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.learn_point then
        return 0
    end

    return skillData.learn_point
end

function UserSkill:updateLearnPoint(learnPoint)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.learn_point = learnPoint
end

function UserSkill:addLearnPoint(learnPoint)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.learn_point = skillData.learn_point + learnPoint
end

function UserSkill:getSkill(skillID)
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.skill_list or not skillData.skill_list.skill_list then
        return nil
    end

    for i, skillInfo in ipairs(skillData.skill_list.skill_list) do
        if skillInfo.skill_id == skillID then
            return skillInfo
        end
    end

    return nil
end

function UserSkill:updateSkillInfo(skillInfo)
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.skill_list then
        return
    end

    local flag = true
    for i, v in ipairs(skillData.skill_list.skill_list) do
        if v.skill_id == skillInfo.skill_id then
            skillData.skill_list.skill_list[i] = skillInfo
            flag = false
            break
        end
    end

    if flag then
        table.insert(skillData.skill_list.skill_list, skillInfo)
    end
end

function UserSkill:updateSkillCombine(combine_id, skill_list)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    if not skillData.skill_combine_list[combine_id] then
        skillData.skill_combine_list[combine_id] = {}
    end

    skillData.skill_combine_list[combine_id].skill_id_list = skill_list
end

function UserSkill:updateEquipCombine(combine_id)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    skillData.equip_combine = combine_id
end

function UserSkill:getSkillCombine(combindID, index)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    if not skillData.skill_combine_list[combindID] then
        return {}
    end

    if index then
        local skillID = skillData.skill_combine_list[combindID].skill_id_list[index]
        if skillID == 0 then
            return nil
        else
            return skillID
        end
    else
        return skillData.skill_combine_list[combindID].skill_id_list
    end
end

function UserSkill:updateCombineSkill(combineID, index, skillID)
    local skillData = self:getValue("SkillData")
    if not skillData then
        return
    end

    if not skillData.skill_combine_list[combindID] then
        skillData.skill_combine_list[combindID] = {}
    end

    skillData.skill_combine_list[combindID].skill_id_list[index] = skillID
end

function UserSkill:sortOneSkill(skillInfo)
    local skillData = self:getValue("SkillData")
    local skillSortLevel = self:getValue("SkillSortLevel")
    local skillSortPower = self:getValue("SkillDataPower")
end

function UserSkill:updateSkillBoundary(skillID, boundary)
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.skill_list or not skillData.skill_list.skill_list then
        return nil
    end

    local skillInfo = self:getSkill(skillID)
    skillInfo.boundary = boundary
end

function UserSkill:showSkillRedPoint()
    local skillData = self:getValue("SkillData")
    if not skillData or not skillData.skill_list or not skillData.skill_list.skill_list then
        return false
    end

    for i, skillInfo in ipairs(skillData.skill_list.skill_list) do
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillInfo.skill_id)
        if cp.getUtils("NotifyUtils").needNotifySkill(skillInfo, skillEntry) then
            return true
        end
    end
    return false
end

function UserSkill:updateUseArt(skillID, index)
    local skillInfo = cp.getUserData("UserSkill"):getSkill(skillID)
    skillInfo.art_index = index
end

function UserSkill:updateSkillUseList(useList)
    local skillData = self:getValue("SkillData")
    skillData.use_list = useList
end

function UserSkill:getCombatTypeList(combineID)
    local skillData = self:getValue("SkillData")
    for _, combineInfo in ipairs(skillData.use_list) do
        if combineInfo.combine_id == combineID then
            return combineInfo.combat_type_list
        end
    end

    return {}
end

function UserSkill:isCombineActive(skillID, equipList)
    if not equipList or #equipList == 0 then
        return false
    end

    local combineList = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("SkillUnits", skillID):getValue("NeedSkills"), ";")
    table.insert(combineList, skillID)

    for _, id in ipairs(combineList) do
        if id > 0 and not table.indexof(equipList, id) then
            return false
        end
    end

    return true
end

function UserSkill:getEquipSkillList()
    local skillData = self:getValue("SkillData")
    local combineID = skillData.equip_combine + 1

    if not skillData.skill_combine_list[combineID] then
        return {0,0,0,0,0,0}
    end

    local equipList = skillData.skill_combine_list[combineID].skill_id_list
    return equipList
end

return UserSkill