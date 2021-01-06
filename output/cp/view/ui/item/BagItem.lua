local ItemIcon = require("cp.view.ui.icon.ItemIcon")
local BagItem = class("BagItem",ItemIcon) --揹包物品格子

-- itemInfo = {uuid = "伺服器中存的唯一id", id = "表格中對應的id", Name = "表格中對應的name", 
				--Icon = "表格中對應的Icon", num = "數量", Colour ="品質", hideName = "true/false 是否隱藏名字"}
function BagItem:create(itemInfo)
	local ret = BagItem.new()
	local isInBag = true
	if itemInfo then itemInfo.hideName = false end
	BagItem.super.init(ret,itemInfo,isInBag)

    return ret
end


function BagItem:reset(itemInfo,needShowFlag)
	local isInBag = true
	if itemInfo then itemInfo.hideName = false end
	BagItem.super.reset(self,itemInfo,isInBag)
	
	local haveFlag = false
	if itemInfo and needShowFlag ~= nil then
		if itemInfo.operateName ~= "" then
			BagItem.super.addFlag(self,itemInfo.operateName)
			haveFlag = true
		end
		--[[
		if itemInfo.Type == 5 or itemInfo.Type == 3  then --可使用（體力，錢袋，修為丹）  類型(1裝備,2碎片，3寶箱，4書籍，5消耗品,6材料，7道具)
			BagItem.super.addFlag(self,"keshiyong")
			haveFlag = true
		elseif itemInfo.Type == 2 then
			if itemInfo.id ~= nil then
				local needNum = 0
				local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
				local str = string.split(conf:getValue("Extra"),"=")
				if str ~= nil and tonumber(str[2]) ~= nil then
					needNum = tonumber(str[2])
				end
				if itemInfo.num >= needNum then
					BagItem.super.addFlag(self,"kehecheng")
					haveFlag = true
				end
			end
		elseif itemInfo.Type == 4 then
			if itemInfo.id ~= nil then
				local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
				local str = string.split(conf:getValue("Extra"),"=")
				if str ~= nil and tonumber(str[1]) ~= nil then
					local skillID = tonumber(str[1])
					local skillInfo = cp.getUserData("UserSkill"):getSkill(skillID)
					if skillInfo == nil then
						BagItem.super.addFlag(self,"kexuexi")
						haveFlag = true
					end
				end
			end
		end
		]]
	end
	if not haveFlag then
		BagItem.super.addFlag(self,nil)
	end

	if itemInfo then
		BagItem.super.addFlagNew(self,itemInfo.newlyAcquired)	
	end
end

return BagItem