local BaseData = require("cp.data.BaseData")
local GameWorldMap = class("GameWorldMap",BaseData)

function GameWorldMap:create()
    local ret =  GameWorldMap.new()
    ret:init()
    return ret
end

function GameWorldMap:init()
	 
    self["roadPointInfo"] = {}  --路徑點訊息列表

    --背景圖縮放與錨點訊息
    self["lastScale"] = 2.0    --保存上次背景縮放比例,第一次打開默認2
    self["bgCurrentAnchorPoint"] = cc.p(0,0) --背景圖的錨點

    -- 多點觸摸訊息
    self["touchPointes"]  = {}  -- 當前觸摸的點的座標(可能會有多個點)
    self["isAltKeyPressed"] = false -- 是否按住左ALT鍵(windows和mac模擬縮放)
    
    self["roleStayPoint"] = cc.p(0,0) --主角當前停留在世界地圖的位置

    self["npc_liit"] = {}   --保存npc列表
    
    local cfg = {}	
    self:addProtectedData(cfg)
end

return GameWorldMap