-- *****************************************************************************
-- 定義規則
-- cpUtils 為最基礎的最簡單的基本工具類方法。內部不能引用一切cp開頭的其他單例。 可以被一切cp開頭的其他單例引用
-- cpConst 和 cpConfig 為基礎層 。 內部最多隻能引用cpUtils裡的基礎方法
-- cpData 內部不能引用 cpManager
-- cpManager 可以引用其他 cpManager 
-- view 內部 可以引用一切 cp開頭的
-- *****************************************************************************

-- for name,v in pairs(package.loaded) do
--     local shouldLoad = string.find(name,"cp.view")
--     if shouldLoad then
--         package.loaded[name] = nil
--         require(name)
--     end
-- end

cp = cp or {}

------------------------------------------------------------------------------------------------------
--Utils
cp.Utils = require("cp.utils.CpUtils"):create() 
function cp.getUtils(name)
    return cp.Utils:getUtils(name)
end

------------------------------------------------------------------------------------------------------
--Const
cp.Const = require("cp.const.CpConst"):create()

function cp.getConst(name)
    return cp.Const:getConst(name)
end 

------------------------------------------------------------------------------------------------------
--Config
cp.Config = require("cp.config.CpConfig"):create() 

function cp.getAutoConfig(name)
    return cp.Config:getAutoConfig(name)
end

function cp.getManualConfig(name)
    return cp.Config:getManualConfig(name)
end

function cp.cleanAutoConfig()
    return cp.Config:cleanAutoConfig()
end

function cp.cleanManualConfig()
    return cp.Config:cleanManualConfig()
end

function cp.cleanConfig()
    return cp.Config:cleanConfig()
end

--CombatController
cp.CombatController = require("cp.controll.combat.CombatController")
cp.CombatStory = require("cp.controll.combat.CombatStory")
cp.DataUtils = require("cp.utils.common.DataUtils")

------------------------------------------------------------------------------------------------------
--Data
cp.Data = require("cp.data.CpData"):create() 

function cp.getGameData(name)
    return cp.Data:getGameData(name)
end

function cp.getUserData(name)
    return cp.Data:getUserData(name)
end

function cp.cleanGameData()
    return cp.Data:cleanGameData()
end

function cp.cleanUserData()
    return cp.Data:cleanUserData()
end

function cp.cleanData()
    return cp.Data:cleanData()
end

------------------------------------------------------------------------------------------------------
--Manager
cp.Manager = require("cp.manager.CpManager"):create() 

function cp.getManager(name)
    return cp.Manager:getManager(name)
end

--------------------------------------------------------------
--重新封裝日誌函數,保存日誌到文件
function cp.LOG(logStr)
    local str = log(logStr)
    if LUA_LOG ~= nil and LUA_LOG.LOG ~= nil then
        LUA_LOG.LOG(str)
    end
end

function cp.DUMP(logStr)
    local str = dump(logStr)
    if LUA_LOG ~= nil and LUA_LOG.LOG ~= nil then
        LUA_LOG.LOG(str)
    end
end
--------------------------------------------------------------

--lua第一次random數據不準，這裡調用一次
math.randomseed(os.time())
math.random()

local director = cc.Director:getInstance()

director:setProjection(cc.DIRECTOR_PROJECTION2_D)

--cpDirector:getScheduler():setTimeScale(2)
director:setAnimationInterval(1.0 / 60)
if CC_SHOW_FPS then
    director:setDisplayStats(true)
end

LUA_LOG.close() -- %H%M%S
LUA_LOG.open("log_" .. os.date("%Y%m%d") ..".txt","Game",2,2)

--initialize designResolutionSize

--PopupManager initialize
cp.getManager("PopupManager"):setDefaultModalSize(display.size)
cp.getManager("PopupManager"):setDefaultModalColor(cp.getManualConfig("Color").defaultModal_c4b)

--Timer
--cp.getManager("TimerManager"):stop()

--Protobuf
local protoFiles = cp.getManualConfig("ProtoFiles")
cp.getManager("ProtobufManager"):registerFiles(protoFiles)

-- local soundEnable = cp.getManager("AudioManager"):getSoundSwitch()
-- local effectEnable = cp.getManager("AudioManager"):getEffectSwitch()
-- cp.getManager("AudioManager"):setSoundSwitch(soundEnable)
-- cp.getManager("AudioManager"):setEffectSwitch(effectEnable)

--刪除舊的log日誌
-- log_20180907.txt
local filePath = cc.FileUtils:getInstance():getWritablePath()
local localTime2 = os.time()
for i=1,30 do
    local tm = localTime2 - 24*60*60*i
    local day = os.date("%Y%m%d",tm)
    local fileExist = cc.FileUtils:getInstance():isFileExist(filePath .. "log_" .. day .. ".txt")
    if fileExist then
        cc.FileUtils:getInstance():removeFile(filePath .. "log_" .. day .. ".txt")
    end
end