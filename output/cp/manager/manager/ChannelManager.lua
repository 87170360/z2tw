local ChannelManager = class("ChannelManager")

function ChannelManager:create()
    local ret =  ChannelManager.new() 
    ret:init()
    return ret
end  

function ChannelManager:init()
    local init = false
    local cname = cp.getManualConfig("Channel").channel
    local cfgItem = cp.getManager("ConfigManager").getItemByMatch("channel_config",{channelName = cname})
    local channel_id = cfgItem:getValue("channelCode") or "2" 
    local cfgItem2 = cp.getManager("ConfigManager").getItemByMatch("channel_entername",{channelCode = channel_id})
    local enterName = cfgItem2:getValue("enterName")
    
    local platform = device.platform
    if platform == "windows" or platform == "mac" then
        platform = "desktop"
    end
    local path = "cp.view.channel."..platform.."."..cname..".".."Entry"
    if enterName ~= nil and enterName ~= "" then
        path = "cp.view.channel."..platform.."."..enterName..".".."Entry"
    end
	
    local Entry = nil
    local function requireEntry(path)
        Entry =  require(path)
    end
    pcall(requireEntry,path)
    if Entry then
        local entry = Entry:create()
        self.entry = entry
        self.enterName = enterName
        init = true
    end
    return init,enterName
end

--[[
    callback(params)
    返回callback的參數
    params=
    {
        usrid:id碼, 
        usrpsd: id驗證密碼,統一用string類型
        errorcode:錯誤類型（看是否需要，一般在sdk的Entry或指定的文件裡面就處理錯誤了）
    }

    調用goLogin後，根據不同sdk平臺，調用不同的sdk彈出不同的界面，界面會實現自己的登錄邏輯，登錄成功後在 sdk的Entry裡或Entry指定的文件內調用callback函數

]]
--登錄
function ChannelManager:goLogin(callback)
    log("ChannelManager:goLogin ..")
    if self.entry then
        self.entry:goLogin(callback) -- 設置登錄回調
    end
end

function ChannelManager:loginFailed( callback )
    -- body
    if self.entry then
        self.entry:loginFailed(callback)
    end
end

function ChannelManager:logout( callback )
    -- body
    if self.entry then
        self.entry:logout(callback)
    end
end

--[[
    --多加個接口，選擇支付方式
    --選擇支付方式。
]]
function ChannelManager:goChoosePayWay(info, callback)
    if self.entry then
        dump(info)
        self.entry:goChoosePayWay(info,callback)
    end
end

--儲值
--[[
     參數:
        params = 
        {
            sid:商品id
            sname:商品名
            tid:訂單id 
            price:商品價格
            usrchannel:渠道 （應該就是cp.getManualConfig("Sdk").sdk 指定的，可能不需要）
            usrarea:玩家所在區
            usrid:玩家id碼
            
        }

    callback(params)
    callback返回的參數
    params = 
    {
        --保留參數
    }

]]
function ChannelManager:goRecharge(params,callback)
    if self.entry then
        self.entry:goRecharge(params,callback)
    end
end

function ChannelManager:quit()
    if self.entry and self.entry.sdkExit then
        self.entry:sdkExit()
    end
end

function ChannelManager:onKeyDown()
    if self.entry then
        self.entry:onKeyDown()
    end
end

--sdk切換賬號
function ChannelManager:doSdkSwitchAccount()
    if self.entry then
        self.entry:doSdkSwitchAccount()
    end
end

--sdk上傳用戶數據
function ChannelManager:doSdkUploadInformation(sceneId)
    if self.entry and device.platform == "android" and self.entry.updatePlayerGameInfo then
        print("-------------- entry not nil")
        self.entry:updatePlayerGameInfo(sceneId)
    else
        print("------------entry nil---")
    end
end

function ChannelManager:onExtraFunction(func_name,params,callback)
    log("ChannelManager:onExtraFunction func_name =" .. func_name)
    if self.entry and self.entry.onExtraFunction then
        self.entry:onExtraFunction(func_name,params,callback)
    end
end

return ChannelManager