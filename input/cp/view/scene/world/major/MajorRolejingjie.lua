local BNode = require "cp.view.ui.base.BNode"
local MajorRolejingjie = class("MajorRolejingjie",BNode)

function MajorRolejingjie:create(openInfo)
	local node = MajorRolejingjie.new(openInfo)
	return node
end

function MajorRolejingjie:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
	}
end

function MajorRolejingjie:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/major_role_jingjie.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		--Panel_jingjie
		["Panel_jingjie"] = {name = "Panel_jingjie", click = "onUIButtonClick", clickScale = 1},
		["Panel_jingjie.Button_jingjie_close"] = {name = "Button_jingjie_close",click = "onUIButtonClick"},
		["Panel_jingjie.Text_shengming"] = {name = "Panel_jingjie_Text_shengming"},
		["Panel_jingjie.Text_neili"] = {name = "Panel_jingjie_Text_neili"},
		["Panel_jingjie.Text_gongji"] = {name = "Panel_jingjie_Text_gongji"},
		["Panel_jingjie.Text_fangyu"] = {name = "Panel_jingjie_Text_fangyu"},
		["Panel_jingjie.Text_juqi"] = {name = "Panel_jingjie_Text_juqi"},
		["Panel_jingjie.Text_shengming_0"] = {name = "Panel_jingjie_Text_shengming_0"},
		["Panel_jingjie.Text_neili_0"] = {name = "Panel_jingjie_Text_neili_0"},
		["Panel_jingjie.Text_gongji_0"] = {name = "Panel_jingjie_Text_gongji_0"},
		["Panel_jingjie.Text_fangyu_0"] = {name = "Panel_jingjie_Text_fangyu_0"},
		["Panel_jingjie.Text_juqi_0"] = {name = "Panel_jingjie_Text_juqi_0"},
		["Panel_jingjie.Text_shengming_1"] = {name = "Panel_jingjie_Text_shengming_1"},
		["Panel_jingjie.Text_neili_1"] = {name = "Panel_jingjie_Text_neili_1"},
		["Panel_jingjie.Text_gongji_1"] = {name = "Panel_jingjie_Text_gongji_1"},
		["Panel_jingjie.Text_fangyu_1"] = {name = "Panel_jingjie_Text_fangyu_1"},
		["Panel_jingjie.Text_juqi_1"] = {name = "Panel_jingjie_Text_juqi_1"},
		["Panel_jingjie.Text_level"] = {name = "Panel_jingjie_Text_level"},
		["Panel_jingjie.Image_role_jingjie"] = {name = "Panel_jingjie_Image_role_jingjie"},
		["Panel_jingjie.Text_exp"] = {name = "Panel_jingjie_Text_exp"},
		["Panel_jingjie.LoadingBar_exp"] = {name = "Panel_jingjie_LoadingBar_exp"},
		["Panel_jingjie.Panel_list"] = {name = "Panel_jingjie_Panel_list"},
		["Panel_jingjie.Image_arrow_shengming"] = {name = "Panel_jingjie_Image_arrow_shengming"},
		["Panel_jingjie.Image_arrow_neili"] = {name = "Panel_jingjie_Image_arrow_neili"},
		["Panel_jingjie.Image_arrow_gongji"] = {name = "Panel_jingjie_Image_arrow_gongji"},
		["Panel_jingjie.Image_arrow_fangyu"] = {name = "Panel_jingjie_Image_arrow_fangyu"},
		["Panel_jingjie.Image_arrow_juqi"] = {name = "Panel_jingjie_Image_arrow_juqi"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	self.rootView:setPosition(cc.p(display.cx,display.cy))
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b, nil, function()
		if self.closeCallBack then
			self.closeCallBack()
	  	end
		self:removeFromParent()
	end)
	ccui.Helper:doLayout(self.rootView)

	self.jingjie = { 
		selfText = {
    		self["Panel_jingjie_Text_shengming"],
    		self["Panel_jingjie_Text_neili"],
    		self["Panel_jingjie_Text_gongji"],
    		self["Panel_jingjie_Text_fangyu"],
    		self["Panel_jingjie_Text_juqi"],
		},
		targetText = {
    		self["Panel_jingjie_Text_shengming_0"],
    		self["Panel_jingjie_Text_neili_0"],
    		self["Panel_jingjie_Text_gongji_0"],
    		self["Panel_jingjie_Text_fangyu_0"],
    		self["Panel_jingjie_Text_juqi_0"],
		},
		changeText = {
    		self["Panel_jingjie_Text_shengming_1"],
    		self["Panel_jingjie_Text_neili_1"],
    		self["Panel_jingjie_Text_gongji_1"],
    		self["Panel_jingjie_Text_fangyu_1"],
    		self["Panel_jingjie_Text_juqi_1"],
		},
		attName = {
			"HP",	
			"MP",	
			"Attack",	
			"Defend",	
			"Energy",	
		},
		arrow = {
			self["Panel_jingjie_Image_arrow_shengming"],
			self["Panel_jingjie_Image_arrow_neili"],
			self["Panel_jingjie_Image_arrow_gongji"],
			self["Panel_jingjie_Image_arrow_fangyu"],
			self["Panel_jingjie_Image_arrow_juqi"],
		}
	}

end

function MajorRolejingjie:onUIButtonClick(sender)
  local buttonName = sender:getName()
  log("click button : " .. buttonName)
  
  if "Button_jingjie_close"  == buttonName then
		if self.closeCallBack then
			self.closeCallBack()
	  	end
	  	self:removeFromParent()
  end
end


function MajorRolejingjie:onEnterScene()
	local roleAtt = self.openInfo.roleAtt
	if roleAtt == nil then
		return
	end

	--cellview
	local cellViewCallback = function(itemInfo)
		self:setJingJieText(itemInfo.level)  
		for i1, v1 in ipairs(self.jingjieItemInfo) do
			v1.select = itemInfo.idx == i1
		end
		local offset = self.cellView:getContentOffset()
		self.cellView:reloadData()
		--dump(offset)
		self.cellView:setContentOffset(offset, false)
	end

	self.jingjieItemInfo = {}
	for i, v in ipairs(cp.getManager("ConfigManager").getConfig("RoleAttribute").dataList) do
		self.jingjieItemInfo[i] = {
			select = v[1] == roleAtt.level,
			tip = v[18] == 1 or false,
			level = v[1],
			desc = v[17],
			idx = i,
			cover = roleAtt.level < v[1],
			callback = cellViewCallback,
		}
	end

	self.cellView = cp.getManager("ViewManager").createCellView(self["Panel_jingjie_Panel_list"]:getContentSize())
    self.cellView:setCellSize(175,58)
    self.cellView:setColumnCount(1)
	self.cellView:setCellCount(cp.getManager("ConfigManager").getItemCount("RoleAttribute"))
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p(0, 0))
	self.cellView:setCellFactory(function(cellview, idx) return self:cellFactory(cellview, idx + 1) end)
	self.cellView:reloadData()
	self["Panel_jingjie_Panel_list"]:addChild(self.cellView)

	levelOffset = cc.p(0, -2529 + roleAtt.level * 2529 / 50 + 75 )
	--dump(levelOffset)
	self.cellView:setContentOffset(levelOffset, false)

	self:onRoleUpdate()
end

function MajorRolejingjie:cellFactory(cellview, idx)
	--log("idx    " .. idx)
	itemInfo = self.jingjieItemInfo[idx]

    local item = nil
    local cell = cellview:dequeueCell()
    if nil == cell then
		cell = cc.TableViewCell:new()
		item = require("cp.view.ui.item.JingjieItem"):create(itemInfo)		
		item:setAnchorPoint(cc.p(0,0))
        item:setName("item")
		cell:addChild(item)
    else
		item = cell:getChildByName("item")
		item:reset(itemInfo)
    end
    return cell
end

--設置境界目標值和差異值
function MajorRolejingjie:setJingJieText(targetLevel)
	local roleAtt = self.openInfo.roleAtt
	if roleAtt == nil then
		return
	end

	local selfConf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", roleAtt.level)
	local targetConf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", targetLevel)

	local value = 0
	for i, v in ipairs(self.jingjie.targetText) do
		v:setString(targetConf:getValue(self.jingjie.attName[i]) .. "")
		value = targetConf:getValue(self.jingjie.attName[i]) - selfConf:getValue(self.jingjie.attName[i])
		changeText = self.jingjie.changeText[i]
		arrow = self.jingjie.arrow[i]
		if value >= 0 then
			changeText:setString("+" .. value)
			changeText:setTextColor(cc.c3b(24,178,42))
			arrow:loadTexture("ui_major_role_jingjie_module11_rwsx_yueli_shangsheng.png", ccui.TextureResType.plistType)
		else
			changeText:setString(value)
			changeText:setTextColor(cc.c3b(234,42,42))
			arrow:loadTexture("ui_major_role_jingjie_module11_rwsx_yueli_xiajiang.png", ccui.TextureResType.plistType)
		end
	end
end


function MajorRolejingjie:onRoleUpdate()
	local roleAtt = self.openInfo.roleAtt
	if roleAtt == nil then
		return
	end

	--jingjie
	local attConf = cp.getManager("ConfigManager").getItemByKey("RoleAttribute", roleAtt.level)
	for i, v in ipairs(self.jingjie.selfText) do
		v:setString(attConf:getValue(self.jingjie.attName[i]) .. "")
	end
	self:setJingJieText(roleAtt.level)
	self["Panel_jingjie_Text_level"]:setString("Lv." .. roleAtt.level)
	self["Panel_jingjie_Image_role_jingjie"]:loadTexture("img/icon/jingjie/jingjie_" .. roleAtt.level ..".png", ccui.TextureResType.localType)
	self["Panel_jingjie_Text_exp"]:setString(roleAtt.exp .. " / " .. attConf:getValue("ExpMax"))
	self["Panel_jingjie_LoadingBar_exp"]:setPercent(roleAtt.exp * 100 / attConf:getValue("ExpMax"))
	if roleAtt.level == cp.getManager("ConfigManager").getItemCount("RoleAttribute") then 
		self["Panel_jingjie_LoadingBar_exp"]:setPercent(100)
		self["Panel_jingjie_Text_exp"]:setString(attConf:getValue("ExpMax") .. " / " .. attConf:getValue("ExpMax"))
	end

end

function MajorRolejingjie:setCloseCallBack(cb)
	self.closeCallBack = cb
end

return MajorRolejingjie
