local BLayer = require "cp.view.ui.base.BLayer"
local FashionAttributeLayer = class("FashionAttributeLayer", BLayer)
function FashionAttributeLayer:create()
	local scene = FashionAttributeLayer.new()
    return scene
end

function FashionAttributeLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").BuyFashionRsp] = function(data)	
			self:refreshView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function FashionAttributeLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_fashion/uicsb_fashion_attribute.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
	self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Text_num"] = {name = "Text_num"},
		["Panel_root.Image_1.Text_Attr0"] = {name = "Text_Attr0"},
		["Panel_root.Image_1.Text_Attr1"] = {name = "Text_Attr1"},
		["Panel_root.Image_1.Text_Attr2"] = {name = "Text_Attr2"},
		["Panel_root.Image_1.Text_Attr3"] = {name = "Text_Attr3"},
		["Panel_root.Image_1.Text_Attr4"] = {name = "Text_Attr4"},
		["Panel_root.Image_1.Text_Attr5"] = {name = "Text_Attr5"},
		["Panel_root.Image_1.Text_Attr6"] = {name = "Text_Attr6"},
		["Panel_root.Image_1.Text_Attr7"] = {name = "Text_Attr7"},
		["Panel_root.Image_1.Text_Attr8"] = {name = "Text_Attr8"},
		["Panel_root.Image_1.Text_Attr9"] = {name = "Text_Attr9"},
		["Panel_root.Image_1.Text_Attr10"] = {name = "Text_Attr10"},
		["Panel_root.Image_1.Text_Attr11"] = {name = "Text_Attr11"},
		["Panel_root.Image_1.Text_Attr12"] = {name = "Text_Attr12"},
		["Panel_root.Image_1.Text_Attr13"] = {name = "Text_Attr13"},
		["Panel_root.Image_1.Text_Attr14"] = {name = "Text_Attr14"},
		["Panel_root.Image_1.Text_Attr15"] = {name = "Text_Attr15"},
		["Panel_root.Image_1.Text_Attr16"] = {name = "Text_Attr16"},
		["Panel_root.Image_1.Text_Attr17"] = {name = "Text_Attr17"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
    --self.Image_1:setScale(0.5)
    --self.Image_1:runAction(cc.ScaleTo:create(0.1, 1.0))
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)

	self:refreshView()
end

function FashionAttributeLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
		self:removeFromParent()
	end
end

function FashionAttributeLayer:refreshView()
    local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
	self.Text_num:setString(#fashion_data.own)

	if self.confs == nil then
    	self.confs =  cp.getManager("GDataManager"):getAllFashionConfigInfo()
	end

	local function findConfig(id)
		local conf = nil
		for _,info in pairs(self.confs) do
			if info.ID == id then
				conf = info
				break
			end
		end
		return conf
	end

	--累積每件時裝屬性
	local attSum = {}
	for i, v in pairs(fashion_data.own) do 
		local conf = findConfig(v)
		if conf then
			for _, v1 in pairs(conf.att_list) do
				if attSum[v1.type] ~= nil then
					attSum[v1.type] = attSum[v1.type] + v1.value
				else
					attSum[v1.type] = v1.value
				end
			end
		end
	end

	for i=0, 17 do
		self["Text_Attr"..i]:setVisible(false)
	end

	--遍歷每一個顯示字段
	local i = 0
	for k, v in pairs(attSum) do
		if i > 17 then
			break
		end
		local txt = self["Text_Attr"..i]
		local tempStr = cp.getUtils("DataUtils").formatSkillAttribute(k, v)
		txt:setString(tempStr)
		txt:setVisible(true)
		i = i + 1
	end
	
end

function FashionAttributeLayer:onEnterScene()
end

function FashionAttributeLayer:setCloseCallback(cb)
	self.closeCallback = cb
end

function FashionAttributeLayer:onExitScene()
end

return FashionAttributeLayer
