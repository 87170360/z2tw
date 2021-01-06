local BLayer = require "cp.view.ui.base.BLayer"
local ArenaRankLayer = class("ArenaRankLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ArenaRankLayer:create(rankList)
    local scene = ArenaRankLayer.new()
    scene.rankList = rankList
	scene:updateArenaRankView()
    return scene
end

function ArenaRankLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ArenaRankLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_arena/uicsb_arena_rank.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
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
end

function ArenaRankLayer:getRankRangeEntry(i)
    local arenaRankEntry = nil
    local lastRank = 1
    cp.getManager("ConfigManager").foreach("ArenaRankNpc", function(entry)
        if i >= lastRank and i <= entry:getValue("Rank") then
            arenaRankEntry = entry
            return false
        end

        lastRank = entry:getValue("Rank")
        return true
    end)

    --log("i="..i..",rank="..arenaRankEntry:getValue("Rank"))
    return arenaRankEntry
end

function ArenaRankLayer:updateArenaRankView()
    for i=1, 10 do
        local playerInfo = self.rankList[i]
        cp.getUtils("DataUtils").fillArenaPlayerInfo(playerInfo)

        local img = self["Image_Rank"..i]
        local txtName = img:getChildByName("Text_Name")
        local txtGold = img:getChildByName("Text_Gold")
        local txtPrestige = img:getChildByName("Text_Prestige")

        txtName:setString(playerInfo.name)
        local arenaRankEntry = self:getRankRangeEntry(i)
        local goldList = cp.getUtils("DataUtils").splitBufferList(arenaRankEntry:getValue("Gold"))
        local prestigeList = cp.getUtils("DataUtils").splitBufferList(arenaRankEntry:getValue("Prestige"))
        if #goldList == 1 then
            txtGold:setString(goldList[1])
        else
            txtGold:setString(goldList[i])
        end
        
        if #prestigeList == 1 then
            txtPrestige:setString(prestigeList[1])
        else
            txtPrestige:setString(prestigeList[i])
        end
    end

    local img = self["Image_MyRank"]
    local txtName = img:getChildByName("Text_Name")
    local txtRank = img:getChildByName("Text_Rank")
    local txtGold = img:getChildByName("Text_Gold")
    local txtPrestige = img:getChildByName("Text_Prestige")
    local myRankInfo = self.rankList[11]
    local arenaRankEntry = self:getRankRangeEntry(myRankInfo.rank)
    txtName:setString(myRankInfo.name)
    txtRank:setString(myRankInfo.rank..".")
    if arenaRankEntry then
        local goldList = cp.getUtils("DataUtils").splitBufferList(arenaRankEntry:getValue("Gold"))
        local prestigeList = cp.getUtils("DataUtils").splitBufferList(arenaRankEntry:getValue("Prestige"))
        if #goldList == 1 then
            txtGold:setString(goldList[1])
        else
            txtGold:setString(goldList[myRankInfo.rank])
        end
        
        if #prestigeList == 1 then
            txtPrestige:setString(prestigeList[1])
        else
            txtPrestige:setString(prestigeList[myRankInfo.rank])
        end
    else
        txtRank:setString("未上榜")
        txtPrestige:setString(0)
        txtGold:setString(0)
    end
end

function ArenaRankLayer:onBtnClick(btn)
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

function ArenaRankLayer:onEnterScene()
end

function ArenaRankLayer:onExitScene()
    self:unscheduleUpdate()
end

return ArenaRankLayer