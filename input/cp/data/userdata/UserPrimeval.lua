local BaseData = require("cp.data.BaseData")
local UserPrimeval = class("UserPrimeval",BaseData)

function UserPrimeval:create()
    local ret =  UserPrimeval.new() 
    ret:init()
    return ret
end

function UserPrimeval:init()
end

function UserPrimeval:setPrimevalData(primevalData)
    local posMap = {}
    local equipMap = {}
    local metaList = {}
    for _, metaInfo in ipairs(primevalData.meta_list) do
        if metaInfo.id > 0 then
            metaInfo.idx = 0
            posMap[metaInfo.pos] = metaInfo
            if metaInfo.pack > 0 and metaInfo.place > 0 then
                local equipPos = bit.lshift(metaInfo.pack, 16) + metaInfo.place
                equipMap[equipPos] = metaInfo
            end
            metaInfo.entry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
            table.insert(metaList, metaInfo)
        end
    end
    primevalData.idx = 1
    self:setValue("PrimevalData", primevalData)
    self:setValue("PosMap", posMap)
    self:setValue("EquipMap", equipMap)
end

function resetMetaInfo(metaInfo)
    metaInfo.id = 0
    metaInfo.color = 0
    metaInfo.level = 0
    metaInfo.exp = 0
    metaInfo.pack = 0
    metaInfo.place = 0
    metaInfo.attr_list = {}
    metaInfo.lock = false
end

function UserPrimeval:getPrimevalData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local primevalData = self:getValue("PrimevalData")
    if not primevalData then return nil end
    if primevalData.day ~= today then
        primevalData.free_learn = 0
        primevalData.day = today
    end

    return primevalData
end

function UserPrimeval:removeMetaPos(posList)
    local primevalData = self:getPrimevalData()
    local posMap = self:getValue("PosMap")
    local equipMap = self:getValue("EquipMap")
    for _, pos in ipairs(posList) do
        if pos > 0 then
            local metaInfo = posMap[pos]
            posMap[pos] = nil
        end
    end
end

function findMetaIndexByPos(metaList, pos)
    for i, metaInfo in ipairs(metaList) do
        if metaInfo.pos == pos then
            return i
        end
    end

    return 0
end

function UserPrimeval:equipMeta(equipList)
    local primevalData = self:getPrimevalData()
    local posMap = self:getValue("PosMap")
    local equipMap = self:getValue("EquipMap")
    for _, equipInfo in ipairs(equipList) do
        local equipPos = bit.lshift(equipInfo.pack, 16) + equipInfo.place
        local oldMetaInfo = equipMap[equipPos]
        local newMetaInfo = posMap[equipInfo.pos]
        if oldMetaInfo then
            oldMetaInfo.pack = 0
            oldMetaInfo.place = 0
        end
        if newMetaInfo then
            newMetaInfo.pack = equipInfo.pack
            newMetaInfo.place = equipInfo.place
        end
        equipMap[equipPos] = newMetaInfo
    end
end

function UserPrimeval:addMetaList(metaList)
    local primevalData = self:getPrimevalData()
    local posMap = self:getValue("PosMap")
    local equipMap = self:getValue("EquipMap")
    for _, metaInfo in ipairs(metaList) do
        posMap[metaInfo.pos] = metaInfo
        if metaInfo.pack > 0 and metaInfo.place > 0 then
            local equipPos = bit.lshift(metaInfo.pack, 16) + metaInfo.place
            equipMap[equipPos] = metaInfo
        end
        metaInfo.entry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
        metaInfo.idx = primevalData.idx
        primevalData.idx = primevalData.idx + 1
    end
    
    self:setValue("RecentAddMeta", metaList)
end

function UserPrimeval:getRecentAddMeta()
    return self:getValue("RecentAddMeta")
end

function UserPrimeval:updateMetaInfo(metaInfo)
    local primevalData = self:getPrimevalData()
    local posMap = self:getValue("PosMap")
    local equipMap = self:getValue("EquipMap")
    local oldMetaInfo = posMap[metaInfo.pos]
    oldMetaInfo.id = metaInfo.id
    oldMetaInfo.color = metaInfo.color
    oldMetaInfo.level = metaInfo.level
    oldMetaInfo.exp = metaInfo.exp
    oldMetaInfo.pack = metaInfo.pack
    oldMetaInfo.place = metaInfo.place
    oldMetaInfo.attr_list = metaInfo.attr_list
    oldMetaInfo.lock = metaInfo.lock
    oldMetaInfo.entry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", metaInfo.id)
end

function UserPrimeval:updateMasterLevel(count, master)
    local primevalData = self:getPrimevalData()
    primevalData.master = master
    if count == 0 then
        primevalData.free_learn = primevalData.free_learn + 1
    end
end

function UserPrimeval:updateMetaLock(pos, lock)
    local primevalData = self:getPrimevalData()
    local posMap = self:getValue("PosMap")
    local equipMap = self:getValue("EquipMap")
    local metaInfo = posMap[pos]
    metaInfo.lock = lock
end

function UserPrimeval:updatePrimevalSpace(space)
    local primevalData = self:getPrimevalData()
    primevalData.space = space
end

function UserPrimeval:summaryAllEffect()
    local effectList = {}
    local equipMap = self:getValue("EquipMap")
    for _, metaInfo in pairs(equipMap) do
        for _, attrID in ipairs(metaInfo.attr_list) do
            local value = cp.getUtils("DataUtils").GetPrimevalEffect(attrID, metaInfo.color, metaInfo.level)
            if effectList[attrID] then
                effectList[attrID] = effectList[attrID] + value
            else
                effectList[attrID] = value
            end
        end
    end

    return effectList
end

function UserPrimeval:getMetaByID(id)
    local metaList = {}
    local posMap = self:getValue("PosMap")
    for _, metaInfo in pairs(posMap) do
        if metaInfo.id == id then
            table.insert(metaList, metaInfo)
        end
    end

    return metaList
end

function UserPrimeval:getMetaIDCount()
    local posMap = self:getValue("PosMap")
    local ret = {}
    for _, metaInfo in pairs(posMap) do
        if ret[metaInfo.id] then
            ret[metaInfo.id] = ret[metaInfo.id] + 1
        else
            ret[metaInfo.id] = 1
        end
    end

    return ret
end

return UserPrimeval