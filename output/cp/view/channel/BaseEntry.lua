local BaseEntry = class("BaseEntry")

function BaseEntry:create()
    local ret =  BaseEntry.new() 
    ret:init()
    return ret
end  

function BaseEntry:init()
    self.loginCallBack = nil
    self.choosePayWayCallBack = nil
    self.rechargeCallBack = nil

    if device.platform == "android" then
        cp.getManager("GDataManager"):initTalkingDataGA()
    end
end

function BaseEntry:goLogin(callback)
    self.loginCallBack = callback


    -- callback(params)
end

function BaseEntry:goChoosePayWay(info,callback)
    self.choosePayWayCallBack = callback
end

function BaseEntry:goRecharge(params,callback)
    self.rechargeCallBack = callback
    
end

return BaseEntry