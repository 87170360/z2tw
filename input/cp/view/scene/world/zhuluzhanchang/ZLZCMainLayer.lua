
local BLayer = require "cp.view.ui.base.BLayer"
local ZLZCMainLayer = class("ZLZCMainLayer",BLayer)

function ZLZCMainLayer:create(openInfo)
	local layer = ZLZCMainLayer.new(openInfo)
	return layer
end

function ZLZCMainLayer:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").DeerSignRsp] = function(evt)
            self:refreshUI()
            
            local idx_list = evt.person.camp == 1 and {2} or {1}
            self:showCampSelectedStory(evt.person.camp,idx_list)
            
            self.CampSelect:removeFromParent()    
        end,
        
        [cp.getConst("EventConst").DeerViewCityRsp] = function(evt)
            local openInfo = {cityid = evt.cityid, cityPerson = evt.cityPerson}
            local ZLZCBuildDetailInfo = require("cp.view.scene.world.zhuluzhanchang.ZLZCBuildDetailInfo"):create(openInfo)
            self.rootView:addChild(ZLZCBuildDetailInfo,2)
            ZLZCBuildDetailInfo:setCloseCallBack(function()
                ZLZCBuildDetailInfo:removeFromParent()
            end)
        end,
        
	}
end

function ZLZCMainLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
		
        ["Panel_root.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.ScrollView_1.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.ScrollView_1.Image_bg.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Image_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Image_top.Button_help"] = {name = "Button_help",click = "onUIButtonClick"},
        ["Panel_root.Image_top.Button_rank"] = {name = "Button_rank",click = "onUIButtonClick"},
        ["Panel_root.Image_top.Button_shop"] = {name = "Button_shop",click = "onUIButtonClick"},
        ["Panel_root.Image_top.Text_camp"] = {name = "Text_camp"},
        ["Panel_root.Image_top.FileNode_1"] = {name = "FileNode_1"},
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.rootView:setContentSize(display.size)
    local sz = self.ScrollView_1:getContentSize()
    self.ScrollView_1:setTouchEnabled(true)
    self.ScrollView_1:setScrollBarEnabled(false)
    self.ScrollView_1:setContentSize(display.size)
    self.ScrollView_1:jumpToPercentVertical(50)

    local node = require("cp.view.scene.world.zhuluzhanchang.MingDiLing"):create()
    self.FileNode_1:addChild(node)

    self.build_items = {}
    self:createBuildings()

    ccui.Helper:doLayout(self["rootView"])
    
end

function ZLZCMainLayer:onEnterScene()
    
    local sign = cp.getUserData("UserZhuluzhanchang"):getValue("sign")
    if not sign then
        local sz = self.ScrollView_1:getInnerContainerSize()
        local node = require("cp.view.scene.world.zhuluzhanchang.CampSelect"):create()
        self.ScrollView_1:addChild(node)
        node:setPosition(cc.p(sz.width/2,sz.height/2))
        self.CampSelect = node
    else
        self:refreshUI()
    end
end

function ZLZCMainLayer:onExitScene()
   
end

function ZLZCMainLayer:onBuildClick(sender)
    local btnName = sender:getName()
    local idx = tonumber(string.sub(btnName,string.len("Image_build_") + 1))
    log("idx = " .. idx)
end

 
function ZLZCMainLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack then
            self.closeCallBack()
        end
        -- local info = {openState = "close"}
        self:dispatchViewEvent(cp.getConst("EventConst").open_zhuluzhanchang_view, false)
    elseif buttonName == "Button_help" then
        cp.getManager("ViewManager").showHelpTips("zhuluzhanchang")
    elseif buttonName == "Button_rank" then
        local layer = require("cp.view.scene.rank.RankMainLayer"):create(3)
        self:addChild(layer, 100)
    elseif buttonName == "Button_shop" then
        local layer = require("cp.view.scene.world.shop.Zhenwutang"):create()
        self:addChild(layer, 100)
    end
end

function ZLZCMainLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function ZLZCMainLayer:createBuildings()
    self.Panel_1:removeAllChildren()
    self.buildsInfo = cp.getManager("GDataManager"):getZhulujianghuAllBuildInfo()
    for i=1,table.nums(self.buildsInfo) do

        local item = require("cp.view.scene.world.zhuluzhanchang.ZLZCBuildingItem"):create()
        self.Panel_1:addChild(item)
        item:setVisible(true)
        item:setClickCallBack(function(info)
            dump(info)
            local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat")
            if buildings_defeat and buildings_defeat[info.ID] and buildings_defeat[info.ID] >= info.Hp then
                cp.getManager("ViewManager").gameTip(info.Name .. "已被擊破，請查看其它建築。")
                return
            end

            cp.getManager("PvpSocketManager"):doSend(cp.getConst("ProtoConst").DeerViewCityReq, {cityid=info.ID})

        end)
        item:resetInfo(self.buildsInfo[i])
        self.build_items[i] = item
    end
end

function ZLZCMainLayer:refreshUI()
    --camp 1 俠客堂 2 六扇門
    local self_info = cp.getUserData("UserZhuluzhanchang"):getValue("self_info")
    self_info.camp = math.max(self_info.camp,1)
    self.Text_camp:setString(self_info.camp == 1 and "俠客堂" or "六扇門")
    local bgPic = self_info.camp == 1 and "module83_zlzc_beijingtu02.png" or "module83_zlzc_beijingtu03.png"
    self.Image_bg:loadTexture("img/bg/bg_zlzc/" .. bgPic,ccui.TextureResType.localType)
    self.Image_bg:setVisible(true)
    for i=1,table.nums(self.build_items) do
        local pos = self.buildsInfo[i].posArr[3-self_info.camp]
        self.build_items[i]:resetPos(cc.p(tonumber(pos[1]),tonumber(pos[2])))
    end

    ccui.Helper:doLayout(self["rootView"])
end


function ZLZCMainLayer:showCampSelectedStory(camp,idx_list)
	
    if self.gamePopTalk == nil then
        self.gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create()
        local function closeCallBack()
            self.gamePopTalk:setVisible(false)
        end
        self.gamePopTalk:setFinishedCallBack(closeCallBack)
        self.gamePopTalk:setName("gamePopTalk")
        self.rootView:addChild(self.gamePopTalk,3)
        self.gamePopTalk:setPosition(cc.p(display.width/2,110))
        self.gamePopTalk:resetBgOpacity(0)
        self.gamePopTalk:hideSkip()
    end

    if self.popTalkTextList == nil then
        local status, gameStory = xpcall(
            function() return require("cp.story.GameStoryZLZC") end, 
            function(msg) print("load stroy error: ", msg) end
        )
        self.popTalkTextList = gameStory
    end

    local contentTable = {}
    for i=1,table.nums(idx_list) do
        table.insert(contentTable,self.popTalkTextList[idx_list[i]]) 
    end

    self.gamePopTalk:resetTalkText(contentTable)
    self.gamePopTalk:setVisible(true)
    self.gamePopTalk:resetBgOpacity(120)
    
end


return ZLZCMainLayer
