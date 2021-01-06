
local BNode = require "cp.view.ui.base.BNode"
local MenPaiMockFightsItem = class("MenPaiMockFightsItem",BNode)

function MenPaiMockFightsItem:create(openInfo)
	local node = MenPaiMockFightsItem.new(openInfo)
	return node
end

function MenPaiMockFightsItem:initListEvent()
	self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
      
	}
end

function MenPaiMockFightsItem:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_menpai/uicsb_menpai_mockfights_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item",click = "onItemClick"},
		["Panel_item.Image_head"] = {name = "Image_head"},
        ["Panel_item.Text_fight"] = {name = "Text_fight"},
		["Panel_item.Text_name"] = {name = "Text_name"},
		["Panel_item.Text_level"] = {name = "Text_level"},
		["Panel_item.Text_rank"] = {name = "Text_rank"},
		["Panel_item.Image_select"] = {name = "Image_select"},
		["Panel_item.Image_back"] = {name = "Image_back"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.Image_select:setVisible(false)
	self.Image_back:setVisible(false)
end

function MenPaiMockFightsItem:onEnterScene()
    
end

function MenPaiMockFightsItem:onExitScene()
   
end

function MenPaiMockFightsItem:reset(info)
	-- local info = {level = math.random(1,50), name = "司徒雷登" .. tostring(i), fight = math.random(1000,99999), rank = i ,career = math.random(0,7), gender = math.random(0,1)}
	self["Image_back"]:setVisible(false)

	local delay1 = cc.DelayTime:create(0.5)
	local scaleTo1 = cc.ScaleTo:create(0.25,0,1)
	local func1 = cc.CallFunc:create(function()
		self["Image_back"]:setVisible(true)
	end)
	local scaleTo2 = cc.ScaleTo:create(0.25,-1,1)
	local delay2 = cc.DelayTime:create(0.3)
	local scaleTo3 = cc.ScaleTo:create(0.25,0,1)  
	local func2 = cc.CallFunc:create(function()
		self.openInfo = info
		self["Panel_item"]:setTouchEnabled(true)
		self.Text_fight:setString(tostring(info.fight))
		self.Text_name:setString(tostring(info.name))
		self.Text_level:setString(tostring(info.level))
		self.Text_rank:setString(tostring(info.rank))
		
		local modelId = cp.getManager("GDataManager"):getModelId(info.career,info.gender)
		if modelId ~= nil and modelId > 0 then
			local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)  
		
			local headFile = cp.DataUtils.getModelFace(itemCfg:getValue("Face"))
			self.Image_head:loadTexture(headFile, UI_TEX_TYPE_LOCAL)
			self.Image_head:setVisible(true)
		end
		self["Image_back"]:setVisible(false)
	end)
	local scaleTo4 = cc.ScaleTo:create(0.5,1,1)  
	
	local actSeq = cc.Sequence:create(delay,scaleTo1,func1,scaleTo2,delay2,scaleTo3,func2,scaleTo4)
	self["Panel_item"]:runAction(actSeq)
	self["Panel_item"]:setTouchEnabled(false)

end

function MenPaiMockFightsItem:setSelected(bSelected)
	self.Image_select:setVisible(bSelected)
end

function MenPaiMockFightsItem:getRank()
	if self.openInfo ~= nil then
		return self.openInfo.rank
	else
		return 0
	end
end


function MenPaiMockFightsItem:onItemClick(sender)
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self.openInfo)	
	end
end

function MenPaiMockFightsItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return MenPaiMockFightsItem
