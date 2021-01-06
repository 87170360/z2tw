
local BLayer = require "cp.view.ui.base.BLayer"
local LilianDetailLayer = class("LilianDetailLayer",BLayer)

function LilianDetailLayer:create(openInfo)
	local layer = LilianDetailLayer.new(openInfo)
	return layer
end

function LilianDetailLayer:initListEvent()
	self.listListeners = {
        --快速歷練
        [cp.getConst("EventConst").QuickExerciseRsp] = function(data)
            self:showQuickExerciseresult(data)
        end,

        --獲取歷練結果
        [cp.getConst("EventConst").GetExerciseRsp] = function(data)
            self:onGetExerciseResult()
        end,

        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "LilianDetailLayer" then
                if evt.guide_name == "lilian" then
                    self:onUIButtonClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "LilianDetailLayer" then
                if evt.guide_name == "lilian" then
                    local boundbingBox = self[evt.target_name]:getBoundingBox()
                    local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                end
            end
		end,
	}
end

function LilianDetailLayer:onInitView(openInfo)

    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_lilian/uicsb_lilian_detail.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_bg"] = {name = "Panel_bg"},
        ["Panel_root.Panel_bg.Panel_title.ListView_1"] = {name = "ListView_1"},
        ["Panel_root.Panel_bg.Panel_title.Panel_online"] = {name = "Panel_online"},

        ["Panel_root.Panel_bg.Panel_title.Text_notice"] = {name = "Text_notice"},
        ["Panel_root.Panel_bg.Button_view_drop"] = {name = "Button_view_drop",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Button_fast"] = {name = "Button_fast",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Button_auto_sell"] = {name = "Button_auto_sell",click = "onUIButtonClick"},
        ["Panel_root.Panel_bg.Panel_title.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    self.ListView_1:setScrollBarEnabled(false) 
    self.Button_view_drop:setVisible(false)
end

function LilianDetailLayer:onEnterScene()
    self.descripTexts = {
"路過市集，一夥凶徒正在調戲賣畫小姑娘\n頓時怒從心上起\n操起一根水火棍將他們痛打一番\n集上眾人都拍手稱快",

"前去拜訪前輩高人\n你虛心求問，他不吝賜教\n臨別之時，他有心考較你的武藝\n於是兩人切磋一番，你感覺獲益匪淺",

"走在路上，偶遇小股劫匪\n你心念一轉，佯裝膽怯，被帶至土匪老窩\n出其不意，將他們全數制住\n併成功解救了其他人質",

"星夜靜修，一黑衣人不期而至\n你掣出兵器，與他鬥了個旗鼓相當\n正所謂不打不相識\n你們互相參詳，各有進益",

"天黑之際，投宿客棧\n飯菜中拌有迷藥，顯然這是家黑店\n你心下了然，卻佯裝中招\n略施小計便將他們一網打盡",

"邊荒之地，劫匪肆虐\n受困之際，偶遇同道中人\n你們攜手並進，挫敗敵酋\n一路拔除匪患，從此引為知己"
}

    self:showAllResult()
    self:adjustUI()

    self:onNewGuideStory()
    
end


function LilianDetailLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseQuick = major_roleAtt.exerciseQuick
    local exerciseId = major_roleAtt.exerciseId

    if "Button_fast" == buttonName then --快速歷練
        --檢測是否揹包滿了。
        if cp.getManager("GDataManager"):checkPackageFull() then --揹包已滿(不包含裝備界面裡的物品)
            cp.getManager("ViewManager").gameTip("揹包已滿,請先清理揹包。")
            return
        end

        local maxTimes = cp.getUtils("DataUtils").GetVipEffect(4)
        --檢測是否免費
        if exerciseQuick == 0 then
            local req = {}
            self:doSendSocket(cp.getConst("ProtoConst").QuickExerciseReq, req)
        elseif exerciseQuick > maxTimes then
            --已經達到最大的快速歷練次數
            cp.getManager("ViewManager").gameTip("提升VIP等級可獲得更多快速歷練次數!")
        else
            
            local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
            local PriceList = cfg:getValue("Price")
            local priceTable = string.split(PriceList,"|")
            local index = exerciseQuick + 1
            index = math.min(index, table.nums(priceTable)) 
            local price = tonumber(priceTable[index])
            local function comfirmFunc()
                --檢測是否元寶足夠
                if cp.getManager("ViewManager").checkGoldEnough(price) then
                    local req = {}
                    self:doSendSocket(cp.getConst("ProtoConst").QuickExerciseReq, req)
                end
            end

            local leftTimes = math.max(maxTimes - exerciseQuick,0)
            local GameConst = cp.getConst("GameConst")
            local contentTable = {
                {type="ttf", fontName="fonts/msyh.ttf",fontSize=22, text="快速歷練2個小時，將消耗", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"},
                {type="ttf", fontName="fonts/msyh.ttf",fontSize=22, text=tostring(priceTable[index]), textColor=GameConst.QualityTextColor[2], outLineColor=GameConst.QualityOutlineColor[2], outLineSize=2,verticalAlign="middle"},
                {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
                {type="ttf",  fontName="fonts/msyh.ttf",fontSize=22, text="，是否繼續？", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"},
                {type="blank",blankSize=1},
                {type="ttf",  fontName="fonts/msyh.ttf",fontSize=22, text="每日可快速歷練次數 ", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="top"},
                {type="ttf",  fontName="fonts/msyh.ttf",fontSize=22, text=tostring(leftTimes), textColor=(leftTimes>0 and GameConst.QualityTextColor[2] or GameConst.QualityTextColor[6]), outLineColor=(leftTimes>0 and GameConst.QualityOutlineColor[2] or GameConst.QualityOutlineColor[6]), outLineSize=2,verticalAlign="top"},
                {type="ttf",  fontName="fonts/msyh.ttf",fontSize=22, text="/" .. tostring(maxTimes), textColor=GameConst.QualityTextColor[2], outLineColor=GameConst.QualityOutlineColor[2],outLineSize=2,verticalAlign="top"},
            }
            if self.isInActive then
                contentTable[#contentTable + 1] = {type="ttf",  fontName="fonts/msyh.ttf",fontSize=22, text="(活動期間獎勵翻倍)", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"}
            end
            cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

        end
    elseif "Button_auto_sell"  == buttonName then
        cp.getManager("ViewManager").showAutoSellSettings()
    elseif "Button_view_drop"  == buttonName then
        
        local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
        if cfg ~= nil then
            local items = cfg:getValue("Items")
            local name = cfg:getValue("Name")
            if items ~= "" then
                local itemsTb = string.split(items,"|")
                local items = {}
                for i=1, table.nums(itemsTb) do
                    table.insert(items,tonumber(itemsTb[i]))
                end

                if #items > 0 then
                    local itemList = {}
                    for i=1,#items do
                        table.insert(itemList, {id = items[i], num=1,hideName = false})
                    end
                    cp.getManager("ViewManager").showGameRewardPreView(itemList,name,false)
                end
            end 
        end

        
    elseif "Button_close" == buttonName then
        if self.closeCallBack ~= nil then
            self.closeCallBack()
        end
    end
end

function LilianDetailLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function LilianDetailLayer:showAllResult()
    local name = ""
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseId = major_roleAtt.exerciseId
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
    if cfg ~= nil then
        name = cfg:getValue("Name")
    end
    name = name ~= "" and (" " .. name .. " ") or ""
    local contentTable = {
        {type="ttf", fontSize=22, text="你隻身前來 " .. name .. " 歷練……" , textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        --{type="ttf", fontSize=22, text=name, textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        --{type="ttf", fontSize=22, text=" 歷練……", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
    }
    self:createRichText(contentTable)

    local result_list = cp.getUserData("UserLilian"):getValue("result_list")
    if table.nums(result_list) > 0 then
        for i=1,table.nums(result_list) do
            local list = result_list[i]
            self:addOneResult(list)
        end
    end

    local isInActive,timeList = cp.getManager("GDataManager"):isLiLianInActivityTime(exerciseId)
    local Image_huodong = self.Button_fast:getChildByName("Image_huodong")
    Image_huodong:setVisible(isInActive)
    self.timeList = timeList
    self.isInActive = isInActive
    local str = ""
    for i=1,table.nums(self.timeList) do
        str = str .. self.timeList[i][1] .. ":" .. self.timeList[i][2] .. "~" .. self.timeList[i][3] .. ":" .. self.timeList[i][4]
        if i < table.nums(self.timeList) then
            str = str .. "及"
        end 
    end
    str = str .. "為活動時間,將獲得額外獎勵。"
    self.Text_notice:setString(str)
    
end

function LilianDetailLayer:addOneResult(list)
    local contentTable = {}
    local curIndex = math.random(table.nums(self.descripTexts))
    self.lastTxtIndex = self.lastTxtIndex or curIndex
    if self.lastTxtIndex == curIndex then
        curIndex = math.random(table.nums(self.descripTexts))
        self.lastTxtIndex = curIndex
    end
    
    local txt = self.descripTexts[self.lastTxtIndex]
    self.lastTxtIndex = curIndex

    local getText = ""
    if list.trainPoint > 0 then
        getText = getText .. "獲得" .. tostring(list.trainPoint) .. "修為點"
    end
    if list.silver > 0 then
        getText = getText .. "獲得" .. tostring(list.silver) .. "銀兩"
    end
    if list.conductGood > 0 then
        getText = getText .. "獲得" .. tostring(list.conductGood) .. "俠義令"
    end
    if list.conductBad > 0 then
        getText = getText .. "獲得" .. tostring(list.conductBad) .. "鐵膽令"
    end
    if table.nums(list.items) > 0 then
        for itemid,num in pairs(list.items) do
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemid)
            if cfgItem ~= nil then
                local name = cfgItem:getValue("Name")
                local Hierarchy = cfgItem:getValue("Hierarchy") 
                getText = getText .. "獲得" .. name .. " x " .. tostring(num) .. ""
            end
        end
    end
    
    local activeText = list.isInActive and getText or ""
    if list.soldSilver and list.soldSilver > 0 then
        getText = getText .. ",自動出售裝備獲得" .. tostring(list.soldSilver) .. "銀兩"
    end

    local newTb1 = {type="ttf", fontSize=22, text=txt, textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2}
    table.insert(contentTable,newTb1)

    if list.isInActive then
        local newTb2 = {type="ttf", fontSize=24, text=getText, textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2}
        table.insert(contentTable,newTb2)  
        local newTb3 = {type="ttf", fontSize=20, text="(活動額外" .. activeText .. ")" .. "\n", textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2}
        table.insert(contentTable,newTb3)
    else
        local newTb2 = {type="ttf", fontSize=24, text=getText .. "\n", textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2}
        table.insert(contentTable,newTb2)    
    end
    
    self:createRichText(contentTable)
end

function LilianDetailLayer:onGetExerciseResult(data)
    
    local result_list = cp.getUserData("UserLilian"):getValue("result_list")
    if table.nums(result_list) > 0 then
        local list = result_list[table.nums(result_list)]
        self:addOneResult(list)
    end
end


function LilianDetailLayer:createRichText(contentTable)
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
    -- local richText = require("cp.view.ui.base.RichText"):create()
    local richText = ccui.RichText:create()
    for i=1, #contentTable do
        local info  = contentTable[i]
        if info.type == "ttf" then


            local params = {font = "fonts/msyh.ttf", size = info.fontSize,color = info.textColor, dimensions = cc.size(440,0)}
            local label = display.newTTFLabel(params)
            label:setString(info.text)
            -- label:setAnchorPoint(0.0, 1.0)
            label:enableOutline(info.outLineColor,info.outLineSize)
            -- label:setLineHeight(10)
            -- Panel_text:addChild(label)
            label:visit()
            local sz_1 = label:getDimensions()
            label:setDimensions(sz_1.width,sz_1.height)
            -- local txt = ccui.RichElementText:create(i,cc.c3b(255,255,255),255,txt,fontName,fontSzie)
            -- local newLine = ccui.RichElementNewLine:create(i,cc.c3b(255,255,255),255)

            local recustom = ccui.RichElementCustomNode:create( i, cc.c3b(255, 255, 255), 255, label ) 
            richText:pushBackElement(recustom)

        end
        
	end
    
    richText:setAnchorPoint(cc.p(0,1))
    richText:setContentSize(cc.size(440,300))
    richText:ignoreContentAdaptWithSize(false)
    --richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			--水平居中
    --richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_TOP)   -- 垂直居中
    richText:setVerticalSpace(0.6)
    richText:formatText()
    self.ListView_1:pushBackCustomItem(richText)
    self.ListView_1:jumpToBottom()
    return richText


    --[[

    	local richText = require("cp.view.ui.base.RichText"):create()
        for i=1, #contentTable do
            richText:addElement(contentTable[i])
        end
        
        richText:setContentSize(cc.size(410,85))
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:ignoreContentAdaptWithSize(false)
        richText:setPosition(cc.p(268,400))
        richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
        richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
        richText:setLineGap(2)
        return richText
    ]]
end


function LilianDetailLayer:showQuickExerciseresult(data)
    local exerCompress = cp.getUserData("UserLilian"):getValue("fast_result_list")
    if exerCompress == nil or next(exerCompress) == nil then
        return
    end 
    local itemTotalNum = 0
    if next(exerCompress.itemNum) then
        for i=1,table.nums(exerCompress.itemNum) do
            itemTotalNum = itemTotalNum + exerCompress.itemNum[i]
        end
    end
    if not (exerCompress.trainPoint > 0 or exerCompress.silver > 0 or exerCompress.conductGood > 0 or exerCompress.conductBad >0 or itemTotalNum > 0) then
        return
    end

    --顯示快速歷練結果
    local name = ""
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseId = major_roleAtt.exerciseId
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
    if cfg ~= nil then
        name = cfg:getValue("Name")
    end

    local GameConst = cp.getConst("GameConst")
    local contentTable = {
        {type="ttf", fontSize=24, text="你在", textColor=GameConst.ContentTextColor, outLineEnable=false},
        {type="ttf", fontSize=24, text=name, textColor=GameConst.QualityTextColor[2], outLineColor=GameConst.QualityOutlineColor[2], outLineSize=2},
        {type="ttf", fontSize=24, text="快速歷練2小時，", textColor=GameConst.ContentTextColor, outLineEnable=false},
        {type="blank", fontSize=1},
        {type="ttf", fontSize=24, text="獲得以下獎勵", textColor=GameConst.ContentTextColor, outLineEnable=false},
    }

    local openInfo = {info = exerCompress, title = "快速歷練報告", content = contentTable}
    local LilianResultLayer = require("cp.view.scene.world.lilian.LilianResultLayer"):create(openInfo) 
    self:addChild(LilianResultLayer)
    LilianResultLayer:setCloseCallBack(function()
        self:onNewGuideStory()
    end)
    
    cp.getUserData("UserLilian"):setValue("fast_result_list",{})
end

function LilianDetailLayer:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lilian" then
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        if cur_step == 4 or cur_step == 8 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.3))
            table.insert(sequence,cc.CallFunc:create(
                function()
                    local info =
                    {
                        classname = "LilianResultLayer",
                    }
                    self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
                end)
            )
            self:runAction(cc.Sequence:create(sequence))
        end
    end
end

function LilianDetailLayer:adjustUI()
    self.rootView:setContentSize(display.width,display.height)
    if display.height > 960 then
        self.Panel_root:setPositionY(display.height/2 + 110/2)
    else
        self.Panel_root:setPositionY(510)
    end
    ccui.Helper:doLayout(self.rootView)
end

return LilianDetailLayer
