
local BaseData = require("cp.data.BaseData")
local GameNet = class("GameNet",BaseData)

function GameNet:create()
    local ret =  GameNet.new() 
    ret:init()
    return ret
end

function GameNet:init()	
	local cfg = {
		["ip"] = nil,		--遊戲伺服器的Ip(與登錄伺服器ip不一樣)
		["port"] = nil,		--遊戲伺服器的端口
		["pvpIp"] = nil,	--PVP IP
		["pvpPort"] = nil	--PVP端口
	}
    self:addProtectedData(cfg)
	
end

return GameNet