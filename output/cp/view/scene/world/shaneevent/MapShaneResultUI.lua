local BNode = require "cp.view.ui.base.BNode"
local MapShaneResultUI = class("MapShaneResultUI",BNode)

function MapShaneResultUI:create(openInfo)
	local node = MapShaneResultUI.new(openInfo)
	return node
end

function MapShaneResultUI:initListEvent()
	self.listListeners = {
	}
end

function MapShaneResultUI:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_result.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Text_content"] = {name = "Text_content"},
        ["Panel_root.Image_bg.Panel_title.Text_title"] = {name = "Text_title"},
        ["Panel_root.Image_bg.Panel_reward"] = {name = "Panel_reward"},
        ["Panel_root.Image_bg.Panel_reward.Panel_reward_base"] = {name = "Panel_reward_base"},
        ["Panel_root.Image_bg.Panel_reward.Panel_reward_lucky"] = {name = "Panel_reward_lucky"},
        ["Panel_root.Image_bg.Panel_title.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy))

    self:setPosition(cc.p(display.cx,display.cy))

    self.openInfo = openInfo
end

function MapShaneResultUI:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_cancel" then
        --打開歷史戰鬥界面
    else
        if self.btnClickCallBack ~= nil then
            self.btnClickCallBack()
        end
    end
end

function MapShaneResultUI:setUIButtonClickCallBack(cb)
  self.btnClickCallBack = cb
end

function MapShaneResultUI:onEnterScene()
--    self.openInfo
    
    -- log(self.openInfo.uuid)
    --self.openInfo.result = false
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", self.openInfo.confId)
    local eventName = cfg:getValue("Name")
    local eventType = cfg:getValue("Type")

    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local isSelfEvent = self.openInfo.owner == majorRole.account
    local breaker_name = self.openInfo.breaker_name    
    local contentTable = {}
    if self.openInfo.result then
        if eventType == 1  then --基礎善
            local content = "少俠不愧是名門之後，當真是年少有為啊，佩服，佩服！"
            contentTable = {{type="ttf", fontSize=27, text = content, textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}} 
        elseif eventType == 3 then --基礎惡
            local content = "哇哈哈，你的惡灌滿名快趕上江湖中傳說的四大惡人了！"
            contentTable = {{type="ttf", fontSize=27, text = content, textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}} 
        else -- 高級善惡
            contentTable = {
                {type="ttf", fontSize=26, text = "在少俠", textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
                {type="ttf", fontSize=27, text = eventName, textColor=cc.c4b(255,173,205,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=26, text = "之時,宵小之輩【" , textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=27, text = breaker_name, textColor=cc.c4b(255,0,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=26, text = "】竟敢前來滋擾，真是自不量力!", textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}} 
        end
    else
        contentTable = {
                {type="ttf", fontSize=26, text = "在少俠", textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
                {type="ttf", fontSize=27, text = eventName, textColor=cc.c4b(255,173,205,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=26, text = "之時,竟被宵小之輩【" , textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=27, text = breaker_name, textColor=cc.c4b(255,0,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}, 
                {type="ttf", fontSize=26, text = "】打成重傷，少俠仍需努力啊!", textColor=cc.c4b(139,173,225,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}} 
 
    end
    -- self.Text_content:setString(content)

    self.Text_content:setVisible(false)
    local posX,posY = self.Text_content:getPosition()
    local sz = self.Text_content:getContentSize()
    sz.width = sz.width / self.Text_content.clearScale
    sz.height = sz.height / self.Text_content.clearScale
    local richText = self:createRichText(contentTable,sz)
    richText:setPosition(cc.p(posX,posY))
    self["Image_bg"]:addChild(richText)
    self.richText = richText

    if self.openInfo.result == true then
        if self.Panel_reward_base:getChildrenCount() > 0 then
            self.Panel_reward_base:removeAllChildren()
        end
        
        local AwardVirtual = cfg:getValue("Award6") -- 銀兩，俠義令，鐵膽令，閱歷值，預留項
        if not isSelfEvent then
            AwardVirtual = cfg:getValue("Award5")
        end
        local arr = string.split( AwardVirtual,"|")
        local Sliver = tonumber(arr[1]) or 0
        local ConductGood = tonumber(arr[2]) or 0
        local ConductBad = tonumber(arr[3]) or 0
        local Exp = tonumber(arr[4]) or 0
        
        local virtual_item = {}
        if Silver > 0 then
            table.insert(virtual_item,{type = 2, num = Silver})
        end
        if Exp > 0 then
            table.insert(virtual_item,{type = 4, num = Exp})
        end
        if ConductGood > 0 then
            table.insert(virtual_item,{type = 7, num = ConductGood})
        end
        if ConductBad > 0 then
            table.insert(virtual_item,{type = 8, num = ConductBad})
        end
        
        for i=1, #virtual_item do
            local item = require("cp.view.ui.item.HuobiItem")
            local v_item = item:create(virtual_item[i].type,virtual_item[i].num)
            self.Panel_reward_base:addChild(v_item)
            if i<3 then
                v_item:setPosition(130*(i-1),60)
            else
                v_item:setPosition(130*(i-3),20)
            end
        end

        --物品獎勵
        self.Panel_reward_lucky:removeAllChildren()
        local AwardItem = cfg:getValue("Award1")
        if not isSelfEvent then
            AwardItem = cfg:getValue("Award4")
        end
        local item_list = {}
        local arr2 = {}
        string.loopSplit(AwardItem,"|-",arr2)
        for i=1,#arr2 do
            local itemtb = arr2[i]
            local itemID = tonumber(itemtb[1])
            local itemNum = tonumber(itemtb[2])
        
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
            local itemInfo = {id = itemID, num = itemNum, Name = cfgItem:getValue("Name") , Icon = cfgItem:getValue("Icon"),Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type") }
            local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
            local width = item:getContentSize().width
            item:setPosition(cc.p(width*(i-1) + 5 , 15))
            self.Panel_reward_lucky:addChild(item)
        end
    
    end
    self:adjustUI()
    --[[
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
    required bool result                    = 2;                    //true 事件成功, fasle 事件被破壞
    optional string breaker_name            = 7;                    //破壞者名稱
    optional string breaker_account         = 8;                    //破壞者uid
    optional int32 breaker_level            = 9;                    //破壞者等級
    optional int32 breaker_gender           = 10;                   //破壞者性別
    optional int32 breaker_career           = 11;                   //破壞者職業
    optional int32 breaker_fight            = 12;                   //破壞者戰力
    optional int32 breaker_hierarchy        = 13;                   //破壞者階級
    optional int64 breaker_roleid           = 14;                   //破壞者roleid
    ]]
end

function MapShaneResultUI:adjustUI()

    if self.openInfo.result == true then --事件完成，領取獎勵
        self.Panel_root:setContentSize(550,530)
        self.Image_bg:setContentSize(541,514)
        -- self.Text_title:setPositionY(478)
        self.richText:setPositionY(353)
        self.Button_close:setPositionY(491)
        self.Button_OK:setPositionY(56)
        self.Button_cancel:setPositionY(56)

        self.Panel_reward:setVisible(true)
    else --未完成，無獎勵
        self.Panel_root:setContentSize(550,330)
        self.Image_bg:setContentSize(541,314)
        -- self.Text_title:setPositionY(280)
        self.richText:setPositionY(160)
        self.Button_close:setPositionY(291)
        self.Button_OK:setPositionY(56)
        self.Button_cancel:setPositionY(56)
        self.Panel_reward:setVisible(false)
    end
    ccui.Helper:doLayout(self.rootView)
end

function MapShaneResultUI:createRichText(contentTable,sz)
	--[[
		contentTable = {
			{type="ttf", fontSize=27, text="是否遺忘", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="魚躍龍門", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="回憶", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="水濺躍", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text=",需要消耗一枚:", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="心之鱗片", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
	]]
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(sz.width,sz.height))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(270,160))
    richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    richText:setLineGap(2)
    return richText

end

return MapShaneResultUI