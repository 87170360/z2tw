local BLayer = require "cp.view.ui.base.BLayer"
local MailDetailLayer = class("MailDetailLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function MailDetailLayer:create(mailDetail)
	local scene = MailDetailLayer.new()
	scene.mailDetail = mailDetail
    return scene
end

function MailDetailLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").DeleteMailRsp] = function(data)
			self:removeFromParent()
		end,
		[cp.getConst("EventConst").ReceiveMailRsp] = function(data)
			if #self.mailDetail.item_list.item_list == 0 then
				self.mailDetail.flag = true
				cp.getManager("ViewManager").setEnabled(self.Button_Receive, false)
			else
				self:updateMailDetailView()
			end
		end,

		[cp.getConst("EventConst").get_guide_view_point] = function(evt)	
			if evt.classname == "MailDetailLayer" then
				if evt.guide_name == "mail" then
					local boundbingBox = self[evt.target_name]:getBoundingBox()
					pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
				
					local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
					evt.ret = finger_info
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "MailDetailLayer" then
				if evt.guide_name == "mail" then
					self:onBtnClick(self[evt.target_name])
				end
			end
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function MailDetailLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_system/uicsb_system_mail_info.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Sender"] = {name = "Text_Sender"},
		["Panel_root.Image_1.Text_Subject"] = {name = "Text_Subject"},
		["Panel_root.Image_1.Image_Subject"] = {name = "Image_Subject"},
		["Panel_root.Image_1.Text_TimeStamp"] = {name = "Text_TimeStamp"},
		["Panel_root.Image_1.ScrollView_Body.Text_Body"] = {name = "Text_Body"},
		["Panel_root.Image_1.ScrollView_Body"] = {name = "ScrollView_Body"},
		["Panel_root.Image_1.ScrollView_Item"] = {name = "ScrollView_Item"},
		["Panel_root.Image_1.Button_Receive"] = {name = "Button_Receive", click="onBtnClick"},
		["Panel_root.Image_1.Button_Delete"] = {name = "Button_Delete", click="onBtnClick"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_Model = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_item.csb"):getChildByName("Panel_item")
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	ccui.Helper:doLayout(self.rootView)
	self.ScrollView_Body:setScrollBarEnabled(false)
	self.ScrollView_Item:setScrollBarEnabled(false)
end

function MailDetailLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		local info = 
		{
			classname = "MailDetailLayer",
		}
		self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		self:removeFromParent()
	elseif nodeName == "Button_Receive" then
		if not self.mailDetail.flag then
			local req = {}
			req.mail_list = {self.mailDetail.mail_id}
			self:doSendSocket(cp.getConst("ProtoConst").ReceiveMailReq, req)
		else
			cp.getManager("ViewManager").gameTip("已經領取過了")
		end
	elseif nodeName == "Button_Delete" then
		local req = {}
		req.mail_list = {self.mailDetail.mail_id}
		local hasItem = false
		if not self.mailDetail.flag and #self.mailDetail.item_list.item_list > 0 then
			hasItem = true
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
	end
end

function MailDetailLayer:setMailBody(body)
	self.Text_Body:setString(self.mailDetail.body)
	if string.find(self.mailDetail.body, "<") then
		self.Text_Body:setVisible(false)
		local sz = self.ScrollView_Body:getContentSize()
		local richText = cp.getUtils("RichTextUtils").ParseRichText(self.mailDetail.body)
		richText:setName("RichText_Body")
	
		richText:setContentSize(cc.size(sz.width-20,9000))
		
		richText:formatText()
		local tsize = richText:getTextSize()
		richText:setContentSize(cc.size(math.max(sz.width-20,tsize.width),math.max(sz.height,tsize.height)))
	
		local sz2 = richText:getContentSize()
		richText:setPosition(0, sz2.height)
		self.ScrollView_Body:setInnerContainerSize(cc.size(sz.width, sz2.height))
		self.ScrollView_Body:addChild(richText)
		self.ScrollView_Body:setScrollBarEnabled(false)
	else
		self.Text_Body:setVisible(true)
	end
end

function MailDetailLayer:updateMailDetailView()
	self.Text_Sender:setString(self.mailDetail.sender)
	self.Text_Subject:setString("主題 "..self.mailDetail.subject)
	self.Text_TimeStamp:setString(os.date("%Y-%m-%d", self.mailDetail.time_stamp))
	self:setMailBody(self.mailDetail.body)

	local itemList = self.mailDetail.item_list.item_list
	
    local pos = cc.p(52, 78)
    for i, itemInfo in ipairs(itemList) do
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
        self.Image_1:removeChildByName("Item_"..i)
		local item = require("cp.view.ui.icon.ItemIcon"):create({
            id = itemInfo.id, num = itemInfo.num, Name = cfgItem:getValue("Name") ,
            Icon = cfgItem:getValue("Icon") , Colour = cfgItem:getValue("Hierarchy"),Type = cfgItem:getValue("Type")
        })
        item:setName("Item_"..i)
        self.ScrollView_Item:addChild(item)
		item:setScale(1)
		
		if self.mailDetail.flag then
            item:addFlag("yilingqu")
		end
        
		item:setItemClickCallBack(function(info)
		    local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(cfgItem)
    		self:addChild(layer, 100)
			layer:hidePlaceAndButtons()
        end)
        item:setPosition(pos)
        pos.x = pos.x + 160
	end
	self.ScrollView_Item:setInnerContainerSize(cc.size(89*#itemList+(#itemList-1)*74, 130))
	
	if #itemList == 0 and not self.mailDetail.flag then
		local req = {}
		req.mail_list = {self.mailDetail.mail_id}
		self:doSendSocket(cp.getConst("ProtoConst").ReceiveMailReq, req)
	end

	if self.mailDetail.flag then
		cp.getManager("ViewManager").setEnabled(self.Button_Receive, false)
	else
		cp.getManager("ViewManager").setEnabled(self.Button_Receive, true)
	end
end

function MailDetailLayer:onEnterScene()
	self:delayNewGuide()
	self:updateMailDetailView()
end

function MailDetailLayer:onExitScene()
    self:unscheduleUpdate()
end

function MailDetailLayer:delayNewGuide()
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "mail" then
		local sequence = {}
		table.insert(sequence, cc.DelayTime:create(0.3))
		table.insert(sequence,cc.CallFunc:create(function()
			local info = 
			{
				classname = "MailDetailLayer",
			}
			self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
		end))
		self:runAction(cc.Sequence:create(sequence))
    end
end

return MailDetailLayer