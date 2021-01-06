local BLayer = require "cp.view.ui.base.BLayer"
local RiverBreakListLayer = class("RiverBreakListLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function RiverBreakListLayer:create(combatList)
    local layer = RiverBreakListLayer.new()
    layer.combatList = combatList
    layer:updateRiverBreakListView()
    return layer
end

function RiverBreakListLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").GetCombatDataRsp] = function(proto)
            cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
		end,
    }
end

function RiverBreakListLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_Close" then
        self:removeFromParent()
    end
end

--初始化界面，以及設定界面元素標籤
function RiverBreakListLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_shane/uicsb_shane_break_list.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick", clickScale=1},
        ["Panel_root.Image_1.ListView_Record"] = {name = "ListView_Record"},
        ["Panel_root.Image_1.Image_Model"] = {name = "Image_Model"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    
    self.ListView_Record:setScrollBarEnabled(false)
    self.Image_1:setPositionY(display.height/2)
    self.Image_Model:setVisible(false)
    ccui.Helper:doLayout(self["rootView"])
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function RiverBreakListLayer:updateOneView(img, combatInfo)
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local icon = img:getChildByName("Image_Icon")
    local name = img:getChildByName("Text_Name")
    local fight = img:getChildByName("Text_Fight")
    local event = img:getChildByName("Image_Event")
    local result = img:getChildByName("Image_Result")
    local button = img:getChildByName("Button_Fight")

    local isWin = false
    if major_roleAtt.account == combatInfo.uid1 and combatInfo.combat_result == 1 then
        isWin = true
    elseif major_roleAtt.account == combatInfo.uid2 and combatInfo.combat_result ~= 1 then
        isWin = true
    end

    if isWin then
        result:loadTexture("ui_mapbuild_module6_jianghushi_win.png",ccui.TextureResType.plistType)
    else
        result:loadTexture("ui_mapbuild_module6_jianghushi_lose.png",ccui.TextureResType.plistType)
    end

    if major_roleAtt.account ~= combatInfo.uid1 then --不是進攻方
        name:setString(combatInfo.name1)
        fight:setString("戰力  "..combatInfo.fight1)
        icon:loadTexture(cp.DataUtils.getModelFace(combatInfo.face1))
        event:loadTexture("ui_mapbuild_module6_jianghushi_fangshou02.png",ccui.TextureResType.plistType)
    else
        name:setString(combatInfo.name2)
        fight:setString("戰力  "..combatInfo.fight2)
        icon:loadTexture(cp.DataUtils.getModelFace(combatInfo.face2))
        event:loadTexture("ui_mapbuild_module6_jianghushi_jingong02.png",ccui.TextureResType.plistType)
    end

    cp.getManager("ViewManager").initButton(button, function()
        local req = {}
        req.combat_id = combatInfo.combat_id
        self:doSendSocket(cp.getConst("ProtoConst").GetCombatDataReq, req)
    end, 0.9)

    --[[
    for i=1, 6 do
        local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", combatInfo.Skill[i])
        local btn = img:getChildByName("Button_Skill"..i)
        local icon = btn:getChildByName("Image_Icon")
        icon:loadTexture(skillEntry:getValue("Icon"))
        local textureName = CombatConst.SkillBoxList[skillEntry:getValue("Colour")]
        btn:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        cp.getManager("ViewManager").initButton(btn, function()
            if not skillEntry or skillEntry:getValue("SkillType") == 2 or skillEntry:getValue("SkillType") == 3 then
                return
            end
            local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(skillEntry)
            self:addChild(layer, 100)
        end)
    end
    ]]
end

function RiverBreakListLayer:updateRiverBreakListView()
    for i, combatInfo in ipairs(self.combatList) do
        local button = self.ListView_Record:getItem(i-1)
        if not button then
            button = self.Image_Model:clone()
            self.ListView_Record:pushBackCustomItem(button)
        end

        self:updateOneView(button, combatInfo)
        button:setVisible(true)
    end

    for i=#self.combatList, self.ListView_Record:getChildrenCount()-1 do
        self.ListView_Record:removeItem(i)
    end
end

function RiverBreakListLayer:onEnterScene()
end

function RiverBreakListLayer:onExitScene()
    self:unscheduleUpdate()
end

return RiverBreakListLayer