local BNode = require "cp.view.ui.base.BNode"
local MapLeftUI = class("MapLeftUI",BNode)

function MapLeftUI:create(openInfo)
	local node = MapLeftUI.new(openInfo)
	return node
end

function MapLeftUI:initListEvent()
	self.listListeners = {
	}
end

function MapLeftUI:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_worldmap/worldmap_left.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_left"] = {name = "Panel_left"},
        ["Panel_left.Image_1"] = {name = "Image_1",click = "onUIButtonClick"},
        ["Panel_left.Image_2"] = {name = "Image_2",click = "onUIButtonClick"},
        ["Panel_left.Image_3"] = {name = "Image_3",click = "onUIButtonClick"},
        ["Panel_left.Image_4"] = {name = "Image_4",click = "onUIButtonClick"},
        ["Panel_left.Image_5"] = {name = "Image_5",click = "onUIButtonClick"},
        ["Panel_left.Image_6"] = {name = "Image_6",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
end

function MapLeftUI:onUIButtonClick(sender)
  local buttonName = sender:getName()
  log("click button : " .. buttonName)
  local index = string.sub(buttonName,string.len( "Image_" )+1)
  log("click button index: " .. tostring(index))
  if self.btnClickCallBack ~= nil then
    self.btnClickCallBack(tonumber(index))
  end
end

function MapLeftUI:setUIButtonClickCallBack(cb)
  self.btnClickCallBack = cb
end

function MapLeftUI:onEnterScene()

end

return MapLeftUI
