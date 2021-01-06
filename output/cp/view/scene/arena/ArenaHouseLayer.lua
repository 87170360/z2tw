local BLayer = require "cp.view.ui.base.BLayer"
local ArenaHouseLayer = class("ArenaHouseLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ArenaHouseLayer:create()
	local scene = ArenaHouseLayer.new()
	scene:updateArenaView(true)
    return scene
end

function ArenaHouseLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetArenaDataRsp] = function(data)
			self:updateArenaView(true)
		end,
		[cp.getConst("EventConst").StoreBuyRsp] = function(data)
			self:updateArenaView(false)
		end,
        [cp.getConst("EventConst").RefreshOpponentRankRsp] = function(data)
            self:updateArenaView(true)
            self:runGuideStep()
		end,
        [cp.getConst("EventConst").BuyChallengeRsp] = function(data)
            self:updateArenaView(false)
		end,
        [cp.getConst("EventConst").ArenaFightRsp] = function(data)
            self:updateArenaView(true)

            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
            
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		[cp.getConst("EventConst").GetArenaRankListRsp] = function(data)
            local layer = require("cp.view.scene.arena.ArenaRankLayer"):create(data)
            self:addChild(layer, 100)
		end,
        [cp.getConst("EventConst").GetCombatListRsp] = function(proto)
            local layer = require("cp.view.scene.world.shaneevent.RiverCombatListLayer"):create(proto.combat_list, CombatConst.CombatType_Arena)
            self:addChild(layer, 100)
        end,
        [cp.getConst("EventConst").GetLastRankAwardRsp] = function(data)
            self:updateArenaView(false)
            local itemList = {
                {
                    id = 3,num = data.gold
                },
                {
                    id = 1096, num = data.prestige
                }
            }
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
        ["ArenaRankChangeRsp"] = function(data)
            self:updateArenaView(true)
		end,
		["UpdateArenaGuideRsp"] = function(proto)
			self:runGuideStep()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function ArenaHouseLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_arena/uicsb_arena_main.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Panel_Player1"] = {name = "Panel_Player1"},
		["Panel_root.Image_1.Panel_Player2"] = {name = "Panel_Player2"},
		["Panel_root.Image_1.Panel_Player3"] = {name = "Panel_Player3"},
		["Panel_root.Image_1.Button_Rank"] = {name = "Button_Rank", click="onBtnClick"},
		["Panel_root.Image_1.Button_Fight"] = {name = "Button_Fight", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Buffer"] = {name = "Button_Buffer", click="onBtnClick"},
        ["Panel_root.Image_1.Text_Count"] = {name = "Text_Count"},
        ["Panel_root.Image_1.Button_AddCount"] = {name = "Button_AddCount", click="onBtnClick"},
        
		["Panel_root.Image_Bottom.Text_Rank"] = {name = "Text_Rank"},
		["Panel_root.Image_Bottom.Text_Prestige"] = {name = "Text_Prestige"},
		["Panel_root.Image_Bottom.Button_Refresh"] = {name = "Button_Refresh", click="onBtnClick"},
        ["Panel_root.Image_Bottom.Button_Reward"] = {name = "Button_Reward", click="onBtnClick"},
        ["Panel_root.Image_Bottom.Button_Prestige"] = {name = "Button_Prestige", click="onBtnClick"},
        ["Panel_root.Image_Bottom.Button_Record"] = {name = "Button_Record", click="onBtnClick"},

        ["Panel_root.Image_Top.Button_Rule"] = {name = "Button_Rule", click="onBtnClick"},
        ["Panel_root.Image_Top.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    ccui.Helper:doLayout(self.rootView)
end

function ArenaHouseLayer:setModelSelect(index)
    if not index then index = 1 end
    local arenaData = cp.getUserData("UserArena"):getArenaData()
    self.selectRank = index
    local selectColor = cc.c4b(73,52,34,255)
    local idleColor = cc.c4b(255,242,188,255)
    for i=1, 3 do
        local node = self["Panel_Player"..i]
        local playerInfo = arenaData.opponent_list[i]
        local imgName = node:getChildByName("Image_Name")
        local imgRank = node:getChildByName("Image_Rank")
        local imgFight = node:getChildByName("Image_Fight")
        local imgBottom = node:getChildByName("Image_Bottom")
        local imgSelect = node:getChildByName("Image_Select")
        local txtName = node:getChildByName("Text_Name")
        local txtRank = node:getChildByName("Text_Rank")
        local txtFight = node:getChildByName("Text_Fight")
        imgSelect:stopAllActions()
        if self.selectRank == i then
            txtName:setTextColor(selectColor)
            txtRank:setTextColor(selectColor)
            txtFight:setTextColor(selectColor)
            imgName:setVisible(false)
            imgRank:setVisible(false)
            imgFight:setVisible(false)
            imgBottom:setVisible(true)
            imgSelect:setVisible(true)
            node:setZOrder(100)
            
	        imgSelect:setVisible(true)
	        imgSelect:setPosition(cc.p(77, 250))
	        imgSelect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(77, 280)),
	        cc.MoveTo:create(0.5, cc.p(77, 250)))))
        else
            txtName:setTextColor(idleColor)
            txtRank:setTextColor(idleColor)
            txtFight:setTextColor(idleColor)
            imgName:setVisible(true)
            imgRank:setVisible(true)
            imgFight:setVisible(true)
            imgBottom:setVisible(false)
            imgSelect:setVisible(false)
            node:setZOrder(1)
        end
    end
end

function ArenaHouseLayer:updateArenaView(refreshModel)
    local arenaData = cp.getUserData("UserArena"):getArenaData()
    local limitCount = cp.getUtils("DataUtils").GetVipEffect(6)
    self.Text_Count:setString(string.format("剩餘挑戰次數：%d/%d", limitCount-arenaData.challenge_count, limitCount))
    if arenaData.my_rank > 1500 then
        self.Text_Rank:setString("未上榜")
    else
        self.Text_Rank:setString(arenaData.my_rank)
    end
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    self.Text_Prestige:setString(roleAtt.prestige)

    self.Button_Reward:getChildByName("Image_Flag"):setVisible(not arenaData.award)
    if not refreshModel then return end
    self:setModelSelect()
    for i=1, 3 do
        local node = self["Panel_Player"..i]
        local playerInfo = arenaData.opponent_list[i]
        local model = node:getChildByName("Model")
        if model then
            model:removeFromParent()
        end

        cp.getUtils("DataUtils").fillArenaPlayerInfo(playerInfo)
        local suffix = ""
        if playerInfo.type == 1 then
            model = cp.getManager("ViewManager").createModel(playerInfo.model)
        else
            --suffix = "NPC"
            model = cp.getManager("ViewManager").createNpc(playerInfo.id)
        end
        model:setName("Model")
        model:setPosition(78, 10)
        node:addChild(model)
        --model:setAnimation(0, "Win_start", false)
        --model:addAnimation(0, "Win_loop", true)
        model:addAnimation(0, "Stand", true)
        model:setZOrder(1)

        local txtName = node:getChildByName("Text_Name")
        local txtRank = node:getChildByName("Text_Rank")
        local txtFight = node:getChildByName("Text_Fight")
        local particalSelect = node:getChildByName("Particle_Select")
        particalSelect:setVisible(false)
        txtName:setString("名稱 "..playerInfo.name..suffix)
        txtName:setZOrder(100)
        txtFight:setString("戰力 "..playerInfo.fight)
        txtFight:setZOrder(100)
        txtRank:setString("排名 "..playerInfo.rank)
        txtRank:setZOrder(100)
        particalSelect:setZOrder(90)

        cp.getManager("ViewManager").initButton(node, function()
            self:setModelSelect(i)
        end, 1.0)
    end
end

function ArenaHouseLayer:showBuyCountMessageBox()
    local arenaData = cp.getUserData("UserArena"):getArenaData()
    local temp = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("ArenaConfig"), ";")[1]
    local costList = cp.getUtils("DataUtils").split(temp, ":")
    local need = cp.getUtils("DataUtils").GetPriceByCount(arenaData.buy_count, costList)
    local function comfirmFunc()
        --檢測是否元寶足夠
        if cp.getManager("ViewManager").checkGoldEnough(need) then
            --發送重置擂臺挑戰的次數協議
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").BuyChallengeReq, req)
        end
    end

    local contentTable = {
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="提升VIP等級可獲得更多免費挑戰次數，是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="重置今日挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
    }
    cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
end

function ArenaHouseLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Back" then
        self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, false)
    elseif nodeName == "Button_Fight" then
        if not self.selectRank then
            cp.getManager("ViewManager").gameTip("請選擇要挑戰的玩家")
            return
        end
        local arenaData = cp.getUserData("UserArena"):getArenaData()
        local limitCount = cp.getUtils("DataUtils").GetVipEffect(6)
        if arenaData.challenge_count >= limitCount then
            self:showBuyCountMessageBox()
        end

        local playerInfo = arenaData.opponent_list[self.selectRank]

        self.fightInfo = {name = playerInfo.name} 
        
        local req = {}
        req.rank = playerInfo.rank
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ArenaFightReq, req)
    elseif nodeName == "Button_Rank" then
        local req = {}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").GetArenaRankListReq, req)
    elseif nodeName == "Button_Refresh" then
        local req = {}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").RefreshOpponentRankReq, req)
    elseif nodeName == "Button_Buffer" then
        local layer = require("cp.view.scene.arena.ArenaBufferLayer"):create()
        self:addChild(layer, 100)
    elseif nodeName == "Button_Rule" then
        local layer = require("cp.view.scene.arena.ArenaRuleLayer"):create()
        self:addChild(layer, 100)
    elseif nodeName == "Button_Record" then
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local req = {}
        req.combat_type = CombatConst.CombatType_Arena
        req.time = cp.getManager("TimerManager"):getTime()-24*3600*30
        req.max_num = 20
        req.uid = major_roleAtt.account
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatListReq, req)
    elseif nodeName == "Button_Reward" then
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GetLastRankAwardReq, req)
    elseif nodeName == "Button_Prestige" then
        if self.ShopMainUI ~= nil then
            self.ShopMainUI:removeFromParent()
        end
        self.ShopMainUI = nil
        
        local storeID = 6  --聲望商店
        local openInfo = {storeID = storeID, closeCallBack = function()
            self.ShopMainUI:removeFromParent()
            self.ShopMainUI = nil
        end}
        local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
        self.rootView:addChild(ShopMainUI)
        self.ShopMainUI = ShopMainUI
    elseif nodeName == "Button_AddCount" then
        self:showBuyCountMessageBox()
	end
end

function ArenaHouseLayer:onEnterScene()
    self:setModelSelect(nil)
	self:runGuideStep()
end

function ArenaHouseLayer:onExitScene()
    self:unscheduleUpdate()
end

function ArenaHouseLayer:enterArenaGuideCombat() 
    cp.getUserData("UserCombat"):setCombatType(CombatConst.CombatType_ArenaGuide)
    cp.getUserData("UserCombat"):setCombatScene(5)
    local path = cc.FileUtils:getInstance():fullPathForFilename("res/arena_guide")
    local combat_result =  cc.FileUtils:getInstance():getStringFromFile(path)
    local result = cp.getManager("ProtobufManager"):decode2Table("protocal.CombatResult", gzip.decompress(combat_result))
    cp.getUserData("UserCombat"):setCombatResult(result)
    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
end

function ArenaHouseLayer:runGuideStep()
	self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
	local guideStep = cp.getUserData("UserArena"):getArenaData().guide_step
	local contentTable = require("cp.story.ArenaGuide")[guideStep]
    if not contentTable then
        if guideStep == 1 then
            local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Panel_Player3, 1)
            guideLayer:setClickCallback(function()
                local req = {}
                req.step = guideStep
                self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
            end)
        elseif guideStep == 3 then
            cp.getManager("ViewManager").openGuideLayer(self, self.Button_Refresh, 1)
        elseif guideStep == 5 then
            local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Panel_Player1, 1)
            guideLayer:setClickCallback(function()
                local req = {}
                req.step = guideStep
                self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
            end)
        elseif guideStep == 6 then
            cp.getManager("ViewManager").openGuideLayer(self, self.Button_Fight, 1)
        elseif guideStep == 8 then
            local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Button_Record, 1)
            guideLayer:setClickCallback(function()
                local req = {}
                req.step = guideStep
                self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
            end)
        elseif guideStep == 12 then
            self:enterArenaGuideCombat()
            local req = {}
            req.step = guideStep
            self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
        else
            return
        end
    elseif guideStep ~= 9 then
		local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 0.5)
		gamePopTalk:setPosition(cc.p(display.width/2,120))
		gamePopTalk:resetTalkText(contentTable)
		gamePopTalk:resetBgOpacity(150)
		gamePopTalk:setFinishedCallBack(function()
			gamePopTalk:removeFromParent()
			local req = {}
			req.step = guideStep
            self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
		end)
		gamePopTalk:hideSkip()
		self:addChild(gamePopTalk, 100)
	end
end

return ArenaHouseLayer