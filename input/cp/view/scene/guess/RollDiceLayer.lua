local BLayer = require "cp.view.ui.base.BLayer"
local RollDiceLayer = class("RollDiceLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

local diceRewardTexture = {
	"ui_roll_dice_module33_doulaoqian_zi_jinliyuemen",
	"ui_roll_dice_module33_doulaoqian_zi_sihaishengping",
	"ui_roll_dice_module33_doulaoqian_zi_duzhongsanyuan",
	"ui_roll_dice_module33_doulaoqian_zi_jinyumantang",
	"ui_roll_dice_module33_doulaoqian_zi_linfengduiyue",
	"ui_roll_dice_module33_doulaoqian_zi_shilaiyunzhuan",
}

function RollDiceLayer:create()
	local scene = RollDiceLayer.new()
    return scene
end

function RollDiceLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").RollDiceRsp] = function(proto)
			self:dispatchViewEvent("GuideLayerCloseMsg")
			self:dispatchViewEvent("GamePopTalkCloseMsg")
			local flag = false
			self.Button_Reset:setEnabled(false)
			self:runGuideStep()
			for i, touzi in ipairs(self.diceModelList) do
				touzi:setVisible(true)
				local animation = cp.getManager("ViewManager").createEffectAnimation("touzi", 0.045, 3)
				touzi:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
					touzi:setVisible(false)
					self["Button_Dice"..i]:getChildByName("Image_Icon"):setVisible(true)
					self["Button_Dice"..i]:setEnabled(true)
					self:updateDiceList()
					self.Button_Reset:setEnabled(true)
					if not flag then
						flag = true
					end
				end)))
				touzi:setVisible(true)

				local btn = self["Button_Dice"..i]
				local flag = btn:getChildByName("Image_Flag")
				flag:setVisible(false)
				self["Button_Dice"..i]:setEnabled(false)
				self["Button_Dice"..i]:getChildByName("Image_Icon"):setVisible(false)
			end
			
			self.Button_Roll:setEnabled(false)
			self.Image_RollNotice:setVisible(false)
			self.Image_RollNotice:stopAllActions()
			cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_dice)
		end,
		[cp.getConst("EventConst").ChangeDiceRsp] = function(proto)
			cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_dice)
			self:runGuideStep()
			--self:updateChangeDice(proto.dice_index, proto.dice_point)
		end,
		[cp.getConst("EventConst").ResetDiceStateRsp] = function(proto)
			self:updateDiceList()
			self.Node_CoinDrop:setVisible(true)
			self.Node_CoinDrop:getChildByName("yuanbao"):setAnimation(0, "yuanbao", false)
			if cp.getUtils("NotifyUtils").needNotifyGetRollReward() then
				cp.getManager("ViewManager").addRedDot(self.Button_Reward,cc.p(112,100))
			else
				cp.getManager("ViewManager").removeRedDot(self.Button_Reward)
			end
			self:runGuideStep()
		end,
		[cp.getConst("EventConst").GetMonthRewardRsp] = function(proto)
			if cp.getUtils("NotifyUtils").needNotifyGetRollReward() then
				cp.getManager("ViewManager").addRedDot(self.Button_Reward,cc.p(112,100))
			else
				cp.getManager("ViewManager").removeRedDot(self.Button_Reward)
			end
		end,
		["UpdateGuessGuideStepRsp"] = function(proto)
			if proto.module == 1 then
				self:runGuideStep()
			end
		end,
    }
end

function getDiceIndexByDiceType(diceList, diceType)
	if #diceList == 0 or diceType == 6 then
		return {}
	end
	local orderDiceList = {}
	local diceIndexList = {}
	for diceIndex, dicePoint in ipairs(diceList) do
		table.insert(orderDiceList, {
			index=diceIndex,
			point=dicePoint,
		})
	end

	table.sort(orderDiceList, function(a,b)
		return a.point < b.point
	end)

	--log(orderDiceList)
	local order, maxOrder, same, maxSame, couple, maxCouple = 1, 1, 1, 1, 0, 0
	local lastDicePoint = orderDiceList[1].point
	for i=2 ,#orderDiceList do
		local dicePoint = orderDiceList[i].point
		if dicePoint == lastDicePoint then
			same = same+1
			if maxSame < same then
				maxSame = same
			end

			if diceType == 2 or diceType == 3 or diceType == 4 or diceType == 5 then
				table.insert(diceIndexList, orderDiceList[i].index)
				table.insert(diceIndexList, orderDiceList[i-1].index)
			end
		else
			same = 1
		end
		--log("same="..same)

		if lastDicePoint+1 == dicePoint then
			order = order + 1
			if diceType == 1 then
				table.insert(diceIndexList, orderDiceList[i].index)
				table.insert(diceIndexList, orderDiceList[i-1].index)
			end
			if maxOrder < order then
				maxOrder = order
			end
		elseif lastDicePoint ~= dicePoint then
			order = 1
		end
		--log("order="..order)

		if same % 2 == 0 then
			couple = couple+1
			if maxCouple < couple then
				maxCouple = couple
			end
		end
		--log("couple="..couple)

		lastDicePoint = dicePoint
	end
	return diceIndexList
end

function JudgeDiceType(diceList)
	local orderDiceList = {}
	for diceIndex, dicePoint in ipairs(diceList) do
		table.insert(orderDiceList, {
			index=diceIndex,
			point=dicePoint,
		})
	end

	table.sort(orderDiceList, function(a,b)
		return a.point < b.point
	end)

	--log(orderDiceList)
	local order, maxOrder, same, maxSame, couple, maxCouple = 1, 1, 1, 1, 0, 0
	local lastDicePoint = orderDiceList[1].point
	for i=2 ,#orderDiceList do
		local dicePoint = orderDiceList[i].point
		if dicePoint == lastDicePoint then
			same = same+1
			if maxSame < same then
				maxSame = same
			end
		else
			same = 1
		end
		--log("same="..same)

		if lastDicePoint+1 == dicePoint then
			order = order + 1
			if maxOrder < order then
				maxOrder = order
			end
		elseif lastDicePoint ~= dicePoint then
			order = 1
		end
		--log("order="..order)

		if same % 2 == 0 then
			couple = couple+1
			if maxCouple < couple then
				maxCouple = couple
			end
		end
		--log("couple="..couple)

		lastDicePoint = dicePoint
	end

	if maxOrder == 4 then
		local temp = 0
		local flag = true
		for i, dicePoint in ipairs(diceList) do
			if temp ~= 0 and dicePoint - diceList[i-1] ~= temp then
				flag = false
				break
			end
			if diceList[i-1] then
				temp = dicePoint - diceList[i-1]
			end
		end

		if flag then
			return 1
		else
			return 6
		end
	elseif maxSame == 4 then
		return 2
	elseif maxSame == 3 then
		return 3
	elseif maxCouple == 2 then
		return 4
	elseif maxCouple == 1 then
		return 5
	else
		return 6
	end
end

function RollDiceLayer:updateChangeDice(diceIndex, dicePoint)
	self:updateDiceList()
end

function RollDiceLayer:updateDiceList()
	local rollDiceData = cp.getUserData("UserGuess"):getRollDiceData()
	for diceIndex=1, #rollDiceData.dice_list do
		local btn = self["Button_Dice"..diceIndex]
		local icon = btn:getChildByName("Image_Icon")
		local mask = btn:getChildByName("Image_Mask")
		mask:setVisible(false)
		cp.getManager("ViewManager").initButton(btn, function()
			local touzi = self.diceModelList[diceIndex]
			local req = {}
			req.dice_index = diceIndex - 1
			self:doSendSocket(cp.getConst("ProtoConst").ChangeDiceReq, req)
			touzi:setVisible(true)
			btn:setEnabled(false)
			self.Button_Reset:setEnabled(false)
			local animation = cp.getManager("ViewManager").createEffectAnimation("touzi", 0.045, 3)
			touzi:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
				touzi:setVisible(false)
				btn:getChildByName("Image_Icon"):setVisible(true)
				btn:setEnabled(true)
				self.Button_Reset:setEnabled(true)
				self:updateDiceList()
			end)))

			self["Button_Dice"..diceIndex]:setEnabled(false)
			self["Button_Dice"..diceIndex]:getChildByName("Image_Icon"):setVisible(false)
		end, 1)
	end

	for i=1, 6 do
		local textureName = "ui_roll_dice_module33_doulaoqian_dizhuo_weixuanzhong.png"
		local btn = self["Image_RollType"..i]
		local imgName = btn:getChildByName("Image_Name")
		btn:loadTexture(textureName, ccui.TextureResType.plistType)
		textureName = diceRewardTexture[i].."02.png"
		imgName:loadTexture(textureName, ccui.TextureResType.plistType)
		imgName:ignoreContentAdaptWithSize(true)
	end

	if #rollDiceData.dice_list > 0 then
		self.diceType = JudgeDiceType(rollDiceData.dice_list)
		local textureName = "ui_roll_dice_module33_doulaoqian_dizhuo_xuanzhong.png"
		local btn = self["Image_RollType"..self.diceType]
		local imgName = btn:getChildByName("Image_Name")
		btn:loadTexture(textureName, ccui.TextureResType.plistType)
		textureName = diceRewardTexture[self.diceType].."02_xuanzhong.png"
		imgName:loadTexture(textureName, ccui.TextureResType.plistType)
		self.Button_Roll:setEnabled(false)
		self.Image_RollNotice:setVisible(false)
		self.Image_RollNotice:stopAllActions() 
		self.Button_Reset:setEnabled(true)
		self.Image_Reward:getChildByName("Image_Name"):setVisible(true)
		self.Image_Reward:getChildByName("Text_Reward"):setVisible(true)
		textureName = "ui_roll_dice_module33_doulaoqian_zi_%d.png"
		self.Image_Reward:getChildByName("Image_Name"):loadTexture(diceRewardTexture[self.diceType]..".png", ccui.TextureResType.plistType)
		self.Image_Reward:getChildByName("Text_Reward"):setString(self:formatRewardText(self.diceType))
	else
		self.Button_Roll:setEnabled(true)
		self:runNoticeAction()
		self.Button_Reset:setEnabled(false)
		self.Image_Reward:getChildByName("Image_Name"):setVisible(false)
		self.Image_Reward:getChildByName("Text_Reward"):setVisible(false)
	end

	local hitDiceList = getDiceIndexByDiceType(rollDiceData.dice_list, self.diceType)
	for i=1, 4 do
		local btn = self["Button_Dice"..i]
		local icon = btn:getChildByName("Image_Icon")
		local flag = btn:getChildByName("Image_Flag")
		local mask = btn:getChildByName("Image_Mask")
		local dicePoint = rollDiceData.dice_list[i]
		if dicePoint then
			icon:loadTexture(string.format("ui_roll_dice_module33_doulaoqian_shaizi_%d.png", dicePoint), ccui.TextureResType.plistType)
			btn:setEnabled(true)
			if table.indexof(hitDiceList, i) then
				mask:setVisible(true)
			else
				mask:setVisible(false)
			end
			flag:setVisible(false)
		else
			btn:setEnabled(false)
			flag:setVisible(true)
		end
	end

    if rollDiceData.free_roll < cp.getUtils("DataUtils").GetVipEffect(7) then
		self.Text_FreeRoll:setString(string.format("今日免費次數%d次", cp.getUtils("DataUtils").GetVipEffect(7)-rollDiceData.free_roll))
	else
		self.Image_RollMoney:setVisible(true)
		self.Text_FreeRoll:setString(string.format("需要%d", self.rollDiceConfig.RollCost))
    end

	if rollDiceData.free_change < rollDiceData.total_free_change then
		self.Text_FreeChange:setString(string.format("今日免費換骰次數%d次", rollDiceData.total_free_change-rollDiceData.free_change))
	else
		self.Image_ChangeMoney:setVisible(true)
		local buyCount = rollDiceData.total_change-rollDiceData.free_change+1
		local const = 0
		if buyCount > #self.rollDiceConfig.ChangeCost then
			cost = self.rollDiceConfig.ChangeCost[#self.rollDiceConfig.ChangeCost]
		else
			cost = self.rollDiceConfig.ChangeCost[buyCount]
		end
		self.Text_FreeChange:setString(string.format("需要%d", cost))
	end

	if cp.getUtils("NotifyUtils").needNotifyGetRollReward() then
        cp.getManager("ViewManager").addRedDot(self.Button_Reward,cc.p(112,100))
	else
        cp.getManager("ViewManager").removeRedDot(self.Button_Reward)
	end
	--log(JudgeDiceType({4,3,5,2}))
	--log(JudgeDiceType({1,1,1,1}))
	--log(JudgeDiceType({1,2,1,1}))
	--log(JudgeDiceType({2,2,3,3}))
	--log(JudgeDiceType({2,2,1,3}))
	--log(JudgeDiceType({6,2,1,3}))
end

local dicePointList = {
	[1] = 80,
	[2] = 60,
	[3] = 25,
	[4] = 15,
	[5] = 5,
	[6] = 1
 }

function RollDiceLayer:formatRewardText(diceType)
	local rollPoint = dicePointList[diceType]
	local rollDiceEntry = cp.getManager("ConfigManager").getItemByKey("RollDice", rollPoint)
	local money = rollDiceEntry:getValue("DiceReward")
	local text = string.format("獎勵：\n%d積分\n%d銀兩", rollPoint, money)
	return text
end

function RollDiceLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, false)
	elseif nodeName == "Button_Roll" then
		local rollDiceReq = function()
			self:doSendSocket(cp.getConst("ProtoConst").RollDiceReq, {})
		end

		local rollDiceData = cp.getUserData("UserGuess"):getRollDiceData()
		if rollDiceData.free_roll < cp.getUtils("DataUtils").GetVipEffect(7) then
			rollDiceReq()
			return
		end

		local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("RollDice"), ";")
		if rollDiceData.total_roll - cp.getUtils("DataUtils").GetVipEffect(7) >= tonumber(info[4]) then
			cp.getManager("ViewManager").gameTip("今日購買次數已達上限")
			return
		end

		local remainCount = cp.getUtils("DataUtils").GetVipEffect(7) + tonumber(info[4]) - rollDiceData.total_roll
		local req = {}
		local needGold = info[2]
		local txt = [[
			<t fs="20" tc="4C331FFF">
				提升VIP等級可獲得更多免費搖骰次數，當前是否花費%d<i tt="1" p="ui_common_yuanbao.png" />，購買一次搖骰次數？
				<b bs="1"/>
				本日剩餘可購買次數：%d次
			</t>
		]]
		txt = string.format(txt, needGold, remainCount)
		cp.getManager("ViewManager").popMessageBoxPanel(self, "系統消息", txt, function()
			rollDiceReq()
		end)
	elseif nodeName == "Button_Reset" then
		local req = {}
		self:doSendSocket(cp.getConst("ProtoConst").ResetDiceStateReq, req)
	elseif nodeName == "Button_Reward" then
		local layer = require("cp.view.scene.guess.RollDiceRewardLayer"):create()
		self:addChild(layer, 100)
	end
end

--初始化界面，以及設定界面元素標籤
function RollDiceLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guess/uicsb_roll_dice.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.rollDiceConfig = cp.getUtils("DataUtils").parseRollDiceConfig(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("RollDice"))
	self.diceModelList = {}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_3"] = {name = "Image_3"},
		["Panel_root.Panel_Center"] = {name = "Panel_Center"},
		["Panel_root.Panel_Bottom"] = {name = "Panel_Bottom"},
		["Panel_root.Panel_Center.Image_1.Button_Close"] = {name = "Button_Close",click="onBtnClick", clickScale=0.9},
		["Panel_root.Panel_Center.Image_1.Button_Reset"] = {name = "Button_Reset",click="onBtnClick", clickScale=0.9},
		["Panel_root.Button_Reward"] = {name = "Button_Reward",click="onBtnClick", clickScale=0.9},
		["Panel_root.Panel_Bottom.Button_Roll"] = {name = "Button_Roll",click="onBtnClick", clickScale=0.9},
		["Panel_root.Panel_Center.Image_1"] = {name = "Image_1"},
		["Panel_root.Panel_Center.Image_1.Image_RollType1"] = {name = "Image_RollType1"},
		["Panel_root.Panel_Center.Image_1.Image_RollType2"] = {name = "Image_RollType2"},
		["Panel_root.Panel_Center.Image_1.Image_RollType3"] = {name = "Image_RollType3"},
		["Panel_root.Panel_Center.Image_1.Image_RollType4"] = {name = "Image_RollType4"},
		["Panel_root.Panel_Center.Image_1.Image_RollType5"] = {name = "Image_RollType5"},
		["Panel_root.Panel_Center.Image_1.Image_RollType6"] = {name = "Image_RollType6"},
		["Panel_root.Panel_Center.Image_1.Text_FreeChange"] = {name = "Text_FreeChange"},
		["Panel_root.Panel_Center.Image_1.Image_ChangeMoney"] = {name = "Image_ChangeMoney"},
		["Panel_root.Panel_Center.Image_1.Button_Dice1"] = {name = "Button_Dice1"},
		["Panel_root.Panel_Center.Image_1.Button_Dice2"] = {name = "Button_Dice2"},
		["Panel_root.Panel_Center.Image_1.Button_Dice3"] = {name = "Button_Dice3"},
		["Panel_root.Panel_Center.Image_1.Button_Dice4"] = {name = "Button_Dice4"},
		["Panel_root.Panel_Center.Image_1.Node_CoinDrop"] = {name = "Node_CoinDrop"},
		["Panel_root.Panel_Bottom.Image_Reward"] = {name = "Image_Reward"},
		["Panel_root.Panel_Bottom.Text_FreeRoll"] = {name = "Text_FreeRoll"},
		["Panel_root.Panel_Bottom.Image_RollMoney"] = {name = "Image_RollMoney"},
		["Panel_root.Panel_Bottom.Image_RollNotice"] = {name = "Image_RollNotice"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	self:updateDiceList()

	for i=1, 4 do
		local touzi = cc.Sprite:create()
		touzi:setName("TouZi")
		touzi:setScale(cp.getConst("GameConst").EffectScale)
			
		table.insert(self.diceModelList, touzi)
		touzi:setPositionX(self["Button_Dice"..i]:getPositionX())
		touzi:setPositionY(self["Button_Dice"..i]:getPositionY()+10)
		touzi:setVisible(false)
		self.Image_1:addChild(touzi, 100)
	end

	local model = cp.getManager("ViewManager").createSpineAnimation("res/spine/yuanbao/yuanbao")
	model:setName("yuanbao")
	self.Node_CoinDrop:setVisible(false)
	model:registerSpineEventHandler(function(tbl)
		self.Node_CoinDrop:setVisible(false)
	end, 2)
	self.Node_CoinDrop:addChild(model)
	--[[
	local req = {}
	req.module = 1
	req.step = -1
	self:doSendSocket(cp.getConst("ProtoConst").UpdateGuessGuideStepReq, req)
	]]
end

function RollDiceLayer:runNoticeAction()
	self.Image_RollNotice:setVisible(true)
	self.Image_RollNotice:stopAllActions()
	self.Image_RollNotice:setPosition(cc.p(538, 232))
	self.Image_RollNotice:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(538, 265)),
	cc.MoveTo:create(0.5, cc.p(538, 232)))))
end

function RollDiceLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function RollDiceLayer:onEnterScene()
	self:runGuideStep()
end

function RollDiceLayer:runGuideStep()
	self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
	local guideStep = cp.getUserData("UserGuess"):getRollDiceData().guide_step
	local contentTable = require("cp.story.RollDiceGuide")[guideStep]
	if not contentTable then
		if guideStep == 1 then
			cp.getManager("ViewManager").openGuideLayer(self, self.Button_Roll, 1)
		elseif guideStep == 3 then
			cp.getManager("ViewManager").openGuideLayer(self, self.Button_Reset, 1)
		elseif guideStep == 4 then
			cp.getManager("ViewManager").openGuideLayer(self, self.Button_Roll, 1)
		elseif guideStep == 6 then
			cp.getManager("ViewManager").openGuideLayer(self, self.Button_Dice4, 1)
		elseif guideStep == 8 then
			cp.getManager("ViewManager").openGuideLayer(self, self.Button_Reset, 1)
		elseif guideStep == 10 then
			local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Button_Reward, 1)
			guideLayer:setClickCallback(function()
				guideLayer:removeFromParent()
				local req = {}
				req.module = 1
				req.step = guideStep
				self:doSendSocket(cp.getConst("ProtoConst").UpdateGuessGuideStepReq, req)
			end)
		else
			log("nothing......................")
			return
		end
	elseif guideStep ~= 11 then
		local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 1)
		gamePopTalk:setPosition(cc.p(display.width/2,0))
		gamePopTalk:resetTalkText(contentTable)
		gamePopTalk:resetBgOpacity(100)
		gamePopTalk:setFinishedCallBack(function()
			gamePopTalk:removeFromParent()
			local req = {}
			req.module = 1
			req.step = guideStep
			self:doSendSocket(cp.getConst("ProtoConst").UpdateGuessGuideStepReq, req)
		end)
		gamePopTalk:hideSkip()
		self:addChild(gamePopTalk, 100)
	else
		log("nothing......................")
	end
end

function RollDiceLayer:onExitScene()
    self:unscheduleUpdate()
end

return RollDiceLayer