
local BLayer = require "cp.view.ui.base.BLayer"
local ExpressLoot = class("ExpressLoot",BLayer)

function ExpressLoot:create(openInfo)
    local layer = ExpressLoot.new(openInfo)
    return layer
end

function ExpressLoot:initListEvent()
    self.listListeners = {
        --獲取所有鏢車列表
        [cp.getConst("EventConst").GetAllVanRsp] = function(data)
			self:refreshAllVan()
        end,

        --購買伏擊次數返回
        [cp.getConst("EventConst").BuyRobRsp] = function(data)
			self:onBuyRobCountBack()
        end,
        
        --伏擊返回
        [cp.getConst("EventConst").RobVanRsp] = function(data)
            dump(data)
            for i=1,self.NumPerPage do
                if self.LootItemList[i] and self.LootItemList[i].openInfo and self.LootItemList[i].openInfo.uuid == data.uuid then
                    self.LootItemList[i]:setToBeRobbed()
                    break
                end
            end
            
            --進入戰鬥場景
            local other_van_list = cp.getUserData("UserVan"):getValue("other_van_list")
            local info = other_van_list[data.uuid]
            local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", info.id)
            local item_list,isHoliday = cp.getManager("GDataManager"):getVanReward(itemCfg,true,info.ownerHierarchy)
            local rewardList = {} 
            rewardList.item_list = {}
            rewardList.currency_list = {}
            if data.success then
                for i=1,table.nums(item_list) do
                    local itemInfo = item_list[i]
                    if itemInfo.itemID == 2 then --銀兩
                        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.silver, num = itemInfo.itemNum })
                    elseif itemInfo.itemID == 3 then --元寶
                        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.gold, num = itemInfo.itemNum })
                    elseif itemInfo.itemID == 1 then --修為點
                        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.trainPoint, num = itemInfo.itemNum })
                    elseif itemInfo.itemID == 1096 then --聲望
                        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.prestige, num = itemInfo.itemNum })
                    elseif itemInfo.itemID == 1098 then --閱歷
                        table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.exp, num = itemInfo.itemNum })
                    end
                end
            end

            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)

            cp.getUserData("UserCombat"):setCombatReward(rewardList)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
				
        end,
    
    }

end

function ExpressLoot:onInitView(openInfo)

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_jiebiao.csb") 
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
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Text_page"] = {name = "Text_page"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Text_num"] = {name = "Text_num"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Button_plus"] = {name = "Button_plus",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Button_Previous"] = {name = "Button_Previous",click = "onUIButtonClick"},
        ["Panel_root.Panel_1.Panel_top.Panel_bottom.Button_Next"] = {name = "Button_Next",click = "onUIButtonClick"},

        ["Panel_root.Panel_1.Panel_top.ScrollView_1"] = {name = "ScrollView_1"},

        ["Panel_root.Panel_1.Panel_top.Image_bg"] = {name = "Image_bg"},
        
    }
    
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    self.Image_help:setVisible(false)

    self.Button_help:getTitleRenderer():setPositionY(26)
    self.Button_close:getTitleRenderer():setPositionY(26)

    self.openInfo = openInfo
    local nameList = {[2] = "風雨亭", [3] = "萬鬆嶺", [4] = "青陽崗"}
    self.title = nameList[openInfo.pos_idx]

    self.Text_title:setString(self.title)
    self:adapterReslution()
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_1)
end


function ExpressLoot:adapterReslution()
    local scroll_sz = self.ScrollView_1:getContentSize() 
  
    self.NumPerPage = 9
    if display.height >= 1200 then
        self.NumPerPage = 9
        self.Panel_root:setContentSize(display.width,1160)
        self.Image_bg:setContentSize(display.width,1108)
        self.ScrollView_1:setContentSize(scroll_sz.width,940) 
        self.ScrollView_1:setInnerContainerSize(cc.size(scroll_sz.width,980))
        self.Panel_bottom:setPositionY(-1040)
        local newheight = display.height/2 + 110/2 + 1160/2
        self.Panel_root:setPositionY(display.height <= 1280 and display.height or newheight)
    else
        self.NumPerPage = 6
        self.Panel_root:setContentSize(display.width,900)
        self.Image_bg:setContentSize(display.width,818)
        self.ScrollView_1:setContentSize(scroll_sz.width,660)
        self.ScrollView_1:setInnerContainerSize(cc.size(scroll_sz.width,660)) 
        self.Panel_bottom:setPositionY(-740)
        self.Panel_root:setPositionY(display.height == 960 and 960 or 1030)
    end

    self.LootItemList = {}
    local inner_size = self.ScrollView_1:getInnerContainerSize()
    for i=1,self.NumPerPage do
        local ExpressLootItem = require("cp.view.scene.world.express.ExpressLootItem"):create()
        ExpressLootItem:setItemClickCallBack(handler(self,self.onJieBiaoButtonClicked))
        
        local y = math.floor((i-1)/3)+1
        local x = math.floor((i-1)%3)
        local sz = ExpressLootItem:getContentSize()
        
        ExpressLootItem:setPosition(cc.p(sz.width*x+8,inner_size.height-y*sz.height-5))
        ExpressLootItem:setVisible(false)
        self["ScrollView_1"]:addChild(ExpressLootItem)
        self.LootItemList[i] = ExpressLootItem
    end

end

function ExpressLoot:onEnterScene()
    self.currentPage = 1
    self:refreshAllVan()

    self:updateRobCount()

    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    if string.find(listStr.finished,"river_event")  then
        if not string.find(listStr.finished,"loot")  then 
           cp.getManager("ViewManager").openNewPlayerGuide("loot",0)
        end
    end
end

function ExpressLoot:updateRobCount()
    local robCount = cp.getUserData("UserVan"):getValue("robCount")
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_rob_count")
    local maxCount = Config:getValue("IntValue")
    local buyRobCount = cp.getUserData("UserVan"):getValue("buyRobCount")
    self.Text_num:setString("伏擊次數:" .. tostring(maxCount + buyRobCount - robCount) .. "/" .. tostring(maxCount))
end

function ExpressLoot:showPage()
    for i=1,self.NumPerPage do
        local idx = (self.currentPage-1)*self.NumPerPage + i
        self.LootItemList[i]:reset(self.all_van_array[idx],self.title)
    end

    self.Text_page:setString(tostring(self.currentPage) .. "/" .. tostring(self.totalPage))
end

function ExpressLoot:onExitScene()
   
end

function ExpressLoot:onUIButtonClick(sender)
    local buttonName = sender:getName()
    if buttonName == "Button_close" then
        -- self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_close_module)
        self:removeFromParent()
    elseif buttonName == "Button_help" then
        cp.getManager("ViewManager").showHelpTips("ExpressLoot")
    --     self.Image_help:setVisible(true)
    -- elseif buttonName == "Button_help_close" then
    --     self.Image_help:setVisible(false)
    elseif buttonName == "Button_plus" then
        --購買伏擊次數
        local robCount = cp.getUserData("UserVan"):getValue("robCount")
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_rob_count")
        local maxCount = Config:getValue("IntValue")
        local buyRobCount = cp.getUserData("UserVan"):getValue("buyRobCount")
        if maxCount + buyRobCount - robCount >= maxCount then
            cp.getManager("ViewManager").gameTip("伏擊次數充足，暫不需要購買次數！")
            return
        end

        self:buyRobCount(maxCount,robCount,buyRobCount)
    elseif buttonName == "Button_Previous" then
        if self.currentPage > 1 then
            self.currentPage = self.currentPage - 1
            self:showPage()
        end
    elseif buttonName == "Button_Next" then
        if self.currentPage < self.totalPage then
            self.currentPage = self.currentPage + 1
            self:showPage()
        end
    end
end

function ExpressLoot:buyRobCount(maxCount,robCount,buyRobCount,content)

    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_buy_rob_cost")
    local priceStr = Config:getValue("StrValue")
    local priceArray = string.split(priceStr,"|")
    local index = buyRobCount+1 > #priceArray and #priceArray or buyRobCount+1
    local price = tonumber(priceArray[index])

    local txt = "是否消耗"
    if content ~= nil then
        txt = content .. txt
    end
    local function comfirmFunc()
        --檢測是否元寶足夠
        if cp.getManager("ViewManager").checkGoldEnough(price) then
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").BuyRobReq, req) --購買伏擊次數
        end
    end

    local contentTable = {
        {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=txt, textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，來購買1次伏擊次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
    }
    cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

end

function ExpressLoot:onJieBiaoButtonClicked(info)
    dump(info)

    local robCount = cp.getUserData("UserVan"):getValue("robCount")
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_rob_count")
    local maxCount = Config:getValue("IntValue")
    local buyRobCount = cp.getUserData("UserVan"):getValue("buyRobCount")
    if maxCount + buyRobCount - robCount > 0 then
        self.fightInfo = {name=info.ownerName, place = self.title}
        local req = {uuid = info.uuid, place = self.title}
        self:doSendSocket(cp.getConst("ProtoConst").RobVanReq, req)
    else
        --伏擊次數不足,是否花費20元寶購買伏擊次數？
        self:buyRobCount(maxCount,robCount,buyRobCount,"伏擊次數不足,")
    end
end

function ExpressLoot:refreshAllVan()

    local other_van_list = cp.getUserData("UserVan"):getValue("other_van_list")
    self.all_van_array = {}

    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_berob_count")
    local maxCount = Config:getValue("IntValue")

    local function canBeRobbedHere(robInfo,curTitle)
        if table.nums(robInfo) >= maxCount then --此鏢車已被伏擊最大次數，不能再被伏擊
            return false
        end
        for i=1,table.nums(robInfo) do
            if robInfo[i].place == curTitle and  robInfo[i].success then --此鏢車在此被伏擊過
                return false
            end
        end
        return true
    end

    local canNotBeRobbedList = {}
    local canBeRobbedEnemyList = {}
    local now = cp.getManager("TimerManager"):getTime()
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    for uuid,info in pairs(other_van_list) do
        local id = info.id
        local lastTime = now - info.startStamp

        local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", id)
        local Time = string.split(itemCfg:getValue("Time"),"|")
        local step_time_list = cp.getManager("GDataManager"):getExpressVehicleStepTime(Time)
    
        local beginTime,endTime = 0,0
        if self.openInfo.pos_idx == 2 then
            beginTime = step_time_list[1] + step_time_list[2]
            endTime = beginTime + step_time_list[3]
        elseif self.openInfo.pos_idx == 3 then
            beginTime = step_time_list[1] + step_time_list[2] + step_time_list[3] + step_time_list[4] + step_time_list[5] + step_time_list[6]
            endTime = beginTime + step_time_list[7]
        elseif self.openInfo.pos_idx == 4 then
            for i=1,9 do
                beginTime = beginTime + step_time_list[i]
            end
            endTime = beginTime + step_time_list[10]
        end
        if lastTime >= beginTime - 3 and lastTime <= endTime - 3 then  --在此停留區間類才顯示
            local isEnemy = cp.getUserData("UserFriend"):getEnemy(info.ownerRoleID) ~= nil
            local newInfo = info
            newInfo.isEnemy = isEnemy
            newInfo.Level = itemCfg:getValue("Level")
            newInfo.fightDistance = math.abs(info.ownerFight-major_roleAtt.fight)
            newInfo.canBeRobbed = canBeRobbedHere(info.robInfo,self.title) 
            if not newInfo.canBeRobbed then
                table.insert(canNotBeRobbedList,newInfo)
            else
                if isEnemy then
                    table.insert(canBeRobbedEnemyList,newInfo)
                else
                    table.insert(self.all_van_array,newInfo)
                end
            end
            
        end
    end

    --[[
    排序優先如下
    1.優先顯示沒有被伏擊的鏢車訊息
    2.優先顯示戰鬥力相近的玩家
    3.優先顯示江湖仇敵的鏢車
    4.優先顯示等階高的玩家的鏢車訊息
    5.優先顯示等級高的鏢車訊息
    6.不能顯示玩家自己的鏢車訊息（即不能劫自己的鏢車）--- other_van_list直接排除掉自己的鏢車訊息
    7.每個地點僅顯示停靠在該地點的鏢車訊息
    （從上至下優先級逐漸降低）
    ]]

    local function sort_vans(a,b)
        if a.fightDistance == b.fightDistance then
            if a.ownerHierarchy == b.ownerHierarchy then
                if a.Level == b.Level then
                    return a.startStamp > b.startStamp
                else
                    return a.Level > b.Level
                end
            else
                return a.ownerHierarchy > b.ownerHierarchy
            end
        else
            return a.fightDistance < b.fightDistance
        end

    end


    if table.nums(self.all_van_array) > 0 then
        table.sort(self.all_van_array,sort_vans)
    end
    --先把敵人放在最前
    if table.nums(canBeRobbedEnemyList) > 0 then
        for i=1,table.nums(canBeRobbedEnemyList) do
            table.insert(self.all_van_array, canBeRobbedEnemyList[i],1)
        end
    end
    --最後把不能伏擊的加到末尾
    if table.nums(canNotBeRobbedList) > 0 then
        for i=1,table.nums(canNotBeRobbedList) do
            self.all_van_array[#self.all_van_array + 1] = canNotBeRobbedList[i]
        end
    end

    if  table.nums(self.all_van_array) > 0  then
        self.totalPage = math.ceil(table.nums(self.all_van_array)/self.NumPerPage)
        if self.currentPage > self.totalPage then
            self.currentPage = self.totalPage
        end
        self:showPage()
    end

end

function ExpressLoot:onBuyRobCountBack()
    self:updateRobCount()
end

return ExpressLoot
