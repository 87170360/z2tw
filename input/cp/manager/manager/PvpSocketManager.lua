--socket網路通信管理

local PvpSocketManager = class("PvpSocketManager")

PvpSocketManager.RESPONSE_SUCCESS = 0
PvpSocketManager.RESPONSE_TIMEOUT = 1
PvpSocketManager.RESPONSE_FAIL = 2
PvpSocketManager.RESPONSE_READ = 3
PvpSocketManager.RESPONSE_CLOSE = 4
PvpSocketManager.RESPONSE_READ_FAIL = 5

PvpSocketManager.STATUS_UNCONNECT = "UN_CONNECT"
PvpSocketManager.STATUS_CONNECT = "CONNECT"

PvpSocketManager.STATUS_NONE_SEND = "NONE_SEND" --沒有消息請求
PvpSocketManager.STATUS_WAIT_RECIVE = "WAIT_RECIVE"--請求消息已發送等待接收返回消息
PvpSocketManager.STATUS_WAIT_RECONNECT = "WAIT_RECONNECT"--等待重新連接

PvpSocketManager.TIME_OUT = 100

function PvpSocketManager:create()
    local ret =  PvpSocketManager.new() 
    ret:init()
    return ret
end  

function PvpSocketManager:init()
    self.socketStatus = PvpSocketManager.STATUS_UNCONNECT
    self.socket = cp.CpSocket:create()
    self.socket:addSocketStatusEventListener(handler(self, self.socketStatusCallback))
    self.socket:addSocketReadEventListener(handler(self, self.socketReadCallback))
	
	self.msgSendStatus = PvpSocketManager.STATUS_NONE_SEND
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

function PvpSocketManager:dispatchViewEvent(eventName,eventData)
    cp.getManager("EventManager"):dispatchEvent("VIEW", eventName, eventData)
end

function PvpSocketManager:clearSendData()
	self.sendDataList = {}
	self.sendList = {}
	self.curMsgIndex = 0
	self.msgSendStatus = PvpSocketManager.STATUS_NONE_SEND
	
end

function PvpSocketManager:doDisConnect()
    self.socket:doDisConnect()
    self:clearSendData()
	self.canSendMsg = true
end

function PvpSocketManager:startUpdate()
	self:stopUpdate()
	if self.messageboxShow then
		return
	end
	self.scheduleEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._update),0.5,false)
	log("tm startUpdate = " .. os.time())
	self:_update(0) --直接調用一次
end

function PvpSocketManager:stopUpdate()
   if self.scheduleEntryId then
       cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleEntryId)
       self.scheduleEntryId = nil
   end
end

function PvpSocketManager:doConnect()
	local newIp = cp.getGameData("GameNet"):getValue("pvpIp") or "119.23.25.26"
	local newPort = cp.getGameData("GameNet"):getValue("pvpPort") or 8001

	self.socket:doConnect(newIp,newPort,PvpSocketManager.TIME_OUT)
	
end

function PvpSocketManager:tryReconnectGame()
	self.canSendMsg = false
	self.isReconnectNow = true
	log("pvp tryReconnectGame tm = " .. os.time())
	-- self.socket:doDisConnect()
	self:doConnect()
end


function PvpSocketManager:doSend(proto,data)
    local addData = {
        proto = proto,
        data = data
    }
    
   self.sendingData = addData
   self:doSendNow(addData.proto , addData.data)
end


function PvpSocketManager:doSendNow(proto,data)
    data = data or {}
    local netProto = cp.getManualConfig("NetProto")
    local tb = table.getChildTable(netProto,{proto=proto},true)
    if tb and tb.key then
        if self.socketStatus == PvpSocketManager.STATUS_UNCONNECT then
		   	if self.isReconnectNow == false then
				self.msgSendStatus = PvpSocketManager.STATUS_WAIT_RECONNECT
				log("PvpSocketManager:doSendNow STATUS_WAIT_RECONNECT")
				self:startUpdate()
			end
        end
        if self.socketStatus == PvpSocketManager.STATUS_CONNECT then
            local protoData = cp.getManager("ProtobufManager"):encode("protocal."..proto, data)

            --發送數據
			self.socket:doSend(tb.key,protoData,0,0)
			log("pvp消息(" .. proto .. ")已發送，data=" ,data)

			self.msgSendStatus = PvpSocketManager.STATUS_WAIT_RECIVE
			log("PvpSocketManager:doSendNow STATUS_WAIT_RECIVE")
			self:startUpdate()
            
        end
        
    end
end


function PvpSocketManager:socketStatusCallback(type)
    if type == PvpSocketManager.RESPONSE_SUCCESS then
        if self.socketStatus == PvpSocketManager.STATUS_UNCONNECT then
            self.socketStatus = PvpSocketManager.STATUS_CONNECT       
			log("pvp socket:連接成功！,self.isReconnectNow = " .. tostring(self.isReconnectNow))  
            if self.isReconnectNow then
				self.isReconnectNow = false

				self:stopUpdate()
				cp.getManager("ViewManager").removeWaitingLayer()
				self.hasShowWaiting = false
				self.msgSendStatus = PvpSocketManager.STATUS_NONE_SEND
				if not self.autoConnect then
					cp.getManager("ViewManager").gameTip("連接伺服器成功！")
				end
			end  
			-- local newIp = cp.getGameData("GameNet"):getValue("pvpIp")
			-- local newPort = cp.getGameData("GameNet"):getValue("pvpPort")
			local token = cp.getUserData("UserLogin"):getValue("user_token")
			if token ~= nil and token ~= "" then -- and newIp ~= nil and newPort ~= nil then
				local token = cp.getUserData("UserLogin"):getValue("user_token")
				self:doSend(cp.getConst("ProtoConst").DeerLoginReq, {token = token})
			end
        end
    elseif type == PvpSocketManager.RESPONSE_TIMEOUT then
        self.socketStatus = PvpSocketManager.STATUS_UNCONNECT
		log("pvp socket:連接失敗！超時")
		self.isReconnectNow = false
    elseif type == PvpSocketManager.RESPONSE_FAIL then
        self.socketStatus = PvpSocketManager.STATUS_UNCONNECT
		log("pvp socket:連接失敗！")
		self.isReconnectNow = false 
    elseif type == PvpSocketManager.RESPONSE_CLOSE then
        self.socketStatus = PvpSocketManager.STATUS_UNCONNECT
		log("pvp socket:連接失敗！關閉")
		self.isReconnectNow = false     
	elseif type == PvpSocketManager.RESPONSE_READ_FAIL then
        self.socketStatus = PvpSocketManager.STATUS_UNCONNECT
		log("pvp socket:接收數據失敗！") 
		self.isReconnectNow = false  
		self.msgSendStatus = PvpSocketManager.STATUS_WAIT_RECONNECT 
		self:startUpdate()
    end
end


function PvpSocketManager:socketReadCallback(key,data)
	self:checkData(key,data)

	self.msgSendStatus = PvpSocketManager.STATUS_NONE_SEND
	self:stopUpdate()
	cp.getManager("ViewManager").removeWaitingLayer()
	self.hasShowWaiting = false
end

function PvpSocketManager:checkData(key,data)
    local netProto = cp.getManualConfig("NetProto")

	local tb = table.getChildTable(netProto,{key=key},true)
    if tb and tb.proto then
        local proto = cp.getManager("ProtobufManager"):decode2Table("protocal."..tb.proto,data)
        --local proto = protobuf.decode("S"..tb.proto, data)
        if proto then
			log("pvp接收到的消息-->" .. tb.proto .. "=" , proto)
            --處理數據
            for _, callback in ipairs(self.callbacks) do
                if callback[tb.proto]~=nil then
					callback[tb.proto](self,key,proto,senddata)
					if proto.respond ~= 0 and proto.respond ~= nil then
						self:tipError(tb.proto,proto.respond)
					end
                    break
                end
            end
        end
    end
end

-- 1s間隔
function PvpSocketManager:_update(dt)
	if self.beginConnect > 0 then
		if  os.time() - self.beginConnect > 3 then
			-- cp.getManager("ViewManager").removeWaitingLayer()
			self.beginConnect = 0
			-- self:stopUpdate()
			if self.socketStatus == PvpSocketManager.STATUS_UNCONNECT then   
				
				self.hasShowWaiting = true
				self.waitForReciveBeginTime = os.time()
				--繼續彈出框
			end
		end
		return
	end
	log("tm pvp = " .. os.time() .. ",dt="..dt)
	if self.messageboxShow then
		 self.hasShowWaiting = false
	end
	if not self.hasShowWaiting  and (self.msgSendStatus == PvpSocketManager.STATUS_WAIT_RECIVE or self.msgSendStatus == PvpSocketManager.STATUS_WAIT_RECONNECT) and (not self.messageboxShow) then
		
		self.hasShowWaiting = true
		self.waitForReciveBeginTime = os.time()
		-- if self.msgSendStatus == PvpSocketManager.STATUS_WAIT_RECONNECT then
		-- 	self.autoConnect = true
		-- 	self:tryReconnectGame()--自動重連一次
		-- end
	end

	if self.hasShowWaiting and (not self.messageboxShow) and (os.time() - self.waitForReciveBeginTime > 1 ) then
		cp.getManager("ViewManager").removeWaitingLayer()
		self.hasShowWaiting = false
		self.msgSendStatus = PvpSocketManager.STATUS_NONE_SEND
		
		self:stopUpdate()
		local function comfirmFunc()
			if self.socketStatus ~= PvpSocketManager.STATUS_UNCONNECT then
				log("self.socket:doDisConnect ")
				self.socket:doDisConnect()
			end
			self.messageboxShow = false
			log("PvpSocketManager:_update , tryReconnectGame ")
			cp.getManager("ViewManager").showWaitingLayer()
			self.beginConnect = os.time()
			self.autoConnect = false
			self:tryReconnectGame()
			self.msgSendStatus = PvpSocketManager.STATUS_WAIT_RECONNECT
			self:startUpdate()
		end
		local function cancelFunc()
			self.messageboxShow = false
		end
		local content = "與伺服器連接已斷開，是否重新連接？"
		cp.getManager("ViewManager").showNetWorkReconnectMessageBox("連接斷開提示",content,1,comfirmFunc,nil)
		self.messageboxShow = true
	end
end


--showErr 是否提示錯誤消息
function PvpSocketManager:tipError(key,errorcode)

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

function PvpSocketManager:registerCallBack()
    self.callbacks = {}
	local s = {"Deer"}--列表中為PvpSocketManager文件夾下的socket目錄中的lua文件名
    for i, m in ipairs(s) do
        local callback =  require("cp.manager.manager.socket."..m)
        table.insert(self.callbacks , callback)
    end
end

return PvpSocketManager
