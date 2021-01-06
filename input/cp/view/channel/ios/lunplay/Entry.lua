local BaseEntry = require "cp.view.channel.BaseEntry"
local Entry = class("Entry",BaseEntry)

function Entry:create()
    local ret =  Entry.new() 
    ret:init()
    return ret
end  

function Entry:init()
    Entry.super.init(self)
    -- self.luaoc = require("cocos.cocos2d.luaoc")
end

--調用sdk登錄
--callback為sdk登錄返回需要處理的函數回調
function Entry:goLogin(callback)
    self.loginCallBack = callback

    --顯示登錄界面，並調用sdk的登錄
    self:sdkLogin()
end

function Entry:sdkLogin()

    local function loginCallBack(name,pnCode,ck,passport,time)
        -- if "success" == backType then
            log("loginCallBack success")
          
            cp.getManager("SocketManager"):doConnectLogin()  --連接登錄伺服器
            
            local info = {}
            info.channel = cp.getManualConfig("Channel").channel
           
            local msg = {}
            msg.account = passport or ""
            msg.session = ""
            msg.info = {}
            table.insert(msg.info, "channel")
            table.insert(msg.info, info.channel)
            table.insert(msg.info, "pnCode")
            table.insert(msg.info, pnCode)
            table.insert(msg.info, "ck")
            table.insert(msg.info, ck)
            table.insert(msg.info, "passport")
            table.insert(msg.info, passport)
            table.insert(msg.info, "time")
            table.insert(msg.info, time)
            table.insert(msg.info, "name") 
            table.insert(msg.info, name)

            -- table.insert(msg.info, "mtype")
            -- table.insert(msg.info, info.mtype)
            -- table.insert(msg.info, "packege")
            -- table.insert(msg.info, info.packege)
            -- table.insert(msg.info, "imsi")
            -- table.insert(msg.info, info.imsi)
            -- table.insert(msg.info, "imei")
            -- table.insert(msg.info, info.imei)
            
            cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ThirdLoginReq, msg)

        -- end
    end
    if LunPlay then
        LunPlay:setLoginCallback(loginCallBack)
        LunPlay:showLogin()
    end
end

function Entry:logout()
    --返回登錄界面
    cp.getManager("AppManager"):reLogin()
    
end

function Entry:goRecharge(args,callback)
    self.rechargeCallBack = callback

    
    local function payCallBack(params)
        
        -- local strList = string.split(params,"|")
        -- local backType = strList[1]
        -- local orderId,money,userInfo = strList[2],strList[3],strList[4]

        -- if "success" == backType then
        if params and params ~= "" then
            log("payCallBack success")
            
            if self.rechargeCallBack then
                self.rechargeCallBack()
            end

        end
    end
    if LunPlay then
        LunPlay:setPurchaseCallback(payCallBack)
        local passport = cp.getUserData("UserLogin"):getValue("user_token")
        local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
        local server = lastServerInfo.name
        local server_id = "nzljh" .. tostring(lastServerInfo.id)
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local param = tostring(major_roleAtt.id)
        LunPlay:huoQuDingDanHaopassport(args.ItemCode,param)
    end
    
end


return Entry