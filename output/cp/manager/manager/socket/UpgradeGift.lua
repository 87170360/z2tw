local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    --領取等級禮包
    [ProtoConst.GetUpgradeGiftRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
			self:dispatchViewEvent(cp.getConst("EventConst").GetUpgradeGiftRsp, proto)
        end
    end,

    [ProtoConst.GetFightGiftRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
			self:dispatchViewEvent(cp.getConst("EventConst").GetFightGiftRsp, proto)
        end
    end,

    [ProtoConst.GetPhysicalRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
			self:dispatchViewEvent(cp.getConst("EventConst").GetPhysicalRsp, proto)
        end
    end,

    --獲取限時儲值活動及江湖基金活動的獎勵領取狀態訊息
    [ProtoConst.OtherRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
            cp.getUserData("UserActivity"):updateRechargeGift(proto.rechargeGift)
            cp.getUserData("UserActivity"):updateFundGift(proto.fundGift)
            cp.getUserData("UserActivity"):setValue("rechargeGold", proto.rechargeGold or 0)
            cp.getUserData("UserActivity"):setValue("firstRecharge", proto.firstRecharge or 0)
            cp.getUserData("UserActivity"):setValue("fund", proto.fund or false)
            
			self:dispatchViewEvent(cp.getConst("EventConst").OtherRsp, proto)
        end
    end,


    --獲取限時儲值活動的配置訊息
    [ProtoConst.RechargeGiftConfRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

            cp.getUserData("UserActivity"):setValue("rechargeGift_time_start", proto.startTime)
            cp.getUserData("UserActivity"):setValue("rechargeGift_time_end", proto.endTime)
            if proto.conf and next(proto.conf) then
                cp.getUserData("UserActivity"):setValue("rechargeGift_config", proto.conf)
                
            end
			self:dispatchViewEvent(cp.getConst("EventConst").RechargeGiftConfRsp, proto)
        end
    end,

    --領取限時儲值活動獎勵
    [ProtoConst.GetRechargeGiftRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

			self:dispatchViewEvent(cp.getConst("EventConst").GetRechargeGiftRsp, proto)
        end
    end,

    --獲取首儲活動的配置訊息
    [ProtoConst.FirstRechargeConfRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
            if proto.element and next(proto.element) then
                cp.getUserData("UserActivity"):setValue("first_recharge_config", proto.element)
            end
            self:dispatchViewEvent(cp.getConst("EventConst").FirstRechargeConfRsp, proto)
        end
    end,

    --領取首儲活動獎勵
    [ProtoConst.GetFirstRechargeRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

			self:dispatchViewEvent(cp.getConst("EventConst").GetFirstRechargeRsp, proto)
        end
    end,

    --獲取基金活動的配置訊息
    [ProtoConst.FundConfRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else
            cp.getUserData("UserActivity"):setValue("fund_config", proto.conf)
            
            self:dispatchViewEvent(cp.getConst("EventConst").FundConfRsp, proto)
        end
    end,
    
    --領取基金獎勵
    [ProtoConst.GetFundRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
        else

			self:dispatchViewEvent(cp.getConst("EventConst").GetFundRsp, proto)
        end
    end,

    
}

return m
