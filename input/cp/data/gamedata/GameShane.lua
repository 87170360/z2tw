local BaseData = require("cp.data.BaseData")
local GameShane = class("GameShane",BaseData)

function GameShane:create()
    local ret =  GameShane.new() 
    ret:init()
    return ret
end

function GameShane:init()

	local cfg = {
        ["uuid"] = nil,	--當前處理的善惡事件
        ["cur_build"] = nil,	--當前善惡事件的建築
        ["isActiveMode"] = false, --更新事件時，需要區分是點擊還是自動倒計時結束（主動還是被動），主動由於有交互，需要彈出下一步的界面。	
	}
    self:addProtectedData(cfg)
	
end

return GameShane