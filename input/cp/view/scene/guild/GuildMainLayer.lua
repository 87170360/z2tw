local BLayer = require "cp.view.ui.base.BLayer"
local GuildMainLayer = class("GuildMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildMainLayer:create()
	local scene = GuildMainLayer.new()
    return scene
end

local buildingLevelName = {
	"初級", "中級", "高級"
}

function GuildMainLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetRoleSimpleRsp] = function(data)
			self:updateGuildMainView()
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
        [cp.getConst("EventConst").EnemyFightRsp] = function()
            cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		[cp.getConst("EventConst").UpdateCurrencyRsp] = function(data)
			self:updateGuildMainView()
		end,
		["UpgradeGuildRsp"] = function(data)
			self:updateGuildMainView()
		end,
		["JoinGuildNotifyRsp"] = function(data)
			self:updateGuildMemberView()
		end,
		["HandleJoinGuildRsp"] = function(data)
			self:updateGuildMainView()
		end,
        ["AppointGuildManagerRsp"] = function(data)
            if data.id == self.roleAtt.id and data.duty == -1 then
                cp.getManager("ViewManager").gameTip("您已被踢出幫派")
                self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
            else
                self:updateGuildMainView()
            end
		end,
        ["QuitGuildRsp"] = function(data)
            if data.id == self.roleAtt.id then
                cp.getManager("ViewManager").gameTip("您已退出幫派")
                self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
            else
                self:updateGuildMainView()
            end
		end,
		["GetGuildSalaryRsp"] = function(data)
			self:updateGuildInfoView()
		end,
		["NotifyMemberContributeRsp"] = function(data)
			self:updateGuildInfoView()
            self:updateGuildMemberView()
		end,
		["ContributeGuildRsp"] = function(data)
			self:updateGuildInfoView()
		end,
        ["GetGuildRankRsp"] = function(data)
            self:updateGuildRankView()
		end,
        ["ModifyGuildNoticeRsp"] = function(data)
            if not self.editing then
                self:updateNotice()
            end
		end,
        ["GuildActivitySweepRsp"] = function(data)
            self:updateSweepActivity()
		end,
        ["GuildBuildRsp"] = function(data)
            self:updateBuildActivity()
		end,
        ["GuildActivityExpelRsp"] = function(data)
            self:updateExpelActivity()
            if data.id == self.roleAtt.id then
                cp.getUserData("UserCombat"):setCombatReward({
                    currency_list = {
                        {
                            type = 11, num=data.money
                        },
                        {
                            type = 100, num=data.exp
                        },
                    }
                })
                cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
            end
		end,
        ["GuildPrepareFightRsp"] = function(data)
            self:updateFightActivity()
		end,
        ["GuildSignFightRsp"] = function(proto)
            self:updateFightActivity()
            if proto.id == self.roleAtt.id then
                local itemList = {
                    {
                        id = 1465,num = proto.contribute
                    },
                }
                cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得獎勵", true)
            end
		end,
        ["GuildFightOverRsp"] = function(data)
			self:updateGuildMainView()
		end,
        ["PlayerLoginNotifyRsp"] = function(data)
			self:updateGuildInfoView()
            self:updateGuildMemberView()
		end,
        ["PlayerLogoutNotifyRsp"] = function(data)
			self:updateGuildInfoView()
            self:updateGuildMemberView()
		end,
        ["GuildEventNotifyRsp"] = function(data)
			self:updateGuildEvent()
		end,
        ["updateFightActivity"] = function(data)
			self:updateFightActivity()
		end,
        ["UpdateMemberDailyRewardRsp"] = function(data)
			self:updateGuildMainView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function GuildMainLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_detail.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.editing = false

    local childConfig = {
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Info"] = {name = "Button_Info", click="onBtnClick"},
		["Panel_root.Image_1.Button_Member"] = {name = "Button_Member", click="onBtnClick"},
		["Panel_root.Image_1.Button_Activity"] = {name = "Button_Activity", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank"] = {name = "Button_Rank", click="onBtnClick"},
		["Panel_root.Image_1.PageView_Guild"] = {name = "PageView_Guild"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Name"] = {name = "Node_Name"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Owner"] = {name = "Node_Owner"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Deputy1"] = {name = "Node_Deputy1"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Deputy2"] = {name = "Node_Deputy2"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Member"] = {name = "Node_Member"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Money"] = {name = "Node_Money"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Level"] = {name = "Node_Level"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Node_Fight"] = {name = "Node_Fight"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Image_Notice"] = {name = "Image_Notice"},
		["Panel_root.Image_1.PageView_Guild.Panel_Info.Image_Personal"] = {name = "Image_Personal"},
        ["Panel_root.Image_1.PageView_Guild.Panel_Info.Image_Event"] = {name = "Image_Event"},
        ["Panel_root.Image_1.PageView_Guild.Panel_Info.Button_HideEvent"] = {name = "Button_HideEvent", click="onBtnClick"},
        
		["Panel_root.Image_1.PageView_Guild.Panel_Member.Image_MemberList"] = {name = "Image_MemberList"},
		["Panel_root.Image_1.PageView_Guild.Panel_Member.Image_MemberList.ListView_MemberList"] = {name = "ListView_MemberList"},
		["Panel_root.Image_1.PageView_Guild.Panel_Member.Button_Request"] = {name = "Button_Request", click="onBtnClick"},
        ["Panel_root.Image_1.PageView_Guild.Panel_Member.Button_Quit"] = {name = "Button_Quit", click="onBtnClick"},
        
        ["Panel_root.Image_1.PageView_Guild.Panel_Activity.ScrollView_ActivityList"] = {name = "ScrollView_ActivityList"},
        
		["Panel_root.Image_1.PageView_Guild.Panel_Rank.Image_RankList"] = {name = "Image_RankList"},
		["Panel_root.Image_1.PageView_Guild.Panel_Rank.Image_RankList.ListView_RankList"] = {name = "ListView_RankList"},
		["Panel_root.Image_1.PageView_Guild.Panel_Rank.Image_MyRank.Image_MyRank"] = {name = "Image_MyRank"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)

    self.ListView_RankList:setScrollBarEnabled(false)
    self.ListView_MemberList:setScrollBarEnabled(false)
    self.ScrollView_ActivityList:setScrollBarEnabled(false)

	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.Image_Notice:getChildByName("TextField_Notice"),"InputBox_Notice",nil)
    self.roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    
    local deltaY = display.height - 1280

    local size = self.PageView_Guild:getSize()
    size.height = size.height + deltaY
    self.PageView_Guild:setSize(size)
    self.PageView_Guild:setClippingEnabled(true)

    local size = self.Image_MemberList:getSize()
    size.height = size.height + deltaY
    self.Image_MemberList:setSize(size)

    local size = self.ListView_MemberList:getSize()
    size.height = size.height + deltaY
    self.ListView_MemberList:setSize(size)

    local size = self.ScrollView_ActivityList:getSize()
    size.height = size.height + deltaY
    self.ScrollView_ActivityList:setSize(size)

    local size = self.Image_RankList:getSize()
    size.height = size.height + deltaY
    self.Image_RankList:setSize(size)

    local size = self.ListView_RankList:getSize()
    size.height = size.height + deltaY
    self.ListView_RankList:setSize(size)

    ccui.Helper:doLayout(self.rootView)
    self.Button_Info:setEnabled(false)

    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local req = {}
    req.player_list = {}
    for _, memberInfo in ipairs(guildDetailData.member_list.member_list) do
        local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(memberInfo.id)
        if not playerSimpleInfo then
            table.insert(req.player_list, {
                id = memberInfo.id
            })
        end
    end

    if #req.player_list > 0 then
        self:doSendSocket(cp.getConst("ProtoConst").GetRoleSimpleReq, req)
    end
    
    self:doSendSocket(cp.getConst("ProtoConst").GetGuildRankReq, {})
    self:updateNotice()

    local txtCount = self.Image_Notice:getChildByName("Text_Count")
    local txtNotice = self.Image_Notice:getChildByName("TextField_Notice")
    local desc = txtNotice:getDescription()
    if desc:find("EditBox") then
        txtNotice:registerScriptEditBoxHandler(function(event, tf)
            if event == "ended" then
                if guildDetailData.notice ~= txtNotice:getString() then
                    local req = {}
                    req.notice = txtNotice:getString()
                    self:doSendSocket(cp.getConst("ProtoConst").ModifyGuildNoticeReq, req)
                end
            end
        end)
    else
        local countLimit = string.format("(%d/140)", txtNotice:getStringLength())
        txtCount:setString(countLimit)
        txtNotice:setMaxLength(140)
        txtNotice:addEventListener(function(tf, event)
            log("event="..event..",editing="..tostring(self.editing))
            local countLimit = string.format("(%d/140)", txtNotice:getStringLength())
            txtCount:setString(countLimit)
            if event == 1 then
                if guildDetailData.notice ~= txtNotice:getString() then
                    local req = {}
                    req.notice = txtNotice:getString()
                    self:doSendSocket(cp.getConst("ProtoConst").ModifyGuildNoticeReq, req)
                    local txtNotice = txtNotice
                    local countLimit = string.format("(%d/140)", txtNotice:getStringLength())
                    txtCount:setString(countLimit)
                end
                self.editing = false
            elseif event == 2 then
                local countLimit = string.format("(%d/140)", txtNotice:getStringLength())
                txtCount:setString(countLimit)
            elseif event == 0 then
                self.editing = true
            end
        end)
    end
    self:updateGuildEvent()
end

function GuildMainLayer:updateSweepActivity()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local sweepConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("SweepConfig"), ";")
    local img = self.ScrollView_ActivityList:getChildByName("Image_Clean")
    local txtRemain = img:getChildByName("Text_Remain")
    local txtMoney = img:getChildByName("Text_Money")
    local txtExp = img:getChildByName("Text_Exp")
    local txtProgress = img:getChildByName("Text_Progress")
    local imgFlag = img:getChildByName("Image_Flag")
    local txtDesc = img:getChildByName("Text_Desc")
    local btn = img:getChildByName("Button_Sweep")

    txtRemain:stopAllActions()
    txtExp:setString("+"..sweepConfig[2])
    txtMoney:setString("+"..sweepConfig[3])
    txtDesc:setString(string.format(txtDesc:getString(), sweepConfig[1]))
    txtProgress:setString(string.format("%d/%d", playerGuildData.sweep_info.count, sweepConfig[1]))
    txtRemain:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        if playerGuildData.sweep_info.start_time > 0 then
            local deltaTime = cp.getManager("TimerManager"):getTime() - playerGuildData.sweep_info.start_time
            deltaTime = 600 - deltaTime
            if deltaTime > 0 then
                txtRemain:setVisible(true)
                txtRemain:setString("剩餘時間 "..cp.getUtils("DataUtils").formatTimeRemain(deltaTime))
                btn:getChildByName("Text"):setString("打掃中")
                cp.getManager("ViewManager").setEnabled(btn, false)
            else
                btn:getChildByName("Text"):setString("領    取")
                cp.getManager("ViewManager").setEnabled(btn, true)
                txtRemain:setVisible(false)
                cp.getManager("ViewManager").initButton(btn, function()
                    local req = {}
                    req.type = 1
                    self:doSendSocket(cp.getConst("ProtoConst").GuildActivitySweepReq, req)
                end)
            end
        else
            btn:getChildByName("Text"):setString("打    掃")
            cp.getManager("ViewManager").setEnabled(btn, true)
            txtRemain:setVisible(false)
            cp.getManager("ViewManager").initButton(btn, function()
                local req = {}
                self:doSendSocket(cp.getConst("ProtoConst").GuildActivitySweepReq, req)
            end)
        end
    end), cc.DelayTime:create(1))))

    if playerGuildData.sweep_info.count >= sweepConfig[1] then
        cp.getManager("ViewManager").setTextQuality(txtProgress, 6)
        txtProgress:setVisible(false)
        btn:setVisible(false)
        imgFlag:setVisible(true)
    else
        cp.getManager("ViewManager").setTextQuality(txtProgress, 2)
        txtProgress:setVisible(true)
        btn:setVisible(true)
        imgFlag:setVisible(false)
    end

    if cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 1) then
        cp.getManager("ViewManager").setEnabled(btn, true)
        txtRemain:disableEffect()
        txtRemain:setTextColor(cc.c4b(52,32,17,255))
    else
        cp.getManager("ViewManager").setEnabled(btn, false)
        txtRemain:stopAllActions()
        txtRemain:setVisible(true)
        local openLevel = cp.getUtils("DataUtils").guildActivityOpenLevel(1)
        txtRemain:setString(openLevel.."級解鎖")
        cp.getManager("ViewManager").setTextQuality(txtRemain, 6)
    end

    if cp.getUtils("NotifyUtils").needNotifyGuildSweep() then
        cp.getManager("ViewManager").addRedDot(btn,cc.p(120,40))
    else
        cp.getManager("ViewManager").removeRedDot(btn)
    end
end

function GuildMainLayer:updateExpelActivity()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local config = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("ExpelRobber"), ";")
    local img = self.ScrollView_ActivityList:getChildByName("Image_Expel")
    local txtRemain = img:getChildByName("Text_Remain")
    local txtMoney = img:getChildByName("Text_Money")
    local txtExp = img:getChildByName("Text_Exp")
    local txtProgress = img:getChildByName("Text_Progress")
    local imgFlag = img:getChildByName("Image_Flag")
    local txtDesc = img:getChildByName("Text_Desc")
    local btn = img:getChildByName("Button_Expel")
    local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildActivity"), ";:")

    txtRemain:stopAllActions()
    txtExp:setString("+"..config[2])
    txtMoney:setString("+"..config[3])
    txtDesc:setString(string.format(txtDesc:getString(), config[1]))
    if guildDetailData.expel_info.count >= config[1] then
        cp.getManager("ViewManager").setTextQuality(txtProgress, 6)
    else
        cp.getManager("ViewManager").setTextQuality(txtProgress, 2)
    end
    txtProgress:setString(string.format("%d/%d", guildDetailData.expel_info.count, config[1]))
    txtRemain:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
        local time1 = nowTab.hour*3600+nowTab.min*60+nowTab.sec
        local time2 = commonConfig[2][1]*3600+commonConfig[2][2]*60
        if time1 < time2 or time1 > time2 + commonConfig[3][1]*60 or not cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 2) then
            cp.getManager("ViewManager").setEnabled(btn, false)
            txtRemain:setString("不在活動範圍內")
            txtRemain:setTextColor(cc.c4b(255,0,0,255))
        else
            local deltaTime = commonConfig[3][1]*60 + time2 - time1
            txtRemain:setString("剩餘時間 "..cp.getUtils("DataUtils").formatTimeRemain(deltaTime))
            cp.getManager("ViewManager").setEnabled(btn, true)
            cp.getManager("ViewManager").initButton(btn, function()
                self:doSendSocket(cp.getConst("ProtoConst").GuildActivityExpelReq, {})
            end)
            txtRemain:setTextColor(cc.c4b(52,32,17,255))
        end
    end), cc.DelayTime:create(1))))

    if guildDetailData.expel_info.count >= config[1] then
        txtProgress:setVisible(false)
        btn:setVisible(false)
        imgFlag:setVisible(true)
    else
        txtProgress:setVisible(true)
        btn:setVisible(true)
        imgFlag:setVisible(false)
    end

    if cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 2) then
        cp.getManager("ViewManager").setEnabled(btn, true)
        txtRemain:disableEffect()
        txtRemain:setTextColor(cc.c4b(52,32,17,255))
    else
        cp.getManager("ViewManager").setEnabled(btn, false)
        txtRemain:stopAllActions()
        txtRemain:setVisible(true)
        local openLevel = cp.getUtils("DataUtils").guildActivityOpenLevel(2)
        txtRemain:setString(openLevel.."級解鎖")
        cp.getManager("ViewManager").setTextQuality(txtRemain, 6)
    end

    if cp.getUtils("NotifyUtils").needNotifyGuildExpel() then
        cp.getManager("ViewManager").addRedDot(btn,cc.p(120,40))
    else
        cp.getManager("ViewManager").removeRedDot(btn)
    end
end

function GuildMainLayer:updateBuildActivity()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local img = self.ScrollView_ActivityList:getChildByName("Image_Build")
    local txtProgress = img:getChildByName("Text_Progress")
    local txtDesc = img:getChildByName("Text_Desc")
    local txtRemain = img:getChildByName("Text_Remain")
    local btn = img:getChildByName("Button_Info")
    local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildBuilding"), ";:")
    txtDesc:setString(string.format(txtDesc:getString(), commonConfig[5][1]))
    if playerGuildData.build_info.count >= commonConfig[5][1] then
        cp.getManager("ViewManager").setTextQuality(txtProgress, 6)
    else
        cp.getManager("ViewManager").setTextQuality(txtProgress, 2)
    end
    txtProgress:setString(string.format("%d/%d", playerGuildData.build_info.count, commonConfig[5][1]))
    for i=1, 3 do
        local txtStatus = img:getChildByName("Text_Status"..i)
        if commonConfig[1][i] > guildDetailData.level then
            txtStatus:setString("未開啟")
            txtStatus:setTextColor(cc.c4b(244,222,199,255))
            txtStatus:enableOutline(cc.c4b(52,32,17,255), 1)
        else
            txtStatus:setTextColor(cc.c4b(117,233,90,255))
            txtStatus:enableOutline(cc.c4b(39,118,37,255), 2)
            local buildingInfo = cp.getUserData("UserGuild"):getBuildInfo(i)
            if not buildingInfo then
                txtStatus:setString(buildingLevelName[1])
            else
                txtStatus:setString(buildingLevelName[buildingInfo.level])
            end
        end
    end

    cp.getManager("ViewManager").initButton(btn, function()
        local layer = require("cp.view.scene.guild.GuildBuildingLayer"):create()
        self:addChild(layer, 100)
    end)

    if cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 3) then
        cp.getManager("ViewManager").setEnabled(btn, true)
        txtRemain:disableEffect()
        txtRemain:setTextColor(cc.c4b(52,32,17,255))
    else
        cp.getManager("ViewManager").setEnabled(btn, false)
        txtRemain:stopAllActions()
        txtRemain:setVisible(true)
        local openLevel = cp.getUtils("DataUtils").guildActivityOpenLevel(3)
        txtRemain:setString(openLevel.."級解鎖")
        cp.getManager("ViewManager").setTextQuality(txtRemain, 6)
    end
    
    if cp.getUtils("NotifyUtils").needNotifyGuildBuild() then
        cp.getManager("ViewManager").addRedDot(btn,cc.p(120,40))
    else
        cp.getManager("ViewManager").removeRedDot(btn)
    end
end

function GuildMainLayer:updateWantedActivity()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local wantedConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level):getValue("WantedConfig"), ";")
    local img = self.ScrollView_ActivityList:getChildByName("Image_Arrest")
    local txtProgress = img:getChildByName("Text_Progress")
    local txtDesc = img:getChildByName("Text_Desc")
    local txtRemain = img:getChildByName("Text_Remain")
    local txtSuccess = img:getChildByName("Text_Success")
    local btn = img:getChildByName("Button_Wanted")
    local imgFlag = img:getChildByName("Image_Flag")

    if playerGuildData.wanted_info.count >= wantedConfig[1] then
        cp.getManager("ViewManager").setTextQuality(txtProgress, 6)
        txtProgress:setVisible(false)
        btn:setVisible(false)
        imgFlag:setVisible(true)
    else
        cp.getManager("ViewManager").setTextQuality(txtProgress, 2)
        txtProgress:setVisible(true)
        btn:setVisible(true)
        imgFlag:setVisible(false)
    end

    txtProgress:setString(string.format("%d/%d", playerGuildData.wanted_info.count, wantedConfig[1]))
    txtDesc:setString(string.format(txtDesc:getString(), wantedConfig[1]))
    txtSuccess:setString(string.format("緝拿成功%d次", playerGuildData.wanted_info.success))
    cp.getManager("ViewManager").initButton(btn, function()
        local info = {
            open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap},
        }
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,info)
        self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
    end)

    if cp.getUtils("DataUtils").guildActivityOpen(guildDetailData, 4) then
        cp.getManager("ViewManager").setEnabled(btn, true)
        txtRemain:disableEffect()
        txtRemain:setTextColor(cc.c4b(52,32,17,255))
    else
        cp.getManager("ViewManager").setEnabled(btn, false)
        txtRemain:stopAllActions()
        txtRemain:setVisible(true)
        local openLevel = cp.getUtils("DataUtils").guildActivityOpenLevel(4)
        txtRemain:setString(openLevel.."級解鎖")
        cp.getManager("ViewManager").setTextQuality(txtRemain, 6)
    end
    
    if cp.getUtils("NotifyUtils").needNotifyGuildWanted() then
        cp.getManager("ViewManager").addRedDot(btn,cc.p(120,40))
    else
        cp.getManager("ViewManager").removeRedDot(btn)
    end
end

local phaseName = {
    "", "報名", "幫戰結束",
}

function GuildMainLayer:updateFightActivity()
    local DataUtils = cp.getUtils("DataUtils")
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local fightConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildFightConfig"), ";:")
    local img = self.ScrollView_ActivityList:getChildByName("Image_Fight")
    local txtPhase = img:getChildByName("Text_Phase")
    local txtNum = img:getChildByName("Text_Num")
    local txtCity = img:getChildByName("Text_City")
    local txtFightCity = img:getChildByName("Text_FightCity")
    local btn = img:getChildByName("Button_Prepare")

    txtPhase:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local weekDay = tonumber(os.date("%w", cp.getManager("TimerManager"):getTime()))
        local nowTab = os.date("*t", cp.getManager("TimerManager"):getTime())
        local nearWD = DataUtils.convertWeekDay(DataUtils.getNearestWeekDay(weekDay, fightConfig[1]))

        local phase, remainTime = DataUtils.getGuildFightPhase(weekDay, nowTab, fightConfig)
        if phase == 1 then
            txtPhase:setString(DataUtils.GetWeekDayZh_CN(nearWD).."凌晨開啟")
            txtFightCity:setVisible(false) 
        elseif phase == 4 then
            txtPhase:setString("")
        else
            txtPhase:setString(string.format("%s剩餘時間：%s", phaseName[phase], DataUtils.formatTimeRemain(remainTime)))
        end

        txtNum:setString(string.format("已報名成員：%d人", cp.getUserData("UserGuild"):getPrepareFightNum()))
    
        local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.roleAtt.id)
        if phase == 2 and guildDetailData.fight_info.city == 0 and memberInfo.duty > 0 then
            btn:getChildByName("Text"):setString("開啟活動")
        else
            btn:getChildByName("Text"):setString("查    看")
        end
        
        if phase == 1 then
            txtFightCity:setVisible(false)
        elseif phase == 2 then
            if guildDetailData.fight_info.city == 0 then
                txtFightCity:setString("幫派未報名攻掠戰")
            else
                txtFightCity:setString("當前進攻城市："..cp.getConst("GameConst").CityName[guildDetailData.fight_info.city])
            end
        elseif phase == 3 then
            txtFightCity:setString("爭奪階段")
        elseif phase == 4 then
            local today = cp.getUtils("TimeUtils").GetDayOfToday(cp.getManager("TimerManager"):getTime())
            if guildDetailData.city > 0 then
                txtFightCity:setString("攻掠成功")
            else
                if today == guildDetailData.fight_info.day then
                    txtFightCity:setString("攻掠失敗")
                else
                    txtFightCity:setString("幫派未報名攻掠戰")
                end
            end
        end
    end), cc.DelayTime:create(1))))

    txtCity:setString(cp.getConst("GameConst").CityName[guildDetailData.city])
    
    cp.getManager("ViewManager").initButton(btn, function()
        local layer = require("cp.view.scene.guild.GuildFightStartLayer"):create()
        self:addChild(layer, 100)
    end)
    
    if DataUtils.guildActivityOpen(guildDetailData, 5) then
        cp.getManager("ViewManager").setEnabled(btn, true)
    else
        cp.getManager("ViewManager").setEnabled(btn, false)
    end
    
    if cp.getUtils("NotifyUtils").needNotifyGuildFight() then
        cp.getManager("ViewManager").addRedDot(btn,cc.p(120,40))
    else
        cp.getManager("ViewManager").removeRedDot(btn)
    end
end

function GuildMainLayer:updateActivityView()
    self:updateSweepActivity()
    self:updateExpelActivity()
    self:updateBuildActivity()
    self:updateWantedActivity()
    self:updateFightActivity()
    if cp.getUtils("NotifyUtils").needNotifyGuildActivity() then
        cp.getManager("ViewManager").addRedDot(self.Button_Activity,cc.p(145,60))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Activity)
    end
end

function  GuildMainLayer:updateNotice()
    local txtNotice = self.Image_Notice:getChildByName("Text_Notice")
    local tfNotice = self.Image_Notice:getChildByName("TextField_Notice")
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.roleAtt.id)
    if memberInfo.duty > 0 then
        txtNotice:setVisible(false)
        tfNotice:setVisible(true)
        tfNotice:setString(guildDetailData.notice)
    else
        tfNotice:setVisible(false)
        txtNotice:setVisible(true)
        txtNotice:setString(guildDetailData.notice)
    end
end

function GuildMainLayer:updateOneGuildRank(rank, guildInfo, model)
    local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildInfo.level)
    local txtName = model:getChildByName("Text_Name")
    --local txtLevel = model:getChildByName("Text_Level")
    local txtMember = model:getChildByName("Text_Member")
    local txtOwner = model:getChildByName("Text_Owner")
    local txtFight = model:getChildByName("Text_Fight")
    local txtRank = model:getChildByName("Text_Rank")
    local imgRank = model:getChildByName("Image_Rank")
    txtName:setString(guildInfo.name)
    --txtLevel:setString(guildInfo.level)
    txtMember:setString(string.format("成員  :  %d/%d", guildInfo.member or #guildInfo.member_list.member_list, guildLevelConfig:getValue("MaxMember")))
    txtOwner:setString("幫主  :  "..guildInfo.owner)
    txtFight:setString(guildInfo.fight)
    txtRank:setString(rank)
    if rank == 1 then
        imgRank:loadTexture("ui_guild_module_bangpai_16.png", ccui.TextureResType.plistType)
    elseif rank == 2 then
        imgRank:loadTexture("ui_guild_module_bangpai_17.png", ccui.TextureResType.plistType)
    elseif rank == 3 then
        imgRank:loadTexture("ui_guild_module_bangpai_18.png", ccui.TextureResType.plistType)
    else
        txtRank:setVisible(true)
        imgRank:loadTexture("ui_guild_module_bangpai_15.png", ccui.TextureResType.plistType)
    end
end

function GuildMainLayer:updateGuildRankView()
    local guildRankList = cp.getUserData("UserGuild"):getValue("GuildRankList")
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local imgModel = self.Image_RankList:getChildByName("Image_Model")
    local listView = self.ListView_RankList
    local children = listView:getItems()
    for i=#guildRankList.guild_list, #children-1 do
        listView:removeItem(i)
    end

    for i, guildInfo in ipairs(guildRankList.guild_list) do
        local img = listView:getItem(i-1)
        if not img then
            img = imgModel:clone()
            listView:pushBackCustomItem(img)
            img:setVisible(true)
        end
        self:updateOneGuildRank(guildRankList.start+i, guildInfo, img)
    end
    self:updateOneGuildRank(guildRankList.rank, guildDetailData, self.Image_MyRank)
end

function GuildMainLayer:sortMemberList(memberList)
	table.sort(memberList, function(a,b)
		local simpleInfoA = cp.getUserData("UserFriend"):getPlayerSimpleInfo(a.id)
		local simpleInfoB = cp.getUserData("UserFriend"):getPlayerSimpleInfo(b.id)
		if simpleInfoA and not simpleInfoB then
			return true
		elseif not simpleInfoA and simpleInfoB then
			return false
		elseif simpleInfoA and simpleInfoB then
			if simpleInfoA.status and not simpleInfoB.status then
				return true
			elseif not simpleInfoA.status and simpleInfoB.status then
				return false
			elseif simpleInfoA.status and simpleInfoB.status then
				return a.duty > b.duty
			elseif not simpleInfoA.status and not simpleInfoB.status then
				return a.duty > b.duty
			end
		end

		return false
    end)

    return memberList
end

local dutyTextureName = {
    "ui_guild_module_bangpai_70.png",
    "ui_guild_module_bangpai_71.png",
    "ui_guild_module_bangpai_72.png",
}

function GuildMainLayer:updateOneGuildMember(memberInfo, img, myMemberInfo)
    local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(memberInfo.id)
    local imgHead = img:getChildByName("Image_Head")
    local txtName = img:getChildByName("Text_Name")
    local txtFight = img:getChildByName("Text_Fight")
    local txtContribute = img:getChildByName("Text_Contribute")
    local txtLevel = img:getChildByName("Text_Level")
    local txtDuty = img:getChildByName("Text_Duty")
    local txtCareer = img:getChildByName("Text_Career")
    local txtOnline = img:getChildByName("Text_Online")
    local imgDuty = img:getChildByName("Image_Duty")
    local btnManager = img:getChildByName("Button_Manager")
    if not playerSimpleInfo then return end
    imgHead:loadTexture(cp.DataUtils.getModelFace(playerSimpleInfo.face))
    txtName:setString(playerSimpleInfo.name)
    txtFight:setString("戰力   "..playerSimpleInfo.fight)
    txtContribute:setString("幫貢   "..memberInfo.contribute)
    txtLevel:setString("LV."..playerSimpleInfo.level)
    imgDuty:ignoreContentAdaptWithSize(true)
    if memberInfo.duty > 0 then
        imgDuty:setVisible(true)
        txtDuty:setVisible(false)
        imgDuty:loadTexture(dutyTextureName[memberInfo.duty], ccui.TextureResType.plistType)
    else
        imgDuty:setVisible(false)
        txtDuty:setVisible(true)
        txtDuty:setString(cp.getConst("GameConst").DutyName[memberInfo.duty])
    end
    txtCareer:setString(playerSimpleInfo.career)
    if playerSimpleInfo.status then
        txtOnline:setString("在線")
        cp.getManager("ViewManager").setTextQuality(txtOnline, 2)
    else
        txtOnline:setString("離線")
        txtOnline:setTextColor(cc.c4b(52,32,17,255))
        txtOnline:disableEffect()
    end

    btnManager:setVisible(myMemberInfo.duty > memberInfo.duty)
    cp.getManager("ViewManager").initButton(btnManager, function()
        local layer = require("cp.view.scene.guild.GuildManageLayer"):create(memberInfo.id)
        self:addChild(layer, 100)
    end)
    
	cp.getManager("ViewManager").initButton(imgHead, function()
		local req = {}
		req.roleID = playerSimpleInfo.id
		req.zoneID = playerSimpleInfo.zone
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
	end,1)
end

function GuildMainLayer:updateGuildMemberView()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level)
    local imgModel = self.Image_MemberList:getChildByName("Image_Model")
    local listView = self.ListView_MemberList
    local children = listView:getItems()
    for i=#guildDetailData.member_list.member_list, #children-1 do
        listView:removeItem(i)
    end

    local memberList = self:sortMemberList(guildDetailData.member_list.member_list)
    local myMemberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.roleAtt.id)
    for i, memberInfo in ipairs(memberList) do
        local img = listView:getItem(i-1)
        if not img then
            img = imgModel:clone()
            listView:pushBackCustomItem(img)
            img:setVisible(true)
        end
        self:updateOneGuildMember(memberInfo, img, myMemberInfo)
    end
    
    if cp.getUtils("NotifyUtils").needMotifyGuildMember() then
        cp.getManager("ViewManager").addRedDot(self.Button_Member,cc.p(145,60))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Member)
    end
    
    if cp.getUtils("NotifyUtils").needNotifyGuildRequest() then
        cp.getManager("ViewManager").addRedDot(self.Button_Request,cc.p(170,50))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Request)
    end
end

function GuildMainLayer:updateGuildEvent()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local scrollView = self.Image_Event:getChildByName("ScrollView_Event")
    scrollView:setScrollBarEnabled(false)
    local txtEvent = scrollView:getChildByName("Text_Event")
    local eventList = cp.getUtils("DataUtils").parseGuildEvent(guildDetailData.event_list.event_list)
    txtEvent:setString(table.concat(eventList, "\n"))
    local size = txtEvent:getVirtualRendererSize()
    if size.height < 150 then
        size.height = 150
    end
    txtEvent:setPosition(0, size.height)
    scrollView:setInnerContainerSize(size)
    scrollView:jumpToBottom()
end

function GuildMainLayer:updateGuildInfoView()
	local playerSimpleData = cp.getUserData("UserFriend"):getValue("PlayerSimpleData")
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildLevelConfig = cp.getManager("ConfigManager").getItemByKey("GuildConfig", guildDetailData.level)
    self.Node_Name:getChildByName("Text_Name"):setString(guildDetailData.name)
    self.Node_Owner:getChildByName("Text_Name"):setString(guildDetailData.owner)
    local memberList = cp.getUserData("UserGuild"):getDutyList(2)
    local owner = cp.getUserData("UserGuild"):getDutyList(3)
    for i=1, 2 do
        local node = self["Node_Deputy"..i]
        local memberInfo = memberList[i]
        if memberInfo then
            local playerInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(memberInfo.id)
            if playerInfo then
                node:getChildByName("Text_Name"):setString(playerInfo.name)
            end
        else
            node:getChildByName("Text_Name"):setString("該職位空缺")
        end
    end
    local ownerInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(owner[1].id)
    if ownerInfo then
        self.Node_Owner:getChildByName("Text_Name"):setString(ownerInfo.name)
    end
    self.Node_Member:getChildByName("Text_Member"):setString(string.format("%d/%d", #guildDetailData.member_list.member_list, guildLevelConfig:getValue("MaxMember")))
    self.Node_Member:getChildByName("Text_Online"):setString(string.format("(%d在線)", #cp.getUserData("UserGuild"):getOnlineMember()))
    local loadingBar_Money = self.Node_Money:getChildByName("LoadingBar_Money")
    self.LoadingBar_Money = require("cp.view.ui.base.DynamicProgressBar"):create(loadingBar_Money, loadingBar_Money:getChildByName("Text_Progress"), true)
    self.LoadingBar_Money:initProgress(guildLevelConfig:getValue("LevelUpCostMoney"), guildDetailData.money)
    self.Node_Level:getChildByName("Text_Level"):setString(guildDetailData.level)
    if guildLevelConfig:getValue("LevelUpCostMoney") <= guildDetailData.money and
            guildLevelConfig:getValue("LevelUpCostExp") <= guildDetailData.exp then
        self.Node_Level:getChildByName("Text_Status"):setVisible(true)
    else
        self.Node_Level:getChildByName("Text_Status"):setVisible(false)
    end

    cp.getManager("ViewManager").initButton(self.Node_Level:getChildByName("Button_Upgrade"), function()
        local layer = require("cp.view.scene.guild.GuildUpgradeLayer"):create()
        self:addChild(layer, 100)
    end)
    self.Node_Fight:getChildByName("Text_Fight"):setString(guildDetailData.fight)
    self.Image_Notice:getChildByName("Text_Notice"):setString(guildDetailData.notice)
    self.Image_Notice:getChildByName("TextField_Notice"):setString(guildDetailData.notice)
    local nodeDuty = self.Image_Personal:getChildByName("Node_Duty")
    local nodeContribute = self.Image_Personal:getChildByName("Node_Contribute")
    local nodeMoney = self.Image_Personal:getChildByName("Node_Money")
    local btnSalary = self.Image_Personal:getChildByName("Button_Salary")
    local btnShop = self.Image_Personal:getChildByName("Button_Shop")
    local btnContribute = self.Image_Personal:getChildByName("Button_Contribute")
    local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.roleAtt.id)
    nodeDuty:getChildByName("Text_Duty"):setString(cp.getConst("GameConst").DutyName[memberInfo.duty])
    nodeContribute:getChildByName("Text_Contribute"):setString(memberInfo.contribute)
    nodeMoney:getChildByName("Text_Money"):setString(playerGuildData.money)
    cp.getManager("ViewManager").initButton(btnSalary, function()
        self:doSendSocket(cp.getConst("ProtoConst").GetGuildSalaryReq, {})
    end)
    cp.getManager("ViewManager").initButton(btnShop, function()
        if self.ShopMainUI ~= nil then
            self.ShopMainUI:removeFromParent()
        end
        self.ShopMainUI = nil
        
        local storeID = 10  --幫派商店
        local openInfo = {storeID = storeID, closeCallBack = function()
            self.ShopMainUI:removeFromParent()
            self.ShopMainUI = nil
        end}
        local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
        self.rootView:addChild(ShopMainUI)
        self.ShopMainUI = ShopMainUI
    end)
    cp.getManager("ViewManager").initButton(btnContribute, function()
        local layer = require("cp.view.scene.guild.GuildContributeLayer"):create()
        self:addChild(layer, 100)
    end)

    if cp.getUtils("NotifyUtils").needNotifySalary() then
        cp.getManager("ViewManager").addRedDot(btnSalary,cc.p(170,50))
    else
        cp.getManager("ViewManager").removeRedDot(btnSalary)
    end

    if cp.getUtils("NotifyUtils").needNotifyShop() then
        cp.getManager("ViewManager").addRedDot(btnShop,cc.p(170,50))
    else
        cp.getManager("ViewManager").removeRedDot(btnShop)
    end

    if cp.getUtils("NotifyUtils").needNotifyGuildInfo() then
        cp.getManager("ViewManager").addRedDot(self.Button_Info,cc.p(145,60))
    else
        cp.getManager("ViewManager").removeRedDot(self.Button_Info)
    end
end

function GuildMainLayer:updateGuildMainView()
    self:updateGuildInfoView()
    self:updateGuildMemberView()
    self:updateActivityView()
end

function GuildMainLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:dispatchViewEvent("GetPlayerGuildDataRsp", false)
    elseif nodeName == "Button_HideEvent" then
        local flippedY = btn:isFlippedY()
        if flippedY then
            btn:setFlippedY(false)
            btn:setEnabled(false)
            self.Image_Event:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(347, 0)), cc.CallFunc:create(function()
                btn:setEnabled(true)
            end)))
        else
            btn:setFlippedY(true)
            btn:setEnabled(false)
            self.Image_Event:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(347, -344)), cc.CallFunc:create(function()
                btn:setEnabled(true)
            end)))
        end
    elseif nodeName == "Button_Info" or nodeName == "Button_Member" or nodeName == "Button_Activity" or nodeName == "Button_Rank" then
        self.Button_Info:setEnabled(true)
        self.Button_Member:setEnabled(true)
        self.Button_Activity:setEnabled(true)
        self.Button_Rank:setEnabled(true)
        local extensionData = tolua.cast(btn:getComponent("ComExtensionData"), "ccs.ComExtensionData")
        local pageIndex = tonumber(extensionData:getCustomProperty())
        self.PageView_Guild:scrollToPage(pageIndex)
        btn:setEnabled(false)
        self:updateGuildMainView()
    elseif nodeName == "Button_Request" then
        local layer = require("cp.view.scene.guild.GuildRequestLayer"):create()
        self:addChild(layer, 100)
    elseif nodeName == "Button_Quit" then
        local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(self.roleAtt.id)

		local notice = "是否退出幫派"
		local contentTable = {
		{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=notice, textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="blank",  blankSize=0.5},
		{type="ttf",  fontName="fonts/msyh.ttf",fontSize=18, text="（退出幫派只保留個人資金，當前擁有的幫貢會清零）", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		}
		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
			self:doSendSocket(cp.getConst("ProtoConst").QuitGuildReq, {})
        end,nil)
	end
end

function GuildMainLayer:onEnterScene()
    self:updateGuildMainView()
end

function GuildMainLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildMainLayer