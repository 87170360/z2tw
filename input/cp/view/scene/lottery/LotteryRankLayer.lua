local BLayer = require "cp.view.ui.base.BLayer"
local LotteryRankLayer = class("LotteryRankLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function LotteryRankLayer:create()
    local scene = LotteryRankLayer.new()
	scene:updateLotteryRankView()
    return scene
end

function LotteryRankLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function LotteryRankLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_lottery_rank.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.imgList = {}

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Point"] = {name = "Text_Point"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.ListView_Rank"] = {name = "ListView_Rank"},
		["Panel_root.Image_1.Image_RankModel"] = {name = "Image_RankModel"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
	end)

    self.ListView_Rank:setScrollBarEnabled(false)
end

function LotteryRankLayer:updateLotteryRankView()
    local userLottery = cp.getUserData("UserLottery")
    self.Text_Point:setString("周積分 "..userLottery:getLotteryData().month_point)

    local lotteryRank = cp.getUserData("UserLottery"):getValue("LotteryRank")
    for i, rankInfo in ipairs(lotteryRank) do
        local imgRank = self.imgList[i]
        if not imgRank then
            imgRank = self.Image_RankModel:clone()
            self.imgList[i] = imgRank
        end

        imgRank:setVisible(true)
        local txtRank = imgRank:getChildByName("Text_Rank")
        local txtName = imgRank:getChildByName("Text_Name")
        local txtPoint = imgRank:getChildByName("Text_Point")
        local imgFlag = imgRank:getChildByName("Image_Flag")
        imgFlag:ignoreContentAdaptWithSize(true)
        if i == 1 then
            imgFlag:loadTexture("ui_treasure_module33_choujiang_jifenpaihangbang_diyi.png", ccui.TextureResType.plistType)
        elseif i == 2 then
            imgFlag:loadTexture("ui_treasure_module33_choujiang_jifenpaihangbang_disan.png", ccui.TextureResType.plistType)
        elseif i == 3 then
            imgFlag:loadTexture("ui_treasure_module33_choujiang_jifenpaihangbang_dier.png", ccui.TextureResType.plistType)
        else
            imgFlag:loadTexture("ui_treasure_module33_choujiang_jifenpaihangbang_di03.png", ccui.TextureResType.plistType)
        end
        txtRank:setString(i)
        txtName:setString(rankInfo.name)
        txtPoint:setString(rankInfo.point)
        local rewardList = cp.getUtils("DataUtils").splitAttr(cp.getManager("ConfigManager").getItemByKey("LotteryRankReward", i):getValue("ItemList"))
        for j=1, #rewardList do
            local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", rewardList[j][1])
            local btnReward = imgRank:getChildByName("Button_Item"..j)
            btnReward:setVisible(true)
            local imgIcon = btnReward:getChildByName("Image_Icon")
            local textNum = btnReward:getChildByName("Text_Num")
            textNum:setString(rewardList[j][2])
            btnReward:loadTextures(itemEntry:getValue("Icon"), itemEntry:getValue("Icon"), itemEntry:getValue("Icon"))
            imgIcon:loadTexture(CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
            
            if itemEntry:getValue("Type") == 2 then
                btnReward:getChildByName("Image_ItemType"):setVisible(true)
            else
                btnReward:getChildByName("Image_ItemType"):setVisible(false)
            end
            cp.getManager("ViewManager").initButton(btnReward, function()
            local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
                self:addChild(layer, 100)
            end, 1.0)
            cp.getManager("ViewManager").addWidgetBottom(btnReward, itemEntry:getValue("Hierarchy"))
        end
        self.ListView_Rank:addChild(imgRank)
    end
end

function LotteryRankLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
	end
end

function LotteryRankLayer:onEnterScene()
end

function LotteryRankLayer:onExitScene()
    self:unscheduleUpdate()
end

return LotteryRankLayer