local StateMachine = require("cp.utils.state_machine.StateMachine")
local CombatPair = class("CombatPair", StateMachine)
local CombatEntity = require("cp.controll.combat.CombatEntity")
local CombatConst = cp.getConst("CombatConst")

function CombatPair:ctor(sceneConfig, layer, row, rounds)
	self.leftEntity = nil
	self.rightEntity = nil
	self.state = 0
	self.layer = layer
	self.sceneConfig = sceneConfig
	self.row = row
	self.deadList = {}
	self.stage = 1
	self.result = 0
	self.round = 0

	self:setupState{
		initial = "JoinPair",
		events = {
			{name="BothEnter", from="JoinPair", to="Story"},
			{name="StoryEnd", from="Story", to="BothStandBy"},
			{name="Ready", from="BothStandBy", to="Attack"},
			{name="Dead", from="Attack", to="JoinPair"},
			{name="Run", from="JoinPair", to="RunningStage"},
		},
		callbacks = {
		}
	}
end

--初始化戰鬥對，
function CombatPair:initPair(stage, rounds)
    self.roundIndex = 1
	self.rounds = rounds
	self.stage = stage
	self.waitTime = 0
	self.inView = true
	local param1, param2
	if self.rounds[1].side_result_list[1] and not self.leftEntity then
		log("Entity Created,row="..self.row..",side=left")
		self.leftEntity = CombatEntity:create(self.sceneConfig, self.layer, self.row, "left", self.rounds[1].side_result_list[1])
		self.leftEntity:setState(CombatConst.CombatEntityState_Into)
	else
		self.leftEntity:setState(CombatConst.CombatEntityState_Idle)
	end
	
	if self.rounds[1].side_result_list[2] and not self.rightEntity then
		log("Entity Created,row="..self.row..",side=right")
		self.rightEntity = CombatEntity:create(self.sceneConfig, self.layer, self.row, "right", self.rounds[1].side_result_list[2])
		self.rightEntity:setState(CombatConst.CombatEntityState_Into)
	else
		self.rightEntity:setState(CombatConst.CombatEntityState_Idle)
	end

	--[[
	if self.rounds[1].side_result_list[1] then
		for _, skillInfo in ipairs(self.rounds[1].side_result_list[1].skill_list) do
			self:preloadSkill(self.leftEntity.modelItem, skillInfo.id)
		end
	end
	
	if self.rounds[1].side_result_list[2] then
		for _, skillInfo in ipairs(self.rounds[1].side_result_list[2].skill_list) do
			self:preloadSkill(self.rightEntity.modelItem, skillInfo.id)
		end
	end
	]]

	self.leftEntity.sideResult = rounds[1].side_result_list[1]
	self.rightEntity.sideResult = rounds[1].side_result_list[2]
	self.leftEntity:initAttr(rounds[1].side_result_list[1])
	self.rightEntity:initAttr(rounds[1].side_result_list[2])
	self.leftEntity:setFightAttr(rounds[1].side_result_list[1])
	self.rightEntity:setFightAttr(rounds[1].side_result_list[2])

	if self.inView then
		self.layer:initCombatLayerView(rounds[1])
		self.layer:addBuffers(self.leftEntity, rounds[1].side_result_list[1].buffer_list)
		self.layer:addBuffers(self.rightEntity, rounds[1].side_result_list[2].buffer_list)
	end

	self.rightEntity.target = self.leftEntity
	self.leftEntity.target = self.rightEntity
	self.leftEntity.pair = self
	self.rightEntity.pair = self
	self:setState(CombatConst.CombatPairState_JoinPair, rounds[1].wait_time/1000)
end

function CombatPair:getState()
	return self.state
end

function CombatPair:setEntityState(state)
	if self.leftEntity then
		self.leftEntity:setState(state)
	end

	if self.rightEntity then
		self.rightEntity:setState(state)
	end
end

function CombatPair:onFight(attacker, defencer, combatRoundFlag)
	attacker.combatRoundFlag = combatRoundFlag
	defencer.combatRoundFlag = combatRoundFlag

	local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", attacker.sideResult.use_skill)
	attacker.useSkill = skillEntry
	defencer.useSkill = cp.getManager("ConfigManager").getItemByKey("SkillEntry", defencer:getNormalSkill())

	local isDoubleHit = bit.band(combatRoundFlag, CombatConst.CombatRoundFlag_DoubleHit)
	local isCritic = bit.band(combatRoundFlag, CombatConst.CombatRoundFlag_Critic)
	local isParry = bit.band(combatRoundFlag, CombatConst.CombatRoundFlag_Parry)
	local isDodge = bit.band(combatRoundFlag, CombatConst.CombatRoundFlag_Dodge)

	if isDoubleHit > 0 then
		attacker:createAttackInfo("連擊", CombatConst.EffectType_Batter)
	end

	local attackerSequenceList = {}
	local defencerSequenceList = {}
	
	attacker:setState(CombatConst.CombatEntityState_Forward)
	
	if isDoubleHit == 0 then
		self.layer:showUseSkill(attacker, attacker.sideResult)
	end
end

function CombatPair:onNewStageBegin()
end

function CombatPair:onStageEnd()
end

function CombatPair:onNewRoundBegin(dtDuration, leftSideResult, rightSideResult)
	self.leftEntity:runCombatEvent(CombatConst.GameEvent_RoundBegin)
	self.rightEntity:runCombatEvent(CombatConst.GameEvent_RoundBegin)

	self.layer:updateQi(self.leftEntity, dtDuration/1000, leftSideResult.qi_recover)
	self.layer:updateLife(self.leftEntity, 0.1, leftSideResult.life_recover, leftSideResult.max_life)
	self.layer:updateForce(self.leftEntity, 0.1, leftSideResult.force_recover, leftSideResult.max_force)
	
	self.layer:updateQi(self.rightEntity, dtDuration/1000, rightSideResult.qi_recover)
	self.layer:updateLife(self.rightEntity, 0.1, rightSideResult.life_recover, rightSideResult.max_life)
	self.layer:updateForce(self.rightEntity, 0.1, rightSideResult.force_recover, rightSideResult.max_force)
end

function CombatPair:onRoundEnd(roundResult)
	self.leftEntity:runCombatEvent(CombatConst.GameEvent_RoundEnd)
	self.rightEntity:runCombatEvent(CombatConst.GameEvent_RoundEnd)
end

function CombatPair:checkEntityDead()
	if self.leftEntity.life == 0 or self.rightEntity.life == 0 then
		if self.leftEntity.life == 0 then
			self.leftEntity:runCombatEvent(CombatConst.GameEvent_Dead)
			if self.leftEntity.life ~= 0 then
				self.leftEntity:setState(CombatConst.CombatEntityState_DeadAlive)
			end
		end

		if self.rightEntity.life == 0 then
			self.rightEntity:runCombatEvent(CombatConst.GameEvent_Dead)
			if self.rightEntity.life ~= 0 then
				self.rightEntity:setState(CombatConst.CombatEntityState_DeadAlive)
			end
		end

		if self.leftEntity.life ~= 0 and self.rightEntity.life ~= 0 then
			return true
		end

		local attacker = nil
		if self.leftEntity.sideResult.is_attacker then
			attacker = self.leftEntity
		else
			attacker = self.rightEntity
		end

		attacker:setState(CombatConst.CombatEntityState_FallBack)
	end
	
	return false
end

function CombatPair:recycleEntity(entity)
	if entity == nil then
		return
	end
	table.insert(self.deadList, entity)
	if entity.side == "left" then
		self.leftEntity = nil
	else
		self.rightEntity = nil
	end
end

function CombatPair:setState(state, param1, param2)
	if self.state == state then
		return
	end

	if state == CombatConst.CombatPairState_Story then
		self:setEntityState(CombatConst.CombatEntityState_Idle)
		if self.leftEntity.life == 0 then
			self:setState(CombatConst.CombatPairState_BothStandby)
			return
		end
		local storyConfig = cp.CombatStory:getStory(self.stage, 0, self:getRound(), self:getMaxRound())
		if storyConfig then
			cp.CombatController:setState(CombatConst.CombatState_GameStory, storyConfig)
		else
			storyConfig = cp.CombatStory:getStory(self.stage, 1, self:getRound() + 1, self:getMaxRound())
			if storyConfig then
				cp.CombatController:setState(CombatConst.CombatState_GameStory, storyConfig)
			else
				self:setState(CombatConst.CombatPairState_BothStandby)
				return
			end 
		end
	elseif state == CombatConst.CombatPairState_BothStandby then
		self.roundIndex = self.roundIndex + 1
		log("New Round Begin， roundIndex="..self.roundIndex)
		self:setEntityState(CombatConst.CombatEntityState_Idle)
		local currentRound = self.rounds[self.roundIndex]
		local lastRound = self.rounds[self.roundIndex-1]
		local lastRoundEndTime = 0
		self.waitTime = 0

		--上一回合結束
		if lastRound then
			self:onRoundEnd(lastRound)
		end

		if currentRound then
			self.leftEntity.sideResult = currentRound.side_result_list[1]
			self.rightEntity.sideResult = currentRound.side_result_list[2]
			
			--dump(currentRound.side_result_list[1].event_list, "left:", 10)
			--dump(currentRound.side_result_list[2].event_list, "right:", 10)
			--是否是新回合開始
			if not lastRound or currentRound.round ~= lastRound.round then
				self:onNewRoundBegin(currentRound.wait_time, currentRound.side_result_list[1], currentRound.side_result_list[2])

				if self.leftEntity.life == 0 or self.rightEntity.life == 0 then
					if self.leftEntity.life == 0 then
						self.leftEntity:setState(CombatConst.CombatEntityState_Dead)
					end
			
					if self.rightEntity.life == 0 then
						self.rightEntity:setState(CombatConst.CombatEntityState_Dead)
					end

					self:setState(CombatConst.CombatPairState_Story)
					return
				end
			end
		end

		if self.inView and currentRound then
			self.layer:updateUseSkill(self.leftEntity.skillNum)
			if lastRound and currentRound.round ~= lastRound.round then
				self.layer:updateBuffer(self.leftEntity, lastRound.side_result_list[1])
				self.layer:updateBuffer(self.rightEntity, lastRound.side_result_list[2])
			end

			self.layer:updateCombatLayerView(currentRound)
		end
	elseif state == CombatConst.CombatPairState_RunStage then
		self:recycleEntity(self.rightEntity)
		self:setEntityState(CombatConst.CombatEntityState_Run)
		for i=1, #self.deadList do
			self.deadList[i]:remove()
		end

		if self.leftEntity then
			self.leftEntity:newStageStart()
		end

		if self.rightEntity then
			self.rightEntity:newStageStart()
		end

		self.deadList = {}
	elseif state == CombatConst.CombatPairState_JoinPair then
	elseif state == CombatConst.CombatPairState_Attack then
		local attacker = nil
		local defencer = nil
		if self.leftEntity.sideResult.is_attacker then
			log("Left Attack Begin")
			attacker = self.leftEntity
			defencer = self.rightEntity
		else
			log("Right Attack Begin")
			attacker = self.rightEntity
			defencer = self.leftEntity
		end
		
		attacker:runCombatEvent(CombatConst.GameEvent_UseSkill)
		if self.leftEntity.life == 0 or self.rightEntity.life == 0 then
			if self.leftEntity.life == 0 then
				self.leftEntity:setState(CombatConst.CombatEntityState_Dead)
			end
	
			if self.rightEntity.life == 0 then
				self.rightEntity:setState(CombatConst.CombatEntityState_Dead)
			end

			self:setState(CombatConst.CombatPairState_Story)
			return
		end

		local combatRoundFlag = param1.combat_round_flag
		self:onFight(attacker, defencer, combatRoundFlag)
	end
	self.state = state
end

function CombatPair:getMaxRound()
	return self.rounds[#self.rounds].round
end

function CombatPair:getRound()
	if self.rounds[self.roundIndex] then
		if self.rounds[self.roundIndex+1] and self.rounds[self.roundIndex+1].round == self.rounds[self.roundIndex].round then
			return  self.rounds[self.roundIndex].round - 1
		else
			return self.rounds[self.roundIndex].round
		end
	else
		if #self.rounds < self.roundIndex then
			return self.rounds[#self.rounds].round + 1
		end
	end
end

function CombatPair:update(dt)
	local currentRound = self.rounds[self.roundIndex]
	if not self.leftEntity or not self.rightEntity then
		return
	end
	
	if self.leftEntity:getState() == CombatConst.CombatEntityState_Cleanup  then
		table.insert(self.deadList, self.leftEntity)
		self.leftEntity = nil
		self:setState(CombatConst.CombatPairState_End)
	end
	
	if self.rightEntity:getState() == CombatConst.CombatEntityState_Cleanup then
		table.insert(self.deadList, self.rightEntity)
		self.rightEntity = nil
		self:setState(CombatConst.CombatPairState_End)
	end
	
	if not currentRound then
		self:setState(CombatConst.CombatPairState_End)
		return
	end

	self.result = currentRound.result

	if self.state == CombatConst.CombatPairState_BothStandby then
		self.waitTime = self.waitTime + dt
	end

	if self.waitTime >= currentRound.wait_time then
		self:setState(CombatConst.CombatPairState_Attack, currentRound)
		self.waitTime = 0
	end
end

return CombatPair