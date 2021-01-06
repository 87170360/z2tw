
local BNode = require "cp.view.ui.base.BNode"
local MijingMainItem = class("MijingMainItem",BNode)

function MijingMainItem:create(openInfo)
	local node = MijingMainItem.new(openInfo)
	return node
end

function MijingMainItem:initListEvent()
	self.listListeners = {
	}
end

function MijingMainItem:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_mijing/uicsb_mijing_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item", click = "onUIButtonClick", clickScale = 1},
        ["Panel_item.Image_icon"] = {name = "Image_icon"},
        ["Panel_item.Text_name"] = {name = "Text_name"},
        ["Panel_item.Text_fight_num"] = {name = "Text_fight_num"},
        ["Panel_item.Text_max_num"] = {name = "Text_max_num"},
        ["Panel_item.Text_descrip"] = {name = "Text_descrip"},

        ["Panel_item.Button_add"] = {name = "Button_add",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self.Panel_item:setTouchEnabled(true)

end


function MijingMainItem:onEnterScene()
   

    log("idx = " .. self.openInfo.id)
    
    local left_fight_times = 3
    local colorIndex = left_fight_times > 0 and 1 or 6  --白色或紅色
	self.Text_fight_num:setTextColor(cp.getConst("GameConst").QualityTextColor[colorIndex])
    self.Text_fight_num:setString(tostring(left_fight_times))

    local nameList = {"吉祥賭坊","弘武會館","雁翎山莊","離火劍冢","藏龍石窟","凌煙古塔"}
    self.Text_name:setString(nameList[self.openInfo.id])
    local descrip = {"可獲得大量銀兩","可獲得大量修為點","可獲得丹藥材料","可獲得武器碎片","可獲得礦石材料","可獲得武學突破材料"}
    self.Text_descrip:setString(descrip[self.openInfo.id])

    self.Text_max_num:setString("可挑戰次數:     /3")
    self.Image_icon:loadTexture("ui_mijing_module06_mijing_tubiao0" .. tostring(self.openInfo.id) .. ".png",ccui.TextureResType.plistType)

end

function MijingMainItem:refreshUI(mijingInfo)
    if mijingInfo ~= nil then
        local left_fight_times = mijingInfo.numLeft
        local colorIndex = left_fight_times > 0 and 1 or 6  --白色或紅色
        self.Text_fight_num:setTextColor(cp.getConst("GameConst").QualityTextColor[colorIndex])
        self.Text_fight_num:setString(tostring(left_fight_times))
        self.Text_max_num:setString("可挑戰次數:     /" .. tostring(mijingInfo.numMax))
    end
end

function MijingMainItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    
    if self.itemClickCallBack ~= nil then
        self.itemClickCallBack(self.openInfo, buttonName)
    end
end

function MijingMainItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return MijingMainItem
