local BLayer = require "cp.view.ui.base.BLayer"
local MajorLayer = class("MajorLayer",BLayer)
--local socket = require "socket"
function MajorLayer:create()
    local layer = MajorLayer.new()
    return layer
end

function MajorLayer:initListEvent()
    self.listListeners = {
        --[[
        ["GetRankListRsp"] = function(data)
            local layer = require("cp.view.scene.rank.RankMainLayer"):create(data)
            self:addChild(layer, 100)
        end,
        ]]
        [cp.getConst("EventConst").ReconnectLoginOK] = function(data)
        end,

        [cp.getConst("EventConst").GetSelfVanRsp] = function(data)
            --網路正常
			local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
            self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
        end,

        [cp.getConst("EventConst").FeatureRsp] = function(data)
			self:refreshFeature()
        end,

        --請求章節訊息列表返回
        -- [cp.getConst("EventConst").GetStoryInfoRsp] = function(data)
        --      self:checkNeedNoticeChallenge()
        -- end,

        --新手指引點擊目標點
        [cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "MajorLayer" then
                if evt.guide_name == "lottery" then
                    self:onBuildClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "MajorLayer" then
                if evt.guide_name == "lottery" then

                    local boundbingBox = self[evt.target_name]:getBoundingBox()
                    local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    pos.x = pos.x + 30
                    --此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info

                end
            end
        end,

        --打開新手指引
        [cp.getConst("EventConst").open_playerguider_view] = function(evt)
            self:onNewGuideStory()
        end,

        --被伏擊通知
        [cp.getConst("EventConst").BeRobVanRsp] = function(evt)
            self:refreshBeRobbedNotice()
            
        end,

        [cp.getConst("EventConst").UpdateHangConductRsp] = function(proto)
            self:refreshBeRobbedNotice()
		end,

        --查看被伏擊錄像
        [cp.getConst("EventConst").GetCombatDataRsp] = function(evt)

            cp.getUserData("UserCombat"):setValue("review_combatID",0)
            local review_type = cp.getUserData("UserCombat"):getValue("review_type")
            if review_type == 1 then
                cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
            end
            cp.getUserData("UserCombat"):setValue("review_type",0)
            
        end,
        
        --請求神祕商店狀態返回
        [cp.getConst("EventConst").StoreOpenRsp] = function(evt)
            self:checkShowShopButton()
        end,
        
        [cp.getConst("EventConst").GetSignInfoRsp] = function(data)
            self:checkNeedNoticeActivity()
		end,
		[cp.getConst("EventConst").SignRsp] = function(data)
            self:checkNeedNoticeActivity()
		end,
		[cp.getConst("EventConst").GetUpgradeGiftRsp] = function(data)
			cp.getUserData("UserRole"):setValue("upgradeGift", data.upgradeGift) 
            self:checkNeedNoticeActivity()
		end,
		[cp.getConst("EventConst").GetFightGiftRsp] = function(data)
			cp.getUserData("UserRole"):setValue("fightGift", data.fightGift) 
            self:checkNeedNoticeActivity()
		end,
		[cp.getConst("EventConst").GetPhysicalRsp] = function(data)
			cp.getUserData("UserRole"):setValue("physicalGift", data.physicalGift) 
            self:checkNeedNoticeActivity()
		end,
        

        [cp.getConst("EventConst").GetLotteryDataRsp] = function(evt)
            self:checkNeedNoticeLottery()
        end,
        [cp.getConst("EventConst").BuyTreasureLotteryRsp] = function(evt)
            self:checkNeedNoticeLottery()
        end,
        [cp.getConst("EventConst").BuySkillLotteryRsp] = function(evt)
            self:checkNeedNoticeLottery()
        end,
        [cp.getConst("EventConst").WantFightRsp] = function(evt)
            self:checkNeedNoticeGuessFinger()
        end,
        [cp.getConst("EventConst").ResetDiceStateRsp] = function(evt)
            self:checkNeedNoticeRollDice()
        end,
        [cp.getConst("EventConst").GetMonthRewardRsp] = function(evt)
            self:checkNeedNoticeRollDice()
        end,
        [cp.getConst("EventConst").BuyChallengeRsp] = function(evt)
            self:checkNeedNoticeArena()
        end,
        [cp.getConst("EventConst").ArenaFightRsp] = function(evt)
            self:checkNeedNoticeArena()
        end,
        ["checkNeedNoticeGuild"] = function(evt)
            self:checkNeedNoticeGuild()
        end,
        ["LearnMetalRsp"] = function(evt)
            self:checkNeedNoticePrimeval()
        end,
        ["EquipMetaRsp"] = function(evt)
            self:checkNeedNoticePrimeval()
        end,

        [cp.getConst("EventConst").StoreTimeOut] = function(evt)
            if self.rootView:getChildByName("Button_shop") ~= nil then
                self.rootView:removeChildByName("Button_shop")
            end
        end,
        

        --打開日常任務
        [cp.getConst("EventConst").open_daily_task] = function(flag)
            if not self.DailyTaskMainUI and flag then
                local DailyTaskMainUI = require("cp.view.scene.world.dailytask.DailyTaskMainUI"):create()
                self.DailyTaskMainUI = DailyTaskMainUI
                self.rootView:addChild(DailyTaskMainUI, 2)
            end

            if self.DailyTaskMainUI and not flag then
                self.DailyTaskMainUI:removeFromParent()
                self.DailyTaskMainUI = nil
            end 

            if flag then
                self.DailyTaskMainUI:setVisible(true)
            end
        end,

        --打開更換頭像界面
        [cp.getConst("EventConst").open_face_change_view] = function(flag)
            if not self.PlayerHeadChangeUI and flag then
                local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
                local openInfo = {type = "major",face = majorRole.face, gender = majorRole.gender}
                local PlayerHeadChangeUI = require("cp.view.ui.messagebox.PlayerHeadChangeUI"):create(openInfo)
                PlayerHeadChangeUI:setCloseCallBack(function (faceID)
                    if majorRole.face ~= faceID then
                        --發送協議更換頭像
                        local req = {face = faceID}
                        self:doSendSocket(cp.getConst("ProtoConst").ChangeFaceReq, req)
                    end
                end)
                self.PlayerHeadChangeUI = PlayerHeadChangeUI
                self.rootView:addChild(PlayerHeadChangeUI, 2)
            end

            if self.PlayerHeadChangeUI and not flag then
                self.PlayerHeadChangeUI:removeFromParent()
                self.PlayerHeadChangeUI = nil
            end

            if flag then
                self.PlayerHeadChangeUI:setVisible(true)
            end

        end,

        --聊天訊息接收,顯示提示
        [cp.getConst("EventConst").ChatChannelRsp] = function(data)
			self:checkNeedNoticeChatMsg()
        end,
        
        [cp.getConst("EventConst").ChatLayerClose] = function(data)
            self:checkNeedNoticeChatMsg()
        end,

        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:checkNeedNotice()
        end,

        [cp.getConst("EventConst").AchieveRsp] = function(evt)
            self:checkNewAchivement()
            self:checkNeedNoticeAchivement()
        end,

        [cp.getConst("EventConst").OnNewGuideDouCheng] = function(evt)
            if evt.idx == 0 then
                local apple_test_version = cp.getManualConfig("Net").apple_test_version
                if apple_test_version == true then
                    cp.getManager("GDataManager"):finishNewGuideName("doucheng")
                else
                    self:showCity()
                end
            end
        end,

        [cp.getConst("EventConst").open_xiakexing_view] = function(flag)
            if not self.XiakexingMainLayer and flag then
                local XiakexingMainLayer = require("cp.view.scene.world.xiakexing.XiakexingMainLayer"):create()
                XiakexingMainLayer:setCloseCallBack(function()
                    
                end)
                self.rootView:addChild(XiakexingMainLayer, 2)
                self.XiakexingMainLayer = XiakexingMainLayer
            end

            if self.XiakexingMainLayer and not flag then
                self.XiakexingMainLayer:removeFromParent()
                self.XiakexingMainLayer = nil
            end 

            if flag then
                self.XiakexingMainLayer:setVisible(true)
            end

        end,

        [cp.getConst("EventConst").open_xiakexing_heroselect_view] = function(info)
            
            if not self.XiakexingHeroSelectLayer and info.openState == "open" then
                local XiakexingHeroSelectLayer = require("cp.view.scene.world.xiakexing.XiakexingHeroSelectLayer"):create(info) 
                XiakexingHeroSelectLayer:setCloseCallBack(function(btnName,closeInfo)
                    --打開npc詳情
                    if btnName == "Image_head" then
                        self:openXiakexingFightLayer(closeInfo)
                    end
                end)
                self.rootView:addChild(XiakexingHeroSelectLayer,2)
                self.XiakexingHeroSelectLayer = XiakexingHeroSelectLayer
            end

            if self.XiakexingHeroSelectLayer and info.openState == "close" then
                self.XiakexingHeroSelectLayer:removeFromParent()
                self.XiakexingHeroSelectLayer = nil
            end 

            if info.openState == "open" then
                self.XiakexingHeroSelectLayer:setVisible(true)
            end

        end,
        
    }
end

function MajorLayer:onInitView(openInfo)
    --self.beginTime = socket.gettime()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major.csb")
    self:addChild(self.rootView)
    --log(string.format("MajorPackage:initView 00 totaltime = %.6f",socket.gettime() - self.beginTime))
    local childConfig = {
        ["Button_Guide"] = {name = "Button_Guide",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg"] = {name = "ScrollView_bg"},
        ["ScrollView_bg.Panel_all"] = {name = "Panel_all"},
        ["ScrollView_bg.Panel_all.Image_major"] = {name = "Image_major"},
        ["ScrollView_bg.Panel_all.Button_changbaoge"] = {name = "Button_changbaoge",click = "onBuildClick",clickScale = 1},
        -- ["ScrollView_bg.Panel_all.Button_mijing"] = {name = "Button_mijing",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_YiXiangYuan"] = {name = "Button_YiXiangYuan",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_RiChang"] = {name = "Button_RiChang",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_chucheng"] = {name = "Button_chucheng", click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_bangpai"] = {name = "Button_bangpai",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_ZuiXianLou"] = {name = "Button_ZuiXianLou",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_ChangLeFang"] = {name = "Button_ChangLeFang",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_ShangCheng"] = {name = "Button_ShangCheng",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_BiWuChang"] = {name = "Button_BiWuChang",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_XiaKeXing"] = {name = "Button_XiaKeXing",click = "onBuildClick",clickScale = 1},
        ["ScrollView_bg.Panel_all.Button_ChengJiu"] = {name = "Button_ChengJiu",click = "onBuildClick",clickScale = 1},
        
        ["ScrollView_bg.Panel_all.Panel_qi_zxl"] = {name = "Panel_qi_zxl"},
        ["ScrollView_bg.Panel_all.Panel_liangyi"] = {name = "Panel_liangyi"},
        ["ScrollView_bg.Panel_all.Panel_denglong1"] = {name = "Panel_denglong1"},
        ["ScrollView_bg.Panel_all.Panel_denglong2"] = {name = "Panel_denglong2"},
        ["ScrollView_bg.Panel_all.Panel_denglong3"] = {name = "Panel_denglong3"},
        ["ScrollView_bg.Panel_all.Panel_denglong4"] = {name = "Panel_denglong4"},
        ["ScrollView_bg.Panel_all.Panel_denglong5"] = {name = "Panel_denglong5"},
        ["ScrollView_bg.Panel_all.Panel_qi_lt"] = {name = "Panel_qi_lt"},
        ["ScrollView_bg.Panel_all.Panel_denglong_yxy1"] = {name = "Panel_denglong_yxy1"},
        ["ScrollView_bg.Panel_all.Panel_denglong_yxy2"] = {name = "Panel_denglong_yxy2"},
        ["ScrollView_bg.Panel_all.Panel_denglong_yxy3"] = {name = "Panel_denglong_yxy3"},
        ["ScrollView_bg.Panel_all.Panel_denglong_yxy4"] = {name = "Panel_denglong_yxy4"},
        ["ScrollView_bg.Panel_all.Panel_denglong_yxy5"] = {name = "Panel_denglong_yxy5"},
        ["ScrollView_bg.Panel_all.Panel_denglong_clf"] = {name = "Panel_denglong_clf"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg1"] = {name = "Panel_denglong_qg1"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg2"] = {name = "Panel_denglong_qg2"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg3"] = {name = "Panel_denglong_qg3"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg4"] = {name = "Panel_denglong_qg4"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg5"] = {name = "Panel_denglong_qg5"},
        ["ScrollView_bg.Panel_all.Panel_denglong_qg6"] = {name = "Panel_denglong_qg6"},
        ["ScrollView_bg.Panel_all.Panel_yizhanqizi"] = {name = "Panel_yizhanqizi"},
        
        ["ScrollView_bg.Panel_all.Image_cloud1"] = {name = "Image_cloud1"},
        ["ScrollView_bg.Panel_all.Image_cloud3"] = {name = "Image_cloud3"},

        ["ScrollView_bg.Panel_all.Panel_npc15_1"] = {name="Panel_npc15_1"},
        ["ScrollView_bg.Panel_all.Panel_npc15_2"] = {name="Panel_npc15_2"},
        ["ScrollView_bg.Panel_all.Panel_npc1_1"] = {name="Panel_npc1_1"},
        ["ScrollView_bg.Panel_all.Panel_npc2_1"] = {name="Panel_npc2_1"},
        ["ScrollView_bg.Panel_all.Panel_npc10_1"] = {name="Panel_npc10_1"},
        ["ScrollView_bg.Panel_all.Panel_npc19_1"] = {name="Panel_npc19_1"},
        ["ScrollView_bg.Panel_all.Panel_npc17_1"] = {name="Panel_npc17_1"},
        
        ["ScrollView_bg.Panel_all.Panel_npc1"] = {name="Panel_npc1"},
        ["ScrollView_bg.Panel_all.Panel_npc2"] = {name="Panel_npc2"},
        ["ScrollView_bg.Panel_all.Panel_npc3"] = {name="Panel_npc3"},
        ["ScrollView_bg.Panel_all.Panel_npc4"] = {name="Panel_npc4"},
        ["ScrollView_bg.Panel_all.Panel_npc5"] = {name="Panel_npc5"},
        ["ScrollView_bg.Panel_all.Panel_npc6"] = {name="Panel_npc6"},
        ["ScrollView_bg.Panel_all.Panel_npc7"] = {name="Panel_npc7"},
        ["ScrollView_bg.Panel_all.Panel_npc8"] = {name="Panel_npc8"},
        ["ScrollView_bg.Panel_all.Panel_npc9"] = {name="Panel_npc9"},
        ["ScrollView_bg.Panel_all.Panel_npc10"] = {name="Panel_npc10"},
        ["ScrollView_bg.Panel_all.Panel_npc11"] = {name="Panel_npc11"},
        ["ScrollView_bg.Panel_all.Panel_npc12"] = {name="Panel_npc12"},
        ["ScrollView_bg.Panel_all.Panel_npc13"] = {name="Panel_npc13"},
        ["ScrollView_bg.Panel_all.Panel_npc14"] = {name="Panel_npc14"},
        ["ScrollView_bg.Panel_all.Panel_npc15"] = {name="Panel_npc15"},
        ["ScrollView_bg.Panel_all.Panel_npc16"] = {name="Panel_npc16"},
        ["ScrollView_bg.Panel_all.Panel_npc17"] = {name="Panel_npc17"},
        ["ScrollView_bg.Panel_all.Panel_npc18"] = {name="Panel_npc18"},
        ["ScrollView_bg.Panel_all.Panel_npc19"] = {name="Panel_npc19"},
        ["ScrollView_bg.Panel_all.Panel_npc20"] = {name="Panel_npc20"},

        ["ScrollView_bg.Panel_all.Image_lock_5"] = {name="Image_lock_5"},
        ["ScrollView_bg.Panel_all.Image_lock_6"] = {name="Image_lock_6"},
        ["ScrollView_bg.Panel_all.Image_lock_7"] = {name="Image_lock_7"},
        ["ScrollView_bg.Panel_all.Image_lock_8"] = {name="Image_lock_8"},
        ["ScrollView_bg.Panel_all.Image_lock_9"] = {name="Image_lock_9"},
        ["ScrollView_bg.Panel_all.Image_lock_10"] = {name="Image_lock_10"},
        ["ScrollView_bg.Panel_all.Image_lock_11"] = {name="Image_lock_11"},
        ["ScrollView_bg.Panel_all.Image_lock_12"] = {name="Image_lock_12"},
    }
    
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    --log(string.format("MajorPackage:initView 10 totaltime = %.6f",socket.gettime() - self.beginTime))
    self.rootView:setContentSize(display.size)
    self.Image_major:loadTexture("img/bg/bg_main/main_bj.png",ccui.TextureResType.localType)
    local scale = display.height / 1280
    self["Panel_all"]:setScale(scale,scale)
    local newWidth = self.Panel_all:getContentSize().width * scale
    self["ScrollView_bg"]:setInnerContainerSize(cc.size(newWidth,display.height))
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    if cp.getManualConfig("Channel").channel == "lunplay" then
        self.Button_RiChang:setEnabled(false)
    end
    --left
    local MajorLeft = require "cp.view.scene.world.major.MajorLeft"
    self.majorLeft = MajorLeft:create()
    self.rootView:addChild(self.majorLeft,1)

    --log(string.format("MajorPackage:initView 22 totaltime = %.6f",socket.gettime() - self.beginTime))
    
    --top
    local MajorTop = require "cp.view.scene.world.major.MajorTop"
    self.majorTop = MajorTop:create()
    self.rootView:addChild(self.majorTop)

    self:addActivityButton()

    ccui.Helper:doLayout(self["rootView"])

    --log(string.format("MajorPackage:initView 33 totaltime = %.6f",socket.gettime() - self.beginTime))
    
    self["Button_changbaoge"]:setAlphaTouchEnable(true)
    -- self["Button_mijing"]:setAlphaTouchEnable(true)
    self["Button_YiXiangYuan"]:setAlphaTouchEnable(true)
    self["Button_RiChang"]:setAlphaTouchEnable(true)
    self["Button_chucheng"]:setAlphaTouchEnable(true)
    self["Button_bangpai"]:setAlphaTouchEnable(true)
    self["Button_ZuiXianLou"]:setAlphaTouchEnable(true)
    self["Button_ChangLeFang"]:setAlphaTouchEnable(true)
    self["Button_ShangCheng"]:setAlphaTouchEnable(true)
    self["Button_BiWuChang"]:setAlphaTouchEnable(true)
    self["Button_XiaKeXing"]:setAlphaTouchEnable(true)
    self["Button_ChengJiu"]:setAlphaTouchEnable(true)

    local apple_test_version = cp.getManualConfig("Net").apple_test_version
    if apple_test_version == true then
        local pic = "ui_major_build_module04_main_ll_03.png"
        self["Button_XiaKeXing"]:loadTextures(pic,pic,pic,ccui.TextureResType.plistType)
        self["Button_XiaKeXing"]:setTouchEnabled(false)
        self["Image_lock_12"]:setVisible(false)

        pic = "ui_major_build_module04_main_fyb_03.png"
        self["Button_RiChang"]:loadTextures(pic,pic,pic,ccui.TextureResType.plistType)
        self["Button_RiChang"]:setTouchEnabled(false)
        self["Image_lock_6"]:setVisible(false)
    end

    self.Button_chat = cp.getManager("ViewManager").addChatMsgNotice(self.rootView,cc.p(670,174),0)
    --log(string.format("MajorPackage:initView 44 totaltime = %.6f",socket.gettime() - self.beginTime))
   
    -- local function initButton(button,callFunc,scale,playBtnEffect)
        
    --     if button.clicked then return end

    --     local function onTouch(sender, event)
    --         if event == cc.EventCode.BEGAN then
    --             button.clickInRect = false
    --             local posX,posY = button:getPosition()
    --             local touchRect = cc.rect(posX-180,posY-65,235,160)
    --             local touchPos = sender:getTouchBeganPosition()
    --             if cc.rectContainsPoint(touchRect,touchPos) then
    --                 button.clicked = true
    --                 sender:loadTexture("ui_major_build_module04_main_cq_a_02.png", ccui.TextureResType.plistType)
    --                 button.clickInRect = true
    --             else
    --                 sender:loadTexture("ui_major_build_module04_main_cq_a.png", ccui.TextureResType.plistType)
    --             end
    --         elseif event == cc.EventCode.MOVED then 
     
    --         elseif event == cc.EventCode.ENDED then
    --             if button.clickInRect then
    --                 callFunc(sender)
    --                 cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
    --             end
    --             button.clicked = false
    --             sender:loadTexture("ui_major_build_module04_main_cq_a.png", ccui.TextureResType.plistType)
    --         elseif event == cc.EventCode.CANCELLED then
    --             button.clicked = false
    --             sender:loadTexture("ui_major_build_module04_main_cq_a.png", ccui.TextureResType.plistType)
    --         end
    --     end
    --     if button.addTouchEventListener ~= nil then
    --         button:addTouchEventListener(onTouch)
    --         button:setTouchEnabled(true)
    --     end
    -- end
    -- initButton(self.Image_chucheng,handler(self,self.onBuildClick))
    
	if cp.getManualConfig("Channel").channel == "lunplay" then
		self.Button_Guide:setVisible(false)
	end
end

function MajorLayer:onEnterScene()
    --log(string.format("MajorPackage:onEnterScene 11 totaltime = %.6f",socket.gettime() - self.beginTime))

    cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_main,true)
    local isOnLine = cp.getUserData("UserRole"):getValue("isOnLine")
    log("MajorLayer:onEnterScene() isOnLine=" .. tostring(isOnLine))
    if isOnLine == false then
        cp.getUserData("UserRole"):setValue("isOnLine",true)
		
        local channelName = cp.getManualConfig("Channel").channel
        log("MajorLayer:onEnterScene() channelName=" .. tostring(channelName))
        if channelName == "lunplay" then
            local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
            local server = lastServerInfo.name
            local server_id =  "nzljh" .. tostring(lastServerInfo.id)
            local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            -- local passport = cp.getUserData("UserLogin"):getValue("user_token")
            local platform = device.platform
            if LunPlay and platform == "ios" then
                LunPlay:baoCunServer(server_id,major_roleAtt.id,major_roleAtt.level)
            end
            if platform == "android" then
                local params = {roleId = tostring(major_roleAtt.id),roleName=major_roleAtt.name,roleLevel=tostring(major_roleAtt.level), serverCode = tostring(server_id)}
                cp.getManager("ChannelManager"):onExtraFunction("roleLogin",params,nil)

                --開啟懸浮窗
                cp.getManager("ChannelManager"):onExtraFunction("startFloat",{},nil)
            end
        end
		
        --請求神祕商店開啟狀態
        self:doSendSocket(cp.getConst("ProtoConst").StoreOpenReq, {})

        --請求門派修煉訊息返回
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GangPracticeInfoReq, req)

    else
        self:checkShowShopButton()
    end
   
    
    self:onNewGuideStory()
    self:refreshBeRobbedNotice()
    self:checkNeedNotice()
    
    self:onMotionObject()
    self:cloudMove()

    --顯示離線歷練結果
    self:showOffLineExerciseresult()

    self:refreshFeature()

    local need_notice = cp.getUserData("UserAchivement"):getValue("need_notice")
    local has_achive_data = cp.getUserData("UserAchivement"):getValue("has_achive_data")
    if need_notice and has_achive_data then
        self:checkNewAchivement()
    end

    local req = {idx=-1}
    self:dispatchViewEvent( cp.getConst("EventConst").OnNewGuideDouCheng,req)
    --[[
    local req = {}
    req.attacker = 100003
    req.defencer = 100004
    req.scene = 5
    self:doSendSocket(cp.getConst("ProtoConst").FirstEnterGameReq, req)
    ]]

end


function MajorLayer:showCity()

	if self.cityPoint == nil then 
		self.cityPoint = { 
			--藏寶閣
            {node = self.Button_changbaoge,  moveTime = 0.01, percent = 0 / 2160,index=51},
			--日常
            {node = self.Button_RiChang,  moveTime = 1, percent = 343 / 2160,index=52},
			--幫派
            {node = self.Button_bangpai,  moveTime = 1, percent = 736 / 2160,index=53},
			--醉仙樓
            {node = self.Button_ZuiXianLou,  moveTime = 1, percent = 1089 / 2160,index=54},
			--比武場
            {node = self.Button_BiWuChang,  moveTime = 1, percent = 1434 / 2160,index=55},
			--長樂坊
            {node = self.Button_ChangLeFang, moveTime = 1, percent = 1861 / 2160,index=56},
		}	
	end	
	
	--停止, 閃爍，介紹動畫, 移動 ...
	local sequence = {}
    for _, v in pairs(self.cityPoint) do
		if v.node ~= nil then
            table.insert(sequence, cc.CallFunc:create(function() self.ScrollView_bg:scrollToPercentHorizontal(v.percent * 100, v.moveTime, true) end))
            table.insert(sequence, cc.CallFunc:create(function() cp.getManager("GDataManager"):flash(v.node, 0.3, 8) end))
            table.insert(sequence, cc.DelayTime:create(1))
            table.insert(sequence, cc.CallFunc:create(function() 
                local req = {idx=v.index}
                self:dispatchViewEvent( cp.getConst("EventConst").OnNewGuideDouCheng,req)
            end))
            table.insert(sequence, cc.DelayTime:create(4))
            
		end
    end
    table.insert(sequence, cc.CallFunc:create(function() 
        local info =
        {
            classname = "MajorLayer",
        }
        self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
    end))

	self:runAction(cc.Sequence:create(sequence))

end


function MajorLayer:refreshFeature()
    local major_feature = cp.getUserData("UserRole"):getValue("major_feature")
    if major_feature and next(major_feature) then
        for _, v in pairs(major_feature) do
            if v.type == 5 then
                cp.getManager("GDataManager"):setFeature(self.Button_chucheng, self.Image_lock_5, v)
            elseif v.type == 6 then
                cp.getManager("GDataManager"):setFeature(self.Button_RiChang, self.Image_lock_6, v)
                local apple_test_version = cp.getManualConfig("Net").apple_test_version
                if apple_test_version == true then
                    self["Image_lock_6"]:setVisible(false)
                end
            elseif v.type == 7 then
                cp.getManager("GDataManager"):setFeature(self.Button_ZuiXianLou, self.Image_lock_7, v)
            elseif v.type == 8 then
                cp.getManager("GDataManager"):setFeature(self.Button_BiWuChang, self.Image_lock_8, v)
            elseif v.type == 9 then
                cp.getManager("GDataManager"):setFeature(self.Button_ChangLeFang, self.Image_lock_9, v)
            elseif v.type == 10 then
                cp.getManager("GDataManager"):setFeature(self.Button_bangpai, self.Image_lock_10, v)
            elseif v.type == 11 then
                cp.getManager("GDataManager"):setFeature(self.Button_YiXiangYuan, self.Image_lock_11, v)
            elseif v.type == 12 then
                cp.getManager("GDataManager"):setFeature(self.Button_XiaKeXing, self.Image_lock_12, v)
                
                local apple_test_version = cp.getManualConfig("Net").apple_test_version
                if apple_test_version == true then
                    self["Image_lock_12"]:setVisible(false)
                end
            end
        end
    end
end

function MajorLayer:showOffLineExerciseresult()
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
    local exerCompress = cp.getUserData("UserLilian"):getValue("offline_result_list")
    if exerCompress == nil or next(exerCompress) == nil then
        return
    end 
    local itemTotalNum = 0
    if next(exerCompress.itemNum) then
        for i=1,table.nums(exerCompress.itemNum) do
            itemTotalNum = itemTotalNum + exerCompress.itemNum[i]
        end
    end
    if not (exerCompress.trainPoint > 0 or exerCompress.silver > 0 or exerCompress.conductGood > 0 or exerCompress.conductBad >0 or itemTotalNum > 0) then
        return
    end
    
    --顯示離線歷練結果
    local name = ""
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseId = major_roleAtt.exerciseId
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
    if cfg ~= nil then
        name = cfg:getValue("Name") or "此"
    end
    local GameConst = cp.getConst("GameConst")
    local contentTable = {
        {type="ttf", fontSize=24, text="在離線期間，你在", textColor=GameConst.ContentTextColor, outLineEnable=false},
        {type="ttf", fontSize=24, text=name, textColor=GameConst.QualityTextColor[2], outLineColor=GameConst.QualityOutlineColor[2], outLineSize=2},
        {type="ttf", fontSize=24, text="歷練，獲得以下獎勵", textColor=GameConst.ContentTextColor, outLineEnable=false},
    }

    local openInfo = {info = exerCompress, title = "離線歷練報告", content = contentTable}
    local LilianResultLayer = require("cp.view.scene.world.lilian.LilianResultLayer"):create(openInfo)
    self.rootView:addChild(LilianResultLayer,2)
    
    cp.getUserData("UserLilian"):setValue("offline_result_list",{})
end

function MajorLayer:refreshBeRobbedNotice()
    local attacked_warning_info_list = cp.getUserData("UserVan"):getValue("attacked_warning_info_list")
    if #attacked_warning_info_list > 0 then
        if self.rootView:getChildByName("Button_beRobbed") == nil then
            cp.getManager("ViewManager").addBeRobbedNotice(self.rootView, cc.p(670,264),handler(self,self.ShowExpressNoticeView))
        end
    else
        if self.rootView:getChildByName("Button_beRobbed") ~= nil then
            self.rootView:removeChildByName("Button_beRobbed")
        end
    end
end

function MajorLayer:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lottery" then
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        if cur_step == 3 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.3))
            table.insert(sequence,cc.CallFunc:create(
                function()
                    local info =
                    {
                        classname = "MajorLayer",
                    }
                    self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                end)
            )
            self:runAction(cc.Sequence:create(sequence))
        end
    end
end

function MajorLayer:onMotionObject()
    if self.motionObject == nil then
        self.motionObject = {
            { binaryPath = "spine/scene01/scene01.json", atlasPath = "spine/scene01/scene01.atlas", panelName = "Panel_qi_zxl", actionName = {"Stand"}},
            { binaryPath = "spine/scene02/scene02.json", atlasPath = "spine/scene02/scene02.atlas", panelName = "Panel_liangyi", actionName = {"Stand"}},
            { binaryPath = "spine/scene03/scene03.json", atlasPath = "spine/scene03/scene03.atlas", panelName = "Panel_denglong1", actionName = {"Stand1", "Stand2"}},
            { binaryPath = "spine/scene03/scene03.json", atlasPath = "spine/scene03/scene03.atlas", panelName = "Panel_denglong2", actionName = {"Stand1", "Stand2"}},
            { binaryPath = "spine/scene03/scene03.json", atlasPath = "spine/scene03/scene03.atlas", panelName = "Panel_denglong3", actionName = {"Stand1", "Stand2"}},
            { binaryPath = "spine/scene03/scene03.json", atlasPath = "spine/scene03/scene03.atlas", panelName = "Panel_denglong4", actionName = {"Stand1", "Stand2"}},
            { binaryPath = "spine/scene03/scene03.json", atlasPath = "spine/scene03/scene03.atlas", panelName = "Panel_denglong5", actionName = {"Stand1", "Stand2"}},
            { binaryPath = "spine/scene04/scene04.json", atlasPath = "spine/scene04/scene04.atlas", panelName = "Panel_qi_lt", actionName = {"animation"}},
            { binaryPath = "spine/scene08/scene08.json", atlasPath = "spine/scene08/scene08.atlas", panelName = "Panel_denglong_yxy1", actionName = {"Stand"}},
            { binaryPath = "spine/scene08/scene08.json", atlasPath = "spine/scene08/scene08.atlas", panelName = "Panel_denglong_yxy2", actionName = {"Stand"}},
            { binaryPath = "spine/scene08/scene08.json", atlasPath = "spine/scene08/scene08.atlas", panelName = "Panel_denglong_yxy3", actionName = {"Stand"}},
            { binaryPath = "spine/scene06/scene06.json", atlasPath = "spine/scene06/scene06.atlas", panelName = "Panel_denglong_yxy4", actionName = {"Stand"}},
            { binaryPath = "spine/scene06/scene06.json", atlasPath = "spine/scene06/scene06.atlas", panelName = "Panel_denglong_yxy5", actionName = {"Stand"}},
            { binaryPath = "spine/scene07/scene07.json", atlasPath = "spine/scene07/scene07.atlas", panelName = "Panel_denglong_clf", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg1", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg2", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg3", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg4", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg5", actionName = {"Stand"}},
            { binaryPath = "spine/scene05/scene05.json", atlasPath = "spine/scene05/scene05.atlas", panelName = "Panel_denglong_qg6", actionName = {"Stand"}},

            { binaryPath = "spine/yizhanqizi/yizhanqizi.json", atlasPath = "spine/yizhanqizi/yizhanqizi.atlas", panelName = "Panel_yizhanqizi", actionName = {"yizhanqizi"}},
            
            { binaryPath = "spine/doucheng/npc8/npc8.json", atlasPath = "spine/doucheng/npc8/npc8.atlas", panelName = "Panel_npc8", actionName = {"npc8"},scale=0.2},
            { binaryPath = "spine/doucheng/npc9/npc9.json", atlasPath = "spine/doucheng/npc9/npc9.atlas", panelName = "Panel_npc9", actionName = {"npc9"},scale=0.2},

            -- { binaryPath = "spine/doucheng/npc15/npc15.json", atlasPath = "spine/doucheng/npc15/npc15.atlas", panelName = "Panel_npc15_1", actionName = {"npc15"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc15/npc15.json", atlasPath = "spine/doucheng/npc15/npc15.atlas", panelName = "Panel_npc15_2", actionName = {"npc15"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc1/npc1.json", atlasPath = "spine/doucheng/npc1/npc1.atlas", panelName = "Panel_npc1_1", actionName = {"npc1"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc2/npc2.json", atlasPath = "spine/doucheng/npc2/npc2.atlas", panelName = "Panel_npc2_1", actionName = {"npc2"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc10/npc10.json", atlasPath = "spine/doucheng/npc10/npc10.atlas", panelName = "Panel_npc10_1", actionName = {"npc10"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc19/npc19.json", atlasPath = "spine/doucheng/npc19/npc19.atlas", panelName = "Panel_npc19_1", actionName = {"npc19"},scale=0.2},
            -- { binaryPath = "spine/doucheng/npc17/npc17.json", atlasPath = "spine/doucheng/npc17/npc17.atlas", panelName = "Panel_npc17_1", actionName = {"npc17"},scale=0.2},
        }

        -- for i=1,20 do
        --     local path = "spine/doucheng/npc" .. tostring(i) .. "/npc" .. tostring(i)
        --     local tb = { binaryPath = path .. ".json", atlasPath = path .. ".atlas", panelName = "Panel_npc" .. tostring(i), actionName = {"npc" .. tostring(i)},scale=0.2}
        --     self.motionObject[#self.motionObject + 1] = tb
        -- end
    end

    for _, v in pairs(self.motionObject) do
        if self[v.panelName]:getChildByName(v.panelName .. "_node") == nil then
            model = sp.SkeletonAnimation:create(v.binaryPath, v.atlasPath)
            for i1, v1 in pairs(v.actionName) do
                if i1 == 1 then
                    if table.nums(v.actionName) > 1 then
                        model:setAnimation(0, v1, false)
                    else
                        model:setAnimation(0, v1, true)
                    end
                else
                    model:addAnimation(0, v1, true)
                end
            end
            model:update(0)
            model:setPosition(cc.p(model:getBoundingBox().width / 2, 0))
            model:setName(v.panelName .. "_node")
            self[v.panelName]:addChild(model)

            if v.scale ~= nil then
                model:setScale(v.scale)
                model:setPosition(cc.p(0,0))
            end
            
        end
    end
end

function MajorLayer:cloudMove()
    if self.cloudInfo == nil then
        self.cloudInfo = {
            {node = self["Image_cloud1"], startPos = cc.p(-308.72, 952), endPos = cc.p(2260, 952), moveTime = 42, waitTime = 1},
            {node = self["Image_cloud3"], startPos = cc.p(-308.72, 371), endPos = cc.p(2260, 371), moveTime = 45, waitTime = 40},
        }
    end

    for _, v in pairs(self.cloudInfo) do
        v.node:setPosition(v.startPos)
        local sequence = {}
        table.insert(sequence, cc.DelayTime:create(v.waitTime))
        table.insert(sequence, cc.MoveTo:create(v.moveTime, v.endPos))
        table.insert(sequence, cc.CallFunc:create( function() v.node:setPosition(v.startPos) end))
        v.node:runAction(cc.RepeatForever:create(cc.Sequence:create(sequence)))
    end

end

function MajorLayer:onBuildClick(sender)
    local buildName = sender:getName()
    log("click build : " .. buildName)

	if self:checkLock(buildName) == false then
		return
	end

    if "Button_changbaoge" == buildName then
        local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif "Button_BiWuChang" == buildName then
        self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, true)
    elseif "Button_ShangCheng" == buildName then
        self:openShangCheng()
    elseif "Button_RiChang" == buildName then
        local apple_test_version = cp.getManualConfig("Net").apple_test_version
        if apple_test_version == true then
            return
        end
        local layer = require("cp.view.scene.rank.RankMainLayer"):create(1)
        self:addChild(layer, 100)

    elseif "Button_chucheng" == buildName then
        --先請求數據，檢測是否斷線
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").GetSelfVanReq, req)
    elseif "Button_ZuiXianLou"  == buildName then
		self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, true)
    elseif "Button_ChangLeFang"  == buildName then
        self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, true)
    elseif "Button_bangpai" == buildName then
        self:dispatchViewEvent("GetPlayerGuildDataRsp", true)
    elseif "Button_XiaKeXing" == buildName then
        local apple_test_version = cp.getManualConfig("Net").apple_test_version
        if apple_test_version == true then
            return
        end
        self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_view, true)
    elseif "Button_YiXiangYuan" == buildName then
        self:dispatchViewEvent("GetPrimevalDataRsp", true)
    elseif "Button_Guide" == buildName then
        self:dispatchViewEvent("ActivityGuide", {flag=true})
    elseif "Button_ChengJiu" == buildName  then
        --打開成就界面
        -- self["Button_ChengJiu"]:setAlphaTouchEnable(true)
        self:dispatchViewEvent(cp.getConst("EventConst").open_achivement_view, true)
    end
end

function MajorLayer:checkLock(buildName)
	local state
    if "Button_BiWuChang" == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(8, self)
    elseif "Button_RiChang" == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(6, self)
    elseif "Button_chucheng" == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(5, self)
    elseif "Button_ZuiXianLou"  == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(7, self)
    elseif "Button_ChangLeFang"  == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(9, self)
    elseif "Button_bangpai"  == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(10, self)
    elseif "Button_YiXiangYuan"  == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(11, self)
    elseif "Button_XiaKeXing"  == buildName then
		state = cp.getManager("GDataManager"):procFeatureState(12, self)
	else
		return true
    end

	if state == -1 or state == 0 then
		return false
	end

	if state == 1 or state == 2 then
		return true
	end

	return true
end

function MajorLayer:openShangCheng()
    if self.ShopMainUI ~= nil then
        self.ShopMainUI:removeFromParent()
    end
    self.ShopMainUI = nil
    
    -- 雜貨鋪(storeID = 3 )
    local openInfo = {storeID = 3, closeCallBack = function()
        self.ShopMainUI:removeFromParent()
        self.ShopMainUI = nil
    end}
    local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
    self.rootView:addChild(ShopMainUI,2)
    self.ShopMainUI = ShopMainUI

end

function MajorLayer:checkShowShopButton()
    
    local needShow = false
    local closeStamp = cp.getUserData("UserShop"):getValue("MysticalStore_closeStamp") 
    if closeStamp > 0 then
        local curStamp = cp.getManager("TimerManager"):getTime()
        if closeStamp > curStamp then
            needShow = true
        end
    end

    if not needShow then
        if self.rootView:getChildByName("Button_shop") ~= nil then
            if self.shopEffect then
                self.shopEffect:removeFromParent()
                self.shopEffect = nil
            end
            self.rootView:removeChildByName("Button_shop")
        end
        return
    end

    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5,0.5)
    layout:setPosition(650,display.height-340)
    layout:setContentSize(100,100)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    -- layout:setBackGroundColor(cc.c4b(255,255,255,255))
    -- layout:setBackGroundColorOpacity(128)
    layout:setTouchEnabled(true)
    self.rootView:addChild(layout,0)
    layout:setName("Button_shop")
    cp.getManager("ViewManager").initButton(layout, function()
        cp.getManager("ViewManager").showMysticalStore() 
    end, 0.9)

    if self.shopEffect then
		self.shopEffect:removeFromParent()
		self.shopEffect = nil
	end
	local shopEffect = cp.getManager("ViewManager").createSpineEffect("shenmishangdian")
	shopEffect:setAnimation(0, "shenmishangdian", true)
    layout:addChild(shopEffect)
    shopEffect:setPosition(cc.p(110/2,0))
    self.shopEffect = shopEffect

end

function MajorLayer:addActivityButton()
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5,0.5)
    layout:setPosition(650,display.height-220)
    layout:setContentSize(100,100)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    -- layout:setBackGroundColor(cc.c4b(255,255,255,255))
    -- layout:setBackGroundColorOpacity(128)
    layout:setTouchEnabled(true)
    self.rootView:addChild(layout,0)


    local Button_Activity = ccui.Button:create("ui_major_left_module04_main_huodong_a.png","ui_major_left_module04_main_huodong_b.png","ui_major_left_module04_main_huodong_b.png",ccui.TextureResType.plistType)
    layout:addChild(Button_Activity,1)
    Button_Activity:setTouchEnabled(true)
    Button_Activity:setScale9Enabled(false)
    Button_Activity:setAnchorPoint(0.5,0.5)
    Button_Activity:setPosition(50,50)
    Button_Activity:setScale(1.2)
    Button_Activity:setName("Button_Activity")
    cp.getManager("ViewManager").initButton(Button_Activity, function()
        self:dispatchViewEvent(cp.getConst("EventConst").open_activity_view,true)
    end, 1)

    self.Button_Activity = Button_Activity
end

function MajorLayer:checkNeedNotice()
    self:checkNeedNoticeLottery()
    self:checkNeedNoticeGuessFinger()
    self:checkNeedNoticeRollDice()
    self:checkNeedNoticeArena()
    self:checkNeedNoticeGuild()
    self:checkNeedNoticeChatMsg()
    self:checkNeedNoticePrimeval()
    self:checkNeedNoticeActivity()
    self:checkNeedNoticeAchivement()
end

function MajorLayer:checkNeedNoticeLottery()
    if cp.getUtils("NotifyUtils").needNotifyLottery() then
        cp.getManager("ViewManager").addRedDot(self.Button_changbaoge,cc.p(453,515))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_changbaoge)
    end
end

function MajorLayer:checkNeedNoticeGuessFinger()
    if cp.getUtils("NotifyUtils").needNotifyGuessFinger() then
        cp.getManager("ViewManager").addRedDot(self.Button_ZuiXianLou,cc.p(345,325))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_ZuiXianLou)
    end
end

function MajorLayer:checkNeedNoticeRollDice()
    if cp.getUtils("NotifyUtils").needNotifyRollDice() then
        cp.getManager("ViewManager").addRedDot(self.Button_ChangLeFang,cc.p(395,315))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_ChangLeFang)
    end
end

function MajorLayer:checkNeedNoticeArena()
    if cp.getUtils("NotifyUtils").needNotifyArena() then
        cp.getManager("ViewManager").addRedDot(self.Button_BiWuChang,cc.p(442,342))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_BiWuChang)
    end
end

function MajorLayer:checkNeedNoticeGuild()
    if cp.getUtils("NotifyUtils").needNotifyGuild() then
        cp.getManager("ViewManager").addRedDot(self.Button_bangpai,cc.p(400,350))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_bangpai)
    end
end

function MajorLayer:checkNeedNoticePrimeval()
    if cp.getUtils("NotifyUtils").needNotifyPrimeval() then
        cp.getManager("ViewManager").addRedDot(self.Button_YiXiangYuan,cc.p(340,430))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_YiXiangYuan)
    end
end

function MajorLayer:checkNeedNoticeChatMsg()
    local total = cp.getUserData("UserChatData"):getNewMsgNum()
    self.Button_chat = cp.getManager("ViewManager").addChatMsgNotice(self.rootView,cc.p(670,174),total or 0)
end

function MajorLayer:checkNeedNoticeActivity()
    if cp.getUtils("NotifyUtils").needNotifyActivity() then
        cp.getManager("ViewManager").addRedDot(self.Button_Activity,cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Button_Activity)
    end
end


function MajorLayer:ShowExpressNoticeView()
    
    local ExpressLootNotice = require("cp.view.scene.world.express.ExpressLootNotice"):create()
    self.rootView:addChild(ExpressLootNotice,2)
    ExpressLootNotice:setCloseCallBack(handler(self,self.refreshBeRobbedNotice)) 
end

--打開俠客行挑戰界面
function MajorLayer:openXiakexingFightLayer(info)
    local type,id,level = cp.getConst("CombatConst").CombatType_HeroChallenge,info.ID,0
    local function closeCallBack(retStr)
        cp.getManager("ViewManager").removeChallengeStory()
    end
    cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack)
end

function MajorLayer:checkNewAchivement()
    local newNoticeIdx = 0
    local cfgItem = cp.getManager("ConfigManager").getItemByMatch("Achieve",{Type = 38})  -- 新手完成的id
    local special_idx = cfgItem:getValue("ID")  --新手指引終止idx

    local achive_config = cp.getUserData("UserAchivement"):getAchivementConfig()
	local achive_list = cp.getUserData("UserAchivement"):getValue("achive_list")
    achive_list = achive_list or {}
    
    if achive_list[special_idx] == nil or achive_list[special_idx] == 0 then-- 未完成新手指引
        local idx=0
        while(idx < special_idx) do
            idx = idx + 1
            if achive_list[idx] == nil or achive_list[idx] == 0 then
                newNoticeIdx = idx
                break
            end
        end
    else
        --已完成新手指引,按規則檢測下個可提示的成就
        local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local level = majorRole.level

        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "achive_notice_idx")
        local str = Config:getValue("StrValue") -- 11-17-48|20-17-73|29-17-98|38-17-158|47-17-163
        local beginIdx,endIndx = 0,0
        local arr1 = {}
        string.loopSplit(str,"|-",arr1)
        for i=1, table.nums(arr1) do
            local lv = tonumber(arr1[i][1])
            if level >= lv then
                beginIdx = tonumber(arr1[i][2])
                endIdx = tonumber(arr1[i][3])
            end
        end
      
        if beginIdx > 0 and endIdx > 0 then
            local idx = beginIdx 
            while(idx < endIdx) do
                if achive_list[idx] == nil or achive_list[idx] == 0 then
                    newNoticeIdx = idx
                    break
                end
                idx = idx + 1
            end
        end
        
    end

    if newNoticeIdx > 0 then --找到需要提示的idx
        for ID,info in pairs(achive_config) do
            if ID == newNoticeIdx then
                self:showAchiveNoticeUI(info)
                break
            end
        end
    else
        if self.AchivementEventNotice ~= nil then
            self.AchivementEventNotice:removeFromParent()
            self.AchivementEventNotice = nil
        end
    end

end

function MajorLayer:showAchiveNoticeUI(achive_config_info)
    if self.AchivementEventNotice == nil then
        self.AchivementEventNotice = require("cp.view.scene.world.achivement.AchivementEventNotice"):create()
        self["rootView"]:addChild(self.AchivementEventNotice,1)

        self.AchivementEventNotice:setCloseCallBack(function()
            self.AchivementEventNotice:removeFromParent()
            self.AchivementEventNotice = nil
        end)
    end
    self.AchivementEventNotice:initContent(achive_config_info)
    self.AchivementEventNotice:setVisible(true)
    self.AchivementEventNotice:setPosition(cc.p(display.cx,200))
end

function MajorLayer:checkNeedNoticeAchivement()
    if cp.getUtils("NotifyUtils").needNoticeAchivement() then
        cp.getManager("ViewManager").addRedDot(self.Button_ChengJiu,cc.p(250,342))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_ChengJiu)
    end
end

return MajorLayer
