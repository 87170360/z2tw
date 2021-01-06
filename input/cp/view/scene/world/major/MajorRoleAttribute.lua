local BNode = require "cp.view.ui.base.BNode"
local MajorRoleAttribute = class("MajorRoleAttribute",BNode)
local AttributeConst = cp.getConst("AttributeConst")

function MajorRoleAttribute:create(openInfo)
	local node = MajorRoleAttribute.new(openInfo)
	return node
end

function MajorRoleAttribute:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
	
	--更新人物全屬性
    [cp.getConst("EventConst").GetRoleRsp] = function(evt)
      self:onRoleUpdate()
    end,
	}
end

function MajorRoleAttribute:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_role_attribute.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Image_attribute_bg"] = {name = "Image_attribute_bg", click = "onUIButtonClick", clickScale = 1},
		["Image_attribute_bg.Button_JiChu"] = {name = "Button_JiChu",click = "onUIButtonClick"},
		["Image_attribute_bg.Button_ZhuiJia"] = {name = "Button_ZhuiJia",click = "onUIButtonClick"},
		["Image_attribute_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
		["Image_attribute_bg.Panel_Attribute_Base"] = {name = "Panel_Attribute_Base"},

		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_ShengMing"] = {name = "Text_Tip_ShengMing"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_NeiLi"] = {name = "Text_Tip_NeiLi"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_GongJi"] = {name = "Text_Tip_GongJi"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_FangYu"] = {name = "Text_Tip_FangYu"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_MingZhong"] = {name = "Text_Tip_MingZhong"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_ShanBi"] = {name = "Text_Tip_ShanBi"},

		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_zhaojia1"] = {name = "Text_Tip_zhaojia1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_zhaojia2"] = {name = "Text_Tip_zhaojia2"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_lianji1"] = {name = "Text_Tip_lianji1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_lianji2"] = {name = "Text_Tip_lianji2"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_baoji1"] = {name = "Text_Tip_baoji1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_baoji2"] = {name = "Text_Tip_baoji2"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_juqi1"] = {name = "Text_Tip_juqi1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_juqi2"] = {name = "Text_Tip_juqi2"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_tiaoxi1"] = {name = "Text_Tip_tiaoxi1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_tiaoxi2"] = {name = "Text_Tip_tiaoxi2"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_xiuyang1"] = {name = "Text_Tip_xiuyang1"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_xiuyang2"] = {name = "Text_Tip_xiuyang2"},

		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_daofa"] = {name = "Text_Tip_daofa"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_jianfa"] = {name = "Text_Tip_jianfa"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_gunfa"] = {name = "Text_Tip_gunfa"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_qimen"] = {name = "Text_Tip_qimen"},
		["Image_attribute_bg.Panel_Attribute_Base.Text_Tip_quanzhang"] = {name = "Text_Tip_quanzhang"},

		["Image_attribute_bg.Panel_Attribute_Base.Button_help"] = {name = "Button_help",click = "onUIButtonClick",clickScale = 0.7},

		["Image_attribute_bg.Panel_Attribute_Attach"] = {name = "Panel_Attribute_Attach"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v1"] = {name = "bang_v1"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v2"] = {name = "bang_v2"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v3"] = {name = "bang_v3"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v4"] = {name = "bang_v4"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v5"] = {name = "bang_v5"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v6"] = {name = "bang_v6"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_bang.v7"] = {name = "bang_v7"},

		["Image_attribute_bg.Panel_Attribute_Attach.Panel_men.v1"] = {name = "men_v1"},
		["Image_attribute_bg.Panel_Attribute_Attach.Panel_men.v2"] = {name = "men_v2"},

	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

  	self["Panel_Attribute_Attach"]:setVisible(false)

	self.bangValues = {
		[AttributeConst.HpValue] 			= self["bang_v1"],
		[AttributeConst.MpValue] 			= self["bang_v2"],
		[AttributeConst.AttackValue] 		= self["bang_v3"],
		[AttributeConst.HpPercent] 			= self["bang_v4"],
		[AttributeConst.MpPercent] 			= self["bang_v5"],
		[AttributeConst.AttackPercent] 		= self["bang_v6"],
		[AttributeConst.DefendPercent] 		= self["bang_v7"]
	}

	self.menValues = {
		[AttributeConst.HpPercent] 			= self["men_v1"],
		[AttributeConst.DefendPercent] 		= self["men_v2"]
	}
  	
	--[[
	if openInfo.type == "MajorRoleSelf" then
	elseif openInfo.type == "MajorRoleOther" then
	end
	ccui.Helper:doLayout(self.rootView)
	]]

	self.openInfo = openInfo
	if openInfo.type == "MajorRoleOther" then
		self.rootView:setPosition(cc.p(display.cx,453)) -- 查看其他玩家訊息界面高度為906
	else
		self.rootView:setPosition(cc.p(display.cx,display.cy))
	end
	
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b, nil, function()
		if self.closeCallBack then
			self.closeCallBack()
	  	end
		self:removeFromParent()
	end)

	ccui.Helper:doLayout(self["rootView"])
end

function MajorRoleAttribute:onEnterScene()
	self.AttributeState = 1

	self:onRoleUpdate()
end

function MajorRoleAttribute:onUIButtonClick(sender)
  local buttonName = sender:getName()
  log("click button : " .. buttonName)
  local selectImg 	= "ui_major_role_module11_rwsx_biaoqian1.png"
  local unSelectImg 	= "ui_major_role_module11_rwsx_biaoqian2.png"

  if "Panel_Attribute" == buttonName then
	  	if self.closeCallBack then
			self.closeCallBack()
	  	end
	  	self:removeFromParent()
  elseif "Button_close"  == buttonName then
		if self.closeCallBack then
			self.closeCallBack()
	  	end
	  	self:removeFromParent()
  elseif "Button_JiChu"  == buttonName then
	if self.AttributeState ~= 1 then
		self.AttributeState = 1
		self["Button_JiChu"]:loadTextures(selectImg, selectImg, selectImg, ccui.TextureResType.plistType)
		self["Button_ZhuiJia"]:loadTextures(unSelectImg, unSelectImg, unSelectImg, ccui.TextureResType.plistType)
	end
  	self["Panel_Attribute_Attach"]:setVisible(false)
  	self["Panel_Attribute_Base"]:setVisible(true)
  elseif "Button_ZhuiJia"  == buttonName then
	if self.AttributeState ~= 2 then
		self.AttributeState = 2
		self["Button_JiChu"]:loadTextures(unSelectImg, unSelectImg, unSelectImg, ccui.TextureResType.plistType)
		self["Button_ZhuiJia"]:loadTextures(selectImg, selectImg, selectImg, ccui.TextureResType.plistType)
	end
  	self["Panel_Attribute_Attach"]:setVisible(true)
  	self["Panel_Attribute_Base"]:setVisible(false)
  elseif "Button_help" == buttonName then
		cp.getManager("ViewManager").showJingTongTips()
  end
end


function MajorRoleAttribute:onRoleUpdate()
	if self.openInfo == nil or self.openInfo.roleAtt == nil then
		return
	end
	local roleAtt = self.openInfo.roleAtt
	self["Text_Tip_ShengMing"]:setString("" .. roleAtt.hp)
    self["Text_Tip_NeiLi"]:setString("" .. roleAtt.mp)
    self["Text_Tip_GongJi"]:setString("" .. roleAtt.attack)
    self["Text_Tip_FangYu"]:setString("" .. roleAtt.defend)
    self["Text_Tip_MingZhong"]:setString("" .. roleAtt.hit)
    self["Text_Tip_ShanBi"]:setString("" .. roleAtt.dodge)

    self["Text_Tip_zhaojia1"]:setString("" .. roleAtt.parry)
    self["Text_Tip_zhaojia2"]:setString(roleAtt.parryPercent / 100 .. "%")
    self["Text_Tip_lianji1"]:setString("" .. roleAtt.batter)
    self["Text_Tip_lianji2"]:setString(roleAtt.batterPercent / 100 .. "%")
    self["Text_Tip_baoji1"]:setString("" .. roleAtt.crit)
    self["Text_Tip_baoji2"]:setString(roleAtt.critPercent / 100 .. "%")
    self["Text_Tip_juqi1"]:setString("" .. roleAtt.energy)
    self["Text_Tip_juqi2"]:setString(string.format("%.2f", roleAtt.energyTime) .. "秒")
    self["Text_Tip_tiaoxi1"]:setString("" .. roleAtt.mpResume)
	if roleAtt.mpResumeRate >= 0 then
    	self["Text_Tip_tiaoxi2"]:setString("+" .. roleAtt.mpResumeRate)
	else
    	self["Text_Tip_tiaoxi2"]:setString("" .. roleAtt.mpResumeRate)
	end
    self["Text_Tip_xiuyang1"]:setString("" .. roleAtt.hpResume)
	if roleAtt.hpResumeRate >= 0 then
    	self["Text_Tip_xiuyang2"]:setString("+" .. roleAtt.hpResumeRate)
	else
    	self["Text_Tip_xiuyang2"]:setString("" .. roleAtt.hpResumeRate)
	end

    self["Text_Tip_daofa"]:setString(roleAtt.knife .. "")
    self["Text_Tip_jianfa"]:setString(roleAtt.sword .. "")
    self["Text_Tip_gunfa"]:setString(roleAtt.stick .. "")
    self["Text_Tip_qimen"]:setString(roleAtt.strange .. "")
    self["Text_Tip_quanzhang"]:setString(roleAtt.fist .. "")

	--attach attribute
		--幫派
	local guildAtt = self.openInfo.guildAtt
	if guildAtt ~= nil then
		for _, v in pairs(guildAtt) do 
			text = self.bangValues[v.type]

			if text ~= nil then
				if v.type == AttributeConst.HpValue or v.type == AttributeConst.MpValue or v.type == AttributeConst.AttackValue then 
					text:setString("+" .. v.value)
				else
					text:setString("+" .. v.value/100 .. "%")
				end
			end
		end 
	end
		--門派
	local gangConf = cp.getManager("ConfigManager").getItemByKey("GangRank", "" .. roleAtt.gangRank)
	--不需要處理配置分段部分
	if gangConf ~= nil then	
 		local gangAtt = cp.getUtils("DataUtils").split(gangConf:getValue("Attribute"), "|=")
		for _, v in pairs(gangAtt) do
			text = self.menValues[v[1]]
			if text ~= nil then
				text:setString("+" .. v[2] / 100 .. "%")
			end
		end
	end
end

function MajorRoleAttribute:setCloseCallBack(cb)
	self.closeCallBack = cb
end

return MajorRoleAttribute
