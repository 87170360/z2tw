local DynamicProgressBar = {}
local mt = { __index = DynamicProgressBar }

function DynamicProgressBar:create(bar, text, isRound)
    return setmetatable({ text = text, bar=bar, isRound=isRound }, mt)
end

function DynamicProgressBar:initProgress(maxValue, curValue)
    if self.text then
        self.text:setString(string.format("%d/%d", curValue, maxValue))
    end
    self.bar:stopAllActions()
    self.bar:setPercent(curValue*100/maxValue)
    self.curValue = curValue
    self.maxValue = maxValue
    self.toValue = curValue
end

function DynamicProgressBar:updateProgress(maxValue, deltaValue, deltaTime)
    if deltaTime == 0 and deltaValue ~= 0 then
        deltaTime = 0.01
    end
    if maxValue then
        self.maxValue = maxValue
    end
    self.bar:stopAllActions()
    self.toValue = self.toValue + deltaValue

    if self.toValue > self.maxValue and not self.isRound then
        self.toValue = self.maxValue
    end

    if self.toValue < 0 then
        self.toValue = 0
    end

    if self.debug then
        log("updateProgress:"..self.bar:getName()..",maxValue="..self.maxValue..",toValue="..self.toValue..",curValue="..self.curValue)
    end

    if self.toValue == self.curValue then
        return
    end
    
    local toValue = self.toValue
    if self.toValue > self.maxValue then
        toValue = self.maxValue
    end
    local dtValue = (self.toValue-self.curValue)/(deltaTime*40)
    self.bar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/40), cc.CallFunc:create(function()
        self.curValue = self.curValue + dtValue
        if self.debug then
            log("runAction:"..self.bar:getName()..",toValue="..self.toValue..",curValue="..self.curValue)
        end
        if dtValue > 0 then
            if self.curValue > toValue then
                self.curValue = toValue
                self.bar:stopAllActions()
                if self.curValue >= toValue and self.isRound then
                    self.toValue = self.toValue % self.maxValue
                    self.curValue = self.curValue % self.maxValue
                end
            end
        else
            if self.curValue < self.toValue then
                self.curValue = self.toValue
                self.bar:stopAllActions()
            end
        end

        if self.text then
            self.text:setString(string.format("%d/%d", self.curValue, self.maxValue))
        end
        self.bar:setPercent(self.curValue*100/self.maxValue)
    end))))
end

return DynamicProgressBar