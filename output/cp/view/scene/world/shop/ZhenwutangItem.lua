
local BNode = require "cp.view.ui.base.BNode"
local ZhenwutangItem = class("ZhenwutangItem",BNode)

function ZhenwutangItem:create(goodsInfo)
	local node = ZhenwutangItem.new(goodsInfo)
	return node
end

function ZhenwutangItem:initListEvent()
	self.listListeners = {
		--購買商品返回
        [cp.getConst("EventConst").StoreBuyRsp] = function(data)	
            if data.goodsID > 0 and self.goodsInfo.goodsID == data.goodsID then
                self.goodsInfo.leftNum = data.leftNum
                if self.ItemIcon ~= nil then 
                    self.ItemIcon:resetNum(data.leftNum)
                end
                if data.leftNum == 0 then
					self.Image_soldout:setVisible(true)
					self.Panel_soldout:setVisible(true)
                    self.Text_name:setOpacity(128)
                    self.Image_price_type:setOpacity(128)
                    self.Text_price:setOpacity(128)
				end
            end
        end,
	}
end

function ZhenwutangItem:onInitView(goodsInfo)
    self.goodsInfo = goodsInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shop/uicsb_shop_zhenwutang_item.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_item"] = {name = "Panel_item"},
		["Panel_item.Image_price_type"] = {name = "Image_price_type"},
        ["Panel_item.Text_name"] = {name = "Text_name"},
		["Panel_item.Text_price"] = {name = "Text_price"},
		["Panel_item.Node_icon"] = {name = "Node_icon"},
		["Panel_item.Panel_soldout"] = {name = "Panel_soldout"},
		["Panel_item.Image_soldout"] = {name = "Image_soldout"},

		["Panel_item.Image_bg_unlock"] = {name = "Image_bg_unlock"},
		["Panel_item.Text_unlock"] = {name = "Text_unlock"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.Image_soldout:setVisible(false)
	self.Panel_soldout:setVisible(false)
end

function ZhenwutangItem:onEnterScene()
    
end

function ZhenwutangItem:onExitScene()
   
end

function ZhenwutangItem:resetBG(needBG)
	if needBG then
		if self.Image_bg == nil then
			self.Image_bg = ccui.ImageView:create()
			self.Image_bg:setAnchorPoint(cc.p(0.5,0.5))
			self.Image_bg:ignoreContentAdaptWithSize(true)
			self.Image_bg:setPosition(238,69)
			local path = "ui_shop_module46_shangdian11.png"
			self.Image_bg:loadTexture(path, ccui.TextureResType.plistType) 
			self.Image_bg:ignoreContentAdaptWithSize(false)
			self.Panel_item:addChild(self.Image_bg,-1)
		end
		self.Image_bg:setVisible(true)
	else
		if self.Image_bg then
			self.Image_bg:setVisible(false)
		end
	end


end


function ZhenwutangItem:resetInfo(goodsInfo)
	self.goodsInfo = goodsInfo
	if self.Node_icon:getChildByName("ItemIcon") ~= nil then
		self.Node_icon:removeAllChildren()
		self.ItemIcon = nil
	end
	if goodsInfo == nil then
		self.Text_name:setString("")
		self.Text_price:setString("")
		self.Image_soldout:setVisible(false)
		self.Image_price_type:setVisible(false)
		return
	end
	self.Text_price:setString(tostring(goodsInfo.Price))
	-- 元寶1， 銀兩2， 聲望3，俠義令4，鐵膽令5，天書殘頁6,幫派個人資金7，幫貢8
	local image = {[1] = "ui_common_yuanbao.png",[2] = "ui_common_yinliang.png",[3] = "ui_common_swz.png",[4]="ui_common_sz.png",[5]="ui_common_ez.png",[6]="ui_common_06tscy.png",[7]="ui_common_bpzj.png",[8]="ui_common_bg.png",[9]="ui_common_module33_vip_goumai_yu.png"}
	self.Image_price_type:loadTexture(image[goodsInfo.PriceType],ccui.TextureResType.plistType)
	self.Image_price_type:setVisible(true)
	local x,y = self.Text_price:getPosition()
	local szWidth = self.Text_price:getContentSize().width / self.Text_price.clearScale
	-- self.Image_price_type:setScale(self.Text_price.clearScale)
	self.Image_price_type:setPositionX(x - szWidth/2+5)
	
	local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", goodsInfo.ItemID)
	local itemInfo = {shopModel = true, hideName = true, Name = goodsInfo.Name,id = goodsInfo.ItemID, num = goodsInfo.leftNum,Icon = goodsInfo.Icon,Colour = goodsInfo.Colour,Type = conf:getValue("Type"), SubType = conf:getValue("SubType") }
	
	local item = require("cp.view.ui.icon.ItemIcon"):create(itemInfo)
	item:setName("ItemIcon")
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:resetNamePosY(-12)
	item:setItemClickCallBack(handler(self,self.onItemClick))
	
	self.Node_icon:addChild(item)
	self.ItemIcon = item
	
	self.Text_name:setString( goodsInfo.Name)
	-- self.Text_name:setTextColor(cp.getConst("GameConst").QualityTextColor[goodsInfo.Colour])
	cp.getManager("ViewManager").setTextQuality(self.Text_name,goodsInfo.Colour)
	
	self.Text_name:setOpacity(goodsInfo.leftNum > 0 and 255 or 128)
	self.Image_price_type:setOpacity(goodsInfo.leftNum > 0 and 255 or 128)
	self.Text_price:setOpacity(goodsInfo.leftNum > 0 and 255 or 128)
	self.Image_soldout:setVisible(goodsInfo.leftNum <= 0)
	self.Panel_soldout:setVisible(goodsInfo.leftNum <= 0)
end

function ZhenwutangItem:getItemSize()
    return self.Panel_item:getContentSize()
end

function ZhenwutangItem:onItemClick(sender)
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self.goodsInfo)	
	end
end

function ZhenwutangItem:setItemClickCallBack(cb)
    self.itemClickCallBack = cb
end

return ZhenwutangItem
