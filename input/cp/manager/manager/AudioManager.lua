local AudioManager = class("AudioManager")

function AudioManager:create()
    local ret =  AudioManager.new() 
    ret:init()
    return ret
end  

function AudioManager:init()
    -- 背景音樂
    self.musicName = ""
    -- 音效{name="",hash=109088123451}
    self.sounds={}
    
    -- 聲音路徑
    self.soundPath = "audio/"
    
end


function AudioManager:onExit()
    self:uncacheAll()
    -- ccexp.AudioEngine:endToLua()
end

function AudioManager:uncacheAll()
    self:unloadEffects()
    self:stopMusic(true)
    self.musicName = ""
end

function AudioManager:getSoundSwitch()
    local musicEnable = cp.getManager("LocalDataManager"):getPublicValue("gamesetting","musicEnable",true)
    return musicEnable
end

function AudioManager:getEffectSwitch()
    -- return cp.getGameData("GamePlayerSystem"):getValue("effect",true) 
    local effectEnable = cp.getManager("LocalDataManager"):getPublicValue("gamesetting","effectEnable",true)
    return effectEnable
end

function AudioManager:setSoundSwitch(bSwitch)
    bSwitch = bSwitch or false
    local curSwitch = self:getSoundSwitch()
    if bSwitch ~= curSwitch then
        cp.getManager("LocalDataManager"):setPublicValue("gamesetting","musicEnable",bSwitch)
        self:stopMusic(true)
        if bSwitch then    
            local fileName = self.musicName
            if fileName == nil or fileName == "" then
                fileName = cp.getManualConfig("AudioConfig").bg_main  
            end
            self.musicName = ""
            self:playMusic(fileName,true)
        end
    end
end

function AudioManager:setEffectSwitch(bSwitch)
    bSwitch = bSwitch or false
    local curSwitch = self:getEffectSwitch()
    if bSwitch ~= curSwitch then
        cp.getManager("LocalDataManager"):setPublicValue("gamesetting","effectEnable",bSwitch)
        if bSwitch then            
            -- ccexp.AudioEngine:resumeAll()
            cc.SimpleAudioEngine:getInstance():resumeAllEffects()
        else
            -- ccexp.AudioEngine:pauseAll() 
            cc.SimpleAudioEngine:getInstance():pauseAllEffects()
        end
    end
end

function AudioManager:setMusicVolume(fMusicVolume)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(fMusicVolume)
end

function AudioManager:stopMusic(isReleaseData)
    cc.SimpleAudioEngine:getInstance():stopMusic(isReleaseData)   
end

--播放背景音樂
function AudioManager:playMusic(filename, isLoop)
    
    local curSwitch = self:getSoundSwitch()
    if not curSwitch then   --關閉音樂
        self:stopMusic(true)
        self.musicName = ""
        return
    end

    local volume = 1
    if self.musicName ~= filename then
        log("music volume="..volume)
        cc.SimpleAudioEngine:getInstance():stopMusic(true)
        local filePath = self.soundPath .. filename
        cc.SimpleAudioEngine:getInstance():preloadMusic(filePath)
        cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
        cc.SimpleAudioEngine:getInstance():playMusic(filePath, isLoop)  
        self.musicName = filename
    end 
    
      
end


function AudioManager:setEffectsVolume(fEffectVolume)
    -- ccexp.AudioEngine:setVolume(fEffectVolume)
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(fEffectVolume)
end


function AudioManager:unloadEffects()
    -- ccexp.AudioEngine:uncacheAll()

    for i,v in pairs(self.sounds) do
        cc.SimpleAudioEngine:getInstance():unloadEffect(v.hash)    
    end
    
    self.sounds={}
end


--播放音效
function AudioManager:playEffect(filename, isLoop)
    local curSwitch = self:getEffectSwitch()
    if not curSwitch then   --關閉音樂
        self:stopAllEffects()
        self.sounds={}
        return
    end

	isLoop = isLoop or false
    
    local filePath = self.soundPath .. filename
    -- log("AudioManager:playEffect filePath = " .. tostring(filePath))
    local volume = 1
    --ccexp.AudioEngine:preload(filePath,nil)
    --local effectId = ccexp.AudioEngine:play2d(filePath,isLoop,volume)
    -- log("effect volume="..volume)

    cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
    self:stopEffect(filename)
    cc.SimpleAudioEngine:getInstance():preloadEffect(filePath)
    local effectId = cc.SimpleAudioEngine:getInstance():playEffect(filePath,isLoop)
    self.sounds[effectId] = {name=filename,hash=effectId}
end

function AudioManager:stopEffect(filename)
    local hash = self:findEffectByName(filename)
    -- log("AudioManager:stopEffect hash = " .. tostring(hash))
    if hash and hash > 0 then
        cc.SimpleAudioEngine:getInstance():stopEffect(hash)
        --ccexp.AudioEngine:stop(hash)
        --cc.SimpleAudioEngine:getInstance():stopEffect(hash)
        self.sounds[hash] = nil
    end
end

function AudioManager:stopAllEffects()
    --ccexp.AudioEngine:stopAll()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    self.sounds={}
end

--通過音效名查找內存中的音效
function AudioManager:findEffectByName(filename)
    for i,v in pairs(self.sounds) do
        if filename == v.name then
            return v.hash
        end
    end
    return nil
end


return AudioManager
