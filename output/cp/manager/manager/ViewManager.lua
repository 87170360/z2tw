--跟視圖有關的工具方法寫在這裡
local CombatConst = cp.getConst("CombatConst")
local ViewManager = class("ViewManager")

function ViewManager:create()
    local ret =  ViewManager.new() 
    ret:init()
    return ret
end  

function ViewManager:init()
    self.sceneName = nil
    self.oldScene = nil
end

--------------------------場景相關--------------------------------
--切換場景
function ViewManager:changeScene(sceneName, layerName)
    local scene = nil
    local director = cc.Director:getInstance()
    ViewManager.cleanPopup()
	local sceneClass = require(sceneName)
    if sceneClass then
        scene = sceneClass:create()
    end
    if scene then
        self.sceneName = sceneName
        self.layerName = layerName
        self.oldScene = scene  -- changeScene不需要保存上次的scene，oldScene就是當前運行的scene
        if director:getRunningScene() then
            director:replaceScene(scene)
        else
            director:runWithScene(scene)
        end

        --切換場景後，popup的root會發生改變，
        cp.getManager("PopupManager"):setRoot(scene)
    end
    return scene
end

function ViewManager:cleanPopup()
    cp.getManager("PopupManager"):clean()
    ViewManager.totalMultiTips = 0
    ViewManager.multiTipers = {}
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene and runningScene.top_root then
        runningScene.top_root:removeAllChildren()
    end
end

function ViewManager:pushScene(sceneName, layerName)
    local scene = nil
    local director = cc.Director:getInstance()
    self.oldScene = director:getRunningScene() --pushScene先保存當前運行的Scene 
    ViewManager.cleanPopup()
	local sceneClass = require(sceneName)
    if sceneClass then
        scene = sceneClass:create()
    end
    if scene then
        self.sceneName = sceneName
        self.layerName = layerName
        director:pushScene(scene)

        --切換場景後，popup的root會發生改變，
        cp.getManager("PopupManager"):setRoot(scene)
    end
    return scene
end

function ViewManager:popScene()
    local director = cc.Director:getInstance()
    ViewManager.cleanPopup()
    director:popScene()
    
    --切換場景後，popup的root會發生改變，
    if self.oldScene and self.oldScene then
        cp.getManager("PopupManager"):setRoot(self.oldScene)
    end
end
--獲取當前場景lua路徑名
function ViewManager:getSceneName()
    return self.sceneName
end

--獲取world場景中的當前module
function ViewManager:getModuleInWorldScene(cur_module_class_name)
    if self.sceneName == cp.getConst("SceneConst").SCENE_WORLD then
        local curScene = cc.Director:getInstance():getRunningScene()
		if curScene ~= nil then
			local cur_module = curScene:getCurrentModule()
			if cur_module ~= nil and cur_module.__cname == cur_module_class_name then
				return cur_module
			end
		end
	end
	
	return nil
end

--獲取world場景中的當前module
function ViewManager:getModuleNameInWorldScene()
    if self.sceneName == cp.getConst("SceneConst").SCENE_WORLD then
        local curScene = cc.Director:getInstance():getRunningScene()
        if curScene ~= nil then
            local cur_module = curScene:getCurrentModule()
            if cur_module ~= nil then
                return cur_module.__cname
            end
        end
    end
    
    return nil
end

-----------------------end of 場景相關--------------------------




---------------------------shader相關---------------------------------

--[[
添加shader，支持ccui,Sprite,scale9sprite,Armature
@para node 需要添加shader的節點
@para shadername 文件名，其中文件在shader目錄下 如果為nil，則還原shader
]]
function ViewManager.setShader(node,shadername,callback)
    if not node then return end
    local function shaderRecursive(node,glp)
        --給node添加shader
        if not node then return end
        if node.setGLProgram then
            local descriptionStr = node:getDescription()
            local isFind = nil
            _,isFind = string.find(descriptionStr,"Text ")

            if string.len(descriptionStr) <= 6 then
                _,isFind = string.find(descriptionStr,"Text")
            end
            
            if isFind then
                return
            end

            _,isFind = string.find(descriptionStr,"Label")

            if isFind then
                return
            end

            node:setGLProgram(glp)
        end
        -- setGLProgramState
        
        --armature
        if node.getBoneDic then
            for _, bone in pairs(node:getBoneDic()) do
                local rnode = bone:getDisplayRenderNode()
                if rnode then
                   local ntype = bone:getDisplayRenderNodeType()
                   if ntype == ccs.DisplayType.CS_DISPLAY_SPRITE then
                       shaderRecursive(rnode,glp)
                   elseif ntype == ccs.DisplayType.CS_DISPLAY_ARMATURE then
                       --
                   end
                end
            end
        --sprite,ccui等
        else
            --給Scale9Sprite添加shader
            if node.getSprite then
                local img = node:getSprite()
                shaderRecursive(img,glp)
            end
            --遍歷子元素添加shader
            if node.getChildren then
                for _,child in pairs(node:getChildren()) do
                    shaderRecursive(child,glp)
                end
            end
            --遍歷protectedNode子元素添加shader，針對Scale9Sprite和ccui庫
            --getVirtualRenderer
            if node.getVirtualRenderer  then
                local img =  node:getVirtualRenderer() 
                if img and img~=node then
                    shaderRecursive(img,glp)
                end
            end
            -- if node.getProtectedChildren then
            --     for _,child in pairs(node:getProtectedChildren()) do
            --         shaderRecursive(child,glp)
            --     end
            -- end
        end
    end
    
    local glp = nil
    if shadername and tostring(shadername) ~= "" then
        glp = cc.GLProgramCache:getInstance():getGLProgram(shadername)
        if not glp then
            glp = cc.GLProgram:createWithFilenames("shader/"..shadername..".vsh","shader/"..shadername..".fsh")
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_TEX_COORDS)
            if callback then
                local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glp)
                callback(glProgramState)
                node:setGLProgramState(glProgramState)
            end
            glp:link()
            glp:updateUniforms()
            cc.GLProgramCache:getInstance():addGLProgram(glp , shadername)
        end
    else
        glp = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    end
    
    shaderRecursive(node,glp)
end

function ViewManager.setSpineShader(render, shadername, callback)
    if not node then return end
    local glp = nil
    if shadername and tostring(shadername) ~= "" then
        --glp = cc.GLProgramCache:getInstance():getGLProgram(shadername)
        --if not glp then
            glp = cc.GLProgram:createWithFilenames("shader/"..shadername..".vsh","shader/"..shadername..".fsh")
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_TEX_COORDS)
            if callback then
                local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glp)
                callback(glProgramState)
                node:setGLProgramState(glProgramState)
            end
            glp:link()
            glp:updateUniforms()
            cc.GLProgramCache:getInstance():addGLProgram(glp , shadername)
        --end
    else
        glp = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    end
    
    if node.setGLProgram then
        local descriptionStr = node:getDescription()
        local isFind = nil
        _,isFind = string.find(descriptionStr,"Text ")

        if string.len(descriptionStr) <= 6 then
            _,isFind = string.find(descriptionStr,"Text")
        end
        
        if isFind then
            return
        end

        _,isFind = string.find(descriptionStr,"Label")

        if isFind then
            return
        end

        node:setGLProgram(glp)
    end
    -- setGLProgramState
    
    --armature
    if node.getBoneDic then
        for _, bone in pairs(node:getBoneDic()) do
            local rnode = bone:getDisplayRenderNode()
            if rnode then
               local ntype = bone:getDisplayRenderNodeType()
               if ntype == ccs.DisplayType.CS_DISPLAY_SPRITE then
                    rnode:setGLProgram(glp)
               elseif ntype == ccs.DisplayType.CS_DISPLAY_ARMATURE then
                   --
               end
            end
        end
    --sprite,ccui等
    else
        --給Scale9Sprite添加shader
        if node.getSprite then
            local img = node:getSprite()
            img:setGLProgram(glp)
        end
        --遍歷protectedNode子元素添加shader，針對Scale9Sprite和ccui庫
        --getVirtualRenderer
        if node.getVirtualRenderer  then
            local img =  node:getVirtualRenderer() 
            if img and img~=node then
                img:setGLProgram(glp)
            end
        end
        if node.getProtectedChildren then
            for _,child in pairs(node:getProtectedChildren()) do
                child:setGLProgram(glp)
                --shaderRecursive(child,glp)
             end
         end
    end
end

function ViewManager.setShaderSingle(node,shadername,callback)
    if not node then return end
    local glp = nil
    if shadername and tostring(shadername) ~= "" then
        --glp = cc.GLProgramCache:getInstance():getGLProgram(shadername)
        --if not glp then
            glp = cc.GLProgram:createWithFilenames("shader/"..shadername..".vsh","shader/"..shadername..".fsh")
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
            glp:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_TEX_COORDS)
            if callback then
                local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glp)
                callback(glProgramState)
                node:setGLProgramState(glProgramState)
            end
            glp:link()
            glp:updateUniforms()
            cc.GLProgramCache:getInstance():addGLProgram(glp , shadername)
        --end
    else
        glp = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    end
    
    if node.setGLProgram then
        local descriptionStr = node:getDescription()
        local isFind = nil
        _,isFind = string.find(descriptionStr,"Text ")

        if string.len(descriptionStr) <= 6 then
            _,isFind = string.find(descriptionStr,"Text")
        end
        
        if isFind then
            return
        end

        _,isFind = string.find(descriptionStr,"Label")

        if isFind then
            return
        end

        node:setGLProgram(glp)
    end
    -- setGLProgramState
    
    --armature
    if node.getBoneDic then
        for _, bone in pairs(node:getBoneDic()) do
            local rnode = bone:getDisplayRenderNode()
            if rnode then
               local ntype = bone:getDisplayRenderNodeType()
               if ntype == ccs.DisplayType.CS_DISPLAY_SPRITE then
                    rnode:setGLProgram(glp)
               elseif ntype == ccs.DisplayType.CS_DISPLAY_ARMATURE then
                   --
               end
            end
        end
    --sprite,ccui等
    else
        --給Scale9Sprite添加shader
        if node.getSprite then
            local img = node:getSprite()
            img:setGLProgram(glp)
        end
        --遍歷protectedNode子元素添加shader，針對Scale9Sprite和ccui庫
        --getVirtualRenderer
        if node.getVirtualRenderer  then
            local img =  node:getVirtualRenderer() 
            if img and img~=node then
                img:setGLProgram(glp)
            end
        end
        if node.getProtectedChildren then
            for _,child in pairs(node:getProtectedChildren()) do
                child:setGLProgram(glp)
                --shaderRecursive(child,glp)
             end
         end
    end
end
--使元素以及所有的子元素，包括子元素的子元素，支持隨父元素透明度改變而改變
function ViewManager.setAllCascadeOpacityEnabled(node)
    node:setCascadeOpacityEnabled(true)
    for _, snode in pairs(node:getChildren()) do
        ViewManager.setAllCascadeOpacityEnabled(snode)
    end
    if node.getProtectedChildren then
        for _,child in pairs(node:getProtectedChildren()) do
            ViewManager.setAllCascadeOpacityEnabled(child)
        end
    end
end

-----------------------------------end of shader相關----------------------------------------------------------------------------



-------------------------------初始化ccui點擊事件----------------------------------------------------------------------------
function ViewManager.initButton(button, callFunc,scale,playBtnEffect)
    local oscalex = button:getScaleX()
    local oscaley = button:getScaleY()
    local scalex =(scale or 0.9)*oscalex
    local scaley =(scale or 0.9)*oscaley
   
    local function onTouch(sender, event)
        if event == cc.EventCode.BEGAN then
            sender:setScaleX(scalex)
            sender:setScaleY(scaley)
            
        elseif event == cc.EventCode.MOVED then 
            --sender:setScale(scale)
        elseif event == cc.EventCode.ENDED then
            sender:setScaleX(oscalex)
            sender:setScaleY(oscaley)
            callFunc(sender)
            local name = button:getName()
            if name and (name == "Button_close" or name == "Button_Close") then
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_close)
            else
                cp.getManager("AudioManager"):playEffect(cp.getManualConfig("AudioConfig").sound_btn_click)  --按鈕點擊音效
            end
            button:setTouchEnabled(false)
            button:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() button:setTouchEnabled(true) end)))
        elseif event == cc.EventCode.CANCELLED then
            sender:setScaleX(oscalex)
            sender:setScaleY(oscaley)
        end
    end
    if button.addTouchEventListener ~= nil then
        button:addTouchEventListener(onTouch)
    end
end

-------------------------------end of 初始化ccui點擊事件---------------------------------------------------------------------------


----------------------------------------------界面加阻擋層---阻擋touch事件向下層傳播------------------

function ViewManager.addModal(node,c4b,pos,modalClickCallBack)
    if node._modalLayout then return end
    local modalColor,modalOpacity
    if c4b then
        modalColor = cc.c3b(c4b.r,c4b.g,c4b.b)
        modalOpacity = c4b.a
    else
        modalColor = cc.c3b(0,0,0)
        modalOpacity = 0
    end

    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0,0)
    layout:setPosition(0,0)
    layout:setContentSize(display.size)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(modalColor)
    layout:setBackGroundColorOpacity(modalOpacity)
    layout:setTouchEnabled(true)
    layout:setLocalZOrder(-1000)
    if pos ~= nil then
        layout:setPosition(pos.x,pos.y)
    end
    node:addChild(layout)
    node._modalLayout = layout

    if modalClickCallBack then
        local function onTouch(sender, event)
            if event == cc.EventCode.ENDED  then
                modalClickCallBack(node)
            end
        end
        -- node._modalLayout:setTouchEnabled(true)
        node._modalLayout:addTouchEventListener(onTouch)
    end
end

function ViewManager.removeModal(node)
    if node._modalLayout then 
        node:removeChild(node._modalLayout)
        node._modalLayout = nil
    end
end



function ViewManager.addModalByDefaultImage(node,bgPicturePath)
    if node._modalLayout then return end
    
    local image = ccui.ImageView:create()
	local path = bgPicturePath == nil and "img/bg/bg_login/bg_wudang.jpg" or bgPicturePath
	image:ignoreContentAdaptWithSize(false)
    image:setAnchorPoint(cc.p(0,0))
    if display.height >= 1200 then
        image:setPosition(0,0)
    elseif display.height == 1080 then
        image:setPosition(0,-107)
    elseif display.height == 960 then
        image:setPosition(0,-210)
    end
    if device.platform == "ios" then
        image:setPositionX(0)
    end
    image:loadTexture(path, ccui.TextureResType.localType)
    image:setTouchEnabled(true)
   
    node:addChild(image,-1)
    node._modalLayout = image
end

function ViewManager.addImage(node, scale, bgPicturePath)
    local image = ccui.ImageView:create()
    image:setAnchorPoint(cc.p(0.5,0.5))
	image:setPosition(cc.p(node:getPosition()))
	image:setScale(scale)
    image:ignoreContentAdaptWithSize(true)
    image:loadTexture(bgPicturePath, ccui.TextureResType.localType)
    node:addChild(image,-1)
    return image
end

--添加動畫點擊事件
function ViewManager.addArmatureTouchEventListener(armature,callback)
    if armature.touchListener then
        local eventDispatcher = armature:getEventDispatcher()
        eventDispatcher:removeEventListener(armature.touchListener)
    end

    if not callback then
        return
    end

    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        local mouseX , mouseY = location.x , location.y
        local boundbingBox = armature:getBoundingBox()
        local cityPosition = armature:convertToWorldSpace(cc.p(boundbingBox.x,boundbingBox.y))
        if mouseX>=cityPosition.x and mouseX<= cityPosition.x+boundbingBox.width
            and mouseY>=cityPosition.y and mouseY<= cityPosition.y+boundbingBox.height
        then
            callback(event:getCurrentTarget(),0)
            return true
        else
            return false
        end
    end

    local function onTouchMoved(touch, event)
        callback(event:getCurrentTarget(),1)
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local mouseX , mouseY = location.x , location.y
        local boundbingBox = armature:getBoundingBox()
        local cityPosition = armature:convertToWorldSpace(cc.p(boundbingBox.x,boundbingBox.y))
        if mouseX>=cityPosition.x and mouseX<= cityPosition.x+boundbingBox.width
            and mouseY>=cityPosition.y and mouseY<= cityPosition.y+boundbingBox.height
        then
            callback(event:getCurrentTarget(),2)
        else
            callback(event:getCurrentTarget(),3)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = armature:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,armature)
    armature.touchListener = listener
end

--動畫路徑,創建骨骼動畫
function ViewManager.createArmature(path)
    if not path then return nil end
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return nil
    end
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    local armatureName = cp.getUtils("BaseUtils").getFileName(path)
    local armature = ccs.Armature:create(armatureName)
    return armature
end

--通過NPC表格中的NpcID來創建npc
function ViewManager.createNpc(npcid,scale,defaultAnimName)
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    if cfgItem ~= nil then
        local npc_model = cfgItem:getValue("ModelID")
        local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameModel", npc_model)
        if cfgItem2 ~= nil then
            local ModelFile = cfgItem2:getValue("ModelFile")
            local weapon = cfgItem2:getValue("DefaultWeapon")
            scale = scale or 1
            local model = cp.getManager("ViewManager").createSpineAnimation(ModelFile,weapon)
            model:setScale(scale)
            model:setToSetupPose()
            defaultAnimName = defaultAnimName or "Stand"
            model:setAnimation(0,defaultAnimName , true) -- npc的默認動作 "Stand"
            return model
        end
    end
    return nil
end


--創建模型
function ViewManager.createRoleModel(career, gender, fashionID,scale)
    local modelId = 0
    if fashionID == nil or fashionID <= 0 then
        modelId = cp.getManager("GDataManager"):getModelId(career, gender)
    else
        local cfg = cp.getManager("ConfigManager").getItemByKey("Fashion",fashionID)
        modelId = cfg:getValue("ModelID")
    end
	if modelId ~= nil and modelId > 0 then
		local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
		local modelFile = itemCfg:getValue("ModelFile")

		local weapon = itemCfg:getValue("DefaultWeapon")
		local model = cp.getManager("ViewManager").createSpineAnimation(modelFile, weapon)
		model:setScale(scale)
		model:setToSetupPose()
		model:setAnimation(0, "Stand", false)
		return model
	end
	return nil
end

--創建spine動畫 (spineFileName:動畫文件名，不含後綴。)
function ViewManager.createSpineAnimation(spineFileName, weapon)
    if not weapon or string.len(weapon) == 0 then
        weapon = ""
    else
        weapon = "_" .. weapon
    end
    local jsonPath,atlasPath = spineFileName .. weapon .. ".json", spineFileName .. ".atlas"
    
    if not jsonPath or not atlasPath then return nil end
    if not cc.FileUtils:getInstance():isFileExist(jsonPath) or 
        not cc.FileUtils:getInstance():isFileExist(atlasPath) then
        log("file not exist, file="..jsonPath)
        return nil
    end
    local model = sp.SkeletonAnimation:create(jsonPath, atlasPath)
	--model:setAnimation(0, defaultAnimName, true,0) 
    return model
end

--創建spine特效
function ViewManager.createSceneSkeleton(scene, name)
    local pathName = string.format("spine/skeleton/s%02d/%s/%s", scene, name, name)
    local jsonPath,atlasPath = pathName..".json", pathName..".atlas"
    if not jsonPath or not atlasPath then return nil end
    if not cc.FileUtils:getInstance():isFileExist(jsonPath) or 
        not cc.FileUtils:getInstance():isFileExist(atlasPath) then
        return nil
    end
    local model = sp.SkeletonAnimation:create(jsonPath, atlasPath)
    return model
end

--創建spine特效
function ViewManager.createSpineEffect(effectFileName)
    local jsonPath,atlasPath = "img/effect/"..effectFileName.."/"..effectFileName..".json", "img/effect/"..effectFileName.."/"..effectFileName..".atlas"
    if not jsonPath or not atlasPath then return nil end
    if not cc.FileUtils:getInstance():isFileExist(jsonPath) or 
        not cc.FileUtils:getInstance():isFileExist(atlasPath) then
        return nil
    end
    local model = sp.SkeletonAnimation:create(jsonPath, atlasPath)
    return model
end

--播放spine動畫 --參數：動畫的實例，動畫名， 起始幀，是否循環
function ViewManager.setSpineAnimation(spineAnim,animName,begintrace,loop)
    if not spineAnim then
        return
    end

    begintrace = begintrace == nil and 0 or begintrace
    loop = loop == nil and false or loop
    spineAnim:setToSetupPose()
    spineAnim:setAnimation(begintrace, animName, loop)
end

-- 通過路徑找子節點
-- 參數:
--      node:父節點
--      path:路徑   "root1.root2.child1.child2"
function ViewManager.seekNodeByPath(node,path)
    local patharr = string.split(path,".")
    for i,name in ipairs(patharr) do
        node = node:getChildByName(name)
        if not node then
            log("node not exist, name="..name)
        end
    end
    return node
end


-- function xx:onTouch(sender,event)
-- {
--     if event == 0 then
--         --name = "began"
--     elseif event == 1 then
--         --name = "moved"
--     elseif event == 2 then
--         --name = "ended"
--     else
--         --name = "cancelled"
--     end
-- }

-- function xx:onClick(sender)
-- {
--     --
-- }
-- s = {
--     ["ly.d"] = {name = s1 ,touch=onTouch},
--     ["da"] = {name =s2 ,click=onClick,clickScale=0.8},
--     ["txt"] = {name =txt , type="text"},     --設置文字清晰點
-- }
--ViewManager.setCSNodeBinding(root,csnode,s)
function ViewManager.setCSNodeBinding(root,csnode,binding)
    for nodeName,nodeBinding in pairs(binding) do
        ViewManager.setCSNodeBindingOnce(root,csnode,nodeName,nodeBinding)
    end
end

function ViewManager.setCSNodeBindingOnce(root,csnode,nodeName,nodeBinding)
    local node = ViewManager.seekNodeByPath(csnode,nodeName)
    if node == nil then
        log("nodeName = " .. nodeName) 
    end
    if nodeBinding.name then
        root[nodeBinding.name] = node
    end
    if nodeBinding.click then
        if node.setTouchEnabled ~= nil then
            node:setTouchEnabled(true)
        end
        if nodeBinding.clickScale then
            ViewManager.initButton(node, handler(root, root[nodeBinding.click]),nodeBinding.clickScale)
        else
            ViewManager.initButton(node, handler(root, root[nodeBinding.click]))
        end
    end
    if nodeBinding.touch then
        node:addTouchEventListener(handler(root, root[nodeBinding.touch]))
    end
    if nodeBinding.type == "text" and node.getDescription and node:getDescription() == "Label" then
        ViewManager.setTextClear(node)
    end
end

function ViewManager.setCSNodeTextClear(node)
    if node.getDescription and node:getDescription() == "Label" then
        ViewManager.setTextClear(node)
    end
    for k,child in pairs(node:getChildren()) do
        ViewManager.setCSNodeTextClear(child)
    end
end

--[[
根據csb的設計分辨率，以及對齊方式，來適配子元件的位置
    referencePoint ：
            1:display.left_top           
            2:display.left_bottom      
            3:display.left_center    
            4:display.right_top          
            5:display.right_bottom     
            6:display.right_center       
            7:display.center_top        
            8:display.center_bottom       

]]
function ViewManager.adapterCSNode(childnode,designSize, referencePoint)
    local pos = cc.p(childnode:getPosition())
    local tempx,tempy = pos.x,pos.y
    if referencePoint == display.left_top then
        tempx = pos.x
        tempy = display.top - designSize.height + pos.y
    elseif referencePoint == display.left_bottom then
        tempx = pos.x
        tempy = pos.y
    elseif referencePoint == display.left_center then
        tempx = pos.x
        tempy = display.cy - designSize.height/2 + pos.y
    elseif referencePoint == display.right_top then
        tempx = display.right - designSize.width + pos.x
        tempy = display.top - designSize.height + pos.y
    elseif referencePoint == display.right_bottom then
        tempx = display.right - designSize.width + pos.x
        tempy = pos.y
    elseif referencePoint == display.right_center then
        tempx = display.right - designSize.width + pos.x
        tempy = display.cy - designSize.height/2 + pos.y
    elseif referencePoint == display.center_top then
        tempx = display.cx - designSize.width/2 + pos.x
        tempy = display.top - designSize.height + pos.y
    elseif referencePoint == display.center_bottom then
        tempx = display.cx - designSize.width/2 + pos.x
        tempy = pos.y
    end
    childnode:setPosition(cc.p(tempx,tempy))
end


--設置文字清晰些
function ViewManager.setTextClear(node)
    if node.clearScale then return end
    
    local scale = display.scale * display.scale * 2
    node.clearScale = scale
    local fontSize = node:getFontSize()
    local fontScaleX = node:getScaleX()
    local fontScaleY = node:getScaleY()
    local newFontSize = math.round(fontSize * scale)
    node:setFontSize( newFontSize)
    node:setScale(fontScaleX / scale , fontScaleY/scale)
    --描邊
    if node:getLabelEffectType() == 1 then
        local outlineSize = node:getOutlineSize()
        local outlineColor = node:getEffectColor()
        local newOutlineSize = math.round(outlineSize*scale)
        node:enableOutline(outlineColor , newOutlineSize)
    end
    if node:isIgnoreContentAdaptWithSize() == false then
        local tsize = node:getContentSize()
        local csize = cc.size(tsize.width*scale,tsize.height*scale)
        node:setContentSize(csize)
    end
end

--設置過文字清晰之後的 描邊
function ViewManager.textClearEnableOutline(node,outlineColor,outlineSize)
    outlineSize = outlineSize or 1
    outlineColor = outlineColor or cc.c4b(0,0,0,255)
    if node.clearScale then
        local newOutlineSize = math.round(outlineSize * node.clearScale)
        node:enableOutline(outlineColor , newOutlineSize)
    else
        node:enableOutline(outlineColor , outlineSize)
    end
end

--設置過文字清晰之後的 設置字體大小
function ViewManager.textClearSetFontSize(node,fontSize)
    if node.clearScale then
        local newFontSize = math.round(fontSize * node.clearScale)
        node:setFontSize( newFontSize)
    else
        node:setFontSize( fontSize)
    end
end

---icon框
function ViewManager.createIcon( cid, isBink)
    return require("cp.view.ui.icon.BIcon"):create( cid, isBink)
end

--CellView
function ViewManager.createCellView( size)
    return require("cp.view.ui.base.CellView"):create( size)
end


---------------------------------------------彈提示-----------------------------------
--str內容文本
--[[
function ViewManager.gameTip(str)
    local curTotalGameTiper = 1
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="GameTiper" then
            curTotalGameTiper = curTotalGameTiper + 1
        end
    end

    --彈出提示框
    local GameTiper = require("cp.view.ui.tip.GameTiper")
    local tiper = GameTiper:create()
    tiper:setText(str)
    tiper:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(tiper)
    tiper:setName("tiper")
    cp.getManager("PopupManager"):addPopup(tiper, false)

    --動態彈出 和關閉
    local function onTiperRemove(sender)
        cp.getManager("PopupManager"):removePopup(sender)
    end

    tiper:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.1, 1)
    local act2 = cc.DelayTime:create(0.2*curTotalGameTiper)
    local yy = display.top > 1300 and 400 or (display.top > 1100 and 300 or 200 )
    local act3 = cc.MoveTo:create(1, cc.p(display.cx,(display.top - yy) ))
    local act4 = cc.Spawn:create( cc.FadeTo:create(0.5,0), cc.MoveTo:create(0.5, cc.p(display.cx,display.top)) )
    local act5 = cc.CallFunc:create(onTiperRemove)
    local actseq = cc.Sequence:create(act1,act2,act3,act4,act5)
    tiper:runAction(actseq)
end
]]

function ViewManager.gameTip(txt, cb)
    if txt == nil or txt == "" then
        return
    end
    local deltaY = 65
    local maxTips = math.ceil((display.cy-200)/deltaY)
    ViewManager.multiTipers = ViewManager.multiTipers or {}
    local tiper = nil
    if #ViewManager.multiTipers >= 10 then
        tiper = table.remove(ViewManager.multiTipers, 1)
        tiper:stopAllActions()
    else
        tiper = require("cp.view.ui.tip.GameTiper"):create()
        ViewManager.setAllCascadeOpacityEnabled(tiper)
        cp.getManager("PopupManager"):addPopup(tiper, false)
        tiper:setName("multitiper")
    end

    tiper:setText(txt)
    tiper:setPosition(cc.p(display.cx,display.cy+200))
    tiper:setOpacity(255)
    tiper:setScaleY(0.8)

    local curTipNum = #ViewManager.multiTipers
    local lastTip = ViewManager.multiTipers[curTipNum]
    if lastTip then
        deltaY = deltaY - (lastTip:getPositionY()-display.cy-200)
        if deltaY < 0 then
            deltaY = 0
        end
    end

    ViewManager.totalMultiTips = ViewManager.totalMultiTips or 0

    table.insert(ViewManager.multiTipers, tiper)

    local repeatTimes = 0.2*60
    local sequence = {}
    local act = cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
        for _, _tiper in ipairs(ViewManager.multiTipers) do
            if _tiper == tiper then
                break
            end
            local posY = _tiper:getPositionY()+deltaY/repeatTimes
            --log("deltaY="..deltaY)
            _tiper:setPositionY(posY)
        end
        local scale = tiper:getScaleY()
        tiper:setScaleY(scale+0.2/repeatTimes)
    end), cc.DelayTime:create(1/60)), repeatTimes)
    table.insert(sequence, act)
    act = cc.DelayTime:create(0.5)
    table.insert(sequence, act)
    if cb then
        act = cc.CallFunc:create(cb)
        table.insert(sequence, act)
    end
    act = cc.MoveBy:create(0.5, cc.vec3(0, 50, 0))
    table.insert(sequence, act)
    act = cc.FadeTo:create(0.2, 0)
    table.insert(sequence, act)
    act = cc.CallFunc:create(function()
        table.removebyvalue(ViewManager.multiTipers, tiper)
        curTipNum = curTipNum-1
        cp.getManager("PopupManager"):removePopup(tiper)
    end)
    table.insert(sequence, act)
    tiper:runAction(cc.Sequence:create(sequence))
    ViewManager.totalMultiTips = ViewManager.totalMultiTips + 1
end

--網路斷開重新連接，需要放在最頂層
function ViewManager.showNetWorkReconnectMessageBox(title,content,ok_cancel_mode,OKCallBack,CancelCallBack)
    local params = {title = title , content = content , ok_cancel_mode = ok_cancel_mode, OKCallBack = OKCallBack, CancelCallBack = CancelCallBack}
    --彈出提示框
    local GameMessageBox = require("cp.view.ui.messagebox.GameMessageBox")
    local messageBox = GameMessageBox:create(params)
    messageBox:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(messageBox)
    local currentScene = cc.Director:getInstance():getRunningScene()
    currentScene.top_root:addChild(messageBox,10)
    cp.getManager("ViewManager").addModal(messageBox, cp.getManualConfig("Color").defaultModal_c4b,cc.p(-display.cx,-display.cy),function() end)
	
end

---------------------------------------------彈確認框-----------------------------------
function ViewManager.showGameMessageBox(title,content,ok_cancel_mode,OKCallBack,CancelCallBack)
    local params = {title = title , content = content , ok_cancel_mode = ok_cancel_mode, OKCallBack = OKCallBack, CancelCallBack = CancelCallBack}
    --彈出提示框
    local GameMessageBox = require("cp.view.ui.messagebox.GameMessageBox")
    local messageBox = GameMessageBox:create(params)
    messageBox:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(messageBox)
    cp.getManager("PopupManager"):addPopup(messageBox, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(messageBox)
		end)
	
    messageBox:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act2,act3)
    messageBox:runAction(actseq)
end


function ViewManager.showGameMessageBoxExtra(params)
    --彈出提示框
	-- params = {title = "標題" , content  = "顯示內容" , ok_cancel_mode = 2, OKCallBack = function() end, CancelCallBack = nil,Text_OK = "好的", Text_cancel = "太客氣了"}
    local GameMessageBox = require("cp.view.ui.messagebox.GameMessageBox")
    local messageBox = GameMessageBox:create(params)
    messageBox:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(messageBox)
    cp.getManager("PopupManager"):addPopup(messageBox, true,nil,
		function()
		end)
	
    messageBox:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act2,act3)
    messageBox:runAction(actseq)
end

--獲取彈出的GameMessageBox
function ViewManager.getPopupGameMessageBox()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="GameMessageBox" then
            return node
        end
    end
    return nil
end

---------------------------------------------打開自動售賣物品的品質設定-----------------------------------
function ViewManager.showAutoSellSettings()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="AutoSellSettings" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end

    local AutoSellSettings = require("cp.view.ui.messagebox.AutoSellSettings"):create()
    AutoSellSettings:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(AutoSellSettings)
    cp.getManager("PopupManager"):addPopup(AutoSellSettings, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(messageBox)
		end)

    AutoSellSettings:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act2,act3)
    AutoSellSettings:runAction(actseq)
end

------------------------------- 打開揹包售賣物品界面 ---------------------------
function ViewManager.showPackageItemSellUI()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="PackageItemSell" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end

    local PackageItemSell = require("cp.view.scene.world.major.PackageItemSell"):create()
    PackageItemSell:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(PackageItemSell)
    cp.getManager("PopupManager"):addPopup(PackageItemSell, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(messageBox)
		end)

    PackageItemSell:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act2,act3)
    PackageItemSell:runAction(actseq)
end


------------------------------- 打開物品操作界面(多個數量) ---------------------------
function ViewManager.showMultiItemOperateConfirmUI(openInfo)
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="MultiItemOperateConfirm" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end

    local MultiItemOperateConfirm = require("cp.view.ui.messagebox.MultiItemOperateConfirm"):create(openInfo)
    MultiItemOperateConfirm:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(MultiItemOperateConfirm)
    cp.getManager("PopupManager"):addPopup(MultiItemOperateConfirm, true,nil,
		function()
		end)

    MultiItemOperateConfirm:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    MultiItemOperateConfirm:runAction(actseq)
    return MultiItemOperateConfirm
end

function ViewManager.removeMultiItemOperateConfirmUI()
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="MultiItemOperateConfirm" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end
end

---------------------------------------------領取獎勵彈出界面-----------------------------------
function ViewManager.showGetRewardUI(itemList,title,showGetButton, cb)
    local open_info = {itemList = itemList,title = title,showGetButton = showGetButton, cb = cb}
    --itemList = { {id=1,num=3},{id=2,num=1}}
    local GameRewardReceiveUI = require("cp.view.ui.messagebox.GameRewardReceiveUI")
    local rewardReceiveUI = GameRewardReceiveUI:create(open_info)
    rewardReceiveUI:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(rewardReceiveUI)
    cp.getManager("PopupManager"):addPopup(rewardReceiveUI, true,nil,
        function()
            local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
            if cur_guide_module_name == "" or cur_guide_module_name == nil then
                if rewardReceiveUI.openInfo and rewardReceiveUI.openInfo.cb then
                    rewardReceiveUI.openInfo.cb()
                end
                cp.getManager("PopupManager"):removePopup(rewardReceiveUI)
            end
		end)
	
    rewardReceiveUI:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    rewardReceiveUI:runAction(actseq)
    return rewardReceiveUI
end


---------------------------------------------預覽獎勵彈出界面-----------------------------------
function ViewManager.showGameRewardPreView(itemList,title,showGetButton)
    --itemList = { {id=1,num=3},{id=2,num=1}}
    local GameRewardPreView = require("cp.view.ui.messagebox.GameRewardPreView"):create(itemList,title,showGetButton)
    GameRewardPreView:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(GameRewardPreView)
    cp.getManager("PopupManager"):addPopup(GameRewardPreView, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(GameRewardPreView)
		end)
	
    GameRewardPreView:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    GameRewardPreView:runAction(actseq)
end

function ViewManager.showHelpTips(title)
    local tipsHelp = require("cp.view.ui.tip.TipsHelp"):create(title)
    tipsHelp:setPosition(cc.p(display.cx,display.cy))
    
	ViewManager.setAllCascadeOpacityEnabled(tipsHelp)
    cp.getManager("PopupManager"):addPopup(tipsHelp, true,nil,
		function()
			cp.getManager("PopupManager"):removePopup(tipsHelp)
		end)
	
	
    tipsHelp:setScale(0.8)
    local act2 = cc.ScaleTo:create(0.2 , 1)
    -- local act3 = cc.DelayTime:create(2)
    local act4 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act2,act4)
    tipsHelp:runAction(actseq)
end

function ViewManager.showJingTongTips()
    local tipsHelp = require("cp.view.ui.tip.JingTongTip"):create(title)
    tipsHelp:setPosition(cc.p(display.cx,display.cy))
    
	ViewManager.setAllCascadeOpacityEnabled(tipsHelp)
    cp.getManager("PopupManager"):addPopup(tipsHelp, true,nil,
		function()
			cp.getManager("PopupManager"):removePopup(tipsHelp)
		end)
	
	
    tipsHelp:setScale(0.8)
    local act2 = cc.ScaleTo:create(0.2 , 1)
    -- local act3 = cc.DelayTime:create(2)
    local act4 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act2,act4)
    tipsHelp:runAction(actseq)
end

--技能tips
function ViewManager.showSkillTip(skillInfo,pos)
    --移除其他Tips
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="SkillTip" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end

    --彈出提示框
    local SkillTip = require("cp.view.ui.tip.SkillTip"):create(skillInfo,pos)
    
    ViewManager.setAllCascadeOpacityEnabled(SkillTip)
    cp.getManager("PopupManager"):addPopup(SkillTip, false)

end

function ViewManager.removeSkillTip()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="SkillTip" then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end
end


--顯示物品tips,武器tips，武學書tips
function ViewManager.showItemTip(itemInfo,closeCallBack)
    --移除其他Tips
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and (node:getDescription()=="ItemTip" or node:getDescription()=="EquipTip" or node:getDescription()=="WeaponTip") then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end

    local id = itemInfo.id
    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
    if conf == nil then
        log("no item with id :" .. tostring(id))
        return
    end
	itemInfo.Type = conf:getValue("Type")
	itemInfo.SubType = conf:getValue("SubType")
	itemInfo.Package = conf:getValue("Package")
	itemInfo.Tips = conf:getValue("Tips")
	itemInfo.Price = conf:getValue("Price")
	itemInfo.Colour = conf:getValue("Hierarchy")
	itemInfo.Package = math.max(itemInfo.Package,1)
	itemInfo.Package = math.min(itemInfo.Package,6)
    itemInfo.Price = math.max(itemInfo.Price,0)
    itemInfo.Extra = conf:getValue("Extra") -- 對應的武學id
    if itemInfo.Name == nil then
        itemInfo.Name = conf:getValue("Name")
    end
    if itemInfo.Icon == nil then
        itemInfo.Icon = conf:getValue("Icon")
    end
    local itemTip = nil
    if itemInfo.Package == 1 then --裝備
        local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", id)
        itemInfo.Pos = conf2:getValue("Pos")
        itemInfo.WeaponIcon = conf2:getValue("Ico")
        log("showWeapon Tips PlayerHierarchy = " .. tostring(conf2:getValue("PlayerHierarchy")))
        itemInfo.PlayerHierarchy = conf2:getValue("PlayerHierarchy") or 1
        itemInfo.PlayerHierarchy = math.max(itemInfo.PlayerHierarchy,1)
        if itemInfo.attachAtt == nil or next(itemInfo.attachAtt) == nil then
            itemInfo.attachAtt = {}
            if itemInfo.uuid then
                local item = cp.getUserData("UserItem"):getItem(itemInfo.uuid)
                if item ~= nil then
                    itemInfo.attachAtt = item.attachAtt
                end
            end
        end
        if itemInfo.Pos == 1 then --武器
            itemTip = require("cp.view.ui.tip.WeaponTip"):create(itemInfo)
            itemTip:setPosition(cc.p(display.cx,display.cy))
        else -- 其他裝備
            itemTip = require("cp.view.ui.tip.EquipTip"):create(itemInfo)
            itemTip:setPosition(cc.p(display.cx,display.cy))
        end
	else
        itemTip = require("cp.view.ui.tip.ItemTip"):create(itemInfo)
        itemTip:setPosition(cc.p(display.cx,display.cy))
	end

    if itemTip ~= nil then
        itemTip:setClosedCallBack(closeCallBack)
        
        ViewManager.setAllCascadeOpacityEnabled(itemTip)
    
        cp.getManager("PopupManager"):addPopup(itemTip, true,nil,
            function()
                cp.getManager("PopupManager"):removePopup(itemTip)
            end)
        
        
        -- itemTip:setScale(0.8)
        -- local act2 = cc.ScaleTo:create(0.2 , 1)
        -- local act3 = cc.DelayTime:create(2)
        -- local act4 = cc.FadeIn:create(0.3)
        -- local actseq = cc.Sequence:create(act2,act3,act4)
        -- itemTip:runAction(actseq)
    end
end

function ViewManager.removeItemTip()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and (node:getDescription()=="ItemTip" or node:getDescription()=="EquipTip" or node:getDescription()=="WeaponTip") then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end
end


--顯示裝備預覽
function ViewManager.showEquipPreview(itemInfo,closeCallBack)
    local id = itemInfo.id
    local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
    if conf == nil then
        log("no item with id :" .. tostring(id))
        return
    end
	itemInfo.Type = conf:getValue("Type")
	itemInfo.SubType = conf:getValue("SubType")
	itemInfo.Package = conf:getValue("Package")
	itemInfo.Tips = conf:getValue("Tips")
	itemInfo.Price = conf:getValue("Price")
	itemInfo.Colour = conf:getValue("Hierarchy")
	itemInfo.Package = math.max(itemInfo.Package,1)
	itemInfo.Package = math.min(itemInfo.Package,6)
    itemInfo.Price = math.max(itemInfo.Price,0)
    itemInfo.Extra = conf:getValue("Extra") -- 對應裝備id
    itemInfo.mode = "preview"
    if itemInfo.Name == nil then
        itemInfo.Name = conf:getValue("Name")
    end
    if itemInfo.Icon == nil then
        itemInfo.Icon = conf:getValue("Icon")
    end
    local itemTip = nil
    if itemInfo.Package == 1 then --裝備
        local conf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", id)
        itemInfo.Pos = conf2:getValue("Pos")
        itemInfo.WeaponIcon = conf2:getValue("Ico")
        log("showWeapon Tips PlayerHierarchy = " .. tostring(conf2:getValue("PlayerHierarchy")))
        itemInfo.PlayerHierarchy = conf2:getValue("PlayerHierarchy") or 1
        itemInfo.PlayerHierarchy = math.max(itemInfo.PlayerHierarchy,1)
        if itemInfo.attachAtt == nil or next(itemInfo.attachAtt) == nil then
            itemInfo.attachAtt = {}
            if itemInfo.uuid then
                local item = cp.getUserData("UserItem"):getItem(itemInfo.uuid)
                if item ~= nil then
                    itemInfo.attachAtt = item.attachAtt
                end
            end
        end
        if itemInfo.Pos == 1 then --武器
            itemTip = require("cp.view.ui.tip.WeaponTip"):create(itemInfo)
        else -- 其他裝備
            itemTip = require("cp.view.ui.tip.EquipTip"):create(itemInfo)
        end
	end
    return itemTip
end

--顯示挑戰界面
function ViewManager.showChallengeStory(type,id,level,closeCallBack)
    
    local challengeStory = require("cp.view.scene.world.challenge.ChallengeStory"):create(type,id,level)
    challengeStory:setCloseCallBack(closeCallBack)

    -- challengeStory:setPosition(cc.p(display.cx,display.cy))
    
	ViewManager.setAllCascadeOpacityEnabled(challengeStory)
    cp.getManager("PopupManager"):addPopup(challengeStory, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(challengeStory)
		end)
end


function ViewManager.removeChallengeStory()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and (node:getDescription()=="ChallengeStory") then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end
end

---------------------------------------------彈對話框-----------------------------------
-- needBlackMark 是否需要黑色遮罩，nil或true為需要，false為不需要
-- finishCallBack 對話完成回調
-- 對話的內容列表
function ViewManager.showGamePopTalk(contentTable,finishCallBack,needBlackMark)
    
    local gamePopTalk = require("cp.view.ui.messagebox.GamePopTalk"):create(contentTable,needBlackMark)
    gamePopTalk:setPosition(cc.p(display.cx,0))
    gamePopTalk:setFinishedCallBack(finishCallBack)
    ViewManager.setAllCascadeOpacityEnabled(gamePopTalk)
    cp.getManager("PopupManager"):addPopup(gamePopTalk, true,nil,
		function()
			gamePopTalk:Next()
		end)
end

function ViewManager.removeGamePopTalk()
	local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and (node:getDescription()=="GamePopTalk") then
            cp.getManager("PopupManager"):removePopup(node)
        end
    end
end


--創建富文本框RichText
--[[
contentTable {
	[1] = {type="image",filePath="ui_common_status_physical.png",textureType=ccui.TextureResType.localType},
	[2] = {type="ttf", fontSize=12, text="文本內容", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=1}
]]
function ViewManager.createRichText(contentTable,width,height,linegap)
    local richText = require("cp.view.ui.base.RichText"):create()
	richText:setAnchorPoint(cc.p(0,0))
    richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(width,3000))
	richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)
    -- richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    richText:setLineGap( tonumber(linegap) ~= nil and tonumber(linegap) or 1)
	
    for i=1,#contentTable do
		richText:addElement(contentTable[i])
	end
   
    richText:formatText()
    local tsize = richText:getTextSize()
    richText:setContentSize(cc.size(width,math.max(height,tsize.height)))
	
	return richText
end

--:::::::::::::::::::::::::::::::::::::::::::::滾動廣播:::::::::::::::::::::::::::::::::
function ViewManager.showBroadcast()
    
    local currentScene = cc.Director:getInstance():getRunningScene()
    local broadcast = currentScene.top_root:getChildByName("ChatBroadcast")
    if broadcast == nil then
        broadcast = require("cp.view.scene.world.chat.ChatBroadcast"):create()
        broadcast:setName("ChatBroadcast")
        currentScene.top_root:addChild(broadcast,8)  --必需在斷線重連的下層，在其他界面的上層
        broadcast:setPosition(cc.p(display.cx,display.height-200))
    end
    broadcast:show()
    
end


--::::::::::::::::::::::::::::::::紅點提示:::::::::::::::::::::::::::::::::::::
function ViewManager.addRedDot(parent, pos, filename)
    local img = nil
    if parent ~= nil then
        display.loadSpriteFrames("uiplist/ui_common.plist")
        filename = filename or "ui_common_tishi_a.png"
        img = parent:getChildByName("NewNotice")
        if img == nil then
            img = ccui.ImageView:create(filename, ccui.TextureResType.plistType)
            img:setName("NewNotice")
            parent:addChild(img,2)
            local sz = parent:getContentSize()
            if pos == nil then
                pos = {x = sz.width, y = sz.height}
            end
            img:setPosition(cc.p(pos.x,pos.y))
        else
            img:loadTexture(filename, ccui.TextureResType.plistType)
        end
    end
    return img
end

function ViewManager.removeRedDot(parent)
    if parent ~= nil then
        local img =  parent:getChildByName("NewNotice")
        if img ~= nil then
            img:removeFromParent()
        end
    end
end

--::::::::::::::::::::::::::::::::新提示:::::::::::::::::::::::::::::::::::::
function ViewManager.addDot(parent, pos, filename, dotname)
    local img = nil
    if parent ~= nil then
        display.loadSpriteFrames("uiplist/ui_common.plist")
        img = parent:getChildByName(dotname)
        if img == nil then
            img = ccui.ImageView:create(filename, ccui.TextureResType.plistType)
            img:setName(dotname)
            parent:addChild(img,2)
            local sz = parent:getContentSize()
            if pos == nil then
                pos = {x = sz.width, y = sz.height}
            end
            img:setPosition(cc.p(pos.x,pos.y))
        else
            img:loadTexture(filename, ccui.TextureResType.plistType)
        end
    end
    return img
end

function ViewManager.removeDot(parent, dotname)
    if parent ~= nil then
        local img =  parent:getChildByName(dotname)
        if img ~= nil then
            img:removeFromParent()
        end
    end
end


--::::::::::::::::::::::::::::::::邊框特效:::::::::::::::::::::::::::::::::::::
function ViewManager:createFrameEffect()
    local armature = cp.getManager("ViewManager").createArmature("animation/other/UI_guangbiao.csb")
    if not armature then return nil end
    armature:setName("armature")
    armature:getAnimation():playWithIndex(0)
    armature:setPosition(cc.p(50, 50))

    return armature
end


--::::::::::::::::::::::::::::::::邊框特效:::::::::::::::::::::::::::::::::::::
function ViewManager:showStartAnimation(node, callback, pos)
    if node == nil then return end
    node:setScale(0.001)
    node:setAnchorPoint(cc.p(0.5, 0.5))
    if pos == nil then
        node:setPosition(cc.p(display.width / 2, display.height / 2))
    else
        node:setPosition(cc.p(pos.x, pos.y))
    end

    local function func()
        if callback ~= nil then
            callback()
        end
    end
    local seq = cc.Sequence:create(
        cc.ScaleTo:create(0.2, 1.1),
        cc.ScaleTo:create(0.1, 1),
        cc.CallFunc:create(func)
    )
    node:runAction(seq)
end

function ViewManager:showCloseAnimation(node, callback)
    local function func()
        if callback ~= nil then
            callback()
        end
    end

    local seq = cc.Sequence:create(
        cc.ScaleTo:create(0.2, 0.001),
        cc.CallFunc:create(func)
    )
    node:runAction(seq)
end


--::::::::::::::::::::::::::::::::分享戰鬥:::::::::::::::::::::::::::::::::::::
function ViewManager.shareFight(info, share2WorldCallback, share2UnionCallback, closeCallBack, closeFunc)
    local shareFightLayer = require("cp.view.scene.world.share.ShareFightLayer"):create(info)
    local function close()
        if closeCallBack ~= nil then
            closeCallBack()
        end
        if shareFightLayer ~= nil then
            cp.getManager("PopupManager"):removePopup(shareFightLayer)
            shareFightLayer = nil
        end
    end
    shareFightLayer:registerCloseCallFunc(close)

    local function share2World(info)
        if share2WorldCallback ~= nil then
            share2WorldCallback(info)
        end
    end
    shareFightLayer:registerShare2WorldCallFunc(share2World)

    local function share2Union(info)
        if share2UnionCallback ~= nil then
            share2UnionCallback(info)
        end
    end
    shareFightLayer:registerShare2UnionCallFunc(share2Union)

    if closeFunc ~= nil and type(closeFunc) == "table" then
        local closeLayert = function()
            if shareFightLayer ~= nil then
                cp.getManager("PopupManager"):removePopup(shareFightLayer)
                shareFightLayer = nil
            end
        end
        closeFunc.close = closeLayert
    end
    cp.getManager("PopupManager"):addPopup(shareFightLayer, true, nil, function() end)   
end

--::::::::::::::::::::::::::::::::戰鬥回放:::::::::::::::::::::::::::::::::::::
function ViewManager.fightPlayBack(info, confirmCallBack, closeCallBack)
    local shareFightLayer = require("cp.view.scene.world.share.ShareFightLayer"):create(info)
    local function close()
        if closeCallBack ~= nil then
            closeCallBack()
        end
        cp.getManager("PopupManager"):removePopup(shareFightLayer)
    end
    shareFightLayer:registerCloseCallFunc(close)

    local function confirm()
        if confirmCallBack ~= nil then
            confirmCallBack()
        end
        cp.getManager("PopupManager"):removePopup(shareFightLayer)
    end
    shareFightLayer:registerConfirmCallFunc(confirm)

    shareFightLayer:isFightPlayBack(true)
    cp.getManager("PopupManager"):addPopup(shareFightLayer, true, nil, function() end)   
end


function ViewManager.showGetExperienceItem(useItemId)
    if useItemId == nil or useItemId == "" then
        return
    end
    local openInfo = {}
    openInfo["itemId"] = useItemId
    local ExperienceItemLayer = require("cp.view.scene.world.pack.ExperienceItemLayer")
    local experienceLayer = ExperienceItemLayer:create(openInfo)
    local function remove()
        cp.getManager("PopupManager"):removePopup(experienceLayer)
    end
    experienceLayer:registerCloseCallFunc(remove)
    cp.getManager("PopupManager"):addPopup(experienceLayer, true, nil, function() end)
end

--查看好友或其他玩家的人物屬性界面
function ViewManager.showOtherRoleInfo(data,closeCallBack)

    --[[
        message ViewPlayerRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
	optional RoleAtt roleAtt                = 2;                    //角色屬性
    repeated ItemData equipList             = 3;                    //裝備
    required int64 roleID                   = 4;
    required int32 zoneID                   = 5;
    repeated SkillSummary skill             = 6;                    //武學
    optional int32 vip                      = 7;                    //vip
    repeated ItemAtt guildAtt               = 8;                    //幫派屬性
    optional FashionData fashion            = 9;                    //時裝
}
        ]]
    local openInfo = data
    openInfo.closeCallBack = closeCallBack
    local MajorRoleOther = require("cp.view.scene.world.major.MajorRoleOther"):create(openInfo)
    MajorRoleOther:setPosition(cc.p(0,0))
    ViewManager.setAllCascadeOpacityEnabled(MajorRoleOther)
    cp.getManager("PopupManager"):addPopup(MajorRoleOther, true,nil,
		function()
			--cp.getManager("PopupManager"):removePopup(messageBox)
		end)
	
    MajorRoleOther:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2 , 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    MajorRoleOther:runAction(actseq)
end

--打開聊天界面
function ViewManager.showChatLayer(chatObjInfo)

    local nodes = cp.getManager("PopupManager"):getPopups()
    local ChatLayer = nil 
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="ChatLayer" then
            ChatLayer = node
            break
        end
    end
    if not ChatLayer then
        ChatLayer = require("cp.view.scene.world.chat.ChatLayer"):create(chatObjInfo)
        ChatLayer:setPosition(cc.p(0,0))
        ViewManager.setAllCascadeOpacityEnabled(ChatLayer)
        cp.getManager("PopupManager"):addPopup(ChatLayer, true,nil,
            function()
                cp.getManager("PopupManager"):removePopup(ChatLayer)
            end)
    else
        ChatLayer:chatWith(chatObjInfo)
    end
    return ChatLayer
end
    

--打開銀兩兌換界面
function ViewManager.showSilverConvertUI()
    local SilverConvertUI = require("cp.view.ui.messagebox.SilverConvertUI"):create()
    SilverConvertUI:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(SilverConvertUI)
    cp.getManager("PopupManager"):addPopup(SilverConvertUI, true,nil,
        function()
            
        end)
    
    SilverConvertUI:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2, 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    SilverConvertUI:runAction(actseq)
end

--打開選擇俠客行關卡
function ViewManager.showSilverConvertUI()
    local SilverConvertUI = require("cp.view.ui.messagebox.SilverConvertUI"):create()
    SilverConvertUI:setPosition(cc.p(display.cx,display.cy))
    ViewManager.setAllCascadeOpacityEnabled(SilverConvertUI)
    cp.getManager("PopupManager"):addPopup(SilverConvertUI, true,nil,
        function()
            
        end)
    
    SilverConvertUI:setScale(0.8)
    local act1 = cc.ScaleTo:create(0.2, 1)
    -- local act2 = cc.DelayTime:create(2)
    local act3 = cc.FadeIn:create(0.3)
    local actseq = cc.Sequence:create(act1,act3)
    SilverConvertUI:runAction(actseq)
end

--心跳動畫，目標對象wid: widget
function ViewManager.popUpView(wig)
    -- wig:setPositionY(display.height/2)
    wig:setScale(0.5)
    wig:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.ScaleTo:create(0.1, 1)))
end

--心跳動畫，目標對象wid: widget
function ViewManager.popUpViewEx(wig, view)
    wig:setPositionY(display.height/2)
    wig:setScale(0.5)
    wig:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function()
        if view and view.popFinishCallback then
            view:popFinishCallback()
        end
    end)))
end

--txt為ccui.Text控件，color為品質
function ViewManager.setTextQuality(txt, color)
	txt:setTextColor(CombatConst.SkillQualityColor4b[color])
	txt:enableOutline(CombatConst.QualityOutlineC4b[color], 2)
end


--檢測是否需要新手指引
function ViewManager.openNewPlayerGuide(moduleName,cur_step)
    
    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    local guide_moduleInfo = guideInfo[moduleName]
    
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name ~= moduleName then
        cp.getGameData("GameNewGuide"):setValue("cur_guide_module_name",guide_moduleInfo.name)
        cp.getGameData("GameNewGuide"):setValue("cur_step",cur_step or 0)
        cp.getGameData("GameNewGuide"):setValue("max_step",guide_moduleInfo.max_step)
    else
        local cur_step = cp.getGameData("GameNewGuide"):getValue("cur_step")
        log("openNewPlayerGuide:" .. cur_guide_module_name .. "cur_step = " .. tostring(cur_step))
    end

    local function finishCallBack(guide_name)
        log("guide finished , guide_name = " .. tostring(guide_name))

        local new_guide_name,needGuid,step = cp.getManager("GDataManager"):getNextNewGuideName()
        if needGuid and new_guide_name ~= "" then
            cp.getManager("ViewManager").openNewPlayerGuide(new_guide_name)
        else
            cp.getGameData("GameNewGuide"):setValue("cur_guide_module_name","")
            local open_info = { type = "close"}
            cp.getManager("EventManager"):dispatchEvent("VIEW",cp.getConst("EventConst").open_playerguider_view,open_info)
        end
    end

    local open_info = {guide_moduleInfo = guide_moduleInfo,guide_name = guide_moduleInfo.name, type = "show", finishCallBack = finishCallBack }
    cp.getManager("EventManager"):dispatchEvent("VIEW",cp.getConst("EventConst").open_playerguider_view,open_info)    
    
end

function ViewManager.initSkillNode(parent, skillEntry, skillLevel)
    parent = parent or cc.Layer:create()

    local imgIcon = parent:getChildByName("Image_Icon")
    if not imgIcon then
        imgIcon = ccui.ImageView:create()
        imgIcon:setName("Image_Icon")
        parent:addChild(imgIcon)
    end
    imgIcon:loadTexture(skillEntry:getValue("Icon"),ccui.TextureResType.localType)

    local btnBox = parent:getChildByName("Button_Box")
    if not btnBox then
        btnBox = ccui.Button:create()
        btnBox:setName("Button_Box")
        parent:addChild(btnBox)
    end
    local btnTexture = CombatConst.SkillBoxList[skillEntry:getValue("Colour")]
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(btnTexture)
	if not spriteFrame then
        display.loadSpriteFrames("uiplist/ui_common.plist")
    end
    btnBox:loadTextures(btnTexture, btnTexture, btnTexture, ccui.TextureResType.plistType)

    local txtLevel = parent:getChildByName("Text_Level")
    if not txtLevel and skillLevel then
        txtLevel = ccui.Text:create()
        txtLevel:setName("Text_Level")
        txtLevel:setPosition(0, -32)
        txtLevel:setFontName("fonts/msyh.ttf")
        txtLevel:setFontSize(16)
        txtLevel:setTextColor(cc.c4b(255,255,255,255))
        txtLevel:enableOutline(cc.c4b(0,0,0,255), 2)
        parent:addChild(txtLevel)
    end
    if txtLevel then
        txtLevel:setString("LV."..skillLevel)
    end

    local txtName = parent:getChildByName("Text_Name")
    if not txtName then
        txtName = ccui.Text:create()
        txtName:setName("Text_Name")
        txtName:setPosition(0, -62)
        txtName:setFontName("fonts/msyh.ttf")
        txtName:setFontSize(20)
        parent:addChild(txtName)
    end
    txtName:setString(skillEntry:getValue("SkillName"))
    ViewManager.setTextQuality(txtName, skillEntry:getValue("Colour"))

    return parent, imgIcon, btnBox, txtLevel
end

function ViewManager.addWidgetBottom(wig, quality)
    quality = quality or 1
    local parent = wig:getParent()
    wig:setZOrder(1)
    local zOrder = 0--wig:getZOrder() - 1
    local img = ccui.ImageView:create(CombatConst.QualityBottomList[quality], ccui.TextureResType.plistType)
    img:setPosition(wig:getPosition())
    img:setSize(wig:getSize())
    img:setContentSize(wig:getContentSize())
    parent:addChild(img, zOrder)
    return img
end


function ViewManager.showRoleLevelUpView(oldLevel,newLevel,closeCallBack)

    local openInfo = {oldLevel = oldLevel, newLevel = newLevel, closeCallBack = closeCallBack}
    local PublicLevelUpLayer = require("cp.view.scene.public.PublicLevelUpLayer"):create(openInfo)
    ViewManager.setAllCascadeOpacityEnabled(PublicLevelUpLayer)
    cp.getManager("PopupManager"):addPopup(PublicLevelUpLayer, true,nil,
        function()
            cp.getManager("PopupManager"):removePopup(PublicLevelUpLayer)
        end
    )

end

--在不打斷前一個action的前提下按照序列運行
function ViewManager.runStepAction(node, act, cb)
    node.runStepAction = node.runStepAction or function(self, act, cb)
        self.stepActionSequence = self.stepActionSequence or {}
        table.insert(self.stepActionSequence, act)
        if not self.isRunStepAction then
            self.isRunStepAction = true
            self:runAction(cc.Sequence:create(act, cc.CallFunc:create(function()
                if cb then
                    cb()
                end
                self:stepActionFinished()
            end)))
        end
    end
    
    node.stepActionFinished = node.stepActionFinished or function(self)
        table.arrShift(self.stepActionSequence)
        local act = self.stepActionSequence[1]
        if not act then
            self.isRunStepAction = false
        else
            self:runStepAction(act)
        end
    end

    node:runStepAction(act, cb)
end

--給武學圖標設置狀態(未學的，置灰加遮罩)
function ViewManager.addSkillItemMark(imgIcon,learned,pos)
    local parent = imgIcon:getParent()
    if not parent then return end 

    local Panel_mark = parent:getChildByName("Panel_mark") 
    if Panel_mark then
        if learned then
            parent:removeChildByName("Panel_mark")
            Panel_mark = nil
        else
            Panel_mark:setVisible(true)
        end
    else
        if not learned then
            local sz = parent:getContentSize()
            local img_sz = imgIcon:getContentSize()
            Panel_mark = ccui.Layout:create()
            Panel_mark:setAnchorPoint(0.5,0.5)
            Panel_mark:setPosition(sz.width/2,sz.height/2)
            if pos then
                Panel_mark:setPosition(pos.x,pos.y)
            end
            Panel_mark:setContentSize(cc.size(img_sz.width,img_sz.height))
            Panel_mark:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
            Panel_mark:setBackGroundColor(cc.c3b(0,0,0))
            Panel_mark:setBackGroundColorOpacity(128)
            Panel_mark:setTouchEnabled(false)
            parent:addChild(Panel_mark,1)
            Panel_mark:setVisible(true)
        end    
    end
    
    local shaderName = cp.getConst("ShaderConst").GrayShader
    if learned then
        shaderName = nil
    end
    cp.getManager("ViewManager").setShader(imgIcon,shaderName)
end

--檢測元寶是否足夠
function ViewManager.checkGoldEnough(needGold)

    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if majorRole.gold >= needGold then
        return true
    else
        local GameConst = cp.getConst("GameConst")
        local contentTable = {
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="您的元寶不足，是否前往儲值界面進行儲值？", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"}
        }
        ViewManager.showGameMessageBox("系統消息",contentTable,2,function()
            --打開儲值界面
            ViewManager.showRechargeUI()
        end,nil)
        return false
    end
    
end

--檢測銀兩是否足夠
function ViewManager.checkSilverEnough(needSilver)
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if majorRole.silver >= needSilver then
        return true
    else
        local GameConst = cp.getConst("GameConst")
        local contentTable = {
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text="您的銀兩不足，是否前往招財界面兌換銀兩？", textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"}
        }
        ViewManager.showGameMessageBox("系統消息",contentTable,2,function()
            cp.getManager("ViewManager").showSilverConvertUI()
        end,nil)
        return false
    end
end

--檢測虛擬貨幣是否充足
function ViewManager.checkVirtualItemEnough(needValue,virtualItemType)

    --  1:銀兩 2:元寶 3：修為點(技能點) 4：領悟點 5.聲望值 6：俠義令 7：鐵膽令  8:體力 9：閱歷值(exp)  10:罪惡值(紅名)  11:幫派個人資金 ... 
    local vType = cp.getConst("GameConst").VirtualItemType
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local contribute = 0
    if virtualItemType == vType.guildContribute then
        local memberInfo = cp.getUserData("UserGuild"):getMemberInfo(majorRole.id)
        if memberInfo then
            contribute = memberInfo.contribute or 0
        end
    end
    local list = {}
    list[vType.silver] = {info = "您的銀兩不足，是否前往招財界面兌換銀兩？",value=majorRole.silver,func = function()
        cp.getManager("ViewManager").showSilverConvertUI()
    end}
    list[vType.gold] = {info = "您的元寶不足，是否前往儲值界面進行儲值？",value=majorRole.gold,func = function()
        cp.getManager("ViewManager").showRechargeUI()
    end}
    list[vType.trainPoint] = {info = "修為點不足", value=cp.getUserData("UserSkill"):getTrainPoint()}
    list[vType.learnPoint] = {info = "領悟點不足", value=cp.getUserData("UserSkill"):getLearnPoint()}
    list[vType.prestige] = {info = "聲望值不足", value=majorRole.prestige}
    list[vType.goodPoint] = {info = "俠義令不足", value=majorRole.conductGood}
    list[vType.badPoint] = {info = "鐵膽令不足", value=majorRole.conductBad}
    list[vType.physical] = {info = "體力不足", value=majorRole.physical}
    list[vType.exp] = {info = "閱歷值不足", value=majorRole.exp}
    list[vType.sins] = {info = "罪惡值不足", value=majorRole.sins}
    list[vType.guildGold] = {info = "幫派個人資金不足", value=majorRole.guild_money}
    list[vType.guildContribute] = {info = "幫派貢獻不足", value=contribute}
    list[vType.jade] = {info = "玄玉不足", value=majorRole.jade}
    list[vType.vigor] = {info = "精力不足", value=majorRole.vigor}
        -- guildExp=100, --幫派經驗(客戶端使用)
        -- guildContribute=101,--幫派貢獻(客戶端使用)
        -- taskPoint=102,--任務積分(客戶端使用)
    

    if list[virtualItemType].value >= needValue then
        return true
    else
        if virtualItemType == 1 or virtualItemType == 2 then
            local GameConst = cp.getConst("GameConst")
            local contentTable = {
                {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=list[virtualItemType].info, textColor=GameConst.ContentTextColor, outLineEnable=false,verticalAlign="middle"}
            }
            ViewManager.showGameMessageBox("系統消息",contentTable,2,list[virtualItemType].func,nil)
        else
            ViewManager.gameTip(list[virtualItemType].info)
        end
        return false
    end
    
end


--添加伏擊警告
function ViewManager.addBeRobbedNotice(parent,pos,callback)
    display.loadSpriteFrames("uiplist/ui_common.plist")
    if parent and parent:getChildByName("Button_beRobbed") ~= nil then
        -- parent:removeChildByName("Button_beRobbed")
        return
    end
    local Button_beRobbed = ccui.Button:create("ui_common_module21_yabiao_17.png","ui_common_module21_yabiao_17.png","ui_common_module21_yabiao_17.png",ccui.TextureResType.plistType)
    parent:addChild(Button_beRobbed,1)
    Button_beRobbed:setTouchEnabled(true)
    Button_beRobbed:setScale9Enabled(false)
    Button_beRobbed:setAnchorPoint(0.5,0.5)
    Button_beRobbed:setPosition(655,390)
    Button_beRobbed:setName("Button_beRobbed")
    cp.getManager("ViewManager").initButton(Button_beRobbed, function()
        if callback then
            callback()
        end
    end, 0.9)
    return Button_beRobbed
end

--添加聊天訊息提示
function ViewManager.addChatMsgNotice(parent,pos,msgNum)
    display.loadSpriteFrames("uiplist/ui_common.plist")
    local Button_Chat = nil
    if parent then
        Button_Chat = parent:getChildByName("Button_Chat") 
        if Button_Chat == nil then
            local Button_Chat = ccui.Button:create("ui_common_module04_main_xiaoxi_a.png","ui_common_module04_main_xiaoxi_b.png","ui_common_module04_main_xiaoxi_b.png",ccui.TextureResType.plistType)
            parent:addChild(Button_Chat,1)
            Button_Chat:setTouchEnabled(true)
            Button_Chat:setScale9Enabled(false)
            Button_Chat:setAnchorPoint(0.5,0.5)
            Button_Chat:setPosition(670,174)
            Button_Chat:setName("Button_Chat")
            cp.getManager("ViewManager").initButton(Button_Chat, function()
                cp.getManager("ViewManager").showChatLayer() 
            end, 0.9)
        end
    end
    
    if Button_Chat then
        local chat_num = Button_Chat:getChildByName("chat_num")
        if msgNum > 0 then 
            if chat_num == nil then
                local chat_num = ccui.ImageView:create()
                chat_num:loadTexture("ui_common_module33_liaotian_xiaoxi.png",ccui.TextureResType.plistType)
                Button_Chat:addChild(chat_num)
                chat_num:setName("chat_num")
                chat_num:setPosition(60,55)

                local Text_chat_num = ccui.Text:create()
                Text_chat_num:setText(tostring(msgNum))
                Text_chat_num:setName("Text_chat_num")
                Text_chat_num:setFontName("fonts/msyh.ttf") 
                Text_chat_num:setAnchorPoint(cc.p(0.5, 0.5))
                Text_chat_num:setTextColor(cc.c3b(255, 255, 255))
                Text_chat_num:setFontSize(20)
                Text_chat_num:enableOutline(cc.c4b(0, 0, 0, 255), 1)
                Text_chat_num:setPosition(cc.p(18, 18))
                chat_num:addChild(Text_chat_num)
            else
                local Text_chat_num = chat_num:getChildByName("Text_chat_num")
                if Text_chat_num then
                    Text_chat_num:setText(tostring(msgNum))
                end
            end
        else
            if chat_num then
                chat_num:setVisible(false)
            end
        end
    end
    return Button_Chat
end

function ViewManager.createGangModel(career, gender)
    local modelConfig = nil
	local chartConfig = cp.getManager("ConfigManager").getItemByKey("GangEnhance", career)
	if gender == 0 then
		modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", chartConfig:getValue("Role1"))
	else
		modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", chartConfig:getValue("Role2"))
    end
    
    local weapon = modelConfig:getValue("DefaultWeapon")
    local model = ViewManager.createSpineAnimation(modelConfig:getValue("ModelFile"), weapon)
    return model
end

function ViewManager.createModel(model)
    local modelConfig = cp.getManager("ConfigManager").getItemByKey("GameModel", model)
    
    local weapon = modelConfig:getValue("DefaultWeapon")
    local model = ViewManager.createSpineAnimation(modelConfig:getValue("ModelFile"), weapon)
    return model
end


--打開儲值界面
function ViewManager.showRechargeUI()
    
    local Recharge = require("cp.view.scene.world.vip.Recharge"):create()
    ViewManager.setAllCascadeOpacityEnabled(Recharge)
    cp.getManager("PopupManager"):addPopup(Recharge, true,nil,
        function()
        end
    )    
end

--打開神祕商店
function ViewManager.showMysticalStore()
    
    local MysticalStoreUI = require("cp.view.scene.world.shop.MysticalStoreUI"):create()
    ViewManager.setAllCascadeOpacityEnabled(MysticalStoreUI)
    cp.getManager("PopupManager"):addPopup(MysticalStoreUI, true,nil,
        function()
        end
    )    
end

--打開兌換禮包界面
function ViewManager.showExchangeGiftUI()
    
    local JiangHuGoExchangeGift = require("cp.view.scene.world.jianghugo.JiangHuGoExchangeGift"):create()
    ViewManager.setAllCascadeOpacityEnabled(JiangHuGoExchangeGift)
    JiangHuGoExchangeGift:setPosition(cc.p(display.cx,display.cy))
    cp.getManager("PopupManager"):addPopup(JiangHuGoExchangeGift, true,nil,
        function()
        end
    )    
end

function ViewManager.closeExchangeGiftUI()
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="JiangHuGoExchangeGift" then
            cp.getManager("PopupManager"):removePopup(node)
            return
        end
    end
end

--打開邀請好友界面
function ViewManager.showInviteUI()
    
    local JiangHuGoInvite = require("cp.view.scene.world.jianghugo.JiangHuGoInvite"):create()
    ViewManager.setAllCascadeOpacityEnabled(JiangHuGoInvite)
    JiangHuGoInvite:setPosition(cc.p(display.cx,display.cy))
    cp.getManager("PopupManager"):addPopup(JiangHuGoInvite, true,nil,
        function()
        end
    )    
end

--打開綁定邀請碼界面
function ViewManager.showInviteBind()
    
    local JiangHuGoInviteBind = require("cp.view.scene.world.jianghugo.JiangHuGoInviteBind"):create()
    ViewManager.setAllCascadeOpacityEnabled(JiangHuGoInviteBind)
    JiangHuGoInviteBind:setPosition(cc.p(display.cx,display.cy))
    cp.getManager("PopupManager"):addPopup(JiangHuGoInviteBind, true,nil,
        function()
        end
    )    
end


function ViewManager.setEnabled(btn, flag)
    btn:setEnabled(flag)
    if flag then
        ViewManager.setShader(btn, nil)
    else
        ViewManager.setShader(btn, "GrayShader")
    end
end

function ViewManager.setTouchClose(layer, panel, cb)
    panel:setTouchEnabled(true)
	panel:onTouch(function(event)
		if event.name == "ended" then
            if cb then
                cb()
            end
			layer:removeFromParent()
		end
	end)
end

function ViewManager.setTouchHide(layer, panel, cb)
	panel:onTouch(function(event)
		if event.name == "ended" then
            if cb then
                cb()
            end
			layer:setVisible(false)
		end
	end)
end

function ViewManager.createEffectAnimation(name, delayPerUnit, loops, frameStep)
    loops = loops or 1
    frameStep = frameStep or 1
    
	local fileName = "res/img/effect/"..name.."/"..name
	local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames(fileName..".plist", fileName..".png")
    
	local animation = cc.Animation:create()
	local frameList = {}
    local maxFrame = 0
    local lastFrame = nil
	for i=1, 60 do
		if i%frameStep == 0 then
			framePath = string.format("%s_%d.png", name, i)
            local frame = frameCache:getSpriteFrame(framePath)
            if frame then
                table.insert(frameList, frame)
                lastFrame = frame
            else
				if lastFrame then
					table.insert(frameList, lastFrame)
				else
					table.insert(frameList, false)
				end
            end

			if frame then
				maxFrame = i
			end
		end
	end

	for i=1, math.floor(maxFrame/frameStep) do
		local frame = frameList[i]
		if not frame then
			animation:addSpriteFrameWithFile("res/img/effect/alpha_0.png")
		else
			animation:addSpriteFrame(frame)
		end
	end

	animation:setDelayPerUnit(delayPerUnit)
    animation:setLoops(loops)
    return animation, maxFrame
end

function ViewManager.showWaitingLayer()
    
    ViewManager.removeWaitingLayer()
    local WaitingLayer = require("cp.view.scene.login.WaitingLayer"):create()
    WaitingLayer:setName("WaitingLayer")
    local currentScene = cc.Director:getInstance():getRunningScene()
    currentScene.top_root:addChild(WaitingLayer,9)

end

function ViewManager.removeWaitingLayer()
    local currentScene = cc.Director:getInstance():getRunningScene()
    local WaitingLayer = currentScene.top_root:getChildByName("WaitingLayer")
    if WaitingLayer then
        WaitingLayer:removeFromParent()
    end
end

--彈出購買體力窗口
function ViewManager.showBuyPhysicalUI()
    --購買體力
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local BuyPhysicalCost = cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("BuyPhysicalCost")
    local costList = string.split(BuyPhysicalCost,":")
    local idx = major_roleAtt.buyPhysical + 1 > #costList and #costList or major_roleAtt.buyPhysical + 1 
    local need = tonumber(costList[idx])
    local maxBuyTimes = cp.getUtils("DataUtils").GetVipEffect(1)
    local function comfirmFunc()
        if major_roleAtt.buyPhysical >= maxBuyTimes then
            local vip = cp.getUserData("UserVip"):getValue("level")
            local str = vip >= 15 and "今日可購買次數已達上限。" or "提升VIP等級可獲得更多購買次數。" 
            cp.getManager("ViewManager").gameTip(str)
            return
        end
        --檢測是否元寶足夠
        if cp.getManager("ViewManager").checkGoldEnough(need) then
            --發送購買體力協議
            local req = {}
            cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").BuyPhysicalReq, req)
        end
    end
    local contentTable = {
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text=tostring(need), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="購買120點體力？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        {type="blank",  blankSize=0.5},
        {type="ttf",  fontName="fonts/msyh.ttf",fontSize=24, text="今日已購次數 : " .. tostring(major_roleAtt.buyPhysical) .. " / " .. tostring(maxBuyTimes) , textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
    }
    cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)

end

--顯示時裝界面
function ViewManager.showFashionMainLayer(closeCallBack)

    local FashionMainLayer = require("cp.view.scene.world.fashion.FashionMainLayer"):create(openInfo)
    FashionMainLayer:setCloseCallBack(closeCallBack)
    cp.getManager("PopupManager"):addPopup(FashionMainLayer, true,nil,
		function()
			
		end)
end

function ViewManager.showFaceUnlockNotice(fashionID,closeCallBack)
    
    local FaceUnlockNotice = require("cp.view.ui.messagebox.FaceUnlockNotice"):create(fashionID)
    FaceUnlockNotice:setCloseCallBack(closeCallBack)
    cp.getManager("PopupManager"):addPopup(FaceUnlockNotice, true,nil,
        function()                
        end)
end

function ViewManager.setItemIcon(panel, id, num)
    local imgBG = panel:getChildByName("Image_bg")
    local imgIcon = panel:getChildByName("Image_icon")
    local imgQuality = panel:getChildByName("Image_quality")
    local imgPiece = panel:getChildByName("Image_suipian")
    local txtName = panel:getChildByName("Text_name")
    local txtNum = panel:getChildByName("Image_num"):getChildByName("Text_num")
    local itemEntry = cp.getManager("ConfigManager").getItemByKey("GameItem", id)
    ViewManager.setTextQuality(txtName, itemEntry:getValue("Hierarchy"))
    txtName:setString(itemEntry:getValue("Name"))
    if num and num > 0 then
        panel:getChildByName("Image_num"):setVisible(true)
        txtNum:setString(num)
    else
        panel:getChildByName("Image_num"):setVisible(false)
        --txtNum:setString(1)
    end
    imgBG:loadTexture(cp.getConst("CombatConst").QualityBottomList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
    imgQuality:loadTexture(cp.getConst("CombatConst").SkillBoxList[itemEntry:getValue("Hierarchy")], ccui.TextureResType.plistType)
    imgIcon:loadTexture(itemEntry:getValue("Icon"))
    if itemEntry:getValue("Type") == 2 then
        imgPiece:setVisible(true)
    else
        imgPiece:setVisible(false)
    end
    
    imgIcon:setTouchEnabled(true)
	cp.getManager("ViewManager").initButton(imgIcon, function()
		local layer = require("cp.view.scene.skill.SkillMatiralLayer"):create(itemEntry)
		layer:addTo(panel:getParent():getParent())
    end, 1.0)
end


function ViewManager.ShowEquipOperateLayer(index,closeCallBack)
    local nodes = cp.getManager("PopupManager"):getPopups()
    for i,node in ipairs(nodes) do
        if node.getDescription and node:getDescription()=="EquipOperateLayer" then
            node:switchTo(index)
            return
        end
    end

    local openInfo = {type = index}
    local EquipOperateLayer = require("cp.view.scene.world.equipoperate.EquipOperateLayer"):create(openInfo)
    EquipOperateLayer:setCloseCallBack(closeCallBack)
    cp.getManager("PopupManager"):addPopup(EquipOperateLayer, true,nil,
    function()           
        -- cp.getManager("PopupManager"):removePopup(EquipOperateLayer)
    end)
end

--顯示歷練結果
function ViewManager:showExerciseresult(data,isOffLine)
    if data ~= nil and data.info ~= nil and next(data.info) ~= nil then
        
        local name = ""
        local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
        local exerciseId = major_roleAtt.exerciseId
        local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",exerciseId)
        if cfg ~= nil then
            name = cfg:getValue("Name") or "此"
        end

        local GameConst = cp.getConst("GameConst")
        local contentTable = {}
        contentTable[1] = {type="ttf", fontSize=24, text=(isOffLine and "在離線期間，你在" or "你在"), textColor=GameConst.ContentTextColor, outLineEnable=false}
        contentTable[2] = {type="ttf", fontSize=24, text=name, textColor=GameConst.QualityTextColor[2], outLineColor=GameConst.QualityOutlineColor[2], outLineSize=2}
        if isOffLine then
            contentTable[3] = {type="ttf", fontSize=24, text="歷練，獲得以下獎勵", textColor=GameConst.ContentTextColor, outLineEnable=false}
        else
            contentTable[3] = {type="ttf", fontSize=24, text="快速歷練2小時，", textColor=GameConst.ContentTextColor, outLineEnable=false}
            contentTable[4] = {type="blank", fontSize=1}
            contentTable[5] = {type="ttf", fontSize=24, text="獲得以下獎勵", textColor=GameConst.ContentTextColor, outLineEnable=false}
        end
    
        local openInfo = {info = data.info, title = isOffLine and "離線歷練報告" or "快速歷練報告", content = contentTable}
        local LilianResultLayer = require("cp.view.scene.world.lilian.LilianResultLayer"):create(openInfo) 
        cp.getManager("PopupManager"):addPopup(LilianResultLayer, true,nil,
        function()           
            -- cp.getManager("PopupManager"):removePopup(LilianResultLayer)
        end)
    end
end

function ViewManager.setWidgetAdapt(designHeight, wigetList, height)
    if not height then
        height = display.height
    end
    local deltaHeight = height - designHeight
    for _, wiget in ipairs(wigetList) do
        local size = wiget:getSize()
        size.height = size.height + deltaHeight
        wiget:setSize(size)
    end
end

function ViewManager.popMessageBoxPanel(panel, title, content, confirmCallback, closeCallback)
    local layer = require("cp.view.ui.messagebox.GameMessagePanel"):create(title,content)
    layer:setCloseCallback(closeCallback)
    layer:setConfirmCallback(confirmCallback)
    panel:addChild(layer, 100)
end

function ViewManager.getVirtualItemIcon(type)
    -- self.type  1:銀兩 2:元寶 3：修為點(技能點)  ...  對應於伺服器的枚舉
    local VirtualItemType = cp.getConst("GameConst").VirtualItemType
    local iconList = {
        [VirtualItemType.silver]="ui_common_yinliang.png", 
        [VirtualItemType.gold]="ui_common_yuanbao.png",
        [VirtualItemType.trainPoint]="ui_common_xiuweidian.png",
        [VirtualItemType.learnPoint]="ui_common_lingwudian.png",
        [VirtualItemType.prestige]="ui_common_swz.png",   -- 聲望

        [VirtualItemType.goodPoint]="ui_common_sz.png",
        [VirtualItemType.badPoint]="ui_common_ez.png",
        [VirtualItemType.physical]="ui_common_tili.png",
        [VirtualItemType.exp]="ui_common_yueli.png",
        [VirtualItemType.sins]="", -- 罪惡值
                        
        [VirtualItemType.guildGold]="ui_common_bpzj.png", -- 幫派個人資金
        [VirtualItemType.totalGood]="ui_common_sz.png",
        [VirtualItemType.totalBad]="ui_common_ez.png",
        [VirtualItemType.fashion]="ui_common_module40_shizhuang_8.png",
        [VirtualItemType.normalEvent]="",  --善惡事件剩餘次數
        
        --16,
        [VirtualItemType.vip_exp]="",  --vip經驗
        [VirtualItemType.vip_level]="",  --vip等級
        [VirtualItemType.jade]="ui_common_module33_vip_goumai_yu.png",  --玄玉
        [VirtualItemType.vigor]="ui_common_yinliang.png",  --精力

        [VirtualItemType.guildExp]="ui_common_01_bpyl.png", -- 幫派經驗
        [VirtualItemType.guildContribute]="ui_common_bg.png", -- 幫派貢獻
        [VirtualItemType.taskPoint]="", -- 任務積分  img/icon/item/01_rcjf.png
        [VirtualItemType.tscy]="ui_common_06tscy.png"  -- 天書殘頁

    }
    return iconList[type]
end


--給輸入框添加事件，彈出自定義輸入框
function ViewManager.addTextFieldEvent(parent,textField,editBoxName,extraInfo)
    
    local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            local inputBox = parent:getChildByName(editBoxName)
            if inputBox then
                inputBox:removeFromParent()
                inputBox = nil
            end
            local openInfo = extraInfo or {}
            openInfo.editBoxName = editBoxName
            inputBox = require("cp.view.ui.tip.GameEditBox"):create(openInfo)
            inputBox:setCloseCallBack(function(name,text)
                if name == "Button_ok" then
                    -- if extraInfo and extraInfo.maxLength and tonumber(extraInfo.maxLength) then
                    --     if string.utf8len_m(text) > tonumber(extraInfo.maxLength) then
                    --         text = string.msubstr(text,tonumber(extraInfo.maxLength))
                    --     end
                    -- end
                    textField:setString(text)
                end
                textField:setTouchEnabled(true)
                inputBox:hideKeyBoard()
                inputBox:removeFromParent()
                inputBox = nil

                if extraInfo and extraInfo.hideCallBack then
                    extraInfo.hideCallBack()
                end

            end)
            parent:addChild(inputBox,1)
            inputBox:setPosition(cc.p(0,0))
            if extraInfo and extraInfo.pos then
                inputBox:setPosition(extraInfo.pos)
            end
    
            textField:setTouchEnabled(false)
            inputBox:setInitText(textField:getString())
            inputBox:showKeyBoard()
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            
        elseif eventType == ccui.TextFiledEventType.insert_text then
            
        elseif eventType == ccui.TextFiledEventType.delete_backward then
            
        end
    end

    textField:setTouchEnabled(true)
    textField:addEventListener(textFieldEvent)
end

function ViewManager.openGuideLayer(layer, widget, delay)
    local guideLayer = require("cp.view.scene.newguide.GuideLayer"):create(widget, delay or 0)
    layer:addChild(guideLayer, 100)
    return guideLayer
end

--顯示一個手指動畫
function ViewManager.showGuideFinger(parent,pos)
    -- local fingerGuideNode = parent:getChildByName("finger")
    -- if fingerGuideNode == nil then
    --     fingerGuideNode = require("cp.view.scene.newguide.FingerGuideNode"):create()
    --     fingerGuideNode:setName("finger")
    --     parent:addChild(fingerGuideNode,1)
    --     fingerGuideNode:setPosition(cc.p(0,0))
    -- end
    -- local finger_info = {pos = pos or cc.p(0,0), finger = {guide_type = "point",dir="right"} }
    -- fingerGuideNode:reset(finger_info)
    -- fingerGuideNode:setVisible(true)

    local image_head = ccui.ImageView:create()
    image_head:ignoreContentAdaptWithSize(true)
    image_head:loadTexture("ui_mapbuild_module21_yabiao_20.png",UI_TEX_TYPE_PLIST)
    parent:addChild(image_head,1)
    image_head:setName("finger")
    image_head:setPosition(pos)

    local act1 = cc.MoveTo:create(0.8,cc.p(pos.x,pos.y+10))
    local act2 = cc.EaseSineOut:create(act1)
    local act3 = cc.MoveTo:create(0.8,cc.p(pos.x,pos.y))
    local act4 = cc.EaseSineOut:create(act3)
    local acts = {act2,act4}
    local action = cc.Sequence:create(acts)
    local action2 = cc.RepeatForever:create(action)

    -- local move = cc.MoveTo:create(1, cc.p(pos.x,pos.y+10))
	-- local move2 = cc.MoveTo:create(0.5, cc.p(pos.x,pos.y-10))
	-- local delay1 = cc.DelayTime:create(0.3)
	-- local delay2 = cc.DelayTime:create(0.5)
	-- local action2 = cc.RepeatForever:create(cc.Sequence:create(move,delay1,move2,delay2))
    image_head:runAction(action2)
    
end

function ViewManager.createPicAnimation(resList, delayPerUnit, loops)
    loops = loops or 1
	local animation = cc.Animation:create()
	for i=1, #resList do
        animation:addSpriteFrameWithFile(resList[i])
    end

	animation:setDelayPerUnit(delayPerUnit)
    animation:setLoops(loops)
    return animation
end

function ViewManager.updatePrimevalInfo(metaInfo, node)
    local txtLevel = imgPlace:getChildByName("Text_Level")
    local txtName = imgPlace:getChildByName("Text_Name")
    local imgColor = imgPlace:getChildByName("Image_Color")
    local imgFlag = imgPlace:getChildByName("Image_Flag")
    local imgTag = imgPlace:getChildByName("Image_Tag")
end

function ViewManager.fightTip(oldFight, newFight)
    local deltaY = 100
    local tiper = nil

	if ViewManager.fightTiper ~= nil then
        cp.getManager("PopupManager"):removePopup(ViewManager.fightTiper)
	end

	tiper = require("cp.view.ui.tip.FightTip"):create()
	ViewManager.fightTiper = tiper
	ViewManager.setAllCascadeOpacityEnabled(tiper)
	cp.getManager("PopupManager"):addPopup(tiper, false)

    tiper:setText(oldFight, newFight)
    tiper:setPosition(cc.p(display.cx,display.cy))
    tiper:setOpacity(255)
    tiper:setScaleY(0.8)
    tiper:setScaleX(0.8)

	--放大
    local repeatTimes = 0.2*60
	local scalet = 0.1 --放大時間
    local sequence = {}
    local act = cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
		--其他的gameTip上頂
        for _, _tiper in ipairs(ViewManager.multiTipers) do
            if _tiper == tiper then
                break
            end
            local posY = _tiper:getPositionY()+deltaY/repeatTimes
            _tiper:setPositionY(posY)
        end
		--逐漸放大,總計放大 0.2 = 0.2 / repeatTimes * repeatTimes
        tiper:setScaleY(tiper:getScaleY()+0.2/repeatTimes)
        tiper:setScaleX(tiper:getScaleX()+0.2/repeatTimes)
    end), cc.DelayTime:create(scalet/repeatTimes)), repeatTimes)
    table.insert(sequence, act)
	--延時
    act = cc.DelayTime:create(0.3)
    table.insert(sequence, act)
	--數字跳動
	local nrpts = 60 --跳動次數
	local ts = 0.5   --跳動總時長
	local ct = 0.4   --跳動中差值出現時間點
	local cot = 0
	local dela = math.ceil(math.abs((newFight - oldFight) / nrpts))
	if oldFight > newFight then
		dela = -dela
	end
	act = cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
		--顯示數字
		tiper:setNewFight(oldFight + cot * dela)
		cot = cot + 1
		if cot == nrpts then
			tiper:setNewFight(newFight)
		end
		--顯示差值
		if cot * ts/nrpts >= ct then
			tiper:showChange()
		end
	end), cc.DelayTime:create(ts/nrpts)), nrpts)
    table.insert(sequence, act)
	--延時
    act = cc.DelayTime:create(1)
    table.insert(sequence, act)
	--移動
    act = cc.MoveBy:create(0.5, cc.vec3(0, 50, 0))
    table.insert(sequence, act)
	--變淡
    act = cc.FadeTo:create(0.2, 0)
    table.insert(sequence, act)
	--刪除
    act = cc.CallFunc:create(function()
        cp.getManager("PopupManager"):removePopup(tiper)
    end)
    table.insert(sequence, act)

    tiper:runAction(cc.Sequence:create(sequence))
end


return ViewManager
