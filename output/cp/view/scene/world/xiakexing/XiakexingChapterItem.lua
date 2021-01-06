
local BNode = require "cp.view.ui.base.BNode"
local XiakexingChapterItem = class("XiakexingChapterItem",BNode)

function XiakexingChapterItem:create(openInfo)
	local node = XiakexingChapterItem.new(openInfo)
	return node
end

function XiakexingChapterItem:initListEvent()
	self.listListeners = {
	}
end

function XiakexingChapterItem:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_xkx/uicsb_xkx_chapter_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Image_lock"] = {name = "Image_lock"},
        ["Panel_item"] = {name = "Panel_item"},
        ["Panel_item.Image_icon"] = {name = "Image_icon", click = "onUIButtonClick",clickScale=1},
        ["Panel_item.Image_state"] = {name = "Image_state"},
        ["Panel_item.Image_title_state"] = {name = "Image_title_state"},
        ["Panel_item.Image_title"] = {name = "Image_title"},

        ["Panel_item.Node_primeval.Text_name"] = {name = "Text_name"},
        ["Panel_item.Node_primeval.Image_color"] = {name = "Image_color"},
        ["Panel_item.Node_primeval.Image_primeval"] = {name = "Image_primeval",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
    self.Image_icon:setSwallowTouches(false)
    self.Panel_item:setTouchEnabled(false)

    self.open_state = 0
end


function XiakexingChapterItem:onEnterScene()
    

    log("ID = " .. self.openInfo.ID)
    self.idList = cp.getManager("GDataManager"):getHeroStroyPartIDList(self.openInfo.ID)

    local PrimevalID = self.openInfo.PrimevalID
    local cfg = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", tonumber(PrimevalID))
    if cfg then
        self.Text_name:setString(cfg:getValue("Name"))
        self.Image_primeval:loadTexture(cfg:getValue("Icon"),ccui.TextureResType.localType)
    else
        self.Text_name:setString("無")
        self.Image_primeval:loadTexture("")
    end

    self.Image_title:loadTexture(self.openInfo.Name,ccui.TextureResType.plistType)
    self.Image_icon:loadTexture(self.openInfo.BgIcon,ccui.TextureResType.localType)
end

function XiakexingChapterItem:resetState()
    local result,canGetBoxReward = cp.getManager("GDataManager"):getHeroStroyChapterState(self.idList)
    if result == 0 then
        --判斷前一章是否全通關，通關後開啟本章節
        if self.openInfo.ID <= 1 then
            result = 1
        else
            local idList = cp.getManager("GDataManager"):getHeroStroyPartIDList(self.openInfo.ID-1)
            local result1,_ = cp.getManager("GDataManager"):getHeroStroyChapterState(idList)
            if result1 >= 2 then
                result = 1
            end
        end
    end
    self.Image_lock:setVisible(result == 0)
    self.Image_state:setVisible(result > 0)
    self.open_state = result 
    if result == 0 then --0鎖住，1已開啟未通關，2已全部通關
        self.Image_title_state:loadTexture("ui_xiakexing_module98__xkx_9.png",ccui.TextureResType.plistType)
        cp.getManager("ViewManager").setShader(self.Panel_item,cp.getConst("ShaderConst").GrayShader)
    else
        local file = result == 1 and "ui_xiakexing_module98__xkx_10.png" or "ui_xiakexing_module98__xkx_3.png"
        self.Image_state:loadTexture(file,ccui.TextureResType.plistType)

        local file2 = result == 1 and "ui_xiakexing_module98__xkx_4.png" or "ui_xiakexing_module98__xkx_8.png"
        self.Image_title_state:loadTexture(file2,ccui.TextureResType.plistType)
        cp.getManager("ViewManager").setShader(self.Panel_item,nil)
    end
end

function XiakexingChapterItem:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    
    if buttonName == "Image_primeval" then
        if self.itemClickCallBack ~= nil then
            self.itemClickCallBack(self.openInfo,buttonName)
        end
    elseif buttonName == "Image_icon" then
        local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
        if distance < 30 then
            if self.open_state == 0 then
                cp.getManager("ViewManager").gameTip("尚未解鎖，請先通關前面關卡。")
                return
            end
            if self.itemClickCallBack ~= nil then
                self.itemClickCallBack(self.openInfo,buttonName)
            end  
        end
    end
end

function XiakexingChapterItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return XiakexingChapterItem
