

local BNode = require "cp.view.ui.base.BNode"
local WaitingLayer = class("WaitingLayer",BNode)

function WaitingLayer:create()
    local node = WaitingLayer.new()
    return node
end

--該界面UI註冊的事件偵聽
function WaitingLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function WaitingLayer:onInitView()
	local jsonPath,atlasPath = "spine/connect/point.json", "spine/connect/point.atlas"
    --local jsonPath,atlasPath = "img/effect/xiaohao/xiaohao.json", "img/effect/xiaohao/xiaohao.atlas"
    
    if not jsonPath or not atlasPath then return nil end
    if not cc.FileUtils:getInstance():isFileExist(jsonPath) or 
        not cc.FileUtils:getInstance():isFileExist(atlasPath) then
        return nil
    end
    local spineAnim = sp.SkeletonAnimation:create(jsonPath, atlasPath)
    spineAnim:setToSetupPose()
    spineAnim:setAnimation(0, "ponit", true)
    -- spineAnim:setAnimation(0, "xiaohao", true)
    self:addChild(spineAnim)
    self.spineAnim = spineAnim
    self:setPosition(display.cx,display.cy)
    -- spineAnim:setPosition(display.cx,display.cy)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function() 
        log("SSSSS")
    end)
end

function WaitingLayer:onEnterScene()

end

function WaitingLayer:onExitScene()
    self.spineAnim:setToSetupPose()
	self.spineAnim:removeFromParent()
end

function WaitingLayer:getDescription()
    return "WaitingLayer"
end


return WaitingLayer