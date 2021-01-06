
local BLayer = require "cp.view.ui.base.BLayer"
local MijingDetailLayer = class("MijingDetailLayer",BLayer)

function MijingDetailLayer:create(openInfo)
	local layer = MijingDetailLayer.new(openInfo)
	return layer
end

function MijingDetailLayer:initListEvent()
	self.listListeners = {
        
        [cp.getConst("EventConst").BuyMijingRsp] = function(data)
			self:refreshFightNums()
		end,
        
        [cp.getConst("EventConst").OnlineCrossDayRsp] = function(evt)
            self:refreshFightNums()
        end,
	}
end

function MijingDetailLayer:onInitView(openInfo)

    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_mijing/uicsb_mijing_detail.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
        ["Panel_root.Panel_bg.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Panel_bg.Image_bg.Panel_1.Node_role"] = {name = "Node_role"},
        ["Panel_root.Panel_bg.Image_bg.Image_name.Text_name"] = {name = "Text_name"},
		
		["Panel_root.Image_fightnums"] = {name = "Image_fightnums"},
        
        ["Panel_root.Image_top"] = {name = "Image_top"},
        ["Panel_root.Image_bottom"] = {name = "Image_bottom"},

        ["Panel_root.Panel_bg.Image_bg.Image_name.Button_left"] = {name = "Button_left",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Image_bg.Image_name.Button_right"] = {name = "Button_right",click = "onUIButtonClick"},

        ["Panel_root.Button_view_drop"] = {name = "Button_view_drop",click = "onUIButtonClick"},
        ["Panel_root.Button_add"] = {name = "Button_add",click = "onUIButtonClick"},
        ["Panel_root.Button_fight"] = {name = "Button_fight",click = "onUIButtonClick"},
        ["Panel_root.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    
end

function MijingDetailLayer:onEnterScene()
   
    log("MijingDetailLayer id = " .. self.openInfo.id)

    self.openInfo.level = 0
    local fight_id = cp.getUserData("UserMijing"):getValue("fight_id")
    if fight_id ~= nil and fight_id ~= "" then
        local str = string.split(fight_id,"_")
        local mijingType = tonumber(str[1]) 
        if self.openInfo.id == mijingType then
            self.openInfo.level = tonumber(str[2]) 
        end
    end

    if self.openInfo.level == 0 then
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local hierarchy = major_roleAtt.hierarchy  --當前人物的階級
        self.openInfo.level = hierarchy
    end
  
    self:refreshUI()

    self.rootView:setContentSize(display.width,display.height)
    if display.height > 960 then
        self.Panel_root:setPositionY(display.height/2 + 110/2)
    else
        self.Panel_root:setPositionY(510)
    end
    ccui.Helper:doLayout(self.rootView)
    

    local isInActive = cp.getManager("GDataManager"):isMijingInActivityTime(tostring(self.openInfo.id).. "_" .. tostring(self.openInfo.level))
    local Image_huodong = self["Button_view_drop"]:getChildByName("Image_huodong")
    Image_huodong:setVisible(isInActive)
    self.isInActive = isInActive
end

function MijingDetailLayer:initNpc(npcid)
    self.Node_role:removeAllChildren()
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    if cfgItem ~= nil then
        local model = cp.getManager("ViewManager").createNpc(npcid,1)
        self.Node_role:addChild(model)

        cp.getManager("ViewManager").addArmatureTouchEventListener(model,function(target,eventType)
            if eventType == 2 then  --onTouchEnded並且選中回調
                
                self:openFightLayer()
            end
        end)
    end
end


function MijingDetailLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

    if "Button_view_drop"  == buttonName then
        
        local mijing_id = tostring(self.openInfo.id) .. "_" .. tostring(self.openInfo.level)
        local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
        if cfg ~= nil then
            local items = cfg:getValue("Items")
            local name = cfg:getValue("Name")

            if items ~= "" then
                local arr = {}
                string.loopSplit(items,"|-",arr)
                self.openInfo.items = {}
                for i=1, table.nums(arr) do
                    local itemInfo = {id = tonumber(arr[i][1]), num=1,hideName = false, showNum = false}
                    table.insert(self.openInfo.items,itemInfo)
                end
            end 

            if self.isInActive then
                local ExItems = cfg:getValue("ExItems")
                if ExItems ~= "" then
                    local arr = {}
                    string.loopSplit(ExItems,"|-",arr)
                    for i=1, table.nums(arr) do
                        local itemInfo = {id = tonumber(arr[i][1]), num=1,hideName = false,isActive=true}
                        table.insert(self.openInfo.items,itemInfo)
                    end
                end 
            end

            if table.nums(self.openInfo.items) > 0 then
                cp.getManager("ViewManager").showGameRewardPreView(self.openInfo.items,name,false)
            end
        end
    elseif "Button_fight" == buttonName then
        self:openFightLayer()
    elseif "Button_add" == buttonName then
        -- 添加祕境挑戰次數
        self:onBuyFightNums()
    
    elseif "Button_left" == buttonName then
        self.openInfo.level = self.openInfo.level - 1
        self.openInfo.level = math.max(self.openInfo.level,1)
        self:refreshUI()
    elseif "Button_right" == buttonName then
        self.openInfo.level = self.openInfo.level + 1
        self.openInfo.level = math.min(self.openInfo.level,6)
        self:refreshUI()
    elseif "Button_close" == buttonName then
        if self.closeCallBack ~= nil then
            self.closeCallBack()
        end
    end
end

function MijingDetailLayer:onBuyFightNums()
    local mijing_id = tostring(self.openInfo.id) .. "_" .. tostring(self.openInfo.level)
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
    if cfg ~= nil then

        local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
        local mijingInfo = mijingInfoList[self.openInfo.id]
        if mijingInfo.numLeft > 0  then
            cp.getManager("ViewManager").gameTip("尚剩餘挑戰次數，勿需重置挑戰次數!")
        end

        local PriceList = cfg:getValue("Price")
        local priceTable = string.split(PriceList,"|")
        local index = mijingInfo.numBuy + 1
        index = math.min(index, table.nums(priceTable)) 
        local price = tonumber(priceTable[index])
       
        local function comfirmFunc()
            --檢測是否元寶足夠
            
            if cp.getManager("ViewManager").checkGoldEnough(price) then
				local req = {}
                req.id = mijing_id
                self:doSendSocket(cp.getConst("ProtoConst").BuyMijingReq, req)
			end
        end

        local contentTable = {
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="提升VIP等級可獲得額外挑戰次數，是否消耗", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(priceTable[index]), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，來重置挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
        }
        if price == 0 then
            contentTable = {
                {type="ttf", fontSize=24, text="是否重置挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
                {type="blank", blankSize=1},
                {type="ttf", fontSize=24, text="(本次免費)", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            }
        end
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    end
end

function MijingDetailLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function MijingDetailLayer:openFightLayer()
    local type,id,level = cp.getConst("CombatConst").CombatType_Mijing,self.openInfo.id,self.openInfo.level

    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local hierarchy = major_roleAtt.hierarchy
    if hierarchy < level then
        cp.getManager("ViewManager").gameTip("需要人物達到" .. tostring(level) .. "階級才能挑戰！")
        return
    end

    local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
    local mijingInfo = mijingInfoList[self.openInfo.id]
    if mijingInfo.numLeft <= 0  then
        cp.getManager("ViewManager").gameTip("剩餘挑戰次數不足，請先重置挑戰次數!")
        return
    end

    local function closeCallBack(retStr)
        if retStr == "mijing_fight" then
            self:refreshFightNums()
        end
        cp.getManager("ViewManager").removeChallengeStory()
    end
    cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack)
end


function MijingDetailLayer:refreshUI()
    self.Button_left:setVisible(self.openInfo.level > 1)
    self.Button_right:setVisible(self.openInfo.level < 6)
    local mijing_id = tostring(self.openInfo.id) .. "_" .. tostring(self.openInfo.level)
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
    if cfg ~= nil then
        local name = cfg:getValue("Name")
        local npc = cfg:getValue("Npc")
        local price = cfg:getValue("Price")
        self.openInfo.priceList = price 

        self.Text_name:setString(name)

        self:refreshFightNums()

        if npc > 0 then
            self:initNpc(npc)
        end

    end

end

function MijingDetailLayer:refreshFightNums()

    local mijingInfoList = cp.getUserData("UserMijing"):getValue("mijingInfoList")
    local mijingInfo = mijingInfoList[self.openInfo.id]
    local left_fight_times = mijingInfo.numLeft
    local color = left_fight_times > 0 and cc.c3b(252,242,200) or cp.getConst("GameConst").QualityTextColor[6]  --金色或紅色
    self.Button_add:setVisible(left_fight_times <= 0)
    local maxTimes = cp.getUtils("DataUtils").GetVipEffect(8)
    local contentTable = {
        {type="ttf", fontName="fonts/msyh.ttf", fontSize=20, text="可挑戰次數:  ", textColor=cc.c3b(252,242,200)},
        {type="ttf", fontName="fonts/msyh.ttf", fontSize=20, text=tostring(left_fight_times), textColor=color},
        {type="ttf", fontName="fonts/msyh.ttf", fontSize=20, text="/ " .. tostring(maxTimes), textColor=cc.c3b(252,242,200)},
    }
    self.Image_fightnums:removeChildByName("richText")
    local richText = cp.getManager("ViewManager").createRichText(contentTable,260,35)
    richText:setName("richText")
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)
    self.Image_fightnums:addChild(richText)

end

return MijingDetailLayer
