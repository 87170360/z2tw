require "cocos.cocos2d.json"
local CombatConst = cp.getConst("CombatConst")
local CombatStory = {}

function CombatStory:init(layer, storyList, controller)
    self.storyList = storyList
    --當前的對話ID
    self.dialog = 1
    --當前對話的持續時間
    self.dialogDuration = 0
    self.layer = layer
    self.controller = controller
    self.storyInfo  =  nil
    self.storyConfig = nil
    self.talkID = 1
    self.state = 0
end

--每一幀調用
function CombatStory:updateStory(dt)
    -- if not self.storyInfo or not self.storyConfig then
    --     self.state = 0
    --     return
    -- end

    -- self.dialogDuration = self.dialogDuration + dt
    -- local dialogInfo = self.storyInfo.talk[self.talkID]
    -- if self.dialogDuration > dialogInfo.duration then
    --     if self.talkID >= #self.storyInfo.talk then
    --         self.state = 1
    --     else
    --         self.talkID = self.talkID + 1
    --     end
    -- else
    --     self:updateDialog(dialogInfo)
    -- end
end


function CombatStory:setStory(storyConfig)
    
    self.dialog = 1
    self.dialogDuration = 0
    self.talkID = 0

    self.storyConfig = storyConfig
    self.storyInfo = nil
    local StoryID = storyConfig:getValue("StoryID")
    if StoryID <= 0 then
        return
    end
    local packageName = string.format("cp.story.GameStory%d", StoryID)
    local status, gameStory = xpcall(function()
            return require(packageName)
        end, function(msg)
        --if not string.find(msg, string.format("'%s' not found:", packageName)) then
            print("load view error: ", msg)
        --end
    end)
   
    self.storyInfo = gameStory
    if not self.storyInfo then
        return
    end
     cp.getManager("EventManager"):dispatchEvent("VIEW", cp.getConst("EventConst").combat_show_story, gameStory)
    return
end

function CombatStory:getStory(stage, occasion, round, maxRound)
    if self.storyList == nil then
        return nil
    end

    if cp.getUserData("UserCombat"):getCombatDifficulty() == 1 and
        cp.getUserData("UserCombat"):getCombatType() == 1 then
        return nil
    end

    for i, storyConfig in ipairs(self.storyList) do
        if stage ~= storyConfig:getValue("Stage") then
            return nil
        end

        if storyConfig:getValue("Occasion") == occasion then
            if occasion == 0 and storyConfig:getValue("Round") == round then
                table.remove(self.storyList, i)
                return storyConfig
            end
            if occasion == 1 then
                if round == maxRound + storyConfig:getValue("Round") then
                    table.remove(self.storyList, i)
                    return storyConfig
                end
            end
        end
    end

    return nil
end

return CombatStory