local BaseData = require("cp.data.BaseData")
local UserInvite = class("UserInvite",BaseData)

function UserInvite:create()
    local ret =  UserInvite.new()
    ret:init()
    return ret
end

function UserInvite:init()
    
    self["giftState"]   = {}    --獎勵狀態列表
    
    local cfg = {
        invite_code = "", --邀請碼
        inviteeCount = 0, -- 成功邀請玩家數量
    }	
    self:addProtectedData(cfg)
end

return UserInvite