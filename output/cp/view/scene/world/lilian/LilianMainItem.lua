
local BNode = require "cp.view.ui.base.BNode"
local LilianMainItem = class("LilianMainItem",BNode)

function LilianMainItem:create(openInfo)
	local node = LilianMainItem.new(openInfo)
	return node
end

function LilianMainItem:initListEvent()
	self.listListeners = {
	}
end

function LilianMainItem:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_lilian/uicsb_lilian_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Panel_clip"] = {name = "Panel_clip"},
        ["Panel_item.Panel_clip.Image_icon"] = {name = "Image_icon"},
        ["Panel_item.Image_locked"] = {name = "Image_locked"},
        ["Panel_item.Button_name_bg"] = {name = "Button_name_bg",click = "onUIButtonClick",clickScale=1},
        ["Panel_item.Button_name_bg.Image_name"] = {name = "Image_name"},
        ["Panel_item.Image_huodong"] = {name = "Image_huodong"},
        ["Panel_item.Text_descrip"] = {name = "Text_descrip"},
        ["Panel_item.Text_notice"] = {name = "Text_notice"},
        ["Panel_item.Button_view_drop"] = {name = "Button_view_drop",click = "onUIButtonClick"},
        ["Panel_item.Button_enter"] = {name = "Button_enter",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    self.Panel_item:setTouchEnabled(true)

    local function onTouch(sender, event)
		if event == cc.EventCode.BEGAN then
 
        elseif event == cc.EventCode.MOVED then 

        elseif event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self.Panel_item:setSwallowTouches(true)
                if self.itemClickCallBack ~= nil then
                    self.itemClickCallBack(self.openInfo, "Panel_item")
                end
            else
                self.Panel_item:setSwallowTouches(false)
            end
        elseif event == cc.EventCode.CANCELLED then
  
        end
	end
    self.Panel_item:addTouchEventListener(onTouch)

end

function LilianMainItem:onEnterScene()
   
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local exerciseId = major_roleAtt.exerciseId
    local hierarchy = major_roleAtt.hierarchy
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",self.openInfo.id)
    if cfg ~= nil then
        local cfgHierarchy = cfg:getValue("Hierarchy")
        local items = cfg:getValue("Items")
        local name = cfg:getValue("Name")
        local name_pic = cfg:getValue("NamePic")
        local icon = cfg:getValue("Icon")

        if items ~= "" then
            local itemsTb = string.split(items,"|")
            self.openInfo.items = {}
            for i=1, table.nums(itemsTb) do
                table.insert(self.openInfo.items,tonumber(itemsTb[i]))
            end
        end 
        self.openInfo.name = name
        local isLocked = cfgHierarchy > hierarchy
        self.Image_locked:setVisible(isLocked)
        local shaderName = isLocked and cp.getConst("ShaderConst").GrayShader or nil
        cp.getManager("ViewManager").setShader(self.Image_icon,shaderName)
        local txt = {"一","二","三","四","五","六"}
        self.Text_descrip:setString("達到" .. txt[cfgHierarchy] .. "階可進入")

        if exerciseId > 0 and exerciseId == self.openInfo.id then
            self.Text_notice:setVisible(true)
            self.Text_descrip:setVisible(false)
        else
            self.Text_notice:setVisible(false)
            self.Text_descrip:setVisible(true)
        end
        self.Image_name:loadTexture(name_pic,ccui.TextureResType.plistType)
        self.Image_icon:loadTexture(icon,ccui.TextureResType.plistType)

        local isInActive = cp.getManager("GDataManager"):isLiLianInActivityTime(self.openInfo.id)
        self.Image_huodong:setVisible(isInActive)
    end
end

function LilianMainItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    --if buttonName == "Button_view_drop" then
        -- --查看掉落
        -- if self.openInfo.items ~= nil and table.nums(self.openInfo.items) > 0 then
            -- --彈出掉落顯示
        -- end
    
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self.openInfo, buttonName)
	end
end

function LilianMainItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return LilianMainItem
