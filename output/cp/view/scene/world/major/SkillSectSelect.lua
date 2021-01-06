local BLayer = require "cp.view.ui.base.BLayer"
local SkillSectSelect = class("SkillSectSelect",BLayer)

function SkillSectSelect:create()
	local layer = SkillSectSelect.new()
	return layer
end

function SkillSectSelect:initListEvent()
	self.listListeners = {
        [cp.getConst("EventConst").point_skillsect_2] = function(evt)
            
            self.Image_select:setVisible(true)
            self.Image_select:setPositionY(539)
            self:delayNewGuide(0.6)
        end,

        [cp.getConst("EventConst").point_skillsect_3] = function(evt)
            self.Image_select:setVisible(true)
            self.Image_select:setPositionY(260)
            self:delayNewGuide(0.6)
        end,

        [cp.getConst("EventConst").select_skillsect] = function(evt)
            self.Image_select:setVisible(false)
            -- local delay = CCDelayTime:create(delay)
            -- local callfunc = CCCallFunc:create(callback)
            -- local sequence = CCSequence:createWithTwoActions(delay, callfunc)
            -- local action = CCRepeatForever:create(sequence)
            -- self.Button_Study_1:runAction(action)

            local act = {}
            local act1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.1,0.8,0.8))
            local act2 = cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1,1))
            local act3 = cc.EaseSineOut:create(cc.ScaleTo:create(0.1,1.1,1.1))
            local act4 = cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1,1))
            local act5 = cc.DelayTime:create(1)
    
            local acts = {act1,act2,act3,act4,act5}
            local seq = cc.Sequence:create(acts)
            local action = cc.RepeatForever:create(seq)
            self.Button_Study_1:runAction(action)
            self.Button_Study_2:runAction(action:clone())
            self.Button_Study_3:runAction(action:clone())
        end,

         --新手指引獲取目標點位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "SkillSectSelect" then
                if evt.guide_name == "lottery" then
                    if evt.target_name == "Panel_content" then
                        local boundbingBox = self[evt.target_name]:getBoundingBox()
                        pos =   self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
                        
                        evt.ret = {top = pos.x - boundbingBox.width/2-10,bottom = pos.y-boundbingBox.height/2, width = boundbingBox.width+20,height = boundbingBox.height }
                    end
				end
			end
        end,
        
        [cp.getConst("EventConst").SkillItemRsp] = function(evt)
            self:checkNeedClose(evt.skillId)
        end,
	}
end

function SkillSectSelect:onInitView(openInfo)
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_sect_select.csb") 
	self:addChild(self.rootView)

	local childConfig = {
        ["Panel_root"] = {name = "Panel_root"},
        ["Panel_root.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},
        ["Panel_root.Panel_content"] = {name = "Panel_content"},
        
        ["Panel_root.Panel_content.Image_select"] = {name = "Image_select"},
        ["Panel_root.Panel_content.Panel_Model_1"] = {name = "Panel_Model_1"},
        ["Panel_root.Panel_content.Panel_Model_2"] = {name = "Panel_Model_2"},
        ["Panel_root.Panel_content.Panel_Model_3"] = {name = "Panel_Model_3"},
        ["Panel_root.Panel_content.Panel_Model_1.Button_Study_1"] = {name = "Button_Study_1",click = "onUIButtonClick"},
        ["Panel_root.Panel_content.Panel_Model_2.Button_Study_2"] = {name = "Button_Study_2",click = "onUIButtonClick"},
        ["Panel_root.Panel_content.Panel_Model_3.Button_Study_3"] = {name = "Button_Study_3",click = "onUIButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

    self:setPosition(cc.p(0,0))

    self.Image_select:setVisible(false)

    cp.getManager("ViewManager").addModal(self,cp.getManualConfig("Color").defaultModal_c4b)
    ccui.Helper:doLayout(self.rootView)

end

function SkillSectSelect:onUIButtonClick(sender)
    local buttonName = sender:getName()
    log("click button : " .. buttonName)

    if "Button_close"  == buttonName then
        if self.closeCallBack then
            self.closeCallBack()
        end
    elseif "Button_Study_1" == buttonName then
        self:autoStudySkill(1)
    elseif "Button_Study_2" == buttonName then
        self:autoStudySkill(2)
    elseif "Button_Study_3" == buttonName then
        self:autoStudySkill(3)
    end
end

function SkillSectSelect:setCloseCallBack(cb)
    self.closeCallBack = cb
end

function SkillSectSelect:onEnterScene()
    
    local lotteryConfig = cp.DataUtils.split(cp.getManager("ConfigManager").getItemByKey("Common", 1):getValue("FirstTreasureLottery"), ";=")
 
    local itemId_list = {{},{},{}}
    for i=1,3 do
        for j=1,3 do
            local skillId = 0
            local itemId = lotteryConfig[j+i*3-3][1]
            local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemId)
            if conf ~= nil then
                skillId = tonumber(conf:getValue("Extra")) or 0
            end
            if skillId > 0 then
                if itemId_list[i] == nil then
                    itemId_list[i] = {}
                end
                if itemId_list[i][j] == nil then
                    itemId_list[i][j] = {}
                end
                itemId_list[i][j] = {itemId = itemId,skillId = skillId}
            end
        end
    end
    self.itemSkill_list = itemId_list
   
    for i=1,3 do
        for j=1,3 do
            local node = self["Panel_Model_" .. tostring(i)]:getChildByName("Node_skill_" .. tostring(j))
            if node and self.itemSkill_list[i] and  self.itemSkill_list[i][j] then
                local skillId = self.itemSkill_list[i][j].skillId
                local cfgItem3 = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillId)
                local Name = cfgItem3:getValue("SkillName")
                local Colour = cfgItem3:getValue("Colour")
                local Icon = cfgItem3:getValue("Icon")
                local wuxueInfo = {id=skillId,level = 0, Name = Name, Colour = Colour,Icon = Icon }
                local item = require("cp.view.ui.item.SkillItem"):create(wuxueInfo)
                node:addChild(item)
                item:setItemClickCallBack(function()
                    
                    local combatSkillInfo = {id = skillId,skill_level = 0}
                    if cfgItem3 == nil or cfgItem3:getValue("SkillType") == 2 or cfgItem3:getValue("SkillType") == 3 then
                        return
                    end
                    local layer = require("cp.view.scene.skill.SkillDetailNoneLayer"):create(cfgItem3, combatSkillInfo)
                    self:addChild(layer, 1)
                    layer:setPosition(cc.p(0,-70))
                end)
            end
        end
    end

    self:delayNewGuide(0.3)

    performWithDelay(self.Image_select, function()
        self.Image_select:setVisible(true)
        self.Image_select:setPositionY(816)    
    end, 0.15)
    
end

function SkillSectSelect:onExitScene()
end


function SkillSectSelect:delayNewGuide(time)
    local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
    if cur_guide_module_name == "lottery" then
        local sequence = {}
        table.insert(sequence, cc.DelayTime:create(time))
        table.insert(sequence,cc.CallFunc:create(function()
            local info = 
            {
                classname = "SkillSectSelect",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
        end))
        self:runAction(cc.Sequence:create(sequence))
    end
end

function SkillSectSelect:autoStudySkill(idx)
    local list = self.itemSkill_list[idx]
    local skillIds = {}
    local sequence = {}
    for i=1,#list do
        local itemId = list[i].itemId
        log("itemId = " .. itemId)
        local itemInfo = cp.getUserData("UserItem"):getItemFormPackage(itemId,2) -- 武學書揹包欄
        if itemInfo ~= nil then
            log("uuid = " .. itemInfo.uuid)
            table.insert(skillIds,list[i].skillId)
            table.insert(sequence,cc.CallFunc:create(function()
                local data = {uuid=itemInfo.uuid, num=1}
                self:doSendSocket(cp.getConst("ProtoConst").SkillItemReq,data)
            end))
            table.insert(sequence, cc.DelayTime:create(0.5))
        end
    end
    self.newPlayerSkillIds = skillIds
    self:stopAllActions()
    self:runAction(cc.Sequence:create(sequence))
    
end

function SkillSectSelect:checkNeedClose(skillId)
    
    if table.arrIndexOf(self.newPlayerSkillIds, skillId) ~= -1 then

        local skillData = cp.getUserData("UserSkill"):getValue("SkillData")
        if skillData and skillData.skill_combine_list and skillData.skill_combine_list[1] then
            
            local req = {}
            req.combine_id = 0
            req.skill_list = {}
            req.skill_list.skill_id_list = skillData.skill_combine_list[1].skill_id_list
            for i=1, 6 do
                if req.skill_list.skill_id_list[i] == 0 then
                    req.skill_list.skill_id_list[i] = skillId
                    break
                end
            end
            self:doSendSocket(cp.getConst("ProtoConst").UpdateSkillCombineReq, req) 
        end

        table.arrRemoveItem(self.newPlayerSkillIds, skillId, 1)
    end
    if table.nums(self.newPlayerSkillIds) <= 0 then
        --關閉界面，進入下一步
        local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
        if cur_guide_module_name == "lottery" then
            local info = 
            {
                classname = "SkillSectSelect",
            }
            self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )

            local sequence = {}
            table.insert(sequence, cc.DelayTime:create(0.2))
            table.insert(sequence,cc.CallFunc:create(function()
                self:removeFromParent()
            end))
            self:runAction(cc.Sequence:create(sequence))
        end

    end
end

return SkillSectSelect
