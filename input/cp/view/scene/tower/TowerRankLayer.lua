local BLayer = require "cp.view.ui.base.BLayer"
local TowerRankLayer = class("TowerRankLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function TowerRankLayer:create(proto)
    local scene = TowerRankLayer.new()
    scene.rankList = proto.player_list
    scene.rank = proto.rank
    return scene
end

function TowerRankLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function TowerRankLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_tower/uicsb_tower_rank.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Image_Rank1"] = {name = "Image_Rank1"},
		["Panel_root.Image_1.Image_Rank2"] = {name = "Image_Rank2"},
		["Panel_root.Image_1.Image_Rank3"] = {name = "Image_Rank3"},
		["Panel_root.Image_1.Image_Rank4"] = {name = "Image_Rank4"},
		["Panel_root.Image_1.Image_Rank5"] = {name = "Image_Rank5"},
		["Panel_root.Image_1.Image_Rank6"] = {name = "Image_Rank6"},
		["Panel_root.Image_1.Image_Rank7"] = {name = "Image_Rank7"},
		["Panel_root.Image_1.Image_Rank8"] = {name = "Image_Rank8"},
		["Panel_root.Image_1.Image_Rank9"] = {name = "Image_Rank9"},
		["Panel_root.Image_1.Image_Rank10"] = {name = "Image_Rank10"},
		["Panel_root.Image_1.Image_MyRank"] = {name = "Image_MyRank"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
    cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
end

function TowerRankLayer:updateTowerRankView()
    for i=1, 10 do
        local playerInfo = self.rankList[i]

        local img = self["Image_Rank"..i]
        local txtName = img:getChildByName("Text_Name")
        local txtFloor = img:getChildByName("Text_Floor")
        if playerInfo then
            txtName:setString(playerInfo.name)
            txtFloor:setString(playerInfo.floor)
        else
            txtName:setString("")
            txtFloor:setString("")
        end
    end

    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local towerData = cp.getUserData("UserTower"):getTowerData()
    local img = self["Image_MyRank"]
    local txtName = img:getChildByName("Text_Name")
    local txtRank = img:getChildByName("Text_Rank")
    local txtFloor = img:getChildByName("Text_Floor")
    txtRank:setString(self.rank+1)
    txtName:setString(roleAtt.name)
    txtFloor:setString(towerData.floor)
end

function TowerRankLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Fight" then
        if not self.selectRank then
            cp.getManager("ViewManager").gameTip("請選擇要挑戰的玩家")
            return
        end
        local req = {}
        req.rank = self.selectRank
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ArenaFightReq, req)
	end
end

function TowerRankLayer:onEnterScene()
    self:updateTowerRankView()
end

function TowerRankLayer:onExitScene()
    self:unscheduleUpdate()
end

return TowerRankLayer