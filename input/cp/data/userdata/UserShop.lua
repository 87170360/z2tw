local BaseData = require("cp.data.BaseData")
local UserShop = class("UserShop",BaseData)

function UserShop:create()
    local ret =  UserShop.new()
    ret:init()
    return ret
end

function UserShop:init()
    
    --神祕商店
    self["MysticalStore_GoodsList"] = {}
    
    self["GoodsList"] = {}
    local cfg = {
		["current_storeID"] = 0,
        ["RefreshCount"] = 0,

        ["MysticalStore_storeID"] = 0, -- 神祕商店id
        ["MysticalStore_closeStamp"] = 0, --神祕商店剩餘時間
    }	
    self:addProtectedData(cfg)
end

return UserShop