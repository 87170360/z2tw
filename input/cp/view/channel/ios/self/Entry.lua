local BaseEntry = require "cp.view.channel.BaseEntry"
local Entry = class("Entry",BaseEntry)

function Entry:create()
    local ret =  Entry.new() 
    ret:init()
    return ret
end  

function Entry:init()
    Entry.super.init(self)
end

--調用sdk登錄
--callback為sdk登錄返回需要處理的函數回調
function Entry:goLogin(callback)
    self.loginCallBack = callback
    --sdk調用自己的登錄，window平臺沒有自己的登錄
end

function Entry:logout( callback )
    -- body
    if callback ~= nil then
        local isSucceed = true
        callback(isSucceed)
    end
end

function Entry:goRecharge(params,callback)
    self.rechargeCallBack = callback

    --自己平臺

    --彈自己寫的選擇支付界面。。進行對應的操作
    --比如popup SelectPayWayLayer，在Layer裡面操作對應邏輯，並註冊 callback事件。
end


return Entry