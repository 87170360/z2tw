--Tween方法

local TweenFunc = {}

function TweenFunc.checkTime(time)
    time = time or 1
    if time<0 then
        time = 0
    elseif time>1 then
        time = 1
    end
    return time
end

function TweenFunc.linear(time)
    time = TweenFunc.checkTime(time)
    return time
end

function TweenFunc.sineEaseIn(time)
    time = TweenFunc.checkTime(time)
    return  -1 * math.cos(time * math.pi/2) + 1
end

function TweenFunc.sineEaseOut(time)
    time = TweenFunc.checkTime(time)
    return  math.sin(time * math.pi/2)
end

function TweenFunc.sineEaseInOut(time)
    time = TweenFunc.checkTime(time)
    return  -0.5 * (math.cos(math.pi* time) - 1)
end

function TweenFunc.quadEaseIn(time)
    time = TweenFunc.checkTime(time)
    return  time * time
end

function TweenFunc.quadEaseOut(time)
    time = TweenFunc.checkTime(time)
    return  -1 * time * (time - 2)
end

function TweenFunc.quadEaseInOut(time)
    time = time*2
    if time < 1 then
        return 0.5 * time * time
    end
    time = time - 1
    return -0.5 * (time * (time - 2) - 1)
end

function TweenFunc.cubicEaseIn(time)
    time = TweenFunc.checkTime(time)
    return  time * time * time
end

function TweenFunc.cubicEaseOut(time)
    time = TweenFunc.checkTime(time)
    time = time - 1
    return (time * time * time + 1)
end

function TweenFunc.cubicEaseInOut(time)
    time = TweenFunc.checkTime(time)
    time = time*2
    if (time < 1) then
        return 0.5 * time * time * time
    end
    time = time - 2
    return 0.5 * (time * time * time + 2)
end

function TweenFunc.quartEaseIn(time)
    time = TweenFunc.checkTime(time)
    return   time * time * time * time
end

function TweenFunc.quartEaseOut(time)
    time = TweenFunc.checkTime(time)
    time = time - 1
    return -(time * time * time * time - 1)
end

function TweenFunc.quartEaseInOut(time)
    time = TweenFunc.checkTime(time)
    time = time*2
    if (time < 1) then
        return 0.5 * time * time * time * time
    end
    time = time -2
    return -0.5 * (time * time * time * time - 2)
end

function TweenFunc.quintEaseIn(time)
    time = TweenFunc.checkTime(time)
    return    time * time * time * time * time
end

function TweenFunc.quintEaseOut(time)
    time = TweenFunc.checkTime(time)
    time =time -1
    return (time * time * time * time * time + 1)
end

function TweenFunc.quintEaseInOut(time)
    time = TweenFunc.checkTime(time)
    time = time*2
    if time < 1 then
        return 0.5 * time * time * time * time * time
    end
    time = time - 2
    return 0.5 * (time * time * time * time * time + 2)
end

function TweenFunc.expoEaseIn(time)
    time = TweenFunc.checkTime(time)
    if time ==0 then
        return 0
    else
        return  math.pow(2, 10 * (time/1 - 1)) - 1 * 0.001
    end
end

function TweenFunc.expoEaseOut(time)
    time = TweenFunc.checkTime(time)
    if time ==1 then
        return 1
    else
        return (-math.pow(2, -10 * time / 1) + 1)
    end
end

function TweenFunc.expoEaseInOut(time)
    time = TweenFunc.checkTime(time)
    time = time / 0.5
    if time < 1 then
        time = 0.5 * math.pow(2, 10 * (time - 1))
    else
        time = 0.5 * (-math.pow(2, -10 * (time - 1)) + 2)
    end
    return time
end

function TweenFunc.circEaseIn(time)
    time = TweenFunc.checkTime(time)
    return -1 * (math.sqrt(1 - time * time) - 1)
end

function TweenFunc.circEaseOut(time)
    time = TweenFunc.checkTime(time)
    time = time - 1
    return math.sqrt(1 - time * time)
end

function TweenFunc.circEaseInOut(time)
    time = TweenFunc.checkTime(time)
    time = time * 2
    if (time < 1) then
        return -0.5 * (math.sqrt(1 - time * time) - 1)
    end
    time =  time - 2
    return 0.5 * (math.sqrt(1 - time * time) + 1)
end

function TweenFunc.elasticEaseIn(time,period)
    time = TweenFunc.checkTime(time)
    period = period or 0.3
    local newT = 0
    if (time == 0 or time == 1) then
        newT = time
    else
        local s = period / 4
        time = time - 1
        newT = -math.pow(2, 10 * time) * math.sin((time - s) * math.pi *2/ period)
    end
    return newT
end

function TweenFunc.elasticEaseOut(time,period)
    time = TweenFunc.checkTime(time)
    period = period or 0.3
    local newT = 0
    if (time == 0 or time == 1) then
        newT = time
    else
        local s = period / 4
        newT = math.pow(2, -10 * time) *  math.sin((time - s) * math.pi *2 / period) + 1
    end
    return newT
end

function TweenFunc.elasticEaseInOut(time,period)
    time = TweenFunc.checkTime(time)
    period = period or 0.3
    local newT = 0
    if (time == 0 or time == 1) then
        newT = time
    else
        time = time * 2
        if (not period) then
            period = 0.3 * 1.5
        end

        local s = period / 4

        time = time - 1
        if (time < 0) then
            newT = -0.5 * math.pow(2, 10 * time) * math.sin((time -s) *  math.pi *2 / period)
        else
            newT = math.pow(2, -10 * time) * math.sin((time - s) *  math.pi *2 / period) * 0.5 + 1
        end
    end
    return newT
end

function TweenFunc.backEaseIn(time)
    time = TweenFunc.checkTime(time)
    local overshoot = 1.70158
    return time * time * ((overshoot + 1) * time - overshoot)
end

function TweenFunc.backEaseOut(time)
    time = TweenFunc.checkTime(time)
    local overshoot = 1.70158
    time = time - 1
    return time * time * ((overshoot + 1) * time + overshoot) + 1
end

function TweenFunc.backEaseInOut(time)
    time = TweenFunc.checkTime(time)
    local overshoot = 1.70158 * 1.525
    time = time * 2
    if (time < 1) then
        return (time * time * ((overshoot + 1) * time - overshoot)) / 2
    else
        time = time - 2;
        return (time * time * ((overshoot + 1) * time + overshoot)) / 2 + 1
    end
end

function TweenFunc.bounceTime(time)
    time = TweenFunc.checkTime(time)
    if (time < 1 / 2.75) then
        return 7.5625 * time * time
    elseif (time < 2 / 2.75) then
        time = time -1.5 / 2.75
        return 7.5625 * time * time + 0.75
    elseif (time < 2.5 / 2.75) then
        time = time - 2.25 / 2.75
        return 7.5625 * time * time + 0.9375
    end
    time = time - 2.625 / 2.75
    return 7.5625 * time * time + 0.984375
end

function TweenFunc.bounceEaseIn(time)
    time = TweenFunc.checkTime(time)
    return 1 - TweenFunc.bounceTime(1 - time)
end

function TweenFunc.bounceEaseOut(time)
    time = TweenFunc.checkTime(time)
    return TweenFunc.bounceTime(time)
end

function TweenFunc.bounceEaseInOut(time)
    time = TweenFunc.checkTime(time)
    local newT = 0
    if (time < 0.5) then
        time = time * 2
        newT = (1 - TweenFunc.bounceTime(1 - time)) * 0.5
    else
        newT = TweenFunc.bounceTime(time * 2 - 1) * 0.5 + 0.5
    end
    return newT
end

function TweenFunc.easeIn(time,rate)
    time = TweenFunc.checkTime(time)
    rate = rate or 2
    return math.pow(time, rate)
end

function TweenFunc.easeOut(time,rate)
    time = TweenFunc.checkTime(time)
    rate = rate or 2
    return math.pow(time, 1 / rate)
end

function TweenFunc.easeInOut(time,rate)
    time = TweenFunc.checkTime(time)
    time = time * 2
    if (time < 1) then
        return 0.5 * math.pow(time, rate)
    else
        return (1.0 - 0.5 * math.pow(2 - time, rate))
    end
end

function TweenFunc.quadraticIn(time)
    time = TweenFunc.checkTime(time)
    return math.pow(time,2)
end

function TweenFunc.quadraticOut(time)
    time = TweenFunc.checkTime(time)
    return -time*(time-2)
end

function TweenFunc.quadraticInOut(time)
    time = TweenFunc.checkTime(time)
    local resultTime = time
    time = time*2
    if (time < 1) then
        resultTime = time * time * 0.5
    else
        time = time - 1
        resultTime = -0.5 * (time * (time - 2) - 1)
    end
    return resultTime
end

function TweenFunc.bezieratFunction(  a,  b,  c,  d,  t )
    return (math.pow(1-t,3) * a + 3*t*(math.pow(1-t,2))*b + 3*math.pow(t,2)*(1-t)*c + math.pow(t,3)*d )
end

return TweenFunc
