
local BNode = require "cp.view.ui.base.BNode"
local MultiItemOperateConfirm = class("MultiItemOperateConfirm",BNode)  --function() return cc.Node:create() end)
function MultiItemOperateConfirm:create(openInfo)
    local node = MultiItemOperateConfirm.new(openInfo)
    return node
end


function MultiItemOperateConfirm:initListEvent()
	self.listListeners = {
	}
end

function MultiItemOperateConfirm:onInitView(openInfo)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_multi_item_operate.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Text_title"] = {name = "Text_title" },
		["Panel_root.Image_bg.Text_content"] = {name = "Text_content" },
		["Panel_root.Image_bg.Text_nums"] = {name = "Text_nums" },
		
		["Panel_root.Image_bg.Button_one"] = {name = "Button_one" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_all"] = {name = "Button_all" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_plus"] = {name = "Button_plus" },
		["Panel_root.Image_bg.Button_minus"] = {name = "Button_minus"},
		["Panel_root.Image_bg.Button_OK"] = {name = "Button_OK" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_cancel"] = {name = "Button_cancel" ,click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_close"] = {name = "Button_close" ,click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	
	self.openInfo = openInfo

	local function initButton(button, callFunc)
		local oscalex = 1
		local oscaley = 1
		local scalex =(scale or 0.9)*oscalex
		local scaley =(scale or 0.9)*oscaley
		local touchBeginTime = 0
		local function onTouch(sender, event)
			if event == cc.EventCode.BEGAN then
				sender:setScaleX(scalex)
				sender:setScaleY(scaley)
				--先執行一次
				cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
				if callFunc then
					callFunc()
				end
				schedule(sender,function()
						cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
						if callFunc then
							callFunc()
						end
					end,0.15)
					touchBeginTime = os.time()
			elseif event == cc.EventCode.ENDED then
				sender:setScaleX(oscalex)
				sender:setScaleY(oscaley)
				sender:stopAllActions()
				
			elseif event == cc.EventCode.CANCELLED then
				sender:setScaleX(oscalex)
				sender:setScaleY(oscaley)
				sender:stopAllActions()
			end
		end
		if button.addTouchEventListener ~= nil then
			button:addTouchEventListener(onTouch)
		end
	end
	initButton(self.Button_plus,function( ... )
		self.curSelectNum = self.curSelectNum + 1
		self.curSelectNum = math.min(self.curSelectNum,self.maxNum)
		self:updateNums()
		if self.curSelectNum >= self.maxNum then
			self.Button_plus:stopAllActions()
		end
	end)

	initButton(self.Button_minus,function( ... )
		self.curSelectNum = self.curSelectNum - 1
		self.curSelectNum = math.max(self.curSelectNum,1)
		self:updateNums()
		if self.curSelectNum <= 1 then
			self.Button_minus:stopAllActions()
		end
	end)

end

function MultiItemOperateConfirm:onEnterScene()
	
	self.maxNum = self:getMaxNum()
	if self.openInfo.contentType == "buyItem" then
		self.curSelectNum = math.min(1, self.maxNum)
	else
		self.curSelectNum = self.maxNum
	end
	self:updateNums()
end

function MultiItemOperateConfirm:updateContent()
	
	local contentTable = {}
	local color = cp.getConst("GameConst").QualityTextColor[self.openInfo.itemInfo.Colour]
	local txtContent = "是否"
	if self.openInfo.contentType == "sellItem" then
		txtContent = txtContent .. "出售"
	elseif self.openInfo.contentType == "buyItem" then
		txtContent = txtContent .. "購買   "
	elseif self.openInfo.contentType == "useItem" then
		txtContent = txtContent .. "使用"
	elseif self.openInfo.contentType == "fenjieItem" then
		txtContent = txtContent .. "分解"
	elseif self.openInfo.contentType == "duihuan" then
		txtContent = txtContent .. "兌換"
	end

	contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=txtContent, textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
	contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=" " .. self.openInfo.itemInfo.Name.. " x " ..tostring(self.curSelectNum), textColor=color, outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
	contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=" ？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}

	if self.openInfo.contentType == "fenjieItem" then
		contentTable[#contentTable + 1] = {type="blank", blankSize = 1}
		contentTable[#contentTable + 1] = {type="ttf", fontSize=18, text="(分解可獲得少量領悟點。)", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
	end
	if self.openInfo.contentType == "buyItem" then
		contentTable[#contentTable + 1] = {type="blank", blankSize = 1}
		contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text="將消耗   ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
		contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=tostring(self.openInfo.itemInfo.Price * self.curSelectNum), textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}

		local icon = cp.getManager("ViewManager").getVirtualItemIcon(self.openInfo.itemInfo.PriceType)
		if icon and icon ~= "" then
			contentTable[#contentTable + 1] = {type="image",filePath=icon,textureType=ccui.TextureResType.plistType,verticalAlign="bottom"}
		end
	end
	if self.openInfo.contentType == "sellItem" then
		contentTable[#contentTable + 1] = {type="blank", blankSize = 1}
		contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text="    將獲得 ", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
		contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=tostring(self.openInfo.itemInfo.Price * self.curSelectNum), textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}

		local icon = cp.getManager("ViewManager").getVirtualItemIcon(cp.getConst("GameConst").VirtualItemType.silver)
		if icon and icon ~= "" then
			contentTable[#contentTable + 1] = {type="image",filePath=icon,textureType=ccui.TextureResType.plistType,verticalAlign="bottom"}
		end
	end
	if self.openInfo.contentType == "duihuan" then
		contentTable[#contentTable + 1] = {type="blank", blankSize = 1}
		local strText = "將消耗  " .. tostring(self.openInfo.itemInfo.Price * self.curSelectNum) .. " 藏寶積分"
		contentTable[#contentTable + 1] = {type="ttf", fontSize=24, text=strText, textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}

		
	end

	self["Text_content"]:setVisible(false)
	local posX,posY = self["Text_content"]:getPosition()
	local sz = self["Text_content"]:getContentSize()
	if self["Image_bg"]:getChildByName("richText") ~= nil then
		self["Image_bg"]:removeChildByName("richText")
	end
	local richText = self:createRichText(contentTable)
	richText:setPosition(cc.p(posX,posY))
	self["Image_bg"]:addChild(richText)
	
end


function MultiItemOperateConfirm:createRichText(contentTable)
	--[[
		contentTable = {
			{type="ttf", fontSize=27, text="是否遺忘", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="魚躍龍門", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="回憶", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="水濺躍", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text=",需要消耗一枚:", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
			{type="ttf", fontSize=27, text="心之鱗片", textColor=cc.c4b(255,168,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1},
		}
	]]
	local richText = require("cp.view.ui.base.RichText"):create()
	for i=1, #contentTable do
		richText:addElement(contentTable[i])
	end
	
    richText:setContentSize(cc.size(400,80))
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:ignoreContentAdaptWithSize(false)
    richText:setPosition(cc.p(231,120))
    richText:setHAlign(cc.TEXT_ALIGNMENT_CENTER)  			--水平居中
    richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   -- 垂直居中
	richText:setLineGap(2)
	richText:setName("richText")
    return richText

end

function MultiItemOperateConfirm:onUIButtonClick(sender)
	local buttonName = sender:getName()
    log("click button : " .. buttonName)
	
	if "Button_OK" == buttonName then
		if self.openInfo ~= nil and self.openInfo.callback ~= nil then
			self.openInfo.callback(self.curSelectNum, self.openInfo.itemInfo)
		end
		cp.getManager("PopupManager"):removePopup(self)
	elseif "Button_cancel" == buttonName or "Button_close" == buttonName then
		if self.openInfo ~= nil and self.openInfo.callback ~= nil then
			self.openInfo.callback(0, self.openInfo.itemInfo)
		end
		cp.getManager("PopupManager"):removePopup(self)
	elseif "Button_minus" == buttonName then
		self.curSelectNum = self.curSelectNum - 1
		self.curSelectNum = math.max(self.curSelectNum,1)
		self:updateNums()
	elseif "Button_plus" == buttonName then
		self.curSelectNum = self.curSelectNum + 1
		self.curSelectNum = math.min(self.curSelectNum,self.maxNum)
		self:updateNums()
	elseif "Button_all" == buttonName then
		self.curSelectNum = self.maxNum
		self:updateNums()
	elseif "Button_one" == buttonName then
		self.curSelectNum = 1
		self:updateNums()
	end
end

function MultiItemOperateConfirm:updateNums()

	self.Text_nums:setString(tostring(self.curSelectNum) .. "/" .. tostring(self.maxNum))

	self:updateContent()
end


function MultiItemOperateConfirm:getMaxNum()
	local numMax = self.openInfo.itemInfo.num
	if self.openInfo.itemInfo.Type == 3 then -- 寶箱類特殊處理
		local id = self.openInfo.itemInfo.id
		local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameChest", id)
		if itemCfg then
			local keyId = itemCfg:getValue("Key")
			if keyId > 0 then
				local keyNum = cp.getUserData("UserItem"):getItemNum(keyId)
				numMax = math.min(numMax,keyNum)
			end
		end
	end
	return numMax
end

function MultiItemOperateConfirm:onCloseButtonClick(sender)
	-- cp.getManager("PopupManager"):removePopup(self)
	if self.openInfo ~= nil and self.openInfo.callback ~= nil then
		self.openInfo.callback(0,self.openInfo.itemInfo)
	end
end

function MultiItemOperateConfirm:getDescription()
    return "MultiItemOperateConfirm"
end

return MultiItemOperateConfirm