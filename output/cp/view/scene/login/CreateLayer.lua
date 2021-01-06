local BLayer = require "cp.view.ui.base.BLayer"
local CreateLayer = class("CreateLayer",BLayer)

function CreateLayer:create()
    local layer = CreateLayer.new()
    return layer
end

function CreateLayer:initListEvent()
    self.listListeners = {
    }

end

function CreateLayer:onInitView(openInfo)

    local csbName = "rolecreate_1280.csb"
    if display.size.height > 1280 then
        csbName = "rolecreate_1440.csb"
    elseif display.size.height > 1080 then
        csbName = "rolecreate_1280.csb"
    elseif display.size.height > 960 then
        csbName = "rolecreate_1080.csb"
    else
        csbName = "rolecreate_960.csb"
    end

    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_login/" .. csbName) 

    self:addChild(self.rootView)

    local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Panel_1"] = {name = "Panel_1"},
        ["Panel_root.Panel_1.Image_role_bg"] = {name = "Image_role_bg"},
        ["Panel_root.Panel_1.Image_role_bg.Text_descrip"] = {name = "Text_descrip"}, 
        ["Panel_root.Panel_1.Image_role_bg.Image_role_bottom.Node_role"] = {name = "Node_role"},  
        ["Panel_root.Panel_1.Image_title"] = {name = "Image_title"},
        ["Panel_root.Panel_1.Image_title.Text_menpai"] = {name = "Text_menpai"},  
        ["Panel_root.Panel_1.Image_title.Image_role_head"] = {name = "Image_role_head"},  
        ["Panel_root.Panel_1.Image_title.Button_change"] = {name = "Button_change",click = "onChangeHeadClicked"},

        ["Panel_root.Panel_1.Node_menpai_root"] = {name = "Node_menpai_root"},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_0"] = {name = "Panel_menpai_0", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_1"] = {name = "Panel_menpai_1", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_2"] = {name = "Panel_menpai_2", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_3"] = {name = "Panel_menpai_3", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_4"] = {name = "Panel_menpai_4", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_5"] = {name = "Panel_menpai_5", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_6"] = {name = "Panel_menpai_6", click = "onSelectmenpai", clickScale = 1},  
        ["Panel_root.Panel_1.Node_menpai_root.Panel_menpai_7"] = {name = "Panel_menpai_7", click = "onSelectmenpai", clickScale = 1},  
        
        ["Panel_root.Panel_1.Image_yaoqingma_bg"] = {name = "Image_yaoqingma_bg"},
        ["Panel_root.Panel_1.Image_yaoqingma_bg.TextField_yaoqingma"] = {name = "TextField_yaoqingma"}, 
        ["Panel_root.Panel_1.Image_getName_bg"] = {name = "Image_getName_bg"}, 
        ["Panel_root.Panel_1.Image_getName_bg.TextField_name"] = {name = "TextField_name"}, 
        ["Panel_root.Panel_1.Image_getName_bg.Image_getName"] = {name = "Image_getName", click = "onGetRandomNameClick"},  
        ["Panel_root.Panel_1.Image_sex_1"] = {name = "Image_sex_1", click = "onSexButtonClick", clickScale = 1},  
        ["Panel_root.Panel_1.Image_sex_2"] = {name = "Image_sex_2", click = "onSexButtonClick", clickScale = 1},  
        ["Panel_root.Panel_1.Button_back"] = {name = "Button_back", click = "onBackButtonClick"},  
        ["Panel_root.Panel_1.Button_create"] = {name = "Button_create", click = "onCreateButtonClick"},

        ["Panel_root.Panel_1.Button_1"] = {name = "Button_1", click = "onSkipButtonClick"},
        
    }
    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    
    self.TextField_yaoqingma:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.TextField_name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)


    cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_name,"nameInputBox",nil)
    -- cp.getManager("ViewManager").addTextFieldEvent(self.rootView,self.TextField_yaoqingma,"yaoqingmaInputBox",nil)
    self.Image_yaoqingma_bg:setVisible(false)

    self.posY1 = self.Image_yaoqingma_bg:getPositionY()
    self.posY2 = self.Image_getName_bg:getPositionY()

    --分辨率適配
    self:adapterReslution()

    self.Button_1:setVisible(true)
   
end

function CreateLayer:onChangeHeadClicked(sender)
    local openInfo = {type = "create",face = self.face,gender=self.gender}
    local PlayerHeadChangeUI = require("cp.view.ui.messagebox.PlayerHeadChangeUI"):create(openInfo)
    PlayerHeadChangeUI:setCloseCallBack(function (faceID)
        if self.face ~= faceID then
            self.face = faceID
            self.Image_role_head:loadTexture("img/model/head/" .. self.face .. ".png", UI_TEX_TYPE_LOCAL)
        end
    end)
    self:addChild(PlayerHeadChangeUI,1)
end


function CreateLayer:onSkipButtonClick(sender)
    cp.getUserData("UserLogin"):setValue("skip_guide",true)
end

--分辨率適配
function CreateLayer:adapterReslution() 
    self.rootView:setContentSize(display.size)
    self["Panel_root"]:setContentSize(display.size)
    -- self["Panel_1"]:setContentSize(display.size)
    cp.getManager("ViewManager").addModalByDefaultImage(self)

--[[
    local index = 1 
    if display.size.height > 1280 then
        index = 4
    elseif display.size.height > 1080 then
        index = 3
    elseif display.size.height > 960 then
        index = 2   
    else
        index = 1
    end

    local posList = {
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(503,767), cc.p()},
        ["Image_title"] = {cc.p(), cc.p(), cc.p(368,1184), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
        ["Image_role_bg"] = {cc.p(), cc.p(), cc.p(), cc.p()},
    }
   
    for name,values in pairs(posList) do
        self[name]:setPosition(values[index])
    end
]]
    ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
end


function CreateLayer:initRoleData()
    local modelId = cp.getManager("GDataManager"):getModelId(self.career,self.gender)
    if modelId ~= nil and modelId > 0 then
        self:refreshRoleModel(modelId,self.career)  
    end
    cp.getManager("AudioManager"):stopAllEffects()
    cp.getManager("AudioManager"):playEffect("menpai/menpai_" .. tostring(self.career) .. "_" .. tostring(self.gender) .. ".mp3" )
end

function CreateLayer:refreshMenPaiInfo()
    for i=0,7 do
        local pic = i == self.career and self.createInfo[i].namePic[1] or self.createInfo[i].namePic[2]
        self["Panel_menpai_" .. tostring(i)]:getChildByName("Image_meinpai"):loadTexture(pic, UI_TEX_TYPE_PLIST)
        local pic2 = i == self.career and "ui_create_module02_role_touxiangbox2.png" or "ui_create_module02_role_touxiangbox1.png"
        self["Panel_menpai_" .. tostring(i)]:setBackGroundImage(pic2,UI_TEX_TYPE_PLIST)
    end
    
    local careerDescrip = {
        [[「 萬裡西來坐少林，燈燈相續至如今 」
        
        被尊為天下宗門的少林，向以匡扶正義、拯救蒼生為己任，因此威望極高。]],
        [[「 雲龍風虎正經綸，長嘯歸山作道人 」
        
        門派武學講究以靜制動，後發先制，含陰陽動靜之機，具造化玄微之妙。]],
        [[「 笑對人間滄桑事，看盡世態道炎涼 」
        
        丐幫中人遍佈天下，天性逍遙自在，放歌縱酒與熱血義氣，向來缺一不可。]],
        [[「 萬裡峨眉夜夜月，千秋巫峽朝朝雲 」
        
        峨眉武學，在於亦剛亦柔，以巧取勝；如芝蘭玉樹，姿態優美，令人目眩神迷。]],
        [[「 狂呼酒盞稱英雄，醉拭刀芒氣如虹 」
        
        雁北之地的蒼涼鑄就了霸刀門人的血性，他們就如一柄出鞘刀，凜冽而無情。]],
        [[「 鷹擊長空逐北雁， 梅花三弄折梅巔 」
        
        天山派位於終年積雪的極寒之地，其神鬼莫測的武學，總令敵人心驚膽寒。]],
        [[「 熊熊聖火掩風月，堂堂虎陣滿旌旗 」
        
        明教中人旨在行善去惡，拯救世人，卻因行事詭祕遭受誤解，被視之為魔。]],
        [[「 毒霧漲天橫沴氣，落星浮海散寒芒 」
        
        詭異的施毒之術，殺人於無形之中，使得五毒教成為武林人士心口的毒刺。]],
    }
    self.Text_descrip:setString(careerDescrip[self.career+1])
end

function CreateLayer:onEnterScene()
    
    self.createInfo = {
        [0] = {weapon="club",namePic={"ui_create_module02_role_shaolin02.png","ui_create_module02_role_shaolin03.png"}},
        [1] = {weapon="blade",namePic={"ui_create_module02_role_wudang02.png","ui_create_module02_role_wudang03.png"}},
        [2] = {weapon="club",namePic={"ui_create_module02_role_gaibang02.png","ui_create_module02_role_gaibang03.png"}},
        [3] = {weapon="blade",namePic={"ui_create_module02_role_emei02.png","ui_create_module02_role_emei03.png"}},
        [4] = {weapon="knife",namePic={"ui_create_module02_role_badao02.png","ui_create_module02_role_badao03.png"}},
        [5] = {weapon="blade",namePic={"ui_create_module02_role_tianshan02.png","ui_create_module02_role_tianshan03.png"}},
        [6] = {weapon="knife",namePic={"ui_create_module02_role_mingjiao02.png","ui_create_module02_role_mingjiao03.png"}},
        [7] = {weapon="dagger",namePic={"ui_create_module02_role_wudu02.png","ui_create_module02_role_wudu03.png"}},
    }

    for i=0,1 do
        for j=0,7 do
            local fileName = "audio/menpai/menpai_" .. tostring(j) .. "_" .. tostring(i) .. ".mp3"
            if cc.FileUtils:getInstance():isFileExist(fileName) then
                cc.SimpleAudioEngine:getInstance():preloadEffect(fileName)
            end
        end
    end

    self.randomNameStrList = {} 
    
    self.career = 0 -- 0~7
    self.gender = 0 -- 0~1

    self.face = cp.getManager("GDataManager"):getRoleCreateFace(self.career,self.gender)
    self.Image_role_head:loadTexture("img/model/head/" .. self.face .. ".png", UI_TEX_TYPE_LOCAL)

    self:refreshMenPaiInfo()
    self:initRoleData()

    self:onGetRandomNameClick(nil)
    self:refreshGenderButton()
end

function CreateLayer:onSelectmenpai(sender)
    local senderName = sender:getName()
    local idx = tonumber(string.sub(senderName,string.len("Panel_menpai_")+1))
    log("select menpai idx = " .. tostring(idx))
    --if idx == 1 or idx == 5 then
        --self.career = idx
        --self:refreshRoleModel(1,idx)
        --self:refreshMenPaiInfo()
        --cp.getManager("ViewManager").gameTip("此門派尚在開發中，暫未開放！")
        --return
    --end
    local old_career = self.career
    self.career = idx
    if old_career == idx then
        return
    end
    self:refreshMenPaiInfo(idx)
    local gender = 0
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",idx)
    local genderLimit = cfgItem:getValue("Limit")
    if genderLimit == 1 then
        gender = 0
    elseif genderLimit == 2 then
        gender = 1
    end
    if self.gender ~= gender then
        self:onGetRandomNameClick(nil)
        self.gender = gender
    end
    self.face = cp.getManager("GDataManager"):getRoleCreateFace(self.career,self.gender)
    self.Image_role_head:loadTexture("img/model/head/" .. self.face .. ".png", UI_TEX_TYPE_LOCAL)

    self:initRoleData()

    self:refreshGenderButton()
end

--切換性別
function CreateLayer:onSexButtonClick(sender)
    local name = sender:getName() 
    local career = self.career
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",career)
    local genderLimit = cfgItem:getValue("Limit")
    local old_gender = self.gender
    local new_gender = -1
    if name == "Image_sex_1" then
        if genderLimit ~= 1 then
            new_gender = 0
            self:setSexSelected(0)
        end
    else
        if genderLimit ~= 1 then
            new_gender = 1
            self:setSexSelected(1)
        end
    end
    if new_gender == old_gender then
        return
    end
    self.gender = new_gender
    log("select gender = " .. tostring(new_gender))

    self:initRoleData()
    self:onGetRandomNameClick(nil)
    self.face = cp.getManager("GDataManager"):getRoleCreateFace(career,new_gender)
    self.Image_role_head:loadTexture("img/model/head/" .. self.face .. ".png", UI_TEX_TYPE_LOCAL)
end

function CreateLayer:onCreateButtonClick(sender)
    --發送創建人物協議
     
    local name = self["TextField_name"]:getString() 
    if not self:checkNameMactchRules(name) then
        return
    end

    local yaoqingma = self["TextField_yaoqingma"]:getString()
    local lastAccount = cp.getManager("GDataManager"):getLastAccount()
    local req = {}
    req.account = lastAccount[1]
    req.name = name
    req.gender = self.gender
    req.career = self.career
    req.invite = yaoqingma
    req.face = self.face
    dump(req)
    self:doSendSocket(cp.getConst("ProtoConst").CreateReq, req)
end

function CreateLayer:checkNameMactchRules(name)
    if string.len(string.trim(name)) == 0 then
        cp.getManager("ViewManager").gameTip("名字不能為空")
        return false
    end
    if string.utf8len_m(string.trim(name)) > 6 then
        cp.getManager("ViewManager").gameTip("名字不能超過6個字符")
        return false
    end
    return true
end

function CreateLayer:setBackClickCallBack(cb)
    self.backCallBack = cb
end

function CreateLayer:onBackButtonClick(sender)
    if self.backCallBack ~= nil then
        self.backCallBack()
    end
end

function CreateLayer:refreshGenderButton()
    local career = self.career
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",career)
    local genderLimit = cfgItem:getValue("Limit")
    self.Text_menpai:setString(cfgItem:getValue("Name"))
    

    self["Image_sex_1"]:setTouchEnabled(true)
    self["Image_sex_2"]:setTouchEnabled(true)
    local gender = self.gender 
    if genderLimit == 1 then
        self:setSexSelected(0)
        self["Image_sex_2"]:setTouchEnabled(false)
    elseif genderLimit == 2 then
        self:setSexSelected(1)
        self["Image_sex_1"]:setTouchEnabled(false)
    else
        self:setSexSelected(gender)
    end
end

function CreateLayer:refreshRoleModel(id,career)
    local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", id)
    local modelFile = itemCfg:getValue("ModelFile")
    local weapon = itemCfg:getValue("DefaultWeapon") --itemCfg:getValue("DefaultWeapon")

    self.Node_role:removeAllChildren()
    local model = cp.getManager("ViewManager").createSpineAnimation(modelFile, weapon)
    
    model:setTag(id)
    model:setScale(1)
    self.Node_role:addChild(model)

    self.model = model

    self.model:setToSetupPose()
    self.model:setAnimation(0, "Into", false)
    self.model:addAnimation(0, "Stand", true)
    self.model:setMix("Stand", "Stand", 0.1)
    local aniType = 1
    self.model:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
        --播放勝利動作
        if aniType == 1 then
            self.model:setAnimation(0, "Win_start", false)
            self.model:addAnimation(0, "Win_loop", true)
        --播放拳掌動作
        elseif aniType == 2 then
            self.model:setAnimation(0, "Finger", false)
            self.model:addAnimation(0, "Stand", true)
        --播放內功動作
        elseif aniType == 3 then
            self.model:setAnimation(0, "Martial", false)
            self.model:addAnimation(0, "Stand", true)
        else
            local aniID = (aniType%4+1)
            local motionTag = "Attack"..aniID
            self.model:setAnimation(0, motionTag, false)
            self.model:addAnimation(0, "Stand", true)
            if aniID == 4 then
                aniType = 1
                return
            end
        end
        aniType = aniType + 1
    end))))
    
    self.model:registerSpineEventHandler(function(tbl)
        -- self:onSpineEvent(tbl)
    end, 3)

end

function CreateLayer:onSpineEvent(event)
    if event.eventData.name == "effect1" then
        self:loadSkillAttackEffect(self.skillID)
   end
end


--隨機名字
function CreateLayer:onGetRandomNameClick(sender)
    local newName = self:generalRandomName()
    self["TextField_name"]:setString(newName)
    if sender then
        cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_dice)
    end
end

--gender(0:男 1:女) 
function CreateLayer:setSexSelected(gender)
    local filename = {
        "ui_create_module02_role_sex_a.png", --男選中
        "ui_create_module02_role_sex_a1.png", --男未選中
        "ui_create_module02_role_sex_b.png", --女選中
        "ui_create_module02_role_sex_b1.png", -- 女未選中
    }
    if gender == 0 then
        self["Image_sex_1"]:loadTexture(filename[1], ccui.TextureResType.plistType)
        self["Image_sex_2"]:loadTexture(filename[4], ccui.TextureResType.plistType)
    elseif gender == 1 then
        self["Image_sex_1"]:loadTexture(filename[2], ccui.TextureResType.plistType)
        self["Image_sex_2"]:loadTexture(filename[3], ccui.TextureResType.plistType)
    end
    
end



function CreateLayer:loadRandomName()
    self.randomNameStrList = {{},{},{},{}}

	local kmz1, kmz2, kmz3, kmz4
	local localtype = cp.getManager("GDataManager"):getTextLocalType()
	if localtype == 0 then
		kmz1 = "mz1"
		kmz2 = "mz2"
		kmz3 = "mz3"
		kmz4 = "mz4"
	elseif localtype == 1 then
		kmz1 = "fmz1"
		kmz2 = "fmz2"
		kmz3 = "fmz3"
		kmz4 = "fmz4"
	end

    local cnt = cp.getManager("ConfigManager").getItemCount("name_random")
    for i=1,cnt do
        local configItem = cp.getManager("ConfigManager").getItemAt("name_random",i)
        --local mz1 = configItem:getValue(kmz1)
        local mz2 = configItem:getValue(kmz2)
        local mz3 = configItem:getValue(kmz3)
        local mz4 = configItem:getValue(kmz4)
        -- if mz1 ~= nil and mz1 ~= "" then
        --  table.insert(self.randomNameStrList[1],mz1)
        -- end
        if mz2 ~= nil and mz2 ~= "" then
            table.insert(self.randomNameStrList[2],mz2)
        end
        if mz3 ~= nil and mz3 ~= "" then
            table.insert(self.randomNameStrList[3],mz3)
        end
        if mz4 ~= nil and mz4 ~= "" then
            table.insert(self.randomNameStrList[4],mz4)
        end
    end
end

function CreateLayer:generalRandomName()
    if table.nums(self.randomNameStrList) == 0 then
        self:loadRandomName()
    end

    --local num1 = table.nums(self.randomNameStrList[1])
    local num2 = table.nums(self.randomNameStrList[2])
    local num3 = table.nums(self.randomNameStrList[3])
    local num4 = table.nums(self.randomNameStrList[4])

    math.newrandomseed()
    math.random()
    math.random()
    
    --local randomNum1 = math.random(1,num1)
    local randomNum2 = math.random(1,num2)
    
    local gender = self.gender
    local secName = ""
    local randomNum3 = 1
    if gender == 1 then
        secName = self.randomNameStrList[4][math.random(1,num4)]
    else
        secName = self.randomNameStrList[3][math.random(1,num3)]
    end
    
    return self.randomNameStrList[2][randomNum2] .. secName
    --return self.randomNameStrList[1][randomNum1] .. self.randomNameStrList[2][randomNum2] .. secName
end

return CreateLayer
