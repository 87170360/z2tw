local BNode = require "cp.view.ui.base.BNode"
local EquipMeltRevertUI = class("EquipMeltRevertUI",BNode)

function EquipMeltRevertUI:create(openInfo)
	local node = EquipMeltRevertUI.new(openInfo)
	return node
end

function EquipMeltRevertUI:initListEvent()
	self.listListeners = {
		--裝備熔鍊撤銷返回
		[cp.getConst("EventConst").EquipMeltCancleRsp] = function(evt)
			self:onEquipMeltCancelResult(evt)
		end,
		
		--新手指引獲取按鈕位置
		[cp.getConst("EventConst").get_guide_view_point] = function(evt)
			if evt.classname == "EquipMeltRevertUI" then
				if evt.guide_name == "equip" then
					if evt.target_name == "Button_ok" then
						local boundbingBox = self[evt.target_name]:getBoundingBox()
						local pos = self[evt.target_name]:getParent():convertToWorldSpace(cc.p(boundbingBox.x+boundbingBox.width/2,boundbingBox.y+boundbingBox.height/2))
						
						local finger_info = {pos = pos, finger = {guide_type = "point",dir="right"} }
						evt.ret = finger_info
					end
				end
			end
		end,
		
		--模擬點擊按鍵
		[cp.getConst("EventConst").guide_click_view_point] = function(evt)
			if evt.classname == "EquipMeltRevertUI" then
				if evt.guide_name == "equip" then
					if evt.target_name == "Button_ok" then
						self:onUIButtonClick(self[evt.target_name])
					end
					
				end
			end
		end
	}
end

-- local openInfo = {uuid = uuid,revert_need = 50, revertInfo = evt}
function EquipMeltRevertUI:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_equip_operate/uicsb_equip_ronglian_revert.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
		["Panel_root.Image_bg.Button_ok"] = {name = "Button_ok",click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_revert"] = {name = "Button_revert",click = "onUIButtonClick"},
		["Panel_root.Image_bg.Button_close"] = {name = "Button_close",click = "onUIButtonClick"},

		["Panel_root.Image_bg.Text_need"] = {name = "Text_need"},
		["Panel_root.Image_bg.Text_new"] = {name = "Text_new"},
		["Panel_root.Image_bg.Text_old"] = {name = "Text_old"},

	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)

	-- cp.getManualConfig("Color").defaultModal_c4b
	cp.getManager("ViewManager").addModal(self,cc.c4b(255,255,255,0),cc.p(-display.cx,-display.cy))


	--[[
	message EquipMeltRsp {
    required int32 respond                  = 1;                    //處理結果(消息錯誤碼)
    required int32 targetPos                = 2;                    //目標位置(0,1,2,3,4,5)
    required int32 materialPos              = 3;                    //材料位置(0,1,2,3,4,5)
    optional EquipAtt beforAtt              = 4;                    //目標原來屬性
    required EquipAtt afterAtt              = 5;                    //目標替換屬性
}
]]
	local revertInfo = self.openInfo.revertInfo

	local old_text = "無"
	if revertInfo.beforAtt ~= nil and revertInfo.beforAtt.attValue > 0 then
		old_text = cp.getConst("CombatConst").AttributeList[tonumber(revertInfo.beforAtt.attType)] .. " +" .. tostring(revertInfo.beforAtt.attValue)
	end
	local new_text = cp.getConst("CombatConst").AttributeList[tonumber(revertInfo.afterAtt.attType)] .. " +" .. tostring(revertInfo.afterAtt.attValue)
	self.Text_need:setString(tostring(self.openInfo.revert_need))
	self.Text_old:setString(tostring(old_text))
	self.Text_new:setString(tostring(new_text))
end

function EquipMeltRevertUI:onEnterScene()
	
	local cur_guide_module_name = cp.getGameData("GameNewGuide"):getValue("cur_guide_module_name")
	if cur_guide_module_name == "equip" then
		local seq = cc.Sequence:create(
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(
				function()
					local info = 
					{
						classname = "EquipOperateLayer",
					}
					self:dispatchViewEvent( cp.getConst("EventConst").enter_layer_notice, info )
				end
			)
		)
		self:runAction(seq)
	end
end

function EquipMeltRevertUI:onUIButtonClick(sender)
	local buttonName = sender:getName()
	log("click button : " .. buttonName)
	if "Button_revert"  == buttonName then
		local req = {targetUID = self.openInfo.uuid}
		self:doSendSocket(cp.getConst("ProtoConst").EquipMeltCancleReq,req)
	elseif "Button_ok" == buttonName or "Button_close"  == buttonName then
		cp.getManager("GDataManager"):showFightBuff()
		if self.closeCallBack then
			self.closeCallBack()
		end
		self:removeFromParent()
	end
end

function EquipMeltRevertUI:setCloseCallBack(cb)
	self.closeCallBack = cb
end

function EquipMeltRevertUI:onEquipMeltCancelResult(evt)
	if self.closeCallBack then
		self.closeCallBack()
	end
	self:removeFromParent()
end


return EquipMeltRevertUI
