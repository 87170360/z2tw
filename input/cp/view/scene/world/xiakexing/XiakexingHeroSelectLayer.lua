
local BLayer = require "cp.view.ui.base.BLayer"
local XiakexingHeroSelectLayer = class("XiakexingHeroSelectLayer",BLayer)

function XiakexingHeroSelectLayer:create(openInfo)
	local layer = XiakexingHeroSelectLayer.new(openInfo)
	return layer
end

function XiakexingHeroSelectLayer:initListEvent()
	self.listListeners = {
    
        [cp.getConst("EventConst").HeroStoryExtraRsp] = function(evt)
			self:updateBoxState(evt)
        end,
        
        [cp.getConst("EventConst").HeroStoryInfoRsp] = function(evt)
			self:updateAllState(evt)
        end,
        
	}
end

function XiakexingHeroSelectLayer:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_xkx/uicsb_xkx_hero_select.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_title_state"] = {name = "Image_title_state"},
        ["Panel_root.Image_title_state.Image_title"] = {name = "Image_title"},

        ["Panel_root.Panel_model"] = {name = "Panel_model"},
        
        ["Panel_root.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.ScrollView_1.Panel_content"] = {name = "Panel_content"},
        
        ["Panel_root.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.rootView:setContentSize(display.size)
    self.Panel_model:setVisible(false)
    self.ScrollView_1:setScrollBarEnabled(false)

    ccui.Helper:doLayout(self["rootView"])
    
end

function XiakexingHeroSelectLayer:onEnterScene()
    self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_view, false)
    local cfg = cp.getManager("ConfigManager").getItemByKey("HeroStory",self.openInfo.ID*1000)
    if cfg then
        local BgImg = cfg:getValue("BgImg")
        self.Panel_content:setBackGroundImage(BgImg,ccui.TextureResType.localType)
    end

    self.Panel_content:removeAllChildren()
    self.Anim = nil
    self.itemList = {}
    self.itemList = {}
    self.idList = cp.getManager("GDataManager"):getHeroStroyPartIDList(self.openInfo.ID)
    for i=1,table.nums(self.idList) do
        local item = self.Panel_model:clone()
        item:setVisible(true)
        self:initHeroInfo(item,i)
        self.itemList[i] = item
        -- item:setPosition(cc.p(250, 100 + i*200))
        self.Panel_content:addChild(item)
    end

    
    if display.height > 1200 then
        self.ScrollView_1:setTouchEnabled(true)
        self.ScrollView_1:jumpToPercentVertical(50)
    else
        local current = cp.getUserData("UserXiakexing"):getValue("current") 
        local idx = table.arrIndexOf(self.idList,current)
        idx = idx == -1 and table.nums(self.itemList) or idx
        local sz1 = self.ScrollView_1:getInnerContainerSize()
        local newPosX,newPosY = self.itemList[idx]:getPosition() 
        local scale = (sz1.height - newPosY)/sz1.height * 100
        self.ScrollView_1:jumpToPercentVertical(scale)
        self.ScrollView_1:setTouchEnabled(true)
    end
end

function XiakexingHeroSelectLayer:onExitScene()
   
end

function XiakexingHeroSelectLayer:createExtraBox(id,boxPos,award)
    local box_award_state_list = cp.getUserData("UserXiakexing"):getValue("box_award_state_list")
    local state = box_award_state_list[id] or 0 -- 0:未通過 1:已通過可領獎 2:已領獎
    if state == 2 then
        return
    end

    local img_file = "ui_xiakexing_module98__xkx_11.png"
    if state == 2 then
        img_file = "ui_xiakexing_module98__xkx_7.png"
        if self.Panel_content:getChildByName("Image_light_" .. tostring(id)) then
            self.Panel_content:removeChildByName("Image_light_" .. tostring(id))
        end
    end

    local pos = cc.p(360,300)
    local posStr = string.split(boxPos,"-")
    if posStr and posStr[1] and posStr[2] and tonumber(posStr[1]) and tonumber(posStr[2]) then
        pos = cc.p(tonumber(posStr[1]),tonumber(posStr[2]))
    end
    
    local Image_box = ccui.ImageView:create()
	Image_box:ignoreContentAdaptWithSize(true)
    Image_box:loadTexture(img_file, ccui.TextureResType.plistType)  
    self.Panel_content:addChild(Image_box,10)
    Image_box:setAnchorPoint(cc.p(0.5,0.5))
    Image_box:setPosition(pos)
    Image_box:setName("Image_box_" .. tostring(id) )
    Image_box:setTouchEnabled(true)
    Image_box:setAlphaTouchEnable(true)
    cp.getManager("ViewManager").initButton(Image_box, function()
        local box_award_state_list = cp.getUserData("UserXiakexing"):getValue("box_award_state_list")
        local newState = box_award_state_list[id] or 0
        if newState == 0 then
            cp.getManager("ViewManager").gameTip("還未通過此關卡,繼續加油吧！")  
        elseif newState == 1 then
            local req = {id=id}
            self:doSendSocket(cp.getConst("ProtoConst").HeroStoryExtraReq, req)
        elseif newState == 2 then
            cp.getManager("ViewManager").gameTip("獎勵已領取。") 
        end
    end)
    
    local current = cp.getUserData("UserXiakexing"):getValue("current")
    Image_box:setVisible(current >= id)	

    if state == 1 then
        local Image_light = ccui.ImageView:create()
        Image_light:loadTexture("ui_common_module33_qiandao_baoxiangshanguang.png", ccui.TextureResType.plistType)  
        self.Panel_content:addChild(Image_light,9)
        Image_light:setAnchorPoint(cc.p(0.5,0.5))
        Image_light:setPosition(pos)
        Image_light:setScale(1.5)
        Image_light:setName("Image_light_" .. tostring(id))

        local action = cc.RepeatForever:create(cc.RotateBy:create(6, 360))
        Image_light:runAction(action)
    end
end

function XiakexingHeroSelectLayer:initHeroInfo(parent,i)
   
    local current_id = self.idList[i]
    local cfg = cp.getManager("ConfigManager").getItemByKey("HeroStory",current_id)
    if cfg then
        --設置父節點座標
        local HeadPos = cfg:getValue("HeadPos")
        if HeadPos ~= "" then
            local posStr = string.split(HeadPos,"-")
            if posStr and posStr[1] and posStr[2] and tonumber(posStr[1]) and tonumber(posStr[2]) then
                local pos = cc.p(tonumber(posStr[1]),tonumber(posStr[2]))
                parent:setPosition(pos)
            end
        end
        local ExtraBoxPos = cfg:getValue("ExtraBoxPos") or ""
        local ExtraAward = cfg:getValue("ExtraAward") or ""
        ExtraBoxPos = string.trim(ExtraBoxPos)
        ExtraAward = string.trim(ExtraAward)
        if string.len(ExtraBoxPos) > 0 and string.len(ExtraAward) > 0 then
           self:createExtraBox(current_id, ExtraBoxPos,ExtraAward) 
        end
    end

    local current = cp.getUserData("UserXiakexing"):getValue("current")    
    -- local state = current > current_id and 1 or 0 --當前npc的狀態(1:已通過，0:未通過)
    parent:setVisible(current >= current_id)
    local Image_bg = parent:getChildByName("Image_bg")
    if current == current_id then
        Image_bg:loadTexture("ui_xiakexing_module98__xkx_6.png",ccui.TextureResType.plistType)
    else
        Image_bg:loadTexture("ui_xiakexing_module98__xkx_5.png",ccui.TextureResType.plistType)
    end

    local Image_head = parent:getChildByName("Image_head")
    local Text_name = parent:getChildByName("Text_name")
    local npcid = 0
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("HeroStory", self.idList[i])
    if cfgItem then
        npcid = cfgItem:getValue("NPC")
    end
    if npcid > 0 then
        local name,face = cp.getManager("GDataManager"):getGangNpcNameIcon(npcid,0,0)
        Image_head:loadTexture(face,ccui.TextureResType.localType)
        Text_name:setString(name)
    else
        Image_head:loadTexture("",ccui.TextureResType.localType)
        Text_name:setString("")
    end
    
    cp.getManager("ViewManager").initButton(parent, function()
        if self.closeCallBack then
            local info = {ID= current_id, npcid = npcid}
            self.closeCallBack("Image_head",info)
        end
    end)
    parent:setTouchEnabled(true)
    
    if current == current_id then
        self:createFightAnimation(parent)
    end
end

function XiakexingHeroSelectLayer:updateBoxState(evt)
    if evt.id > 0 then
        local img = self.Panel_content:getChildByName("Image_box_" .. tostring(evt.id))
        if img then
            img:loadTexture("ui_xiakexing_module98__xkx_7.png", ccui.TextureResType.plistType)
        end
    end
end

function XiakexingHeroSelectLayer:onItemClicked(itemInfo)
    dump(itemInfo)
end

 
function XiakexingHeroSelectLayer:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if buttonName == "Button_close" then
        if self.closeCallBack then
            self.closeCallBack(buttonName)
        end
        self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_view, true)

        local info = {openState = "close"}
        self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_heroselect_view, info)
        
    end
end

function XiakexingHeroSelectLayer:setCloseCallBack(cb)
    self.closeCallBack = cb
end


function XiakexingHeroSelectLayer:createFightAnimation(parent)
    if self.Anim then
        self.Anim:removeFromParent()
        self.Anim = nil
    end
    local Anim = cp.getManager("ViewManager").createSpineEffect("zhanling_gj")
    Anim:setAnimation(0, "zhanling_gj", true)
    parent:addChild(Anim,4)
    Anim:setPosition( cc.p(parent:getContentSize().width/2,parent:getContentSize().height-60))
    self.Anim = Anim
end

function XiakexingHeroSelectLayer:updateAllState()
    for i=1,table.nums(self.idList) do 
        
        local current_id = self.idList[i]
        local current = cp.getUserData("UserXiakexing"):getValue("current")   
        self.itemList[i]:setVisible(current >= current_id) 
        local Image_bg = self.itemList[i]:getChildByName("Image_bg")
        if current == current_id then
            Image_bg:loadTexture("ui_xiakexing_module98__xkx_6.png",ccui.TextureResType.plistType)
        else
            Image_bg:loadTexture("ui_xiakexing_module98__xkx_5.png",ccui.TextureResType.plistType)
        end

        local img = self.Panel_content:getChildByName("Image_box_" .. tostring(current_id))
        if img then
            
            local box_award_state_list = cp.getUserData("UserXiakexing"):getValue("box_award_state_list")
            local state = box_award_state_list[current_id] or 0 -- 0:未通過 1:已通過可領獎 2:已領獎
            local img_file = "ui_xiakexing_module98__xkx_11.png"
            if state == 1 then
                img_file = "ui_xiakexing_module98__xkx_2.png"
            elseif state == 2 then
                img_file = "ui_xiakexing_module98__xkx_7.png"
            end
            img:loadTexture(img_file, ccui.TextureResType.plistType)
        end
    end

    
    if display.height <= 1200 then  
        local current = cp.getUserData("UserXiakexing"):getValue("current") 
        local idx = table.arrIndexOf(self.idList,current)
        idx = idx == -1 and table.nums(self.itemList) or idx
        local sz1 = self.ScrollView_1:getInnerContainerSize()
        local newPosX,newPosY = self.itemList[idx]:getPosition() 
        local scale = (sz1.height - newPosY)/sz1.height * 100
        self.ScrollView_1:jumpToPercentVertical(scale)
    end
end



return XiakexingHeroSelectLayer
