local BaseData = require("cp.data.BaseData")
local UserMenPai = class("UserMenPai",BaseData)

function UserMenPai:create()
    local ret =  UserMenPai.new()
    ret:init()
    return ret
end

function UserMenPai:init()

    self["rankInfoList"] = {} -- 門派排名列表

    self["current_fight_List"] = {} -- 當前刷新的對戰成員列表
    self["fight_list_cache"] = {} -- 待刷新的對戰成員列表緩存

    self["practiceLevelInfo"] = {} -- 門派修煉訊息
    local cfg = {
        ["leftCount"] = "", --門派地位剩餘挑戰次數
        ["maxCount"] = "", --門派地位最大挑戰次數
        ["selfRank"] = 0, --門派地位自己的排名
        ["goldCount"] = 0, --門派修煉使用元寶的次數
        ["silverCount"] = 0,--門派修煉使用銀兩的次數
    }	
    self:addProtectedData(cfg)
end

return UserMenPai