local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    --請求vip訊息返回
    [ProtoConst.GetVipInfoRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else 

            cp.getUserData("UserVip"):setValue("privilege", proto.privilege or 0)  -- 特權禮包
            cp.getUserData("UserVip"):setValue("exclusive", proto.exclusive or 0)  -- 專屬禮包
            cp.getUserData("UserVip"):setValue("daily", proto.daily or 0)          -- 日常禮包
            cp.getUserData("UserVip"):setValue("exp", proto.exp or 0)
            cp.getUserData("UserVip"):setValue("level", proto.level or 0)
            cp.getUserData("UserVip"):setValue("gold", proto.gold or 0)
            
            self:dispatchViewEvent(cp.getConst("EventConst").GetVipInfoRsp,proto)
        end
    end,
    
    --領取/購買vip各種禮包
    [ProtoConst.GetVipGiftRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else 
            cp.getUserData("UserVip"):setValue("privilege", proto.privilege or 0)
            cp.getUserData("UserVip"):setValue("exclusive", proto.exclusive or 0)
            cp.getUserData("UserVip"):setValue("daily", proto.daily or 0)
            if proto.items  ~= nil and next(proto.items) ~= nil then
                local itemList = {}
                for i=1,#proto.items do
                    table.insert(itemList, {id = proto.items[i].itemID , num = proto.items[i].num, hideName = false})
                end
				cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
			end

            self:dispatchViewEvent(cp.getConst("EventConst").GetVipGiftRsp,proto)
        end
    end,

    --儲值返回
    [ProtoConst.RechargeRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else
            -- local first = proto.first
            cp.getUserData("UserVip"):setValue("firstRecharge", proto.firstRecharge or 0)
        
            if proto.vipExp then
                cp.getUserData("UserVip"):setValue("exp",proto.vipExp)
            end
            if proto.vipLevel then
                cp.getUserData("UserVip"):setValue("level",proto.vipLevel)
            end
            self:dispatchViewEvent(cp.getConst("EventConst").RechargeRsp, proto)
        end
    end,
    
}

return m