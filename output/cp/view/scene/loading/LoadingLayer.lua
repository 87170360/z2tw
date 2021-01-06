
local BNode = require "cp.view.ui.base.BNode"
local LoadingLayer = class("LoadingLayer",BNode)

function LoadingLayer:create(openInfo)
    local node = LoadingLayer.new()
    return node
end

function LoadingLayer:initListEvent()
    self.listListeners = {
	}
end

function LoadingLayer:onInitView(openInfo)
	--self:initMember()
	--self:loadSpriteFrames()
	self:loadCSB()
	self:initComponent()
	--self:adapterReslution()
	--self:showData()
end

--初始化成員變量
function LoadingLayer:initMember()
	self.totalCount = cp.SocketSend.getSendCount()
	self.curCount = 0
	self.finishCallFunc  = nil --載入完畢回調函數
end

--載入plist文件
function LoadingLayer:loadSpriteFrames()
    display.loadSpriteFrames("uiplist/ui_common.plist")
end

--載入csb文件
function LoadingLayer:loadCSB()
	self.root = cc.CSLoader:createNode("uicsb/uicsb_login/uicsb_loading.csb")
	self:addChild(self.root)
end

--初始化UI控件
function LoadingLayer:initComponent()
	local childConfig = {
		["Panel"] = {name = "panel"},
		["Panel.Image_progress"] = {name = "Image_progress"},
		["Panel.Image_progress.LoadingBar_1"] = {name = "LoadingBar_1"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.root,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.root)
	
	self:setLoadingPercent(0)
	cp.getManager("ViewManager").addModalByDefaultImage(self)
	self:adapterReslution()
	
end

function LoadingLayer:setLoadingPercent(percent)
	if percent > 100 then
		percent = 100
	end
	self["LoadingBar_1"]:setPercent(percent)
end


--適配
function LoadingLayer:adapterReslution()
	self.root:setContentSize(display.size)
	
	cp.getManager("ViewManager").setCSNodeTextClear(self.root)
	ccui.Helper:doLayout(self.root)
end

--[[
function LoadingLayer:showData()
	local count = cp.getManager("ConfigManager").getItemCount("loading_tip")
	local cfgItem = cp.getManager("ConfigManager").getItemAt("loading_tip", math.random(1, count))
	self:setTip(cfgItem:getValue("xts"))

	local filename = string.format("img/bg/bg_hotup/bg_hotup_%d.jpg", math.random(1, 4))
	self:setBgTexture(filename)

	self:refreshPercent()
end

function LoadingLayer:eventCallBack()
	self.curCount = self.curCount + 1
	self:refreshPercent()
end

function LoadingLayer:refreshPercent()
	local scale = self.curCount / self.totalCount
	scale = scale > 1.0 and 1.0 or scale
	local percent = math.floor(100 * scale)
	percent = percent > 100 and 100 or percent

	self:setLoadingBar(scale)
	self:setPercent(percent.."%")
end

--設置小提示
function LoadingLayer:setTip(tip)
	self["tip"]:setString(tip)
end

--設置背景圖片
function LoadingLayer:setBgTexture(filename)
	if filename ~= nil then
		self["bg"]:loadTexture(filename, ccui.TextureResType.localType)
	end
end

--設置百分比percent：0 - 100
function LoadingLayer:setLoadingBar(percent)
	if type(percent) == "number" then
		local width = 774.00 * percent
		self["loadingBar"]:setSize(cc.size(width, 12))
	end
end

--設置百分比
function LoadingLayer:setPercent(percent)
	self["percent"]:setString(percent)
end

function LoadingLayer:delayEntenWorld()
	local seq = cc.Sequence:create(
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(handler(self, self.finishCallBack))
		)
	self["tip"]:runAction(seq)
--	self:finishCallBack()
end

function LoadingLayer:finishCallBack()
	if self.finishCallFunc ~= nil then
		self.finishCallFunc()
	end
end

function LoadingLayer:registerFinishCallFunc(func)
	self.finishCallFunc = func
end
]]

return LoadingLayer
