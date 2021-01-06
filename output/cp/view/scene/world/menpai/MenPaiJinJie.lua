
local BLayer = require "cp.view.ui.base.BLayer"
local MenPaiJinJie = class("MenPaiJinJie",BLayer)

function MenPaiJinJie:create(openInfo)
	local layer = MenPaiJinJie.new(openInfo)
	return layer
end

function MenPaiJinJie:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
        [cp.getConst("EventConst").GangEnhanceRsp] = function(data)	

            cp.getUserData("UserCombat"):resetFightInfo()
            cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)

            local rewardList = {item_list = {}}
            cp.getUserData("UserCombat"):setCombatReward(rewardList)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
            -- cp.getManager("PopupManager"):removePopup(self)
            -- self:removeFromParent()
        end,
        
	}
end

function MenPaiJinJie:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_jinjie.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_bg.Node_role"] = {name = "Node_role"},
        ["Panel_root.Panel_bg.Image_name.Text_name"] = {name = "Text_name"},
        ["Panel_root.Panel_bg.Image_name_1.Text_name_1"] = {name = "Text_name_1"},
        
        ["Panel_root.Panel_bg.Panel_attribute"] = {name = "Panel_attribute"},
		["Panel_root.Panel_bg.Panel_attribute.Panel_1"] = {name = "Panel_1"},
		["Panel_root.Panel_bg.Panel_attribute.Panel_2"] = {name = "Panel_2"},
		["Panel_root.Panel_bg.Panel_attribute.Panel_3"] = {name = "Panel_3"},
		["Panel_root.Panel_bg.Panel_attribute.Panel_4"] = {name = "Panel_4"},
		
        ["Panel_root.Panel_bg.Panel_unlock.Text_unlock"] = {name = "Text_unlock"},
        ["Panel_root.Panel_bg.Panel_unlock.Image_4"] = {name = "Image_4"},
        ["Panel_root.Panel_bg.Panel_unlock.Image_5"] = {name = "Image_5"},
		
        ["Panel_root.Panel_bg.Button_fight"] = {name = "Button_fight",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Panel_top.Text_title"] = {name = "Text_title"},
        ["Panel_root.Panel_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    self.Image_5:setVisible(false)

	self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    if display.height < 1000 then
       self.Panel_bg:setPositionY(920)
       self.Panel_attribute:setPositionY(300)
       self.Panel_1:setPositionY(143)
       self.Panel_2:setPositionY(143)
       self.Panel_3:setPositionY(85)
       self.Panel_4:setPositionY(85)
    end

    cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b)
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_root)
end

function MenPaiJinJie:onEnterScene()
    self:refreshUI()
    self.Panel_root:setPositionY( display.height/2 + 110/2 - 10) --110為底部一排按鈕的高度
end

function MenPaiJinJie:onExitScene()
   
end

function MenPaiJinJie:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function MenPaiJinJie:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        -- cp.getManager("PopupManager"):removePopup(self)
        if self.closeCallBack then
            self.closeCallBack()
        end
        self:removeFromParent()
    elseif buttonName == "Button_fight" then
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        if major_roleAtt.hierarchy >= 6 then
            cp.getManager("ViewManager").gameTip("您已通過六階挑戰，繼承師門衣鉢。")
        end
        local newLevel = cp.getManager("GDataManager"):getNewHierarchyBeginLevel(major_roleAtt.hierarchy + 1)
		if major_roleAtt.level < newLevel then
			cp.getManager("ViewManager").gameTip("需要達到" .. tostring(newLevel) .. "級，才能挑戰" .. tostring(major_roleAtt.hierarchy + 1).. "階接引人!")
			return
        end
        
        self.fightInfo = {name = self.npcName,hierarchy = major_roleAtt.hierarchy + 1, career = major_roleAtt.career} 

        local req = {}
		req.hierarchy = major_roleAtt.hierarchy + 1
		self:doSendSocket(cp.getConst("ProtoConst").GangEnhanceReq, req)
        
    end
end

function MenPaiJinJie:refreshUI()   
	--當前的階數
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local hierarchy = major_roleAtt.hierarchy

    local level = major_roleAtt.level
    local hp = major_roleAtt.hp
    local mp = major_roleAtt.mp
    local attack = major_roleAtt.attack
    local defend = major_roleAtt.defend
    local curValue = {[1] = hp, [2] = mp, [3] = attack, [4] = defend}

    local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", major_roleAtt.career)
    local Attribute = cfg:getValue("Attribute")  -- 0=100|1=300|2=200|3=100#
    local Attribute_list = string.split(Attribute,"#")
    local arr = {}
    string.loopSplit(Attribute_list[hierarchy],"|=",arr)


    local Npc = cfg:getValue("Npc") 
    local npc_list = string.split(Npc,"|")
    local npcid = tonumber(npc_list[hierarchy])
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    self.Text_name:setString(cfgItem:getValue("Name"))
    self.npcName = cfgItem:getValue("Name")
    self.Text_name_1:setString(cp.getConst("CombatConst").NumberZh_Cn[hierarchy+1] .. "階接引人" )
	
	for i=1,4 do
		local Text_value_1 = self["Panel_" .. tostring(i)]:getChildByName("Text_value_1")
		local Text_value_2 = self["Panel_" .. tostring(i)]:getChildByName("Text_value_2")
		Text_value_1:setString(tostring(curValue[i]))
		Text_value_2:setString("(+" .. arr[i][2] .. ")")
	end
    
    local str = {
        "解鎖門派二階武學\n\n解鎖二階裝備\n\n解鎖二階歷練地圖\n\n解鎖二階祕境地圖\n\n解鎖門派商店",
        "解鎖門派三階武學\n\n解鎖三階裝備\n\n解鎖三階歷練地圖\n\n解鎖三階祕境地圖",
        "解鎖門派四階武學\n\n解鎖四階裝備\n\n解鎖四階歷練地圖\n\n解鎖四階祕境地圖", 
        "解鎖門派五階武學\n\n解鎖五階裝備\n\n解鎖五階歷練地圖\n\n解鎖五階祕境地圖",
        "解鎖門派六階武學\n\n解鎖六階裝備\n\n解鎖六階歷練地圖\n\n解鎖六階祕境地圖"
    }
    self.Text_unlock:setString(str[hierarchy])
    self:initNpc(npcid)
    if hierarchy == 1 then
        self.Image_5:setVisible(true)
    else
        self.Image_5:setVisible(false)
    end
end


function MenPaiJinJie:initNpc(npcid)
    self.Node_role:removeAllChildren()
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    if cfgItem ~= nil then

        -- local model = cp.getManager("ViewManager").createNpc(npcid,1)
        
        --self.Node_role:addChild(model)

        -- cp.getManager("ViewManager").addArmatureTouchEventListener(model,function(target,eventType)
        --     if eventType == 2 then  --onTouchEnded並且選中回調
                
        --         self:openFightLayer()
        --     end
        -- end)

        local WholeDraw = cfgItem:getValue("NpcImage")
        local modelId = cfgItem:getValue("ModelID")
		if WholeDraw == "" or WholeDraw == nil then
			local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
			WholeDraw = itemCfg:getValue("WholeDraw")
		end
        if WholeDraw ~= nil and WholeDraw ~= "" then
            local img = cp.getManager("ViewManager").addImage(self.Node_role, 0.75, WholeDraw)
            img:setPosition(cc.p(-65,50))
        end

    end
end


return MenPaiJinJie
