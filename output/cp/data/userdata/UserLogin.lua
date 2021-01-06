
local BaseData = require("cp.data.BaseData")
local UserLogin = class("UserLogin",BaseData)

function UserLogin:create()
    local ret =  UserLogin.new() 
    ret:init()
    return ret
end

function UserLogin:init()
    self["lastServerInfo"] = {}  --最後登錄的區服訊息
    self["serverList"] = {}	 --伺服器列表
 
    self["account"] = nil --玩家賬號（註冊的時候）
    self["user_token"] = "" -- token
    
    self["isNewRole"] = false
    
    self["skip_guide"] = false
    local cfg = {
        
    }
    self:addProtectedData(cfg)
end

return UserLogin