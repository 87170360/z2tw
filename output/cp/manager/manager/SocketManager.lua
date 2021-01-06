--socket網路通信管理

local SocketManager = class("SocketManager")

SocketManager.RESPONSE_SUCCESS = 0
SocketManager.RESPONSE_TIMEOUT = 1
SocketManager.RESPONSE_FAIL = 2
SocketManager.RESPONSE_READ = 3
SocketManager.RESPONSE_CLOSE = 4
SocketManager.RESPONSE_READ_FAIL = 5

SocketManager.STATUS_UNCONNECT = "UN_CONNECT"
SocketManager.STATUS_CONNECT = "CONNECT"

SocketManager.STATUS_NONE_SEND = "NONE_SEND" --沒有消息請求
SocketManager.STATUS_WAIT_RECIVE = "WAIT_RECIVE"--請求消息已發送等待接收返回消息
SocketManager.STATUS_WAIT_RECONNECT = "WAIT_RECONNECT"--等待重新連接

SocketManager.TIME_OUT = 1000

function SocketManager:create()
    local ret =  SocketManager.new() 
    ret:init()
    return ret
end  

function SocketManager:init()
	self.url_list = {}  --登錄url列表(最多選3個出來)
	self.curUseLoginUrl = nil --當前正在嘗試登錄的url
	self.lastCollectSuccessUrl = nil --上次嘗試連接成功的url
	self.loginUrlTried = {} --已經登錄試過的url列表
	self.allCollectedFail = nil -- 是否所有都嘗試連接過2次

    self.socketStatus = SocketManager.STATUS_UNCONNECT
    self.socket = cp.CpSocket:create()
    self.socket:addSocketStatusEventListener(handler(self, self.socketStatusCallback))
    self.socket:addSocketReadEventListener(handler(self, self.socketReadCallback))
	
	self.msgSendStatus = SocketManager.STATUS_NONE_SEND
	self.hasShowWaiting = false

    self:registerCallBack()
	self.sendDataList = {}
	self.sendList = {}
	
	self.isReconnectNow = false
	self.curMsgIndex = 0
	self.beginConnect = 0
	
   if self.scheduleEntryId then
       cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
       self.scheduleEntryId = nil
   end
   self.canSendMsg = true
end

function SocketManager:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function SocketManager:clearSendData()
	self.sendDataList = {}
	self.sendList = {}
	self.curMsgIndex = 0
	self.msgSendStatus = SocketManager.STATUS_NONE_SEND
	
end

function SocketManager:doDisConnect()
    self.socket:doDisConnect()
    self:clearSendData()
	self.canSendMsg = true
end

function SocketManager:startUpdate()
	self:stopUpdate()
	if self.messageboxShow then
		return
	end
	self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),0.5,false)
	log("tm startUpdate = " .. os.time())
	self:_update(0) --直接調用一次
end

function SocketManager:stopUpdate()
   if self.scheduleEntryId then
       cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
       self.scheduleEntryId = nil
   end
end

function SocketManager:doConnect(isPlayerAuth)
	local hasLogin = cp.getGameData("GameLogin"):getValue("hasLogin")
    --log("SocketManager:doConnect , hasLogin = " .. tostring(hasLogin))
    local newIp = cp.getGameData("GameNet"):getValue("ip")
    local newPort = cp.getGameData("GameNet"):getValue("port")
    local hasCollectGameServer = (newIp ~= nil and newPort ~= nil)
	if hasLogin or isPlayerAuth or hasCollectGameServer then
		log("SocketManager:doConnect , connect game")
		self:doConnectGame()
	else
		log("SocketManager:doConnect , connect login")
		self:doConnectLogin()
	end
end


--連接登錄伺服器
function SocketManager:doConnectLogin()
	self.isConnectLoginNow = true
	
	if self.url_list == nil or next(self.url_list) == nil then
		self.url_list = {}
		local channelName = cp.getManualConfig("Channel").channel	
		local loginUrl = cp.getManager("GDataManager"):getGameConfigByChannel(channelName, "loginUrl")
		local all_url_list = string.split(loginUrl,"|")
		if table.nums(all_url_list) <= 3 then
			self.url_list = all_url_list
		else
			while (table.nums(self.url_list) < 3) do
				local idx = math.random(1,table.nums(all_url_list))
				if table.arrIndexOf(self.url_list,all_url_list[idx]) == -1 then
					self.url_list[table.nums(self.url_list) + 1] = all_url_list[idx]
				end
			end
		end

		for i=1,table.nums(self.url_list) do
			self.loginUrlTried[table.nums(self.loginUrlTried) + 1] = {fail_count = 0, url = self.url_list[i]}
		end
	end
	if self.lastCollectSuccessUrl ~= nil then
		self.curUseLoginUrl = self.lastCollectSuccessUrl
	else
		self.curUseLoginUrl,self.allCollectedFail = self:getNewLoginUrl()
	end
	
	log("SocketManager:doConnectLogin()  111")
	log("last = " .. tostring(self.lastCollectSuccessUrl))
	log("cur = " .. tostring(self.curUseLoginUrl))
	dump(self.loginUrlTried)

	log("SocketManager:doConnectLogin()  222")

	local strList = string.split(self.curUseLoginUrl,":")
	if string.sub(strList[1],1,4) == "192." or string.sub(strList[1],1,4) == "119." then
		-- 內網直接連接ip
		-- log("SocketManager:doConnect, ip = " .. strList[1] .. ", port = " .. strList[2])
		self.socket:doConnect(strList[1], strList[2],SocketManager.TIME_OUT)
	else
		-- log("SocketManager:doConnectLogin,  domain = " .. strList[1] .. ", port = " .. strList[2])
		self.socket:doConnectByDomain(strList[1], strList[2],SocketManager.TIME_OUT)
	end
end

function SocketManager:getNewLoginUrl()
	if table.nums(self.url_list) == 1 then
		return self.url_list[1]
	end

	if self.loginUrlTried ~= nil and next(self.loginUrlTried) ~= nil then
		table.sort(self.loginUrlTried,function(a,b)
			if a and b then
				return a.fail_count < b.fail_count
			end
			return false
		end)

		return self.loginUrlTried[1].url
	end

	local allCollectedFail = true 
	return self.url_list[1],allCollectedFail
end


function SocketManager:refreshFailCollect(curUseUrl)
	for i,info in pairs(self.loginUrlTried) do
		if info.url == curUseUrl then
			self.loginUrlTried[i].fail_count = self.loginUrlTried[i].fail_count + 1 
			if self.lastCollectSuccessUrl and self.lastCollectSuccessUrl == curUseUrl then
				if self.loginUrlTried[i].fail_count > 2 then
					self.lastCollectSuccessUrl = nil --3次連接都失敗，重置上次保存的
				end
			end
			break
		end
	end
end

function SocketManager:doConnectGame()
	local newIp = cp.getGameData("GameNet"):getValue("ip")
	local newPort = cp.getGameData("GameNet"):getValue("port")
	self.isConnectLoginNow = false
	-- log("SocketManager:doConnectGame()  newIp = " .. newIp .. ", newPort = " .. newPort)
	if newIp == nil or newPort == nil then  --沒有數據，需求返回登錄重新獲取			
		--是否返回重新登錄
		-- local function comfirmFunc()
        --     cp.getManager("AppManager"):reLogin()
		-- end
		-- local content = "網路斷開，嘗試重新連接失敗，是否返回重新登錄！"--"由於您長時間未操作，與伺服器連接已斷開，是否重新連接？"
		
		-- cp.getManager("ViewManager").showNetWorkReconnectMessageBox("網路斷開提示",content,2,comfirmFunc,nil)
		
	else
		self.socket:doConnect(newIp,newPort,SocketManager.TIME_OUT)
	end
end

function SocketManager:tryReconnectGame()
	self.socket:doDisConnect() --先關閉網路，再設置isReconnectNow為true

	self.canSendMsg = false
	self.isReconnectNow = true
	log("tryReconnectGame tm = " .. os.time())
	self:doConnect()
end


function SocketManager:doSend(proto,data)
    local addData = {
        proto = proto,
        data = data
    }
    
    -- table.insert(self.sendList, addData )
    -- log("self.sendList num =" .. tostring(#self.sendList))
   self.sendingData = addData
   self:doSendNow(addData.proto , addData.data)
end

function SocketManager:_listSend()
    if #self.sendList  >0 then
        local addData = self.sendList[1]
        self:doSendNow(addData.proto , addData.data)
    end
end


function SocketManager:doSendNow(proto,data)
    data = data or {}
    local netProto = cp.getManualConfig("NetProto")
    local tb = table.getChildTable(netProto,{proto=proto},true)
    if tb and tb.key then
        log("準備發送消息-->" .. proto )
        if self.socketStatus == SocketManager.STATUS_UNCONNECT then
		   	if self.isReconnectNow == false then
				self.msgSendStatus = SocketManager.STATUS_WAIT_RECONNECT
				log("SocketManager:doSendNow STATUS_WAIT_RECONNECT")
				self:startUpdate()
			end
        end
        if self.socketStatus == SocketManager.STATUS_CONNECT then
            local protoData = cp.getManager("ProtobufManager"):encode("protocal."..proto, data)

            --發送數據
			self.socket:doSend(tb.key,protoData,0,0)
			log("消息(" .. proto .. ")已發送，data=" ,data)

			self.msgSendStatus = SocketManager.STATUS_WAIT_RECIVE
			log("SocketManager:doSendNow STATUS_WAIT_RECIVE")
			self:startUpdate()
            
        end
        
    end
end


function SocketManager:socketStatusCallback(type)
	-- local newIp = cp.getGameData("GameNet"):getValue("ip")
	-- local newPort = cp.getGameData("GameNet"):getValue("port")
	
    if type == SocketManager.RESPONSE_SUCCESS then
        if self.socketStatus == SocketManager.STATUS_UNCONNECT then
			self.socketStatus = SocketManager.STATUS_CONNECT       
			
			if self.curUseLoginUrl ~= nil then  --不為nil，表示當前是連接登錄系統
				self.lastCollectSuccessUrl = self.curUseLoginUrl  --保存上次登錄成功的url
				log("socket:連接成功！,self.isReconnectNow = " .. tostring(self.isReconnectNow) .. ",cur url =" .. self.curUseLoginUrl)
			else
				log("socket:連接成功！,self.isReconnectNow = " .. tostring(self.isReconnectNow) )  				
			end

            if self.isReconnectNow then
				self.isReconnectNow = false

				self:stopUpdate()
				cp.getManager("ViewManager").removeWaitingLayer()
				self.hasShowWaiting = false
				self.msgSendStatus = SocketManager.STATUS_NONE_SEND
				if not self.autoConnect then
					cp.getManager("ViewManager").gameTip("網路連接成功！")
				end
				local newIp = cp.getGameData("GameNet"):getValue("ip")
				local newPort = cp.getGameData("GameNet"):getValue("port")
				local token = cp.getUserData("UserLogin"):getValue("user_token")
				if token ~= nil and token ~= "" and newIp ~= nil and newPort ~= nil then
					local serverinfo = cp.getGameData("GameLogin"):getValue("selectServerInfo")
					local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
					local info = {}
					info.zoneid = serverinfo.id
					info.token = cp.getUserData("UserLogin"):getValue("user_token")
					info.resetTime = majorRole.resetTime
					self:doSendNow(cp.getConst("ProtoConst").ReconnectReq, info)

				end
			end  
        end
    elseif type == SocketManager.RESPONSE_TIMEOUT then
        self.socketStatus = SocketManager.STATUS_UNCONNECT
		log("socket:連接失敗！超時")
		self.isReconnectNow = false
		self:refreshFailCollect(self.curUseLoginUrl)
    elseif type == SocketManager.RESPONSE_FAIL then
        self.socketStatus = SocketManager.STATUS_UNCONNECT
		log("socket:連接失敗！")
		self.isReconnectNow = false
		self:refreshFailCollect(self.curUseLoginUrl) 
    elseif type == SocketManager.RESPONSE_CLOSE then
        self.socketStatus = SocketManager.STATUS_UNCONNECT
		log("socket:連接失敗！關閉")
		self.isReconnectNow = false     
	elseif type == SocketManager.RESPONSE_READ_FAIL then  
        self.socketStatus = SocketManager.STATUS_UNCONNECT
		log("socket:接收數據失敗！") 
		self.isReconnectNow = false  
		self.msgSendStatus = SocketManager.STATUS_WAIT_RECONNECT 
		self:startUpdate()
	end

	self.curUseLoginUrl = nil
end

function SocketManager:socketReadCallback(key,data)
	self:checkData(key,data)

	self.msgSendStatus = SocketManager.STATUS_NONE_SEND
	self:stopUpdate()
	cp.getManager("ViewManager").removeWaitingLayer()
	self.hasShowWaiting = false
end

function SocketManager:checkData(key,data)
    local netProto = cp.getManualConfig("NetProto")

	local tb = table.getChildTable(netProto,{key=key},true)
    if tb and tb.proto then
        local proto = cp.getManager("ProtobufManager"):decode2Table("protocal."..tb.proto,data)
        --local proto = protobuf.decode("S"..tb.proto, data)
        if proto then
			log("接收到的消息-->" .. tb.proto .. "=" , proto)
            --處理數據
            for _, callback in ipairs(self.callbacks) do
                if callback[tb.proto]~=nil then
					callback[tb.proto](self,key,proto,senddata)
					if proto.respond ~= 0 and proto.respond ~= nil then
						self:tipError(tb.proto,proto.respond)
					end
					if "ChatChannelRsp" == tb.proto and proto.respond == 0 then
						cp.getManager("GDataManager"):saveChatMsg(data)
					end
                    break
                end
            end
        end
    end
end

-- 1s間隔
function SocketManager:_update(dt)
	if self.beginConnect > 0 then
		if  os.time() - self.beginConnect > 3 then
			-- cp.getManager("ViewManager").removeWaitingLayer()
			self.beginConnect = 0
			-- self:stopUpdate()
			if self.socketStatus == SocketManager.STATUS_UNCONNECT then   
				
				self.hasShowWaiting = true
				self.waitForReciveBeginTime = os.time()
				--繼續彈出框
			end
		end
		return
	end
	log("tm aaa = " .. os.time() .. ",dt="..dt)
	if self.messageboxShow then
		-- cp.getManager("ViewManager").removeWaitingLayer()
		 self.hasShowWaiting = false
		-- self.msgSendStatus = SocketManager.STATUS_NONE_SEND
		
		-- self:stopUpdate()
		-- return
	end
	if not self.hasShowWaiting  and (self.msgSendStatus == SocketManager.STATUS_WAIT_RECIVE or self.msgSendStatus == SocketManager.STATUS_WAIT_RECONNECT) and (not self.messageboxShow) then
		
		self.hasShowWaiting = true
		self.waitForReciveBeginTime = os.time()
		if self.msgSendStatus == SocketManager.STATUS_WAIT_RECONNECT then
			self.autoConnect = true
			self:tryReconnectGame()--自動重連一次
		end
	end

	if self.hasShowWaiting and (not self.messageboxShow) and (os.time() - self.waitForReciveBeginTime > 1 ) then
		cp.getManager("ViewManager").removeWaitingLayer()
		self.hasShowWaiting = false
		self.msgSendStatus = SocketManager.STATUS_NONE_SEND
		
		self:stopUpdate()
		local function comfirmFunc()
			if self.socketStatus ~= SocketManager.STATUS_UNCONNECT then
				log("self.socket:doDisConnect ")
				self.socket:doDisConnect()
			end
			self.messageboxShow = false
			log("SocketManager:_update , tryReconnectGame ")
			cp.getManager("ViewManager").showWaitingLayer()
			self.beginConnect = os.time()
			self.autoConnect = false
			self:tryReconnectGame()
			self.msgSendStatus = SocketManager.STATUS_WAIT_RECONNECT
			self:startUpdate()
		end
		local function cancelFunc()
			self.messageboxShow = false
		end
		local content = "網路連接已斷開，是否重新連接？"
		cp.getManager("ViewManager").showNetWorkReconnectMessageBox("網路斷開提示",content,1,comfirmFunc,nil)
		self.messageboxShow = true
	end
end

--斷線重連繼續重新發送未發送出去的協議
function SocketManager:setReSendEnabel()
	self.canSendMsg = true
	self.isReconnectNow = false
end

--showErr 是否提示錯誤消息
function SocketManager:tipError(key,errorcode)

	local Config = cp.getManager("ConfigManager").getItemByMatch("ErrorCode", {MsgID = key, ErrorCode = errorcode})
	local Text = ""
	if Config then
		Text = Config:getValue("Text")
		if Text == "VIP" then
			local vip = cp.getUserData("UserVip"):getValue("level")
			Text = vip < 15 and Config:getValue("Extra1") or Config:getValue("Extra2")
		end
	end
	if Text == "" or Text == nil then
		local Config2 = cp.getManager("ConfigManager").getItemByKey("ErrorDefine",errorcode)
		if Config2 then
			Text = Config2:getValue("Define")
		else
			log("ErrorDefine havn't this errorcode, errorcode = " .. tostring(errorcode))
		end
	end

	if Text and Text ~= "不提示" then
		cp.getManager("ViewManager").gameTip(Text)
		log("--- Socket error:" .. Text .. ",key=" .. key .. ",errorcode=" .. errorcode)
	end
end

function SocketManager:registerCallBack()
    self.callbacks = {}
	local s = {"Login", "Combat", "Major", "Skill", "WorldMap", "Lottery",
				"Sign", "Mijing","Shop", "Friend", "MenPai", "Mail", "Guess",
				"Equip", "Arena", "Mountain","Vip", "Guild","DailyTask", "UpgradeGift",
				"Tower", "Primeval"}--列表中為SocketManager文件夾下的socket目錄中的lua文件名
    for i, m in ipairs(s) do
        local callback =  require("cp.manager.manager.socket."..m)
        table.insert(self.callbacks , callback)
    end
end

return SocketManager
