local BNode = require "cp.view.ui.base.BNode"
local ExpressVehicle = class("ExpressVehicle",BNode)


function ExpressVehicle:create(openInfo)
    local scene = ExpressVehicle.new(openInfo)
    return scene
end

--該界面UI註冊的事件偵聽
function ExpressVehicle:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ExpressVehicle:onInitView(openInfo)

    self.openInfo = openInfo

    self.rootNode = cc.Node:create()
    self:addChild(self.rootNode, 0)

    local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", self.openInfo.vanInfo.id)
    local animPath = itemCfg:getValue("Animation")
    
    local model = cp.getManager("ViewManager").createSpineAnimation(animPath)
    model:setAnchorPoint(cc.p(0.5, 0.5))
    model:setPosition(cc.p(0,0))
    model:setScale(0.5)
    model:setToSetupPose()
    model:setAnimation(0,"Stand_loop", true)
    self.model = model

    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5,0.5)
    layout:setPosition(cc.p(0,40))
    layout:setContentSize(cc.size(150,70))
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none) --ccui.LayoutBackGroundColorType.solid) -- solid
    -- layout:setBackGroundColor(cc.c3b(0,0,255))
    -- layout:setBackGroundColorOpacity(150)
    self.rootNode:addChild(layout,-1)
    layout:setTouchEnabled(true)
    local function onTouch(sender, event)
        if event == cc.EventCode.ENDED  then
            cp.getManager("ViewManager").gameTip("前往下一個伏擊點才能伏擊鏢車。")
        end
    end
    layout:addTouchEventListener(onTouch)

    self.rootNode:addChild(self.model, 0)
    
    local fileName = "ui_express_module21_yabiao_15.png"
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(fileName)
    if not spriteFrame then
        display.loadSpriteFrames("uiplist/ui_express.plist")
    end
    
    self.image_flag_bg = ccui.ImageView:create()
    self.image_flag_bg:loadTexture(fileName,ccui.TextureResType.plistType)
    self.image_flag_bg:setAnchorPoint(cc.p(0.5,0.5))
    self.image_flag_bg:setPosition(cc.p(0,90))
    self.image_flag_bg:setScale(1)
    self.image_flag_bg:ignoreContentAdaptWithSize(false)
    self.rootNode:addChild(self.image_flag_bg,1)
    
    self.image_flag = ccui.ImageView:create()
    self.image_flag:setAnchorPoint(cc.p(0.5,0.5))
    self.image_flag:setPosition(cc.p(32,40))
    self.image_flag:ignoreContentAdaptWithSize(false)
    self.image_flag_bg:addChild(self.image_flag,1)

    self.isSelfVehicle = false
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if self.openInfo.ownerRoleID == major_roleAtt.id then
        self.image_flag:loadTexture("img/model/head/" .. major_roleAtt.face .. ".png", UI_TEX_TYPE_LOCAL)
        self.image_flag:setScale(0.30)
        self.isSelfVehicle = true
        self.image_flag:setPosition(cc.p(32,45))
    else
        local vehicleType = itemCfg:getValue("Type")
        vehicleType = math.max(vehicleType,1)
        vehicleType = math.min(vehicleType,3)
        local flagNameList = {"ui_common_yinliang.png","ui_common_yueli.png","ui_common_yuanbao.png"}
        local flag = flagNameList[vehicleType]
        self.image_flag:loadTexture(flag,ccui.TextureResType.plistType)
        self.image_flag:setScale(1)
    end


    --觸摸層
    -- if openInfo.isNpc then
        -- local layout = ccui.Layout:create()
        -- layout:setAnchorPoint(0.5,0.5)
        -- layout:setPosition(cc.p(0,40))
        -- layout:setContentSize(cc.size(60,80))
        -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none) -- solid
        -- -- layout:setBackGroundColor(cc.c3b(0,0,255))
        -- -- layout:setBackGroundColorOpacity(150)
        -- layout:setTouchEnabled(true)
        -- self:addChild(layout,-1)
        -- layout:onTouch(handler(self, self.onRoleClicked))
    -- end


    local Time = string.split(itemCfg:getValue("Time"),"|")
    self.step_time_list = cp.getManager("GDataManager"):getExpressVehicleStepTime(Time)
    
    if self.openInfo ~= nil and self.openInfo.currentPos ~= nil then
        self.timeIndex = 1
        self.stepLeftTime = self.step_time_list[1]
        local express_pos_list = cp.getUserData("UserVan"):getValue("express_pos_list")
        self.openInfo.nextTargetPos = express_pos_list[1].endPos
        self.openInfo.nextTargetPos.y = self.openInfo.nextTargetPos.y
        self.openInfo.currentPos.y = self.openInfo.currentPos.y
    else
        --根據時長計算初始點
        self.timeIndex,self.stepLeftTime = self:getTimeIndexAndStepLeftTime(self.openInfo.vanInfo.startStamp)
        self.openInfo.nextTargetPos,self.openInfo.currentPos = self:getCurrentPosByStartStamp(self.timeIndex,self.stepLeftTime)
        
    end
    self.moveSpeed = 0
    self:setPosition(cc.p(self.openInfo.currentPos.x, self.openInfo.currentPos.y))
    if self.timeIndex == 3 or self.timeIndex == 7 or self.timeIndex == 10 then
        self.rootNode:setVisible(false)
    else
        self.moveSpeed = cc.pGetDistance(self.openInfo.currentPos,self.openInfo.nextTargetPos)/self.stepLeftTime
        self.rootNode:setVisible(true)
        self:TurnDirection()
    end

    if self.isSelfVehicle == true then
        local info = {timeIndex = self.timeIndex}
        self:dispatchViewEvent(cp.getConst("EventConst").onEnterRestErea, info )
    end
end


--獲取時間節點索引以及此段路的剩餘時間
function ExpressVehicle:getTimeIndexAndStepLeftTime(startStamp)
    local now = cp.getManager("TimerManager"):getTime()
    local lastTime = now - startStamp

    local timeTemp = 0
    for i=1,#self.step_time_list do
        timeTemp = timeTemp + self.step_time_list[i]
        if timeTemp > lastTime then
            return i,(timeTemp - lastTime) --此階段索引，及此階段剩餘時間秒數
        end
    end
    return 0,0
end

--根據比例值，獲取線段上的點的位置
function ExpressVehicle:getPosFromLine(beginPos,endPos,scale)
    if scale <= 0.0005 then
        return beginPos
    elseif scale >= 0.9995 then
        return endPos
    else
        local x = (endPos.x - beginPos.x)*scale + beginPos.x
        local y = (endPos.y - beginPos.y)*scale + beginPos.y
        return cc.p(x,y)
    end
end

function ExpressVehicle:getCurrentPosByStartStamp(timeIndex,stepLeftTime)
    local express_pos_list = cp.getUserData("UserVan"):getValue("express_pos_list")
    
    local curStepTotalTime = self.step_time_list[timeIndex]
    local curStepScale = (curStepTotalTime - stepLeftTime)/curStepTotalTime


    --獲取下個目標點
    local nextTargetPos,beginPos,curMoveState = nil,nil,nil
    
--[[ 

    -- if timeIndex == 1 then
    --     nextTargetPos = express_pos_list[2]  --拐角 鳳翔
    --     beginPos = self:getPosFromLine(express_pos_list[1],express_pos_list[2],curStepScale)
    -- elseif timeIndex == 2 then
    --     nextTargetPos = express_pos_list[3]  --風雨亭
    --     beginPos = self:getPosFromLine(express_pos_list[2],express_pos_list[3],curStepScale)
    -- elseif timeIndex == 3 then
    --     nextTargetPos = express_pos_list[3]
    --     beginPos = express_pos_list[3]
    -- elseif timeIndex == 4 then
    --     nextTargetPos = express_pos_list[4]  --拐角點(襄陽)
    --     beginPos = self:getPosFromLine(express_pos_list[3],express_pos_list[4],curStepScale)
    -- elseif timeIndex == 5 then
    --     nextTargetPos = express_pos_list[5]
    --     beginPos = self:getPosFromLine(express_pos_list[4],express_pos_list[5],curStepScale)
    -- elseif timeIndex == 6 then
    --     nextTargetPos = express_pos_list[6]
    --     beginPos = self:getPosFromLine(express_pos_list[5],express_pos_list[6],curStepScale)
    -- elseif timeIndex == 7 then
    --     nextTargetPos = express_pos_list[6]
    --     beginPos = express_pos_list[6]
    -- elseif timeIndex == 8 then
    --     nextTargetPos = express_pos_list[7]
    --     beginPos = self:getPosFromLine(express_pos_list[6],express_pos_list[7],curStepScale)
    -- elseif timeIndex == 9 then
    --     nextTargetPos = express_pos_list[8]
    --     beginPos = self:getPosFromLine(express_pos_list[7],express_pos_list[8],curStepScale)
    -- elseif timeIndex == 10 then
    --     nextTargetPos = express_pos_list[8]
    --     beginPos = express_pos_list[8]
    -- elseif timeIndex == 11 then
    --     nextTargetPos = express_pos_list[9]
    --     beginPos = self:getPosFromLine(express_pos_list[8],express_pos_list[9],curStepScale)
    -- end
]]
    if timeIndex == 1 then
        nextTargetPos = express_pos_list[1].endPos  --拐角 鳳翔
        beginPos = self:getPosFromLine(express_pos_list[1].beginPos,express_pos_list[1].endPos,curStepScale)
    elseif timeIndex == 2 then
        nextTargetPos = express_pos_list[2].endPos  --風雨亭
        beginPos = self:getPosFromLine(express_pos_list[2].beginPos,express_pos_list[2].endPos,curStepScale)
    elseif timeIndex == 3 then
        nextTargetPos = express_pos_list[3].beginPos
        beginPos = nextTargetPos
    elseif timeIndex == 4 then
        nextTargetPos = express_pos_list[3].endPos  --拐角點(襄陽)
        beginPos = self:getPosFromLine(express_pos_list[3].beginPos,express_pos_list[3].endPos,curStepScale)
    elseif timeIndex == 5 then
        nextTargetPos = express_pos_list[4].endPos
        beginPos = self:getPosFromLine(express_pos_list[4].beginPos,express_pos_list[4].endPos,curStepScale)
    elseif timeIndex == 6 then
        nextTargetPos = express_pos_list[5].endPos
        beginPos = self:getPosFromLine(express_pos_list[5].beginPos,express_pos_list[5].endPos,curStepScale)
    elseif timeIndex == 7 then
        nextTargetPos = express_pos_list[6].beginPos
        beginPos = nextTargetPos
    elseif timeIndex == 8 then
        nextTargetPos = express_pos_list[6].endPos
        beginPos = self:getPosFromLine(express_pos_list[6].beginPos,express_pos_list[6].endPos,curStepScale)
    elseif timeIndex == 9 then
        nextTargetPos = express_pos_list[7].endPos
        beginPos = self:getPosFromLine(express_pos_list[7].beginPos,express_pos_list[7].endPos,curStepScale)
    elseif timeIndex == 10 then
        nextTargetPos = express_pos_list[8].beginPos
        beginPos = nextTargetPos
    elseif timeIndex == 11 then
        nextTargetPos = express_pos_list[8].endPos
        beginPos = self:getPosFromLine(express_pos_list[8].beginPos,express_pos_list[8].endPos,curStepScale)
    end

    nextTargetPos.y = nextTargetPos.y
    beginPos.y = beginPos.y
    return nextTargetPos,beginPos 
end

function ExpressVehicle:onEnterScene()
    
    self.moveDirection = nil --移動方向
    self.isMoving = false --是否在移動


    self:startSchedule()

    -- local act = cc.DelayTime:create(0.01)
    -- local func = cc.CallFunc:create(handler(self,self.onActionUpdate))
    -- local seq = cc.Sequence:create(act,func)
    -- local action = cc.RepeatForever:create(seq)
    -- self:runAction(action)
end

function ExpressVehicle:onActionUpdate()

end

function ExpressVehicle:changeModelAnimation(name)
    self.model:setToSetupPose()
    self.model:setAnimation(0, name , true)
end


function ExpressVehicle:onExitScene()
    self:stopSchedule()
end

function ExpressVehicle:stopSchedule()
    if self.scheduleEntryId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
    end
    self.scheduleEntryId = nil

    -- self.image_flag_bg:removeAllActions()
end

function ExpressVehicle:startSchedule()
    if self.scheduleEntryId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
    end
    self.scheduleEntryId = nil
    self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateMove),0,false)

    -- self.image_flag_bg:removeAllActions()
    -- local act = cc.DelayTime:create(0.01)
    -- local func = cc.CallFunc:create(handler(self,self._updateMove))
    -- local seq = cc.Sequence:create(act,func)
    -- local action = cc.RepeatForever:create(seq)
    -- self.image_flag_bg:runAction(action)
end


--獲取人物狀態
function ExpressVehicle:getRoleIsMove()
    return self.isMoving
end

--獲取當前的位置
function ExpressVehicle:getCurrentPos()
    return self.openInfo.currentPos
end

--獲取人物移動的方向
function ExpressVehicle:getMoveDirection()
    return self.moveDirection
end

--更新移動
function ExpressVehicle:_updateMove(dt)
    self.stepLeftTime = self.stepLeftTime - dt
    if self.stepLeftTime <= 0 then
        if self.timeIndex >= #self.step_time_list then
            self:pause()
            self:stopSchedule()
            self.stepLeftTime = 0
            self.moveSpeed = 0
            self:dispatchViewEvent(cp.getConst("EventConst").ExpressFinished, self.openInfo.vanInfo)
            return
        end
    end
    if self.moveSpeed == 0 and self.stepLeftTime <= 0 then
        self:moveToNextPos()
        return
    end

    local distance = cc.pGetDistance(self.openInfo.currentPos,self.openInfo.nextTargetPos)
    local map_min_distance = cp.getConst("GameConst").map_min_distance
    if distance > map_min_distance*0.1 then  -- 距離小於10表示達到目的地
        --log("ExpressVehicle:_updateMove = " .. tostring(distance))
        if not self.isMoving then 
            self.isMoving = true
            self:TurnDirection()
            self:resume()
        end
        local newFaceDir = {x = self.openInfo.nextTargetPos.x - self.openInfo.currentPos.x , y = self.openInfo.nextTargetPos.y - self.openInfo.currentPos.y }
        newFaceDir = cc.pNormalize(newFaceDir)        
        local offset = { x = newFaceDir.x * self.moveSpeed * dt, y = newFaceDir.y * self.moveSpeed * dt  }
        self.moveDirection = newFaceDir
        self.openInfo.currentPos = cc.p(self.openInfo.currentPos.x + offset.x,self.openInfo.currentPos.y + offset.y)
        self:setPosition(self.openInfo.currentPos)
        
    else
        if self.isMoving then
            self.isMoving = false
           
            local act = cc.DelayTime:create(0.02)
            local func = cc.CallFunc:create(handler(self,self.moveToNextPos))
            local seq = cc.Sequence:create(act,func)
            self.rootNode:runAction(seq)
            
        end
    end
end

function ExpressVehicle:TurnDirection()
    -- local newFaceDir = {x = self.openInfo.nextTargetPos.x - self.openInfo.currentPos.x , y = self.openInfo.nextTargetPos.y - self.openInfo.currentPos.y }
    -- newFaceDir = cc.pNormalize(newFaceDir)
    -- local angle = math.atan2(newFaceDir.y,newFaceDir.x)
    -- local aa = angle >= 0 and ((1.5707963-angle)*180/math.pi) or ((-1.5707963-angle)*180/math.pi)
    
    -- local rotateList = {24,-63,0,-57,10,43,0,43,-44,0,-43}
    local rotateList = {24,-30,0,-33,10,33,0,33,-34,0,-33}
    local aa = 0
    if not (self.timeIndex == 3 or self.timeIndex == 7 or self.timeIndex == 10) then
        aa = rotateList[self.timeIndex]
        self.rootNode:setRotation(aa)
    end
    return aa
end

function ExpressVehicle:moveToNextPos()
    self.timeIndex = self.timeIndex + 1
    if self.timeIndex > #self.step_time_list then
        return
    end
    self.stepLeftTime = self.step_time_list[self.timeIndex]
    self.openInfo.nextTargetPos,self.openInfo.currentPos = self:getCurrentPosByStartStamp(self.timeIndex,self.stepLeftTime)
    
    self:setPosition(cc.p(self.openInfo.currentPos.x, self.openInfo.currentPos.y))
    if self.timeIndex == 3 or self.timeIndex == 7 or self.timeIndex == 10 then
        self:pause()
        self.moveSpeed = 0
    else
        self.moveSpeed = cc.pGetDistance(self.openInfo.currentPos,self.openInfo.nextTargetPos)/self.stepLeftTime
        local aa = self:TurnDirection()
        -- log("moveToNextPos  aa = " .. tostring(aa))
        self:resume()
    end
    if self.isSelfVehicle == true then
        local info = {timeIndex = self.timeIndex}
        self:dispatchViewEvent(cp.getConst("EventConst").onEnterRestErea, info )
    end
end

function ExpressVehicle:pause()    
    self.model:setToSetupPose()
    self.rootNode:setVisible(false)
end

function ExpressVehicle:resume()
    self.model:setToSetupPose()
    self.model:setAnimation(0, "Stand_start" , false)
    self.model:addAnimation(0, "Move", true)
    
    self.rootNode:setVisible(true)
end

-- function ExpressVehicle:setClickRoleCallBack(cb)
--     self.roleClickCallBack = cb
-- end

-- function ExpressVehicle:onRoleClicked(event)
--     -- local sender = event.target
--     if event.name == "ended" then
--         log("click role name=" .. self.openInfo.name)
--         if self.roleClickCallBack ~= nil then
--             self.roleClickCallBack(self)
--         end
--     end
-- end


return ExpressVehicle
