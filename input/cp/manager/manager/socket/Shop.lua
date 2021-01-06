local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    
    --請求商店物品列表
    [ProtoConst.StoreGoodsRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            if current_storeID == proto.storeID then
                local refresh = proto.refresh
                local GoodsList = {}
                if proto.goods ~= nil and next(proto.goods) ~= nil then
                    for i=1,table.nums(proto.goods) do
                        local goodsInfo = proto.goods[i]
                        if goodsInfo.goodsID ~= nil and goodsInfo.goodsID > 0 then
                            table.insert(GoodsList, goodsInfo)
                        end
                    end
                end
                table.sort(GoodsList,function(a,b)
                    return a.goodsID > b.goodsID
                end)
                cp.getUserData("UserShop"):setValue("GoodsList",GoodsList)
                cp.getUserData("UserShop"):setValue("RefreshCount",refresh)
            else
                log(string.format("商店id不符。請求storeID=%d,返回storeID=%d",current_storeID,proto.storeID))
            end
            
			self:dispatchViewEvent(cp.getConst("EventConst").StoreGoodsRsp,proto)
        end
    end,


    -- 請求刷新商店物品列表
    [ProtoConst.StoreRefreshRsp] = function(self,key,proto,senddata)
        
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            
            local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            if current_storeID == proto.storeID then
                local refresh = proto.refresh
                local GoodsList = {}
                if proto.goods ~= nil and next(proto.goods) ~= nil then
                    for i=1,table.nums(proto.goods) do
                        local goodsInfo = proto.goods[i]
                        if goodsInfo.goodsID ~= nil and goodsInfo.goodsID > 0 then
                            table.insert(GoodsList, goodsInfo)
                        end
                    end
                end
                table.sort(GoodsList,function(a,b)
                    return a.goodsID > b.goodsID
                end)
                cp.getUserData("UserShop"):setValue("GoodsList",GoodsList)
                cp.getUserData("UserShop"):setValue("RefreshCount",refresh)
            else
                log(string.format("商店id不符。請求storeID=%d,返回storeID=%d",current_storeID,proto.storeID))
            end
			self:dispatchViewEvent(cp.getConst("EventConst").StoreRefreshRsp,proto)
        end
    end,


    -- 購買物品返回
    [ProtoConst.StoreBuyRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            local buyNum = 0
            local current_storeID = cp.getUserData("UserShop"):getValue("current_storeID")
            if current_storeID == proto.storeID then
                local GoodsList = cp.getUserData("UserShop"):getValue("GoodsList")
                for i,goodsInfo in pairs(GoodsList) do
                    if goodsInfo.goodsID == proto.goodsID then
                        buyNum = GoodsList[i].leftNum - proto.leftNum
                        GoodsList[i].leftNum = proto.leftNum
                        break
                    end
                end
            end
            
            self:dispatchViewEvent(cp.getConst("EventConst").StoreBuyRsp,proto)


            if buyNum > 0 then
                local cfgItem = cp.getManager("ConfigManager").getItemByKey("Goods",proto.goodsID)
                if cfgItem ~= nil then
                    local ItemID = cfgItem:getValue("ItemID")
                    if ItemID > 0 then
                        local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameItem",ItemID)
                        if cfgItem2 ~= nil then
                            local itemList = {}
                            table.insert(itemList, {id = ItemID, num=buyNum, hideName = false})
                            cp.getManager("ViewManager").showGetRewardUI(itemList,"獲得物品",true)
                        end
                    end
                end
            end
            
        end
    end,
    
     -- 請求神祕商店開啟狀態
     [ProtoConst.StoreOpenRsp] = function(self,key,proto,senddata)
        if proto.respond~=nil and proto.respond ~=0 then
            --彈錯誤提示
            
        else
            cp.getUserData("UserShop"):setValue("MysticalStore_storeID",proto.storeID)
            cp.getUserData("UserShop"):setValue("MysticalStore_closeStamp",proto.closeStamp)
            
            self:dispatchViewEvent(cp.getConst("EventConst").StoreOpenRsp,proto)
        end
    end,

}

return m