--顯示離線歷練的獎勵，以及快速歷練的獎勵
local BNode = require "cp.view.ui.base.BNode"
local LilianResultLayer = class("LilianResultLayer",BNode)

function LilianResultLayer:create(openInfo)
	local node = LilianResultLayer.new(openInfo)
	return node
end

function LilianResultLayer:initListEvent()
	self.listListeners = {
        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
            if evt.classname == "LilianResultLayer" then
                if evt.guide_name == "lilian" then
                    self:onUIButtonClick(self[evt.target_name])
                end
            end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
            if evt.classname == "LilianResultLayer" then
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

function LilianResultLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_lilian/uicsb_lilian_offline.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_title.Text_title"] = {name = "Text_title"},
        ["Panel_root.Image_bg.Text_content"] = {name = "Text_content"},
        ["Panel_root.Image_bg.Text_value_1"] = {name = "Text_value_1"},
        ["Panel_root.Image_bg.Text_value_2"] = {name = "Text_value_2"},
        ["Panel_root.Image_bg.Text_value_3"] = {name = "Text_value_3"},
        ["Panel_root.Image_bg.Text_value_4"] = {name = "Text_value_4"},

        ["Panel_root.Image_bg.Text_item_1"] = {name = "Text_item_1"},
        ["Panel_root.Image_bg.Text_item_2"] = {name = "Text_item_2"},
        ["Panel_root.Image_bg.Text_item_3"] = {name = "Text_item_3"},
        ["Panel_root.Image_bg.Text_item_4"] = {name = "Text_item_4"},
        ["Panel_root.Image_bg.Text_tips"] = {name = "Text_tips"},

        ["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK",click = "onUIButtonClick"},
        ["Panel_root.Image_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self:setPosition(display.cx,display.cy)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy))

end

function LilianResultLayer:createRichText(contentTable)
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
	
    richText:setContentSize(cc.size(440,85))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    local posx,posy = self.Text_content:getPosition()
    richText:setPosition(cc.p(posx,posy))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    richText:setLineGap(2)
    return richText

end

function LilianResultLayer:onEnterScene()
    self.Text_title:setString(self.openInfo.title)
    -- self.Text_content:setString(self.openInfo.content)

    self["Text_content"]:setVisible(false)
    -- local posX,posY = self["Text_content"]:getPosition()
    -- local sz = self["Text_content"]:getContentSize()
    local richText = self:createRichText(self.openInfo.content)
    -- richText:setPosition(cc.p(posX,posY))
    self["Image_bg"]:addChild(richText,1)
   
    self.Text_value_1:setString(tostring(self.openInfo.info.trainPoint))
    self.Text_value_2:setString(tostring(self.openInfo.info.silver))
    self.Text_value_3:setString(tostring(self.openInfo.info.conductGood))
    self.Text_value_4:setString(tostring(self.openInfo.info.conductBad))

    
    local selectedState = cp.getManager("GDataManager"):getAutoSellState()
    self.Text_tips:setVisible(selectedState[1] == 1 or selectedState[2] == 1 or selectedState[3] == 1 or selectedState[4] == 1)

    self.Text_item_1:setString("白色裝備 x" .. tostring(self.openInfo.info.itemNum[1]) .. (selectedState[1] == 1 and " (已自動出售)" or ""))
    self.Text_item_2:setString("綠色裝備 x" .. tostring(self.openInfo.info.itemNum[2]) .. (selectedState[2] == 1 and " (已自動出售)" or ""))
    self.Text_item_3:setString("藍色裝備 x" .. tostring(self.openInfo.info.itemNum[3]) .. (selectedState[3] == 1 and " (已自動出售)" or ""))
    self.Text_item_4:setString("紫色裝備 x" .. tostring(self.openInfo.info.itemNum[4]) .. (selectedState[4] == 1 and " (已自動出售)" or ""))

    self:onNewGuideStory()

    cp.getUserData("UserLilian"):setValue("fast_result_list",{})
    cp.getUserData("UserLilian"):setValue("offline_result_list",{})
    
end

function LilianResultLayer:onNewGuideStory()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lilian" then
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        if cur_step == 6 then
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

function LilianResultLayer:onUIButtonClick(sender)
    if self.callBack then
        self.callBack()
    end
    self:removeFromParent()
end

function LilianResultLayer:setCloseCallBack(cb)
    self.callBack = cb
end

return LilianResultLayer
