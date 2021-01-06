local BLayer = require "cp.view.ui.base.BLayer"
local GuildCreateLayer = class("GuildCreateLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function GuildCreateLayer:create()
	local scene = GuildCreateLayer.new()
    return scene
end

function GuildCreateLayer:initListEvent()
    self.listListeners = {
    }
end

--初始化界面，以及設定界面元素標籤
function GuildCreateLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_guild/uicsb_guild_create.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_Name.TextField_Name"] = {name = "TextField_Name"},
		["Panel_root.Image_1.Image_Name.Text_Num"] = {name = "Text_Num"},
		["Panel_root.Image_1.Image_Spirit.TextField_Spirit"] = {name = "TextField_Spirit"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Cancel"] = {name = "Button_Cancel", click="onBtnClick"},
		["Panel_root.Image_1.Button_Create"] = {name = "Button_Create", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.TextField_Name,"InputBox_Name",nil)
	cp.getManager("ViewManager").addTextFieldEvent(self.rootView, self.TextField_Spirit,"InputBox_Spirit",nil)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	ccui.Helper:doLayout(self.rootView)
	
	local createGuildConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:")[4]
	self.Text_Num:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
		local name = self.TextField_Name:getString()
		local hanzCount, nhzCount = cp.getUtils("DataUtils").getHanziNum(name)
		if nhzCount > 0 then
			self.Text_Num:setString("只能輸入漢字")
			cp.getManager("ViewManager").setTextQuality(self.Text_Num, 6)
		else
			if hanzCount < createGuildConfig[1] or hanzCount > createGuildConfig[2] then
				self.Text_Num:setString(string.format("%d~%d個漢字", createGuildConfig[1], createGuildConfig[2]))
				cp.getManager("ViewManager").setTextQuality(self.Text_Num, 6)
			else
				cp.getManager("ViewManager").setTextQuality(self.Text_Num, 2)
				self.Text_Num:setString(string.format("%d/6", hanzCount, createGuildConfig[2]))
			end
		end
	end), cc.DelayTime:create(1))))
end

function GuildCreateLayer:updateGuildCreateView()
end

function GuildCreateLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Close" or nodeName == "Button_Cancel" then
        self:removeFromParent()
	elseif nodeName == "Button_Create" then
		local createGuildConfig = cp.getUtils("DataUtils").split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("GuildConfig"), ";:")
		local name = self.TextField_Name:getString()
		local hanzCount, nhzCount = cp.getUtils("DataUtils").getHanziNum(name)
	
		if hanzCount < createGuildConfig[4][1] or hanzCount > createGuildConfig[4][2] or nhzCount ~= 0 then
			cp.getManager("ViewManager").gameTip("幫派名只能輸入漢字")
		end

		local roleAtt = cp.getUserData("UserRole").major_roleAtt
		if createGuildConfig[1][1] > roleAtt.gold then
			local contentTable = {
				{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="您的元寶不足，是否前往儲值界面進行儲值？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			}
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
				cp.getManager("ViewManager").showRechargeUI()
			end,nil)
			return 
		end

		--log("hanzi num"..hanzCount)
        local req = {}
        req.name = self.TextField_Name:getString()
        req.spirit = self.TextField_Spirit:getString()
        self:doSendSocket(cp.getConst("ProtoConst").CreateGuildReq, req)
    elseif nodeName == "Button_AddCount" then
		local contentTable = {
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
			{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
			{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，重置今日挑戰次數？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
		}
		cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
	end
end

function GuildCreateLayer:onEnterScene()
	self:updateGuildCreateView()
end

function GuildCreateLayer:onExitScene()
    self:unscheduleUpdate()
end

return GuildCreateLayer