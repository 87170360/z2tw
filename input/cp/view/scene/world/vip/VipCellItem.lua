local VipCellItem = class("VipCellItem",function() return ccui.ScrollView:create() end)

function VipCellItem:create(info)
    local ret = VipCellItem.new()
    ret:init(info)
    return ret
end

function VipCellItem:init(info)
    self.width = info.width
    self.height = info.height
    self:setContentSize(cc.size(info.width,info.height-20))
    self:setInnerContainerSize(cc.size(info.width,info.height))
    -- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- self:setBackGroundColor(cc.c3b(0,0,0))
    -- self:setBackGroundColorOpacity(128)
    self:setTouchEnabled(true)
    self:setDirection(ccui.ScrollViewDir.both)
    self:setScrollBarEnabled(false)
end

function VipCellItem:resetInfo(idx)
    self:removeAllChildren()
    
    local contentTable = self:generateTeQuanDescription(idx)
    local richText = cp.getManager("ViewManager").createRichText(contentTable,self.width, 50,1)
    local sz = richText:getContentSize()
    -- layout:setContentSize(cc.size(sz.width, sz.height))
    richText:setAnchorPoint(cc.p(0,1))
    self:addChild(richText)
    local height = sz.height > self.height and sz.height or self.height
    self:setInnerContainerSize(cc.size(self.width,height))
    richText:setPosition(cc.p(0,height))
    self:jumpToTop()
end




function VipCellItem:generateTeQuanDescription(curLv)
    if curLv > 15 then
        return {}
    end

    local config = cp.getManager("ConfigManager").getItemByKey("Vip", curLv)
    local Effect = config:getValue("Effect")
    local EffectValueList = string.split(Effect,"-")
    local values = {
        tonumber(EffectValueList[1]),  --config:getValue("FreeSweep"),
        tonumber(EffectValueList[2]),  --config:getValue("BuyPhysical"),
        tonumber(EffectValueList[3]),  --config:getValue("BuySilver"),
        tonumber(EffectValueList[4]),  --config:getValue("BuyTrainPoint"),
        tonumber(EffectValueList[5]),  --config:getValue("QuickExercise"),
        tonumber(EffectValueList[6]),  --config:getValue("ResetStory"),

        config:getValue("SkipTime"),
        config:getValue("EscortLimit"),

        tonumber(EffectValueList[7]),  --config:getValue("ArenaTimes"),
        tonumber(EffectValueList[8]),  --config:getValue("FreeRoleDice"),
        tonumber(EffectValueList[9]),  --config:getValue("Mijing"),
        tonumber(EffectValueList[10]),  --config:getValue("RiverEvent"),

        config:getValue("VipHead"),
        config:getValue("ChatFrame"),
        tonumber(EffectValueList[11])
    }
    
    local Des = config:getValue("Des")
    local values2 = values
    
    if 15 >= curLv then
        local vip = cp.getUserData("UserVip"):getValue("level")
        local config_next = cp.getManager("ConfigManager").getItemByKey("Vip", vip)
        -- Des = config_next:getValue("Des")
        local Effect2 = config_next:getValue("Effect")
        local EffectValueList2 = string.split(Effect2,"-")
        values2 = {
            tonumber(EffectValueList2[1]),  --config_next:getValue("FreeSweep"),
            tonumber(EffectValueList2[2]),  --config_next:getValue("BuyPhysical"),
            tonumber(EffectValueList2[3]),  --config_next:getValue("BuySilver"),
            tonumber(EffectValueList2[4]),  --config_next:getValue("BuyTrainPoint"),
            tonumber(EffectValueList2[5]),  --config_next:getValue("QuickExercise"),
            tonumber(EffectValueList2[6]),  --config_next:getValue("ResetStory"),
    
            config_next:getValue("SkipTime"),
            config_next:getValue("EscortLimit"),
    
            tonumber(EffectValueList2[7]),  --config_next:getValue("ArenaTimes"),
            tonumber(EffectValueList2[8]),  --config_next:getValue("FreeRoleDice"),
            tonumber(EffectValueList2[9]),  --config_next:getValue("Mijing"),
            tonumber(EffectValueList2[10]), --config_next:getValue("RiverEvent"),

            config_next:getValue("VipHead"),
            config_next:getValue("ChatFrame"),
            tonumber(EffectValueList2[11])
        }
    end

    local idx_list = string.split(Des,"-")
    local contentTable = {}
    for i=1,#idx_list do
        local idx = tonumber(idx_list[i])
        self:getContent(idx,values[idx], values2[idx], contentTable,curLv,i)
    end

    return contentTable
end

function VipCellItem:getContent(idx,value,value2,contentTable,curLv,i)
    local add_value = value - value2
    local msg_text = {
        [1] = {"免費掃蕩次數  "," 次 "},
        [2] = {"可購買體力次數  "," 次 "},
        [3] = {"可招財銀兩次數  "," 次 "},
        [4] = {"可購買修為點次數  "," 次 "},
        [5] = {"可快速歷練次數  "," 次 "},
        [6] = {"可重置困難本次數  "," 次 "},
        [7] = {"跳過回合縮短至  "," 回合 "},
        [8] = {"押鏢刷新至少得到1輛  "," 階鏢車 "},
        [9] = {"比武擂臺可挑戰次數  "," 次 "},
        [10] = {"免費搖骰次數  "," 次 "},
        [11] = {"祕境可額外挑戰次數  "," 次 "},
        [12] = {"同時進行的江湖事數量  "," 個 "},
        [13] = {"解鎖 VIP"," 頭像"},
        [14] = {"解鎖 VIP"," 特殊聊天框"},
        [15] = {"每天最多能完成的江湖事數量  "," 個 "},
    }

    local showValue = value
    if idx == 13 or idx == 14 then
        if curLv >= 15 then
            showValue = 15
        else
            showValue = curLv + 1
        end
    elseif idx == 7 then
        showValue = value
    elseif idx == 8 then
        showValue = value 
    end

    local txt = msg_text[idx]
    contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=tostring(i) .. "." .. txt[1], textColor=cc.c4b(52,32,17,255)}
    contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=tostring(showValue), textColor=cc.c4b(96,118,231,255)}
    contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=txt[2], textColor=cc.c4b(52,32,17,255)}

    if idx < 13 and idx ~= 7 and idx ~= 8 then
        if add_value < 0 then
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text="  ", textColor=cc.c4b(255,0,0,255)}
            contentTable[#contentTable + 1] = {type="image",filePath="ui_vip_module33_vip_xia.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"}
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=tostring(math.abs(add_value)), textColor=cc.c4b(255,0,0,255)}
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=txt[2], textColor=cc.c4b(255,0,0,255)}
        elseif add_value > 0 then
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text="  ", textColor=cc.c4b(59,153,17 ,255)}
            contentTable[#contentTable + 1] = {type="image",filePath="ui_vip_module33_vip_shang.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"}
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=tostring(math.abs(add_value)), textColor=cc.c4b(59,153,17,255)}
            contentTable[#contentTable + 1] = {type="ttf",fontSize=20, text=txt[2], textColor=cc.c4b(59,153,17,255)}
        end
    end
    contentTable[#contentTable + 1] = {type="blank", blankSize=3}
    return contentTable
end


return VipCellItem