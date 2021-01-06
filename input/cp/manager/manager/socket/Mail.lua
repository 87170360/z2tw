local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetMailListRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserMail"):setValue("MailData", proto.mail_data)
            self:dispatchViewEvent(cp.getConst("EventConst").GetMailListRsp)
        end
    end,
    [ProtoConst.DispatchMailRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserMail"):addMail(proto.mail_list)
            self:dispatchViewEvent(cp.getConst("EventConst").DispatchMailRsp)
        end
    end,
    [ProtoConst.ReceiveMailRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("揹包已滿")
        elseif proto.result == 0 and #proto.mail_list > 0 then
            cp.getUserData("UserMail"):receiveMail(proto.mail_list)
            self:dispatchViewEvent(cp.getConst("EventConst").ReceiveMailRsp, proto.item_list)
        end
    end,
    [ProtoConst.DeleteMailRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserMail"):deleteMail(proto.mail_list)
            self:dispatchViewEvent(cp.getConst("EventConst").DeleteMailRsp)
        end
    end,
}

return m