local BNode = require "cp.view.ui.base.BNode"
local TestModuleLayer = class("TestModuleLayer",BNode)
function TestModuleLayer:create(openInfo)
    local scene = TestModuleLayer.new(openInfo)
    return scene
end


--該界面UI註冊的事件偵聽
function TestModuleLayer:initListEvent()
    self.listListeners = {

        --選中建築
        ["wolegecao"] = function(data)
            log(111111)
        end,
    }

end

--初始化界面，以及設定界面元素標籤
function TestModuleLayer:onInitView(openInfo)
  -- openInfo參數:
  --    name:模塊名字
  --    txt : 顯示標題用
  -- local txt = openInfo.txt

   local txt = "我來測試下的04876就是這樣9541"
	
    self.bg = ccui.ImageView:create()
    self.bg:setAnchorPoint(cc.p(0,0))
    self.bg:ignoreContentAdaptWithSize(false)
    self.bg:setSize(display.size)
    self:addChild(self.bg)
    self.bg:loadTexture("img/bg/bg_main/bg_main_popup_bg.jpg",ccui.TextureResType.localType)
	
   -- self.bg = ccui.ImageView:create("img/bg/bg_main/bg_main_popup_bg.jpg" , ccui.TextureResType.localType)
   -- self.bg:setScale(2)
   -- self:addChild(self.bg)
   -- self.bg:setPosition(display.cx, display.cy)

  self.rootView = cc.CSLoader:createNode("uicsb/uicsb_testmodule/uicsb_testmodule_test1.csb") --主場景
  self:addChild(self.rootView)
  --self.rootView:setPosition(0,0)

  local childConfig = {
      ["panel"] = {name = "panel", click = "onBuildClick"},
      ["btn_close"] = {name = "btn_close" ,click = "onBuildClick"},
      ["txt_title"] = {name = "txt_title" , type="text"},
      ["txt_title2"] = {name = "txt_title2" , type="text"},
      ["txt_title3"] = {name = "txt_title3" , type="text"},
      ["ui_testmodule_di_1"] = {name = "ui_testmodule_di_1" ,click = "onBuildClick"},
  }
  cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
  cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

  --分辨率適配
  

  local panelSize  = self["panel"]:getLayoutSize()
  local displaySize = display.size
  local w,h = panelSize.width,panelSize.height
  -- local w,h = 1024,684
  local offsex = (w - displaySize.width)/2
  local offsety = (h -displaySize.height)/2
  self.rootView:setPosition(-offsex,-offsety)

  --txt展示
  self["txt_title"]:setString(txt)
  self["txt_title2"]:setString(txt)

end

--進入場景後的遊戲邏輯
function TestModuleLayer:onEnterScene()

  -- self:dispatchViewEvent("wolegecao",{})

    local function callback(wday)
      --判斷緩存的wday與當前回調wday不相等，說明為新的一天
      if cp.getGameData("GameTestModule"):getValue("wday") ~= wday then
        cp.getGameData("GameTestModule"):setValue("wday",wday)

        --跟伺服器請求新的一天的數據
        --xxx

      end
    end

    local date1 = {hour = 4,min=0,sec=4}
    local date2 = {hour = 4,min=0,sec=0}
    local id =cp.getManager("TimerManager"):registerEnterTime(date1,date2,callback,true)

end

function TestModuleLayer:onBuildClick(sender)
self:dispatchViewEvent("wolegecao",{})
  -- self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_close_module)
  self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = {name = cp.getConst("SceneConst").MODULE_FairyCenter}})
end

return TestModuleLayer