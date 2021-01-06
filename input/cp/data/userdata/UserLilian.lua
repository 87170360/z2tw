local BaseData = require("cp.data.BaseData")
local UserLilian = class("UserLilian",BaseData)

function UserLilian:create()
    local ret =  UserLilian.new()
    ret:init()
    return ret
end

function UserLilian:init()

    self["result_list"] = {}   --保存歷練結果列表只保留20條
    
    self["offline_result_list"] = {}   --離線歷練
    self["fast_result_list"] = {}   --快速歷練

    local cfg = {}	
    self:addProtectedData(cfg)
end

function UserLilian:addNewResult(data)
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseId = major_roleAtt.exerciseId  --當前的歷練id
    local isInActive,_ = cp.getManager("GDataManager"):isLiLianInActivityTime(exerciseId)

    -- trainPoint 修為點(用於提升武學等級)
    local list = {items={}, trainPoint = 0, silver = 0,  conductGood = 0,conductBad = 0,isInActive = false,soldSilver=0,soldItems={}}
    if table.nums(data.info) == 4 and isInActive then
        for i=1,4,2 do
            local info = data.info[i]
            list.trainPoint = list.trainPoint + (info.trainPoint or 0)
            list.silver = list.silver + (info.silver or 0)
            list.conductGood = list.conductGood + (info.conductGood or 0)
            list.conductBad = list.conductBad + (info.conductBad or 0)
            list.soldSilver = list.soldSilver + (info.soldSilver or 0)
            local itemid = info.itemId
            if itemid > 0 then
                list.items[itemid] = list.items[itemid] or 0
                list.items[itemid] = list.items[itemid] + 1
            end
            if info.soldItemId > 0 then
                list.soldItems[info.soldItemId] = list.soldItems[info.soldItemId] or 0
                list.soldItems[info.soldItemId] = list.soldItems[info.soldItemId] + 1
            end
            list.isInActive = true
        end
    else
        for i=1, table.nums(data.info) do
            local info = data.info[i]
            list.trainPoint = list.trainPoint + (info.trainPoint or 0)
            list.silver = list.silver + (info.silver or 0)
            list.conductGood = list.conductGood + (info.conductGood or 0)
            list.conductBad = list.conductBad + (info.conductBad or 0)
            list.soldSilver = list.soldSilver + (info.soldSilver or 0)
            
            local itemid = info.itemId
            if itemid > 0 then
                list.items[itemid] = list.items[itemid] or 0
                list.items[itemid] = list.items[itemid] + 1
            end
 
            if info.soldItemId > 0 then
                list.soldItems[info.soldItemId] = list.soldItems[info.soldItemId] or 0
                list.soldItems[info.soldItemId] = list.soldItems[info.soldItemId] + 1
            end
        end
    end
    table.insert(self["result_list"], list)
    
    local nums = table.nums(self["result_list"])
    if  nums > 20 then --去掉多餘的
        local newTb = {}
        for i=nums-20,nums do
            table.insert(newTb,self["result_list"][i])
        end
        self["result_list"] = newTb
    end
end

return UserLilian