
local BLayer = require "cp.view.ui.base.BLayer"
local ExpressLootNotice = class("ExpressLootNotice",BLayer)

function ExpressLootNotice:create(openInfo)
    local layer = ExpressLootNotice.new(openInfo)
    return layer
end

function ExpressLootNotice:initListEvent()
    self.listListeners = {
    }

end

function ExpressLootNotice:onInitView(openInfo)

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_express/uicsb_express_notice.csb") 
    self.rootView:setContentSize(display.size)
    self:addChild(self.rootView)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		
		["Panel_root.Image_bg.Image_title.ScrollView_1"] = {name = "ScrollView_1" },
		["Panel_root.Image_bg.Image_title.Button_close"] = {name = "Button_close" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.Panel_root:setContentSize(display.size)
	-- cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(0,0),function()
	-- 	-- self:removeFromParent()
    -- end)
    
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_root)
end



function ExpressLootNotice:onEnterScene()
    self.ScrollView_1:removeAllChildren()

    local attacked_warning_info_list = cp.getUserData("UserVan"):getValue("attacked_warning_info_list")

    -- for i=1,10 do
    --     attacked_warning_info_list[i] = {}
    --     attacked_warning_info_list[i].uuid = tostring(i)
    --     attacked_warning_info_list[i].combatID = tostring(i)
    --     local success = true
    --     if i%2==0 then
    --         success = false
    --     end
    --     attacked_warning_info_list[i].robInfo = {place= "風雨亭",name="伏擊ren"..tostring(i),stamp=1,success=success, face = "head_1015"}
    -- end

    local num = table.nums(attacked_warning_info_list)
    local sz = self.ScrollView_1:getContentSize()
    local height = num*195 --195為ExpressLootNoticeItem的寬高
    height = math.max(height,sz.height)
    self.ScrollView_1:setInnerContainerSize(cc.size(sz.width,height))
    
    for i=1,num do
        local attackedInfo = attacked_warning_info_list[i]

        -- local item = self.Panel_model:clone()
        local item = require("cp.view.scene.world.express.ExpressLootNoticeItem"):create()
        item:setVisible(true)
        self.ScrollView_1:addChild(item)
        item:setPosition(cc.p(0,height-(i)*195))
        item:setItemClickCallBack(handler(self,self.onItemClicked))
        item:reset(attackedInfo)
    end
    
    self.ScrollView_1:jumpToTop()
    ccui.Helper:doLayout(self["rootView"])
    
end

function ExpressLootNotice:createRichText(contentTable)
	
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(400,80))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(231,120))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
    richText:setLineGap(2)
    return richText

end

function ExpressLootNotice:onExitScene()
   
end

function ExpressLootNotice:onItemClicked(noticeInfo,name)
    if "Button_review" == name then
        -- local attacked_warning_info_list = cp.getUserData("UserVan"):getValue("attacked_warning_info_list")
        -- for i,info in pairs(attacked_warning_info_list) do
        --     if info.uuid == noticeInfo.uuid then
        --         table.remove(attacked_warning_info_list,i)
        --         break
        --     end
        -- end
        local combatID = noticeInfo.type == "BeRobVan" and noticeInfo.combatID or noticeInfo.battleID
        self:onViewBeRobVanFight(combatID)
    elseif "Image_head_icon" == name then
    
        local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
        local req = {}
        req.roleID = noticeInfo.type == "BeRobVan" and noticeInfo.robInfo.roleid or 0 
    
        req.uid = noticeInfo.type == "BeRobVan" and noticeInfo.robInfo.uid or noticeInfo.UID
        req.zoneID = serverinfo.id
        self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
        
    end
end


function ExpressLootNotice:onViewBeRobVanFight(combatID)
    if combatID > 0 then
        cp.getUserData("UserCombat"):setValue("review_type",1)
        cp.getUserData("UserCombat"):setValue("review_combatID",combatID)
        local req = {}
        req.combat_id = combatID
        req.side = 0 --1是防守方 0是攻擊方
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
    end
end

function ExpressLootNotice:onCloseButtonClick(sender)
    --關閉時，清空數據
    cp.getUserData("UserVan"):setValue("attacked_warning_info_list",{})
    if self.callback then
        self.callback()
    end
    self:removeFromParent()
    
end

function ExpressLootNotice:setCloseCallBack(callback)
    self.callback = callback
end

return ExpressLootNotice
