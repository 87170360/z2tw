local BaseData = require("cp.data.BaseData")
local GameNewGuide = class("GameNewGuide",BaseData)

function GameNewGuide:create()
    local ret =  GameNewGuide.new() 
    ret:init()
    return ret
end

function GameNewGuide:init()

    local cfg = {
		["cur_step"] = 0, --某個模塊指引中正進行的步數
		["max_step"] = 0, --某個模塊指引中最大步數
        ["cur_guide_module_name"] = "",  --當前正在進行的引導de模塊名字
		
        ["cur_guide_index"] = 0,  --最新引導的索引(本地保存，不一定正在進行)

        ["cur_story_index"] = 0,  --當前對話的索引 (對應於story.xlsx中的cid)
        
        ["step_skip_mode"] = 0, --跳過步驟模式
	}
    self:addProtectedData(cfg)
end

return GameNewGuide