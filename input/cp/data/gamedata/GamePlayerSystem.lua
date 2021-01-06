local BaseData = require("cp.data.BaseData")
local GamePlayerSystem = class("GamePlayerSystem",BaseData)

function GamePlayerSystem:create()
    local ret =  GamePlayerSystem.new() 
    ret:init()
    return ret
end

function GamePlayerSystem:init()
	self.setting_list = {}
	local cfg = {
		["sound"] = true,  --遊戲設置，背景音樂開關，true為開，false為關
		["effect"] = true,  -- 音效開關
	}
    self:addProtectedData(cfg)
	
end

return GamePlayerSystem