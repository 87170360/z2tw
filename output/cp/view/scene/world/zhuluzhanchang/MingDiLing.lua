
local BNode = require "cp.view.ui.base.BNode"
local MingDiLing = class("MingDiLing",BNode)

function MingDiLing:create()
	local node = MingDiLing.new()
	return node
end

function MingDiLing:initListEvent()
	self.listListeners = {
	}
end

function MingDiLing:onInitView(openInfo)
    self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_zlzc/uicsb_zlzc_mdl.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Image_price_bg"] = {name = "Image_price_bg"},
        ["Image_price_bg.Node_1"] = {name = "Node_1"},
        ["Image_price_bg.Node_1.Text_max"] = {name = "Text_max"},
        ["Image_price_bg.Node_1.Text_current"] = {name = "Text_current"},
        ["Image_price_bg.Node_1.Button_add"] = {name = "Button_add", click = "onUIButtonClick"},
        ["Image_price_bg.Node_2"] = {name = "Node_2"},
        ["Image_price_bg.Node_2.Text_time"] = {name = "Text_time"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
    cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
    ccui.Helper:doLayout(self["rootView"])
end


function MingDiLing:onEnterScene()
    
    local current_ringing_arrow = cp.getUserData("UserZhuluzhanchang"):getValue("current_ringing_arrow")
    current_ringing_arrow = 9

    self.Text_current:setString(tostring(current_ringing_arrow))
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "init_sound")
    local init_sound = Config:getValue("IntValue")
    
    local str = "鳴鏑令     /" .. tostring(init_sound)
    if current_ringing_arrow < init_sound then
        self.Node_1:setPositionX(110)
        self.Node_2:setVisible(true)
        self.Text_time:setString("")
        
        -- cp.getUserData("UserZhuluzhanchang"):setValue("resume_time",150)
        local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            local resume_time = cp.getUserData("UserZhuluzhanchang"):getValue("resume_time")
            cp.getUserData("UserZhuluzhanchang"):setValue("resume_time",resume_time - 1)
            if resume_time - 1 <= 0 then
                local current = cp.getUserData("UserZhuluzhanchang"):getValue("current_ringing_arrow")
                if current + 1 < init_sound then
                    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "resume_sound")
                    local resume_sound = Config:getValue("IntValue")
                    cp.getUserData("UserZhuluzhanchang"):setValue("resume_time",resume_sound)
                    local str =  cp.getUtils("DataUtils").formatTimeRemainWAllShow(resume_sound,false)
                    self.Text_time:setString(str)
                else
                    self.Node_2:stopAllActions()
                    self.Node_2:setVisible(false)
                end
                
            else
                local str =  cp.getUtils("DataUtils").formatTimeRemainWAllShow(resume_time - 1,false)
                self.Text_time:setString(str)
            end
        end))
        self.Node_2:runAction(cc.RepeatForever:create(seq))
    else
        self.Node_1:setPositionX(210)
        self.Node_2:setVisible(false)
    end
end

function MingDiLing:onExitScene()

    self.Node_2:stopAllActions()
    self.Node_2:setVisible(false)
end

function MingDiLing:onUIButtonClick(sender)
    local buttonName = sender:getName()
    if buttonName == "Button_add" then
        --購買鳴鏑令
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "sound_cost")
        local sound_cost = Config:getValue("IntValue")
        local function comfirmFunc()
            --檢測是否元寶足夠
            if cp.getManager("ViewManager").checkGoldEnough(sound_cost) then
                -- local req = {}
                -- self:doSendSocket(cp.getConst("ProtoConst").ResetStoryReq, req) --購買鳴鏑令
            end
        end
        
        local contentTable = {
            {type="ttf", fontName="fonts/msyh.ttf", fontSize=24, text="是否花費", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="ttf", fontName="fonts/msyh.ttf",fontSize=24, text=tostring(sound_cost), textColor=cc.c4b(0,255,0,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
            {type="image",filePath="ui_common_yuanbao.png",textureType=ccui.TextureResType.plistType,verticalAlign="bottom"},
            {type="ttf",  fontName="fonts/msyh.ttf", fontSize=24, text="，購買1枚鳴鏑令？", textColor=cc.c4b(255,255,255,255), outLineColor=cc.c4b(0,0,0,255), outLineSize=2},
        }
        cp.getManager("ViewManager").showGameMessageBox("系統消息",contentTable,2,comfirmFunc,nil)
    end
end

return MingDiLing
