local BaseData = require("cp.data.BaseData")
local UserMail = class("UserMail", BaseData)

function UserMail:create()
    local ret = UserMail.new() 
    ret:init()
    return ret
end

function UserMail:init()
end

function UserMail:addMail(mailList)
    local mailData = self:getValue("MailData")
    for _, mailDetail in ipairs(mailList) do
        table.insert(mailData.mail_list, mailDetail)
    end
end

function UserMail:receiveMail(mailList)
    local mailData = self:getValue("MailData")
    for _, mailID in ipairs(mailList) do
        for i, mailDetail in ipairs(mailData.mail_list) do
            if mailDetail.mail_id == mailID then
                mailDetail.flag = true
                break
            end
        end
    end
end

function UserMail:deleteMail(mailList)
    local mailData = self:getValue("MailData")
    for _, mailID in ipairs(mailList) do
        for i, mailDetail in ipairs(mailData.mail_list) do
            if mailDetail.mail_id == mailID then
                table.remove(mailData.mail_list, i)
                break
            end
        end
    end
end

return UserMail