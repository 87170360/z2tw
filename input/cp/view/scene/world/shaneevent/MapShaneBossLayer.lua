
local BNode = require "cp.view.ui.base.BNode"
local MapShaneBossLayer = class("MapShaneBossLayer",BNode)

function MapShaneBossLayer:create(openInfo)
	local node = MapShaneBossLayer.new(openInfo)
	return node
end

function MapShaneBossLayer:initListEvent()
	self.listListeners = {
        --請求開始打善惡Boss事件 
        -- [cp.getConst("EventConst").StartBossRsp] = function(data)
        --     --進入戰鬥
        --     log(data)
        --     self:onStartBoss(data)
        -- end,
	}
end

function MapShaneBossLayer:onInitView(openInfo)

    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_worldboss.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
        ["Panel_root.Panel_bg.Image_role"] = {name = "Image_role"},
        
        ["Panel_root.Panel_bg.Panel_base_reward.Panel_base"] = {name = "Panel_base"},
        ["Panel_root.Panel_bg.Panel_finder_reward.Panel_finder"] = {name = "Panel_finder"},
        ["Panel_root.Panel_bg.Panel_involved_reward.Panel_involved"] = {name = "Panel_involved"},

        ["Panel_root.Panel_bg.Text_boss_hp"] = {name = "Text_boss_hp"},
        ["Panel_root.Panel_bg.Text_notice"] = {name = "Text_notice"},
        ["Panel_root.Panel_bg.Text_boss_name"] = {name = "Text_boss_name"},


        ["Panel_root.Button_recruit_world"] = {name = "Button_recruit_world",click = "onUIButtonClick"},
        ["Panel_root.Button_recruit_friend"] = {name = "Button_recruit_friend",click = "onUIButtonClick"},
        ["Panel_root.Button_fight"] = {name = "Button_fight",click = "onUIButtonClick"},
        ["Panel_root.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)

end

function MapShaneBossLayer:onEnterScene()
    self.rewardList = {}
    self:updateUI()
end

function MapShaneBossLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if "Button_fight" == buttonName then
        if self.openInfo.isBoss and self.openInfo.hp > 0 then
            local req = {uuid = self.openInfo.uuid}
            self:doSendSocket(cp.getConst("ProtoConst").StartBossReq, req)
        else
            log("hp is less than 0.")
        end
    elseif "Button_recruit_friend"  == buttonName then
    
    elseif "Button_recruit_world"  == buttonName then
    
    elseif "Button_close" == buttonName then
        self:removeFromParent()
    end
end

function MapShaneBossLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function MapShaneBossLayer:updateUI()
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", self.openInfo.confId)

    local Desc = cfg:getValue("Desc")
    local NPC = cfg:getValue("NPC")
    --local Award1 = cfg:getValue("Award1")
    local AwardVirtual = cfg:getValue("Award6") -- 銀兩，俠義令,鐵膽令，閱歷值，預留項
    local arr = string.split( AwardVirtual,"|")
    local Sliver = tonumber(arr[1])
    local ConductGood = tonumber(arr[2])
    local ConductBad = tonumber(arr[3])
    local Exp = tonumber(arr[4])
  
    local Award1 = cfg:getValue("Award1") -- 基礎獎勵
    local Award2 = cfg:getValue("Award2") -- 發現者獎勵
    local Award3 = cfg:getValue("Award3") -- 參與獎勵
    			
    if self.Panel_base:getChildrenCount() > 0 then
        self.Panel_base:removeAllChildren()
    end
    
    self.rewardList = {}
    self.rewardList.currency_list = {}

    local virtual_item = {}
    if Sliver > 0 then
        table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.silver, num = Sliver})
    end
    if Exp > 0 then
        table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.exp, num = Exp})
    end
    if ConductGood > 0 then
        table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.goodPoint, num = ConductGood})
    end
    if ConductBad > 0 then
        table.insert(virtual_item,{type = cp.getConst("GameConst").VirtualItemType.badPoint, num = ConductBad})
    end
	
    self.rewardList.currency_list = virtual_item
	for i=1, #virtual_item do
		local item = require("cp.view.ui.item.HuobiItem")
		local v_item = item:create(virtual_item[i].type,virtual_item[i].num)
		self.Panel_base:addChild(v_item)
		if i<3 then
			v_item:setPosition(130*(i-1),40)
		else
			v_item:setPosition(130*(i-3),0)
		end
	end

    --基礎獎勵物品，界面不顯示(或者沒有基礎物品獎勵，只有金幣等虛擬物品獎勵)
    self.rewardList.item_list = {}
    if Award1 ~= nil and string.trim(Award1) ~= "" then
        local arr2 = {}
        string.loopSplit(Award1,"|-",arr2)
        for i=1,#arr2 do
            local itemtb = arr2[i]
            local itemID = tonumber(itemtb[1])
            local itemNum = tonumber(itemtb[2])
            table.insert(self.rewardList.item_list,{item_id = itemID,item_num = itemNum})
        end
    end

    local function initItemReward(parent,award)
        local arr = {}
        string.loopSplit(award,"|-",arr)
        for i=1,#arr do
            local itemtb = arr[i]
            local itemID = tonumber(itemtb[1])
            local itemNum = tonumber(itemtb[2])
    
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
            local itemInfo = {id = itemID, num = itemNum, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon"),Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type") }
            local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
            -- item:setScale(0.8)
            local width = item:getContentSize().width
            item:setPosition(cc.p(5, 15))
            parent:addChild(item)
        end
    end

    --發現者獎勵
    self.Panel_finder:removeAllChildren()
    initItemReward(self.Panel_finder,Award2)
    
    --參與者獎勵
    self.Panel_involved:removeAllChildren()
    arr = {}
    initItemReward(self.Panel_involved,Award3)
    
    --boss訊息
    local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameNpc", NPC)
    local npcName = cfgItem2:getValue("Name")
    local npcHp = cfgItem2:getValue("MaxLife")
    --local npcDescrip = cfgItem2:getValue("Description")
    --local SkillID = cfgItem2:getValue("SkillID") -- 1=1;2=1;3=1;4=1;5=1;6=1  武學id:武學等級;
    local npc_image = cfgItem2:getValue("NpcImage")
    local modelId = cfgItem2:getValue("ModelID")
    if npc_image == "" or npc_image == nil then
        local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
        npc_image = itemCfg:getValue("WholeDraw")
    end
    
    self.Image_role:loadTexture(npc_image, ccui.TextureResType.localType)
    self.Image_role:ignoreContentAdaptWithSize(true)

    self.Text_boss_hp:setString("生命:" .. tostring(self.openInfo.hp) .. "/" .. tostring(npcHp))
    self.Text_boss_name:setString(npcName)
end

function MapShaneBossLayer:onStartBoss(event_info)
    -- local uuid = event_info.uuid
    
    cp.getUserData("UserCombat"):setCombatReward(self.rewardList)
    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
    self:removeFromParent()
end

return MapShaneBossLayer
