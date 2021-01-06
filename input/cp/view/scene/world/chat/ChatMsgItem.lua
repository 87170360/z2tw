
local BNode = require "cp.view.ui.base.BNode"
local ChatMsgItem = class("ChatMsgItem",BNode)

function ChatMsgItem:create()
    local node = ChatMsgItem.new()
    return node
end

function ChatMsgItem:initListEvent()
    self.listListeners = {}
end

function ChatMsgItem:onInitView()
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_chat/uicsb_chat_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_head"] = {name = "Panel_head"},
		["Panel_root.Panel_head.Image_head_bg"] = {name = "Image_head_bg"},
		["Panel_root.Panel_head.Image_head"] = {name = "Image_head",click="onHeadClick",clickScale=1},
		["Panel_root.Panel_head.Image_vip_bg"] = {name = "Image_vip_bg"},
		["Panel_root.Panel_head.Image_vip_bg.Image_vip"] = {name = "Image_vip"},
		["Panel_root.Panel_head.Image_level"] = {name = "Image_level"}, 
		["Panel_root.Panel_head.Image_level.Text_level"] = {name = "Text_level"},
		
		["Panel_root.Panel_name"] = {name = "Panel_name"},

		["Panel_root.Panel_content_system"] = {name = "Panel_content_system"},
		["Panel_root.Panel_content"] = {name = "Panel_content"},
	}
	
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.Panel_name:setTouchEnabled(false)
	self.Panel_content:setTouchEnabled(false)
	self.Panel_content_system:setTouchEnabled(false)
	self.Panel_head:setTouchEnabled(false)
	self.Panel_root:setTouchEnabled(false)
	ccui.Helper:doLayout(self.rootView)
end

function ChatMsgItem:onEnterScene()
	
end

--[[
message ChatChannelRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
    required int32 channel                  = 2;                    //0系統 1世界 2門派 3幫派 4個人
    repeated string content                 = 3;                    //內容
    required int64 stamp                    = 4;                    //時間戳
    optional int64 senderID                 = 5;                    //發送者roleid
    optional string senderName              = 6;                    //發送者名字
    optional int32 hierarchy                = 7;                    //發送者階級
    optional int32 career                   = 8;                    //發送者門派
    optional string face                    = 9;                    //發送者頭像
    optional int32 gender                   = 10;                   //發送者性別
    optional int32 gangRank                 = 11;                   //發送者門派地位
    optional int32 vip                      = 12;                   //發送者vip
    optional int32 level                    = 13;                   //發送者等級
}

]]

function ChatMsgItem:resetHeadInfo(msgInfo,isSelf)
	self.Panel_head:setVisible(msgInfo.channel ~= 0)
	if msgInfo.channel > 0 then
		self.Panel_head:setAnchorPoint(isSelf and cc.p(1,0.5) or cc.p(0,0.5))
		self.Panel_head:setPositionX(isSelf and self.Panel_root:getContentSize().width-6 or 6)
		self.Image_level:setPositionX(isSelf and 102 or 22)
		self.Image_head:setFlippedX(isSelf)

		local headIcon = "img/model/head/42_03.png"
		if msgInfo.face ~= nil and string.len(msgInfo.face) > 0 then
			headIcon = "img/model/head/" .. msgInfo.face .. ".png"
		end
		self.Image_head:loadTexture(headIcon,ccui.TextureResType.localType)
		
		local bg_icon = msgInfo.vip > 0 and "ui_chat_module33_liaotian_touxiangkuang.png" or "ui_common_module19_menpaibiwu_touxiangkuang.png"  
		self.Image_head_bg:loadTexture(bg_icon, ccui.TextureResType.plistType)
		self.Image_vip_bg:setVisible(msgInfo.vip > 0)
		if msgInfo.vip > 0 then  
			self.Image_vip:loadTexture("ui_chat_module33_liaotian_VIP" .. tostring(msgInfo.vip) .. ".png", ccui.TextureResType.plistType)
		end
		self.Text_level:setString(tostring(msgInfo.level))
	end
end


function ChatMsgItem:resetNameInfo(msgInfo,isSelf)
	self.Panel_name:setVisible(msgInfo.channel ~= 0)
	self.Panel_name:removeAllChildren()
	if msgInfo.channel > 0 then
		self.Panel_name:setAnchorPoint(isSelf and cc.p(1,0) or cc.p(0,0))
		self.Panel_name:setPositionX(isSelf and 473 or 140)
		local GameConst = cp.getConst("GameConst")

		-- 0系統 1世界 2門派 3幫派 4個人 5走馬燈
		local imgs = {	
			[0] = "ui_chat_module33_liaotian_pindao4.png",
			[1] = "ui_chat_module33_liaotian_pindao.png",
			[2] = "ui_chat_module33_liaotian_pindao5.png",
			[3] = "ui_chat_module33_liaotian_pindao3.png",
			[4] = "ui_chat_module33_liaotian_pindao2.png",
		}
		local channel = msgInfo.channel == 5 and 0 or msgInfo.channel

		local chartConfig = cp.getManager("ConfigManager").getItemByKey("GangEnhance", msgInfo.career)
		local career_name = chartConfig:getValue("Name")

		local contentTable = {}
		if isSelf then
			if msgInfo.channel == 4 then
				contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text="回覆 ", textColor=GameConst.ChatMsgColor}
			end
			local name = (msgInfo.channel == 4) and (msgInfo.receName or "神祕人") or msgInfo.senderName
			contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text=name, textColor=GameConst.ChatMsgColor, underLineEnable=true,underLineColor=GameConst.ChatMsgColor,underLineSize=2,touchCallBack = function(sender, event)
				log("chat name click ")
				dump(self.msgInfo)
				if self.clickCallBack then
					self.clickCallBack("name",self.msgInfo)
				end
			end}
	
			contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text=" [" .. career_name .. "]   ", textColor=GameConst.QualityTextColor[5], outLineColor=GameConst.QualityOutlineColor[5], outLineSize=2}

			contentTable[#contentTable + 1] = {type="image",filePath=imgs[channel],textureType=ccui.TextureResType.plistType}
		else
			contentTable[#contentTable + 1] = {type="image",filePath=imgs[channel],textureType=ccui.TextureResType.plistType}
			contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text=" [" .. career_name .. "]   ", textColor=GameConst.QualityTextColor[5], outLineColor=GameConst.QualityOutlineColor[5], outLineSize=2}
			contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text=msgInfo.senderName, textColor=GameConst.ChatMsgColor,underLineEnable=true,underLineColor=GameConst.ChatMsgColor,underLineSize=2,touchCallBack = function(sender, event)
				log("chat name click ")
				dump(self.msgInfo)
				if self.clickCallBack then
					self.clickCallBack("name",self.msgInfo)
				end
			end}
			if msgInfo.channel == 4 then
				contentTable[#contentTable + 1] = {type="ttf", fontSize=20,fontName="fonts/msyh.ttf", text=" 與你私聊", textColor=GameConst.QualityTextColor[1]}
			end
		end
		
	
		local richText = require("cp.view.ui.base.RichText"):create()
		richText:setAnchorPoint(isSelf and cc.p(1,0) or cc.p(0,0))
		richText:ignoreContentAdaptWithSize(false)
		richText:setContentSize(cc.size(300,40))
		richText:setHAlign(isSelf and cc.TEXT_ALIGNMENT_RIGHT or cc.TEXT_ALIGNMENT_LEFT)
		richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
		richText:setLineGap(1)
		
		for i=1,#contentTable do
			richText:addElement(contentTable[i])
		end
	   
		richText:formatText()
		local tsize = richText:getTextSize()
		richText:setPositionX(isSelf and self.Panel_name:getContentSize().width or 0)
		richText:setPositionY(0)
		richText:setTouchEnabled(true)
		self.Panel_name:addChild(richText)
	end
end

function ChatMsgItem:resetTextContent(msgInfo,isSelf)
	self.Panel_root:setContentSize(cc.size(620,msgInfo.channel == 0 and 100 or 140))
	self.Panel_root:setPositionY(msgInfo.channel == 0 and 100 or 140)
	self.Panel_content_system:setVisible(msgInfo.channel == 0)
	self.Panel_content_system:removeAllChildren()
	self.Panel_content:setVisible(msgInfo.channel ~= 0)
	self.Panel_content:removeAllChildren()

	local textContentTable,emoticonType = self:convertContent(msgInfo)
	local richText = nil
	local richTextSize = nil
	local max_width = msgInfo.channel ~= 0 and 425 or 570
	richText,richTextSize = self:createRichText(textContentTable,max_width)

	if richText then
		if msgInfo.channel > 0 then
			self.Panel_content:removeBackGroundImage()
			self.Panel_content:setAnchorPoint(isSelf and cc.p(1,1) or cc.p(0,1))
			if not emoticonType then
				local bg1 = isSelf and "ui_chat_module33_liaotian_qipao2.png" or "ui_chat_module33_liaotian_qipao.png"
				self.Panel_content:setBackGroundImage(bg1,ccui.TextureResType.plistType)
				self.Panel_content:setBackGroundImageScale9Enabled(true)
				self.Panel_content:setBackGroundImageCapInsets({x = isSelf and 50 or 100, y = 55, width = 307, height = 2})

				local newHeight = math.max(richTextSize.height+20,72) --默認高72
				local newWidth = math.min(richTextSize.width+40, 457)  --默認最大寬457
				newWidth = math.max(newWidth, 150)	
				self.Panel_content:setContentSize(cc.size(newWidth,newHeight))
				
				-- richText:setPositionY(newHeight <= 60 and (self.Panel_content:getContentSize().height - richTextSize.height) or newHeight/2)
				richText:setPositionY(self.Panel_content:getContentSize().height - newHeight/2)
				richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)

				self.Panel_content:addChild(richText)
				-- self.Panel_content:setPositionY(richTextSize.height > 30 and 78 or 78)
			
			else
				self.Panel_content:setContentSize(cc.size(457,72))
				richText:setPositionY(32)
				self.Panel_content:addChild(richText)
			end

			self.Panel_content:setPositionX(isSelf and 495 or 123)
		
			richText:setPositionX( isSelf and (emoticonType and 340 or 10) or (emoticonType and 20 or 25) )
			
		else

			richText:setPosition(cc.p(0,self.Panel_content_system:getContentSize().height/2))
			self.Panel_content_system:addChild(richText)
		end
	end
end

function ChatMsgItem:reset(msgInfo)
	msgInfo.channel = msgInfo.channel == 5 and 0 or msgInfo.channel 
	msgInfo.vip =  msgInfo.vip or 0
	msgInfo.level = msgInfo.level or 0

	self.msgInfo = msgInfo
	
	self.Panel_content_system:setVisible(msgInfo.channel == 0)

	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local isSelf = msgInfo.senderID == major_roleAtt.id

	self:resetHeadInfo(self.msgInfo,isSelf)
	self:resetNameInfo(self.msgInfo,isSelf)
	self:resetTextContent(self.msgInfo,isSelf)
	
	ccui.Helper:doLayout(self.Panel_root)
end


function ChatMsgItem:createRichText(contentTable,maxW)
	if table.nums(contentTable) == 0 then
		return nil,cc.size(0,0)
	end
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(maxW,100))
    richText:setAnchorPoint(cc.p(0,0.5))
	richText:ignoreContentAdaptWithSize(false)
    richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
	richText:setLineGap(0)
	richText:setName("richText")
	richText:formatText()
    local txtSize = richText:getTextSize()
	richText:setContentSize(cc.size(maxW,txtSize.height))
	richText:setTouchEnabled(true)
    return richText,txtSize
end

function ChatMsgItem:onHeadClick(sender)
	dump(self.msgInfo)
	local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local isSelf = self.msgInfo.senderID == major_roleAtt.id
	if not isSelf then
		if self.clickCallBack then
			self.clickCallBack("headIcon",self.msgInfo)
		end
	end
end


function ChatMsgItem:getItemContentSize()
	return self.Panel_chat_item:getContentSize()
end


function ChatMsgItem:convertContent(msgInfo)
	--msgInfo.content[1] = "<role=(name='狂刀無敵',roleID=111,zoneID=1,npc=0)>" --"<item=(id=19,uuid='1111',roleID=111,zoneID=1)>"
	local contentCount = table.nums(msgInfo.content)

	local contentTable = {}
	local emoticonType = false
	for i=1,contentCount do
		local contentInfo = msgInfo.content[i]
		if string.find(contentInfo,"<emoticon=") then
			local idx = string.sub(contentInfo,string.len("<emoticon=")+1, string.len(contentInfo)-1)
			local imageID = tonumber(idx)
			if imageID ~= nil then
				contentTable[#contentTable + 1] = {type="image", filePath="img/icon/emoticon/" ..tostring(imageID) .. ".png",textureType=ccui.TextureResType.localType} --,opacity=204,blink=true,blinkInterval=3},
			end
			emoticonType = true
		elseif string.find(contentInfo,"<item=") then  -- <item=(id=19,uuid="1111",roleID=111,zoneID=1)>
			self.msgInfo.itemInfo = {}
			local itemID = nil
			local itemName = ""
			local itemIcon = ""
			local itemColor = ""
			local sub = string.sub(contentInfo,string.len("<item=(")+1, string.len(contentInfo)-2) -- id=19,uuid="1111",roleID=111,zoneID=1
			local arr = {}
			string.loopSplit(sub,",=",arr)
			for i=1,#arr do
				if arr[i][1] == "id" then
					itemID = tonumber(arr[i][2])
					local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemID)
					if cfgItem ~= nil then
						itemName = cfgItem:getValue("Name")
						local Hierarchy = cfgItem:getValue("Hierarchy")
						Hierarchy = Hierarchy or 1
						itemColor = cp.getConst("GameConst").QualityTextColor[Hierarchy]
						itemIcon = cfgItem:getValue("Icon")
						self.msgInfo.itemInfo.itemID = itemID
						
					end
				elseif arr[i][1] == "uuid" then
					local uuid = tostring(arr[i][2])
					self.msgInfo.itemInfo.itemUID = uuid
				elseif arr[i][1] == "roleID" then
					local roleID = tostring(arr[i][2])
					self.msgInfo.itemInfo.roleID = roleID
				elseif arr[i][1] == "zoneID" then
					local zoneID = tostring(arr[i][2])
					self.msgInfo.itemInfo.zoneID = zoneID
				end
			end
			
			if itemID ~= nil then
				
				contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=itemName,verticalAlign="middle", textColor=itemColor,underLineEnable=true,underLineColor=itemColor,underLineSize=1,touchCallBack = function(sender, event) 
					log("chat item click ")
					dump(self.msgInfo)
					local req = {}
					req.roleID = self.msgInfo.itemInfo.roleID
					req.zoneID = self.msgInfo.itemInfo.zoneID
					req.itemUID = self.msgInfo.itemInfo.itemUID
					self:doSendSocket(cp.getConst("ProtoConst").ViewItemReq, req)
				end}
				-- contentTable[#contentTable + 1] = {type="image", filePath=itemIcon,textureType=ccui.TextureResType.localType}
			end
		elseif string.find(contentInfo,"<role=") then  -- <role=(name="狂刀無敵",roleID=111,zoneID=1,npc=0)>
			self.msgInfo.roleInfo = {}
			local roleName = ""
			local npcid = 0
			local sub = string.sub(contentInfo,string.len("<role=(")+1, string.len(contentInfo)-2) -- roleID=111,zoneID=1,npc=0
			local arr = {}
			string.loopSplit(sub,",=",arr)
			for i=1,#arr do
				if arr[i][1] == "name" then
					roleName = arr[i][2]
					self.msgInfo.roleInfo.name = roleName
				elseif arr[i][1] == "npc" then
					npcid = tonumber(arr[i][2])
					self.msgInfo.roleInfo.npcid = npcid
				elseif arr[i][1] == "roleID" then
					local roleID = tonumber(arr[i][2])
					self.msgInfo.roleInfo.roleID = roleID
				elseif arr[i][1] == "zoneID" then
					local zoneID = tonumber(arr[i][2])
					self.msgInfo.roleInfo.zoneID = zoneID
				end
			end
			if npcid and npcid > 0 then
				--顯示npc的名字
			end
			contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=roleName, textColor=cc.c4b(255,0,0,255),underLineEnable=true,underLineColor=cc.c4b(0,255,0),underLineSize=1,touchCallBack =	function(sender, event) 
	
				dump(self.msgInfo)
				local req = {}
				req.roleID = self.msgInfo.roleInfo.roleID
				req.zoneID = self.msgInfo.roleInfo.zoneID
				self:doSendSocket(cp.getConst("ProtoConst").ViewPlayerReq, req)
			end}
			
		elseif string.find(contentInfo,"<fight=") then -- 戰鬥記錄
			-- <fight=(combat_id=1111,name="xxx")>
			self.msgInfo.fightInfo = {}
			
			local sub = string.sub(contentInfo,string.len("<fight=(")+1, string.len(contentInfo)-2) -- roleID=111,zoneID=1,npc=0
			local arr = {}
			string.loopSplit(sub,",=",arr)
			for i=1,#arr do
				if arr[i][1] == "name" then
					self.msgInfo.fightInfo.name =  arr[i][2]
				elseif arr[i][1] == "combat_id" then
					self.msgInfo.fightInfo.combat_id = tonumber(arr[i][2])
				elseif arr[i][1] == "combat_type" then
					self.msgInfo.fightInfo.combat_type = tonumber(arr[i][2])
				elseif arr[i][1] == "result" then
					self.msgInfo.fightInfo.result = tonumber(arr[i][2])
				elseif arr[i][1] == "rank" then
					self.msgInfo.fightInfo.rank = tonumber(arr[i][2])
				elseif arr[i][1] == "floor" then
					self.msgInfo.fightInfo.floor = tonumber(arr[i][2])
				elseif arr[i][1] == "place" then
					self.msgInfo.fightInfo.place = arr[i][2]
				elseif arr[i][1] == "partID" then
					self.msgInfo.fightInfo.partID = tonumber(arr[i][2])
				elseif arr[i][1] == "difficut" then
					self.msgInfo.fightInfo.difficut = tonumber(arr[i][2])
				elseif arr[i][1] == "hierarchy" then
					self.msgInfo.fightInfo.hierarchy = tonumber(arr[i][2])
				elseif arr[i][1] == "career" then
					self.msgInfo.fightInfo.career = tonumber(arr[i][2])
				end
			end

			if self.msgInfo.fightInfo.combat_type ~= nil and self.msgInfo.fightInfo.combat_id ~= nil and self.msgInfo.fightInfo.combat_id > 0 then
				local content = cp.getManager("GDataManager"):getShareChatMsgContent( self.msgInfo.fightInfo )
				if content then
					for j=1,table.nums(content) do
						contentTable[#contentTable + 1] = content[j]
					end
					contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text="查看 ", textColor=cc.c4b(255,0,0,255),underLineEnable=true,underLineColor=cc.c4b(0,0,0,255),underLineSize=2,touchCallBack =	
							function(sender, event)
								dump(self.msgInfo)
								local req = {}
								req.combat_id = self.msgInfo.fightInfo.combat_id
								req.side = 0 --防守方 0是攻擊方
								self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
							end}
				end
			end
		elseif string.find(contentInfo,"<seekhelp=") then -- 大俠挑戰求助訊息，點擊大俠名字
			-- <seekhelp=(npcid=1,npc_uid="aaaaaa",sender_uid="bbbb",hierarchy=1)>
			self.msgInfo.seekHelpInfo = {}
			local roleName = ""
			local npcid = 0
			local sub = string.sub(contentInfo,string.len("<seekhelp=(")+1, string.len(contentInfo)-2) -- npcid=1,npc_uid="aaaaaa",sender_uid="bbbb"
			local arr = {}
			string.loopSplit(sub,",=",arr)
			for i=1,#arr do
				if arr[i][1] == "npcid" then
					npcid = tonumber(arr[i][2])
					self.msgInfo.seekHelpInfo.npcid = npcid
				elseif arr[i][1] == "npc_uid" then
					self.msgInfo.seekHelpInfo.npc_uid = arr[i][2]
				elseif arr[i][1] == "sender_uid" then
					self.msgInfo.seekHelpInfo.sender_uid = arr[i][2]
				elseif arr[i][1] == "hierarchy" then
					self.msgInfo.seekHelpInfo.hierarchy = tonumber(arr[i][2])
				elseif arr[i][1] == "sender_roleid" then
					self.msgInfo.seekHelpInfo.sender_roleid = tonumber(arr[i][2])
				end
			end

			if npcid > 0 then
				local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
				if cfgItem ~= nil then
					roleName = cfgItem:getValue("Name")
				end
			end
			local msgHelp = {
				[1] = {"唉！我在與江湖好漢", "切磋時不慎落敗，懇請大俠指點迷津！"},
				[2] = {"大哥，我在與", "切磋時棋差一著，被人吊起來打，能不能幫兄弟找回點場子？"},
				[3] = {"大哥，那個","竟敢大言不慚吹噓自己乃天下無敵手，要不要給點顏色瞧瞧！"},
				[4] = {"兄弟們，喝酒誤事，美色害人啊！","趁我大意突施暗手，我這臉面……能不能勞煩兄弟們幫我教訓教訓她？"} 
			}
			local index = math.random(1,4)
			index = math.random(1,4)
			contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text="【求助】 ", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineColor=cp.getConst("GameConst").QualityOutlineColor[2], outLineSize=2}
			contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=msgHelp[index][1], textColor=cp.getConst("GameConst").ChatMsgColor}
			contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=roleName, textColor=cc.c4b(255,0,0,255),underLineEnable=true,underLineColor=cc.c4b(0,255,0),underLineSize=1,touchCallBack =	function(sender, event) 
				dump(self.msgInfo.seekHelpInfo)
				
				cp.getUserData("UserChatData"):setValue("seekHelpInfo", self.msgInfo.seekHelpInfo)
				local req = {}
				req.heroUUID = self.msgInfo.seekHelpInfo.npc_uid
				req.inviterUID = self.msgInfo.seekHelpInfo.sender_uid
				req.inviterRoleID = self.msgInfo.seekHelpInfo.sender_roleid
				
				self:doSendSocket(cp.getConst("ProtoConst").ViewHeroStateReq, req)
				
			end}
			contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=msgHelp[index][2], textColor=cp.getConst("GameConst").ChatMsgColor}

		else
			-- local channel = msgInfo.channel  -- (0系統 1世界 2門派 3幫派 4個人)  幫派發出的消息全用綠色字；門派發出的用藍色字；私聊發出的用紫紅色；系統消息用淡黃色。

			-- local cfg = cp.getManager("ConfigManager").getItemByKey("TextFormat","lamp9")
			-- contentInfo = cfg:getValue("Format")
			
			local function trim(s)
				return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
			end
			contentInfo = trim(contentInfo)

			local beginStr = string.sub(contentInfo,1,2)
			local endStr = string.sub(contentInfo,-4,-1)
			if beginStr == "<t" and endStr == "</t>" then
				if string.find(contentInfo,[[tc="F6E3D0FF"]]) then
					contentInfo = string.gsub(contentInfo,[[tc="F6E3D0FF"]], [[tc="5D330DFF"]])
					contentInfo = string.gsub(contentInfo,[[fs="20"]], [[fs="22"]])
				end
				contentTable[#contentTable + 1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text="【系統】 ", textColor=cc.c4b(255,255,255,255),outLineColor=cc.c4b(111,111,111,255), outLineSize=2}
				local tblList = cp.getUtils("RichTextUtils").ParseRichText(contentInfo,true)
				for i=1,#tblList do
					contentTable[#contentTable + 1] = tblList[i]
				end
			else
				contentTable[#contentTable + 1] = {type="ttf", fontSize=18,fontName="fonts/msyh.ttf", text=contentInfo, textColor= cp.getConst("GameConst").ChatMsgColor}
			end
		end
	end
	return contentTable,emoticonType
end

function ChatMsgItem:setClickCallBack(cb)
	self.clickCallBack =cb
end

return ChatMsgItem
