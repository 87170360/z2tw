local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
	--遊客登錄返回
    [ProtoConst.GuestRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --彈出統一的錯誤提示框(提示文字以後通過表格配置)
            log("ProtoConst.GuestRsp proto.respond = " .. tostring(proto.respond))
            if proto.respond == 3 then 
                cp.getManager("ViewManager").gameTip("帳號區服id不存在") -- zone
            elseif proto.respond == 4 then
                cp.getManager("ViewManager").gameTip("帳號數據錯誤")  --DB
			elseif proto.respond == 5 then
                cp.getManager("ViewManager").gameTip("角色賬號創建錯誤")
            end
        else
            cp.getUserData("UserLogin"):setValue("lastServerInfo", proto.zone)
            self:dispatchViewEvent(cp.getConst("EventConst").GuestRsp , proto)
        end
    end,

	--正常登錄返回
    [ProtoConst.LoginRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            log("ProtoConst.GuestRsp proto.respond = " .. tostring(proto.respond))
             if proto.respond == 26 then
				local text = cp.getManager("GDataManager"):getTextFormat("forbit_login")
				text = string.gsub(text, 'a', ""..proto.forbit_time)
                cp.getManager("ViewManager").gameTip(text)    
             end
        else
            cp.getUserData("UserLogin"):setValue("lastServerInfo", proto.zone)
            self:dispatchViewEvent(cp.getConst("EventConst").LoginRsp, proto)
        end
	end,

	--註冊消息返回
    [ProtoConst.RegisterRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --彈出統一的錯誤提示框(提示文字以後通過表格配置)
            log("ProtoConst.GuestRsp proto.respond = " .. tostring(proto.respond))
			if proto.respond == 1 then
                cp.getManager("ViewManager").gameTip("帳號已經被註冊")
			end
        else
            cp.getUserData("UserLogin"):setValue("lastServerInfo", proto.zone)
            --保存賬號密碼到本地文件
            
            self:dispatchViewEvent(cp.getConst("EventConst").RegisterRsp, proto)
        end
	end,

	--請求伺服器列表返回
    [ProtoConst.ZoneRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
        else
            --先保存數據
            local zonelist = {}
            if proto.zonelist ~= nil then
                for i=1,table.nums(proto.zonelist) do
                    if proto.zonelist[i].id ~= nil then
                        table.insert(zonelist,proto.zonelist[i])
                    end
                end
            end
           
            if table.nums(zonelist) > 1 then
                local function sortServerList( a,b )
                    return a.id > b.id
                end
                table.sort(zonelist,sortServerList)
            end
            cp.getUserData("UserLogin"):setValue("serverList", zonelist)
		    self:dispatchViewEvent(cp.getConst("EventConst").ZoneRsp, proto)
        end
	end,

	--創建角色返回
	[ProtoConst.CreateRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
            
        else
		    self:dispatchViewEvent(cp.getConst("EventConst").CreateRsp, proto)
		end
	end,

	--進入遊戲
	[ProtoConst.EnterGameRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
        else
		    self:dispatchViewEvent(cp.getConst("EventConst").EnterGameRsp, proto)
		end
	end,

    --斷線重連上後重新驗證
    [ProtoConst.ReconnectRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            --錯誤處理
            if proto.respond == 9 then -- token無效
                cp.getManager("ViewManager").showGameMessageBox("系統消息","token無效，請重新登錄",1,function()
                    cp.getManager("AppManager"):reLogin()
                end,nil)
            end
        else
            if proto.timeStamp and proto.timeStamp > 0 then
                cp.getManager("TimerManager"):resetTime(proto.timeStamp,true) --伺服器時間
            end
            cp.getManager("SocketManager"):setReSendEnabel()
            self:dispatchViewEvent(cp.getConst("EventConst").ReconnectLoginOK)
		end
    end,
    
    --第三方登錄(其他sdk登錄)
    [ProtoConst.ThirdLoginRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
             if proto.respond == 26 then
				local text = cp.getManager("GDataManager"):getTextFormat("forbit_login")
				text = string.gsub(text, 'a', ""..proto.forbit_time)
				dump(proto)
                cp.getManager("ViewManager").gameTip(text)    
             end
        else
            cp.getUserData("UserLogin"):setValue("user_token",proto.token)
            cp.getManager("GDataManager"):saveAccount({ proto.account, "0" })
			cp.getManager("GDataManager"):saveLastAccount({ proto.account, "0" })
            cp.getUserData("UserLogin"):setValue("lastServerInfo", proto.zone)
            self:dispatchViewEvent(cp.getConst("EventConst").LoginRsp, proto)
        end
    end,

    --被頂下線提示
    [ProtoConst.KickOfflineRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else
            local str = "您的賬號已在其他地方登錄。"
            if proto.reason == 2 then
                str = "你已被GM踢下線。"
            end
            if proto.addr and proto.addr ~= "" then
                log("proto.addr = " .. proto.addr)
            end
            --斷網
            cp.getManager("SocketManager"):doDisConnect()
            cp.getManager("SocketManager"):stopUpdate()
            cp.getManager("TimerManager"):stop()

            cp.getManager("ViewManager").showGameMessageBox("系統消息",str,1,function()
                cp.getManager("AppManager"):reLogin()
            end,nil)

        end
    end,

    --揹包格子擴展
	[ProtoConst.ExpandPackSizeRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then

        else
            -- local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
            -- major_roleAtt.packSize = proto.packSize
            log("proto.packSize = " .. proto.packSize)
		    self:dispatchViewEvent(cp.getConst("EventConst").ExpandPackSizeRsp, proto)
		end
    end,
    
    --同步月卡，季卡，年卡，終身卡的數據
    [ProtoConst.CardRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then

        else
            if proto.element and next(proto.element) then
                cp.getUserData("UserVip"):updateCards(proto.element)
            end
            
		    self:dispatchViewEvent(cp.getConst("EventConst").CardRsp, proto)
		end
    end,
    
}

return m
