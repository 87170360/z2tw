
local BLayer = require "cp.view.ui.base.BLayer"
local Recharge = class("Recharge",BLayer)

function Recharge:create(openInfo)
	local layer = Recharge.new(openInfo)
	return layer
end

function Recharge:initListEvent()
	self.listListeners = {
     
        --儲值返回
        [cp.getConst("EventConst").RechargeRsp] = function(evt)
           
            for i=1,table.nums(self.itemList) do
                if self.itemList[i].ID == evt.rechargeID then

                    if self.itemList[i].Type >= 1 then  --月卡,終身卡,季卡，年卡，江湖基金
                        if self.itemList[i].Type == 5 then
                            cp.getManager("ViewManager").gameTip("江湖基金已購買，趕緊升級領取更多獎勵吧。")
                            return 
                        end

                        local Cards = cp.getUserData("UserVip"):getValue("Cards")  --月卡,終身卡,季卡，年卡
                        local cfgItem = cp.getManager("ConfigManager").getItemByMatch("Card",{RechargeID = evt.rechargeID})
                        local itemId = cfgItem:getValue("ID")
                        local addDays = cfgItem:getValue("Day")
                        local days = 0
                        if Cards then
                            days = Cards[tostring(itemId)] or 0
                            days = math.max(days,0)
                        end
                        local text = {[6]="月卡",[7]="終身卡",[8]="季卡",[9]="年卡"}
                        if days > addDays then
                            
                            cp.getManager("ViewManager").gameTip( "激活成功，您的" .. text[evt.rechargeID] .. "時限已延長。")
                        else
                            cp.getManager("ViewManager").gameTip(text[evt.rechargeID] .. "已激活，每日獎勵將通過信札發放。")
                        end
                    else
                        local str = "儲值成功，獲得"
                        local BuyItemArr = string.split(self.itemList[i].BuyItem,"-")
                        local buyItemId = tonumber(BuyItemArr[1])
                        local buyItemNum = tonumber(BuyItemArr[2])
                        local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", buyItemId)
                        if conf ~= nil then
                            local name = conf:getValue("Name")
                            str = str .. tostring(buyItemNum) .. name
                            cp.getManager("ViewManager").gameTip(str)
                        end
                        if evt.first then
                            local arr1 = {}
                            string.loopSplit(self.itemList[i].GiftItem,"|-",arr1)
                            if table.nums(arr1) > 0 then
                                local str = "首儲贈送"
                                for j=1,table.nums(arr1) do
                                    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", tonumber(arr1[j][1]) )
                                    if conf ~= nil then
                                        local name = conf:getValue("Name")
                                        str = str .. arr1[j][2] .. name
                                        if j ~= table.nums(arr1) then
                                            str = str .. ","
                                        end
                                    end
                                end
                                cp.getManager("ViewManager").gameTip(str)
                            end
                        else
                            if self.itemList[i].More ~= "" then
                                local str = "儲值贈送"
                                local arrTemp = string.split(self.itemList[i].More,"-")
                                local num = tonumber(arrTemp[2])
                                local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", tonumber(arrTemp[1]) )
                                if conf ~= nil then
                                    local name = conf:getValue("Name")
                                    str = str .. arrTemp[2] .. name
                                end
                                cp.getManager("ViewManager").gameTip(str)
                            end
                        end
                    end

                    break
                end
            end
			
        end,
        
	}
end

function Recharge:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_vip/uicsb_vip_recharge.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_top"] = {name = "Panel_top"},
        ["Panel_root.Panel_top.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Panel_top.FileNode_1"] = {name = "FileNode_1"},
        ["Panel_root.Panel_top.Panel_content"] = {name = "Panel_content"}
        
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    self:setPosition(display.cx,display.cy)
    if display.height <= 960 then
        self:setPositionY(display.height - self.Panel_root:getContentSize().height/2)
    end

    local VipTopUI = require("cp.view.scene.world.vip.VipTopUI"):create("Recharge")
    VipTopUI:setButtonClickCallBack(function()
        self:dispatchViewEvent(cp.getConst("EventConst").open_vip_view,true)
        cp.getManager("PopupManager"):removePopup(self)
    end)
    self.FileNode_1:addChild(VipTopUI)
    
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy))
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpView(self.Panel_root)
end

function Recharge:onEnterScene()

    self.itemList = {}
    local count = cp.getManager("ConfigManager").getItemCount("Recharge")
    for i=1,count do
        local cfg = cp.getManager("ConfigManager").getItemAt("Recharge",i)
        local itemInfo = {}
        itemInfo.ID = cfg:getValue("ID") 
        itemInfo.Money = cfg:getValue("Money")
        itemInfo.BuyItem = cfg:getValue("BuyItem")
        itemInfo.GiftItem = cfg:getValue("GiftItem")
        itemInfo.Icon = cfg:getValue("Icon")
        itemInfo.Type = cfg:getValue("Type")
        itemInfo.ItemCode = cfg:getValue("ItemCode")
        itemInfo.SustainedEarnings = cfg:getValue("SustainedEarnings")
        itemInfo.First = cfg:getValue("First")
        itemInfo.More = cfg:getValue("More")
        if itemInfo.Icon ~= "" then
            table.insert(self.itemList,itemInfo)
        end
    end
    
    table.sort(self.itemList, function(a,b)
        return a.ID <= b.ID
    end)

    self:createCellItems()
end

function Recharge:onExitScene()
    
end


function Recharge:refreshItems()
    
end

function Recharge:createCellItems()
    self.Panel_content:removeAllChildren()
   
    -- self:refreshItems()

    local sz = self.Panel_content:getContentSize()
    self.cellView = cp.getManager("ViewManager").createCellView(cc.size(sz.width,sz.height))
    self.cellView:setCellSize(325,165)
    self.cellView:setColumnCount(2)
    self.cellView:setAnchorPoint(cc.p(0, 0))
    self.cellView:setPosition(cc.p(0, 0))
    self.cellView:setCountFunction(
        function()
            return table.nums(self.itemList)
        end)

    local function cellFactoryFunc(cellview, idx)
        idx = idx + 1

        local item = nil
        local cell = cellview:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = require("cp.view.scene.world.vip.RechargeItem"):create()
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        if item then
            item:resetInfo(self.itemList[idx])
        end
        return cell
    end
    self.cellView:setCellFactory(cellFactoryFunc)
    self.cellView:reloadData()
    self["Panel_content"]:addChild(self.cellView)
    
end

function Recharge:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)
    if "Button_close" == buttonName then
        -- self:dispatchViewEvent(cp.getConst("EventConst").open_vip_view,true) --發消息更新主界面的元寶訊息，更新VIP訊息。
        cp.getManager("PopupManager"):removePopup(self)
    end
end


return Recharge
