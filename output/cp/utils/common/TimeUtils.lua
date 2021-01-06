local M = {}
function M.GetToday(ts)
    local tb = os.date("*t", ts)
    tb.hour = 0
    tb.min = 0
    tb.sec = 0

    return os.time(tb)
end

function M.GetTime(ts, hour, min, sec)
    local tb = os.date("*t", ts)
    tb.hour = hour
    tb.min = min
    tb.sec = sec

    return os.time(tb)
end

function M.GetDayOfToday(ts)
    if ts == nil then
        ts = cp.getManager("TimerManager"):getTime()
    end
    local a = os.time(os.date('!*t', ts))--中時區的時間

    local dd = math.floor((ts - a)/3600)
    local day = math.floor((ts+dd*3600)/(24*3600))
    return day
end

function M.GetMonth(ts)
    if ts == nil then
        ts = cp.getManager("TimerManager"):getTime()
    end
    local tb = os.date("*t", ts)
    return tb.month
end

function M.GetDate(ts)
    if ts == nil then
        ts = cp.getManager("TimerManager"):getTime()
    end
    local tb = os.date("*t", ts)
    return tb.year, tb.month, tb.day
end

function M.GetThisWeekDay(ts, weekDay)
    if ts == nil then
        ts = cp.getManager("TimerManager"):getTime()
    end

    for i=0, 6 do
        local tempTime = ts - i * 3600 * 24
        local wd = tonumber(os.date("%w", tempTime))
        if wd == weekDay then
            return M.GetToday(tempTime)
        end
    end

    return ts  
end
return M