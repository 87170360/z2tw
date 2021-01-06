local BLayer = require "cp.view.ui.base.BLayer"
local RiverHeroListLayer = class("RiverHeroListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverHeroListLayer:create()
	local scene = RiverHeroListLayer.new()
    return scene
end

function RiverHeroListLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").BribeAllHeroRsp] = function(proto)
            self:updateRiverHeroListView()
            self:updateAwardList()
		end,
        [cp.getConst("EventConst").StartFightHeroRsp] = function(proto)
            self:updateRiverHeroListView()
		end,
        [cp.getConst("EventConst").GetAccuAwardRsp] = function(proto)
            self:updateAwardList()
		end,
        [cp.getConst("EventConst").BribeHeroRsp] = function(proto)
            self:updateRiverHeroListView()
            self:updateAwardList()
		end,
    }
end

function RiverHeroListLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Close" then
        self:removeFromParent()
    elseif btnName == "Button_OneKey" then
        
        -- local needGold = cp.getUserData("UserNpc"):getValue("bribe")
        local needGold = cp.getManager("GDataManager"):getAllHeroBribeNeed()
        if needGold == 0 then
            cp.getManager("ViewManager").gameTip("您已結交所有豪傑")
            return
        end
		local contentTable = {
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(needGold), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，結交以上豪俠，直接獲得豪俠獎勵？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		}

		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2, function()
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").BribeAllHeroReq, req)
		end,nil)
    end
end

--初始化界面，以及設定界面元素標籤
function RiverHeroListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_hero_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.killList = {3, 8 , 15, 18}

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_top.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1},
        ["Panel_root.Image_center"] = {name = "Image_center"},
        ["Panel_root.Image_center.Text_Refresh"] = {name = "Text_Refresh"},
        ["Panel_root.Image_center.Image_HeroBg"] = {name = "Image_HeroBg"},
        ["Panel_root.Image_center.Image_HeroBg.ScrollView_Heros"] = {name = "ScrollView_Heros"},
        ["Panel_root.Image_center.Image_HeroBg.ScrollView_Heros.Image_Model"] = {name = "Image_Model"},
        ["Panel_root.Image_center.Button_OneKey"] = {name = "Button_OneKey", click="onBtnClick"},
        ["Panel_root.Image_center.Image_Kill1"] = {name = "Image_Kill1"},
        ["Panel_root.Image_center.Image_Kill2"] = {name = "Image_Kill2"},
        ["Panel_root.Image_center.Image_Kill3"] = {name = "Image_Kill3"},
        ["Panel_root.Image_center.Image_Kill4"] = {name = "Image_Kill4"},
        ["Panel_root.Image_center.Image_Progress"] = {name = "Image_Progress"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    local deltaHeight = display.height - 1280
    local size = self.Image_center:getSize()
    size.height = size.height + deltaHeight
    self.Image_center:setSize(size)
    size = self.Image_HeroBg:getSize()
    size.height = size.height + deltaHeight
    self.Image_HeroBg:setSize(size)
    size = self.ScrollView_Heros:getSize()
    size.height = size.height + deltaHeight
    self.ScrollView_Heros:setSize(size)
    self.ScrollView_Heros:setScrollBarEnabled(false)
    if display.height > 1280 then
        for i=1, 3 do
            local img = self.ScrollView_Heros:getChildByName("Image_Model"..i)
            local posX, posY = img:getPosition()
            posY = posY + deltaHeight
            img:setPosition(posX, posY)
        end
        for i=4, 6 do
            local img = self.ScrollView_Heros:getChildByName("Image_Model"..i)
            local posX, posY = img:getPosition()
            posY = posY + deltaHeight/2
            img:setPosition(posX, posY)
        end
    end

    ccui.Helper:doLayout(self.rootView)
end

function RiverHeroListLayer:updateRiverHeroListView()
    local leftTime = cp.getUserData("UserNpc"):getValue("leftTime")
    self.Text_Refresh:stopAllActions()
    self.Text_Refresh:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local text = cp.getUtils("DataUtils").formatTimeRemainEx(leftTime)
        self.Text_Refresh:setString(text.."後刷新下一批")
        leftTime = leftTime - 1
    end), cc.DelayTime:create(1))))

    local hero_list = cp.getUserData("UserNpc"):getSortedNpcList()
    for index, hero_info in ipairs(hero_list) do
        local npcConfig = cp.getManager("ConfigManager").getItemByKey("GameNpc", hero_info.ID)
        local modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", npcConfig:getValue("ModelID"))
        local img = self.ScrollView_Heros:getChildByName("Image_Model"..index)
        if not img then return end
        local imgIcon = img:getChildByName("Image_Icon")
        local txtName = img:getChildByName("Text_Name")
        local txtFight = img:getChildByName("Text_Fight")
        local imgFlag = img:getChildByName("Image_Flag")
        imgIcon:loadTexture(cp.DataUtils.getModelFace(modelConfig:getValue("Face")))
        txtName:setString(npcConfig:getValue("Name"))
        local _,color,_ = cp.getManager("GDataManager"):getHeroInfoByID(hero_info.ID)
        cp.getManager("ViewManager").setTextQuality(txtName, color + 2)
        txtFight:setString("戰力 "..npcConfig:getValue("Fight"))

        imgFlag:setVisible(true)
        if hero_info.state == 0 then
            imgFlag:setVisible(false)
        elseif hero_info.state == 2 then
            imgFlag:loadTexture("ui_mapbuild_module33_jianghuhaoxia_yijiejiao.png", ccui.TextureResType.plistType)
        else
            imgFlag:loadTexture("ui_mapbuild_module33_jianghuhaoxia_yijibai.png", ccui.TextureResType.plistType)
        end

        cp.getManager("ViewManager").initButton(imgIcon, function()
            if hero_info.state ~= 0 then
                return
            end
            local type,id,level = cp.getConst("CombatConst").CombatType_Shane,hero_info.ID,0  
            local function closeCallBack(retStr)
                if retStr == "Shane_TiaoZhan" then
                    local fightInfo = {name = npcConfig:getValue("Name")} 
                    cp.getUserData("UserCombat"):resetFightInfo()
                    cp.getUserData("UserCombat"):updateFightInfo(fightInfo)
                    local req = {}
                    req.uuid = hero_info.uuid
                    self:doSendSocket(cp.getConst("ProtoConst").StartFightHeroReq, req)
                elseif retStr == "JieJiao" then
                    local req = {}
                    req.uuid = hero_info.uuid
                    self:doSendSocket(cp.getConst("ProtoConst").BribeHeroReq, req)
                elseif retStr == "CallHelp" then
                    local req = {}
                    req.uuid = hero_info.uuid
                    self:doSendSocket(cp.getConst("ProtoConst").InviteHeroReq, req)
                elseif retStr == "close" then

                    cp.getManager("ViewManager").removeChallengeStory()
                end
                
            end
            cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack)
        end, 1.0)
    end
end

function RiverHeroListLayer:updateAwardList()
    local award = cp.getUserData("UserNpc"):getValue("award")
    for i=1, 4 do
        local state = award[i] or 0
        local nodeReward = self.Image_Progress:getChildByName("Node_Reward"..i)
        local btnReward = nodeReward:getChildByName("Button_Reward")
        local imgBg = nodeReward:getChildByName("Image_bg")
        local imgSuccess = self.Image_Progress:getChildByName("Image_Success"..i)
        local loadingbar = self.Image_Progress:getChildByName("LoadingBar_"..i)
        local imgBox = self["Image_Kill"..i]
        if state ~= 0 then
            loadingbar:setVisible(true)
            imgSuccess:setVisible(true)
            imgBox:loadTexture("ui_mapbuild_module33_jianghuhaoxia_jindutiao06.png", ccui.TextureResType.plistType)
        else
            loadingbar:setVisible(false)
            imgSuccess:setVisible(false)
            imgBox:loadTexture("ui_mapbuild_module33_jianghuhaoxia_jindutiao05.png", ccui.TextureResType.plistType)
        end

        btnReward:stopAllActions()
        btnReward:setScale(1)
        imgBg:setVisible(false)
        if state == 2 then
            btnReward:setEnabled(false)
        elseif state == 0 then
            btnReward:setEnabled(true)
            cp.getManager("ViewManager").initButton(btnReward, function()
                local rewardItem = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("HeroAccu", i-1):getValue("Award"), "|-")
                local rewardPreviewLayer = require("cp.view.scene.activity.ActivityRewardPreviewLayer"):create(0, rewardItem)
                self:addChild(rewardPreviewLayer, 100)
            end, 1.0)
        else
            imgBg:setVisible(true)
            imgBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 30)))
            btnReward:setEnabled(true)
            btnReward:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 0.7), cc.ScaleTo:create(0.1, 1, 1), cc.DelayTime:create(1))))
            cp.getManager("ViewManager").initButton(btnReward, function()
                local req = {}
                req.pos = i - 1
                self:doSendSocket(cp.getConst("ProtoConst").GetAccuAwardReq, req)
            end, 1.0)
        end
    end
end

function RiverHeroListLayer:onEnterScene()
    self:updateRiverHeroListView()
    self:updateAwardList()
end

function RiverHeroListLayer:onExitScene()
    self:unscheduleUpdate()
end

return RiverHeroListLayer