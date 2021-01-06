local BLayer = require "cp.view.ui.base.BLayer"
local MajorLeft = class("MajorLeft",BLayer)

function MajorLeft:create()
	local layer = MajorLeft.new()
	return layer
end

function MajorLeft:initListEvent()
	self.listListeners = {

        [cp.getConst("EventConst").GetMailListRsp] = function(data)
            self:checkNeedNoticeMail()
        end,
        [cp.getConst("EventConst").AddFriendNotifyRsp] = function(data)
            self:checkNeedNoticeFriend()
        end,
        [cp.getConst("EventConst").AgreeRequestRsp] = function(data)
            self:checkNeedNoticeFriend()
        end,
        [cp.getConst("EventConst").DispatchMailRsp] = function(data)
            self:checkNeedNoticeMail()
        end,

        [cp.getConst("EventConst").GetDailyTaskRsp] = function(data)	
            self:checkNeedNoticeDailyTask()
        end,
        [cp.getConst("EventConst").GetDailyPointRsp] = function(data)	
            self:checkNeedNoticeDailyTask()
        end,
        [cp.getConst("EventConst").GetDailyDataRsp] = function(data)	
            self:checkNeedNoticeDailyTask()
        end,
        
        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "MajorLeft" then
				if evt.guide_name == "mail" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MajorLeft" then
				if evt.guide_name == "mail" then
					self:onUIButtonClick(self[evt.target_name])
				end
			end
        end,
        
	}
end

function MajorLeft:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_left.csb") 
	self:addChild(self.rootView)

	local childConfig = {
    ["Panel_click"] = {name = "Panel_click"},
    ["Panel_click.Button_click"] = {name = "Button_click",click = "onUIButtonClick"}, 
    ["Panel_click.Panel_left"] = {name = "Panel_left"},
    ["Panel_click.Panel_left.Panel_move"] = {name = "Panel_move"},
    ["Panel_click.Panel_left.Panel_move.Image_bg"] = {name = "Image_bg"},
    
    ["Panel_click.Panel_left.Panel_move.ScrollView_1"] = {name = "ScrollView_1"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content"] = {name = "Panel_content"},
    
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_SheZhi"] = {name = "Button_SheZhi",click = "onUIButtonClick"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_XinZha"] = {name = "Button_XinZha",click = "onUIButtonClick"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_ChongZhi"] = {name = "Button_ChongZhi",click = "onUIButtonClick"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_HaoYou"] = {name = "Button_HaoYou",click = "onUIButtonClick"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_TuJian"] = {name = "Button_TuJian",click = "onUIButtonClick"},
    ["Panel_click.Panel_left.Panel_move.ScrollView_1.Panel_content.Button_RiChang"] = {name = "Button_RiChang",click = "onUIButtonClick"},
    
    
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self.rootView:setContentSize(display.size)
    local csbSize = cc.size(720,1280)
    cp.getManager("ViewManager").adapterCSNode(self["Panel_click"] , csbSize, display.left_top)


    local sz = self.Panel_content:getContentSize()
    self["ScrollView_1"]:setInnerContainerSize(cc.size(sz.width, sz.height))

    local scroll_height = 680
    if display.height > 1080 then
        scroll_height = 680
    elseif display.height > 960 then
        scroll_height = 650
    else -- 960
        scroll_height = 530
    end
    local scrollViewSize = self["ScrollView_1"]:getContentSize()
    self.Panel_left:setContentSize(cc.size(scrollViewSize.width, scroll_height+50)) 

    self["ScrollView_1"]:setContentSize(cc.size(scrollViewSize.width, scroll_height))
    self["ScrollView_1"]:setPositionY(scroll_height+40)
    self["ScrollView_1"]:setTouchEnabled(scroll_height < 650)

    ccui.Helper:doLayout(self.rootView)

    self.panel_move_up = false
end

function MajorLeft:onUIButtonClick(sender)
  local buttonName = sender:getName()
  log("click button : " .. buttonName)

  if "Button_click"  == buttonName then

	local posX, posY = self.Panel_move:getPosition()
	local height = self.Panel_move:getContentSize().height
	if self.panel_move_up then
		height = -height
		self["Button_click"]:loadTextures("ui_major_left_module04_main_shousuo01_a.png", "ui_major_left_module04_main_shousuo01_b.png", "ui_major_left_module04_main_shousuo01_b.png", ccui.TextureResType.plistType)
	else
		self["Button_click"]:loadTextures("ui_major_left_module04_main_shousuo02_a.png", "ui_major_left_module04_main_shousuo02_b.png", "ui_major_left_module04_main_shousuo02_b.png", ccui.TextureResType.plistType)
	end
	self.panel_move_up = not self.panel_move_up

  	local act1 = cc.MoveTo:create(0.2, cc.p(posX, posY + height))
    local act2 = cc.EaseSineOut:create(act1)
    self.Panel_move:runAction(act2)


    elseif "Button_SheZhi"  == buttonName then
        local GameSettingsUI = require("cp.view.scene.world.major.GameSettingsUI"):create()
        self:addChild(GameSettingsUI)
        self.GameSettingsUI = GameSettingsUI
        GameSettingsUI:setCloseCallBack(function()
            self.GameSettingsUI:removeFromParent()
            self.GameSettingsUI = nil
            
            LUA_LOG.flush()
            LUA_LOG.close()
            local filePath = cc.FileUtils:getInstance():getWritablePath()..LUA_LOG.LOG_FILE
            LUA_LOG.LogHandler =  assert(io.open(filePath,"r"),"file not found.")
            if LUA_LOG.LogHandler then
                local len = assert(LUA_LOG.LogHandler:seek("end"))
                if len > 0 then
                    cp.getManager("HotUpManager"):sendHttpRequest()

                    self.Panel_click:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                        
                        log("log file path = " .. filePath)
                        if LUA_LOG.LogHandler then
                            LUA_LOG.close()
                        end
                        LUA_LOG.LogHandler =  assert(io.open(filePath,"w+"),"file not found.") --清除保存的數據
                        LUA_LOG.close()
                        LUA_LOG.resetCache()
                    end)))
                end
            end
        end)
    elseif "Button_XinZha"  == buttonName then
        self:dispatchViewEvent(cp.getConst("EventConst").open_mail_view,true)
    elseif "Button_ChongZhi"  == buttonName then
        cp.getManager("ViewManager").showRechargeUI()
    elseif "Button_HaoYou"  == buttonName then
        self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,true)
    elseif "Button_TuJian" == buttonName then
        local open_info = {name = cp.getConst("SceneConst").MODULE_SkillMap}
        self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_open_module, {open_info = open_info})
    elseif "Button_RiChang" == buttonName then
        local state = cp.getManager("GDataManager"):procFeatureState(6, self)
        if state == -1 or state == 0 then
            return
        end
        self:dispatchViewEvent(cp.getConst("EventConst").open_daily_task,true)
    end
end

function MajorLeft:onEnterScene()
    self:checkNeedNotice()
    self:delayNewGuide(0.3)
end

function MajorLeft:checkNeedNotice()
    self:checkNeedNoticeMail()
    self:checkNeedNoticeFriend()
    self:checkNeedNoticeDailyTask()
end

function MajorLeft:checkNeedNoticeDailyTask()
    if cp.getUtils("NotifyUtils").needNotifyDailyTask() then
        cp.getManager("ViewManager").addRedDot(self.Button_RiChang,cc.p(90,80))
    else
		cp.getManager("ViewManager").removeRedDot(self.Button_RiChang)
    end
end


function MajorLeft:checkNeedNoticeMail()
    if cp.getUtils("NotifyUtils").needNotifyMail() then
        cp.getManager("ViewManager").addRedDot(self.Button_XinZha,cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Button_XinZha)
    end
end

function MajorLeft:checkNeedNoticeFriend()
    if cp.getUtils("NotifyUtils").needNotifyFriend() then
        cp.getManager("ViewManager").addRedDot(self.Button_HaoYou,cc.p(90,90))
    else
		cp.getManager("ViewManager").removeRedDot(self.Button_HaoYou)
    end
end



function MajorLeft:delayNewGuide(delayTime)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "mail" then
        if delayTime > 0 then
            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(delayTime))
            table.insert(sequence,cc.CallFunc:create(function()
                -- local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
                local info = 
                {
                    classname = "MajorLeft",
                }
                self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
            end))
            self:runAction(cc.Sequence:create(sequence))
        else
            local info = 
            {
                classname = "MajorLeft",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end
    end
end

return MajorLeft
