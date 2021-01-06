local BaseData = require("cp.data.BaseData")
local UserLottery = class("UserLottery", BaseData)

function UserLottery:create()
    local ret = UserLottery.new() 
    ret:init()
    return ret
end

function UserLottery:init()
end

function UserLottery:getLotteryData()
    local lotteryData = self:getValue("LotteryData")
    if not lotteryData then return nil end

    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local thisWeekDay = cp.getUtils("TimeUtils").GetThisWeekDay(nil, 1)
    local year, month, day = cp.getUtils("TimeUtils").GetDate(thisWeekDay)
    local nowMonth = year*10000 + month*100 + day
    if nowMonth ~= lotteryData.month then
        lotteryData.month = nowMonth
        lotteryData.month_point = 0
    end

    if today ~= lotteryData.day then
        lotteryData.day = today
        lotteryData.treasure_lottery.free_count = 0
        lotteryData.skill_lottery.count = 0
    end
    return lotteryData
end

function UserLottery:getSkillLottery()
    local lotteryData = self:getLotteryData()
    if not lotteryData then return nil end
    return lotteryData.skill_lottery
end

function UserLottery:setSkillLottery(skillLottery)
    self:getLotteryData().skill_lottery = skillLottery
end

function UserLottery:getTreasureLottery()
    local lotteryData = self:getLotteryData()
    if not lotteryData then return nil end
    return lotteryData.treasure_lottery
end

function UserLottery:setTreasureLottery(treasureLottery)
    self:getLotteryData().treasure_lottery = treasureLottery
end

function UserLottery:getPointShop()
    local lotteryData = self:getLotteryData()
    if not lotteryData then return nil end
    return self:getLotteryData().point_shop
end

function UserLottery:setPointShop(pointShop)
    local lotteryData = self:getLotteryData()
    if not lotteryData then return nil end
    self:getLotteryData().point_shop = pointShop
end

function UserLottery:addPoint(point)
    local lotteryData = self:getLotteryData()
    lotteryData.point = lotteryData.point + point
    lotteryData.month_point = lotteryData.month_point + point
end

function UserLottery:getPoint()
    local lotteryData = self:getLotteryData()
    return lotteryData.point, lotteryData.month_point
end

function UserLottery:setPoint(point)
    local lotteryData = self:getLotteryData()
    lotteryData.point = point
end

function UserLottery:updateShopItem(itemID, num)
    local pointShop = self:getLotteryData().point_shop
    for _, itemInfo in ipairs(pointShop.item_list) do
        if itemInfo.item_id == itemID then
            itemInfo.num = itemInfo.num - num
            break
        end
    end
end

return UserLottery