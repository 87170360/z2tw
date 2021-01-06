--[====[
CellView ： 支持多行多列的TableView
使用方法：

local CellView = require("cp.view.ui.base.CellView")
local cellView = CellView:create(cc.size(400,400))
cellView:setCellCount(30)          --設置子元素個數，也可以通過setCountFunction方式動態變化個數。
cellView:setCellSize(100,100)       --設置子元素長寬
cellView:setColumnCount(3)      --設置子元素一行顯示的個數,如不設置，則自動計算一行顯示多少個
--cellView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)     --設置滑動方向，默認 cc.SCROLLVIEW_DIRECTION_VERTICAL 
local function cellFactory(cellview, idx)
        local cell = cellview:dequeueCell()
        local item
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = cc.Sprite:create()
            item:setName("item")
            cell:addChild(item)
        else
            item = cell:getChildByName("item")
        end
        return cell
end
cellView:setCellFactory(cellFactory)        --設置刷新子元素的方法，參考TableView的事例
cellView:reloadData()       --刷新數據


    -- void setContentOffset(Vec2 offset, bool animated = false);
    -- Vec2 getContentOffset();
        -- void setContentOffsetInDuration(Vec2 offset, float dt); 
]====]



local CellView = class("CellView",function(...)return cp.CpCellView:create(...) end)

function CellView:create(size)
    local ret = CellView.new(size)
    ret:init()
    return ret
end

function CellView:init()
    self:getContainer():setLocalZOrder(-1)
    self:setDelegate()
    --self:setCellSize(100,100)
end

--設置子元素個數，也可以通過setCountFunction方式動態變化個數。
function CellView:setCellCount(cnt)
    local function countFunction(cellview)
        return cnt
    end
    self:setCountFunction(countFunction)
end

-- local function countFunction(cellview)
--     return 30
-- end
--設置獲取子元素個數的函數
function CellView:setCountFunction(func)
    if func then
        self:registerScriptHandler(func , cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    else
        self:unregisterScriptHandler(cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    end
end


-- local function cellFactory(cellview, idx)
--         local cell = cellview:dequeueCell()
--         local item
--         if nil == cell then
--             cell = cc.TableViewCell:new()
--             item = cc.Sprite:create()
--             item:setName("item")
--             cell:addChild(item)
--         else
--             item = cell:getChildByName("item")
--         end
--         return cell
--     end
-- end
--設置刷新子元素的方法
function CellView:setCellFactory(func)
    if func then
        self:registerScriptHandler(func , cc.TABLECELL_SIZE_AT_INDEX)
    else
        self:unregisterScriptHandler(cc.TABLECELL_SIZE_AT_INDEX)  
    end
end

-- local function scrollFunction(cellview)
--     return 
-- end
--設置監聽滾動事件的方法
function CellView:setScrollFunction(func)
    if func then
        self:registerScriptHandler(func , cc.SCROLLVIEW_SCRIPT_SCROLL)  
    else
        self:unregisterScriptHandler(cc.SCROLLVIEW_SCRIPT_SCROLL)  
    end
end

-- local function zoomFunction(cellview)
--     return 
-- end
--設置監聽縮放事件的方法
function CellView:setZoomFunction(func)
    if func then
        self:registerScriptHandler(func , cc.SCROLLVIEW_SCRIPT_ZOOM)  
    else
        self:unregisterScriptHandler(cc.SCROLLVIEW_SCRIPT_ZOOM)  
    end
end

-- local function cellFunction(cellview , tableViewCell)
--     return 
-- end
--設置監聽觸摸子元素事件的方法
function CellView:setCellTouchFunction(func)
    if func then
        self:registerScriptHandler(func , cc.TABLECELL_TOUCHED)  
    else
        self:unregisterScriptHandler(cc.TABLECELL_TOUCHED)  
    end
end

-- local function cellFunction(cellview , tableViewCell)
--     return 
-- end
--設置監聽子元素高亮事件的方法
function CellView:setCellHighLightFunction(func)
    if func then
        self:registerScriptHandler(func , cc.TABLECELL_HIGH_LIGHT)  
    else
        self:unregisterScriptHandler(cc.TABLECELL_HIGH_LIGHT)  
    end
end


-- local function cellFunction(cellview , tableViewCell)
--     return 
-- end
--設置監聽取消子元素高亮事件的方法
function CellView:setCellUnHighLightFunction(func)
    if func then
        self:registerScriptHandler(func , cc.TABLECELL_UNHIGH_LIGHT)  
    else
        self:unregisterScriptHandler(cc.TABLECELL_UNHIGH_LIGHT)  
    end
end


-- local function cellFunction(cellview , tableViewCell)
--     return 
-- end
--設置監聽子元素回收事件的方法
function CellView:setCellWillRecycleFunction(func)
    if func then
        self:registerScriptHandler(func , cc.TABLECELL_WILL_RECYCLE)  
    else
        self:unregisterScriptHandler(cc.TABLECELL_WILL_RECYCLE)  
    end
end

--設置子元素長寬
-- function CellView:setCellSize(w , h)
--     if y == nil then
--         CellView.super.setCellSize(self , w)
--     else
--         CellView.super.setCellSize(self , w , h)
--     end
-- end

--設置子元素一行顯示的個數,如不設置，則自動計算一行顯示多少個
-- function CellView:setColumnCount(cnt)
--     CellView.super.setColumnCount(self, cnt)
-- end

--刷新數據
-- function CellView:reloadData()
--     CellView.super.reloadData(self,)
-- end


return CellView

