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
    self.className = "org/cocos2dx/lua/LunPlaySDK"
    
    -- sdk init if exist 
end

--調用sdk登錄
--callback為sdk登錄返回需要處理的函數回調
function Entry:goLogin(callback)
    self.loginCallBack = callback

    self:sdkLogin()
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
            local mPnCode,mTime,mPassport,mCk = strList[2],strList[3],strList[4],strList[5]

            cp.getManager("SocketManager"):doConnectLogin()  --連接登錄伺服器
            
            local info = {}
            info.channel = cp.getManualConfig("Channel").channel
        
            local msg = {}
            msg.account = mPassport or ""
            msg.session = ""
            msg.info = {}
            table.insert(msg.info, "channel")
            table.insert(msg.info, info.channel)
            table.insert(msg.info, "pnCode")
            table.insert(msg.info, mPnCode)
            table.insert(msg.info, "ck")
            table.insert(msg.info, mCk)
            table.insert(msg.info, "passport")
            table.insert(msg.info, mPassport)
            table.insert(msg.info, "time")
            table.insert(msg.info, mTime)
            -- table.insert(msg.info, "name") 
            -- table.insert(msg.info, "")

            info.imsi = cp.getManager("GDataManager").getIMSI() 
            info.imei = cp.getManager("GDataManager").getIMEI()
            info.mtype = cp.getManager("GDataManager").getMobileType()
            info.packege = cp.getManager("GDataManager").getPackageName()   --包名
            
            table.insert(msg.info, "mtype")
            table.insert(msg.info, info.mtype)
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
        elseif "logoutConfirm" == backType then
            log("Entry:sdkLogin logoutConfirm back")
            -- -- cp.getManager("ViewManager").showGameMessageBox("系統消息","是否退出遊戲？",2,function()
            --     local args = {exitCallBack}
            --     local sig = "(I)V"
            --     local ok,ret = self.luaj.callStaticMethod(self.className,"miExit",args,sig) 
            -- -- end,nil)
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
        -- local itemCode,serverCode,glevel,extraParam = strList[2],strList[3],strList[4],strList[5]

        if "success" == backType then
            log("payCallBack success")
            
            if self.rechargeCallBack then
                self.rechargeCallBack(params)
            end

        elseif "fail" == backType then
            log("payCallBack fail")
        
        end
    end

    log("Entry:sdkPay 111")

    local itemCode = args.ItemCode
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local passport = cp.getUserData("UserLogin"):getValue("user_token")
    local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
    -- local server_name = lastServerInfo.name
    local serverCode = "nzljh" .. tostring(lastServerInfo.id)
    local userlevel = tostring(major_roleAtt.level)
    local extraParam = tostring(major_roleAtt.id)
    
	local args = {itemCode,serverCode,userlevel,extraParam,payCallBack}
	local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok,ret = self.luaj.callStaticMethod(self.className,"sdkPay",args,sig)
    log("Entry:sdkPay 2222")
end


function Entry:onExtraFunction( func_name,params,callback )
    log("Entry:onExtraFunction func_name =" .. func_name)
    dump(params)
    if func_name == "upLevel" then --人物等級改變
        local userlevel = tostring(params.level)
        local args = {userlevel}
        local sig = "(Ljava/lang/String;)V"
        local ok,ret = self.luaj.callStaticMethod(self.className,"upLevel",args,sig)
    elseif func_name == "tutorialCompletion" then  --完成新手指引
        local args = {params.roleId,params.serverCode}
        local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = self.luaj.callStaticMethod(self.className,"tutorialCompletion",args,sig)
    elseif func_name == "roleCreate" then --創建角色
        local args = {params.roleId,params.serverCode}
        local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = self.luaj.callStaticMethod(self.className,"roleCreate",args,sig)
    elseif func_name == "roleLogin" then
        local args = {params.roleId,params.roleName,params.roleLevel,params.serverCode}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = self.luaj.callStaticMethod(self.className,"roleLogin",args,sig)
    elseif func_name == "startFloat" then
        local args = {}
        local sig = "()V"
        local ok,ret = self.luaj.callStaticMethod(self.className,"startFloat",args,sig)
    -- elseif func_name == "bb" then
    end
end

return Entry