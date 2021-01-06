
local BNode = require "cp.view.ui.base.BNode"
local ExpressEscortItem = class("ExpressEscortItem",BNode)

function ExpressEscortItem:create(openInfo)
    local node = ExpressEscortItem.new(openInfo)
    return node
end

function ExpressEscortItem:initListEvent()
    self.listListeners = {
      
    }
end

function ExpressEscortItem:onInitView(openInfo)
    self.openInfo = openInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_yabiao_item.csb") 
    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Image_icon"] = {name = "Image_icon"},
        ["Panel_item.Image_double"] = {name = "Image_double"},
        ["Panel_item.Image_mark"] = {name = "Image_mark"},
        ["Panel_item.Image_mark_1"] = {name = "Image_mark_1"},
        ["Panel_item.Text_level"] = {name = "Text_level"},
        ["Panel_item.Node_2"] = {name = "Node_2"},
        ["Panel_item.Node_1"] = {name = "Node_1"},
        ["Panel_item.Button_yabiao"] = {name = "Button_yabiao",click = "onItemClick"},
    }
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self.Image_double:setVisible(false)
    self.Image_mark:setVisible(false)
    self.Image_mark_1:setVisible(false)
end

function ExpressEscortItem:onEnterScene()

end

function ExpressEscortItem:onExitScene()

end

function ExpressEscortItem:resetInfo(info)
    self.openInfo = info
    self.Image_mark:setVisible(false)
    self.Image_mark_1:setVisible(false)
    local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", info.id)
    local lv = itemCfg:getValue("Level")  --鏢車的等級
    local Time = string.split(itemCfg:getValue("Time"),"|")
    local totalTime = 0
    for i=1,#Time do
        totalTime = totalTime + tonumber(Time[i])
    end

    local icon = itemCfg:getValue("Icon")
    self.Image_icon:loadTexture(icon,ccui.TextureResType.plistType)

    self.Text_level:setString(cp.getConst("CombatConst").NumberZh_Cn[lv] .. "級鏢車")
    local vip = cp.getUserData("UserVip"):getValue("level")
    local now = cp.getManager("TimerManager"):getTime()
    local state = 0 -- 0:未開啟 1：正在進行 2：已結束
    local shaderName = nil
    if info.startStamp > 0 then  --已經開啟
        state = (now - info.startStamp > totalTime) and 2 or 1
        
    end

    self.Image_mark:setVisible(state > 0)
    self.Image_mark_1:setVisible(state > 0)
    self.Button_yabiao:setVisible(state == 0)
    
    if state > 0 then
        local file = state == 1 and "ui_express_module21_yabiao_3.png" or "ui_express_module21_yabiao_4.png"
        self.Image_mark:loadTexture(file, ccui.TextureResType.plistType)
        shaderName = cp.getConst("ShaderConst").GrayShader
    end
    cp.getManager("ViewManager").setShader(self.Image_icon,shaderName)

    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local item_list,isHoliday = cp.getManager("GDataManager"):getVanReward(itemCfg,false,major_roleAtt.hierarchy)
    self.Image_double:setVisible(isHoliday)
    
    for i=1,2 do
        self["Node_" .. tostring(i)]:removeAllChildren()
    end

    for i=1,#item_list do
        
        if i>2 then break end
        
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", item_list[i].itemID)
        local itemInfo = {id = item_list[i].itemID, num = item_list[i].itemNum, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type") }
        local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
        item:setScale(1)
        item:setItemClickCallBack(function(info)
            -- local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
            -- self:addChild(layer, 2)
            -- layer:hidePlaceAndButtons()
        end)
        self["Node_" .. tostring(i)]:addChild(item)
    end

    if #item_list <= 1 then
        self["Node_1"]:setPosition(cc.p(468,90))
    else
        self["Node_1"]:setPosition(cc.p(404,90))
        self["Node_2"]:setPosition(cc.p(522,90))
    end
end

function ExpressEscortItem:setIndex(i)
    self._index = i
end

function ExpressEscortItem:getIndex()
    return self._index
end


function ExpressEscortItem:onItemClick(sender)
    if self.openInfo.startStamp ~= nil and self.openInfo.startStamp > 0 then
        cp.getManager("ViewManager").gameTip("鏢車正在路途中...")
        return
    end
    if self.itemClickCallBack ~= nil then
        self.itemClickCallBack(self.openInfo,self._index)
    end
end

function ExpressEscortItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return ExpressEscortItem
