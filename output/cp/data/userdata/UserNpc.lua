local BaseData = require("cp.data.BaseData")
local UserNpc = class("UserNpc",BaseData)

function UserNpc:create()
    local ret =  UserNpc.new()
    ret:init()
    return ret
end

function UserNpc:init()

    self["npc_list"] = {}   --保存npc列表(其他玩家)
    self["hero_list"] = {} --大俠列表
end

function UserNpc:getSortedNpcList()
    local npcList = self:getValue("hero_list")
    local ret = {}
    for _, npcInfo in pairs(npcList) do
        table.insert(ret, npcInfo)
    end

    table.sort(ret, function(a, b)
        if a.ID == b.ID then
            return false
        end
        local _,colorA,_ = cp.getManager("GDataManager"):getHeroInfoByID(a.ID)
        local _,colorB,_ = cp.getManager("GDataManager"):getHeroInfoByID(b.ID)
        return colorA < colorB
    end)
    return ret
end

function  UserNpc:getNpcNum()
    local npcList = self:getValue("hero_list")
    local total, count = 0, 0
    for _, npcInfo in pairs(npcList) do
        total = total + 1
        if npcInfo.state > 0 then
            count = count + 1
        end
    end
    return count , total
end
return UserNpc