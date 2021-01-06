local BaseData = require("cp.data.BaseData")
local UserVan = class("UserVan", BaseData)


function UserVan:create()
    local ret =  UserVan.new()
    ret:init()
    return ret
end

function UserVan:init()
    self["van_list"] = {} --鏢車列表
    self["other_van_list"] = {} --其他人的鏢車列表

    self["attacked_warning_info_list"] = {} --被伏擊的訊息列表 + 江湖事被打斷訊息

    self["express_pos_list"] = {} --押鏢路徑點(額外增加拐角點做方向變換),修改為起點-終點模式，優化行走路線
    self["express_total_length"] = 0 --押鏢路徑直線總長
    self["length_list"] = {} --保存押鏢路徑每段的長度
    local cfg = {
        ["refreshLeftTime"] = 0, --系統刷新剩餘時間(秒數)
        ["refreshStamp"] = 0, --上次刷新時間戳，包括手動刷新
        ["refreshCount"] = 0, --今日已經刷新的次數
        ["escortCount"] = 0,  --今日已經押鏢的次數
        ["robCount"] = 0, --今日已伏擊次數
        ["buyRobCount"] = 0,--今日已購買的伏擊次數
    }	
    self:addProtectedData(cfg)
end

function UserVan:addNewNotice(info)
    local attacked_warning_info_list = cp.getUserData("UserVan"):getValue("attacked_warning_info_list")
    attacked_warning_info_list = attacked_warning_info_list or {}
    attacked_warning_info_list[#attacked_warning_info_list + 1] = info

    local function sortByTime(a,b)
        local stampA,stampB = 0,0
        stampA = (a.type == "BeRobVan") and a.robInfo.stamp or a.breakInfo.stamp
        stampB = (b.type == "BeRobVan") and b.robInfo.stamp or b.breakInfo.stamp    
        
        return stampA > stampB
    end
    table.sort(attacked_warning_info_list,sortByTime)
    cp.getUserData("UserVan"):setValue("attacked_warning_info_list",attacked_warning_info_list)

end

return UserVan