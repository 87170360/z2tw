local BNode = require "cp.view.ui.base.BNode"
local ServerListItem = class("ServerListItem",BNode)

function ServerListItem:create()
	local node = ServerListItem.new()
	return node
end

function ServerListItem:initListEvent()
	self.listListeners = {}
end

function ServerListItem:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/serverlistitem.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"}, --click = "onItemClick", clickScale=1},
      	["Panel_root.Text_servername"] = {name = "Text_servername"},
      	["Panel_root.Text_serverindex"] = {name = "Text_serverindex"},
		["Panel_root.Image_serverstatus"] = {name = "Image_serverstatus"},
		["Panel_root.Image_select"] = {name = "Image_select"},
		["Panel_root.Image_status"] = {name = "Image_status"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	local function onTouch(sender, event)
        if event == cc.EventCode.ENDED then
            local distance = cc.pGetDistance(sender:getTouchEndPosition(),sender:getTouchBeganPosition())
            if distance < 50 then
                self:onItemClick(sender)
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效    
            end
        end
    end
    if self.Panel_root.addTouchEventListener ~= nil then
        self.Panel_root:addTouchEventListener(onTouch)
	end
	
end

function ServerListItem:setItemSelectedCallBack(cb)
	self.selectCallBack = cb
end

function ServerListItem:onItemClick(sender)

	if self.selectCallBack ~= nil then
		self.selectCallBack(self.serverInfo)
	end
end
function ServerListItem:initServerInfo(serverInfo, bgImage, showState)
	self.serverInfo = serverInfo
	if serverInfo ~= nil then
		self["Text_serverindex"]:setString("伺服器" .. tostring(serverInfo.id))
		self["Text_servername"]:setString(serverInfo.name)
		
		self["Image_serverstatus"]:setVisible(showState)
		self["Image_status"]:setVisible(showState)

		local filename = "ui_login_module01_log_zbiaoqian.png"
		if serverInfo.status == 1 then
			filename = "ui_login_jian.png"
		elseif serverInfo.status == 2 then
			filename = "ui_login_xin.png"
		elseif serverInfo.status == 3 then
			filename = "ui_login_re.png"
		elseif serverInfo.status == 4 then
			filename = "ui_login_man.png"
		end
		self["Image_status"]:loadTexture(filename, ccui.TextureResType.plistType)

		if bgImage ~= nil then
			self["Panel_root"]:setBackGroundImage(bgImage, ccui.TextureResType.plistType)
		end
		
		 self.serverInfo.select = self.serverInfo.select or false
		self["Image_select"]:setVisible(self.serverInfo.select)
	end
end

return ServerListItem
