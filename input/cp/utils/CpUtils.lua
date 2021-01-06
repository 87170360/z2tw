--所有工具類全局總入口cpUtils。

local CpUtils = class("CpUtils")

function CpUtils:getInstance() 
    if not self.instance then  
        self.instance = CpUtils.new()  
    end
    return self.instance
end

function CpUtils:create() 
    return CpUtils.new()  
end

function CpUtils:getUtils(name)
    return require("cp.utils.common."..name)
end

return CpUtils