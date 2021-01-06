local HttpManager = class("HttpManager")

HttpManager.GET = "GET"
HttpManager.POST = "POST"

function HttpManager:create()
    local ret =  HttpManager.new() 
    ret:init()
    return ret
end  

function HttpManager:init()
end

function HttpManager:doSend(values, callback, url, port, way)
    if url == nil  then
        url = "http://192.168.2.67:8080/api.php?"--?action=BugRecord&param=
    end
    if port == nil then
        port = cp.getManualConfig("HttpSever").port
    end
    if way == nil then
        way =HttpManager.POST
    end

    --xxx 未實現
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    
    require "cocos.cocos2d.json"
    values = json.encode(values)

    local turl = string.format("%s%s", url, values)

    values = string.urlencode(values)
    url = string.format("%s%s", url, values)
    xhr:open(way, url)

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            --print(xhr.response)
            if callback ~= nil then
                callback(xhr.statusText)
            end
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback ~= nil then
                callback("失敗")
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChanged)

    xhr:send()
end



return HttpManager