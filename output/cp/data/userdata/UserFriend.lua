local BaseData = require("cp.data.BaseData")
local UserFriend = class("UserFriend", BaseData)

function UserFriend:create()
    local ret = UserFriend.new() 
    ret:init()
    return ret
end

function UserFriend:init()
    self:setValue("PlayerSimpleData", {})
end

function UserFriend:getFriendData()
    local today = cp.getUtils("TimeUtils").GetDayOfToday()
    local friendData = self:getValue("FriendData")
    if friendData == nil then return nil end
    if today ~= friendData.today then
        friendData.today = today
        friendData.fight_count = 0
    end
    return friendData
end

function UserFriend:updatePlayerSimpleData(simpleInfoList)
    local playerSimpleData = self:getValue("PlayerSimpleData")
	for _, simpleInfo in ipairs(simpleInfoList) do
        local key = simpleInfo.id
        simpleInfo.last_refresh = cp.getManager("TimerManager"):getTime()
        playerSimpleData[key] = simpleInfo
	end
end

function UserFriend:getPlayerSimpleInfo(id)
    local now = cp.getManager("TimerManager"):getTime()
    local playerSimpleData = self:getValue("PlayerSimpleData")
    local playerInfo = playerSimpleData[id]
    if not playerInfo or now - playerInfo.last_refresh > 60 or playerInfo.career == nil then
        return nil
    end
    return playerInfo
end

function UserFriend:deleteFriend(playerInfo)
    local friendData = self:getFriendData()
    local index = -1
    for i, playerInfo1 in ipairs(friendData.friend_list) do
        if playerInfo1.id == playerInfo.id and
            playerInfo1.zone == playerInfo.zone then
            index = i
            break
        end
    end

    if index ~= -1 then
        table.remove(friendData.friend_list, index)
    end
end

function UserFriend:addFriendRequest(requestInfo)
    local friendData = self:getFriendData()
    local index = -1
    for i, requestInfo1 in ipairs(friendData.request_list) do
        if requestInfo1.id == requestInfo.id and
            requestInfo1.zone == requestInfo.zone then
            index = i
            break
        end
    end

    if index ~= -1 then
        friendData.request_list[index] = requestInfo
    else
        table.insert(friendData.request_list, requestInfo)
    end
end

function UserFriend:addFriendRequestNotify(requestInfo)
    local friendData = self:getFriendData()
    local index = -1
    for i, requestInfo1 in ipairs(friendData.response_list) do
        if requestInfo1.id == requestInfo.id and
            requestInfo1.zone == requestInfo.zone then
            index = i
            break
        end
    end

    if index ~= -1 then
        friendData.response_list[index] = requestInfo
    else
        table.insert(friendData.response_list, requestInfo)
    end
end

function UserFriend:deleteResponse(playerList)
    local friendData = self:getFriendData()
    for _, playerInfo in ipairs(playerList) do
        local index = -1
        for i, playerInfo1 in ipairs(friendData.response_list) do
            if playerInfo1.id == playerInfo.id and
                playerInfo1.zone == playerInfo.zone then
                index = i
                break
            end
        end

        if index ~= -1 then
            table.remove(friendData.response_list, index)
        end
    end
end

function UserFriend:deleteRequest(playerList)
    local friendData = self:getFriendData()
    for _, playerInfo in ipairs(playerList) do
        local index = - 1
        for i, playerInfo1 in ipairs(friendData.request_list) do
            if playerInfo1.id == playerInfo.id and
            playerInfo1.zone == playerInfo.zone then
                index = i
                break
            end
        end
        
        if index ~= - 1 then
            table.remove(friendData.request_list, index)
        end
    end 
end

function UserFriend:addFriend(playerList)
    local friendData = self:getFriendData()
    for _, playerInfo in ipairs(playerList) do
        local index = - 1
        for i, playerInfo1 in ipairs(friendData.friend_list) do
            if playerInfo1.id == playerInfo.id and
            playerInfo1.zone == playerInfo.zone then
                index = i
                break
            end
        end
        
        if index ~= - 1 then
            friendData.friend_list[index] = playerInfo
        else
            table.insert(friendData.friend_list, playerInfo)
        end
    end 
end

function UserFriend:updateOnlineStatus(playerInfo, status)
    local friendData = self:getFriendData()
    local playerSimpleData = self:getValue("PlayerSimpleData")

    local playerSimpleInfo = playerSimpleData[playerInfo.id]
    if playerSimpleInfo then
        playerSimpleInfo.status = status
        playerSimpleInfo.login = cp.getManager("TimerManager"):getTime()
        playerSimpleInfo.last_refresh = cp.getManager("TimerManager"):getTime()
    else
        playerSimpleData[playerInfo.id] = {
            status=status,
            login=cp.getManager("TimerManager"):getTime(),
            last_refresh = cp.getManager("TimerManager"):getTime()
        }
    end
end

function UserFriend:updateRequestList(requestList)
    local friendData = self:getFriendData()
    friendData.request_list = requestList
end

function UserFriend:addEnemy(playerInfo)
    local friendData = self:getFriendData()
    local index = - 1
    for i, playerInfo1 in ipairs(friendData.enemy_list) do
        if playerInfo1.id == playerInfo.id and
        playerInfo1.zone == playerInfo.zone then
            index = i
            break
        end
    end
        
    if index ~= - 1 then
        friendData.enemy_list[index] = playerInfo
    else
        table.insert(friendData.enemy_list, playerInfo)
    end
end

function UserFriend:deleteEnemy(playerInfo)
    local friendData = self:getFriendData()
    local index = -1
    for i, playerInfo1 in ipairs(friendData.enemy_list) do
        if playerInfo1.id == playerInfo.id and
            playerInfo1.zone == playerInfo.zone then
            index = i
            break
        end
    end

    if index ~= -1 then
        table.remove(friendData.enemy_list, index)
    end
end

function UserFriend:getEnemy(role_id)
    local friendData = self:getFriendData()
    for i, playerInfo1 in ipairs(friendData.enemy_list) do
        if playerInfo1.id == role_id then
            return playerInfo1
        end
    end
    return nil
end

return UserFriend