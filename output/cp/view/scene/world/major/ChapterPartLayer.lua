local BLayer = require "cp.view.ui.base.BLayer"
local ChapterPartLayer = class("ChapterPartLayer", BLayer)

function ChapterPartLayer:getNextID()
    local partID = 1000 
    if self.hard_level == 0 then
        partID = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
    else
        partID = cp.getUserData("UserCombat"):getValue("hard_chapter_part_id")
    end

    partID = partID + 1
    local partInfo = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", partID)
    if partInfo == nil then
        self.chapter = math.floor(partID/1000) + 1
        local chapterConfig = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", self.chapter*1000)
        if chapterConfig == nil then
            self.chapter = self.chapter - 1
            self.part = partID%1000 - 1
        else
            self.part = 1
        end
    else
        self.chapter = math.floor(partID/1000)
        self.part = partID%1000
    end
end

function ChapterPartLayer:create(open_info)
    open_info = open_info or {}
    local scene = ChapterPartLayer.new()
    scene.hard_level = 0  --困難模式(0:容易 1:困難)
    scene.combat_type = cp.getConst("CombatConst").CombatType_Story --戰鬥類型，(1為章節模式 2善惡事件模式 3祕境副本模式)
    if not open_info.data then
        scene:getNextID()
        scene.autoScroll = true
    else
        scene.chapter = open_info.data.chapter or 1
        scene.part = open_info.data.part or 1 
    end
    scene.sizeX = 168
    scene.deltaX = 20
    return scene
end

function ChapterPartLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").on_combat_finished] = function(data)
            if self.autoScroll then
                self:getNextID()
                self:updatePartListView()
            end
        end,
		[cp.getConst("EventConst").on_cache_ui_visible_state_changed] = function(evt)
			self:removeFromParent()
		end,

        [cp.getConst("EventConst").check_layer_visible] = function(evt)
            if evt.guide_name == "lottery" or evt.guide_name == "mail" then
                evt.ret = evt.ret + 1
            end
        end,

        --新手指引點擊目標點
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "ChapterPartLayer" then
                if "story_part_1" == evt.target_name then
                    local openInfo = {id = 1001, combat_type = self.combat_type, hard_level = 0}
                    self:openChallengeUI(openInfo) 
                elseif "story_part_2" == evt.target_name then
                    local openInfo = {id = 1002, combat_type = self.combat_type, hard_level = 0}
                    self:openChallengeUI(openInfo)
                elseif "story_part_3" == evt.target_name then
                    local openInfo = {id = 1003, combat_type = self.combat_type, hard_level = 0}
                    self:openChallengeUI(openInfo) 
                elseif evt.target_name == "story_part_4" then
                    local openInfo = {id = 1004, combat_type = self.combat_type, hard_level = 0}
                    self:openChallengeUI(openInfo)
                end
			end
        end,

        [cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "ChapterPartLayer" then
                if evt.target_name == "story_part_1" then
                    local boundbingBox = self.PartList[1]:getBoundingBox()
                    local pos = self.PartList[1]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                elseif evt.target_name == "story_part_2" then
                    local boundbingBox = self.PartList[2]:getBoundingBox()
                    local pos = self.PartList[2]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                elseif evt.target_name == "story_part_3" then
                    local boundbingBox = self.PartList[3]:getBoundingBox()
                    local pos = self.PartList[3]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                elseif evt.target_name == "story_part_4" then
                    local boundbingBox = self.PartList[4]:getBoundingBox()
                    local pos = self.PartList[4]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                    
                    local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
                    evt.ret = finger_info
                end
			end
		end
        
    }
end

function ChapterPartLayer:getPartByPosX(posX, posY)
    local begin = self.ScrollView_Part:getPositionX()
    posX = posX - begin + math.abs(self.ScrollView_Part:getInnerContainerPosition().x)
    local index = math.ceil(posX / (self.sizeX + self.deltaX))
    local partView = self.PartList[index]
    if math.abs(posX - partView:getPositionX()) > self.sizeX/2 then
        return 0
    end

    return index
end

function ChapterPartLayer:onInitView(openInfo)
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_major/chapter_and_part.csb")
    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Image_bg.Image_1"] = {name = "Image_1"},
        ["Panel_root.Image_bg.Image_2"] = {name = "Image_2"},
        ["Panel_root.Image_bg.ScrollView_Part"] = {name = "ScrollView_Part"},
        ["Panel_root.Image_bg.ScrollView_Part.Image_Part"] = {name = "Image_Part"},
        ["Panel_root.Image_bg.Text_Chapter"] = {name = "Text_Chapter"},
        ["Panel_root.Image_bg.Button_PrevChapter"] = {name = "Button_PrevChapter", click="onBtnClick"},
        ["Panel_root.Image_bg.Button_NextChapter"] = {name = "Button_NextChapter", click="onBtnClick"},
        ["Panel_root.Image_bg.Button_Back"] = {name = "Button_Back", click="onBtnClick"},
        ["Panel_root.Image_bg.Button_Difficulty"] = {name = "Button_Difficulty", click="onBtnClick"},
        ["Panel_root.Image_bg.Button_Story"] = {name = "Button_Story",click="onBtnClick"},

        ["Panel_root.Panel_Story"] = {name = "Panel_Story",click="onBtnClick",clickScale = 1},
        ["Panel_root.Panel_Story.Image_Story.Button_close"] = {name = "Button_close",click="onBtnClick"},
        ["Panel_root.Panel_Story.Image_Story.Text_title"] = {name = "Text_title"},
        ["Panel_root.Panel_Story.Image_Story.ScrollView_1"] = {name = "ScrollView_1"},
        ["Panel_root.Panel_Story.Image_Story.ScrollView_1.Text_content"] = {name = "Text_content"}
        
    }
    cp.getManager("ViewManager").setCSNodeBinding(self, self.rootView, childConfig)
	self.Panel_root:onTouch(function(event)
		if event.name == "ended" then
            if self.closeCallback then
                self.closeCallback()
            end
			self:removeFromParent()
		end
	end)
    
    self.Panel_Story:setVisible(false)
    self.Image_Part:setVisible(false)
    self.ScrollView_Part:setScrollBarEnabled(false)
    self.PartList = {}

    self.rootView:setContentSize(display.size)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
    ccui.Helper:doLayout(self.rootView)
    self:setupAchivementGuide()
end

function ChapterPartLayer:setupAchivementGuide()
    local guideType = cp.getUserData("UserAchivement"):getValue("GuideType")
    if not guideType then return end
    local guideBtn = nil
    if guideType == 39 then
        guideBtn = self.Button_Difficulty
        cp.getUserData("UserAchivement"):setValue("GuideType", nil)
    else
        return
    end

    local guideLayer = cp.getManager("ViewManager").openGuideLayer(self, guideBtn, 0.2)
    guideLayer:setTouchCallback(function()
        guideLayer:removeFromParent()
    end)
end

function ChapterPartLayer:onBtnClick(btn)
    local btnName = btn:getName()
    if btnName == "Button_PrevChapter" then
        if self.chapter == 1 then
            return
        end
    
        self.chapter = self.chapter - 1
        self.part = 1
        self:updatePartListView()
    elseif btnName == "Button_NextChapter" then
        local chapter = self.chapter + 1
        local chapterConfig = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", chapter*1000)
        if chapterConfig then
            self.chapter = self.chapter + 1
            self.part = 1
            self:updatePartListView()
        end
    elseif btnName == "Button_Back" then
        -- self:dispatchViewEvent(cp.getConst("EventConst").game_world_to_return_module)
        self:removeFromParent()
    elseif btnName == "Button_Difficulty" then
        if self.hard_level ~= 0 then
            self.hard_level = 0
            local partID = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
            self.part = partID%1000
            self.chapter = math.floor(partID/1000)
            self.Button_Difficulty:loadTextures("ui_story_module08__jqfb_4.png",
                "ui_story_module08__jqfb_5.png", "ui_story_module08__jqfb_5.png", ccui.TextureResType.plistType)
        else
            local partID = cp.getUserData("UserCombat"):getValue("hard_chapter_part_id")
            self.part = partID%1000
            self.chapter = math.floor(partID/1000)
            self.hard_level = 1
            self.Button_Difficulty:loadTextures("ui_story_module08__jqfb_3.png",
                "ui_story_module08__jqfb_6.png", "ui_story_module08__jqfb_6.png", ccui.TextureResType.plistType)
        end 

        if self.part == 0 then
            self.part = 1
        end
        self:updatePartListView()
    elseif btnName == "Button_Story" then

        local partID = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
        local part = partID%1000
        local chapter = math.floor(partID / 1000)
        local maxPart = getChapterMaxPart(chapter)
        if self.chapter > chapter or (self.chapter == chapter and part < maxPart) then
            cp.getManager("ViewManager").gameTip("您還未通關本章劇情。")
            return
        end

        self.Panel_Story:setVisible(true)
        self:initChapterStory(self.chapter)
    elseif btnName == "Button_close" then
        self.Panel_Story:setVisible(false)
    end
end

function getLastChapterPart(id)
    if id == 1000 or id == 1001 then
        return 1000
    end 

    local part = id % 1000
    local chapter = math.floor(id / 1000)

    if part == 1 then
        local maxPart = getChapterMaxPart(chapter - 1)
        return (chapter-1)*1000 + maxPart
    end

    return id - 1
end

function getChapterMaxPart(chapter)
    local part = 0
    cp.getManager("ConfigManager").getItemList("GameChapterPart", "ID", function(id)
        if math.floor(id / 1000) == chapter and part < id % 1000 then
            part = id % 1000
        end
        return true 
    end)

    return part
end

function checkCanChallenge(id, difficulty)
    local lastPartID = getLastChapterPart(id)
    local normal_id = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
    local hard_id = cp.getUserData("UserCombat"):getValue("hard_chapter_part_id")
    if difficulty == 1 then
        if hard_id < lastPartID then
            return false
        end 

        local chapter = math.floor(id / 1000)
        local maxPart = getChapterMaxPart(chapter)
        if normal_id < chapter*1000+maxPart then
            return false
        end
    else
        if normal_id < lastPartID then
            return false
        end
    end

    return true
end

function ChapterPartLayer:scrollToPart(part, bScroll)
    if part <= 0 then
        part = 1
    end
    local innerWidth = self.ScrollView_Part:getInnerContainerSize().width
    local innerHeight = self.ScrollView_Part:getInnerContainerSize().height
    local posX = (part-1)*(self.sizeX+self.deltaX)
    local width = self.ScrollView_Part:getSize().width
    local percent = 0
    if innerWidth > width then
        percent = posX*100/(innerWidth - width)
    end

    if percent > 100 then
        percent = 100
    end
    if bScroll then
        self.ScrollView_Part:scrollToPercentHorizontal(percent, 1, false)
    else
        self.ScrollView_Part:jumpToPercentHorizontal(percent)
    end
end

function ChapterPartLayer:showSpecialItem(str, partView)
    local imgSpecial = partView:getChildByName("Image_Special")
    local itemList = cp.getUtils("DataUtils").split(str, ";:")
    local itemEntry = nil
    for _, itemInfo in ipairs(itemList) do
        itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo[2])
        if itemInfo[2] == 614 or itemInfo[2] == 1467 then
            break
        else
            if itemEntry:getValue("Type") == 2 and itemEntry:getValue("SubType") == 1 then
                break
            end
        end

        itemEntry = nil
    end

    if itemEntry then
        local imgItem = imgSpecial:getChildByName("Image_Item")
        imgSpecial:setVisible(true)
        imgItem:loadTexture(itemEntry:getValue("Icon"))
        imgItem:setSize(cc.size(80, 80))
    else
        imgSpecial:setVisible(false)
    end
    return
end

function ChapterPartLayer:updatePartListView()
    self.partConfigList = cp.getManager("GDataManager"):getChapterPartList(self.chapter)
    local width = (#self.partConfigList-1)*self.sizeX + (#self.partConfigList-2)*self.deltaX
    self.ScrollView_Part:setInnerContainerSize(cc.size(width, 892))

    self.Text_Chapter:setString(self.partConfigList[1]:getValue("Name"))
    table.arrShift(self.partConfigList)
    for i, partConfig in ipairs(self.partConfigList) do
        local part = partConfig:getValue("Part")
        local id = partConfig:getValue("ID")
        local posX = 84+(self.sizeX+self.deltaX)*(part-1)

        local partView = self.PartList[i]
        if not partView then
            partView = self.Image_Part:clone()
            self.ScrollView_Part:addChild(partView, 100)
            partView:setPosition(cc.p(posX, 320))
            self.PartList[i] = partView
        end

        if self.hard_level == 0 then
            self:showSpecialItem(partConfig:getValue("NormalReward"), partView)
        else
            self:showSpecialItem(partConfig:getValue("HardReward"), partView)
        end

        partView:setVisible(true)
        local textureName = "img/bg/bg_story/"..partConfig:getValue("BackGround")
        partView:loadTexture(textureName)
        local imgFlag = partView:getChildByName("Image_Flag")
        local btnBox = partView:getChildByName("Button_Box")
        local txtPart = partView:getChildByName("Text_Part")
        local txtTittle = partView:getChildByName("Text_Tittle")
        txtPart:setString("第"..cp.getUtils("DataUtils").formatZh_CN(part).."話")
        txtTittle:setString(partConfig:getValue("Name"))
        if self.hard_level == 0 then
            local textureName = "ui_story_module08__jqfb_diban03.png"
            btnBox:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        else
            local textureName = "ui_story_module08__jqfb_diban04.png"
            btnBox:loadTextures(textureName, textureName, textureName, ccui.TextureResType.plistType)
        end

        if not checkCanChallenge(id,self.hard_level) then
            imgFlag:setVisible(true)
            partView:setColor(cc.c3b(100,100,100))
        else
            imgFlag:setVisible(false)
            partView:setColor(cc.c3b(255,255,255))
        end

        cp.getManager("ViewManager").initButton(btnBox, function()
            local openInfo = {id = self.chapter*1000 + part, combat_type = self.combat_type, hard_level = self.hard_level}
            if self.hard_level == 0 then
                local partID = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
                if self.chapter*1000 + part <= partID then
                    self.autoScroll = false
                else
                    self.autoScroll = true
                end
            else
                local partID = cp.getUserData("UserCombat"):getValue("hard_chapter_part_id")
                if self.chapter*1000 + part <= partID then
                    self.autoScroll = false
                else
                    self.autoScroll = true
                end
            end
            self:openChallengeUI(openInfo) 
        end, 1.0)
    end

    for i=#self.partConfigList+1, #self.PartList do
        if self.PartList[i] then
            self.PartList[i]:setVisible(false)
        end
    end

    if self.hard_level == 0 then
        self.Button_Difficulty:loadTextures("ui_story_module08__jqfb_4.png",
            "ui_story_module08__jqfb_5.png", "ui_story_module08__jqfb_5.png", ccui.TextureResType.plistType)
        self.Image_bg:loadTexture("img/bg/bg_common/module09__tzjm_putongbeijing01.png", ccui.TextureResType.localType)
        self.Image_1:loadTexture("ui_story_module09__tzjm_putongbeijing02.png", ccui.TextureResType.plistType)
        self.Image_2:loadTexture("ui_story_module09__tzjm_putongbeijing03.png", ccui.TextureResType.plistType)
    else
        self.Button_Difficulty:loadTextures("ui_story_module08__jqfb_3.png",
            "ui_story_module08__jqfb_6.png", "ui_story_module08__jqfb_6.png", ccui.TextureResType.plistType)
        self.Image_bg:loadTexture("img/bg/bg_common/module09__tzjm_kunnanbeijing01.png", ccui.TextureResType.localType)
        self.Image_1:loadTexture("ui_story_module09__tzjm_kunnanbeijing03.png", ccui.TextureResType.plistType)
        self.Image_2:loadTexture("ui_story_module09__tzjm_kunnanbeijing02.png", ccui.TextureResType.plistType)
    end

    self:scrollToPart(self.part - 1, false)
end

function ChapterPartLayer:onEnterScene()
    cp.getManager("AudioManager"):playMusic(cp.getManualConfig("AudioConfig").bg_chose_tollgate,true)
    if self.autoScroll then
        self:getNextID()
        self:updatePartListView()
    end


    local needGuid = false
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
    if (cur_guide_module_name == "story" and cur_step == 5) or 
        (cur_guide_module_name == "character" and cur_step == 23) or
        (cur_guide_module_name == "wuxue_use" and cur_step == 12) or
        (cur_guide_module_name == "wuxue_pos_change" and cur_step == 10) or
        (cur_guide_module_name == "equip" and cur_step == 34) then
        needGuid = true

        if cur_guide_module_name == "story" then
            local partID = cp.getUserData("UserCombat"):getValue("normal_chapter_part_id")
            if partID == 1001 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",9) 
                cp.getGameData("GameNewGuide"):setValue("step_skip_mode",1) 
            elseif partID == 1002 then
                cp.getGameData("GameNewGuide"):setValue("cur_step",14) 
                cp.getGameData("GameNewGuide"):setValue("step_skip_mode",1)
            end
        end
    end
    if needGuid  then
        local sequence = {}
        table.insert(sequence, cc.DelayTime:create(0.3))
        table.insert(sequence,cc.CallFunc:create(function()
            
            local info = 
            {
                classname = "ChapterPartLayer",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end))
        self:runAction(cc.Sequence:create(sequence))
    end
end

function ChapterPartLayer:openChallengeUI(onpenInfo)
 
    local function closeCallBack(retStr)
        -- cp.getManager("ViewManager").removeChallengeStory()
        self.challengeStory:removeFromParent()
        self.challengeStory = nil
    end
    -- cp.getManager("ViewManager").showChallengeStory(onpenInfo.combat_type, onpenInfo.id, onpenInfo.hard_level,closeCallBack)

    local challengeStory = require("cp.view.scene.world.challenge.ChallengeStory"):create(onpenInfo.combat_type, onpenInfo.id, onpenInfo.hard_level)
    challengeStory:setCloseCallBack(closeCallBack)
    self:addChild(challengeStory,1)
    self.challengeStory = challengeStory
end

function ChapterPartLayer:gotoComBat()
    if self.scrollViewListener then
        self.ScrollView_Part:removeEventListener(self.scrollViewListener)
    end
    if self.clickScrollViewListener then
        self.ScrollView_Part:removeClickEventListener(self.clickScrollViewListener)
    end

    cp.getManager("ViewManager"):pushScene(cp.getConst("SceneConst").SCENE_COMBAT)
end

function ChapterPartLayer:initChapterStory(chapter)
    if display.height <= 960 then
        self.Image_Story:setPositionPercent(cc.p(0.5,0.54))
    end
    
    local sz = self.ScrollView_1:getContentSize()
    local path = cc.FileUtils:getInstance():fullPathForFilename("xml/fullStory/chapter".. tostring(chapter) .. ".txt")
    if not cc.FileUtils:getInstance():isFileExist(path ) then
        self.Text_title:setString("")
        self.Text_content:setString("")
        return
    end

    self.Text_title:setString("第".. cp.getConst("CombatConst").NumberZh_Cn[chapter] .. "章")

    local str =  cc.FileUtils:getInstance():getStringFromFile(path)

    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if string.find(str,"（師兄姐）") then 
		if majorRole.gender == 0 then
			str = string.gsub(str,"（師兄姐）", majorRole.career == 0  and "師兄" or "師姐")
		elseif majorRole.gender == 1 then
			str = string.gsub(str,"（師兄姐）", majorRole.career == 3  and "師姐" or "師兄")
		end
    end
    
    self.Text_content:setContentSize((sz.width-20)*self.Text_content.clearScale,0)
    local ss = self.Text_content:getContentSize()    
    self.Text_content:setString(str)
    
    self.Text_content:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
    local sz2 = self.Text_content:getVirtualRendererSize()
    self.Text_content:setContentSize(math.max(ss.width,sz2.width),math.max(sz.height-20,sz2.height))

    local newHeight = math.max(sz.height,sz2.height/self.Text_content.clearScale+10)
    self.ScrollView_1:setInnerContainerSize(cc.size(sz.width, newHeight))
    self.Text_content:setPositionY(newHeight)
    self.ScrollView_1:setScrollBarEnabled(false)

    ccui.Helper:doLayout(self.rootView)
end

return ChapterPartLayer