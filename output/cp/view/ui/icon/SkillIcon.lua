-- 物品(含裝備)及武學圖標框的基類，兩者共有屬性, 不包含點擊事件處理
local SkillIcon = class("SkillIcon",function() return cc.Node:create() end)
local CombatConst = cp.getConst("CombatConst")

-- itemInfo = {Name = "表格中對應的Name", Icon = "表格中對應的Icon", num = "數量", Colour ="品質", hideName = "true/false 是否隱藏名字"}
function SkillIcon:create(skillInfo)
	local ret = SkillIcon.new()
	ret:reset(skillInfo)
    return ret
end

function SkillIcon:ctor()	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_skill.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_Skill"] = {name = "Panel_Skill", click="onSkillClicked"},
		["Panel_Skill.Image_Icon"] = {name = "Image_Icon"},
		["Panel_Skill.Image_Pendant"] = {name = "Image_Pendant"},
		["Panel_Skill.Image_Box"] = {name = "Image_Box"},
		["Panel_Skill.Text_Name"] = {name = "Text_Name"},
		["Panel_Skill.Text_Level"] = {name = "Text_Level"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
end

function SkillIcon:onSkillClicked()
	self.skillClicked()
end

function SkillIcon:updateSkillIconView(skillInfo)
	self.Image_Icon:loadTexture(skillInfo.icon)
	self.Image_Box:loadTexture(CombatConst.SkillBoxList[skillInfo.color], ccui.TextureResType.plistType)
	self.Text_Name:setString(skillInfo.name)
	cp.getManager("ViewManager").setTextQuality(self.Text_Name, skillInfo.color)
	if skillInfo.level == 0 then
		self.Text_Level:setString("")
	else
		self.Text_Level:setString("LV."..skillInfo.level)
	end
	if skillInfo.showPendant then
		self.Image_Pendant:setVisible(true)
	else
		self.Image_Pendant:setVisible(false)
	end
end

function SkillIcon:setIconShader(name)
	cp.getManager("ViewManager").setShader(self.Image_Icon, name)
end

function SkillIcon:setIconColor(color)
	self.Image_Icon:setColor(color)
end

function SkillIcon:setSkillClicked(fn)
	self.skillClicked = fn
end

function SkillIcon:reset(skillInfo)
	self:updateSkillIconView(skillInfo)
end

return SkillIcon
