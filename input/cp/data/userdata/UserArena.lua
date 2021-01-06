local BaseData = require("cp.data.BaseData")
local UserArena = class("UserArena",BaseData)

function UserArena:create()
    local ret =  UserArena.new() 
    ret:init()
    return ret
end

function UserArena:init()
end

function UserArena:getArenaData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local arenaData = self:getValue("ArenaData")
    if arenaData == nil then return nil end
    if today ~= arenaData.day then
        arenaData.last_rank = arenaData.my_rank
        arenaData.day = today
        arenaData.challenge_count = 0
        arenaData.buy_count = 0
        arenaData.buffer_list = {}
        if arenaData.my_rank <= 1500 then
            arenaData.award = false
        else
            arenaData.award = true
        end
    end
    return arenaData
end

function UserArena:updateOpponentList(opponent_list)
    local arenaData = self:getArenaData()
    if arenaData.guide_step == 3 then
        arenaData.guide_step = 4
    end
    arenaData.opponent_list = opponent_list
end

function UserArena:updateBuffer(buffer)
    local arenaData = self:getArenaData()
    local finded = false
    for _, bufferInfo in ipairs(arenaData.buffer_list) do
        if bufferInfo.buffer == buffer then
            bufferInfo.number = bufferInfo.number + 1
            finded = true
            break
        end
    end

    if not finded then
        table.insert(arenaData.buffer_list, {
            buffer = buffer,
            number = 1,
        })
    end
end

function UserArena:updateBuyCount()
    local arenaData = self:getArenaData()
    arenaData.buy_count = arenaData.buy_count + 1
    arenaData.challenge_count = 0
end

function UserArena:updateLastRankReward()
    local arenaData = self:getArenaData()
    arenaData.award = true
end

function  UserArena:getBufferNum( bufferID  )
    local arenaData = self:getArenaData()
    local finded = false
    for _, bufferInfo in ipairs(arenaData.buffer_list) do
        if bufferInfo.buffer == bufferID then
            return bufferInfo.number
        end
    end

    if not finded then
        return 0
    end
end

function  UserArena:updatePlayerRank( rank  )
    local arenaData = self:getArenaData()
    arenaData.my_rank = rank
end

function  UserArena:updateGuideStep( step  )
    local arenaData = self:getArenaData()
    arenaData.guide_step = step
end
return UserArena