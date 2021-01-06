local BLayer = require "cp.view.ui.base.BLayer"
local PrimevalSellLayer = class("PrimevalSellLayer", BLayer)

function PrimevalSellLayer:create()
    local scene = PrimevalSellLayer.new()
    return scene
end

function PrimevalSellLayer:initListEvent()
    self.listListeners = {
		["SellMetaRsp"] = function(data)
			self:updatePrimevalSellView()
		end
    }
end

--初始化界面，以及設定界面元素標籤
function PrimevalSellLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_primeval/uicsb_primeval_sell.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Panel_1.Button_sell_1"] = {name = "Button_sell_1", click="onSellClick"},
		["Panel_root.Image_1.Panel_2.Button_sell_2"] = {name = "Button_sell_2", click="onSellClick"},
		["Panel_root.Image_1.Panel_3.Button_sell_3"] = {name = "Button_sell_3", click="onSellClick"},
		["Panel_root.Image_1.Panel_4.Button_sell_4"] = {name = "Button_sell_4", click="onSellClick"},
		["Panel_root.Image_1.Panel_5.Button_sell_5"] = {name = "Button_sell_5", click="onSellClick"},
		["Panel_root.Image_1.Panel_6.Button_sell_6"] = {name = "Button_sell_6", click="onSellClick"},
		["Panel_root.Image_1.Panel_1.Text_num_1"] = {name = "Text_num_1"},
		["Panel_root.Image_1.Panel_2.Text_num_2"] = {name = "Text_num_2"},
		["Panel_root.Image_1.Panel_3.Text_num_3"] = {name = "Text_num_3"},
		["Panel_root.Image_1.Panel_4.Text_num_4"] = {name = "Text_num_4"},
		["Panel_root.Image_1.Panel_5.Text_num_5"] = {name = "Text_num_5"},
		["Panel_root.Image_1.Panel_6.Text_num_6"] = {name = "Text_num_6"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	cp.getManager("ViewManager").setTouchClose(self, self.Panel_root)
	cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function PrimevalSellLayer:updateColorList()
	self.colorList = {{},{},{},{},{},{}}
	local posMap = cp.getUserData("UserPrimeval"):getValue("PosMap")
	for _, metaInfo in pairs(posMap) do
		table.insert(self.colorList[metaInfo.color], metaInfo.pos)
    end
end

local colorList = {
	"白色","綠色","藍色","紫色","金色","紅色"
}
function PrimevalSellLayer:updatePrimevalSellView()
	self:updateColorList()
	for i=1, 6 do
		local text = self["Text_num_"..i]
		text:setString(string.format("%s混元 X %d", colorList[i], #self.colorList[i]))
	end
end

function PrimevalSellLayer:onBtnClick(sender)
    local nodeName = sender:getName()
	if nodeName == "Button_Close" then
		self:removeFromParent()
    end
end

local sellNotice = [[
	<t  fs="20"  tc="FFFFFFFF" oc="000000FF" os="2">
		是否確認出售<t  fs="20"  t="%s色"  tc="%d"  oc="%d"  os="2"/>品質混元?
	</t>
]]

function PrimevalSellLayer:onSellClick(sender)
	local nodeName = sender:getName()
	for i=1, 6 do
		local nm = "Button_sell_"..i
		if nm == nodeName then
			if self.colorList[i] and #self.colorList[i] > 0 then
				if i >= 5 then
					local layer = require("cp.view.ui.messagebox.GameMessagePanel"):create("提示", string.format(sellNotice, cp.getConst("CombatConst").SeriseColorZhCN[i], i, i))
					self:addChild(layer, 100)
					layer:setConfirmCallback(function()
						local req = {}
						req.pos_list = self.colorList[i]
						self:doSendSocket(cp.getConst("ProtoConst").SellMetaReq, req)
					end)
					return
				else
					local req = {}
					req.pos_list = self.colorList[i]
					self:doSendSocket(cp.getConst("ProtoConst").SellMetaReq, req)
				end
			end
			return
		end
	end
end

function PrimevalSellLayer:onEnterScene()
    self:updatePrimevalSellView()
end

function PrimevalSellLayer:onExitScene()
end

return PrimevalSellLayer