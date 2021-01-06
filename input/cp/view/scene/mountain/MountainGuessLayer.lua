local BLayer = require "cp.view.ui.base.BLayer"
local MountainGuessLayer = class("MountainGuessLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function MountainGuessLayer:create(phaseState, pairIndex)
	local scene = MountainGuessLayer.new()
	scene.phaseState = phaseState
	scene.pairIndex = pairIndex
	scene:updateMountainGuessView()
	return scene
end

function MountainGuessLayer:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").GetCombatDataRsp] = function(proto)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		[cp.getConst("EventConst").MountainGuessRsp] = function(data)
			self:updateMountainGuessView()
		end,
	}
end

--初始化界面，以及設定界面元素標籤
function MountainGuessLayer:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_mountain/uicsb_mountain_pair.csb")
	self.rootView:setPosition(cc.p(0, 0))
	self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	
	--一開始顯示武學抽獎界面
	self.mode = 1
	
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click = "onBtnClick"},
        ["Panel_root.Image_1.Image_LeftHead"] = {name = "Image_LeftHead"},
        ["Panel_root.Image_1.Image_LeftName"] = {name = "Image_LeftName"},
		["Panel_root.Image_1.Button_LeftRecord"] = {name = "Button_LeftRecord", click = "onBtnClick"},
		["Panel_root.Image_1.Button_LeftAttr"] = {name = "Button_LeftAttr", click = "onBtnClick"},
		["Panel_root.Image_1.Text_WinGold"] = {name = "Text_WinGold"},
		["Panel_root.Image_1.Text_WinPrestige"] = {name = "Text_WinPrestige"},
		["Panel_root.Image_1.Text_LoseGold"] = {name = "Text_LoseGold"},
		["Panel_root.Image_1.Text_LosePrestige"] = {name = "Text_LosePrestige"},
        ["Panel_root.Image_1.Image_RightHead"] = {name = "Image_RightHead"},
        ["Panel_root.Image_1.Image_RightName"] = {name = "Image_RightName"},
		["Panel_root.Image_1.Button_RightRecord"] = {name = "Button_RightRecord", click = "onBtnClick"},
		["Panel_root.Image_1.Button_RightAttr"] = {name = "Button_RightAttr", click = "onBtnClick"},
		["Panel_root.Image_1.Button_GuessLeft"] = {name = "Button_GuessLeft", click = "onBtnClick"},
		["Panel_root.Image_1.Button_GuessRight"] = {name = "Button_GuessRight", click = "onBtnClick"},
		["Panel_root.Image_1.Text_GuessCost"] = {name = "Text_GuessCost"},
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self, self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
    self.guessDuration = tonumber(string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("MountainConfig"), ";")[1])*60
end

function MountainGuessLayer:updateMountainGuessView()
	local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(self.phaseState)
	local guessList = cp.getUserData("UserMountain"):getPhaseGuessList(self.phaseState)
	local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", self.phaseState)
	local guessConfig = cp.getUtils("DataUtils").split(phaseStateEntry:getValue("GuessInfo"), ";:=")

	local leftPlayerInfo = phaseStateInfo.player_list[self.pairIndex*2+1]
	local rightPlayerInfo = phaseStateInfo.player_list[self.pairIndex*2+2]
	local pairInfo = nil
	if phaseStateInfo.round_list and phaseStateInfo.round_list[1] and phaseStateInfo.round_list[1].pair_list then
		pairInfo = phaseStateInfo.round_list[1].pair_list[self.pairIndex+1]
	end

	self.Image_LeftHead:getChildByName("Image_Icon"):loadTexture(cp.DataUtils.getModelFace(leftPlayerInfo.face))
	self.Image_RightHead:getChildByName("Image_Icon"):loadTexture(cp.DataUtils.getModelFace(rightPlayerInfo.face))
	self.Image_LeftName:getChildByName("Text_Name"):setString(leftPlayerInfo.name)
	self.Image_RightName:getChildByName("Text_Name"):setString(rightPlayerInfo.name)
	self.Text_WinGold:setString(string.format("+%d",tonumber(guessConfig[3][1][2])))
	self.Text_WinPrestige:setString(string.format("+%d",tonumber(guessConfig[3][2][2])))
	self.Text_LoseGold:setString(string.format("+%d",tonumber(guessConfig[4][1][2]) ))
	self.Text_LosePrestige:setString(string.format("+%d",tonumber(guessConfig[4][2][2])))
	self.Text_GuessCost:setString(string.format("消耗 %s", guessConfig[2][1][1]))
	cp.getManager("ViewManager").setEnabled(self.Button_LeftRecord, pairInfo ~= nil)
	cp.getManager("ViewManager").setEnabled(self.Button_RightRecord, pairInfo ~= nil)

	log("state_begin="..phaseStateInfo.state_begin..",cur="..cp.getManager("TimerManager"):getTime()..",guessDuration="..self.guessDuration)
	if phaseStateInfo.state_begin < cp.getManager("TimerManager"):getTime() - self.guessDuration then
		cp.getManager("ViewManager").setEnabled(self.Button_GuessLeft, false)
		cp.getManager("ViewManager").setEnabled(self.Button_GuessRight, false)
	else
		cp.getManager("ViewManager").setEnabled(self.Button_GuessLeft, true)
		cp.getManager("ViewManager").setEnabled(self.Button_GuessRight, true)
	end

	if table.indexof(guessList, leftPlayerInfo.id) ~= false then
		cp.getManager("ViewManager").setEnabled(self.Button_GuessLeft, false)
		self.Button_GuessLeft:getChildByName("Text"):setString("已助威")
		self.Button_GuessRight:setVisible(false)
	end

	if table.indexof(guessList, rightPlayerInfo.id) ~= false then
		cp.getManager("ViewManager").setEnabled(self.Button_GuessRight, false)
		self.Button_GuessRight:getChildByName("Text"):setString("已助威")
		self.Button_GuessLeft:setVisible(false)
	end

    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	if roleAtt.id == leftPlayerInfo.id then
		cp.getManager("ViewManager").setEnabled(self.Button_LeftAttr, false)
	end

	if roleAtt.id == rightPlayerInfo.id then
		cp.getManager("ViewManager").setEnabled(self.Button_RightAttr, false)
	end
end

function MountainGuessLayer:onBtnClick(btn)
	local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	elseif nodeName == "Button_LeftRecord" or nodeName == "Button_RightRecord" then
		local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(self.phaseState)
		local pairInfo = nil
		if phaseStateInfo.round_list and phaseStateInfo.round_list[1] and phaseStateInfo.round_list[1].pair_list then
			pairInfo = phaseStateInfo.round_list[1].pair_list[self.pairIndex+1]
		end

		if pairInfo == nil then
			return
		end

		local req = {}
		req.combat_id = pairInfo.combat_id
		if nodeName == "Button_RightRecord" then
			req.side = 1
		end
		self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
	elseif nodeName == "Button_LeftAttr" or nodeName == "Button_RightAttr" then
		local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(self.phaseState)
		local playerInfo = nil
		if nodeName == "Button_LeftAttr" then
			playerInfo = phaseStateInfo.player_list[self.pairIndex*2+1]
		else
			playerInfo = phaseStateInfo.player_list[self.pairIndex*2+2]
		end
		local req = {}
		req.roleID = playerInfo.id
		req.zoneID = 0
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
	elseif nodeName == "Button_GuessLeft" or nodeName == "Button_GuessRight"then
		local phaseStateInfo = cp.getUserData("UserMountain"):getPhaseStateInfo(self.phaseState)
		local phaseStateEntry = cp.getManager("ConfigManager").getItemByKey("MountainTop", self.phaseState)
		local guessConfig = string.split(phaseStateEntry:getValue("GuessInfo"), ";")

		log("state_begin="..phaseStateInfo.state_begin..",cur="..cp.getManager("TimerManager"):getTime()..",guessDuration="..self.guessDuration)
		if phaseStateInfo.state_begin < cp.getManager("TimerManager"):getTime() - self.guessDuration then
			cp.getManager("ViewManager").gameTip("助威時間已過")
			return
		end

		local playerInfo = phaseStateInfo.player_list[self.pairIndex*2+1]
		if nodeName == "Button_GuessRight" then
			playerInfo = phaseStateInfo.player_list[self.pairIndex*2+2]
		end
		local req = {}
		req.phase_state = self.phaseState
		req.id = playerInfo.id
		self:doSendSocket(cp.getConst("ProtoConst").MountainGuessReq, req)
	end
end

function MountainGuessLayer:onEnterScene()
end

function MountainGuessLayer:onExitScene()
	self:unscheduleUpdate()
end

return MountainGuessLayer 