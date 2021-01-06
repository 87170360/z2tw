local BScene = class("BScene",function() return cc.Scene:create() end)

function BScene:ctor(...)
    self:initListEvent()
    self._listCallBack = handler(self,self._onListEventCallBack)
    self:registerScriptHandler(handler(self,self.onEnterOrExitCallBack))

    self.top_root = cc.Node:create()     --指引窗口的和網路斷開提醒根節點
    self:addChild(self.top_root,1001)    --目前最高層級
    self:onInitView(...)
end

function BScene:onEnterOrExitCallBack(eventType)
    if eventType == "enter" then
        self:_registerViewListeners()
        if cp.getManager("PopupManager"):getRoot() ~= self then
            cp.getManager("PopupManager"):setRoot(self)
        end
        self:onEnterScene()
    elseif eventType == "exit" then
        self:_unregisterViewListeners()
        if cp.getManager("PopupManager"):getRoot() == self then
            cp.getManager("PopupManager"):clean()
            cp.getManager("PopupManager"):setRoot(nil)
        end
        self.top_root:removeAllChildren()
        self:onExitScene()
    end
end

function BScene:initListEvent()
    self.listListeners = {
        --        ["dataup_scene_xxx"] = functio n(data)
        --            
        --        end,
        --
        --        ["game_scene_xxx"] = function(data)
        --            
        --        end,
        }
end

function BScene:_onListEventCallBack(evt)
    if self.listListeners and self.listListeners[evt.name] then
        self.listListeners[evt.name](evt.data)
    end
end

function BScene:_registerViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):addEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BScene:_unregisterViewListeners()
    for eventName, eventFunc in pairs(self.listListeners) do
        cp.getManager("EventManager"):removeEventListener("VIEW",eventName,self._listCallBack)
    end
end

function BScene:onInitView(...)
    --override
--    log(1)
end

function BScene:onEnterScene()
    --override
end

function BScene:onExitScene()
    --override
end

function BScene:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function BScene:doSendSocket(protoName,data)
    cp.getManager("SocketManager"):doSend(protoName,data)
end

return BScene