local BaseData = require("cp.data.BaseData")
local UserMijing = class("UserMijing",BaseData)

function UserMijing:create()
    local ret =  UserMijing.new()
    ret:init()
    return ret
end

function UserMijing:init()

    self["mijingInfoList"] = {} -- 祕境挑戰次數訊息  
    self["fightResult"] = {} --祕境挑戰結果
    local cfg = {
        ["fight_id"] = "", --當前挑戰的祕境id
    }	
    self:addProtectedData(cfg)
end

return UserMijing