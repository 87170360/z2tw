local CombatConst = cp.getConst("CombatConst")
local M = {}

function M.needNotifySkillArt(skillInfo, skillEntry)
    local list = {}
    if skillEntry:getValue("SkillType") == 3 then return list end
    local packageItemList = cp.getUserData("UserItem"):getItemList()
    local arts = cp.getUtils("DataUtils").splitBufferList(skillEntry:getValue("Arts"))
    for artIndex, artInfo in ipairs(skillInfo.art_list) do
        local upgradeEntry = cp.getManager("ConfigManager").getItemByKey("SkillArtLevelUp", artInfo.art_level+1)
        if upgradeEntry then
            local enough = true
            local itemList = cp.getUtils("DataUtils").splitAttr(upgradeEntry:getValue(CombatConst.SeriseColor[skillEntry:getValue("Colour")]))
            for _, itemInfo in ipairs(itemList) do
                local ownNum = cp.getUserData("UserItem"):getItemNum(itemInfo[1])
                if itemInfo[2] > ownNum then
                    enough = false
                    break
                end
            end

            local needPoint = cp.getUtils("DataUtils").GetArtLevelUpCost(skillEntry:getValue("Colour"), artInfo.art_level)
            if needPoint > cp.getUserData("UserSkill"):getLearnPoint() then
                enough = false
            end

            if enough then
                table.insert(list, artIndex)
            end
        end
    end
    return list
end

function M.needNotifySkillBoundary(skillInfo, skillEntry)
    if skillEntry:getValue("SkillType") == 3 then return false end
    local packageItemList = cp.getUserData("UserItem"):getItemList()
    local totalSilver = cp.getUserData("UserRole").major_roleAtt.silver
    local upgradeEntry = cp.getManager("ConfigManager").getItemByKey("SkillBoundaryUpgrade", skillInfo.boundary+1)
    if upgradeEntry then
        local silverCost = upgradeEntry:getValue(CombatConst.SeriseColor[skillEntry:getValue("Colour")])
        if totalSilver < silverCost then
            return false
        end

        local needBook = 0
        if skillInfo.boundary+1 >= 1 and skillInfo.boundary+1 < 5 then
            needBook = 1
        elseif skillInfo.boundary+1 >= 5 and skillInfo.boundary+1 < 9 then
            needBook = 2
        elseif skillInfo.boundary+1 >= 9 and skillInfo.boundary+1 <= 10 then
            needBook = 3
        end

        local itemID = cp.getUtils("DataUtils").splitBufferList(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BoundaryMatiral"))[skillEntry:getValue("Colour")]
        local itemNum = cp.getUserData("UserItem"):getItemNum(skillEntry:getValue("ItemID"))
        itemNum = itemNum + cp.getUserData("UserItem"):getItemNum(itemID)
        if itemNum < needBook then
            return false
        else
            return true
        end
    end

    return false
end

function M.needNotifySkillUpgrade(skillInfo, skillEntry)
    if skillEntry:getValue("SkillType") == 3 then return false end

    if skillInfo.skill_level == 140 then
        return false
    end

    if skillInfo.skill_level > 0 and not skillInfo.is_break and skillInfo.skill_level%20==0 then
        return false
    end

    local totalTrainPoint = cp.getUserData("UserSkill"):getTrainPoint()
    local needTrainPoint = cp.getUtils("DataUtils").GetSkillLevelUpCost(skillEntry:getValue("Colour"), skillInfo.skill_level, skillInfo.skill_level+1)
    if totalTrainPoint < needTrainPoint then
        return false
    end

    return true
end

function M.needNotifySkillBreak(skillInfo, skillEntry)
    if skillEntry:getValue("SkillType") == 3 then return false end
    
    if skillInfo.is_break then
        return false
    end
    
    if skillInfo.skill_level == 0 or skillInfo.skill_level%20 ~= 0 or skillInfo.skill_level == 140 then
        return false
    end

    --[[
    if skillInfo.is_break then
        return false
    end

    local breakoutEntry = cp.getManager("ConfigManager").getItemByKey("SkillBreakout", math.floor(skillInfo.skill_level/20))
    local itemList = cp.getUtils("DataUtils").splitAttr(breakoutEntry:getValue(CombatConst.SkillSeriseList[skillEntry:getValue("Serise")]))
    for _, itemInfo in ipairs(itemList) do
        local ownNum = cp.getUserData("UserItem"):getItemNum(itemInfo[1])
        if ownNum < itemInfo[2] then
            return false
        end
    end
    ]]

    return true
end

function M.needNotifySkill(skillInfo, skillEntry)
    if M.needNotifySkillBoundary(skillInfo, skillEntry) or #M.needNotifySkillArt(skillInfo, skillEntry)>0  then
        return true
    end

    return false
end

--mail
function M.needNotifyMail()
    local mailData = cp.getUserData("UserMail"):getValue("MailData")
    if not mailData then return false end
    for _, mailDetail in ipairs(mailData.mail_list) do
        if mailDetail.flag == false then
            return true
        end
    end

    return false
end

--friend

function M.needNotifyFriendRequest()
    local friendData = cp.getUserData("UserFriend"):getFriendData()
    if not friendData then
        return false
    end
    return #friendData.response_list > 0 
end

function M.needNotifyFriend()
    return M.needNotifyFriendRequest()
end

--activity
function M.needNotifyActivity()

	--簽到
    local signData = cp.getUserData("UserSign"):getValue("SignData")

    if not signData then
        return false
    end
    local today = cp.getUserData("UserSign"):getToday()
    local signFlag = cp.getUserData("UserSign"):getSignFlag(today)
    if signFlag == 0 then
        return true
    end
    for i=1, 30 do
        local signEntry = cp.getManager("ConfigManager").getItemByKey("GameSign", i)
        if signEntry:getValue("TotalReward"):len() > 0 and
            table.indexof(signData.summary_days, i) == false and
            signData.sign_days >= i then
            return true
        end
    end

	--upgrade gift
	if M.needNotifyUpgradeGift() then
		return true
	end

	--fight gift
	if M.needNotifyFightGift() then
		return true
	end

	--physical gift
	if M.needNotifyPhysicalGift() then
		return true
	end

    return false
end

--upgrade gift
function M.needNotifyUpgradeGift()
	--升級禮包
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local upgradeGift = cp.getUserData("UserRole"):getValue("upgradeGift")
	local conf = cp.getManager("ConfigManager").getConfig("UpgradeGift")	
	for _, v in ipairs(conf.dataList) do
		local id = tonumber(v[1])
		local level = tonumber(v[2])
		--開啟狀態
		local open = false
		if level <= roleAtt.level then
			open = true
		end	
		--領取狀態
		local get = false
		if upgradeGift[id+1] then --伺服器數組下標從0開始，lua下標從1開始，數組第一個是等級0的狀態
			get = true
		end
		if open and not get then
			return true
		end
	end
end

--fight gift
function M.needNotifyFightGift()
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local fightGift = cp.getUserData("UserRole"):getValue("fightGift")
	local conf = cp.getManager("ConfigManager").getConfig("FightGift")	
	for _, v in ipairs(conf.dataList) do
		local id = tonumber(v[1])
		local fight = tonumber(v[2])
		--開啟狀態
		local open = false
		if fight <= roleAtt.fightTop then
			open = true
		end	
		--領取狀態
		local get = false
		if fightGift[id+1] then --伺服器數組下標從0開始，lua下標從1開始，數組第一個是等級0的狀態
			get = true
		end
		if open and not get then
			return true
		end
	end
end

--physical gift
function M.needNotifyPhysicalGift()
	local show, index = cp.getManager("GDataManager"):isPhysicalGiftTime()
	if not show then
		return false
	end

	local physicalGift = cp.getUserData("UserRole"):getValue("physicalGift")
	if physicalGift[index] then
		return false
	end

	return true
end

--treasure
function M.needNotifySkillLottery()
    local skillLottery = cp.getUserData("UserLottery"):getSkillLottery()
    if not skillLottery then
        return false
    end
    
    local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("SkillLottery"), ":")
    local now = cp.getManager("TimerManager"):getTime()
    if now - skillLottery.free_time >= tonumber(info[4])*3600 then
        return true
    end

    return false
end

function M.needNotifyTreasureLottery()
    local treasureLottery = cp.getUserData("UserLottery"):getTreasureLottery()
    if not treasureLottery then
        return false
    end
    
    local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("TreasureLottery"), ":")
    local now = cp.getManager("TimerManager"):getTime()
    if now - treasureLottery.free_time >= tonumber(info[4])*60 and treasureLottery.free_count < tonumber(info[5]) then
        return true
    end

    return false
end

function M.needNotifyUsePoint()
    local lotteryData = cp.getUserData("UserLottery"):getLotteryData()
    if not lotteryData then return false end
    local gameConfig = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("LotteryShop"), ":")
    local point = lotteryData.point
    for _, itemInfo in ipairs(lotteryData.point_shop.item_list) do
        if itemInfo.num ~= 0 then
            local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.item_id)
            local cost = 0
            if itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Blue then
                cost = tonumber(gameConfig[2])
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Purole then
                cost = tonumber(gameConfig[3])
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Gold then
                cost = tonumber(gameConfig[4])
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Red then
                cost = tonumber(gameConfig[5])
            end

            if cost <= point then
                return true
            end
        end
    end
    return false
end

function M.needNotifyLottery()
    return M.needNotifyTreasureLottery() or M.needNotifySkillLottery() or M.needNotifyUsePoint()
end

--guess finger
function M.needNotifyGuessFinger()
    local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
    if not guessFingerData then
        return false
    end

    return not guessFingerData.is_over
end

--roll dice
function M.needNotifyRoll()
    local rollDiceData = cp.getUserData("UserGuess"):getRollDiceData()
    if not rollDiceData then
        return false
    end

    return rollDiceData.free_roll < cp.getUtils("DataUtils").GetVipEffect(7)
end

function M.needNotifyGetRollReward()
    local need = false
    local rollDiceData = cp.getUserData("UserGuess"):getRollDiceData()
    if not rollDiceData then return false end
    cp.getManager("ConfigManager").foreach("RollDice", function(entry)
        if entry:getValue("MonthReward"):len() > 0 and rollDiceData.month_point >= entry:getValue("RollPoint") then
            if table.indexof(rollDiceData.point_list, entry:getValue("RollPoint")) == false then
                need = true
                return false
            end
        end

        return true
    end)

    return need
end

function M.needNotifyRollDice()
    return M.needNotifyGetRollReward() or M.needNotifyRoll()
end

--arena
function M.needNotifyArena()
    local arenaData = cp.getUserData("UserArena"):getArenaData()
    if not arenaData then
        return false
    end

    return arenaData.challenge_count < cp.DataUtils.GetVipEffect(6) or not arenaData.award
end

--challenge
function M.needNotifyChallenge()
    return false
end

--mountain
function M.needNotifyMountainSign()
    local mountainData = cp.getUserData("UserMountain"):getValue("MountainData")
    if not mountainData then return false end

    return not mountainData.signed
end

function M.needNotifyMountain()
    local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
    local phaseState = cp.getUtils("DataUtils").getMountainFightPhase(weekDay, nowTab)
    if phaseState == 0 then
        return M.needNotifyMountainSign()
    elseif phaseState ~= 7 then
        return true
    end

    return false
end

--dailytask
function M.needNotifyDailyTask()
    local daily_data = cp.getUserData("UserDailyData"):getValue("daily_data")
    for i,info in pairs (daily_data.taskAward) do
        if info.val == 1 then
            return true
        end
    end
    for i,info in pairs (daily_data.accuAward) do
        if info.val == 1 then
            return true
        end
    end

    return false
end

--guild
function M.needNotifySalary()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local today = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())
    return playerGuildData.last_salary_day ~= today
end

function M.needNotifyShop()
    return false
end

function M.needNotifyGuildInfo()
    return M.needNotifySalary() or M.needNotifyShop()
end

function M.needNotifyGuildRequest()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end
    return #guildDetailData.request_list.request_list > 0
end

function M.needMotifyGuildMember()
    return M.needNotifyGuildRequest()
end

function M.needNotifyGuildSweep()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end

    local sweepConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("SweepConfig"), ";")
    return playerGuildData.sweep_info.count < sweepConfig[1] and (cp.getManager("TimerManager"):getTime() - playerGuildData.sweep_info.start_time > 600)
end

function M.needNotifyGuildExpel()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end
    if not cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 2) then return false end
    local config = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("ExpelRobber"), ";")
    local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildActivity"), ";:")
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
    local time1 = nowTab.hour*3600+nowTab.min*60+nowTab.sec
    local time2 = commonConfig[2][1]*3600+commonConfig[2][2]*60
    if time1 < time2 or time1 > time2 + commonConfig[3][1]*60 then
        return false
    end

    return true
end

function M.needNotifyGuildBuild()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end
    if not cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 3) then return false end
    
    local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildBuilding"), ";:")
    return playerGuildData.build_info.count < commonConfig[5][1]
end

function M.needNotifyGuildWanted()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end
    if not cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 4) then return false end
    
    local wantedConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("WantedConfig"), ";")
    return playerGuildData.wanted_info.count < wantedConfig[1]
end

function M.needNotifyGuildPrepare()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end

    local DataUtils = cp.getUtils("DataUtils")
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(roleAtt.id)
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
    local phase, remainTime = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
    if phase == 2 and memberInfo.duty > 0 and guildDetailData.fight_info.city == 0 then
        return true
    end

    return false
end

function M.needNotifyGuildSign()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    if not playerGuildData then return false end
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    if not guildDetailData then return false end

    local DataUtils = cp.getUtils("DataUtils")
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
    local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
    local phase, remainTime = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)

    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local signed = cp.getUserData("UserGuild"):isMemberSigned(roleAtt.id)
    return phase == 2 and not signed and guildDetailData.fight_info.city > 0 
end

function M.needNotifyGuildFightList()
    local DataUtils = cp.getUtils("DataUtils")
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local now = cp.getManager("TimerManager"):getTime()
    local weekDay = tonumber(os.date("%w", now))
    local nowTab = os.date("*t", now)
    local phase, _ = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
    if phase == 3 then
        return false
    end

    local checkTime = cp.getManager("LocalDataManager"):getValue("", "red_notify", "fight_list") or 0
    return  checkTime < now and checkTime ~= 0
end

function M.needNotifyGuildFight()
    return M.needNotifyGuildPrepare() or M.needNotifyGuildSign() or M.needNotifyGuildFightList()
end

function M.needNotifyGuildActivity()
    return M.needNotifyGuildSweep() or M.needNotifyGuildExpel() or M.needNotifyGuildBuild() or M.needNotifyGuildWanted() or M.needNotifyGuildFight()
end

function M.needNotifyGuild()
    return M.needNotifyGuildInfo() or M.needMotifyGuildMember() or M.needNotifyGuildActivity()
end

function M.needNotifyPrimeval()
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if not roleAtt then return false end
    if roleAtt.hierarchy <= 3 then
        return false
    end
    return M.needNotifyPrimevalFreeBuy() or M.needNotifyPrimevalEquip()
end

function M.needNotifyPrimevalFreeBuy()
    local primevalData = cp.getUserData("UserPrimeval"):getPrimevalData()
    if not primevalData then return false end
    local primevalConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("PrimevalConfig"), ";")
    if primevalData.free_learn < primevalConfig[7] then
        return true
    end

    return false
end

function M.needNotifyPrimevalEquip()
    for pack=1, 3 do
        if M.needNotifyPrimevalEquipPack(pack) then
            return true
        end
    end

    return false
end

function M.needNotifyPrimevalEquipPack(pack)
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if not roleAtt then return false end
    if roleAtt.hierarchy < 3 then
        return false
    end

    if roleAtt.hierarchy - 3 < pack - 1 then
        return false
    end

    local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
    local equipMap = cp.getUserData("UserPrimeval"):getValue("EquipMap")
    if not posMap then return false end
    if not equipMap then return false end
    if table.nums(posMap) == 0 then
        return false
    end
    for place=1, 6 do
        local equipPos = bit.lshift(pack, 16) + place
        if equipMap[equipPos] == nil then
            return true
        end
    end

    return false
end


function M.needNoticeAchivement()
    local achive_list = cp.getUserData("UserAchivement"):getValue("achive_list")
    for ID,num in pairs(achive_list) do
        if num == 1 then
            return true
        end
    end
    return false
end

return M
