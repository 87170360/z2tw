local BaseData = require("cp.data.BaseData")
local UserEquipOperate = class("UserEquipOperate",BaseData)

function UserEquipOperate:create()
    local ret =  UserEquipOperate.new()
    ret:init()
    return ret
end

function UserEquipOperate:init()

    -- 索引1，2，3對應操作類型 強化，傳承，熔鍊
    self["material_list"] = {
        [1] = {[1] = {}, [2] = {}}, --強化： 1為裝備列表, 2為強化石列表
        [2] = {}, --傳承 具有強化等級的裝備列表
        [3] = {}, --熔鍊 對應位置的裝備列表
    }

    self["material_list_by_uuid"] = {}

    self["select_item_list"] = {} -- 當前已經選擇的材料列表( 存的是uuid列表 ,強化可以多選)
    self["evaluate_result"] = nil  --強化預估消耗及結果
    local cfg = {
        ["target_item_uuid"] = "", --待強化，傳承，熔鍊的裝備的uuid
        ["select_property_pos"] = -1, -- 附加屬性位置(0,1,2,3,4,5)
        ["money_need"] = 0,
	}	
    self:addProtectedData(cfg)
end

--剔除 目標物品target_item_uuid
function UserEquipOperate:refreshAllMaterialItems()
    
    local uuid = self:getValue("target_item_uuid")
    local itemInfo = cp.getUserData("UserItem"):getItem(uuid)
    local equipconf1 = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemInfo.id)
    itemInfo.Pos = equipconf1:getValue("Pos")

    --遍歷角色物品數據
    self.material_list_by_uuid = {
        stoneList = {},
        itemList = {},
        itemWithLevelList ={}, 
        samePosItemListWithAttachAtt = {},
        samePosItemWithUpLevelList = {},
    }
    local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
    for _, v in pairs(roleItem) do
        if  v.using ~= 1 and v.uuid ~= uuid then
            local item = clone(v)

            local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
            if conf == nil then
                log("item is not exist id = " .. tostring( v.id))	
                dump(v)
            end
            item.Name = conf:getValue("Name")
            item.Icon = conf:getValue("Icon")
            item.Type = conf:getValue("Type")
            item.SubType = conf:getValue("SubType")
            item.Package = conf:getValue("Package")
            item.Colour = conf:getValue("Hierarchy")

            --強化材料列表
            if v.id >= 602 and v.id <=607 then --強化石
                self.material_list_by_uuid.stoneList[item.uuid] = item
            else
                local equipconf = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
                if equipconf ~= nil then
                    item.Pos = equipconf:getValue("Pos")
                    item.PlayerHierarchy = equipconf:getValue("PlayerHierarchy")
                    
                    if item.strengthenLevel and item.strengthenLevel > 0 then
                        self.material_list_by_uuid.itemWithLevelList[item.uuid] = item
                    else
                        self.material_list_by_uuid.itemList[item.uuid] = item
                    end
                    if item.Pos == itemInfo.Pos then
                        if item.attachAtt ~= nil and next(item.attachAtt) ~= nil then
                            self.material_list_by_uuid.samePosItemListWithAttachAtt[item.uuid] = item
                        end
                        if item.strengthenLevel and item.strengthenLevel  > itemInfo.strengthenLevel then
                            self.material_list_by_uuid.samePosItemWithUpLevelList[item.uuid] = item
                        end
                    end
                    
                end
            end
        end
    end
    
   
    self:reOrderItemList()
end

function UserEquipOperate:reOrderItemList()
    local stoneList = table.values(self.material_list_by_uuid.stoneList,false)
    local itemList = table.values(self.material_list_by_uuid.itemList,false)
    local itemWithLevelList = table.values(self.material_list_by_uuid.itemWithLevelList,false)
    local samePosItemListWithAttachAtt = table.values(self.material_list_by_uuid.samePosItemListWithAttachAtt,false)
    local samePosItemWithUpLevelList = table.values(self.material_list_by_uuid.samePosItemWithUpLevelList,false)

    local function sort_by_Quality(a,b)
        if a.Colour == b.Colour then
            return a.id > b.id
        end
        return a.Colour < b.Colour
    end
    table.sort(stoneList,sort_by_Quality)
    table.sort(samePosItemListWithAttachAtt,sort_by_Quality)

    local function sortForChuancheng(a,b)
        if a.PlayerHierarchy == b.PlayerHierarchy then
            
            if a.Colour == b.Colour then
                if a.strengthenLevel == b.strengthenLevel then
                    return a.id > b.id
                else
                    return a.strengthenLevel > b.strengthenLevel
                end
            end
            return a.Colour > b.Colour
        else
            return a.PlayerHierarchy > b.PlayerHierarchy
        end
    end
    table.sort(samePosItemWithUpLevelList,sortForChuancheng)

    local function sortForQianghua(a,b)
        if a.PlayerHierarchy == b.PlayerHierarchy then
            
            if a.Colour == b.Colour then
                if a.strengthenLevel == b.strengthenLevel then
                    return a.id < b.id
                else
                    return a.strengthenLevel < b.strengthenLevel
                end
            end
            return a.Colour < b.Colour
        else
            return a.PlayerHierarchy < b.PlayerHierarchy
        end
    end
    table.sort(itemList,sortForQianghua)
    table.sort(itemWithLevelList,sortForQianghua)


    table.insertto(itemList, itemWithLevelList, -1)
    table.insertto(itemList, stoneList, -1)
    self.material_list[1] = itemList
    self.material_list[2] = samePosItemWithUpLevelList
    self.material_list[3] = samePosItemListWithAttachAtt
end

function UserEquipOperate:removeSelectedMaterialList()
    if table.nums(self.select_item_list) > 0 then
        for i=1,table.nums(self.select_item_list) do
            local uuid = self.select_item_list[i]
            if self.material_list_by_uuid.stoneList[uuid] then
                self.material_list_by_uuid.stoneList[uuid] = nil
                
            end
            if self.material_list_by_uuid.itemList[uuid] then
                self.material_list_by_uuid.itemList[uuid] = nil
            end
            if self.material_list_by_uuid.itemWithLevelList[uuid] then
                self.material_list_by_uuid.itemWithLevelList[uuid] = nil
            end

            if self.material_list_by_uuid.samePosItemListWithAttachAtt[uuid] then
                self.material_list_by_uuid.samePosItemListWithAttachAtt[uuid] = nil
            end
            if self.material_list_by_uuid.samePosItemWithUpLevelList[uuid] then
                self.material_list_by_uuid.samePosItemWithUpLevelList[uuid] = nil
            end
        end
    end

    self:reOrderItemList()
    self.select_item_list = {}
end

return UserEquipOperate