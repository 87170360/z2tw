local BaseData = require("cp.data.BaseData")
local UserMapEvent = class("UserMapEvent",BaseData)

function UserMapEvent:create()
    local ret =  UserMapEvent.new()
    ret:init()
    return ret
end

--[[
//善惡事件格式
message ConductData {
    required string uuid                    = 1;                    //uuid
    required int64 confId                   = 2;                    //配置表id
    required int32 state                    = 3;                    //狀態 ConductState
    optional int32 leftTime                 = 4;                    //剩餘時間秒
    optional int64 startStamp               = 5;                    //事件開始時間戳
    optional string owner                   = 6;                    //擁有者帳號
    repeated BreakInfo breakInfo            = 7;                    //破壞訊息
    repeated uint32 ownerSkillId            = 8;                    //擁有者武學列表
    optional int32 ownerFight               = 9;                    //擁有者戰力
    optional string pos                     = 10;                   //位置索引
}

]]
function UserMapEvent:init()
    
    self["map_event_list"] = {}   --保存事件列表(uuid做key)
    
    self["event_used_pos"] = {} --當前已經在使用事件位置
    
    self["event_result"] = {} --事件處理的結果 獎勵數據
        
    self["callhelp_uuid"] = {} --已求助過的豪俠的uuid  {uuid1=time1,uuid2=time2}
    local cfg = {
        ["isSwitch"] = false
    }
    self:addProtectedData(cfg)
end

function UserMapEvent:getMapEvent(uuid)
    return self["map_event_list"][uuid]
end

function UserMapEvent:removeEvent(uuid)
    self["map_event_list"][uuid] = nil
end

function UserMapEvent:getEffectiveEvent()
    local uuidList = {}
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    for uuid, conductData in pairs(self["map_event_list"]) do
        if conductData.owner == majorRole.account and conductData.state > 1 then
            table.insert(uuidList, uuid)
        end
    end

    return uuidList
end

--更新事件
function UserMapEvent:refreshMapEvent(eventList)
    self:stopUpdate()
    self._hasUpdate = false

    for uuid,info in pairs (eventList) do
        if info.pos then
            info.pos = tonumber(info.pos)
        end
        self["map_event_list"][uuid] = info
    end

    --檢測是否需要開啟定時器
    -- self:checkNeedUpdate()
end

function UserMapEvent:clearMapEvent()
	self["map_event_list"] = {}
end

function UserMapEvent:checkNeedUpdate()
    --檢測是否需要開啟定時器
    if not self._hasUpdate then
        for uuid,eventInfo in pairs (self["map_event_list"]) do
            if self["map_event_list"][uuid].state > 1 and self["map_event_list"][uuid].state < 4 and self["map_event_list"][uuid].leftTime > 0 then
                self:startUpdate()
                break
            end
        end
    end
end

--刷新函數
function UserMapEvent:_update()
    self._hasUpdate = true
    local needStop = true
    for uuid,eventInfo in pairs (self["map_event_list"]) do
        if eventInfo and eventInfo.state > 1 and eventInfo.state < 4 and eventInfo.leftTime > 0 then
            needStop = false
            self["map_event_list"][uuid].leftTime = self["map_event_list"][uuid].leftTime - 1
        end
    end

    if needStop then
        self:stopUpdate()
        self._hasUpdate = false
    end
end

-- interval為更新的間隔時間
function UserMapEvent:startUpdate(interval)
    interval = interval or 1 -- 默認1秒調用一次_update
    self:stopUpdate()
    self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),interval,false)

end

function UserMapEvent:stopUpdate()
    if self._scheduleID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleID)
    end
    self._scheduleID = nil
end



return UserMapEvent
