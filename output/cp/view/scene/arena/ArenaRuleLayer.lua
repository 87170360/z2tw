local BLayer = require "cp.view.ui.base.BLayer"
local ArenaRuleLayer = class("ArenaRuleLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ArenaRuleLayer:create(rankList)
    local scene = ArenaRuleLayer.new()
    scene.rankList = rankList
	scene:updateArenaRuleView()
    return scene
end

function ArenaRuleLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function ArenaRuleLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_arena/uicsb_arena_rule.csb")
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

function ArenaRuleLayer:getRankRangeEntry(i)
    local arenaRankEntry = nil
    local lastRank = 1
    cp.getManager("ConfigManager").foreach("ArenaRuleNpc", function(entry)
        if i >= lastRank and i <= entry:getValue("Rank") then
            arenaRankEntry = entry
            return false
        end

        lastRank = entry:getValue("Rank")
        return true
    end)

    return arenaRankEntry
end

function ArenaRuleLayer:updateArenaRuleView()
end

function ArenaRuleLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Fight" then
	end
end

function ArenaRuleLayer:onEnterScene()
end

function ArenaRuleLayer:onExitScene()
    self:unscheduleUpdate()
end

return ArenaRuleLayer