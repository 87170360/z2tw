
local ConfigItem = require("cp.manager.manager.config.ConfigItem")
local ConfigManager = class("ConfigManager")

function ConfigManager:create()
    local ret =  ConfigManager.new() 
    ret:init()
    return ret
end  

function ConfigManager:init()
end

--獲取配置表其中一條數據，返回一個ConfigItem。hash類型的配置表才可用，數組類型的配置表返回nil
function ConfigManager.getItemByKey(name,key)
    local cfg = cp.getAutoConfig(name)
    local ret = nil
    if cfg.hash == true then
        local data = cfg.dataList[cfg.hashkeys[key]]
        if data == nil then
            return nil
        end
        local datakeys = cfg.datakeys
        ret = ConfigItem:create(data,datakeys)
    end
    return ret
end

--獲取配置表其中一條數據，返回一個ConfigItem
function ConfigManager.getItemAt(name,idx)
    local cfg = cp.getAutoConfig(name)
    local ret = nil
    local data = cfg.dataList[idx]
    local datakeys = cfg.datakeys
    ret = ConfigItem:create(data,datakeys)
    return ret
end

--獲取配置表共有多少條數據
function ConfigManager.getItemCount(name)
    local cfg = cp.getAutoConfig(name)
    return #cfg.dataList
end


--[[
匹配matchTable，返回一條item數據
matchTable：用來匹配的table
    格式： {cid="Q001",...}
]]
function ConfigManager.getItemByMatch(name,matchTable)
    local ret = nil
    local cnt = ConfigManager.getItemCount(name)
    local item = nil
    local isMatch = true
    local pairs_ = pairs
    for i=1,cnt do
        item = ConfigManager.getItemAt(name,i)
        isMatch = true
        for key,value in pairs_(matchTable) do
            if item:getValue(key) ~= value then
                isMatch = false
                break
            end
        end
        if isMatch then
            ret = item
            break
        end
    end
    return ret
end

--[[
匹配matchTable，返回多條item數據列表
matchTable：用來匹配的table
    格式： {cid="Q001",...}
maxcnt：最多匹配條數，如為nil則有多少條匹配多少條
]]
function ConfigManager.getItemListByMatch(name,matchTable,maxcnt)
    local ret = {}
    local cnt = ConfigManager.getItemCount(name)
    local retcnt = 0
    local item = nil
    local isMatch = true
    local insert_ = table.insert
    local pairs_ = pairs
    for i=1,cnt do
        item = ConfigManager.getItemAt(name,i)
        isMatch = true
        for key,value in pairs_(matchTable) do
            if type(value) ~= "table" then
                if item:getValue(key) ~= value then
                    isMatch = false
                    break
                end
            else
                local oneOf = false
                for _, v in ipairs(value) do
                    if item:getValue(key) == v then
                        oneOf = true
                        break
                    end
                end

                if not oneOf then
                    isMatch = false
                    break
                end
            end
        end
        if isMatch then
            insert_(ret,item)
            if maxcnt~=nil then
                retcnt = retcnt +1
                if retcnt >= maxcnt then
                    break
                end
            end
        end
    end
    return ret
end

function ConfigManager.getConfig(name)
    local cfg = cp.getAutoConfig(name)
    return cfg
end

function ConfigManager.getItemList(name, key, match)
    local ret = {}
    local cnt = ConfigManager.getItemCount(name)
    local item = nil
    for i=1,cnt do
        item = ConfigManager.getItemAt(name,i)
        if not match or match(item:getValue(key)) then
            table.insert(ret,item)
        end
    end

    return ret
end

function ConfigManager.foreach(name, cb)
    local ret = {}
    local cnt = ConfigManager.getItemCount(name)
    for i=1,cnt do
        local item = ConfigManager.getItemAt(name,i)
        if not cb(item) then
            return false, item
        end
    end

    return true, nil
end

function ConfigManager.getGangModelConfig(career, gender)
    local gangConfig = ConfigManager.getItemByKey("GangEnhance", career)
    local modelID = 0
    if gender == 0 then
        modelID = gangConfig:getValue("Role1")
    else
        modelID = gangConfig:getValue("Role2")
    end

    return ConfigManager.getItemByKey("GameModel", modelID)
end

function ConfigManager.getGameModelByNpc(npcEntry)
    local modelConfig = ConfigManager.getItemByKey("GameModel", npcEntry:getValue("ModelID"))
    return modelConfig
end

return ConfigManager