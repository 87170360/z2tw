local BaseEntry = require "cp.view.channel.BaseEntry"
local Entry = class("Entry",BaseEntry)

function Entry:create()
    local ret =  Entry.new() 
    ret:init()
    return ret
end  

function Entry:init()
    Entry.super.init(self)
    self.luaj = require("cocos.cocos2d.luaj")
    self.className = "org/cocos2dx/lua/MiSDK"
    self:sdkInit()
end

--調用sdk登錄
--callback為sdk登錄返回需要處理的函數回調
function Entry:goLogin(callback)
    self.loginCallBack = callback

    --顯示登錄界面，並調用sdk的登錄
    self:sdkLogin()
end

function Entry:sdkInit()
    log("Entry:sdkInit 111111")
    local appId = "2882303761517835913"  --小米appId
    local appKey = "5181783537913"       --小米appKey
    local args = {appId,appKey}
    local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
    local ok,ret = self.luaj.callStaticMethod(self.className,"sdkInit",args,sig)
    log("Entry:sdkInit 2222")
end

function Entry:sdkLogin()
    
    local function exitCallBack(params)
        cp.getManager("ViewManager").gameTip("退出到登錄界面")
        self:logout()
    end
    
    local function loginCallBack(params)
        if params == nil or params == "" then
            log("loginCallBack error, no params.")
            return
        end
        local strList = string.split(params,"|")
        local backType = strList[1]
        if "success" == backType then
            log("loginCallBack success")
            local uid,session,nickName = strList[2],strList[3],strList[4]

            cp.getManager("SocketManager"):doConnectLogin()  --連接登錄伺服器
            
            local info = {}
            info.channel = cp.getManualConfig("Channel").channel

            -- if device.platform == "android" then  --小米必然是Android系統
                info.imsi = cp.getManager("GDataManager").getIMSI() 
                info.imei = cp.getManager("GDataManager").getIMEI()
                info.mtype = cp.getManager("GDataManager").getMobileType()
                info.packege = cp.getManager("GDataManager").getPackageName()   --包名
            -- end

            local msg = {}
            msg.account = uid or ""
            msg.session = session or ""
            msg.info = {}
            table.insert(msg.info, "channel")
            table.insert(msg.info, info.channel)
            table.insert(msg.info, "mtype")
            table.insert(msg.info, info.mtype)
            table.insert(msg.info, "nickName")
            table.insert(msg.info, nickName)
            table.insert(msg.info, "packege")
            table.insert(msg.info, info.packege)
            table.insert(msg.info, "imsi")
            table.insert(msg.info, info.imsi)
            table.insert(msg.info, "imei")
            table.insert(msg.info, info.imei)
            
            cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ThirdLoginReq, msg)

        elseif "fail" == backType then
            log("loginCallBack fail")
        elseif "cancel" == backType then
            log("loginCallBack cancel")
        elseif "action_executed" == backType then  --操作正在進行中
            log("loginCallBack action_executed")
        elseif "default" == backType then --其他情況
            local errorCode = strList[2]
            log("loginCallBack errorCode=" .. errorCode)
        -- elseif "logout" == backType then  --退出
        --     cp.getManager("ViewManager").gameTip("退出到登錄界面")
        --     self:logout()
        elseif "logoutConfirm" == backType then
            log("Entry:sdkLogin logoutConfirm back")
            -- cp.getManager("ViewManager").showGameMessageBox("系統消息","是否退出遊戲？",2,function()
                local args = {exitCallBack}
                local sig = "(I)V"
                local ok,ret = self.luaj.callStaticMethod(self.className,"miExit",args,sig) 
            -- end,nil)
        end
    end

    log("Entry:sdkLogin 111")
	local args = {loginCallBack}
	local sig = "(I)V"
    local ok,ret = self.luaj.callStaticMethod(self.className,"sdkLogin",args,sig)
    log("Entry:sdkLogin 2222")
end

function Entry:logout()
    --返回登錄界面
    cp.getManager("AppManager"):reLogin()
    
end

function Entry:goRecharge(args,callback)
    self.rechargeCallBack = callback

    
    local function payCallBack(params)
        if params == nil or params == "" then
            log("payCallBack error, no params.")
            return
        end

        log(params)

        local strList = string.split(params,"|")
        local backType = strList[1]
        local orderId,money,userInfo = strList[2],strList[3],strList[4]

        if "success" == backType then
            log("payCallBack success")
            
            if self.rechargeCallBack then
                self.rechargeCallBack(orderId,money,userInfo)
            end

        elseif "fail" == backType then
            log("payCallBack fail")
        elseif "cancel" == backType then
            log("payCallBack cancel")
        elseif "action_executed" == backType then  --操作正在進行中
            log("payCallBack action_executed")
        elseif "default" == backType then --其他情況
            local errorCode = strList[2]
            log("payCallBack errorCode=" .. errorCode)
        elseif "login_fail" == backType then  --驗證session失敗，需重新登錄
            log("payCallBack login_fail")
            self:logout()
        end
    end

    log("Entry:sdkPay 111")
	local args = {payCallBack}
	local sig = "(ILjava/lang/String;I)V"
    local ok,ret = self.luaj.callStaticMethod(self.className,"sdkPay",args,sig)
    log("Entry:sdkPay 2222")
end


return Entry