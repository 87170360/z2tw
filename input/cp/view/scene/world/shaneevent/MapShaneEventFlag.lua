--地圖上的善惡事件點(旗幟)

--選擇人物和建築後的彈出選擇和選中效果
local MapShaneEventFlag = class("MapShaneEventFlag", function() return cc.Node:create() end )

function MapShaneEventFlag:create(eventFlagInfo)
    local node = MapShaneEventFlag.new()
    node:init(eventFlagInfo)
    return node
end

--初始化界面，以及設定界面元素標籤
function MapShaneEventFlag:init(eventFlagInfo)
    self.eventFlagInfo = eventFlagInfo

    self:setPosition(cc.p(eventFlagInfo.pos[1],eventFlagInfo.pos[2]))

    -- local layout = ccui.Layout:create()
    -- layout:setAnchorPoint(0.5,0.5)
    -- layout:setPosition(cc.p(0,0))
    -- layout:setContentSize(cc.size(60,80))
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- layout:setBackGroundColor(cc.c3b(0,255,0))
    -- layout:setBackGroundColorOpacity(150)
    -- self:addChild(layout,-1)

    display.loadSpriteFrames("uiplist/ui_map_shane.plist")
    self.image_flag = ccui.ImageView:create()
	self.image_flag:loadTexture("ui_map_shane_module06_map_lose.png",ccui.TextureResType.plistType)
	self.image_flag:setPosition(cc.p(0,0))
	self.image_flag:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self.image_flag)

    -- self.image2 = ccui.ImageView:create() -- 漏斗
	-- self.image2:loadTexture("ui_mapbuild_chakan02.png",ccui.TextureResType.plistType)
	-- self.image2:setPosition(cc.p(118,104))
	-- self.image2:setAnchorPoint(cc.p(0,0.5))
    -- self.image_flag:addChild(self.image2)

    self.text_timer = ccui.Text:create()
    self.text_timer:setString(tostring(self.eventFlagInfo.confId))
    self.text_timer:setFontName("fonts/msyh.ttf")
    self.text_timer:setFontSize(20)
    self.text_timer:setTextColor(cc.c3b(255, 0, 255))
    self.text_timer:setAnchorPoint(cc.p(0.5,0.5))
    self.text_timer:setPosition(cc.p(26,60))
    self.image_flag:addChild(self.text_timer)


    local function onFlagClicked(event)
        if event.name == "ended" then
            if self.btnCallBack ~= nil then
                self.btnCallBack(self.eventFlagInfo)
            end
        end
    end
    self.image_flag:onTouch(onFlagClicked)
    self.image_flag:setTouchEnabled(true)

    self:updateFlag()
end

function MapShaneEventFlag:removeFlag()
    self:_stopUpdate()
    self:removeFromParent()
end

--更新旗子狀態
function MapShaneEventFlag:updateFlag()
    if self.eventFlagInfo.uuid ~= nil then
        local curFlagImage = "ui_map_shane_module06_map_lose.png"
        local list = {"ui_map_shane_module06_map_good01.png", "ui_map_shane_module06_map_good02.png", "ui_map_shane_module06_map_bad01.png", "ui_map_shane_module06_map_bad02.png"}
        self.text_timer:setVisible(false)
        local eventInfo = cp.getUserData("UserMapEvent"):getMapEvent(self.eventFlagInfo.uuid)
        if eventInfo.state == 1 then --未開始
            curFlagImage = list[self.eventFlagInfo.Type]
        elseif eventInfo.state == 2 or eventInfo.state == 3  then  -- 進行中
            if eventInfo.leftTime > 0 then
                curFlagImage = list[self.eventFlagInfo.Type]
                local str =  cp.getUtils("DataUtils").formatTimeRemainEx(eventInfo.leftTime)
                self.text_timer:setString(str)
                self.text_timer:setVisible(true)
                self:_startUpdate()
            else
                curFlagImage = "ui_map_shane_module06_map_win.png"
            end
        elseif eventInfo.state == 4 or eventInfo.state == 5 then -- 完成態(未被打斷過或被打斷過)
            curFlagImage = "ui_map_shane_module06_map_win.png"
        elseif eventInfo.state == 6 then -- 失敗態
            curFlagImage = "ui_map_shane_module06_map_lose.png"
        end
        self.image_flag:loadTexture(curFlagImage, ccui.TextureResType.plistType)
    end
    
end

function MapShaneEventFlag:setClickCallBack(callBack)
    self.btnCallBack = callBack
end

function MapShaneEventFlag:setTimeOutCallBack(callBack)
    self.timeOutCallBack = callBack
end

function MapShaneEventFlag:_startUpdate()
    self:_stopUpdate()
    self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),1,false)

    self.text_timer:setVisible(true)
end

function MapShaneEventFlag:_stopUpdate()
    if self._scheduleID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleID)
    end
    self._scheduleID = nil
    self.text_timer:setVisible(false)
end

function MapShaneEventFlag:_update()
    -- 繼承的類去實現
    if self.text_timer ~= nil and self.eventFlagInfo ~= nil and self.eventFlagInfo.uuid ~= nil then
        local eventInfo = cp.getUserData("UserMapEvent"):getMapEvent(self.eventFlagInfo.uuid)
        if eventInfo.leftTime <= 0 then
            self:_stopUpdate()
            if self.timeOutCallBack ~= nil then
                self.timeOutCallBack(self.eventFlagInfo)
            end
        else
            local str =  cp.getUtils("DataUtils").formatTimeRemainEx(eventInfo.leftTime)
            self.text_timer:setString(str)
        end
    end
end

return MapShaneEventFlag