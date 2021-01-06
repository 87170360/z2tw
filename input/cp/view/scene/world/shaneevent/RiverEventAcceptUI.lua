local BLayer = require "cp.view.ui.base.BLayer"
local RiverEventAcceptUI = class("RiverEventAcceptUI",BLayer)

function RiverEventAcceptUI:create(openInfo)
	local layer = RiverEventAcceptUI.new(openInfo)
	return layer
end

function RiverEventAcceptUI:initListEvent()
	self.listListeners = {

        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "RiverEventAcceptUI" then
                if evt.guide_name == "river_event" then
                    self:onUIButtonClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "RiverEventAcceptUI" then
                if evt.guide_name == "river_event" then
                    local boundbingBox = self[evt.target_name]:getBoundingBox()
                    local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                end
            end
		end,
    }
end

function RiverEventAcceptUI:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_event_accept.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Text_name"] = {name = "Text_name"},
        ["Panel_root.Image_bg.Text_des"] = {name = "Text_des"},
        ["Panel_root.Image_bg.Text_progress"] = {name = "Text_progress"},
        ["Panel_root.Image_bg.Image_role"] = {name = "Image_role"},
        ["Panel_root.Image_bg.Panel_items"] = {name = "Panel_items"},
        ["Panel_root.Image_bg.Button_confirm"] = {name = "Button_confirm",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

    self.Image_role:ignoreContentAdaptWithSize(true)

    self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self["rootView"])

    self.openInfo = openInfo
end

function RiverEventAcceptUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    if buttonName == "Button_confirm" then
        if self.btnClickCallBack ~= nil then
            self.btnClickCallBack(self.openInfo)
        end
    elseif buttonName == "Button_cancel" then
        if self.btnClickCallBack ~= nil then
            self.btnClickCallBack()
        end
    end
end

function RiverEventAcceptUI:setUIButtonClickCallBack(cb)
  self.btnClickCallBack = cb
end

function RiverEventAcceptUI:onEnterScene()
    
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", self.openInfo.confId)
    local Name = cfg:getValue("Name")
    -- local Type = cfg:getValue("Type")
    local Desc = cfg:getValue("Desc")
    local Desc2 = cfg:getValue("Desc2") --打斷描述
    local npc_id = cfg:getValue("NPC")
    local Process = cfg:getValue("Process") -- 處理方式:1掛機，2戰鬥

    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local isSelfEvent = self.openInfo.owner == nil or self.openInfo.owner == majorRole.account
 
    if self.openInfo.Process ~= 2 then --挑戰npc類
        self.Image_bg:getChildByName("Text_1"):setString("獎勵(每小時)")
    end

    self.Text_name:setString(Name)
    local descrip = isSelfEvent and Desc or Desc2
    self.Text_des:setString(descrip)

    local conduct_max_num = tonumber(cp.getUtils("DataUtils").GetVipEffect(10))
    local cnt = conduct_max_num - (majorRole.normalEvent or 0)
    self.Text_progress:setString("今日已完成江湖事 " .. tostring(cnt) .. "/" .. tostring(conduct_max_num))

    if self.Panel_items:getChildrenCount() > 0 then
        self.Panel_items:removeAllChildren()
    end
    local item_list,_ = cp.getManager("GDataManager"):getMapEventReward(self.openInfo.confId)

    local sz = self.Panel_items:getContentSize()
    local totalNum = #item_list
    local space = 50 - 10*totalNum
    local startX = sz.width/2 - totalNum/2 * 90 - (totalNum-1)*space/2
    startX = startX < 0 and 0 or startX

    for i=1,#item_list do
        local itemtb = item_list[i]
    
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemtb.id)
        local itemInfo = {id = itemtb.id, num = itemtb.num, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon"),Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type") }
        local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
        item:setScale(0.9)
        if itemtb.flag then
            item:addFlag(itemtb.flag)
        end
        local sz = item:getContentSize()
        local width = sz.width * 0.9
        local x = startX + i*width - width/2 + (i-1)*space
        item:setPosition(cc.p(x , 15 + sz.height/2))
        -- item:setPosition(cc.p(width*(i-1) + 5 , 15))
        
        self.Panel_items:addChild(item)
    end


    local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameNpc", npc_id or 0)
    if cfgItem2 == nil then
        self:onNewGuideStory()
		return
	end
    local npc_image = cfgItem2:getValue("NpcImage")
    local modelId = cfgItem2:getValue("ModelID")
    if npc_image == "" or npc_image == nil then
        local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
        npc_image = itemCfg:getValue("HalfDraw")
    end
    self.Image_role:loadTexture(npc_image, ccui.TextureResType.localType)
    
    self:onNewGuideStory()
end


function RiverEventAcceptUI:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "river_event" then
        -- local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        -- if cur_step == 5 or cur_step == 11 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.3))
            table.insert(sequence,cc.CallFunc:create(
                function()
                    local info =
                    {
                        classname = "RiverEventAcceptUI",
                    }
                    self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                end)
            )
            self:runAction(cc.Sequence:create(sequence))
        -- end
    end
end

return RiverEventAcceptUI