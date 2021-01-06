local BNode = require "cp.view.ui.base.BNode"
local AchivementEventNotice = class("AchivementEventNotice",BNode)

function AchivementEventNotice:create()
	local node = AchivementEventNotice.new()
	return node
end

function AchivementEventNotice:initListEvent()
	self.listListeners = {

	}
end

function AchivementEventNotice:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_achievement/uicsb_achievement_event_notice.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Panel_1"] = {name = "Panel_1", click = "onUIButtonClick",clickScale=1},
		["Panel_item.Image_type"] = {name = "Image_type"},
		["Panel_item.Text_type"] = {name = "Text_type"},
		["Panel_item.Text_content"] = {name = "Text_content"},
		["Panel_item.Button_close"] = {name = "Button_close", click = "onUIButtonClick"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
    ccui.Helper:doLayout(self["rootView"])
end

function AchivementEventNotice:onEnterScene()

end

function AchivementEventNotice:initContent(info)
	local showTypeStr = {"新手","收集","修行","活動","競技","幫派","江湖","佚聞"}
	local str = showTypeStr[info.ShowType]
    self.Text_type:setString(str)
	self.Text_content:setString(info.Desc)
	self.info = info
end

function AchivementEventNotice:onUIButtonClick(sender)
    local buttonName = sender:getName()
	log(buttonName)
	if "Button_close" == buttonName then
		cp.getUserData("UserAchivement"):setValue("need_notice",false)
		if self.closeCallback then
			self.closeCallback()
		end
	elseif "Panel_1" == buttonName then
		self:achiveGoto(self.info)
	end
end

function AchivementEventNotice:setCloseCallBack(cb)
	self.closeCallback = cb
end

function AchivementEventNotice:achiveGoto(data)
    
	dump(data)
	
	--[[...
	功能類型：
--前往藏寶閣
購買（）次江湖奇珍 8
收集（）套武學組合 9
收集（）套紫色武學 10
收集（）套金色武學 11
收集（）套紅色武學 12
購買（）次武林祕籍 30

--前往江湖界面
通關（）層修羅塔 18
掃蕩（）次副本 19
完成（）章劇情 20
完成（）次快速歷練 21
挑戰（）次祕境 22
華山論劍排名第（） 31

--前往大地圖界面
擊敗（）次江湖豪俠 13
完成（）次江湖事件 14

--進入幫派界面 
完成（）掃除 2
獲得（）幫貢 3
完成（）次緝拿 4
完成（）次掠奪戰 6
完成（）次幫派修築 5
加入幫會 37

比武場排名第（） 7
完成（）次比武 24
排行榜戰力排名第（） 25

成為VIP（） 1

--前往風雨樓
獲取（）次混元 15

--打開好友界面
添加（）個好友 16

--打開活動界面
食用（）次包子 17


收集（）套時裝 23


購買（）次體力 26
完成（）次長樂坊 27
完成（）次斗酒 28
完成（）次招財 29

--門派界面
門派地位 32
完成（）次門派修煉 33

--武學界面
完成（）次武學境界 34
完成（）次武學招式 35
完成（）次武學突破 36

完成其他成就 38

通過（）次困難本 39
學習（）本武學書 40
	
	]]
	
	if data.ShowType == 1 then
		cp.getUserData("UserAchivement"):setValue("GuideType", data.Type)
	end
    if data.Type == 18  or data.Type == 19 or data.Type == 20 or data.Type == 21 or data.Type == 22 or data.Type == 31 or data.Type == 39 then --劇情闖關,掃蕩副本，歷練，祕境,修羅塔,華山論劍,困難本
        local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif data.Type == 8 or data.Type == 9 or data.Type == 10 or data.Type == 11 or data.Type == 12 or data.Type == 30 then --藏寶閣抽獎
        local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif data.Type == 34 or data.Type == 35 or data.Type == 36 then  --武學相關
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillSummary}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif data.Type == 32 or data.Type == 33 then  --門派相關
        local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai,auto_open_name = "MenPaiXiuLian"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif data.Type == 7 or data.Type == 24 or data.Type == 25 then  --比武場
        self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, true)
	elseif data.Type == 13 or data.Type == 14 then -- 大地圖
        local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
		self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
	
	elseif data.Type == 2 or data.Type == 3 or data.Type == 4 or data.Type == 5 or data.Type == 6 or data.Type == 37 then --幫派界面
		self:dispatchViewEvent("GetPlayerGuildDataRsp", true)
	elseif data.Type == 15 then --混元
		self:dispatchViewEvent("GetPrimevalDataRsp", true)
	elseif data.Type == 16 then --好友
		self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,true)
	elseif data.Type == 17 then --包子
		self:dispatchViewEvent(cp.getConst("EventConst").open_activity_view,true)
	elseif data.Type == 23 then --時裝
		cp.getManager("ViewManager").showFashionMainLayer(nil)
	elseif data.Type == 26 then --體力購買
		cp.getManager("ViewManager").showBuyPhysicalUI()
	elseif data.Type == 27 then --鬥老千
        self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, true)
    elseif data.Type == 28 then  --斗酒
        self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, true)
    elseif data.Type == 29 then --招財
        cp.getManager("ViewManager").showSilverConvertUI()
    elseif data.Type == 1 then --儲值成為vip
		 cp.getManager("ViewManager").showRechargeUI()
	elseif data.Type == 40 then --學習武學書
		local info = {classname = "MajorDown",button_name="Button_BeiBao"}
		self:dispatchViewEvent(cp.getConst("EventConst").click_view_button, info)
		
	else
		-- 38  
		cp.getManager("ViewManager").gameTip("請大俠自行前往")
    end
	
	if data.Type > 0 and data.Type ~= 38 then
		self:dispatchViewEvent("open_achivement_view", false)
	end
end

return AchivementEventNotice