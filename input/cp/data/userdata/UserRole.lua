local BaseData = require("cp.data.BaseData")
local UserRole = class("UserRole",BaseData)

function UserRole:create()
    local ret =  UserRole.new() 
    ret:init()
    return ret
end

function UserRole:init()
    --領悟點(用於提升武學招式的等級)
    --self["major_role"] = {}
    self["major_roleAtt"] = {
        name        = "",         --名字
        gender      = 0,          --性別
        career      = 0,          --職業
        fight       = 0,          --戰力
        level       = 1,          --等級
        hierarchy   = 0,          --階級
        vip         = 0,          --vip
        gold        = 0,          --元寶
        silver      = 0,          --銀兩
        physical    = 0,          --體力
        physicalMax = 120,        --體力上限
        exp         = 0,          --經驗(閱歷值)
        expMax      = 0,          --經驗上限(閱歷值上限)
        -- 其他數據在role.proto查看RoleAtt
		
		exerciseId = 0,           --當前的歷練id
    }
    
    self["buyface_list"] = {} --已購頭像列表
    self["fashion_data"] = {  --時裝數據
        own = {},  --當前已擁有的時裝ID列表
        use = 0,  --當前正在使用的時裝ID
        coin = 0,  --時裝券
    } 
    self["major_feature"] = {} -- 特性解鎖數據
    self["newplayerguider"] = {
        finished="",     -- 已完成的指引的索引
        current = "",    -- 當前的指引及進度
    }

    local cfg = {
        ["isOnLine"] = false,
        ["lastEnterBackTime"] = 0,
    }
    self:addProtectedData(cfg)
end

function UserRole:getUserModel()
    local roleAtt = self:getValue("major_roleAtt")
    local fashionData = self:getValue("fashion_data")
    local _, model = cp.getManager("GDataManager"):getMajorRoleIamge(fashionData.use, roleAtt.career, roleAtt.gender)
    return model
end

--保存格式 "menpai_wuxue|wuxue|story==menpai_wuxue|1" 
function UserRole:resetNewplayerguiderList(lead)
    local guideStr = {}
    if lead ~= "" then
        local list = string.split(lead,"==")
        self["newplayerguider"].finished = list[1]
        self["newplayerguider"].current = list[2]
        
    else
        self["newplayerguider"] = {finished="",current=""}
    end
end

-- --獲取角色當前經驗
-- function UserRole:getRoleExp()
--     return self["major_roleAtt"].exp, self["major_roleAtt"].expMax
-- end

-- --增加經驗
-- function UserRole:addExp(expAdded)
--     self["major_roleAtt"].exp = self["major_roleAtt"].exp + expAdded
--     if self["major_roleAtt"].exp > self["major_roleAtt"].expMax then
--         self["major_roleAtt"].level = self["major_roleAtt"].level + 1 
--         local roleconf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", self["major_roleAtt"].level)
-- 	    self["major_roleAtt"].expMax = roleconf:getValue("ExpMax")
--     end
-- end


-- --更新屬性數據 tb = {physical = addnum1, gold = addnum2, ... }
-- function UserRole:updateProperty(tb)
--     for key, value in pairs(tb) do
--         if self["major_roleAtt"][key] ~= nil then
--             self["major_roleAtt"][key] = self["major_roleAtt"][key] + value -- value為負數時，減少
--         end
--     end
    
-- end


return UserRole
