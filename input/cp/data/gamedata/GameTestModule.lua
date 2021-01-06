local BaseData = require("cp.data.BaseData")
local GameTestModule = class("GameTestModule",BaseData)

function GameTestModule:create()
    local ret = GameTestModule.new()
    ret:init()
    return ret
end

function GameTestModule:init()
    self.wday = -1
end

return GameTestModule