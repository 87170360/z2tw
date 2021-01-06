local BaseData = require("cp.data.BaseData")
local UserZhuluzhanchang = class("UserZhuluzhanchang", BaseData)


function UserZhuluzhanchang:create()
    local ret =  UserZhuluzhanchang.new()
    ret:init()
    return ret
end

function UserZhuluzhanchang:init()

    local buildings_defeat = {} --所有建築的被打敗次數
    local self_info = {} --自己的參與訊息

    local current_city_id = {} --當前查看的城市id
    local current_city_npc = {} --當前查看的城市防禦的npc詳情
    local cfg = {
        ["current_ringing_arrow"] = 0, --當前的鳴鏑令數量
        ["resume_time"] = -1, --自動恢復鳴鏑令所剩的時間秒數

        ["sign"] = false, -- 是否參與
    }	
    self:addProtectedData(cfg)
end


return UserZhuluzhanchang