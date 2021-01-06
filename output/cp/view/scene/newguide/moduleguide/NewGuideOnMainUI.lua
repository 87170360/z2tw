local BLayer = require "cp.view.ui.base.BLayer"
local NewGuideOnMainUI = class("NewGuideOnMainUI",BLayer)

function NewGuideOnMainUI:create(open_info)
    local layer = NewGuideOnMainUI.new(open_info)
    return layer
end


function NewGuideOnMainUI:initListEvent()
    self.listListeners = {

		[cp.getConst("EventConst").UseEquipRsp] = function(evt)
			local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
			if self.open_info.guide_name == "character" then --角色穿裝備並強化
				if cur_step == 9 then
					self:Next()
				end
			elseif self.open_info.guide_name == "equip" then --傳承熔鍊
				if cur_step == 11 or cur_step == 19 then
					self:Next()
				end
			end
		end,

		--門派武學界面打開通知
		[cp.getConst("EventConst").enter_layer_notice] = function(evt)
		
			if evt.classname == "MenPaiSkillLayer" then 
				self.open_info.pos = evt.pos
				self:Next()
			end
			
			if evt.classname == "JiangHuLayer" then
				if self.open_info.guide_name == "story" then
					local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
					if cur_step >= 9 then --戰鬥返回,不更新步驟
						return
					end
				end
				self:Next()
			end

			if evt.classname == "ChapterPartLayer" then
				if self.open_info.guide_name == "story" then
					local step_skip_mode = cp.getGameData("GameNewGuide"):getValue("step_skip_mode") 
					local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
					if cur_step >= 9 and step_skip_mode == 0 then --戰鬥返回,不更新步驟
						return
					end
				end
				self:Next()
				cp.getGameData("GameNewGuide"):setValue("step_skip_mode",0) 
			end

			if evt.classname == "SkillDetailNoneLayer" or 
				evt.classname == "SkillSummaryLayer" or
				evt.classname == "SkillDetailLearnLayer" or
				evt.classname == "SkillSectSelect" or
				evt.classname == "LilianMainLayer" or
				evt.classname == "LilianDetailLayer" or
				evt.classname == "LilianResultLayer" or
				evt.classname == "ChallengeStory" or
				evt.classname == "MajorRolePublic" or
				evt.classname == "SelectEquipTip" or
				evt.classname == "WeaponTip" or
				evt.classname == "ItemTip" or
				evt.classname == "EquipOperateLayer" or
				evt.classname == "MajorLayer" or
				evt.classname == "MajorLeft" or
				evt.classname == "MajorPackage" or
				evt.classname == "LotteryHouseLayer" or
				evt.classname == "LotteryItemLayer" or 
				evt.classname == "MailListLayer" or 
				evt.classname == "MailDetailLayer" or 
				evt.classname == "GameRewardReceiveUI" or 
				evt.classname == "MajorRoleSelf" or
				evt.classname == "RiverEventListLayer" or
				evt.classname == "RiverEventAcceptUI" or
				evt.classname == "RiverMainLayer" or
				-- evt.classname == "WeaponTip" or
				evt.classname == "MenPaiMainLayer" then 
				self:Next()
			end
			
		end,
    }
end

function NewGuideOnMainUI:resetGuideInfo(open_info)
	
	open_info.stencil_mode = "image"

	self.open_info = open_info
	if self.NewGuideLayer then
		
		self.NewGuideLayer:resetGuideInfo(open_info)
		if open_info.cancelCallBack ~= nil and type(open_info.cancelCallBack) == "function" then
			self.NewGuideLayer:setCancelGuideCallBack(open_info.cancelCallBack)
		end
	end
end

function NewGuideOnMainUI:onInitView(open_info)
	self.open_info = open_info
	open_info.stencil_mode = "image"
    
    local NewGuideLayer = require("cp.view.scene.newguide.NewGuideLayer"):create(open_info)
	self:addChild(NewGuideLayer)
	
	local function onTouchFunc()
		self:Next()
	end
	NewGuideLayer:setTouchCallBack(onTouchFunc)
	
	if open_info.cancelCallBack ~= nil and type(open_info.cancelCallBack) == "function" then
        NewGuideLayer:setCancelGuideCallBack(open_info.cancelCallBack)
	end
    self.NewGuideLayer = NewGuideLayer
   
	-- local layout = ccui.Layout:create()
    -- layout:setAnchorPoint(0,0)
    -- layout:setPosition(0,0)
    -- layout:setContentSize(display.size)
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- layout:setBackGroundColor(cc.c3b(255,255,0))
    -- layout:setBackGroundColorOpacity(104)
    -- layout:setTouchEnabled(false)
	-- -- layout:setLocalZOrder(-1)
	
	-- self:addChild(layout,-1)

	
	self.Image_skip = ccui.ImageView:create()
	self.Image_skip:ignoreContentAdaptWithSize(true)
	display.loadSpriteFrames("uiplist/ui_combat.plist")
    self.Image_skip:loadTexture("ui_combat_module03_battle_anniu_tiaoguo.png", ccui.TextureResType.plistType)  
    self:addChild(self.Image_skip,10)
    self.Image_skip:setAnchorPoint(cc.p(0.5,0.5))
    self.Image_skip:setPosition(cc.p(50,display.height-50))
	self.Image_skip:setTouchEnabled(true)
	cp.getManager("ViewManager").initButton(self.Image_skip, function()
		cp.getUserData("UserLogin"):setValue("skip_guide",true)
		cp.getUserData("UserLogin"):setValue("isNewRole",false)

		cp.getManager("GDataManager"):finishAllNewGuide()

		cp.getGameData("GameNewGuide"):setValue("cur_guide_module_name","")
		cp.getGameData("GameNewGuide"):setValue("cur_step",0)
		cp.getGameData("GameNewGuide"):setValue("max_step",0)

		local open_info = { type = "close"}
		cp.getManager("EventManager"):dispatchEvent("VIEW",cp.getConst("EventConst").open_playerguider_view,open_info)
	end)

	self.Image_skip:setVisible(true)	
	
end

function NewGuideOnMainUI:onEnterScene()
	log("self.open_info.guide_name = " .. tostring(self.open_info.guide_name))
	
    self:Next()
end

function NewGuideOnMainUI:onExitScene()
    log("NewGuideOnMainUI:onExitScene ")
    self.NewGuideLayer:reset()
end

	
function NewGuideOnMainUI:Next()
	local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
	local max_step = cp.getGameData("GameNewGuide"):getValue("max_step")

	if cur_step >= max_step then
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
		return
	end
	
	cur_step = cur_step + 1
	cp.getGameData("GameNewGuide"):setValue("cur_step",cur_step) 
	cp.getManager("GDataManager"):saveNewGuideStep(self.open_info.guide_name,cur_step)

	log("NewGuideOnMainUI:Next() guide_name = " .. self.open_info.guide_name .. ",cur_step = " .. cur_step)

	self.NewGuideLayer:reset()
	self.NewGuideLayer:setSwallowTouches(true)
	if self.open_info.guide_moduleInfo and self.open_info.guide_moduleInfo.firstguide then
		self.Image_skip:setVisible(false)
	end
	
	if self.open_info.guide_name == "menpai_wuxue" then --門派武學
		self:onMenPaiWuXueGuide(cur_step)
	elseif self.open_info.guide_name == "wuxue" then --武學界面
		self:onWuXueLevelUpGuide(cur_step)
	elseif self.open_info.guide_name == "story" then --劇情選關
		self:onStoryFightGuide(cur_step)
	elseif self.open_info.guide_name == "character" then --角色穿裝備並強化
		self:onCharacterGuide(cur_step)
	elseif self.open_info.guide_name == "lottery" then --抽獎
		self:onLotteryGuide(cur_step)
	elseif self.open_info.guide_name == "wuxue_use" then --裝備武學到技能欄
		self:onWuXueToSkillGuide(cur_step)
	elseif self.open_info.guide_name == "wuxue_pos_change" then --武學位置更換
		self:onWuXuePosChangeGuide(cur_step)
	elseif self.open_info.guide_name == "mail" then --領取郵件
		self:onMailGuide(cur_step)
	elseif self.open_info.guide_name == "equip" then --更換裝備並傳承熔鍊
		self:onEquipGuide(cur_step)

	elseif self.open_info.guide_name == "lilian" then --歷練指引
		self:onLilianGuide(cur_step)
	elseif self.open_info.guide_name == "mijing" then --祕境指引
		self:onMijingGuide(cur_step)
	elseif self.open_info.guide_name == "loot" then --劫鏢指引
		self:onExpressLootGuide(cur_step)
	elseif self.open_info.guide_name == "escort" then --押鏢指引
		self:onExpressEscortGuide(cur_step)
	elseif self.open_info.guide_name == "river_event" then --出城江湖事指引
		self:onRiverEventGuide(cur_step)
	elseif self.open_info.guide_name == "doucheng" then --強制指引完成後首次進入都城的指引
		self:onDouChengGuide(cur_step)
	elseif self.open_info.guide_name == "primeval_equip" then --混元裝備界面
		self:onPrimevalEquipGuide(cur_step)
	elseif self.open_info.guide_name == "primeval_main" then --混元主界面
		self:onPrimevalMainGuide(cur_step)
	elseif self.open_info.guide_name == "skill_boundary" then -- 武學境界界面
		self:onSkillBoundaryGuide(cur_step)
	elseif self.open_info.guide_name == "skill_art" then --武學招式界面
		self:onSkillArtGuide(cur_step)
	end
end


function NewGuideOnMainUI:setGuideFinishCallBack(callback)
	self.open_info.finishCallBack = callback
end


function NewGuideOnMainUI:setStepCallBack(stepCallBackList)
    self.stepCallBackList = stepCallBackList
end

-- 當前步驟執行後的回調函數
function NewGuideOnMainUI:onStepCallBack(step)
    if self.stepCallBackList ~= nil and self.stepCallBackList[step] ~= nil and "function" == type(self.stepCallBackList[step]) then
		self.stepCallBackList[step]()
	end
end

--門派武學的具體指引步驟
function NewGuideOnMainUI:onMenPaiWuXueGuide(cur_step)
	log("onMenPaiWuXueGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(-7,1) -- 播放GameStoryPlayerGuider.lua中的對話，第1句
	elseif cur_step == 2 then 
		self.NewGuideLayer:popTalk(2) -- 播放GameStoryPlayerGuider.lua中的對話，第2句
	elseif cur_step == 3 then
		--獲取需要指引的位置點(Button_MenPai)，並顯示指引手指 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_MenPai",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 4 then  --點擊門派後打開門派界面
		--發送客戶端內部消息，觸發Button_MenPai的點擊事件
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_MenPai",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
		
	elseif cur_step == 5 then
		--此步已經進入了門派界面，指引點擊門派武學的位置
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiMainLayer",
			target_name = "Panel_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 6 then
		--發送客戶端內部消息，觸發Panel_1(門派武學)的點擊事件,打開門派武學
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiMainLayer",
			target_name = "Panel_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
		
	elseif cur_step == 7 then
		--此步已經進入了門派武學界面，指引點擊一階武學1的位置
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "menpai_skill_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		
		-- local finger_info = {pos = cc.p(195,1030), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 8 then
		--點擊一階武學1的icon
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "menpai_skill_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
	
	elseif cur_step == 9 then
		--打開武學1學習界面，指引到學習按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailNoneLayer",
			target_name = "Button_Study",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(495,290), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 10 then
		--點擊學習按鈕，學習武學
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailNoneLayer",
			target_name = "Button_Study",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )

	elseif cur_step == 11 then 
		--此步已經進入了門派武學界面，指引點擊一階武學2的位置
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "menpai_skill_2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(350,1030), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 12 then
		--點擊一階武學2的icon
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "menpai_skill_2",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
	
	elseif cur_step == 13 then
		--打開武學2學習界面，指引到學習按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailNoneLayer",
			target_name = "Button_Study",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(495,290), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 14 then
		--點擊學習按鈕，學習武學
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailNoneLayer",
			target_name = "Button_Study",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
	elseif cur_step == 15 then
		--指引關閉門派武學界面
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "Button_close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point , info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(680,1060), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 16 then
		--點擊學習按鈕，學習武學
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MenPaiSkillLayer",
			target_name = "Button_close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point , info )
	elseif cur_step == 17 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name)

		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end



--武學升級並加入戰鬥列表的具體指引步驟
function NewGuideOnMainUI:onWuXueLevelUpGuide(cur_step)
	log("onWuXueLevelUpGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(3) -- 播放GameStoryPlayerGuider.lua中的對話，第3句
	elseif cur_step == 2 then 
		--獲取需要指引的位置點(Button_WuXue)，並顯示指引手指 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 3 then
		--模擬點擊(Button_WuXue) 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		--此步已經進入了武學界面，指引升級第一個武學
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Skill_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(170,1000), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
	
		--模擬點擊第一個武學圖標 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Skill_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 6 then
		--指引到【一鍵升級】按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_SkillLevelUp2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(550,395), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)		

	elseif cur_step == 7 then
		--點擊一鍵升級
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_SkillLevelUp2",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 8 then
		self.NewGuideLayer:popTalk(4)
	
	elseif cur_step == 9 then
		self.NewGuideLayer:popTalk(5)

	elseif cur_step == 10 then
		--指引顯示到武學詳情關閉按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_Close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(630,980), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
		self.NewGuideLayer:resetBgColor(0,0,0,128)
	elseif cur_step == 11 then 
		--點擊關閉武學詳情界面
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_Close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
		self.NewGuideLayer:resetBgColor(0,0,0,0)
	elseif cur_step == 12 then
		--此步已經進入了武學界面，指引升級第二個武學
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Skill_2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(300,1000), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 13 then
	
		--模擬點擊第二個武學圖標 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Skill_2",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 14 then
		--指引到【一鍵升級】按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_SkillLevelUp2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(550,395), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)		

	elseif cur_step == 15 then
		--點擊一鍵升級
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_SkillLevelUp2",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 16 then
		--指引顯示到武學詳情關閉按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_Close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(630,980), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
		self.NewGuideLayer:resetBgColor(0,0,0,128)
	elseif cur_step == 17 then 
		--點擊關閉武學詳情界面
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillDetailLearnLayer",
			target_name = "Button_Close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
		self.NewGuideLayer:resetBgColor(0,0,0,0)
	elseif cur_step == 18 then
		self.NewGuideLayer:popTalk(6)
	elseif cur_step == 19 then
		--指引 拖動 武學1 icon 到下方的組合列表
		self.NewGuideLayer:setSwallowTouches(true)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(170,1000), finger = {guide_type = "move", moveto = cc.p(60,205)} }
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 20 then
		self.NewGuideLayer:setSwallowTouches(true)
		--指引 拖動 武學2 icon 到下方的組合列表
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		-- local finger_info = {pos = cc.p(305,1000), finger = {guide_type = "move", moveto = cc.p(170,205)} }
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 21 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:resetGuideTypeToPoint()	
		self.NewGuideLayer:popTalk(7)	
	elseif cur_step == 22 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end



--進入江湖劇情挑戰的具體指引步驟
function NewGuideOnMainUI:onStoryFightGuide(cur_step)
	log("onStoryFightGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(7) -- 播放GameStoryPlayerGuider.lua中的對話，第7句
	elseif cur_step == 2 then 
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 3 then
		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		--此步已經進入了江湖界面，指引到劇情
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(600,620), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then

		-- self.NewGuideLayer:resetStencilSize(60,50)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 6 then
		--此步已經進入了劇情關卡選擇界面，指引簡單模式第一關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 

		-- local finger_info = {pos = cc.p(140,620), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 7 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		-- local finger_info = {pos = cc.p(360,300), finger = {guide_type = "point",dir="right"} }
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 10 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(8)
	elseif cur_step == 11 then
		--戰鬥完返回了劇情關卡選擇界面，指引簡單模式第二關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 12 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_2",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 13 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 14 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 15 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(9)
	elseif cur_step == 16 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end

end

--角色穿戴裝備並強化
function NewGuideOnMainUI:onCharacterGuide(cur_step)
	log("onCharacterGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(11) -- 播放GameStoryPlayerGuider.lua中的對話，第11句：行走江湖怎能沒有一把趁手的武器（首通獎勵獲得）
	elseif cur_step == 2 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 3 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		--此步已經進入了角色界面，指引武器格子
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 6 then
		--此步已經進入了裝備選擇界面，指引選擇第一件武器
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "weapon_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 7 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "weapon_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 10 then
		--此步已經進入了角色界面，指引武器格子
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 11 then
		-- 第二次點擊，已經裝備了武器，打開武器Tips進行強化
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 12 then
		-- 武器Tips指向強化按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = "Button_qianghua",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 13 then
		-- 武器Tips點擊強化按鈕
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = "Button_qianghua",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 14 then
		-- 裝備強化界面，指引第一次強化，指向第一個格子物品
		self.NewGuideLayer:setSwallowTouches(false)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "material_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 15 then
		self.NewGuideLayer:setSwallowTouches(true)
		-- 裝備強化界面，指向確定按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 16 then
		-- 點擊確定強化
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 17 then
		-- 指向關閉
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 18 then
		-- 點擊確定關閉
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 19 then
		-- 提示去挑戰第三關卡
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(12)

	elseif cur_step == 20 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 21 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 22 then
		--此步已經進入了江湖界面，指引到劇情
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 23 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 24 then
		--此步已經進入了劇情關卡選擇界面，指引簡單模式第三關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_3",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 25 then
		--模擬點擊第三關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_3",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 26 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 27 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 28 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end

end

function NewGuideOnMainUI:onLotteryGuide(cur_step)
	log("onLotteryGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(13) -- 播放GameStoryPlayerGuider.lua中的對話，第7句 
	elseif cur_step == 2 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			ret = 0,
		}
		self:dispatchViewEvent( cp.getConst("EventConst").check_layer_visible, info )
		if info.ret == 0 then
			cp.getGameData("GameNewGuide"):setValue("cur_step",3)
			self:Next()
		else
			local finger_info = {}
			local info = 
			{
				guide_name = self.open_info.guide_name,
				classname = "MajorDown",
				target_name = "Button_DouCheng",
				ret = {},
			}
			self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
			finger_info = info.ret 
			self.NewGuideLayer:fingerGuide(finger_info)
		end
	elseif cur_step == 3 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_DouCheng",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorLayer",
			target_name = "Button_changbaoge",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorLayer",
			target_name = "Button_changbaoge",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 6 then
		self.NewGuideLayer:popTalk(14,nil,128)
		
	elseif cur_step == 7 then
		self.NewGuideLayer:popTalk(15,nil,128)
	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_BuyOnce",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_BuyOnce",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 10 then
		self.NewGuideLayer:popTalk(16,nil,128)
	elseif cur_step == 11 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryItemLayer",
			target_name = "close_result",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
		self.NewGuideLayer:setSwallowTouches(false)
		self.NewGuideLayer:setNeedCallBackWhileTouchOut(true)
	elseif cur_step == 12 then

		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryItemLayer",
			target_name = "close_result",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
		self.NewGuideLayer:setSwallowTouches(false)
	elseif cur_step == 13 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_Treasure",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 14 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_Treasure",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 15 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_BuyTenth",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 16 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryHouseLayer",
			target_name = "Button_BuyTenth",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 17 then
		self.NewGuideLayer:popTalk(17,nil,128)
	elseif cur_step == 18 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryItemLayer",
			target_name = "close_result",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
		self.NewGuideLayer:setSwallowTouches(false)
		self.NewGuideLayer:setNeedCallBackWhileTouchOut(true)
	elseif cur_step == 19 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LotteryItemLayer",
			target_name = "close_result",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
		self.NewGuideLayer:setSwallowTouches(false)
	elseif cur_step == 20 then
		self:dispatchViewEvent( cp.getConst("EventConst").show_skillsect_layer)
	elseif cur_step == 21 then
		self.NewGuideLayer:popTalk(18,nil,128)
	elseif cur_step == 22 then
		self:dispatchViewEvent( cp.getConst("EventConst").point_skillsect_2)
	elseif cur_step == 23 then
		self.NewGuideLayer:popTalk(19,nil,128)
	elseif cur_step == 24 then
		self:dispatchViewEvent( cp.getConst("EventConst").point_skillsect_3)
	elseif cur_step == 25 then
		self.NewGuideLayer:popTalk(190,nil,128)
	elseif cur_step == 26 then
		self.NewGuideLayer:popTalk(191,nil,128)
	elseif cur_step == 27 then
		self:dispatchViewEvent( cp.getConst("EventConst").select_skillsect)
		self.NewGuideLayer:setTouchCallBack(nil)
		local rect = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSectSelect",
			target_name = "Panel_content",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		rect = info.ret
		self.NewGuideLayer:changeStencil("whole_block",rect)
		self.NewGuideLayer:setSwallowTouches(true)
	elseif cur_step == 28 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:resetGuideTypeToPoint()
		local function onTouchFunc()
			self:Next()
		end
		self.NewGuideLayer:setTouchCallBack(onTouchFunc)
		self.NewGuideLayer:popTalk(192,nil,128)
	elseif cur_step == 29 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--武學加入戰鬥列表的指引
function NewGuideOnMainUI:onWuXueToSkillGuide(cur_step)
	log("onWuXueToSkillGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(193)
	elseif cur_step == 2 then 
		--獲取需要指引的位置點(Button_WuXue)，並顯示指引手指 
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 3 then
		--模擬點擊(Button_WuXue) 
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		--此步已經進入了武學界面,指引 拖動 武學1 icon 到下方的組合列表
		self.NewGuideLayer:setSwallowTouches(true)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_3",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 5 then
		self.NewGuideLayer:setSwallowTouches(true)
		--指引 拖動 武學2 icon 到下方的組合列表
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_4",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 6 then
		--指引 拖動 武學3 icon 到下方的組合列表
		self.NewGuideLayer:setSwallowTouches(true)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_5",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 7 then
		self.NewGuideLayer:setSwallowTouches(true)
		--指引 拖動 武學4 icon 到下方的組合列表
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Move_Skill_6",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	

	elseif cur_step == 8 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:resetGuideTypeToPoint()	
		self.NewGuideLayer:popTalk(194)	
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 11 then
		--此步已經進入了江湖界面，指引到劇情
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 12 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 13 then
		--此步已經進入了劇情關卡選擇界面，指引簡單模式第一關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_4",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 14 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_4",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 15 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 16 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 17 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(20)
	elseif cur_step == 18 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--領取郵件
function NewGuideOnMainUI:onMailGuide(cur_step)
	log("onMailGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(21)
	elseif cur_step == 2 then

		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			ret = 0,
		}
		self:dispatchViewEvent( cp.getConst("EventConst").check_layer_visible, info )
		if info.ret == 0 then
			cp.getGameData("GameNewGuide"):setValue("cur_step",3)
			self:Next()
		else
			local finger_info = {}
			local info = 
			{
				guide_name = self.open_info.guide_name,
				classname = "MajorDown",
				target_name = "Button_DouCheng",
				ret = {},
			}
			self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
			finger_info = info.ret 
			self.NewGuideLayer:fingerGuide(finger_info)
		end
	elseif cur_step == 3 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_DouCheng",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorLeft",
			target_name = "Button_XinZha",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorLeft",
			target_name = "Button_XinZha",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 6 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailListLayer",
			target_name = "mail_list_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 7 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailListLayer",
			target_name = "mail_list_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailDetailLayer",
			target_name = "Button_Receive",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailDetailLayer",
			target_name = "Button_Receive",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "GameRewardReceiveUI",
			target_name = "Button_get",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 11 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "GameRewardReceiveUI",
			target_name = "Button_get",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 12 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailDetailLayer",
			target_name = "Button_Close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 13 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailDetailLayer",
			target_name = "Button_Close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 14 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailListLayer",
			target_name = "Button_Close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 15 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MailListLayer",
			target_name = "Button_Close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 16 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--裝備更換與傳承熔鍊
function NewGuideOnMainUI:onEquipGuide(cur_step)
	log("onEquipGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(22)
	elseif cur_step == 2 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 3 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 4 then
		--此步已經進入了角色界面，指引武器格子
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 6 then
		--此步已經進入了武器tips，指引更換武器

		local btn_name = "Button_chushou"  --更換按鈕
		--此處需判斷伺服器存儲的實際進度(根據不同進度指向不同的按鈕)
		local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "equip" then
			if step >= 19 and step <= 25 then
                btn_name = "Button_ronglian"  --熔鍊按鈕
            end
        end

		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = btn_name,
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 7 then
		local btn_name = "Button_chushou"  --更換按鈕
		--此處需判斷伺服器存儲的實際進度(根據不同進度指向不同的按鈕)
		local name, step = cp.getManager("GDataManager"):getLocalNewGuideStep()
		if name == "equip" then
			if step >= 19 and step <= 25 then
                btn_name = "Button_ronglian"  --熔鍊按鈕
            end
        end
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = btn_name,
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 8 then
		--此步已經進入了裝備選擇界面，指引選擇第一件武器
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "weapon_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 9 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "weapon_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 11 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SelectEquipTip",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 12 then
		self.NewGuideLayer:popTalk(23)
	elseif cur_step == 13 then
		--此步已經進入了角色界面，指引武器格子
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 14 then
		-- 第二次點擊，已經裝備了武器，打開武器Tips進行傳承
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorRolePublic",
			target_name = "Panel_wuqi",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 15 then
		-- 武器Tips指向傳承按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = "Button_chuancheng",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 16 then
		-- 武器Tips點擊傳承按鈕
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "WeaponTip",
			target_name = "Button_chuancheng",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 17 then
		-- 裝備傳承界面，指引第一次傳承，指向第一個格子物品
		self.NewGuideLayer:setSwallowTouches(false)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "material_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 18 then
		self.NewGuideLayer:setSwallowTouches(true)
		-- 裝備傳承界面，指向確定按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 19 then
		-- 點擊確定傳承
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 20 then
		self.NewGuideLayer:popTalk(24)
	elseif cur_step == 21 then
		-- 指向熔鍊按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Image_ronglian",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 22 then
		-- 點擊切換到熔鍊按鈕
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Image_ronglian",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 23 then
		-- 裝備熔鍊界面，指引第一次熔鍊，指向第一個格子物品
		self.NewGuideLayer:setSwallowTouches(false)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "material_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 24 then
		self.NewGuideLayer:setSwallowTouches(true)
		-- 裝備熔鍊界面，指向確定按鈕
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 25 then
		-- 點擊確定熔鍊
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 26 then
		--點擊熔鍊恢復界面確認
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipMeltRevertUI",
			target_name = "Button_ok",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 27 then
		-- 點擊確定熔鍊的結果
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipMeltRevertUI",
			target_name = "Button_ok",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 28 then
		-- 指向關閉
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_close",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 29 then
		-- 點擊確定關閉
		local finger_info = {} 
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "EquipOperateLayer",
			target_name = "Button_close",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 30 then
		-- 提示去挑戰第五關卡
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(12)

	elseif cur_step == 31 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 32 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 33 then
		--此步已經進入了江湖界面，指引到劇情
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 34 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 35 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(25,26)
	elseif cur_step == 36 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--武學位置更換
function NewGuideOnMainUI:onWuXuePosChangeGuide(cur_step)
	log("onWuXuePosChangeGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 2 then
		--模擬點擊(Button_WuXue) 
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_WuXue",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
		
	elseif cur_step == 3 then 	
		self.NewGuideLayer:popTalk(193)
	elseif cur_step == 4 then
		--此步已經進入了武學界面,指引 拖動 下方的組合列表中 武學4 icon 到 武學1的位置
 		self.NewGuideLayer:setSwallowTouches(true)
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Change_Pos_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	
	elseif cur_step == 5 then
		self.NewGuideLayer:setSwallowTouches(true)
		--指引 拖動 武學5 到 武學2 的位置
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "SkillSummaryLayer",
			target_name = "Change_Pos_2",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret
		self.NewGuideLayer:fingerGuide(finger_info)	

	elseif cur_step == 6 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:resetGuideTypeToPoint()	
		self.NewGuideLayer:popTalk(194)	
	elseif cur_step == 7 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JiangHu",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 9 then
		--此步已經進入了江湖界面，指引到劇情
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "JiangHuLayer",--"MajorLayer",
			target_name = "Button_5",--"Button_juqing",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 11 then
		--此步已經進入了劇情關卡選擇界面，指引簡單模式第一關卡
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_4",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)

	elseif cur_step == 12 then
		--模擬點擊
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChapterPartLayer",
			target_name = "story_part_4",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 13 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 14 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "ChallengeStory",
			target_name = "Button_tiaozhan",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 15 then
		self.NewGuideLayer:setSwallowTouches(true)
		self.NewGuideLayer:popTalk(20)
	elseif cur_step == 16 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--歷練指引(進入歷練界面之後)
function NewGuideOnMainUI:onLilianGuide(cur_step)
	log("onLilianGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(27)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(28)
	elseif cur_step == 3 then
		--引導點擊確認進入歷練
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "GameMessageBox",
			target_name = "Button_OK",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 4 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "GameMessageBox",
			target_name = "Button_OK",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LilianDetailLayer",
			target_name = "Button_fast",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 6 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LilianDetailLayer",
			target_name = "Button_fast",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	
	elseif cur_step == 7 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LilianResultLayer",
			target_name = "Button_OK",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 8 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "LilianResultLayer",
			target_name = "Button_OK",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 9 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "MajorDown",
			target_name = "Button_JueSe",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )

	elseif cur_step == 11 then
		self.NewGuideLayer:popTalk(29)
	elseif cur_step == 12 then
		self.NewGuideLayer:popTalk(30)
	elseif cur_step == 13 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--祕境指引
function NewGuideOnMainUI:onMijingGuide(cur_step)
	log("onMijingGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(31)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(32)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(33)
	elseif cur_step == 4 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end
--押鏢指引
function NewGuideOnMainUI:onExpressEscortGuide(cur_step)
	log("onExpressEscortGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(34)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(35)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(36)
	elseif cur_step == 4 then
		self.NewGuideLayer:popTalk(37)
	elseif cur_step == 5 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end
--劫鏢指引
function NewGuideOnMainUI:onExpressLootGuide(cur_step)
	log("onExpressLootGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(38)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(39)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(40)
	elseif cur_step == 4 then
		self.NewGuideLayer:popTalk(41)
	elseif cur_step == 5 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

function NewGuideOnMainUI:onRiverEventGuide(cur_step)
	log("onRiverEventGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(42)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(43)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(44)
	elseif cur_step == 4 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverMainLayer",
			target_name = "Button_Event",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
		
	elseif cur_step == 5 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverMainLayer",
			target_name = "Button_Event",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 6 then
		self.NewGuideLayer:popTalk(45)
	elseif cur_step == 7 then
		self.NewGuideLayer:popTalk(46)
	elseif cur_step == 8 then
		self.NewGuideLayer:popTalk(47)
	elseif cur_step == 9 then
		self.NewGuideLayer:popTalk(48)
	elseif cur_step == 10 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventListLayer",
			target_name = "event_item_1",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 11 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventListLayer",
			target_name = "event_item_1",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 12 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventListLayer",
			target_name = "Button_Start",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 13 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventListLayer",
			target_name = "Button_Start",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 14 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventAcceptUI",
			target_name = "Button_confirm",
			ret = {},
		}
		self:dispatchViewEvent( cp.getConst("EventConst").get_guide_view_point, info )
		finger_info = info.ret 
		self.NewGuideLayer:fingerGuide(finger_info)
	elseif cur_step == 15 then
		local finger_info = {}
		local info = 
		{
			guide_name = self.open_info.guide_name,
			classname = "RiverEventAcceptUI",
			target_name = "Button_confirm",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").guide_click_view_point, info )
	elseif cur_step == 16 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--都城指引
function NewGuideOnMainUI:onDouChengGuide(cur_step)
	log("onDouChengGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(49,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(50,nil,128)
	elseif cur_step == 3 then
		self.NewGuideLayer:setTouchCallBack(nil)
		local req = {idx=0}
		self:dispatchViewEvent( cp.getConst("EventConst").OnNewGuideDouCheng,req)
	elseif cur_step == 4 then
		self.NewGuideLayer:popTalk(57)
		local function onTouchFunc()
			self:Next()
		end
		self.NewGuideLayer:setTouchCallBack(onTouchFunc)
	elseif cur_step == 5 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--裝備混元界面
function NewGuideOnMainUI:onPrimevalEquipGuide(cur_step)
	log("onPrimevalEquipGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(61,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(62,66,128)
	elseif cur_step == 3 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--混元主界面
function NewGuideOnMainUI:onPrimevalMainGuide(cur_step)
	log("onPrimevalMainGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(58,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(59,nil,128)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(60,nil,128)
	elseif cur_step == 4 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--武學境界界面
function NewGuideOnMainUI:onSkillBoundaryGuide(cur_step)
	log("onSkillBoundaryGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(67,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(68,nil,128)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(69,nil,128)
	elseif cur_step == 4 then
		self.NewGuideLayer:popTalk(70,nil,128)
	elseif cur_step == 5 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--首次進入武學招式界面
function NewGuideOnMainUI:onSkillArtGuide(cur_step)
	log("onSkillArtGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(71,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(72,nil,128)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(73,nil,128)
	elseif cur_step == 4 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end

--首次進入門派地位界面
function NewGuideOnMainUI:onMenPaiRankGuide(cur_step)
	log("onMenPaiRankGuide cur_step = " .. tostring(cur_step))
	if cur_step == 1 then
		self.NewGuideLayer:popTalk(74,nil,128)
	elseif cur_step == 2 then
		self.NewGuideLayer:popTalk(75,nil,128)
	elseif cur_step == 3 then
		self.NewGuideLayer:popTalk(76,nil,128)
	elseif cur_step == 4 then
		self.NewGuideLayer:popTalk(77,nil,128)
	elseif cur_step == 5 then
		self.NewGuideLayer:popTalk(78,nil,128)
	elseif cur_step == 6 then
		cp.getManager("GDataManager"):finishNewGuideName(self.open_info.guide_name) 
		if self.open_info.finishCallBack ~= nil then
			self.open_info.finishCallBack(self.open_info.guide_name)
		end
	end
end


return NewGuideOnMainUI
