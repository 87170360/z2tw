local BaseData = require("cp.data.BaseData")
local GameWorld = class("GameWorld",BaseData)

function GameWorld:create()
    local ret =  GameWorld.new() 
    ret:init()
    return ret
end

function GameWorld:init()
    self.back_list = {}
end

return GameWorld