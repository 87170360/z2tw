local BLayer = require "cp.view.ui.base.BLayer"
local FriendListLayer = class("FriendListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function FriendListLayer:create()
	local scene = FriendListLayer.new()
    return scene
end

function FriendListLayer:initListEvent()
    self.listListeners = {
		
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
		[cp.getConst("EventConst").GetRoleSimpleRsp] = function(data)
			self:updateFriendView(data)
		end,
		[cp.getConst("EventConst").DeleteFriendRsp] = function(data)
			if self.selectIndex == 1 then
				self:updateFriendView()
			end
		end,
		[cp.getConst("EventConst").AddFriendRsp] = function(data)
			if self.selectIndex == 3 or self.selectIndex == 2 then
				self:updateFriendView()
			end
		end,
		[cp.getConst("EventConst").AddFriendNotifyRsp] = function(data)
			if self.selectIndex == 3 then
				self:updateFriendView()
			end
		end,
		[cp.getConst("EventConst").DeleteEnemyRsp] = function(data)
			if self.selectIndex == 4 then
				self:updateFriendView()
			end
		end,
		[cp.getConst("EventConst").SearchPlayerRsp] = function(data)
			if self.selectIndex == 2 then
				self:updateSearchFriendView(data)
			end
		end,
		[cp.getConst("EventConst").AgreeRequestRsp] = function(data)
			if self.selectIndex == 3 or self.selectIndex == 2 or self.selectIndex == 1 then
				self:updateFriendView(data)
			end
		end,
		[cp.getConst("EventConst").DeclineRequestRsp] = function(data)
			if self.selectIndex == 3 or self.selectIndex == 2 then
				self:updateFriendView(data)
			end
		end,
		[cp.getConst("EventConst").GetPlayerOnlineRsp] = function(select_index)
			if self.selectIndex == select_index then
				self:updateFriendView(data)
			end
		end,
		[cp.getConst("EventConst").PlayerLoginNotifyRsp] = function()
			self:updateFriendView()
		end,
		[cp.getConst("EventConst").PlayerLogoutNotifyRsp] = function()
			self:updateFriendView()
		end,
		[cp.getConst("EventConst").ChangeSearchListRsp] = function()
			if self.selectIndex == 2 then
				self:updateFriendView()
			end
		end,
		[cp.getConst("EventConst").FriendFightRsp] = function()
			cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		[cp.getConst("EventConst").EnemyFightRsp] = function()
			cp.getUserData("UserCombat"):resetFightInfo()
			cp.getUserData("UserCombat"):updateFightInfo(self.fightInfo)
			cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
		[cp.getConst("EventConst").AddFriendRsp] = function()
			if self.selectIndex == 4 then
				self:updateFriendView()
			end
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function FriendListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_friend/uicsb_friend_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.selectIndex = 1

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_1.Button_FriendList"] = {name = "Button_FriendList", click="onBtnClick", clickScale=1},
		["Panel_root.Panel_1.Button_FriendReq"] = {name = "Button_FriendReq", click="onBtnClick", clickScale=1},
		["Panel_root.Panel_1.Button_FriendRsp"] = {name = "Button_FriendRsp", click="onBtnClick", clickScale=1},
		["Panel_root.Panel_1.Button_FriendBlack"] = {name = "Button_FriendBlack", click="onBtnClick", clickScale=1},
		["Panel_root.Panel_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Panel_1.Panel_List"] = {name = "Panel_List"},
		["Panel_root.Panel_1.Panel_Req"] = {name = "Panel_Req"},
		["Panel_root.Panel_1.Panel_Rsp"] = {name = "Panel_Rsp"},
		["Panel_root.Panel_1.Panel_Black"] = {name = "Panel_Black"},
		["Panel_root.Panel_1.Panel_Req.Panel_top"] = {name = "Panel_top"},
		["Panel_root.Panel_1.Panel_Req.Panel_top.Image_req_bg"] = {name = "Image_req_bg"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.Panel_top:getChildByName("TextField_Count"),"InputBox_Count",nil)
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.Panel_top:getChildByName("TextField_ID"),"InputBox_ID",nil)
	ccui.Helper:doLayout(self.rootView)
	self:updateFriendView()
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
      		self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,false)
		end
	end)
	self.Panel_List:getChildByName("ListView_List"):setScrollBarEnabled(false)
	self.Panel_Rsp:getChildByName("ListView_List"):setScrollBarEnabled(false)
	self.Panel_Black:getChildByName("ListView_List"):setScrollBarEnabled(false)
	self.Image_req_bg:getChildByName("ListView_List"):setScrollBarEnabled(false)

	-- self.Panel_root:setPosition()
	ccui.Helper:doLayout(self.rootView)
	self:setupAchivementGuide()
end

function FriendListLayer:setupAchivementGuide()
    local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
	if guideType == 16 then
		self:onBtnClick(self.Button_FriendReq)
		cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end
end

function FriendListLayer:updatePlayerSimpleInfo(simpleInfoList)
	local listView = nil
	if self.selectIndex == 1 then
		listView = self.Panel_List:getChildByName("ListView_List")
	elseif self.selectIndex == 2 then
		listView = self.Image_req_bg:getChildByName("ListView_List")
	elseif self.selectIndex == 3 then
		listView = self.Panel_Rsp:getChildByName("ListView_List")
	elseif self.selectIndex == 4 then
		listView = self.Panel_Black:getChildByName("ListView_List")
	end

	for _, simpleInfo in ipairs(simpleInfoList) do
		local key = simpleInfo.id
		local img = listView:getChildByName(key)
		if img then
			self:fillPlayerInfo(img, simpleInfo)
		end
	end
end

function FriendListLayer:fillPlayerInfo(img, simpleInfo)
	local name = img:getChildByName("Text_Name")
	local icon = img:getChildByName("Button_Icon")
	local fight = img:getChildByName("Text_Fight")
	local txtStatus = img:getChildByName("Text_Status")
	local modelID = 0
	local configItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance", simpleInfo.career)
	if not configItem then
		return
	end
	img:setName(simpleInfo.id)
    if simpleInfo.gender == 0 then
        modelID = configItem:getValue("Role1")
    else
        modelID = configItem:getValue("Role2")
	end
	local modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", modelID)
	if modelConfig then
		local textureName = cp.DataUtils.getModelFace(simpleInfo.face)
		icon:loadTextures(textureName, textureName, textureName)
	end
	name:setString(simpleInfo.name)
	fight:setString("戰力      " .. tostring(simpleInfo.fight))
	if txtStatus then
		if simpleInfo.status then
			txtStatus:setString("(在線)")
			--txtStatus:setTextColor(cc.c4b(0,255,0,255))
			icon:setColor(cc.c3b(255,255,255))
		else
			txtStatus:setString(cp.getUtils("DataUtils").formatOnlineStatus(simpleInfo.login))
			--txtStatus:setTextColor(cc.c4b(206,206,206,255))
			icon:setColor(cc.c3b(100,100,100))
		end
	end
	cp.getManager("ViewManager").initButton(icon, function()
		local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		if major_roleAtt.id == simpleInfo.id then --點擊的是自己
			return
		end 

		local req = {}
		req.roleID = simpleInfo.id
		req.zoneID = simpleInfo.zone
		self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
	end,1)
end

function FriendListLayer:getNotCachedPlayerList()
	local friendData = cp.getUserData("UserFriend"):getFriendData()
	local playerSimpleList = {}
	local playerList = nil
	if self.selectIndex == 1 then
		playerList = friendData.friend_list
	elseif self.selectIndex == 2 then
		playerList = friendData.request_list
	elseif self.selectIndex == 3 then
		playerList = friendData.response_list
	elseif self.selectIndex == 4 then
		playerList = friendData.enemy_list
	end

	for _, playerInfo in ipairs(playerList) do
		local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(playerInfo.id)
		if playerInfo.id ~= 0 and (not playerSimpleInfo or not playerSimpleInfo.career) then
			table.insert(playerSimpleList, {
				id = playerInfo.id,
				zone = playerInfo.zone
			})
		end
	end

	return playerSimpleList
end

function FriendListLayer:updateFriendView()
	local nocachedList = self:getNotCachedPlayerList()
	if #nocachedList > 0 then
		local req = {}
		req.player_list = nocachedList
		self:doSendSocket(cp.getConst("ProtoConst").GetRoleSimpleReq, req)
		return
	end
	local friendData = cp.getUserData("UserFriend"):getFriendData()
	local playerSimpleData = cp.getUserData("UserFriend"):getValue("PlayerSimpleData")
	self.Panel_List:setVisible(false)
	self.Panel_Req:setVisible(false)
	self.Panel_Rsp:setVisible(false)
	self.Panel_Black:setVisible(false)
	local textureName = "ui_friend_module33_haoyou_haoyouliebiao.png"
	self.Button_FriendList:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
	textureName = "ui_friend_module33_haoyou_haoyoushenqing.png"
	self.Button_FriendReq:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
	textureName = "ui_friend_module33_haoyou_shenqingliebiao.png"
	self.Button_FriendRsp:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
	textureName = "ui_friend_module33_haoyou_jianghuchoudi.png"
	self.Button_FriendBlack:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
	if self.selectIndex == 1 then
		self.Panel_List:setVisible(true)
		textureName = "ui_friend_module33_haoyou_haoyouliebiao_xuanzhong.png"
		self.Button_FriendList:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		local model = self.Panel_List:getChildByName("Image_ListModel")
		model:setVisible(false)
		local txtNum = self.Panel_List:getChildByName("Text_Num")
		txtNum:setString(string.format("%d/%d", #friendData.friend_list, friendData.max_friend))
		local listView = self.Panel_List:getChildByName("ListView_List")
		self:sortPlayerList(friendData.friend_list)
		for i, playerInfo in ipairs(friendData.friend_list) do
			local img = listView:getItem(i-1)
			if not img then
				img = model:clone()
				listView:insertCustomItem(img, i-1)
				img:setName(playerInfo.id)
			end
			img:setVisible(true)
			local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(playerInfo.id)
			if playerSimpleInfo and playerSimpleInfo.career then
				self:fillPlayerInfo(img, playerSimpleInfo)
			end
			local btnFight = img:getChildByName("Button_Fight")
			local btnDelete = img:getChildByName("Button_Delete")
			cp.getManager("ViewManager").initButton(btnFight, function()
				self.fightInfo = {name=playerSimpleInfo.name}
				local req = {}
				req.id = playerInfo.id
				req.zone = playerInfo.zone
				self:doSendSocket(cp.getConst("ProtoConst").FriendFightReq, req)
			end)
			
			cp.getManager("ViewManager").initButton(btnDelete, function()
				local function comfirmFunc()
					local req = {}
					req.id = playerInfo.id
					req.zone = playerInfo.zone
					self:doSendSocket(cp.getConst("ProtoConst").DeleteFriendReq, req)
				end
	
				local contentTable = {
					{type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="是否確定刪除好友？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1,verticalAlign="middle"},
				}
				cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
			end)
		end

		local count = listView:getChildrenCount()
		for i=#friendData.friend_list, count-1 do
			listView:removeItem(i)
		end
	elseif self.selectIndex == 2 then
		self.Panel_Req:setVisible(true)
		textureName = "ui_friend_module33_haoyou_haoyoushenqing_xuanzhong.png"
		self.Button_FriendReq:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		local model = self.Panel_Req:getChildByName("Image_ListModel")
		model:setVisible(false)
		local listView = self.Image_req_bg:getChildByName("ListView_List")
		self:sortPlayerList(friendData.request_list)
		for i, requestInfo in ipairs(friendData.request_list) do
			local img = listView:getItem(i-1)
			if not img then
				img = model:clone()
				listView:insertCustomItem(img, i-1)
				img:setName(requestInfo.id)
			end
			img:setVisible(true)
			local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(requestInfo.id)
			if playerSimpleInfo and playerSimpleInfo.career then
				self:fillPlayerInfo(img, playerSimpleInfo)
			end

			local btnConfirm = img:getChildByName("Button_Confirm")
			if requestInfo.replied == 1 then
				btnConfirm:setEnabled(false)
			else
				btnConfirm:setEnabled(true)
			end
			cp.getManager("ViewManager").initButton(btnConfirm, function()
				btnConfirm:setEnabled(false)
				local req = {}
				req.player_info = {}
				req.player_info.id = requestInfo.id
				req.player_info.zone = requestInfo.zone
				self:doSendSocket(cp.getConst("ProtoConst").AddFriendReq, req)
			end)
		end

		local searchBtn = self.Panel_top:getChildByName("Button_Search")
		local otherBtn = self.Panel_Req:getChildByName("Button_Other")
		cp.getManager("ViewManager").initButton(searchBtn, function()
			local txtName = self.Panel_top:getChildByName("TextField_Count"):getString()
			local txtID = self.Panel_top:getChildByName("TextField_ID"):getString()
			local req = {}
			req.search_type = 0
			local key = txtName
			if key:len() == 0 then
				req.search_type = 1
				key = txtID
			else
				req.search_type = 2
				key = txtName
			end

			if key:len() == 0 then
				req.search_type = 1
				return
			end
			
			req.name = key
			self:doSendSocket(cp.getConst("ProtoConst").SearchPlayerReq, req)
		end)

		cp.getManager("ViewManager").initButton(otherBtn, function()
			local req = {}
			self:doSendSocket(cp.getConst("ProtoConst").ChangeSearchListReq, req)
			--listView:removeAllItems()
		end)

		local count = listView:getChildrenCount()
		for i=#friendData.request_list, count-1 do
			listView:removeItem(i)
		end
	elseif self.selectIndex == 3 then
		self.Panel_Rsp:setVisible(true)
		textureName = "ui_friend_module33_haoyou_shenqingliebiao_xuanzhong.png"
		self.Button_FriendRsp:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		local model = self.Panel_Rsp:getChildByName("Image_ListModel")
		local txtNum = self.Panel_Rsp:getChildByName("Text_Num")
		txtNum:setString(string.format("%d/%d", #friendData.response_list, 30))
		model:setVisible(false)
		local listView = self.Panel_Rsp:getChildByName("ListView_List")
		self:sortPlayerList(friendData.response_list)
		for i, requestInfo in ipairs(friendData.response_list) do
			local img = listView:getItem(i-1)
			if not img then
				img = model:clone()
				listView:insertCustomItem(img, i-1)
				img:setName(requestInfo.id)
			end
			img:setVisible(true)
			local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(requestInfo.id)
			if playerSimpleInfo and playerSimpleInfo.career then
				self:fillPlayerInfo(img, playerSimpleInfo)
			end

			local btnReject = img:getChildByName("Button_Reject")
			local btnAgree = img:getChildByName("Button_Agree")
			cp.getManager("ViewManager").initButton(btnAgree, function()
				local req = {}
				req.player_list={
					{
						id = requestInfo.id,
						zone = requestInfo.zone
					}
				}
				self:doSendSocket(cp.getConst("ProtoConst").AgreeRequestReq, req)
			end)

			cp.getManager("ViewManager").initButton(btnReject, function()
				local req = {}
				req.player_list={
					{
						id = requestInfo.id,
						zone = requestInfo.zone
					}
				}
				self:doSendSocket(cp.getConst("ProtoConst").DeclineRequestReq, req)
			end)
		end

		local btnAgreeAll = self.Panel_Rsp:getChildByName("Button_AgreeAll")
		local btnRejectAll = self.Panel_Rsp:getChildByName("Button_RejectAll")
		cp.getManager("ViewManager").initButton(btnAgreeAll, function()
			if #friendData.response_list > 0 then
				local req = {}
				req.player_list = {}
				for _, playerInfo in ipairs(friendData.response_list) do
					table.insert(req.player_list, {
						id=playerInfo.id,
						zone=playerInfo.zone,
					})
				end
				self:doSendSocket(cp.getConst("ProtoConst").AgreeRequestReq, req)
			end
		end)

		cp.getManager("ViewManager").initButton(btnRejectAll, function()
			if #friendData.response_list > 0 then
				local req = {}
				req.player_list = {}
				for _, playerInfo in ipairs(friendData.response_list) do
					table.insert(req.player_list, {
						id=playerInfo.id,
						zone=playerInfo.zone,
					})
				end
				self:doSendSocket(cp.getConst("ProtoConst").DeclineRequestReq, req)
			end
		end)

		local count = listView:getChildrenCount()
		for i=#friendData.response_list, count-1 do
			listView:removeItem(i)
		end
	elseif self.selectIndex == 4 then
		self.Panel_Black:setVisible(true)
		textureName = "ui_friend_module33_haoyou_jianghuchoudi_xuanzhong.png"
		self.Button_FriendBlack:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
		local model = self.Panel_Black:getChildByName("Image_ListModel")
		local txtNum = self.Panel_Black:getChildByName("Text_Num")
		txtNum:setString(string.format("%d/%d", #friendData.enemy_list, 30))
		model:setVisible(false)
		local listView = self.Panel_Black:getChildByName("ListView_List")
		self:sortPlayerList(friendData.enemy_list)
		for i, requestInfo in ipairs(friendData.enemy_list) do
			local img = listView:getItem(i-1)
			if not img then
				img = model:clone()
				listView:insertCustomItem(img, i-1)
				img:setName(requestInfo.id)
			end
			img:setVisible(true)
			local playerSimpleInfo = cp.getUserData("UserFriend"):getPlayerSimpleInfo(requestInfo.id)
			if playerSimpleInfo and playerSimpleInfo.career then
				self:fillPlayerInfo(img, playerSimpleInfo)
			end

			local btnFight = img:getChildByName("Button_Fight")
			local btnDelete = img:getChildByName("Button_Delete")
			cp.getManager("ViewManager").initButton(btnFight, function()

				self.fightInfo = {name=playerSimpleInfo.name}
				local req = {}
				req.id = requestInfo.id
				req.zone = requestInfo.zone 
				self:doSendSocket(cp.getConst("ProtoConst").EnemyFightReq, req)
			end)

			cp.getManager("ViewManager").initButton(btnDelete, function()
				local req = {}
				req.player_info = {}
				req.player_info.id = requestInfo.id
				req.player_info.zone = requestInfo.zone 
				self:doSendSocket(cp.getConst("ProtoConst").DeleteEnemyReq, req)
			end)
		end

		local count = listView:getChildrenCount()
		for i=#friendData.enemy_list, count-1 do
			listView:removeItem(i)
		end
	end

	if cp.getUtils("NotifyUtils").needNotifyFriendRequest() then
		cp.getManager("ViewManager").addRedDot(self.Button_FriendRsp, cc.p(90,150))
	else
		cp.getManager("ViewManager").removeRedDot(self.Button_FriendRsp)
	end
end

function FriendListLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function FriendListLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
      	self:dispatchViewEvent(cp.getConst("EventConst").open_friend_view,false)
	elseif nodeName == "Button_FriendList" then
		if self.selectIndex ~= 1 then
			self.selectIndex = 1
			self:updateFriendView()
		end 
	elseif nodeName == "Button_FriendReq" then
		if self.selectIndex ~= 2 then
			self.selectIndex = 2
			self:updateFriendView()
		end
	elseif nodeName == "Button_FriendRsp" then
		if self.selectIndex ~= 3 then
			self.selectIndex = 3
			self:updateFriendView()
		end
	elseif nodeName == "Button_FriendBlack" then
		if self.selectIndex ~= 4 then
			self.selectIndex = 4
			local friendData = cp.getUserData("UserFriend"):getFriendData()
			local req = {}
			req.select_index = self.selectIndex
			req.player_list = friendData.enemy_list
			if #req.player_list ~= 0 then
				self:doSendSocket(cp.getConst("ProtoConst").GetPlayerOnlineReq, req)
			end
			self:updateFriendView()
		end
	end
end

function FriendListLayer:updateSearchFriendView(playerList)
	local listView = self.Image_req_bg:getChildByName("ListView_List")
	listView:removeAllItems()
	local model = self.Panel_Req:getChildByName("Image_ListModel")
	model:setVisible(false)
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	for i, playerInfo in ipairs(playerList) do
		local img = listView:getItem(i-1)
		if not img then
			img = model:clone()
			listView:insertCustomItem(img, i-1)
		end
		img:setVisible(true)
		local key = playerInfo.id
		self:fillPlayerInfo(img, playerInfo)

		local btnConfirm = img:getChildByName("Button_Confirm")
		btnConfirm:setEnabled(key ~= major_roleAtt.id)  -- 搜出的是自己則灰掉按鈕
		cp.getManager("ViewManager").initButton(btnConfirm, function()
			btnConfirm:setEnabled(false)
			local req = {}
			req.player_info = {}
			req.player_info.id = playerInfo.id
			req.player_info.zone = playerInfo.zone
			self:doSendSocket(cp.getConst("ProtoConst").AddFriendReq, req)
		end)
	end

	local count = listView:getChildrenCount()
	for i=#playerList, count-1 do
		listView:removeItem(i)
	end
end

function FriendListLayer:sortPlayerList(playerList)
	table.sort(playerList, function(a,b)
		local simpleInfoA = cp.getUserData("UserFriend"):getPlayerSimpleInfo(a.id)
		local simpleInfoB = cp.getUserData("UserFriend"):getPlayerSimpleInfo(b.id)
		if simpleInfoA and not simpleInfoB then
			return true
		elseif not simpleInfoA and simpleInfoB then
			return false
		elseif simpleInfoA and simpleInfoB then
			if simpleInfoA.status and not simpleInfoB.status then
				return true
			elseif not simpleInfoA.status and simpleInfoB.status then
				return false
			elseif simpleInfoA.status and simpleInfoB.status then
				return simpleInfoA.fight > simpleInfoB.fight
			elseif not simpleInfoA.status and not simpleInfoB.status then
				return simpleInfoA.login > simpleInfoB.login
			end
		end

		return false
	end)
end

function FriendListLayer:onEnterScene()
end

function FriendListLayer:onExitScene()
    self:unscheduleUpdate()
end

return FriendListLayer
