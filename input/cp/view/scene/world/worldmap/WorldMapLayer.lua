--世界地圖場景(善惡事等)，點擊主界面中 【出城】 按鈕後進入
local BLayer = require "cp.view.ui.base.BLayer"
local WorldMapLayer = class("WorldMapLayer",BLayer)

function WorldMapLayer:create(openInfo)
    local layer = WorldMapLayer.new(openInfo)
    return layer
end


--該界面UI註冊的事件偵聽
function WorldMapLayer:initListEvent()
    self.listListeners = {

        --地圖上玩家移動到某個點後
        [cp.getConst("EventConst").map_role_move_to] = function(evt)
           self:onRoleMoveTo(evt)
        end,

        --隨機npc(玩家)
        [cp.getConst("EventConst").IdleStaffRsp] = function(data)	
             self:initOtherRole()
        end,
        
        --江湖大俠
        [cp.getConst("EventConst").GetHeroRsp] = function(data)	
            self:initHeroes()
        end,

        --請求善惡事件列表返回
        [cp.getConst("EventConst").GetConductRsp] = function(data)
            
            self:showMapEventList(data)
        end,
        
        --請求掛機善惡事件返回
        [cp.getConst("EventConst").StartHangConductRsp] = function(data)
            --更新建築狀態
            self:refreshBuildState(data)
        end,

        --請求戰鬥善惡事件返回
        [cp.getConst("EventConst").StartFightConductRsp] = function(data)
            self:onStartFightConduct(data)
        end,    

        --打斷事件返回
        [cp.getConst("EventConst").BreakHangConductRsp] = function(data)
            self:onBreakConduct(data)
        end,

        --更新善惡事件 
        [cp.getConst("EventConst").UpdateHangConductRsp] = function(data)
     
            for uuid,info in pairs(data) do
                self:refreshBuildState(info)
            end
        end,

        --停止善惡事件返回
        [cp.getConst("EventConst").StopConductRsp] = function(data)
            -- dump(data)
            self:onStopConductCallBack(data)
        end,

        --新手指引自動接任務
        [cp.getConst("EventConst").OnNewGuideAutoAcceptEvent] = function(data)
            if data.confId > 0 then
                for j,mapBuildItem in pairs(self.MapBuildList) do
                    if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.build_type == "eventpoint" and mapBuildItem.openInfo.confId == data.confId then
                        
                        self:checkBuildEvent(mapBuildItem)
                    end
                end
            end
        end,

        --點擊任務自動尋路
        [cp.getConst("EventConst").NavigateEvent] = function(data)
            if data.uuid ~= "" and data.pos ~= nil then
                local buildItem = self:getBuildItemByPos(tonumber(data.pos))
                if buildItem then
                    self:onEventBuildClicked(buildItem)
                end
            else
                if data.confId > 0 then
                    for j,mapBuildItem in pairs(self.MapBuildList) do
                        if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.build_type == "eventpoint" and mapBuildItem.openInfo.confId == data.confId then
                            self:onEventBuildClicked(mapBuildItem)
                        end
                    end
                end
            end
        end,

        --獲取各個城市的狀態
        [cp.getConst("EventConst").GetFightCityStateRsp] = function(data)	
            self:refreshCityState(data)
        end,

		--查看玩家訊息返回
		[cp.getConst("EventConst").ViewPlayerRsp] = function(data)
			local function closeCallBack(btnName)
                log("close viewplayer.")
                if "Button_QieCuo" == btnName then
                    log("挑戰玩家 name=" .. data.roleAtt.name)

                    local sins_max = cp.getManager("ConfigManager").getItemByKey("Other", "sins_max_per_day"):getValue("IntValue")
                    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
                    if major_roleAtt.sins and major_roleAtt.sins >= sins_max then
                        cp.getManager("ViewManager").gameTip("當前罪惡值已達到" .. tostring(sins_max) .. "，不允許進行比試")
                        return
                    end
            
            
                    local function confirmFunc()
                        self.fightInfo = {name = data.roleAtt.name}
                        local req = {}
                        req.uuid = data.roleAtt.account
                        self:doSendSocket(cp.getConst("ProtoConst").StartFightIdleStaffReq, req)
                    end
            
                    local function cancleFunc()
                    end
                    
                    local content = "比試會增加5點罪惡值，是否繼續比試？"
                    cp.getManager("ViewManager").showGameMessageBox("系統提示",content,2,confirmFunc,cancelFunc)

                end
			end
			cp.getManager("ViewManager").showOtherRoleInfo(data,closeCallBack)
		end,

		--挑戰吃瓜群眾訊息返回
		[cp.getConst("EventConst").StartFightIdleStaffRsp] = function(data)
            dump(data)
            if self.MapObjectSelect then
                self.MapObjectSelect:removeFromParent()
                self.MapObjectSelect = nil
            end
            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
            -- local rewardList = {}
			--cp.getUserData("UserCombat"):setCombatReward(rewardList)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
        end,
        
        --挑戰大俠
        [cp.getConst("EventConst").StartFightHeroRsp] = function(data)
            self:gotoFightHero(data)
        end,
        
        --結交大俠
        [cp.getConst("EventConst").BribeHeroRsp] = function(data)
            self:gotoBribeHero(data)
        end,
        
        --一鍵結交所有大俠
        [cp.getConst("EventConst").BribeAllHeroRsp] = function(data)
            self:onBribeAllHero(data)
        end,

        --他人幫你擊敗大俠
        [cp.getConst("EventConst").OtherDefeatRsp] = function(data)
            self:onOtherDefeatHero(data)
        end,

        --獲取自己的鏢車列表
        [cp.getConst("EventConst").GetSelfVanRsp] = function(data)
			self:getSelfVan(data)
        end,

        --獲取其他人的鏢車列表
        [cp.getConst("EventConst").GetAllVanRsp] = function(data)
			self:getAllVan(data)
        end,
        
        --開始押鏢，顯示鏢車
        [cp.getConst("EventConst").StartVanRsp] = function(data)
            dump(data)
            local idx = data.vanIndex + 1
            self:onStartVanCallBack(idx)
        end,

        --押鏢結束
        [cp.getConst("EventConst").ExpressFinished] = function(evt)
   
            if evt.uuid ~= nil and self.vanList[evt.uuid] ~= nil then
                self.vanList[evt.uuid]:removeFromParent()
                self.vanList[evt.uuid] = nil
            end
        end,

        --押鏢休息區顯示頭像
        [cp.getConst("EventConst").onEnterRestErea] = function(evt)
            self:updateVanHeadState(evt)
        end,


        --獲取幫派npc列表
        [cp.getConst("EventConst").GetGuildWantedListRsp] = function(data)
			self:initGuildWantedNpc(data)
        end,
        
        --幫派npc緝拿
        [cp.getConst("EventConst").FightGuildWantedRsp] = function(data)
            if data.npc > 0 then
                for i=table.nums(self.guildNpcList),1,-1 do
                    if self.guildNpcList[i] and self.guildNpcList[i].openInfo and self.guildNpcList[i].openInfo.id == data.npc then
                        self.guildNpcList[i]:removeFromParent()
                        table.remove(self.guildNpcList,i)
                        break
                    end
                end
            end

            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
            -- local rewardList = {}
            -- cp.getUserData("UserCombat"):setCombatReward(rewardList)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
        end,
        
        --自動打開界面
		-- [cp.getConst("EventConst").on_auto_open_ui] = function(evt)
		-- 	if evt.name == cp.getConst("SceneConst").MODULE_WorldMap then
		-- 		if evt.auto_open_name == "ExpressEscort" then
		-- 			self:onExpressBuildClicked(self["Image_express_1"])
		-- 		end
		-- 	end
		-- end,
		["ShowCityOwnerRsp"] = function(data)
            local layer = require("cp.view.scene.guild.GuildCityInfoLayer"):create(data.city, data.id, data.owner)
            self:addChild(layer, 100)
        end,

        [cp.getConst("EventConst").ChangeLeadRsp] = function(data)
            self:checkNeedExpressGuide()
        end,
        
        
    }

end

--初始化界面，以及設定界面元素標籤
function WorldMapLayer:onInitView(openInfo)
 
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_worldmap/worldmap.csb") --大地圖
	self:addChild(self.rootView)

	local childConfig = {
		["ScrollView_bg"] = {name = "ScrollView_bg"},
        ["ScrollView_bg.Panel_all"] = {name = "Panel_all"},
        ["ScrollView_bg.Panel_all.Node_city"] = {name = "Node_city"},
        ["ScrollView_bg.Panel_all.Node_event"] = {name = "Node_event"},
        
        ["ScrollView_bg.Panel_all.Node_convoy"] = {name = "Node_convoy"},
        ["ScrollView_bg.Panel_all.Node_convoy.Node_van"] = {name = "Node_van"}, --鏢車
        ["ScrollView_bg.Panel_all.Node_convoy.Node_express"] = {name = "Node_express"}, --鏢局，快遞點
        ["ScrollView_bg.Panel_all.Node_convoy.Node_express.Image_express_1"] = {name = "Image_express_1",click = "onExpressBuildClicked"},
        ["ScrollView_bg.Panel_all.Node_convoy.Node_express.Image_express_2"] = {name = "Image_express_2",click = "onExpressBuildClicked"},
        ["ScrollView_bg.Panel_all.Node_convoy.Node_express.Image_express_3"] = {name = "Image_express_3",click = "onExpressBuildClicked"},
        ["ScrollView_bg.Panel_all.Node_convoy.Node_express.Image_express_4"] = {name = "Image_express_4",click = "onExpressBuildClicked"},

        ["ScrollView_bg.Panel_all.Node_road_line"] = {name = "Node_road_line" },
        ["ScrollView_bg.Panel_all.Node_role"] = {name = "Node_role" },
        ["ScrollView_bg.Panel_all.Node_ui"] = {name = "Node_ui" },
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	

    self.rootView:setContentSize(display.size)
    local scale = display.height / 1280
    self["Panel_all"]:setScale(scale,scale)
    local newWidth = self.Panel_all:getContentSize().width * scale
    self["ScrollView_bg"]:setInnerContainerSize(cc.size(newWidth,display.height))
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self["rootView"])


    self["ScrollView_bg"]:setTouchEnabled(true)
    self["ScrollView_bg"]:onTouch(function(event)
        if event.name == "ended" then
            local distance = cc.pGetDistance(self.beginTouchPos, cc.p(event.x,event.y))
            if distance > 30 then -- 大於30視為點擊後移動
                return
            end
            if self.MapObjectSelect then
                self.MapObjectSelect:removeFromParent()
                self.MapObjectSelect = nil
            end
            -- log(string.format("OnTouch ended : pt=(%.1f,%.1f)",event.x, event.y))
            self.beginTouchPos = cc.p(0,0)
        elseif event.name == "moved" then
        elseif event.name == "began" then
            self.beginTouchPos = cc.p(event.x,event.y) 
        end
    end)

    local RiverMainLayer = require("cp.view.scene.world.shaneevent.RiverMainLayer"):create()
    self:addChild(RiverMainLayer,1)

    self:initMapData()
end

function WorldMapLayer:initMapData()
    self.defaultPos = cp.getManualConfig("MapEventPos").pos[51] --一階城市點
    local scale = display.height / 1280
    local newWidth = self.Panel_all:getContentSize().width * scale
    self.mapSize = cc.size(newWidth,display.height)
    self.visibleSize = cc.Director:getInstance():getVisibleSize()


    self.MapBuildList = {}
    self.curSelectedBuild = nil
    self.heroNpcList = {}
    self.guildNpcList = {}
    self.Node_role:removeAllChildren()
    self:initCityBuild()

    self:initRoleStayPoint()
    self:initSelfRole()

    self:initExpressPosList()
        
    --請求npc列表(其他玩家)
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").IdleStaffReq, req)

    --請求npc列表(大俠)
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GetHeroReq, req)
    
    --請求善惡事件列表
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GetConductReq, req)

    --請求自己的鏢車數據
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GetSelfVanReq, req)

    -- --請求他人的鏢車數據
    -- local req = {}
    -- self:doSendSocket(cp.getConst("ProtoConst").GetAllVanReq, req)

    --請求幫派npc列表
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GetGuildWantedListReq,req)
end

function WorldMapLayer:loading()
	self.loadingPercent = self.loadingPercent + 10
	log("loading !!" .. self.loadingPercent)
	self.loadingLayer:setLoadingPercent(self.loadingPercent)
end

function WorldMapLayer:hideLoading()
    cp.getManager("PopupManager"):removePopup(self.loadingLayer, false)
end

function WorldMapLayer:showLoading()
    if not self.loadingLayer then
        local loadingLayer = require "cp.view.scene.loading.LoadingLayer"
        self.loadingLayer = loadingLayer:create()       
    end  
    cp.getManager("PopupManager"):addPopup(self.loadingLayer, false)

	self.loadingPercent = 10

	--載入進度條， 關閉loading
    self:runAction(cc.Sequence:create(
	cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.loading)), cc.DelayTime:create(0.08)), 10),
	cc.DelayTime:create(0.1),
	cc.CallFunc:create(handler(self,self.hideLoading))))
end

--進入場景後的遊戲邏輯
function WorldMapLayer:onEnterScene()
	--self:showLoading()

    cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_map,true)

    if self.MapObjectSelect ~= nil then
        self.MapObjectSelect:removeFromParent()
        self.MapObjectSelect = nil
    end

    --定時器，請求更新其他人的鏢車數據
    self.Panel_all:stopAllActions()
    self.Panel_all:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GetAllVanReq, req)
        cp.getUserData("UserGuild"):updateFightCityState()

        self:checkVanHolidayTime()
    end), cc.DelayTime:create(60))))

    self:updateSelfVanPos()


    --先檢測一次，然後每隔60s檢測一下。
    self:checkVanHolidayTime()

    self:checkNeedExpressGuide()

end

function WorldMapLayer:onExitScene()
    self:stopAutoMovePlayer()
    self.Panel_all:stopAllActions()
    self.rootView:stopAllActions()
    self:stopAllActions()
end

function WorldMapLayer:removeAllRole()
    -- self.Node_role:removeAllChildren()
end

--創建城市
function WorldMapLayer:initCityBuild()

    self.cityInfoConfig = {
        [1] = {pos=cc.p(411,523), name="成都",image = "ui_mapbuild_module24_map_city01.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=1},
        [2] = {pos=cc.p(978,317), name="鳳翔",image = "ui_mapbuild_module24_map_city02.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=2},
        [3] = {pos=cc.p(1450,934), name="襄陽",image = "ui_mapbuild_module24_map_city03.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=3},
        [4] = {pos=cc.p(2066,792), name="開封",image = "ui_mapbuild_module24_map_city04.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=4},
        [5] = {pos=cc.p(2716,307), name="臨安",image = "ui_mapbuild_module24_map_city05.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=5},
        [6] = {pos=cc.p(3278,819), name="揚州",image = "ui_mapbuild_module24_map_city06.png",small_icon="ui_mapbuild_module6_jianghushi_chengchi.png",state=0,open_hierarchy=6},
    }

    self.Node_city:removeAllChildren()
    for i=1,#self.cityInfoConfig do
        local openInfo = self.cityInfoConfig[i]
        openInfo.build_type = "city" -- type : "city","eventpoint","holdpoint"
        openInfo.cityIndex = i
        openInfo.pos_real = self.cityInfoConfig[i].pos
        openInfo.pos = 50+i
        local MapBuild = require("cp.view.scene.world.worldmap.MapBuild"):create(openInfo)
        MapBuild:setTag(i)
        MapBuild:setPosition(openInfo.pos_real)
        MapBuild:setBuildClickCallBack(handler(self,self.onCityClicked),handler(self,self.onCityStateClicked))
        self.Node_city:addChild(MapBuild)
        self.MapBuildList[i] = MapBuild
    end

end


function WorldMapLayer:initRoleStayPoint()
    local ptStr = cp.getManager("LocalDataManager"):getUserValue("worldmap","roleStayPoint","")
    if ptStr == "" then
        local luoyangPos = self.defaultPos
        ptStr = tostring(luoyangPos.x) .. "#".. tostring(luoyangPos.y) -- 第一個點為洛陽
    end
    if ptStr ~= "" then
        local ptTable = string.split(ptStr,"#")
        local x,y = tonumber(ptTable[1]), tonumber(ptTable[2])
        x = math.max(x,0)
        x = math.min(x,self.mapSize.width)
        y = math.max(y,0)
        y = math.min(y,self.mapSize.height)
        local roleStayPoint = cc.p(x, y)
        cp.getGameData("GameWorldMap"):setValue("roleStayPoint",roleStayPoint)
    end
end

function WorldMapLayer:saveRoleStayPoint()
    local roleStayPoint = cp.getGameData("GameWorldMap"):getValue("roleStayPoint")
    local x = math.floor(roleStayPoint.x)
    local y = math.floor(roleStayPoint.y)
    local str = tostring(x) .. "#" .. tostring(y)
    cp.getManager("LocalDataManager"):setUserValue("worldmap","roleStayPoint",str)
end

--獲取武器
function WorldMapLayer:getWeapon(career)
	local weaponList = {[0] = "club", [1] = "blade", [2] = "club", [3] = "blade", [4] = "knife", [5] = "blade", [6] = "knife", [7] = "dagger"}
	return weaponList[career]
end

--創建一個NPC(其他玩家)
function WorldMapLayer:createNpc(npcInfo, birthPos)
    if npcInfo == nil or next(npcInfo) == nil then
        return
    end
    local openInfo = npcInfo
	openInfo.currentPos = birthPos or cc.p(0,0)
    openInfo.isNpc = true
    openInfo.needAutoMove = true
	openInfo.weapon = self:getWeapon(npcInfo.career)
    -- openInfo.model = self:createModel(npcInfo.career, npcInfo.gender,npcInfo.fashionID)
    openInfo.model = cp.getManager("ViewManager").createRoleModel(npcInfo.career, npcInfo.gender,npcInfo.fashionID,0.37)
	openInfo.needShowConductName = true
	local role = require("cp.view.scene.world.worldmap.MapRole"):create(openInfo)
	
    local sz = self.Panel_all:getContentSize()
	role:initBeginPos(birthPos)
	role:setClickRoleCallBack(handler(self,self.selectMapRole))
	self.Node_role:addChild(role)
	return role
end

function WorldMapLayer:initHeroes()
    local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
    self.hero_array = {}
    for uuid, info in pairs(hero_list) do
        if info and next(info) and info.state == 0  then
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", info.ID or 0)
            if cfgItem then
                info.name = cfgItem:getValue("Name")
                table.insert(self.hero_array,info)
            end
        end
    end
    local num = table.nums(self.hero_array)
    self.hero_create_index = num > 0 and 1 or nil
    if num > 0 then
        self.Node_role:runAction(		
            cc.Sequence:create(
                -- cc.DelayTime:create(2),
                cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.createHeroNpc)), cc.DelayTime:create(0.03)), num)
            )
        )
    end
end

--創建一個大俠(其他玩家或npc)
function WorldMapLayer:createHeroNpc()
    local npcInfo = self.hero_array[self.hero_create_index]
   
    local openInfo = npcInfo
	openInfo.currentPos = cc.p(npcInfo.x,npcInfo.y) or cp.getManualConfig("MapEventPos").npc_pos[#self.heroNpcList + 1]
    openInfo.isNpc = true
    openInfo.needAutoMove = false
    openInfo.needShowConductName = false
    openInfo.isHero = true
    local _,i,_ = cp.getManager("GDataManager"):getHeroInfoByID(npcInfo.ID)
    openInfo.hero_index = i + 2 -- 控制名字的顏色 (藍，紫，金，紅)
    openInfo.model = cp.getManager("ViewManager").createNpc(npcInfo.ID,0.4)
	
	local role = require("cp.view.scene.world.worldmap.MapRole"):create(openInfo)
	
	role:initBeginPos(openInfo.currentPos)
	role:setClickRoleCallBack(handler(self,self.selectMapHero))
    self.Node_role:addChild(role)
    table.insert(self.heroNpcList, role)

    self.hero_create_index = self.hero_create_index + 1
end


function WorldMapLayer:createOneNpc()
	local npcInfo = self.createList[self.createIdx]
	local birthPos = self:getBirthPos()
	self["role_list"][self.createIdx] = self:createNpc(npcInfo, birthPos)
	self.createIdx = self.createIdx + 1
end

--獲取出生點
function WorldMapLayer:getBirthPos()
	local roleStayPoint = cp.getGameData("GameWorldMap"):getValue("roleStayPoint")
	if self.createIdx <= self.createFirst then
		--主角可視區域隨機
		return cc.p(math.random(roleStayPoint.x - 360, roleStayPoint.x + 360), math.random(0, 1080))
	else
		--主角可視區外隨機
		if self.createIdx % 2 == 0 then
			return cc.p(math.random(roleStayPoint.x - 1440, roleStayPoint.x - 460), math.random(0, 1080))
		else
			return cc.p(math.random(roleStayPoint.x + 460, roleStayPoint.x + 1440), math.random(0, 1080))
		end
	end
end

--其他玩家和npc
function WorldMapLayer:initOtherRole()
    local npc_list = cp.getUserData("UserNpc"):getValue("npc_list")
    if table.nums(npc_list) == 0 then
        return
    end
    --其他玩家或npc
    self["role_list"] = {} 

	self.createIdx = 1
	self.createList = {}
	self.createPos = {}
	self.createFirst = 5
	local idx = 1
    for _, npcInfo in pairs(npc_list) do
        self.createList[idx] = npcInfo
        idx = idx + 1
	end

	local npcnum = table.nums(npc_list)

    self:runAction(		
		cc.Sequence:create(
			cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.createOneNpc)), cc.DelayTime:create(0.03)), self.createFirst),
			--cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.createOneNpc)), cc.DelayTime:create(4.5)), npcnum - self.createFirst)
			cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.createOneNpc)), cc.DelayTime:create(0.03)), npcnum - self.createFirst)
			)
        )
end

--玩家自己
function WorldMapLayer:initSelfRole()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local roleStayPoint = cp.getGameData("GameWorldMap"):getValue("roleStayPoint")
    if roleStayPoint == nil or roleStayPoint == cc.p(0,0) then
        roleStayPoint = self.defaultPos
        cp.getGameData("GameWorldMap"):setValue("roleStayPoint", roleStayPoint)
    end
    local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
    local openInfo =  {
		career = majorRole.career,
		gender = majorRole.gender,
		mount=majorRole.mount,
		name = majorRole.name, 
		currentPos = roleStayPoint,
		isNpc = false,
		weapon = self:getWeapon(majorRole.career),
        -- model = self:createModel(majorRole.career, majorRole.gender,fashion_data.use),
        model = cp.getManager("ViewManager").createRoleModel(majorRole.career, majorRole.gender,fashion_data.use,0.37),
        totalGood = majorRole.totalGood,
        totalBad = majorRole.totalBad,
        needShowConductName = true,
	}

    local role = require("cp.view.scene.world.worldmap.MapRole"):create(openInfo)
    self.Node_role:addChild(role,1)
    self.player = role

    self:checkRoleInScreen()
    
end

function WorldMapLayer:onCityClicked(buildItem)
    local cityInfo = buildItem.openInfo
    dump(cityInfo.name)

    local req = {}
    req.city = buildItem.openInfo.cityIndex
    self:doSendSocket(cp.getConst("ProtoConst").ShowCityOwnerReq, req)
    --設置選中city效果，並彈出city的操作界面
    if self.curSelectedBuild then
        if self.curSelectedBuild ~= buildItem then
            self.curSelectedBuild:setSelected(false)
            buildItem:setSelected(true)
            self.curSelectedBuild = buildItem
        end
    else
        self.curSelectedBuild = buildItem
        buildItem:setSelected(true)
    end
    
    --彈出佔領界面


    
    --[[
    local function moveFinishedCallBack()
        --移動到目的地後打開操作界面
    end

    self.player:moveTo(cityInfo.pos, moveFinishedCallBack)
    self.rootView:runAction( cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create( handler(self,self.startAutoMovePlayer)) ) )
    
      --判斷role當前是否在屏幕內，不在則移動到屏幕內
    self:checkRoleInScreen()
    self:drawWalkPath(self.player:getRolePos(), cityInfo.pos)
    ]]
end

function WorldMapLayer:drawWalkPath(start, target)

	local distance = cc.pGetDistance(start, target)

	if self.walkPath == nil then
		local layout = ccui.Layout:create()
		--layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
		layout:setBackGroundColor(cc.c4b(255,255,255,128))
		layout:setTouchEnabled(false)
		layout:setAnchorPoint(0,0.5)
		self.walkPath = layout
		self.Node_road_line:addChild(layout)
	end

	self.walkPath:removeAllChildren()

	local angle = -getAngleByPos(start, target)
	self.walkPath:setPosition(start)
	self.walkPath:setContentSize(cc.size(distance, 20))
	self.walkPath:setRotation(angle)

	self:drawWalkArrow()
end

function WorldMapLayer:drawWalkArrow()
	self.walkArrow = {}
	local len = self.walkPath:getContentSize().width 
	local drawLen = 0
	while drawLen < len do
		local image = ccui.ImageView:create("ui_mapbuild_module6_jianghushi_luxian.png", ccui.TextureResType.plistType)
		local size = image:getContentSize()
		drawLen = drawLen + size.width
		image:setPosition(cc.p(drawLen, 10))
        image:setAnchorPoint(cc.p(0.5, 0.5))
		self.walkPath:addChild(image)
		table.insert(self.walkArrow, {
			image = image,
			pos = self:getArrowWorldPos(image),
		})
	end
end

function WorldMapLayer:getArrowWorldPos(arrow)
	  local p1 = arrow:convertToWorldSpace(cc.p(arrow:getAnchorPointInPoints()))
	  local p2 = self.Panel_all:convertToNodeSpace(p1)
	  return p2
end

function WorldMapLayer:onCityStateClicked(cityInfo)

end

function WorldMapLayer:selectMapHero(maprole)
    log("WorldMapLayer:selectMapRole name=" ..  maprole.openInfo.name)
    -- 打開挑戰界面

    local type,id,level = cp.getConst("CombatConst").CombatType_Shane,maprole.openInfo.ID,0  
    local function closeCallBack(retStr)
        if retStr == "Shane_TiaoZhan" then
            log("挑戰大俠 name=" .. maprole.openInfo.name)
            local fightInfo = {name = maprole.openInfo.name} 
            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(fightInfo)
            local req = {}
            req.uuid = maprole.openInfo.uuid
            self:doSendSocket(cp.getConst("ProtoConst").StartFightHeroReq, req)
        elseif retStr == "JieJiao" then
            log("收買大俠 name=" .. maprole.openInfo.name)
            local req = {}
            req.uuid = maprole.openInfo.uuid
            self:doSendSocket(cp.getConst("ProtoConst").BribeHeroReq, req)
        elseif retStr == "CallHelp" then
            --求助
            local curTime = cp.getManager("TimerManager"):getTime()
            local callhelp_uuid = cp.getUserData("UserMapEvent"):getValue("callhelp_uuid")
            if callhelp_uuid and callhelp_uuid[maprole.openInfo.uuid] then
                
                if math.abs(tonumber(callhelp_uuid[maprole.openInfo.uuid]) - curTime) < 30*60 then
                    cp.getManager("ViewManager").gameTip("你已向江湖同道發起求助。")
                    return
                end
            else
                callhelp_uuid = callhelp_uuid or {}
                callhelp_uuid[maprole.openInfo.uuid] = curTime
                 -- local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
                local req = {}
                req.uuid = maprole.openInfo.uuid
                -- req.zoneID = serverinfo.id
                self:doSendSocket(cp.getConst("ProtoConst").InviteHeroReq, req)
            end
           
        elseif retStr == "close" then

            cp.getManager("ViewManager").removeChallengeStory()
        end
        
    end
    cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack)

end

function WorldMapLayer:selectMapRole(maprole)
    log("WorldMapLayer:selectMapRole name=" ..  maprole.openInfo.name)
    
    if self.MapObjectSelect ~= nil then
        self.MapObjectSelect:removeFromParent()
        self.MapObjectSelect = nil
    end

    local MapObjectSelect = require("cp.view.scene.world.worldmap.MapObjectSelect"):create()
    MapObjectSelect:setName("MapObjectSelect")
    MapObjectSelect:setPosition(maprole:getRolePos())
    log("select role pos:", maprole:getRolePos().x, maprole:getRolePos().y)
    self.MapObjectSelect = MapObjectSelect

    self.Node_role:addChild(self.MapObjectSelect,10)
    local function onChaKanCallBack()
        log("查看玩家 name=" .. maprole.openInfo.name)
		local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
		local req = {}
		req.roleID = maprole.openInfo.roleid
		--機器人需傳uid, 真人不用
		req.uid = maprole.openInfo.account 
		req.zoneID = serverinfo.id
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
    end

    local function onTiaozhanCallBack()
        log("挑戰玩家 name=" .. maprole.openInfo.name)

    	local sins_max = cp.getManager("ConfigManager").getItemByKey("Other", "sins_max_per_day"):getValue("IntValue")
		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		if major_roleAtt.sins and major_roleAtt.sins >= sins_max then
			cp.getManager("ViewManager").gameTip("當前罪惡值已達到" .. tostring(sins_max) .. "，不允許進行比試")
			return
		end


        local function confirmFunc()
            self.fightInfo = {name = maprole.openInfo.name}
			local req = {}
			req.uuid = maprole.openInfo.account
			self:doSendSocket(cp.getConst("ProtoConst").StartFightIdleStaffReq, req)
		end

		local function cancleFunc()
		end
		
		local content = "比試會增加5點罪惡值，是否繼續比試？"
		cp.getManager("ViewManager").showGameMessageBox("系統提示",content,2,confirmFunc,cancelFunc)

    end
    self.MapObjectSelect:setButtonClickCallBack(onChaKanCallBack,onTiaozhanCallBack)

end


function WorldMapLayer:startAutoMovePlayer()
	if self.scheduleEntryId ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
	end
    self.scheduleEntryId = nil
	self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),0,false)
end

function WorldMapLayer:stopAutoMovePlayer()
	if self.scheduleEntryId ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
	end
    self.scheduleEntryId = nil

    self:saveRoleStayPoint()
end

function WorldMapLayer:updateWalkArrow()
    if self.player.getRoleIsMove == nil then
        dump(self.player)
        log("------------------")
        dump(self)
    end
	if self.player:getRoleIsMove() == false then
		return
	end

    local map_min_distance = cp.getConst("GameConst").map_min_distance * 0.25

    local pos = self.player:getRolePos()
	for _, v in pairs(self.walkArrow) do
		if v.image:isVisible() then
    		local distance = cc.pGetDistance(v.pos, pos)
			if distance <= map_min_distance then
				v.image:setVisible(false)
			end
		end
	end
end

function WorldMapLayer:clearWalkPath()
	for _, v in pairs(self.walkArrow) do
		if v.image:isVisible() then
			v.image:setVisible(false)
		end
	end
end

--更新移動
function WorldMapLayer:_update(dt)
    if self.player.getRoleIsMove == nil then
        dump(self.player)
        log("------------------")
        dump(self)
    end
    if not self.player:getRoleIsMove() then
        self:stopAutoMovePlayer() 
        return
    end

	self:updateWalkArrow()

    self:checkRoleInScreen()
end

--玩家移動到目標點後的通知事件
function WorldMapLayer:onRoleMoveTo(evt)
   
    -- 先判斷role是否存在列表中，再判斷位置，看是否需要彈出界面
    if evt.role == self.player then --當前是玩家的移動
        local mapBuildItem = self:checkPointInTownRect(evt.pos) 
        self:checkBuildEvent(mapBuildItem)
    end

	self:clearWalkPath()
end

function WorldMapLayer:checkBuildEvent(mapBuildItem)
    if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.confId and mapBuildItem.openInfo.confId > 0 then
        
        --1.對話 2.彈接任務框 3.點擊按鈕後發消息（打斷，接任務，挑戰npc）
        local function onStoryFinishCallBack()
            cp.getManager("ViewManager").removeGamePopTalk()
            
			self:dispatchViewEvent(cp.getConst("EventConst").onOpenAcceptUI, mapBuildItem.openInfo)
        end

        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local storyID = nil
        local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", mapBuildItem.openInfo.confId)
        if mapBuildItem.openInfo.uuid ~= nil and mapBuildItem.openInfo.uuid ~= "" then -- 任務已經存在，且必定是掛機類的事件，挑戰類的事件直接完成的。
            
            if mapBuildItem.openInfo.owner ~= major_roleAtt.account then -- 別人的事件
               
                if major_roleAtt.normalEvent == 0 then --當日善惡事件已完成
                    local vip = cp.getUserData("UserVip"):getValue("level")
                    if vip < 15 then
                        cp.getManager("ViewManager").gameTip("本日江湖事次數已滿，可提升VIP等級以增加每日次數。")
                    else
                        cp.getManager("ViewManager").gameTip("今日江湖事已完成，請明日再戰。")
                    end
                    return
                end
                storyID = cfg:getValue("StoryID2")
            else
            
                --事件完成或失敗，發送結束事件消息
                if mapBuildItem.openInfo.state == 3 or mapBuildItem.openInfo.state == 4 then
                    cp.getUserData("UserMapEvent"):setValue("isSwitch",false)
                    local req = {uuid = {mapBuildItem.openInfo.uuid}}
                    self:doSendSocket(cp.getConst("ProtoConst").StopConductReq, req)
                else
                    cp.getManager("ViewManager").gameTip("事件正在進行中...")
                end
                return  --自己的正在進行的事件
            end
        else
            if major_roleAtt.normalEvent == 0 then --當日善惡事件已完成
                local vip = cp.getUserData("UserVip"):getValue("level")
                if vip < 15 then
                    cp.getManager("ViewManager").gameTip("本日江湖事次數已滿，可提升VIP等級以增加每日次數。")
                else
                    cp.getManager("ViewManager").gameTip("今日江湖事已完成，請明日再戰。")
                end
                return
            end
            storyID = cfg:getValue("StoryID1")
        end

        local contentTable = nil
        if storyID then
            local packageName = "cp.story.GameStory" .. tostring(storyID)
            local status, gameStory = xpcall(function()
                    return require(packageName)
                end, function(msg)
                --if not string.find(msg, string.format("'%s' not found:", packageName)) then
                    print("load stroy error: ", msg)
                --end
            end)
           
            contentTable = gameStory
        end

        if contentTable and type(contentTable) == "table" and next(contentTable) > 0 then
            cp.getManager("ViewManager").showGamePopTalk(contentTable,onStoryFinishCallBack,false)
        else
            onStoryFinishCallBack()
        end

    end
end


--檢測人物是否在屏幕中間，檢測是否需要移動地圖
function WorldMapLayer:checkRoleInScreen()
    local pos = self.player:getRolePos()
    local innerPos = self.ScrollView_bg:getInnerContainerPosition()
    local newX = 0
    if pos.x > self.visibleSize.width/2 and pos.x < self.mapSize.width - self.visibleSize.width/2 then
        newX = self.visibleSize.width/2 - pos.x
    elseif pos.x <= self.visibleSize.width/2 then
        newX = 0
    elseif pos.x >= self.mapSize.width - self.visibleSize.width/2 then
        newX = self.visibleSize.width - self.mapSize.width
    end
    if newX ~= innerPos.x then
        self.ScrollView_bg:setInnerContainerPosition(cc.p(newX,0))
    end
end


--根據事件創建事件建築
function WorldMapLayer:showMapEventList(data)
    self.Node_event:removeAllChildren()
    
    
    local event_used_pos = {}
    local event_used_conductID = {}
    local event_level_num = {0,0,0,0,0,0}
    --創建事件點建築
    for uuid,info in pairs(data) do
        local MapBuild,open_hierarchy = self:createEventBuild(info.confId,info)
        self.Node_event:addChild(MapBuild)
        self.MapBuildList[#self.MapBuildList + 1] = MapBuild
        
        event_level_num[open_hierarchy] = event_level_num[open_hierarchy] + 1
        local posIndex = tonumber(info.pos)
        event_used_pos[tostring(posIndex)] = tostring(posIndex)
 
        if table.arrIndexOf(event_used_conductID,info.confId) == -1 then
            table.insert(event_used_conductID,info.confId)
        end

    end
    cp.getUserData("UserMapEvent"):setValue("event_used_pos",event_used_pos)
    --檢測是否需要創建未開始的事件建築
    local event_level_maxnum = cp.getManualConfig("MapEventPos").event_level_maxnum --各階對應的事件最大數量
    local need_level_num = {0,0,0,0,0,0}
    for lv,num in pairs(event_level_num) do
        need_level_num[lv] = math.max(0, event_level_maxnum[lv] - num)
    end
    
    self:createNewEventBuild(need_level_num,event_used_conductID)
    
end


--隨機產生事件的位置
function WorldMapLayer:generateNewPos(posStr)
    local event_used_pos = cp.getUserData("UserMapEvent"):getValue("event_used_pos")
    
    local posArr = string.split(posStr,"|")
    local num = table.nums(posArr)
    local leftPos = {}
    for i=1,num do
        if event_used_pos[posArr[i]] == nil then
            table.insert(leftPos,posArr[i])
        end
    end
    local newPos = nil
    local newNum = table.nums(leftPos)
    if newNum > 1 then
        newPos = leftPos[math.random(1,newNum)]
        event_used_pos[newPos] = newPos
    elseif newNum == 1 then
        newPos = leftPos[1]
        event_used_pos[newPos] = newPos
    else
        --沒有位置了(一般不會出現此情況)
        newPos = posArr[math.random(1,num)]
        event_used_pos[newPos] = newPos
    end
    cp.getUserData("UserMapEvent"):setValue("event_used_pos",event_used_pos)
   
    return tonumber(newPos) --返回的是位置索引
end

--創建事件建築
function WorldMapLayer:createEventBuild(confId,eventInfo)

    local openInfo = eventInfo or {}
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", confId)
    openInfo.name = openInfo.ownerName or cfg:getValue("BuildName")
    openInfo.confId = confId
    openInfo.Type = cfg:getValue("Type")
    openInfo.image = cfg:getValue("BuildImage") 
    openInfo.open_hierarchy = cfg:getValue("Hierarchy")
    openInfo.Process = cfg:getValue("Process") 
    openInfo.small_icon = cfg:getValue("Icon")
    openInfo.build_type = "eventpoint" -- type : "city","eventpoint","holdpoint"
    openInfo.pos = tonumber(openInfo.pos) or 0

    if openInfo.pos == nil or tonumber(openInfo.pos) == nil or tonumber(openInfo.pos) == 0 then
        local posIndex = self:generateNewPos(cfg:getValue("Pos")) 
        -- log("posIndex = " .. posIndex)
        openInfo.pos = posIndex 
    end
    local pos = cp.getManualConfig("MapEventPos").pos[tonumber(openInfo.pos)]
    openInfo.pos_real = pos

    log(string.format("posIndex=%d,(x=%s,y=%s)",openInfo.pos,tostring(pos.x),tostring(pos.y)))

    local MapBuild = require("cp.view.scene.world.worldmap.MapBuild"):create(openInfo)
    MapBuild:setPosition(pos)
    MapBuild:setBuildClickCallBack(handler(self,self.onEventBuildClicked),handler(self,self.onEventStateClicked))

    return MapBuild, openInfo.open_hierarchy
end

function WorldMapLayer:createNewEventBuild(need_level_num,event_used_conductID)

    local event_list = cp.getManager("GDataManager"):generateMapEventListFromConfig()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local conductType = majorRole.conductType or 1 -- 善惡模式1 善, 2 惡
    local cur_type_event_list = event_list[conductType] --當前類型的事件id列表

    local cur_type_zhuanshu_list = event_list[conductType+2] --當前類型的專屬事件id列表

    --生成事件id
    local new_event_id = {{},{},{},{},{},{}}

    for lv, num in pairs (need_level_num) do
        local cur_level_event_list = cur_type_event_list[lv]
        local cur_level_zhuanshu_id = cur_type_zhuanshu_list[lv][1]
        if num == table.nums(cur_level_event_list) + 1 then --需要全部重新創建
            new_event_id[lv] = cur_level_event_list
            table.insert(new_event_id[lv], cur_level_zhuanshu_id) --加一個專屬事件

            for i=1,table.nums(new_event_id[lv]) do
                table.insert(event_used_conductID,new_event_id[lv][i])
            end
        else  --需要部分重新創建，需創建num個事件
            
            if table.arrIndexOf(event_used_conductID,cur_level_zhuanshu_id) == -1 then
                table.insert(new_event_id[lv],cur_level_zhuanshu_id)
                num = num - 1 
                table.insert(event_used_conductID,cur_level_zhuanshu_id)
            end

            while(num > 0) do
                local newID = cur_level_event_list[math.random(1,table.nums(cur_level_event_list))] 
                local nextID = cp.getManager("GDataManager"):getNextConductID(newID)
                if table.arrIndexOf(event_used_conductID,newID) == -1 and table.arrIndexOf(event_used_conductID,nextID) == -1 then
                    table.insert(new_event_id[lv],newID)
                    num = num - 1
                    table.insert(event_used_conductID,newID)
                end
                
            end
        end
    end
 
    --通過事件id創建建築
    for lv,ids in pairs(new_event_id) do
        if #ids > 0 then 
            for i=1,#ids do
                local MapBuild = self:createEventBuild(ids[i],nil,nil)
                self.Node_event:addChild(MapBuild)
                self.MapBuildList[#self.MapBuildList + 1] = MapBuild
            end
        end
    end
    
end


function WorldMapLayer:onEventBuildClicked(buildItem)
    local buildInfo = buildItem.openInfo
    dump(buildInfo)
    
    if self:eventBuildTimesCheck(buildItem) == false then
        return
    end

    if self.curSelectedBuild then
        if self.curSelectedBuild ~= buildItem then
			if self.curSelectedBuild.setSelected ~= nil then
            	self.curSelectedBuild:setSelected(false)
			end
            buildItem:setSelected(true)
            self.curSelectedBuild = buildItem
        else
            --判斷距離是否已經靠近，是否彈出操作界面
            if not self.player:getRoleIsMove() then
                self:checkBuildEvent(buildItem)
            end
            return
        end
    else
        self.curSelectedBuild = buildItem
        buildItem:setSelected(true)
    end

    self.player:moveTo(buildInfo.pos_real)
    self.rootView:runAction( cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(
        handler(self,self.startAutoMovePlayer)) ) )
    
        --判斷role當前是否在屏幕內，不在則移動到屏幕內
    self:checkRoleInScreen()

	self:drawWalkPath(self.player:getRolePos(), buildInfo.pos_real)
end

function WorldMapLayer:onEventStateClicked()

end


--檢測當前點是否在城鎮或事件建築附近，是的話返回當前建築，否則返回nil
function WorldMapLayer:checkPointInTownRect(pos)
    local min_distance = cp.getConst("GameConst").map_min_distance
    for _,mapBuildItem in pairs(self.MapBuildList) do
        if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.pos_real then
            local distance = cc.pGetDistance(pos,  mapBuildItem.openInfo.pos_real)
            if distance < min_distance then
                return mapBuildItem
            end
        end
    end
    return nil
end

--通過建築的位置來獲取建築實例
function WorldMapLayer:getBuildItemByPos(pos_idx)

    for _,mapBuildItem in pairs(self.MapBuildList) do
        if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.pos == pos_idx  then
            return mapBuildItem
        end
    end
    return nil
end

--更新建築狀態
function WorldMapLayer:refreshBuildState(data)
    log("refreshBuildState,pos_idx=%d.",data.pos)
    local buildItem = self:getBuildItemByPos(tonumber(data.pos))
    if buildItem then
        for key,value in pairs(data) do
            buildItem.openInfo[key] = value
        end
        if data.confId then
            local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", data.confId)
            -- openInfo.name = openInfo.ownerName or cfg:getValue("BuildName")
            -- openInfo.confId = confId
            buildItem.openInfo.Type = cfg:getValue("Type")
            buildItem.openInfo.image = cfg:getValue("BuildImage") 
            buildItem.openInfo.open_hierarchy = cfg:getValue("Hierarchy")
            buildItem.openInfo.Process = cfg:getValue("Process") 
            buildItem.openInfo.small_icon = cfg:getValue("Icon")
        end
        
        buildItem:setEventState(data.state,data.ownerName)
    end
end

--打斷別人的善惡事件
function WorldMapLayer:onBreakConduct(proto)
    local info = proto.data
    if proto.success then
        --更新建築事件
        self:refreshBuildState(proto.data)
    end

    if self.curSelectedBuild and self.curSelectedBuild.setSelected then
        self.curSelectedBuild:setSelected(false)
        self.curSelectedBuild = nil
    end
    

    --進入戰鬥場景
    local item_list = self:getCombatReward(proto)
    cp.getUserData("UserCombat"):setCombatReward(item_list or {})
    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
  
end

function WorldMapLayer:getCombatReward(proto)

    --[[
    message BreakHangConductRsp {
        required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
        required string uuid                    = 2;                    //uuid
        required bool success                   = 3;                    //打斷成功
        optional ConductData data               = 4;                    //打斷成功後，新產生一個事件                    
        repeated ConductItem items              = 5;                    //獎勵物品
        optional int32 silver                   = 6;                    //銀兩
        optional int32 good                     = 7;                    //善值
        optional int32 bad                      = 8;                    //惡值
        optional int32 skill                    = 9;                    //修為點
    }
    ]]
    local rewardListForCombat = {currency_list= {},item_list={}}
    if proto.silver > 0 then
        table.insert(rewardListForCombat.currency_list,{type=cp.getConst("GameConst").VirtualItemType.silver, num = proto.silver})
    end
    if proto.good > 0 then
        table.insert(rewardListForCombat.currency_list,{type=cp.getConst("GameConst").VirtualItemType.goodPoint, num = proto.good})
    end
    if proto.bad > 0 then
        table.insert(rewardListForCombat.currency_list,{type=cp.getConst("GameConst").VirtualItemType.badPoint, num = proto.bad})
    end
    if proto.skill > 0 then
        table.insert(rewardListForCombat.currency_list,{type=cp.getConst("GameConst").VirtualItemType.trainPoint, num = proto.skill})
    end

    if proto.items and next(proto.items) then
        for i=1,#proto.items do
            local itemID = proto.items[i].itemid
            local itemNum = proto.items[i].itemnum
            table.insert(rewardListForCombat.item_list,{item_id = itemID,item_num = itemNum})
        end
    end
    return rewardListForCombat
end

--挑戰npc返回
function WorldMapLayer:onStartFightConduct(data)
--[[
    message StartFightConductRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
    required bool success                   = 2;                    //戰鬥結果
    required int32 id                       = 3;                    //事件配置id
}
]]

    local id = data.id
    if self.curSelectedBuild and self.curSelectedBuild.setSelected then
        self.curSelectedBuild:setSelected(false)
        
    end

    if data.success then
        --刷新建築位置，相當於重新生成了一個新事件
       for j,mapBuildItem in pairs(self.MapBuildList) do
            if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.confId == data.id  then
                
                local oldIndex = mapBuildItem.openInfo.pos
                local event_used_pos = cp.getUserData("UserMapEvent"):getValue("event_used_pos")
                
                local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", data.id)
                local newPosIndex = self:generateNewPos(cfg:getValue("Pos"))
                
                event_used_pos[tostring(oldIndex)] = nil
                event_used_pos[tostring(newPosIndex)] = tostring(newPosIndex)
                cp.getUserData("UserMapEvent"):setValue("event_used_pos",event_used_pos)
                    
                if self.curSelectedBuild == mapBuildItem then
                    self.curSelectedBuild = nil
                end

                mapBuildItem.openInfo.pos = newPosIndex
                mapBuildItem.openInfo.pos_real = cp.getManualConfig("MapEventPos").pos[newPosIndex]
                mapBuildItem:setPosition(mapBuildItem.openInfo.pos_real)
                break
            end
        end
        
    end

    --進入戰鬥場景
    local item_list = self:getCombatReward(data)
    cp.getUserData("UserCombat"):setCombatReward(item_list or {})
    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
end

--結束善惡事件
function WorldMapLayer:onStopConductCallBack(data)
    if data.eventInfoList then

        -- 刪除建築
        for i=1,#data.eventInfoList do
            local curEventInfo = data.eventInfoList[i]
            for j,mapBuildItem in pairs(self.MapBuildList) do
                
                if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.pos == tonumber(curEventInfo.pos) then
                    if self.curSelectedBuild == mapBuildItem then
                        self.curSelectedBuild = nil
                    end
                    mapBuildItem:removeFromParent()
                    table.remove(self.MapBuildList,j)

                    local posIndex = tonumber(curEventInfo.pos)
                    local event_used_pos = cp.getUserData("UserMapEvent"):getValue("event_used_pos")
                    event_used_pos[tostring(posIndex)] = nil
                    cp.getUserData("UserMapEvent"):setValue("event_used_pos",event_used_pos)
                        
                    break
                end
            end
        end
    end
end

--挑戰大俠協議返回
function WorldMapLayer:gotoFightHero(data)
    cp.getManager("ViewManager").removeChallengeStory()

    if data.success then
        -- local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
        -- self.hero_array = table.values(hero_list)
    
        --刪除大俠npc
        for i=1, #self.heroNpcList do
            if self.heroNpcList[i] and self.heroNpcList[i].openInfo and self.heroNpcList[i].openInfo.uuid == data.uuid then
                self.heroNpcList[i]:removeFromParent()
                table.remove(self.heroNpcList,i)
                break
            end
        end
    end
    local rewardList = {item_list = {}, currency_list={}}
    if data.silver > 0 then
        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.silver, num=data.silver})
    end
    for i=1,#data.items do
        if data.items[i] and data.items[i].itemid > 0 and data.items[i].itemnum > 0 then
            table.insert(rewardList.item_list, {item_id = data.items[i].itemid,item_num = data.items[i].itemnum })
        end
    end
    cp.getUserData("UserCombat"):setCombatReward(rewardList)
    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
end

--結交大俠
function WorldMapLayer:gotoBribeHero(data)
    
    cp.getManager("ViewManager").removeChallengeStory()

    -- local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
    -- self.hero_array = table.values(hero_list)

    --刪除大俠npc
    for i=1, #self.heroNpcList do
        if self.heroNpcList[i] and self.heroNpcList[i].openInfo and self.heroNpcList[i].openInfo.uuid == data.uuid then
            self.heroNpcList[i]:removeFromParent()
            table.remove(self.heroNpcList,i)
            break
        end
    end

    local item_list = {}
    if data.silver > 0 then
        table.insert(item_list, {id = 2,num = data.silver })
    end
    for i=1,#data.items do
        if data.items[i] and data.items[i].itemid > 0 and data.items[i].itemnum > 0 then
            table.insert(item_list, {id = data.items[i].itemid,num = data.items[i].itemnum })
        end
    end

    if table.nums(item_list) > 0 then
        cp.getManager("ViewManager").showGetRewardUI(item_list,"義結金蘭",true)
    end
end

--一鍵結交大俠
function WorldMapLayer:onBribeAllHero(data)
    -- local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
    -- self.hero_array = table.values(hero_list)

    local needRemove = {}
    local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
    for uuid, info in pairs(hero_list) do
        if info.state > 0 then
            table.insert(needRemove,uuid)
        end
    end
    
    --刪除已經結交的大俠npc
    for i=#self.heroNpcList,1,-1 do
        if self.heroNpcList[i] and self.heroNpcList[i].openInfo and table.arrIndexOf(needRemove,self.heroNpcList[i].openInfo.uuid) ~= -1 then
            self.heroNpcList[i]:removeFromParent()
            table.remove(self.heroNpcList,i)
        end
    end
end

function WorldMapLayer:onExpressBuildClicked(sender)
    local btnName = sender:getName()
    local idx = tonumber(string.sub(btnName,string.len("Image_express_")+1))
    if idx == 1 then  -- 龍門鏢局
        --打開押鏢界面
        if not self.ExpressEscort then
            local ExpressEscort = require(cp.getConst("SceneConst").MODULE_ExpressEscort):create()
            self:addChild(ExpressEscort,2)
            ExpressEscort:setCloseCallBack(function()
                self.ExpressEscort:removeFromParent()
                self.ExpressEscort = nil    
            end)
            self.ExpressEscort = ExpressEscort
        end
        self.ExpressEscort:refresh()
        
    elseif idx == 2 or idx == 3 or idx == 4 then
        --打開伏擊界面
        local openInfo = {pos_idx = idx}
        local ExpressLoot = require(cp.getConst("SceneConst").MODULE_ExpressLoot):create(openInfo)
        self:addChild(ExpressLoot,2)
    end

end
    
--獲取個人押鏢數據，顯示鏢車
function WorldMapLayer:getSelfVan(data)

    local van_list = cp.getUserData("UserVan"):getValue("van_list")
    for i=1, table.nums(van_list) do
        if van_list[i].uuid ~= nil and van_list[i].uuid ~= "" and van_list[i].startStamp > 0 then
            local id = van_list[i].id
            local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", id)
            local Time = string.split(itemCfg:getValue("Time"),"|")
            local totalTime = 0
            for i=1,#Time do
                totalTime = totalTime + tonumber(Time[i])
            end
        
            local now = cp.getManager("TimerManager"):getTime()
            local state = 0 -- 0:未開啟 1：正在進行 2：已結束
            state = (now - van_list[i].startStamp > totalTime) and 2 or 1
            if state == 1 then
                self:beginEscort(van_list[i])
                return  
            end
        end
    end

end

function WorldMapLayer:onStartVanCallBack(idx)
    local van_list = cp.getUserData("UserVan"):getValue("van_list")
    if van_list[idx].uuid ~= nil and van_list[idx].uuid ~= "" and van_list[idx].startStamp > 0 then
        local beginPos = cc.p(self.Image_express_1:getPosition())
        self:beginEscort(van_list[idx],beginPos)
    end
    
end

--開始押鏢
function WorldMapLayer:beginEscort(vanInfo,beginPos)
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local openInfo = {}
    openInfo.vanInfo = vanInfo
    openInfo.currentPos = beginPos
    openInfo.ownerRoleID = major_roleAtt.id
    local ExpressVehicle = require("cp.view.scene.world.worldmap.ExpressVehicle"):create(openInfo)
    self.Node_van:addChild(ExpressVehicle,1)
    self.vanList = self.vanList or {}
    self.vanList[vanInfo.uuid] = ExpressVehicle
end

--初始化押鏢點在地圖上的位置
function WorldMapLayer:initExpressPosList()

    local express_pos_list = {}
    -- express_pos_list[1] = cc.p(self.Image_express_1:getPosition()) --起始點
    -- express_pos_list[2] = self.cityInfoConfig[2].pos               --第一個拐角點(鳳翔)
    -- express_pos_list[3] = cc.p(self.Image_express_2:getPosition()) --風雨亭
    -- express_pos_list[4] = self.cityInfoConfig[3].pos               --第二個拐角點(襄陽)
    -- express_pos_list[5] = self.cityInfoConfig[4].pos               --第三個拐角點(開封)
    -- express_pos_list[6] = cc.p(self.Image_express_3:getPosition()) --萬鬆嶺
    -- express_pos_list[7] = self.cityInfoConfig[5].pos               --第四個拐角點(臨安)
    -- express_pos_list[8] = cc.p(self.Image_express_4:getPosition()) --青陽崗
    -- express_pos_list[9] = self.cityInfoConfig[6].pos               --結束點(揚州)

    express_pos_list[1] = {beginPos = cc.p(150,647), endPos = cc.p(1005,234)}         --龍門鏢局 -> 鳳翔
    express_pos_list[2] = {beginPos = cc.p(1010,245), endPos = cc.p(1253,736)}       --鳳翔 -> 風雨亭
    express_pos_list[3] = {beginPos = cc.p(1253,732), endPos = cc.p(1390,944)}       --風雨亭 -> 襄陽
    express_pos_list[4] = {beginPos = cc.p(1390,938), endPos = cc.p(2118,810)}       --襄陽 -> 開封
    express_pos_list[5] = {beginPos = cc.p(2117.6,801.5), endPos = cc.p(2435,505)}   --開封 -> 萬鬆嶺
    express_pos_list[6] = {beginPos = cc.p(2430,505), endPos = cc.p(2701,251)}       --萬鬆嶺 -> 臨安
    express_pos_list[7] = {beginPos = cc.p(2701,256), endPos = cc.p(2980,526)}       --臨安 -> 青陽崗
    express_pos_list[8] = {beginPos = cc.p(2980,526), endPos = cc.p(3287,814)}       --青陽崗 -> 揚州

    cp.getUserData("UserVan"):setValue("express_pos_list",express_pos_list)

    local totalLength = 0
    local idx = 1
    local length_list = {} -- 8段路程
    for i=1,#express_pos_list do
        local curLen = cc.pGetDistance(express_pos_list[1].beginPos, express_pos_list[i].endPos) 
        totalLength = totalLength + curLen 
        length_list[#length_list + 1] = curLen
    end

    cp.getUserData("UserVan"):setValue("express_total_length",totalLength)
    cp.getUserData("UserVan"):setValue("length_list",length_list)
end


function WorldMapLayer:getAllVan(data)

    local other_van_list = cp.getUserData("UserVan"):getValue("other_van_list")
    self.vanList = self.vanList or {}
    for uuid,info in pairs(other_van_list) do
        if self.vanList[info.uuid] == nil then
            local openInfo = {}
            openInfo.vanInfo = info
            local ExpressVehicle = require("cp.view.scene.world.worldmap.ExpressVehicle"):create(openInfo)
            self.Node_van:addChild(ExpressVehicle)
            
            self.vanList[info.uuid] = ExpressVehicle

            local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if info.ownerRoleID == major_roleAtt.id then
                ExpressVehicle:setLocalZOrder(1)
            end
        end
    end
end

function WorldMapLayer:updateVanHeadState(evt)
    
    if self.image_head == nil then
        local image_head = ccui.ImageView:create()
        image_head:ignoreContentAdaptWithSize(true)
        -- local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        -- image_head:loadTexture("img/model/head/" .. major_roleAtt.face .. ".png", UI_TEX_TYPE_LOCAL)
        image_head:loadTexture("ui_mapbuild_module21_yabiao_20.png",UI_TEX_TYPE_PLIST)
        self.Node_convoy:addChild(image_head,1)
        self.image_head = image_head
    end
    self.image_head:setVisible(false)
    if evt.timeIndex == 3 then
        local posX,posY = self.Image_express_2:getPosition()
        self.image_head:setPosition(cc.p(posX,posY+100))
        self.image_head:setVisible(true)
    elseif evt.timeIndex == 7 then
        local posX,posY = self.Image_express_3:getPosition()
        self.image_head:setPosition(cc.p(posX,posY+100))
        self.image_head:setVisible(true)
    elseif evt.timeIndex == 10 then
        local posX,posY = self.Image_express_4:getPosition()
        self.image_head:setPosition(cc.p(posX,posY+100))
        self.image_head:setVisible(true)
    end
end

function WorldMapLayer:updateSelfVanPos()
    if self.vanList == nil or next(self.vanList) == nil then return end
    
    for uuid, eVehicle in pairs(self.vanList) do
        if eVehicle and eVehicle.isSelfVehicle then
            if eVehicle.timeIndex and eVehicle.timeIndex > 0 and eVehicle.timeIndex <= 11 then
                self:updateVanHeadState({timeIndex = eVehicle.timeIndex})
            end
        end
    end
end

function WorldMapLayer:onOtherDefeatHero(data)
    --刪除大俠npc
    for i=1, #self.heroNpcList do
        if self.heroNpcList[i] and self.heroNpcList[i].openInfo and self.heroNpcList[i].openInfo.uuid == data.info.uuid then
            self.heroNpcList[i]:removeFromParent()
            table.remove(self.heroNpcList,i)
            break
        end
    end
end


function WorldMapLayer:initGuildWantedNpc(data)

    local npc_list = cp.getUserData("UserGuild"):getGuildWantedInfo().npc_list
   
    local num = table.nums(npc_list)
    if num > 0 then
        self.guild_npc_create_index = 1
        self.Node_role:runAction(		
            cc.Sequence:create(
                cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(handler(self,self.createGuildWantedNpc)), cc.DelayTime:create(0.03)), num)
            )
        )
    end
end

--創建一個幫派懸賞npc
function WorldMapLayer:createGuildWantedNpc()
    local npc_list = cp.getUserData("UserGuild"):getGuildWantedInfo().npc_list
    local npcInfo = npc_list[self.guild_npc_create_index]
    if npcInfo == nil then
        log("11111")
    end
    
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcInfo.id or 0)
	if cfgItem == nil then
		return
    end
    
    local openInfo = clone(npcInfo)
    openInfo.name = cfgItem:getValue("Name")
	openInfo.currentPos = cp.getManualConfig("MapEventPos").guild_npc_pos[#self.guildNpcList + 1]
    openInfo.isNpc = true
    openInfo.needAutoMove = false
    openInfo.needShowConductName = false
    openInfo.isGuildNpc = true
    openInfo.model = cp.getManager("ViewManager").createNpc(npcInfo.id,0.4)
	
	local role = require("cp.view.scene.world.worldmap.MapRole"):create(openInfo)
	
	role:initBeginPos(openInfo.currentPos)
	role:setClickRoleCallBack(handler(self,self.selectMapGuildNpc))
    self.Node_role:addChild(role)
    table.insert(self.guildNpcList, role)

    self.guild_npc_create_index = self.guild_npc_create_index + 1
end

function WorldMapLayer:selectMapGuildNpc( maprole )

    log("WorldMapLayer:selectMapGuildNpc name=" ..  maprole.openInfo.name)
    -- 打開挑戰界面

    local type,id,level = cp.getConst("CombatConst").CombatType_GuildWanted,maprole.openInfo.id,0  
    local function closeCallBack(retStr)
        if retStr == "jina" then

            local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
            local guildLevel = guildDetailData.level
            local cfg = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildLevel)
            local maxCount = 0
            if cfg then
                local countArr = string.split(cfg:getValue("WantedConfig"), ";")
                maxCount = tonumber(countArr[1]) or 0
            end
        
            local count = cp.getUserData("UserGuild"):getGuildWantedInfo().count
            if count >= maxCount then
                cp.getManager("ViewManager").gameTip("緝拿次數已達到上限!")
                return
            end

            log("緝拿幫派npc: name=" .. maprole.openInfo.name)
            self.fightInfo = {name=maprole.openInfo.name }
            local req = {}
            req.id = maprole.openInfo.id
            self:doSendSocket(cp.getConst("ProtoConst").FightGuildWantedReq, req)
        
        elseif retStr == "close" then
            cp.getManager("ViewManager").removeChallengeStory()
        end
        
    end
    cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack)

end


function WorldMapLayer:refreshCityState(data)
    local cityState = {}
    if data and next(data) then
        for i=1,table.nums(data) do
            if data[i].city >= 1 and data[i].city <= 6 then
                -- state 0無人佔領 1有人佔領 2 被攻打中
                cityState[data[i].city] = data[i].state
            end
        end
    end

    for _,mapBuildItem in pairs(self.MapBuildList) do
        if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.build_type == "city" then
            if cityState[mapBuildItem.openInfo.cityIndex] then
                mapBuildItem:refreshCityState(cityState[mapBuildItem.openInfo.cityIndex])
            end
        end
    end
end

function WorldMapLayer:eventBuildTimesCheck(mapBuildItem)

    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if mapBuildItem and mapBuildItem.openInfo and mapBuildItem.openInfo.confId and mapBuildItem.openInfo.confId > 0 and mapBuildItem.openInfo.build_type == "eventpoint" then
        if (mapBuildItem.openInfo.uuid == nil or mapBuildItem.openInfo.uuid == "") or  --或任務未開始
            (mapBuildItem.openInfo.uuid ~= nil and mapBuildItem.openInfo.uuid ~= "" and mapBuildItem.openInfo.owner ~= major_roleAtt.account) then  -- 別人的事件

            if major_roleAtt.normalEvent == 0 then --當日善惡事件已完成
                local vip = cp.getUserData("UserVip"):getValue("level")
                if vip < 15 then
                    cp.getManager("ViewManager").gameTip("本日江湖事次數已滿，可提升VIP等級以增加每日次數。")
                else
                    cp.getManager("ViewManager").gameTip("今日江湖事已完成，請明日再戰。")
                end
                return false
            end
        end
    end
    return true
end

function WorldMapLayer:checkVanHolidayTime()
    local isHoliday = cp.getManager("GDataManager"):isInVanHolidayTime()
    self.Image_express_1:getChildByName("Image_huodong"):setVisible(isHoliday)
end


function WorldMapLayer:checkNeedExpressGuide()
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    if string.find(listStr.finished,"river_event")  then
        --可以指引了
        if not string.find(listStr.finished,"escort")  then 
            if not self["Image_express_1"]:getChildByName("finger") then
                cp.getManager("ViewManager").showGuideFinger(self["Image_express_1"],cc.p(115,200))
            end
        else
            if self["Image_express_1"]:getChildByName("finger") then
                self["Image_express_1"]:removeChildByName("finger")
            end
        end
        if not string.find(listStr.finished,"loot")  then 
            for i=2,4 do
                if not self["Image_express_" .. tostring(i)]:getChildByName("finger") then
                    cp.getManager("ViewManager").showGuideFinger(self["Image_express_" .. tostring(i)],cc.p(50,100))
                end
            end
        else
            for i=2,4 do
                if self["Image_express_" .. tostring(i)]:getChildByName("finger") then
                    self["Image_express_" .. tostring(i)]:removeChildByName("finger")
                end
            end
        end
    else
        for i=1,4 do
            if self["Image_express_" .. tostring(i)]:getChildByName("finger") then
                self["Image_express_" .. tostring(i)]:removeChildByName("finger")
            end
        end
    end
end

return WorldMapLayer
