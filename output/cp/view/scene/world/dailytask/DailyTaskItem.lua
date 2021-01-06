
local BNode = require "cp.view.ui.base.BNode"
local DailyTaskItem = class("DailyTaskItem",BNode)

function DailyTaskItem:create()
	local node = DailyTaskItem.new()
	return node
end

function DailyTaskItem:initListEvent()
	self.listListeners = {

        -- --領取任務獎勵返回
        -- [cp.getConst("EventConst").GetDailyTaskRsp] = function(data)	
        --     self.Text_1:setString("已完成")
        --     self.Button_go:setTouchEnabled(false)
        -- end,
	}
end

function DailyTaskItem:onInitView()
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_daily_task/uicsb_daily_task_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Panel_name"] = {name = "Panel_name"},
        ["Panel_item.Text_des"] = {name = "Text_des"},
        ["Panel_item.Node_item_1"] = {name = "Node_item_1"},
        ["Panel_item.Node_item_2"] = {name = "Node_item_2"},
        ["Panel_item.Image_finished"] = {name = "Image_finished"},
        ["Panel_item.Button_go"] = {name = "Button_go", click = "onUIButtonClick"},
        ["Panel_item.Button_go.Text_1"] = {name = "Text_1"}
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
end

function DailyTaskItem:onEnterScene()
    
end

function DailyTaskItem:resetInfo(taskInfo)
    self.taskInfo = taskInfo
    
    self.Node_item_1:removeAllChildren()
    self.Node_item_2:removeAllChildren()
    self.Panel_name:removeAllChildren()

    if self.taskInfo.item_list[1] then
        local itemInfo = {id = self.taskInfo.item_list[1].id}
        local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", self.taskInfo.item_list[1].id)
        itemInfo.Name = conf:getValue("Name")
        itemInfo.Icon = conf:getValue("Icon")
        itemInfo.Type = conf:getValue("Type")
        itemInfo.SubType = conf:getValue("SubType")
        itemInfo.Package = conf:getValue("Package")
        itemInfo.Colour = conf:getValue("Hierarchy")
        itemInfo.num = self.taskInfo.item_list[1].num
        local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
        if itemIcon ~= nil then
            self.Node_item_1:addChild(itemIcon)
        end
    end
    if self.taskInfo.item_list[2] then
        local itemInfo = {id = self.taskInfo.item_list[2].id}
        local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", self.taskInfo.item_list[2].id)
        itemInfo.Name = conf:getValue("Name")
        itemInfo.Icon = conf:getValue("Icon")
        itemInfo.Type = conf:getValue("Type")
        itemInfo.SubType = conf:getValue("SubType")
        itemInfo.Package = conf:getValue("Package")
        itemInfo.Colour = conf:getValue("Hierarchy")
        itemInfo.num = self.taskInfo.item_list[2].num
        local itemIcon = require("cp.view.ui.icon.ItemIcon"):create(itemInfo) 
        if itemIcon ~= nil then
            self.Node_item_2:addChild(itemIcon)
        end
    end

    self.Text_des:setString(self.taskInfo.Desc)

    local state = cp.getUserData("UserDailyData"):getTaskState(self.taskInfo.ID)
    local txt = {[0] = "前    往", [1] = "領    取", [2] = "已完成" }
    self.Text_1:setString(txt[state])
    self.Text_1:setTextColor( state == 1 and cc.c4b(4,79,11,255) or cc.c4b(122,22,22,255))
    self.Button_go:setVisible(state < 2)
    local pic = state == 1 and "ui_common_module60_rechang7.png" or "ui_common_newbtn.png"
    self.Button_go:loadTextures(pic,pic,pic,ccui.TextureResType.plistType)
    self.Image_finished:setVisible(state==2)
    
    local curProgress = cp.getUserData("UserDailyData"):getTaskCompleteTimes(self.taskInfo.ID)
    local contentTable = {
        {type="ttf", fontSize=30,fontName="fonts/HYJinChangTiJ.ttf", text=self.taskInfo.Name, textColor=cc.c4b(52,32,17,255)},
        {type="ttf", fontSize=30, text="(" .. tostring(curProgress), textColor=cc.c4b(52,32,17,255)},
        {type="ttf", fontSize=30, text="/", textColor=cc.c4b(52,32,17,255)},
        {type="ttf", fontSize=30, text=tostring(self.taskInfo.Limit) .. ")", textColor=cc.c4b(52,32,17,255)},
    }
    local richText = require("cp.view.ui.base.RichText"):create()
	richText:setAnchorPoint(cc.p(0.5,0))
    richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(300,40))
	richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)
    -- richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    richText:setLineGap(1)
	
    for i=1,#contentTable do
		richText:addElement(contentTable[i])
	end
   
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setPosition(cc.p(150,0))
    self.Panel_name:addChild(richText)
end

function DailyTaskItem:getItemSize()
    return self.Panel_item:getContentSize()
end

function DailyTaskItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
    
    dump(self.taskInfo)
    
    local state = cp.getUserData("UserDailyData"):getTaskState(self.taskInfo.ID)
    if state == 2 then --已領取獎勵
        cp.getManager("ViewManager").gameTip("獎勵已領取")
        return
    elseif state == 1 then --已完成未領獎

        local req = {taskID = self.taskInfo.ID}
        self:doSendSocket(cp.getConst("ProtoConst").GetDailyTaskReq, req)
        return
    end
    
    if self.taskInfo.ID == 1 then --劇情闖關
        local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu,auto_open_name = "ChapterPartLayer"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})

    elseif self.taskInfo.ID == 2 then -- 祕境
        local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu,auto_open_name = "MijingMainLayer"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 3 then --藏寶閣抽獎
        local open_info = {name = cp.getConst("SceneConst").MODULE_LotteryHouse}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif self.taskInfo.ID == 4 then  --武學升級
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillSummary}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif self.taskInfo.ID == 5 then  --門派修煉
        local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai,auto_open_name = "MenPaiXiuLian"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 6 then --歷練
        local open_info = {name = cp.getConst("SceneConst").MODULE_JiangHu,auto_open_name = "LilianMainLayer"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 7 then  --比武場
        self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, true)
    elseif self.taskInfo.ID == 8 then -- 門派地位戰
        local open_info = {name = cp.getConst("SceneConst").MODULE_MenPai,auto_open_name = "MenPaiPlace"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 9 then  --斗酒
        self:dispatchViewEvent(cp.getConst("EventConst").GetGuessFingerDataRsp, true)
    elseif self.taskInfo.ID == 10 then --鬥老千
        self:dispatchViewEvent(cp.getConst("EventConst").GetRollDiceDataRsp, true)
    elseif self.taskInfo.ID == 14 then --體力購買
        cp.getManager("ViewManager").showBuyPhysicalUI()
    elseif self.taskInfo.ID == 15 then --儲值
        cp.getManager("ViewManager").showRechargeUI()

    elseif self.taskInfo.ID == 11 then -- 江湖切磋
        local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 12 then -- 押鏢
        local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap,auto_open_name = "ExpressEscort"}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    elseif self.taskInfo.ID == 13 then -- 善惡事件
        local open_info = {name = cp.getConst("SceneConst").MODULE_WorldMap}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module,{open_info = open_info})
    end
    
end


return DailyTaskItem
