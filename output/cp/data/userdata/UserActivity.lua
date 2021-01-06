local BaseData = require("cp.data.BaseData")
local UserActivity = class("UserActivity",BaseData)

function UserActivity:create()
    local ret =  UserActivity.new()
    ret:init()
    return ret
end

function UserActivity:init()
    
    self["first_recharge_config"] = {} --首儲獎勵的配置訊息
    self["rechargeGift_config"] = {} --限時儲值活動配置訊息
    self["rechargeGift"] = {} --限時儲值活動獎勵領取狀態
    self["fundGift"] = {} --基金獎勵領取狀態
    self["fund_config"] = {} --活動基金配置
    local cfg = {
        ["rechargeGift_time_start"] = 0, -- 限時儲值活動開啟時間
        ["rechargeGift_time_end"] = 0,   -- 限時儲值活動結束時間
        ["rechargeGold"] = 0, --限時活動中儲值的元寶數
        ["firstRecharge"] = 0, --首儲狀態(0:不可領 1：可領 2：已領)
        ["fund"] = false, --是否購買了江湖基金
    }	                               
    self:addProtectedData(cfg)
end

function UserActivity:updateRechargeGift(element)
    self["rechargeGift"] = {}
    if element and next(element) then
        for i,value in pairs(element) do
            self["rechargeGift"][value.id] = value.num + 1
        end
    end
    for i,info in pairs(self["rechargeGift_config"]) do
        if self["rechargeGift"][info.ID] == nil then
            self["rechargeGift"][info.ID] = 0 -- 未達到領取條件
        end
    end
end

function UserActivity:updateFundGift(element)
    self["fundGift"] = {}
    if element and next(element) then
        for i,value in pairs(element) do
            self["fundGift"][value.id] = value.num + 1
        end
    end
end


return UserActivity