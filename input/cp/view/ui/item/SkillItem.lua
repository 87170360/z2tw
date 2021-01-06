local ItemIcon = require("cp.view.ui.icon.ItemIcon")
local SkillItem = class("SkillItem",ItemIcon)
function SkillItem:create(itemInfo)
    local ret = SkillItem.new()
    ret:init(itemInfo)
    return ret
end


function SkillItem:init(itemInfo)
	SkillItem.super.init(self,itemInfo)

	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	--display.loadSpriteFrames("uiplist/ui_common.plist")
	local panelItemSz = self["Panel_item"]:getContentSize()
	self:setContentSize(panelItemSz)
	
	
	self["Panel_item"]:setTouchEnabled(true)
	
	self:setItemInfo()
end

function SkillItem:setItemInfo()
	if self.itemInfo == nil then
		return
	end
	
	SkillItem.super.setItemInfo(self,itemInfo)

end

function SkillItem:reset(itemInfo)
	SkillItem.super.reset(self,itemInfo)


end

return SkillItem