local BNode = require "cp.view.ui.base.BNode"
local EquipPropertyList = class("EquipPropertyList",BNode)

function EquipPropertyList:create(openInfo)
	local node = EquipPropertyList.new(openInfo)
	return node
end

function EquipPropertyList:initListEvent()
	self.listListeners = {
	}
end

-- openInfo ={operateType = 1}
function EquipPropertyList:onInitView(openInfo)
	self.openInfo = openInfo
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_equip_operate/uicsb_equip_property_list.csb") 
	self:addChild(self.rootView)

	local childConfig = {
		["Panel_property_list"] = {name = "Panel_property_list"},
		["Panel_property_list.Image_bg_left"] = {name = "Image_bg_left"},
		["Panel_property_list.Image_bg_right"] = {name = "Image_bg_right"},
		["Panel_property_list.Image_bg_left.Text_title_left"] = {name = "Text_title_left"},
		["Panel_property_list.Image_bg_right.Text_title_right"] = {name = "Text_title_right"},
		["Panel_property_list.Image_array"] = {name = "Image_array"},
		["Panel_property_list.Image_mark"] = {name = "Image_mark"},
		["Panel_property_list.Image_tips"] = {name = "Image_tips"},
		["Panel_property_list.Image_tips.Text_tips"] = {name = "Text_tips"},
	}

	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)

	self.Image_array:setLocalZOrder(1)
	self.Image_mark:setLocalZOrder(2)
	self.Image_mark:setVisible(false)

	local sz = self.Panel_property_list:getContentSize()
	self.EquipPropertyItemList = {}
	for i=1,6 do
		local EquipPropertyItem = require("cp.view.scene.world.equipoperate.EquipPropertyItem"):create()
		self.Panel_property_list:addChild(EquipPropertyItem)
		EquipPropertyItem:setPosition(cc.p(5,sz.height-i*40))
		EquipPropertyItem:setClickCallBack(handler(self,self.onListItemSelected))
		self.EquipPropertyItemList[i] = EquipPropertyItem
	end

	ccui.Helper:doLayout(self["rootView"])
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
 
end

function EquipPropertyList:onEnterScene()

	
end

function EquipPropertyList:getContentSize()
	local sz = self.Panel_property_list:getContentSize()
	if self.openInfo.operateType ~= 1 then
		sz.height = sz.height + 32 
	end
	return sz
end

function EquipPropertyList:changeOperateType(operateType)
	log("operateType" .. operateType)

	self.openInfo.operateType = operateType
	self.Image_array:setFlippedX(self.openInfo.operateType ~= 1)
	self.Image_array:setPositionY(self.openInfo.operateType == 1 and 140 or 110)
	self.Image_tips:setVisible(self.openInfo.operateType ~= 1)
	self.Text_title_left:setString(self.openInfo.operateType == 1 and "強化前" or "附加屬性")
	self.Text_title_right:setString(self.openInfo.operateType == 1 and "強化後" or "附加屬性")
	-- self.Panel_property_list:setPositionY(self.openInfo.operateType == 1 and 530 or 560)
	-- self.Panel_property_list:setContentSize(self.tabIndex == 1 and cc.size(570,200) or cc.size(570,242))
	-- self.Panel_property_list:setContentSize(cc.size(570,242))
	self.Image_bg_left:setPositionY(self.Panel_property_list:getContentSize().height)
	self.Image_bg_right:setPositionY(self.Panel_property_list:getContentSize().height)
	if operateType ~= 1 then  -- 強化
		local txt = {"","傳承將會取代目標裝備的強化等級以及附加屬性!","熔鍊後，消耗的裝備將會隨機一個屬性給目標!"}
		self.Text_tips:setString(txt[operateType])
	end

end

function EquipPropertyList:resetList()
	
	for i=1,6 do
		if self.openInfo.operateType == 1 and i == 6 then
			self.EquipPropertyItemList[i]:setVisible(false)
		else
			self.EquipPropertyItemList[i]:reset(self.propertyInfoList[i])
			self.EquipPropertyItemList[i]:setVisible(true)
		end
	end
end

-- operateInfo = {fight=0,afterFight=0,beforAtt = {},afterAtt ={}}
function EquipPropertyList:resetQianghuaPropertyInfoList(operateInfo)
	self.propertyInfoList = {}
	local fight = tonumber(operateInfo.fight) or 0

	local afterFightColor = cc.c4b(52,32,17,255)
	local afterOutlineColor = nil
	if operateInfo.fight ~= operateInfo.afterFight then 
		afterFightColor = cc.c4b(117,233,90,255)
		afterOutlineColor = cc.c4b(39,118,37,255)
	end

	--戰力的顯示
	local info = {
		left = {text="fight" , value=fight, color=cc.c4b(237,215,193,255)},
		right = {text="fight" , value=operateInfo.afterFight, color=afterFightColor,outline = afterOutlineColor},
		needSelect = false,
		isSelected = false, --強化不需要選擇
		isQiangHua = true,
		index = 1,
	 }
	self.propertyInfoList[1] = info

	local count = table.nums(operateInfo.beforAtt)
	count = math.max(count, table.nums(operateInfo.afterAtt))
	-- local typeList = {[0]="生命",[1]="內力",[2]="攻擊",[3]="防禦",[4]="命中",[5]="閃避",[6]="連擊",[7]="暴擊","招架","聚氣","修養","調息"}
	for i=1,5 do
		local afterAttColor = cc.c4b(52,32,17,255)
		local afterOutlineColor = nil
		local leftText,rightText = "無","無"
		local leftValue,rightValue = 0,0
		if i<=count then
			local befor = operateInfo.beforAtt[i]
			local after = operateInfo.afterAtt[i]
			leftText = cp.getConst("CombatConst").AttributeList[tonumber(befor.attType)] .. ":"
			leftValue = befor.attValue
			rightText = tostring(after.attValue)
			rightValue = after.attValue
			if befor.attValue ~= after.attValue then 
				afterAttColor = cc.c4b(117,233,90,255)
				afterOutlineColor = cc.c4b(39,118,37,255)
			end
		end
		local info = {
			left = {text=leftText, value=leftValue, color=cc.c4b(52,32,17,255)},
			right = {text=rightText, value=rightValue, color=afterAttColor,outline = afterOutlineColor},
			needSelect = false,
			isSelected = false,
			index = table.nums(self.propertyInfoList)+1,
			isQiangHua = true,
		 }
		self.propertyInfoList[info.index] = info
	end

	--立即刷新界面
	self:resetList()
end

function EquipPropertyList:resetPropertyInfoList(operateType,itemInfoLeft, itemInfoRight)
	self.propertyInfoList = {}
	self.rightPropertyMaxIndex = 0
	local attachAttLeft = itemInfoLeft and itemInfoLeft.attachAtt or {}
	local attachAttRight = itemInfoRight and itemInfoRight.attachAtt or {}
	--附加屬性
	
	-- 不再排序，按照服務下發屬性數據的順序
	-- local function sortByType(a,b)
	-- 	return a.type < b.type
	-- end
	
	-- if attachAttLeft ~= nil and next(attachAttLeft) ~= nil and table.nums(attachAttLeft) >= 2 then
	-- 	table.sort( attachAttLeft,sortByType)
	-- end
	-- if attachAttRight ~= nil and next(attachAttRight) ~= nil and table.nums(attachAttRight) >= 2 then
	-- 	table.sort( attachAttRight,sortByType)
	-- end
	local select_property_pos = 7
	for i=1,6 do
		local leftText = "無"
		local rightText = "無"
		local leftValue = 0
		local rightValue = 0
		local colorL,colorR = cc.c4b(52,32,17,255), cc.c4b(52,32,17,255)
		local outlineL,outlineR = nil,nil
		if attachAttLeft and attachAttLeft[i] then
			leftText = cp.getConst("CombatConst").AttributeList[tonumber(attachAttLeft[i].type)] .. ":"
			leftValue = attachAttLeft[i].value
			if leftValue > 0 then
				local colorText,colorOutline = cp.getManager("GDataManager"):getEquipAttachAttributeColor(itemInfoLeft.id,tonumber(attachAttLeft[i].type),leftValue)
				colorL = colorText
				outlineL = colorOutline
			end
		else
			select_property_pos = math.min(select_property_pos,i)
		end

		if attachAttRight and attachAttRight[i] then
			rightText = cp.getConst("CombatConst").AttributeList[tonumber(attachAttRight[i].type)] .. ":"
			rightValue = attachAttRight[i].value
			self.rightPropertyMaxIndex = math.max(self.rightPropertyMaxIndex,i)
			if rightValue > 0 then
				local colorText,colorOutline = cp.getManager("GDataManager"):getEquipAttachAttributeColor(itemInfoRight.id,tonumber(attachAttRight[i].type),rightValue)
				colorR = colorText
				outlineR = colorOutline
			end
		end

		local info = {
			left = {text=leftText, value=leftValue, color=colorL,outline=outlineL},
			right = {text=rightText, value=rightValue, color=colorR,outline=outlineR},
			needSelect = operateType == 3,
			index = i,
			isSelected = false,
		}
		if i==1 then
			info.isQiangHua = false
		end
		if select_property_pos < 6 and i > select_property_pos then
			info.needSelect = false
		end
		if info.needSelect and select_property_pos <= 6 then
			info.isSelected = true
		end
		self.propertyInfoList[i] = info
	end

	if operateType == 3 and select_property_pos > 0 and select_property_pos < 7 then --只能是1~6
		cp.getUserData("UserEquipOperate"):setValue("select_property_pos",select_property_pos-1) --與伺服器保持一致，0~5
	end

	--立即刷新界面
	self:resetList()
end



function EquipPropertyList:resetPropertyInfoListForRight(itemInfoRight)
	
	local attachAttRight = itemInfoRight and itemInfoRight.attachAtt or {}

	-- local function sortByType(a,b)
	-- 	return a.type < b.type
	-- end
	
	-- if attachAttRight ~= nil and next(attachAttRight) ~= nil and table.nums(attachAttRight) >= 2 then
	-- 	table.sort( attachAttRight,sortByType)
	-- end
	self.rightPropertyMaxIndex = 0
	for i=1,6 do
		local rightText = "無"
		local rightValue = 0
		local colorR = cc.c4b(52,32,17,255)
		local outlineR = nil
		local info = self.propertyInfoList[i]
		if attachAttRight and attachAttRight[i] then
			rightText = cp.getConst("CombatConst").AttributeList[tonumber(attachAttRight[i].type)] .. ":"
			rightValue = attachAttRight[i].value
			self.rightPropertyMaxIndex = math.max(self.rightPropertyMaxIndex,i)
			if rightValue > 0 then
				local colorText,colorOutline = cp.getManager("GDataManager"):getEquipAttachAttributeColor(itemInfoRight.id,tonumber(attachAttRight[i].type),rightValue)
				colorR = colorText
				outlineR = colorOutline
			end
		end
		info.right.text = rightText
		info.right.value = rightValue
		info.right.color = colorR
		info.right.outline = outlineR
		self.propertyInfoList[i] = info
	end

	--立即刷新界面
	self:resetList()
end


function EquipPropertyList:onListItemSelected(item)

	for i=1,6 do
		local info = self.propertyInfoList[i]
		if self.EquipPropertyItemList[i] == item then
			self.propertyInfoList[i].isSelected = true
			cp.getUserData("UserEquipOperate"):setValue("select_property_pos",i-1)
		else
			self.propertyInfoList[i].isSelected = false
		end
		self.EquipPropertyItemList[i]:setSelectedState(self.propertyInfoList[i].isSelected)
	end
end

function EquipPropertyList:playMeltSelectAnimation(idx,finishCallBack)
	self.Image_mark:setPosition(cc.p(305,218)) --最上面一個屬性值
	self.Image_mark:setVisible(true)
	local posList = {}
	for i=1,self.rightPropertyMaxIndex do
		table.insert(posList,cc.p(305,218 - (i-1)*38 ))
	end

	local curIndex = 0

	--第一輪滾動
	local nextIndex1 = 0
	local repeatNum1 = self.rightPropertyMaxIndex*5 + idx
	--log("repeatNum1 " .. repeatNum1)
	local function tt1()
		if repeatNum1 <= 0 then
		--當repeat次數為3的時候，會被調用4次，cc.Repeat的BUG
			return
		end
		curIndex = nextIndex1 % self.rightPropertyMaxIndex + 1
		--log("tt1() curIndex " .. curIndex .. " nextIndex1 " .. nextIndex1)
		self.Image_mark:setPosition(posList[curIndex])
		nextIndex1 = nextIndex1 + 1
		repeatNum1 = repeatNum1 - 1
	end
	local delay1 = cc.DelayTime:create(0.1)
	local func1 = cc.CallFunc:create(tt1)
	local actSeq1 = cc.Sequence:create(delay1,func1)
	local actRep1 = cc.Repeat:create(actSeq1, repeatNum1) 
	

	--第二輪滾動
	local nextIndex2 = 0
	local repeatNum2 = self.rightPropertyMaxIndex + idx
	--log("repeatNum2 " .. repeatNum2)
	local function tt2()
		if repeatNum2 <= 0 then
		--當repeat次數為3的時候，會被調用4次，cc.Repeat的BUG
			return
		end
		curIndex = nextIndex2 % self.rightPropertyMaxIndex + 1
		--log("tt2() curIndex " .. curIndex .. " nextIndex2 " .. nextIndex2)
		self.Image_mark:setPosition(posList[curIndex])
		nextIndex2 = nextIndex2 + 1
		repeatNum2 = repeatNum2 - 1
	end
	local delay2 = cc.DelayTime:create(0.5)
	local func2 = cc.CallFunc:create(tt2)
	local actSeq2 = cc.Sequence:create(delay2, func2)
	local actRep2 = cc.Repeat:create(actSeq2, repeatNum2)
	
	--關閉
	local function tt3()
		--log("tt3()")
		self.Image_mark:stopAllActions()
		self.Image_mark:setPosition(cc.p(305,218)) --最上面一個屬性值
		self.Image_mark:setVisible(false)
		if curIndex ~= idx then
			log("select action wrong!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! curIndex " .. curIndex .. " idx " .. idx)
		end
		if finishCallBack then
			finishCallBack()
		end
	end
	
	local delay3 = cc.DelayTime:create(1)
	local func3 = cc.CallFunc:create(tt3)
	local actSeq3 = cc.Sequence:create(delay3, func3)

	local actAll = cc.Sequence:create(actRep1, actRep2, actSeq3)
    self.Image_mark:runAction(actAll)
	
end


return EquipPropertyList
