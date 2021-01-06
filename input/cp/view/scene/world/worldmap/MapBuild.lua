--城市建築或事件點的建築 
local BNode = require "cp.view.ui.base.BNode"
local MapBuild = class("MapBuild",BNode)

function MapBuild:create(openInfo)
	local node = MapBuild.new(openInfo)
	return node
end

function MapBuild:initListEvent()
	self.listListeners = {
	}
end

function MapBuild:onInitView(openInfo)
    self.openInfo = openInfo
    self.openInfo.state = self.openInfo.state or 0
    display.loadSpriteFrames("uiplist/ui_mapbuild.plist")

    --事件狀態提示2(底部方框提示)
    self.Image_event_state_2 = ccui.ImageView:create()
    self.Image_event_state_2:setAnchorPoint(cc.p(0.5,0.5))
    -- self.Image_event_state_2:loadTexture("ui_mapbuild_module6_jianghushi_light07.png",ccui.TextureResType.plistType)
    self:addChild(self.Image_event_state_2,0)
    self.Image_event_state_2:setVisible(false)

    self.Image_build_mark = ccui.ImageView:create()
	self.Image_build_mark:loadTexture("ui_mapbuild_module24_map_dizuo.png",ccui.TextureResType.plistType)
    self.Image_build_mark:setName("Image_build_mark")
	self.Image_build_mark:setPosition(cc.p(0,0))
	self.Image_build_mark:setAnchorPoint(cc.p(0.5,0.5))
    self.Image_event_state_2:addChild(self.Image_build_mark,1)

    self.Image_build = ccui.ImageView:create()
	self.Image_build:loadTexture(self.openInfo.image,ccui.TextureResType.plistType)
    self.Image_build:setName("Image_build")
    self.Image_build:setPosition(cc.p(0,0))
    if self.openInfo.image == "ui_mapbuild_module24_map_city06.png" then
        self.Image_build:setPosition(cc.p(0,15))
    elseif self.openInfo.image == "ui_mapbuild_module24_map_city05.png" then
        self.Image_build:setPosition(cc.p(0,-5))
    end
	self.Image_build:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self.Image_build,2)
    local sz = self.Image_build:getContentSize()

    --事件狀態提示1(頂部提示)
    self.Image_event_state_1 = ccui.ImageView:create()
    self.Image_event_state_1:setPosition(cc.p(0,sz.height/2+15))
    self.Image_event_state_1:setAnchorPoint(cc.p(0.5,0.5))
    self.Image_event_state_1:setName("Image_event_state_1")
    -- self.Image_event_state_1:loadTexture("ui_mapbuild_module6_jianghushi_shijiantishi01.png",ccui.TextureResType.plistType)
    self:addChild(self.Image_event_state_1,3)
    self.Image_event_state_1:setVisible(false)

    

    self.Image_name_bg = ccui.ImageView:create()
	self.Image_name_bg:loadTexture("ui_mapbuild_module6_jianghushi_shijiantishi06.png",ccui.TextureResType.plistType)
	self.Image_name_bg:setPosition(cc.p(sz.width/2,0))
	self.Image_name_bg:setAnchorPoint(cc.p(0.3,0.5))
    self.Image_build:addChild(self.Image_name_bg)

    --建築小圖標
    self.Image_icon = ccui.ImageView:create()
	self.Image_icon:setPosition(cc.p(-8,17.5))
	self.Image_icon:setAnchorPoint(cc.p(0.5,0.5))
    self.Image_name_bg:addChild(self.Image_icon)

    --建築名
    self.Text_name = ccui.Text:create()
    self.Text_name:setFontName("fonts/msyh.ttf")
    self.Text_name:setFontSize(26)
    self.Text_name:setTextColor(cc.c3b(255, 253, 214))
    self.Text_name:setAnchorPoint(cc.p(0.5,0.5))
    self.Text_name:setPositionType(ccui.PositionType.percent)
    self.Text_name:setPositionPercent(cc.p(0.4,0.6))
    self.Image_name_bg:addChild(self.Text_name,1)
    
    
    if self.openInfo.build_type == "city" then
        local bottom_block_pos = {cc.p(12,-18),cc.p(7,-17),cc.p(12,-18), cc.p(12,-18),cc.p(12,-18),cc.p(12,-18)}
        self.Image_event_state_2:setPosition(bottom_block_pos[self.openInfo.cityIndex])
        self.Image_event_state_2:setScale(self.openInfo.cityIndex == 5 and 0.8 or 0.8)
        self.Text_name:setString(self.openInfo.name or "")
        self.Image_icon:loadTexture(self.openInfo.small_icon or "ui_mapbuild_module6_jianghushi_chengchi.png",ccui.TextureResType.plistType)
        self.Image_icon:setScale(1)
        self.Image_build_mark:setVisible(false)
        
        self.Image_city_state = ccui.ImageView:create()
        self.Image_city_state:setPosition(cc.p(0,50))
        self.Image_city_state:setAnchorPoint(cc.p(0.5,0.5))
        self.Image_city_state:setName("Image_city_state")
        self:addChild(self.Image_city_state,3)
        self.Image_city_state:setVisible(false)


    elseif self.openInfo.build_type == "eventpoint" then
        self.Image_event_state_2:setPosition(cc.p(0,-28))
        self.Image_event_state_2:setScale(0.3)
        self.Image_name_bg:setVisible(false)
        self.Image_icon:loadTexture(self.openInfo.small_icon or "ui_mapbuild_module6_jianghushi_chengchi.png",ccui.TextureResType.localType)
        self.Image_icon:setScale(0.8)

        if self.openInfo.ownerName ~= nil and self.openInfo.ownerName ~= "" then
            self.Text_name:setString(self.openInfo.ownerName)
            self.Image_name_bg:setPosition(cc.p(sz.width/2,-25))
            self.Image_name_bg:setVisible(true)
        end
        self.Text_name:setFontSize(18)
        self.Text_name:setPositionPercent(cc.p(0.45,0.55))
    end
  
    local function onTouch(sender, event)
		if event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                if sender:getName() == "Image_build" then
                    local isUnLocked =  self:checkUnLocked()
                    if isUnLocked then
                        if self.btnCallBack1 then
                            self.btnCallBack1(self)
                        end
                    else
                        cp.getManager("ViewManager").gameTip("需要" .. tostring(self.openInfo.open_hierarchy) .. "階才能解鎖！")
                    end
                elseif sender:getName() == "Image_event_state_1" then
                    if self.btnCallBack2 then
                        self.btnCallBack2(self)
                    end
                end
            end
        end
	end

	self.Image_build:setTouchEnabled(true) 
    self.Image_build:addTouchEventListener(onTouch)
  
    
    -- self.Image_event_state_1:setTouchEnabled(true) 
    -- self.Image_event_state_1:addTouchEventListener(onTouch)
    
    self:setOpenState()
    
    self:setEventState(self.openInfo.state,self.openInfo.ownerName)
end

function MapBuild:setEventState(state,ownerName)
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")

    -- 1:等待開始  2:進行中  3:完成  4:打斷
    local client_state = state  --0：沒有任務可接或未解鎖 1：解鎖有任務可接 2：善任務進行中 3：惡任務進行中 4：任務完成 5：任務失敗
    if state <= 1 then
        client_state = self:checkUnLocked() and (self.openInfo.confId ~= nil) and 1 or 0
    elseif state == 2 then
        client_state = ownerName == majorRole.name and 2 or 3
    elseif state == 3 then
        client_state = 4
    elseif state == 4 then
        client_state = 5
    end
    display.loadSpriteFrames("uiplist/ui_mapbuild.plist")
    local imageStateSmall = {
        [1] = "ui_mapbuild_module6_jianghushi_shijiantishi01.png",--有新任務
        [2] = "ui_mapbuild_module6_jianghushi_shijiantishi03.png",--善事件進行中
        [3] = "ui_mapbuild_module6_jianghushi_shijiantishi04.png",--惡事件進行中
        [4] = "ui_mapbuild_module6_jianghushi_shijiantishi02.png",--已完成可領取
        [5] = "ui_mapbuild_module6_jianghushi_shijiantishi08.png",--事件失敗

    }
    local imageSelect = {
        [1] = "ui_mapbuild_module6_jianghushi_light07.png",--沒有事件或有可接事件
        [2] = "ui_mapbuild_module6_jianghushi_light03.png",--進行善事件中
        [3] = "ui_mapbuild_module6_jianghushi_light06.png",--進行惡事件中
        [4] = "ui_mapbuild_module6_jianghushi_light05.png",--事件成功
        [5] = "ui_mapbuild_module6_jianghushi_light04.png",--事件失敗
    }

    if client_state > 0 then
        
        -- self.Image_event_state_2:loadTexture(imageSelect[client_state],ccui.TextureResType.plistType)
        local idx = 1
        if self.openInfo.Process == 1 and ownerName then
            idx = ownerName == majorRole.name and 2 or 3
        end
        self.Image_event_state_2:loadTexture(imageSelect[idx],ccui.TextureResType.plistType)
        self.Image_event_state_1:loadTexture(imageStateSmall[client_state],ccui.TextureResType.plistType)
        
    else
        self.Image_event_state_2:loadTexture(imageSelect[1],ccui.TextureResType.plistType) --沒有事件時
    end
    self.Image_event_state_1:setVisible(client_state >= 1)
    self.Image_name_bg:setVisible(self.openInfo.build_type == "city" or client_state > 1)
    self.Image_event_state_2:setVisible(true) --client_state > 1)
 
    if self.openInfo.build_type == "eventpoint" then
        local sz1 = self.Image_event_state_2:getContentSize()
        self.Image_build_mark:setPosition(cc.p(sz1.width/2,sz1.height/2))
    elseif self.openInfo.build_type == "city" then
        self.Image_event_state_2:setVisible(false)
    end
    if ownerName and self.openInfo.build_type ~= "city" then
        self.Text_name:setString(ownerName or "")
    end
    
end

function MapBuild:setSelected(isSelected)
    self.Image_event_state_2:stopAllActions()
    display.loadSpriteFrames("uiplist/ui_mapbuild.plist")
    --播放選中特效
    if isSelected  then
        local opacity = self.Image_event_state_2:getOpacity()
        local seq = cc.Sequence:create(cc.FadeTo:create(1,0),cc.FadeTo:create(1,opacity))
        local repeatBlink = cc.RepeatForever:create(seq)
        self.Image_event_state_2:runAction(repeatBlink)
        self.Image_event_state_2:setVisible(true)
    else
        self.Image_event_state_2:setOpacity(255)
        -- if self.openInfo.state <= 1 then
            -- self.Image_event_state_2:setVisible(false)
        -- end
    end
end

function MapBuild:checkUnLocked()
    if self.openInfo.build_type == "city" then
        return true
    end
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    return self.openInfo.open_hierarchy <= majorRole.hierarchy 
end

function MapBuild:setOpenState()
    local isUnLocked =  self:checkUnLocked()
    
    if isUnLocked then
        display.loadSpriteFrames("uiplist/ui_mapbuild.plist")
    end
    self.Image_event_state_2:setVisible(isUnLocked)
    
    self.Image_event_state_1:setVisible(isUnLocked)
    -- self.Image_event_state_1:setTouchEnabled(isUnLocked) -- 解鎖並且有事件可接的時候才能觸摸

end

function MapBuild:setBuildClickCallBack(callBack1,callBack2)
    self.btnCallBack1 = callBack1
    self.btnCallBack2 = callBack2
end

-- state 0無人佔領 1有人佔領 2 被攻打中
function MapBuild:refreshCityState(state)
    if self.cityStateAnim then
        self.cityStateAnim:removeFromParent()
        self.cityStateAnim = nil
    end
    if state == 0 then
        self.Image_city_state:setVisible(false) 
    else
        self.Image_city_state:setVisible(state == 2)
        local pic = state == 1 and "ui_mapbuild_module6_jianghushi_yizhanling.png" or "ui_mapbuild_module6_jianghushi_zhengduozhong.png"
        self.Image_city_state:loadTexture(pic, ccui.TextureResType.plistType)

        self.Image_city_state:setPosition(state == 1 and cc.p(0,50) or cc.p(0,-40))

        local animName = state == 1 and "zhanling" or "zhanling_gj"
        local cityStateAnim = cp.getManager("ViewManager").createSpineEffect(animName)
        cityStateAnim:setAnimation(0, animName, true)
        self:addChild(cityStateAnim,4)
        cityStateAnim:setPosition(state == 1 and cc.p(0,-20) or cc.p(0,-50))
        self.cityStateAnim = cityStateAnim

    end
end

return MapBuild