local BLayer = require "cp.view.ui.base.BLayer"
local ChatLayer = class("ChatLayer",BLayer)

function ChatLayer:create(openInfo)
	local layer = ChatLayer.new(openInfo)
	return layer
end

function ChatLayer:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").ChatChannelRsp] = function(data)
			if data == nil then
				return
			end
			--插入新的聊天訊息
			--刷新cellview
			self:initMsgData()
			if self.cellView then
				self.cellView:setCellSize(620, (self.currentChannelType == 0) and 100 or 140)  --系統消息減少間隔
				self.cellView:reloadData()
				if table.nums(self.msgList) > 4 then
					self.cellView:setContentOffset(cc.p(0,0))
				end
			end

			--  5全部 1世界 3幫派 2門派 4個人私聊  0系統
			if self.currentChannelType == 5 or self.currentChannelType == data.channel or (self.currentChannelType == 0 and data.channel == 5) then
				cp.getUserData("UserChatData"):removeNewMsgIndex(data.index)
			end
			self:refreshNewMsgNotice()
		end,

		--查看玩家訊息返回
		[cp.getConst("EventConst").ViewPlayerRsp] = function(data)
			local function closeCallBack(btnName)
				if "Button_QieCuo" == btnName then
					
					local sins_max = cp.getManager("ConfigManager").getItemByKey("Other", "sins_max_per_day"):getValue("IntValue")
                    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
                    if major_roleAtt.sins and major_roleAtt.sins >= sins_max then
                        cp.getManager("ViewManager").gameTip("當前罪惡值已達到" .. tostring(sins_max) .. "，不允許進行比試")
                        return
                    end
            
					local function confirmFunc()
						self.fightInfo = {name=data.roleAtt.name}
                        local req = {}
						req.id = data.roleID
						req.zone = data.zoneID
						self:doSendSocket(cp.getConst("ProtoConst").EnemyFightReq, req)
                    end
            
                    local function cancleFunc()
                    end
                    
                    local content = "比試會增加5點罪惡值，是否繼續比試？"
                    cp.getManager("ViewManager").showGameMessageBox("系統提示",content,2,confirmFunc,cancelFunc)
				end
			end
			cp.getManager("ViewManager").showOtherRoleInfo(data,closeCallBack)
		end,

		--查看物品詳情訊息返回
		[cp.getConst("EventConst").ViewItemRsp] = function(data)
			local function closeCallBack()
				log("close viewiteminfo.")
			end
			data.item.openType = "ViewOtherItem"
			cp.getManager("ViewManager").showItemTip(data.item,closeCallBack)
		end,

		--查看分享的戰鬥記錄
		[cp.getConst("EventConst").GetCombatDataRsp] = function(proto)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		
		--聊天對象間切磋
		[cp.getConst("EventConst").EnemyFightRsp] = function(data)
			cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,

		[cp.getConst("EventConst").AcceptHeroRsp] = function(data)
			local rewardList = {} 
			rewardList.item_list = {}
            rewardList.currency_list = {}
			if data.success then
				table.insert(rewardList.currency_list, {type=cp.getConst("GameConst").VirtualItemType.silver, num = data.silver })
			end
			cp.getUserData("UserCombat"):setCombatReward(rewardList)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,

		[cp.getConst("EventConst").ViewHeroStateRsp] = function(data)
			
			local function closeCallBack(retStr)
				if retStr == "Shane_TiaoZhan" then
					local seekHelpInfo = cp.getUserData("UserChatData"):getValue("seekHelpInfo")
					log("協助挑戰大俠 npcid=" .. tostring(seekHelpInfo.npcid))
					local req = {}
					req.heroUUID = seekHelpInfo.npc_uid
					req.inviterUID = seekHelpInfo.sender_uid
					req.inviterRoleID = seekHelpInfo.sender_roleid
					req.hierarchy = seekHelpInfo.hierarchy
					self:doSendSocket(cp.getConst("ProtoConst").AcceptHeroReq, req)
				elseif retStr == "close" then
					cp.getManager("ViewManager").removeChallengeStory()
				end
			end
			cp.getManager("ViewManager").removeChallengeStory()
			local seekHelpInfo = cp.getUserData("UserChatData"):getValue("seekHelpInfo")
			local type,id,level = cp.getConst("CombatConst").CombatType_InviteHero,seekHelpInfo.npcid,0
			cp.getManager("ViewManager").showChallengeStory(type,id,level,closeCallBack) 

		end,
	}
end

function ChatLayer:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_chat/uicsb_chat_main.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_bg"] = {name = "Panel_bg",click = "onUIButtonClick",clickScale=1},
		["Panel_bg.Image_box"] = {name = "Image_box"},
		["Panel_bg.Image_box.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},

		["Panel_bg.Image_box.Panel_head.Panel_cellviewbg"] = {name = "Panel_cellviewbg"},
		["Panel_bg.Image_box.Panel_head.Panel_quanbu"] = {name = "Panel_quanbu",click = "onTabItemClick"},
		["Panel_bg.Image_box.Panel_head.Panel_world"] = {name = "Panel_world",click = "onTabItemClick"},
		["Panel_bg.Image_box.Panel_head.Panel_bangpai"] = {name = "Panel_bangpai",click = "onTabItemClick"},
		["Panel_bg.Image_box.Panel_head.Panel_menpai"] = {name = "Panel_menpai",click = "onTabItemClick"},
		["Panel_bg.Image_box.Panel_head.Panel_siliao"] = {name = "Panel_siliao",click = "onTabItemClick"},
		["Panel_bg.Image_box.Panel_head.Panel_system"] = {name = "Panel_system",click = "onTabItemClick"},

		["Panel_bg.Image_box.Panel_input"] = {name = "Panel_input"},
		["Panel_bg.Image_box.Panel_input.Image_input"] = {name = "Image_input"},
		["Panel_bg.Image_box.Panel_input.Image_input.TextField_input"] = {name = "TextField_input"},
		["Panel_bg.Image_box.Panel_input.Button_send"] = {name = "Button_send",click = "onUIButtonClick"},
		["Panel_bg.Image_box.Panel_input.Image_emoticon"] = {name = "Image_emoticon",click = "onUIButtonClick"},
		["Panel_bg.Image_box.Panel_input.Panel_type_select"] = {name = "Panel_type_select",click = "onUIButtonClick",clickScale = 1},
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Image_type"] = {name = "Image_type"},
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Text_chatType"] = {name = "Text_chatType"},
		
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Panel_chatType"] = {name = "Panel_chatType"},
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Panel_chatType.Panel_1"] = {name = "Panel_1",click = "onChatTypeSelected"},
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Panel_chatType.Panel_2"] = {name = "Panel_2",click = "onChatTypeSelected"},
		["Panel_bg.Image_box.Panel_input.Panel_type_select.Panel_chatType.Panel_3"] = {name = "Panel_3",click = "onChatTypeSelected"},

		["Panel_bg.Image_box.Panel_emoticon"] = {name = "Panel_emoticon",click = "onUIButtonClick",clickScale=1},
		["Panel_bg.Image_box.Panel_emoticon.Image_emoticon.ScrollView_1"] = {name = "ScrollView_1"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	self.Image_type:setFlippedY(false)
	-- self.TextField_input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    
    -- cp.getManager("GDataManager"):onCreateTextField(self.TextField_input)
	self.TextField_input:setPlaceHolderColor(cc.c4b(255,255,255,128))


	--調整分辨率適配
	self.rootView:setContentSize(display.size)
	-- local sz = self.Image_box:getContentSize()
	-- local newHeight = 705
	-- if display.height > 1080 then 
	-- 	newHeight = 995
	-- elseif display.height > 960 then 
	-- 	newHeight = 805
	-- else  --960
	-- 	newHeight = 705
	-- end
	-- self.Image_box:setContentSize(sz.width,newHeight) 

	local extraInfo = {maxLength = 50}
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_input,"chatInputBox",extraInfo)

	cp.getManager("ViewManager").addModal(self, cp.getManualConfig("Color").defaultModal_c4b)
	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	
	self.TextField_input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.TextField_input:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.tabItems = {  -- 5全部 1世界 3幫派 2門派 4個人私聊  0系統
		self["Panel_system"],	
		self["Panel_world"],
		self["Panel_menpai"],
		self["Panel_bangpai"],
		self["Panel_siliao"],
		self["Panel_quanbu"],
	}
    for i=1,table.nums(self.tabItems) do
		local Image_array = self.tabItems[i]:getChildByName("Image_array")
		Image_array:setVisible(false)
	end
	self.Panel_chatType:setVisible(false)

	
	cp.getManager("ViewManager").popUpView(self.Panel_bg)
end

function ChatLayer:chatWith(newInfo)
	self.openInfo = newInfo
	if self.openInfo and self.openInfo.zoneID > 0 and  self.openInfo.roleID > 0 then -- 直接進入私聊
		self.chatType = 1
		self.chatObjName = self.openInfo.roleName
		self:onTabItemClick(self["Panel_siliao"])
	end
end

function ChatLayer:onEnterScene()

	if self.openInfo and self.openInfo.zoneID > 0 and  self.openInfo.roleID > 0 then -- 直接進入私聊
		self.chatType = 1
		self.chatObjName = self.openInfo.roleName
		self:onTabItemClick(self["Panel_siliao"])
	else

		self.chatType = 1  --切換髮送的聊天頻道 （1：發送到世界頻道，2：發送到門派頻道，3：發送到幫派頻道， 4:私聊, 系統不能手動切換）
		self.chatObjName = "" --私聊的對象
		self:onTabItemClick(self["Panel_quanbu"])
	end
	
	self:setItemView()

	self:refreshNewMsgNotice()
end

function ChatLayer:onChatTypeSelected(sender)
	local buttonName = sender:getName()
	local idx = tonumber(string.sub(buttonName,string.len("Panel_")+1))
	self.chatType = idx
	log("change  self.chatType  = " .. tostring(self.chatType))

	self.Panel_chatType:setVisible(false)
	-- self.Image_type:loadTexture("ui_chat_module33_liaotian_jiantou02.png", ccui.TextureResType.plistType)
	self.Image_type:setFlippedY(false)
	self:refreshChatType()
end

function ChatLayer:refreshChatType()
	if self.currentChannelType == 4 then
		if self.chatObjName == "" then
			self.TextField_input:setString("")
			self.TextField_input:setPlaceHolder("點擊玩家名字選擇私聊對象.")
		else
			self.TextField_input:setString("")
			self.TextField_input:setPlaceHolder("你與" .. self.chatObjName .. "私聊：")
		end
		self.Image_input:setContentSize(cc.size(421,55))
		self.Image_input:setPositionX(0)
	else
		local text = {"世界","門派","幫派"}  --  1世界 2門派 3幫派 
		local color = {cc.c3b(143,195,253),cc.c3b(248,234,165),cc.c3b(143,253,151)}
		self.Text_chatType:setString(text[self.chatType])
		self.Text_chatType:setTextColor(color[self.chatType])
		local str = self.TextField_input:getString()
		if string.trim(str) == "" then
			local placeHolderText = "請輸出內容，不可超過30個字符。"
			if self.currentChannelType == 0 then
				placeHolderText = "無法在此界面發送聊天訊息。"

			end
			self.TextField_input:setPlaceHolder(placeHolderText)
			self.TextField_input:setString("")
		end
		self.Image_input:setContentSize(cc.size(298,55))
		self.Image_input:setPositionX(123)
	end
	ccui.Helper:doLayout(self.Image_input)
	self.Panel_type_select:setVisible(self.currentChannelType ~= 4)
end

function ChatLayer:onUIButtonClick(sender)
	local buttonName = sender:getName()
	if "Image_emoticon"  == buttonName then
		if self:checkCanChat() == false then
			return
		end
		if self.Panel_emoticon:isVisible() == false then
			self.Panel_emoticon:setVisible(true)
			self:createEmoticons()
		end
	elseif "Panel_type_select"  == buttonName then
		local isVisible = self.Panel_chatType:isVisible()
		self.Panel_chatType:setVisible(not isVisible)
		-- self.Image_type:loadTexture(isVisible and "ui_chat_module33_liaotian_jiantou02.png" or "ui_chat_module33_liaotian_jiantou01.png", ccui.TextureResType.plistType)
		self.Image_type:setFlippedY(not isVisible)
	elseif "Button_send"  == buttonName then
		if self:checkCanChat() == false then
			return
		end

		local txt = self.TextField_input:getString()
		if self.currentChannelType == 4 then
			--txt = string.sub(txt,string.len("你與" .. self.chatObjName .. "私聊：")+1)
		end
		if self:checkChatMsgMactchRules(txt) then
			
			local content = {}
			table.insert(content,txt)

			-----------------------------------
			-- for test
			-- local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			-- local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
			-- local zoneid = serverinfo.id
			-- --msgInfo.content[1] = "<role=(name='狂刀無敵',roleID=111,zoneID=1,npc=0)>" --"<item=(id=19,uuid='1111',roleID=111,zoneID=1)>"
			-- table.insert(content,"<role=(name=".. major_roleAtt.name .. ",roleID=".. tostring(major_roleAtt.id) .. ",zoneID=" .. tostring(zoneid) .. ",npc=0)>")

			-- table.insert(content,"<item=(id=754,uuid=".. tostring("89c4b653-fa7c-11e7-893b-00163e069f22")..",roleID=".. tostring(major_roleAtt.id) .. ",zoneID=" .. tostring(zoneid) .. ")>")
			
			-----------------------------------------

			if self.chatType == 3 then
				local req = {}
				req.content = content
				self:doSendSocket(cp.getConst("ProtoConst").DispatchGuildTalkReq, req)
			else
				local req = {}
				req.channel = self.currentChannelType == 4 and 4 or self.chatType  --發送消息(1世界 2門派 3幫派 4私聊)
				req.roleID = 0
				req.zoneID = 0
				req.content = content
				if self.currentChannelType == 4 then
					req.roleID = self.openInfo.roleID
					req.zoneID = self.openInfo.zoneID
				end
				self:doSendSocket(cp.getConst("ProtoConst").ChatChannelReq, req)
			end
			self.TextField_input:setString("")
			if self.currentChannelType == 4 then
				-- self.TextField_input:setString("你與" .. self.chatObjName .. "私聊：")
				self.TextField_input:setPlaceHolder("你與" .. self.chatObjName .. "私聊：")
			end
		end
	elseif "Button_close" == buttonName or "Panel_bg" == buttonName then
		if self.Panel_emoticon:isVisible() then
			self.Panel_emoticon:setVisible(false)
			self.ScrollView_1:removeAllChildren()
		else
			cp.getUserData("UserChatData"):resetNewMsgNum()
			self:dispatchViewEvent(cp.getConst("EventConst").ChatLayerClose)
			cp.getManager("PopupManager"):removePopup(self)
		end
	elseif "Panel_emoticon" == buttonName then
		if self.Panel_emoticon:isVisible() then
			self.Panel_emoticon:setVisible(false)
			self.ScrollView_1:removeAllChildren()
		end
	end
end

function ChatLayer:checkCanChat()

	if self.currentChannelType == 0 then
		cp.getManager("ViewManager").gameTip("無法在系統頻道發送消息！")
		return false
	end

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	if major_roleAtt.level < 5 then
		cp.getManager("ViewManager").gameTip("請大俠升級至5級以上!")
		return false
	end

	if self.currentChannelType == 4 and self.chatObjName == "" then
		cp.getManager("ViewManager").gameTip("請先選擇私聊對象!")
		return false
	end
	if self.chatType == 3 then
		local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData() --幫派數據
		if not guildDetailData.name or guildDetailData.name == "" then 
			cp.getManager("ViewManager").gameTip("請先加入一個幫派!")
			return false
		end
	end
	return true
end

function ChatLayer:onTabItemClick(sender)
	local buttonName = sender:getName()
	log("click button : " .. buttonName)
	local channelType = 5  --  5全部 1世界 3幫派 2門派 4個人私聊  0系統
	if "Panel_quanbu"  == buttonName then
		channelType = 5
		self.chatType = 1
	elseif "Panel_world"  == buttonName then
		channelType = 1
		self.chatType = 1
	elseif "Panel_bangpai"  == buttonName then
		channelType = 3
		self.chatType = 3
	elseif "Panel_menpai"  == buttonName then
		channelType = 2
		self.chatType = 2
	elseif "Panel_siliao"  == buttonName then
		channelType = 4
	elseif "Panel_system"  == buttonName then
		channelType = 0
		self.chatType = 1
	end
	self:changeChatChannel(channelType)
	self:refreshButtonStatus(channelType)

	self.Panel_chatType:setVisible(false)
	self.Image_type:setFlippedY(false)

	self:refreshChatType()

	cp.getUserData("UserChatData"):removeNewMsgByChannel(channelType)
	self:refreshNewMsgNotice()
	
end

function ChatLayer:changeChatChannel(channelType)
	
	if self.currentChannelType and self.currentChannelType == channelType then
		return
	end

	self.currentChannelType = channelType
	log("currentChannelType = " .. self.currentChannelType)
	self:initMsgData()
	
	if self.cellView then
		self.cellView:setCellSize(620, (self.currentChannelType == 0) and 100 or 140)  --系統消息減少間隔
		self.cellView:reloadData()
		if table.nums(self.msgList) > 4 then
			self.cellView:setContentOffset(cc.p(0,0))
		end
	end
	
	log("change  channelType = " .. tostring(self.chatType))
end


function ChatLayer:refreshButtonStatus(channelType)
	self.Panel_cellviewbg:setLocalZOrder(1)
	
	for i=1,table.nums(self.tabItems) do
		local icon = "ui_chat_module31_backpack_fk_a.png"
		local Text_1 = self.tabItems[i]:getChildByName("Text_1")
		if channelType == i-1 then
			icon = "ui_chat_module31_backpack_fk_b.png"
			self.tabItems[i]:setLocalZOrder(2)
			Text_1:setTextColor(cc.c3b(255,245,165))
			Text_1:setFontSize(23*Text_1.clearScale)
			-- Text_1:setPosition(cc.p(43,27))
			-- Text_1:enableOutline(cc.c4b(0,0,0,255),2)
		else
			self.tabItems[i]:setLocalZOrder(2)
			Text_1:setTextColor(cc.c3b(93,51,13))
			Text_1:setFontSize(21*Text_1.clearScale)
			-- Text_1:setPosition(cc.p(42,20))
			-- Text_1:disableEffect(cc.LabelEffect.OUTLINE)  
		end
		self.tabItems[i]:setBackGroundImage(icon, ccui.TextureResType.plistType)
		-- self.tabItems[i]:ignoreContentAdaptWithSize(false)
	
	end
end


--設置顯示的內容
function ChatLayer:setItemView()
	local sz = self["Panel_cellviewbg"]:getContentSize()
	self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width, sz.height))
	self.cellView:setCellSize(620, 140)
	self.cellView:setColumnCount(1)
	self.cellView:setCountFunction(function()
		return table.nums(self.msgList)
	end)

	local function cellFactoryFunc(cellview, idx)
		return self:cellFactory(cellview, idx + 1)
	end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()       --刷新數據
	if table.nums(self.msgList) > 4 then
		self.cellView:setContentOffset(cc.p(0,0))
	end
	self.cellView:setAnchorPoint(cc.p(0, 0))
	self.cellView:setPosition(cc.p(0, 0))
	self["Panel_cellviewbg"]:addChild(self.cellView,1)
end

function ChatLayer:cellFactory(cellview, idx)
    local item = nil
    local cell = cellview:dequeueCell()
    if nil == cell then
		cell = cc.TableViewCell:new()
		
		item = require("cp.view.scene.world.chat.ChatMsgItem"):create(nil)
		item:setAnchorPoint(cc.p(0, 0))
		item:setPosition(cc.p(0, 0))
		item:setName("ChatMsgItem")
		item:setClickCallBack(handler(self,self.chatItemClickCallBack))
		cell:addChild(item)
    else
		item = cell:getChildByName("ChatMsgItem")
    end

	local data = self:getData()[idx]
	item:reset(data)	

    return cell
end

function ChatLayer:chatItemClickCallBack(clickType,msgInfo)
	if clickType == "name" then
		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local isSelf = msgInfo.senderID == major_roleAtt.id
		if not isSelf or (isSelf and msgInfo.channel == 4) then

			local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
			self.openInfo = self.openInfo or  {}
			self.openInfo.zoneID = serverinfo.id
			self.openInfo.roleID = (isSelf and msgInfo.channel == 4) and msgInfo.receRoleID or msgInfo.senderID  
			self.openInfo.roleName = (isSelf and msgInfo.channel == 4) and msgInfo.receName or msgInfo.senderName

			if self.openInfo and self.openInfo.zoneID > 0 and  self.openInfo.roleID > 0 then -- 直接進入私聊
				self.chatType = 1
				self.chatObjName = self.openInfo.roleName	
				self:onTabItemClick(self["Panel_siliao"])
			end
			
		end
	elseif clickType == "headIcon" then
		local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
		local req = {}
		req.roleID = msgInfo.senderID
		req.zoneID = serverinfo.id
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
	elseif clickType == "richText" then
		--查看物品訊息
	end
end

function ChatLayer:initMsgData()
	self.msgList = {}
	if self.currentChannelType == 5 then -- 0系統 1世界 2門派 3幫派 4個人 5全部 （1的情況特殊處理，顯示全部訊息）
		local msg = cp.getUserData("UserChatData"):getValue("chat_msg_list")
		for _,value in pairs(msg) do
			if value.channel ~= 0 and value.channel ~= 5 then  -- 0系統 1世界 2門派 3幫派 4個人 5走馬燈
				self.msgList[#self.msgList+1] = value
			end
		end
	else
		local msg = cp.getUserData("UserChatData"):getValue("chat_msg_list")
		for _,value in pairs(msg) do
			if value.channel == self.currentChannelType or (value.channel == 5 and self.currentChannelType == 0) then
				self.msgList[#self.msgList+1] = value
			end
		end
	end
end

function ChatLayer:getData()
	return self.msgList 
end

function ChatLayer:checkChatMsgMactchRules(txt)
	if string.len(string.trim(txt)) == 0 then
		cp.getManager("ViewManager").gameTip("聊天內容不能為空")
		return false
	end
	if string.utf8len_m(string.trim(txt)) > 30 then
		cp.getManager("ViewManager").gameTip("聊天內容不能超過30個字符")
		return false
	end
	return true
end


function ChatLayer:createEmoticons()
	local totalCount = 18
	local totalRow = math.floor(18/4 + 0.5)
	local totalSize = cc.size(4*(94+6),totalRow*(83+7))
	local sz = self.ScrollView_1:getInnerContainerSize()
	if sz.height < totalSize.height then
		self.ScrollView_1:setInnerContainerSize(cc.size(sz.width,totalSize.height))
	end

	local function onTouch(sender, event)
		if event == cc.EventCode.ENDED then
			local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
			if major_roleAtt.level < 5 then
				cp.getManager("ViewManager").gameTip("請大俠升級至5級以上!")
				return
			end
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onEmoticonItemSelected(sender)
            end
        end
	end


	for i=1,totalCount do
		local item = ccui.ImageView:create("img/icon/emoticon/" .. tostring(i) .. ".png", ccui.TextureResType.localType)
		self.ScrollView_1:addChild(item)
		item:setAnchorPoint(cc.p(0,1))
		local x = (i-1)%4
		local y = math.floor((i-1)/4)
		item:setPosition(cc.p(x*(94+6), totalSize.height - y*(83+7)))

		item:setTouchEnabled(true)
		item:addTouchEventListener(onTouch)
		item:setTag(i)
	end
end

function ChatLayer:onEmoticonItemSelected(sender)
	local tag = sender:getTag()
	log("onEmoticonItemSelected tag = " .. tag)

	if self.Panel_emoticon:isVisible() then
		self.Panel_emoticon:setVisible(false)
		self.ScrollView_1:removeAllChildren()
	end

	--發送聊天表情
	local content = {}
	table.insert(content,"<emoticon=" .. tostring(tag) .. ">")

	if self.chatType == 3 then
		local req = {}
		req.content = content
		self:doSendSocket(cp.getConst("ProtoConst").DispatchGuildTalkReq, req)
	else
		local req = {}
		req.channel = self.currentChannelType == 4 and 4 or self.chatType  --發送消息(1世界 2門派 3幫派 4私聊)
		req.roleID = 0
		req.zoneID = 0
		req.content = content
		if self.currentChannelType == 4 then
			req.roleID = self.openInfo.roleID
			req.zoneID = self.openInfo.zoneID
		end
		self:doSendSocket(cp.getConst("ProtoConst").ChatChannelReq, req)
	end
	self.TextField_input:setString("")
	if self.currentChannelType == 4 then
		-- self.TextField_input:setString("你與" .. self.chatObjName .. "私聊：")
		self.TextField_input:setPlaceHolder("你與" .. self.chatObjName .. "私聊：")
	end
	
end

function ChatLayer:getDescription()
	return "ChatLayer"
end

function ChatLayer:refreshNewMsgNotice()
	
	-- 5全部 1世界 3幫派 2門派 4個人私聊  0系統
	local total ,nums = cp.getUserData("UserChatData"):getAllChannelNewMsgNum()
	for i=1,table.nums(self.tabItems) do
		local Image_array = self.tabItems[i]:getChildByName("Image_array")
		if i<=5 then
			Image_array:setVisible(nums[i] > 0)
			if nums[i] > 0 then
				Image_array:getChildByName("Text_num"):setString( nums[i] > 99 and "..." or tostring(nums[i]) )
			end
		else -- 全部
			Image_array:setVisible(total > 0)
			if total > 0 then
				Image_array:getChildByName("Text_num"):setString( total > 99 and "..." or tostring(total) )
			end
		end
	end

end

function ChatLayer:addTextFieldEvent(textField)
	
		if self.inputBox then
			self.inputBox:removeFromParent()
			self.inputBox = nil
		end
	
		local function textFieldEvent(sender, eventType)
			if eventType == ccui.TextFiledEventType.attach_with_ime then
				if self.inputBox then
					self.inputBox:removeFromParent()
					self.inputBox = nil
				end
				self.inputBox = require("cp.view.ui.tip.GameEditBox"):create()
				self.inputBox:setCloseCallBack(function(name,text)
					if name == "Button_ok" then
						textField:setString(text)
					end
					textField:setTouchEnabled(true)
					self.inputBox:removeFromParent()
					self.inputBox = nil
				end)
				self.rootView:addChild(self.inputBox,1)
				self.inputBox:setPosition(cc.p(0,0))
	 
				textField:setTouchEnabled(false)
			elseif eventType == ccui.TextFiledEventType.detach_with_ime then
				
			elseif eventType == ccui.TextFiledEventType.insert_text then
				
			elseif eventType == ccui.TextFiledEventType.delete_backward then
				
			end
		end
	
		textField:setTouchEnabled(true)
		textField:addEventListener(textFieldEvent)
		
	end

return ChatLayer
