local BLayer = require "cp.view.ui.base.BLayer"
local AchivementEffectLayer = class("AchivementEffectLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function AchivementEffectLayer:create()
	local layer = AchivementEffectLayer.new()
    return layer
end

function AchivementEffectLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function AchivementEffectLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_achievement/uicsb_achievement_effect.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_bg.Text_num"] = {name = "Text_num"},
		["Panel_root.Image_bg.Panel_att"] = {name = "Panel_att"},

		["Panel_root.Image_bg.Panel_mode"] = {name = "Panel_mode"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
	end)

	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_bg)
end

function AchivementEffectLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
	end
end

function AchivementEffectLayer:onEnterScene()
end

function AchivementEffectLayer:onExitScene()
end

function AchivementEffectLayer:initAllAttribute()
	self:getAllAttribute()
	self:createCellItems()

end

function AchivementEffectLayer:createCellItems()
    self.Panel_att:removeAllChildren()

    local contentSize = self.Panel_att:getContentSize()
	local cellSize = self.Panel_mode:getContentSize()
    self.cellView = cp.getManager("ViewManager").createCellView(contentSize)
    self.cellView:setCellSize(cellSize)
    self.cellView:setColumnCount(3)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p(0, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.all_att_by_index)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1
        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
			cell = cc.TableViewCell:new()
            item = self.Panel_mode:clone()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
			item:setName("item")
			item:setVisible(true)
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
		end
		local info = self.all_att_by_index[idx]
		item:getChildByName("Text_att"):setString(info.title .. "+" .. tostring(info.value))

        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
	self.Panel_att:addChild(self.cellView)
	self.cellView:reloadData()
end

function AchivementEffectLayer:getAllAttribute()
	
	self.all_att = {}
	local achive_config = cp.getUserData("UserAchivement"):getAchivementConfig()
	local achive_list = cp.getUserData("UserAchivement"):getValue("achive_list")
	achive_list = achive_list or {}

	self.Text_num:setString(tostring(table.nums(achive_list)))

	for ID,info in pairs(achive_config) do
		if info.Att ~= "" then
			
			local strArr = {}
			string.loopSplit(info.Att,"|-",strArr)
			for i=1,table.nums(strArr) do
				if strArr[i][1] and strArr[i][2] and tonumber(strArr[i][1]) and tonumber(strArr[i][2]) then
					local type = tonumber(strArr[i][1])
					local value = tonumber(strArr[i][2])
					local baseTitle = cp.getConst("CombatConst").AttributeList[type]
					if self.all_att[type] == nil then
						self.all_att[type] = {ID = ID,type=type,title=baseTitle,value=0}
					end
					if table.arrIndexOf(achive_list,ID) ~= -1 then
						self.all_att[type].value = self.all_att[type].value + value
					end
				end
			end
		end
	end

	self.all_att_by_index = {}
	for type, info in pairs(self.all_att) do
		table.insert(self.all_att_by_index,info)
	end
end

return AchivementEffectLayer