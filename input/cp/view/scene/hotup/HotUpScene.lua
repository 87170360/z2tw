local BScene = require "cp.view.ui.base.BScene"
local HotUpScene = class("HotUpScene",BScene)

function HotUpScene:create()
    local scene = HotUpScene.new()
    return scene
end


function HotUpScene:initListEvent()
    self.listListeners = {
        ["CheckHotUp"] = function(data)
            local layer = require("cp.view.scene.hotup.HotUpLayer"):create()
            self:addChild(layer)            
        end,
    }
end

function HotUpScene:onEnterScene()
    if not cp.getUtils("DataUtils").hasSoftPartInstalled() then
        local layer = require("cp.view.scene.hotup.SoftPartLayer"):create()
        self:addChild(layer)
    else
        local layer = require("cp.view.scene.hotup.HotUpLayer"):create()
        self:addChild(layer)
    end
end

return HotUpScene