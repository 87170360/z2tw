local BLayer = require "cp.view.ui.base.BLayer"
local ArenaBufferLayer = class("ArenaBufferLayer", BLayer)
local CombatConst = cp.getConst("CombatConst")

function ArenaBufferLayer:create(rankList)
    local scene = ArenaBufferLayer.new()
    scene.rankList = rankList
	scene:updateArenaBufferView()
    return scene
end

function ArenaBufferLayer:initListEvent()
    self.listListeners = {
        [cp.getConst("EventConst").BuyBufferRsp] = function(data)
            self:updateArenaBufferView()
		end,
    }
end

--初始化界面，以及設定界面元素標籤
function ArenaBufferLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_arena/uicsb_arena_buffer.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)
    
    --一開始顯示武學抽獎界面
    self.mode = 1

    local childConfig = {
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_1.Button_Close"] = {name = "Button_Close", click="onBtnClick"},
		["Panel_root.Image_1.Node_1"] = {name = "Node_1"},
		["Panel_root.Image_1.Node_2"] = {name = "Node_2"},
		["Panel_root.Image_1.Node_3"] = {name = "Node_3"},
		["Panel_root.Image_1.Node_4"] = {name = "Node_4"},
		["Panel_root.Image_1.Node_5"] = {name = "Node_5"},
	}

    cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)
	ccui.Helper:doLayout(self.rootView)
    cp.getManager("ViewManager").popUpViewEx(self.Image_1)
end

function ArenaBufferLayer:updateArenaBufferView()
    local arenaConfig = string.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("ArenaConfig"), ";")
    local bufferList = string.split(arenaConfig[3], ":")
    for i=1, 5 do
        local txt8 = self["Node_"..i]:getChildByName("Text_8")
        local button = self["Node_"..i]:getChildByName("Button_Buy")
        local bufferID = tonumber(bufferList[i])
        local bufferNum = cp.getUserData("UserArena"):getBufferNum(bufferID)
        if i==1 then
            txt8:setString("最多提高50%,當前提高"..(bufferNum*10).."%")
        elseif i==2 then
            txt8:setString("最多提高50%,當前提高"..(bufferNum*10).."%")
        elseif i==3 then
            txt8:setString("最多提高100%,當前提高"..(bufferNum*20).."%")
        elseif i==4 then
            txt8:setString("最多提高100%,當前提高"..(bufferNum*20).."%")
        else
            txt8:setString("最多提高25%,當前提高"..(bufferNum*5).."%")
        end

        cp.getManager("ViewManager").initButton(button, function()
            local req = {}
            req.buffer = bufferID
		    self:doSendSocket(cp.getConst("ProtoConst").BuyBufferReq, req)
        end)
    end
end

function ArenaBufferLayer:onBtnClick(btn)
    local nodeName = btn:getName()
	if nodeName == "Button_Close" then
        self:removeFromParent()
    elseif nodeName == "Button_Fight" then
	end
end

function ArenaBufferLayer:onEnterScene()
end

function ArenaBufferLayer:onExitScene()
    self:unscheduleUpdate()
end

return ArenaBufferLayer