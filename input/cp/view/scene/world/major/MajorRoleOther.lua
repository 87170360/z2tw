local BLayer = require "cp.view.ui.base.BLayer"
local MajorRoleOther = class("MajorRoleOther",BLayer)

function MajorRoleOther:create(openInfo)
	local layer = MajorRoleOther.new(openInfo)
	return layer
end

function MajorRoleOther:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
	}
end

function MajorRoleOther:onInitView(openInfo)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_role_other.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_renwu"] = {name = "Panel_renwu"},
		["Panel_root.Panel_renwu.Image_RenWu"] = {name = "Image_RenWu"},
		["Panel_root.Panel_info"] = {name = "Panel_info"},
		["Panel_root.Panel_info.Image_title.Text_1"] = {name = "Text_title"},
		["Panel_root.Panel_info.Image_id.Text_1"] = {name = "Text_id"},
		["Panel_root.Panel_info.Image_name.Text_1"] = {name = "Text_name"},
		["Panel_root.Panel_info.Image_levelinfo.Text_1"] = {name = "Text_levelinfo"},
		["Panel_root.Panel_info.Image_gang.Text_1"] = {name = "Text_gang"},
		["Panel_root.Panel_info.Image_fight.Text_1"] = {name = "Text_fight"},
		["Panel_root.FileNode_1"] = {name = "FileNode_1"},
		["Panel_root.Button_ShuXing"] = {name = "Button_ShuXing",click = "onUIButtonClick"},
		["Panel_root.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
		["Panel_root.Button_Wuxue"] = {name = "Button_Wuxue",click = "onUIButtonClick"},
		["Panel_root.Button_JieChou"] = {name = "Button_JieChou",click = "onUIButtonClick"},
		["Panel_root.Button_JiaoYou"] = {name = "Button_JiaoYou",click = "onUIButtonClick"},
		["Panel_root.Button_SiLiao"] = {name = "Button_SiLiao",click = "onUIButtonClick"},
		["Panel_root.Button_QieCuo"] = {name = "Button_QieCuo",click = "onUIButtonClick"},
    
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

--[[
        message ViewPlayerRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
	optional RoleAtt roleAtt                = 2;                    //角色屬性
    repeated ItemData equipList             = 3;                    //裝備
    required int64 roleID                   = 4;
    required int32 zoneID                   = 5;
    repeated SkillSummary skill             = 6;                    //武學
    optional int32 vip                      = 7;                    //vip
    repeated ItemAtt guildAtt               = 8;                    //幫派屬性
    optional FashionData fashion            = 9;                    //時裝
}
]]
		
	self.openInfo = openInfo
	self.openInfo.type = "MajorRoleOther"
	local MajorRolePublic = require("cp.view.scene.world.major.MajorRolePublic"):create(self.openInfo) 
	MajorRolePublic:setJingjieClickCallBack(handler(self, self.onUIButtonClick))
	self.MajorRolePublic = MajorRolePublic
	self.FileNode_1:addChild(self.MajorRolePublic)

	self.rootView:setContentSize(display.size)
	-- self.FileNode_1:setPositionY(display.height - 100)  --MajorTop人物頭像訊息框高度按170算
	self:autoAdjust()	
	ccui.Helper:doLayout(self.rootView)

end

function MajorRoleOther:autoAdjust()
	self.Panel_renwu:setPositionX(self.Panel_renwu:getPositionX() + 33)
end

function MajorRoleOther:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log("click button : " .. buttonName)
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

	if "Button_ShuXing"  == buttonName then
		local roleAtt = self.openInfo.roleAtt
		local guildAtt = self.openInfo.guildAtt
		local fashion = self.openInfo.fashion
		-- local pos = self.FileNode_1:getPositionY()
		local openInfo = {roleAtt = roleAtt,type = "MajorRoleOther",guildAtt=guildAtt, fashion=fashion}
		local MajorRoleAttribute = require("cp.view.scene.world.major.MajorRoleAttribute"):create(openInfo)
		self.Panel_root:addChild(MajorRoleAttribute,1)
	elseif "Button_jingjie"  == buttonName then
		local roleAtt = self.openInfo.roleAtt
		local openInfo = {roleAtt = roleAtt}
		local MajorRolejingjie = require("cp.view.scene.world.major.MajorRolejingjie"):create(openInfo)
		self:addChild(MajorRolejingjie,1)
	elseif "Button_Wuxue" == buttonName then
		--打開武學列表
		local wuxueList = self.openInfo.skill
		local PlayerWuxueList = require("cp.view.ui.messagebox.PlayerWuxueList"):create(wuxueList)
		self:addChild(PlayerWuxueList,1)

	elseif "Button_JieChou" == buttonName then
		if major_roleAtt.id == self.openInfo.roleID then
			cp.getManager("ViewManager").gameTip("不能將自己標註為江湖對立。")
			return
		end
		local name = self.openInfo.roleAtt.name
		local contentTable = {
			{type="ttf", fontSize=24, text="確定將【", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text=name, textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text="】加入標註為江湖對立？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
			local req = {}
			req.player_info = {}
			req.player_info.id = self.openInfo.roleID
			req.player_info.zone = self.openInfo.zoneID
			self:doSendSocket(cp.getConst("ProtoConst").AddEnemyReq, req)
		end,nil)
		
	elseif "Button_JiaoYou" == buttonName then
		if major_roleAtt.id == self.openInfo.roleID then
			cp.getManager("ViewManager").gameTip("不能向自己申請好友。")
			return
		end
		local name = self.openInfo.roleAtt.name
		local contentTable = {
			{type="ttf", fontSize=24, text="是否向【", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text=name, textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text="】申請好友？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
			local req = {}
			req.player_info = {}
			req.player_info.id = self.openInfo.roleID
			req.player_info.zone = self.openInfo.zoneID
			self:doSendSocket(cp.getConst("ProtoConst").AddFriendReq, req)
		end,nil)
	elseif "Button_SiLiao" == buttonName then
		if major_roleAtt.id == self.openInfo.roleID then
			cp.getManager("ViewManager").gameTip("不能與自己私聊。")
			return
		end
		local name = self.openInfo.roleAtt.name
		local contentTable = {
			{type="ttf", fontSize=24, text="是否前往聊天界面與【", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text=name, textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=24, text="】聊天？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
			--關閉當前界面並進入聊天界面
			if self.openInfo.closeCallBack ~= nil then
				self.openInfo.closeCallBack("Button_SiLiao")
			end
			local chatObjInfo = {
				roleID = self.openInfo.roleID, 
				zoneID = self.openInfo.zoneID, 
				roleName = self.openInfo.roleAtt.name,
				hierarchy = self.openInfo.roleAtt.hierarchy,
				career = self.openInfo.roleAtt.career,
				gender = self.openInfo.roleAtt.gender,
				head = self.openInfo.roleAtt.head,
				vip = self.openInfo.vip,
				gangRank = self.openInfo.roleAtt.gangRank,
			}
			cp.getManager("ViewManager").showChatLayer(chatObjInfo)
			cp.getManager("PopupManager"):removePopup(self)
		end,nil)
	elseif "Button_QieCuo"  == buttonName then
		if major_roleAtt.id == self.openInfo.roleID then
			cp.getManager("ViewManager").gameTip("不能與自己切磋。")
			return
		end
		if self.openInfo.closeCallBack ~= nil then
			self.openInfo.closeCallBack("Button_QieCuo")
		end
	elseif "Button_close"  == buttonName then
		if self.openInfo.closeCallBack ~= nil then
			self.openInfo.closeCallBack("Button_close")
		end

		cp.getManager("PopupManager"):removePopup(self)
		return
	end
end


function MajorRoleOther:onEnterScene()
	local roleAtt = self.openInfo.roleAtt


	-- self.Text_title:setString("稱謂: 無")
	self.Text_title:setVisible(false) 
	self.Text_id:setString("ID: " .. roleAtt.id)
	self.Text_name:setString("名字: " .. tostring(roleAtt.name))
	local hierarchyInfo = cp.getManager("GDataManager"):getHierarchyInfo(roleAtt.career, roleAtt.gangRank, roleAtt.hierarchy)
	self.Text_levelinfo:setString("LV." .. roleAtt.level .. "  " .. hierarchyInfo)
	self.Text_fight:setString("戰力: " .. tostring(roleAtt.fight))

	self.Text_gang:setString(tostring("無幫派"))
	if self.openInfo.guildName and string.len(self.openInfo.guildName) > 0 then
		self.Text_gang:setString(tostring("幫派 【" .. self.openInfo.guildName .. "】"))
	end

	self["Image_RenWu"]:setVisible(false)
	local fashion_data = self.openInfo.fashion
	local cfg, _ = cp.getManager("GDataManager"):getMajorRoleIamge(fashion_data.use,roleAtt["career"],roleAtt["gender"]) 
	local WholeDraw = cfg:getValue("WholeDraw")
	if WholeDraw ~= nil and WholeDraw ~= "" then
		self["Image_RenWu"]:loadTexture(WholeDraw, ccui.TextureResType.localType)
		self["Image_RenWu"]:ignoreContentAdaptWithSize(true)
		self["Image_RenWu"]:setVisible(true)
		self["Image_RenWu"]:setScale(0.75)
	end

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self.Button_JieChou:setEnabled(major_roleAtt.id ~= self.openInfo.roleID)	
	self.Button_JiaoYou:setEnabled(major_roleAtt.id ~= self.openInfo.roleID)
	self.Button_SiLiao:setEnabled(major_roleAtt.id ~= self.openInfo.roleID)
	self.Button_QieCuo:setEnabled(major_roleAtt.id ~= self.openInfo.roleID)
end

return MajorRoleOther
