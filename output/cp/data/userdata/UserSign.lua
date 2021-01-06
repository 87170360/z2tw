local BaseData = require("cp.data.BaseData")
local UserSign = class("UserSign", BaseData)

function UserSign:create()
    local ret = UserSign.new() 
    ret:init()
    return ret
end

function UserSign:init()
end

function UserSign:getSignDay()
    local signData = self:getValue("SignData")
    local today = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())
    local nowDay = today-signData.first_day+1
    return nowDay
end

function UserSign:needSignToday()
    local signData = self:getValue("SignData")
    local nowDay = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())-signData.first_day+1
    return self:getSignFlag(nowDay) == 0
end

function UserSign:getToday()
    local signData = self:getValue("SignData")
    local nowDay = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())-signData.first_day+1
    return nowDay
end

--返回0為未簽到，1為已經簽到，2為已經補籤,-1表示日子還沒來
function UserSign:getSignFlag(day)
    local signData = self:getValue("SignData")
    local nowDay = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())-signData.first_day+1
    if day > nowDay then
        return -1
    end

    if day == nowDay and (signData.sign_days + #signData.unsign_day_list)<nowDay then
        return 0
    end

    if table.indexof(signData.resign_day_list, day) then
        return 2
    end

    if table.indexof(signData.unsign_day_list, day) then
        return 0
    end

    return 1
end

function UserSign:updateResignAll()
    local signData = self:getValue("SignData")
    signData.sign_days = signData.sign_days + #signData.unsign_day_list
    for _, day in ipairs(signData.unsign_day_list) do
        table.insert(signData.resign_day_list, day)
    end

    signData.unsign_day_list = {}
end

function UserSign:updateSummaryReward(totalDay)
    local signData = self:getValue("SignData")
    table.insert(signData.summary_days, totalDay)
end

return UserSign