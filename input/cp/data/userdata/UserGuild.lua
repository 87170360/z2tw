local BaseData = require("cp.data.BaseData")
local UserGuild = class("UserGuild",BaseData)

function UserGuild:create()
    local ret =  UserGuild.new() 
    ret:init()
    return ret
end

function UserGuild:init()
end

function UserGuild:getGuildDetailData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local guildDetailData = self:getValue("GuildDetailData")
    if not guildDetailData then return nil end
    if guildDetailData.expel_info.day ~= today then
        guildDetailData.expel_info.day = today
        guildDetailData.expel_info.count = 0
    end
    return guildDetailData
end

function UserGuild:getPlayerGuildData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local playerGuildData = self:getValue("PlayerGuildData")
    if not playerGuildData then return nil end
    if playerGuildData.sweep_info.day ~= today then
        playerGuildData.sweep_info.day = today
        playerGuildData.sweep_info.start_time = 0
        playerGuildData.sweep_info.count = 0
    end

    if playerGuildData.build_info.day ~= today then
        playerGuildData.build_info.day = today
        playerGuildData.build_info.count = 0
    end

    if playerGuildData.wanted_info.day ~= today then
        playerGuildData.wanted_info.day = today
        playerGuildData.wanted_info.success = 0
        playerGuildData.wanted_info.count = 0
        playerGuildData.wanted_info.npc_list = {}
    end

    return playerGuildData
end

function UserGuild:updateGuildDetailData(guildDetailData)
    self:setValue("GuildDetailData", guildDetailData)
    self:getPlayerGuildData().id = guildDetailData.id
end

function UserGuild:updateGuildFight(fight)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.fight = fight
end

function UserGuild:getDutyList(duty)
    local memberList = {}
    local guildDetailData = self:getGuildDetailData()
    for _, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        if memberInfo.duty == duty then
            table.insert(memberList, memberInfo)
        end
    end

    return memberList
end

function UserGuild:updateGuildExp(exp)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.exp = guildDetailData.exp + exp
end

function UserGuild:getMemberInfo(id)
    local guildDetailData = self:getGuildDetailData()
    for _, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        if memberInfo.id == id then
            return memberInfo
        end
    end

    return nil
end

function UserGuild:getOnlineMember()
    local memberList = {}
    local guildDetailData = self:getGuildDetailData()
    for _, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(memberInfo.id)
        if playerSimpleInfo and playerSimpleInfo.status then
            table.insert(memberList, memberInfo)
        end
    end

    return memberList
end

function UserGuild:addPersonalMoney(money)
    local playerGuildData = self:getPlayerGuildData()
    playerGuildData.money = playerGuildData.money + money
end

--分別增加幫貢，幫派個人資金，幫派資金
function UserGuild:changeGuildCurrency(id, contribute, money, guildMoney)
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.money = guildDetailData.money + guildMoney or 0
    if roleAtt.id == id then
        local playerGuilDData = self:getPlayerGuildData()
        playerGuilDData.money = playerGuilDData.money + money
    end
    
    if id > 0 and contribute > 0 then
        local memberInfo = self:getMemberInfo(id)
        memberInfo.contribute =  memberInfo.contribute + contribute
    end
end

function UserGuild:addRequest(id)
    local guildDetailData = self:getGuildDetailData()
    for _, id1 in ipairs(guildDetailData.request_list.request_list) do
        if id1 == id then
            return
        end
    end

    table.insert(guildDetailData.request_list.request_list, id)
end

function UserGuild:updateGuilRequestList(id, agree)
    local guildDetailData = self:getGuildDetailData()
    table.removebyvalue(guildDetailData.request_list.request_list, id)
    
    if not agree then return end
    
    for _, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        if memberInfo.id == id then
            memberInfo.contribute = 0
            memberInfo.duty = 0
            return
        end
    end
    
    table.insert(guildDetailData.member_list.member_list, {
        id = id,
        contribute = 0,
        duty = 0,
    })
end

function UserGuild:updateGuildDuty(id, duty)
    local guildDetailData = self:getGuildDetailData()
    local playerGuildData = self:getPlayerGuildData()
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if roleAtt.id == id and duty == -1 then
        playerGuildData.id = 0
        self:setValue("GuildDetailData", {})
        return 
    end

    for i, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        if duty == -1 and memberInfo.id == id then
            table.remove(guildDetailData.member_list.member_list, i)
            return
        end

        if duty ~= -1 then
            if memberInfo.id == id then
                memberInfo.duty = duty
                if duty ~= 3 then
                    return
                end
            end

            if duty == 3 and memberInfo.duty == duty and memberInfo.id ~= id then
                memberInfo.duty = 0
            end
        end
    end
end

function UserGuild:updateGuildLevel(level, money, exp)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.money = money
    guildDetailData.exp = exp
    guildDetailData.level = level
end

function UserGuild:addGuildMoney(money)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.money = guildDetailData.money + money
end

function UserGuild:updateGuildNotice(notice)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.notice = notice
end

function UserGuild:updateGuildSweepStatus(start)
    local playerGuildData = self:getPlayerGuildData()
    playerGuildData.sweep_info.start_time = start
    if start == 0 then
        playerGuildData.sweep_info.count = playerGuildData.sweep_info.count + 1
    end
end

function UserGuild:updateGuildExpelStatus(exp)
    local guildDetailData = self:getGuildDetailData()
    local playerGuildData = self:getPlayerGuildData()
    guildDetailData.exp = guildDetailData.exp + exp
    if exp > 0 then
        guildDetailData.expel_info.count = guildDetailData.expel_info.count + 1
    end
end

function UserGuild:updateGuildBuildStatus(id, contribute, buildingInfo)
    local guildDetailData = self:getGuildDetailData()
    local playerGuildData = self:getPlayerGuildData()
    for i, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        if memberInfo.id == id then
            memberInfo.contribute = memberInfo.contribute + contribute
            break
        end
    end

    local flag = true
    for i, buildingInfo1 in ipairs(guildDetailData.building_info.building_list) do
        if buildingInfo1.building == buildingInfo.building then
            guildDetailData.building_info.building_list[i] = buildingInfo
            flag = false
            break
        end
    end

    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if roleAtt.id == id then
        playerGuildData.build_info.count = playerGuildData.build_info.count + 1
    end

    if flag then
        table.insert(guildDetailData.building_info.building_list, buildingInfo)
    end
end

function UserGuild:updateGuildWantedList(npc_list, count, success)
    local playerGuildData = self:getPlayerGuildData()
    playerGuildData.wanted_info.npc_list = npc_list
    playerGuildData.wanted_info.count = count
    playerGuildData.wanted_info.success = success
end

function UserGuild:updateGuildWantedStatus(id, count, success, exp)
    local guildDetailData = self:getGuildDetailData()
    local playerGuildData = self:getPlayerGuildData()
    guildDetailData.exp = guildDetailData.exp + exp

    playerGuildData.wanted_info.count = count
    playerGuildData.wanted_info.success = success

    for i, npcInfo in ipairs(playerGuildData.wanted_info.npc_list)do
        if npcInfo.id == id then
            table.remove(playerGuildData.wanted_info.npc_list, i)
            break
        end
    end
end

function UserGuild:getBuildInfo(building)
    local guildDetailData = self:getGuildDetailData()
    for i, buildingInfo in ipairs(guildDetailData.building_info.building_list) do
        if buildingInfo.building == building then
            return buildingInfo
        end
    end

    local buildInfo = {
        building = building,
        level = 1,
        exp = 0,
    }
    table.insert(guildDetailData.building_info.building_list, buildInfo)
    return buildInfo
end

function UserGuild:getPrepareFightNum()
    local guildDetailData = self:getGuildDetailData()
    return #guildDetailData.fight_info.sign_list
end


function UserGuild:getGuildWantedInfo()
    local playerGuildData = self:getPlayerGuildData()
    return playerGuildData.wanted_info
end

function UserGuild:updateGuildFightStatus(city)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.fight_info.city = city
end

function UserGuild:updateGuildMemberSign(id)
    local guildDetailData = self:getGuildDetailData()
    table.insert(guildDetailData.fight_info.sign_list, id)
end

function UserGuild:updateGuildFightOver(city, money, exp)
    local guildDetailData = self:getGuildDetailData()
    guildDetailData.money = money
    guildDetailData.exp = exp
    guildDetailData.city = city
end

function UserGuild:isMemberSigned(id)
    local guildDetailData = self:getGuildDetailData()
    return table.indexof(guildDetailData.fight_info.sign_list, id)

end

function UserGuild:updateGuildFightCity(city, guildList)
    local guildFightCity = self:getValue("GuildFightCity")
    if guilldFightCity == nil then
        self:setValue("GuildFightCity", {})
        guildFightCity = self:getValue("GuildFightCity")
    end
    guildFightCity[city] = guildList
end

function UserGuild:updateGuildFightCombat(left, right, cobmatList)
    local guildFightCombat = self:getValue("GuildFightCombat")
    if guildFightCombat == nil then
        self:setValue("GuildFightCombat", {})
        guildFightCombat = self:getValue("GuildFightCombat")
    end
    local key = ""
    if left < right then
        key = string.format("%d_%d", left, right)
    else
        key = string.format("%d_%d", right, left)
    end

    guildFightCombat[key] = cobmatList
end

function UserGuild:getFightGuildList( city )
    local guildFightCity = self:getValue("GuildFightCity")
    if not guildFightCity then
        return nil
     end
    return guildFightCity[city] 
end

function UserGuild:getFightCombatList( key )
    local guildFightCombat = self:getValue("GuildFightCombat")
    if not guildFightCombat then
        return nil
    end

    return guildFightCombat[key]
end

function UserGuild:addNewGuildEvent(event)
    local guildDetailData = self:getGuildDetailData()
    table.insert(guildDetailData.event_list.event_list, event)
end

function UserGuild:updateSalaryDay(day)
    local playerGuildData = self:getPlayerGuildData()
    playerGuildData.last_salary_day = day
end

function UserGuild:addMemberDailyReward(contribute, money)
    local guildDetailData = self:getGuildDetailData()
    local playerGuildData = self:getPlayerGuildData()
    for i, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        memberInfo.contribute = memberInfo.contribute + contribute
    end
    
    playerGuildData.money = playerGuildData.money + money
end

function UserGuild:updateFightCityState()
    local fightCityState = self:getValue("FightCityState")
    if fightCityState == nil then
        fightCityState = {
            fight_state = -1,
            state_list = {

            }
        }
    end

    local fightConfig = cp.DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local now = cp.getManager("TimerManager"):getTime()
    local weekDay = tonumber(os.date("%w", now))
    local nowTab = os.date("*t", now)
    local phase, _ = cp.DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)

    if phase ~= fightCityState.fight_state then
	    cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").GetFightCityStateReq, {})
    else
        cp.getManager("EventManager"):dispatchEvent("VIEW", "GetFightCityStateRsp", fightCityState.state_list)
    end
end

return UserGuild