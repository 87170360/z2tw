local BaseData = require("cp.data.BaseData")
local UserItem = class("UserItem",BaseData)

function UserItem:create()
    local ret =  UserItem.new() 
    ret:init()
    return ret
end

function UserItem:init()

    self["major_roleItem"] = {} --所有的物品數據

    --為揹包界面緩存數據
    self["items_for_package"] = {[0]={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}} --全部 裝備 武學 材料 道具 碎片 服飾 
    self["role_equip_ids"] = {}  --人物的八個裝備的ID列表
    local cfg = {
        
    }
    self:addProtectedData(cfg)
end

--初始化物品數據(每次登錄後，進入遊戲會重新刷新數據)
function UserItem:resetAllItems(gzipItemsData)
    self["major_roleItem"] = {} 
    
    self["items_for_package"] = {[0]={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}} --全部 裝備 武學 材料 道具 碎片 服飾 
    self["role_equip_ids"] = {}  --人物的八個裝備的ID列表

    if gzipItemsData ~= nil and gzipItemsData ~= "" then
        local result = cp.getManager("ProtobufManager"):decode2Table("protocal.ItemListInfo", gzip.decompress(gzipItemsData))
        if result and result.itemList and next(result.itemList) then
            for i=1,table.nums(result.itemList) do
                local itemInfo = result.itemList[i]
                if itemInfo.id > 0 and itemInfo.uuid ~= "" then
                    
                    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
                    if conf ~= nil then
                        itemInfo.Package = tonumber(conf:getValue("Package"))
                        itemInfo.Name = conf:getValue("Name")
                        itemInfo.Icon = conf:getValue("Icon")
                        itemInfo.Colour = conf:getValue("Hierarchy")
                        itemInfo.Type = conf:getValue("Type")
                        itemInfo.SubType = conf:getValue("SubType")
                        
                    end

                    local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
                    if conf2 then
                        itemInfo.Pos = conf2:getValue("Pos")
                        itemInfo.PlayerHierarchy = conf2:getValue("PlayerHierarchy") 
                    end

                    if itemInfo.using == 1 then
                        self["role_equip_ids"][itemInfo.Pos] = itemInfo.uuid
                    else
                        itemInfo.operateName = cp.getManager("GDataManager"):getPackageItemOperateState(itemInfo)
                        table.insert(self.items_for_package[0], itemInfo.uuid)
                        table.insert(self.items_for_package[itemInfo.Package], itemInfo.uuid)
                        
                    end
                    self["major_roleItem"][itemInfo.uuid] = itemInfo
                end
            end
        end
    end

    --對揹包裡的數據進行排序
    self:sortForPackage()
    
end

function UserItem:updateItems(itemNew,itemDelID,itemChange)
    local needReSort = false
    local packageSort = {}

    --new
    for _, v in pairs(itemNew) do
        local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
        if conf ~= nil then
            v.Package = tonumber(conf:getValue("Package"))
            v.Name = conf:getValue("Name")
            v.Icon = conf:getValue("Icon")
            v.Colour = conf:getValue("Hierarchy")
            v.Type = conf:getValue("Type")
            v.SubType = conf:getValue("SubType")
        end

        local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
        if conf2 then
            v.Pos = conf2:getValue("Pos")
            v.PlayerHierarchy = conf2:getValue("PlayerHierarchy") 
        end

        if v.using == 1 then
            self["role_equip_ids"][v.Pos] = v.uuid
        else
            v.operateName = cp.getManager("GDataManager"):getPackageItemOperateState(v)
            v.newlyAcquired = true

            needReSort = true
            packageSort[v.Package] = 1
            if table.arrIndexOf(self.items_for_package[0], v.uuid) == -1 then
                table.insert(self.items_for_package[0], v.uuid)
            end
            if table.arrIndexOf(self.items_for_package[v.Package],v.uuid) == -1 then
                table.insert(self.items_for_package[v.Package], v.uuid)
            end 

        end
        self["major_roleItem"][v.uuid] = v
    end
    --del
    for _, uuid in pairs(itemDelID) do
        local itemInfo = self["major_roleItem"][uuid]
        for pos,uuid2 in pairs (self["role_equip_ids"]) do
            if uuid2 == uuid then
                self["role_equip_ids"][pos] = nil
            end
        end

        --刪除的是揹包中的物品
        local Package = itemInfo.Package
        table.removebyvalue(self.items_for_package[Package], uuid)
        table.removebyvalue(self.items_for_package[0], uuid)
        self["major_roleItem"][uuid] = nil

    end

    --change
    for _, v in pairs(itemChange) do
        local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
        if conf ~= nil then
            v.Package = tonumber(conf:getValue("Package"))
            v.Name = conf:getValue("Name")
            v.Icon = conf:getValue("Icon")
            v.Colour = conf:getValue("Hierarchy")
            v.Type = conf:getValue("Type")
            v.SubType = conf:getValue("SubType")
        end

        local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
        if conf2 then
            v.Pos = conf2:getValue("Pos")
            v.PlayerHierarchy = conf2:getValue("PlayerHierarchy") 
        end
        if v.using == 1 then -- 物品在裝備欄
            self["role_equip_ids"][v.Pos] = v.uuid

            table.removebyvalue(self.items_for_package[v.Package], v.uuid)
            table.removebyvalue(self.items_for_package[0], v.uuid)

        else -- 物品當前在揹包中
            
            for pos,uuid2 in pairs (self["role_equip_ids"]) do
                if uuid2 == v.uuid then
                    self["role_equip_ids"][pos] = nil
                end
            end

            --更新揹包中此物品數據
            v.operateName = cp.getManager("GDataManager"):getPackageItemOperateState(v)
            needReSort = v.operateName ~= ""
            if needReSort then
                packageSort[v.Package] = 1
            end
            if table.arrIndexOf(self.items_for_package[0],v.uuid) == -1 then
                table.insert(self.items_for_package[0], v.uuid)
            end
            if table.arrIndexOf(self.items_for_package[v.Package],v.uuid) == -1 then
                table.insert(self.items_for_package[v.Package], v.uuid)
            end            
           
        end
        self["major_roleItem"][v.uuid] = v
    end

    if needReSort then
        self:sortForPackage(0)
        for packIndex ,_ in pairs(packageSort) do
            self:sortForPackage(packIndex)
        end
    end

end

--只排序揹包中的物品
function UserItem:sortForPackage(idx)
    
    local function getOrder(item)
        if item.newlyAcquired then
            return 5
        elseif item.operateName == "kehecheng" then
            return 4
        elseif item.operateName == "kexuexi" then
            return 3
        elseif item.operateName == "keshiyong" then
            return 2
        else
            if (item.strengthenLevel and item.strengthenLevel > 0) then
                return 1
            else
                return 0
            end
        end
        return 0
    end

    --裝備，武學，材料，道具
    local function getSubTypeOrder(item)
        if item.SubType == 4 then
            return 4
        elseif item.SubType == 1 then
            return 3
        elseif item.SubType == 3 then
            return 2
        elseif item.SubType == 2 then
            return 1
        end
        return 0
    end

    local sortSuipian = function(a, b)
        local itemA = self["major_roleItem"][a]
        local itemB = self["major_roleItem"][b]
        if itemA == nil or itemB == nil then
            return false
        end
        local orderA = getOrder(itemA)
        local orderB = getOrder(itemB)
        local subA = getSubTypeOrder(itemA)
        local subB = getSubTypeOrder(itemB)
        if orderA == orderB then
            if subA == subB then
                if itemA.Colour == itemB.Colour then
                    if itemA.id == itemB.id then
                        return itemA.num > itemB.num
                    end
                    return itemA.id > itemB.id
                end
                return itemA.Colour > itemB.Colour 
            else
                return subA > subB 
            end
        else
            return orderA > orderB
        end
    end

    local sortItem = function(a, b)
        local itemA = self["major_roleItem"][a]
        local itemB = self["major_roleItem"][b]
        if itemA == nil or itemB == nil then
            return false
        end
        local orderA = getOrder(itemA)
        local orderB = getOrder(itemB)
        if orderA == orderB then
            if itemA.Package == itemB.Package then
                if itemA.Colour == itemB.Colour then
                    if orderA == 1 then --同品質有強化等級的，按強化等級高低排
                        if itemA.PlayerHierarchy == itemB.PlayerHierarchy then
                            if itemA.strengthenLevel == itemB.strengthenLevel then
                                if itemA.id == itemB.id then
                                    return itemA.num > itemB.num
                                end
                                return itemA.id > itemB.id
                            else
                                return itemA.strengthenLevel > itemB.strengthenLevel
                            end
                        else
                            return itemA.PlayerHierarchy > itemB.PlayerHierarchy
                        end
                    else
                        if itemA.id == itemB.id then
                            return itemA.num > itemB.num
                        end
                        return itemA.id > itemB.id
                    end
                end
                return itemA.Colour > itemB.Colour    
            else
                return itemA.Package < itemB.Package
            end
        else
            return orderA > orderB
        end
    end

    if idx then
        if table.nums(self.items_for_package[idx]) > 1 then
            table.sort(self.items_for_package[idx], (idx == 5 and sortSuipian or sortItem)) 
        end
    else
        for i=0,6 do
            if table.nums(self.items_for_package[i]) > 1 then
                table.sort(self.items_for_package[i], (i == 5 and sortSuipian or sortItem))
            end
        end
    end
end

--重置新物品位置
function UserItem:resetNewlyAcquired(packageType)

    local num = table.nums(self.items_for_package[packageType])
    if num > 0 then
        for i=1,num do
            local uuid = self.items_for_package[packageType][i]
            if self["major_roleItem"][uuid] and self["major_roleItem"][uuid].newlyAcquired == true then
                self["major_roleItem"][uuid].newlyAcquired = nil
            end
        end
        self:sortForPackage(packageType)
    end
end

function UserItem:getItem(item_uuid)
    return self["major_roleItem"][item_uuid]
end


function UserItem:getItemNum(itemID)
    local itemData = self["major_roleItem"]
    local totalNum = 0
    if itemData == nil then
        return 0
    else
        for _, itemInfo in pairs(itemData) do
            if itemInfo.id == itemID then
                totalNum = totalNum + itemInfo.num
            end
        end
    end

    return totalNum
end

function UserItem:getItemPackMax(itemID)
    local itemData = self["major_roleItem"]
    local maxNum = 0
    local itemDetail = nil
    local uuid = nil
    if itemData == nil then
        return 0,nil,nil
    else
        for id, itemInfo in pairs(itemData) do
            if itemInfo.id == itemID and maxNum < itemInfo.num then
                maxNum = itemInfo.num
                itemDetail = itemInfo
                uuid = id
            end
        end
    end

    return uuid, itemDetail,maxNum
end


function UserItem:getItemFormPackage(itemId,packageIdx)
    if self.items_for_package[packageIdx] and next(self.items_for_package[packageIdx]) then
        for i=1,#self.items_for_package[packageIdx] do
            local uuid = self.items_for_package[packageIdx][i]
            local itemInfo = self["major_roleItem"][uuid]
            if itemInfo.id == itemId then
                return self["major_roleItem"][uuid]
            end
        end
    end
    return nil
end

function UserItem:getItemList()
    local itemData = self["major_roleItem"]
    local result = {}
    if itemData == nil then
        return {}
    else
        for _, itemInfo in pairs(itemData) do
            if result[itemInfo.id] then
                result[itemInfo.id] = result[itemInfo.id] + itemInfo.num
            else
                result[itemInfo.id] = itemInfo.num
            end
        end
    end

    return result
end

--更新揹包物品可操作狀態
function UserItem:updatePackageItemOperateState()
    for uuid,itemInfo in pairs(self["major_roleItem"]) do
        local operateName = cp.getManager("GDataManager"):getPackageItemOperateState(itemInfo)
        itemInfo.operateName = operateName or ""
    end
end

--判斷物品是否可以操作
function UserItem:checkPackageItemCanOperate()
    local packageNeedRedPoint = {0,0,0,0,0,0}  --裝備，武學，材料，道具，碎片，服飾
    -- for uuid,itemInfo in pairs(self["major_roleItem"]) do
    --     if (itemInfo.operateName and itemInfo.operateName ~= "") or itemInfo.newlyAcquired == true then
    --         packageNeedRedPoint[itemInfo.Package] = 1
    --     end
    -- end

    for i=1,6 do  -- i從1開始，全部欄 不提示
        for _,uuid in pairs(self["items_for_package"][i]) do
            local itemInfo = self:getItem(uuid)
            if itemInfo and ((itemInfo.operateName and itemInfo.operateName ~= "") or itemInfo.newlyAcquired == true) then
                packageNeedRedPoint[itemInfo.Package] = 1
                break
            end
        end
    end

    return packageNeedRedPoint
end

return UserItem