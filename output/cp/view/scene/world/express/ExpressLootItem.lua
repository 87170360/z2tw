
local BNode = require "cp.view.ui.base.BNode"
local ExpressLootItem = class("ExpressLootItem",BNode)

function ExpressLootItem:create(openInfo)
    local node = ExpressLootItem.new(openInfo)
    return node
end

function ExpressLootItem:initListEvent()
    self.listListeners = {
        
    }
end

function ExpressLootItem:onInitView(openInfo)
    self.openInfo = openInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_jiebiao_item.csb") 
    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Image_title"] = {name = "Image_title"},
        ["Panel_item.Image_enemy"] = {name = "Image_enemy"},
        ["Panel_item.Text_name"] = {name = "Text_name"},
        ["Panel_item.Text_level"] = {name = "Text_level"},
        ["Panel_item.Text_fight"] = {name = "Text_fight"},
        ["Panel_item.Node_2"] = {name = "Node_2"},
        ["Panel_item.Node_1"] = {name = "Node_1"},
        ["Panel_item.Button_jiebiao"] = {name = "Button_jiebiao",click = "onItemClick"},
    }
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self.Image_enemy:setVisible(false)

end

function ExpressLootItem:getContentSize()
    return self.Panel_item:getContentSize()
end

function ExpressLootItem:onEnterScene()

end

function ExpressLootItem:onExitScene()

end

function ExpressLootItem:reset(info,place)
    self.openInfo = info
    self.Image_enemy:setVisible(false)
    -- self.Image_title:setVisible(false)
    -- self.Text_fight:setVisible(false)
    -- self.Text_name:setVisible(false)
    -- self.Text_level:setVisible(false)
    
    if info ~= nil and next(info) ~= nil then
        
        local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", info.id)
        local lv = itemCfg:getValue("Level")  --鏢車的等級

        self.Text_fight:setString("戰力：" .. tostring(info.ownerFight))
        local hierarchyInfo = cp.getManager("GDataManager"):getHierarchyInfo(info.ownerCareer or 0, 0, info.ownerHierarchy)
        self.Text_level:setString(hierarchyInfo)
        self.Text_name:setString(info.ownerName)
        if cp.getUserData("UserFriend"):getEnemy(info.ownerRoleID) ~= nil then
            self.Image_enemy:setVisible(true)
        end

        local path_list = {
            [1]="ui_express_module21_yabiao_13.png",  --一階鏢車
            [2]="ui_express_module21_yabiao_12.png", --二階
            [3]="ui_express_module21_yabiao_8.png", 
            [4]="ui_express_module21_yabiao_7.png", 
            [5]="ui_express_module21_yabiao_6.png", --五階鏢車
            [6]="ui_express_module21_yabiao_19.png" --洗劫一空
        }
        local path = path_list[lv]
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_berob_count")
        local maxCount = Config:getValue("IntValue")
        if cp.getManager("GDataManager"):isBeRobbed(place,info.robInfo) then --洗劫一空
            path = path_list[6]
            self.Button_jiebiao:setEnabled(false)
            cp.getManager("ViewManager").setShader(self.Button_jiebiao,cp.getConst("ShaderConst").GrayShader)
        else
            self.Button_jiebiao:setEnabled(true)
            cp.getManager("ViewManager").setShader(self.Button_jiebiao,nil)
        end
        self.Image_title:loadTexture(path,ccui.TextureResType.plistType)

        self:initReward(itemCfg)

        self:setVisible(true)
    else
        self:setVisible(false)
    end

end

function ExpressLootItem:initReward(itemCfg)
    
    local item_list,isHoliday = cp.getManager("GDataManager"):getVanReward(itemCfg,true,self.openInfo.ownerHierarchy)
    for i=1,2 do
        self["Node_" .. tostring(i)]:removeAllChildren()
    end
    for i=1,#item_list do

        if i>2 then break end
        
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", item_list[i].itemID)
        local itemInfo = {id = item_list[i].itemID, num = item_list[i].itemNum, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")}
        local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
        item:setScale(0.8)
        item:setItemClickCallBack(function(info)
            -- local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
            -- self:addChild(layer, 2)
            -- layer:hidePlaceAndButtons()
        end)
        self["Node_" .. tostring(i)]:addChild(item)
    end

    if #item_list <= 1 then
        self["Node_1"]:setPosition(cc.p(110,120))
    else
        self["Node_1"]:setPosition(cc.p(61,120))
        self["Node_2"]:setPosition(cc.p(161,120))
    end
end

function ExpressLootItem:onItemClick(sender)
    if self.itemClickCallBack ~= nil then
        self.itemClickCallBack(self.openInfo)
    end
end

function ExpressLootItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

function ExpressLootItem:setToBeRobbed()
    self.Image_title:loadTexture("ui_express_module21_yabiao_19.png",ccui.TextureResType.plistType)
    self.Button_jiebiao:setEnabled(false)
    cp.getManager("ViewManager").setShader(self.Button_jiebiao,cp.getConst("ShaderConst").GrayShader)
end

return ExpressLootItem
