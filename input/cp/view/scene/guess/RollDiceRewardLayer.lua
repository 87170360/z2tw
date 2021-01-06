local BLayer = require "cp.view.ui.base.BLayer"
local RollDiceRewardLayer = class("RollDiceRewardLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RollDiceRewardLayer:create()
	local scene = RollDiceRewardLayer.new()
    return scene
end

function RollDiceRewardLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetMonthRewardRsp] = function(proto)
            local rollDiceEntry = cp.getManager("ConfigManager").getItemByKey("RollDice", proto.roll_point)
			local itemList = cp.getUtils("DataUtils").splitAttr(rollDiceEntry:getValue("MonthReward"))
			for _, itemInfo in ipairs(itemList) do
				itemInfo.id = itemInfo[1]
				itemInfo.num = itemInfo[2]
			end
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
			self:updateRollDiceRewardView()
		end,
    }
end

function RollDiceRewardLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	end
end
--初始化界面，以及設定界面元素標籤
function RollDiceRewardLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guess/uicsb_roll_dice_reward.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close",click="onBtnClick", clickScale=0.9},
		["Panel_root.Image_1.Text_MonthPoint"] = {name = "Text_MonthPoint"},
		["Panel_root.Image_1.Image_Model"] = {name = "Image_Model"},
		["Panel_root.Image_1.ListView_Reward"] = {name = "ListView_Reward"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1, self)
	self:updateRollDiceRewardView()
	self.ListView_Reward:setScrollBarEnabled(false)
end

function RollDiceRewardLayer:popFinishCallback()
	self:runGuideStep()
end

function RollDiceRewardLayer:updateRollDiceRewardView()
	self.ListView_Reward:removeAllItems()
	local rollDiceData = cp.getUserData("UserGuess"):getRollDiceData()
	self.Text_MonthPoint:setString("本月積分："..rollDiceData.month_point)
	cp.getManager("ConfigManager").foreach("RollDice", function(entry)
		if string.len(entry:getValue("MonthReward")) > 0 then
			local model = self.Image_Model:clone()
			model:setVisible(true)
			local point = model:getChildByName("Text_MonthPoint")
			local btnGet = model:getChildByName("Button_Get")
			if not table.indexof(rollDiceData.point_list, entry:getValue("RollPoint")) then
				if rollDiceData.month_point >= entry:getValue("RollPoint") then
					cp.getManager("ViewManager").initButton(btnGet, function()
						local req = {}
						req.roll_point = entry:getValue("RollPoint")
						self:doSendSocket(cp.getConst("ProtoConst").GetMonthRewardReq, req)
					end, 0.9)
					cp.getManager("ViewManager").addRedDot(btnGet,cc.p(110,35))
					cp.getManager("ViewManager").setEnabled(btnGet, true)
				else
					btnGet:setTitleText("積分不夠")
					cp.getManager("ViewManager").setEnabled(btnGet, false)
					cp.getManager("ViewManager").removeRedDot(btnGet)
				end
			else
				btnGet:setEnabled(false)
				btnGet:setTitleText("已  領")
				cp.getManager("ViewManager").setEnabled(btnGet, false)
				cp.getManager("ViewManager").removeRedDot(btnGet)
			end

			point:setString("月積分需達到"..entry:getValue("RollPoint"))
			local itemList = cp.getUtils("DataUtils").splitAttr(entry:getValue("MonthReward"))
			for i, itemInfo in ipairs(itemList) do
				local item = model:getChildByName("Item_"..i)
				if not item then
					item = require("cp.view.ui.icon.ItemIcon"):create(nil)
					item:setPosition(70+(i-1)*126, 96)
					item:setName("Item_"..i)
					model:addChild(item, 100)
				end

				local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo[1])
				itemInfo.id = itemInfo[1]
				itemInfo.num = itemInfo[2]
				itemInfo.Colour = itemEntry:getValue("Hierarchy")
				itemInfo.Name = itemEntry:getValue("Name") 
				itemInfo.Icon = itemEntry:getValue("Icon")
				itemInfo.Type = itemEntry:getValue("Type")

				item:reset(itemInfo)
				item:setItemClickCallBack(function()
					local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
					self:addChild(layer,100)
				end)
			end
			self.ListView_Reward:pushBackCustomItem(model)
		end
		return true
	end)
end

function RollDiceRewardLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function RollDiceRewardLayer:onEnterScene()
end

function RollDiceRewardLayer:onExitScene()
    self:unscheduleUpdate()
end

function RollDiceRewardLayer:runGuideStep()
	self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
	local guideStep = cp.getUserData("UserGuess"):getRollDiceData().guide_step
	local contentTable = require("cp.story.RollDiceGuide")[guideStep]
	if not contentTable then
		return
	else
		local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 1)
		gamePopTalk:setPosition(cc.p(display.width/2,0))
		gamePopTalk:resetTalkText(contentTable)
		gamePopTalk:resetBgOpacity(150)
		gamePopTalk:setFinishedCallBack(function()
			gamePopTalk:removeFromParent()
			local req = {}
			req.module = 1
			req.step = guideStep
			self:doSendSocket(cp.getConst("ProtoConst").UpdateGuessGuideStepReq, req)
		end)
		gamePopTalk:hideSkip()
		self:addChild(gamePopTalk, 100)
	end
end

return RollDiceRewardLayer