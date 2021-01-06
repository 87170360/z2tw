
local BNode = require "cp.view.ui.base.BNode"
local ExpressLootNoticeItem = class("ExpressLootNoticeItem",BNode)

function ExpressLootNoticeItem:create()
    local node = ExpressLootNoticeItem.new()
    return node
end

function ExpressLootNoticeItem:initListEvent()
    self.listListeners = {
        
    }
end

function ExpressLootNoticeItem:onInitView()

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_notice_item.csb") 
    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Image_head_icon"] = {name = "Image_head_icon",click = "onItemClick",clickScale=1},
        ["Panel_item.Panel_content"] = {name = "Panel_content"},
        ["Panel_item.Image_name_bg.Text_name"] = {name = "Text_name"},
        ["Panel_item.Button_review"] = {name = "Button_review",click = "onItemClick"},
    }
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

end

function ExpressLootNoticeItem:getContentSize()
    return self.Panel_item:getContentSize()
end

function ExpressLootNoticeItem:onEnterScene()

end

function ExpressLootNoticeItem:onExitScene()

end

function ExpressLootNoticeItem:reset(attackedInfo)
    self.openInfo = attackedInfo
    
    if attackedInfo ~= nil and next(attackedInfo) ~= nil then
        
        local content = {}
        local face = "head_1012"
        local name = ""
        local success = false

        local ContentTextColor = cp.getConst("GameConst").ContentTextColor
        local extraTextColor = cp.getConst("GameConst").QualityTextColor[2]
        local extraOutlineColor = cp.getConst("GameConst").QualityOutlineColor[2]


        if attackedInfo.type == "BeRobVan" then
            if attackedInfo.robInfo.face ~= nil then
                face = attackedInfo.robInfo.face or "head_1001"
            end
            name = attackedInfo.robInfo.name or " "
            
            local txt = "護鏢" .. (attackedInfo.robInfo.success and "失敗！" or "成功！")
            content = {
                {type="ttf", fontSize=24, text="在", textColor=ContentTextColor},
                {type="ttf", fontSize=24, text=attackedInfo.robInfo.place, textColor=extraTextColor, outLineColor=extraOutlineColor, outLineSize=2},
                {type="ttf", fontSize=24, text="被", textColor=ContentTextColor},
                {type="ttf", fontSize=24, text=attackedInfo.robInfo.name, textColor=extraTextColor, outLineColor=extraOutlineColor, outLineSize=2},
                {type="ttf", fontSize=24, text="伏擊，", textColor=ContentTextColor},
                {type="blank", blankSize=1 },
                {type="ttf", fontSize=24, text=txt, textColor=ContentTextColor},
            }
            
        else
            name = attackedInfo.Name or " "
            face = attackedInfo.face or "head_1001"
            local conductEventEntry = cp.getManager("ConfigManager").getItemByKey("GameConduct", attackedInfo.confId)
            local eventName = conductEventEntry:getValue("Name")

            local txt = (attackedInfo.success and "乘虛而入，" or "意圖滋事，")
            local txt1 = (attackedInfo.success and "任務失敗！" or "被你擊退。")
            local txt2 = attackedInfo.success and "被" or ""
            content = {
                {type="ttf", fontSize=24, text="在進行", textColor=ContentTextColor},
                {type="ttf", fontSize=24, text=eventName, textColor=extraTextColor, outLineColor=extraOutlineColor, outLineSize=2},
                {type="ttf", fontSize=24, text="時，" .. txt2, textColor=ContentTextColor},
                {type="ttf", fontSize=24, text=name, textColor=extraTextColor, outLineColor=extraOutlineColor, outLineSize=2},
                {type="ttf", fontSize=24, text=txt, textColor=ContentTextColor},
                {type="ttf", fontSize=24, text=txt1, textColor=ContentTextColor},
            }

        end
        
        self.Text_name:setString(name)
        self.Image_head_icon:loadTexture("img/model/head/" .. face .. ".png", UI_TEX_TYPE_LOCAL)
        
        self.Panel_content:removeAllChildren()
        local richText = self:createRichText(content)
        self.Panel_content:addChild(richText)
        

        self:setVisible(true)
    else
        self:setVisible(false)
    end

end


function ExpressLootNoticeItem:createRichText(contentTable)
	
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(340,60))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(170,30))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    richText:setLineGap(2)
    return richText

end

function ExpressLootNoticeItem:onItemClick(sender)
    if self.itemClickCallBack ~= nil then
        self.itemClickCallBack(self.openInfo,sender:getName())
    end
end

function ExpressLootNoticeItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return ExpressLootNoticeItem
