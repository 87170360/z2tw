
local BLayer = require "cp.view.ui.base.BLayer"
local MenPaiPlace = class("MenPaiPlace",BLayer)

function MenPaiPlace:create(openInfo)
	local layer = MenPaiPlace.new(openInfo)
	return layer
end

function MenPaiPlace:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
        --請求門派地位排名列表
		[cp.getConst("EventConst").GangRankInfoRsp] = function(data)	
			self:refreshAllName()
        end,
        
        --刷新挑戰對象返回
		[cp.getConst("EventConst").GangRankRefreshRsp] = function(data)	
            
            local fight_list_cache = cp.getUserData("UserMenPai"):getValue("fight_list_cache") 
            local totalNum = table.nums(fight_list_cache)

            local current_fight_List = {}
            local idxList = {}
            while(table.nums(idxList) < 5) do
                local idx =  math.random(1,totalNum)
                if table.arrIndexOf(idxList,idx) == -1 then
                    table.insert(idxList,idx)
                end
            end
            for i=1,table.nums(idxList) do
                table.insert(current_fight_List,fight_list_cache[idxList[i]])
            end
            table.sort(current_fight_List,function(a, b)
                return a.rank < b.rank
            end)

            cp.getUserData("UserMenPai"):setValue("current_fight_List", current_fight_List)
            
            if self.MenPaiMockFights then
                self.MenPaiMockFights:refreshItems()
            else
                local idx = cp.getUserData("UserMenPai"):getValue("fight_grade")
                local openInfo = {grade = idx}
                local MenPaiMockFights = require("cp.view.scene.world.menpai.MenPaiMockFights"):create(openInfo) 
                self:addChild(MenPaiMockFights)
                MenPaiMockFights:setCloseCallBack(
                    function(backType)
                        self.MenPaiMockFights:removeFromParent()
                        self.MenPaiMockFights = nil
                    end
                )
                self.MenPaiMockFights = MenPaiMockFights
            end
            
        end
        
	}
end

function MenPaiPlace:onInitView(openInfo)
    self.openInfo = openInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_place.csb") 
    self.rootView:setContentSize(display.size)
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},

        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.ScrollView_bg"] = {name = "ScrollView_bg"},

        ["Panel_root.Panel_1.Panel_top.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.Panel_content_bg"] = {name = "Panel_content_bg"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.Panel_content_bg.Button_pipei_5"] = {name = "Button_pipei_5",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.Panel_content_bg.Button_pipei_6"] = {name = "Button_pipei_6",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.Panel_content_bg.Button_pipei_7"] = {name = "Button_pipei_7",click = "onUIButtonClick"},

        ["Panel_root.Panel_1.Panel_top.Image_top.Button_Back"] = {name = "Button_Back",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.Image_top.Button_Rule"] = {name = "Button_Rule",click = "onUIButtonClick"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
 
    local function onTouch(sender, event)

        if event == cc.EventCode.ENDED then
            log("onTouch item = " .. sender:getName())
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onItemClick(sender)
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效    
            end
            
        end
    end
    

    self.uiList = {}
    for i=1,27 do
        local Panel_item = self.Panel_content_bg:getChildByName("Panel_" .. tostring(i))
        if Panel_item ~= nil then
            local Text_name = Panel_item:getChildByName("Text_name")
            local Image_head = Panel_item:getChildByName("Image_head")
            self.uiList[i] = { ["Text_name"] = Text_name, ["Image_head"] = Image_head}
            if i < 8 then
                local Text_zhiwei = Panel_item:getChildByName("Text_zhiwei")
                self.uiList[i]["Text_zhiwei"] = Text_zhiwei
            end
            if i > 15 then
                local Text_rank = Panel_item:getChildByName("Text_rank")
                self.uiList[i]["Text_rank"] = Text_rank 
            end
            if Panel_item.addTouchEventListener ~= nil then
                Panel_item:addTouchEventListener(onTouch)
            end
            Panel_item:setTouchEnabled(true)
        end
    end

    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.ScrollView_bg:setScrollBarEnabled(false)
    self.ScrollView_1:setScrollBarEnabled(false)
    self:adapterReslution()
    ccui.Helper:doLayout(self["rootView"])
    -- cp.getManager("ViewManager").popUpView(self.Panel_1)
end


function MenPaiPlace:adapterReslution()
    local scroll_sz = self.ScrollView_1:getContentSize() 
    local root_height = display.height - ( display.height < 1000 and 100 or 110)
    self.Panel_root:setContentSize(display.width,root_height)
    self.Panel_root:setPositionY(display.height )
    self.ScrollView_1:setContentSize(scroll_sz.width,root_height-170)	
    self.ScrollView_bg:setContentSize(display.width,root_height-100)
    self.ScrollView_bg:setInnerContainerSize(cc.size(display.width,root_height-100))
	-- ccui.Helper:doLayout(self["rootView"])

end

function MenPaiPlace:onEnterScene()
    self:initzhiwei()
    local req = {}
    self:doSendSocket(cp.getConst("ProtoConst").GangRankInfoReq, req)

    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if major_roleAtt.gangRank == 0 or major_roleAtt.gangRank > 530 then
        self.ScrollView_1:jumpToPercentVertical(99)
    elseif major_roleAtt.gangRank > 30 then
        self.ScrollView_1:jumpToPercentVertical(75)
    elseif major_roleAtt.gangRank > 15 then
        self.ScrollView_1:jumpToPercentVertical(display.height <=1080 and 55 or 50)
    elseif major_roleAtt.gangRank > 7 then
        self.ScrollView_1:jumpToPercentVertical(display.height <=1080 and 38 or 35)
    elseif major_roleAtt.gangRank > 3 then
        self.ScrollView_1:jumpToPercentVertical(display.height <=1080 and 17 or 15)
    else
        self.ScrollView_1:jumpToTop()
    end
    
    if major_roleAtt.gangRank > 0 then
        local now = cp.getManager("TimerManager"):getTime()
        local str = os.date("%Y-%m-%d", now)
        local saveValue = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_getDate","")
        local firstGetDate = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
        local needNotice = (saveValue ~= str and firstGetDate ~= str and firstGetDate ~= "0-0-0")
        if needNotice then
            self:showSelfRankInfoUI() --今天還未領獎
        end
    end
    
end

function MenPaiPlace:onExitScene()
   
end

function MenPaiPlace:onItemClick(sender)
    local itemName = sender:getName()
    local idx = tonumber(string.sub(itemName,string.len("Panel_")+1) )
    
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local gangRank = major_roleAtt.gangRank

    local gradeList = {1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7} -- 1+2+4+8+15(3)+500(3)+1000(3)
    local grade = gradeList[idx]
    local rankInfoList = cp.getUserData("UserMenPai"):getValue("rankInfoList")
    local curInfoList = {}
    local curRank = 0
    if idx <= 18 then
        if gangRank == idx then
            -- cp.getManager("ViewManager").gameTip("不能挑戰自己,請另選對手！")
            -- return
            local selfRankInfo = self:generateSelfRankInfo()
            table.insert(curInfoList,selfRankInfo)
            cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
        else
            table.insert(curInfoList,rankInfoList[idx])
            cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
            curRank = idx
        end
        
    elseif idx == 20 or idx == 21 or idx == 22 or idx == 24 or idx == 25 or idx == 26 then
        local idx_list = {[20] = 31, [21] = 32, [22] = 33, [24] = 34, [25] = 35, [26] = 36}
        if gangRank == rankInfoList[idx_list[idx]].rank then
            -- cp.getManager("ViewManager").gameTip("不能挑戰自己,請另選對手！")
            -- return
            local selfRankInfo = self:generateSelfRankInfo()
            table.insert(curInfoList,selfRankInfo)
            cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
        else
            table.insert(curInfoList,rankInfoList[idx_list[idx]])
            cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
            curRank = idx_list[idx]
        end
    else
         -- i == 19 or i == 23 or i == 27
        if (gangRank > 18 and gangRank < 31 and idx == 19) or (gangRank > 33 and gangRank < 531 and idx == 23) or (gangRank > 533 and gangRank < 1531 and idx == 27)  then
            -- cp.getManager("ViewManager").gameTip("不能挑戰自己,請另選對手！")
            local selfRankInfo = self:generateSelfRankInfo()
            table.insert(curInfoList,selfRankInfo)
            cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)

        else
            cp.getManager("ViewManager").gameTip("想要挑戰更多，請點擊匹配對手！")
            return
        end
        
    end
    if curRank <= 33 then 
        local retValue = self:checkLevelDistance(curRank) 
        if retValue ~= "" then
            cp.getManager("ViewManager").gameTip(retValue)
            return
        end
    end

    if self.MenPaiMockFights then
        self.MenPaiMockFights:refreshItems()
    else
        local openInfo = {grade = grade}
        local MenPaiMockFights = require("cp.view.scene.world.menpai.MenPaiMockFights"):create(openInfo) 
        self:addChild(MenPaiMockFights)
        MenPaiMockFights:setCloseCallBack(
            function(backType)
                self.MenPaiMockFights:removeFromParent()
                self.MenPaiMockFights = nil
            end
        )
        self.MenPaiMockFights = MenPaiMockFights
    end

end

function MenPaiPlace:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_Back" then
        if self.closeCallBack ~= nil then
            self.closeCallBack()
        end
        self:removeFromParent()
    elseif buttonName == "Button_Rule" then
        cp.getManager("ViewManager").showHelpTips("MenPaiMockFights")
    elseif buttonName == "Button_pipei_5" then --真傳弟子 匹配
        local retValue = self:checkLevelDistance(16) 
        if retValue ~= "" then
            cp.getManager("ViewManager").gameTip(retValue)
            return
        end

        local randIdx = {}
        while(table.nums(randIdx) < 5) do
            local idx = math.random(16, 30)
            if table.arrIndexOf(randIdx,idx) == -1 then
                table.insert(randIdx,idx)
            end
        end
        table.sort(randIdx,function(a,b)
            return a<b
        end)
        local rankInfoList = cp.getUserData("UserMenPai"):getValue("rankInfoList")
        local curInfoList = {}
        for i=1,table.nums(randIdx) do
            local rankInfo = rankInfoList[randIdx[i]]
            table.insert(curInfoList,rankInfo)
        end
        cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
        local fight_list_cache = {}
        for i=16,30 do
            local rankInfo = rankInfoList[i]
            table.insert(fight_list_cache,rankInfo)
        end
        cp.getUserData("UserMenPai"):setValue("fight_list_cache",fight_list_cache)
        if self.MenPaiMockFights then
            self.MenPaiMockFights:refreshItems()
        else
            local openInfo = {grade = 5}
            local MenPaiMockFights = require("cp.view.scene.world.menpai.MenPaiMockFights"):create(openInfo) 
            self:addChild(MenPaiMockFights)
            MenPaiMockFights:setCloseCallBack(
                function(backType)
                    self.MenPaiMockFights:removeFromParent()
                    self.MenPaiMockFights = nil
                end
            )
            self.MenPaiMockFights = MenPaiMockFights
        end
    elseif buttonName == "Button_pipei_6" or  buttonName == "Button_pipei_7" then
        local idx = tonumber(string.sub(buttonName,string.len("Button_pipei_")+1))
        if idx == 6 then
            local retValue = self:checkLevelDistance(31) 
            if retValue ~= "" then
                cp.getManager("ViewManager").gameTip(retValue)
                return
            end
        end

        cp.getUserData("UserMenPai"):setValue("current_fight_List",{})
        cp.getUserData("UserMenPai"):setValue("fight_list_cache",{})
        cp.getUserData("UserMenPai"):setValue("fight_grade",idx)
        local req = {}
		req.grade = idx
        self:doSendSocket(cp.getConst("ProtoConst").GangRankRefreshReq, req)

    end
end



function MenPaiPlace:initzhiwei()
    
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local career = major_roleAtt.career
    for i=1,7 do
        local titleData = cp.getManager("ConfigManager").getItemByKey("Title", career .. "_" .. i)
        local name = titleData:getValue("Title")
        self.uiList[i].Text_zhiwei:setString(name)
    end

end

function MenPaiPlace:refreshAllName()
    local rankInfoList = cp.getUserData("UserMenPai"):getValue("rankInfoList")
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local gangRank = major_roleAtt.gangRank
    -- local npcNames = require("cp.config.manual.GangNpcName" .. major_roleAtt.career)

    --伺服器下發的數據，前5層全發，第6層3個，第七層3個，1+2+4+8+15+3+3
    --但是客戶端的真傳弟子只顯示前3名
    for i=1,27 do
        local rankInfo = nil
        local idx_list = {[20] = 31, [21] = 32, [22] = 33, [24] = 34, [25] = 35, [26] = 36}
        if i >= 19  then
            if i== 19 or i == 23 or i == 27 then
                --不做處理
            else
                rankInfo = rankInfoList[idx_list[i]]
            end
        else
            rankInfo = rankInfoList[i]
        end
        if rankInfo then
            
            local modelId = nil
            if rankInfo.npc == 0 or string.len(rankInfo.uid) > 0 then --玩家
                if rankInfo.face ==  nil or rankInfo.face == "" then
                    modelId = cp.getManager("GDataManager"):getModelId(rankInfo["career"],rankInfo["gender"])
                    if modelId ~= nil and modelId > 0 then
                        local itemCfg2 = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
                        rankInfo.face = cp.DataUtils.getModelFace(itemCfg2:getValue("Face"))
                    end
                end
                if gangRank == rankInfo.rank then -- 自己
                    rankInfo.face = "img/model/head/" .. major_roleAtt.face .. ".png"
                    rankInfo.name = major_roleAtt.name
                else
                    rankInfo.face = "img/model/head/" .. rankInfo.face .. ".png"
                end
            end
            
            self.uiList[i].Text_name:setString(rankInfo.name)
            self.uiList[i].Image_head:loadTexture(rankInfo.face, UI_TEX_TYPE_LOCAL)
            if gangRank == rankInfo.rank then
                self:addSelfMark(self.uiList[i].Image_head)
            end
            
        end
    end

    local extra = {[19] = {name="",rank="",head=""},[23] = {name="",rank="",head=""},[27] = {name="",rank="",head=""}}

    if gangRank <= 0 or gangRank > 1530 then --未入門
        extra[19] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
        extra[23] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
        extra[27] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
    elseif gangRank >= rankInfoList[34].rank then --外門弟子
        extra[19] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
        extra[23] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
        if gangRank == rankInfoList[34].rank or gangRank == rankInfoList[35].rank or gangRank == rankInfoList[36].rank then
            extra[27] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        else
            extra[27] = {name=major_roleAtt.name,rank=tostring(gangRank),head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        end
    elseif gangRank > 30 then -- 內門弟子
        extra[19] = {name="虛位以待",rank="未進排名",head="ui_menpai_place_module19_menpaibiwu_wenhao.png"}
        if gangRank == rankInfoList[31].rank or gangRank == rankInfoList[32].rank or gangRank == rankInfoList[33].rank then
            extra[23] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        else
            extra[23] = {name=major_roleAtt.name,rank=tostring(gangRank),head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        end
        extra[27] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
    elseif gangRank > 15 then -- 真傳弟子
        if gangRank == rankInfoList[16].rank or gangRank == rankInfoList[17].rank or gangRank == rankInfoList[18].rank then
            extra[19] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        else
            extra[19] = {name=major_roleAtt.name,rank=tostring(gangRank),head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        end
        extra[23] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        extra[27] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
    elseif gangRank >= 1 then  --真傳以上
        extra[19] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        extra[23] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
        extra[27] = {name="...",rank="更多",head="ui_menpai_place_module19_menpaibiwu_gengduo.png"}
    end


    self.uiList[19].Text_name:setString(extra[19].name) 
    self.uiList[19].Text_rank:setString(extra[19].rank) 
    self.uiList[19].Image_head:loadTexture(extra[19].head, UI_TEX_TYPE_PLIST)
    self.uiList[19].Image_head:ignoreContentAdaptWithSize(true)
    self.uiList[19].Image_head:setScale( (tonumber(extra[19].rank) ~= nil) and 0.8 or 1)
    self.uiList[23].Text_name:setString(extra[23].name) 
    self.uiList[23].Text_rank:setString(extra[23].rank) 
    self.uiList[23].Image_head:loadTexture(extra[23].head, UI_TEX_TYPE_PLIST)
    self.uiList[23].Image_head:ignoreContentAdaptWithSize(true)
    self.uiList[23].Image_head:setScale( (tonumber(extra[19].rank) ~= nil) and 0.8 or 1)
    self.uiList[27].Text_name:setString(extra[27].name) 
    self.uiList[27].Text_rank:setString(extra[27].rank) 
    self.uiList[27].Image_head:loadTexture(extra[27].head, UI_TEX_TYPE_PLIST)
    self.uiList[27].Image_head:ignoreContentAdaptWithSize(true)
    self.uiList[27].Image_head:setScale( (tonumber(extra[19].rank) ~= nil) and 0.85 or 1)

    local idx = 0
    if extra[19].name == major_roleAtt.name then
        idx = 19
    elseif extra[23].name == major_roleAtt.name then
        idx = 23
    elseif extra[27].name == major_roleAtt.name then
        idx = 27
    end
    if idx > 0 then
        local headFile =  "img/model/head/" .. major_roleAtt.face .. ".png" 
        self.uiList[idx].Image_head:loadTexture(headFile, UI_TEX_TYPE_LOCAL)
        self.uiList[idx].Image_head:setScale(idx == 27 and 0.8 or 0.8)
        self:addSelfMark(self.uiList[idx].Image_head)
    end
end

function MenPaiPlace:addSelfMark(parent)
    if self.Image_head_selected ~= nil then
        self.Image_head_selected:removeFromParent()
    end
      
    local sz = parent:getContentSize()
    self.Image_head_selected = ccui.ImageView:create()
    self.Image_head_selected:ignoreContentAdaptWithSize(true)
    self.Image_head_selected:loadTexture("ui_menpai_place_module19_menpaibiwu_kuang.png", ccui.TextureResType.plistType)  
    parent:addChild(self.Image_head_selected)
    self.Image_head_selected:setAnchorPoint(cc.p(0.5,0.5))
    self.Image_head_selected:setPosition(cc.p(sz.width/2,sz.height/2))
    self.Image_head_selected:setVisible(true)
    local scale = parent:getScale()
    self.Image_head_selected:setScale(1/scale)
end

function MenPaiPlace:setCloseCallBack(cb)
    self.closeCallBack = cb
end


function MenPaiPlace:checkLevelDistance(rank)
	-- 你還沒有成為“*”！
	local retValue = ""
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local canFight = true
	if rank == 1 or rank == 2 or rank == 3 then
		if major_roleAtt.gangRank >= 8 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【鎮派高手】！"
		end
	elseif rank >= 4 and rank <= 7 then
		if major_roleAtt.gangRank >= 16 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【天下行走】！"
		end
	elseif rank >= 8 and rank <= 15 then
		if major_roleAtt.gangRank >= 31 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【真傳弟子】！"  
		end
	elseif rank >= 16 and rank <= 30 then
		if major_roleAtt.gangRank > 530 or major_roleAtt.gangRank == 0 then
			canFight = false
			retValue = "你還沒有成為【內門弟子】！"
		end
	elseif rank >= 31 and rank <= 530 then
		if major_roleAtt.gangRank > 1530 or major_roleAtt.gangRank == 0  then
			canFight = false
			retValue = "你還沒有成為【外門弟子】！"
		end
	end

	return retValue
end


function MenPaiPlace:generateSelfRankInfo()
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local fashionData = cp.getUserData("UserRole"):getValue("fashion_data")

    local info = {}
    info.npc = 0
    info.uid = major_roleAtt.account
    info.rank = major_roleAtt.gangRank
    info.name = major_roleAtt.name
    info.fight = major_roleAtt.fight
    info.level = major_roleAtt.level
    info.career = major_roleAtt.career
    info.gender = major_roleAtt.gender
    info.face = major_roleAtt.face
    info.fashionid = fashionData.use or 0
    
    return info
end

function MenPaiPlace:showSelfRankInfoUI()

    if self.MenPaiMockFights then
        self.MenPaiMockFights:removeFromParent()
        self.MenPaiMockFights = nil
    end

    local curInfoList = {}
    local selfRankInfo = self:generateSelfRankInfo()
    table.insert(curInfoList,selfRankInfo)
    cp.getUserData("UserMenPai"):setValue("current_fight_List", curInfoList)
    
    local openInfo = {grade = 0}
    local MenPaiMockFights = require("cp.view.scene.world.menpai.MenPaiMockFights"):create(openInfo) 
    self:addChild(MenPaiMockFights)
    MenPaiMockFights:setCloseCallBack(
        function(backType)
            self.MenPaiMockFights:removeFromParent()
            self.MenPaiMockFights = nil
        end
    )
    self.MenPaiMockFights = MenPaiMockFights
end

return MenPaiPlace
