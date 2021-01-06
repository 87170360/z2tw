local BLayer = require "cp.view.ui.base.BLayer"
local MajorDown = class("MajorDown",BLayer)

function MajorDown:create()
	local layer = MajorDown.new()
	return layer
end

function MajorDown:initListEvent()
	self.listListeners = {
	
		-- --更新虛擬貨幣
		 [cp.getConst("EventConst").UpdateCurrencyRsp] = function(evt)
		 	self:refreshExp()
		 end,
	  
		[cp.getConst("EventConst").onRoleLevelChange] = function(evt)
			self:checkNeedNotice()
		end,

		[cp.getConst("EventConst").lilian_open] = function(evt)
			self:refreshNew()
		end,

		--更新人物全屬性
		[cp.getConst("EventConst").GetRoleRsp] = function(evt)
			self:onEnterScene()
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			
			if evt.classname == "MajorDown" then
				if evt.guide_name == "menpai_wuxue" or 
					evt.guide_name == "wuxue" or 
					evt.guide_name == "story" or 
					evt.guide_name == "character" or 
					evt.guide_name == "lottery" or 
					evt.guide_name == "wuxue_use" or
					evt.guide_name == "wuxue_pos_change" or
					evt.guide_name == "mail" or
					evt.guide_name == "lilian" or
					evt.guide_name == "equip" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
					--此步指引為向右的手指,-- Button_MenPai處的指引為menpai_wuxue指引的第3步，故索引設置為3，方便後面調用
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MajorDown" then
				if evt.guide_name == "menpai_wuxue" or 
					evt.guide_name == "wuxue" or 
					evt.guide_name == "story" or 
					evt.guide_name == "character" or 
					evt.guide_name == "lottery" or 
					evt.guide_name == "wuxue_use" or 
					evt.guide_name == "wuxue_pos_change" or
					evt.guide_name == "mail" or
					evt.guide_name == "lilian" or
					evt.guide_name == "equip" then
					self:onUIButtonClick(self[evt.target_name])
					
				end
			end
		end,

		--模擬點擊按鍵(非指引)
		[cp.getConst("EventConst").click_view_button] = function(evt)
			if evt.classname == "MajorDown" then
				if self[evt.button_name] then
					self:onUIButtonClick(self[evt.button_name])
				end	
			end
		end,

		--刷新紅點
		[cp.getConst("EventConst").LearnSkillRsp] = function(evt)
			local showSkill = cp.getUserData("UserSkill"):showSkillRedPoint()
			if showSkill then
				cp.getManager("ViewManager").addRedDot(self.Button_WuXue,cc.p(85,85))
			else
				cp.getManager("ViewManager").removeRedDot(self.Button_WuXue)
			end
		end,

		--刷新紅點
		[cp.getConst("EventConst").refreshRedPoint] = function(evt)
			if evt.type == nil or evt.type == "" then
				self:checkNeedNotice()
			else
				if evt.type == "menpai" then
					local totalNum = 0
					local needNotice = cp.getManager("GDataManager"):checkMenPaiRedPoint()
					for i=1,6 do
						totalNum = totalNum + needNotice[i]
					end
					if totalNum > 0 then
						local fileName = needNotice[4] == 1 and "ui_common_jinjie.png" or nil
						cp.getManager("ViewManager").addRedDot(self.Button_MenPai,cc.p(85,85),fileName)
					else
						cp.getManager("ViewManager").removeRedDot(self.Button_MenPai)
					end
				end
			end
		end,
		[cp.getConst("EventConst").SignUpMountainRsp] = function()
			self:checkNeedNotifyMountain()
		end,
		
		[cp.getConst("EventConst").GetAllSkillRsp] = function(data)
			local totalNum = 0
			local packageNeedRedPoint = cp.getUserData("UserItem"):checkPackageItemCanOperate()
			for i=1,#packageNeedRedPoint do
				totalNum = totalNum + packageNeedRedPoint[i]
			end
			if totalNum > 0 then
				local fileName = packageNeedRedPoint[2] == 1 and "ui_common_shu.png" or nil
				cp.getManager("ViewManager").addRedDot(self.Button_BeiBao,cc.p(85,85),fileName)
			else
				cp.getManager("ViewManager").removeRedDot(self.Button_BeiBao)
			end
		end,

        [cp.getConst("EventConst").FeatureRsp] = function(data)
			self:refreshNew()
        end,
	}
end

function MajorDown:checkNeedNotifyMountain()
	if cp.getUtils("NotifyUtils").needNotifyMountain() then
	    cp.getManager("ViewManager").addRedDot(self.Button_JiangHu,cc.p(85,85), "ui_common_huashan.png")
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_JiangHu)
	end
end

function MajorDown:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_down.csb") 
	self:addChild(self.rootView)

	local childConfig = {
    ["Panel_down"] = {name = "Panel_down"},
    ["Panel_down.Button_DouCheng"] = {name = "Button_DouCheng",click = "onUIButtonClick"},
    ["Panel_down.Button_MenPai"] = {name = "Button_MenPai",click = "onUIButtonClick"},
    ["Panel_down.Button_JueSe"] = {name = "Button_JueSe",click = "onUIButtonClick"},
    ["Panel_down.Button_BeiBao"] = {name = "Button_BeiBao",click = "onUIButtonClick"},
    ["Panel_down.Button_WuXue"] = {name = "Button_WuXue",click = "onUIButtonClick"},
    ["Panel_down.Button_JiangHu"] = {name = "Button_JiangHu",click = "onUIButtonClick"},
    ["Panel_down.Image_exp"] = {name = "Image_exp"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	local csbSize = cc.size(720,1280)
	cp.getManager("ViewManager").adapterCSNode(self["Panel_down"] , csbSize, display.center_down)

	self.buttonlist = {self.Button_DouCheng, self.Button_MenPai, self.Button_JueSe, self.Button_BeiBao, self.Button_WuXue, self.Button_JiangHu}
end

function MajorDown:onEnterScene()
	self:refreshExp()
	self:checkNeedNotice()
	self:refreshNew()
	self:refreshLearn()
end

function MajorDown:refreshLearn()
	cp.getManager("GDataManager"):showLearnPoint(self.Button_MenPai)
end

function MajorDown:refreshNew()
	st = cp.getManager("GDataManager"):showNew()
	if #st ~= #self.buttonlist then
		log("Error................. button list")
		return
	end

	--dump(st)

    for i=1, #st do
		if st[i] then 
	    	cp.getManager("ViewManager").addDot(self.buttonlist[i], cc.p(85,85), "ui_common_xin.png", "newpic")
		else
			cp.getManager("ViewManager").removeDot(self.buttonlist[i], "newpic")
		end
	end
end

function MajorDown:refreshExp()
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local exp = majorRole["exp"]
	local roleconf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", majorRole["level"])
	local expMax = roleconf:getValue("ExpMax")
	local roleMaxLv = cp.getManager("GDataManager"):getRoleMaxLevel()
	if majorRole["level"] >= roleMaxLv then
		exp = expMax
	end
	local height = self["Image_exp"]:getContentSize().height
	self["Image_exp"]:setContentSize( exp / expMax * 685, height)
end

function MajorDown:onUIButtonClick(sender)
	self:dispatchViewEvent(cp.getConst("EventConst").open_activity_view,false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_mail_view,false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_vip_view,false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_arena_view, false)

	self:dispatchViewEvent(cp.getConst("EventConst").close_shop_view, false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_view, false)
	self:dispatchViewEvent(cp.getConst("EventConst").open_xiakexing_heroselect_view, {openState = "close"})
	self:dispatchViewEvent(cp.getConst("EventConst").open_zhuluzhanchang_view,  false)

	-- self:dispatchViewEvent(cp.getConst("EventConst").open_SelectEquipTip_view,false)
	
    local buttonName = sender:getName()
	log("click button : " .. buttonName)
	
    if self.buttonClickCallBack ~= nil then
        self.buttonClickCallBack(buttonName)
	end
	self:refreshButtonState(buttonName)
	
	self:dispatchViewEvent(cp.getConst("EventConst").on_cache_ui_visible_state_changed)
end

function MajorDown:setUIButtonClickCallBack(callback)
	self.buttonClickCallBack = callback
end

function MajorDown:refreshButtonState(buttonName)
	local list = {
		["Button_DouCheng"] = {"ui_major_module04_main_ducheng_a.png","ui_major_module04_main_ducheng_c.png"},
		["Button_MenPai"] = {"ui_major_module04_main_menpai_a.png","ui_major_module04_main_menpai_c.png"},
		["Button_JueSe"] = {"ui_major_module04_main_juese_a.png","ui_major_module04_main_juese_c.png"}, 
		["Button_BeiBao"] = {"ui_major_module04_main_beibao_a.png","ui_major_module04_main_beibao_c.png"}, 
		["Button_WuXue"] = {"ui_major_module04_main_wuxue_a.png","ui_major_module04_main_wuxue_c.png"}, 
		["Button_JiangHu"] = {"ui_major_module04_main_jianghu_a.png","ui_major_module04_main_jianghu_c.png"}
	}
	display.loadSpriteFrames("uiplist/ui_major.plist")
	for name, pictures in pairs(list) do
		local path = name == buttonName and pictures[2] or pictures[1]
		
		self[name]:ignoreContentAdaptWithSize(true)
		self[name]:loadTextureNormal(path, ccui.TextureResType.plistType)
	end
end

function MajorDown:checkNeedNotice()
	local totalNum = 0
    local packageNeedRedPoint = cp.getUserData("UserItem"):checkPackageItemCanOperate()
    for i=1,#packageNeedRedPoint do
        totalNum = totalNum + packageNeedRedPoint[i]
    end
	if totalNum > 0 then
		local fileName = packageNeedRedPoint[2] == 1 and "ui_common_shu.png" or nil
	    cp.getManager("ViewManager").addRedDot(self.Button_BeiBao,cc.p(85,85),fileName)
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_BeiBao)
    end

	local showRole = cp.getManager("GDataManager"):showRoleRedPoint()
	if showRole then
	    cp.getManager("ViewManager").addRedDot(self.Button_JueSe,cc.p(85,85))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_JueSe)
	end

	local showSkill = cp.getUserData("UserSkill"):showSkillRedPoint()
	if showSkill then
	    cp.getManager("ViewManager").addRedDot(self.Button_WuXue,cc.p(85,85))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_WuXue)
	end
	
	self:checkNeedNotifyMountain()

	--門派
	totalNum = 0
	local needNotice = cp.getManager("GDataManager"):checkMenPaiRedPoint()
	for i=1,6 do
		totalNum = totalNum + needNotice[i]
	end
	if totalNum > 0 then
		local fileName = needNotice[4] == 1 and "ui_common_jinjie.png" or nil
		cp.getManager("ViewManager").addRedDot(self.Button_MenPai,cc.p(85,85),fileName)
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_MenPai)
    end
end

return MajorDown
