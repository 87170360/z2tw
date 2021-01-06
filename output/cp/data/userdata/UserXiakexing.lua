local BaseData = require("cp.data.BaseData")
local UserXiakexing = class("UserXiakexing", BaseData)


function UserXiakexing:create()
    local ret =  UserXiakexing.new()
    ret:init()
    return ret
end

function UserXiakexing:init()
    self["box_award_state_list"] = {} --俠客行寶箱領獎狀態

    local cfg = {
        ["current"] = 0, --俠客行當前的進度
    }	
    self:addProtectedData(cfg)
end

--更新寶箱獎勵領取狀態
function UserXiakexing:updateBoxStateList(newList)
    if newList == nil or next(newList) == nil then return end

    for _,info in pairs(newList) do
        self["box_award_state_list"][info.id] = info.num
    end
    
end

return UserXiakexing