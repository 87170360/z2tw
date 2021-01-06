local BLayer = require "cp.view.ui.base.BLayer"
local RiverEventListLayer = class("RiverEventListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverEventListLayer:create()
	local scene = RiverEventListLayer.new()
    return scene
end

function RiverEventListLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").GetConductRsp] = function(proto)
            self:updateRiverEventListView()
        end,
        
        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "RiverEventListLayer" then
                if evt.guide_name == "river_event" then
                    if evt.target_name == "Button_Start" then
                        self:onNewGuideStory(0)
                        self:onBtnClick(self[evt.target_name])
                    elseif evt.target_name == "event_item_1" then
                        if self.selectIndex ~= 1 then
                            self.selectIndex = 1
                        end
                        self:onNewGuideStory()
                    end
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "RiverEventListLayer" then
                if evt.guide_name == "river_event" then
                    if evt.target_name == "Button_Start" then
                        local boundbingBox = self[evt.target_name]:getBoundingBox()
                        local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                        local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                        evt.ret = finger_info
                    elseif evt.target_name == "event_item_1" then
                        -- for i, conductEventEntry in ipairs(self.eventList) do
                        --     if conductEventEntry:getValue("Hierarchy") == 1 and conductEventEntry:getValue("Process") == 2 then
                        --         local confId = conductEventEntry:getValue("ID")
                                
                        --     end
                        -- end
                        
                        local item = self.ListView_EventList:getItem(0)
                        local boundbingBox = item:getBoundingBox()
                        local pos = item:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                        local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                        evt.ret = finger_info
                    end
                    
                end
            end
		end,
    }
end

function RiverEventListLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Start" then
        local eventEntry = self.eventList[self.selectIndex]
        local confId = eventEntry:getValue("ID")
        if confId > 0 then
            local conductData = {confId = confId}
            self:dispatchViewEvent(cp.getConst("EventConst").NavigateEvent, conductData)
            self:removeFromParent()
        end
    elseif btnName == "Button_Close" then
        self:removeFromParent()
    elseif btnName == "Button_help" then
        cp.getManager("ViewManager").showHelpTips("riverEventList")
    end
end

--初始化界面，以及設定界面元素標籤
function RiverEventListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_event_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_1"] = {name = "Image_1"},
        
        ["Panel_root.Image_1.Button_help"] = {name = "Button_help", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
        ["Panel_root.Image_1.Button_Start"] = {name = "Button_Start", click="onBtnClick"},
        ["Panel_root.Image_1.ListView_EventList"] = {name = "ListView_EventList"},
        ["Panel_root.Image_1.Button_Model"] = {name = "Button_Model"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.ListView_EventList:setScrollBarEnabled(false)
    self.Image_1:setPositionY(display.height/2)
    self:updateRiverEventListView()
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
    ccui.Helper:doLayout(self["rootView"])
end

function RiverEventListLayer:getEventList()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local type = majorRole.conductType or 1 -- 善惡模式1 善, 2 惡
    self.eventList = cp.getManager("ConfigManager").getItemListByMatch("GameConduct", {Type=type})
    table.sort(self.eventList, function(a, b)
        return a:getValue("Hierarchy") < b:getValue("Hierarchy")
    end)
end

function RiverEventListLayer:updateOneButton(button, conductEventEntry)

    local icon = button:getChildByName("Image_Icon")
    local name = button:getChildByName("Text_Name")
    local desc = button:getChildByName("Text_Desc")
    local mask = button:getChildByName("Image_Mask")
    local mask_state = button:getChildByName("Image_Mask_State")
    local mask_level = button:getChildByName("Image_Mask_level")
    
    if conductEventEntry:getValue("Hierarchy") <= self.level then
        mask:setVisible(false)
        button:setEnabled(true)
        mask_level:setVisible(true)
        mask_state:setVisible(true)
        local level = mask_level:getChildByName("Text_Level")
        level:setString(cp.getUtils("DataUtils").formatZh_CN(conductEventEntry:getValue("Hierarchy")).."階")

        local Text_State = mask_state:getChildByName("Text_State")
       
        local confId = conductEventEntry:getValue("ID")
        local state = self:getConductState(confId)
        if state > 0 then
            local str = ""
            if state == 2 then str = "進行中" end
            if state == 3 then str = "已完成" end
            if state == 4 then str = "被打斷" end
            Text_State:setString(str)
            local textColor = state == 2 and 5 or 2 
            cp.getManager("ViewManager").setTextQuality(Text_State, textColor)
        else
            mask_state:setVisible(false)
        end
    else
        mask:setVisible(true)
        button:setEnabled(false)
        mask_state:setVisible(false)
        mask_level:setVisible(false)
        local level = mask:getChildByName("Text_Level")
        level:setString(cp.getUtils("DataUtils").formatZh_CN(conductEventEntry:getValue("Hierarchy")).."階開啟")
    end

    if self.ListView_EventList:getItem(self.selectIndex-1) == button then
        local textureName = "ui_mapbuild_module6_jianghushi_shijianbu02.png"
        button:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        name:setTextColor(cc.c4b(254,217,170,255))
        name:enableOutline(cc.c4b(97,32,9,255), 2)
        desc:setTextColor(cc.c4b(254,217,170,255))
        desc:enableOutline(cc.c4b(97,32,9,255), 2)
    else
        local textureName = "ui_mapbuild_module6_jianghushi_shijianbu03.png"
        button:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        name:setTextColor(cc.c4b(53,31,16,255))
        name:enableOutline(cc.c4b(97,32,9,0), 0)
        desc:setTextColor(cc.c4b(53,31,16,255))
        desc:enableOutline(cc.c4b(97,32,9,0), 0)
    end
    icon:loadTexture(conductEventEntry:getValue("Icon"), ccui.TextureResType.localType)
    icon:ignoreContentAdaptWithSize(true)
    name:setString(conductEventEntry:getValue("Name"))
    desc:setString(conductEventEntry:getValue("Desc"))
    
end

function RiverEventListLayer:sortEventList()
    cp.getUtils("DataUtils").quick_sort(self.eventList, function(eventEntryA, eventEntryB)
        if eventEntryA:getValue("Hierarchy") <= self.level and eventEntryB:getValue("Hierarchy") <= self.level then
            return eventEntryA:getValue("Hierarchy") >= eventEntryB:getValue("Hierarchy")
        elseif eventEntryA:getValue("Hierarchy") > self.level and eventEntryB:getValue("Hierarchy") > self.level then
            return eventEntryA:getValue("Hierarchy") < eventEntryB:getValue("Hierarchy")
        elseif eventEntryA:getValue("Hierarchy") > self.level then
            return false
        elseif eventEntryB:getValue("Hierarchy") > self.level then
            return true
        end
    end)
end

function RiverEventListLayer:updateRiverEventListView()
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    self.level = majorRole.hierarchy
    self:getEventList()
    self:sortEventList()
    
    for i, conductEventEntry in ipairs(self.eventList) do
        local confId = conductEventEntry:getValue("ID")
        local button = self.ListView_EventList:getItem(i-1)
        if not button then
            button = self.Button_Model:clone()
            button:setVisible(true)
            self.ListView_EventList:pushBackCustomItem(button)
            cp.getManager("ViewManager").initButton(button, function()
                local preButton = tolua.cast(self.ListView_EventList:getItem(self.selectIndex-1), "ccui.Button")
                local preEntry = self.eventList[self.selectIndex]
                self.selectIndex = i
                self:updateOneButton(preButton, preEntry,state)
                self:updateOneButton(button, conductEventEntry,state)
            end, 1.0)
        end

        if not self.selectIndex then
            self.selectIndex = i
        end

        self:updateOneButton(button, conductEventEntry, state)
    end

    for i=#self.eventList, self.ListView_EventList:getChildrenCount()-1 do
        self.ListView_EventList:removeItem(i)
    end

end

function RiverEventListLayer:onEnterScene()

    self:onNewGuideStory()
end

function RiverEventListLayer:onExitScene()
    self:unscheduleUpdate()
end

function RiverEventListLayer:getConductState( confId )
    local state = 0
    local map_event_list = cp.getUserData("UserMapEvent").map_event_list
    for uuid,info in pairs(map_event_list) do
        if info.confId == confId then
            state = info.state
        end
    end
    return state
end


function RiverEventListLayer:onNewGuideStory(delay)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "river_event" then
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        if cur_step == 5 or cur_step == 11 or cur_step == 13 then
            if delay and delay == 0 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",15)
                local info =
                {
                    classname = "RiverEventListLayer",
                }
                self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
            else
                local sequence = {}
                table.insert(sequence, cc.DelayTime:create(0.3))
                table.insert(sequence,cc.CallFunc:create(
                    function()
                        local info =
                        {
                            classname = "RiverEventListLayer",
                        }
                        self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                    end)
                )
                self:runAction(cc.Sequence:create(sequence))
            end
        end
    end
end

return RiverEventListLayer