--彈出窗口管理

local PopupInfo = class("PopupInfo")
function PopupInfo:create()
    local ret =  PopupInfo.new() 
    return ret
end  
function PopupInfo:ctor()
    self.node = nil 
    self.modal = nil 
end


local PopupManager = class("PopupManager")

PopupManager.popZOrder = 1000

function PopupManager:create()
    local ret =  PopupManager.new() 
    ret:init()
    return ret
end  

function PopupManager:init()
    self.popupInfos = {}        --info格式 node,modal
    self.root = nil                 --根視圖
    self.modalSize = cc.size(960,640)
    self.modalColor = cc.c3b(0,0,0)
    self.modalOpacity = 204
end

function PopupManager:setDefaultModalSize(size)
    self.modalSize = size
end

function PopupManager:setDefaultModalColor(c4b)
    self.modalColor = cc.c3b(c4b.r,c4b.g,c4b.b)
    self.modalOpacity = c4b.a
end

function PopupManager:setRoot(root)
    self.root = root
end

function PopupManager:getRoot()
    return self.root
end

function PopupManager:_getPopup(node)
    for i,info in ipairs(self.popupInfos) do
        if info.node == node then
            return i,info
        end
    end
    return -1,nil
end

function PopupManager:_createDefaultModal()
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0,0)
    layout:setPosition(0,0)
    layout:setContentSize(self.modalSize)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(self.modalColor)
    layout:setBackGroundColorOpacity(self.modalOpacity)
    layout:setTouchEnabled(true)
    return layout
end

--modalNode must be based on ccui
function PopupManager:addPopup(node,isModal,modalNode,modalClickCallBack)
    if not node then return  end
    local info = PopupInfo:create()
    if isModal then
        if modalNode then
            info.modal = modalNode
        else
            info.modal = self:_createDefaultModal()
        end
        self.root:addChild(info.modal,PopupManager.popZOrder)
        if modalClickCallBack then
            local function onTouch(sender, event)
                if event == cc.EventCode.ENDED  then
                    modalClickCallBack(node)
                end
            end
            info.modal:setTouchEnabled(true)
            info.modal:addTouchEventListener(onTouch)
        end
    else
        info.modal = nil
    end
    info.node = node
    self.root:addChild(info.node,PopupManager.popZOrder)
    table.insert(self.popupInfos,info)
end

function PopupManager:removePopup(node)
    local idx,info = self:_getPopup(node)
    return self:removePopupByIndex(idx)
end

function PopupManager:getPopupByIndex(idx)
    local info = self.popupInfos[idx]
    if info then
        return info.node
    end
    return nil
end

function PopupManager:removePopupByIndex(idx)
    local info = self.popupInfos[idx]
    if info then
        if info.modal then
            info.modal:removeFromParent(true)
        end
        info.node:removeFromParent(true)
        table.remove(self.popupInfos,idx)
        return info.node
    end
    return nil
end

function PopupManager:getPopups()
    local tb = {}
    for i,v in ipairs(self.popupInfos) do
        tb[i] = v.node
    end
    return tb
end

function PopupManager:clean()
    local cnt = #self.popupInfos
    for i=cnt,1,-1 do
        local info = self.popupInfos[i]
        if info.modal then
            info.modal:removeFromParent(true)
        end
        if info.node then
            info.node:removeFromParent(true)
        end
    end
    self.popupInfos = {}
end

-- function PopupManager:bringToFront(node)
    
-- end

return PopupManager