local BNode = require "cp.view.ui.base.BNode"
local MapRole = class("MapRole",BNode)


function MapRole:create(openInfo)
    local scene = MapRole.new(openInfo)
    return scene
end

--該界面UI註冊的事件偵聽
function MapRole:initListEvent()
    self.listListeners = {
		-- [cp.getConst("EventConst").data_login_game_init_secces] = function(data)
			
		-- end,
    }
end

--初始化界面，以及設定界面元素標籤
function MapRole:onInitView(openInfo)
	openInfo = openInfo or {career = 1, gender = 1, mount=0, currentPos = cc.p(0,0), name = "player", totalGood = 0,totalBad = 0, isNpc = true }

    self.openInfo = openInfo
    
    self.currentPos = openInfo.currentPos --初始位置


    display.loadSpriteFrames("uiplist/ui_common.plist")

    -- display.loadSpriteFrames("maprole/1001.plist")
	-- self.sprite_role = cc.Sprite:create()
	-- self.sprite_role:setTexture("1001-Word_Run_0.png")
	-- self.sprite_role:setPosition(cc.p(0,0))
	-- self:addChild(self.sprite_role)
    -- self.sprite_role:setScale(1)
    
    local model = openInfo.model
	-- 	model = cp.getManager("ViewManager").createNpc(npcid)
	
	if model ~= nil then
        self:addChild(model)
        self.model = model
    end
    
    if self.currentPos ~= nil and self.currentPos.x ~= nil and self.currentPos.y ~= nil then
        self:setPosition(cc.p(self.currentPos.x,self.currentPos.y))
    end

    self.image_flag = ccui.ImageView:create()
	self.image_flag:loadTexture("ui_mapbuild_module6_jianghushi_secw.png",ccui.TextureResType.plistType)
    self.image_flag:setAnchorPoint(cc.p(0.5,0.5))
    self.image_flag:setPosition(cc.p(0,120))
    self.image_flag:setScale(1.2)
    self.image_flag:ignoreContentAdaptWithSize(false)
	self:addChild(self.image_flag,1)

    local flag_sz = self.image_flag:getContentSize()
    self.text_conduct_name = ccui.Text:create()
    self.text_conduct_name:setFontName("fonts/msyh.ttf")
    self.text_conduct_name:setFontSize(14)
    self.text_conduct_name:setAnchorPoint(cc.p(0.5,0.5))
    self.text_conduct_name:setPosition(cc.p(flag_sz.width/2,flag_sz.height/2+2))
    self.image_flag:addChild(self.text_conduct_name,1)

    if openInfo.needShowConductName == false then
        self.image_flag:setVisible(false)
    else
        local conductName = cp.getManager("GDataManager"):getRoleConductName(openInfo.totalGood, openInfo.totalBad)
        local colorIndex = openInfo.totalGood>=openInfo.totalBad and 2 or 5 
        self.text_conduct_name:setString(conductName)        
        
        cp.getManager("ViewManager").setTextQuality(self.text_conduct_name, colorIndex)
    end

    self.text_name = ccui.Text:create()
    self.text_name:setString(self.openInfo.name)
    self.text_name:setFontName("fonts/msyh.ttf")
    self.text_name:setFontSize(20)
    self.text_name:setTextColor(cc.c3b(255, 255, 255))
    self.text_name:setAnchorPoint(cc.p(0.5,0.5))
    self.text_name:setPosition(cc.p(0,0))
    self:addChild(self.text_name,3)
    if openInfo.isHero then
        self.text_name:setPosition(cc.p(0,120))
        openInfo.hero_index = openInfo.hero_index or 3
        openInfo.hero_index = math.max(3,openInfo.hero_index)
        openInfo.hero_index = math.min(6,openInfo.hero_index)
        self.text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[openInfo.hero_index])
        self.text_name:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    elseif openInfo.isGuildNpc then
        self.text_name:setVisible(false)
        self.image_flag:setVisible(true)
        self.image_flag:setScale(1.5)
        self.image_flag:loadTexture("ui_mapbuild_module6_jianghushi_shijiantishi06.png",ccui.TextureResType.plistType)
        
        local lv_pic = {[0] = "ui_mapbuild_module_bangpai_61.png", [1] = "ui_mapbuild_module_bangpai_60.png", [2] = "ui_mapbuild_module_bangpai_59.png"}
        self.image_level = ccui.ImageView:create()
        self.image_level:loadTexture(lv_pic[openInfo.level],ccui.TextureResType.plistType)
        self.image_level:setAnchorPoint(cc.p(0.5,0.5))
        self.image_level:setPosition(cc.p(-75,120))
        self.image_level:setScale(1)
        self.image_level:ignoreContentAdaptWithSize(false)
        self:addChild(self.image_level,2)

        self.text_conduct_name:disableEffect(cc.LabelEffect.OUTLINE)
        self.text_conduct_name:setFontSize(12)
        self.text_conduct_name:setString(self.openInfo.name)
        self.text_conduct_name:setTextColor(cc.c3b(255, 253, 214))
    
    end

    -- self.text_banghui = ccui.Text:create()
    -- self.text_banghui:setString(self.openInfo.banghui)
    -- self.text_banghui:setFontName("fonts/msyh.ttf")
    -- self.text_banghui:setFontSize(24)
    -- self.text_banghui:setTextColor(cc.c3b(255, 0, 0))
    -- self.text_banghui:setAnchorPoint(cc.p(0.5,0.5))
    -- self.text_banghui:setPosition(cc.p(0,50))
    -- self:addChild(self.text_banghui,1)


    --觸摸層
    if openInfo.isNpc then
        local layout = ccui.Layout:create()
        layout:setAnchorPoint(0.5,0.5)
        layout:setPosition(cc.p(0,40))
        layout:setContentSize(cc.size(60,80))
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none) -- solid
        -- layout:setBackGroundColor(cc.c3b(0,0,255))
        -- layout:setBackGroundColorOpacity(150)
        layout:setTouchEnabled(true)
        self:addChild(layout,-1)
        layout:onTouch(handler(self, self.onRoleClicked))
    end
end

function MapRole:onEnterScene()
	self.desPos = nil --目標位置
    self.moveDirection = nil --移動方向
    self.roleIsMoving = false --是否在移動

    self.pointListAI = {} --npc 自動移動的點集

    --首次移動
    self:moveNpc()
end

function MapRole:changeModelAnimation(name)
    -- local frames = display.newFrames("1001-Word_Run_%d.png", 0, 14)
    -- local animation = display.newAnimation(frames, 0.7 / 15) -- 0.5 秒播放 15 楨
    -- display.setAnimationCache("Walk", animation)
   
    -- -- 播放動畫
    -- -- local animation1 = display.getAnimationCache("Walk")
    -- local animate = cc.Animate:create(animation)
    -- local action = cc.RepeatForever:create(animate)
    -- self.sprite_role:runAction(action)

    -- local animation = display.getAnimationCache("Walk")
    -- display.removeAnimationCache("Walk")

    self.model:setToSetupPose()
    self.model:setAnimation(0, name , true)

end


function MapRole:onExitScene()
	self:stopSchedule()
end

function MapRole:stopSchedule()
	if self.scheduleEntryId ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
	end
    self.scheduleEntryId = nil
end

function MapRole:startSchedule()
	if self.scheduleEntryId ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
	end
    self.scheduleEntryId = nil
    self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateMove),0,false)
    
    self:changeModelAnimation("Run")
end

function MapRole:initBeginPos(pt)
    self.currentPos = pt
    self:setPosition(self.currentPos)
end

function MapRole:initEndPos(pt)
    self.desPos = pt
end

--移動到某個點
function MapRole:moveTo(desPt)
    self:initEndPos(desPt)
    self:TurnDirection()
    self:startSchedule()
    -- self.roleIsMoving = true
end

--人物轉方向
function MapRole:TurnDirection()
    local newFaceDir = {x = self.desPos.x - self.currentPos.x, y = self.desPos.y - self.currentPos.y }
    newFaceDir = cc.pNormalize(newFaceDir)
    -- self.sprite_role:setFlippedX(newFaceDir.x < 0)
    self.model:setFlipX(newFaceDir.x < 0 and 1 or 0)
end

function MapRole:startAutoMove()
    self:startSchedule()
end

--獲取人物狀態
function MapRole:getRoleIsMove()
    return self.roleIsMoving
end

--獲取人物當前的位置
function MapRole:getRolePos()
    return self.currentPos
end

--獲取人物移動的方向
function MapRole:getMoveDirection()
    return self.moveDirection
end

--更新移動
function MapRole:_updateMove(dt)
	
    local distance = cc.pGetDistance(self.currentPos,self.desPos)
    local map_min_distance = cp.getConst("GameConst").map_min_distance
    if distance > map_min_distance*0.25 then  -- 距離小於25表示達到目的地
        --log("MapRole:_updateMove = " .. tostring(distance))
        local newFaceDir = {x = self.desPos.x - self.currentPos.x , y = self.desPos.y - self.currentPos.y }
        newFaceDir = cc.pNormalize(newFaceDir)        
        local role_move_speed = cp.getConst("GameConst").role_move_speed
        local offset = { x = newFaceDir.x * role_move_speed * dt, y = newFaceDir.y * role_move_speed * dt  }
        self.moveDirection = newFaceDir
        self.currentPos = cc.p(self.currentPos.x + offset.x,self.currentPos.y + offset.y)
        self:setPosition(self.currentPos)
        if not self.roleIsMoving then 
            self.roleIsMoving = true
        end
        --log("self.currentPos = (%.2f,%.2f)",self.currentPos.x,self.currentPos.y)
    else

        if self.openInfo.isNpc then
            if self.openInfo.needAutoMove then 
                self:npcAction()
            end
		else
			self:stopSchedule()

			cp.getGameData("GameWorldMap"):setValue("roleStayPoint",self.currentPos)
			self.roleIsMoving = false

            self:changeModelAnimation("Stand")

			local data = {role = self, pos = self.currentPos}
			self:dispatchViewEvent(cp.getConst("EventConst").map_role_move_to, data)
		end
    end
	
end

function MapRole:npcAction()
	self:runAction(cc.Sequence:create(
    cc.CallFunc:create(handler(self,self.npcStop)),
    cc.DelayTime:create(10), 
    cc.CallFunc:create(handler(self,self.npcHide)),
    cc.CallFunc:create(handler(self,self.moveToNextPos)), 
	cc.DelayTime:create(2),
	cc.CallFunc:create(handler(self,self.npcShow))
	))
end

function MapRole:moveToNextPos()
    local poslist = cp.getManualConfig("MapEventPos").pos
    local posnum = table.nums(poslist)
    local pos = poslist[math.random(1,posnum)]
    
	self:initEndPos(pos)
    self:TurnDirection()    
	--log("npc set net desPos (%.2f,%.2f)", self.desPos.x, self.desPos.y)
end

function MapRole:npcStop()    
    self:stopSchedule()
    self:changeModelAnimation("Stand")
end

function MapRole:npcHide()
    self:setVisible(false)
end

function MapRole:npcShow()
    self:setVisible(true)
    self:startSchedule() 
end

function MapRole:setClickRoleCallBack(cb)
    self.roleClickCallBack = cb
end

function MapRole:onRoleClicked(event)
    -- local sender = event.target
    if event.name == "ended" then
        log("click role name=" .. self.openInfo.name)
        if self.roleClickCallBack ~= nil then
            self.roleClickCallBack(self)
        end
    end
end


function MapRole:initAI(pointList)
    self.pointListAI = pointList or {}

end

--首次移動
function MapRole:moveNpc()
   
    if self.roleIsMoving == false and self.openInfo.needAutoMove then
        local poslist = cp.getManualConfig("MapEventPos").pos
        local posnum = table.nums(poslist)
        local pos = poslist[math.random(1,posnum)]
        self:moveTo(pos)
    end
    
end

return MapRole
