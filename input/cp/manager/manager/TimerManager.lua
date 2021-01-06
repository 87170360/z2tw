--跟計時有關數據變更的方法寫在這裡

local TimerManager = class("TimerManager")
function TimerManager:create()
    local ret =  TimerManager.new() 
    ret:init()
    return ret
end  

function TimerManager:init()
    self.sysTime = 0

    self.receiveSysTime = 0
    self.localTime = 0

    self.isStart = false

    self.enterList = {}
    self.leaveList = {}

    self.dayTime0 = 0            --凌晨0點0分0秒
    self.dayTime24 = self:_getDayTimeByDate({hour=24,min=0,sec=0})  --24點
    self.idx = 1
    self.scheduleEntryId = nil

end

function TimerManager:resetTime(time,start)
    self.receiveSysTime = time
    self.localTime = os.time()
    self.sysTime = self.receiveSysTime
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "resume_interval")
    self.resume_interval = Config:getValue("IntValue")
    local Config1 = cp.getManager("ConfigManager").getItemByKey("Other", "init_physical")
	self.init_physical = Config1:getValue("IntValue")
    if start == true then
        self:start()
    end
end

--啟動時間管理
function TimerManager:start()
    self:stop()

    self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),1,false)
    self.isStart = true
end

function TimerManager:stop()
    if self.scheduleEntryId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
        self.scheduleEntryId = nil
    end
    self.isStart = false
end

--獲取伺服器時間戳
function TimerManager:getTime()
    return self.sysTime
end

--[[
    獲取當前系統時間的table形式
    return {year=2016, month=7, day=13, hour=10,min=51,sec=7,isdst=false,wday=4,yday=195}
    wday 星期幾， 星期天為1，星期1為2...星期6為7
    yday 每年中的第幾天 ，1月1號為1 ...
]]
function TimerManager:getDate()
    return os.date("*t",self.sysTime)
end

--
function TimerManager:_updateTime()
    local localTime2 = os.time()
    self.sysTime = self.receiveSysTime  + localTime2 - self.localTime
end

--定時器，每秒執行
function TimerManager:_update(dt)  
    if not (self.sysTime >0) then
        return
    end

    self:_updateTime()

    self:_checkEnter()

    self:_checkLeave()
    
    self:_getExerciseResult()
end

--獲取一個date中當天時間折算為秒
function TimerManager:_getDayTimeByDate(date)
    return date.hour*60*60+date.min*60+date.sec
end

--獲取前一天是星期幾，1為星期天，2為星期一...
function TimerManager:_getPrevWday(wday)
    wday = wday - 1
    if wday == 0 then
        wday = 7
    end
    return wday
end

--[[
    檢查當前系統時間的當天時間，是否在time1,time2之間
    返回：
        第一個參數 ture/false  是否在time1，time2之間
        第二個參數 ture/false  如果time2為第二天，且當前時間也在第二天，則返回false，第一天或同一天返回true
]]
function TimerManager:getDayTimeBetween(time1,time2)
    local date = self:getDate()
    local time = self:_getDayTimeByDate(date)
    local isBetween = false
    local isSameDay = false
    if  time1 <= time2 then
        if time>=time1 and time<= time2 then
            isBetween = true
            isSameDay = true
        else
            isBetween = false
            if time < time1 then
                isSameDay = false
            else
                isSameDay = true
            end
        end
    else
        if (time >= time1 and time<self.dayTime24) then
            isBetween = true
            isSameDay = true
        elseif (time >= self.dayTime0 and time<=time2)  then
            isBetween = true
            isSameDay = false
        else
            isBetween = false
            isSameDay = true
        end
    end
    local useday = -1
    if isSameDay then
        useday = date.wday
    else
        useday = self:_getPrevWday(date.wday)
    end
    return isBetween,useday
end

function TimerManager:_checkDate(date)
    date = date or {}
    date.hour = checkint(date.hour)
    date.min = checkint(date.min)
    date.sec = checkint(date.sec)
end

--[[
    註冊回調，進入時間段
    date1 = {hour=23,min=5,sec=8}
    date2 = {hour=3,min=6,sec=12}
    代表時間進入 23:05:08 - 03:06:12 這個時間段時，執行回調callback
    immediatelyUse 
        為ture時，註冊時已經在此時間段，立即執行一次
        默認為false，如註冊時已經在此時間段，則隔天這個時間段再執行。
]]
function TimerManager:registerEnterTime(date1,date2,callback,immediatelyUse)
    local idx = self.idx
    self.idx = self.idx + 1
    self:_checkDate(date1)
    self:_checkDate(date2)
    local time1 = self:_getDayTimeByDate(date1)
    local time2 = self:_getDayTimeByDate(date2)
    local isBetween,useday = self:getDayTimeBetween(time1,time2)
    if isBetween then
        if immediatelyUse == true then
            useday = -1
        end
    else
        useday = -1
    end

    self.enterList[idx] = {time1 = time1 , time2 = time2 , callback = callback , useday = useday}
    return idx
end

function TimerManager:unregisterEnterTime(idx)
    self.enterList[idx] = nil
end

function TimerManager:_checkEnter()
    local isBetween = nil
    local useday = nil
    for idx, datatb in pairs(self.enterList) do
        isBetween,useday = self:getDayTimeBetween(datatb.time1,datatb.time2)
        if isBetween and datatb.useday ~= useday then
            datatb.useday = useday
            datatb.callback(useday)
        end
    end
end


--[[
    註冊回調，離開時間段
    date1 = {hour=23,min=5,sec=8}
    date2 = {hour=3,min=6,sec=12}
    代表時間離開 23:05:08 - 03:06:12 這個時間段時，執行回調callback
    immediatelyUse 
        為ture時，註冊時已經不在此時間段，立即執行一次
        默認為false，如註冊時已經不在此時間段，則隔天這個時間段再執行。
]]
function TimerManager:registerLeaveTime(date1,date2,callback,immediatelyUse)
    local idx = self.idx
    self.idx = self.idx + 1
    self:_checkDate(date1)
    self:_checkDate(date2)
    local time1 = self:_getDayTimeByDate(date1)
    local time2 = self:_getDayTimeByDate(date2)
    local isBetween,useday = self:getDayTimeBetween(time1,time2)
    if not isBetween then
        if immediatelyUse == true then
            useday = -1
        end
    else
        useday = -1
    end
    self.leaveList[idx] = {time1 = time1 , time2 = time2 , callback = callback , useday = useday}
    return idx
end

function TimerManager:unregisterLeaveTime(idx)
    self.leaveList[idx] = nil
end

function TimerManager:_checkLeave()
    local isBetween = nil
    local useday = nil
    for idx, datatb in pairs(self.leaveList) do
        isBetween,useday = self:getDayTimeBetween(datatb.time1,datatb.time2)
        if (not isBetween ) and datatb.useday ~= useday then
            datatb.useday = useday
            datatb.callback(useday)
        end
    end
end

function TimerManager:_getExerciseResult()
    local onLineTimeCount = self.sysTime - self.receiveSysTime

    --請求自動歷練數據
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if onLineTimeCount % 120 == 0 then --每2分鐘請求一次
        if major_roleAtt.exerciseId > 0 then
          local req = {}
          cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").GetExerciseReq, req)
        end

        --判斷跨天
        local date = self:getDate()
        if date.hour == 0 and date.min >= 0 and date.min <=3  then
            local req = {}
            cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").OnlineCrossDayReq, req)
        end
    end
    
    --體力值更新
    if self.resume_interval == nil then
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "resume_interval")
        self.resume_interval = Config:getValue("IntValue")
        local Config1 = cp.getManager("ConfigManager").getItemByKey("Other", "init_physical")
        self.init_physical = Config1:getValue("IntValue")
    end
    if major_roleAtt.physical < self.init_physical  and onLineTimeCount % self.resume_interval == 0 then --每6分鐘請求一次
        local req = {}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").UpdatePhysicalReq, req)
    end

    --罪惡值更新
    if self.sins_del_time == nil then
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "sins_del_time")
        self.sins_del_time = Config:getValue("IntValue")
    end
    if major_roleAtt.sins > 0 and onLineTimeCount % self.sins_del_time == 0  then
        local req = {}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").UpdateSinsReq, req)
    end
    
    --精力更新
    if self.resume_vigor == nil then
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "resume_vigor")
        self.resume_vigor = Config:getValue("IntValue")
        local Config1 = cp.getManager("ConfigManager").getItemByKey("Other", "init_vigor")
        self.init_vigor = Config1:getValue("IntValue")
    end
    if major_roleAtt.vigor < self.init_vigor and onLineTimeCount % self.resume_vigor == 0 then --每3分鐘請求一次精力更新
        local req = {}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").UpdateVigorReq, req)
    end
    
end

return TimerManager


