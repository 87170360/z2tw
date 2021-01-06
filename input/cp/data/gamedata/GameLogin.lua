

local BaseData = require("cp.data.BaseData")
local GameLogin = class("GameLogin",BaseData)

function GameLogin:create()
    local ret =  GameLogin.new()
    ret:init()
    return ret
end

function GameLogin:init()
	self["selectServerInfo"] = {}--選擇伺服器區服
	self["lastProto"] = {}
    self["sendData"] = {}
    self.isLogout = false  --是否註銷成功
	local cfg = {
		["requestRoleList"] = 0,--是否已經請求角色賬號列表 0:還沒有請求  1：已經請求
		["hasLogin"] = false, --是否已經進入了遊戲伺服器（斷線重連）
        ["hasLoginPVP"] = false, --是否已經進入pvp伺服器
		["sendProto"] = nil,
		["retryTimes"] = 0,--重連次數
		
		["newRetryTimes"] = 5, --重連次數
		["game_version"] = nil, --遊戲的版本(更新後的)
		["_isHasExitBox"] = "0",
    }	
    self:addProtectedData(cfg)
end

return GameLogin