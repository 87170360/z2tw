local BLayer = require "cp.view.ui.base.BLayer"
local ChallengeStory = class("ChallengeStory",BLayer)

function ChallengeStory:create(type, id, difficulty)
	local layer = ChallengeStory.new(type, id, difficulty)
	layer.combat_type = type  --戰鬥類型，(1為章節模式 2善惡事件模式 3祕境副本模式 4門派進階挑戰)
	layer.id = id
	layer.difficulty = difficulty
	return layer
end

function ChallengeStory:initListEvent()
	self.listListeners = {
        --進入戰鬥消息返回
		[cp.getConst("EventConst").EnterStoryLevelRsp] = function(data)
			
			if data.result == 0 then
				local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
				local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
				if cur_guide_module_name == "character" and cur_step >= 27 then 
					cp.getManager("GDataManager"):finishNewGuideName(cur_guide_module_name)
				end

				cp.getUserData("UserCombat"):resetFightInfo()
				cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
				cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
				if self.combat_type == cp.getConst("CombatConst").CombatType_Story then
					-- cp.getManager("PopupManager"):removePopup(self)
					if self.closeCallBack ~= nil then
						self.closeCallBack("TiaoZhan")
					end
				end
			elseif data.result == 2 then
				self:fightTimesNotEnough() --困難本每天有挑戰次數限制
			end

		end,

		--重置掃蕩次數或挑戰次數返回
		[cp.getConst("EventConst").ResetStoryRsp] = function(data)
			self:updateSaodangTimes()
		end,

        --掃蕩協議返回掃蕩結果
		[cp.getConst("EventConst").SweepStoryRsp] = function(data)
			if data.result == 0 then
				self:openSweepResultUI(data.data_list)
				self:updateSaodangTimes()
			elseif data.result == 1 then
				self:physicalNotEnough()
			elseif data.result == 2 then
				self:fightTimesNotEnough()  --困難本每天有挑戰次數限制
			elseif data.result == 3 then
				-- //1:體力不足,2:挑戰次數不足,3:前置關卡未通過,4:掃蕩次數不足
				local tips = {"體力不足","挑戰次數不足","關卡尚未通過","掃蕩次數不足" }
				cp.getManager("ViewManager").gameTip(tips[data.result])	
			elseif data.result == 4 then
				self:saodangTimesNotEnough()
			end
			
		end,

		--開啟祕境挑戰返回
		[cp.getConst("EventConst").StartMijingRsp] = function(data)
			self:gotoMijingFight(data)
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "ChallengeStory" then
				if evt.guide_name == "story" or evt.guide_name == "character" or evt.guide_name == "wuxue_use" or evt.guide_name == "wuxue_pos_change" then
					if evt.target_name == "Button_tiaozhan" then
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
                        --此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
                        local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                        evt.ret = finger_info
                    end
				end
			end
		end,

		--新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "ChallengeStory" then
				if evt.guide_name == "story"  or evt.guide_name == "character" or evt.guide_name == "wuxue_use" or evt.guide_name == "wuxue_pos_change" then
					if evt.target_name == "Button_tiaozhan" then
                        self:onButtonClick(self[evt.target_name])
                    end
				end
			end
		end,
		
		--俠客行挑戰5次返回
		[cp.getConst("EventConst").HeroStorySweepRsp] = function(data)
			self:updateVigor()

		end,

		--俠客行挑戰1次返回
		[cp.getConst("EventConst").HeroStoryChallengeRsp] = function(data)
			self:updateVigor()
		
			local rewardList = {} 
			rewardList.item_list = {}
			rewardList.currency_list = {}
			if data.award ~= nil and next(data.award) ~= nil then
				for i=1,table.nums(data.award) do
					table.insert(rewardList.item_list,{item_id = data.award[i].id,item_num = data.award[i].num})
				end
			end
			cp.getUserData("UserCombat"):setCombatReward(rewardList)
			
			-- cp.getUserData("UserCombat"):setCombatResult(data.result and 1 or 2)

			cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)

		end,
	}

end

function ChallengeStory:openSweepResultUI(reward_list)
	log("ChallengeStory:openSweepResultUI  11111")
    if self.SweepStory == nil then
        local SweepStory = require("cp.view.scene.world.challenge.SweepStory"):create()
        
        -- 帶參數返回，參數(0:挑戰 1:掃蕩1次 2:掃蕩3次 3:關閉)
        local function callback(type)
            log("type = " .. tostring(type))
            if type == 3 then
                self.SweepStory:removeFromParent()
                self.SweepStory = nil
            elseif type == 2 then
                local hard_level = cp.getGameData("GameChallenge"):getValue("hard_level")
                local times = hard_level == 1 and 3 or 10
                cp.getGameData("GameChallenge"):setValue("times",times)
                self:gotoSweep(times)
            elseif type == 1 then
                self:gotoSweep(1)
                cp.getGameData("GameChallenge"):setValue("times",1)
            end    
        end
        SweepStory:setCloseCallBack(callback)
        self:addChild(SweepStory,2)
		self.SweepStory = SweepStory
		log("ChallengeStory:openSweepResultUI  2222")
	end
	log("ChallengeStory:openSweepResultUI  3333")
    self.SweepStory:refreshSweepResult(reward_list)
	log("ChallengeStory:openSweepResultUI  4444")
end

-- local openInfo = {id = self.chapter*1000 + self.part, combat_type = cp.getConst("CombatConst").CombatType_Story, hard_level = 1}
-- combat_type --戰鬥類型，(1為章節 2善惡事件 3祕境副本)
function ChallengeStory:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_challenge/ui_challenge_story.csb") 
	self:addChild(self.rootView)
	self.rootView:setContentSize(display.size)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Image_2"] = {name = "Image_2"},
		
		["Panel_root.Image_bg.Panel_ui"] = {name = "Panel_ui"},
		["Panel_root.Image_bg.Panel_ui.Button_close"] = {name = "Button_close",click = "onButtonClick"},
		["Panel_root.Image_bg.Panel_ui.Image_role"] = {name = "Image_role"},
		["Panel_root.Image_bg.Panel_ui.Image_role_1"] = {name = "Image_role_1"},
		  
		["Panel_root.Image_bg.Panel_ui.Panel_wuxue_list"] = {name = "Panel_wuxue_list"},  
		["Panel_root.Image_bg.Panel_ui.Panel_jiangli_base"] = {name = "Panel_jiangli_base"}, 
		["Panel_root.Image_bg.Panel_ui.Panel_jiangli_lucky"] = {name = "Panel_jiangli_lucky"},  
		
		["Panel_root.Image_bg.Panel_ui.Node_title_1"] = {name = "Node_title_1"},
		["Panel_root.Image_bg.Panel_ui.Node_title_2"] = {name = "Node_title_2"},
		["Panel_root.Image_bg.Panel_ui.Node_title_3"] = {name = "Node_title_3"},

		["Panel_root.Image_bg.Panel_ui.Button_jina"] = {name = "Button_jina", click = "onButtonClick"},
		["Panel_root.Image_bg.Panel_ui.Button_back"] = {name = "Button_back", click = "onButtonClick"},
		
		["Panel_root.Image_bg.Panel_ui.Button_call_help"] = {name = "Button_call_help", click = "onButtonClick"},
		["Panel_root.Image_bg.Panel_ui.Button_jiejiao"] = {name = "Button_jiejiao", click = "onButtonClick"},
		["Panel_root.Image_bg.Panel_ui.Button_saodang_1"] = {name = "Button_saodang_1", click = "onButtonClick"},
        ["Panel_root.Image_bg.Panel_ui.Button_saodang_3"] = {name = "Button_saodang_3", click = "onButtonClick"},
        ["Panel_root.Image_bg.Panel_ui.Button_tiaozhan"] = {name = "Button_tiaozhan", click = "onButtonClick"},
        ["Panel_root.Image_bg.Panel_ui.Button_add"] = {name = "Button_add", click = "onButtonClick"},
		["Panel_root.Image_bg.Panel_ui.Button_tiaozhan_5"] = {name = "Button_tiaozhan_5", click = "onButtonClick"},  

		["Panel_root.Image_bg.Panel_ui.Text_fight"] = {name = "Text_fight"},  
		["Panel_root.Image_bg.Panel_ui.Text_role_texing"] = {name = "Text_role_texing"},  
		

		-- ["Panel_root.Image_bg.Panel_ui.Text_tiaozhan_cishu"] = {name = "Text_tiaozhan_cishu"},  
		-- ["Panel_root.Image_bg.Panel_ui.Text_tiaozhan_cishu_value"] = {name = "Text_tiaozhan_cishu_value"}, 
		-- ["Panel_root.Image_bg.Panel_ui.Text_saodang_cishu"] = {name = "Text_saodang_cishu"},
		-- ["Panel_root.Image_bg.Panel_ui.Text_saodang_cishu_value"] = {name = "Text_saodang_cishu_value"},
		["Panel_root.Image_bg.Panel_ui.Image_saodang_bg"] = {name = "Image_saodang_bg"},
		["Panel_root.Image_bg.Panel_ui.Image_content_bg"] = {name = "Image_content_bg"},
		["Panel_root.Image_bg.Panel_ui.Image_wuxue_bg"] = {name = "Image_wuxue_bg"},
		["Panel_root.Image_bg.Panel_ui.Image_qiecuo"] = {name = "Image_qiecuo"},  
		
        ["Panel_root.Image_bg.Panel_ui.Text_role_des"] = {name = "Text_role_des"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
end

function ChallengeStory:onEnterScene()
	self:initUI()
	

	local needGuid = false
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
    if (cur_guide_module_name == "story") or 
		(cur_guide_module_name == "character") or
		(cur_guide_module_name == "wuxue_use") or
		(cur_guide_module_name == "wuxue_pos_change") then
        needGuid = true
    end
    if needGuid  then
        local sequence = {}
        table.insert(sequence, cc.DelayTime:create(0.3))
        table.insert(sequence,cc.CallFunc:create(function()
            local info = 
			{
			  classname = "ChallengeStory",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end))
        self:runAction(cc.Sequence:create(sequence))
	end

end

function ChallengeStory:initUI()

	self.fightInfo = {}
	--重置UI
	self.Text_role_des:setString("")
	self.Text_fight:setString("")
	self.Text_role_texing:setString("")
	self.Image_role:setVisible(false)
	self.Image_role_1:setVisible(false)
	self.Image_qiecuo:setVisible(false)
	self.Panel_jiangli_lucky:setPositionY(400)
	self.Panel_jiangli_lucky:removeAllChildren()
	self.Panel_jiangli_base:removeAllChildren()
	self.Panel_wuxue_list:removeAllChildren()
	self.Button_call_help:setVisible(false)
	self.Button_jiejiao:setVisible(false)
	self.Button_jina:setVisible(false)
	self.Button_back:setVisible(false)
	self.Button_tiaozhan_5:setVisible(false)
	if self.combat_type == cp.getConst("CombatConst").CombatType_Mijing then  --祕境
		self.Button_saodang_1:setVisible(false)
		self.Button_saodang_3:setVisible(false)
		self.Button_add:setVisible(false)
		self.Panel_jiangli_lucky:setVisible(false)
		self.Node_title_3:setVisible(true)
		local Text_title = self.Node_title_3:getChildByName("Text_title")
		Text_title:setString("人物特性")
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Shane then  --善惡大俠挑戰
		self.Image_qiecuo:setVisible(true)
		self.Node_title_3:setVisible(false)
		self.Panel_jiangli_lucky:setPositionY(515)
		self.Panel_jiangli_lucky:setContentSize(cc.size(250,240))
		self.Button_call_help:setVisible(true)
		self.Button_jiejiao:setVisible(true)
		self.Button_saodang_1:setVisible(false)
		self.Button_saodang_3:setVisible(false)
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_InviteHero then  --受邀挑戰大俠
		self.Button_saodang_1:setVisible(false)
		self.Button_saodang_3:setVisible(false)
		self.Button_add:setVisible(false)
		self.Node_title_3:setVisible(false)
		self.Panel_jiangli_lucky:setVisible(false)
		self.Panel_jiangli_base:setVisible(true)
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_GuildWanted then  --幫派通緝
		self.Button_saodang_1:setVisible(false)
		self.Button_saodang_3:setVisible(false)
		self.Button_tiaozhan:setVisible(false)
		self.Button_add:setVisible(false)
		self.Panel_jiangli_lucky:setVisible(false)
		self.Node_title_3:setVisible(false)
		
		self.Panel_jiangli_base:setVisible(true)
		self.Panel_jiangli_base:setPositionY(500)
		-- self.Panel_jiangli_base:setContentSize(cc.size(250,240))

		self.Button_jina:setVisible(true)
		self.Button_back:setVisible(true)
		self.Image_qiecuo:setVisible(true)
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_HeroChallenge then  --俠客行挑戰
		local current = cp.getUserData("UserXiakexing"):getValue("current")
		self.Button_tiaozhan_5:setVisible(current > self.id)
		self.Button_tiaozhan:setPositionX(current > self.id and 475 or 340)
		self.Button_tiaozhan_5:setPositionX(165)
		self.Button_saodang_1:setVisible(false)
		self.Button_saodang_3:setVisible(false)
		self.Button_add:setVisible(false)
		self.Node_title_3:setVisible(false)
		self.Panel_jiangli_lucky:setVisible(false)
		self.Panel_jiangli_base:setVisible(true)

	end

	if self.combat_type == cp.getConst("CombatConst").CombatType_Story then --劇情模式
		self.Image_saodang_bg:setVisible(true)
		if self.difficulty == 0 then 
			self.Button_saodang_3:loadTextures("ui_story_info_module09__tzjm_saodang04.png","ui_story_info_module09__tzjm_saodang05.png","ui_story_info_module09__tzjm_saodang0 ommon/module08__jqfb_diban01.png",ccui.TextureResType.localType)
			self.Image_bg:loadTexture("img/bg/bg_common/module09__tzjm_putongbeijing01.png",ccui.TextureResType.localType)
			self.Image_2:loadTexture("ui_story_info_module09__tzjm_putongbeijing03.png",ccui.TextureResType.plistType)
			
			for i=1,3 do 
				local Image_1 = self["Node_title_" .. tostring(i)]:getChildByName("Image_1")
				Image_1:loadTexture("ui_story_info_module09__tzjm_putongbiaoti.png",ccui.TextureResType.plistType)
			end

			self.Image_content_bg:loadTexture("ui_story_info_module09__tzjm_putongbeijing04.png",ccui.TextureResType.plistType)
			self.Image_saodang_bg:loadTexture("ui_story_info_module09__tzjm_putongbeijing04.png",ccui.TextureResType.plistType)
			self.Image_wuxue_bg:loadTexture("ui_story_info_module09__tzjm_putongbeijing04.png",ccui.TextureResType.plistType)

			self.Image_saodang_bg:setScale9Enabled(true)
			self.Image_saodang_bg:setCapInsets({x = 17, y = 17, width = 1, height = 1})
			self.Image_wuxue_bg:setScale9Enabled(true)
			self.Image_wuxue_bg:setCapInsets({x = 18, y = 18, width = 1, height = 1})
			self.Image_content_bg:setScale9Enabled(true)
			self.Image_content_bg:setCapInsets({x = 18, y = 18, width = 1, height = 1})

		else --困難模式
			self.Button_saodang_3:loadTextures("ui_story_info_module09__tzjm_saodang08.png","ui_story_info_module09__tzjm_saodang06.png","ui_story_info_module09__tzjm_saodang08.png",ccui.TextureResType.plistType)  --三次
			self.Image_bg:loadTexture("img/bg/bg_common/module09__tzjm_kunnanbeijing01.png",ccui.TextureResType.localType)
			self.Image_2:loadTexture("ui_story_info_module09__tzjm_kunnanbeijing02.png",ccui.TextureResType.plistType)
			
			for i=1,3 do
				local Image_1 = self["Node_title_" .. tostring(i)]:getChildByName("Image_1")
				Image_1:loadTexture("ui_story_info_module09__tzjm_kunnanbiaoti.png",ccui.TextureResType.plistType)
			end

			self.Image_content_bg:loadTexture("ui_story_info_module09__tzjm_kunnanbeijing04.png",ccui.TextureResType.plistType)
			self.Image_saodang_bg:loadTexture("ui_story_info_module09__tzjm_kunnanbeijing05.png",ccui.TextureResType.plistType)
			self.Image_wuxue_bg:loadTexture("ui_story_info_module09__tzjm_kunnanbeijing05.png",ccui.TextureResType.plistType)

			self.Image_saodang_bg:setScale9Enabled(true)
			self.Image_saodang_bg:setCapInsets({x = 14, y = 14, width = 1, height = 1})
			-- self.Image_saodang_bg:setContentSize(cc.size(303,455))
			self.Image_wuxue_bg:setScale9Enabled(true)
			self.Image_wuxue_bg:setCapInsets({x = 14, y = 14, width = 1, height = 1})
			self.Image_content_bg:setScale9Enabled(true)
			self.Image_content_bg:setCapInsets({x = 23, y = 23, width = 1, height = 1})			

		end
	
		cp.getGameData("GameChallenge"):setValue("current_id",self.id)
		cp.getGameData("GameChallenge"):setValue("hard_level",self.difficulty)

		-- 1.掃蕩次數，挑戰次數
		self:updateSaodangTimes()
	

		-- 物品獎勵
		local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", self.id)

		local luckyReward = self.difficulty == 0 and cfgItem:getValue("NormalReward") or cfgItem:getValue("HardReward") -- 30:1:1;30:2:1  概率:物品id:物品數量
		local item_list = {}
		local arr = {}
		string.loopSplit(luckyReward,";:",arr)
		for i=1,#arr do
			table.insert(item_list,{id = tonumber(arr[i][2]), num = tonumber(arr[i][3])})
		end
		self:initItemReward(item_list)


		-- 虛擬物品獎勵
		local FixedReward = self.difficulty == 0 and cfgItem:getValue("FixedRewardNormal") or cfgItem:getValue("FixedRewardHard") -- 0;600;1000;12 元寶;銀兩;修為點;閱歷值
		local arr = {}
		string.loopSplit(FixedReward,";",arr)  -- 元寶;銀兩;修為點;閱歷值
		-- 1:銀兩 2:元寶 3：修為點(技能點) 4：領悟點 5.門派聲望值 6：俠義令 7：鐵膽令  8:體力 9：閱歷值(exp) 
		local typeList = {
			cp.getConst("GameConst").VirtualItemType.gold,
			cp.getConst("GameConst").VirtualItemType.silver,
			cp.getConst("GameConst").VirtualItemType.trainPoint,
			cp.getConst("GameConst").VirtualItemType.exp
		}

		local virtual_item = {}
		for i=1,#arr do
			local num = tonumber(arr[i])
			if num > 0 then
				table.insert(virtual_item,{type = typeList[i], num = num})
			end
		end
		self:initBaseReward(virtual_item)

		-- 關卡消耗體力
		-- local needTili = self.difficulty == 0 and 6 or 12
		-- self.Text_tiaozhan_xiaohao:setString("每次消耗 " .. tostring(needTili))


		-- npc 相關
		local NPC_str = self.difficulty == 0 and cfgItem:getValue("NPCNormal") or cfgItem:getValue("NPCHard")  -- 5;4;6
		local npc_tb = string.split(NPC_str,";")
		local npc_id = tonumber(npc_tb[#npc_tb])
		self:initNpcInfo(npc_id)

		self.fightInfo = {}
		self.fightInfo.partID = self.id
		self.fightInfo.difficut = self.difficulty
		
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Mijing then
		local mijing_id = tostring(self.id) .. "_" .. tostring(self.difficulty)
		local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
		if cfg == nil then
			return
		end

		-- 物品獎勵
		-- local items = cfg:getValue("Items")
		-- if items ~= "" then
		-- 	local item_list = {}
		-- 	local arr = {}
		-- 	string.loopSplit(items,"|-",arr)  --  itemid1-num1-weight1|itemid2-num2-weight2
			
		-- 	for i=1, table.nums(arr) do
		-- 		local itemInfo = {id = tonumber(arr[i][1]), num=1,hideName = false}
		-- 		table.insert(item_list,itemInfo)
		-- 	end
			
		-- 	self:initItemReward(item_list)
		-- end

		-- 虛擬物品獎勵 --1:銀兩 2:元寶 3：修為點(技能點) 4：領悟點 5.聲望值 6：俠義令 7：鐵膽令  8:體力 9：閱歷值(exp)  10:罪惡值(紅名)  11:幫派個人資金
		local virtual_item = {}
		local exp = cfg:getValue("Exp")
		table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.exp, num = exp})
		self:initBaseReward(virtual_item)

		-- npc 相關
		local npc_id = cfg:getValue("Npc")
		self:initNpcInfo(npc_id)
		local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameNpc", npc_id)
		if cfgItem2 ~= nil then
			local texingStr = cfgItem2:getValue("EventList")
			local strList = string.split(texingStr,";")
			local texing = ""
			if strList ~= nil and strList ~= "" and next(strList) ~= nil then
				local txtArr = {
					["300"] = "免疫刀系武學",
					["301"] = "免疫劍系武學", 
					["302"] = "免疫棍系武學",
					["303"] = "免疫奇門武學",
					["304"] = "免疫拳掌武學"
				}
				for i=1,#strList do
					if strList[i] and strList[i] ~= "" then
						texing = texing .. txtArr[strList[i]]
						if i<#strList then
							texing = texing .. "\n"
						end
					end
				end
			end
			self.Text_role_texing:setString(texing)
		end

		-- 關卡消耗體力
		local Config = cp.getManager("ConfigManager").getItemByKey("Other", "mijing_physical")
		local needTili = Config:getValue("IntValue")
		local contentTable = {
			{type="ttf", fontName="fonts/msyh.ttf", fontSize=20, text="每次消耗 " .. tostring(needTili), textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
			{type="image",filePath="ui_common_tili.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			
		}
		self.Image_saodang_bg:removeChildByName("richText")
		local richText = self:createRichText(contentTable)
		self.Image_saodang_bg:addChild(richText)
	
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Shane   --大俠挑戰
		or self.combat_type == cp.getConst("CombatConst").CombatType_InviteHero then --受邀挑戰大俠
		if self.id == nil or self.id < 0 then
			return
		end
		self.NeedGold = 0
		self.Image_saodang_bg:setVisible(false)
		local _,posY = self.Image_wuxue_bg:getPosition()
		local _,posY2 = self.Panel_wuxue_list:getPosition()
		self.Image_wuxue_bg:setPositionY(posY-20)
		self.Panel_wuxue_list:setPositionY(posY2-20)
		local Text_title = self.Node_title_2:getChildByName("Text_title")
		Text_title:setString("獎  勵")

		local cfgItem,k,_ = cp.getManager("GDataManager"):getHeroInfoByID(self.id)
		local item_list = {}
		if cfgItem then
			local AwardShow = cfgItem:getValue("AwardShow")
			local AwardShowList = string.split(AwardShow,"|") 
			local AwardStr = AwardShowList[k]
			self.NeedGold = cfgItem:getValue("Gift" .. tostring(k))
			
			local arr = {}
			string.loopSplit(AwardStr,"#-",arr)
			for i=1, table.nums(arr) do
				local itemInfo = {id = tonumber(arr[i][1]), num=tonumber(arr[i][2]),hideName = false}
				table.insert(item_list,itemInfo)
			end
		end
		self:initItemReward(item_list)

		if self.combat_type == cp.getConst("CombatConst").CombatType_InviteHero then
			local virtual_item = {}
			local AwardAtt = cfgItem:getValue("AwardAtt" .. tostring(k))
			local num = tonumber(AwardAtt)
			if num > 0 then
				table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.silver, num = num})
			end
			self:initBaseReward(virtual_item)
		end
		
		-- npc 相關
		self:initNpcInfo(self.id)
		
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_GuildWanted then --幫派通緝
		self.Image_saodang_bg:setVisible(false)

		local Text_title = self.Node_title_2:getChildByName("Text_title")
		Text_title:setString("緝拿獎勵")

		local npcInfo = nil
		local npc_list = cp.getUserData("UserGuild"):getGuildWantedInfo().npc_list
		for i=1,table.nums(npc_list) do
			if npc_list[i].id == self.id then
				npcInfo = npc_list[i]
			end
		end

		-- 0低級，1中級，2高級
		local pic = {[0] = "ui_story_info_module_bangpai_66.png", [1] = "ui_story_info_module_bangpai_65.png", [2] = "ui_story_info_module_bangpai_64.png"}
		self.Image_qiecuo:loadTexture(pic[npcInfo.level],ccui.TextureResType.plistType)

		self:initNpcInfo(npcInfo.id)

		--獲得獎勵 幫派個人資金 幫派經驗
		local GuildWantedConfig = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildWantedConfig")
		local arr = {}
		string.loopSplit(GuildWantedConfig,";:",arr)
		local rewardList = arr[npcInfo.level+1]
		
		local typeList = {
			cp.getConst("GameConst").VirtualItemType.guildGold,
			cp.getConst("GameConst").VirtualItemType.guildExp
		}
		local virtual_item = {}
		local num = tonumber(rewardList[1])
		if num > 0 then
			table.insert(virtual_item,{type = typeList[1], num = num})
		end
		num = tonumber(rewardList[2])
		if num > 0 then
			table.insert(virtual_item,{type = typeList[2], num = num})
		end

		self:initBaseReward(virtual_item)
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_HeroChallenge then  --俠客行挑戰
		local cfg = cp.getManager("ConfigManager").getItemByKey("HeroStory",self.id)
		if cfg == nil then
			return
		end

		-- 物品獎勵
		local items = cfg:getValue("AwardShow")
		local item_list = {}
		if items ~= "" then
			local arr = string.split(items,"-")  --  itemid1-itemid2-itemid3-itemid4
			for i=1, table.nums(arr) do
				local itemInfo = {id = tonumber(arr[i]), num=1,hideName = false,shoutong = true,scale=0.85}
				table.insert(item_list,itemInfo)
			end
		end
		self:initItemReward(item_list)

		-- npc 相關
		local npc_id = cfg:getValue("NPC")
		self:initNpcInfo(npc_id)

		self:updateVigor()
	end

end

function ChallengeStory:initItemReward(item_list)
	if item_list == nil or next(item_list) == nil then return end

	for i=1,table.nums(item_list) do
		
		local itemID = item_list[i].id
		local itemNum = item_list[i].num

		local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
		local itemInfo = {id = itemID, num = itemNum, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")}
		if item_list[i].scale then
			itemInfo.scale = tonumber(item_list[i].scale)
		end
		local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
		local sz = item:getContentSize()
		if i<=2 then
			item:setPosition(cc.p(i * sz.width - sz.width/2 + 5 +  35 * (i-1), 25+sz.height/2))
		else
			local delta = itemInfo.scale and 158 or 165
			item:setPosition(cc.p((i-2) * sz.width - sz.width/2 + 8 + 35 * (i-3), delta+sz.height/2))
		end
		self.Panel_jiangli_lucky:addChild(item)
	end
	self.Panel_jiangli_lucky:setVisible(true)
end

function ChallengeStory:initBaseReward(virtual_item)

	for i=1, table.nums(virtual_item) do
		local item = require("cp.view.ui.item.HuobiItem")
		local coin = item:create(virtual_item[i].type,virtual_item[i].num,true)
		self.Panel_jiangli_base:addChild(coin)
		
		if i<3 then
			coin:setPosition(130*(i-1),54)
			if table.nums(virtual_item) == 1 then --只有一個時居中顯示
				coin:setPosition(125 - 50,24)
			end
		else
			coin:setPosition(130*(i-3),0)
		end
	end
end

function ChallengeStory:initNpcInfo(npc_id)

	local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameNpc", npc_id or 0)
	if cfgItem2 == nil then
		return
	end
	local npcName = cfgItem2:getValue("Name")
	local npcDescrip = cfgItem2:getValue("Description")
	local SkillID = cfgItem2:getValue("SkillID") -- 1=1;2=1;3=1;4=1;5=1;6=1  武學id:武學等級;
	local npc_image = cfgItem2:getValue("NpcImage")
	local modelId = cfgItem2:getValue("ModelID")
	if npc_image == "" or npc_image == nil then
		local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
		npc_image = itemCfg:getValue("HalfDraw")
	end

	local Fight = cfgItem2:getValue("Fight")

	-- npc相關訊息
	self.Text_role_des:setString(npcDescrip)
	self.Text_fight:setString("戰力：" .. tostring(Fight))

	--npc圖片
	self.Image_role:loadTexture(npc_image, ccui.TextureResType.localType)
	self.Image_role:ignoreContentAdaptWithSize(true)
	self.Image_role:setVisible(true)
	self.Image_role_1:loadTexture(npc_image, ccui.TextureResType.localType)
	self.Image_role_1:ignoreContentAdaptWithSize(true)
	self.Image_role_1:setVisible(true)

	--npc武學列表
	local wuxueList = {}
	string.loopSplit(SkillID,";=",wuxueList)
	display.loadSpriteFrames("uiplist/ui_combat.plist")
	local total = table.nums(wuxueList)

	local totalWidth = self.Panel_wuxue_list:getContentSize().width
	for i=1,total do
		local wuxueId = tonumber(wuxueList[i][1])
		local wuxueLevel = tonumber(wuxueList[i][2])
		local cfgItem3 = cp.getManager("ConfigManager").getItemByKey("SkillEntry", wuxueId)
		local Name = cfgItem3:getValue("SkillName")
		local Colour = cfgItem3:getValue("Colour")
		local Icon = cfgItem3:getValue("Icon")
		local wuxueInfo = {id=wuxueId,level = wuxueLevel, Name = Name, Colour = Colour,Icon = Icon }
		
		local wuxue = require("cp.view.ui.item.SkillItem"):create(wuxueInfo)
		wuxue:setScale(1)
		local sz = wuxue:getContentSize()

		local perWidth = totalWidth/(total+1) 
		perWidth = math.max(perWidth,105)
		local startX = perWidth - sz.width/2
		startX = startX < 0 and 0 or startX
		
		wuxue:setPosition(cc.p(startX + (i-1) * perWidth -5, 18+sz.height/2))

		-- wuxue:setItemClickCallBack(function()
		-- 	local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(cfgItem3)
		-- 	self:addChild(layer, 1)
		-- end)
		self.Panel_wuxue_list:addChild(wuxue)
	end

	if self.combat_type == cp.getConst("CombatConst").CombatType_Shane   --大俠挑戰
		or self.combat_type == cp.getConst("CombatConst").CombatType_GuildWanted --幫派緝拿
		or self.combat_type == cp.getConst("CombatConst").CombatType_HeroChallenge --俠客行
		or self.combat_type == cp.getConst("CombatConst").CombatType_InviteHero then --受邀挑戰大俠
		self.fightInfo = self.fightInfo or {}
		self.fightInfo.name = npcName	
	end
end

-- 帶參數返回，參數(0:關閉 1:掃蕩1次 2:掃蕩3次 3:挑戰)
function ChallengeStory:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function ChallengeStory:onButtonClick(sender)
    local btnName = sender:getName()
    if "Button_saodang_3" == btnName then
		local hard_level = cp.getGameData("GameChallenge"):getValue("hard_level")
		local times = hard_level == 1 and 3 or 10
		
		self:gotoSweep(times)
	elseif "Button_saodang_1" == btnName then
		self:gotoSweep(1)
	elseif "Button_tiaozhan" == btnName then
		self:gotoTiaozhan()
	elseif "Button_tiaozhan_5" == btnName then
		self:gotoTiaozhan5()
	elseif "Button_call_help" == btnName then
		if self.combat_type == cp.getConst("CombatConst").CombatType_Shane then
			if self.closeCallBack ~= nil then
				self.closeCallBack("CallHelp")
			end
		end
	elseif "Button_jiejiao" == btnName then
		if self.combat_type == cp.getConst("CombatConst").CombatType_Shane then

			
			local function comfirmFunc()
				--檢測是否元寶足夠
				if cp.getManager("ViewManager").checkGoldEnough(self.NeedGold) then
					if self.closeCallBack ~= nil then
						self.closeCallBack("JieJiao")
					end
				end
			end

			local contentTable = {
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(self.NeedGold), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
				{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，請大俠喝酒，直接獲得獎勵？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			}
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
			
		end
	elseif "Button_add" == btnName then --增加挑戰次數
		--不夠時建議按鈕文字提示
	-- elseif "Button_shilipingu" == btnName then
	-- 	--建議直接顯示出來
	-- 	self:showShiLiPinGu()
	elseif "Button_jina" == btnName then
		if self.combat_type == cp.getConst("CombatConst").CombatType_GuildWanted then
			if self.closeCallBack ~= nil then
				self.closeCallBack("jina")
			end
		end
	elseif "Button_close" == btnName or "Button_back" == btnName then
		if self.closeCallBack ~= nil then
			self.closeCallBack("close")
		end
    end
end


function ChallengeStory:gotoTiaozhan()
	if self.combat_type == cp.getConst("CombatConst").CombatType_Story then
		if self.difficulty == 1 then 
			--還要檢測是否有足夠挑戰次數 (困難本才有挑戰次數的限制)
			local fight_times = cp.getUserData("UserCombat"):getChallengeCount(self.id)
			local fight_times_max = cp.getConst("CombatConst").Challenge_Count_Max 
			local left_fight_times = fight_times_max - fight_times 
			left_fight_times = math.max(left_fight_times,0)

			if left_fight_times <= 0 then
				--購買挑戰次數

				--檢測vip等級，看是否達到購買次數上限
				local challengeCountList = cp.getUserData("UserCombat"):getValue("challengeCountList")
				local curMax = cp.getUtils("DataUtils").GetVipEffect(5)
				if challengeCountList[self.id] ~= nil and challengeCountList[self.id].reset_count >= curMax then
					--彈框是否去儲值，提升vip等級
					self:needVipLevelUp()
					return
				end
				self:fightTimesNotEnough()
				return
			end
		end

		local req = {}
		req.combat_type = self.combat_type
		req.id = self.id
		req.difficulty = self.difficulty
		
		self:doSendSocket(cp.getConst("ProtoConst").EnterStoryLevelReq, req)
		cp.getManager("GDataManager"):setFightDelay(true)
		cp.getUserData("UserRole"):setValue("major_roleAtt_old", nil)
		cp.getGameData("GameChallenge"):setValue("times",1)
		
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Mijing then
		local req = {}
		req.id = (self.id) .. "_" .. tostring(self.difficulty)
		self:doSendSocket(cp.getConst("ProtoConst").StartMijingReq, req)
		cp.getUserData("UserMijing"):setValue("fight_id",req.id )
		cp.getManager("GDataManager"):setFightDelay(true)

	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Shane
		or self.combat_type == cp.getConst("CombatConst").CombatType_InviteHero then
		if self.closeCallBack ~= nil then
			self.closeCallBack("Shane_TiaoZhan")
		end
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_HeroChallenge then
		--判斷精力是否足夠
		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local vigor = major_roleAtt.vigor
		local Config = cp.getManager("ConfigManager").getItemByKey("Other", "consume_vigor")
		local consume_vigor = Config:getValue("IntValue")
	
		if vigor < consume_vigor then
			cp.getManager("ViewManager").gameTip("精力值不足")
			return
		end
		
		local req = {}
		req.id = self.id
		self:doSendSocket(cp.getConst("ProtoConst").HeroStoryChallengeReq, req)
		cp.getUserData("UserMijing"):setValue("fight_id",req.id )
	end
end

--發送掃蕩協議
function ChallengeStory:gotoSweep(times)
	
	--檢測是否有足夠的掃蕩次數
	local saodang_times = cp.getUserData("UserCombat"):getValue("sweep_count")
	local buy_count = cp.getUserData("UserCombat"):getValue("buy_count")
	local saodang_times_max = cp.getUtils("DataUtils").GetVipEffect(0)
	local left_saodang_times = saodang_times_max + buy_count - saodang_times
	left_saodang_times = math.max(left_saodang_times,0)
	if left_saodang_times < times then
		--購買掃蕩次數
		self:saodangTimesNotEnough()
		return
	end

	if self.difficulty == 1 then 
		--還要檢測是否有足夠挑戰次數 (困難本才有挑戰次數的限制)
		local fight_times = cp.getUserData("UserCombat"):getChallengeCount(self.id)
		local fight_times_max = cp.getConst("CombatConst").Challenge_Count_Max 
		local left_fight_times = fight_times_max - fight_times 
		left_fight_times = math.max(left_fight_times,0)

		if left_fight_times < times then
			if left_fight_times > 0 then
				-- 當前挑戰次數僅為 2 次，是否進行掃蕩 2 次？
				local function comfirmFunc()
					cp.getGameData("GameChallenge"):setValue("times", left_fight_times)
					local req = {}
					req.id = self.id
					req.difficulty = self.difficulty
					req.count = left_fight_times
				
					self:doSendSocket(cp.getConst("ProtoConst").SweepStoryReq, req)
					cp.getManager("GDataManager"):setFightDelay(true)
				end
			
				local contentTable = {
					{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="當前挑戰次數僅為", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
					{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(left_fight_times), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
					{type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text=" 次，是否進行掃蕩 ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
					{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(left_fight_times), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
					{type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text=" 次？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
				}
				cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
				return
			else
				
				--檢測vip等級，看是否達到購買次數上限
				local challengeCountList = cp.getUserData("UserCombat"):getValue("challengeCountList")
				local curMax = cp.getUtils("DataUtils").GetVipEffect(5)
				if challengeCountList[self.id] ~= nil and challengeCountList[self.id].reset_count >= curMax then
					--彈框是否去儲值，提升vip等級
					self:needVipLevelUp()
					return
				end

				--購買挑戰次數
				self:fightTimesNotEnough()
				return
			end
		end
	end

	--次數足夠，請求掃蕩
	cp.getGameData("GameChallenge"):setValue("times",times)
	local req = {}
    req.id = self.id
    req.difficulty = self.difficulty
    req.count = times

	self:doSendSocket(cp.getConst("ProtoConst").SweepStoryReq, req)
	cp.getManager("GDataManager"):setFightDelay(true)
	
end

-- function ChallengeStory:showShiLiPinGu()
-- 	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
-- 	local selfZhanli = majorRole.fight -- 戰力

-- end

--祕境挑戰，關閉挑戰界面並進入戰鬥場景
function ChallengeStory:gotoMijingFight(data)
	dump(data)
	local rewardList = {} 
	rewardList.item_list = {}
	rewardList.currency_list = {}
	table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.exp, num = data.exp})
	if data.items ~= nil and next(data.items) ~= nil then
		for i=1,table.nums(data.items) do
			table.insert(rewardList.item_list,{item_id = data.items[i].id,item_num = data.items[i].num})
		end
	end
	if data.exItems ~= nil and next(data.exItems) ~= nil then
		for i=1,table.nums(data.exItems) do
			table.insert(rewardList.item_list,{item_id = data.exItems[i].id,item_num = data.exItems[i].num, isActive = true})
		end
	end

	cp.getUserData("UserCombat"):setCombatReward(rewardList)
	cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
	if self.closeCallBack ~= nil then
		self.closeCallBack("mijing_fight") --祕境挑戰
	end
end

function ChallengeStory:updateSaodangTimes()

	local fight_times = cp.getUserData("UserCombat"):getChallengeCount(self.id)
	local fight_times_max = cp.getConst("CombatConst").Challenge_Count_Max 
	
	local saodang_times = cp.getUserData("UserCombat"):getValue("sweep_count")
	local buy_count = cp.getUserData("UserCombat"):getValue("buy_count")
	local saodang_times_max = cp.getUtils("DataUtils").GetVipEffect(0)


	local left_fight_times = fight_times_max - fight_times 
	left_fight_times = math.max(left_fight_times,0)

	local left_saodang_times = saodang_times_max + buy_count - saodang_times
	left_saodang_times = math.max(left_saodang_times,0)
	
	self.Button_add:setVisible(false)-- self.difficulty == 1)

	-- 關卡消耗體力
	local needTili = 0
	if self.combat_type == cp.getConst("CombatConst").CombatType_Story then
		needTili = self.difficulty == 0 and 6 or 12
	elseif self.combat_type == cp.getConst("CombatConst").CombatType_Mijing then
		local Config = cp.getManager("ConfigManager").getItemByKey("Other", "mijing_physical")
		needTili = Config:getValue("IntValue")
	end

	local color1 = left_saodang_times > 0 and cc.c4b(255,255,255,255) or cp.getConst("GameConst").QualityTextColor[6]  --白色或紅色
	local color2 = left_fight_times > 0 and cc.c4b(255,255,255,255) or cp.getConst("GameConst").QualityTextColor[6]  --白色或紅色
	local contentTable = {
		{type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text="每日免費掃蕩次數", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
		{type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text=tostring(left_saodang_times), textColor=color1, outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
        {type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text="/" .. tostring(saodang_times_max) .. ",每次消耗 " .. tostring(needTili), textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
		{type="image",filePath="ui_common_tili.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		
	}
	if self.difficulty == 1 then
		local info1 = {type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text=" 剩餘挑戰次數", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"}
		table.insert(contentTable,info1)
		local info2 = {type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text=tostring(left_fight_times), textColor=color2, outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"}
		table.insert(contentTable,info2) 
		local info3 = {type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text="/" .. tostring(fight_times_max) , textColor=color2, outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"}
		table.insert(contentTable,info3)
	end
	self.Image_saodang_bg:removeChildByName("richText")
	local richText = self:createRichText(contentTable)
    self.Image_saodang_bg:addChild(richText)
end

function ChallengeStory:createRichText(contentTable)
	
	local richText = require("cp.view.ui.base.RichText"):create()
	
	
    richText:setContentSize(cc.size(600,40))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(300,20))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
	-- richText:setLineGap(1)
	richText:setName("richText")

	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	richText:formatText()
    -- local tsize = richText:getTextSize()
    -- richText:setContentSize(cc.size(width,math.max(height,tsize.height)))
    return richText
end


function ChallengeStory:getDescription()
    return "ChallengeStory"
end

function ChallengeStory:fightTimesNotEnough()
	local BuyTiaoZhanCost = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BuyTiaoZhanCost")

	local function comfirmFunc()
		--檢測是否元寶足夠
		if cp.getManager("ViewManager").checkGoldEnough(BuyTiaoZhanCost) then
			local req = {mode = 1, story_id=self.id}
			self:doSendSocket(cp.getConst("ProtoConst").ResetStoryReq, req) --重置挑戰次數
		end
	end

	
	local contentTable = {
		{type="ttf", fontName="fonts/msyh.ttf", fontSize=24, text="當前關卡挑戰次數不足，是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(BuyTiaoZhanCost), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		{type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text="，購買3次挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
	}
	cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
end

function ChallengeStory:physicalNotEnough()

	cp.getManager("ViewManager").showBuyPhysicalUI()
end


function ChallengeStory:saodangTimesNotEnough()
	--購買掃蕩次數
	local BuySaodangCost = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BuySaodangCost")
	local BuySaodangTimes = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BuySaodangTimes")
	local saodang_times_max = cp.getUtils("DataUtils").GetVipEffect(0)
	local function comfirmFunc()
		--檢測是否元寶足夠
		if cp.getManager("ViewManager").checkGoldEnough(BuySaodangCost) then
			local req = {mode = 0, story_id=0}
			self:doSendSocket(cp.getConst("ProtoConst").ResetStoryReq, req) --重置掃蕩次數
		end
	end

	local contentTable = {
		{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="提升VIP等級可獲得更多免費掃蕩次數，是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(BuySaodangCost), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		{type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text="，購買".. tostring(BuySaodangTimes) .. "次掃蕩次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
	}
	cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
end

--需要提升VIP等級提示
function ChallengeStory:needVipLevelUp()

	local vip = cp.getUserData("UserVip"):getValue("level")
	if vip >= 15 then
		local str = "今日可購買次數已達上限。"
		cp.getManager("ViewManager").gameTip(str)
		return
	end
	local function comfirmFunc()
		cp.getManager("ViewManager").showRechargeUI()
	end

	local contentTable = "您的可購買挑戰次數不足，\n提升VIP等級即可增加購買次數。\n是否立即前往儲值界面，提升VIP等級？"
	cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
end


--俠客行挑戰5次
function ChallengeStory:gotoTiaozhan5()
	if self.combat_type == cp.getConst("CombatConst").CombatType_HeroChallenge then
		--判斷精力是否足夠
		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local vigor = major_roleAtt.vigor
		local Config = cp.getManager("ConfigManager").getItemByKey("Other", "consume_vigor")
		local consume_vigor = Config:getValue("IntValue")
	
		if vigor < consume_vigor then
			cp.getManager("ViewManager").gameTip("精力值不足")
			return
		end

		local req = {}
		req.id = self.id
		req.num = 5
		self:doSendSocket(cp.getConst("ProtoConst").HeroStorySweepReq, req)
		cp.getUserData("UserMijing"):setValue("fight_id",req.id )
	end
end

--俠客行挑戰界面更新精力訊息
function ChallengeStory:updateVigor()

	if self.combat_type ~= cp.getConst("CombatConst").CombatType_HeroChallenge then
		return	
	end

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local vigor = major_roleAtt.vigor

	local Config = cp.getManager("ConfigManager").getItemByKey("Other", "consume_vigor")
	local consume_vigor = Config:getValue("IntValue")
	Config = cp.getManager("ConfigManager").getItemByKey("Other", "init_vigor")
	local init_vigor = Config:getValue("IntValue")
	
	self.Button_add:setVisible(false)

	local color1 = major_roleAtt.vigor > 0 and cc.c4b(255,255,255,255) or cp.getConst("GameConst").QualityTextColor[6]  --白色或紅色
	local contentTable = {
		{type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text="當前精力值", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
		{type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text=tostring(major_roleAtt.vigor), textColor=color1, outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
        {type="ttf", fontName="fonts/msyh.ttf", fontSize=18, text="/" .. tostring(init_vigor) .. ",每次消耗 " .. tostring(consume_vigor), textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2,verticalAlign="middle"},
		-- {type="image",filePath="ui_common_tili.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
		
	}
	self.Image_saodang_bg:removeChildByName("richText")
	local richText = self:createRichText(contentTable)
    self.Image_saodang_bg:addChild(richText)
end

return ChallengeStory
