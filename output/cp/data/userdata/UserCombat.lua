local BaseData = require("cp.data.BaseData")
local UserCombat = class("UserCombat", BaseData)

function UserCombat:create()
    local ret = UserCombat.new() 
    ret:init()
    return ret
end

function UserCombat:init()
	self["challengeCountList"] = {} --今天困難關卡挑戰的次數及重置的次數

	self["fight_enemy_info"] = {}  --與自己戰鬥的人物的訊息(非自己的戰鬥無效)
    local cfg = {

		["normal_chapter_part_id"] = 1000, --普通關卡進度
		["hard_chapter_part_id"] = 1000, --困難關卡進度
		["sweep_count"] = 0,  --今天已經掃蕩的總次數
		["buy_count"] = 0, --今日已購買的掃蕩次數
		["review_type"] = 0, --重看戰鬥類型，1：鏢車被伏擊戰鬥
    }
	self:addProtectedData(cfg)
	self.CombatData = {}
end

function UserCombat:resetFightInfo()
	self["fight_enemy_info"].name = "none"
	self["fight_enemy_info"].place = "none"
	self["fight_enemy_info"].floor = 0
	self["fight_enemy_info"].partID = 0
	self["fight_enemy_info"].difficut = 0
	self["fight_enemy_info"].rank = 0
	self["fight_enemy_info"].hierarchy = 0
	self["fight_enemy_info"].career = -1
end

function UserCombat:updateFightInfo(info)
	if info and next(info) then
		for key,value in pairs(info) do
			self["fight_enemy_info"][key] = value
		end
	end
end

-- 更新關卡進度，挑戰次數，掃蕩次數
function UserCombat:updateChapterPartInfo(type, current_id, hard_level, times)
	if hard_level == 1 then
		if self["challengeCountList"][current_id] == nil then
			self["challengeCountList"][current_id] = {value=times, reset_count = 0}
		else
			self["challengeCountList"][current_id].value = self["challengeCountList"][current_id].value + times
		end
	end

	if "sweep" == type then
		local old_count = self:getValue("sweep_count")
		self:setValue("sweep_count",old_count + times)
	elseif "fight" == type then
		if hard_level == 1 then
			local old_id = self:getValue("hard_chapter_part_id")
			self:setValue("hard_chapter_part_id", math.max(current_id,old_id))
		elseif hard_level == 0 then
			local old_id = self:getValue("normal_chapter_part_id")
			self:setValue("normal_chapter_part_id", math.max(current_id,old_id))
		end	
	end
end

function UserCombat:getNextID(hard_level, partID)
	if not partID then
		partID = 1000
    	if hard_level == 0 then
        	partID = self:getValue("normal_chapter_part_id")
    	else
        	partID = self:getValue("hard_chapter_part_id")
		end
	end
	
	local chapter, part = math.floor(partID/1000), partID%1000

    partID = partID + 1
    local partInfo = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", partID)
    if partInfo == nil then
        chapter = math.floor(partID/1000) + 1
        local chapterConfig = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", chapter*1000)
        if chapterConfig == nil then
            chapter = chapter - 1
            part = partID%1000 - 1
        else
            part = 1
        end
    else
        chapter = math.floor(partID/1000)
        part = partID%1000
	end
	
	return chapter*1000 + part
end

function UserCombat:getChallengeCount(id)
	return self["challengeCountList"][id] == nil and 0 or self["challengeCountList"][id].value
end

function UserCombat:setCombatType(type)
	self.combatType = type
end

function UserCombat:getCombatType()
	return self.combatType
end

--當為章節模式時，為章*1000+節
function UserCombat:setID(id)
	self.id = id
end

function UserCombat:getCombatDifficulty()
	return self.difficulty
end

function UserCombat:setCombatDifficulty(difficulty)
	self.difficulty = difficulty
end

function UserCombat:getID()
	return self.id
end

function UserCombat:setCombatReward(reward)
	reward = reward or {}
	reward.currency_list = reward.currency_list or {}
	self.CombatData.combat_reward = reward
end

function UserCombat:getCombatData()
	if self.CombatData.combat_reward == nil then
		self.CombatData.combat_reward = {}
		self.CombatData.combat_reward.item_list = {}
	end
	return self.CombatData
end

function UserCombat:setCombatResult(result)
	self.CombatData.combat_result = result
end

function UserCombat:isLeftWin()
	return self.CombatData.combat_result.result == 1
end

function UserCombat:setCombatScene(sceneID)
	self.CombatData.scene_id = sceneID
end

function UserCombat:reverseCombatResult()
	if self.CombatData.combat_result.result == 1 then
		self.CombatData.combat_result.result = 2
	elseif self.CombatData.combat_result.result == 2 then
		self.CombatData.combat_result.result = 1
	end

	for _, stageResult in ipairs(self.CombatData.combat_result.stage_result) do
		if stageResult.result == 1 then
			stageResult.result = 2
		elseif stageResult.result == 2 then
			stageResult.result = 1
		end
	
		for _, pairResult in ipairs(stageResult.combat_round_result) do	
			for _, roundResult in ipairs(pairResult.round_result) do
				if roundResult.attacker == 0 then
					roundResult.attacker = 1
				else
					roundResult.attacker = 0
				end

				if roundResult.result == 1 then
					roundResult.result = 2
				elseif roundResult.result == 2 then
					roundResult.result = 1
				end

				local temp = roundResult.side_result_list[1]
				roundResult.side_result_list[1] = roundResult.side_result_list[2]
				roundResult.side_result_list[2] = temp
			end
		end
	end
end


return UserCombat