
local BLayer = require "cp.view.ui.base.BLayer"
local ZLZCBuildDetailInfo = class("ZLZCBuildDetailInfo",BLayer)

function ZLZCBuildDetailInfo:create(openInfo)
	local layer = ZLZCBuildDetailInfo.new(openInfo)
	return layer
end

function ZLZCBuildDetailInfo:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").DeerFightRsp] = function(evt)
            --進入戰鬥
            local rewardList = {
                currency_list = {},
                item_list = {}
            }
            if evt.result then
                if evt.award ~= nil and next(evt.award) ~= nil then
                    for i=1,table.nums(evt.award) do
                        table.insert(rewardList.item_list,{item_id = evt.award[i].id,item_num = evt.award[i].num})
                    end
                end
            end

			cp.getUserData("UserCombat"):setCombatReward(rewardList)
			-- local fightInfo = {floor = data.floor}
            -- cp.getUserData("UserCombat"):resetFightInfo()
			-- cp.getUserData("UserCombat"):updateFightInfo(fightInfo)
            -- cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_COMBAT)
            
		end,
	}
end

function ZLZCBuildDetailInfo:onInitView(openInfo)
    self.openInfo = openInfo 
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_build_detail.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.ScrollView_1.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.ScrollView_1.Image_bg.Panel_1"] = {name = "Panel_1"},

        ["Panel_root.Panel_top"] = {name = "Panel_top"},
        
        ["Panel_root.Panel_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Panel_top.Text_camp"] = {name = "Text_camp"},
        ["Panel_root.Panel_top.FileNode_1"] = {name = "FileNode_1"},
        ["Panel_root.Panel_top.Panel_process_info"] = {name = "Panel_process_info"},
        ["Panel_root.Panel_top.Panel_process_info.Text_reward_desp"] = {name = "Text_reward_desp"},
        ["Panel_root.Panel_top.Panel_process_info.Image_process_bg"] = {name = "Image_process_bg"},
        ["Panel_root.Panel_top.Panel_process_info.Image_process_bg.Image_process"] = {name = "Image_process"},
        ["Panel_root.Panel_top.Panel_process_info.Image_process_bg.Text_process"] = {name = "Text_process"},
        
        ["Panel_root.Panel_bottom"] = {name = "Panel_bottom"},
        ["Panel_root.Panel_bottom.Image_1"] = {name = "Image_1",click = "onUIButtonClick"},
        ["Panel_root.Panel_bottom.Image_2"] = {name = "Image_2",click = "onUIButtonClick"},
        ["Panel_root.Panel_bottom.Image_3"] = {name = "Image_3",click = "onUIButtonClick"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    local node = require("cp.view.scene.world.zhuluzhanchang.MingDiLing"):create()
    self.FileNode_1:addChild(node)

    self.rootView:setContentSize(display.size)
    local sz = self.ScrollView_1:getContentSize()
    self.ScrollView_1:setTouchEnabled(true)
    self.ScrollView_1:setContentSize(display.size)
    self.ScrollView_1:setScrollBarEnabled(false)
    self.ScrollView_1:jumpToPercentVertical(50)

    ccui.Helper:doLayout(self["rootView"])
    
end

function ZLZCBuildDetailInfo:onEnterScene()

    local cityid = self.openInfo.cityid 
    local cfg = cp.getManager("ConfigManager").getItemByKey("DeerCity",cityid)
    self.Text_camp:setString(cfg:getValue("Name"))
    local Hp = cfg:getValue("Hp")
    local Type = cfg:getValue("Type")
    local BrokenReward = cfg:getValue("BrokenReward")
    self.Text_reward_desp:setString(BrokenReward)
    local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat")

    local processValue = math.min(buildings_defeat[cityid] or 0, Hp)
    local scale = math.floor(processValue/Hp*100.0)
    self.Image_process:setContentSize(cc.size(328*processValue/Hp, 23))
    self.Text_process:setString(tostring(scale) .. "%")

    local self_info = cp.getUserData("UserZhuluzhanchang"):getValue("self_info")
    self_info.camp = math.max(self_info.camp,1)

    if Type == self_info.camp then
        self["Image_1"]:setVisible(false)
        self["Image_2"]:setVisible(false)
        self["Image_3"]:setVisible(false)
    else
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "deer_consume_sound")
        local deer_consume_sound = Config:getValue("IntValue")
        Config = cp.getManager("ConfigManager").getItemByKey("Other", "deer_fight_low")
        local deer_fight_low = Config:getValue("StrValue")
        Config = cp.getManager("ConfigManager").getItemByKey("Other", "deer_fight_middle")
        local deer_fight_middle = Config:getValue("StrValue")
        Config = cp.getManager("ConfigManager").getItemByKey("Other", "deer_fight_high")
        local deer_fight_high = Config:getValue("StrValue")
        local rewardListStr = {deer_fight_low,deer_fight_middle,deer_fight_high}

        for i=1,3 do
            self:initReward(i,deer_consume_sound,rewardListStr[i])
        end
    end

    self:createAllNpc()
    
end

function ZLZCBuildDetailInfo:initReward(idx,deer_consume_sound,deer_fight)
    local gxz_num = 0
    local arr = {}
    string.loopSplit(deer_fight,"|-",arr)
    for i=1,#arr do
        if arr[i] and tonumber(arr[i][1]) == cp.getConst("GameConst").GongXunZhi_ItemID then 
            gxz_num = tonumber(arr[i][2])
        end
    end
    local str = {"少量","適量","大量"}
    local txt = string.format("鳴鏑令 -%d\n功勳 + %d\n%s真武令",deer_consume_sound,gxz_num,str[idx])
    self["Image_" .. tostring(idx)]:getChildByName("Text_2"):setString(txt)
    self["Image_" .. tostring(idx)]:setVisible(true)
end

function ZLZCBuildDetailInfo:onExitScene()
   
end


function ZLZCBuildDetailInfo:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack then
            self.closeCallBack()
        end
        
    elseif buttonName == "Image_1" then
        self:fightBuild(0)
    elseif buttonName == "Image_2" then
        self:fightBuild(1)
    elseif buttonName == "Image_3" then
        self:fightBuild(2)
    end
end

function ZLZCBuildDetailInfo:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function ZLZCBuildDetailInfo:createAllNpc()
    self.Panel_1:removeAllChildren()
    local sz = self.Panel_1:getContentSize()
    local cityPerson = self.openInfo.cityPerson
    -- local current_city_npc = cp.getUserData("UserZhuluzhanchang"):getValue("current_city_npc")
    dump(cityPerson)
    if cityPerson and next(cityPerson) then
        for i=1,table.nums(cityPerson) do
            local roleInfo = cityPerson[i]
            local ZLZCBuildDefender = require("cp.view.scene.world.zhuluzhanchang.ZLZCBuildDefender"):create(roleInfo)
            self.Panel_1:addChild(ZLZCBuildDefender)
            ZLZCBuildDefender:setPosition(cc.p(math.random(50,sz.width-50), math.random(0,sz.height-100)))
        end
    end
end

function ZLZCBuildDetailInfo:fightBuild(idx)
    -- idx :  0 低級， 1 中級， 2 高級
    local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local req = {}
    req.type = idx
    req.roleid = majorRole.id
    req.zoneid = serverinfo.id
    cp.getManager("PvpSocketManager"):doSend(cp.getConst("ProtoConst").DeerFightReq, req)
    
end

return ZLZCBuildDetailInfo
