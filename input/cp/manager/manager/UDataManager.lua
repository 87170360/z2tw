--改變用戶數據的方法，寫這裡

local UDataManager = class("UDataManager")

function UDataManager:create()
    local ret =  UDataManager.new() 
    ret:init()
    return ret
end  

function UDataManager:init()
    
end

function UDataManager:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end


return UDataManager


