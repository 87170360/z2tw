--事件分發監聽管理

local EventManager = class("EventManager")

function EventManager:create()
    local ret =  EventManager.new() 
    ret:init()
    return ret
end  

function EventManager:init()
    self.dispatchers = {}
end


--內部使用 private方法
function EventManager:_getDispatcher(name)
    if not self.dispatchers[name] then
        local dispatcher = cc.EventDispatcher:new()
        dispatcher:retain()
        dispatcher:setEnabled(true)
        self.dispatchers[name] = dispatcher
        self.dispatchers[name].listeners = {}
    end
    return self.dispatchers[name]
end

--內部使用 private方法
function EventManager:_removeDispatcher(name)
    if self.dispatchers[name] then
        local dispatcher = self.dispatchers[name]
        dispatcher:removeAllEventListeners()
        dispatcher.listeners = nil
        dispatcher:setEnabled(false)
        dispatcher:release()
    end
    self.dispatchers[name] = nil
end

--內部使用 private方法
function EventManager:_removeAllDispatchers()
    for name, dispatcher in pairs(self.dispatchers) do
        dispatcher:removeAllEventListeners()
        dispatcher.listeners = nil
        dispatcher:setEnabled(false)
        dispatcher:release()
    end
    self.dispatchers = {}
end

--廣播事件
function EventManager:dispatchEvent(dispatcherName,eventName,eventData)
    local evt = cc.EventCustom:new(eventName)
    evt.name = eventName
    evt.data = eventData
    self:_getDispatcher(dispatcherName):dispatchEvent(evt)
end

--添加事件偵聽器
function EventManager:addEventListener(dispatcherName,eventName,handler,priority)
    priority = priority or 1
    local dispatcher = self:_getDispatcher(dispatcherName)
    for listener, data in pairs(dispatcher.listeners) do
        if data and #data ==2 and data[1]== eventName and data[2]== handler then
            --已經有了，不重複添加
            return nil
        end
    end
    local listener = cc.EventListenerCustom:create(eventName,handler)
    dispatcher:addEventListenerWithFixedPriority(listener, priority)
    dispatcher.listeners[listener] = {eventName,handler}
    return listener
end

--移除事件偵聽器，2重載
--function EventManager:removeEventListener(dispatcherName,listener) 如handler為空，則使用api
function EventManager:removeEventListener(dispatcherName,eventName,handler)
    local dispatcher = self:_getDispatcher(dispatcherName)
    if handler then
        for listener, data in pairs(dispatcher.listeners) do
            if data and #data ==2 and data[1]== eventName and data[2]== handler then
                dispatcher:removeEventListener(listener)
                dispatcher.listeners[listener] = nil
            end
        end
    else
        local listener = eventName
        dispatcher:removeEventListener(listener)
        dispatcher.listeners[listener] = nil
    end
end

--移除所有事件
function EventManager:removeAllEventListener(dispatcherName)
    local dispatcher = self:_getDispatcher(dispatcherName)
    dispatcher:removeAllEventListeners()
    dispatcher.listeners = {}
end

function EventManager:destroy()
    self:_removeAllDispatchers()
end

return EventManager

