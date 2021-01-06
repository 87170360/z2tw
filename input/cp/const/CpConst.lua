----所有常量類全局總入口cpConst。

local CpConst = class("CpConst")

function CpConst:getInstance() 
    if not self.instance then  
        self.instance = CpConst.new()  
    end
    return self.instance
end

function CpConst:create() 
    return CpConst.new()  
end

function CpConst:getConst(name)
    return require("cp.const.const."..name)
end

return CpConst