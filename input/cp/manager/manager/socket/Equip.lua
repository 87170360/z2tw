local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    
    --獲取銀兩兌換訊息
    [ProtoConst.GetConvertInfoRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            --[[
                message ConvertBase {
                    required int32 leftNum                  = 2;                    //剩餘次數
                    required int32 maxNum                   = 3;                    //最大次數
                    required int32 gold1                    = 4;                    //普通兌換消耗元寶
                    required int32 gold2                    = 5;                    //快速兌換消耗元寶
                    required int32 silver1                  = 6;                    //普通兌換獲得銀兩
                    required int32 silver2                  = 7;                    //快速兌換獲得銀兩
                }
            ]]
            
			self:dispatchViewEvent(cp.getConst("EventConst").GetConvertInfoRsp,proto)
        end
    end,

    --兌換銀兩返回
    [ProtoConst.ConvertSilverRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            if proto.respond == 17 then
                local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日招財次數已達上限。" or "提升VIP等級可獲得更多招財次數!" 
                cp.getManager("ViewManager").gameTip(str)
            end
        else
            --[[
               message ConvertSilverRsp {
                required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
                required ConvertInfo info               = 2;
                required ConvertBase base               = 3;
            }
            message ConvertInfo {
                required int32 silver                   = 1;                    //銀兩
                required int32 prob                     = 2;                    //倍率
            }
            ]]
            
			self:dispatchViewEvent(cp.getConst("EventConst").ConvertSilverRsp,proto)
        end
    end,

    --快速兌換返回(兌換10次)
    [ProtoConst.ConvertSilverExRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            if proto.respond == 17 then
                local vip = cp.getUserData("UserVip"):getValue("level")
                local str = vip >= 15 and "今日招財次數已達上限。" or "提升VIP等級可獲得更多招財次數!" 
                cp.getManager("ViewManager").gameTip(str)
            end
        else
            
            
			self:dispatchViewEvent(cp.getConst("EventConst").ConvertSilverExRsp,proto)
        end
    end,

    --強化消耗評估返回
    [ProtoConst.EquipStrengthenEvaluateRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            --[[
                message EquipStrengthenEvaluateRsp {
                required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
                required int32 silver                   = 2;                    //開銷銀兩
                required int32 exp                      = 3;                    //獲得經驗
                required int32 level                    = 4;                    //強化後等級
                required int32 maxLevel                 = 5;                    //強化等級上限
                repeated EquipAtt beforAtt              = 6;                    //強化前屬性
                repeated EquipAtt afterAtt              = 7;                    //強化後屬性
            }
            ]]
            if proto.beforAtt ~= nil and next(proto.beforAtt) ~= nil then
                local newBeforAtt = {}
                for i=1,table.nums(proto.beforAtt) do
                    if not (proto.beforAtt[i].attType >= 12 and proto.beforAtt[i].attType <= 16) then  --剔除掉各種精通值屬性，不算在基礎屬性裡
                        table.insert(newBeforAtt, proto.beforAtt[i])
                    end
                end
                proto.beforAtt = newBeforAtt
            end
            if proto.afterAtt ~= nil and next(proto.afterAtt) ~= nil then
                local newAfterAtt = {}
                for i=1,table.nums(proto.afterAtt) do
                    if not (proto.afterAtt[i].attType >= 12 and proto.afterAtt[i].attType <= 16) then  --剔除掉各種精通值屬性，不算在基礎屬性裡
                        table.insert(newAfterAtt, proto.afterAtt[i])
                    end
                end
                proto.afterAtt = newAfterAtt
            end

            local function sortByType(a,b)
                return a.attType < b.attType
            end
            table.sort( proto.beforAtt,sortByType)
            table.sort( proto.afterAtt,sortByType)

            cp.getUserData("UserEquipOperate"):setValue("evaluate_result",proto)
			self:dispatchViewEvent(cp.getConst("EventConst").EquipStrengthenEvaluateRsp,proto)
        end
    end,

    --強化結果返回
    [ProtoConst.EquipStrengthenRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
			self:dispatchViewEvent(cp.getConst("EventConst").EquipStrengthenRsp,proto)
        end
    end,

    --一鍵選擇強化材料返回
    [ProtoConst.EquipStrengthenQuickSelectRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            -- if proto.respond == 25 then
            --     cp.getManager("ViewManager").gameTip("該物品已達最高強化等級！")
            -- end
        else

            local select_item_list = proto.materialUID or {}
            -- if proto.materialUID and next(proto.materialUID) then
            --     for _,uuid in pairs(proto.materialUID) do
            --         select_item_list[uuid] = uuid
            --     end
            -- end
            cp.getUserData("UserEquipOperate"):setValue("select_item_list",select_item_list)

			self:dispatchViewEvent(cp.getConst("EventConst").EquipStrengthenQuickSelectRsp,proto)
        end
    end,

    --傳承結果返回
    [ProtoConst.EquipInheritedRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            
			self:dispatchViewEvent(cp.getConst("EventConst").EquipInheritedRsp,proto)
        end
    end,

    --熔鍊結果返回
    [ProtoConst.EquipMeltRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            
            
			self:dispatchViewEvent(cp.getConst("EventConst").EquipMeltRsp,proto)
        end
    end,

    --熔鍊結果撤銷返回
    [ProtoConst.EquipMeltCancleRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            
            
			self:dispatchViewEvent(cp.getConst("EventConst").EquipMeltCancleRsp,proto)
        end
    end,


    --購買時裝
    [ProtoConst.BuyFashionRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            
            local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
            fashion_data.coin = proto.coin
            fashion_data.use = proto.fashionID
            if table.arrIndexOf(fashion_data.own, proto.fashionID) == -1 then
                table.insert( fashion_data.own, proto.fashionID)
            end
			self:dispatchViewEvent(cp.getConst("EventConst").BuyFashionRsp,proto)
        end
    end,

    --使用時裝
    [ProtoConst.UseFashionRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
            fashion_data.use = proto.fashionID
			self:dispatchViewEvent(cp.getConst("EventConst").UseFashionRsp,proto)
        end
    end,


}

return m