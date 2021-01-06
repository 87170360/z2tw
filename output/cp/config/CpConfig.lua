----所有配置類全局總入口cpConfig。包括xlxs導出的自動配置auto，和手寫配置manual

local CpConfig = class("CpConfig")

function CpConfig:getInstance() 
    if not self.instance then  
        self.instance = CpConfig.new()  
        self.instance:init()
    end
    return self.instance
end

function CpConfig:create() 
    local ret = CpConfig.new()  
    ret:init()
    return ret
end

function CpConfig:init()
    self.autoList = {}
    self.manualList = {}

    --自動管理配置表訊息，自動垃圾回收
    -- setmetatable(self.autoList, {__mode = "v"})     
    -- setmetatable(self.manualList, {__mode = "v"})     

    --因效率太低，註釋掉↑上面自動垃圾回收，改為關閉模塊時釋放。

end

function CpConfig:getAutoConfig(name)
    local cfg = self.autoList[name] 
    if not cfg then
        cfg = require("cp.config.auto."..name)
        package.loaded["cp.config.auto."..name] = nil
        self.autoList[name]  = cfg
    end
    return cfg
end

function CpConfig:cleanAutoConfig()
    self.autoList = {}
end

function CpConfig:getManualConfig(name)
    local cfg = self.manualList[name] 
    if not cfg then
        cfg =  require("cp.config.manual."..name)
        package.loaded["cp.config.manual."..name] = nil
        self.manualList[name]  = cfg
    end
    return cfg
end

function CpConfig:cleanManualConfig()
    self.manualList = {}
end

function CpConfig:cleanConfig()
    self:cleanAutoConfig()
    self:cleanManualConfig()
end


return CpConfig
