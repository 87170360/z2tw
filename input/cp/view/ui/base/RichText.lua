--[====[
------------------------------------------------------------------------------------------------------------------------------
    -- local RichText = require("cp.view.ui.base.RichText")
    -- local richText = RichText:create()
    -- local tb = {type="ttf",touchCallBack=function(sender, event)log(event)end,fontSize=20,text="1234lalala" ,textColor =cc.c4b(250,250,250,255)}
    -- local tb2 ={type="image",filePath="img/icon/build/icon_20001.png",textureType=ccui.TextureResType.Local,opacity=80,blink=true,blinkInterval=3}
    -- richText:addElement(tb)
    -- richText:addElement(tb2)
    -- richText:setContentSize(cc.size(300,300))
    -- richText:setAnchorPoint(cc.p(0.5,0.5))
    -- richText:ignoreContentAdaptWithSize(false)
    -- richText:setPosition(cc.p(1024/2,576/2))
    -- richText:setHAlign(cc.TEXT_ALIGNMENT_RIGHT)
    -- -- richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    -- richText:setLineGap(5)
    -- self:addChild(richText)
-- 
-- -------------------------------------------
-- 
-- ttf param:   type:string,              default: "ttf"                                --類型
--              text:String,              default: ""                                   --文本
--              fontName:String,          default: "droid sans fallback"                --字體
--              fontSize:int,             default: 12                                   --字體大小
--              textColor:c4b
--              underLineEnable:boolean,  default: false                                --是否有下劃線
--              underLineColor:c4b,       default: cc.c4b(0,0,0,255)                    --下劃線顏色
--              underLineSize:int,        default: 1                                    --下劃線大小
--              outLineEnable:boolean,    default: false                                --是否有描邊
--              outLineColor:c4b,         default: cc.c4b(0,0,0,255)                    --描邊顏色
--              outLineSize:int,          default: 1                                    --描邊大小
--              glowEnable:boolean,       default: false                                --是否發光 （不建議開啟，渲染和排序位置有bug）
--              glowColor:c4b,            default: cc.c4b(0,0,0,255)                    --發光顏色
--              shadowEnable:boolean,     default: false                                --是否有陰影
--              shadowColor:c4b,          default: cc.c4b(0,0,0,255)                    --陰影顏色（有bug）
--              shadowOffset:size,        default: cc.size(2,-2)                        --陰影偏移位置
--              shadowBlurRadius:int,     default: 0                                    --陰影模糊半徑
--              deleteLineEnable:boolean, default: false                                --是否有刪除線
--              deleteLineColor:c4b,      default: cc.c4b(0,0,0,255)                    --刪除線顏色
--              deleteLineSize:int,       default: 1                                    --刪除線大小
--            
-- img param:   type:string,              default: "image"                              --類型
--              filePath:string,          defalut: ""                                   --圖片路徑
--              textureType:string,       defalut: 0                                    --紋理類型 0/1相對於local/plist
--            
-- node param:  type:string,              default: "node"                               --類型
--              customNode:cc.Node,       default: nil                                  --自定義node
--
--bmfont param: type:string,              default: "bmfont"                             --類型
--              text:String,              default: ""                                   --文本
--              fntFile:String,           default: ""                                   --位圖字體fnt文件
--
--blank param:  type:string,              default: "blank"                              --類型
--              blankSize,                default: 10                                   --段落間隔
--
--通用公共參數: 
--              color:c3b,                default: cc.c3b(255,255,255)                  --附加顏色
--              opacity:byte,             default: 255                                  --透明度0-255
--              verticalAlign:string,     default: "bottom"                             --垂直排列方式 top/middle/bottom
--              blink:boolean,            default: false                                --是否閃爍
--              blinkInterval:number,     default: 1                                    --閃爍間隔時間
--              touchCallBack:Function,   defalut: nil                                  --點擊事件響應函數
--
------------------------------------------------------------------------------------------------------------------------------
--RichText封裝的方法
--addElement   參數:一個table 返回:一個Element
--
------------------------------------------------------------------------------------------------------------------------------
--
-- 父類cp.CpRichText 所擁有方法
--create
--insertElement
--pushBackElement
--removeElement
--removeAllElement
--setAnchorPoint
--ignoreContentAdaptWithSize
--setLineGap
--formatText    --立即刷新文本，改變文本內容之類的，如果立馬要獲取高寬什麼的，需要調用此函數立即刷新，否則下一幀才會刷新
--setHAlign  cc.TEXT_ALIGNMENT_LEFT/cc.TEXT_ALIGNMENT_RIGHT/cc.TEXT_ALIGNMENT_CENTER
--getHAlign 
--setVAlign cc.VERTICAL_TEXT_ALIGNMENT_TOP/cc.VERTICAL_TEXT_ALIGNMENT_CENTER/cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM
--getVAlign
--getTextSize
------------------------------------------------------------------------------------------------------------------------------
]====]

local RichText = class("RichText",function()return cp.CpRichText:create()end)

function RichText:create()
    local ret = RichText.new()
    return ret
end

function RichText:addElement(tb)
    local elmt = nil
    if tb["type"]=="ttf" then
        elmt = cp.CpRichElementText:create()
        if tb["text"] then
            elmt:setText(tb["text"])
        end
        if tb["fontName"] then
            elmt:setFontName(tb["fontName"])
        else
            elmt:setFontName("fonts/msyh.ttf")
        end
        if tb["fontSize"] then
            elmt:setFontSize(tb["fontSize"])
        end
        if tb["textColor"] then
            elmt:setTextColor(tb["textColor"])
        end
        if tb["underLineEnable"] then
            elmt:setUnderLineEnable(tb["underLineEnable"])
        end
        if tb["underLineColor"] then
            elmt:setUnderLineColor(tb["underLineColor"])
        end
        if tb["underLineSize"] then
            elmt:setUnderLineSize(tb["underLineSize"])
        end
        if tb["outLineEnable"] then
            elmt:setOutLineEnable(tb["outLineEnable"])
        end
        if tb["outLineColor"] then
            elmt:setOutLineColor(tb["outLineColor"])
			elmt:setOutLineEnable(true)
        end
        if tb["outLineSize"] then
            elmt:setOutLineSize(tb["outLineSize"])
        end
        if tb["glowEnable"] then
            elmt:setGlowEnable(tb["glowEnable"])
        end
        if tb["glowColor"] then
            elmt:setGlowColor(tb["glowColor"])
        end
        if tb["shadowEnable"] then
            elmt:setShadowEnable(tb["shadowEnable"])
        end
        if tb["shadowColor"] then
            elmt:setShadowColor(tb["shadowColor"])
        end
        if tb["shadowOffset"] then
            elmt:setShadowOffset(tb["shadowOffset"])
        end
        if tb["shadowBlurRadius"] then
            elmt:setShadowBlurRadius(tb["shadowBlurRadius"])
        end
        if tb["deleteLineEnable"] then
            elmt:setDeleteLineEnable(tb["deleteLineEnable"])
        end
        if tb["deleteLineColor"] then
            elmt:setDeleteLineColor(tb["deleteLineColor"])
        end
        if tb["deleteLineSize"] then
            elmt:setDeleteLineSize(tb["deleteLineSize"])
        end
        if not tb["verticalAlign"] then
            tb["verticalAlign"] = "middle"
        end
    elseif tb["type"]=="image" then
        elmt = cp.CpRichElementImage:create()
        if tb["filePath"] then
            elmt:setFilePath(tb["filePath"])
        end
        if tb["textureType"] then
            elmt:setTextureType(tb["textureType"])
        end
		if tb["scale"] then
            elmt:setImageScale(tb["scale"])
        end
        if not tb["verticalAlign"] then
            tb["verticalAlign"] = "bottom"
        end
    elseif tb["type"]=="node" then
        elmt = cp.CpRichElementCustomNode:create(tb["customNode"])
    elseif tb["type"]=="bmfont" then
        elmt = cp.CpRichElementBMFont:create()
        if tb["text"] then
            elmt:setText(tb["text"])
        end
        if tb["fntFile"] then
            elmt:setFntFile(tb["fntFile"])
        end
    elseif tb["type"]=="blank" then
        elmt = cp.CpRichElementBlank:create()
        if tb["blankSize"] then
            elmt:setBlankSize(tb["blankSize"])
        end
    end
    
    if elmt then
        if tb["color"] then
            elmt:setColor(tb["color"])
        end
        if tb["opacity"] then
            elmt:setOpacity(tb["opacity"])
        end
        if tb["verticalAlign"] then
            elmt:setVerticalAlign(tb["verticalAlign"])
        end
        if tb["blink"] then
            elmt:setBlink(tb["blink"])
        end
        if tb["blinkInterval"] then
            elmt:setBlinkInterval(tb["blinkInterval"])
        end
        if tb["touchCallBack"] then
            elmt:setTouchCallBack(tb["touchCallBack"])
        end
        cp.CpRichText.pushBackElement(self,elmt)
    end
    return elmt
end


function RichText:setLineGap(num)
    cp.CpRichText.setLineGap(self,num)
end

return RichText