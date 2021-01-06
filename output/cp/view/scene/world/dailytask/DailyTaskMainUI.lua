
local BLayer = require "cp.view.ui.base.BLayer"
local DailyTaskMainUI = class("DailyTaskMainUI",BLayer)

function DailyTaskMainUI:create(openInfo)
	local layer = DailyTaskMainUI.new(openInfo)
	return layer
end

function DailyTaskMainUI:initListEvent()
	self.listListeners = {

        [cp.getConst("EventConst").GetDailyTaskRsp] = function(data)	
            self:refreshAccu()
            -- if self.cellView then
            --     self:reOrderTaskList()
            --     -- local offset = self.cellView:getContentOffset()    
            --     self.cellView:reloadData()
                
            -- end

            self:createCellItems()

            for _,taskInfo in pairs(self.taskList) do
                if data.taskID == taskInfo.ID then
                    -- cp.getManager("ViewManager").gameTip("獲得" .. tostring(taskInfo.accu) .. "任務積分")
                    cp.getManager("ViewManager").showGetRewardUI(taskInfo.item_list,"恭喜獲得",true)
                    break
                end
            end

        end,

        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            if self.cellView then
                self:reOrderTaskList()
                -- local offset = self.cellView:getContentOffset()
                self.cellView:reloadData()
                -- self.cellView:setContentOffset(offset, false)
            end
            self:refreshAccu()
        end,

        [cp.getConst("EventConst").GetDailyPointRsp] = function(data)	
            self:refreshAccu()
        end,

        [cp.getConst("EventConst").GetDailyDataRsp] = function(data)	
            if self.cellView then
                self:reOrderTaskList()
                -- local offset = self.cellView:getContentOffset()
                self.cellView:reloadData()
                -- self.cellView:setContentOffset(offset, false)
            end
        end,
	}
end

function DailyTaskMainUI:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_daily_task/uicsb_daily_task_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_title"] = {name = "Panel_title"},
        ["Panel_root.Panel_title.Panel_content"] = {name = "Panel_content"},
        ["Panel_root.Panel_title.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        
        ["Panel_root.Panel_title.Panel_reward"] = {name = "Panel_reward"},
        ["Panel_root.Panel_title.Panel_reward.Text_reset_time"] = {name = "Text_reset_time"},
        ["Panel_root.Panel_title.Panel_reward.Text_jifen"] = {name = "Text_jifen"},
        -- ["Panel_root.Panel_title.Panel_reward.Image_p_bg "] = {name = "Image_p_bg"},
        ["Panel_root.Panel_title.Panel_reward.Image_progress"] = {name = "Image_progress"},

        
        ["Panel_root.Panel_title.Panel_reward.Button_Reward1"] = {name = "Button_Reward1",click = "onRewardButtonClick"},
        ["Panel_root.Panel_title.Panel_reward.Button_Reward2"] = {name = "Button_Reward2",click = "onRewardButtonClick"},
        ["Panel_root.Panel_title.Panel_reward.Button_Reward3"] = {name = "Button_Reward3",click = "onRewardButtonClick"},
        ["Panel_root.Panel_title.Panel_reward.Button_Reward4"] = {name = "Button_Reward4",click = "onRewardButtonClick"},
        ["Panel_root.Panel_title.Panel_reward.Image_1"] = {name = "Image_1"},
        ["Panel_root.Panel_title.Panel_reward.Image_2"] = {name = "Image_2"},
        ["Panel_root.Panel_title.Panel_reward.Image_3"] = {name = "Image_3"},
        ["Panel_root.Panel_title.Panel_reward.Image_4"] = {name = "Image_4"},
        ["Panel_root.Panel_title.Panel_reward.Text_1"] = {name = "Text_1"},
        ["Panel_root.Panel_title.Panel_reward.Text_2"] = {name = "Text_2"},
        ["Panel_root.Panel_title.Panel_reward.Text_3"] = {name = "Text_3"},
        ["Panel_root.Panel_title.Panel_reward.Text_4"] = {name = "Text_4"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    self:setPosition(display.cx,display.cy)

    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
        self:dispatchViewEvent(cp.getConst("EventConst").open_daily_task,false) 
    end)
    cp.getManager("ViewManager").popUpView(self.Panel_root)
end

function DailyTaskMainUI:onEnterScene()
   self:createCellItems()
   self:refreshAccu()
end

function DailyTaskMainUI:onExitScene()
    
end

function DailyTaskMainUI:refreshAccu()
    local currentAccu = cp.getUserData("UserDailyData"):getValue("daily_data").accu
    self.Text_jifen:setString(tostring(currentAccu))

    local totalAccu = 0
    local AccuList = cp.getUserData("UserDailyData"):getValue("AccuList")
    
    local pic = {"ui_daily_task_module60_rechang4.png","ui_daily_task_module60_rechang5.png"}

    local btn_pics = {
        {"ui_daily_task_module33_qiandao_baoxiang01.png","ui_daily_task_module33_qiandao_baoxiangdakai01.png"},
        {"ui_daily_task_module33_qiandao_baoxiang03.png","ui_daily_task_module33_qiandao_baoxiangdakai03.png"},
        {"ui_daily_task_module33_qiandao_baoxiang04.png","ui_daily_task_module33_qiandao_baoxiangdakai04.png"},
        {"ui_daily_task_module33_qiandao_baoxiang05.png","ui_daily_task_module33_qiandao_baoxiangdakai05.png"},
    }
    local idx = 1
    for _,accuInfo in pairs(AccuList) do
        totalAccu = math.max(totalAccu ,accuInfo.Accu)
       
        if idx <= 4 then
            local state = cp.getUserData("UserDailyData"):getTaskAccu(accuInfo.ID)
            local btnPic = state >=2 and btn_pics[idx][2] or btn_pics[idx][1]
            self["Button_Reward".. tostring(idx)]:setTag(accuInfo.ID)
            self["Button_Reward".. tostring(idx)]:loadTextures(btnPic,btnPic,btnPic, UI_TEX_TYPE_PLIST)
            
            self["Button_Reward".. tostring(idx)]:getChildByName("Image_Flag"):setVisible(state >= 2)
            
            self["Text_" .. tostring(idx)]:setString( tostring(accuInfo.Accu) .. "積分")
            self["Image_" .. tostring(idx)]:loadTexture( state >= 2 and pic[1] or pic[2] ,UI_TEX_TYPE_PLIST)

            self:addCanRewardAnimation(self["Button_Reward".. tostring(idx)],state)
            self["Button_Reward".. tostring(idx)]:setTouchEnabled(state<2)
        end
        idx = idx + 1
    end

    -- local sz = self.Image_p_bg:getContentSize()
    local width = 440--sz.width
    if totalAccu > 0 then
        local scale = currentAccu/totalAccu
        scale = math.min(scale,1.0)
        width = math.floor(width * scale)
    end
    self.Image_progress:setContentSize(cc.size(width,18))
end

function DailyTaskMainUI:addCanRewardAnimation(btn,state)
    btn:stopAllActions()
    if state == 1 then
        btn:setRotation(0)
        if btn then
            local act = {}
            local act1 = cc.EaseSineOut:create(cc.RotateTo:create(0.1,-15))
            local act2 = cc.EaseSineIn:create(cc.RotateTo:create(0.1,0))
            local act3 = cc.EaseSineOut:create(cc.RotateTo:create(0.1,15))
            local act4 = cc.EaseSineIn:create(cc.RotateTo:create(0.1,0))
            local act5 = cc.DelayTime:create(2)

            local acts = {act1,act2,act3,act4,act5}
            local seq = cc.Sequence:create(acts)
            local action = cc.RepeatForever:create(seq)
            btn:runAction(action)
        end
    end
end

function DailyTaskMainUI:reOrderTaskList()

    local function cmp(a,b)
        if a and b then
            local stateA = cp.getUserData("UserDailyData"):getTaskState(a.ID)
            local stateB = cp.getUserData("UserDailyData"):getTaskState(b.ID)
            if stateA == stateB then
                return a.ID < b.ID    
            else
                return stateA < stateB
            end
        end
        return false
    end
    
    table.sort(self.taskList,cmp)

    local list = {}
    local infoList = {}
    for _,taskInfo in pairs(self.taskList) do
        local state = cp.getUserData("UserDailyData"):getTaskState(taskInfo.ID)
        if state == 1 then
            table.insert(list,taskInfo.ID)
            table.insert(infoList,taskInfo)
        end
    end
    if table.nums(list) > 0 then
        table.sort(infoList,function(a,b)
            return a.ID < b.ID
        end)


        for i = table.nums(self.taskList),1,-1 do
            taskInfo = self.taskList[i]
            if table.arrIndexOf(list,taskInfo.ID) ~= -1 then
                table.remove(self.taskList,i)
            end
        end

        for i = table.nums(infoList),1,-1 do
            table.insert(self.taskList,1,infoList[i])
        end
    end
    

end

function DailyTaskMainUI:createCellItems()
    -- self.Panel_content:removeAllChildren()
    if self.cellView then
        self.cellView:removeFromParent()
    end
   
    self.taskList = cp.getManager("GDataManager"):getDailyTaskList()

    self:reOrderTaskList()

    local sz = self.Panel_content:getContentSize()
    self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width,sz.height))
    self.cellView:setCellSize(sz.width,160)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p(0, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.taskList)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1

        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.dailytask.DailyTaskItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        item:resetInfo(self.taskList[idx])
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.cellView:reloadData()
    self["Panel_content"]:addChild(self.cellView,1)
    
end

-- function DailyTaskMainUI:setCloseCallBack(cb)
--     self.closeCallBack = cb
-- end

function DailyTaskMainUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        self:dispatchViewEvent(cp.getConst("EventConst").open_daily_task,false) 
    
    end
end

function DailyTaskMainUI:onRewardButtonClick(sender)
    local buttonName = sender:getName()
    local id = sender:getTag()
    if id > 0 then
        local state = cp.getUserData("UserDailyData"):getTaskAccu(id)
        if state == 1 then
            local req = {AccuID = id}
            self:doSendSocket(cp.getConst("ProtoConst").GetDailyPointReq, req)
        else
            -- cp.getManager("ViewManager").gameTip("積分不足，還不能領取獎勵。")
            local AccuList = cp.getManager("GDataManager"):getDailyTaskAccuList() 
            if AccuList[id] and AccuList[id].item_list then
                cp.getManager("ViewManager").showGameRewardPreView(AccuList[id].item_list,"獎勵預覽",false)
            end
        end
    end
end

return DailyTaskMainUI
