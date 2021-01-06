local BLayer = require "cp.view.ui.base.BLayer"
local GuildBuildingLayer = class("GuildBuildingLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildBuildingLayer:create()
	local scene = GuildBuildingLayer.new()
    return scene
end

function GuildBuildingLayer:initListEvent()
    self.listListeners = {
		["GuildBuildRsp"] = function(data)
            cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_wuxue_3)
			local buildingInfo = cp.getUserData("UserGuild"):getBuildInfo(self.building)
			local temp = cp.getManager("ConfigManager").getItemByKey("GuildBuilding", buildingInfo.level):getValue("Building"..self.building-1)
			local buildingLevelConfig = cp.getUtils("DataUtils").split(temp, ";:=")
			self.LoadingBar_Exp:updateProgress(buildingLevelConfig[1][1][1], 10, 0.2)
			self.Image_1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
				self:updateGuildBuildingView()
			end)))
			local img = self["Image_Building"..self.building]
			local model = img:getChildByName("Effect")
			model:setAnimation(0, "bangpaishengji", false)
		end,
    }
end

local buildingDesc = {
	"%s建築收益\n每日幫派經驗+%d\n全員%s",
	"%s建築收益\n每日幫派經驗+%d\n全員%s",
	"%s建築收益\n每日幫派經驗+%d\n全員%s"
}
local levelName = {
	"初級", "中級", "高級"
}
--初始化界面，以及設定界面元素標籤
function GuildBuildingLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_building.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)
	self.building = 1
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_3"] = {name = "Image_3"},
		["Panel_root.Image_1.Image_Building1"] = {name = "Image_Building1"},
		["Panel_root.Image_1.Image_Building2"] = {name = "Image_Building2"},
		["Panel_root.Image_1.Image_Building3"] = {name = "Image_Building3"},
		["Panel_root.Image_1.LoadingBar_Exp"] = {name = "LoadingBar_Exp"},
		["Panel_root.Image_1.LoadingBar_Exp.Text_Exp"] = {name = "Text_Exp"},
		["Panel_root.Image_1.Image_Level"] = {name = "Image_Level"},
		["Panel_root.Image_1.Text_LevelDesc"] = {name = "Text_LevelDesc"},
		["Panel_root.Image_1.Text_Count"] = {name = "Text_Count"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
		["Panel_root.Image_1.Image_Cost"] = {name = "Image_Cost"},
		["Panel_root.Image_1.Button_Build"] = {name = "Button_Build", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Rule"] = {name = "Button_Rule", click="onBtnClick"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)

    ccui.Helper:doLayout(self.rootView)
    self.LoadingBar_Exp = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Exp, self.Text_Exp, false)
	local buildingInfo = cp.getUserData("UserGuild"):getBuildInfo(self.building)
	local temp = cp.getManager("ConfigManager").getItemByKey("GuildBuilding", buildingInfo.level):getValue("Building"..self.building-1)
	local buildingLevelConfig = cp.getUtils("DataUtils").split(temp, ";:=")
	self.LoadingBar_Exp:initProgress(buildingLevelConfig[1][1][1], buildingInfo.exp)
	--[[
	cp.getManager("ViewManager").setShaderSingle(self.Image_3, "Water", function(glProgramState)
		local glProgram = glProgramState:getGLProgram()
		local location = gl.getUniformLocation("resolution")
		glProgramState:setUniformVec2(location, cc.p(500, 500))
	end)
	]]
end

function GuildBuildingLayer:updateGuildBuildingView()
    local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
    local guildDetailData = cp.getUserData("UserGuild"):getGuildDetailData()
	local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildBuilding"), ";:")
	local buildingInfo = cp.getUserData("UserGuild"):getBuildInfo(self.building)
	local temp = cp.getManager("ConfigManager").getItemByKey("GuildBuilding", buildingInfo.level):getValue("Building"..self.building-1)
	local buildingLevelConfig = cp.getUtils("DataUtils").split(temp, ";:=")
    self.LoadingBar_Exp:initProgress(buildingLevelConfig[1][1][1], buildingInfo.exp)
	
	local img = self["Image_Building"..self.building]
	local btn = img:getChildByName("Button")
	self.Image_Level:getChildByName("Text_Level"):setString(levelName[buildingInfo.level].."建築")
	for i=1, 3 do
		local img = self["Image_Building"..i]
		local btn = img:getChildByName("Button")
		local txtLevel = img:getChildByName("Text_Level")
		local buildingInfo1 = cp.getUserData("UserGuild"):getBuildInfo(i)
		if commonConfig[1][i] > guildDetailData.level then
			cp.getManager("ViewManager").setEnabled(btn, false)
			txtLevel:setString(commonConfig[1][i].."級開啟")
		else
			cp.getManager("ViewManager").setEnabled(btn, true)
			txtLevel:setString(levelName[buildingInfo1.level])
		end
		cp.getManager("ViewManager").initButton(btn, function()
			self.building = i
			self:updateGuildBuildingView()
		end, 1)
		
		if i == self.building then
			btn:setEnabled(false)
		end

		local model = img:getChildByName("Effect")
		if model == nil then
			local model = cp.getManager("ViewManager").createSpineAnimation("res/spine/bangpaishengji/bangpaishengji")
			model:setName("Effect")
			img:addChild(model)
			model:setPosition(83, 0)
		end
	end

	if playerGuildData.build_info.count >= commonConfig[6][1] then
		local cost = cp.getUtils("DataUtils").GetPriceByCount(playerGuildData.build_info.count - commonConfig[6][1], commonConfig[2])
		self.Text_Cost:setString("消耗"..cost)
		self.Image_Cost:setVisible(true)
	else
		self.Text_Cost:setString("免費次數x"..commonConfig[6][1]-playerGuildData.build_info.count)
		self.Image_Cost:setVisible(false)
	end

	self.Text_Count:setString(string.format("%d/%d", playerGuildData.build_info.count, commonConfig[5][1]))
	if commonConfig[5][1] > playerGuildData.build_info.count then
		cp.getManager("ViewManager").setTextQuality(self.Text_Count, 2)
	else
		cp.getManager("ViewManager").setTextQuality(self.Text_Count, 6)
		self.countOver = true
	end
	local attrDesc = ""
	for _, config in ipairs(buildingLevelConfig[3]) do
		if attrDesc ~= "" then
			attrDesc = attrDesc .. "；"
		end
		attrDesc = attrDesc .. cp.getUtils("DataUtils").formatSkillAttribute(config[1], config[2])
	end
	self.Text_LevelDesc:setString(string.format(buildingDesc[buildingInfo.building], levelName[buildingInfo.level], buildingLevelConfig[2][1][1], attrDesc))
end

function GuildBuildingLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" then
        self:removeFromParent()
	elseif nodeName == "Button_Build" then
		if self.countOver then
            cp.getManager("ViewManager").gameTip("今日建造次數已滿")
			return
		end
		local playerGuildData = cp.getUserData("UserGuild"):getPlayerGuildData()
		local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildBuilding"), ";:")
		if false then--playerGuildData.build_info.count >= commonConfig[6][1] then
			local commonConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildBuilding"), ";:")
			local need = commonConfig[2][playerGuildData.build_info.count - commonConfig[6][1]+1]
			if need == nil then
				need = commonConfig[2][#commonConfig[2]]
			end
			if not cp.getManager("ViewManager").checkGoldEnough(need) then
				return
			end
			
			local contentTable = {
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
				{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，完成一次幫派建設？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			}
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
				local req = {}
				req.building = self.building
				self:doSendSocket(cp.getConst("ProtoConst").GuildBuildReq, req)
			end,nil)
		else
			local req = {}
			req.building = self.building
			self:doSendSocket(cp.getConst("ProtoConst").GuildBuildReq, req)
		end

	elseif nodeName == "Button_Rule" then
        local desc = cc.FileUtils:getInstance():getStringFromFile("xml/rc_guild_building_rule.xml")
        local layer = require("cp.view.scene.mountain.MountainRuleLayer"):create("guild_building_rule", desc)
        self:addChild(layer, 100)
	end
end

function GuildBuildingLayer:onEnterScene()
	self:updateGuildBuildingView()
end

function GuildBuildingLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildBuildingLayer