local BScene = require "cp.view.ui.base.BScene"
local LoginScene = class("LoginScene",BScene)

function LoginScene:create()
	local scene = LoginScene.new()
	scene:doSomeThing()
    return scene
end

function LoginScene:initListEvent()
    self.listListeners = {  
		--guest login rsp
		[cp.getConst("EventConst").GuestRsp] = function(data)	
			cp.getManager("GDataManager"):saveAccount({ data.account, data.password })
			cp.getManager("GDataManager"):saveLastAccount({ data.account, data.password })
			cp.getUserData("UserLogin"):setValue("user_token",data.token)
    		if self.loginLayer then
                self.loginLayer:setVisible(false)
			end

            self:openEnterLayer()
		end,

		--account login rsp
		[cp.getConst("EventConst").LoginRsp] = function(data)	

			cp.getUserData("UserLogin"):setValue("user_token",data.token)
    		if self.loginLayer then
                self.loginLayer:setVisible(false)
			end

            self:openEnterLayer()
		end,

		--register rsp
		[cp.getConst("EventConst").RegisterRsp] = function(data)	
			--錯誤處理

			cp.getManager("GDataManager"):saveAccount({ data.account, data.password })
			cp.getManager("GDataManager"):saveLastAccount({ data.account, data.password })
			cp.getUserData("UserLogin"):setValue("user_token",data.token)
    		if self.loginLayer then
                self.loginLayer:setVisible(false)
			end
    		if self.registerLayer then
                self.registerLayer:setVisible(false)
			end

            self:openEnterLayer()
		end,

		--zone rsp
		[cp.getConst("EventConst").ZoneRsp] = function(data)	
			self:openServerSelectLayer()
		end,

		--create role rsp
		[cp.getConst("EventConst").CreateRsp] = function(data)	

			local token = cp.getUserData("UserLogin"):getValue("user_token")
			local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
			local req = {}
			req.token = token
			req.cutover = 0
			req.zoneid = serverinfo.id
			self:doSendSocket(cp.getConst("ProtoConst").EnterGameReq, req)
			if self.createLayer then
				self.createLayer:setVisible(false)
			end
		end,
		
		--enter game rsp
		[cp.getConst("EventConst").EnterGameRsp] = function(data)	
			if data.roleExist == 0 then  --沒有角色
				self:openCreateRoleLayer()

				cp.getUserData("UserLogin"):setValue("isNewRole",true)
			else
				cp.getManager("TimerManager"):resetTime(data.timeStamp,true) --伺服器時間
				
				cp.getUserData("UserVip"):resetVipInfo(data.vipInfo)  --vip訊息
				cp.getUserData("UserRole"):setValue("major_roleAtt", data.roleAtt) -- 角色屬性
				--cp.getUserData("UserRole"):setValue("guildAtt", data.guildAtt) -- 幫派屬性
				cp.getUserData("UserRole"):setValue("upgradeGift", data.upgradeGift) -- 升級禮包狀態
				cp.getUserData("UserRole"):setValue("fightGift", data.fightGift) -- 升級禮包狀態
				cp.getUserData("UserRole"):setValue("physicalGift", data.physicalGift)  

				cp.getUserData("UserItem"):resetAllItems(data.itemInfo)  --物品數據

				cp.getUserData("UserDailyData"):resetAllDailyData(data.dailyData) --日常任務數據

				cp.getUserData("UserRole"):setValue("fashion_data", data.fashion) --時裝數據
				
				cp.getUserData("UserRole"):resetNewplayerguiderList(data.roleAtt.lead) --新手指引進度

				cp.getUserData("UserLilian"):setValue("offline_result_list", data.exerCompress) --離線歷練數據
				-- dump(data.exerCompress)
				--[[
{
     "conductBad"  = 173
     "conductGood" = 122
     "itemNum" = {
         1 = 73
         2 = 74
         3 = 67
         4 = 70
         5 = 0
         6 = 0
     }
     "silver"      = 5690
     "trainPoint"  = 3192
 }
				]]

				--本地數據存儲
				cp.getManager("LocalDataManager"):setUser(data.roleAtt.account, data.roleAtt.id)

				if data.roleAtt.gangRank == 0 then
					cp.getManager("LocalDataManager"):setUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
				else
					local str = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
					if str == "0-0-0" then
						local now = cp.getManager("TimerManager"):getTime()
						str = os.date("%Y-%m-%d",now-24*60*60)
						cp.getManager("LocalDataManager"):setUserValue("redpoint","GangRankAward_firstGetDate",str)
					end
				end

				local channelName = cp.getManualConfig("Channel").channel
				if channelName == "lunplay" and data.roleAtt.lead == "" then --創建角色進入遊戲
					local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
					local server = lastServerInfo.name
					local server_id = "nzljh" .. tostring(lastServerInfo.id)
					local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
					-- local passport = cp.getUserData("UserLogin"):getValue("user_token")

					local platform = device.platform
					if LunPlay and platform == "ios" then
						LunPlay:appflyerJueSeChuangJian(major_roleAtt.id,server_id)
					end
					if platform == "android" then
						local params = {roleId = tostring(major_roleAtt.id), serverCode = tostring(server_id)}
						cp.getManager("ChannelManager"):onExtraFunction("roleCreate",params,nil)
					end
				end

				--跳過新手指引
				local skip_guide = cp.getUserData("UserLogin"):getValue("skip_guide")
				if skip_guide then
					cp.getManager("GDataManager"):finishAllNewGuide()

					cp.getUserData("UserLogin"):setValue("isNewRole",false)
				end
				
				self:initTA()
				if cp.getUserData("UserLogin"):getValue("isNewRole") then
					local talkText = [[
江湖
距離那件事
已然沉寂二十餘年
但平靜之下
暗流洶湧
隱有困獸蟄伏，即將甦醒……]]
	
					local NewGuideTypeWriter = require("cp.view.scene.newguide.NewGuideTypeWriter"):create(talkText)
					NewGuideTypeWriter:setFinishedCallBack(function()
							cp.getUserData("UserCombat"):setCombatType(cp.getConst("CombatConst").CombatType_Guide)
							cp.getUserData("UserCombat"):setCombatScene(1)
							local path = cc.FileUtils:getInstance():fullPathForFilename("res/combat_guide")
							local combat_result =  cc.FileUtils:getInstance():getStringFromFile(path)
							local result = cp.getManager("ProtobufManager"):decode2Table("protocal.CombatResult", gzip.decompress(combat_result))
							cp.getUserData("UserCombat"):setCombatResult(result)
							cp.getUserData("UserCombat"):setCombatScene(4)
							cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_COMBAT)
					end)
					self:addChild(NewGuideTypeWriter,100)
					TDGAMission:onBegin(cp.DataUtils.formatStoryInfo(1001, 0))
					TDGAAccount:setLevel(1)
				else
					cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_WORLD)
					cp.getManager("GDataManager"):loadSaveChatMsg()
				end
			end
		end,
    }
end

function LoginScene:onInitView( ... )
    --display.loadSpriteFrames("uiplist/ui_waiting.plist")
	self:addAnimation()
end

function LoginScene:initTalkingData()
	if TalkingDataGA then
		log("TalkingData not empty!")
		return
	end

	TalkingDataGA = {}
	TalkingDataGA.onStart = function()
	end
	TalkingDataGA.setVerboseLogDisabled = function()
	end
	TalkingDataGA.setVerboseLogEnabled = function()
	end
	TalkingDataGA.onEvent = function()
	end
	TalkingDataGA.setLocation = function()
	end
	TalkingDataGA.getDeviceId = function()
	end
	TalkingDataGA.onKill = function()
	end
	TalkingDataGA.onKill = function()
	end

	TDGAAccount = {}
	TDGAAccount.setAccount = function()
	end
	TDGAAccount.setAccountName = function()
	end
	TDGAAccount.setAccountType = function()
	end
	TDGAAccount.setLevel = function()
	end
	TDGAAccount.setGender = function()
	end
	TDGAAccount.setAge = function()
	end
	TDGAAccount.setGameServer = function()
	end

	TDGAMission = {}
	TDGAMission.onBegin = function()
	end
	TDGAMission.onCompleted = function()
	end
	TDGAMission.onFailed = function()
	end
	TDGAMission.onChargeRequest = function()
	end
	TDGAMission.onChargeSuccess = function()
	end
	TDGAMission.onReward = function()
	end

	TDGAItem = {}
	TDGAItem.onPurchase = function()
	end
	TDGAItem.onUse = function()
	end
end

function LoginScene:doSomeThing()
    cc.FileUtils:getInstance():purgeCachedEntries()
    local split = string.split
    for loadName, _ in pairs(package.loaded) do
       local tb = split(loadName,".")
      if tb[1]== "cp" then
           package.loaded[loadName] = nil
       end
	end

	self:initTalkingData()

	if device.platform == "ios" then
		local channelName = cp.getManualConfig("Channel").channel 
		TalkingDataGA:setVerboseLogDisabled()
		TalkingDataGA:onStart("F293CAE516C948BC9F6383031D24309A", channelName)
	end

    --重新載入新的lua文件
    require("cp.init")
 end

function LoginScene:onEnterScene()
    --1.play background music
    --cp.getManager("AudioManager"):changePlayBgMusic(3)

    --2.init channel
    local initResult,enterName = cp.getManager("ChannelManager"):init()
    if not initResult then
        log("channel init fail...")
        return
	end

    --3.show LoginLayer,if is android or ios, sdk will show it's self LoginLayer
    local platform = device.platform
    local cname = cp.getManualConfig("Channel").channel
    log("loginScene channel = ".. cname)
    log("loginScene platform = ".. platform)
    log("loginScene enterName = ".. enterName)
    local LoginLayer = nil
	if enterName ~= nil and enterName ~= "" then
		if platform == "windows" or platform == "mac" then
			platform = "desktop"
		end
        local path = "cp.view.channel."..platform.."."..enterName..".".."LoginLayer"
		log("loginScene path = ".. path)
        local function requireLoginLayer(path)
            LoginLayer =  require(path)
        end
        pcall(requireLoginLayer,path)
    end
  
    if LoginLayer then
        local loginLayer = LoginLayer:create()
        self:addChild(loginLayer)
        self.loginLayer = loginLayer
    
        local function login_callback( )
            log("login call back..")
        end
        cp.getManager("ChannelManager"):goLogin(login_callback)

		--login UI -> register UI
		local function showRegisterUI()
			if not self.registerLayer then
				local RegisterLayer = require "cp.view.scene.login.RegisterLayer"
				self.registerLayer = RegisterLayer:create()
				self:addChild(self.registerLayer, 1)

				--register UI -> login UI
				local function showLoginUI()
					self.registerLayer:setVisible(false)
					self.loginLayer:setVisible(true)
				end
				self.registerLayer:setShowLoginUICallback(showLoginUI)
				
			end
			self.loginLayer:setVisible(true)
			self.registerLayer:setVisible(true)
		end

		if self.loginLayer.setBtnClickCallBack then
			self.loginLayer:setBtnClickCallBack(function(btnName,info)
				if btnName == "Button_register" then
					showRegisterUI()
				elseif btnName == "Button_guest" then
					local msg = {}
					msg.imei = "imeixxxxxx"
					cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").GuestReq, msg)
				elseif btnName == "Button_login" then

					cp.getManager("GDataManager"):saveLastAccount({ info.account, info.password })
					
					local msg = {}
					msg.account = info.account
					msg.password = info.password
					cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").LoginReq, msg)
				end
			end)
		end
    end
	
	cp.getManager("AudioManager"):uncacheAll()

	cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_login,true)
	if true then --cp.updated then
		local layer = require("cp.view.scene.login.NoticeLayer"):create()
		self:addChild(layer, 100)
    end
	-- cp.getManager("AudioManager"):setMusicVolume(0.2)
end

function LoginScene:onExitScene()
end

function LoginScene:initTA()
	local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
	local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	TDGAAccount:setAccount(roleAtt.account)
	TDGAAccount:setAccountName(roleAtt.name)
	TDGAAccount:setAccountType(TDGAAccount.kAccountRegistered)
	TDGAAccount:setGameServer(serverinfo.id)
	TDGAAccount:setLevel(roleAtt.level)
end

function LoginScene:addAnimation()
    -- local armature = cp.getManager("ViewManager").createArmature("animation/other/denglu2.csb")
    -- if not armature then return armature end
    -- self:addChild(armature)
    -- armature:getAnimation():playWithIndex(0)
    -- armature:setPosition(cc.p(display.width / 2, display.height / 2))
end

function LoginScene:exit(sender)
    cp.getManager("ChannelManager"):quit()
end


function LoginScene:openCreateRoleLayer()
	self.enterLayer:setVisible(false)

	local function backButtonCallBack()
		self.enterLayer:setVisible(true)
		self.createLayer:setVisible(false)
	end

	if not self.createLayer then
		local CreateLayer = require "cp.view.scene.login.CreateLayer"
		self.createLayer = CreateLayer:create()
		self:addChild(self.createLayer)
		self.createLayer:setBackClickCallBack(backButtonCallBack)
	else
		self.createLayer:setVisible(true)
	end
end

-- open enter game ui
function LoginScene:openEnterLayer()
	local function callBack(serverInfo)
		local serverList = cp.getUserData("UserLogin"):getValue("serverList")
		if serverList == nil or table.nums(serverList) == 0 then
			cp.getManager("SocketManager"):doDisConnect()
			cp.getManager("SocketManager"):doConnectLogin()
			cp.getManager("SocketManager"):setReSendEnabel()
			local msg = {}
			cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ZoneReq, msg)
		else
			self.selectLayer:setVisible(true)
			self.enterLayer:setVisible(false)
		end
	end

    if not self.enterLayer then
        local enterLayer = require "cp.view.scene.login.EnterLayer"
        self.enterLayer = enterLayer:create()
        self:addChild(self.enterLayer)

		self.enterLayer:setLastserverClickCallBack(callBack)
    end
    self.enterLayer:setVisible(true)
end

function LoginScene:openServerSelectLayer( )
	self.enterLayer:setVisible(false)

	local function callBack(serverInfo)
		self.selectLayer:setVisible(false)
		self.enterLayer:setVisible(true)
		self.enterLayer:initLastSelectServerInfo(serverInfo)
	end
	if not self.selectLayer then
		self.selectLayer = require("cp.view.scene.login.SelectLayer"):create()
		self:addChild(self.selectLayer,1)
		self.selectLayer:setCloseCallBack(callBack)
	end
end


return LoginScene
