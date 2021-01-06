local BLayer = require "cp.view.ui.base.BLayer"
local LotteryHouseLayer = class("LotteryHouseLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function LotteryHouseLayer:create()
	local scene = LotteryHouseLayer.new()
	scene:updateLotteryView()
    return scene
end

function LotteryHouseLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetLotteryDataRsp] = function(data)
			self:updateLotteryView()
		end,
        [cp.getConst("EventConst").BuySkillLotteryRsp] = function(data)
            local layer = require("cp.view.scene.lottery.LotteryItemLayer"):create(1, data)
            layer:setName("LotteryItemLayer")
            self:addChild(layer, 100)
            self:updateLotteryView()
		end,
        [cp.getConst("EventConst").BuyTreasureLotteryRsp] = function(data)
            local layer = require("cp.view.scene.lottery.LotteryItemLayer"):create(2, data)
            layer:setName("LotteryItemLayer")
            self:addChild(layer, 100)
            self:updateLotteryView()
		end,
		[cp.getConst("EventConst").GetLotteryRankRsp] = function(data)
            local layer = require("cp.view.scene.lottery.LotteryRankLayer"):create()
            self:addChild(layer, 100)
            self:updateLotteryView()
		end,
		[cp.getConst("EventConst").BuyLotteryPointShopRsp] = function(data)
            if cp.getUtils("NotifyUtils").needNotifyUsePoint() then
                cp.getManager("ViewManager").addRedDot(self.Button_Point, cc.p(80,80))
            else
                cp.getManager("ViewManager").removeRedDot(self.Button_Point)
            end
		end,
		[cp.getConst("EventConst").RefreshLotteryPointShopRsp] = function(data)
            if cp.getUtils("NotifyUtils").needNotifyUsePoint() then
                cp.getManager("ViewManager").addRedDot(self.Button_Point, cc.p(80,80))
            else
                cp.getManager("ViewManager").removeRedDot(self.Button_Point)
            end
        end,
        
        --新手指引獲取目標點位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "LotteryHouseLayer" then
                if evt.guide_name == "lottery" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					pos =   self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					--此步指引為向右的手指
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "LotteryHouseLayer" then
                if evt.guide_name == "lottery" then
                    self:onBtnClick(self[evt.target_name])
                    if evt.target_name == "Button_BuyOnce" or evt.target_name == "Button_BuyTenth" then
                        self[evt.target_name]:setTouchEnabled(false)
                        local sequence = {}
                        table.insert(sequence, cc.DelayTime:create(1))
                        table.insert(sequence,cc.CallFunc:create(function()
                            self[evt.target_name]:setTouchEnabled(true)
                        end))
                        self.Panel_root:runAction(cc.Sequence:create(sequence)) 
                    end
				end
			end
        end,
        
        [cp.getConst("EventConst").show_skillsect_layer] = function(evt)
			self:showSkillSectSelectLayer()
        end,
        
    }
end

--初始化界面，以及設定界面元素標籤
function LotteryHouseLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_lottery.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
		["Panel_root.Panel_top"] = {name = "Panel_top"},
		["Panel_root.Panel_top.Button_Pool"] = {name = "Button_Pool", click="onBtnClick"},
		["Panel_root.Panel_top.Button_Point"] = {name = "Button_Point", click="onBtnClick"},
		["Panel_root.Panel_top.Button_Rank"] = {name = "Button_Rank", click="onBtnClick"},
		["Panel_root.Panel_top.Button_Skill"] = {name = "Button_Skill", click="onBtnClick"},
		["Panel_root.Panel_top.Button_Treasure"] = {name = "Button_Treasure", click="onBtnClick"},
		["Panel_root.Panel_bottom.Button_BuyOnce"] = {name = "Button_BuyOnce", click="onBtnClick"},
        ["Panel_root.Panel_bottom.Button_BuyTenth"] = {name = "Button_BuyTenth", click="onBtnClick"},
        ["Panel_root.Panel_bottom.Button_Say"] = {name = "Button_Say", click="onBtnClick"},
        ["Panel_root.Panel_bottom.Node_Boss"] = {name = "Node_Boss"},
        ["Panel_root.Panel_bottom.Image_Notice"] = {name = "Image_Notice"},
        ["Panel_root.Panel_bottom.Image_Notice.AtlasLabel_BuyNum"] = {name = "AtlasLabel_BuyNum"},
        ["Panel_root.Panel_bottom.Text_BuyOnce"] = {name = "Text_BuyOnce"},
        ["Panel_root.Panel_bottom.Text_OnceCost"] = {name = "Text_OnceCost"},
        ["Panel_root.Panel_bottom.Text_FreeTime"] = {name = "Text_FreeTime"},
        ["Panel_root.Panel_bottom.Text_BuyCount"] = {name = "Text_BuyCount"},
        ["Panel_root.Panel_bottom.Text_BuyTenth"] = {name = "Text_BuyTenth"},
        ["Panel_root.Panel_bottom.Text_TenthCost"] = {name = "Text_TenthCost"},
        ["Panel_root.Panel_bottom.Image_OnceCost"] = {name = "Image_OnceCost"},
        ["Panel_root.Panel_bottom.Image_TenthCost"] = {name = "Image_TenthCost"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    
    self.Panel_top:setPosition(cc.p(0, display.height))
    self.Button_Skill:setEnabled(false)
    self.Button_Treasure:setEnabled(true)
    
	local model = self.Node_Boss:getChildByName("Boss")
	if not model then
		model = cp.getManager("ViewManager").createSpineAnimation("res/spine/laoban/laoban")
        model:setAnimation(0, "Stand", true)
        model:setName("Boss")
		self.Node_Boss:addChild(model)
    end
    self:setupAchivementGuide()
end

function LotteryHouseLayer:setupAchivementGuide()
    local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
    if guideType == 8 then
        guideBtn = self.Button_Treasure
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    elseif guideType == 30 then
        guideBtn = self.Button_Skill
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end
    
    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function LotteryHouseLayer:updateLotteryView()
    self.Text_FreeTime:stopAllActions()
    
    if cp.getUtils("NotifyUtils").needNotifyUsePoint() then
        cp.getManager("ViewManager").addRedDot(self.Button_Point, cc.p(80,80))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Point)
    end

    if self.mode == 1 then
        local itemNum = cp.getUserData("UserItem"):getItemNum(614)
        if cp.getUtils("NotifyUtils").needNotifySkillLottery() then
            cp.getManager("ViewManager").addRedDot(self.Button_BuyOnce,cc.p(180,60))
        else
            cp.getManager("ViewManager").removeRedDot(self.Button_BuyOnce)
        end
        self.Image_OnceCost:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        self.Image_TenthCost:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        local skillLottery = cp.getUserData("UserLottery"):getSkillLottery()
        local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("SkillLottery"), ":")
        self.Image_Notice:setVisible(true)
        local buyCount = 10-skillLottery.buy_count%10
        if buyCount == 1 then
            self.AtlasLabel_BuyNum:setVisible(false)
            self.Image_Notice:loadTexture("ui_treasure_module33_choujiang02.png", ccui.TextureResType.plistType)
            --self.AtlasLabel_BuyNum:setString("本次購買必得稀有武學")
        else
            self.Image_Notice:loadTexture("ui_treasure_module33_choujiang_bidewuxue.png", ccui.TextureResType.plistType)
            self.AtlasLabel_BuyNum:setString(buyCount)
            self.AtlasLabel_BuyNum:setVisible(true)
        end
        self.Text_BuyCount:setVisible(true)
        local remainCount = tonumber(info[5]) - skillLottery.count
        if remainCount < 0 then remainCount = 0 end
        self.Text_BuyCount:setString(string.format("本日剩餘購買次數：%2d次", remainCount))
        self.Text_BuyOnce:setString(string.format("買1次武林祕籍\n贈送%d點積分", info[3]))
        self.Text_OnceCost:setString(info[1])
        self.Text_BuyTenth:setString(string.format("買10次武林祕籍\n贈送%d點積分", info[3]*10))
        self.Text_TenthCost:setString(info[2])
        local now = cp.getManager("TimerManager"):getTime()
        if itemNum > 10 then
            self.Text_TenthCost:setString(10)
            self.Image_TenthCost:loadTexture("ui_common_01_chouijangquan.png", ccui.TextureResType.plistType)
        else
            self.Image_TenthCost:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
        end
        if now - skillLottery.free_time >= tonumber(info[4])*3600 then
            self.Text_FreeTime:setString("本次免費")
            self.Image_OnceCost:setVisible(false)
            self.Text_OnceCost:setVisible(false)
            self.Text_FreeTime:setPositionY(181)
            self.isFree = true
        else
            if itemNum > 0 then
                self.Image_OnceCost:loadTexture("ui_common_01_chouijangquan.png", ccui.TextureResType.plistType)
                self.Text_OnceCost:setString("1")
            else
                self.Image_OnceCost:loadTexture("ui_common_yuanbao.png", ccui.TextureResType.plistType)
            end

            self.Image_OnceCost:setVisible(true)
            self.Text_OnceCost:setVisible(true)
            self.Text_FreeTime:setPositionY(141)
            self.isFree = false
            self.Text_FreeTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                local now = cp.getManager("TimerManager"):getTime()
                local deltaTime = tonumber(info[4])*3600 - (now - skillLottery.free_time)
                if deltaTime == 0 then
                    self.Text_FreeTime:setString("本次免費")
                    self.Text_FreeTime:stopAllActions()
                    self.Image_OnceCost:setVisible(false)
                    self.Text_OnceCost:setVisible(false)
                    self.Text_FreeTime:setPositionY(181)
                    self.isFree = true
                else
                    local hour, minute, sec = math.floor(deltaTime/3600), math.floor((deltaTime%3600)/60), deltaTime%60
                    self.Text_FreeTime:setString(string.format("%02d小時%02d分%02d秒後免費",hour, minute, sec))
                    self.Image_OnceCost:setVisible(true)
                    self.Text_OnceCost:setVisible(true)
                    self.Text_FreeTime:setPositionY(141)
                end
                end),cc.DelayTime:create(1))))
        end
    else
        if cp.getUtils("NotifyUtils").needNotifyTreasureLottery() then
            cp.getManager("ViewManager").addRedDot(self.Button_BuyOnce,cc.p(180,60))
        else
            cp.getManager("ViewManager").removeRedDot(self.Button_BuyOnce)
        end
        self.Image_OnceCost:loadTexture("ui_common_yinliang.png", ccui.TextureResType.plistType)
        self.Image_TenthCost:loadTexture("ui_common_yinliang.png", ccui.TextureResType.plistType)
        local treasureLottery = cp.getUserData("UserLottery"):getTreasureLottery()
        local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("TreasureLottery"), ":")
        self.Image_Notice:setVisible(false)
        self.Text_BuyCount:setVisible(false)
        self.Text_BuyOnce:setString(string.format("買1次江湖奇珍\n贈送%d點積分", info[3]))
        self.Text_OnceCost:setString(info[1])
        self.Text_BuyTenth:setString(string.format("買10次江湖奇珍\n贈送%d點積分", info[3]*10))
        self.Text_TenthCost:setString(info[2])
        if treasureLottery.free_count >= tonumber(info[5]) then
            self.Text_FreeTime:setVisible(false)
            self.Image_OnceCost:setVisible(true)
            self.Text_OnceCost:setVisible(true)
        else
            self.Text_FreeTime:setVisible(true)
            local now = cp.getManager("TimerManager"):getTime()
            if now - treasureLottery.free_time >= tonumber(info[4])*60 then
                self.Text_FreeTime:setString("本次免費")
                self.Image_OnceCost:setVisible(false)
                self.Text_OnceCost:setVisible(false)
                self.Text_FreeTime:setPositionY(181)
            else
                self.Image_OnceCost:setVisible(true)
                self.Text_OnceCost:setVisible(true)
                self.Text_FreeTime:setPositionY(141)
                self.Text_FreeTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                    local now = cp.getManager("TimerManager"):getTime()
                    local deltaTime = tonumber(info[4])*60 - (now - treasureLottery.free_time)
                    if deltaTime == 0 then
                        self.Text_FreeTime:setString("本次免費")
                        self.Text_FreeTime:stopAllActions()
                        self.Image_OnceCost:setVisible(false)
                        self.Text_OnceCost:setVisible(false)
                        self.Text_FreeTime:setPositionY(181)
                    else
                        local minute, sec = math.floor(deltaTime/60), deltaTime%60
                        self.Text_FreeTime:setString(string.format("%02d分%02d秒後免費", minute, sec))
                        self.Image_OnceCost:setVisible(true)
                        self.Text_OnceCost:setVisible(true)
                        self.Text_FreeTime:setPositionY(141)
                    end
                    end),cc.DelayTime:create(1))))
            end
        end
    end
end

function LotteryHouseLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function LotteryHouseLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:getParent():removeChild(self)
    elseif nodeName == "Button_Skill" then
        if self.mode == 2 then
            self.mode = 1
            self.Button_Skill:setEnabled(false)
            self.Button_Treasure:setEnabled(true)
            self:updateLotteryView()
        end
    elseif nodeName == "Button_Treasure" then
        if self.mode == 1 then
            self.mode = 2
            self.Button_Skill:setEnabled(true)
            self.Button_Treasure:setEnabled(false)
            self:updateLotteryView()
            self:delayNewGuide()
        end
    elseif nodeName == "Button_BuyOnce" then
        local req = {}
        local now = cp.getManager("TimerManager"):getTime()
        if self.mode == 1 then
            local itemNum = cp.getUserData("UserItem"):getItemNum(614)
            local skillLottery = cp.getUserData("UserLottery"):getSkillLottery()
            if not self.isFree and skillLottery.count + 1 > 50 then
                cp.getManager("ViewManager").gameTip("今日購買次數已達上限")
                return
            end
            local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("SkillLottery"), ":")
            if now - skillLottery.free_time >= tonumber(info[4])*3600 then
                req.buy_type = 1
            elseif itemNum > 0 then
                req.buy_type = 3
            else
                req.buy_type = 2
            end

            self:doSendSocket(cp.getConst("ProtoConst").BuySkillLotteryReq, req)
        else
            local treasureLottery = cp.getUserData("UserLottery"):getTreasureLottery()
            local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("TreasureLottery"), ":")
            if now - treasureLottery.free_time >= tonumber(info[4])*60 and treasureLottery.free_count < tonumber(info[5]) then
                req.buy_type = 1
            else
                req.buy_type = 2
            end
			req.buy_count = 1
            self:doSendSocket(cp.getConst("ProtoConst").BuyTreasureLotteryReq, req)
        end
	elseif nodeName == "Button_BuyTenth" then
		local req = {}
        req.buy_count = 10
        if self.mode == 1 then
            local skillLottery = cp.getUserData("UserLottery"):getSkillLottery()
            local info = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("SkillLottery"), ":")
            if skillLottery.count + 10 > tonumber(info[5]) then
                cp.getManager("ViewManager").gameTip("今日購買次數已達上限")
                return
            end
            
            local itemNum = cp.getUserData("UserItem"):getItemNum(614)
            if itemNum >= 10 then
                req.buy_type = 3
            else
                req.buy_type = 2
            end
            self:doSendSocket(cp.getConst("ProtoConst").BuySkillLotteryReq, req)
        else
            req.buy_type = 2
            req.buy_count = 10
            self:doSendSocket(cp.getConst("ProtoConst").BuyTreasureLotteryReq, req)
        end
	elseif nodeName == "Button_Pool" then
        local layer = require("cp.view.scene.lottery.LotteryPoolLayer"):create()
        self:addChild(layer, 100)
	elseif nodeName == "Button_Point" then
        local layer = require("cp.view.scene.lottery.LotteryPointLayer"):create()
        self:addChild(layer, 100)
    elseif nodeName == "Button_Rank" then
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GetLotteryRankReq, req)
    elseif nodeName == "Button_Say" then
	end
end

function LotteryHouseLayer:onEnterScene()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lottery" then
        local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "lottery" then
			if step >= 10 and step < 16 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",12)
            elseif step >= 16 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",19)
            end
        end
    end
    self:delayNewGuide()
end

function LotteryHouseLayer:onExitScene()
    self:unscheduleUpdate()
end

function LotteryHouseLayer:delayNewGuide()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lottery" then
        local sequence = {}
        table.insert(sequence, cc.DelayTime:create(0.3))
        table.insert(sequence,cc.CallFunc:create(function()
            -- local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
            local info = 
            {
                classname = "LotteryHouseLayer",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end))
        self:runAction(cc.Sequence:create(sequence))
    end
end

function LotteryHouseLayer:showSkillSectSelectLayer()
    
    local layer = require("cp.view.scene.world.major.SkillSectSelect"):create()
    layer:setCloseCallBack(function()
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        log("cur_step = " .. cur_step)
    end)
    self:addChild(layer, 101)
end

return LotteryHouseLayer