local BNode = require "cp.view.ui.base.BNode"
local SelectLayer = class("SelectLayer",BNode)

function SelectLayer:create()
	local node = SelectLayer.new()
	return node
end

function SelectLayer:initListEvent()
	self.listListeners = {}
end

function SelectLayer:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/select.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
  		["Panel_root.Button_close"] = {name = "Button_close", click = "onCloseClick"},
  		["Panel_root.Button_confirm"] = {name = "Button_confirm", click = "onConfirmClick"},
  		["Panel_root.Panel_list"] = {name = "Panel_list"},
		["Panel_root.FileNode_lastServer"] = {name = "FileNode_lastServer"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	--分辨率適配
	self:adapterReslution()
	
	local lastServerInfo = cp.getUserData("UserLogin"):getValue("lastServerInfo")
	local serverlistitem = require("cp.view.scene.login.ServerListItem"):create()
	serverlistitem:initServerInfo(lastServerInfo, "ui_login_module01_sign_zjdlfyq.png", true)
	self["FileNode_lastServer"]:addChild(serverlistitem)

	self.selectedServerInfo = lastServerInfo
end

--分辨率適配
function SelectLayer:adapterReslution()	
	self.rootView:setContentSize(display.size)
	cp.getManager("ViewManager").addModalByDefaultImage(self)
	ccui.Helper:doLayout(self.rootView)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
end

function SelectLayer:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function SelectLayer:onCloseClick(sender)
	if self.closeCallBack ~= nil then
		self.closeCallBack(self.selectedServerInfo)
	end
end

function SelectLayer:onConfirmClick(sender)
	if self.closeCallBack ~= nil then
		self.closeCallBack(self.selectedServerInfo)
	end
end

function SelectLayer:onEnterScene()

	local sz = self.Panel_list:getContentSize()

	self.cellView = cp.getManager("ViewManager").createCellView(sz)
    self.cellView:setCellSize(430,65)
    self.cellView:setColumnCount(1)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p(0, 0))
    self.cellView:setCountFunction(function()
        local serverList = cp.getUserData("UserLogin"):getValue("serverList")
		return table.nums(serverList)
    end)

    local function cellFactoryFunc(cellview, idx)
        return self:cellFactory(cellview, idx + 1)
    end
	self.cellView:setCellFactory(cellFactoryFunc)
	self.cellView:reloadData()
	self["Panel_list"]:addChild(self.cellView)

end

function SelectLayer:cellFactory(cellview, idx)

	local function callback(serverInfo)
		self.selectedServerInfo = serverInfo
		local serverList = cp.getUserData("UserLogin"):getValue("serverList")
		for i = 1, table.nums(serverList) do 
			if serverList[i].id == serverInfo.id then
				serverList[i].select = true
			else
				serverList[i].select = false
			end
		end
		local offset = self.cellView:getContentOffset()
		self.cellView:reloadData()
		self.cellView:setContentOffset(offset, false)
	end

    local item = nil
    local cell = cellview:dequeueCell()
    if nil == cell then
		cell = cc.TableViewCell:new()
		item = require("cp.view.scene.login.ServerListItem"):create()
		item:setItemSelectedCallBack(callback)
		item:setAnchorPoint(cc.p(0,0))
        item:setName("item")
		cell:addChild(item)
    else
		item = cell:getChildByName("item")
    end

	local serverList = cp.getUserData("UserLogin"):getValue("serverList")
	local data = serverList[idx]
	item:initServerInfo(data, nil, true)
	--[[
    local function touchEvent(sender, etype)
    	
		if etype == ccui.TouchEventType.ended then
			--sender:setScale(1)
			local box = sender:getBoundingBox()
			local pos = sender:getParent():convertToWorldSpace(cc.p(box.x, box.y))
			if math.abs(self.positionY - pos.y) < 10 then
				-- sender:loadTextures("ui_login_mx.png", "ui_login_mx.png", "ui_login_mx.png", ccui.TextureResType.plistType)
				-- self.selectItem:loadTextures("ui_login_my.png", "ui_login_my.png", "ui_login_my.png", ccui.TextureResType.plistType)
				-- self.selectItem = sender
				-- self.selectIndex = sender.index

				-- self:updateServerDetail(info)
				-- self:switchPanel(SERVERPANEL)

			end
		elseif etype == ccui.TouchEventType.began then
			
			local box = sender:getBoundingBox()
			local pos = sender:getParent():convertToWorldSpace(cc.p(box.x, box.y))
			self.positionY = pos.y
		elseif etype == ccui.TouchEventType.canceled then
			
		end
    end
    item:addTouchEventListener(touchEvent)
    ]]
    return cell
end

return SelectLayer
