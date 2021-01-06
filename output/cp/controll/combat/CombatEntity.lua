local CombatEntity = class("CombatEntity")
local CombatConst = cp.getConst("CombatConst")

--layer為戰鬥的layer
--row為第幾行
--id為ModelID
--side為left或者right
function CombatEntity:ctor(sceneConfig, layer, row, side, sideResult)
	self.layer = layer
	self.sceneConfig = sceneConfig
	self.weapon	=	sideResult.weapon
	self.modelItem = cp.getManager("ConfigManager").getItemByKey("GameModel", sideResult.model_id)
	local modelFile = self.modelItem:getValue("ModelFile")
	local model = cp.getManager("ViewManager").createSpineAnimation(modelFile, self.weapon)
	model:setAnimation(0, self:getSkeletonAnimation("Stand"), true)
    model:registerSpineEventHandler(function(tbl)
        self:onSpineEndEvent(tbl)
	end, 2)
	
	model:registerSpineEventHandler(function(tbl)
		self:onSpineEvent(tbl)
	end, 3)
	
    local leftPos = sceneConfig:getValue("LeftPos")
    local rightPos = sceneConfig:getValue("RightPos")
    local baseY    = sceneConfig:getValue("BaseY")
    local beltaX = sceneConfig:getValue("BeltaX")
    local beltaY = sceneConfig:getValue("BeltaY")
    local beltaScale = sceneConfig:getValue("BeltaScale")/1000
	
	local posX = 0
	local posY = 0
	if side == "left" then
		posX = leftPos + beltaX*(row-1)
		posY = baseY+(row-1)*beltaY
		model:setScale(1-row*beltaScale)
	else
        posX = rightPos + beltaX*(row-1)
		posY = baseY+(row-1)*beltaY
		model:setScale(1-row*beltaScale)
		model:setFlipX(1)
	end

	self.row = row
	self.model = model
	self.side = side
	self.posX = posX
	self.posY = posY
	self.state = CombatConst.CombatEntityState_Idle
	self.skillNum = 1
	self.normalSkill = 11
	self.bufferList = {}
	self.qi = 0
	self.isRunStepAction = false
	self.maxQi = CombatConst.MaxQi

	model:setPosition(cc.p(posX, posY))
	self.layer.rootView:addChild(model, 50 - self.row*5)
end

function CombatEntity:getSkeletonAnimation(motion)
	if motion:find("Attack") then
		local attackIndex = tonumber(motion:sub(#motion) - 1) % self.modelItem:getValue("AttackMotions") + 1
		motion = "Attack"..attackIndex
	end
	
	return motion
end

function CombatEntity:initAttr(sideResult)
	--self.skillList = sideResult.skill_list
	self.normalSkill = sideResult.normal_skill
	self.entityType = sideResult.combat_entity_type
	self.entityName = sideResult.entity_name
	self.skillNum = 1
	self.weapon = sideResult.weapon

	self.life  = sideResult.life
	self.maxLife = sideResult.max_life
	self.force = sideResult.force
	self.maxForce = sideResult.max_force
	self.qi = 0
	self.layer:setNodeBlink(self, 0)
end

function CombatEntity:getNormalSkill()
	return self.normalSkill
end

function CombatEntity:setFightAttr()
	--self.life  = sideResult.life
	self.maxLife = self.sideResult.max_life
	--self.force = sideResult.force
	self.maxForce = self.sideResult.max_force
	--self.qi = sideResult.qi
	self.maxQi = CombatConst.MaxQi
end

function CombatEntity:setZOrder(posZ)
	self.model:setZOrder(posZ)
end

function CombatEntity:getLife()
	return self.life
end

function CombatEntity:runAction(action)
	self.model:runAction(action)
end

function CombatEntity:stopAllActioins()
	self.model:stopAllActions()
end

--武學名字
function CombatEntity:playAttackSound(skillEntry)
	local sex = self.modelItem:getValue("Sex") or 0
	if sex == -1 then
		return
	end
	local sound = string.split(skillEntry:getValue("Sound"), ":")[sex+1]
	sound = tonumber(sound)
	if not sound or sound == 0 then
		return
	end

	local soundEntry = cp.getManager("ConfigManager").getItemByKey("GameSound", sound)
	if not soundEntry then
		return
	end
	local soundPath = soundEntry:getValue("path")
	
	--log("play attack sound:"..soundPath)
	cp.getManager("AudioManager"):playEffect(soundPath, false)
end

function CombatEntity:playDefenceSound()
	local sound = self.modelItem:getValue("DefenceSound")
	if not sound or #sound == 0 then
		return
	end

	local soundPath = string.format("model/%s.mp3", sound)
	--log("play defence sound:"..soundPath)
	cp.getManager("AudioManager"):playEffect(soundPath, false)
end

--根據武學類型，載入武學聲音
function CombatEntity:loadSkillSound(skillEntry, suffix)
	local soundPath = string.format("skill/%s_%02d.mp3", CombatConst.SkillType_Sound[skillEntry:getValue("Serise")], suffix)
	--log("play defence sound:"..soundPath)
	cp.getManager("AudioManager"):playEffect(soundPath, false)
end

function CombatEntity:playDeadEffect()
	local sound = self.modelItem:getValue("DeadSound")
	if not sound or #sound == 0 then
		return
	end

	local soundPath = string.format("model/%s.mp3", sound)
	--log("play death sound:"..soundPath)
	cp.getManager("AudioManager"):playEffect(soundPath, false)
end

function CombatEntity:runStepAction(act, param)
	self.stepActionSequence = self.stepActionSequence or {}
	table.insert(self.stepActionSequence, act)
	if not self.isRunStepAction then
		self.isRunStepAction = true
		self.model:runAction(cc.Sequence:create(act, cc.CallFunc:create(function()
			if type(param) == "function" then
				param()
			elseif type(param) == "number" then
				self:setState(param)
			end
			self:stepActionFinished()
		end)))
	end
end

function CombatEntity:stepActionFinished()
	table.arrShift(self.stepActionSequence)
	local act = self.stepActionSequence[1]
	if not act then
		self.isRunStepAction = false
	else
		self:runStepAction(act)
	end
end

function CombatEntity:setState(state, flag)
	--log(self.side.." try to transation from "..self.state.." to "..state)
	if self.state == state then
		return
	end

	if self.state == CombatConst.CombatEntityState_Run
		or self.state == CombatConst.CombatEntityState_Forward 
		or self.state == CombatConst.CombatEntityState_FallBack then
			self.model:setToSetupPose()
	end

	if state == CombatConst.CombatEntityState_Idle then
		--如果是跑過去打，在fallback判斷
		if self.life == 0 then
			if not self.sideResult.is_attacker then
				self:setState(CombatConst.CombatEntityState_Dead)
			end
			return
		end
		self:setZOrder(50-self.row*5)
		if self.state == CombatConst.CombatEntityState_Dodge then
			self.model:addAnimation(0, self:getSkeletonAnimation("Stand"), true)
		else
			self.model:setAnimation(0, self:getSkeletonAnimation("Stand"), true)
		end
	elseif state == CombatConst.CombatEntityState_Forward then
		if self.useSkill:getValue("Target") == 0 then
			self:setState(CombatConst.CombatEntityState_Spell)
			return
		end
		
		self.model:setAnimation(0, self:getSkeletonAnimation("Run"), true)
		local newPosY  = self.posY
		local newPosX  = self.posX + 300
		if self.side == "right" then
			newPosX = self.posX - 300
		end
		self:runStepAction(cc.MoveTo:create(0.15, cc.p(newPosX, newPosY)), CombatConst.CombatEntityState_Spell)
	elseif state == CombatConst.CombatEntityState_FallBack then
		if self.life == 0 then
			self:playDeadEffect()
			self.model:setAnimation(0, self:getSkeletonAnimation("Death"), false)
			self.pair:setState(CombatConst.CombatPairState_Story)
			return
		end
		
		if self.state == CombatConst.CombatEntityState_DeadAlive then
			return
		end

		if self.useSkill:getValue("Target") == 1 then
			self.model:setAnimation(0, self:getSkeletonAnimation("Back"), false)
			self:runStepAction(cc.MoveTo:create(0.25, cc.p(self.posX, self.posY)), function()
				if self.attackEnd then
					self.pair:setState(CombatConst.CombatPairState_Story)
				else
					self.pair:setEntityState(CombatConst.CombatEntityState_Idle)
					self.attackEnd = true
				end
			end)
		else
			self.pair:setState(CombatConst.CombatPairState_Story)
			self:setState(CombatConst.CombatEntityState_Idle)
			return
		end
	elseif state == CombatConst.CombatEntityState_Dead then
		if self.state < 0 then
			return
		end
		self:playDeadEffect()
		self.model:setAnimation(0, self:getSkeletonAnimation("Death"), false)
	elseif state == CombatConst.CombatEntityState_DeadAlive then
		self:playDeadEffect()
		self.model:setAnimation(0, self:getSkeletonAnimation("Death"), false)
	elseif state == CombatConst.CombatEntityState_Spell then
		self:onAttack()
	elseif state == CombatConst.CombatEntityState_Defence then
		self.model:setAnimation(0, self:getSkeletonAnimation("Hit"), false)
	elseif state == CombatConst.CombatEntityState_Dodge then
		local offset = 20
		if self.side == "left" then
			offset = -20
		end
		self:runStepAction(cc.Sequence:create(
			cc.MoveTo:create(0.1, cc.p(self.posX + offset, self.posY)),
			cc.DelayTime:create(0.5),
			cc.MoveTo:create(0.1, cc.p(self.posX, self.posY))
		), CombatConst.CombatEntityState_Idle)
	elseif state == CombatConst.CombatEntityState_Parry then
		self.model:setAnimation(0, self:getSkeletonAnimation("Block"), false)
	elseif state == CombatConst.CombatEntityState_Jump then
		self.model:setAnimation(0, self:getSkeletonAnimation("Jump"), false)
		self.model:addAnimation(0, self:getSkeletonAnimation("Stand"), true)
	elseif state == CombatConst.CombatEntityState_Run then
		self.model:setAnimation(0, self:getSkeletonAnimation("Run"), true)
	elseif state == CombatConst.CombatEntityState_Into then
		self.model:setAnimation(0, self:getSkeletonAnimation("Into"), false)
		self.model:addAnimation(0, self:getSkeletonAnimation("Stand"), true)
	elseif state == CombatConst.CombatEntityState_Win then
		if state == CombatConst.CombatEntityState_Dead or state == CombatConst.CombatEntityState_Cleanup then
			return
		end
		self.model:setAnimation(0, self:getSkeletonAnimation("Win").."_start", false)
		self.model:addAnimation(0, self:getSkeletonAnimation("Win").."_loop", true)
	end

	self.state = state
end

function CombatEntity:setPositionX(x)
	self.model:setPosition(cc.p(x, self.posY))
end

function CombatEntity:getState()
	return self.state
end

function CombatEntity:onAttack()
	local isDoubleHit = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_DoubleHit)
	if self.sideResult.is_attacker and isDoubleHit == 0 then
		self.skillNum = self.skillNum + 1
	end

	self:setZOrder(50-self.row*5+1)
	if self.useSkill:getValue("Target") == 0 then
		self.model:setAnimation(0, self.useSkill:getValue("MotionTag"), false)
	else
		self.model:setAnimation(0, self:getSkeletonAnimation(self.useSkill:getValue("MotionTag")), false)
	end

	self:loadSkillSound(self.useSkill, 1)
	self:playAttackSound(self.useSkill)
	self:setFightAttr(self.sideResult)
	
	self:runCombatEvent(CombatConst.GameEvent_AddBuffer)
	self.target:runCombatEvent(CombatConst.GameEvent_AddBuffer)
	self:runCombatEvent(CombatConst.GameEvent_ChangeBuffer)
	self.target:runCombatEvent(CombatConst.GameEvent_ChangeBuffer)
end

function CombatEntity:onDefence(skillEntry)
	local isCritic = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_Critic)
	local isParry = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_Parry)
	local isDodge = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_Dodge)
	
	self.layer:updateLife(self, 0.1, -self.sideResult.hurt, self.sideResult.max_life)
	
	if self.sideResult.is_attacker then
		isCritic = 0
		isDodge = 0
		isParry = 0
	end

	self:setZOrder(50-self.row*5)

	if isDodge > 0 then
		self:createAttackInfo("閃避", CombatConst.EffectType_Dodge)
		self:setState(CombatConst.CombatEntityState_Dodge)
	end

	if isParry == 0 then
		--cp.getManager("AudioManager"):playEffect("skill/attack_10.mp3", false)
		self:playDefenceSound()
		if isDodge == 0 then
			self:setState(CombatConst.CombatEntityState_Defence)
		end
	else
		self:createAttackInfo("招架", CombatConst.EffectType_Parry)
		self:setState(CombatConst.CombatEntityState_Parry)
	end

	if isCritic > 0 then
		self:createHurtInfo(self.sideResult.hurt, CombatConst.EffectType_Critic)
	else
		if isDodge == 0 then
			self:createHurtInfo(self.sideResult.hurt, nil)
		end
	end
	
	self.target:runCombatEvent(CombatConst.GameEvent_Critic)
	self:runCombatEvent(CombatConst.GameEvent_BeCritic)
	self.target:runCombatEvent(CombatConst.GameEvent_Hurt)
	self:runCombatEvent(CombatConst.GameEvent_BeHurt)
	self.target:runCombatEvent(CombatConst.GameEvent_CalHurt)
	self:runCombatEvent(CombatConst.GameEvent_CalBeHurt)
	self.target:runCombatEvent(CombatConst.GameEvent_Attack)
	self:runCombatEvent(CombatConst.GameEvent_BeAttack)

	self.target:runCombatEvent(CombatConst.GameEvent_Batter)
	self:runCombatEvent(CombatConst.GameEvent_BeBatter)

	self.target:loadSkillSound(skillEntry, 2)
	self:setFightAttr()
end

function CombatEntity:addLife(life)
end

function CombatEntity:subLife(life)
end

function CombatEntity:addForce(force)
end

function CombatEntity:subForce(force)
end

--buffer列表是否含有某個元素
function CombatEntity:getElemStatus(elem)
	local value = 0
	local percent = 0
	for _, bufferInfo in pairs(self.bufferList) do
		for _, elementInfo in ipairs(bufferInfo.elements) do
			if elem == elementInfo.id then
				value = value + elementInfo.value
			elseif elem < 50 and elementInfo.id == elem + 50 then
				percent = percent + elementInfo.value
			end
		end
	end

	if value == 0 and percent == 0 then
		return 0
	elseif value < 0 or percent < 0 then
		return -1
	else
		return 1
	end
end

function CombatEntity:runEntityElement(elementList)
	local target = 0
	for _, elementInfo in ipairs(elementList) do
		if elementInfo.id == 158 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 162 then--life host
			self.layer:updateLife(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 165 then--life host
			self.layer:updateLife(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 166 then--force host
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 167 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 168 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 169 then--life host
			self.layer:updateLife(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 170 then--force host
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 171 then--force host
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 172 then--force target host
			self.layer:updateForce(self, 0.1, elementInfo.value)
			self.layer:updateForce(self.target, 0.1, elementInfo.extra)
			target = 1
		elseif elementInfo.id == 173 then--life host
			self.layer:updateLife(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 174 then--force target
			self.layer:updateForce(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 176 then--force host
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 177 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 178 then--qi host
			self.layer:updateQi(self, nil, elementInfo.value)
		elseif elementInfo.id == 179 then--qi target
			self.layer:updateQi(self.target, nil, elementInfo.value)
			target = 1
		elseif elementInfo.id == 187 then--qi target
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 194 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 195 then--life host
			self.layer:updateLife(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 197 then--force host
			self.layer:updateForce(self, 0.1, elementInfo.value)
		elseif elementInfo.id == 199 then--life target
			self.layer:updateLife(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 200 then--life host target
			self.layer:updateLife(self, 0.1, elementInfo.value)
			self.layer:updateLife(self.target, 0.1, elementInfo.extra)
		elseif elementInfo.id == 201 then--force target
			self.layer:updateForce(self.target, 0.1, elementInfo.value)
			target = 1
		elseif elementInfo.id == 203 then--remove host buffer
			self.layer:removeBuffer(self, elementInfo.value)
		end
	end

	return target
end

function CombatEntity:findoutPermanentElement(eventEntry, elementList)
	local lElementList, rElementList = {}, {}
	for _, elementInfo in ipairs(elementList) do
		local elementListEntry = cp.getUtils("DataUtils").split(eventEntry:getValue("LoadElements"), ";=")
		local flag = true
		for _, elementEntry  in ipairs(elementListEntry) do
			if elementEntry[1] == elementInfo.id then
				table.insert(lElementList, elementInfo)
				flag = false
			end
		end
		if flag then
			table.insert(rElementList, elementInfo)
		end
	end
	return lElementList, rElementList
end

function CombatEntity:runLoadElements(eventList)
	for _, combatEvent in ipairs(self.sideResult.event_list) do
		local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", combatEvent.event_id)
		local elementList = self:findoutPermanentElement(eventEntry, combatEvent.element_list)
		if eventEntry and table.indexof(eventList, combatEvent.event_id) and #elementList > 0  then
			local entity = nil
			local target = self:runEntityElement(elementList)
			if target == 0 then
				entity = self
			else
				entity = self.target
			end

			if eventEntry:getValue("ShowName"):len() > 0 then
				local showDesc = cp.getUtils("DataUtils").formatBufferElement(eventEntry:getValue("ShowName"), elementList)
				if combatEvent.event_type == 4 then
					if combatEvent.event_owner > 0 then
						self:createBufferEffectInfo(combatEvent.event_owner, showDesc, eventEntry:getValue("ShowColor"))
					end
				else
					entity:createEffectInfo(showDesc, eventEntry:getValue("ShowColor"))
				end
			end
		end
	end
end

function CombatEntity:runPrimevalEffect(eventEntry, combatEvent)
	local primevalID = eventEntry:getValue("Primeval")
	if primevalID == 0 then
		return
	end
	
	if primevalID == 12 and combatEvent.element_list[1].value == 0 then
		return 
	end

	local metaEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", primevalID)
	self.layer:showPrimevalEffect(self.side, metaEntry)
end

function CombatEntity:runCombatEvent(event)
	local eventList = self.sideResult.event_list
	for _, combatEvent in ipairs(eventList) do
		local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", combatEvent.event_id)
		local _, rElementList = self:findoutPermanentElement(eventEntry, combatEvent.element_list)
		if eventEntry and eventEntry:getValue("Event") == event and #rElementList > 0 then
			local entity = nil
			local target = self:runEntityElement(rElementList)
			if target == 0 then
				entity = self
			else
				entity = self.target
			end

			self:runPrimevalEffect(eventEntry, combatEvent)

			if eventEntry:getValue("ShowName"):len() > 0 then
				local showDesc = cp.getUtils("DataUtils").formatBufferElement(eventEntry:getValue("ShowName"), rElementList)
				if combatEvent.event_type == 4 then
					if combatEvent.event_owner > 0 then
						self:createBufferEffectInfo(combatEvent.event_owner, showDesc, eventEntry:getValue("ShowColor"))
					end
				else
					entity:createEffectInfo(showDesc, eventEntry:getValue("ShowColor"))
				end
			end
		end
	end
end

function CombatEntity:getAnimationType(animation)
	if string.find(animation, "Attack") or string.find(animation, "Finger") or string.find(animation, "Martial") then
		return CombatConst.CombatEntityState_Spell
	elseif string.find(animation, "Death") then
		if self.state == CombatConst.CombatEntityState_DeadAlive then
			return CombatConst.CombatEntityState_DeadAlive
		elseif self.state == CombatConst.CombatEntityState_Dead then
			return CombatConst.CombatEntityState_Dead
		end
	elseif string.find(animation, "Hit") then
		return CombatConst.CombatEntityState_Defence
	elseif string.find(animation, "Block") then
		return CombatConst.CombatEntityState_Parry
	end

	return -100
end

function CombatEntity:onSpineEndEvent(tbl)
	local posY = self.posY+50
	--dump(tbl)
	if self:getAnimationType(tbl.animation) == CombatConst.CombatEntityState_Spell then
		self.pair:checkEntityDead()
		if self.state ~= CombatConst.CombatEntityState_Spell then
			return
		end
		--if self.target:getLife() == 0 then
		--	self.target:setState(CombatConst.CombatEntityState_Dead)
		--end

		local isParry = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_Parry)
		if self.sideResult.is_attacker then
			if isParry ~= 0 then
				self:setState(CombatConst.CombatEntityState_Idle)
			else
				self:setState(CombatConst.CombatEntityState_FallBack)
			end
		else
			if isParry ~= 0 then
				self.target:setState(CombatConst.CombatEntityState_FallBack)
			end
			self:setState(CombatConst.CombatEntityState_Idle)
		end
	elseif self:getAnimationType(tbl.animation) == CombatConst.CombatEntityState_DeadAlive then
		--self.pair:checkEntityDead()

		local isParry = bit.band(self.combatRoundFlag, CombatConst.CombatRoundFlag_Parry)
		if self.sideResult.is_attacker then
			self:setState(CombatConst.CombatEntityState_FallBack)
		else
			self:setState(CombatConst.CombatEntityState_Idle)
		end
	elseif self:getAnimationType(tbl.animation) == CombatConst.CombatEntityState_Defence then
		self:setState(CombatConst.CombatEntityState_Idle)
	elseif self:getAnimationType(tbl.animation) == CombatConst.CombatEntityState_Parry then
		self:setState(CombatConst.CombatEntityState_Spell)
	elseif self:getAnimationType(tbl.animation) == CombatConst.CombatEntityState_Dead then
		local cleanupTime = self.sceneConfig:getValue("CleanupTime")
		self.model:runAction(cc.Sequence:create(cc.DelayTime:create(cleanupTime),
			cc.CallFunc:create(function()
				if self.model and self.state == CombatConst.CombatEntityState_Cleanup then
					self.model:removeFromParent()
					self.model = nil
				end
		end)))
		self:setState(CombatConst.CombatEntityState_Cleanup)
	elseif self.state == CombatConst.CombatEntityState_Run then
		--self.model:setToSetupPose()
	elseif self.state == CombatConst.CombatEntityState_Into then
		self:setState(CombatConst.CombatEntityState_Idle)
		if self.target.state ~= CombatConst.CombatEntityState_Into then
			self.pair:setState(CombatConst.CombatPairState_Story)
		end
	else
	end
end

function CombatEntity:onSpineEvent(event)
	if event.eventData.name == "effect1" then
		self.attackEnd = false
		--self.pair:checkEntityDead()
		if self.useSkill:getValue("Target") == 1 then
			self.target:onDefence(self.useSkill)
		end
		
		self:loadSkillAttackEffect(self.useSkill)

		if self.sideResult.is_attacker then
			self.layer:addBuffers(self.target, self.target.sideResult.buffer_list)
			self.layer:addBuffers(self, self.sideResult.buffer_list)
			self.layer:updateForce(self, 0.1, -self.sideResult.cost_force, self.sideResult.max_force)
		end
   end
end

function CombatEntity:newStageStart()
	self.bufferList = {}
end

function CombatEntity:loadSkillAttackEffect(skillEntry)
	if not skillEntry then
		return
	end

	local effectID = skillEntry:getValue("AttackEffect")
	if not effectID or effectID == 0 then
		self.attackEnd = true
		return
	end

	local effectEntry = cp.getManager("ConfigManager").getItemByKey("SkillEffect", effectID)
	local effectFileName = effectEntry:getValue("EffectFile")
	local deltaX = effectEntry:getValue("EffectPosX")
	local deltaY = effectEntry:getValue("EffectPosY")
	local fileName = "res/img/effect/"..effectFileName.."/"..effectFileName
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(fileName..".plist", fileName..".png")
	local framePath = ""
	self.attackEffect0 = cc.Sprite:create()
	self.attackEffect0:setAnchorPoint(cc.p(0.5,0))
	self.attackEffect0:setScale(cp.getConst("GameConst").EffectScale)
	self.attackEffect1 = cc.Sprite:create()
	self.attackEffect1:setAnchorPoint(cc.p(0.5,0))
	self.attackEffect1:setScale(cp.getConst("GameConst").EffectScale)
	local animation0 = cc.Animation:create()
	local animation1 = cc.Animation:create()
	local frameStep = effectEntry:getValue("FrameStep") + 1
	local frameList0 = {}
	local frameList1 = {}
	local maxFrame = 0
	local lastFrame0, lastFrame1
	for i=0, 60 do
		if i%frameStep == 0 then
			framePath = string.format("%s_0_%d.png", effectFileName, i)
			--log(framePath)
			local frame0 = frameCache:getSpriteFrame(framePath)
			if frame0 then
				table.insert(frameList0, frame0)
				lastFrame0 = frame0
			else
				if lastFrame0 then
					table.insert(frameList0, lastFrame0)
				else
					table.insert(frameList0, false)
				end
			end
			
			framePath = string.format("%s_1_%d.png", effectFileName, i)
			--log(framePath)
			local frame1 = frameCache:getSpriteFrame(framePath)
			if frame1 then
				table.insert(frameList1, frame1)
				lastFrame1 = frame1
			else
				if lastFrame1 then
					table.insert(frameList1, lastFrame1)
				else
					table.insert(frameList1, false)
				end
			end

			if frame0 or frame1 then
				maxFrame = i + 1
			end
		end
	end

	for i=1, math.floor(maxFrame/frameStep) do
		local frame0 = frameList0[i]
		if not frame0 then
			animation0:addSpriteFrameWithFile("res/img/effect/alpha_0.png")
		else
			animation0:addSpriteFrame(frame0)
		end
		
		local frame1 = frameList1[i]
		if not frame1 then
			animation1:addSpriteFrameWithFile("res/img/effect/alpha_0.png")
		else
			animation1:addSpriteFrame(frame1)
		end
	end

	animation0:setDelayPerUnit(effectEntry:getValue("DelayPerUnit"))
	animation1:setDelayPerUnit(effectEntry:getValue("DelayPerUnit"))
	animation0:setLoops(1)
	animation1:setLoops(1)

	self.attackEffect0:runAction(cc.Sequence:create(cc.Animate:create(animation0), cc.CallFunc:create(function()
		self.attackEffect0:removeFromParent()
		self.attackEffect0 = nil
	end)))
	self.attackEffect1:runAction(cc.Sequence:create(cc.Animate:create(animation1), cc.CallFunc:create(function()
		self.attackEffect1:removeFromParent()
		self.attackEffect1 = nil
		if self.attackEnd then
			self.pair:setState(CombatConst.CombatPairState_Story)
		else
			self.attackEnd = true
		end
	end)))

	self.layer.rootView:addChild(self.attackEffect0, 1)
	self.layer.rootView:addChild(self.attackEffect1, 50)
	if self.side == "left" then
		self.attackEffect0:setPosition(cc.p(self.model:getPositionX() + deltaX, 
			self.model:getPositionY() + deltaY))
		self.attackEffect1:setPosition(cc.p(self.model:getPositionX() + deltaX, 
			self.model:getPositionY() + deltaY))

		if effectEntry:getValue("Side") ~= 0 then
			self.attackEffect0:setFlipX(true)
			self.attackEffect1:setFlipX(true)
		end
	else
		self.attackEffect0:setPosition(cc.p(self.model:getPositionX() - deltaX, 
			self.model:getPositionY() + deltaY))
		self.attackEffect1:setPosition(cc.p(self.model:getPositionX() - deltaX, 
			self.model:getPositionY() + deltaY))

		if effectEntry:getValue("Side") ~= 1 then
			self.attackEffect0:setFlipX(true)
			self.attackEffect1:setFlipX(true)
		end
	end

	--[[
	local size = self.attackEffect0:getContentSize()
	cp.getManager("ViewManager").setShader(self.attackEffect0, "WaterWave", function(glps)
		local glProgram = glps:getGLProgram()
		local loc = gl.getUniformLocation(glProgram, "u_width")
		glps:setUniformFloat(loc, size.width)
		loc = gl.getUniformLocation(glProgram, "u_height")
		glps:setUniformFloat(loc, size.height)
	end)

	local size = self.attackEffect1:getContentSize()
	cp.getManager("ViewManager").setShader(self.attackEffect1, "WaterWave", function(glps)
		local glProgram = glps:getGLProgram()
		local loc = gl.getUniformLocation(glProgram, "u_width")
		glps:setUniformFloat(loc, size.width)
		loc = gl.getUniformLocation(glProgram, "u_height")
		glps:setUniformFloat(loc, size.height)
	end)
	]]
end

function CombatEntity:remove()
	if self.model then
		self.model:removeFromParent()
		self.model = nil
		return true
	end

	return false
end

function CombatEntity:createHurtInfo(hurt, effectType)
	local img = nil
	if effectType == CombatConst.EffectType_Critic then
		img = self.layer.Image_Critic:clone()
	else
		img = self.layer.Image_Hurt:clone()
	end
	
	self.layer.rootView:addChild(img, 100)
	local txtHurt = img:getChildByName("Text_Hurt")
	txtHurt:setString(hurt)

	local posX = self.model:getPositionX()
	local posY = self.posY+250

	if self.side == "left" then
		posX = posX + 50
	else
		posX = posX - 50
	end

	if effectType == CombatConst.EffectType_Critic then
		posY = posY + 20
		img:setPosition(cc.p(posX, posY))
		img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.5, 1.5),cc.ScaleTo:create(0.1, 1.2, 1.2), cc.DelayTime:create(0.8), cc.CallFunc:create(function()
			img:removeFromParent()
		end)))
	else
		img:setPosition(cc.p(posX, posY))
		img:runAction(cc.Sequence:create(cc.MoveTo:create(0.8, cc.p(posX, posY+10)), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
			img:removeFromParent()
		end)))
	end

	return img
end

function CombatEntity:createBufferEffectInfo(index, txt, showColor)
	showColor = string.split(showColor, ",")
	local color = {}
	if #showColor == 3 then
		color.x = tonumber(showColor[1])/255
		color.y = tonumber(showColor[2])/255
		color.z = tonumber(showColor[3])/255
	end
	local listView = nil
	if self.side == "left" then
		listView = self.layer.ListView_LeftBuffer
	else
		listView = self.layer.ListView_RightBuffer
	end
	
	local name = "Button_"..index
	local btn = listView:getChildByName(name)
	if not btn then
		log("btn not exist, side="..self.side..",name="..name)
		return
	end
	local img = btn:getChildByName("Image_BufferEvent")
	img:stopAllActions()
	local txtEffect = img:getChildByName("Text_Effect")
	txtEffect:setString(txt)

	if color.x and color.y and color.z then
        txtEffect:setTextColor(cc.c4b(color.x*255,color.y*255,color.z*255,255))
	end

	local sz = txtEffect:getVirtualRendererSize()
	img:setSize(cc.size(sz.width+86, 50))
	txtEffect:setPosition((sz.width+86)/2, 24)
	if self.side == "left" then
		cp.getManager("ViewManager").runStepAction(img, cc.Sequence:create(cc.CallFunc:create(function()
				img:setVisible(true)
				img:setPosition(cc.p(-200, 35))
			end),
			cc.MoveTo:create(0.2, cc.p(60, 35)), cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				img:setVisible(false)
			end)
		))
	else
		cp.getManager("ViewManager").runStepAction(img, cc.Sequence:create(cc.CallFunc:create(function()
				img:setVisible(true)
				img:setPosition(cc.p(300, 35))
			end), 
			cc.MoveTo:create(0.2, cc.p(0, 35)), cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				img:setVisible(false)
			end)
		))
	end

	return img
end

function CombatEntity:createEffectInfo(txt, showColor)
	showColor = showColor or ""
	showColor = string.split(showColor, ",")
	local color = {}
	if #showColor == 3 then
		color.x = tonumber(showColor[1])/255
		color.y = tonumber(showColor[2])/255
		color.z = tonumber(showColor[3])/255
	end
	local img = self.layer.Image_Event:clone()
	self.layer.rootView:addChild(img, 100)
	local txtEffect = img:getChildByName("Text_Effect")
	txtEffect:setString(txt)
	if color.x and color.y and color.z then
        txtEffect:setTextColor(cc.c4b(color.x*255,color.y*255,color.z*255,255))
	end

	local sz = txtEffect:getVirtualRendererSize()
	img:setSize(cc.size(sz.width+86, 50))
	img:setRotation(-10)
	img:setVisible(false)
	txtEffect:setPosition((sz.width+86)/2, 24)

	local posX = self.model:getPositionX()
	local head = self[self.side.."_Effect_"..posX]
	if head then
		local tail = head
		while tail.next do
			tail = tail.next
		end
		tail.next = img
		return
	else
		head = img
		self[self.side.."_Effect_"..posX] = head
	end

	--local next = head.next
	self:showEffectInfo(head, posX, true)
	--[[
	img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.ScaleTo:create(0.1, 1.0), cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		img:removeFromParent()
	end)))
	]]

	return img
end

function CombatEntity:showEffectInfo(img, originPosX, isFirst)
	if not img then
		return
	end

	if not originPosX then
		log("Break")
	end
	
	local initScale = 0.4
	local middleScale = 0.8
	local hideScale = 0.4
	local showTime = 0.5
	local posX = originPosX
	local posY = self.posY+350
	local spawnTime = 0.1
	if self.side == "left" then
		posX = posX + 50
	else
		posX = posX - 50
	end

	local deltaX = 15
	local deltaY = 15
	local sequence = {}
	img:setVisible(true)
	img:setPosition(posX, posY)
	img:setScale(initScale)
	if isFirst then
		table.insert(sequence, cc.ScaleTo:create(spawnTime, 1, 1))
	else
		table.insert(sequence, cc.Spawn:create(
			cc.MoveTo:create(spawnTime, cc.p(posX+deltaX,posY-deltaY)),
			cc.ScaleTo:create(spawnTime, middleScale, middleScale)))
		table.insert(sequence, cc.Spawn:create(
			cc.MoveTo:create(spawnTime, cc.p(posX,posY)),
			cc.ScaleTo:create(spawnTime, 1, 1)))
	end
	table.insert(sequence, cc.DelayTime:create(showTime))
	table.insert(sequence, cc.CallFunc:create(function()
		self[self.side.."_Effect_"..originPosX] = img.next
		self:showEffectInfo(img.next, originPosX)
		if not img.next then
			img:removeFromParent()
		end
	end))
	table.insert(sequence, cc.Spawn:create(
		cc.MoveTo:create(spawnTime, cc.p(posX-deltaX,posY+deltaY)),
		cc.ScaleTo:create(spawnTime, middleScale, middleScale)))
	table.insert(sequence, cc.Spawn:create(
		cc.MoveTo:create(spawnTime, cc.p(posX,posY)),
		cc.ScaleTo:create(spawnTime, hideScale, hideScale)))
	table.insert(sequence, cc.CallFunc:create(function()
		img:removeFromParent()
	end))
	img:runAction(cc.Sequence:create(sequence))
end

function CombatEntity:createAttackInfo(txt, effectType)
	local img = nil
	if effectType == CombatConst.EffectType_Parry then
		img = self.layer.Image_Parry:clone()
	elseif effectType == CombatConst.EffectType_Batter then
		img = self.layer.Image_Other:clone()
		img:loadTexture("ui_combat_module03_battle_lianji.png", ccui.TextureResType.plistType)
	elseif effectType == CombatConst.EffectType_Dodge then
		img = self.layer.Image_Other:clone()
		img:loadTexture("ui_combat_module03_battle_anniu_shanbi.png", ccui.TextureResType.plistType)
	else
		return
	end

	self.layer.rootView:addChild(img, 100)
	local posX = self.model:getPositionX()
	local posY = self.posY+200

	local imgText = img:getChildByName("Image_Text")
	if self.side == "left" then
		posX = posX + 75
	else
		if effectType == CombatConst.EffectType_Parry then
			img:setFlippedX(true)
			imgText:setFlippedX(true)
		end
		posX = posX - 75
	end

	img:setPosition(cc.p(posX, posY))
	img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.0), cc.DelayTime:create(0.8), cc.FadeOut:create(0.2),cc.CallFunc:create(function()
		img:removeFromParent()
	end)))

	return img
end

return CombatEntity