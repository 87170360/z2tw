local BNode = require "cp.view.ui.base.BNode"
local PlayerHeadChangeUI = class("PlayerHeadChangeUI",BNode)
function PlayerHeadChangeUI:create(openInfo)
    local ret = PlayerHeadChangeUI.new(openInfo)
    return ret
end
function PlayerHeadChangeUI:initListEvent()
	self.listListeners = {
		--獲取已購買頭像列表
		[cp.getConst("EventConst").GetFaceRsp] = function(data)
			self:initHeadList()
		end,

		--購買頭像
		[cp.getConst("EventConst").BuyFaceRsp] = function(data)
			self:initHeadList()
		end,
	}
end

function PlayerHeadChangeUI:onInitView(openInfo)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_head_change.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Panel_bg"] = {name = "Panel_bg"},
		["Panel_root.Panel_bg.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Panel_bg.Panel_model"] = {name = "Panel_model"},
		
		["Panel_root.Panel_bg.Button_OK"] = {name = "Button_OK",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.Button_Cancel"] = {name = "Button_Cancel",click = "onUIButtonClick"},
		["Panel_root.Panel_bg.ScrollView_1"] = {name = "ScrollView_1" },
		["Panel_root.Panel_bg.Button_close"] = {name = "Button_close" ,click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	

	self.Panel_model:setVisible(false)
	self.ScrollView_1:setScrollBarEnabled(false)
	self:setPosition(cc.p(display.cx,display.cy))
	cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function()
		-- self:removeFromParent()
	end)
	self.openInfo  = openInfo

end

function PlayerHeadChangeUI:onEnterScene()

	self.selectFace = self.openInfo.face
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	self.headList = {}
	local cnt = cp.getManager("ConfigManager").getItemCount("Face")
    for i=1,cnt do
        local cfgItem = cp.getManager("ConfigManager").getItemAt("Face",i)
		local Show = cfgItem:getValue("Show")
		local Career = cfgItem:getValue("Career")
		local Gender = cfgItem:getValue("Gender")
		local _,idx1 = string.find(Career,tostring(majorRole.career))
        if idx1 ~= nil and (Gender == -1 or Gender == majorRole.gender) and Show == 0 then
		
            local ID = cfgItem:getValue("ID")
            local Price = cfgItem:getValue("Price")
            local Vip = cfgItem:getValue("Vip")
            local Level = cfgItem:getValue("Level")
            
            local FashionID = cfgItem:getValue("FashionID")
			
			if (self.openInfo.gender == Gender or Gender == -1) and (not (self.openInfo.type == "create") or ((self.openInfo.type == "create") and Price == 0 and Vip == 0 and FashionID == 0 and Level==0)) then
				self.headList[#self.headList + 1] = {ID = ID, Price = Price, Vip = Vip, Level = Level, Gender = Gender, FashionID=FashionID}
			end
        end
	end

	if not (self.openInfo.type == "create") then
		--請求解鎖列表
		local req = {}
		self:doSendSocket(cp.getConst("ProtoConst").GetFaceReq, req)
	else
		self:initHeadList()
	end
end

function PlayerHeadChangeUI:initHeadList()
	self["ScrollView_1"]:removeAllChildren()
	self.Image_Select = nil
	self.jumpToScale = 0
	local vip = cp.getUserData("UserVip"):getValue("level")
	local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
	local own_list = fashion_data.own
	local buyface_list = cp.getUserData("UserRole"):getValue("buyface_list")
	buyface_list = buyface_list or {}

	local scrollViewSize = self["ScrollView_1"]:getContentSize()
	local totalHeight = math.ceil(table.nums(self.headList) / 3) * 160
	if totalHeight > scrollViewSize.height then
		self["ScrollView_1"]:setInnerContainerSize(cc.size(scrollViewSize.width,totalHeight))
	else
		totalHeight = scrollViewSize.height
	end
	for i=1,table.nums(self.headList) do
		local faceInfo = self.headList[i]
		faceInfo.locked = false

		if faceInfo.Vip > 0 then
			if vip < faceInfo.Vip then
				faceInfo.locked = true
			end
		end
		if faceInfo.FashionID > 0 then
			faceInfo.locked = table.arrIndexOf(own_list,faceInfo.FashionID) == -1
		end
		if faceInfo.Price > 0 then
			if table.arrIndexOf(buyface_list,faceInfo.ID) == -1 then
				faceInfo.locked = true
			end
		end

		local item = self:createHeadItem(faceInfo)
		local x = math.floor((i-1) % 3) * 160
		local y = totalHeight - math.floor((i-1) / 3) * 160 - 160
		item:setPosition(cc.p(x, y))
		self.ScrollView_1:addChild(item)
		if self.selectFace == faceInfo.ID  then
			self:setSelectedHead(item)
			self.jumpToScale = math.floor((totalHeight-y-160)/totalHeight*100.0)
		end
	end
	
	self.ScrollView_1:jumpToPercentVertical(self.jumpToScale)
end

function PlayerHeadChangeUI:setSelectedHead(item)
	local posx,posy = item:getPosition()
	if self.Image_Select == nil then
		self.Image_Select = ccui.ImageView:create()
		self.Image_Select:setAnchorPoint(0.5,0.5)
		self.Image_Select:loadTexture("ui_head_change_module02_role_touxiangxuanzhong.png",ccui.TextureResType.plistType)
		self.ScrollView_1:addChild(self.Image_Select,1)
	end
	
	self.Image_Select:setPosition(posx+80,posy+98)
end

function PlayerHeadChangeUI:createHeadItem(faceInfo)

	local item = self.Panel_model:clone()
	item:setVisible(true)
	--faceInfo.locked = math.random( 1, 10) > 2 and true or false
	local Image_lock = item:getChildByName("Image_lock")
	local Text_lock = item:getChildByName("Text_lock")
	if faceInfo.locked then
		--faceInfo.Vip = math.random(1,10)>6 and 1 or 0
		--faceInfo.Price = math.random(30,500)
		if faceInfo.Vip > 0 then
			Text_lock:setText("Vip" .. tostring(faceInfo.Vip) .. "解鎖")
		elseif faceInfo.Price > 0 then
			Text_lock:setText(tostring(faceInfo.Price) .. "元寶解鎖")
		elseif faceInfo.FashionID > 0 then
			Text_lock:setText("時裝解鎖")
		end
		Image_lock:setVisible(true)
	else
		Image_lock:setVisible(false)
		if faceInfo.Vip > 0 or faceInfo.Price > 0 or faceInfo.FashionID > 0 then
			Text_lock:setText("已解鎖")
		else
			Text_lock:setText("免費")
		end
	end

	local Image_icon = item:getChildByName("Image_icon")
    Image_icon:loadTexture("img/model/head/" .. faceInfo.ID .. ".png",ccui.TextureResType.localType)
	Image_icon:setTouchEnabled(true)
	local function touchEvent(touch, etype)
		if etype == ccui.TouchEventType.ended then
			if self.selectFace ~= faceInfo.ID then
				local head = nil
				for i=1,#self.headList do
					if self.headList[i].ID == faceInfo.ID then
						head = self.headList[i]
						break
					end
				end
				
				
				if head then
					if head.Vip > 0 then
						local vip = cp.getUserData("UserVip"):getValue("level")
						if vip < head.Vip then
							cp.getManager("ViewManager").gameTip("需要達到VIP" .. tostring(head.Vip) .. "才能解鎖")
							--彈出購買vip界面
							return
						end
					end
					if head.Level > 0 then
						local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
						if roleAtt.level < head.Level then
							cp.getManager("ViewManager").gameTip("提升人物等級到" .. tostring(head.Level) .. "級解鎖")
							return
						end
					end

					if head.FashionID > 0 then
						local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
						local own_list = fashion_data.own
						if table.arrIndexOf(own_list,head.FashionID) == -1 then
							cp.getManager("ViewManager").gameTip("購買對應時裝解鎖")
							return
						end
					end


					local buyface_list = cp.getUserData("UserRole"):getValue("buyface_list")
					buyface_list = buyface_list or {}
					if head.Price > 0 and table.arrIndexOf(buyface_list,faceInfo.ID) == -1 then
						--是否花費 元寶解鎖頭像？
						local function comfirmFunc()
							--檢測是否元寶足夠
							if cp.getManager("ViewManager").checkGoldEnough(head.Price) then
								local req = {face = faceInfo.ID}
								self:doSendSocket(cp.getConst("ProtoConst").BuyFaceReq, req)
							end
						end
				
						local contentTable = {
							{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
							{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(head.Price), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
							{type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
							{type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="，解鎖頭像？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
						}
						cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
						return
					end
				end
				self.selectFace = faceInfo.ID
				self:setSelectedHead(item)
			end
		end
	end
	Image_icon:addTouchEventListener(touchEvent)
	return item
end


function PlayerHeadChangeUI:setCloseCallBack(cb)
	self.CloseCallBack = cb
end

function PlayerHeadChangeUI:onUIButtonClick(sender)
	if sender:getName() == "Button_Cancel" then
		self.selectFace = self.openInfo.face  --重置
	end
	if self.CloseCallBack then 
		self.CloseCallBack(self.selectFace)
	end
	if self.openInfo.type == "major" then
		self:dispatchViewEvent(cp.getConst("EventConst").open_face_change_view,false)
	else
        self:removeFromParent()
	end
end

function PlayerHeadChangeUI:getDescription()
    return "PlayerHeadChangeUI"
end

return PlayerHeadChangeUI