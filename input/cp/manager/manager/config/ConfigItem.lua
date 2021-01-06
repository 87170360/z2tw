local ConfigItem = class("ConfigItem")

function ConfigItem:create(data,datakeys)
    local ret =  ConfigItem.new() 
    if data ~= nil  and datakeys~=nil then
        ret:reset(data,datakeys)
    end
    return ret
end  

function ConfigItem:reset(data,datakeys)
    self.data = data
    self.datakeys = datakeys
end

function ConfigItem:getValue(key)
    local keyidx = self.datakeys[key]
    if keyidx ~= nil then
        return self.data[keyidx]
    end
    return nil
end

return ConfigItem