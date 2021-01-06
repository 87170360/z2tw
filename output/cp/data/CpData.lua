----所有數據類全局總入口cpData。

local CpData = class("CpData")

function CpData:getInstance() 
    if not self.instance then  
        self.instance = CpData.new()  
    end
    return self.instance
end

function CpData:create() 
    return CpData.new()  
end

function CpData:getGameData(name)
    self["gameList"] = self["gameList"] or {}
    if not self["gameList"][name] then
        self["gameList"][name] = require("cp.data.gamedata."..name):create()
    end
    return self["gameList"][name]
end

function CpData:getUserData(name)
    self["userList"] = self["userList"] or {}
    if not self["userList"][name] then
        self["userList"][name] = require("cp.data.userdata."..name):create()
    end
    return self["userList"][name] 
end

function CpData:cleanGameData()
    for name,gameData in pairs(self["gameList"]) do
        if gameData.stopUpdate ~= nil then
            gameData:stopUpdate()
        end
    end
    self["gameList"] = {}
end

function CpData:cleanUserData()
    for name,userData in pairs(self["userList"]) do
        if userData.stopUpdate ~= nil then
            userData:stopUpdate()
        end
    end
    self["userList"] = {}
end

function CpData:cleanData()
    self:cleanGameData()
    self:cleanUserData()
end

return CpData