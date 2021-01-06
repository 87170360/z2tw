local BNode = require "cp.view.ui.base.BNode"
local HotUpLayer = class("HotUpLayer",BNode)

function HotUpLayer:create()
    local ret = HotUpLayer.new()
    ret:init()
    return ret
end


function HotUpLayer:initListEvent()
    self.listListeners = {}
end

function HotUpLayer:init()
  --self.originAppVer = nil
  --self.hotupAppVer = nil
  self.localAppVer = nil
  self.serverAppVer = nil
end

--初始化界面，以及設定界面元素標籤
function HotUpLayer:onInitView()
  self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/uicsb_hotup_layer.csb") 
  self:addChild(self.rootView)
  local childConfig = {
      ["Panel_root"] = {name = "Panel_root"},
      ["Panel_root.Image_progress"] = {name = "Image_progress"},
      ["Panel_root.Image_progress.LoadingBar_1"] = {name = "LoadingBar_1"},
      ["Panel_root.Image_progress.Text_title"] = {name = "Text_title"},
      ["Panel_root.Image_progress.Text_percent"] = {name = "Text_percent"},
      ["Panel_root.Image_progress.Panel_richtxt"] = {name = "Panel_richtxt"},
  }
  cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
  cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

  self.rootView:setPosition(0,0)

  local panelRichtxtSize  = self["Panel_richtxt"]:getLayoutSize()
  local richText = require("cp.view.ui.base.RichText"):create()
  richText:setAnchorPoint(cc.p(0,0))
  richText:ignoreContentAdaptWithSize(false)
  richText:setContentSize(panelRichtxtSize)
  richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)
  
  self["richText"] = richText
  self["Panel_richtxt"]:addChild(self["richText"] )

  self.size_loading = cc.size(456,19)

  cp.getManager("ViewManager").addModalByDefaultImage(self)

end

function HotUpLayer:onEnterScene()
    self.urlList = {}
    self:checkAppVerFirst()

  --播放音樂
 -- cp.getManager("AudioManager"):changePlayBgMusic(3)
end

function HotUpLayer:getHotUpVersion()
  return cp.getManager("LocalDataManager"):getValue("", "hotupver", "version")
end

function HotUpLayer:setHotUpVersion(version)
  return cp.getManager("LocalDataManager"):setValue("", "hotupver", "version", version)
end

--對比應用程序App版本和 hotup目錄下記錄的app版本，如果應用程序App版本比資源目錄下的高，則清除資源目錄
function HotUpLayer:checkAppVerFirst()
  if device.platform == "ios" or device.platform == "android" then
      cc.FileUtils:getInstance():addSearchPath("./", false)
  end

  --查找資源目錄下的版本號
  local hotupAppVer = self:getHotUpVersion()

  --先去掉熱更新資源目錄索引，查找應用App本身裡面的版本號
  local paths = cc.FileUtils:getInstance():getSearchPaths()
  -- dump(paths)
  local newpaths = {}
  for i,path in ipairs(paths) do
    if string.find( path , "hotup/") == nil then
      table.insert(newpaths , path)
    end
  end
  cc.FileUtils:getInstance():setSearchPaths(newpaths)

  --清掉getManualConfig
  cp.cleanConfig()
  
  local originAppVer = cp.getManualConfig("HotUp").version

  --加回 熱更新資源目錄
  cc.FileUtils:getInstance():setSearchPaths(paths)
  cp.cleanConfig()

  --比較熱更新資源目錄的AppVer 與 應用程序原生AppVer
  --如果原生AppVer版本比較高，則移除資源目錄
  log("self.hotupAppVer , self.originAppVer  : ",hotupAppVer , originAppVer)
  self.localAppVer  = originAppVer
  if hotupAppVer then
    self.localAppVer = hotupAppVer
  end

  local hotupDir = cc.FileUtils:getInstance():getWritablePath().."hotup/"
  local cver = self:compareVer(localAppVer , originAppVer )
  if cver <= 0 then
    log("remove hotup")
    if cc.FileUtils:getInstance():isDirectoryExist(hotupDir) then
        local isRemove = cc.FileUtils:getInstance():removeDirectory(hotupDir)
        log("isRemove - >", isRemove)
    end
  end

  --獲取伺服器版本訊息
  self:checkUpdate()
end

function HotUpLayer:compareVer(ver1 , ver2 , cnt )
  cnt = cnt or 3
  local arrVer1 = string.split(ver1,".")
  local arrVer2 = string.split(ver2,".")
  for i=1,cnt do
    local intVer1 = checkint(arrVer1[i])
    local intVer2 = checkint(arrVer2[i])
    if intVer1 > intVer2 then
      return 1
    elseif intVer1 < intVer2 then
      return -1
    end
  end
  return 0
end

function HotUpLayer:checkUpdate()
    self["Text_title"]:setString("正在檢測更新...")
    self["Text_percent"]:setString("")
    self["LoadingBar_1"]:setSize(self.size_loading)

    local channelName = cp.getManualConfig("Channel").channel 
    local urlStr = cp.getManager("GDataManager"):getGameConfigByChannel(channelName, "hotupUrl")
    self.urlList = string.split(urlStr,"#")
  
    if #self.urlList > 0 and self.urlList[1] ~= "" then
        self.index = 1
        local ver_path = self.urlList[1] .. "version"
	      cp.getManager("HotUpManager"):doGetVersion(ver_path, handler(self,self.checkVerCallback))
    end
end

--[[
HotUpManager.GetVersionState = 
{
    OK = 0,                 --獲取成功
    ERROR_NETWORK = 1,      --網路錯誤
    ERROR_CREATE_FILE = 2,  --創建文件失敗
    GET_VERSION_ING = 3,    --正在獲取版本訊息
    DOWNLOAD_ING = 4,       --正在下載資源
    UNCOMPRESS_ING = 5,     --正在解壓縮
}
]]
function HotUpLayer:checkVerCallback(get_ver_state , version)
  log("get_ver_state - > ",get_ver_state,version)
  --網路錯誤
  if get_ver_state == cp.getManager("HotUpManager").GetVersionState.ERROR_NETWORK then
    if self.index < #self.urlList then
        self.index = self.index + 1
        local ver_path = self.urlList[self.index] .. "version"
	      log("HotUpLayer:checkUpdate() ver_path = ".. ver_path .. ", self.index = " .. tostring(self.index))
	      cp.getManager("HotUpManager"):doGetVersion(ver_path, handler(self,self.checkVerCallback))
    else
        --網路錯誤
        self["Text_title"]:setString("更新失敗！")
        self["richText"]:removeAllElement()
        local tb = {type="ttf",fontSize=16,text="網路錯誤，獲取最新版本失敗，請稍後重試！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
        self["richText"]:addElement(tb)
    end

  --創建文件失敗
  elseif get_ver_state == cp.getManager("HotUpManager").GetVersionState.ERROR_CREATE_FILE then
    --創建文件失敗
    self["Text_title"]:setString("更新失敗！")
    self["richText"]:removeAllElement()
    local tb = {type="ttf",fontSize=16,text="更新失敗，無法創建文件。請清理手機空間後重試！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)

  --獲取伺服器遊戲版本成功
  elseif get_ver_state == cp.getManager("HotUpManager").GetVersionState.OK then
    --判斷版本比較
      local hotupDir = cc.FileUtils:getInstance():getWritablePath().."hotup/"
      local zipStoragePath = cc.FileUtils:getInstance():getWritablePath().."tmp/"
      self.serverAppVer = version:split("\n")[1]
      local cver = self:compareVer(self.localAppVer , self.serverAppVer )
      if cver == -1 then
        --要更新
        self["Text_title"]:setString("檢測到新版本！")
        self["richText"]:removeAllElement()
        local tb = {type="ttf",fontSize=16,text="當前版本："..checkstring(self.localAppVer ).."，".."最新版本：".. checkstring(self.serverAppVer).."，準備下載資源..." ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
        self["richText"]:addElement(tb)

        local channelName = cp.getManualConfig("Channel").channel 
        local hotupUrl = cp.getManager("GDataManager"):getGameConfigByChannel(channelName, "hotupUrl")
        local zipFileUrl = hotupUrl .. "Update/" .. self.localAppVer .."_" .. self.serverAppVer .. ".zip"
        log("zipFileUrl = " .. zipFileUrl)
        if not cc.FileUtils:getInstance():isDirectoryExist(hotupDir) then
          cc.FileUtils:getInstance():createDirectory(hotupDir)
        end
        if not cc.FileUtils:getInstance():isDirectoryExist(zipStoragePath) then
          cc.FileUtils:getInstance():createDirectory(zipStoragePath)
        end
        local uncompressStoragePath = hotupDir 
        log("----------","\n",zipFileUrl,"\n",zipStoragePath,"\n",uncompressStoragePath)


        local function comfirmFunc()
          cp.getManager("HotUpManager"):doUpdate(zipFileUrl, zipStoragePath, uncompressStoragePath , handler(self,self.updateCallback))
        end
        
        local contentTable = {
          {type="ttf", fontName="fonts/msyh.ttf", fontSize=24, text="當前有新的遊戲版本，是否更新？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        }
        cp.getManager("ViewManager").showGameMessageBox("更新提示",contentTable,2,comfirmFunc,nil)
      else
        --不需要更新，直接進遊戲
        self["Text_title"]:setString("已經是最新版本！")
        if cc.FileUtils:getInstance():isDirectoryExist(zipStoragePath) then
            cc.FileUtils:getInstance():removeDirectory(zipStoragePath)
        end
        self:goEnterGame()
    end
  end
end

--[[
HotUpManager.UpdateState = 
{
    DOWNLOAD_OK = 0,            --下載完成
    ERROR_NETWORK = 1,          --網路錯誤
    ERROR_CREATE_FILE = 2,      --創建文件失敗
    GET_VERSION_ING = 3,        --正在獲取版本訊息
    DOWNLOAD_ING = 4,           --正在下載資源
    UNCOMPRESS_ING = 5,         --正在解壓縮
    DOWNLOAD_PROGRESS = 6,      --下載進度 x%
    UNCOMPRESS_PROGRESS = 7,    --解壓進度 x%
    UNCOMPRESS_FAILUE = 8,      --解壓失敗
    INVALID_PARAM = 9,          --參數錯誤
    UNCOMPRESS_OK = 10,         --解壓完成
}
]]
function HotUpLayer:updateCallback(update_state , pram1,pram2)
  log("update_state --> " ,update_state , pram1 ,pram2)
  --網路錯誤
  if update_state == cp.getManager("HotUpManager").UpdateState.ERROR_NETWORK then 
    self["Text_title"]:setString("更新失敗！")
    self["richText"]:removeAllElement()
    local tb = {type="ttf",fontSize=16,text="網路錯誤，下載資源失敗，請稍後重試！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)

  --創建文件失敗
  elseif update_state == cp.getManager("HotUpManager").UpdateState.ERROR_CREATE_FILE then 
    self["Text_title"]:setString("更新失敗！")
    self["richText"]:removeAllElement()
    local tb = {type="ttf",fontSize=16,text="更新失敗，無法創建文件。請清理手機空間後重試！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)

  --下載 進度百分比
  elseif update_state == cp.getManager("HotUpManager").UpdateState.DOWNLOAD_PROGRESS then 
    log("正在下載資源 --> " )
    self["Text_title"]:setString("正在下載資源...")
    self["richText"]:removeAllElement()
    local p1 = self:getByteStr(pram1)
    local p2 = self:getByteStr(pram2)
    local tb = {type="ttf",fontSize=16,text="當前版本："..checkstring(self.localAppVer ).."，".."最新版本：".. checkstring(self.serverAppVer).."，".."本次更新共".. p2 .. "，".."當前已更新"..p1 ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    -- local tb2 = {type="ttf",fontSize=16,text="  （" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    -- local tb3 = {type="ttf",fontSize=16,text="建議在wifi環境下更新" ,textColor =cc.c4b(38,212,0,255),outLineEnable = true}
    -- local tb4 = {type="ttf",fontSize=16,text="）" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)
    -- self["richText"]:addElement(tb2)
    -- self["richText"]:addElement(tb3)
    -- self["richText"]:addElement(tb4)
    local percent = 0
    if pram2 >0 then
      percent = checkint(pram1/pram2 * 100)
      percent = math.min(percent,100)
    end
    self["Text_percent"]:setString(checkstring(percent) .. "%")
    --進度條動
    self["LoadingBar_1"]:setPercent(percent)

  --下載完成
  elseif update_state == cp.getManager("HotUpManager").UpdateState.DOWNLOAD_OK then 
    self["Text_title"]:setString("下載完成,準備解壓資源")
    self["richText"]:removeAllElement()

    self["Text_percent"]:setString("")
    self["LoadingBar_1"]:setPercent(100)

  --解壓 進度百分比
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_PROGRESS then 
    self["Text_title"]:setString("正在解壓資源...")
    self["richText"]:removeAllElement()
    local p1 = pram1
    local p2 = pram2
    local tb = {type="ttf",fontSize=16,text="解壓資源 ".. checkstring(p1) .. "/"..checkstring(p2) ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    local tb2 = {type="ttf",fontSize=16,text="  （" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    local tb3 = {type="ttf",fontSize=16,text="解壓資源不消耗網路流量",textColor =cc.c4b(0,255,0,255),outLineEnable = true}
    local tb4 = {type="ttf",fontSize=16,text="）" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)
    self["richText"]:addElement(tb2)
    self["richText"]:addElement(tb3)
    self["richText"]:addElement(tb4)
    local percent = 0
    if pram2 >0 then
      percent = checkint(pram1/pram2 * 100)
    end
    self["Text_percent"]:setString(checkstring(percent) .. "%")
    --進度條動
    self["LoadingBar_1"]:setSize(cc.size(self.size_loading.width*percent/100,self.size_loading.height))

  --解壓失敗
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_FAILUE then 
    self["Text_title"]:setString("更新失敗！")
    self["richText"]:removeAllElement()
    local tb = {type="ttf",fontSize=16,text="更新失敗，解壓縮文件失敗。請清理手機空間後重試！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)

  --參數錯誤
  elseif update_state == cp.getManager("HotUpManager").UpdateState.INVALID_PARAM then 
    self["Text_title"]:setString("更新失敗！")
    self["richText"]:removeAllElement()
    local tb = {type="ttf",fontSize=16,text="參數錯誤，請重新下載軟件包進行安裝！" ,textColor =cc.c4b(255,255,255,255),outLineEnable = true}
    self["richText"]:addElement(tb)

  --解壓完成
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_OK then 
    self["Text_title"]:setString("更新完成！")
    self["richText"]:removeAllElement()
    self["Text_percent"]:setString("")
    self["LoadingBar_1"]:setSize(self.size_loading)

    --下一幀執行清理操作
    self.localAppVer = self.serverAppVer
    self:setHotUpVersion(self.localAppVer)
    local action = cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(handler(self,self.doSomeThing)))
    self:runAction(action)
  end
end

function HotUpLayer:getByteStr(byte)
  local mb = byte / 1024 / 1024
  if mb > 1 then
    return checkstring( math.tofloat(mb, 1) ) .. "M"
  end

  local kb = byte / 1024
  if kb > 1 then
    return checkstring( checkint(kb) ) .. "kb"
  else
    return checkstring( math.tofloat(kb, 1) ) .. "kb"
  end
  return checkstring( byte ) .. "b"
end

function HotUpLayer:doSomeThing()
    local split = string.split
    for loadName, _ in pairs(package.loaded) do
       local tb = split(loadName,".")
      if tb[1]== "cp" then
           package.loaded[loadName] = nil
       end
    end
    
    --重新載入新的lua文件
    require("cp.init")

    self:goEnterGame()
    cp.updated = true
  end

function HotUpLayer:goEnterGame()
  log("serverAppVer = " .. tostring(self.serverAppVer))
  local game_version = self.serverAppVer
  game_version = (game_version == nil or game_version == "") and self.localAppVer or game_version
  cp.getGameData("GameLogin"):setValue("game_version", game_version)
  cp.getManager("LocalDataManager"):setPublicValue("login","game_version",game_version)
  cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_LOGIN)
end

function HotUpLayer:onExitScene()
  local spriteFrameCache = cc.SpriteFrameCache:getInstance()
  spriteFrameCache:removeSpriteFrames()
end

return HotUpLayer