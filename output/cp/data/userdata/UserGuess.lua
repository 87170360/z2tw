local BaseData = require("cp.data.BaseData")
local UserGuess = class("UserGuess", BaseData)

function UserGuess:create()
    local ret = UserGuess.new() 
    ret:init()
    return ret
end

function UserGuess:init()
end

function UserGuess:judgeGuessFinger(leftFinger, rightFinger)
    if leftFinger < rightFinger then
        if rightFinger - leftFinger == 1 then
            return 1
        else
            return -1
        end
    elseif leftFinger > rightFinger then
        if leftFinger - rightFinger == 1 then
            return -1
        else
            return 1
        end
    end
    
    return 0
end

function UserGuess:getGuessFingerData()
    local guessFingerData = self:getValue("GuessFingerData")
    if not guessFingerData then return nil end
    local today = cp.getManager("TimerManager"):getTime()
    if guessFingerData.day > 0 and today > guessFingerData.day then
        guessFingerData.day = 0
        guessFingerData.opponent_info = {}
        guessFingerData.round = 1
        guessFingerData.is_over = false
        guessFingerData.wine_flag = {0,0,0,0,0,0}
        guessFingerData.drink_point = {}
        guessFingerData.guess_list = {
            {
                finger_list = {},
                drink_point = 0
            },
            {
                finger_list = {},
                drink_point = 0
            }
        }
    end

    return guessFingerData
end

function UserGuess:updateDrinkPoint(winePoint, drinkPoint, wineIndex)
    local guessFingerData = self:getValue("GuessFingerData")
    local leftGuess = guessFingerData.guess_list[1]
    local rightGuess = guessFingerData.guess_list[2]
    local result = self:judgeGuessFinger(leftGuess.finger_list[guessFingerData.round], rightGuess.finger_list[guessFingerData.round])
    if result == 1 then
        rightGuess.drink_point = drinkPoint
    else
        leftGuess.drink_point = drinkPoint
    end
    guessFingerData.wine_flag[wineIndex+1] = winePoint
    guessFingerData.round = guessFingerData.round + 1
    log(guessFingerData.wine_flag)
    return result
end

function UserGuess:updateGuessFinger(selfFinger, opponentFinger)
    local guessFingerData = self:getGuessFingerData()
    local leftGuess = guessFingerData.guess_list[1]
    local rightGuess = guessFingerData.guess_list[2]
    if self:judgeGuessFinger(selfFinger,opponentFinger) ~= 0 then
        table.insert(leftGuess.finger_list, selfFinger)
        table.insert(rightGuess.finger_list, opponentFinger) 
    end
end

function  UserGuess:getLastGuessResult()
    local guessFingerData = self:getValue("GuessFingerData")
    local leftGuess = guessFingerData.guess_list[1]
    local rightGuess = guessFingerData.guess_list[2]
    local lastGuessIndex = #leftGuess.finger_list
    local result = self:judgeGuessFinger(leftGuess.finger_list[lastGuessIndex], rightGuess.finger_list[lastGuessIndex])
    return result
end

function UserGuess:getRollDiceData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local month = cp.getUtils("TimeUtils").GetMonth()
    local rollDiceData = self:getValue("RollDiceData")
    if rollDiceData == nil then return nil end
    if today ~= rollDiceData.effective_day then
        rollDiceData.effective_day = today
        rollDiceData.free_roll = 0
        rollDiceData.total_roll = 0
        rollDiceData.free_change = 0
        rollDiceData.total_change = 0
        rollDiceData.dice_list = {}
        rollDiceData.total_free_change = 0
    end

    if month ~= rollDiceData.month then
        rollDiceData.month = month
        rollDiceData.month_point = 0
        rollDiceData.point_list = {}
    end

    return rollDiceData
end

function UserGuess:updateDiceList(diceList)
    local rollDiceData = self:getRollDiceData()
    rollDiceData.dice_list = diceList
    if rollDiceData.free_roll < cp.getUtils("DataUtils").GetVipEffect(7) then
        rollDiceData.free_roll = rollDiceData.free_roll + 1
    end
    if rollDiceData.guide_step == 1 then
        rollDiceData.guide_step = 2
    elseif rollDiceData.guide_step == 4 then
        rollDiceData.guide_step = 5
    end
    rollDiceData.total_roll = rollDiceData.total_roll + 1
end

function UserGuess:getFreeRollCount()
    return cp.getUtils("DataUtils").GetVipEffect(7)
end

function UserGuess:changeDice(diceIndex, dicePoint)
    local rollDiceData = self:getRollDiceData()
    if rollDiceData.free_change < rollDiceData.total_free_change then
        rollDiceData.free_change = rollDiceData.free_change + 1
    end

    if rollDiceData.guide_step == 6 then
        rollDiceData.guide_step = 7
    end

    rollDiceData.total_change = rollDiceData.total_change + 1
    rollDiceData.dice_list[diceIndex] = dicePoint
end

function UserGuess:resetDiceState(rollPoint)
    local rollDiceData = self:getRollDiceData()
    rollDiceData.month_point = rollDiceData.month_point+rollPoint
    rollDiceData.dice_list = {}
    if rollDiceData.guide_step == 3 then
        rollDiceData.guide_step = 4
    elseif rollDiceData.guide_step == 8 then
            rollDiceData.guide_step = 9
    end
end

function UserGuess:updateMonthReward(rollPoint)
    local rollDiceData = self:getRollDiceData()
    table.insert(rollDiceData.point_list, rollPoint)
end

function UserGuess:updateGuessStep(module, step)
    if module == 1 then
        local data = self:getRollDiceData()
        data.guide_step = step
    else
        local data = self:getGuessFingerData()
        data.guide_step = step
    end
end

return UserGuess