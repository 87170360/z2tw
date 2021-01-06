local BScene = require "cp.view.ui.base.BScene"
local CombatScene = class("CombatScene",BScene)

function CombatScene:create()
    local scene = CombatScene.new()
    return scene
end


function CombatScene:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").combat_finish] = function()
            if self.combatFinishLayer then return end
            local combatData = cp.getUserData("UserCombat"):getCombatData()
            if not combatData then
                log("CombatScene event combat_finish,combatData is nil")
                return
            end

            if cp.getUserData("UserCombat"):getCombatType() ~= 0 then
                self:onOpenRewardView(combatData.combat_result.result, combatData.combat_reward)
            else
                if cp.getUserData("UserLogin"):getValue("isNewRole") then
                
                    local talkText = [[
此刻
在宗門練武坪上……]]
                    local NewGuideTypeWriter = require("cp.view.scene.newguide.NewGuideTypeWriter"):create(talkText)
                    NewGuideTypeWriter:setFinishedCallBack(function()
                        cp.getManager("ViewManager"):changeScene(cp.getConst("SceneConst").SCENE_WORLD)
                    end)
                    self:addChild(NewGuideTypeWriter,100)
                else
                    cp.getManager("ViewManager"):popScene()
                end
            end
        end,
        ["OpenCombatView"] = function()
            self:onOpenCombatView()
        end,
       
	}
end

function CombatScene:onEnterScene()
    log("111111111111111111111111111111111111111111111111111111111111111111111111111")
    local loadingLayer = require("cp.view.scene.combat.CombatLoadingLayer"):create()
    self:addChild(loadingLayer, 10)
    --[[
    local combatLayer = require("cp.view.scene.combat.CombatLayer"):create()
    self:addChild(combatLayer, 1)
    ]]
end

function CombatScene:onOpenCombatView()
    local combatLayer = require("cp.view.scene.combat.CombatLayer"):create()
    self:addChild(combatLayer, 1)
end

function CombatScene:onOpenRewardView(result, combatReward)
    local combatFinishLayer = require("cp.view.scene.combat.CombatFinishLayer"):create()
    self:addChild(combatFinishLayer,2)
    combatFinishLayer:showView(result, combatReward)
    self.combatFinishLayer = combatFinishLayer
end

return CombatScene