local BLayer = require "cp.view.ui.base.BLayer"
local RiverCombatListLayer = class("RiverCombatListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverCombatListLayer:create(combatList, combatType)
    local layer = RiverCombatListLayer.new(combatList, combatType)
    return layer
end

function RiverCombatListLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").GetCombatDataRsp] = function(proto)
            --cp.getUserData("UserCombat"):reverseCombatResult()
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		["UpdateArenaGuideRsp"] = function(proto)
			self:runGuideStep()
		end,
    }
end

function RiverCombatListLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Close" then
        self:removeFromParent()
    end
end

--初始化界面，以及設定界面元素標籤
function RiverCombatListLayer:onInitView(combatList, combatType)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_combat_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1},
        ["Panel_root.Image_1.ListView_Record"] = {name = "ListView_Record"},
        ["Panel_root.Image_1.Image_Model"] = {name = "Image_Model"},
        ["Panel_root.Image_1.Text_Comment"] = {name = "Text_Comment"},
	}

    self.combatList = combatList
    self.combatType = combatType

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    if #combatList > 0 then
        self.Text_Comment:setVisible(false)
    end

    self.ListView_Record:setScrollBarEnabled(false)
    self.Image_1:setPositionY(display.height/2)
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function RiverCombatListLayer:updateOneView(img, combatInfo)
    local attackName = img:getChildByName("Text_AttackName")
    local attackFight = img:getChildByName("Text_AttackFight")
    local defenceName = img:getChildByName("Text_DefenceName")
    local defenceFight = img:getChildByName("Text_DefenceFight")
    local beginTime = img:getChildByName("Text_BeginTime")
    local button1 = img:getChildByName("Button_Left")
    local button2 = img:getChildByName("Button_Right")

    attackName:setString(combatInfo.name1)
    attackFight:setString("戰力："..combatInfo.fight1)
    defenceName:setString(combatInfo.name2)
    defenceFight:setString("戰力："..combatInfo.fight2)
    beginTime:setString(cp.getUtils("DataUtils").formatCombatBegin(combatInfo.begin_time))
    cp.getManager("ViewManager").initButton(button1, function()
        local req = {}
        req.combat_id = combatInfo.combat_id
        req.side = 0
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
    end, 0.9)
    
    cp.getManager("ViewManager").initButton(button2, function()
        local req = {}
        req.combat_id = combatInfo.combat_id
        req.side = 1
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
    end, 0.9)
end

function RiverCombatListLayer:updateRiverCombatListView()
    for i, combatInfo in ipairs(self.combatList) do
        local img = self.ListView_Record:getItem(i-1)
        if not img then
            img = self.Image_Model:clone()
            self.ListView_Record:pushBackCustomItem(img)
        end

        local imgMsg = img:getChildByName("Image_Title"):getChildByName("Text_Msg")
        if combatInfo.combat_result == 1 then
            imgMsg:setString(combatInfo.name1.."  獲勝")
        elseif combatInfo.combat_result == 2 then
            imgMsg:setString(combatInfo.name2.."  獲勝")
        else
            imgMsg:setString("雙方平手")
        end

        img:setVisible(true)
        self:updateOneView(img:getChildByName("Image_Model"), combatInfo)
    end

    for i=#self.combatList, self.ListView_Record:getChildrenCount()-1 do
        self.ListView_Record:removeItem(i)
    end
end

function RiverCombatListLayer:onEnterScene()
    self:updateRiverCombatListView()
    self:runGuideStep()
end

function RiverCombatListLayer:onExitScene()
    self:unscheduleUpdate()
end

function RiverCombatListLayer:runGuideStep()
    self:dispatchViewEvent("GuideLayerCloseMsg")
	self:dispatchViewEvent("GamePopTalkCloseMsg")
    if self.combatType == cp.getConst("CombatConst").CombatType_Arena then
	    local guideStep = cp.getUserData("UserArena"):getArenaData().guide_step
	    local contentTable = require("cp.story.ArenaGuide")[guideStep]
        if not contentTable then
            if guideStep == 10 then
                local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, self.Button_Close, 1)
                guideLayer:setClickCallback(function()
                    local req = {}
                    req.step = guideStep
                    self:doSendSocket(cp.getConst("ProtoConst").UpdateArenaGuideReq, req)
                end)
            else
                return
            end
        elseif guideStep == 9 then
		    local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(nil, nil, 1)
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
end

return RiverCombatListLayer