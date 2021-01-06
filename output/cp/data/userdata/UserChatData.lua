local BaseData = require("cp.data.BaseData")
local UserChatData = class("UserChatData",BaseData)

function UserChatData:create()
    local ret =  UserChatData.new()
    ret:init()
    return ret
end

function UserChatData:init()
    
    self["broadcast_msg_list"] = {} --廣播數據

    self["chat_msg_list"] = {}

    self["seekHelpInfo"] = {}
    self["newNum"] = {}  --存發送消息的index
    local cfg = {
	}	
    self:addProtectedData(cfg)

end

function UserChatData:resetNewMsgNum()
    self["newNum"] = {}
end

--通過消息索引來刪除新消息記錄
function UserChatData:removeNewMsgIndex(index)
    if table.arrIndexOf(self["newNum"], index) ~= -1 then
        table.removebyvalue(self["newNum"], index, true)
    end
end

-- 通過頻道來刪除新消息記錄
function UserChatData:removeNewMsgByChannel(channel)

    for i=1,table.nums(self["chat_msg_list"]) do
        local msgInfo = self["chat_msg_list"][i]
        if msgInfo.channel == channel then
            self:removeNewMsgIndex(msgInfo.index)
        end
    end
end

function UserChatData:getNewMsgNum(channel)
    local total = 0

    for i=1,table.nums(self["chat_msg_list"]) do
        local msgInfo = self["chat_msg_list"][i]
        if channel == nil or msgInfo.channel == channel then
            if table.arrIndexOf(self["newNum"], msgInfo.index) ~= -1 then
                total = total + 1
            end
        end
    end
    return total
end

function UserChatData:getAllChannelNewMsgNum()
    local total = 0
    local nums = {0,0,0,0,0}  -- 5全部 1世界 3幫派 2門派 4個人私聊  0系統
    for i=1,table.nums(self["chat_msg_list"]) do
        local msgInfo = self["chat_msg_list"][i]
        if msgInfo ~= nil then
            if table.arrIndexOf(self["newNum"], msgInfo.index) ~= -1 then
                if msgInfo.channel ~= 0 then
                    total = total + 1
                end
                nums[msgInfo.channel+1] = nums[msgInfo.channel+1] + 1  --這裡channel+1是為了與聊天界面裡的tabIndex對應
            end
        end
    end
    return total,nums
end

function UserChatData:addNewMsg(msgInfo)
    --[[
message ChatChannelRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
    required int32 channel                  = 2;                    //0系統 1世界 2門派 3幫派 4個人
    repeated string content                 = 3;                    //內容
    required int64 stamp                    = 4;                    //時間戳
    optional int64 senderID                 = 5;                    //發送者roleid
    optional string senderName              = 6;                    //發送者名字
    optional int32 hierarchy                = 7;                    //發送者階級
    optional int32 career                   = 8;                    //發送者門派
    optional string face                    = 9;                    //發送者頭像
    optional int32 gender                   = 10;                   //發送者性別
    optional int32 gangRank                 = 11;                   //發送者門派地位
    optional int32 vip                      = 12;                   //發送者vip
    optional int32 level                    = 13;                   //發送者等級
    optional string receName                = 14;                   //接收者名字
}

    ]]


    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    
    if msgInfo and next(msgInfo) then
        msgInfo.index = #self["chat_msg_list"]+1
        self["chat_msg_list"][msgInfo.index] = msgInfo
        if table.arrIndexOf(self["newNum"], msgInfo.index) == -1 and msgInfo.senderID ~= majorRole.id then
            table.insert(self["newNum"], msgInfo.index)
        end
    end
end


return UserChatData