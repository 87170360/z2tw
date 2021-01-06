local BLayer = require "cp.view.ui.base.BLayer"
local GuessFingerLayer = class("GuessFingerLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

local fingerTexture = {
	"ui_guess_finger_module33_doujiu_caiquan_quantou.png",
	"ui_guess_finger_module33_doujiu_caiquan_jiandao.png",
	"ui_guess_finger_module33_doujiu_caiquan_bu.png"
}

local wineTexture = {
	"ui_guess_finger_module33_doujiu_wan_kong.png",
	"ui_guess_finger_module33_doujiu_wan_man.png",
	"ui_guess_finger_module33_doujiu_wan_xuanzhong.png"
}

local wineName = {
	[-3] = "醒酒湯",
	[1] = "猴兒釀",
	[2] = "杏花村",
	[3] = "竹葉青",
	[4] = "紅高粱",
	[5] = "女兒紅",
}

local wineTypeTexture = {
	[-3] = "ui_guess_finger_module33_doujiu_zuijiuzhi01.png",
	[1] = "ui_guess_finger_module33_doujiu_zuijiuzhi02.png",
	[2] = "ui_guess_finger_module33_doujiu_zuijiuzhi03.png",
	[3] = "ui_guess_finger_module33_doujiu_zuijiuzhi04.png",
	[4] = "ui_guess_finger_module33_doujiu_zuijiuzhi05.png",
	[5] = "ui_guess_finger_module33_doujiu_zuijiuzhi06.png",
}

function GuessFingerLayer:create()
	local scene = GuessFingerLayer.new()
    return scene
end

function GuessFingerLayer:getGuessState()
	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
	if guessFingerData.is_over then
		return "OVER"
	end
	local leftFinger = guessFingerData.guess_list[1].finger_list
	local rightFinger = guessFingerData.guess_list[2].finger_list
	if guessFingerData.opponent_info == nil or guessFingerData.opponent_info.id == 0 then
		--還沒匹配
		return "NONE"
	end

	local lastRound = #leftFinger

	if guessFingerData.round > 5 then
		return "FINISH"
	end

	if lastRound + 1 == guessFingerData.round then
		return "GUESS"
	else
		return "DRINK"
	end
end

function GuessFingerLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetGuessOpponentRsp] = function(data)
			self:fillSearchPanel(data)
		end,
		[cp.getConst("EventConst").PickWineRsp] = function(winePoint)
			local wineIndex = self.selectIndex
			local btn = self["Button_Wine"..wineIndex]
			--local name = btn:getChildByName("Text_Name")
			local mask = btn:getChildByName("Image_Mask")
			--name:setVisible(true)
			mask:setVisible(true)
			mask:loadTexture(wineTypeTexture[winePoint], ccui.TextureResType.plistType)
			--name:setString(wineName[winePoint])
			local colorIndex = winePoint > 0 and winePoint or 1
			--name:setTextColor(CombatConst.SkillQualityColor4b[colorIndex])

			local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
			btn:setEnabled(false)
			local result = cp.getUserData("UserGuess"):getLastGuessResult()
			local loserName = ""
			local isLeft = true
			if result == 1 then
				local drinkPoint = guessFingerData.guess_list[2].drink_point
				self.LoadingBar_Right:getChildByName("Text"):setString(string.format("%d/15", drinkPoint))
				self.LoadingBar_Right:setPercent(drinkPoint*100/15)
				loserName = guessFingerData.opponent_info.name
			elseif result == -1 then
				local drinkPoint = guessFingerData.guess_list[1].drink_point
				self.LoadingBar_Left:getChildByName("Text"):setString(string.format("%d/15", drinkPoint))
				self.LoadingBar_Left:setPercent(drinkPoint*100/15)
				loserName = "你"
				isLeft = false
			end
			local bbWord = {
				"你這酒選的，佩服!",
				"這...",
				"少俠真會選酒啊！",
				"酒量一般啊，少俠！",
				"6了呀！",
				"少俠真會選酒啊！",
			}
			local xxWord = {
				"這酒選的就很舒服！",
				"這酒和白開水一樣！",
				"額...",
				"這酒來十壇都不見醉的！",
				"哎喲，不錯哦！",
				"當真是好酒啊！",
			}
			local bb = ""
			local xx = ""
			if winePoint < 0 then
				bb = bbWord[1]
				xx = xxWord[1]
			else
				bb = bbWord[winePoint+1]
				xx = xxWord[winePoint+1]
			end

			self:playerSpeak(not isLeft, xx)
			self:playerSpeak(isLeft, bb, 2)
			local text = self.Text_Log:getString()
			text = text.."\n"
			text = text..loserName.."挑中“"..wineName[winePoint].."”喝下"
			if winePoint > 0 then
				text = text.."增加"
			else
				text = text.."減少"
			end
			text = text..winePoint.."點醉酒值"
			self.Text_Log:setString(text)

			local state = self:getGuessState()
			if state == "GUESS" then
				self:onStartGuessFinger()
			else
				local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
				if guessFingerData.guess_list[1].drink_point < guessFingerData.guess_list[2].drink_point and not guessFingerData.opponent_info.want_fight then
					self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi06.png", ccui.TextureResType.plistType)
					self.Image_GuessResult:setPosition(cc.p(360, 550))
					self.Image_GuessResult:setVisible(true)
					self.Image_GuessResult:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
						local req = {}
						req.want_fight = false
						self:doSendSocket(cp.getConst("ProtoConst").WantFightReq, req)
					end)))
				else
					self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi06.png", ccui.TextureResType.plistType)
					self.Image_GuessResult:setPosition(cc.p(360, 550))
					self.Image_GuessResult:setVisible(true)
					self.Image_GuessResult:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
						self:showFinishPanel()
					end)))
				end
			end
		end,
		[cp.getConst("EventConst").GuessFingerRsp] = function(proto)
			self:updateBothFinger(proto.self_finger, proto.opponent_finger)
		end,
		[cp.getConst("EventConst").WantFightRsp] = function(proto)
			self.fight_result = proto.fight_result
			self.item_list = proto.item_list
            if proto.want_fight then
				cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
			else
				self:showRewardPanel()
            end
		end,
    }
end

function GuessFingerLayer:updateBothFinger(selfFinger, opponentFinger)
	self.Image_LeftFinger:stopAllActions()
	self.Image_RightFinger:stopAllActions()
	local sequence = {}
	table.insert(sequence, cc.RotateTo:create(0.1, 0, 0.0))
	table.insert(sequence, cc.CallFunc:create(function()
		self.Image_LeftFinger:loadTexture(fingerTexture[selfFinger+1], ccui.TextureResType.plistType)
		self.Image_RightFinger:loadTexture(fingerTexture[opponentFinger+1], ccui.TextureResType.plistType)
		local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
		self.AtlasLabel_Time:setVisible(true)
		local guessResult = cp.getUserData("UserGuess"):judgeGuessFinger(selfFinger, opponentFinger)
		if guessResult == 0 then
			self.leftModel:setAnimation(0, "Stand", true)
			self.rightModel:setAnimation(0, "Stand", true)
			local text = self.Text_Log:getString()
			text = text.."\n"
			text = text.."雙方平局"
			self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi01.png", ccui.TextureResType.plistType)
			self.AtlasLabel_Time:setVisible(false)
			self.Text_Log:setString(text)
			log("平局")
		elseif guessResult == 1 then
			self.leftModel:setAnimation(0, "Win_start", false)
			self.leftModel:addAnimation(0, "Win_loop", true)
			local text = self.Text_Log:getString()
			text = text.."\n"
			text = text.."恭喜你贏得第"..cp.getUtils("DataUtils").formatZh_CN(guessFingerData.round).."輪猜拳"
			self.Text_Log:setString(text)
			self:playerSpeak(true, "承讓了！")
			log("左邊贏")
		else
			self.rightModel:setAnimation(0, "Win_start", false)
			self.rightModel:addAnimation(0, "Win_loop", true)
			local text = self.Text_Log:getString()
			text = text.."\n"
			text = text.."恭喜"..guessFingerData.opponent_info.name.."贏得第"..cp.getUtils("DataUtils").formatZh_CN(guessFingerData.round).."輪猜拳"
			self.Text_Log:setString(text)
			self:playerSpeak(false, "承讓了！")
			log("右邊贏")
		end

		self.Image_GuessResult:setVisible(true)
		self.Image_GuessResult:setPosition(cc.p(1080, 550))
		local sequence = {}
		table.insert(sequence, cc.DelayTime:create(1))
		table.insert(sequence, cc.MoveTo:create(0.2, cc.p(360, 550)))
		if selfFinger == opponentFinger then
			table.insert(sequence, cc.DelayTime:create(1.5))
			table.insert(sequence, cc.MoveTo:create(0.2, cc.p(-360, 550)))
		end
		table.insert(sequence, cc.CallFunc:create(function()
			local state = self:getGuessState()
			if state == "DRINK" then
				self:onStartDrinkWine(guessResult) 
			elseif state == "GUESS" then
				self:onStartGuessFinger(guessResult) 
			else
				self:showFinishPanel()
			end
		end))
		self.Image_GuessResult:runAction(cc.Sequence:create(sequence))
	end))
	self.Image_LeftFinger:runAction(cc.RotateTo:create(0.1, 0.0, 0.0))
	self.Image_RightFinger:runAction(cc.Sequence:create(sequence))
end

function GuessFingerLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_guess_finger_rule.xml")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("guess_finger_rule", desc)
        self:addChild(layer, 100)
	end
end
--初始化界面，以及設定界面元素標籤
function GuessFingerLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guess/uicsb_guess_finger.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_Guess"] = {name = "Panel_Guess"},
		["Panel_root.Panel_Start"] = {name = "Panel_Start"},
		["Panel_root.Panel_Finish"] = {name = "Panel_Finish"},
		["Panel_root.Panel_Reward"] = {name = "Panel_Reward"},
		["Panel_root.Panel_Search"] = {name = "Panel_Search"},
		["Panel_root.Button_Rule"] = {name = "Button_Rule", click="onBtnClick", clickScale=0.9},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self.leftModelInfo = {
		face = majorRole.face,
		model = cp.getUserData("UserRole"):getUserModel(),
		name = majorRole.name,
	}
	local state = self:getGuessState()
	self:loadGuessFingerView(state)
end

function GuessFingerLayer:loadGuessFingerView(state)
	if state == "OVER" or state == "NONE" then
		self:showStartPanel()
	elseif state == "SEARCHING" then
		self:showSearchPanel()
	elseif state == "GUESS" or state == "DRINK" then
		self:showGuessPanel(state)
	elseif state == "FINISH" then
		self:showFinishPanel()
	end
end

function GuessFingerLayer:updateGuessFingerView()
end

function GuessFingerLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function GuessFingerLayer:onPanelStartBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self.Panel_Search:stopAllActions()
		self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, false)
	elseif nodeName == "Button_Start" then
		local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
		if not guessFingerData.is_over then
			self:showSearchPanel()
		else
			cp.getManager("ViewManager").gameTip("少俠，斗酒重置時間未到！")
		end
	end
end

function GuessFingerLayer:showStartPanel()
	self.Panel_Guess:setVisible(false)
	self.Panel_Start:setVisible(true)
	self.Panel_Finish:setVisible(false)
	self.Panel_Reward:setVisible(false)
	self.Panel_Search:setVisible(false)
	local childConfig = {
		["Button_Close"] = {name = "Button_Close", click="onPanelStartBtnClick", clickScale=0.9},
		["Button_Start"] = {name = "Button_Start", click="onPanelStartBtnClick", clickScale=0.9},
		["Image_Comment"] = {name = "Image_Comment"},
		["Node_Boss"] = {name = "Node_Boss"},
		["Text_Num"] = {name = "Text_Num"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self, self.Panel_Start, childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	local state = self:getGuessState()
	if state == "OVER" then
		self.Text_Num:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
			local remain = guessFingerData.day - cp.getManager("TimerManager"):getTime()
			if remain > 0 then
				self.Text_Num:setString(string.format("重置倒計時%s", cp.getUtils("DataUtils").formatTimeRemainEx(remain)))
			else
				self.Text_Num:setString("")
			end
		end), cc.DelayTime:create(1))))
	else
		self.Text_Num:setString("")
	end
	local model = self.Node_Boss:getChildByName("Boss")
	if not model then
		model = cp.getManager("ViewManager").createSpineAnimation("res/spine/laoban/laoban")
		model:setAnimation(0, "Stand", true)
        model:setName("Boss")
		self.Node_Boss:addChild(model)
	end
	self.Image_Comment:setScale(0.1)
	self.Image_Comment:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1, 1), cc.DelayTime:create(2), cc.CallFunc:create(function()
		local txt = self.Image_Comment:getChildByName("Text_2")
		txt:setString("斗酒分為2個階段，第一階段為猜拳喝酒階段，分為5局。第二階段為測試醉酒階段。匹配到對手之後，猜拳輸的一方需要從六杯酒中選擇一杯喝掉。")
	end)))
end

function GuessFingerLayer:onPanelSearchBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		local state = self:getGuessState()
		self:loadGuessFingerView(state)
	elseif nodeName == "Button_Start" then
		self:showSearchPanel()
	end
end

function GuessFingerLayer:showSearchPanel()
	self.Panel_Guess:setVisible(false)
	self.Panel_Start:setVisible(false)
	self.Panel_Finish:setVisible(false)
	self.Panel_Reward:setVisible(false)
	self.Panel_Search:setVisible(true)
	local childConfig = {
		["Text_Searching"] = {name = "Text_Searching"},
		["Button_Close"] = {name = "Button_Close", click="onPanelSearchBtnClick", clickScale=0.9},
		["Image_LeftHead"] = {name = "Image_LeftHead"},
		["Image_RightHead"] = {name = "Image_RightHead"},
		["Text_LeftName"] = {name = "Text_LeftName"},
		["Text_RightName"] = {name = "Text_RightName"},
		["AtlasLabel_Time"] = {name = "AtlasLabel_Time"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self, self.Panel_Search, childConfig)
	cp.getManager("ViewManager").popUpViewEx(self.Panel_Search)

	local randomTime = math.random(2, 6)
	self.Panel_Search:stopAllActions()
	self.Panel_Search:runAction(cc.Sequence:create(cc.DelayTime:create(randomTime), cc.CallFunc:create(function()
		local req = {}
		self:doSendSocket(cp.getConst("ProtoConst").GetGuessOpponentReq, req)
	end)))
	local originTime = 1
	self.AtlasLabel_Time:stopAllActions()
	self.AtlasLabel_Time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
		self.AtlasLabel_Time:setString(string.format("%2d", originTime))
		if originTime == randomTime then
			self.AtlasLabel_Time:stopAllActions()
		end
		originTime = originTime + 1
	end), cc.DelayTime:create(1))))
	
	self.Image_LeftHead:loadTexture(cp.DataUtils.getModelFace(self.leftModelInfo.face))
	self.Text_LeftName:setString(self.leftModelInfo.name)
end

function GuessFingerLayer:fillSearchPanel(opponent_info)
	self.Panel_Search:stopAllActions()
	if self.Panel_Search:isVisible() then
		self.Button_Close:setEnabled(false)
		self.rightModelInfo = opponent_info
		self.Image_RightHead:setVisible(true)
		self.Image_RightHead:loadTexture(cp.DataUtils.getModelFace(self.rightModelInfo.face))
		self.Text_RightName:setString(self.rightModelInfo.name)
		self.Panel_Search:stopAllActions()
		self.Panel_Search:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
			local state = self:getGuessState()
			self:loadGuessFingerView(state)
		end)))
	end
end

function GuessFingerLayer:onPanelGuessBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, false)
	elseif nodeName == "Button_Speak" then
		if self.ListView_Say:getPositionY() < 0 then
			self.ListView_Say:runAction(cc.MoveTo:create(0.2, cc.p(0, 43)))
		else
			self.ListView_Say:runAction(cc.MoveTo:create(0.2, cc.p(0, -86)))
		end
	end
end

function GuessFingerLayer:playerSpeak(isLeft, txt, delay)
	delay = delay or 0.1
	local imgSpeak = nil
	if isLeft then
		imgSpeak = self.Image_LeftSpeak
	else
		imgSpeak = self.Image_RightSpeak
	end
	imgSpeak:getChildByName("Text"):setString(txt)
	imgSpeak:setVisible(true)
	imgSpeak:setScale(0.1)
	imgSpeak:stopAllActions()
	imgSpeak:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.ScaleTo:create(0.2, 1.0, 1.0),cc.DelayTime:create(3.0), cc.CallFunc:create(function()
		imgSpeak:setVisible(false)
	end)))
end

function GuessFingerLayer:showGuessPanel(state)
	self.Panel_Guess:setVisible(true)
	self.Panel_Start:setVisible(false)
	self.Panel_Finish:setVisible(false)
	self.Panel_Reward:setVisible(false)
	self.Panel_Search:setVisible(false)
	local childConfig = {
		["Panel_Bottom"] = {name = "Panel_Bottom"},
		["Panel_Center"] = {name = "Panel_Center"},
		["Panel_Top"] = {name = "Panel_Top"},
		["Panel_Bottom.ListView_Say"] = {name = "ListView_Say"},
		["Panel_Bottom.Image_DeskMask"] = {name = "Image_DeskMask"},
		["Panel_Bottom.Button_Speak"] = {name = "Button_Speak", click="onPanelGuessBtnClick", clickScale=1.0},
		["Panel_Bottom.Button_Wine1"] = {name = "Button_Wine1"},
		["Panel_Bottom.Button_Wine2"] = {name = "Button_Wine2"},
		["Panel_Bottom.Button_Wine3"] = {name = "Button_Wine3"},
		["Panel_Bottom.Button_Wine4"] = {name = "Button_Wine4"},
		["Panel_Bottom.Button_Wine5"] = {name = "Button_Wine5"},
		["Panel_Bottom.Button_Wine6"] = {name = "Button_Wine6"},
		["Panel_Bottom.Button_Finger1"] = {name = "Button_Finger1"},
		["Panel_Bottom.Button_Finger2"] = {name = "Button_Finger2"},
		["Panel_Bottom.Button_Finger3"] = {name = "Button_Finger3"},
		["Panel_Top.Image_Left.Image_Icon"] = {name = "Image_Left"},
		["Panel_Top.Image_Right.Image_Icon"] = {name = "Image_Right"},
		["Panel_Top.LoadingBar_Left"] = {name = "LoadingBar_Left"},
		["Panel_Top.LoadingBar_Right"] = {name = "LoadingBar_Right"},
		["Panel_Top.Button_Close"] = {name = "Button_Close", click="onPanelGuessBtnClick", clickScale=0.9},
		["Panel_Center.Node_LeftPlayer.Image_LeftFinger"] = {name = "Image_LeftFinger"},
		["Panel_Center.Node_RightPlayer.Image_RightFinger"] = {name = "Image_RightFinger"},
		["Panel_Center.Image_GuessResult.AtlasLabel_Time"] = {name = "AtlasLabel_Time"},
		["Panel_Center.Image_GuessResult"] = {name = "Image_GuessResult"},
		["Panel_Center.Node_LeftPlayer"] = {name = "Node_LeftPlayer"},
		["Panel_Center.Node_RightPlayer"] = {name = "Node_RightPlayer"},
		["Panel_Center.Node_LeftPlayer.Text_LeftName"] = {name = "Text_LeftName"},
		["Panel_Center.Node_RightPlayer.Text_RightName"] = {name = "Text_RightName"},
		["Panel_Center.Node_LeftPlayer.Image_LeftSpeak"] = {name = "Image_LeftSpeak"},
		["Panel_Center.Node_RightPlayer.Image_RightSpeak"] = {name = "Image_RightSpeak"},
		["Panel_Top.Image_DrinkPoint.Panel_Log.Text_Log"] = {name = "Text_Log"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self, self.Panel_Guess, childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.Panel_Top:setPosition(cc.p(0, display.height))
	
	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
	self.rightModelInfo = guessFingerData.opponent_info

	self.Text_LeftName:setString(self.leftModelInfo.name)
	self.Text_RightName:setString(self.rightModelInfo.name)
	
	self.Panel_Guess:setVisible(true)
	self.Image_Left:loadTexture(cp.DataUtils.getModelFace(self.leftModelInfo.face))
	self.Image_Right:loadTexture(cp.DataUtils.getModelFace(self.rightModelInfo.face))
	self.ListView_Say:setPosition(cc.p(0, -129))
	self.ListView_Say:setTouchEnabled(true)
	self.LoadingBar_Left:setPercent(guessFingerData.guess_list[1].drink_point*100/15)
	self.LoadingBar_Left:getChildByName("Text"):setString(string.format("%d/15", guessFingerData.guess_list[1].drink_point))
	self.LoadingBar_Right:setPercent(guessFingerData.guess_list[2].drink_point*100/15)
	self.LoadingBar_Right:getChildByName("Text"):setString(string.format("%d/15", guessFingerData.guess_list[2].drink_point))
	for i=1, 3 do
		local img = self.ListView_Say:getChildByName(i)
		img:onTouch(function(event)
			if event.name == "ended" then
				local textList = {
					"對面的小子，我要出布了!",
					"下回合我要出石頭!",
					"對面的小子，我要出布了!"
				}

				self.ListView_Say:runAction(cc.MoveTo:create(0.2, cc.p(0, -86)))
				self.Image_LeftSpeak:getChildByName("Text"):setString(textList[i])
				self.Image_LeftSpeak:setVisible(true)
				self.Image_LeftSpeak:setScale(0.1)
				self.Image_LeftSpeak:stopAllActions()
				self.Image_LeftSpeak:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.0, 1.0),cc.DelayTime:create(3.0), cc.CallFunc:create(function()
					local rate = math.random( 1, 100 )
					if rate <= 70 then
						self.Image_RightSpeak:setVisible(true)
						local randIndex = math.random(1,3)
						self.Image_RightSpeak:getChildByName("Text"):setString(textList[randIndex])
						self.Image_RightSpeak:stopAllActions()
						self.Image_RightSpeak:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.0, 1.0),cc.DelayTime:create(3.0), cc.CallFunc:create(function()
							self.Image_RightSpeak:setVisible(false)
						end)))
					end
					self.Image_LeftSpeak:setVisible(false)
				end)))
			end
		end)
	end

	for i=1, 6 do
		local btn = self["Button_Wine"..i]
		--local name = btn:getChildByName("Text_Name")
		local mask = btn:getChildByName("Image_Mask")
		local winePoint = guessFingerData.wine_flag[i]
		if winePoint ~= 0 then
			btn:loadTextures(wineTexture[1], wineTexture[1], wineTexture[1], ccui.TextureResType.plistType)
			btn:setEnabled(false)
			local colorIndex = winePoint > 0 and winePoint or 1
			--name:setString(wineName[winePoint])
			--name:setTextColor(CombatConst.SkillQualityColor4b[colorIndex])
			--name:setVisible(true)
			mask:setVisible(true)
			mask:loadTexture(wineTypeTexture[winePoint], ccui.TextureResType.plistType)
		else
			btn:loadTextures(wineTexture[2], wineTexture[2], wineTexture[1], ccui.TextureResType.plistType)
			btn:setEnabled(true)
			--name:setVisible(false)
			mask:setVisible(false)
		end
	end

	self.leftModel = cp.getManager("ViewManager").createModel(self.leftModelInfo.model)
	self.leftModel:setAnimation(0, "Into", false)
	self.leftModel:addAnimation(0, "Stand", true)
	--self.leftModel:setPosition(cc.p(100, 400))
	self.rightModel = cp.getManager("ViewManager").createModel(self.rightModelInfo.model)
	self.rightModel:setAnimation(0, "Into", false)
	self.rightModel:addAnimation(0, "Stand", true)
	--self.rightModel:setPosition(cc.p(620, 400))
	self.rightModel:setFlipX(1)
	self.Node_LeftPlayer:addChild(self.leftModel, 0)
	self.Node_RightPlayer:addChild(self.rightModel, 0)

	self.Image_GuessResult:setVisible(true)
	self.Image_GuessResult:setPosition(cc.p(1080, 550))
    self.Image_GuessResult:ignoreContentAdaptWithSize(true)
	local sequence = {}
	table.insert(sequence, cc.DelayTime:create(2))
	table.insert(sequence, cc.MoveTo:create(0.2, cc.p(360, 550)))
	table.insert(sequence, cc.DelayTime:create(1.5))
	table.insert(sequence, cc.MoveTo:create(0.2, cc.p(-360, 550)))
	table.insert(sequence, cc.CallFunc:create(function()
		local state = self:getGuessState()
		if state == "GUESS" then
			self:onStartGuessFinger()
		else
			local guessResult = cp.getUserData("UserGuess"):getLastGuessResult()
			self:onStartDrinkWine(guessResult)
		end
	end))

	self.Image_GuessResult:runAction(cc.Sequence:create(sequence))
end

function GuessFingerLayer:onStartGuessFinger()
	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
	local text = self.Text_Log:getString()
	text = text.."\n"
	text = text.."第"..cp.getUtils("DataUtils").formatZh_CN(guessFingerData.round).."局開始，請選擇猜拳手勢"
	self.Text_Log:setString(text)
	self.Image_GuessResult:setVisible(true)
	self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi02.png", ccui.TextureResType.plistType)
	self.Image_GuessResult:setPosition(cc.p(360, 550))
	self.selectIndex = math.random(1,3)
	self.AtlasLabel_Time:setString(5)
	self.AtlasLabel_Time:setPosition(cc.p(333,28))
	self.AtlasLabel_Time:setScale(1)
	self.AtlasLabel_Time:setVisible(true)
	self.Image_DeskMask:setVisible(false)
	self.Image_LeftFinger:setVisible(true)
	self.Image_RightFinger:setVisible(true)
	self.leftModel:setAnimation(0, "Stand", true)
	self.rightModel:setAnimation(0, "Stand", true)
	self.AtlasLabel_Time:stopAllActions()
	self.AtlasLabel_Time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.5, 0.5), cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		local time = tonumber(self.AtlasLabel_Time:getString()) - 1
		self.AtlasLabel_Time:setString(time)
		self.AtlasLabel_Time:setScale(1)
		if time == 0 then
			local req = {}
			self.selectIndex = self.selectIndex or math.random(1,3)
			req.finger = self.selectIndex - 1
			self.AtlasLabel_Time:setVisible(false)
			self.AtlasLabel_Time:stopAllActions()
			self.Image_GuessResult:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-360, 550)), cc.CallFunc:create(function()
				self:doSendSocket(cp.getConst("ProtoConst").GuessFingerReq, req)
			end)))
		end
	end))))

	local totalIndex = 0
	self.Image_RightFinger:setRotation(60)
	self.Image_RightFinger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		local index = totalIndex % 3 + 1
		totalIndex = totalIndex+1
		self.Image_RightFinger:loadTexture(fingerTexture[index], ccui.TextureResType.plistType)
	end))))
	self.Image_LeftFinger:setRotation(-60)
	self.Image_LeftFinger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		local index = totalIndex % 3 + 1
		self.Image_LeftFinger:loadTexture(fingerTexture[index], ccui.TextureResType.plistType)
	end))))

	for i=1, 3 do
		local btn = self["Button_Finger"..i]
		btn:setVisible(true)
		cp.getManager("ViewManager").initButton(btn, function()
			if self.selectIndex then
				self["Button_Finger"..self.selectIndex]:getChildByName("Image_Mask"):setVisible(false)
			end
			self["Button_Finger"..i]:getChildByName("Image_Mask"):setVisible(true)
			self.selectIndex = i
		end, 1.0)

		if self.selectIndex == i then
			btn:getChildByName("Image_Mask"):setVisible(true)
		else
			btn:getChildByName("Image_Mask"):setVisible(false)
		end
	end
end

function GuessFingerLayer:getRandomWine()
	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()

	local temp = {}
	for i, flag in ipairs(guessFingerData.wine_flag) do
		if flag == 0 then
			table.insert(temp, i)
		end
	end
	local randomIndex = math.random(1,#temp)
	return temp[randomIndex]
end

function GuessFingerLayer:onStartDrinkWine(guessResult)
	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
	self.selectIndex = self:getRandomWine()
	self.AtlasLabel_Time:setString(5)
	self.AtlasLabel_Time:setVisible(true)
	if guessResult == 0 then
		self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi01.png", ccui.TextureResType.plistType)
		self.AtlasLabel_Time:setPosition(cc.p(330, 30))
	elseif guessResult == 1 then
		self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi05.png", ccui.TextureResType.plistType)
		self.AtlasLabel_Time:setPosition(cc.p(433, 42))
	else
		self.Image_GuessResult:loadTexture("ui_guess_finger_module33_doujiu_yishuzi04.png", ccui.TextureResType.plistType)
		self.AtlasLabel_Time:setPosition(cc.p(340, 26))
	end
	--self.Image_RightFinger:setVisible(false)
	--self.Image_LeftFinger:setVisible(false)
	self.AtlasLabel_Time:stopAllActions()
	self.AtlasLabel_Time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.5, 0.5), cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		local time = tonumber(self.AtlasLabel_Time:getString())-1
		self.AtlasLabel_Time:setString(time)
		self.AtlasLabel_Time:setScale(1)
		if time == 0 then
			local req = {}
			self.selectIndex = self.selectIndex or math.random(1,6)
			req.wine_index = self.selectIndex - 1
			self.AtlasLabel_Time:setVisible(false)
			self.AtlasLabel_Time:stopAllActions()
			self.Image_DeskMask:stopAllActions()
			self.Image_GuessResult:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-360, 550)), cc.CallFunc:create(function()
				self:doSendSocket(cp.getConst("ProtoConst").PickWineReq, req)
			end)))
		end
	end))))

	for i=1, 6 do
		local btn = self["Button_Wine"..i]
		if guessFingerData.wine_flag[i] ~= 0 then
			btn:loadTextures(wineTexture[1], wineTexture[1], wineTexture[1], ccui.TextureResType.plistType)
			btn:setEnabled(false)
		else
			btn:loadTextures(wineTexture[2], wineTexture[2], wineTexture[1], ccui.TextureResType.plistType)
			btn:setEnabled(true)
			cp.getManager("ViewManager").initButton(btn, function()
				local state = self:getGuessState()
				if state == "DRINK" and cp.getUserData("UserGuess"):getLastGuessResult() == -1 then
					if self.selectIndex then
						self["Button_Wine"..self.selectIndex]:loadTextures(wineTexture[2], wineTexture[2], wineTexture[1], ccui.TextureResType.plistType)
					end
					self["Button_Wine"..i]:loadTextures(wineTexture[3], wineTexture[3], wineTexture[1], ccui.TextureResType.plistType)
					self.selectIndex = i
				end
			end, 1.0)

			if i == self.selectIndex and cp.getUserData("UserGuess"):getLastGuessResult() == -1 then
				self["Button_Wine"..i]:loadTextures(wineTexture[3], wineTexture[3], wineTexture[1], ccui.TextureResType.plistType)
			else
				self["Button_Wine"..i]:loadTextures(wineTexture[2], wineTexture[2], wineTexture[1], ccui.TextureResType.plistType)
			end
		end
	end

	if cp.getUserData("UserGuess"):getLastGuessResult() == -1 then
		self.Image_DeskMask:setVisible(true)
		self.Image_DeskMask:runAction(cc.Blink:create(10, 20))
	end

	for i=1, 3 do
		local btn = self["Button_Finger"..i]
		btn:setVisible(false)
	end
end

function GuessFingerLayer:onPanelFinishBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Combat" then
		local req = {}
		req.want_fight = true
		self:doSendSocket(cp.getConst("ProtoConst").WantFightReq, req)
	elseif nodeName == "Button_OK" then
		local req = {}
		req.want_fight = false
		self:doSendSocket(cp.getConst("ProtoConst").WantFightReq, req)
	end
end

function GuessFingerLayer:showFinishPanel()
	self.Panel_Guess:setVisible(false)
	self.Panel_Start:setVisible(false)
	self.Panel_Finish:setVisible(true)
	self.Panel_Reward:setVisible(false)
	self.Panel_Search:setVisible(false)
	local childConfig = {
		["Image_Lose"] = {name = "Image_Lose"},
		["Image_Win"] = {name = "Image_Win"},
		["Node_Boss"] = {name = "Node_Boss"},
	}

	local guessFingerData = cp.getUserData("UserGuess"):getGuessFingerData()
	local isWin = guessFingerData.guess_list[1].drink_point < guessFingerData.guess_list[2].drink_point
	if isWin then
		childConfig["Image_Win.Button_Combat"] = {name = "Button_Combat", click="onPanelFinishBtnClick", clickScale=0.9}
		childConfig["Image_Win.Button_OK"] = {name = "Button_OK", click="onPanelFinishBtnClick", clickScale=0.9}
	else
		childConfig["Image_Lose.Button_Combat"] = {name = "Button_Combat", click="onPanelFinishBtnClick", clickScale=0.9}
		childConfig["Image_Lose.Button_OK"] = {name = "Button_OK", click="onPanelFinishBtnClick", clickScale=0.9}
	end
	cp.getManager("ViewManager").setCSNodeBinding(self, self.Panel_Finish, childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	local model = self.Node_Boss:getChildByName("Boss")
	if not model then
		model = cp.getManager("ViewManager").createSpineAnimation("res/spine/laoban/laoban")
		model:setAnimation(0, "Stand", true)
        model:setName("Boss")
		self.Node_Boss:addChild(model)
	end

	local img = nil
	if isWin then
		self.Image_Win:setVisible(true)
		self.Image_Lose:setVisible(false)
		img = self.Image_Win
	else
		self.Image_Lose:setVisible(true)
		self.Image_Win:setVisible(false)
		img = self.Image_Lose
	end
	img:setScale(0.1)
	img:runAction(cc.ScaleTo:create(0.2, 1, 1))
end

function GuessFingerLayer:onPanelRewardBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Thank" then
		self:showStartPanel()
	end
end

function GuessFingerLayer:showRewardPanel()
	self.Panel_Guess:setVisible(false)
	self.Panel_Start:setVisible(false)
	self.Panel_Finish:setVisible(false)
	self.Panel_Reward:setVisible(false)
	self.Panel_Search:setVisible(false)

	if self.fight_result == 1 then
		cp.getManager("ViewManager").showGetRewardUI(self.item_list, "千杯不醉",true, function()
			self:showStartPanel()
		end)
	else
		cp.getManager("ViewManager").showGetRewardUI(self.item_list, "不勝酒力",true, function()
			self:showStartPanel()
		end)
	end
end

function GuessFingerLayer:updateGuessPanel()
end

function GuessFingerLayer:onEnterScene()
	if self.fight_result and self.item_list then
		self.Panel_Guess:setVisible(false)
		self.Panel_Start:setVisible(false)
		self.Panel_Finish:setVisible(false)
		self.Panel_Reward:setVisible(false)
		self.Panel_Search:setVisible(false)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create(function()
			self:showRewardPanel()
		end)))
	end
end

function GuessFingerLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuessFingerLayer
