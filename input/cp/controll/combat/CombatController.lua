local bit = require("bit")
local CombatController = {}
local CombatPair = require("cp.controll.combat.CombatPair")
local CombatConst = cp.getConst("CombatConst")

function CombatController:init(layer, sceneConfig)
	self.combat_result = cp.getUserData("UserCombat"):getCombatData().combat_result
	self.combatType = cp.getUserData("UserCombat"):getCombatType()
	if self.combatType == CombatConst.CombatType_Story then
		local id = cp.getUserData("UserCombat"):getID()
		local storyConfig = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", id)
		if storyConfig then
			local storyList = {}
			local userCombat = cp.getUserData("UserCombat")
			local partID = userCombat:getValue("normal_chapter_part_id")
			if storyConfig:getValue("ID") > partID then
				local storyIDList = string.split(storyConfig:getValue("StoryID"), ";")
				for i=1, #storyIDList do
					local story = cp.getManager("ConfigManager").getItemByKey("GameStory", tonumber(storyIDList[i]))
					if story then
						table.insert(storyList, story)
					end
				end
				cp.CombatStory:init(layer, storyList, self)
			end
			
		end
	elseif self.combatType == CombatConst.CombatType_Guide then
		local storyIDList = {500,501}
		local storyList = {}
		for _, storyID in ipairs(storyIDList) do
			local story = cp.getManager("ConfigManager").getItemByKey("GameStory", storyID)
			if story then
				table.insert(storyList, story)
			end
		end
		if #storyList > 0 then
			cp.CombatStory:init(layer, storyList, self)
		end
	elseif self.combatType == CombatConst.CombatType_ArenaGuide then
		local storyIDList = {510,511}
		local storyList = {}
		for _, storyID in ipairs(storyIDList) do
			local story = cp.getManager("ConfigManager").getItemByKey("GameStory", storyID)
			if story then
				table.insert(storyList, story)
			end
		end
		if #storyList > 0 then
			cp.CombatStory:init(layer, storyList, self)
		end
	elseif self.combatType == CombatConst.CombatType_HeroChallenge then --俠客行
		local id = cp.getUserData("UserCombat"):getID()
		local storyConfig = cp.getManager("ConfigManager").getItemByKey("HeroStory", id)
		if storyConfig then
			local storyList = {}
			-- local current = cp.getUserData("UserXiakexing"):getValue("current")
			-- if current > id then
				local storyIDList = string.split(storyConfig:getValue("StoryID"), ";")
				for i=1, #storyIDList do
					local story = cp.getManager("ConfigManager").getItemByKey("GameStory", tonumber(storyIDList[i]))
					if story then
						table.insert(storyList, story)
					end
				end
				if #storyList > 0 then
					cp.CombatStory:init(layer, storyList, self)
				end
			-- end
		end
	else
		cp.CombatStory:init(layer, {}, self)
	end
	--開始的時間，s
	self.beginTime = self.combat_result.begin_time
	self.combatID  = self.combat_result.combat_iD
	self.max_entity = self.combat_result.max_entity
	self.max_stage = self.combat_result.max_stage
	self.sceneConfig = sceneConfig
	self.combatPairList = {}
	self.layer = layer
	self.state = CombatConst.CombatState_StartStage
	--以EntityID為viewEntityID作為視角
	self.viewPair = 1

	self:initStage(1)
end

function CombatController:getStage()
	return self.stage
end

function CombatController:getMaxStage()
	return self.max_stage
end

function CombatController:setCombatFinish()
	self.stage = self.max_stage
	for i=1, self.max_entity do
		local combatPair = self.combatPairList[i]
		if combatPair then
			combatPair.roundIndex = #combatPair.rounds
			combatPair.stage = self.max_stage
		end
	end
end

function CombatController:getMaxCombatEntity()
	return self.max_entity
end

function CombatController:initStage(stage)
	local stageResult = self.combat_result.stage_result[stage]
	if not stageResult then
		return false
	end
	
	self.stage = stage
	self.stageResult = stageResult.result
	for i=1, self.max_entity do
		local combatPair = self.combatPairList[i]
		if stageResult.combat_round_result[i] then
			local rounds = stageResult.combat_round_result[i].round_result
			if not self.combatPairList[i] then
				combatPair = CombatPair:create(self.sceneConfig, self.layer, i, rounds)
				self.combatPairList[i] = combatPair
			end
			combatPair:initPair(self.stage, rounds)
			if i == self.viewPair then
				combatPair.inView = true
			else
				combatPair.inView = false
			end
		end
	end
	self:setState(CombatConst.CombatState_StartStage)
end

--關卡結束後，跑關卡
function CombatController:runStage()
	local stage = self.stage + 1
	if stage > self.max_stage then return end
	self:setState(CombatConst.CombatState_RunStage, stage)
end

function CombatController:setState(state, param)
	if self.state == state then
		return
	end

	if state == CombatConst.CombatState_StartStage then
		if self.state == CombatConst.CombatState_GameStory then
			self:setPairState(CombatConst.CombatPairState_BothStandby)
		end
	elseif state == CombatConst.CombatState_GameStory then
		cp.CombatStory:setStory(param)
	elseif state == CombatConst.CombatState_RunStage then
		self.layer:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
			self:setPairState(CombatConst.CombatPairState_RunStage)
			self.layer:runStageStart(param, self.sceneConfig:getValue("RunStageTime")/1000)
		end)))
	elseif state == CombatConst.CombatState_FinishStage then
		if self.stageResult == CombatConst.CombatRoundResult_Left then
			if self.max_stage ~= self.stage then
				self:runStage(self.stage+1)
				return
			else
				self:setEntityState("left", CombatConst.CombatEntityState_Win)
				self:setEntityState("right", CombatConst.CombatEntityState_Death)
			end
		elseif self.stageResult == CombatConst.CombatRoundResult_Draw then
			--彈出平局框
		elseif self.stageResult == CombatConst.CombatRoundResult_Right then
			self:setEntityState("left", CombatConst.CombatEntityState_Death)
			self:setEntityState("right", CombatConst.CombatEntityState_Win)
			--彈出失敗框
		end
		self.layer:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
			cc.CallFunc:create(function()
				cp.getManager("EventManager"):dispatchEvent("VIEW", cp.getConst("EventConst").combat_finish)
		 end)))
	end

	self.state = state
end

function CombatController:getState()
	return self.state
end

function CombatController:setEntityState(side, state)
	for i = 1, self.max_entity do
		local combatPair = self.combatPairList[i]
		if side == "left" then
			if combatPair and combatPair.leftEntity then
				combatPair.leftEntity:setState(state) 
			end
		elseif side == "right" then
			if combatPair and combatPair.rightEntity then
				combatPair.rightEntity:setState(state) 
			end
		else
			if combatPair and combatPair.leftEntity then
				combatPair.leftEntity:setState(state) 
			end
			if combatPair and combatPair.rightEntity then
				combatPair.rightEntity:setState(state) 
			end
		end
	end 
end

function CombatController:setPairState(state)
	for i=1, self.max_entity do
		local combatPair = self.combatPairList[i]
		if combatPair then
			combatPair:setState(state)
		end
	end
end

function CombatController:updateStage()
	for row=1, self.max_entity do
		local combatPair = self.combatPairList[row]
		if not combatPair then
			return
		end

		if combatPair:getState() ~= CombatConst.CombatPairState_End then
			return
		end
	end

	self:setState(CombatConst.CombatState_FinishStage)
end

function CombatController:updateRound(dt)
	for row=1, self.max_entity do
		local combatPair = self.combatPairList[row]
		if combatPair and combatPair.state == CombatConst.CombatPairState_BothStandby then
			combatPair:update(dt*1000, self.stage)
		end
	end
end

function CombatController:update(dt)
	if self.state == CombatConst.CombatState_GameStory then
		--CombatStory:updateStory(dt)
		return
	end

	if self.state == CombatConst.CombatState_RunStage then
		return
	end

	if self.state == CombatConst.CombatState_StartStage then
		self:updateRound(dt)
		self:updateStage()
	end
end

function CombatController:setInView(row)
	self.combatPairList[i].inView = true
end

return CombatController