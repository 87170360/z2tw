--所有管理類全局總入口cpManager。

local CpManager = class("CpManager")

function CpManager:getInstance() 
    if not self.instance then  
        self.instance = CpManager.new()  
    end
    return self.instance
end

function CpManager:create() 
    return CpManager.new()  
end

function CpManager:getManager(name)
    if not self["Manager"..name] then
        self["Manager"..name] = require("cp.manager.manager."..name):create()
    end
    return self["Manager"..name]
end

return CpManager