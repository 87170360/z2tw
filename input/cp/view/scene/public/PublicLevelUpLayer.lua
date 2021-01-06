local BNode = require "cp.view.ui.base.BNode"
local PublicLevelUpLayer = class("PublicLevelUpLayer", BNode)
function PublicLevelUpLayer:create(openInfo)
    -- local openInfo = {oldLevel = oldLevel, newLevel = newLevel, closeCallBack = closeCallBack}
    local node = PublicLevelUpLayer.new(openInfo)
    return node
end

function PublicLevelUpLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function PublicLevelUpLayer:onInitView(openInfo)
    self.openInfo = openInfo
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_levelup.csb")
    self.rootView:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.rootView)

	--local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_item"] = {name = "Panel_item"},
        ["Panel_root.Panel_item.Image_LevelUp"] = {name = "Image_LevelUp"},
		["Panel_root.Panel_item.Button_LevelUpOK"] = {name = "Button_LevelUpOK", click="onBtnClick"},
		["Panel_root.Panel_item.Panel_unlock"] = {name = "Panel_unlock"},
        ["Panel_root.Panel_item.Panel_unlock.Text_no_unlock"] = {name = "Text_no_unlock"},
        ["Panel_root.Panel_item.Text_des"] = {name = "Text_des"},
		["Panel_root.Panel_item.Image_Defence.Text_Defence"] = {name = "Text_Defence"},
		["Panel_root.Panel_item.Image_Attack.Text_Attack"] = {name = "Text_Attack"},
		["Panel_root.Panel_item.Image_Force.Text_Force"] = {name = "Text_Force"},
		["Panel_root.Panel_item.Image_Life.Text_Life"] = {name = "Text_Life"},
		["Panel_root.Panel_item.Image_Qi.Text_Qi"] = {name = "Text_Qi"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)

    self.Panel_root:onTouch(function(event)
        if event.name == "ended" then
            if self.openInfo.closeCallBack then
                self.openInfo.closeCallBack()
            end
            cp.getManager("PopupManager"):removePopup(self)
        end
    end)


    self.unlock_info_list = cp.getManager("GDataManager"):getUnlockInfoList()

end

function PublicLevelUpLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_LevelUpOK" then
        if self.openInfo.closeCallBack then
            self.openInfo.closeCallBack()
        end
        cp.getManager("PopupManager"):removePopup(self)
		cp.getManager("GDataManager"):showFightBuff()
	end
end

-- function PublicLevelUpLayer:setcloseCallBack(callback)
--     self.closeCallBack = callback
-- end

function PublicLevelUpLayer:showView()
    
	local oldRoleAttr = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", self.openInfo.oldLevel)
	local newRoleAttr = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", self.openInfo.newLevel)
    self.Text_Defence:setString("+" .. tostring(newRoleAttr:getValue("Defend")-oldRoleAttr:getValue("Defend")))
    self.Text_Attack:setString("+" .. tostring(newRoleAttr:getValue("Attack")-oldRoleAttr:getValue("Attack")))
    self.Text_Force:setString("+" .. tostring(newRoleAttr:getValue("MP")-oldRoleAttr:getValue("MP")))
    self.Text_Life:setString("+" .. tostring(newRoleAttr:getValue("HP")-oldRoleAttr:getValue("HP")))
    self.Text_Qi:setString("+" .. tostring(newRoleAttr:getValue("Energy")-oldRoleAttr:getValue("Energy")))
    self.Text_des:setString(newRoleAttr:getValue("Realm"))
    cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_level_up)

    cp.getManager("ViewManager").popUpView(self.Panel_root)

    local newLv = self.openInfo.newLevel
    local unLockList = {}
    for id,info in pairs(self.unlock_info_list) do
        if info.Level == newLv then
            table.insert(unLockList,info)
        end
    end

    local roleAttr = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", newLv)
    if roleAttr and roleAttr:getValue("Jinjie") == 1 then
        local info =  {ID=0,Level=newLv,Icon="ui_combat_finish_mpjj.png",Desc="門派進階"}
        table.insert(unLockList,info)
    end

    local num = table.nums(unLockList)
    if num > 0 then
        num = math.min(num,4)
        for i=1,num do
            local img_icon = self:addUnlockItem(unLockList[i])
            self.Panel_unlock:addChild(img_icon)
            if num==1 then
                img_icon:setPosition(cc.p(340,96))
            elseif num==2 then
                img_icon:setPosition(cc.p(i==1 and 210 or 475,96))
            elseif num==3 then
                img_icon:setPosition(cc.p(i*175-55 + 50*(i-1),96))
            elseif num==4 then
                img_icon:setPosition(cc.p(i*175-87,96))
            end
        end
        self.Text_no_unlock:setVisible(false)
    else
        self.Text_no_unlock:setVisible(true)
    end

end

function PublicLevelUpLayer:onEnterScene()   
    self:showView()
end

function PublicLevelUpLayer:onExitScene()

end

function PublicLevelUpLayer:addUnlockItem(unLockInfo)
    
    local Image_icon = ccui.ImageView:create()
    Image_icon:loadTexture(unLockInfo.Icon, ccui.TextureResType.plistType)
    Image_icon:setName("Image_icon")
    Image_icon:setAnchorPoint(cc.p(0.5,0.5))

    local Text_name = ccui.Text:create()
    Text_name:setText(unLockInfo.Desc)
    Text_name:setName("Text_name")
    Text_name:setFontName("fonts/msyh.ttf") 
    Text_name:setAnchorPoint(cc.p(0.5, 0.5))
    Text_name:setTextColor(cc.c3b(255, 255, 255))
    Text_name:setFontSize(20)
    Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    Text_name:setPosition(cc.p(97, 6))
    Image_icon:addChild(Text_name)
    
    return Image_icon
end

return PublicLevelUpLayer
