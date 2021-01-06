local BaseData = require("cp.data.BaseData")
local UserMountain = class("UserMountain",BaseData)

function UserMountain:create()
    local ret =  UserMountain.new() 
    ret:init()
    return ret
end

function UserMountain:init()
end

function UserMountain:getPhaseStateInfo(phaseState)
    local phaseStateList = self:getValue("PhaseStateList")
    local phaseStateInfo = nil
    for _, phaseStateInfo in ipairs(phaseStateList) do
        if phaseStateInfo.phase_state == phaseState then
            return phaseStateInfo
        end
    end
end

function UserMountain:getGuessState(phaseState, id)
    return false
end

function UserMountain:getPhaseGuessList(phaseState)
    local mountainData = self:getValue("MountainData")
    if not mountainData then
        return {}
    end
    for _, guessInfo in ipairs(mountainData.guess_list) do
        if guessInfo.phase_state == phaseState then
            return guessInfo.player_list
        end
    end

    return {}
end

function UserMountain:updateSignState()
    local mountainData = self:getValue("MountainData")
    mountainData.signed = true
end

function UserMountain:updatePhaseState(phaseInfo)
    local phaseStateList = self:getValue("PhaseStateList")
    local phaseStateInfo = nil
    for i, phaseStateInfo in ipairs(phaseStateList) do
        if phaseStateInfo.phase_state == phaseInfo.phase_state then
            phaseStateList[i] = phaseInfo
            return
        end
    end
    
    table.insert(phaseStateList, phaseInfo)
end

function UserMountain:updatePhaseStatePairInfo(phaseInfo)
    local phaseStateList = self:getValue("PhaseStateList")
    local phaseStateInfo = nil
    for i, phaseStateInfo in ipairs(phaseStateList) do
        if phaseStateInfo.phase_state == phaseInfo.phase_state then
            phaseStateList[i].round_list = phaseInfo.round_list
            break
        end
    end
end

function UserMountain:updatePhaseStateGuess(phaseState, id)
    local mountainData = self:getValue("MountainData")
    for i, guessInfo in ipairs(mountainData.guess_list) do
        if guessInfo.phase_state == phaseState then
            table.insert(guessInfo.player_list, id)
            return
        end
    end

    table.insert(mountainData.guess_list, {
        phase_state = phaseState,
        player_list = {
            id
        },
    })
end

function UserMountain:updateGuideStep(step)
    local mountainData = self:getValue("MountainData")
    mountainData.guide_step = step
end
return UserMountain