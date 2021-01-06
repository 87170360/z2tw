local BNode = class("BNode",function() return cc.Node:create() end)

function BNode:ctor(...)
    self:initListEvent()
    self._listCallBack = handler(self,self._onListEventCallBack)
    self:registerScriptHandler(handler(self,self.onEnterOrExitCallBack))
    self:onInitView(...)
end

function BNode:onEnterOrExitCallBack(eventType)
    if eventType == "enter" then
        self:_registerViewListeners()
        self:onEnterScene()
    elseif eventType == "exit" then
        self:_unregisterViewListeners()
        self:onExitScene()
    end
end

function BNode:initListEvent()
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

function BNode:_onListEventCallBack(evt)
    if self.listListeners and self.listListeners[evt.name] then
        self.listListeners[evt.name](evt.data)
    end
end

function BNode:_registerViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):addEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BNode:_unregisterViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):removeEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BNode:onInitView(...)
    --override
end

function BNode:onEnterScene()
    --override
end

function BNode:onExitScene()
    --override
end

function BNode:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function BNode:doSendSocket(protoName,data)
    cp.getManager("SocketManager"):doSend(protoName,data)
end

return BNode