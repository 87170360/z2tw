local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    --測試使用
    [ProtoConst.DeerTestRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else 

            log("DeerTestRsp")
            self:dispatchViewEvent(cp.getConst("EventConst").open_zhuluzhanchang_view, true)
        end
    end,
    
    --登錄pvp
    [ProtoConst.DeerLoginRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else 
            
            cp.getUserData("UserZhuluzhanchang"):setValue("sign",proto.sign or false)

            cp.getUserData("UserZhuluzhanchang"):setValue("self_info",proto.person or {})

            local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat") or {}
            if proto.defeat and next(proto.defeat) then
                for i=1,table.nums(proto.defeat) do
                    if proto.defeat[i] and proto.defeat[i].id then
                        buildings_defeat[proto.defeat[i].id] = proto.defeat[i].num 
                    end
                end
            end
            cp.getUserData("UserZhuluzhanchang"):setValue("buildings_defeat",buildings_defeat)

            self:dispatchViewEvent(cp.getConst("EventConst").open_zhuluzhanchang_view, true)
        end
    end,

    --隨機陣營進入逐鹿戰場
    [ProtoConst.DeerSignRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            -- cp.getManager("ViewManager").gameTip("沒有符合條件的對手")
        else
            cp.getUserData("UserZhuluzhanchang"):setValue("sign",true)
            cp.getUserData("UserZhuluzhanchang"):setValue("self_info",proto.person or {})

            local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat") or {}
            if proto.defeat and next(proto.defeat) then
                for i=1,table.nums(proto.defeat) do
                    if proto.defeat[i] and proto.defeat[i].id then
                        buildings_defeat[proto.defeat[i].id] = proto.defeat[i].num 
                    end
                end
            end
            cp.getUserData("UserZhuluzhanchang"):setValue("buildings_defeat",buildings_defeat)

            self:dispatchViewEvent(cp.getConst("EventConst").DeerSignRsp, proto)
        end
    end,

    --查看城市詳情
    [ProtoConst.DeerViewCityRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else
            log("cityid = " .. proto.cityid)
            
            cp.getUserData("UserZhuluzhanchang"):setValue("current_city_id", proto.cityid or 0)
            cp.getUserData("UserZhuluzhanchang"):setValue("current_city_npc", proto.cityPerson or {})
            self:dispatchViewEvent(cp.getConst("EventConst").DeerViewCityRsp, proto)
        end
    end,
    
    --進入戰鬥
    [ProtoConst.DeerFightRsp] = function(self,key,proto,senddata)
        if proto.respond ~= 0 then
            
        else
            local buildings_defeat = cp.getUserData("UserZhuluzhanchang"):getValue("buildings_defeat") or {}
            if proto.defeat and next(proto.defeat) then
                for i=1,table.nums(proto.defeat) do
                    if proto.defeat[i] and proto.defeat[i].id then
                        buildings_defeat[proto.defeat[i].id] = proto.defeat[i].num 
                    end
                end
            end
            cp.getUserData("UserZhuluzhanchang"):setValue("buildings_defeat",buildings_defeat)
            
            self:dispatchViewEvent(cp.getConst("EventConst").DeerFightRsp, proto)
        end
    end,
    
    
}

return m