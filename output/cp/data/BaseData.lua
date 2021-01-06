local BaseData = class("BaseData")

function BaseData:create()
    local ret =  BaseData.new() 
    self._protectedData = {}
    return ret
end

BaseData._encodeData = cp.getUtils("BaseUtils").xxtea_encodeData
BaseData._decodeData = cp.getUtils("BaseUtils").xxtea_decodeData
BaseData._encodeDefaultNumber = BaseData._encodeData(0)
BaseData._encodeDefaultString = BaseData._encodeData("")
BaseData._encodeDefaultTrue = BaseData._encodeData(true)
BaseData._encodeDefaultFalse = BaseData._encodeData(false)
BaseData._encodeDefaultNil = BaseData._encodeData(nil)

function BaseData:_setProtectValue(key,value)
    -- if not DEBUG or DEBUG ==0 then
        local vtype = type(value)
        if vtype ~= "number" and vtype ~= "string" and vtype ~="boolean" and vtype ~="nil" then
            return
        end
        self._protectedData[key] = {key= key , vtype = vtype}
        local data = self:_getEncodeDataByType(vtype,value)
        self[key] = data
    -- else
    --     self[key] = value
    -- end
end

function BaseData:_getProtectValue(key,allownull)
    if self[key]~=nil then
        -- if not DEBUG or DEBUG ==0 then
            local vtype = self._protectedData[key].vtype
            local data =  self:_getDecodeDataByType(vtype,self[key])
            return data
        -- else
        --     return self[key]
        -- end
    else
        if allownull == nil then
            allownull =  true
        end
        if allownull then
            return nil
        else
            error("invalid key for BaseData:_getProtectValue!  key --> ",key)
        end
    end
end

function BaseData:_setDefaultValue(key,value)
    self[key] = value
end

function BaseData:_getDefaultValue(key,allownull)
    if self[key]~=nil then
        return self[key]
    else
        if allownull == nil then
            allownull =  true
        end
        if allownull then
            return nil
        else
            error("invalid key for BaseData:_getDefaultValue!  key --> "..key)
        end
    end
end

function BaseData:setValue(key,value)
    local isProtected = false
    if self._protectedData == nil or self._protectedData[key] == nil  then
        isProtected = false
    else
        isProtected = true
    end
    if isProtected then
        self:_setProtectValue(key,value)
    else
        self:_setDefaultValue(key,value)
    end
end

function BaseData:getValue(key,allownull)
    local isProtected = false
    if self._protectedData == nil or self._protectedData[key] == nil  then
        isProtected = false
    else
        isProtected = true
    end
    if isProtected then
        return self:_getProtectValue(key,allownull)
    else
        return self:_getDefaultValue(key,allownull)
    end
end

function BaseData:_getEncodeDataByType(vtype,value)
    local ret
    if vtype == "number" then
        if value == 0 then
            ret = BaseData._encodeDefaultNumber
        else
            ret = BaseData._encodeData(value)
        end
    elseif vtype == "string" then
        if value == "" then
            ret = BaseData._encodeDefaultString 
        else
            ret = BaseData._encodeData(value)
        end
    elseif vtype == "boolean" then
        if value == false then
            ret = BaseData._encodeDefaultFalse
        else
            ret = BaseData._encodeDefaultTrue
        end
    elseif vtype == "nil" then
        ret = BaseData._encodeDefaultNil
    end
    return ret
end

function BaseData:_getDecodeDataByType(vtype,value)
    local ret
    if vtype == "number" then
        if value == BaseData._encodeDefaultNumber then
            ret = 0
        else
            ret = BaseData._decodeData(value)
            ret = checknumber(ret)
        end
    elseif vtype == "string" then
        if value == BaseData._encodeDefaultString then
            ret = ""
        else
            ret = BaseData._decodeData(value)
        end
    elseif vtype == "boolean" then
        if value == BaseData._encodeDefaultFalse then
            ret = false
        else
            ret = true
        end
    elseif vtype == "nil" then
        ret = nil
    end
    return ret
end
    --[[
    local cfg = {
        ["hp"] = 0,
        ["hpmax"] = 100,
        ["pa"] = 10,
        ["ma"] = "dwod",
        ["pd"] = "fag",
        ["md"] = nil,
        ["sp"] =  false,
    }
    ]]
function BaseData:addProtectedData(cfg)
    self._protectedData = self._protectedData or {}
    for key,value in pairs(cfg) do
        self:_setProtectValue(key,value)
    end
end

function BaseData:removeProtectedData(cfg)
    self._protectedData = self._protectedData or {}
    for key,value in pairs(cfg) do
        if self._protectedData[key] ~= nil then
            self._protectedData[key]  = nil
            self[key] = nil
        end
    end
end

return BaseData