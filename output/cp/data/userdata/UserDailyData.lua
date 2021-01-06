local BaseData = require("cp.data.BaseData")
local UserDailyData = class("UserDailyData",BaseData)

function UserDailyData:create()
    local ret =  UserDailyData.new()
    ret:init()
    return ret
end

function UserDailyData:init()
--[[
    message DailyMapData {
    required int32 key                     = 1;
    required int32 val                     = 2;
}

//協議格式
message DailyProtoData {
    required int32 accu                    = 1;                   //當前積分
	repeated DailyMapData accuAward        = 2;                   //積分獎勵狀態 key: 積分獎勵配置id, value: 0 未達成, 1 已經達成, 2 已經領取
	repeated DailyMapData taskAward        = 3;                   //任務獎勵狀態 key: 任務配置id, value: 0 未達成, 1 已經達成, 2 已經領取
	repeated DailyMapData taskComplete     = 4;                   //任務完成次數 key: 任務配置id, value: 次數
}
]]
    self["daily_data"] = {}
    local cfg = {
        
    }	
    self:addProtectedData(cfg)

    self["AccuList"] = cp.getManager("GDataManager"):getDailyTaskAccuList()
end

function UserDailyData:resetAllDailyData(daily_data)
    self["daily_data"] = daily_data

    local function sortByID(a,b)
        return a.key < b.key
    end
    table.sort(self["daily_data"].taskAward,sortByID)
    table.sort(self["daily_data"].accuAward,sortByID)
    table.sort(self["daily_data"].taskComplete,sortByID)

end

--領取積分獎勵及任務獎勵後更新任務數據
function UserDailyData:updateTaskData(taskID,accu,AccuID)
    if taskID > 0 then
        for i,info in pairs (self["daily_data"].taskAward) do
            if taskID == info.key then
                self["daily_data"].taskAward[i].val = 2
            end
        end
    end
    if AccuID > 0 then
        for i,info in pairs (self["daily_data"].accuAward) do
            if AccuID == info.key then
                self["daily_data"].accuAward[i].val = 2
            end
        end
    end
    if accu > 0 then
        self["daily_data"].accu = self["daily_data"].accu + accu

        if taskID > 0 then
            for i,info in pairs (self["daily_data"].accuAward) do
                if info.val == 0 and self["AccuList"][info.key].Accu <= self["daily_data"].accu then    
                    self["daily_data"].accuAward[i].val = 1
                end
            end
        end
    end
end

--獲取任務狀態
function UserDailyData:getTaskState(taskID)
    for _,info in pairs (self["daily_data"].taskAward) do
        if taskID == info.key then
            return info.val
        end
    end
    return 0
end

--獲取積分獎勵領取狀態
function UserDailyData:getTaskAccu(accuID)
    for _,info in pairs (self["daily_data"].accuAward) do
        if accuID == info.key then
            return info.val
        end
    end
    return 0
end

--獲取任務已進行的次數
function UserDailyData:getTaskCompleteTimes(taskID)
    for _,info in pairs (self["daily_data"].taskComplete) do
        if taskID == info.key then
            return info.val
        end
    end
    return 0
end 

return UserDailyData