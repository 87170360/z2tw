local BLayer = class("BLayer",function() return cc.Layer:create() end)

function BLayer:ctor(...)
    self:initListEvent()
    self._listCallBack = handler(self,self._onListEventCallBack)
    self:registerScriptHandler(handler(self,self.onEnterOrExitCallBack))
    self:onInitView(...)
end

function BLayer:onEnterOrExitCallBack(eventType)
    if eventType == "enter" then
        self:_registerViewListeners()
        self:onEnterScene()
        
    elseif eventType == "exit" then
        self:_unregisterViewListeners()
        self:onExitScene()
    end
end

function BLayer:initListEvent()
    self.listListeners = {
        --        ["dataup_scene_xxx"] = function(data)
        --            
        --        end,
        --
        --        ["game_scene_xxx"] = function(data)
        --            
        --        end,
        }
end

function BLayer:_onListEventCallBack(evt)
    if self.listListeners and self.listListeners[evt.name] then
        self.listListeners[evt.name](evt.data)
    end
end

function BLayer:_registerViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):addEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BLayer:_unregisterViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):removeEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BLayer:onInitView(...)
    --override
end

function BLayer:onEnterScene()
    --override
end

function BLayer:onExitScene()
    --override
end

function BLayer:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function BLayer:doSendSocket(protoName,data)
    cp.getManager("SocketManager"):doSend(protoName,data)
end


return BLayer

