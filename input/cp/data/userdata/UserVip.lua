local BaseData = require("cp.data.BaseData")
local UserVip = class("UserVip",BaseData)

function UserVip:create()
    local ret =  UserVip.new()
    ret:init()
    return ret
end

function UserVip:init()
    
    self["Cards"] = {}    -- 月卡，季卡，年卡，終身卡剩餘天數訊息
    local cfg = {
		["privilege"] = 0,             --//特權禮包領取情況 比如010110 
        ["exclusive"] = 0,             --//專屬禮包領取情況 比如010110 
        ["daily"] = 0,                 --//日常禮包領取情況 比如010110 
        ["exp"] = 0,                   --//經驗
        ["level"] = 0,                 --//等級 
        ["gold"] = 0,                  --//儲值元寶
        ["freeGold"] = 0,              --//歷史贈送元寶總數
        ["money"] = 0,                 --//歷史儲值人民幣總數
        ["firstRecharge"] = 0,         --//首儲記錄
    }	                               
    self:addProtectedData(cfg)
end

function UserVip:updateCards(cards)
    for i,info in pairs(cards) do
        self["Cards"][tostring(info.id)] = info.num
    end
end

--登錄後設置Vip訊息
function UserVip:resetVipInfo(info)

    self:setValue("privilege",info.privilege or 0)
    self:setValue("exclusive",info.exclusive or 0)
    self:setValue("daily",info.daily or 0)
    self:setValue("exp",info.exp or 0)
    self:setValue("level",info.level or 0)
    self:setValue("gold",info.gold or 0)
    self:setValue("freeGold",info.freeGold or 0)
    self:setValue("money",info.money or 0)
    self:setValue("firstRecharge",info.firstRecharge or 0)
end

function UserVip:setFirstRechargeState(id)
    local ss = bit.lshift(1, id)
    local aa = bit.bor(ss, self:getValue("firstRecharge"))
    self:setValue("firstRecharge",aa)
end


function UserVip:getFirstRechargeState(id)
    local ss = bit.lshift(1, id)
    local aa = bit.band(ss, self:getValue("firstRecharge"))
    return bit.band(ss, self:getValue("firstRecharge")) ~= ss
end

function UserVip:getLibaoState(libaoType,level)
    -- local level = self:getValue("level")
    if level < 0 then
        return false
    end

    local ss = bit.lshift(1, level)
    if libaoType == 1 then
        return bit.band(ss, self:getValue("exclusive")) == ss  -- 專屬禮包
    elseif libaoType == 2 then
        return bit.band(ss, self:getValue("privilege")) == ss   -- 特權禮包
    elseif libaoType == 3 then
        return bit.band(ss, self:getValue("daily")) == ss
    end 
    return false
end

return UserVip