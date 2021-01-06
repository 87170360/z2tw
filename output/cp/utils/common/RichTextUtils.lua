local xmlParser = require("thirdparty.xmlSimple").newParser()
local RichTextUtils = {}

local map =
{
    ['0'] = 0,
    ['1'] = 1,
    ['2'] = 2,
    ['3'] = 3,
    ['4'] = 4,
    ['5'] = 5,
    ['6'] = 6,
    ['7'] = 7,
    ['8'] = 8,
    ['9'] = 9,
    ['A'] = 10,
    ['B'] = 11,
    ['C'] = 12,
    ['D'] = 13,
    ['E'] = 14,
    ['F'] = 15
}

local function ColorConverH2C(hex_str)
    local color = {}
    for i=1,string.len(hex_str),2 do
        local first = map[string.sub(hex_str, i, i)]
        local second = map[string.sub(hex_str, i+1, i+1)]
        table.insert(color, first*16 + second)
    end
    return cc.c4b(color[1], color[2], color[3], color[4])
end

local shorthandField = {
    ["fs"] = "fontSize",
    ["tc"] = "textColor",
    ["t"] = "text",
    ["oc"] = "outLineColor",
    ["os"] = "outLineSize",
    ["bs"] = "blankSize",
    ["p"] = "filePath",
    ["tt"] = "textureType",
}

--flag=nil or false，返回richText,否則返回table
function RichTextUtils.ParseRichText(xmlInput, flag)
    local xml = xmlParser:ParseXmlText(xmlInput)
    local tblList = {}
    RichTextUtils.ParseNode(tblList, xml:children()[1])

    if flag then 
        return tblList
    end

    local richText = require("cp.view.ui.base.RichText"):create()
    richText:setAnchorPoint(cc.p(0,1))
    richText:ignoreContentAdaptWithSize(false)
    richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_TOP)   -- 垂直居中

    for _, tbl in ipairs(tblList) do
        richText:addElement(tbl)
    end
    return richText
end

function RichTextUtils.ParseNode(tblList, xml)
    RichTextUtils.ParseContentTable(tblList, xml)
    local children = xml:children()
    for _, node in ipairs(children) do
        RichTextUtils.ParseNode(tblList, node)
    end
end

function RichTextUtils.ParseContentTable(tblList, xml)
    local name = xml:name()
    if not name then return end
    local properties = xml:properties()
    local tbl = {}
    if name == "t" then
        tbl["type"] = "ttf"
    elseif name == "b" then
        tbl["type"] = "blank"
    elseif name == "i" then
        tbl["type"] = "image"
    else 
        return
    end

    for _, property in ipairs(properties) do
        local pname = shorthandField[property.name] or property.name
        local value = xml["@"..property.name]
        if pname == "textColor" or pname == "outLineColor" then
            --local temp = cp.getUtils("DataUtils").split(value, ",")
            if value:len() == 1 then
                if pname == "textColor" then
                    value = cp.getConst("CombatConst").SkillQualityColor4b[tonumber(value)]
                elseif pname == "outLineColor" then
                    value = cp.getConst("CombatConst").QualityOutlineC4b[tonumber(value)]
                end
            else
                value = ColorConverH2C(value)
            end
        elseif pname == "fontSize" or pname == "outLineSize" or pname == "blankSize" or pname == "textureType" then
            value = tonumber(value)
        end

        tbl[pname] = value
    end

    if name == "t" and xml:value() then
        tbl["text"] = tbl["text"] and tbl["text"]..xml:value() or xml:value()
    end
    
    table.insert(tblList, tbl)
    --dump(tbl)
    --richText:addElement(tbl)
end

return RichTextUtils