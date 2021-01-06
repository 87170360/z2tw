local BLayer = require "cp.view.ui.base.BLayer"
local MailListLayer = class("MailListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function MailListLayer:create(openInfo)
    local scene = MailListLayer.new()
    return scene
end

function MailListLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").GetMailListRsp] = function(data)
			self:updateMailListView()
		end,
		[cp.getConst("EventConst").DispatchMailRsp] = function(data)
			self:updateMailListView()
		end,
		[cp.getConst("EventConst").ReceiveMailRsp] = function(itemList)
			self:updateMailListView()
			if #itemList > 0 then
            	cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
			end
		end,
		[cp.getConst("EventConst").DeleteMailRsp] = function(data)
			self:updateMailListView()
		end,
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)	
			if evt.classname == "MailListLayer" then
				if evt.guide_name == "mail" then
					if evt.target_name == "mail_list_1" then
						local model,idx  = self:getItemByMailID(100000)
						--滾動到該item處(以後再處理)
						-- local _,posY = model:getPositionY()
						-- local percent = posY/self.ListView_Mail:getContentSize().height
						
						local boundbingBox = model:getBoundingBox()
						local pos = model:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					else
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
					
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					end
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MailListLayer" then
				if evt.guide_name == "mail" then
					if evt.target_name == "mail_list_1" then
						local model,idx  = self:getItemByMailID(100000)
						local mailDetail = self.mailList[idx+1]
						local layer = require("cp.view.scene.system.MailDetailLayer"):create(mailDetail)
						self:addChild(layer, 100)
					else
						self:onBtnClick(self[evt.target_name])
					end
				end
			end
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function MailListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_system/uicsb_system_mail.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Image_List"] = {name = "Image_List"},
		["Panel_root.Image_1.Button_Model"] = {name = "Button_Model"},
		["Panel_root.Image_1.ListView_Mail"] = {name = "ListView_Mail"},
		["Panel_root.Image_1.Text_Num"] = {name = "Text_Num"},
		["Panel_root.Image_1.Button_Receive"] = {name = "Button_Receive", click="onBtnClick"},
		["Panel_root.Image_1.Button_Delete"] = {name = "Button_Delete", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Button_Model:setVisible(false)
	self:setTouchEnabled(true)
    self.ListView_Mail:setScrollBarEnabled(false)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:dispatchViewEvent(cp.getConst("EventConst").GetMailListRsp)
			self:dispatchViewEvent(cp.getConst("EventConst").open_mail_view,false)
		end
	end)

	cp.getManager("ViewManager").setWidgetAdapt(1280, {self.Image_1, self.Image_List, self.ListView_Mail})
	ccui.Helper:doLayout(self.rootView)
end

function MailListLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		local info = 
		{
			classname = "MailListLayer",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		self:dispatchViewEvent(cp.getConst("EventConst").GetMailListRsp)
		self:dispatchViewEvent(cp.getConst("EventConst").open_mail_view,false)
	end
end

function MailListLayer:getSortMailList()
	local mailData = cp.getUserData("UserMail"):getValue("MailData")
	table.sort(mailData.mail_list, function(a,b)
		return a.time_stamp > b.time_stamp
	end)
	return mailData.mail_list
end

function MailListLayer:updateOneMailListlView(index, mailDetail)
	local model  = self.ListView_Mail:getItem(index)
	if model == nil then
		model = self.Button_Model:clone()
		self.ListView_Mail:pushBackCustomItem(model)
	end

	cp.getManager("ViewManager").initButton(model, function()
		local layer = require("cp.view.scene.system.MailDetailLayer"):create(mailDetail)
		self:addChild(layer, 100)
	end, 1.0)

	model:setVisible(true)
	local imgMail = model:getChildByName("Image_Mail")
	local txtSender = model:getChildByName("Text_Sender")
	local txtSubject = model:getChildByName("Text_Subject")
	local txtExpire = model:getChildByName("Text_Expire")
	if mailDetail.flag then
		imgMail:loadTexture("ui_mail_youjian_xitongjiemian_yiduyoujian.png", ccui.TextureResType.plistType)
		local textureName = "img/bg/bg_common/youjian_xitongjiemian_di02.png"
		model:loadTextures(textureName, textureName, textureName)
	else
		imgMail:loadTexture("ui_mail_youjian_xitongjiemian_weiduyoujian.png", ccui.TextureResType.plistType)
		local textureName = "img/bg/bg_treasure/module33_choujiang_jifenpaihangbang_di01.png"
		model:loadTextures(textureName, textureName, textureName)
	end

	txtSender:setString(mailDetail.sender)
	txtSubject:setString(mailDetail.subject)
	cp.getManager("ViewManager").setTextQuality(txtSubject, 4)
	cp.getManager("ViewManager").setTextQuality(txtExpire, 2)
	txtExpire:setString(cp.getUtils("DataUtils").formatTimeRemain(mailDetail.expire_time-cp.getManager("TimerManager"):getTime()))
end

function MailListLayer:updateMailListView()
	self.ListView_Mail:removeAllItems()
	self.mailList = self:getSortMailList()
	for i, mailDetail in ipairs(self.mailList) do
		if cp.getManager("TimerManager"):getTime() < mailDetail.expire_time then
			self:updateOneMailListlView(i-1, mailDetail)
		end
	end

	self.Text_Num:setString(string.format("%d/100", #self.mailList))
	cp.getManager("ViewManager").initButton(self.Button_Receive, function()
		local req = {}
		req.mail_list = {}
		for _, mailDetail in ipairs(self.mailList) do
			if not mailDetail.flag then
				table.insert(req.mail_list, mailDetail.mail_id)
			end
		end
    	self:doSendSocket(cp.getConst("ProtoConst").ReceiveMailReq, req)
	end)
	cp.getManager("ViewManager").initButton(self.Button_Delete, function()
		local req = {}
		req.mail_list = {}
		local hasItem = false
		for _, mailDetail in ipairs(self.mailList) do
			table.insert(req.mail_list, mailDetail.mail_id)
			if not mailDetail.flag and #mailDetail.item_list.item_list > 0 then
				hasItem = true
			end
		end
		if not hasItem then
			self:doSendSocket(cp.getConst("ProtoConst").DeleteMailReq, req)
		else
			local contentTable = {
                {type="ttf", fontSize=24, text="郵件內有未查收物品，是否刪除？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
            }
			cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,function()
				self:doSendSocket(cp.getConst("ProtoConst").DeleteMailReq, req)
			end,nil)
		end
	end)
end

function MailListLayer:onEnterScene()
	self:updateMailListView()
	self:delayNewGuide()
end

function MailListLayer:onExitScene()
    self:unscheduleUpdate()
end


function MailListLayer:delayNewGuide()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "mail" then
		local sequence = {}
		table.insert(sequence, cc.DelayTime:create(0.3))
		table.insert(sequence,cc.CallFunc:create(function()
			local info = 
			{
				classname = "MailListLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end))
		self:runAction(cc.Sequence:create(sequence))
    end
end

function MailListLayer:getItemByMailID(id)
	for i, mailDetail in ipairs(self.mailList) do
		local item = self.ListView_Mail:getItem(i-1)
		local posx,posy = item:getPosition()
		if mailDetail.mail_id == id then
			return self.ListView_Mail:getItem(i-1), i-1
		end
	end
	return self.ListView_Mail:getItem(0), 0
end

return MailListLayer