local BNode = require "cp.view.ui.base.BNode"
local SoftPartLayer = class("SoftPartLayer",BNode)

function SoftPartLayer:create()
    local ret = SoftPartLayer.new()
    ret:init()
    return ret
end


function SoftPartLayer:initListEvent()
    self.listListeners = {}
end

function SoftPartLayer:init()
end

--初始化界面，以及設定界面元素標籤
function SoftPartLayer:onInitView()
  self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/uicsb_softpart_layer.csb") 
	self.rootView:setPosition(cc.p(0,0))
  self:addChild(self.rootView, 1)
  self.rootView:setContentSize(display.size)

  local childConfig = {
      ["Panel_root"] = {name = "Panel_root"},
      ["Panel_root.Image_bg"] = {name = "Image_bg"},
      ["Panel_root.Image_bg.Text_Title"] = {name = "Text_Title"},
      ["Panel_root.Image_bg.Text_Notice"] = {name = "Text_Notice"},
      ["Panel_root.Image_bg.Image_Progress"] = {name = "Image_Progress"},
      ["Panel_root.Image_bg.Image_Progress.LoadingBar_Progress"] = {name = "LoadingBar_Progress"},
      ["Panel_root.Image_bg.Image_Progress.Text_Progress"] = {name = "Text_Progress"},
      ["Panel_root.Image_bg.Image_Progress.Text_Percent"] = {name = "Text_Percent"},
      ["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK", click="onBtnClick"},
  }
  cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
  ccui.Helper:doLayout(self.rootView)
  self.Image_bg:setVisible(false)
  self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
    self.Image_bg:setVisible(true)
    cp.getManager("ViewManager").popUpViewEx(self.Image_bg)
  end)))
end

function SoftPartLayer:onEnterScene()
  self:downLoadSoftPart()
  cp.getManager("ViewManager").setEnabled(self.Button_OK, false)
  self.Button_OK:getChildByName("Text"):setString("繼續下載")
  self.Text_Title:setString("正在下載遊戲資源")
end

function SoftPartLayer:onBtnClick(btn)
  local name = btn:getName()
  if name == "Button_OK" then
    self:downLoadSoftPart()
    cp.getManager("ViewManager").setEnabled(self.Button_OK, false)
    self.Button_OK:getChildByName("Text"):setString("繼續下載")
    self.Text_Title:setString("正在下載遊戲資源")
  end
end

function SoftPartLayer:setSoftPartInstalled()
  return cp.getManager("LocalDataManager"):setValue("", "hotupver", "softPartInstalled", true)
end

function SoftPartLayer:downLoadSoftPart()
    self["Text_Progress"]:setString("正在下載")
    self["Text_Notice"]:setString("")
    self["Image_Progress"]:setVisible(true)

    local channelName = cp.getManualConfig("Channel").channel 
    local urlStr = cp.getManager("GDataManager"):getGameConfigByChannel(channelName, "hotupUrl")
    self.urlList = string.split(urlStr,"#")
  
    local softPartDir = cc.FileUtils:getInstance():getWritablePath().."soft_part/"
    if not cc.FileUtils:getInstance():isDirectoryExist(softPartDir) then
      cc.FileUtils:getInstance():createDirectory(softPartDir)
    end

    if #self.urlList > 0 and self.urlList[1] ~= "" then
        local zipFileUrl = self.urlList[1] .. "soft_part.zip"
        --zipFileUrl = "http://hicdnwszwsg.lunplay.com.cn/soft_part.zip"
        local uncompressStoragePath = softPartDir
        local zipStoragePath = cc.FileUtils:getInstance():getWritablePath().."tmp/"
        if not cc.FileUtils:getInstance():isDirectoryExist(zipStoragePath) then
          cc.FileUtils:getInstance():createDirectory(zipStoragePath)
        end
        cp.getManager("HotUpManager"):doUpdate(zipFileUrl, zipStoragePath, uncompressStoragePath , handler(self,self.updateCallback))
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
function SoftPartLayer:updateCallback(update_state , pram1,pram2)
  log("update_state --> " ,update_state , pram1 ,pram2)
  --網路錯誤
  if update_state == cp.getManager("HotUpManager").UpdateState.ERROR_NETWORK then 
    self["Text_Progress"]:setString("網路錯誤，下載資源失敗，請稍後重試！")
    cp.getManager("ViewManager").setEnabled(self.Button_OK, true)
  --創建文件失敗
  elseif update_state == cp.getManager("HotUpManager").UpdateState.ERROR_CREATE_FILE then 
    self["Text_Progress"]:setString("下載失敗，無法創建文件。請清理手機空間後重試！")
    cp.getManager("ViewManager").setEnabled(self.Button_OK, true)
  --下載 進度百分比
  elseif update_state == cp.getManager("HotUpManager").UpdateState.DOWNLOAD_PROGRESS then 
    log("正在下載資源 --> " )
    local p1 = self:getByteStr(pram1)
    local p2 = self:getByteStr(pram2)
    self["Text_Progress"]:setString("本次下載共".. p2 .. "，".."當前已下載"..p1)
    local percent = 0
    if pram2 >0 then
      percent = checkint(pram1/pram2 * 100)
      percent = math.min(percent,100)
    end
    self["Text_Percent"]:setString(checkstring(percent) .. "%")
    --進度條動
    self["LoadingBar_Progress"]:setPercent(percent)

  --下載完成
  elseif update_state == cp.getManager("HotUpManager").UpdateState.DOWNLOAD_OK then 
    self["Text_Progress"]:setString("下載完成,準備解壓資源")
    self["LoadingBar_Progress"]:setPercent(100)
  --解壓 進度百分比
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_PROGRESS then 
    --self["Text_Progress"]:setString("正在解壓資源...")
    local p1 = pram1
    local p2 = pram2
    local txt = "解壓資源 ".. checkstring(p1) .. "/"..checkstring(p2).."  （".."解壓資源不消耗網路流量）"
    self["Text_Progress"]:setString(txt)
    local percent = 0
    if pram2 >0 then
      percent = checkint(pram1/pram2 * 100)
    end
    self["Text_Percent"]:setString(checkstring(percent) .. "%")
    self["LoadingBar_Progress"]:setPercent(percent)
  --解壓失敗
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_FAILUE then 
    local txt = "下載失敗，解壓縮文件失敗。請清理手機空間後重試！"
    self["Text_Progress"]:setString(txt)
    cp.getManager("ViewManager").setEnabled(self.Button_OK, true)
    --self["Text_Progress"]:setString("下載失敗！")
  --參數錯誤
  elseif update_state == cp.getManager("HotUpManager").UpdateState.INVALID_PARAM then 
    --self["Text_Progress"]:setString("下載失敗！")
    local txt = "參數錯誤，請重新下載軟件包進行安裝！"
    self["Text_Progress"]:setString(txt)
    cp.getManager("ViewManager").setEnabled(self.Button_OK, true)
  --解壓完成
  elseif update_state == cp.getManager("HotUpManager").UpdateState.UNCOMPRESS_OK then 
    self["Text_Progress"]:setString("下載完成！")
    self["Text_Percent"]:setString("")

    cp.getManager("LocalDataManager"):setValue("", "hotupver", "softPartInstalled", true)
    self:dispatchViewEvent("CheckHotUp")
    --下一幀執行清理操作
    local action = cc.Sequence:create(cc.DelayTime:create(0.03),cc.CallFunc:create(function()
        self:removeFromParent()
    end))
    self:runAction(action)
  end
end

function SoftPartLayer:getByteStr(byte)
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

function SoftPartLayer:onExitScene()
end

return SoftPartLayer