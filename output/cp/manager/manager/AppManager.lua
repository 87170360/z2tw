--事件分發監聽管理

local AppManager = class("AppManager")

function AppManager:create()
    local ret =  AppManager.new() 
    ret:init()
    return ret
end  

function AppManager:init()

end

--遊戲退出處理
function AppManager:quit()
    cp.getManager("SocketManager"):doDisConnect()
    cp.getManager("SocketManager"):stopUpdate()
    cp.cleanData()
    cp.getManager("TimerManager"):stop()
    cp.getGameData("GameLogin"):setValue("hasLogin", false)
    cp.getGameData("GameLogin"):setValue("isLogout", true)
    cp.getManager("AudioManager"):onExit()
end

--註銷重登錄
function AppManager:reLogin()
    cp.getManager("SocketManager"):doDisConnect()
    cp.getManager("SocketManager"):stopUpdate()
    cp.cleanData()
    cp.getManager("TimerManager"):stop()
    cp.getManager("AudioManager"):uncacheAll()
    cp.getGameData("GameLogin"):setValue("hasLogin", false)
    cp.getGameData("GameLogin"):setValue("isLogout", true)
    cp.getManager("SocketManager"):doConnect()
    
    cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_LOGIN)
    
end

return AppManager