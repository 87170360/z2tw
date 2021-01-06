local BLayer = require "cp.view.ui.base.BLayer"
local CombatLayer = class("CombatLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")
function CombatLayer:create(openInfo)
    local scene = CombatLayer.new()
    return scene
end

local BufferBoxList = {
    "ui_combat_module03_battle_bufk06.png",
    "ui_combat_module03_battle_bufk02.png",
    "ui_combat_module03_battle_bufk05.png",
    "ui_combat_module03_battle_bufk04.png",
    "ui_combat_module03_battle_bufk01.png",
    "ui_combat_module03_battle_bufk03.png",
}

function CombatLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").combat_show_story] = function(gameStoryList)
            self:showGameStory(gameStoryList)
        end
    }
end

--初始化界面，以及設定界面元素標籤
function CombatLayer:onInitView()
	local sceneID = cp.getUserData("UserCombat"):getCombatData().scene_id
    local sceneConfig = cp.getManager("ConfigManager").getItemByKey("GameScene", sceneID)
    if sceneConfig == nil then
        log("Error,sceneID is not exist, sceneID = " .. tostring(sceneID))
    end
    self.run_stage_time = sceneConfig:getValue("RunStageTime")
    self.maxBufferCount = 0

    self.rootView = cc.CSLoader:createNode(sceneConfig:getValue("SceneFile"))
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    self.uiView = cc.CSLoader:createNode("uicsb/uicsb_combat/uicsb_combat_ui.csb")
	self.uiView:setPosition(cc.p(0,0))
    self:addChild(self.uiView, 2)
    self.uiView:setContentSize(display.size)
    self.round = 0
    self.showLeft = false
    self.showRight = false
    self.spineNode = {}

    self.leftBufferList = {}
    self.rightBufferList = {}

    local viewConfig = {
		["Panel_root"] = {name = "Panel_root"},
		--["Panel_root.Image_Flag"] = {name = "Image_Flag"},
        ["Panel_root.dynamic"] = {name = "dynamic"},
      	["Panel_root.dynamic.yj_loop_0"] = {name = "yj_loop_0"},
      	["Panel_root.dynamic.yj_loop_1"] = {name = "yj_loop_1"},
      	["Panel_root.dynamic.yj_loop_2"] = {name = "yj_loop_2"},
      	["Panel_root.dynamic.zj_loop_0"] = {name = "zj_loop_0"},
      	["Panel_root.dynamic.zj_loop_1"] = {name = "zj_loop_1"},
      	["Panel_root.dynamic.zj_loop_2"] = {name = "zj_loop_2"},
      	["Panel_root.dynamic.qj_loop_0"] = {name = "qj_loop_0"},
      	["Panel_root.dynamic.qj_loop_1"] = {name = "qj_loop_1"},
    }

    local uiConfig = {
		["Image_Parry"] = {name = "Image_Parry"},
		["Image_Hurt"] = {name = "Image_Hurt"},
		["Image_Event"] = {name = "Image_Event"},
		["Image_Critic"] = {name = "Image_Critic"},
		["Image_Other"] = {name = "Image_Other"},
      	["Panel_top.Button_Exit"] = {name = "Button_Exit", click="onBtnClick", clickScale=1.0},
      	["Panel_top.Button_Comment"] = {name = "Button_Comment", click="onBtnClick"},
      	["Panel_top.AtlasLabel_Round"] = {name = "AtlasLabel_Round"},
      	["Panel_top.Image_Comment"] = {name = "Image_Comment"},
      	["Panel_bottom.Image_SkillMask"] = {name = "Image_SkillMask"},
      	["Panel_bottom.btn_skill1"] = {name = "btn_skill1"},
      	["Panel_bottom.btn_skill2"] = {name = "btn_skill2"},
      	["Panel_bottom.btn_skill3"] = {name = "btn_skill3"},
      	["Panel_bottom.btn_skill4"] = {name = "btn_skill4"},
      	["Panel_bottom.btn_skill5"] = {name = "btn_skill5"},
      	["Panel_bottom.btn_skill6"] = {name = "btn_skill6"},
      	["Panel_bottom.Image_Left"] = {name = "Image_left"},
      	["Panel_bottom.Image_Left.LoadingBar_Life_L"] = {name = "LoadingBar_Life_L"},
      	["Panel_bottom.Image_Left.LoadingBar_Life_L.Text_Life_L"] = {name = "Text_Life_L"},
      	["Panel_bottom.Image_Left.LoadingBar_Force_L"] = {name = "LoadingBar_Force_L"},
      	["Panel_bottom.Image_Left.LoadingBar_Force_L.Text_Force_L"] = {name = "Text_Force_L"},
      	["Panel_bottom.Image_Left.Image_Face_L"] = {name = "Image_Face_L"},
      	["Panel_bottom.Image_Left.LoadingBar_Qi_L"] = {name = "LoadingBar_Qi_L"},
      	["Panel_bottom.Image_Left.Text_Qi_L"] = {name = "Text_Qi_L"},
      	["Panel_bottom.Image_Left.Node_LeftBlink"] = {name = "Node_LeftBlink"},
      	["Panel_bottom.Image_Right"] = {name = "Image_right"},
      	["Panel_bottom.Image_Right.LoadingBar_Life_R"] = {name = "LoadingBar_Life_R"},
      	["Panel_bottom.Image_Right.LoadingBar_Force_R"] = {name = "LoadingBar_Force_R"},
      	["Panel_bottom.Image_Right.LoadingBar_Life_R.Text_Life_R"] = {name = "Text_Life_R"},
      	["Panel_bottom.Image_Right.LoadingBar_Force_R.Text_Force_R"] = {name = "Text_Force_R"},
      	["Panel_bottom.Image_Right.LoadingBar_Qi_R"] = {name = "LoadingBar_Qi_R"},
      	["Panel_bottom.Image_Right.Text_Qi_R"] = {name = "Text_Qi_R"},
      	["Panel_bottom.Image_Right.Node_RightBlink"] = {name = "Node_RightBlink"},
      	["Panel_bottom.Image_Right.Image_Face_R"] = {name = "Image_Face_R"},
      	["Panel_side.ListView_LeftBuffer"] = {name = "ListView_LeftBuffer"},
      	["Panel_side.ListView_RightBuffer"] = {name = "ListView_RightBuffer"},
      	["Panel_DefaultLeft"] = {name = "Panel_DefaultLeft"},
      	["Panel_DefaultRight"] = {name = "Panel_DefaultRight"},
      	["Image_LeftSkill"] = {name = "Image_LeftSkill"},
      	["Image_RightSkill"] = {name = "Image_RightSkill"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, viewConfig)
	cp.getManager("ViewManager").setCSNodeBinding(self, self.uiView, uiConfig)

    self.DynamicBar_Qi_L = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Qi_L, self.Text_Qi_L, true)
    self.DynamicBar_Qi_R = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Qi_R, self.Text_Qi_R, true)

    self.DynamicBar_Force_L = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Force_L, self.Text_Force_L, false)
    self.DynamicBar_Force_R = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Force_R, self.Text_Force_R, false)
    
    self.DynamicBar_Life_L = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Life_L, self.Text_Life_L, false)
    self.DynamicBar_Life_R = require("cp.view.ui.base.DynamicProgressBar"):create(self.LoadingBar_Life_R, self.Text_Life_R, false)

    self.sceneConfig = sceneConfig
    self.Image_Face_L:ignoreContentAdaptWithSize(true)
    self.Image_Face_R:ignoreContentAdaptWithSize(true)
    self.ListView_LeftBuffer:setScrollBarEnabled(false)
    self.ListView_RightBuffer:setScrollBarEnabled(false)
    self:loadAllSpineNodes()

    cp.getManager("ViewManager").setWidgetAdapt(1280, {self.ListView_LeftBuffer, self.ListView_RightBuffer})
    
    cp.CombatController:init(self, self.sceneConfig)
    self:scheduleUpdate(function(dt)
        cp.CombatController:update(dt)
    end)

    ccui.Helper:doLayout(self.uiView)
    
    local txtFloor = self.zj_loop_0:getChildByName("Text_Floor")
	local combatType = cp.getUserData("UserCombat"):getCombatType()
    if combatType == cp.getConst("CombatConst").CombatType_Tower then
        local floor = cp.getUserData("UserCombat"):getValue("Floor")
        txtFloor:setString("第 "..floor.." 層")
    elseif txtFloor then
        txtFloor:setString("")
    end

    self:dispatchViewEvent("CloseCombatLoadingLayer")
end

function CombatLayer:shakeLayer()
    self:runAction(cc.Repeat:create(
        cc.Sequence:create(
            cc.MoveBy:create(0.02,cc.p(10,10)),
            cc.MoveBy:create(0.02,cc.p(-10,-10)),
            cc.MoveBy:create(0.02,cc.p(10,10)),
            cc.MoveBy:create(0.02,cc.p(-10,-10)))
    , 8)) 
end

function CombatLayer:loadAllSpineNodes()
    local nodes = string.split(self.sceneConfig:getValue("SpineNode"), ";")
    if #nodes == 0 then
        return
    end

    local viewConfig = {}
    for _, nodePath in ipairs(nodes) do
        local nodeName = ""
        for i=#nodePath, 1, -1 do
            local ch = nodePath:sub(i,i)
            if ch == "." then
                nodeName = string.sub(nodePath, i+1, #nodePath)
                break
            end
        end

        if nodeName:len() ~= 0 then
            viewConfig[nodePath] = {name = nodeName}
        end
    end
    cp.getManager("ViewManager").setCSNodeBinding(self.spineNode, self.rootView, viewConfig)
    local delay = 0
    for nodeName, obj in pairs(self.spineNode) do
        local extensionData = tolua.cast(obj:getComponent("ComExtensionData"), "ccs.ComExtensionData")
        local path = extensionData:getCustomProperty()
        if string.len(path) ~= 0 then
            local model = cp.getManager("ViewManager").createSceneSkeleton(self.sceneConfig:getValue("SceneID"), path)
            model:setAnchorPoint(cc.p(0,1))
            model:setAnimation(0, path, true)
            model:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
                model:setAnimation(0, path, true)
            end)))
            delay = delay + 0.1
            obj:addChild(model)
        end
    end
end

function CombatLayer:updateHeadIcon(leftFace, rightFace)
    self.Image_Face_L:loadTexture(cp.DataUtils.getModelCombatFace(leftFace))
    self.Image_Face_L:ignoreContentAdaptWithSize(true)
    self.Image_Face_R:loadTexture(cp.DataUtils.getModelCombatFace(rightFace))
    self.Image_Face_R:ignoreContentAdaptWithSize(true)
end

function CombatLayer:updateUseSkill(skillNum)
    local initPos = 86
    local newPosX = ((skillNum-1)%6)*(109)+initPos
    local newPosY = self.Image_SkillMask:getPositionY()
    --self.Image_SkillMask:setPositionX(newPos)
    if newPosX ~= self.Image_SkillMask:getPositionX() then
        self.Image_SkillMask:runAction(cc.MoveTo:create(0.2, cc.p(newPosX, newPosY)))
    end
end

function CombatLayer:showUseSkill(entity, result)
    local skillName = ""
    if result.use_skill and result.use_skill > 0 then
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", result.use_skill)
        skillName = skillName..skillEntry:getValue("SkillName")
    end

    if result.use_art and result.use_art > 0 then
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", result.use_art)
        skillName = skillName.."◆"
        skillName = skillName..skillEntry:getValue("SkillName")
    end

    local imgSkillName = nil
    local sequence = {}
    if entity.side == "left" then
        imgSkillName = self.Image_LeftSkill
        imgSkillName:setPosition(cc.p(-720,320))
        table.insert(sequence, cc.MoveTo:create(0.2, cc.p(0, 320)))
        table.insert(sequence, cc.DelayTime:create(1.0))
        table.insert(sequence, cc.MoveTo:create(0.2, cc.p(-720, 320)))
    else
        imgSkillName = self.Image_RightSkill
        imgSkillName:setPosition(cc.p(1440,320))
        table.insert(sequence, cc.MoveTo:create(0.2, cc.p(720, 320)))
        table.insert(sequence, cc.DelayTime:create(1.0))
        table.insert(sequence, cc.MoveTo:create(0.2, cc.p(1440, 320)))
    end

    imgSkillName:getChildByName("Text_SkillName"):setString(skillName)
    imgSkillName:runAction(cc.Sequence:create(sequence))
end

function CombatLayer:hasCombine(skillEntry, skillIDList)
	local unitEntry = cp.getManager("ConfigManager").getItemByKey("SkillUnits", skillEntry:getValue("SkillID"))
	if not unitEntry then
		return false
	end

	local skillList = string.split(unitEntry:getValue("NeedSkills"), ";")
    for _, skillID in ipairs(skillList) do
        local flag = false
        for _, combatSkillInfo in ipairs(skillIDList) do
            if tonumber(skillID) == combatSkillInfo.id then
                flag = true
            end
        end
        if not flag then
            return false
        end
	end

	return true
end

function CombatLayer:initCombatLayerView(roundResult)
    self.AtlasLabel_Round:setString(1)

    local sideResult = roundResult.side_result_list[1]
    local hurt = roundResult.side_result_list[1].hurt or 0
    self.DynamicBar_Life_L:initProgress(sideResult.max_life, sideResult.life)
    self.DynamicBar_Force_L:initProgress(sideResult.max_force, sideResult.force)
    self.DynamicBar_Qi_L:initProgress(CombatConst.MaxQi, sideResult.qi)
    self:loadEntityPrimeval("left", sideResult.primeval)

    sideResult = roundResult.side_result_list[2]
    hurt = roundResult.side_result_list[2].hurt or 0
    self.DynamicBar_Life_R:initProgress(sideResult.max_life, sideResult.life)
    self.DynamicBar_Force_R:initProgress(sideResult.max_force, sideResult.force)
    self.DynamicBar_Qi_R:initProgress(CombatConst.MaxQi, sideResult.qi)
    self:loadEntityPrimeval("right", sideResult.primeval)

    local skillList = roundResult.side_result_list[1].skill_list
    self.equipList = {}
    for i=1, #skillList do
        local combatSkillInfo = skillList[i]
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", combatSkillInfo.id)
        table.insert(self.equipList, combatSkillInfo.id)
        local btn = self["btn_skill"..i]
        cp.getManager("ViewManager").initButton(btn, function()
            if not skillEntry or skillEntry:getValue("SkillType") == 2 or skillEntry:getValue("SkillType") == 3 then
                return
            end
            local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry, combatSkillInfo, false, self.equipList)
            self:addChild(layer, 100)
        end, 1.0)
        local img = btn:getChildByName("Image_skill"..i)
        local txtLevel = btn:getChildByName("Text_Level")
        local TopSkillEffect = img:getChildByName("TopSkillEffect")
        local SkillCombineEffect = img:getChildByName("SkillCombineEffect")
        img:loadTexture(CombatConst.SkillBoxList[skillEntry:getValue("Colour")], ccui.TextureResType.plistType)
        local txt = btn:getChildByName("Text_skill"..i)
        txtLevel:setString("LV."..combatSkillInfo.skill_level)
        if skillEntry:getValue("SkillType") == 3 then
            txtLevel:setVisible(false)
        else
            txtLevel:setVisible(true)
        end
        txt:setString(skillEntry:getValue("SkillName"))
        cp.getManager("ViewManager").setTextQuality(txt, skillEntry:getValue("Colour"))
        btn:loadTextures(skillEntry:getValue("Icon"), skillEntry:getValue("Icon"), skillEntry:getValue("Icon"))
        if combatSkillInfo.boundary == 10 then
            if not TopSkillEffect then
                TopSkillEffect = cc.Sprite:create()
                TopSkillEffect:setName("TopSkillEffect")
                img:addChild(TopSkillEffect)
                TopSkillEffect:setPosition(cc.p(49,51))
                TopSkillEffect:setScale(cp.getConst("GameConst").EffectScale)
            end
            TopSkillEffect:stopAllActions()
            local animation = cp.getManager("ViewManager").createEffectAnimation("SkillSpecial", 0.045, 1000000)
            TopSkillEffect:runAction(cc.Animate:create(animation))
            TopSkillEffect:setVisible(true)
        elseif TopSkillEffect then
            TopSkillEffect:setVisible(false)
        end

        if self:hasCombine(skillEntry, skillList) then
            if not SkillCombineEffect then
                SkillCombineEffect = cc.Sprite:create()
                SkillCombineEffect:setName("SkillCombineEffect")
                img:addChild(SkillCombineEffect)
                SkillCombineEffect:setScale(cp.getConst("GameConst").EffectScale)
                SkillCombineEffect:setPosition(cc.p(49,51))
            end
            SkillCombineEffect:stopAllActions()
            local animation = cp.getManager("ViewManager").createEffectAnimation("SkillCombine", 0.045, 1000000)
            SkillCombineEffect:runAction(cc.Animate:create(animation))
            SkillCombineEffect:setVisible(true)
        elseif SkillCombineEffect then
            SkillCombineEffect:stopAllActions()
            SkillCombineEffect:setVisible(false)
        end
    end

    self:updateUseSkill(1)

    self:updateHeadIcon(roundResult.side_result_list[1].face, roundResult.side_result_list[2].face)
end

function CombatLayer:loadEntityPrimeval(side, primevalList)
    if not primevalList or #primevalList == 0 then
        return
    end
    
    for i=1, 3 do
        local primeval = primevalList[i]
        if not primeval then
            break
        end
        
        local primevalEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", primeval)
        local gameEventEntry = cp.getManager("ConfigManager").getItemByKey("GameEventEntry", tonumber(primevalEntry:getValue("EventList")))

        local nodePrimeval = self["Image_"..side]:getChildByName("Node_Primeval"..i)

        local primevalEffect = cc.Sprite:create()
        primevalEffect:setName("Effect")
        nodePrimeval:addChild(primevalEffect)
        
        nodePrimeval.primeval = primeval

        primevalEffect:stopAllActions()
        local effectName = "hunyuan_moren"
        local framePerSec = 30
        if #gameEventEntry:getValue("LoadElements") > 0 then
            framePerSec = 30
            effectName = primevalEntry:getValue("Combat_Effect")
        end
        local animation = cp.getManager("ViewManager").createEffectAnimation(effectName, 1/framePerSec, 1000000)
        primevalEffect:runAction(cc.Animate:create(animation))
        
        local imgPrimeval = ccui.ImageView:create()
        imgPrimeval:setName("Image_Primeval")
        imgPrimeval:setTouchEnabled(true)
        imgPrimeval:ignoreContentAdaptWithSize(false)
        imgPrimeval:setContentSize(cc.size(39,39))
        imgPrimeval:loadTexture(primevalEntry:getValue("Icon"))
        nodePrimeval:addChild(imgPrimeval)
        
        cp.getManager("ViewManager").initButton(imgPrimeval, function()
            local layer = require("cp.view.scene.primeval.PrimevalCombatLayer"):create(primevalList)
            self:addChild(layer, 100)
        end, 1)
    end
end

function CombatLayer:showPrimevalEffect(side, primevalEntry)
	local img = self["Image_"..side]
	for i=1,3 do
        local nodePrimeval = img:getChildByName("Node_Primeval"..i)
        local primeval = nodePrimeval.primeval
        if primeval and primeval == primevalEntry:getValue("ID") then
            local primevalEffect = nodePrimeval:getChildByName("Effect")
            if not primevalEffect then
                return
            end
		    primevalEffect:stopAllActions()

            local framePerSec = 30
		    local animation1 = cp.getManager("ViewManager").createEffectAnimation(primevalEntry:getValue("Combat_Effect"), 0.033333, 1)
            local animation2 = cp.getManager("ViewManager").createEffectAnimation("hunyuan_moren", 1/framePerSec, 1000000)
		
		    local sequence = {}
		    table.insert(sequence, cc.Animate:create(animation1))
		    table.insert(sequence, cc.Animate:create(animation2))
            primevalEffect:runAction(cc.Sequence:create(sequence))
            break
        end
	end
end

function CombatLayer:updateCombatLayerView(roundResult, initBar)
    local round = roundResult.round
    if not round or round == 0 then
        round = 1
    end

    self.AtlasLabel_Round:setString(tostring(round))
end

function CombatLayer:updateQi(entity, dt, deltaQi)
    local dynamicBar = nil
    if entity.side == "left" then
        dynamicBar = self.DynamicBar_Qi_L
    else
        dynamicBar = self.DynamicBar_Qi_R
    end

    if not dt then
        if deltaQi > 0 then
            self:setNodeBlink(entity, 1)
        elseif deltaQi < 0 then
            self:setNodeBlink(entity, -1)
        end
        dt = 0.1
    end
    --dynamicBar.debug = true
    dynamicBar:updateProgress(entity.maxQi, deltaQi, dt)
end

function CombatLayer:updateForce(entity, dt, deltaForce, maxForce)
    if maxForce then
        entity.maxForce = maxForce
    end
    entity.force = entity.force + deltaForce

    if entity.force < 0 then
        entity.force = 0
    end

    if entity.force > entity.maxForce then
        entity.force = entity.maxForce
    end

    local dynamicBar = nil
    if entity.side == "left" then
        dynamicBar = self.DynamicBar_Force_L
    else
        dynamicBar = self.DynamicBar_Force_R
    end

    dynamicBar:updateProgress(entity.maxForce, deltaForce, dt)
end

function CombatLayer:updateLife(entity, dt, deltaLife, maxLife)
    if maxLife then
        entity.maxLife = maxLife
    end
    entity.life = entity.life + deltaLife
    
    if entity.life < 0 then
        entity.life = 0
    end

    if entity.life > entity.maxLife then
        entity.life = entity.maxLife
    end

    local dynamicBar = nil
    if entity.side == "left" then
        dynamicBar = self.DynamicBar_Life_L
    else
        dynamicBar = self.DynamicBar_Life_R
    end

    dynamicBar:updateProgress(entity.maxLife, deltaLife, dt)
end

function CombatLayer:updateBufferComment()
    local count = self.ListView_LeftBuffer:getChildrenCount()
    for i=0, count-1 do
        local btn = self.ListView_LeftBuffer:getItem(i)
        local img = btn:getChildByName("Image_Comment")
        local txt = btn:getChildByName("Text_Comment")
        img:setVisible(self.showLeft)
        txt:setVisible(self.showLeft)
        local sz = txt:getVirtualRendererSize()
        img:setSize(cc.size(sz.width+50, img:getSize().height))
    end
    
    local count = self.ListView_RightBuffer:getChildrenCount()
    for i=0, count-1 do
        local btn = self.ListView_RightBuffer:getItem(i)
        local img = btn:getChildByName("Image_Comment")
        local txt = btn:getChildByName("Text_Comment")
        img:setVisible(self.showRight)
        txt:setVisible(self.showRight)
        local sz = txt:getVirtualRendererSize()
        img:setSize(cc.size(sz.width+50, img:getSize().height))
    end
end

function CombatLayer:addBuffer(bufferInfo, bufferList, listView)
        local name = "Button_"..bufferInfo.index
        --log(listView:getName()..",add buffer index "..name)
        bufferList[name] = {
            id=bufferInfo.buffer_id,
            round=bufferInfo.round,
            elements=bufferInfo.elements
        }
        local panel = nil
        if listView == self.ListView_LeftBuffer then
            panel = self.Panel_DefaultLeft:clone()
        else
            panel = self.Panel_DefaultRight:clone()
        end
        local btn = panel:getChildByName("Button_Default")
        panel:setVisible(true)
        panel:setName(name)
        local icon = panel:getChildByName("Image_Icon")
        --btn:ignoreContentAdaptWithSize(true)
        local statusEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferInfo.buffer_id)
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", bufferInfo.skill)
        local textureName = ""
        if statusEntry:getValue("BufferType") == 1 then
            textureName = "ui_combat_module03_battle_bufk02.png"
        elseif statusEntry:getValue("BufferType") == 2 then
            textureName = "ui_combat_module03_battle_bufk03.png"
        end
        btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        panel:getChildByName("AtlasLabel_Round"):setString(bufferInfo.round)
        if string.len(statusEntry:getValue("Icon")) > 0 then
            icon:loadTexture(statusEntry:getValue("Icon"))
        elseif skillEntry then
            icon:loadTexture(skillEntry:getValue("Icon"))
        end

        cp.getManager("ViewManager").initButton(panel, function()
            if listView == self.ListView_LeftBuffer then
                self.showLeft = not self.showLeft
                self.showRight = false
                self:updateBufferComment()
            else
                self.showRight = not self.showRight
                self.showLeft = false
                self:updateBufferComment()
            end
        end, 1.0)
        local desc = statusEntry:getValue("BufferDesc")
        if desc:len()==0 then
            desc = statusEntry:getValue("Comment")
        end
        if #bufferInfo.elements > 0 then
            local attrList = {}
            for _, element in ipairs(bufferInfo.elements) do
                table.insert(attrList, {
                    element.id, math.abs(element.value)
                })
            end
            desc = cp.getUtils("DataUtils").formatSkillEffect(nil, desc, attrList)
        end
        if desc:len() == 0 then
            --log("desc empty, buffer="..bufferInfo.buffer_id)
        end
        panel:getChildByName("Text_Comment"):setString(desc)
        listView:pushBackCustomItem(panel)
        listView:jumpToBottom()
        self:updateBufferComment()
        --log("add buffer "..bufferInfo.buffer_id.." to "..name)
end

function CombatLayer:addBuffers(entity, buffers)
    local bufferList = entity.bufferList
    local listView = nil
    if entity.side == "left" then
        listView = self.ListView_LeftBuffer
    else
        listView = self.ListView_RightBuffer
    end

    for i, bufferInfo in ipairs(buffers) do
        if bufferInfo.flag == 0 then
            local bufferEntry = cp.getManager("ConfigManager").getItemByKey("SkillStatusEntry", bufferInfo.buffer_id)
            if bufferInfo.round == 0 then
                if string.len(bufferEntry:getValue("ShowName")) > 0 then
                    entity:createEffectInfo(bufferEntry:getValue("ShowName"))
                end
            else
                self:addBuffer(bufferInfo, bufferList, listView)
                self:setNodeBlink(entity, 0)
            end
            local eventList = cp.getUtils("DataUtils").split(bufferEntry:getValue("EventList"), ";")
            entity:runLoadElements(eventList)
        elseif bufferInfo.flag == 1 then
            local name = "Button_"..bufferInfo.index
            local btn = listView:getChildByName(name)
            local index = listView:getIndex(btn)
            listView:removeItem(index)
            bufferList[name] = nil
            self:setNodeBlink(entity, 0)
        end
    end
end

function CombatLayer:removeBuffer(entity, index)
    local bufferList = entity.bufferList
    local listView = nil
    if entity.side == "left" then
        listView = self.ListView_LeftBuffer
    else
        listView = self.ListView_RightBuffer
    end

    local name = "Button_"..index
    local btn = listView:getChildByName(name)
    bufferList[name] = nil
    if not btn then return end
    local index = listView:getIndex(btn)
    listView:removeItem(index)
    self:setNodeBlink(entity, 0)
end

function CombatLayer:updateBuffer(entity)
    local bufferList = entity.bufferList
    local listView = nil
    if entity.side == "left" then
        listView = self.ListView_LeftBuffer
    else
        listView = self.ListView_RightBuffer
    end

    for name, bufferInfo in pairs(bufferList) do
        local btn = listView:getChildByName(name)
        if bufferInfo.round == 0 then
            bufferList[name] = nil
            local btn = listView:getChildByName(name)
            local index = listView:getIndex(btn)
            listView:removeItem(index)
            
            --log("remove buffer index "..name)
            --log("remove buffer "..bufferInfo.id.." at "..name)
        else
            bufferInfo.round = bufferInfo.round-1
            btn:getChildByName("AtlasLabel_Round"):setString(bufferInfo.round)
        end
    end
end

function CombatLayer:checkCanExit()
    local combatType = cp.getUserData("UserCombat"):getCombatType()
    --如果是錄像模式，可以直接跳過
    local mode = cp.getUserData("UserCombat"):getValue("Mode")
    if mode == 1 then
        return true
    end

    if combatType == 10 or combatType == 14 then
        return true
    end
    
    local round = tonumber(self.AtlasLabel_Round:getString())

    local limitCount, vip = cp.getUtils("DataUtils").GetSkipRound()
    if limitCount >= round then
        if vip == 0 then
            cp.getManager("ViewManager").gameTip(string.format("第%d回合可跳過，VIP用戶可縮短", limitCount+1))
        else
            cp.getManager("ViewManager").gameTip(string.format("第%d回合可跳過", limitCount+1))
        end
        return false
    end

    return true
end

function CombatLayer:onBtnClick(btn)
    local nodeName = btn:getName()
    if nodeName == "Button_Exit" then
        if not self:checkCanExit() then
            return
        end
        cp.CombatController:setCombatFinish()
        cp.getManager("EventManager"):dispatchEvent("VIEW", cp.getConst("EventConst").combat_finish)
    elseif nodeName == "Button_Comment" then
        self.Image_Comment:setVisible(not self.Image_Comment:isVisible())
    end
end

function CombatLayer:onEnterScene()
    cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_battle_scene_1,true)
end

function CombatLayer:onExitScene()
    --self:unscheduleUpdate()
end

function CombatLayer:runStageStart(stage, runTime)
    local posX = self.dynamic:getPositionX()
    local posY = self.dynamic:getPositionY()
    self.ListView_LeftBuffer:removeAllItems()
    self.ListView_RightBuffer:removeAllItems()
	cp.getManager("AudioManager"):playEffect("model/walk_01.mp3", true)
    self.dynamic:runAction(cc.Sequence:create(
        cc.MoveTo:create(runTime, cc.p(posX-720, posY)),
        cc.CallFunc:create(function()
            cp.getManager("AudioManager"):stopEffect("model/walk_01.mp3")
			cp.CombatController:initStage(stage)
            self:runStageFinish(stage)
        end)
    ))
end

function CombatLayer:runStageFinish(stage)
    if stage == cp.CombatController:getMaxStage() then
        return
    end

    local maxStage = self.sceneConfig:getValue("MaxStage")
    local lastStageIndex = (stage-2)%maxStage

    local yjNode = self["yj_loop_"..lastStageIndex]
    local posX = yjNode:getPositionX() + (720-1)*maxStage
    yjNode:setPositionX(posX)

    local zjNode = self["zj_loop_"..lastStageIndex]
    local posX = zjNode:getPositionX() + (720-1)*maxStage
    zjNode:setPositionX(posX)
end

function CombatLayer:showGameStory(gameStoryList)
    --[[參數說明
        gameStoryList = {
            [1] = {
			duration=2,
			name="[player]",
			head="img/bust/xx.png",
			pos = 10, 
			text="你是誰？"
		},
        [2] = {
                duration=2,
                name="神祕僧人",
                head="img/bust/xx.png",
                pos = 700,
                text="哈哈哈哈哈哈！"
            },
        }
    ]]

    if gameStoryList == nil or table.nums(gameStoryList) == 0 then
		return
	end
	self.gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(gameStoryList)
	
	local function finishCallBack()
		self.gamePopTalk:removeFromParent()
        cp.CombatController:setState(CombatConst.CombatState_StartStage)
	end
	self.gamePopTalk:setFinishedCallBack(finishCallBack)

    self:addChild(self.gamePopTalk,3)
    self.gamePopTalk:setName("gamePopTalk")
	self.gamePopTalk:setPosition(cc.p(display.width/2,0))
end

--flag 1加聚氣，-1減聚氣,0不加不減
function CombatLayer:setNodeBlink(entity, flag)
    local node = nil
    local bar = nil
    if entity.side == "left" then
        node = self.Node_LeftBlink
        bar = self.LoadingBar_Qi_L
    else
        node = self.Node_RightBlink
        bar = self.LoadingBar_Qi_R
    end

    bar:setOpacity(255)
    node:stopAllActions()
    if flag == 0 then
        if entity:getElemStatus(8) < 0 then
            --bar:setColor(cc.c4b(255,0,0,255))
            bar:loadTexture("img/bg/bg_common/module03_battle_blood04.png")--, ccui.TextureResType.plistType)
            cp.getManager("ViewManager").setShader(entity.model, "SlowSpine")
        elseif entity:getElemStatus(8) == 0 then
            bar:loadTexture("img/bg/bg_common/module03_battle_blood02.png")--, ccui.TextureResType.plistType)
            cp.getManager("ViewManager").setShader(entity.model, "Origin")
            cp.getManager("ViewManager").setShader(bar, nil)
            --bar:setColor(cc.c4b(255,255,255,255))
            return
        else
            bar:loadTexture("img/bg/bg_common/module03_battle_blood05.png")--, ccui.TextureResType.plistType)
            cp.getManager("ViewManager").setShader(entity.model, "FastSpine")
            --bar:setColor(cc.c4b(0,255,0,255))
        end
    elseif flag == 1 then
        bar:loadTexture("img/bg/bg_common/module03_battle_blood05.png")--, ccui.TextureResType.plistType)
        cp.getManager("ViewManager").setShader(entity.model, "FastSpine")
        --bar:setColor(cc.c4b(0,255,0,255))
    elseif flag == -1 then
        bar:loadTexture("img/bg/bg_common/module03_battle_blood04.png")--, ccui.TextureResType.plistType)
        cp.getManager("ViewManager").setShader(entity.model, "SlowSpine")
        --bar:setColor(cc.c4b(255,0,0,255))
    end

    --cp.getManager("ViewManager").setShader(bar, "Fluor")

    local min = 150
    local max = 255
    local dtValue = (min-max)/(0.2*40)
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/40), cc.CallFunc:create(function()
        local alpha = bar:getOpacity()
        if dtValue < 0 then
            if alpha + dtValue <= min then
                bar:setOpacity(min)
                dtValue = -dtValue
            else
                bar:setOpacity(alpha+dtValue)
            end
        else
            if alpha + dtValue >= max then
                bar:setOpacity(max)
                dtValue = -dtValue
                if flag ~= 0 then
                    self:setNodeBlink(entity, 0)
                end
            else
                bar:setOpacity(alpha+dtValue)
            end
        end
    end))))
end

return CombatLayer
