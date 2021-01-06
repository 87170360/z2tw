--事件分發監聽管理

local LocalDataManager = class("LocalDataManager")

function LocalDataManager:create()
    local ret =  LocalDataManager.new() 
    ret:init()
    return ret
end  

function LocalDataManager:init()
    self.files = {}

    self.directory = device.writablePath .. device.directorySeparator.. "dataCache"
    if not cc.FileUtils:getInstance():isDirectoryExist(self.directory) then
        cc.FileUtils:getInstance():createDirectory(self.directory)
    end

    self.separator_1 = "@_@"          --每個字段直接的間隔符
    self.separator_2 = "#=#"         
    self.encodeKey = "b40d894fge3tcmzq"  

    self.user = nil

end

function LocalDataManager:_checkDirname(dirname)
    if (not dirname) or dirname==nil or dirname=="" then
        dirname = "public"
    end
    return dirname
end

function LocalDataManager:_getDirPath(dirname)
    dirname = self:_checkDirname(dirname)
    local dir = self.directory .. device.directorySeparator ..dirname
    return dir
end

function LocalDataManager:_getFilePath(dirname,filename)
    local dir = self:_getDirPath(dirname)
    return dir .. device.directorySeparator .. filename..".cb"
end

function LocalDataManager:_createDirectory(dirname)
    local dir = self:_getDirPath(dirname)
    if not cc.FileUtils:getInstance():isDirectoryExist(dir) then
        cc.FileUtils:getInstance():createDirectory(dir)
    end
end

function LocalDataManager:_removeDirectory(dirname)
    local dir = self:_getDirPath(dirname)
    if cc.FileUtils:getInstance():isDirectoryExist(dir) then
        cc.FileUtils:getInstance():removeDirectory(dir)
    end
end

function LocalDataManager:_initFile(dirname,filename)
    
    dirname = self:_checkDirname(dirname)
    self:_createDirectory(dirname)
    local path = self:_getFilePath(dirname,filename)

    self.files[dirname] = self.files[dirname] or {}
    self.files[dirname][filename] = self.files[dirname][filename] or {}
    if  cc.FileUtils:getInstance():isFileExist(path) then
        local buffer = cc.FileUtils:getInstance():getStringFromFile(path)
        local datastr = cp.getUtils("BaseUtils").xxtea_decode(buffer,self.encodeKey)
        local dataarr = string.split(datastr,self.separator_1)
        for i,zd in ipairs(dataarr) do
            if zd ~= "" then
                local zdarr = string.split(zd,self.separator_2)
                local key1 = zdarr[1]
                local type1 = zdarr[2]
                local value1 = zdarr[3]
                if type1 == "number" then
                    value1 = checknumber(value1)
                elseif type1 == "string" then
                    value1 = checkstring(value1)
                elseif type1 == "boolean" then
                    value1 = checkbool(value1)
                elseif type1 == "nil" then
                    value1 = nil
                end
                self.files[dirname][filename][key1] = value1
            end
        end
    end
end


-- function LocalDataManager:getPublicValue(filename,key,defaultValue)

-- end

-- function LocalDataManager:setPublicValue(filename,key,value)

-- end



function LocalDataManager:getValue(dirname,filename,key,defaultValue)
    dirname = self:_checkDirname(dirname)
    if self.files[dirname] == nil or self.files[dirname][filename] == nil then
        self:_initFile(dirname,filename)
    end
    key = checkstring(key)
    local ret = self.files[dirname][filename][key] 
    if ret == nil then
        ret = defaultValue
    end
    return ret
end

function LocalDataManager:setValue(dirname,filename,key,value)
    dirname = self:_checkDirname(dirname)
    if self.files[dirname] == nil or self.files[dirname][filename] == nil then
        self:_initFile(dirname,filename)
    end
    key = checkstring(key)
    self.files[dirname][filename][key] = value
    self:_flush(dirname,filename)
end

function LocalDataManager:_flush(dirname,filename)
    dirname = self:_checkDirname(dirname)
    local datastr = ""
    for key ,value in pairs(self.files[dirname][filename]) do
        local ttype = type(value)
        local zd = checkstring(key)..self.separator_2..ttype..self.separator_2..checkstring(value)
        if datastr == "" then
            datastr = datastr..zd
        else
            datastr = datastr..self.separator_1..zd
        end
    end
    local buffer = cp.getUtils("BaseUtils").xxtea_encode(datastr,self.encodeKey)
    local path = self:_getFilePath(dirname,filename)

    cc.FileUtils:getInstance():writeStringToFile(buffer,path)
end

function LocalDataManager:cleanData(dirname)
    dirname = self:_checkDirname(dirname)
    self:_removeDirectory(dirname)
    self.files[dirname] = nil 
end

function LocalDataManager:setUser(account,role_id)
    self.account = account --以後考慮賬號切換問題，文件夾需要加賬號訊息
    self.user = tostring(role_id)
end

function LocalDataManager:getPublicValue(filename,key,defaultValue)
    return self:getValue("public",filename,key,defaultValue)
end

function LocalDataManager:setPublicValue(filename,key,value)
    return self:setValue("public",filename,key,value)
end

function LocalDataManager:getUserValue(filename,key,defaultValue)
    return self:getValue(self.user,filename,key,defaultValue)
end

function LocalDataManager:setUserValue(filename,key,value)
    return self:setValue(self.user,filename,key,value)
end

-- local buffer = cc.FileUtils:getInstance():getStringFromFile(prtFile)
--  getWritablePath() 
-- writeStringToFile(std::string dataStr, const std::string& fullPath);

return LocalDataManager


