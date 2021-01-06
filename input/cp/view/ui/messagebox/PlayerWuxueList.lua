local PlayerWuxueList = class("PlayerWuxueList",function() return cc.Node:create() end)
function PlayerWuxueList:create(wuxueList)
    local ret = PlayerWuxueList.new()
    ret:init(wuxueList)
    return ret
end

function PlayerWuxueList:init(wuxueList)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_wuxue_list.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Panel_title.ScrollView_1"] = {name = "ScrollView_1" },
		["Panel_root.Image_bg.Panel_title.Button_close"] = {name = "Button_close" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	display.loadSpriteFrames("uiplist/ui_common.plist")
	self["Image_bg"]:setTouchEnabled(true)
	
	self:initwuxueList(wuxueList)
	self:setPosition(cc.p(display.cx,display.cy))
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
		self:removeFromParent()
	end)
	
end

function PlayerWuxueList:initwuxueList(wuxueList)
	if wuxueList == nil or #wuxueList == 0 then
		return
	end

	local scrollViewSize = self["ScrollView_1"]:getContentSize()
	
	for i=1,6 do
		local wuxueId = tonumber(wuxueList[i].skill_id)
		local wuxueLevel = tonumber(wuxueList[i].skill_level)
		local cfgItem3 = cp.getManager("ConfigManager").getItemByKey("SkillEntry", wuxueId)
		local Name = cfgItem3:getValue("SkillName")
		local Colour = cfgItem3:getValue("Colour")
		local Icon = cfgItem3:getValue("Icon")
		local wuxueInfo = {id=wuxueId,level = wuxueLevel, Name = Name, Colour = Colour,Icon = Icon }
		local item = require("cp.view.ui.item.SkillItem"):create(wuxueInfo)

		local sz = item:getContentSize()
		local x,y = 0,0 
		if i>3 then
			x,y = (i-4)*sz.width + sz.width/2 + (i-3)*60, 20 + sz.height/2+10
		else
			x,y = (i-1)*sz.width + sz.width/2 + i*60, 170 + sz.height/2+10
		end
		item:setPosition(cc.p(x, y))
		self.ScrollView_1:addChild(item)
		item:setItemClickCallBack(function()
			
			local combatSkillInfo = {id = wuxueId,skill_level = wuxueLevel}
			local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", combatSkillInfo.id)
			
			if skillEntry == nil or skillEntry:getValue("SkillType") == 2 or skillEntry:getValue("SkillType") == 3 then
				return
			end
			local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry, combatSkillInfo)
			self:addChild(layer, 1)
			layer:setPosition(cc.p(-display.cx,-display.cy))
		end)
	end

end

function PlayerWuxueList:onCloseButtonClick(sender)
	 self:removeFromParent()
end

function PlayerWuxueList:getDescription()
    return "PlayerWuxueList"
end

return PlayerWuxueList