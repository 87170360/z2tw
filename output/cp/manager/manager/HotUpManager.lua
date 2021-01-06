--熱更新

local HotUpManager = class("HotUpManager")

HotUpManager.GetVersionState = 
{
    OK = 0,     --獲取成功
    ERROR_NETWORK = 1,      --網路錯誤
    ERROR_CREATE_FILE = 2,      --創建文件失敗
    GET_VERSION_ING = 3,        --正在獲取版本訊息
    DOWNLOAD_ING = 4,       --正在下載資源
    UNCOMPRESS_ING = 5,         --正在解壓縮
}

HotUpManager.UpdateState = 
{
    DOWNLOAD_OK = 0,        --下載完成
    ERROR_NETWORK = 1,      --網路錯誤
    ERROR_CREATE_FILE = 2,      --創建文件失敗
    GET_VERSION_ING = 3,        --正在獲取版本訊息
    DOWNLOAD_ING = 4,       --正在下載資源
    UNCOMPRESS_ING = 5,     --正在解壓縮
    DOWNLOAD_PROGRESS = 6,         --下載進度 x%
    UNCOMPRESS_PROGRESS = 7,        --解壓進度 x%
    UNCOMPRESS_FAILUE = 8,      --解壓失敗
    INVALID_PARAM = 9,      --參數錯誤
    UNCOMPRESS_OK = 10,         --解壓完成
}

function HotUpManager:create()
    local ret =  HotUpManager.new() 
    ret:init()
    return ret
end  

function HotUpManager:init()
    self.hotup = cp.CpHotUp:getInstance()    
end

function HotUpManager:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function HotUpManager:doGetVersion(versionFileUrl , callback)
    self.hotup:addCheckVerEventListener(callback)
    self.hotup:doGetVersion(versionFileUrl)
end

function HotUpManager:doUpdate(zipFileUrl, zipStoragePath, uncompressStoragePath , callback)
    self.hotup:addUpdateEventListener(callback)
    self.hotup:doUpdate(zipFileUrl, zipStoragePath, uncompressStoragePath)
end

-- function HotUpManager:checkVerCallback(get_ver_state , version)
-- end

-- function HotUpManager:updateCallback(update_state , pram1, pram2)
-- end

function HotUpManager:sendHttpRequest()
    --if device.platform ~= "windows" then
        log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaasssssssssssssssss")
        
        if cc.FileUtils:getInstance():isFileExist(device.writablePath .. LUA_LOG.LOG_FILE) then
            -- local pid = cp.getUserData("UserPlayer"):getValue("id")
            local save_file_name = (pid ~= nil and pid ~= 0) and tostring(pid) or ""
            save_file_name = "log_" .. save_file_name.. "_" .. os.date("%Y%m%d%H%M%S") .. ".txt"
            
            self.hotup:sendHttpRequest(save_file_name,
                device.writablePath .. LUA_LOG.LOG_FILE,
                "ftp://119.23.25.26/log/".. save_file_name)
            
            log("bbbbbbbbbbbbbbbbbbbbbbbbbsssssssssssssssss")
        end
    --end    
end

return HotUpManager