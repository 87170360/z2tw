
local BLayer = require "cp.view.ui.base.BLayer"
local JiangHuGoMain = class("JiangHuGoMain",BLayer)

function JiangHuGoMain:create(openInfo)
	local layer = JiangHuGoMain.new(openInfo)
	return layer
end

function JiangHuGoMain:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").InviteRsp] = function(data)	
			self:refreshInviteData()
			self:refreshNotice()
		end,
		
		[cp.getConst("EventConst").InviteGiftRsp] = function(data)	
			
			for i=1,table.nums(self.cellInfo) do
				if self.cellInfo[i].id == data.id then
					local itemList = self.cellInfo[i].item_list 
					cp.getManager("ViewManager").showGetRewardUI(itemList,"恭喜獲得",true)
					break
				end
			end
        end,
	}
end

function JiangHuGoMain:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_jianghu_go.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.Panel_2"] = {name = "Panel_2"},
        ["Panel_root.Panel_1.Panel_2.Panel_3"] = {name = "Panel_3"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Panel_content"] = {name = "Panel_content"},
        ["Panel_root.Panel_1.Panel_2.Panel_3.Image_bg"] = {name = "Panel3_bg"},
		["Panel_root.Panel_1.Panel_2.Panel_3.Image_around_bar"] = {name = "Panel3_bar"},
		
		["Panel_root.Panel_1.Panel_2.Panel_2_crop"] = {name = "Panel_2_crop"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Panel_exchange"] = {name = "Panel_exchange", click="onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Image_invite_frend"] = {name = "Image_invite_frend", click="onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Image_invite_bind"] = {name = "Image_invite_bind", click="onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Image_days"] = {name = "Image_days", click="onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.Image_fights"] = {name = "Image_fights", click="onUIButtonClick"},
		["Panel_root.Panel_1.Panel_2.Panel_2_crop.Image_bg.AtlasLabel_num"] = {name = "AtlasLabel_num"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self:setPosition(display.cx,display.cy)
	self.Panel_root:setContentSize(display.size)

	--動態調整panel3的節點width height
	local panel1Size = self.Panel_1:getContentSize()
	local panel2Size = self.Panel_2:getContentSize()
	local panel3Size = self.Panel_3:getContentSize()
	local changeHeight = display.size.height - panel1Size.height - panel2Size.height 
	self.Panel_3:setContentSize(cc.size(panel3Size.width, changeHeight))
	self.Panel3_bg:setContentSize(cc.size(panel3Size.width, changeHeight + 20))
	self.Panel3_bar:setContentSize(cc.size(panel3Size.width + 15, changeHeight + 20))
	self.Panel_content:setContentSize(cc.size(panel3Size.width, changeHeight-160))
    self.Panel_content:setPositionY(self.Panel_3:getContentSize().height-40)

	self:createCellItems()

    ccui.Helper:doLayout(self["rootView"])
end

function JiangHuGoMain:onEnterScene()
	self.open_type = ""
	self.cellInfo = {}
	self:changeType("online_time")

	if self.effectBtn then
		self.effectBtn:removeFromParent()
		self.effectBtn = nil
	end
	local effectBtn = cp.getManager("ViewManager").createSpineEffect("LiBaoDuiHuan")
	effectBtn:setAnimation(0, "LiBaoDuiHuan", true)
	self.Panel_exchange:addChild(effectBtn)
	local sz = self.Panel_exchange:getContentSize()
    effectBtn:setPosition(cc.p(sz.width/2,-15))
	self.effectBtn = effectBtn
	
	self:refreshNotice()
end

function JiangHuGoMain:refreshInviteData()
	local inviteeCount = cp.getUserData("UserInvite"):getValue("inviteeCount")
	self.AtlasLabel_num:setString(tostring(inviteeCount))

	self:refreshCellInfo()
	self:refreshAllState()
	if self.cellView then
		self.cellView:reloadData()
	end

end

function JiangHuGoMain:onExitScene()
    
end

function JiangHuGoMain:changeType(newType)
	if self.open_type == newType then
		return	
	end
	self.open_type = newType
	if "online_time" == newType then
		self.Image_days:getChildByName("Text_1"):setTextColor(cc.c4b(80,44,8,255))
		self.Image_days:loadTexture("ui_common_module_bangpai_7.png",ccui.TextureResType.plistType)
		self.Image_fights:getChildByName("Text_1"):setTextColor(cc.c4b(80,44,8,192))
		self.Image_fights:loadTexture("ui_common_module_bangpai_6.png",ccui.TextureResType.plistType)
	elseif "fights" == newType then
		self.Image_days:getChildByName("Text_1"):setTextColor(cc.c4b(80,44,8,192))
		self.Image_days:loadTexture("ui_common_module_bangpai_6.png",ccui.TextureResType.plistType)
		self.Image_fights:getChildByName("Text_1"):setTextColor(cc.c4b(80,44,8,255))
		self.Image_fights:loadTexture("ui_common_module_bangpai_7.png",ccui.TextureResType.plistType)
	end
	
	self:refreshInviteData()
end



function JiangHuGoMain:createCellItems()
    self.Panel_content:removeAllChildren()

    local contentSize = self.Panel_content:getContentSize()
	local cellSize = cc.size(691,215)
    self.cellView = cp.getManager("ViewManager").createCellView(contentSize)
    self.cellView:setCellSize(cellSize)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p((contentSize.width - cellSize.width)/2, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.cellInfo)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1
        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.jianghugo.JiangHuGoItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        item:resetInfo(self.cellInfo[idx])
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.Panel_content:addChild(self.cellView)
end

function JiangHuGoMain:refreshCellInfo()

	local tb = {}
	local count = cp.getManager("ConfigManager").getItemCount("InviteGift")
	for i=1,count do
		local item = cp.getManager("ConfigManager").getItemAt("InviteGift",i)
		local ID = item:getValue("ID")
		local Type = item:getValue("Type")
		
		if (self.open_type == "online_time" and (Type == 1 or Type == 3)) or (self.open_type == "fights" and Type == 2) then

			local Count = item:getValue("Count")
			local Gift = item:getValue("Gift")
			local items = {}
			string.loopSplit(Gift, "|-", items)
	
			local newGiftInfo = {id = ID, open_type = self.open_type,Type = Type, max = Count,item_list = {}}
			if items and next(items) then
				for i1, v1 in pairs(items) do
					table.insert(newGiftInfo.item_list, {id = tonumber(v1[1]), num = tonumber(v1[2])})
				end
			end

			newGiftInfo["Value"] = item:getValue("Value")

			table.insert(tb,newGiftInfo)
		end
	end

	self.cellInfo = tb
end

function JiangHuGoMain:refreshAllState()
	for i=1,table.nums(self.cellInfo) do
		local id = self.cellInfo[i].id
		local curGiftState = cp.getManager("GDataManager"):getInviteGiftState(id)
		self.cellInfo[i]["state"] = curGiftState and (curGiftState.openCount > curGiftState.getCount and 1 or 0) or 0
	end

	local function cmp(a,b)
		if a.state == b.state then
			return a.id < b.id
		else
			return a.state > b.state
		end
	end
	table.sort(self.cellInfo,cmp)

end

function JiangHuGoMain:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log(buttonName)
	if buttonName == "Panel_exchange" then  --兌換禮包
		cp.getManager("ViewManager").showExchangeGiftUI()
	elseif buttonName == "Image_invite_frend" then --邀請好友
		cp.getManager("ViewManager").showInviteUI()
	elseif buttonName == "Image_invite_bind" then
		cp.getManager("ViewManager").showInviteBind()
	elseif buttonName == "Image_days" then -- 同行天數禮包
		self:changeType("online_time")
	elseif buttonName == "Image_fights" then -- 同行戰力禮包
		self:changeType("fights")
	end
end


function JiangHuGoMain:refreshNotice()
	local noticeGift,noticeType = cp.getManager("GDataManager"):checkInviteGiftStateNotice()

	if noticeType[1] == 1 then
		cp.getManager("ViewManager").addRedDot(self.Image_days,cc.p(150,60))
	else
		cp.getManager("ViewManager").removeRedDot(self.Image_days)
	end
	if noticeType[2] == 1 then
		cp.getManager("ViewManager").addRedDot(self.Image_fights,cc.p(150,60))
	else
		cp.getManager("ViewManager").removeRedDot(self.Image_fights)
	end
end

return JiangHuGoMain
