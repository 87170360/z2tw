
local BaseData = require("cp.data.BaseData")
local GameChallenge = class("GameChallenge",BaseData)

function GameChallenge:create()
    local ret =  GameChallenge.new()
    ret:init()
    return ret
end

function GameChallenge:init()
	local cfg = {
		["current_id"] = 1000,  --當前挑戰或掃蕩的關卡id
		["times"] = 0,          --當前掃蕩的次數
        ["hard_level"] = 0,     --當前挑戰或掃蕩的困難等級
    }	
    self:addProtectedData(cfg)
end

return GameChallenge