local BaseData = require("cp.data.BaseData")
local UserTower = class("UserTower",BaseData)

function UserTower:create()
    local ret =  UserTower.new() 
    ret:init()
    return ret
end

function UserTower:init()
end

function UserTower:getTowerData()
    local towerData = cp.getUserData("UserTower"):getValue("TowerData")
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    if today ~= towerData.day then
        towerData.day = today
        towerData.count = 0
    end
    return towerData
end

function UserTower:updateTowerFloor(data)
    local towerData = cp.getUserData("UserTower"):getTowerData()
    towerData.began = false
    if data.win then
        towerData.floor = towerData.floor + 1
    else
        towerData.fail = towerData.fail + 1
    end
    towerData.began = false
end

function UserTower:updateTowerQuickBegin(data)
    local towerData = cp.getUserData("UserTower"):getTowerData()
    towerData.quick_begin = data.quick_begin
    towerData.began = false
end

function UserTower:updateTowerQuickDone()
    local towerData = cp.getUserData("UserTower"):getTowerData()
    towerData.quick_begin = 0
end

function UserTower:updateTowerReset()
    local towerData = cp.getUserData("UserTower"):getTowerData()
    towerData.count = towerData.count + 1
    towerData.fail = 0
    towerData.began = true
    towerData.quick_begin = 0
end

function UserTower:updateGuideStep(step)
    local towerData = cp.getUserData("UserTower"):getTowerData()
    towerData.guide_step = step
end
return UserTower