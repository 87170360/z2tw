local CombatConst = cp.getConst("CombatConst")
local GameConst = cp.getConst("GameConst")
local DataUtils = {}
math.E = 2.71828182845904523536028747135266249775724709369995957496696763
math.Pow = math.pow
function DataUtils.splitAttr(input)
    if not input or string.len(input) == 0 then
        return {}
    end
    local attrList = string.split(input, ";")
    for i, info in ipairs(attrList) do
        local temp = string.split(info, "=")
        attrList[i] = {
            checknumber(temp[1]),
            checknumber(temp[2]),
        }
    end 
    return attrList
end

function DataUtils.split(input, splits, index)
    local ret = {}
    if input:len() == 0 then
        return ret
    end
    index = index or 1
    split = splits:sub(index, index)
    local ret = input:split(split)
    if index ~= #splits then
        index = index + 1
        for i=1, #ret do
            ret[i] = DataUtils.split(ret[i], splits, index)
        end
    else
        for i=1, #ret do
            ret[i] = tonumber(ret[i])
        end
    end
    return ret
end

function DataUtils.splitString(input, splits, index)
    local ret = {}
    index = index or 1
    split = splits:sub(index, index)
    local ret = input:split(split)
    if index ~= #splits then
        index = index + 1
        for i=1, #ret do
            ret[i] = DataUtils.splitString(ret[i], splits, index)
        end
    end
    return ret
end

function DataUtils.splitElements(input)
    if not input or string.len(input) == 0 then
        return {}
    end
    local ret = {}
    local attrList = string.split(input, ";")
    for i, info in ipairs(attrList) do
        if info:len() > 0 then
            local temp = string.split(info, "=")
            ret[i] = {
                checknumber(temp[1]),
                checknumber(temp[2]),
                checknumber(temp[3]),
                checknumber(temp[4]),
            }
        end
    end
    return ret
end

function DataUtils.splitBufferList(input)
    if string.len(input) == 0 then
        return {}
    end
    local bufferList = string.split(input, ";")
    for i, info in ipairs(bufferList) do
        bufferList[i] = tonumber(info)
    end 
    return bufferList
end

function DataUtils.splitByColon(input)
end

function DataUtils.GetSkillLevelUpCost(skillColor, srcLevel, dstLevel)
    local trainPoint = 0
    for i=srcLevel+1, dstLevel do
        local point = 0
        if skillColor == 1 then
            point = 6*i*i+18*i+16
        elseif skillColor == 2 then
            point = 7.5*i*i+22.5*i+20
        elseif skillColor == 3 then
            point = 9*i*i+27*i+24
        elseif skillColor == 4 then
            point = 10.5*i*i+31.5*i+28
        elseif skillColor == 5 then
            point = 12*i*i+36*i+32
        elseif skillColor == 6 then
            point = 13.5*i*i+40.5*i+36
        end

        trainPoint = trainPoint + math.floor(point)
    end
 
    return trainPoint
end

--當前的修煉點能把武學升級到幾級
function DataUtils.CalculateLevelup(skillColor, srcLevel, totalTrainPoint)
    local trainPoint = 0
    local dstLevel = (math.floor(srcLevel/20)+1)*20
    for i=srcLevel+1, dstLevel do
        local point = 0
        if skillColor == 1 then
            point = 6*i*i+18*i+16
        elseif skillColor == 2 then
            point = 7.5*i*i+22.5*i+20
        elseif skillColor == 3 then
            point = 9*i*i+27*i+24
        elseif skillColor == 4 then
            point = 10.5*i*i+31.5*i+28
        elseif skillColor == 5 then
            point = 12*i*i+36*i+32
        elseif skillColor == 6 then
            point = 13.5*i*i+40.5*i+36
        end

        trainPoint = trainPoint + math.floor(point)
        if trainPoint > totalTrainPoint then
            return i-1
        elseif trainPoint == totalTrainPoint then
            return i
        end
    end
 
    return dstLevel
end

--計算重置需要的領悟點點以及獲得的修為點
function DataUtils.GetResetSkillPoint(skillColor, skillLevel)
    if skillLevel == 1 then
        return 0, 0
    end
    
    local trainPoint = DataUtils.GetSkillLevelUpCost(skillColor, 1, skillLevel)
    if skillColor == 1 then
        return skillLevel, trainPoint
    elseif skillColor == 2 then
        return math.floor(skillLevel*1.5), math.floor(trainPoint*0.9)
    elseif skillColor == 3 then
        return math.floor(skillLevel*2), math.floor(trainPoint*0.8)
    elseif skillColor == 4 then
        return math.floor(skillLevel*2.5), math.floor(trainPoint*0.7)
    elseif skillColor == 5 then
        return math.floor(skillLevel*3), math.floor(trainPoint*0.6)
    elseif skillColor == 6 then
        return math.floor(skillLevel*3.5), math.floor(trainPoint*0.5)
    end

    return 0, 0
end

function DataUtils.GetArtLevelUpCost(skillColor, artLevel)
    local learnPoint = 0
    if skillColor == 1 then
        learnPoint = artLevel*artLevel+2*artLevel+5
    elseif skillColor == 2 then
        learnPoint = artLevel*artLevel*2+3*artLevel+10
    elseif skillColor == 3 then
        learnPoint = artLevel*artLevel*3+4*artLevel+15
    elseif skillColor == 4 then
        learnPoint = artLevel*artLevel*4+5*artLevel+20
    elseif skillColor == 5 then
        learnPoint = artLevel*artLevel*5+6*artLevel+25
    elseif skillColor == 6 then
        learnPoint = artLevel*artLevel*6+7*artLevel+30
    end

    return math.floor(learnPoint)
end

function DataUtils.GetBoundaryUpgrade(skillColor, artLevel)
    local learnPoint = 0
    if skillColor == 1 then
        learnPoint = artLevel*artLevel+2*artLevel+5
    elseif skillColor == 2 then
        learnPoint = artLevel*artLevel*2+3*artLevel+10
    elseif skillColor == 3 then
        learnPoint = artLevel*artLevel*3+4*artLevel+15
    elseif skillColor == 4 then
        learnPoint = artLevel*artLevel*4+5*artLevel+20
    elseif skillColor == 5 then
        learnPoint = artLevel*artLevel*5+6*artLevel+25
    elseif skillColor == 6 then
        learnPoint = artLevel*artLevel*6+7*artLevel+30
    end

    return math.floor(learnPoint)
end

function DataUtils.GetDecomposePiecesPoint(skillColor)
    if skillColor == 1 then
        return 0
    elseif skillColor == 2 then
        return 1
    elseif skillColor == 3 then
        return 2
    elseif skillColor == 4 then
        return 3
    elseif skillColor == 5 then
        return 4
    elseif skillColor == 6 then
        return 5
    end

    return 0
end

--計算分解武學獲取的領悟點
function DataUtils.GetDecomposeBookPoint(skillColor)
    if skillColor == 1 then
        return 5
    elseif skillColor == 2 then
        return 10
    elseif skillColor == 3 then
        return 20
    elseif skillColor == 4 then
        return 45
    elseif skillColor == 5 then
        return 80
    elseif skillColor == 6 then
        return 125
    end

    return 0
end


--計算武學威力
function DataUtils.GetSkillPower(skillColor, skillLevel, boundary)
    boundary = boundary or 0
    skillLevel = skillLevel or 0
    local result = 1.447*math.pow(skillColor, 1.949)*skillLevel+43.499*skillColor+29.22                               
    result = DataUtils.GetSkillPowerByBoundary(boundary)*result                                         
    return math.floor(result)  
end

--計算武學內力消耗
function DataUtils.GetSkillForceCost(skillColor, skillLevel)
    local result = 0
    local factor1, factor2 = skillColor, skillLevel
    result = 1.0614*math.pow(factor1, 1.8922)*factor2+29.101*factor1+17.338
    return math.floor(result)
end 

--威力根據武學境界提升的增加
function DataUtils.GetSkillPowerByBoundary(boundary)
    if boundary == 1 then
        return 1.1
    elseif boundary == 2 then
        return 1.2
    elseif boundary == 3 then
        return 1.35
    elseif boundary == 4 then
        return 1.55
    elseif boundary == 5 then
        return 1.80
    elseif boundary == 6 then
        return 2.10
    elseif boundary == 7 then
        return 2.45
    elseif boundary == 8 then
        return 2.85
    elseif boundary == 9 then
        return 3.25
    elseif boundary == 10 then
        return 3.75
    end

    return 1.0
end

--附加屬性根據境界的提升的增長
function DataUtils.GetSkillExtraEffectByBoundary(boundary, serise)
    if serise == CombatConst.SkillSerise_Sword or
    serise == CombatConst.SkillSerise_Knife or
    serise == CombatConst.SkillSerise_Stick or
    serise == CombatConst.SkillSerise_Strange or
    serise == CombatConst.SkillSerise_Fist then
        if boundary == 1 then
            return 1.05
        elseif boundary == 2 then
            return 1.1
        elseif boundary == 3 then
            return 1.2
        elseif boundary == 4 then
            return 1.35
        elseif boundary == 5 then
            return 1.55
        elseif boundary == 6 then
            return 1.8
        elseif boundary == 7 then
            return 2.1
        elseif boundary == 8 then
            return 2.45
        elseif boundary == 9 then
            return 2.85
        elseif boundary == 10 then
            return 3.3
        end
    else
        if boundary == 1 then
            return 1.08
        elseif boundary == 2 then
            return 1.16
        elseif boundary == 3 then
            return 1.30
        elseif boundary == 4 then
            return 1.55
        elseif boundary == 5 then
            return 1.85
        elseif boundary == 6 then
            return 2.20
        elseif boundary == 7 then
            return 2.70
        elseif boundary == 8 then
            return 3.25
        elseif boundary == 9 then
            return 3.85
        elseif boundary == 10 then
            return 4.6
        end
    end

    return 1.0
end

function DataUtils.GetSkillExtraEffect(skillColor, level, boundary, id, serise)
    id = tonumber(id) or 0
    local a, x, result = skillColor, level, 0
    if id == 0 then
        result = 8.375*math.pow(math.E,0.423*a)*x+0.496*math.pow(math.E,0.472*a)+1
    elseif id == 1 then
        result = 5.583*math.pow(math.E,0.423*a)*x+0.331*math.pow(math.E,0.472*a)+1
    elseif id == 2 then
        result = 1.396*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 3 then
        result = 0.931*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 4 then
        result = 1.395*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 5 then
        result = 0.1994*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 6 then
        result = 0.798*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 7 then
        result = 0.859*math.pow(math.E,0.423*a)*x+0.143*a+0.667
    elseif id == 10 then
        result = 0.698*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 11 then
        result = 0.698*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 12 then
        result = 0.223*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 13 then
        result = 0.223*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 14 then
        result = 0.223*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 15 then
        result = 0.223*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 16 then
        result = 0.223*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    elseif id == 17 then
        result = 0.931*math.pow(math.E,0.423*a)*x+0.143*a+0.677
    end

    result = DataUtils.GetSkillExtraEffectByBoundary(boundary, serise)*result
    return math.floor(result)
end

function DataUtils.formatGainWay(input, extra)
    local ret = ""
    local out = {}
    local placeList = DataUtils.split(input, ";=")
    for i, placeInfo in ipairs(placeList) do
        local desc = ""
        if placeInfo[1] == 1 then
            desc = string.format( "通過第%d章第%d節獲取(普通)", math.floor(placeInfo[2]/1000), placeInfo[2]%1000)
        elseif placeInfo[1] == 2 then
            desc = string.format( "通過第%d章第%d節獲取(困難)", math.floor(placeInfo[2]/1000), placeInfo[2]%1000)
        elseif placeInfo[1] == 3 then
            desc = "通過藏寶閣獲取"
        elseif placeInfo[1] == 4 then
            desc = "通過精品商店購買"
        elseif placeInfo[1] == 5 then
            desc = "通過集市購買"
        elseif placeInfo[1] == 6 then
            desc = "通過江湖商店購買"
        elseif placeInfo[1] == 7 then
            desc = "通過聲望商店購買"
        elseif placeInfo[1] == 8 then
            desc = "通過天書商店購買"
        elseif placeInfo[1] == 9 then
            desc = "通過門派商店購買"
        elseif placeInfo[1] == 10 then
            desc = "通過神祕商店購買"
        elseif placeInfo[1] == 11 then
            desc = "通過祕境獲得"
        elseif placeInfo[1] == 12 then
            local entry = cp.getManager("ConfigManager").getItemByKey("GangEnhance", placeInfo[2])
            local color = extra
            if color == 1 then
                desc = string.format("【%s】進階至%s階後可學習", entry:getValue("Name"), DataUtils.formatZh_CN(placeInfo[3]))
            else
                local needLevel = (color - 1) * 20
                if color == 6 then
                    needLevel = 120
                end
                desc = string.format("【%s】進階至%s階，同時%s階武學升至%d級可學習", entry:getValue("Name"),
                    DataUtils.formatZh_CN(placeInfo[3] - 1), CombatConst.SeriseColorZhCN[color-1], needLevel)
            end
        end

        table.insert(out, desc)
    end

    return out
end

--武學附加屬性,屬性ID，屬性值，武學境界，武學等級
function DataUtils.formatSkillAttribute(id, value, floor)
    id = tonumber(id) or 0
    floor = floor or 1
    value = value - value % floor
    local tempStr = CombatConst.AttributeList[id]

    if value >= 0 then
        if id >= 50 then
            tempStr = tempStr.."+"..(value/100).."%"
        else
            tempStr = tempStr.."+"..value
        end
    else
        if id >= 50 then
            tempStr = tempStr.."-"..(value/100).."%"
        else
            tempStr = tempStr.."-"..value
        end
    end

    return tempStr
end

function DataUtils.formatSkillEffect(name, comment, attrList)
    if name then
        comment = name .. "  "..comment
    end

    for _, attrInfo in ipairs(attrList) do
        local id = attrInfo[1]
        local value = attrInfo[2]
        --[[
        if (id > CombatConst.Attr_ValueEnd and id < CombatConst.Attr_PercentEnd) or
            (id > CombatConst.Attr_PercentEnd and id < CombatConst.Attr_RateEnd) then
            value = value / 100
        end
        ]]
        local rep = "{"..id.."}%%"
        comment = comment:gsub(rep, tostring(value/100).."%%")
        rep = "{"..id.."}"
        comment = comment:gsub(rep, value)
    end

    return comment
end

function DataUtils.formatBufferElement(comment, elemList)
    for _, elemInfo in ipairs(elemList) do
        local id = elemInfo.id
        local value = elemInfo.value

        rep = "{"..id.."}"
        comment = comment:gsub(rep, math.abs(value))
    end

    local value = comment:match("{(.-)}")
    while value do
        local total = 0
        for k in string.gmatch(value, "(%-?%d+)") do
            total = total + tonumber(k)
        end 
        comment = comment:gsub("{.-}", math.abs(total))
        value = comment:match("{(.-)}")
    end 
    
    return comment
end

function DataUtils.formatZh_CN(number)
    if number == 0 then
        return CombatConst.NumberZh_Cn[number]
    end
    local out = ""
    local temp1 = math.floor(number/10)
    if temp1 == 1 then
        out = out .. "十"
    elseif temp1 > 1 then
        out = out .. CombatConst.NumberZh_Cn[temp1].."十"
    end

    local temp2 = number % 10
    if temp2 > 0 then
        out = out .. CombatConst.NumberZh_Cn[temp2]
    end

    return out
end

function DataUtils.GetAddUseEffect(attrID, skillColor, skillLevel, extra)
    local a = skillColor
	local x = skillLevel
	local param3, value = 0, 0
	if not extra or extra == 0 then
		param3 = 10000
	else
		param3 = extra
    end
	if attrID == 2 then
		value = 2.6839*math.pow(a,1.893)*x+86.347*math.pow(a,1.0671)
		value = value * param3/10000
	elseif attrID == 3 then
		value = 3*math.pow(a,1.6001)*x+80.67*math.pow(math.E,0.435*a)
		value = value * param3/10000
	elseif attrID == 6 then
		value = 3*a*x+17*x+827.14*a+636.67
		value = value * param3/10000
	elseif attrID == 7 then
		value = 6*a*x+26*x+800*a+1200
		value = value * param3/10000
	elseif attrID == 8 then
		value = 0.8333*a*x+2.5*x+100*a+500
		value = value * param3/10000
	elseif attrID == 10 then
		value = 4*a*x+4*x+13.1446*math.pow(a,1.569)
		value = value * param3/10000
	elseif attrID == 11 then
		value = 4*a*x+6*x+13.1446*math.pow(a,1.569)
		value = value * param3/10000
	elseif attrID == 12 then
		value = 2.5*a*x+6.5*x+101*a+141
		value = value * param3/10000
	elseif attrID == 13 then
		value = 2.5*a*x+6.5*x+101*a+141
		value = value * param3/10000
	elseif attrID == 14 then
		value = 2.5*a*x+6.5*x+101*a+141
		value = value * param3/10000
	elseif attrID == 15 then
		value = 2.5*a*x+6.5*x+101*a+141
		value = value * param3/10000
	elseif attrID == 16 then
		value = 2.5*a*x+6.5*x+101*a+141
		value = value * param3/10000
	elseif attrID == 17 then
		value = 1.5*a*x+3*x+124*a+71
		value = value * param3/10000
	elseif attrID == 45 then
		value = 2.1926*math.pow(a,1.8929)*x+33.611*math.pow(a,1.7662)
		value = value * param3/10000
	elseif attrID == 52 then
		value = 0.0001*a*x+0.00025*x+0.0063*a+0.0251
		value = value * param3
	elseif attrID == 53 then
		value = 0.0002*a*x+0.0007*x+0.0336*a+0.0712
		value = value * param3
	elseif attrID == 54 then
		value = 0.00027*a*x+0.00189*x+0.015*a+0.06
		value = value * param3
	elseif attrID == 55 then
		value = 0.00018*a*x+0.00126*x+0.01*a+0.05
		value = value * param3
	elseif attrID == 58 then
		value = 0.0003*a*x+0.0001*x+0.014*a+0.136
		value = value * param3
	elseif attrID == 67 then
		value = 0.00025*a*x+0.001*x+0.01568*a+0.1078
		value = value * param3
	elseif attrID == 95 then
		value = 0.00025*a*x+0.00025*x+0.0224*a+0.1656
		value = value * param3
	elseif attrID == 100 then
		value = 0.0002*a*x+0.0126*a+0.0492
		value = value * param3
	elseif attrID == 101 then
		value = 0.0003645*a*x+0.0025515*x+0.02025*a+0.081
		value = value * param3
	elseif attrID == 102 then
		value = 0.0003*a*x+0.0152*a+0.0568
		value = value * param3
	elseif attrID == 105 then
		value = 0.00075*a*x+0.0015*x+0.2*a+1.3
		value = value * param3
	elseif attrID == 106 then
		value = 0.0000375*a*x+0.00009375*x+0.00237*a+0.009405
		value = value * param3
	elseif attrID == 107 then
		value = 0.0001*a*x+0.0062*a+0.0418
		value = value * param3
	elseif attrID == 152 then
		value = 0.000083*a*x+0.000334*x+0.0199*a+0.0797
		value = value * param3
	elseif attrID == 162 then
		value = 0.0001*a*x+0.0004*x+0.01*a+0.14
		value = value * param3
	elseif attrID == 163 then
		value = 0.00005625*a*x+0.000140625*x+0.003555*a+0.0141075
		value = value * param3
	elseif attrID == 165 then
		value = 3.722*math.pow(math.E,0.4233*a)*x+62.4*a-15.733
		value = value * param3 / 10000
	elseif attrID == 167 then
		value = 0.000525*a*x+0.0266*a+0.0994
		value = value * param3
	elseif attrID == 169 then
		value = 0.00002*a*x+0.00003*x+0.0024*a+0.0086
		value = value * param3
	elseif attrID == 170 then
		value = 0.00002*a*x+0.0001*x+0.0026*a+0.0174
		value = value * param3
	elseif attrID == 171 then
		value = 0.0002*a*x+0.0003*x+0.019*a+0.109
		value = value * param3
	elseif attrID == 172 then
		value = 0.00000625*a*x+0.0000875*x+0.003*a+0.012
		value = value * param3
    elseif attrID == 176 then
        value = 10*a*x+40*x+138.8*a-40.8
		value = value * param3 / 10000
    elseif attrID == 178 then
        value = 0.8333*a*x+2.5*x+100*a+500
		value = value * param3 / 10000
	elseif attrID == 186 then
		value = 0.00075*a*x+0.0015*x+0.2*a+1.3
		value = value * param3
	elseif attrID == 189 then
		value = 0.000375*a*x+0.0015*x+0.02352*a+0.1617
		value = value * param3
	elseif attrID == 190 then
		value = 0.0003*a*x+0.0189*a+0.0738
		value = value * param3
	elseif attrID == 191 then
		value = 1.2*a*x+0.8*x+12*a+8
		value = value * param3 / 10000
	elseif attrID == 199 then
		value = 0.00006*a*x+0.00009*x+0.0072*a+0.0258
		value = value * param3
    else
		value = param3
	end
    return math.floor(value)
end

function DataUtils.GetSubUseEffect(attrID, skillColor, skillLevel, extra)
    local a = skillColor
	local x = skillLevel
	local param3, value = 0, 0
	if not extra or extra == 0 then
		param3 = 10000
	else
		param3 = extra
    end

    if attrID == 2 then
        value = 2.6839*math.pow(a,1.893)*x+86.347*math.pow(a,1.0671)
        value = value * param3 / 10000
    elseif attrID == 3 then
        value = 4.5*math.pow(a,1.6001)*x+160*a-61
        value = value * param3 / 10000
    elseif attrID == 8 then
        value = 1.24995*a*x+3.75*x+150*a+750
        value = value * param3 / 10000
    elseif attrID == 52 then
        value = 0.0001*a*x+0.00025*x+0.0063*a+0.0451
        value = value * param3
    elseif attrID == 53 then
        value = 0.00025*a*x+0.00025*x+0.022*a+0.066
        value = value * param3
    elseif attrID == 54 then
        value = 0.0002*a*x+0.0013*x+0.01*a+0.04
        value = value * param3
    elseif attrID == 55 then
        value = 0.0002*a*x+0.0148*a+0.0392
        value = value * param3
    elseif attrID == 57 then
        value = 0.000225*a*x+0.0114*a+0.0426
        value = value * param3
    elseif attrID == 58 then
        value = 0.00024*a*x+0.00008*x+0.01112*a+0.1088
        value = value * param3
    elseif attrID == 67 then
        value = 0.000281*a*x+0.001125*x+0.0176*a+0.1036
        value = value * param3
    elseif attrID == 100 then
        value = 0.00015*a*x+0.00945*a+0.0369
        value = value * param3
    elseif attrID == 102 then
        value = 0.000225*a*x+0.0114*a+0.0426
        value = value * param3
    elseif attrID == 104 then
        value = 0.0003*a*x+0.0002*x+0.0236*a+0.1044
        value = value * param3
    elseif attrID == 105 then
        value = 0.0002*a*x+0.0007*x+0.0336*a+0.0712
        value = value * param3
    elseif attrID == 106 then
        value = 0.000113*a*x+0.000281*x+0.00711*a+0.028215
        value = value * param3
    elseif attrID == 107 then
        value = 0.0002*a*x+0.0124*a+0.0836
        value = value * param3
	elseif attrID == 158 then
		value = 0.00001*a*x+0.00014*x+0.0048*a+0.0192
		value = value * param3
    elseif attrID == 164 then
        value = 0.0004*a*x+0.0124*a+0.0836
        value = value * param3
    elseif attrID == 165 then
        value = 1.125*math.pow(a,1.6001)*x+19.581*math.pow(math.E,0.435*a)
        value = value * param3 / 10000
    elseif attrID == 166 then
        value = 0.000081*a*x+0.000567*x+0.0045*a+0.018
        value = value * param3
    elseif attrID == 168 then
        value = 0.0000075*a*x+0.000105*x+0.0024*a+0.0096
        value = value * param3
    elseif attrID == 169 then
        value = 0.000005*a*x+0.00007*x+0.0024*a+0.0096
        value = value * param3
    elseif attrID == 170 then
        value = 0.0000125*a*x+0.000075*x+0.0024*a+0.0096
        value = value * param3
    elseif attrID == 173 then
        value = 0.00075*a*x+0.0015*x+0.2*a+1.3
        value = value * param3
    elseif attrID == 174 then
        value = 0.0000125*a*x+0.000075*x+0.0024*a+0.0096
        value = value * param3
    elseif attrID == 177 then
        value = 2.6839*math.pow(a,1.893)*x+86.347*math.pow(a,1.0671)
        value = value * param3 / 10000
    elseif attrID == 178 then
        value = 1.24995*a*x+3.75*x+150*a+750
		value = value * param3 / 10000
    elseif attrID == 192 then
        value = 0.0002*a*x+0.0007*x+0.0336*a+0.0712
        value = value * param3
    elseif attrID == 195 then
        value = 0.0000125*a*x+0.0000625*x+0.0034*a+0.0116
        value = value * param3
    else
        value = param3
    end
    return math.floor(value)
end

function DataUtils.GetAddArtEffect(attrID, skillColor, skillLevel, extra)
	local level = skillLevel*20
	return DataUtils.GetAddUseEffect(attrID, skillColor, level, extra)
end

function DataUtils.GetSubArtEffect(attrID, skillColor, skillLevel, extra)
	local level = skillLevel*20
	return DataUtils.GetSubUseEffect(attrID, skillColor, level, extra)
end

function DataUtils.GetSkillEffectValue(skillColor, skillLevel, effectList)
    for _, effectInfo in ipairs(effectList) do
        if effectInfo[2] == 0 then
            effectInfo[2] = DataUtils.GetAddUseEffect(effectInfo[1], skillColor, skillLevel, effectInfo[3])
        elseif effectInfo[2] == 1 then
            effectInfo[2] = DataUtils.GetSubUseEffect(effectInfo[1], skillColor, skillLevel, effectInfo[3])
        elseif effectInfo[2] == 2 then
            effectInfo[2] = math.abs(effectInfo[3])
        end
    end
end

function DataUtils.GetArtEffectValue(skillColor, skillLevel, effectList)
    for _, effectInfo in ipairs(effectList) do
        if effectInfo[2] == 0 then
            effectInfo[2] = DataUtils.GetAddArtEffect(effectInfo[1], skillColor, skillLevel, effectInfo[3])
        elseif effectInfo[2] == 1 then
            effectInfo[2] = DataUtils.GetSubArtEffect(effectInfo[1], skillColor, skillLevel, effectInfo[3])
        elseif effectInfo[2] == 2 then
            effectInfo[2] = effectInfo[3]
        end
    end
end

function DataUtils.formatOnlineStatus(second)
    local deltaTime = cp.getManager("TimerManager"):getTime()-second
    local days = math.floor(deltaTime/(24*3600))
    if days == 0 then
        local hour = math.floor(deltaTime/3600)
        if hour == 0 then
            return "1小時內在線"
        else
            return tostring(hour) .. "小時內在線"
        end
    elseif days < 7 then
        return string.format("%d天前登入", days)
    else
        return "7天前登入"
    end
end

function DataUtils.formatCombatBegin(second)
    local deltaTime = cp.getManager("TimerManager"):getTime()-second
    local days = math.floor(deltaTime/(24*3600))
    if days == 0 then
        local hour = math.floor(deltaTime/3600)
        if hour == 0 then
            return "1小時內"
        else
            return tostring(hour) .. "小時內"
        end
    elseif days < 7 then
        return string.format("%d天前", days)
    else
        return "7天前"
    end
end

function DataUtils.formatTimeRemain(deltaTime)
    local days = math.floor(deltaTime/(24*3600))
    local hours = math.floor(deltaTime%(24*3600)/3600)
    local minutes = math.floor(deltaTime%(3600)/60)
    local seconds = math.floor(deltaTime%60)
    local out = ""
    if days > 0 then
        out = string.format("%s%2d天", out, days)
    end

    if hours > 0 or days > 0 then
        out = string.format("%s%2d小時", out, hours)
    end
    if minutes > 0 or days > 0 or hours > 0 then
        out = string.format("%s%2d分鐘", out, minutes)
    end
    if seconds > 0 or days > 0 or hours > 0 or minutes > 0 then
        out = string.format("%s%2d秒", out, seconds)
    end
    return out
end

function DataUtils.formatTimeRemainEx(deltaTime)
    local days = math.floor(deltaTime/(24*3600))
    local hours = math.floor(deltaTime%(24*3600)/3600)
    local minutes = math.floor(deltaTime%(3600)/60)
    local seconds = math.floor(deltaTime%60)
    local out = ""
    if days > 0 then
        out = string.format("%s%2dD ", out, days)
    end

    if hours > 0 then
        out = string.format("%s%2d:", out, hours)
    end
    if minutes > 0 or (minutes == 0 and hours > 0) then
        out = string.format("%s%02d:", out, minutes)
    end
    if seconds >= 0 then
        out = string.format("%s%02d", out, seconds)
    end
    return out
end

function DataUtils.formatTimeRemainWAllShow(deltaTime,needHour)
    local days = math.floor(deltaTime/(24*3600))
    local hours = math.floor(deltaTime%(24*3600)/3600)
    local minutes = math.floor(deltaTime%(3600)/60)
    local seconds = math.floor(deltaTime%60)
    local out = ""
    if days > 0 then
        out = string.format("%s%2dD ", out, days)
    end
    if needHour ~= nil and needHour == false then
        if days > 0 or hours > 0 then
            out = string.format("%s%02d:%02d:%02d", out, hours,minutes,seconds)
        else
            out = string.format("%02d:%02d", minutes,seconds)
        end
    else
        out = string.format("%s%02d:%02d:%02d", out, hours,minutes,seconds)
    end
    
    return out
end

function DataUtils.parseRollDiceConfig(text)
    local config = {}
    config.ChangeCost = {}
    config.PointList = {}
    local textList = string.split(text, ";")
    local textList1 = string.split(textList[1], ":")
    local textList2 = string.split(textList[3], ":")
    config.RollCost = tonumber(textList[2])
    for _, tmp in ipairs(textList1) do
        table.insert(config.ChangeCost, tonumber(tmp))
    end

    for _, tmp in ipairs(textList2) do
        table.insert(config.PointList, tonumber(tmp))
    end

    return config
end

function DataUtils.fillArenaPlayerInfo(playerInfo)
    if playerInfo and playerInfo.type == 0 then
        local npcEntry = cp.getManager("ConfigManager").getItemByKey("GameNpc", playerInfo.id)
        playerInfo.career = npcEntry:getValue("Career")
        playerInfo.gender = npcEntry:getValue("Gender")
        playerInfo.name = npcEntry:getValue("Name")
        playerInfo.fight = math.floor(npcEntry:getValue("Fight"))
    end
end

function DataUtils.isBetweenTime(beginTime,endTime,nowTimeTable)
    if (nowTimeTable.hour < beginTime.hour) or
        (nowTimeTable.hour == beginTime.hour and nowTimeTable.min < beginTime.min) or
        (nowTimeTable.hour > endTime.hour) or
        (nowTimeTable.hour == endTime.hour and nowTimeTable.min > endTime.min) then
            return false
    end

    return true
end

function DataUtils.convertWeekDay(wd)
    wd = tonumber(wd)
    if wd == 0 then
        return 7
    end
    return wd
end

function DataUtils.getNearestWeekDay(wd, wdList)
    for i=0, 7 do
        local nearestWd = (wd+i)%7
        if table.indexof(wdList, nearestWd) then
            return nearestWd
        end
    end
end

function DataUtils.getNextWeekDayTime(ts, wdList)
    local weekDay = tonumber(os.date("%w", ts))
    for i=1, 7 do
        local nearestWeekDay = (weekDay+i)%7
        if table.indexof(wdList, nearestWeekDay) then
            return ts+i*24*3600
        end
    end
end

--1報名階段，2等待階段，3幫戰階段
function DataUtils.getGuildFightPhase(wd, nowTab, config)
    local beginTime = {
        hour = config[2][1],
        min = config[2][2],
    }

    local endTime = {
        hour = config[2][1] + math.floor(config[3][1]/60) + math.floor((config[3][1]%60+config[2][2])/60),
        min = (config[3][1]%60+config[2][2])%60,
    }

    local nearWD = DataUtils.convertWeekDay(DataUtils.getNearestWeekDay(wd, config[1]))
    wd = DataUtils.convertWeekDay(wd)
    local phase = 2
    local remainTime = 0
    if wd ~= nearWD then
        phase = 1
        if wd >= nearWD then
            remainTime = (8 - wd + nearWD-1)*24*3600 - (nowTab.hour*3600+nowTab.min*60+nowTab.sec)
        else
            remainTime = (nearWD - wd)*3600*24 - (nowTab.hour*3600+nowTab.min*60+nowTab.sec)
        end
    elseif DataUtils.isBetweenTime(beginTime, endTime, nowTab) then
        phase = 3
        remainTime = endTime.hour*3600 + endTime.min*60 - (nowTab.hour*3600+nowTab.min*60+nowTab.sec)
    elseif DataUtils.isBetweenTime({hour=0,min=0}, beginTime, nowTab) then
        phase = 2
        remainTime = beginTime.hour*3600 + beginTime.min*60 - (nowTab.hour*3600+nowTab.min*60+nowTab.sec)
    elseif DataUtils.isBetweenTime(endTime,{hour=24,min=00}, nowTab) then
        phase = 4
        remainTime = (8 - wd + nearWD-1)*24*3600 - (nowTab.hour*3600+nowTab.min*60+nowTab.sec)
    end

    return phase, remainTime
end

function DataUtils.guildActivityOpen(guildDetailData, activity)
    local activityConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildActivity"), ";:")
    return activityConfig[4][activity] <= guildDetailData.level
end

function DataUtils.guildActivityOpenLevel(activity)
    local activityConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildActivity"), ";:")
    return activityConfig[4][activity]
end

function DataUtils.getHanziNum(name)
    local hanzCount = 0
    local nhzCount = 0
    
    local index = 1
    while(index <= #name) do
        local char = string.sub(name, index, index)
        if string.byte(char) >= 161 then
            hanzCount = hanzCount + 1
            index = index + 2
        else
            nhzCount = nhzCount + 1
        end
        index = index + 1
    end

    return hanzCount, nhzCount
end

function DataUtils.getModelFace(face)
    return "res/img/model/head/"..face..".png"
end

function DataUtils.getModelCombatFace(face)
    local faceEntry = cp.getManager("ConfigManager").getItemByKey("Face", face)
    if not faceEntry then return "" end
    face = faceEntry:getValue("CombatFace")
    return "res/img/model/head/"..face..".png"
end

-- 參數effect 對應Vip表格中Effect字段的取值範圍10種類型(0~9)
function DataUtils.GetVipEffect( effect )
    local vip = cp.getUserData("UserVip"):getValue("level")
    local effectConfig = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Vip", vip):getValue("Effect"), "-")
    return effectConfig[effect+1]
end

function DataUtils.GetSkipRound()
    local vip = cp.getUserData("UserVip"):getValue("level")
    return cp.getManager("ConfigManager").getItemByKey("Vip", vip):getValue("SkipTime"), vip
end

function DataUtils.GetWeekDayZh_CN(wd, wd1)
    if wd == wd1 then
        return "今天"
    end
    if wd == 0 then
        return "週日"
    elseif wd == 1 then
        return "週一"
    elseif wd == 2 then
        return "週二"
    elseif wd == 3 then
        return "週三"
    elseif wd == 4 then
        return "週四"
    elseif wd == 5 then
        return "週五"
    elseif wd == 6 then
        return "週六"
    end
end

function findoutElementBuffer(attrList)
    local bufferList = {}
    for _, elemInfo in ipairs(attrList) do
        if elemInfo[1] == 150 or elemInfo[1] == 151 then
            table.insert(bufferList, elemInfo[3])
        end
    end

    return bufferList
end

local effectTemplate = 
[[
<t fs="18" tc="342011FF">
    %s
</t>
]]
local equipEffectTemplate = [[<t fs="18" t="%s" tc="47D551FF" oc="277625FF" os="2"/>  %s]]
local subEffectTemplate = [[<t fs="18" t="%s" tc="47D551FF" oc="277625FF" os="2"/>  <t ts="16" t="%s  %s" tc="342011FF"/>]]
--上陣效果
function DataUtils.formatEquipEffect(level, color, eventList)
    local output = ""
    for _, id in ipairs(eventList) do
        local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", id)
        local name = eventEntry:getValue("Name")
	    if not name or name:len(name) == 0 then
		    name = "no name"
        end
        
        if output ~= "" then output = output..[[<b bs="1"/>]] end

	    local desc = eventEntry:getValue("Comment")
	    local attrList = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
	    table.insertto(attrList, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
	    cp.getUtils("DataUtils").GetSkillEffectValue(color, level or 1, attrList)
	    if #attrList > 0 then
		    desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
        end
        local desc = string.format(equipEffectTemplate, name, desc)
        output = output .. desc
        local bufferList = findoutElementBuffer(attrList)
        if #bufferList > 0 then
            output = output..DataUtils.formatUseEffect(level, color, bufferList, name)
        end
    end
    
    output = string.format( effectTemplate, output )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_EquipEffect")
	richText:setContentSize(cc.size(600,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(600,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

local primevalTemplate = 
[[
<t fs="20" tc="4A341EFF">
    %s
</t>
]]
local primevalEffectTemplate = [[<t fs="20" t="%s" tc="47D551FF" oc="277625FF" os="2"/>%s]]
function DataUtils.formatPrimevalEffect(level, color, eventList, name, width)
    width = width or 385
    local output = ""
    for _, id in ipairs(eventList) do
        local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", id)
	    if not name  then
		    name = eventEntry:getValue("Name")
        end

        if name:len() ~= 0 then
            name = name.."   "
        end
        
        if output ~= "" then output = output..[[<b bs="1"/>]] end

	    local desc = eventEntry:getValue("Comment")
	    local attrList = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
	    table.insertto(attrList, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
	    cp.getUtils("DataUtils").GetSkillEffectValue(color, level or 1, attrList)
	    if #attrList > 0 then
		    desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
        end
        local desc = string.format(primevalEffectTemplate, name, desc)
        output = output .. desc
    end
    
    output = string.format( primevalTemplate, output )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_PrimevalEffect")
	richText:setContentSize(cc.size(width,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(width,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

--如果flag為true，返回
function DataUtils.formatUseEffect(level, color, bufferList, hostName)
	local output = ""
    for _, bufferID in ipairs(bufferList) do
		local attrList = {}
		local skillStatusEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferID)
        local eventList = cp.getUtils("DataUtils").splitBufferList(skillStatusEntry:getValue("EventList"))
        for _, eventID in ipairs(eventList) do
			local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", eventID)
			local list = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
            table.insertto(list, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
            local conditionInfo = DataUtils.split(eventEntry:getValue("Rate"), "=")
			if conditionInfo[1] == 0 then
				table.insert(list, {
					CombatConst.GameElement_ConditionRate, 0, conditionInfo[2] or 10000
                })
            else
				table.insert(list, {
					CombatConst.GameElement_ConditionRate, 2, conditionInfo[1] or 10000
                })
			end
			cp.getUtils("DataUtils").GetSkillEffectValue(color, level or 1, list)
			for k, v in ipairs(list) do
				table.insert(attrList, v)
			end
		end

		local name = skillStatusEntry:getValue("Name")
		local desc = skillStatusEntry:getValue("Comment")
        if output ~= "" or hostName then output = output..[[<b bs="1"/>]] end

		local list = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("Elements"))
		local boolStatusList = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("BoolStatus"))
		for _, boolStatusInfo in ipairs(boolStatusList) do
			table.insert(list, {
				CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
			})
			table.insert(list, {
				CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
			})
		end
		cp.getUtils("DataUtils").GetSkillEffectValue(color, level or 1, list)
		for k, v in ipairs(list) do
			table.insert(attrList, v)
		end
        desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
        if hostName then
            desc = string.format([[<t fs="18" t="%s" tc="47D55100"/><t fs="16" t="  %s  %s" tc="342011FF"/>]], hostName, name, desc)
        else
            desc = string.format([[<t fs="18" t="%s" tc="47D551FF" oc="277625FF" os="2"/>  %s]], name, desc)
        end
        output = output .. desc
        local bufferList = findoutElementBuffer(attrList)
        if #bufferList > 0 then
            output = output..DataUtils.formatUseEffect(level, color, bufferList, true)
        end
    end

    if hostName then
        return output
    end
    
    output = string.format( effectTemplate, output )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_UseEffect")
	richText:setContentSize(cc.size(600,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(600,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

local combineEffectTemplate = 
[[
<t fs="18" tc="342011FF">
%s
</t>
]]

function DataUtils.formatCombineEffect(skillEntry, skillUnitsEntry, equipList)
    local skillList = cp.getUtils("DataUtils").splitBufferList(skillUnitsEntry:getValue("NeedSkills"))
    local activeCombine = true
    local output = "需求"
    for _, skillID in ipairs(skillList) do
        local entry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
        local colorIndex = 2
        if not table.indexof(equipList, entry:getValue("SkillID")) then
            colorIndex = 6
            activeCombine = false
        end
        output = output .. string.format([[<t fs="18" t="  %s" tc="%d" oc="%d" os="2"/>  ]], entry:getValue("SkillName"), colorIndex, colorIndex)
    end

    output = output..[[<b bs="1"/>效果]]

    local colorIndex = 2
    if not activeCombine then
        colorIndex = 6
    end

    output = output .. string.format([[<t fs="18" t="  %s" tc="%d" oc="%d" os="2"/>  ]], skillUnitsEntry:getValue("Name"), colorIndex, colorIndex)

    local bufferID = tonumber(skillUnitsEntry:getValue("BufferList"))
    local skillStatusEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferID)
    if skillStatusEntry then
        local attrList = {}
        local eventList = cp.getUtils("DataUtils").splitBufferList(skillStatusEntry:getValue("EventList"))
        for _, eventID in ipairs(eventList) do
            local eventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", eventID)
            local list = cp.getUtils("DataUtils").splitElements(eventEntry:getValue("RunElements"))
            table.insertto(list, cp.getUtils("DataUtils").splitElements(eventEntry:getValue("LoadElements")))
            local conditionInfo = DataUtils.split(eventEntry:getValue("Rate"), "=")
            if conditionInfo[1] == 0 then
                table.insert(list, {
                    CombatConst.GameElement_ConditionRate, 0, conditionInfo[2] or 10000
               })
            else
                table.insert(list, {
                    CombatConst.GameElement_ConditionRate, 2, conditionInfo[1] or 10000
               })
            end
            cp.getUtils("DataUtils").GetSkillEffectValue(skillEntry:getValue("Colour"), 0, list)
            for k, v in ipairs(list) do
                table.insert(attrList, v)
            end
        end

        local desc = skillStatusEntry:getValue("Comment")
        local list = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("Elements"))
        local boolStatusList = cp.getUtils("DataUtils").splitElements(skillStatusEntry:getValue("BoolStatus"))
        for _, boolStatusInfo in ipairs(boolStatusList) do
            table.insert(list, {
                CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
            })
            table.insert(list, {
                CombatConst.GameElement_ConditionRate, boolStatusInfo[3], boolStatusInfo[4]
            })
        end
        cp.getUtils("DataUtils").GetSkillEffectValue(skillEntry:getValue("Colour"), 0, list)
        for k, v in ipairs(list) do
            table.insert(attrList, v)
        end
        desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
        output = output .. desc
    end

    output = string.format( combineEffectTemplate, output )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_CombineEffect")
	richText:setContentSize(cc.size(600,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(600,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

function DataUtils.formatSkillComment(skillEntry)
    local output = string.format( combineEffectTemplate, skillEntry:getValue("Comment") )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_Comment")
	richText:setContentSize(cc.size(600,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(600,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

function DataUtils.formatSkillGainWay(skillEntry)
    local gainWay = cp.getUtils("DataUtils").formatGainWay(skillEntry:getValue("GainWay"), skillEntry:getValue("Colour"))
    local output = ""
    for i, desc in ipairs(gainWay) do
        if output ~= "" then
            output = output .. [[<b bs="1"/>]]
        end
        output = output .. i .. ". "..desc
    end
    
    output = string.format( combineEffectTemplate, output )
    local richText = cp.getUtils("RichTextUtils").ParseRichText(output)
    richText:setName("RichText_GainWay")
	richText:setContentSize(cc.size(600,9000))
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(math.max(600,tsize.width),tsize.height))
    richText:setAnchorPoint(cc.p(0,1))
    return richText
end

function DataUtils.GetPriceByCount(count, priceList)
    if #priceList == 0 then
        return 0
    end

    if count + 1 >= #priceList then
        return priceList[#priceList]
    end

    return priceList[count+1]
end

function DataUtils.formatStoryInfo(id, difficulty)
    local chapter = math.floor(id / 1000)
    local part = id % 1000
    local diff = "簡單"
    if difficulty == 1 then
        diff = "困難"
    end
    return string.format("第%d章第%d節_%s", chapter, part, diff)
end

--華山論劍階段
function DataUtils.getMountainFightPhase(wd, nowTab)
    local weekList = DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("MountainConfig"), ";:")[2]
    if not table.indexof(weekList, wd) then
        return 7
    end

    for i=0, 7 do
        local entry = cp.getManager("ConfigManager").getItemByKey("MountainTop", i)
        local phaseBegin = DataUtils.split(entry:getValue("PhaseBegin"), ":")
        local phaseEnd = DataUtils.split(entry:getValue("PhaseEnd"), ":")
        local beginTab = {
            hour = phaseBegin[1], min = phaseBegin[2],
        }
        local endTab = {
            hour = phaseEnd[1], min = phaseEnd[2],
        }
        if DataUtils.isBetweenTime(beginTab, endTab, nowTab) then
            return i
        end
    end

    return 7
end

function DataUtils.parseGuildEvent(eventList)
    local result = {}
    for _, guildEvent in ipairs(eventList) do
        if guildEvent.event == 1 then
            local desc = string.format("%s離開了幫派", guildEvent.params[1])
            table.insert(result, desc)
        elseif guildEvent.event == 2 then
            local desc = string.format("歡迎%s加入幫派", guildEvent.params[1])
            table.insert(result, desc)
        elseif guildEvent.event == 3 then
            local desc = string.format("%s捐獻 %s %s", guildEvent.params[1], guildEvent.params[2], guildEvent.params[3])
            table.insert(result, desc)
        elseif guildEvent.event == 4 then
            local desc = string.format("幫派升級至%s級", guildEvent.params[1])
            table.insert(result, desc)
        elseif guildEvent.event == 5 then
            local desc = string.format("佔領 %s 獲得%s幫派經驗、%s幫派資金", guildEvent.params[1], guildEvent.params[2], guildEvent.params[3])
            table.insert(result, desc)
        elseif guildEvent.event == 6 then
            local desc = string.format("%s 被任命為 %s", guildEvent.params[1], guildEvent.params[2])
            table.insert(result, desc)
        elseif guildEvent.event == 7 then
            local desc = string.format("%s 報名了攻掠戰", guildEvent.params[1])
            table.insert(result, desc)
        elseif guildEvent.event == 8 then
            local desc = string.format("%s 開啟了【%s】的攻掠戰，請各位成員及時報名參加", guildEvent.params[1], guildEvent.params[2])
            table.insert(result, desc)
        elseif guildEvent.event == 9 then
            local desc = string.format("%s 被 %s 踢出幫派", guildEvent.params[1], guildEvent.params[2])
            table.insert(result, desc)
        elseif guildEvent.event == 10 then
            local desc = string.format("%s 參加一次灑掃庭除獲得%s個人資金、%s幫派經驗", guildEvent.params[1], guildEvent.params[2], guildEvent.params[3])
            table.insert(result, desc)
        elseif guildEvent.event == 11 then
            local desc = string.format("%s 驅趕一名幫派強盜獲得%s個人資金、%s幫派經驗", guildEvent.params[1], guildEvent.params[2], guildEvent.params[3])
            table.insert(result, desc)
        elseif guildEvent.event == 12 then
            local desc = string.format("%s參加一次幫派修築獲得%s幫貢", guildEvent.params[1], guildEvent.params[2])
            table.insert(result, desc)
        elseif guildEvent.event == 13 then
            log(guildEvent)
            local level = tonumber(guildEvent.params[2]) - 1
            local desc = string.format("幫派建築【%s】%s加成已激活", GameConst.GuildBuildingName[tonumber(guildEvent.params[1])], GameConst.GuildBuildingLevel[level])
            table.insert(result, desc)
        end
    end
    return result
end

--交換數組元素
function Swap( data, i, j )
    local tmp = data[i];
    data[i] = data[j];
    data[j] = tmp;
end

--一次排序 確定一個位置 左邊小 右邊大
function QSPass( data, low, high , compare)
    local tmp = data[low];
    while low < high do

        while low < high and not compare(data[high] , tmp) do
            high = high - 1;
        end
        
        if low == high then break end
        Swap( data, low, high );
        low = low + 1;
        

        while low < high and compare( data[low] , tmp) do
            low = low + 1;
        end

        if low < high then
            Swap( data, low, high );
            high = high - 1;
        end

    end

    data[low] = tmp;

    return low;
end

--快速排序
function QuickSort( data, low, high, compare )
    if low < high then
        pivot = QSPass( data, low, high, compare );
        QuickSort( data, low, pivot - 1, compare );
        QuickSort( data, pivot + 1, high, compare );
    end
end

DataUtils.quick_sort = function(tbl, compare)
    QuickSort(tbl, 1, #tbl, compare)
end

function DataUtils.GetPrimevalEffect(id, color, level)
    local a,x,value = color, level, 0
    if id == 2 then
		value = 1.7241*a*x+3.4485*x+70*a-20
    elseif id == 52 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 0 then
		value = 16.995*math.pow(math.E,0.4312*a)*x+71*math.pow(math.E,0.6663*a)
    elseif id == 50 then
		value = 0.0003*math.pow(math.E,0.2305*a)*x+0.0057*math.pow(math.E,0.3312*a)
    elseif id == 1 then
		value = 5.665*math.pow(math.E,0.4312*a)*x+23.667*math.pow(math.E,0.6663*a)
    elseif id == 51 then
		value = 0.0003*math.pow(math.E,0.2305*a)*x+0.0057*math.pow(math.E,0.3312*a)
    elseif id == 3 then
		value = 3.1034*a*x+6.2073*x+126*a-36
    elseif id == 53 then
		value = 0.00014*a*x+0.00057*x+0.00701*a-0.00057
    elseif id == 4 then
		value = 1.6995*math.pow(math.E,0.4312*a)*x+7.1*math.pow(math.E,0.6663*a)
    elseif id == 54 then
		value = 0.0003*math.pow(math.E,0.2305*a)*x+0.0057*math.pow(math.E,0.3312*a)
    elseif id == 5 then
		value = 0.8498*math.pow(math.E,0.4312*a)*x+3.55*math.pow(math.E,0.6663*a)
    elseif id == 55 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 6 then
		value = 1.20691*a*x+2.414*x+49*a-14
    elseif id == 56 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 7 then
		value = 1.7241*a*x+3.4485*x+70*a-20
    elseif id == 57 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 10 then
		value = 0.8498*math.pow(math.E,0.4312*a)*x+3.55*math.pow(math.E,0.6663*a)
    elseif id == 60 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 11 then
		value = 1.20691*a*x+2.414*x+49*a-14
    elseif id == 61 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
    elseif id == 17 then
		value = 1.7241*a*x+3.4485*x+70*a-20
    elseif id == 67 then
		value = 0.0001*a*x+0.0004*x+0.0049*a-0.0004
	end

	if id >= 50 then
		value = value * 10000
    end

	return math.floor(value)
end

--獲取一個混元所包含的經驗
function DataUtils.GetMetaExp(color, level, exp)
    return DataUtils.GetMetaStrengthExp(color, 0, 0, level) + exp
end

--從某一級到另外一級需要的經驗
function DataUtils.GetMetaStrengthExp(color, level, exp, targetLevel)
    local toExp = 0
    cp.getManager("ConfigManager").foreach("PrimevalExp", function(entry)
        --log("Level=", entry:getValue("Level"))
        if entry:getValue("Level") <= level then
            return true
        end

        toExp = toExp + entry:getValue("Color"..color)
        if entry:getValue("Level") >= targetLevel then
            return false
        end

        return true
    end)

    return toExp - exp
end

--
function DataUtils.GetExpByLevel(color, level)
    local entry = cp.getManager("ConfigManager").getItemByKey("PrimevalExp", level)
    return entry:getValue("Color"..color)
end

--獲取一個混元加addExp經驗後的等級和經驗
function DataUtils.GetMetaUpgrade(color, level, exp, addExp)
    addExp = addExp + exp
    local needExp = 0
    while addExp > 0 do
        needExp = DataUtils.GetMetaStrengthExp(color, level, 0, level + 1)
        if needExp == 0 or addExp < needExp then
            break
        end

        level = level + 1
        addExp = addExp - needExp
        log("addExp="..addExp)
        if level == 30 then
            break
        end
    end

    return level, addExp, needExp
end

--獲取強化所需的銀幣
function DataUtils.GetStrengthNeedSilver(exp)
    return exp * 200
end

--獲取一個混元售賣所得銀幣                                                                             
function DataUtils.GetMetaSellSilver(color, level)
    local a, x = color, level
    return math.floor(3965.7*a+3792.8*x+31035*a-13793)
end

--軟裝是否安裝
function DataUtils.hasSoftPartInstalled()
    local hasSoftPart = cp.getManualConfig("HotUp").hasSoftPart
    if not hasSoftPart then
        return true
    end

    local softPartInstalled = cp.getManager("LocalDataManager"):getValue("", "hotupver", "softPartInstalled")
    if not softPartInstalled then
        return false
    end

    return true
end

function DataUtils.formatSkillSpecial(skillList)
    local special = {}
    for _, skillID in ipairs(skillList) do
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
        local skillUnits = cp.getManager("ConfigManager").getItemByKey("SkillUnits", skillID)
        if DataUtils.skillUnitsTakeEffect(skillUnits) then
            table.insertto(special, cp.getUtils("DataUtils").split(skillUnits:getValue("Special"), ";"))
        end

        if skillEntry and skillEntry:getValue("Special") ~= "" then
            table.insertto(special, cp.getUtils("DataUtils").split(skillEntry:getValue("Special"), ";"))
        end
    end

    --dump(special)
    special = table.values(table.unique(special))
    return special
end

function DataUtils.skillUnitsTakeEffect(unitsEntry)
    if not unitsEntry then
        return false
    end

    if not cp.getUserData("UserSkill"):getSkill(unitsEntry:getValue("ID")) then
        return false
    end
    local skillList = cp.getUtils("DataUtils").split(unitsEntry:getValue("NeedSkills"), ";")
    for _, skillID in ipairs(skillList) do
        if not cp.getUserData("UserSkill"):getSkill(skillID) then
            return false
        end
    end
    return true
end

function DataUtils.replaceGameTalk(txt, name, gender, career)
	--對話中文字替換
	if string.find(txt,"【玩家】") then 
		txt = string.gsub(txt,"【玩家】", name)
	end
	if string.find(txt,"【玩家】") then 
		txt = string.gsub(txt,"【玩家】",name)
	end
	if string.find(txt,"【門派】") then 
		local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", career)
		txt = string.gsub(txt,"【門派】",cfg:getValue("Name"))
	end
	if string.find(txt,"【門派】") then 
		local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", career)
		txt = string.gsub(txt,"【門派】",cfg:getValue("Name"))
	end
	if string.find(txt,"【師兄姐】") then 
		if gender == 0 then
			txt = string.gsub(txt,"【師兄姐】", career == 0  and "師兄" or "師姐")
		elseif gender == 1 then
			txt = string.gsub(txt,"【師兄姐】", career == 3  and "師姐" or "師兄")
		end
    end
    
    return txt
end

return DataUtils