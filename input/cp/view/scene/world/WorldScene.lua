local BScene = require "cp.view.ui.base.BScene"
local WorldScene = class("WorldScene",BScene)

function WorldScene:create()
    local ret = WorldScene.new()
    ret:init()
    return ret
end

function WorldScene:init()
    self.wait_cmd = nil
end

function WorldScene:initListEvent()
    self.listListeners = {
        --打開界面
        [cp.getConst("EventConst").game_world_to_open_module] = function(data)
            if self.scheduleEntryId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
                self.scheduleEntryId = nil
            end
            
            --等下一幀執行
            self.wait_cmd = {
                name = "open",
                data = data,
            }
            self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.doSomeThing),0,false)
        end,
        
        --關閉所有界面
        [cp.getConst("EventConst").game_world_to_close_module] = function(data)
            if self.scheduleEntryId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
                self.scheduleEntryId = nil
            end
            
            --等下一幀執行
            self.wait_cmd = {
                name = "close",
                data = data,
            }
            self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.doSomeThing),0,false)
        end,

        --返回上一個界面
        [cp.getConst("EventConst").game_world_to_return_module] = function(data)
            if self.scheduleEntryId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
                self.scheduleEntryId = nil
            end

            --等下一幀執行
            self.wait_cmd = {
                name = "return",
                data = data,
            }
            self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.doSomeThing),0,false)
        end,


        --打開關閉新手指引界面
        [cp.getConst("EventConst").open_playerguider_view] = function(info)
            
            local NewGuideOnMainUI = self.top_root:getChildByName("NewGuideOnMainUI")
            if not NewGuideOnMainUI and info.type == "show" then
                NewGuideOnMainUI = require("cp.view.scene.newguide.moduleguide.NewGuideOnMainUI"):create(info)
                NewGuideOnMainUI:setName("NewGuideOnMainUI")
                self.top_root:addChild(NewGuideOnMainUI)
            end

            if info.type == "show" then
                if NewGuideOnMainUI then
                    if info.finishCallBack then
                        NewGuideOnMainUI:setGuideFinishCallBack(info.finishCallBack)
                    end
                    if info.guide_name ~= NewGuideOnMainUI.open_info.guide_name then
                        NewGuideOnMainUI:resetGuideInfo(info)
                        
                        NewGuideOnMainUI:Next()
                    end
                    NewGuideOnMainUI:setVisible(true)
                end
            elseif info.type == "hide" then
                if NewGuideOnMainUI then
                    NewGuideOnMainUI:setVisible(false)
                end
            elseif info.type == "close" then
                if NewGuideOnMainUI then
                    NewGuideOnMainUI:removeFromParent()
                    NewGuideOnMainUI = nil
                end
                
            end
            
        end,

        --打開/關閉活動界面
        [cp.getConst("EventConst").open_activity_view] = function(flag)
            if not self.activityViewLayer and flag then
                local signLayer = require("cp.view.scene.activity.ActivitySignLayer"):create()
                self.activityViewLayer = signLayer
                self.layer_scene:addChild(signLayer, -1)
            end

            if self.activityViewLayer and not flag then
                self.activityViewLayer:removeFromParent()
                self.activityViewLayer = nil
            end

            if flag then
                self.activityViewLayer:setVisible(true)
            end
        end,
        
        --打開/關閉擂臺界面
        [cp.getConst("EventConst").open_arena_view] = function(flag)
            if not self.arenaViewLayer and flag then
                local signLayer = require("cp.view.scene.arena.ArenaHouseLayer"):create()
                self.arenaViewLayer = signLayer
                self.layer_scene:addChild(signLayer, -1)
            end

            if self.arenaViewLayer and not flag then
                self.arenaViewLayer:removeFromParent()
                self.arenaViewLayer = nil
            end

            if flag then
                self.arenaViewLayer:setVisible(true)
            end
        end,
        
        --打開/關閉好友界面
        [cp.getConst("EventConst").open_friend_view] = function(flag)
            if not self.friendViewLayer and flag then
                local friendLayer = require("cp.view.scene.friend.FriendListLayer"):create()
                self.friendViewLayer = friendLayer
                self.layer_scene:addChild(friendLayer, 1)
            end

            if self.friendViewLayer and not flag then
                self.friendViewLayer:removeFromParent()
                self.friendViewLayer = nil
            end

            if flag then
                self.friendViewLayer:setVisible(true)
            end
        end,
        
        --打開/關閉郵件界面
        [cp.getConst("EventConst").open_mail_view] = function(flag)
            if not self.mailListLayer and flag then
                local mailListLayer = require("cp.view.scene.system.MailListLayer"):create()
                self.mailListLayer = mailListLayer
                self.layer_scene:addChild(mailListLayer, 1)
            end

            if self.mailListLayer and not flag then
                self.mailListLayer:removeFromParent()
                self.mailListLayer = nil
            end

            if flag then
                self.mailListLayer:setVisible(true)
            end
        end,


		[cp.getConst("EventConst").GetLotteryDataRsp] = function(data)	
        end,
        
        --打開/關閉猜拳界面
		[cp.getConst("EventConst").GetGuessFingerDataRsp] = function(flag)
            if not self.guessFingerLayer and flag then
                self.guessFingerLayer = require("cp.view.scene.guess.GuessFingerLayer"):create()
                self.layer_scene:addChild(self.guessFingerLayer, 1)
            end

            if self.guessFingerLayer and not flag then
                self.guessFingerLayer:removeFromParent()
                self.guessFingerLayer = nil
            end

            if flag then
                self.guessFingerLayer:setVisible(true)
            end
        end,

		[cp.getConst("EventConst").GetMountainPlayerListRsp] = function(flag)
            if not self.mountainMainLayer and flag then
                self.mountainMainLayer = require("cp.view.scene.mountain.MountainMainLayer"):create()
                self.layer_scene:addChild(self.mountainMainLayer, 1)
            end

            if self.mountainMainLayer and not flag then
                self.mountainMainLayer:removeFromParent()
                self.mountainMainLayer = nil
            end

            if flag then
                self.mountainMainLayer:setVisible(true)
            end
        end,

		[cp.getConst("EventConst").GetRollDiceDataRsp] = function(flag)	
            if not self.rollDiceLayer and flag then
                self.rollDiceLayer = require("cp.view.scene.guess.RollDiceLayer"):create()
                self.layer_scene:addChild(self.rollDiceLayer, 1)
            end

            if self.rollDiceLayer and not flag then
                self.rollDiceLayer:removeFromParent()
                self.rollDiceLayer = nil
            end

            if flag then
                self.rollDiceLayer:setVisible(true)
            end
        end,
        --打開/關閉猜拳界面
		["GetPlayerGuildDataRsp"] = function(flag)
            if not self.guildLayer and flag then
                if cp.getUserData("UserGuild"):getPlayerGuildData().id > 0 then
                    self.guildLayer = require("cp.view.scene.guild.GuildMainLayer"):create()
                else
                    self.guildLayer = require("cp.view.scene.guild.GuildListLayer"):create()
                end
                self.layer_scene:addChild(self.guildLayer, 1)
            end

            if self.guildLayer and not flag then
                self.guildLayer:removeFromParent()
                self.guildLayer = nil
            end

            if flag then
                self.guildLayer:setVisible(true)
            end
        end,
        --打開/關閉我要xxx界面
		["ActivityGuide"] = function(data)
            if not self.guideLayer and data.flag then
                self.guideLayer = require("cp.view.scene.activity.ActivityGuideLayer"):create(data)
                self.layer_scene:addChild(self.guideLayer, -1)
            end

            if self.guideLayer and not data.flag then
                self.guideLayer:removeFromParent()
                self.guideLayer = nil
            end

            if data.flag then
                self.guideLayer:setVisible(true)
            end
        end,
		["GetTowerDataRsp"] = function(flag)
            if not self.towerMainLayer and flag then
                self.towerMainLayer = require("cp.view.scene.tower.TowerMainLayer"):create()
                self.layer_scene:addChild(self.towerMainLayer, 1)
            end

            if self.towerMainLayer and not flag then
                self.towerMainLayer:removeFromParent()
                self.towerMainLayer = nil
            end

            if flag then
                self.towerMainLayer:setVisible(true)
            end
        end,

        [cp.getConst("EventConst").OnNewGuideDouCheng] = function(evt)
            if evt.idx == -1 then	
                if self:checkNeedDouChengGuide() then
                    local apple_test_version = cp.getManualConfig("Net").apple_test_version
                    if apple_test_version == true then
                        cp.getManager("GDataManager"):finishNewGuideName("doucheng")
                    else
                        cp.getManager("ViewManager").openNewPlayerGuide("doucheng",0)
                    end
                end
            end
        end,

        [cp.getConst("EventConst").ChangeLeadRsp] = function(data)
            local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
            local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
            if cur_guide_module_name == "" and listStr.current == "" then
                self:checkNewGuide()
            end
        end,
		["GetPrimevalDataRsp"] = function(flag)
            if not self.primevalMainLayer and flag then
                self.primevalMainLayer = require("cp.view.scene.primeval.PrimevalMainLayer"):create()
                self.layer_scene:addChild(self.primevalMainLayer, 1)
            end

            if self.primevalMainLayer and not flag then
                self.primevalMainLayer:removeFromParent()
                self.primevalMainLayer = nil
            end

            if flag then
                self.primevalMainLayer:setVisible(true)
            end
        end,

        
        [cp.getConst("EventConst").ChatChannelRsp] = function(data)
            local broadcast_msg_list = cp.getUserData("UserChatData"):getValue("broadcast_msg_list")
			if broadcast_msg_list and table.nums(broadcast_msg_list) > 0 then
				cp.getManager("ViewManager").showBroadcast()
			end
        end,

        --打開vip界面
        [cp.getConst("EventConst").open_vip_view] = function(flag)
            if not self.VIPMainUI and flag then
                local VIPMainUI = require("cp.view.scene.world.vip.VIPMainUI"):create()
                self.VIPMainUI = VIPMainUI
                self.layer_scene:addChild(VIPMainUI, -1)
            end

            if self.VIPMainUI and not flag then
                self.VIPMainUI:removeFromParent()
                self.VIPMainUI = nil
            end

            if flag then
                self.VIPMainUI:setVisible(true)
            end
        end,

        --打開成就界面
        [cp.getConst("EventConst").open_achivement_view] = function(flag)
            if not self.AchivementMainLayer and flag then
                local AchivementMainLayer = require("cp.view.scene.world.achivement.AchivementMainLayer"):create()
                AchivementMainLayer:setCloseCallBack(function()
                    
                end)
                self.layer_scene:addChild(AchivementMainLayer, -1)
                self.AchivementMainLayer = AchivementMainLayer
            end

            if self.AchivementMainLayer and not flag then
                self.AchivementMainLayer:removeFromParent()
                self.AchivementMainLayer = nil
            end 

            if flag then
                self.AchivementMainLayer:setVisible(true)
            end

        end,
    }

end

function WorldScene:onInitView(...)
    
    self.layer_module = cc.Node:create()                --界面層 打開的模塊
    self:addChild(self.layer_module)

    self.layer_scene = cc.Node:create()                 --場景常駐界面父節點(top人物屬性，down六個按鈕及經驗條)
    self:addChild(self.layer_scene,1)
    

	--down
    local MajorDown = require "cp.view.scene.world.major.MajorDown"
	self.majorDown = MajorDown:create()
    self.majorDown:setUIButtonClickCallBack(handler(self,self.onDownButtonClicked))
    self.layer_scene:addChild(self.majorDown)

    --background
    local MajorLayer = require "cp.view.scene.world.major.MajorLayer"
    local majorLayer = MajorLayer:create()
    self.layer_module:addChild(majorLayer)

    --模塊
    self.cur_module = majorLayer
    self.cur_module_name = cp.getConst("SceneConst").MODULE_MajorMap


    local function onKeyReleased(keyCode, event)
        local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
        if cur_guide_module_name ~= nil and cur_guide_module_name ~= "" then
            cp.getManager("ViewManager").gameTip("新手指引中不能返回。")
            return
        end
        if keyCode == cc.KeyCode.KEY_BACK then
            if device.platform == "android" then
                self:onBackClick()
            end
        elseif keyCode == cc.KeyCode.KEY_MENU  then
            
        elseif keyCode == cc.KeyCode.KEY_F1 then
            if device.platform == "windows" then
                self:onBackClick()
            end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    local function onSceneComeBackForeground()
        log("onSceneComeBackForeground ")
        
        cp.getManager("SocketManager"):doDisConnect()
        cp.getManager("SocketManager"):doConnect()

        local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
        local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local info = {}
        info.zoneid = serverinfo.id
        info.token = cp.getUserData("UserLogin"):getValue("user_token")
        info.resetTime = majorRole.resetTime
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ReconnectReq, info)
        
    end
    local toForegroundListener = cc.EventListenerCustom:create("event_come_to_foreground",onSceneComeBackForeground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(toForegroundListener, self)
    local function onSceneEnterToBackground()
        log("onSceneEnterToBackground ")
        local now = cp.getManager("TimerManager"):getTime()
        cp.getUserData("UserRole"):setValue("lastEnterBackTime",now)
        log("lastEnterBackTime = " .. tostring(now))
    end
    local toBackgroundListener = cc.EventListenerCustom:create("event_come_to_background",onSceneEnterToBackground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(toBackgroundListener, self)
end

function WorldScene:onEnterScene()
    self:checkNewGuide()

    local broadcast_msg_list = cp.getUserData("UserChatData"):getValue("broadcast_msg_list")
    if broadcast_msg_list and table.nums(broadcast_msg_list) > 0 then
        cp.getManager("ViewManager").showBroadcast()
    end
end

function WorldScene:openModule(open_info)

    --先關閉之前的界面
    self:closeModule()

    --打開新界面
    self.cur_module = self:createModule(open_info)
    self.cur_module_name = open_info.name

    if open_info.name == cp.getConst("SceneConst").MODULE_WorldMap or
        open_info.name == cp.getConst("SceneConst").MODULE_JiangHu or    
        open_info.name == cp.getConst("SceneConst").MODULE_SkillSummary or
        open_info.name == cp.getConst("SceneConst").MODULE_MajorPackage or
        open_info.name == cp.getConst("SceneConst").MODULE_MajorRole or
        open_info.name == cp.getConst("SceneConst").MODULE_MenPai then
        open_info.isShowTop = false
    end

    
	--log(string.format("totaltime = %.6f",socket.gettime() - self.closeTime))
end

function WorldScene:createModule(open_info)
	local module
	if self.residentUI == nil then
		self.residentUI = {}
	end
	--常駐UI先從緩存取
    if self:checkResident(open_info.name) then
		module = self.residentUI[open_info.name]
		if module == nil then 
			module = require(open_info.name):create(open_info)
			self.residentUI[open_info.name] = module
            self.layer_module:addChild(module, 1)
        else
            local info = {name = open_info.name, visible = true}
            self:dispatchViewEvent(cp.getConst("EventConst").on_major_down_btn_clicked,info)
		end
		module:setVisible(true)
	else
		module = require(open_info.name):create(open_info)
		self.layer_module:addChild(module)
    end
    -- if open_info.auto_open_name then

    --     self:runAction(cc.Sequence:create(
    --         cc.DelayTime:create(0.1),
    --         cc.CallFunc:create(
    --             function()
    --             self:dispatchViewEvent(cp.getConst("EventConst").on_auto_open_ui,open_info)
    --             end
    --         )))
    -- end
	return module
end

function WorldScene:closeModule()
	--self.closeTime = socket.gettime()

    --關閉模塊界面
    if self.cur_module then
		--常駐UI不關閉
        if self:checkResident(self.cur_module_name) then
            local info = {name = self.cur_module_name, visible = false}
            self:dispatchViewEvent(cp.getConst("EventConst").on_major_down_btn_clicked,info)
			self.cur_module:setVisible(false) 
		else
			self.cur_module:removeFromParent(true)
			--模塊關閉時觸發，卸載不用的資源
			self.layer_scene:setVisible(true)
			--移除不用的緩存資源
			display.removeUnusedSpriteFrames()
			--移除所有配置表訊息，因為沒有引用計數，所以移除全部配置表訊息
			cp.cleanConfig()
		end
		self.cur_module = nil
		self.cur_module_name = nil
    end
end

function WorldScene:checkResident(module_name)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name ~= nil and cur_guide_module_name ~= "" then
        return false
    end
    if  module_name == cp.getConst("SceneConst").MODULE_SkillSummary or
        module_name == cp.getConst("SceneConst").MODULE_MajorPackage or
        module_name == cp.getConst("SceneConst").MODULE_MajorRole or
        --module_name == cp.getConst("SceneConst").MODULE_MajorMap or
        -- module_name == cp.getConst("SceneConst").MODULE_JiangHu or    
        module_name == cp.getConst("SceneConst").MODULE_MenPai then
		return true
    end
	return false
end

function WorldScene:doSomeThing()
    if self.scheduleEntryId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
        self.scheduleEntryId = nil
    end

    if self.wait_cmd == nil then
        return 
    end

    if self.wait_cmd.name == "open" then
        if self.wait_cmd.data.back_info ~= nil then
            table.insert(cp.getGameData("GameWorld").back_list,self.wait_cmd.data.back_info)
        end
        self:openModule(self.wait_cmd.data.open_info)
    elseif self.wait_cmd.name == "close" then
        table.arrClear(cp.getGameData("GameWorld").back_list)
        self:closeModule()
    elseif self.wait_cmd.name == "return" then
        local back_list = cp.getGameData("GameWorld").back_list
        if #back_list>0 then
            local back_info = table.arrPop(back_list)
            self:openModule(back_info)
        else
            self:closeModule()
        end
    end
end


function WorldScene:onDownButtonClicked(buttonName)
	
    if "Button_DouCheng"  == buttonName then
		if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_MajorMap then 
            local open_info = {name = cp.getConst("SceneConst").MODULE_MajorMap}
            self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
        end
    elseif "Button_MenPai"  == buttonName then
	    if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_MenPai then 
            local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai}
            self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
        end
    elseif "Button_JueSe"  == buttonName then
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		if roleAtt ~= nil then
			if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_MajorRole then 
            	local open_info = {name = cp.getConst("SceneConst").MODULE_MajorRole}
            	self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
        	end
		else
			--[[
			local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").GetRoleReq, req)
			]]
		end

    elseif "Button_BeiBao"  == buttonName then
		local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
		if roleItem ~= nil then
			if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_MajorPackage then 
				local open_info = {name = cp.getConst("SceneConst").MODULE_MajorPackage}
				self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
			end
		else
			--[[
			local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").GetRoleItemReq, req)
			]]
		end
    elseif "Button_WuXue"  == buttonName then
        if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_SkillSummary then 
            local open_info = {name = cp.getConst("SceneConst").MODULE_SkillSummary}
            self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
        end
        --[[
        if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_SkillSummary then 
            local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").GetAllSkillReq, req)
        end
        --]]
    elseif "Button_JiangHu"  == buttonName then
        if self.cur_module_name ~= cp.getConst("SceneConst").MODULE_JiangHu then 

            local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
            self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
        end
		
  end
end

function WorldScene:checkNewGuide()
    local guide_name,needGuid,step = cp.getManager("GDataManager"):getNextNewGuideName()
        --guide_name = "equip"
        --needGuid = true
        --step = 0
        if needGuid then
            local step,needGuid = self:adjustGuideStep(guide_name,step)
            if needGuid then
                cp.getManager("ViewManager").openNewPlayerGuide(guide_name,step)
            end
        end
        if not needGuid then
            if self.cur_module_name == cp.getConst("SceneConst").MODULE_MajorMap then
                if self:checkNeedDouChengGuide() then
                    local apple_test_version = cp.getManualConfig("Net").apple_test_version
                    if apple_test_version == true then
                        cp.getManager("GDataManager"):finishNewGuideName("doucheng")
                    else
                        cp.getManager("ViewManager").openNewPlayerGuide("doucheng",0)
                    end
                end
            end
        end
    return needGuid
end

function WorldScene:checkNeedDouChengGuide()
    local apple_test_version = cp.getManualConfig("Net").apple_test_version
    if apple_test_version == true then
        return false
    end
    
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    if string.find(listStr.finished,"equip")  then
        if not string.find(listStr.finished,"doucheng")  then 
            return true
        end
    end
    return false
end

function WorldScene:onBackClick()

    local messageBox = cp.getManager("ViewManager").getPopupGameMessageBox()
    if messageBox then
        return
    end

    local function exitCallBack(params)
        cp.getManager("ViewManager").gameTip("退出遊戲")
        
        if self.scheduleEntryId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
            self.scheduleEntryId = nil
        end

        cp.getManager("AppManager"):quit()
        cc.Director:getInstance():endToLua() 
    end

    if device.platform == "windows" then

    elseif device.platform == "android" then
        local channelName = cp.getManualConfig("Channel").channel
        if channelName == "xiaomi" or channelName == "xiaomi1" then 
            local args = {exitCallBack}
            local sig = "(I)V"
            local luaj = require("cocos.cocos2d.luaj")
            local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/MiSDK","miExit",args,sig) 
        end
    end
    cp.getManager("ViewManager").showGameMessageBox("系統消息","是否退出當前遊戲？",2,function()
        exitCallBack()
    end,nil)
     
end

--調整指引的步驟，並自動跳轉界面
function WorldScene:adjustGuideStep(name,step)
    local newStep = 0
    local needGuid = true
    if name == "menpai_wuxue" then
        if step >=14 then
            needGuid = false
        elseif step > 0 then
            newStep = 2
        end
    elseif name == "wuxue" then
        if step >20 then
            needGuid = false
        end
    elseif name == "story" then
        if step >=15 then
            needGuid = false
        elseif step == 14 then
            if self.cur_module_name == cp.getConst("SceneConst").MODULE_MajorMap then
                needGuid = false
            end
        end
    elseif name == "character" then
        if step >=27 then
            needGuid = false
        elseif step >=16 then--已強化
            newStep = 18
        end
    elseif name == "lottery" then
        if step >=28 then
            needGuid = false
        end
    elseif name == "wuxue_pos_change" then
        if step >=15 then
            needGuid = false
        elseif step >=6 then
            newStep = 6
        end
    elseif name == "mail" then
        if step >=10 then
            needGuid = false
        end
    elseif name == "equip" then
        if step >=35 then
            needGuid = false
        elseif step >=26 then
            newStep = 29
        elseif step >=12 then
            newStep = 1   
        end
    end
    if needGuid == false then
        cp.getManager("GDataManager"):finishNewGuideName(name)
    end
    return newStep,needGuid
end

return WorldScene
