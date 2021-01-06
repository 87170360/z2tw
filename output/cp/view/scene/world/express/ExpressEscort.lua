
local BLayer = require "cp.view.ui.base.BLayer"
local ExpressEscort = class("ExpressEscort",BLayer)

function ExpressEscort:create(openInfo)
    local layer = ExpressEscort.new(openInfo)
    return layer
end

function ExpressEscort:initListEvent()
    self.listListeners = {
        
        [cp.getConst("EventConst").StartVanRsp] = function(data)
            local idx = data.vanIndex + 1
            local van_list = cp.getUserData("UserVan"):getValue("van_list")
            self["ExpressEscortItemList"][idx]:resetInfo(van_list[idx])

            if self.closeCallBack then
                self.closeCallBack()
            end
        end,

        [cp.getConst("EventConst").RefreshSelfVanRsp] = function(data)
            self:refresh()
        end,
        
    }
end

function ExpressEscort:onInitView(openInfo)
    self.openInfo = openInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_yabiao.csb") 
    self.rootView:setContentSize(display.size)
    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},

        ["Panel_root.Image_help"] = {name = "Image_help"},
        ["Panel_root.Image_help.Button_help_close"] = {name = "Button_help_close",click = "onUIButtonClick"},

        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.Panel_top"] = {name = "Panel_top"},
        ["Panel_root.Panel_1.Panel_top.Image_top"] = {name = "Image_top"},
        ["Panel_root.Panel_1.Panel_top.Image_top.Text_title"] = {name = "Text_title"},
        ["Panel_root.Panel_1.Panel_top.Image_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.Image_top.Button_help"] = {name = "Button_help",click = "onUIButtonClick"},
        
        ["Panel_root.Panel_1.Panel_top.Panel_bottom"] = {name = "Panel_bottom"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Text_timeleft"] = {name = "Text_timeleft"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Text_num"] = {name = "Text_num"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Text_refresh_need"] = {name = "Text_refresh_need"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Image_need"] = {name = "Image_need"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Button_fresh"] = {name = "Button_fresh",click = "onUIButtonClick"},
        
        ["Panel_root.Panel_1.Panel_top.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.FileNode_1"] = {name = "FileNode_1"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.FileNode_2"] = {name = "FileNode_2"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.FileNode_3"] = {name = "FileNode_3"},
        ["Panel_root.Panel_1.Panel_top.ScrollView_1.FileNode_4"] = {name = "FileNode_4"},

        
        ["Panel_root.Panel_1.Panel_top.Image_bg"] = {name = "Image_bg"},
        
    }
    
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    
    self.Button_help:getTitleRenderer():setPositionY(26)
    self.Button_close:getTitleRenderer():setPositionY(26)

    self["ExpressEscortItemList"] = {}
    for i=1,4 do
        local ExpressEscortItem = require("cp.view.scene.world.express.ExpressEscortItem"):create()
        ExpressEscortItem:setItemClickCallBack(handler(self,self.onStartYaBiao))
        ExpressEscortItem:setIndex(i)
        self["FileNode_" .. tostring(i)]:addChild(ExpressEscortItem)
        self["ExpressEscortItemList"][i] = ExpressEscortItem
    end
    
    self.Image_help:setVisible(false)
    self:adapterReslution()
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_1)
end


function ExpressEscort:adapterReslution()
    local scroll_sz = self.ScrollView_1:getContentSize() 
    
    if display.height > 1280 then
        self.Panel_root:setContentSize(display.width,1170)
        self.Image_bg:setContentSize(display.width,1138)
        self.ScrollView_1:setContentSize(scroll_sz.width,980) 
        self.Panel_bottom:setPositionY(-1050)
        local newheight = display.height/2 + 110/2 + 1170/2
        self.Panel_root:setPositionY(display.height == 1280 and 1280 or newheight)
    elseif display.height >= 1200 then
        self.Panel_root:setContentSize(display.width,1170)
        self.Image_bg:setContentSize(display.width,1138)
        self.ScrollView_1:setContentSize(scroll_sz.width,920) 
        self.Panel_bottom:setPositionY(-990)
        local newheight = display.height/2 + 110/2 + 1170/2
        self.Panel_root:setPositionY(display.height == 1280 and 1280 or newheight)
    else
        self.Panel_root:setContentSize(display.width,display.height-110)
        self.Image_bg:setContentSize(display.width,display.height-150)
        self.ScrollView_1:setContentSize(scroll_sz.width,display.height - 350)
        self.Panel_bottom:setPositionY(280-display.height) 
        self.Panel_root:setPositionY(display.height)
    end

end

function ExpressEscort:refresh()
    local van_list = cp.getUserData("UserVan"):getValue("van_list")
    if table.nums(van_list) == 0 then
        return
    end
    for i=1,4 do
        self["ExpressEscortItemList"][i]:resetInfo(van_list[i])
    end

    local now = cp.getManager("TimerManager"):getTime()

    local vip = cp.getUserData("UserVip"):getValue("level")
    local config = cp.getManager("ConfigManager").getItemByKey("VanRefresh", vip)
    local max = config:getValue("FreeMaxNum")
    local str = string.split(config:getValue("AutoTime"),"-")
    local nowTimeTable = os.date("*t",now) 
    local leftTime = (tonumber(str[1]) - nowTimeTable.hour)*3600 + (tonumber(str[2]) - nowTimeTable.min)*60  + (tonumber(str[3]) - nowTimeTable.sec)*1
    if leftTime < 0 then
        leftTime = leftTime + 24*3600
    end
     
    cp.getUserData("UserVan"):setValue("refreshLeftTime",leftTime)
    local escortCount = cp.getUserData("UserVan"):getValue("escortCount")
    self.Text_num:setString("剩餘押鏢次數 " .. tostring(max-escortCount) .. "/" .. tostring(max))

    local refreshCount = cp.getUserData("UserVan"):getValue("refreshCount")
    local ManualCost = string.split(config:getValue("ManualCost"),"|") 
    local idx = refreshCount+1
    if idx > #ManualCost then
        idx = #ManualCost
    end
    local cost = tonumber(ManualCost[idx])

    self.Text_refresh_need:setString(cost == 0 and "本次免費" or tostring(cost))
    self.Image_need:setVisible(cost > 0 )

    self.Text_timeleft:stopAllActions()
    self.Text_timeleft:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            local leftTime = cp.getUserData("UserVan"):getValue("refreshLeftTime")
            self.Text_timeleft:setString(cp.getUtils("DataUtils").formatTimeRemainEx(leftTime))
            if leftTime <=0 then
                leftTime = 24*3600
            end
            cp.getUserData("UserVan"):setValue("refreshLeftTime",leftTime - 1)
    end), cc.DelayTime:create(1))))

    
    -- self.Panel_root:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
    --     if self.beginTime > 0 then
    --         local now = cp.getManager("TimerManager"):getTime()
    --         if now - self.beginTime > 600 then
    --             local req = {}
    --             self:doSendSocket(cp.getConst("ProtoConst").GetSelfVanReq, req)
    --         end
    --     end
    -- end), cc.DelayTime:create(600))))
end

function ExpressEscort:onEnterScene()
    -- self.beginTime =  cp.getManager("TimerManager"):getTime()
    
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    if string.find(listStr.finished,"river_event")  then
        if not string.find(listStr.finished,"escort")  then 
           cp.getManager("ViewManager").openNewPlayerGuide("escort",0)
        end
    end
        
end

function ExpressEscort:onExitScene()
    -- self.beginTime = 0
end

function ExpressEscort:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack then
            self.closeCallBack()
        end
    elseif buttonName == "Button_help" then
        cp.getManager("ViewManager").showHelpTips("ExpressEscort")
    --     self.Image_help:setVisible(true)
    -- elseif buttonName == "Button_help_close" then
    --     self.Image_help:setVisible(false)
    elseif buttonName == "Button_fresh" then
        local refreshCount = cp.getUserData("UserVan"):getValue("refreshCount")
        local vip = cp.getUserData("UserVip"):getValue("level")
        local config = cp.getManager("ConfigManager").getItemByKey("VanRefresh", vip)
        local ManualCost = string.split(config:getValue("ManualCost"),"|") 
        local idx = refreshCount+1
        if idx > #ManualCost then
            idx = #ManualCost
        end
        local cost = tonumber(ManualCost[idx])
        if cost == 0 then
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").RefreshSelfVanReq, req)
            return
        end
        local function comfirmFunc()
            --檢測是否元寶足夠
            if cp.getManager("ViewManager").checkGoldEnough(cost) then
                --檢測元寶是否足夠
                local req = {}
                self:doSendSocket(cp.getConst("ProtoConst").RefreshSelfVanReq, req)
            end
        end

        local contentTable = {
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(cost), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
            {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="來刷新鏢車？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        }
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    end
end

function ExpressEscort:onStartYaBiao(yabiaoInfo,index)
    local van_list = cp.getUserData("UserVan"):getValue("van_list")
    for i=1, table.nums(van_list) do
        if van_list[i].uuid ~= nil and van_list[i].uuid ~= "" and van_list[i].startStamp > 0 then
            local id = van_list[i].id
            local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", id)
            local lv = itemCfg:getValue("Level")  --鏢車的等級
            local Time = string.split(itemCfg:getValue("Time"),"|")
            local totalTime = 0
            for i=1,#Time do
                totalTime = totalTime + tonumber(Time[i])
            end
        
            local now = cp.getManager("TimerManager"):getTime()
            local state = 0 -- 0:未開啟 1：正在進行 2：已結束
            state = (now - van_list[i].startStamp > totalTime) and 2 or 1
            if state == 1 then
                cp.getManager("ViewManager").gameTip("只能同時押送一輛鏢車!")
                return  
            end
        end
    end

    if yabiaoInfo.id > 0 and index >=1 and index <= 4 then
        
        local req = {vanIndex = index - 1 }
        self:doSendSocket(cp.getConst("ProtoConst").StartVanReq, req)
    end
end

function ExpressEscort:setCloseCallBack(cb)
    self.closeCallBack = cb
end

return ExpressEscort
