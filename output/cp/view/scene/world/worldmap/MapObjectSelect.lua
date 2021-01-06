--選擇人物和建築後的彈出選擇和選中效果
local MapObjectSelect = class("MapObjectSelect", function() return cc.Node:create() end )

function MapObjectSelect:create()
    local node = MapObjectSelect.new()
    node:init()
    return node
end

--初始化界面，以及設定界面元素標籤
function MapObjectSelect:init()

    display.loadSpriteFrames("uiplist/ui_mapbuild.plist")

    Button_1 = ccui.Button:create("ui_mapbuild_module6_jianghushi_chakan_a.png","ui_mapbuild_module6_jianghushi_chakan_b.png","ui_mapbuild_module6_jianghushi_chakan_a.png",ccui.TextureResType.plistType)
    self:addChild(Button_1,1)
    Button_1:setTouchEnabled(true)
    Button_1:setScale9Enabled(false)
    Button_1:setAnchorPoint(1,0.5)
    Button_1:setPosition(-29,73)
    cp.getManager("ViewManager").initButton(Button_1, function()
        if self.btnCallBack1 ~= nil then
            self.btnCallBack1()
        end
    end, 0.9)

    Button_2 = ccui.Button:create("ui_mapbuild_module6_jianghushi_qiecha_a.png","ui_mapbuild_module6_jianghushi_qiecha_b.png","ui_mapbuild_module6_jianghushi_qiecha_a.png",ccui.TextureResType.plistType)
    self:addChild(Button_2,1)
    Button_2:setTouchEnabled(true)
    Button_2:setScale9Enabled(false)
    Button_2:setAnchorPoint(0,0.5)
    Button_2:setPosition(29,73)
    cp.getManager("ViewManager").initButton(Button_2, function()
        if self.btnCallBack2 ~= nil then
            self.btnCallBack2()
        end
    end, 0.9)

end

function MapObjectSelect:setButtonClickCallBack(callBack1,callBack2)
    self.btnCallBack1 = callBack1
    self.btnCallBack2 = callBack2
end

return MapObjectSelect
