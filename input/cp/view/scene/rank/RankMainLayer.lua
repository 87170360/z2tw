local BLayer = require "cp.view.ui.base.BLayer"
local RankMainLayer = class("RankMainLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

local rankNameList = {
    "戰力", "財富", "層數", "等級", "地位"
}

local rankImgList = {
    "ui_rank_module65_pata_7.png",
    "ui_rank_module99_fengyunbang_14.png",
    "ui_rank_module99_fengyunbang_15.png",
    "ui_rank_module99_fengyunbang_16.png",
    "ui_rank_module99_fengyunbang_17.png",
}

function RankMainLayer:create(index)
    local scene = RankMainLayer.new(index)
    return scene
end

function RankMainLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
        ["GetRankListRsp"] = function(data)
            self.index = data.type
            self.rankList = data.player_list
            self.my_rank = data.my_rank
            self.my_value = data.my_value
            self:updateRankMainView()
		end,
		--查看玩家訊息返回
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
    }
end

--初始化界面，以及設定界面元素標籤
function RankMainLayer:onInitView(index)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_rank/uicsb_rank_main.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.height = 60
    self.index = index
    self.rankList = {}
    self.my_rank = 0
    self.my_value = 0

    local childConfig = {
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_2.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank1"] = {name = "Button_Rank1", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank2"] = {name = "Button_Rank2", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank3"] = {name = "Button_Rank3", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank4"] = {name = "Button_Rank4", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rank5"] = {name = "Button_Rank5", click="onBtnClick"},
		["Panel_root.Image_1.Image_Rank1"] = {name = "Image_Rank1"},
		["Panel_root.Image_1.Image_Rank2"] = {name = "Image_Rank2"},
		["Panel_root.Image_1.Image_Rank3"] = {name = "Image_Rank3"},
		["Panel_root.Image_1.Image_RankHead"] = {name = "Image_RankHead"},
		["Panel_root.Image_1.Image_RankModel"] = {name = "Image_RankModel"},
		["Panel_root.Image_1.ScrollView_Rank"] = {name = "ScrollView_Rank"},
		["Panel_root.Image_1.Image_MyRank"] = {name = "Image_MyRank"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.ScrollView_Rank, self.Image_1})
    ccui.Helper:doLayout(self.rootView)
    self.ScrollView_Rank:setScrollBarEnabled(false)
    self.Image_RankHead:getChildByName("Text_RankValue"):setString(rankNameList[self.index])
    self.Image_Rank1:setVisible(false)
    self.Image_Rank2:setVisible(false)
    self.Image_Rank3:setVisible(false)
    self.modelList = {self.Image_Rank1, self.Image_Rank2, self.Image_Rank3}
    
    local req = {}
    req.type = self.index
    self:doSendSocket(cp.getConst("ProtoConst").GetRankListReq, req)
end

function RankMainLayer:updateRankMainView()
    local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    self.innerHeight = self.height*(#self.rankList - 3)
    local size = self.ScrollView_Rank:getSize()
    if self.innerHeight < size.height then
        self.innerHeight = size.height
    end
    self.ScrollView_Rank:setInnerContainerSize(cc.size(512, self.innerHeight))

    for i, rankInfo in ipairs(self.rankList) do
        self:updateOneRankView(i, rankInfo)
    end

    for i=#self.rankList+1, #self.modelList do
        self.modelList[i]:setVisible(false)
    end
    self.Image_RankHead:getChildByName("Text_RankValue"):setString(rankNameList[self.index])
    self:onButtonClicked("Button_Rank"..self.index)
    if self.my_rank == 0 then
        self.Image_MyRank:getChildByName("Text_Rank"):setString("未上榜")
    else
        self.Image_MyRank:getChildByName("Text_Rank"):setString(self.my_rank..".")
    end
    self.Image_MyRank:getChildByName("Text_Value"):setString(self.my_value)
    self:formatValueInfo(self.my_value, roleAtt.career, self.Image_MyRank:getChildByName("Text_Value"))
    self.Image_MyRank:getChildByName("Text_Name"):setString(roleAtt.name)
end

function RankMainLayer:formatValueInfo(value, career, txtValue)
    if self.index == 1 then
        txtValue:setString(value)
    elseif self.index == 2 then
        txtValue:setString(value)
    elseif self.index == 3 then
        txtValue:setString(value.."層")
    elseif self.index == 4 then
        txtValue:setString("LV."..value)
    elseif self.index == 5 then
        local rank = tonumber(value)
        if rank > 0 and rank <= 7 then
            local titleData = cp.getManager("ConfigManager").getItemByKey("Title", career .. "_" .. value)
            local name = titleData:getValue("Title")
            txtValue:setString(name)
        else
            local gangEntry = cp.getManager("ConfigManager").getItemByKey("GangEnhance", career)
            local place = cp.getManager("GDataManager").getRankPlace(rank)
            local title = ""
            if place == 4 then
                title = "天下行走"
            elseif place == 5 then
                title = "真傳弟子"
            elseif place == 6 then
                title = "內門弟子"
            elseif place == 7 then
                title = "外門弟子"
            end

            txtValue:setString(gangEntry:getValue("Name")..title)
        end
    end
end

function RankMainLayer:updateOneRankView(i, rankInfo)
    local model = self.modelList[i]
    if model == nil then
        model = self.Image_RankModel:clone()
        model:setName("Image_Rank"..i)
        model:addTo(self.ScrollView_Rank)
        model:getChildByName("Button_Click"):setVisible(true)
        self.modelList[i] = model
    end

    if i > 3 then
        model:setPosition(256, self.innerHeight - self.height / 2 - (i-4)*self.height)
        if i%2 == 1 then
            model:loadTexture("ui_arena_module58__bwlt_12.png", ccui.TextureResType.plistType)
        else
            model:loadTexture("ui_arena_module58__bwlt_8.png", ccui.TextureResType.plistType)
        end
    else
        local btnGift = model:getChildByName("Button_Gift")
        cp.getManager("ViewManager").initButton(btnGift, function()
            local cfgItem = cp.getManager("GDataManager").GetRankListAward(self.index, i)
            local itemList = cp.getUtils("DataUtils").split(cfgItem:getValue("ItemList"), ";=")
            local signRewardLayer = require("cp.view.scene.activity.ActivityRewardPreviewLayer"):create(2, itemList)
            self:addChild(signRewardLayer, 100)
        end)
    end

    model:setVisible(true)
    local txtName = model:getChildByName("Text_Name")
    local txtRankValue = model:getChildByName("Text_RankValue")
    local btnClick = model:getChildByName("Button_Click")

    cp.getManager("ViewManager").initButton(btnClick, function()
		local req = {}
		req.roleID = rankInfo.id
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
    end)

    txtName:setString(rankInfo.name)
    self:formatValueInfo(rankInfo.extra, rankInfo.career, txtRankValue)

    if i <= 3 then
        local imgIcon = model:getChildByName("Image_Icon")
        if self.index == 2 then
            imgIcon:setVisible(true)
        else
            imgIcon:setVisible(false)
        end
        local imgModel = model:getChildByName("Image_Model")
        local modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", rankInfo.model)
        imgModel:loadTexture(modelConfig:getValue("HalfDraw"))
        local imgType = model:getChildByName("Image_Type")
        if self.index == 1 then
            imgType:setSize(cc.size(70, 60))
        else
            imgType:setSize(cc.size(71, 71))
        end
        imgType:loadTexture(rankImgList[self.index], ccui.TextureResType.plistType)
        local txtGuild = model:getChildByName("Text_Guild")
        local btnGift = model:getChildByName("Button_Gift")

        if rankInfo.guild == "" then
            txtGuild:setString("幫派：無")
        else
            txtGuild:setString("幫派："..rankInfo.guild)
        end
    else
        local txtRank = model:getChildByName("Text_Rank")
        txtRank:setString(i..".")
    end
end

function RankMainLayer:onButtonClicked(nodeName)
    for i=1, 5 do
        local name = "Button_Rank"..i
        local btn = self[name]
        if name == nodeName then
            btn:setEnabled(false)
            self.index = i
        else
            btn:setEnabled(true)
        end
    end
end

function RankMainLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Back" then
        self:removeFromParent()
    else
        self:onButtonClicked(nodeName)
        local req = {}
        req.type = self.index
        self:doSendSocket(cp.getConst("ProtoConst").GetRankListReq, req)
	end
end

function RankMainLayer:onEnterScene()
    self:updateRankMainView()
end

function RankMainLayer:onExitScene()
end

return RankMainLayer