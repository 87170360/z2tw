local BLayer = require "cp.view.ui.base.BLayer"
local RiverMainLayer = class("RiverMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverMainLayer:create()
	local scene = RiverMainLayer.new()
    return scene
end

function RiverMainLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").GetConductRsp] = function(proto)
            self:updateRiverMainView()
		end,
        [cp.getConst("EventConst").UpdateHangConductRsp] = function(proto)
            self:updateRiverMainView()
            self:refreshBeRobbedNotice()
		end,
        [cp.getConst("EventConst").BreakHangConductRsp] = function(proto)
    		--self:updateRiverMainView()
            local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").GetConductReq, req)
		end,
        [cp.getConst("EventConst").StartHangConductRsp] = function(proto)
            self:updateRiverMainView()
		end,
        [cp.getConst("EventConst").StopConductRsp] = function(proto)
            self:updateRiverMainView()
            
            if proto.bad > 0 or proto.good > 0 or proto.silver > 0 or (proto.items and next(proto.items)) then
                local layer = require("cp.view.scene.world.shaneevent.RiverRewardLayer"):create(proto)
                self:addChild(layer, 100)
            end

            --結束善惡事件後再重新刷新數據
            local isSwitch = cp.getUserData("UserMapEvent"):getValue("isSwitch")
            if not isSwitch then
			    local req = {}
                self:doSendSocket(cp.getConst("ProtoConst").GetConductReq, req)
            end
            cp.getUserData("UserMapEvent"):setValue("isSwitch",false)
		end,
        [cp.getConst("EventConst").onOpenAcceptUI] = function(openInfo)
            local RiverEventAcceptUI = require("cp.view.scene.world.shaneevent.RiverEventAcceptUI"):create(openInfo)
            RiverEventAcceptUI:setUIButtonClickCallBack(handler(self,self.onAcceptEventButtonClicked))
            self.rootView:addChild(RiverEventAcceptUI,2)
            self.RiverEventAcceptUI = RiverEventAcceptUI
		end,
        [cp.getConst("EventConst").GetCombatListRsp] = function(proto)
            if proto.mode == "combat" then
                if proto.combat_list and next(proto.combat_list) then
                    local layer = require("cp.view.scene.world.shaneevent.RiverCombatListLayer"):create(proto.combat_list)
                    self:addChild(layer, 100)
                else
                    cp.getManager("ViewManager").gameTip("暫無戰鬥記錄可以觀戰。")
                end
            elseif proto.mode == "break" then
                local layer = require("cp.view.scene.world.shaneevent.RiverBreakListLayer"):create(proto.combat_list)
                self:addChild(layer, 100)
            end
        end,
        
        --被伏擊通知
        [cp.getConst("EventConst").BeRobVanRsp] = function(proto)
            self:refreshBeRobbedNotice()
            
        end,

        --查看被伏擊錄像
        [cp.getConst("EventConst").GetCombatDataRsp] = function(proto)
            
            cp.getUserData("UserCombat"):setValue("review_combatID",0)
            local review_type = cp.getUserData("UserCombat"):getValue("review_type")
            if review_type == 1 then
                cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
            end
            cp.getUserData("UserCombat"):setValue("review_type",0)
            
        end,
        [cp.getConst("EventConst").BribeAllHeroRsp] = function(proto)
            self:updateHeroEventNums()
        end,
        [cp.getConst("EventConst").StartFightHeroRsp] = function(proto)
            self:updateHeroEventNums()
        end,
        [cp.getConst("EventConst").BribeHeroRsp] = function(proto)
            self:updateHeroEventNums()
        end,

        --聊天訊息接收,顯示提示
        [cp.getConst("EventConst").ChatChannelRsp] = function(data)
			self:checkNeedNoticeChatMsg()
        end,
        
        [cp.getConst("EventConst").ChatLayerClose] = function(data)
            self:checkNeedNoticeChatMsg()
        end,

        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "RiverMainLayer" then
                if evt.guide_name == "river_event" then
                    self:onBtnClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "RiverMainLayer" then
                if evt.guide_name == "river_event" then
                    local boundbingBox = self[evt.target_name]:getBoundingBox()
                    local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                end
            end
        end,
    }
end

function RiverMainLayer:onAcceptEventButtonClicked(openInfo)
    
    if openInfo then -- openInfo為nil時為取消返回 
        if openInfo.uuid ~= nil and openInfo.uuid ~= "" then -- 任務已經存在，且必定是掛機類的事件，挑戰類的事件直接完成的。
            local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            if openInfo.owner == major_roleAtt.account then -- 自己是事件
                -- cp.getManager("ViewManager").gameTip("事件正在進行中...")
            else
                    --打斷別人的掛機事件
                local req = {uuid = openInfo.uuid}
                self:doSendSocket(cp.getConst("ProtoConst").BreakHangConductReq, req)
            end
        else
            if openInfo.Process == 2 then --挑戰npc類
                local req = {id = openInfo.confId}
                self:doSendSocket(cp.getConst("ProtoConst").StartFightConductReq, req)
            else --掛機類
                local req = {id = openInfo.confId, pos = tostring(openInfo.pos)}
                self:doSendSocket(cp.getConst("ProtoConst").StartHangConductReq, req)        
            end
        end
    end

    self:onNewGuideStory()
    if self.RiverEventAcceptUI then
        self.RiverEventAcceptUI:removeFromParent()
    end
    self.RiverEventAcceptUI = nil
end

function RiverMainLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Mode" then


        local contentTable = {
            {type="ttf", fontSize=24, text="切換江湖陣營，會結算當前正在進行的任務，你確定要切換嗎？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        }
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
            btn:setTouchEnabled(false)
            btn:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    cp.getUserData("UserMapEvent"):setValue("isSwitch",true)
                    local req = {}
                    req.uuid = cp.getUserData("UserMapEvent"):getEffectiveEvent()
                    self:doSendSocket(cp.getConst("ProtoConst").StopConductReq, req)  --結束所有善惡事件
                end), 
                cc.DelayTime:create(1.0),
                
                cc.CallFunc:create(function()
                    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
                    majorRole.conductType = majorRole.conductType or 1
                    majorRole.conductType = math.max(majorRole.conductType, 1) --  -- 善惡模式2  六扇門, 1  俠客堂
                    local req = {}
                    req.conductType = 3 - majorRole.conductType
                    self:doSendSocket(cp.getConst("ProtoConst").SwitchConductTypeReq, req)
                end), 
                cc.DelayTime:create(1.5),
                
                cc.CallFunc:create(function()
                    btn:setTouchEnabled(true)
                end)
            ))
        end,nil)
        
    elseif btnName == "Button_Watch" then
        local req = {}
        req.combat_type = CombatConst.CombatType_Shane
        req.time = cp.getManager("TimerManager"):getTime()-24*3600*100
        req.max_num = 40
        req.mode = "combat"
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatListReq, req)
    elseif btnName == "Button_Event" then
        local layer = require("cp.view.scene.world.shaneevent.RiverEventListLayer"):create()
        self:addChild(layer, 100)
    elseif btnName == "Button_Show" then
        self.showEventList = not self.showEventList
        self.ListView_EventList:setVisible(self.showEventList)
        local img = self.Button_Show:getChildByName("Image_Status")
        img:setScaleY(self.showEventList and 1 or -1)
    elseif btnName == "Button_Hero" then
        local layer = require("cp.view.scene.world.shaneevent.RiverHeroListLayer"):create()
        self:addChild(layer, 100)
    elseif btnName == "Button_River_Shop" then

        self:openShop(5) --俠義商店

        -- local req = {}
        -- req.storeID = 5 --俠義商店
        -- cp.getUserData("UserShop"):setValue("current_storeID",req.storeID)
        -- self:doSendSocket(cp.getConst("ProtoConst").StoreGoodsReq, req)
 
    end
end

--初始化界面，以及設定界面元素標籤
function RiverMainLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_main.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    self.showEventList = true

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_top"] = {name = "Panel_top"},
        ["Panel_root.Panel_top.Text_Good"] = {name = "Text_Good"},
        ["Panel_root.Panel_top.Text_Bad"] = {name = "Text_Bad"},
        ["Panel_root.Panel_top.Button_Mode"] = {name = "Button_Mode", click="onBtnClick", clickScale=1},
        ["Panel_root.Panel_top.Button_Watch"] = {name = "Button_Watch", click="onBtnClick"},
        ["Panel_root.Panel_top.Button_Event"] = {name = "Button_Event", click="onBtnClick"},
        ["Panel_root.Panel_top.Button_Hero"] = {name = "Button_Hero", click="onBtnClick"},
        ["Panel_root.Panel_top.Button_River_Shop"] = {name = "Button_River_Shop", click="onBtnClick"},
        ["Panel_root.Panel_top.Button_Show"] = {name = "Button_Show", click="onBtnClick"},
        ["Panel_root.Panel_top.ListView_EventList"] = {name = "ListView_EventList"},
        ["Panel_root.Panel_top.Button_Model"] = {name = "Button_Model"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.ListView_EventList:setScrollBarEnabled(false)
    self.Panel_top:setPositionY(display.height)
    --self:updateRiverMainView()

    self.Button_chat = cp.getManager("ViewManager").addChatMsgNotice(self.rootView,cc.p(670,174),0)
    self:setupAchivementGuide()
end

function RiverMainLayer:setupAchivementGuide()
    local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    
    local finished = cp.getUserData("UserRole"):getValue("newplayerguider").finished
    if not string.find(finished, "river_event") then
        return
    end

    local guideBtn = nil
    if guideType == 13 then
        guideBtn = self.Button_Hero
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    elseif guideType == 14 then
        guideBtn = self.Button_Event
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end
    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function RiverMainLayer:getShowEventList(event_list)
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local showEventList = {}
    for _, conductData in pairs(event_list) do
        if conductData.owner == majorRole.account and conductData.state > 1 then
            table.insert(showEventList, conductData)
        end
    end

    local now = cp.getManager("TimerManager"):getTime()
    table.sort(showEventList, function(a, b)
        local conductEventEntryA = cp.getManager("ConfigManager").getItemByKey("GameConduct", a.confId)
        local conductEventEntryB = cp.getManager("ConfigManager").getItemByKey("GameConduct", b.confId)
        return conductEventEntryA:getValue("HangTime")*60-(now-a.startStamp) < conductEventEntryB:getValue("HangTime")*60-(now-b.startStamp)
    end)

    return showEventList
end

function RiverMainLayer:updateRiverMainView()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    self.Text_Good:setString(majorRole.totalGood) -- 累積行俠令
    self.Text_Bad:setString(majorRole.totalBad)  -- 累積鐵膽令
    local textureName = ""
    local conductType = majorRole.conductType or 1 -- 善惡模式1 俠義堂, 2 六扇門
    if conductType == 1 then
        textureName = "ui_mapbuild_module6_jianghushi_shane_b.png"
    else
        textureName = "ui_mapbuild_module6_jianghushi_shane_c.png"
    end
    self.Button_Mode:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
    local mapEventData = cp.getUserData("UserMapEvent")
    local showEventList = self:getShowEventList(mapEventData.map_event_list)
    for i, conductData in ipairs(showEventList) do
        local button = self.ListView_EventList:getItem(i-1)
        if not button then
            button = self.Button_Model:clone()
            self.ListView_EventList:pushBackCustomItem(button)
            button:setVisible(true)
        else
            button:stopAllActions()
        end

        local conductEventEntry = cp.getManager("ConfigManager").getItemByKey("GameConduct", conductData.confId)
        local status = button:getChildByName("Text_Status")
        local name = button:getChildByName("Text_Name")
        local desc = button:getChildByName("Text_Desc")
        local task = button:getChildByName("LoadingBar_Task")
        local time = button:getChildByName("Text_Time")
        if conductData.state == 2 then
            status:setString("進行")
            time:setVisible(true)
            status:setTextColor(cc.c4b(0,150,255,255))
        elseif conductData.state == 3 then
            task:setPercent(100)
            time:setVisible(false)
            status:setString("完成")
            status:setTextColor(cc.c4b(255,240,0,255))
            button:stopAllActions()
        elseif conductData.state == 4 then
            task:setPercent(100)
            time:setVisible(false)
            status:setString("失敗")
            status:setTextColor(cc.c4b(175,177,179,255))
        end
        name:setString(conductEventEntry:getValue("Name"))
        desc:setString(conductEventEntry:getValue("Desc"))
        cp.getManager("ViewManager").initButton(button, function()
            self:dispatchViewEvent(cp.getConst("EventConst").NavigateEvent, conductData)
        end, 1.0)

        button:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            if conductData.state == 2 then
                local now = cp.getManager("TimerManager"):getTime()
                local leftTime = conductEventEntry:getValue("HangTime")*60 - (now - conductData.startStamp)
                if leftTime > 0 then
                    task:setPercent(100-leftTime*100/(conductEventEntry:getValue("HangTime")*60))
                    time:setString(cp.getUtils("DataUtils").formatTimeRemain(leftTime))
                else 
                    if math.abs(leftTime)%5 == 0 then
                        local req = {uuid={}}
                        req.uuid[1] = conductData.uuid
                        self:doSendSocket(cp.getConst("ProtoConst").UpdateHangConductReq, req)
                    end
                end
            end
        end), cc.DelayTime:create(1))))
    end

    for i=#showEventList, self.ListView_EventList:getChildrenCount()-1 do
        self.ListView_EventList:removeItem(i)
    end

    local showNum = #showEventList
    if showNum > 5 then
        showNum = 5
    end
    self.ListView_EventList:setSize(cc.size(351, showNum*114))
    self.ListView_EventList:setContentSize(cc.size(351, showNum*114))

    self:updateHeroEventNums()
  

    local txtNum2 = self.Button_Event:getChildByName("Text_Num")
    local conduct_max_num = tonumber(cp.getUtils("DataUtils").GetVipEffect(10))

    local cnt = conduct_max_num - (majorRole.normalEvent or 0)
    txtNum2:setString(string.format("%d/%d", cnt, conduct_max_num))
    local textColor = majorRole.normalEvent <=0 and 2 or 1 
    cp.getManager("ViewManager").setTextQuality(txtNum2, textColor)
    
end

function RiverMainLayer:updateHeroEventNums()
    local count, total = cp.getUserData("UserNpc"):getNpcNum()
    local txtNum = self.Button_Hero:getChildByName("Text_Num")
    txtNum:setString(string.format("%d/%d", count, total))
    local textColor = count >= total and 2 or 1 
    cp.getManager("ViewManager").setTextQuality(txtNum, textColor)
    
end

function RiverMainLayer:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "river_event" then
        -- local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        -- if cur_step == 5 or cur_step == 11 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.3))
            table.insert(sequence,cc.CallFunc:create(
                function()
                    local info =
                    {
                        classname = "RiverMainLayer",
                    }
                    self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                end)
            )
            self:runAction(cc.Sequence:create(sequence))
        -- end
    end
end


function RiverMainLayer:onEnterScene()
    self:updateRiverMainView()

    self:checkNeedNoticeChatMsg()

    self:refreshBeRobbedNotice()

    
    local result,step = cp.getManager("GDataManager"):checkNeedGuide("river_event")
    if result then
        step = step > 0 and 3 or 0
        cp.getManager("ViewManager").openNewPlayerGuide("river_event",step)
    end

end

function RiverMainLayer:refreshBeRobbedNotice()
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

function RiverMainLayer:onExitScene()
    self:unscheduleUpdate()
end



function RiverMainLayer:openShop(storeID)
    if self.ShopMainUI ~= nil then
        self.ShopMainUI:removeFromParent()
    end
    self.ShopMainUI = nil
    
    local openInfo = {storeID = storeID, closeCallBack = function()
        self.ShopMainUI:removeFromParent()
        self.ShopMainUI = nil
    end}
    local ShopMainUI =  require("cp.view.scene.world.shop.ShopMainUI"):create(openInfo)
    self.rootView:addChild(ShopMainUI,2)
    self.ShopMainUI = ShopMainUI

end

function RiverMainLayer:checkNeedNoticeChatMsg()
    local total = cp.getUserData("UserChatData"):getNewMsgNum()
    self.Button_chat = cp.getManager("ViewManager").addChatMsgNotice(self.rootView,cc.p(670,174),total or 0)
end

function RiverMainLayer:ShowExpressNoticeView()

    local ExpressLootNotice = require("cp.view.scene.world.express.ExpressLootNotice"):create()
    self.rootView:addChild(ExpressLootNotice,2)
    ExpressLootNotice:setCloseCallBack(handler(self,self.refreshBeRobbedNotice)) 
end

return RiverMainLayer
