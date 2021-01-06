local BLayer = require "cp.view.ui.base.BLayer"
local LotteryPointLayer = class("LotteryPointLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function LotteryPointLayer:create()
    local scene = LotteryPointLayer.new()
	scene:updateLotteryPointView()
    return scene
end

function LotteryPointLayer:initListEvent()
    self.listListeners = {
		[cp.getConst("EventConst").BuyLotteryPointShopRsp] = function(data)
            self:updateLotteryPointView()
            local itemList = {
                {
                    id=data.item_id,
                    num = data.num,
                }
            }
            cp.getManager("ViewManager").showGetRewardUI(itemList, "獲得物品", true)
		end,
		[cp.getConst("EventConst").RefreshLotteryPointShopRsp] = function(data)
			self:updateLotteryPointView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function LotteryPointLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_activity/uicsb_activity_lottery_point.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Text_Point"] = {name = "Text_Point"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Button_Refresh"] = {name = "Button_Refresh", click="onBtnClick"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item1"] = {name = "Image_Item1"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item2"] = {name = "Image_Item2"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item3"] = {name = "Image_Item3"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item4"] = {name = "Image_Item4"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item5"] = {name = "Image_Item5"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item6"] = {name = "Image_Item6"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item7"] = {name = "Image_Item7"},
		["Panel_root.Image_1.Panel_ItemList.Image_Item8"] = {name = "Image_Item8"},
		["Panel_root.Image_1.Text_Cost"] = {name = "Text_Cost"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
			self:removeFromParent()
		end
	end)
end

--cost單價
function LotteryPointLayer:onBuyItem(itemEntry, itemInfo, cost)
    local openInfo = {
        itemInfo = {
            id = itemInfo.item_id,
            num = itemInfo.num,
            Name = itemEntry:getValue("Name"),
            Colour = itemEntry:getValue("Hierarchy"),
            Type = itemEntry:getValue("Type"),
            Price = cost,
        },
        contentType = "duihuan",
        callback = function(num,itemInfo)
            if num < 1 then
                return
            end

            local req = {}
            req.item_id = itemInfo.id
            req.num = num
            self:doSendSocket(cp.getConst("ProtoConst").BuyLotteryPointShopReq, req)
        end
    }
    cp.getManager("ViewManager").showMultiItemOperateConfirmUI(openInfo)
end

function LotteryPointLayer:updateLotteryPointView()
    local userLottery = cp.getUserData("UserLottery")
    local pointShop = userLottery:getPointShop()
    self.Text_Point:setString("藏寶積分 "..userLottery:getLotteryData().point)

    local gameConfig = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("LotteryShop"), ":")
    table.sort(pointShop.item_list, function(a,b)
        local itemEntryA = cp.getManager("ConfigManager").getItemByKey("GameItem", a.item_id)
        local itemEntryB = cp.getManager("ConfigManager").getItemByKey("GameItem", b.item_id)
        return itemEntryA:getValue("Hierarchy") > itemEntryB:getValue("Hierarchy") or 
            (itemEntryA:getValue("Hierarchy") == itemEntryB:getValue("Hierarchy") and a.item_id<b.item_id)
    end)

    for i=1, #pointShop.item_list do
        local btn = self["Image_Item"..i]:getChildByName("Button_Model")
        local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", pointShop.item_list[i].item_id)
        btn:loadTextures(itemEntry:getValue("Icon"), itemEntry:getValue("Icon"), itemEntry:getValue("Icon"))
        if itemEntry:getValue("Type") == 2 then
            btn:getChildByName("Image_ItemType"):setVisible(true)
        else
            btn:getChildByName("Image_ItemType"):setVisible(false)
        end
        local icon = btn:getChildByName("Image_Icon")
        local name = btn:getChildByName("Text_Name")
        local textCost = btn:getChildByName("Text_Cost")
        local txtNum = btn:getChildByName("Text_Num")
        icon:loadTexture(CombatConst.SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
        name:setString(itemEntry:getValue("Name"))
        cp.getManager("ViewManager").setTextQuality(name, itemEntry:getValue("Hierarchy"))
        cp.getManager("ViewManager").addWidgetBottom(btn, itemEntry:getValue("Hierarchy"))
        txtNum:setString(pointShop.item_list[i].num)
        if pointShop.item_list[i].num == 0 then
            textCost:setString("已售完")
            textCost:setTextColor(cc.c4b(255,0,0,255))
            cp.getManager("ViewManager").initButton(btn, function()
                local skillItemLayer = require("cp.view.scene.shop.SkillItemLayer"):create(itemEntry)
                self:addChild(skillItemLayer, 100)
            end, 0.9)
        else
            local cost = 0
            textCost:setTextColor(cc.c4b(52,36,31,255))
            if itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Blue then
                cost = tonumber(gameConfig[2])
                textCost:setString(gameConfig[2].."積分")
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Purole then
                cost = tonumber(gameConfig[3])
                textCost:setString(gameConfig[3].."積分")
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Gold then
                cost = tonumber(gameConfig[4])
                textCost:setString(gameConfig[4].."積分")
            elseif itemEntry:getValue("Hierarchy") == CombatConst.ItemColor_Red then
                cost = tonumber(gameConfig[5])
                textCost:setString(gameConfig[5].."積分")
            end
            cp.getManager("ViewManager").initButton(btn, function()
                self:onBuyItem(itemEntry, pointShop.item_list[i], cost)
                --local skillItemLayer = require("cp.view.scene.shop.SkillItemLayer"):create(itemEntry, cost)
                --self:addChild(skillItemLayer, 100)
            end, 0.9)
        end
    end

    self.Text_Cost:setString(gameConfig[1])
end

function LotteryPointLayer:setCloseCallback(callback)
	self.closeCallback = callback
end

function LotteryPointLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
		if self.closeCallback then
			self.closeCallback()
		end
        self:removeFromParent()
    elseif nodeName == "Button_Refresh" then
        local req = {}
        self:doSendSocket(cp.getConst("ProtoConst").RefreshLotteryPointShopReq, req)
	end
end

function LotteryPointLayer:onEnterScene()
end

function LotteryPointLayer:onExitScene()
    self:unscheduleUpdate()
end

return LotteryPointLayer