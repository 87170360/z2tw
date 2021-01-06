local JingjieItem = class("JingjieItem", function() return ccui.Layout:create() end)

-- itemInfo = select = bool選中 tip = bool進階 level = num等級 desc = str描述 callback = 回調 idx = 索引, cover = bool 覆蓋
function JingjieItem:create(itemInfo)
    local ret = JingjieItem.new()
    ret:init(itemInfo)
    return ret
end

function JingjieItem:init(itemInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/jingjieItem.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root", click = "onItemClick", clickScale=1},
      	["Panel_root.Image_select"] = {name = "Image_select"},
      	["Panel_root.Image_tip"] = {name = "Image_tip"},
      	["Panel_root.Text_level"] = {name = "Text_level"},
      	["Panel_root.Image_desc"] = {name = "Image_desc"},
      	["Panel_root.Image_cover"] = {name = "Image_cover"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self:setContentSize(self["Panel_root"]:getContentSize())

	self.itemClickCallBack = itemInfo.callback
	self:reset(itemInfo)
end

function JingjieItem:reset(itemInfo)
	self.itemInfo = itemInfo
	self["Image_select"]:setVisible(itemInfo.select)
	self["Image_tip"]:setVisible(itemInfo.tip)
	self["Image_cover"]:setVisible(itemInfo.cover)
	self["Text_level"]:setString("Lv." .. itemInfo.level)
	local jingjie = math.min(itemInfo.level,50)
	self["Image_desc"]:loadTexture("img/icon/jingjie/jingjie_" .. tostring(jingjie) ..".png", ccui.TextureResType.localType)
end

function JingjieItem:onItemClick(sender)
	if self.itemClickCallBack ~= nil then
		self.itemClickCallBack(self.itemInfo)
	end
end

return JingjieItem
