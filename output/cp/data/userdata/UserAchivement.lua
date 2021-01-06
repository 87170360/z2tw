local BaseData = require("cp.data.BaseData")
local UserAchivement = class("UserAchivement",BaseData)

function UserAchivement:create()
    local ret =  UserAchivement.new()
    ret:init()
    return ret
end

function UserAchivement:init()
    
    self["achive_list"] = {} --成就狀態列表

    self["achive_config"] = {}
    local cfg = {
        ["need_notice"] = true,
        ["has_achive_data"] = false
    }	                               
    self:addProtectedData(cfg)
    
end

-- //id = 成就配置id, num = 1 可領取， 2 已領取, 不在隊列中默認未達成(0表示)
function UserAchivement:updateAchieveList(element)
    self["achive_list"] = {}
    if element and next(element) then
        for i,value in pairs(element) do
            self["achive_list"][value.id] = value.num
        end
    end
    self["has_achive_data"] = true
end

function UserAchivement:getAchivementConfig()
    if self["achive_config"] == nil or table.nums(self["achive_config"]) == 0 then
        self["achive_config"] = cp.getManager("GDataManager"):getAchivementConfigInfo()
    end
    return self["achive_config"]
end

return UserAchivement