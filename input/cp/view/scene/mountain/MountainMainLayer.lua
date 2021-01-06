local BLayer = require "cp.view.ui.base.BLayer"
local MountainMainLayer = class("MountainMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

local CareerFlag = {
	[0] = "ui_mountain_module02_role_shaolin01.png",
	[1] = "ui_mountain_module02_role_wudang01.png",
	[2] = "ui_mountain_module02_role_gaibang01.png",
	[3] = "ui_mountain_module02_role_emei01.png",
	[4] = "ui_mountain_module02_role_badao01.png",
	[5] = "ui_mountain_module02_role_tianshan01.png",
	[6] = "ui_mountain_module02_role_mingjiao01.png",
	[7] = "ui_mountain_module02_role_wudu01.png",
}

local phaseStateImg = {
	[0] = "ui_mountain_module_hslj_18.png",
	[1] = "ui_mountain_module_hslj_12.png",
	[2] = "ui_mountain_module_hslj_10.png",
	[3] = "ui_mountain_module_hslj_9.png",
	[4] = "ui_mountain_module_hslj_11.png",
	[5] = "ui_mountain_module_hslj_8.png",
	[6] = "ui_mountain_module_hslj_7.png",
	[7] = "ui_mountain_module_hslj_19.png",
}

local phaseStateBottomGrayImg = {
    [2] = "ui_mountain_module_hslj_21.png",
    [3] = "ui_mountain_module_hslj_21.png",
    [4] = "ui_mountain_module_hslj_21.png",
    [5] = "ui_mountain_module_hslj_21.png",
    [6] = "ui_mountain_module_hslj_23.png",
}

function MountainMainLayer:create()
	local scene = MountainMainLayer.new()
	return scene
end

function MountainMainLayer:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").GetMountainDataRsp] = function(data)
			self:updateMountainMainView()
		end,
		[cp.getConst("EventConst").GetMountainPlayerListRsp] = function(data)
            self:updateMountainMainView()
			self:updateControlView()
		end,
		[cp.getConst("EventConst").SignUpMountainRsp] = function(data)
			self:updateControlView()
		end,
		[cp.getConst("EventConst").MountainGuessRsp] = function(data)
			self:updateMountainMainView()
			self:updateControlView()
		end,
		[cp.getConst("EventConst").GetMountainPhaseStateRsp] = function(data)
            self:updateMountainMainView()
			self:updateControlView()
		end,
		[cp.getConst("EventConst").EnemyFightRsp] = function(data)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
        [cp.getConst("EventConst").ViewPlayerRsp] = function(data)
            local function closeCallBack(btnName)
				if "Button_QieCuo" == btnName then
					
					local sins_max = cp.getManager("ConfigManager").getItemByKey("Other", "sins_max_per_day"):getValue("IntValue")
                    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
                    if major_roleAtt.sins and major_roleAtt.sins >= sins_max then
                        cp.getManager("ViewManager").gameTip("當前罪惡值已達到" .. tostring(sins_max) .. "，不允許進行比試")
                        return
                    end
            
					local function confirmFunc()
						self.fightInfo = {name=data.roleAtt.name}
                        local req = {}
						req.id = data.roleID
						req.zone = data.zoneID
						self:doSendSocket(cp.getConst("ProtoConst").EnemyFightReq, req)
                    end
            
                    local function cancleFunc()
                    end
                    
                    local content = "比試會增加5點罪惡值，是否繼續比試？"
                    cp.getManager("ViewManager").showGameMessageBox("系統提示",content,2,confirmFunc,cancelFunc)
				end
			end
			cp.getManager("ViewManager").showOtherRoleInfo(data,closeCallBack)
		end,
		["UpdateMountainGuideRsp"] = function(proto)
			self:runGuideStep()
		end,
	}
end

--初始化界面，以及設定界面元素標籤
function MountainMainLayer:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_mountain/uicsb_mountain_main.csb")
	self.rootView:setPosition(cc.p(0, 0))
	self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	
	--一開始顯示武學抽獎界面
	self.mode = 1
	
	local childConfig = {
		["Panel_root.ScrollView_Main"] = {name = "ScrollView_Main"},
		["Panel_root.ScrollView_Main.Image_1"] = {name = "Image_1"},
		["Panel_root.ScrollView_Main.Image_1.Image_Progress"] = {name = "Image_Progress"},
		["Panel_root.ScrollView_Main.Image_1.Text_Guess"] = {name = "Text_Guess"},
		["Panel_root.ScrollView_Main.Image_1.Text_GuessCount"] = {name = "Text_GuessCount"},
		["Panel_root.ScrollView_Main.Image_1.Text_GuessNotice"] = {name = "Text_GuessNotice"},
		["Panel_root.ScrollView_Main.Image_1.Button_Back"] = {name = "Button_Back", click = "onBtnClick"},
        ["Panel_root.ScrollView_Main.Image_1.Button_Sign"] = {name = "Button_Sign", click = "onBtnClick"},
		["Panel_root.ScrollView_Main.Image_1.Button_Rule"] = {name = "Button_Rule", click = "onBtnClick"},
		["Panel_root.ScrollView_Main"] = {name = "ScrollView_Main"},
		["Panel_root.ScrollView_Main.Panel_RightState6"] = {name = "Panel_RightState6"},
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self, self.rootView, childConfig)
	self:initMountainMainView()
    local scale = display.height/1280
    self.ScrollView_Main:setScale(scale)
    local size = self.ScrollView_Main:getSize()
    size.width = size.width / scale
    self.ScrollView_Main:setSize(size)
    self.ScrollView_Main:setScrollBarEnabled(false)
    self.guessDuration = tonumber(string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("MountainConfig"), ";")[1])*60
    ccui.Helper:doLayout(self.rootView)
    self.ScrollView_Main:jumpToPercentHorizontal(50)
end

function MountainMainLayer:updatePhaseState(phaseState)
    local phase = cp.getUserData("UserMountain"):getValue("CurrentPhase")
    local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", phaseState)
    local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(phaseState)

    local delayTime = phaseStateInfo.state_begin + self.guessDuration - cp.getManager("TimerManager"):getTime()
    self.ScrollView_Main:stopAllActions()

    log("updatePhaseState after "..delayTime.." seconds")
    if delayTime < 0 then
        delayTime = 0
    end

    self.ScrollView_Main:runAction(cc.Sequence:create(
        cc.DelayTime:create(delayTime+2),
        cc.CallFunc:create(function()
            local req = {}
            req.phase = phase
            req.phase_state = phaseState
            req.need_all = true
            self:doSendSocket(cp.getConst("ProtoConst").GetMountainPhaseStateReq, req)
    end)))
end

function MountainMainLayer:initPhaseState(phaseState)
    local phase = cp.getUserData("UserMountain"):getValue("CurrentPhase")
    local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", phaseState-1)
    local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(phaseState-1)

    local beginTime = string.split(phaseStateEntry:getValue("PhaseBegin"), ":")
    beginTime[1], beginTime[2] = tonumber(beginTime[1]), tonumber(beginTime[2])
    local endTime = string.split(phaseStateEntry:getValue("PhaseEnd"), ":")
    endTime[1], endTime[2] = tonumber(endTime[1]), tonumber(endTime[2])
    local delayTime = phaseStateInfo.state_begin + (endTime[1]-beginTime[1])*3600+(endTime[2]-beginTime[2])*60 - cp.getManager("TimerManager"):getTime()
    self.ScrollView_Main:stopAllActions()

    log("initPhaseState after "..delayTime.." seconds")
    if delayTime < 0 then
        delayTime = 0
    end

    self.ScrollView_Main:runAction(cc.Sequence:create(
        cc.DelayTime:create(delayTime+2),
        cc.CallFunc:create(function()
            local req = {}
            req.phase = phase
            req.phase_state = phaseState
            req.need_all = true
            self:doSendSocket(cp.getConst("ProtoConst").GetMountainPhaseStateReq, req)
    end)))
end

function MountainMainLayer:updateControlView()
    local mountainData = cp.getUserData("UserMountain"):getValue("MountainData")
    local currentState = cp.getUserData("UserMountain"):getValue("CurrentState")
    local currentPhase = cp.getUserData("UserMountain"):getValue("CurrentPhase")

    if mountainData.signed then
        self.Button_Sign:getChildByName("Text_1"):setString("參賽中")
        cp.getManager("ViewManager").setEnabled(self.Button_Sign, false)
        cp.getManager("ViewManager").removeRedDot(self.Button_Sign)
    else
        self.Button_Sign:getChildByName("Text_1"):setString("報  名")
        if currentState == 0 then
            cp.getManager("ViewManager").addRedDot(self.Button_Sign,cc.p(174,50))
            cp.getManager("ViewManager").setEnabled(self.Button_Sign, true)
        else
            cp.getManager("ViewManager").removeRedDot(self.Button_Sign)
            cp.getManager("ViewManager").setEnabled(self.Button_Sign, false)
        end
    end

    local stateImg = phaseStateImg[currentState]
    self.Image_Progress:setVisible(true)
    self.Image_Progress:loadTexture(stateImg, ccui.TextureResType.plistType)
    self.Text_Guess:setVisible(false)
    self.Text_GuessCount:setVisible(false)
    if currentState == 7 then
        self.Text_GuessNotice:setString("比賽已完成")
        return
    end
    
    local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", currentState)
    local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(currentState)

    local currentGuessList = cp.getUserData("UserMountain"):getPhaseGuessList(currentState)
    local guessConfig = string.split(phaseStateEntry:getValue("GuessInfo"), ";")

    local beginTime = string.split(phaseStateEntry:getValue("PhaseBegin"), ":")
    beginTime[1], beginTime[2] = tonumber(beginTime[1]), tonumber(beginTime[2])
    local endTime = string.split(phaseStateEntry:getValue("PhaseEnd"), ":")
    endTime[1], endTime[2] = tonumber(endTime[1]), tonumber(endTime[2])

    local guessDuration = 0
    if currentState >= 2 and currentState <= 6 then
        self.Text_GuessCount:setString(tonumber(guessConfig[1]-#currentGuessList))
        guessDuration = self.guessDuration
    else
        self.Text_Guess:setVisible(false)
        self.Text_GuessCount:setVisible(false)
    end

    local guessBeginTime = phaseStateInfo.state_begin
    local guessEndTime = phaseStateInfo.state_begin + guessDuration
    local phaseStateEndTime = phaseStateInfo.state_begin + (endTime[1]-beginTime[1])*60*60+(endTime[2]-beginTime[2])*60
    local now = cp.getManager("TimerManager"):getTime()
    log("state_begin="..phaseStateInfo.state_begin..",time="..cp.getManager("TimerManager"):getTime())
    if now >= guessBeginTime and now < guessEndTime then
        self.Text_Guess:setVisible(true)
        self.Text_GuessCount:setVisible(true)
        self.Image_Progress:loadTexture("ui_mountain_module_hslj_24.png", ccui.TextureResType.plistType)
        self.Text_GuessNotice:setVisible(true)
        self.Text_GuessNotice:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            local remainGuessTime =  guessEndTime - cp.getManager("TimerManager"):getTime()
            if remainGuessTime <= 0 then
                self.Text_GuessNotice:setVisible(false)
                self.Text_GuessNotice:stopAllActions()
                return
            end
            local minutes = math.floor(remainGuessTime/60)
            local seconds = remainGuessTime % 60
            self.Text_GuessNotice:setString(string.format("%s助威倒計時%02d:%02d", phaseStateEntry:getValue("PhaseName"), minutes, seconds))
        end))))
    elseif now >= guessEndTime and now < phaseStateEndTime then
        self.Text_GuessNotice:setVisible(true)
        self.Text_GuessNotice:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            local remainGuessTime =  phaseStateEndTime - cp.getManager("TimerManager"):getTime()
            if remainGuessTime <= 0 then
                self.Text_GuessNotice:setVisible(false)
                self.Text_GuessNotice:stopAllActions()
                return
            end
            local hours = math.floor(remainGuessTime/3600)
            local minutes = math.floor((remainGuessTime%3600)/60)
            local seconds = remainGuessTime % 60
            if hours > 0 then
                self.Text_GuessNotice:setString(string.format("%s倒計時%02d:%02d:%02d", phaseStateEntry:getValue("PhaseName"), hours, minutes, seconds))
            else
                self.Text_GuessNotice:setString(string.format("%s倒計時%02d:%02d", phaseStateEntry:getValue("PhaseName"), minutes, seconds))
            end
        end))))
    else
        self.Text_GuessNotice:setVisible(false)
        self.Text_GuessNotice:stopAllActions()
    end
end

function MountainMainLayer:initMountainMainView()
    for panelIndex = 2, 6 do
        local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", panelIndex)
		local leftPanel = self.ScrollView_Main:getChildByName("Panel_LeftState" .. panelIndex)
		self["Panel_LeftState" .. panelIndex] = leftPanel
		local rightPanel = self.ScrollView_Main:getChildByName("Panel_RightState" .. panelIndex)
		self["Panel_RightState" .. panelIndex] = rightPanel
        if leftPanel then
            rightPanel:setPosition(2160 - leftPanel:getPositionX(), 0)
            leftPanel:setVisible(false)
        end

        if rightPanel then
            rightPanel:setVisible(false)
        end

        if panelIndex ~= 6 then
            rightPanel:setFlippedX(true)
        end
        
        local playerNum = math.pow(2, 7 - panelIndex)
        log("panelIndex="..panelIndex..",num="..playerNum)
		for i = 0, playerNum / 2 - 1 do
            local panel = nil
            local side = "left"
            local flipped = false
			if i <= playerNum / 4 - 1 then
				panel = leftPanel
			else
                panel = rightPanel
                side = "right"
                flipped = true
            end
            
            if panelIndex == 6 then flipped = false end
            
            local nodeIndex = i%(playerNum/4)
            --log("side="..side..",node="..nodeIndex)
			local group = panel:getChildByName(string.format("Node_Group%02d", nodeIndex))
			local btnWatch = group:getChildByName("Button_Watch")
			local playerLeft = group:getChildByName("Image_PlayerLeft")
            local playerRight = group:getChildByName("Image_PlayerRight")

            btnWatch:setVisible(false)
            btnWatch:getChildByName("Text_3"):setFlippedX(flipped)
			
			local leftName = playerLeft:getChildByName("Text_Name")
			local leftFlag = playerLeft:getChildByName("Image_Flag")
			local leftCareer = playerLeft:getChildByName("Image_Career")
			leftName:setString("")
            leftFlag:setVisible(false)
            leftCareer:setVisible(false)
            local imgState = nil
            local imgTime = nil
            if panelIndex > 3 then
                imgState = group:getChildByName("Image_State")
                imgTime = group:getChildByName("Image_Time")
                imgTime:getChildByName("Text_1"):setString(string.format("%s-%s", phaseStateEntry:getValue("PhaseBegin"), phaseStateEntry:getValue("PhaseEnd")))
                imgState:setFlippedX(flipped)
                imgTime:setFlippedX(flipped)
            elseif panelIndex >=2 and panelIndex <= 3 then
                imgState = panel:getChildByName("Image_State")
                imgTime = panel:getChildByName("Image_Time")
                imgTime:getChildByName("Text_1"):setString(string.format("%s-%s", phaseStateEntry:getValue("PhaseBegin"), phaseStateEntry:getValue("PhaseEnd")))
                imgState:setFlippedX(flipped)
                imgTime:setFlippedX(flipped)
            end
			
            imgTime:getChildByName("Text_1"):setString(string.format("%s-%s", phaseStateEntry:getValue("PhaseBegin"), phaseStateEntry:getValue("PhaseEnd")))
            imgTime:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
            imgState:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
            imgState:setFlippedX(flipped)
            imgTime:setFlippedX(flipped)

			local rightName = playerRight:getChildByName("Text_Name")
			local rightFlag = playerRight:getChildByName("Image_Flag")
            local rightCareer = playerRight:getChildByName("Image_Career")
			rightName:setString("")
			rightFlag:setVisible(false)
			rightCareer:setVisible(false)
            if panelIndex > 3 then
                local imgState = group:getChildByName("Image_State")
                local imgTime = group:getChildByName("Image_Time")
                --imgState:getChildByName("Text_1"):setString(phaseStateEntry:getValue("PhaseName"))
                imgTime:getChildByName("Text_1"):setString(string.format("%s-%s", phaseStateEntry:getValue("PhaseBegin"), phaseStateEntry:getValue("PhaseEnd")))
                imgState:setFlippedX(flipped)
                imgTime:setFlippedX(flipped)
            end

            rightName:setFlippedX(flipped)
            rightFlag:setFlippedX(flipped)
            rightCareer:setFlippedX(flipped)

            leftName:setFlippedX(flipped)
            leftFlag:setFlippedX(flipped)
            leftCareer:setFlippedX(flipped)
		end
	end
end

function MountainMainLayer:updateMountainMainView()
	local showPhase = cp.getUserData("UserMountain"):getValue("ShowPhase")
	local currentPhase = cp.getUserData("UserMountain"):getValue("CurrentPhase")
	local currentState = cp.getUserData("UserMountain"):getValue("CurrentState")
	
	local showState = currentState
	if showPhase ~= currentPhase or currentState > showState then
		showState = 7
	end
	
	local nextState = showState
	if showState > 6 then
		nextState = 6
	end
    
    local innerContainerWidth = 0
    for i = 0, 1 do
        local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(i)
        if phaseStateInfo then
            if i == currentState then
                self:initPhaseState(i+1)
            end
        end
    end
	for i = 2, nextState do
        local width = self:updatePlayersPanel(i, currentState)
        innerContainerWidth = innerContainerWidth + width
    end
    
	for i = nextState + 1, 6 do
		local panelLeft = self["Panel_LeftState" .. i]
		local panelRight = self["Panel_RightState" .. i]
		if panelLeft then
			panelLeft:setVisible(true)
		end
		if panelRight then
			panelRight:setVisible(true)
		end
	end
	
	self:updatePlayerTopPanel()
end

function MountainMainLayer:updatePlayerTopPanel()
	local imgTopHead = self.Panel_RightState6:getChildByName("Image_TopHead")
    local imgTopPlayer = self.Panel_RightState6:getChildByName("Image_TopPlayer")
    
	local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(6)
	imgTopHead:setVisible(false)
	imgTopPlayer:setVisible(false)
	if not phaseStateInfo or not phaseStateInfo.round_list then
		return
	end
	
    local currentStatus = self:getPhaseStateStatus(6)
    if currentStatus ~= 2 then
        return
    end

	imgTopHead:setVisible(true)
    imgTopPlayer:setVisible(true)
    
    local playerInfo = phaseStateInfo.player_list[1]
    if not playerInfo.flag then
        playerInfo = phaseStateInfo.player_list[2]
    end

    cp.getManager("ViewManager").initButton(imgTopHead:getChildByName("Image_Icon"), function()
		local req = {}
		req.roleID = playerInfo.id
		req.zoneID = 0
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
    end)
	
    imgTopHead:getChildByName("Image_Icon"):loadTexture(cp.DataUtils.getModelFace(playerInfo.face))
    imgTopPlayer:getChildByName("Image_Career"):loadTexture(CareerFlag[playerInfo.career], ccui.TextureResType.plistType)
    imgTopPlayer:getChildByName("Text_Name"):setString(playerInfo.name)
end

--0為助威，1為觀戰，2為錄像
function MountainMainLayer:getPhaseStateStatus(phaseState)
	local showPhase = cp.getUserData("UserMountain"):getValue("ShowPhase")
	local currentPhase = cp.getUserData("UserMountain"):getValue("CurrentPhase")
	local currentState = cp.getUserData("UserMountain"):getValue("CurrentState")
	if showPhase ~= currentPhase or currentState > phaseState then
		return 2
	end
	
	if currentState ~= phaseState then
		return 2
	end
	
	local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", phaseState)
	local phaseEnd = string.split(phaseStateEntry:getValue("PhaseEnd"), ":")
	local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(phaseState)
    if not phaseStateInfo then return nil end
    local now = cp.getManager("TimerManager"):getTime()
	if now > phaseStateInfo.state_begin and now < phaseStateInfo.state_begin + self.guessDuration then
		return 0
	end
	
	return 1
end

function MountainMainLayer:updatePlayersPanel(phaseState, currentState)
	local panelLeft = self["Panel_LeftState" .. phaseState]
    local panelRight = self["Panel_RightState" .. phaseState]
    local contentWidth = 0
    if panelLeft then
        contentWidth = contentWidth + panelLeft:getContentSize().width
        panelLeft:setVisible(true)
    end

    if panelRight then
        contentWidth = contentWidth + panelRight:getContentSize().width
        panelRight:setVisible(true)
    end
	log("phaseState=" .. phaseState)
	local currentStatus = self:getPhaseStateStatus(phaseState)
    local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(phaseState)
    local guessList = cp.getUserData("UserMountain"):getPhaseGuessList(phaseState) or {}
	if not phaseStateInfo then
		return 0
    end
    local playerList = phaseStateInfo.player_list
    if playerList == nil then return end
    --dump(playerList)
    local pairList = {}
    if phaseStateInfo.round_list[1] and phaseStateInfo.round_list[1] and phaseStateInfo.round_list[1].pair_list then
        pairList = phaseStateInfo.round_list[1].pair_list
    end

    if #pairList == 0 and phaseState ~= 7 and phaseState == currentState then
        self:updatePhaseState(phaseState, false)
    end

    if #pairList > 0 and phaseState ~= 7 and phaseState == currentState then
        self:initPhaseState(phaseState+1, true)
    end

    local playerNum = #playerList
	for i = 0, playerNum / 2 - 1 do
		local leftPlayerInfo = playerList[i * 2 + 1]
        local rightPlayerInfo = playerList[i * 2 + 2]
        local pairInfo = pairList[i+1]
		local panel = nil
		if i <= playerNum / 4 - 1 then
			panel = panelLeft
		else
			panel = panelRight
		end
		
        local nodeIndex = i%(playerNum/4)
		local group = panel:getChildByName(string.format("Node_Group%02d", nodeIndex))
		local btnWatch = group:getChildByName("Button_Watch")
		local playerLeft = group:getChildByName("Image_PlayerLeft")
		local playerRight = group:getChildByName("Image_PlayerRight")
        
        local isLeftGuess = table.indexof(guessList, leftPlayerInfo.id) ~= false
        local isRightGuess = table.indexof(guessList, rightPlayerInfo.id) ~= false
        if phaseState > 3 then
            local imgState = group:getChildByName("Image_State")
            local imgTime = group:getChildByName("Image_Time")
            if phaseState == currentState then
                imgState:getChildByName("Text_1"):setTextColor(cc.c4b(255,231,136,255))
                imgTime:getChildByName("Text_1"):setTextColor(cc.c4b(255,231,136,255))
            else
                imgState:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
                imgTime:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
            end
        elseif phaseState <=3 and phaseState >=2 then
            local imgState = panel:getChildByName("Image_State")
            local imgTime = panel:getChildByName("Image_Time")
            if phaseState == currentState then
                imgState:getChildByName("Text_1"):setTextColor(cc.c4b(255,231,136,255))
                imgTime:getChildByName("Text_1"):setTextColor(cc.c4b(255,231,136,255))
            else
                imgState:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
                imgTime:getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
            end
        end

        if phaseState <= currentState then
            btnWatch:setVisible(true)
        end

		local leftName = playerLeft:getChildByName("Text_Name")
		local leftFlag = playerLeft:getChildByName("Image_Flag")
		local leftCareer = playerLeft:getChildByName("Image_Career")
		local rightName = playerRight:getChildByName("Text_Name")
		local rightFlag = playerRight:getChildByName("Image_Flag")
        local rightCareer = playerRight:getChildByName("Image_Career")
        
		leftName:setString(leftPlayerInfo.name)
		leftCareer:loadTexture(CareerFlag[leftPlayerInfo.career], ccui.TextureResType.plistType)
        leftCareer:setVisible(true)
        leftFlag:setVisible(false)
        rightFlag:setVisible(false)
		
		if currentStatus == 0 then
            leftFlag:setVisible(isLeftGuess)
            rightFlag:setVisible(isRightGuess)
            btnWatch:getChildByName("Text_3"):setString("助\n威")
            btnWatch:getChildByName("Text_3"):setTextColor(cc.c4b(244,223,196,255))
            local textureName = "ui_mountain_module14_wuxue_fenxianganniu01.png"
            btnWatch:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
            if isLeftGuess or isRightGuess then
                btnWatch:setVisible(false)
            else
                btnWatch:setVisible(true)
            end
		elseif currentStatus == 1 then
            btnWatch:setVisible(true)
			btnWatch:getChildByName("Text_3"):setString("觀\n戰")
            btnWatch:getChildByName("Text_3"):setTextColor(cc.c4b(80,44,8,255))
            local textureName = "ui_mountain_module14_wuxue_fenxianganniu02.png"
            btnWatch:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		else
            btnWatch:setVisible(true)
			btnWatch:getChildByName("Text_3"):setString("錄\n像")
            btnWatch:getChildByName("Text_3"):setTextColor(cc.c4b(80,44,8,255))
            local textureName = "ui_mountain_module14_wuxue_fenxianganniu02.png"
            btnWatch:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		end
		
        cp.getManager("ViewManager").initButton(btnWatch, function()
            local layer = require("cp.view.scene.mountain.MountainGuessLayer"):create(phaseState, i)
            self:addChild(layer, 100)
        end, 1)

		rightName:setString(rightPlayerInfo.name)
		rightCareer:loadTexture(CareerFlag[rightPlayerInfo.career], ccui.TextureResType.plistType)
        rightCareer:setVisible(true)
        
        if currentStatus == 2 then
            if not leftPlayerInfo.flag then
                playerLeft:setColor(cc.c4b(150,150,150,255))
            else
                playerLeft:setColor(cc.c4b(255,255,255,255))
		    end
		
		    if not rightPlayerInfo.flag then
                playerRight:setColor(cc.c4b(150,150,150,255))
            else
                playerRight:setColor(cc.c4b(255,255,255,255))
            end
        end
        
        local leftImgLine1 = playerLeft:getChildByName("Image_Line1")
        local leftImgLine2 = playerLeft:getChildByName("Image_Line2")
        local rightImgLine1 = playerRight:getChildByName("Image_Line1")
        local rightImgLine2 = playerRight:getChildByName("Image_Line2")
        if pairInfo and currentStatus == 2 and phaseState ~= 6 then
            local imgLine1 = nil
            if pairInfo.result == 1 then
                imgLine1 = leftImgLine1
                imgLine2 = leftImgLine2
                playerLeft:setZOrder(10)
                playerRight:setZOrder(1)
            else
                imgLine1 = rightImgLine1
                imgLine2 = rightImgLine2
                playerLeft:setZOrder(1)
                playerRight:setZOrder(10)
            end
            imgLine1:loadTexture("ui_mountain_module_hslj_28.png", ccui.TextureResType.plistType)
            imgLine2:loadTexture("ui_mountain_module_hslj_28.png", ccui.TextureResType.plistType)
            imgLine1:setScale9Enabled(true)
            imgLine2:setScale9Enabled(true)
            imgLine1:ignoreContentAdaptWithSize(false)
            imgLine2:ignoreContentAdaptWithSize(false)
            imgLine1:setCapInsets(cc.rect(2,15,1,1))
            imgLine2:setCapInsets(cc.rect(2,15,1,1))
        end
    end
    
    return contentWidth
end

function MountainMainLayer:onBtnClick(btn)
	local nodeName = btn:getName()
	if nodeName == "Button_Back" then
		self:dispatchViewEvent(cp.getConst("EventConst").GetMountainPlayerListRsp, false)
	elseif nodeName == "Button_Hide" then
		self.Image_1:setVisible(not self.Image_1:isVisible())
	elseif nodeName == "Button_Sign" then
        self:doSendSocket(cp.getConst("ProtoConst").SignUpMountainReq, {})
    elseif nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_mountain_rule.xml")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("mountain_rule", desc)
        self:addChild(layer, 100)
	end
end

function MountainMainLayer:onEnterScene()
    self:updateControlView()
	self:updateMountainMainView()
	self:runGuideStep()
end

function MountainMainLayer:onExitScene()
	self:unscheduleUpdate()
end

function MountainMainLayer:runGuideStep()
	self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
	local guideStep = cp.getUserData("UserMountain"):getValue("MountainData").guide_step
	local contentTable = require("cp.story.MountainGuide")[guideStep]
    if not contentTable then
        if guideStep == 1 then
            local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Button_Sign, 1)
            guideLayer:setTouchCallback(function()
                guideLayer:removeFromParent()
                local req = {}
                req.step = guideStep
                self:doSendSocket(cp.getConst("ProtoConst").UpdateMountainGuideReq, req)
            end)
        else
            return
        end
	else
		local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 0.5)
		gamePopTalk:setPosition(cc.p(display.width/2,0))
		gamePopTalk:resetTalkText(contentTable)
		gamePopTalk:resetBgOpacity(150)
		gamePopTalk:setFinishedCallBack(function()
			gamePopTalk:removeFromParent()
			local req = {}
			req.step = guideStep
			self:doSendSocket(cp.getConst("ProtoConst").UpdateMountainGuideReq, req)
		end)
		gamePopTalk:hideSkip()
		self:addChild(gamePopTalk, 100)
	end
end

return MountainMainLayer 