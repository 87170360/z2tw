--跟遊戲數據相關的工具類方法寫在這裡，比如通過等級獲取升級所需要的經驗值等

local GDataManager = class("GDataManager")

function GDataManager:create()
    local ret =  GDataManager.new() 
    ret:init()
    return ret
end  

function GDataManager:init()
end

--獲取不合法名字字庫
function GDataManager:getUnLawfulName()
	
	local nameList = {}
	local cnt = cp.getManager("ConfigManager").getItemCount("name_unlawful")
	for i=1,cnt do
		local cfgItem = cp.getManager("ConfigManager").getItemAt("name_unlawful",i)
		local lx1 = cfgItem:getValue("lx1") -- string.trim()
		local lx2 = cfgItem:getValue("lx2")
		local lx3 = cfgItem:getValue("lx3")
		local lx4 = cfgItem:getValue("lx4")
		if lx1 ~= nil and lx1 ~= "" then
			table.insert(nameList,lx1)
		end
		if lx2 ~= nil and lx2 ~= "" then
			table.insert(nameList,lx2)
		end
		if lx3 ~= nil and lx3 ~= "" then
			table.insert(nameList,lx3)
		end
		if lx4 ~= nil and lx4 ~= "" then
			table.insert(nameList,lx4)
		end
	end
	return nameList
end


--讀取channel_config表格中字段
function GDataManager:getGameConfigByChannel(channelName, valueType)
	local cfgItem = cp.getManager("ConfigManager").getItemByMatch("channel_config",{channelName = channelName})
    if valueType == nil or valueType == "" then  -- valueType為空則返回整個cfgItem
		return cfgItem
	end
	return cfgItem:getValue(valueType)
end

--獲取IMEI
function GDataManager:getIMEI()
	local retString = "()Ljava/lang/String;"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, imei = luaj.callStaticMethod(className,"getIMEI", args, retString)

    return imei
end

--獲取IMSI
function GDataManager:getIMSI()
	local retString = "()Ljava/lang/String;"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, imsi = luaj.callStaticMethod(className,"getIMSI", args, retString)

    return imsi
end

function GDataManager:getVersionName()
	local retString = "()Ljava/lang/String;"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, versionName = luaj.callStaticMethod(className,"getVersionName", args, retString)

    return versionName
end

function GDataManager:getVersionCode()
	local retInt = "()I"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, versionCode = luaj.callStaticMethod(className,"getVersionCode", args, retInt)

    return versionCode
end

function GDataManager:getPackageName()
	local retString = "()Ljava/lang/String;"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, packageName = luaj.callStaticMethod(className,"getPackageName", args, retString)

    return packageName
end

function GDataManager:getMobileType()
	local retString = "()Ljava/lang/String;"
	local args = {}
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/LuaJavaBridge/LuaJavaBridge"
    local ok, mobileType = luaj.callStaticMethod(className,"getMobileType", args, retString)

    return mobileType
end

-- init TalkData
function GDataManager:initTalkingDataGA()
    local channelName = cp.getManualConfig("Channel").channel 
    local td_appid = "F293CAE516C948BC9F6383031D24309A"  --talkdata appId
    local args = {td_appid,channelName}
    local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
    
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/lua/AppActivity"
    local ok, ret = luaj.callStaticMethod(className,"initTalkingDataGA", args, sig)

end

--保存帳號 accountData {account, password}, 保存格式 account1,pwd1#accont2,pwd2#account3,pwd3
function GDataManager:saveAccount(accountData)
	if not accountData then
		return
	end

	local tmpstr = table.concat(accountData, ",")
	if not tmpstr then
		return
	end

	--取出原有帳號密碼，合併
	local newstr = nil
	local existstr = cp.getManager("LocalDataManager"):getPublicValue("login","user_account")

	if not existstr then
		newstr = tmpstr	
	else
		newstr = string.format("%s#%s", tmpstr, existstr)
	end
    cp.getManager("LocalDataManager"):setPublicValue("login","user_account", newstr)
end

--獲取賬號列表 { {account1, pwd1}, {account2, pwd2} }
function GDataManager:getAccountList()
    local accountArr = {}
    local accountStr = cp.getManager("LocalDataManager"):getPublicValue("login","user_account")
    if accountStr then
        local arr = string.split(accountStr, "#")
        for _, v in ipairs(arr) do
            local tb = string.split(v, ",")
            table.insert(accountArr, tb)
        end
    end
    return accountArr
end

--保存上次登錄帳號 accountData:  {account, pwd}
function GDataManager:saveLastAccount(accountData)
	if not accountData then
		return
	end

	local tmpstr = table.concat(accountData, ",")
    cp.getManager("LocalDataManager"):setPublicValue("login","user_last_account", tmpstr)

    self:topLastAccount(accountData)
end


--上次登錄賬戶在賬戶列表順序排前 {account, pwd}
function GDataManager:topLastAccount(accountData)
    local accountList = self:getAccountList()
    local firstAcc = accountList[1]
    if firstAcc == nil then
        return
    end

    if firstAcc[1] == accountData[1] then
        return
    end

    local newstr = table.concat(accountData, ",")
    for _, v in pairs(accountList) do
        if v[1] ~= accountData[1] then
            newstr = string.format("%s#%s", newstr, table.concat(v, ","))
        end
    end

    cp.getManager("LocalDataManager"):setPublicValue("login","user_account", newstr)
end

--獲取上次登錄帳號
function GDataManager:getLastAccount()
    local lastAccountStr = cp.getManager("LocalDataManager"):getPublicValue("login","user_last_account")
	if lastAccountStr then
		return string.split(lastAccountStr, ",")
	end
end

--通過門派和性別獲取模型id
function GDataManager:getModelId(career,gender)
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",career)
	-- local genderLimit = cfgItem:getValue("limit")
	-- gender = (gender == nil ) and 0 or gender
    -- gender = genderLimit == 1 and 0 or gender
    -- gender = genderLimit == 2 and 1 or gender
    
	local modelId = 0
	if gender == 0 then
		modelId = cfgItem:getValue("Role1")
	else
		modelId = cfgItem:getValue("Role2")
	end
    return modelId
end

--通過城鎮id，獲取城鎮的劇情章節列表
function GDataManager:getChapterStateInfo(city_id)
    local capter_list = {}
    local cfgItems = cp.getManager("ConfigManager").getItemListByMatch("GameChapterPart", {City = city_id})
    for k, item in pairs(cfgItems) do
        local Part = item:getValue("Part")
        if Part > 0 then
            local capterInfo = {
                ID = item:getValue("ID"), 
                Chapter = item:getValue("Chapter"),
                Part = Part,
                }
            table.insert(capter_list,capterInfo)
        end
    end
    return capter_list
end

--通過章節ID獲取本章所有的節數列表(章節ID=章數*1000+節數)
function GDataManager:getChapterPartList(chapter)
    return cp.getManager("ConfigManager").getItemList("GameChapterPart", "ID", function(value)
        if math.floor(value/1000) == chapter then
          return true
        end

        return false
    end)
end

--獲取某幾類武學
function GDataManager:getSkillByType(typeList)
    return cp.getManager("ConfigManager").getItemListByMatch("SkillEntry", {Serise = typeList, SkillType=1})
end

--保存地圖事件點位置(覆蓋保存) posData={uuid1={x1,y1},uuid2={x2,y2}}, 保存格式 uuid1=x1:y1#uuid2=x2:y2
function GDataManager:saveMapEventPos(posData)
	if not posData then
		return
	end

    local tmpstr = ""
    for key,value in pairs(posData) do
        if value ~= nil then
            tmpstr = tmpstr .. key .. "=" .. tostring(value[1]) .. ":" .. tostring(value[2]) .. "#"
        end
    end
	if tmpstr == "" then
		return
	end
    tmpstr=string.sub(tmpstr,1,-2) --去掉最後一個#

    cp.getManager("LocalDataManager"):setUserValue("worldmap","event_pos", tmpstr)
end

--獲取事件點位置列表 posData={uuid1={x1,y1},uuid2={x2,y2}}, 保存格式 uuid1=x1:y1#uuid2=x2:y2
function GDataManager:getMapEventPosList()
    local event_pos = {}
    local eventPosStr = cp.getManager("LocalDataManager"):getUserValue("worldmap","event_pos")
    if eventPosStr then
        local arr = string.split(eventPosStr, "#")
        for _, v in ipairs(arr) do
            local tb = string.split(v, "=")
            local pos = string.split(tb[2], ":")
            event_pos[tb[1]] = {tonumber(pos[1]),tonumber(pos[2])}
        end
    end
    return event_pos
end

--獲取人物新的階級開啟的人物等級
function GDataManager:getNewHierarchyBeginLevel(hierarchy)
    local cnt = cp.getManager("ConfigManager").getItemCount("RoleAttribute")
    local newLevel = -1
    
    for i=1, cnt do
        local item = cp.getManager("ConfigManager").getItemAt("RoleAttribute",i)
        local curLevel =  item:getValue("Level")  
        if hierarchy == item:getValue("Hierarchy") then
            if newLevel < curLevel then
                return curLevel
            end
        end
    end
    return newLevel
end

--獲取人物最大等級
function GDataManager:getRoleMaxLevel()

    local cfg = cp.getManager("ConfigManager").getConfig("RoleAttribute")
    local keys = cfg.hashkeys
    table.sort(keys,function(a,b)
        return a < b
    end)
    return keys[#keys]
end

function GDataManager:getNextConductID(conductID)
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", conductID)
    return cfg:getValue("NextID")
end

--獲取善惡事件列表
function GDataManager:generateMapEventListFromConfig()
    local cnt = cp.getManager("ConfigManager").getItemCount("GameConduct")
    local event_list_shan = {{},{},{},{},{},{}}--善列表,每階對應的列表
    local event_list_e = {{},{},{},{},{},{}}--惡列表,每階對應的列表
    local event_list_shan_zhuanshu = {{},{},{},{},{},{}}--善專屬事件列表
    local event_list_e_zhuanshu = {{},{},{},{},{},{}}--惡專屬事件列表
    local event_list = {}
    for i=1, cnt do
        local item = cp.getManager("ConfigManager").getItemAt("GameConduct",i)
        local ID = item:getValue("ID")
        local Type = item:getValue("Type") 
        local curLevel =  item:getValue("Hierarchy")
        local Show = item:getValue("Show")
        if Type == 1 then
            if Show == 1 then
                table.insert(event_list_shan[curLevel],ID)
            else
                table.insert(event_list_shan_zhuanshu[curLevel],ID)
            end
        elseif Type == 2 then
            if Show == 1 then
                table.insert(event_list_e[curLevel],ID)
            else
                table.insert(event_list_e_zhuanshu[curLevel],ID)
            end
        end
    end
    event_list[1] = event_list_shan
    event_list[2] = event_list_e
    event_list[3] = event_list_shan_zhuanshu
    event_list[4] = event_list_e_zhuanshu
    return event_list

end

--獲取善惡事件獎勵 conductID：表格中配置的善惡事件的id

--獲取善惡事件獎勵 conductID：表格中配置的善惡事件的id
function GDataManager:getMapEventReward(conductID)
    local item_list = {}

    local cfg = cp.getManager("ConfigManager").getItemByKey("GameConduct", conductID)
    -- local Name = cfg:getValue("Name")
    -- local Desc = cfg:getValue("Desc")
    -- local Desc2 = cfg:getValue("Desc2") --打斷描述
    -- local npc_id = cfg:getValue("NPC")
    local Process = cfg:getValue("Process") -- 處理方式:1掛機，2戰鬥

    local AwardVirtual = Process == 1 and cfg:getValue("HangAtt") or cfg:getValue("FightAtt")  -- 銀兩數|善值|惡值|修為點
    local AwardItem = Process == 1 and cfg:getValue("HangItem") or cfg:getValue("FightItem")  -- 物品id-物品數量|物品id-物品數量

    local arr = string.split( AwardVirtual,"|")
    local Silver = tonumber(arr[1]) or 0
    local ConductGood = tonumber(arr[2]) or 0
    local ConductBad = tonumber(arr[3]) or 0
    local trainPoint = tonumber(arr[4]) or 0

    -- 為了顯示多一個物品，銀兩不顯示出來。
    -- if Silver > 0 then
    --     table.insert(item_list, {id=2, num=Silver})
    -- end
    if trainPoint > 0 then
        table.insert(item_list, {id=1, num=trainPoint})
    end
    if ConductGood > 0 then
        table.insert(item_list, {id=1095, num=ConductGood})
    end
    if ConductBad > 0 then
        table.insert(item_list, {id=1094, num=ConductBad})
    end
    
    local arr2 = {}
    string.loopSplit(AwardItem,"|-",arr2)
    for i=1,#arr2 do
        local itemtb = arr2[i]
        local itemID = tonumber(itemtb[1])
        local itemNum = tonumber(itemtb[2])
        table.insert(item_list, {id=itemID, num=itemNum,flag="gailv"})
    end

    return item_list
end

--獲取善惡稱號
function GDataManager:getRoleConductName(totalGood,totalBad)
    local valueList = cp.getConst("GameConst").ConductValue
    local nameList = cp.getConst("GameConst").ConductName[totalGood>=totalBad and 1 or 2]
    
    local curSelectValue = totalGood>=totalBad and totalGood or totalBad
    local index = 1
    for i=table.nums(valueList),1,-1 do
        if valueList[i] <= curSelectValue then
            index = i
            break
        end
    end
    return nameList[index]
    
end

--通過npcid獲取Hero表的訊息
function GDataManager:getHeroInfoByID(npcid)
    -- local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    -- local hierarchy = major_roleAtt.hierarchy
    for k=1,6 do --階數
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("Hero", k)
        if cfgItem then
            for i=1,4 do
                local npc = cfgItem:getValue("Npc" .. tostring(i))
                if npc ~= nil and npc ~= "" then
                    local id_arr = string.split(npc,"|")
                    for j=1,#id_arr do
                        if tonumber(id_arr[j]) == npcid then
                            return cfgItem,i,j
                        end
                    end
                end
            end
        end
    end
    return nil,0,0
end


-- 獲取下一個指引的名字
function GDataManager:getNextNewGuideName()
    -- local listStr = cp.getManager("LocalDataManager"):getUserValue("newplayerguider","guideList","")
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    
    local curGuideName,step = "",0
    if listStr.current ~= "" then
        local str = string.split(listStr.current,"|")
        curGuideName = str[1]
        step = tonumber(str[2])
    end

    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    table.sort(guideInfo,function(a,b)
        return a.index > b.index
    end)
    

    if curGuideName ~= nil and curGuideName ~= "" and guideInfo[curGuideName] then
        if guideInfo[curGuideName].max_step >= step and (not guideInfo[curGuideName].firstguide) then
            return curGuideName,true,step 
        else
            curGuideName = ""
        end
    end

    local nextIndex = 0
    if curGuideName == nil or curGuideName == "" then
        local maxIndex = 1
        local list = {}
        if listStr.finished ~= "" then
            list = string.split(listStr.finished,"|")
        end
        if #list > 0 then
            for i=1,#list do
                local finishedName = list[i]
                if guideInfo[finishedName] then
                    maxIndex = math.max(maxIndex, guideInfo[finishedName].index)
                end
            end
        end
        nextIndex = maxIndex + 1
    end

    for name,info in pairs(guideInfo) do
        if info.index == nextIndex then
            local player_lv = cp.getUserData("UserRole"):getValue("major_roleAtt").level
            local needNewGuid = info.lv <= player_lv and not info.firstguide
            return name, needNewGuid,step
        end
    end
    return "",false,step
end

function GDataManager:checkNeedGuide(moduleName)
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    local _,isFind = string.find(listStr.finished,moduleName) 
    if isFind then
        return false,0
    end
    local list = string.split(listStr.current,"|")
    if list[1] == moduleName then
        return true,tonumber(list[2])
    end
    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    if guideInfo[moduleName] and guideInfo[moduleName].firstguide == true then
        return true,0
    end
    return false,0
end

function GDataManager:saveNewGuideStep(moduleName,step)

    local curIndex = 0
    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    for name,info in pairs(guideInfo) do
        if name == moduleName then
            curIndex = info.index
            break
        end
    end

    if curIndex > 0 then
        local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
        listStr.finished = listStr.finished or ""
        listStr.finished = string.gsub(listStr.finished,"||","|")
        local needChange = false
        if listStr.current == nil or listStr.current == "" then
            listStr.current = moduleName .. "|" .. tostring(step)
            needChange = true
        else
            local arr = string.split(listStr.current,"|")
            if arr[1] ~= moduleName then
                listStr.current = moduleName .. "|" .. tostring(step) 
                needChange = true
            else
                if step > tonumber(arr[2]) then
                    listStr.current = moduleName .. "|" .. tostring(step) 
                    needChange = true
                else
                    log("saveNewGuideStep: moduleName=" .. moduleName .. ",curStep=" .. step .. ",serverStep=" .. arr[2] .. ",not send ChangeLeadReq")
                end
            end
        end
        if needChange then
            local req = {lead = listStr.finished .. "==" .. listStr.current}
            cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ChangeLeadReq, req)
        end
    end
end

function GDataManager:finishAllNewGuide()
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    listStr = listStr or {}
    listStr.finished = listStr.finished or ""
    listStr.current = ""
    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    local i=1
    local finished = ""
    for name,info in pairs(guideInfo) do
        if not info.firstguide or string.find(listStr.finished,info.name) then
            local newName = info.name
            if i < table.nums(guideInfo) then
                newName = newName .. "|"
            end
            i=i+1
            finished = finished .. newName
        end
    end
    local strEnd = string.sub(finished,-1,-1)
    if strEnd ~= "|" then
        finished = finished .. "|"
    end
    listStr.finished = finished .. "doucheng"  or ""
    listStr.finished = string.gsub(listStr.finished,"||","|")
    local req = {lead = listStr.finished .. "==" .. listStr.current}
    cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ChangeLeadReq, req)

end

function GDataManager:getLocalNewGuideStep()
    local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
    if listStr and listStr.current ~= "" then
        local arr = string.split(listStr.current,"|")
        return arr[1], tonumber(arr[2])
    else
        return "", 0
    end
end

function GDataManager:finishNewGuideName(moduleName)
    local inConfig = false
    local guideInfo = require("cp.view.scene.newguide.moduleguide.UIGuideConfig")
    for name,info in pairs(guideInfo) do
        if name == moduleName then
            inConfig = true
            break
        end
    end
    if moduleName ~= nil and moduleName ~= "" and inConfig then
        local listStr = cp.getUserData("UserRole"):getValue("newplayerguider")
        if listStr and listStr.finished ~= "" then
            local arr = string.split(listStr.finished,"|")
            if table.arrIndexOf(arr,moduleName) == -1 then
                listStr.finished = listStr.finished .. "|" .. tostring(moduleName)
            else
                return
            end
        else
            listStr.finished = tostring(moduleName)
        end
        listStr.current = ""
        listStr.finished = string.gsub(listStr.finished,"||","|")
        local req = {lead = listStr.finished .. "==" .. listStr.current}
        cp.getManager("SocketManager"):doSend(cp.getConst("ProtoConst").ChangeLeadReq, req)
    end

end

--換裝物品挑選
function GDataManager:pickEquip(pos)
	local equips = {}
	local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
	for _, v in pairs(roleItem) do
		local equipConf = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id) or nil
		local itemConf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id) or nil
		local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")		
		--裝備位置， 使用情況，裝備階數
		if equipConf ~= nil and (equipConf:getValue("Pos") == pos) and (v.using == 0) and (equipConf:getValue("PlayerHierarchy") <= majorRole.hierarchy) then
			local item = {
				Name = itemConf:getValue("Name"), 
				Icon = itemConf:getValue("Icon"), 
				Colour = itemConf:getValue("Hierarchy"),
				Type = itemConf:getValue("Type"),
				uuid = v.uuid, 
				id = v.id,
				using = v.using, 
				eventID = v.eventID,
				num = v.num,
				fight = v.fight,
				strengthenLevel = v.strengthenLevel or 0,
				strengthenExp = v.strengthenExp or 0,
                selected = false,
                weaponAtt = v.weaponAtt,
			}
			table.insert(equips, item)
		end
	end

	--排序
	local sortItem = function(a, b)
		if a.Colour == b.Colour then
			return a.fight > b.fight
		end
		return a.Colour > b.Colour 
	end
	table.sort(equips, sortItem)
	return equips
end

--階級訊息
function GDataManager:getHierarchyInfo(career, rank, hierarchy)  
  if rank > 7 or rank == 0 then
		local hierarchyName = {"一階弟子", "二階弟子", "三階弟子", "四階弟子", "五階弟子", "六階弟子"}
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",career)
    return cfgItem:getValue("Name") .. hierarchyName[hierarchy]
  else
    local titleData = cp.getManager("ConfigManager").getItemByKey("Title", career .. "_" .. rank)
    return titleData:getValue("Title")
  end  
end

--獲取裝備初始戰力看
function GDataManager:getEquipBaseFight(id)
	local cfg = cp.getManager("ConfigManager").getItemByKey("GameEquip", id)
	if cfg == nil then
		log("euqip config nil " .. id)
		return 0
	end

	local attstr = cfg:getValue("Attribute")
	local attval = {}
	local fight = 0
	string.loopSplit(attstr, ";=", attval)
    for _, v in pairs(attval) do
		local cfg1 = cp.getManager("ConfigManager").getItemByKey("Attribute2Fight", tonumber(v[1]))
		fight = fight + cfg1:getValue("Fight") * tonumber(v[2])
	end

	return fight
end

--裝備可以升級(強化, 傳承，熔鍊)
function GDataManager:canUpdate(uuid)
    if not uuid then return false,false,false end

    local selectItem = cp.getUserData("UserItem"):getItem(uuid)
    local selectConf = cp.getManager("ConfigManager").getItemByKey("GameEquip", selectItem.id)
    if selectItem.PlayerHierarchy == nil then
		selectItem.PlayerHierarchy = selectConf:getValue("PlayerHierarchy")
		selectItem.PlayerHierarchy = selectItem.PlayerHierarchy or 1
	end
    local StrengthenMaxLevel = cp.getConst("GameConst").EquipStrengthenMaxLevel[selectItem.PlayerHierarchy][selectItem.Colour]
    
	local canStrengthen, canInherited, canMelt = false, false, false
    local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
	
	local pos = selectConf:getValue("Pos")

    for _, v in pairs(roleItem) do
        if  v.using ~= 1 and v.uuid ~= uuid then

            local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", v.id)
            if conf == nil then
                log("item is not exist id = " .. tostring( v.id))	
                dump(v)
            end

            --強化條件
            if v.id >= 602 and v.id <=607 and StrengthenMaxLevel > selectItem.strengthenLevel then --強化石
				canStrengthen = true
			end

			local equipconf = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
			if equipconf ~= nil then
                --強化條件
                if StrengthenMaxLevel > selectItem.strengthenLevel then
                    canStrengthen = true
                end
				if equipconf:getValue("Pos") == pos then
					if v.attachAtt ~= nil and next(v.attachAtt) ~= nil then
					--熔鍊條件
						canMelt = true
					end
					--傳承條件
					if v.strengthenLevel and v.strengthenLevel > selectItem.strengthenLevel then
						canInherited = true
					end
				end
			end
		end
	end

	return canStrengthen, canInherited, canMelt
end

--裝備可替換
function GDataManager:canChange(id)
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")		
    local roleItem = cp.getUserData("UserItem"):getValue("major_roleItem")
	local fight1 = self:getEquipBaseFight(id)
	local equipconf1 = cp.getManager("ConfigManager").getItemByKey("GameEquip", id)

	for _, v in pairs(roleItem) do
		local equipconf2 = cp.getManager("ConfigManager").getItemByKey("GameEquip", v.id)
		if v.id ~= id and v.using == 0 
			and equipconf2 ~= nil
			and equipconf1:getValue("Pos") == equipconf2:getValue("Pos") 
			and (equipconf2:getValue("PlayerHierarchy") <= majorRole.hierarchy) then
			local fight2 = self:getEquipBaseFight(v.id)
			if fight1 < fight2 then
				return true
			end
		end
	end

	return false
end

function GDataManager:showRoleRedPoint()
	local emptiyPos = {true,true,true,true,true,true,true,true}
	local roleEquip = cp.getUserData("UserItem"):getValue("role_equip_ids")
    for pos, uuid in pairs(roleEquip) do
        if uuid then
            --標記已用位置
            emptiyPos[pos] = false
            --已用裝備可升級
            if self:canUpdate(uuid) then
                return true
            end
            --已用裝備可替換
            local item = cp.getUserData("UserItem"):getItem(uuid)
            if self:canChange(item.id) then
                return true
            end
        end
	end

	for k, v in pairs(emptiyPos) do
		--空位有可用裝備
		if v and table.nums(self:pickEquip(k)) > 0 then
			return true
		end
	end

	return false
end


--判斷當前地點是否被伏擊過
function GDataManager:isBeRobbed(place,robInfo)
    if robInfo == nil or next(robInfo) == nil then
        return false
    end
    for i=1,table.nums(robInfo) do
        if place == nil or place == robInfo[i].place then
            return true
        end
    end
    return false
end

--獲取鏢車總時間
function GDataManager:getVanTotalTime(id)
    local totalTime = 0
    local itemCfg = cp.getManager("ConfigManager").getItemByKey("VanInfo", id)
    if itemCfg then
        local Time = string.split(itemCfg:getValue("Time"),"|")
        for i=1,#Time do
            totalTime = totalTime + tonumber(Time[i])
        end
    end
    return totalTime
end

--判斷押鏢是否處於活動時間
function GDataManager:isInVanHolidayTime()
    local now = cp.getManager("TimerManager"):getTime()
    local isHoliday = false
    local nowTimeTable = os.date("*t",now) 
    local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_holiday")
    local str = Config:getValue("StrValue") -- 12-00|13-00|20-00|21-00
    local arr1 = {}
    string.loopSplit(str,"|-",arr1)
    for i=1,table.nums(arr1),2 do
        local beginTime = {hour = tonumber(arr1[i][1]), min = tonumber(arr1[i][2])}
        local endTime = {hour = tonumber(arr1[i+1][1]), min = tonumber(arr1[i+1][2])} 
        local result = cp.getUtils("DataUtils").isBetweenTime(beginTime,endTime,nowTimeTable)
        if result then
            isHoliday = true
            break
        end
    end
    return isHoliday
end

function GDataManager:getVanReward(itemCfg,isRobbedModel,hierarchy)
    
    --判斷是否處於活動時間
    local isHoliday = cp.getManager("GDataManager"):isInVanHolidayTime()

    local scale = 1
    if isRobbedModel then 
        local Config = cp.getManager("ConfigManager").getItemByKey("Other", "van_rob_award")
        scale = Config:getValue("IntValue")/100
    end

    
    local gift = isHoliday and itemCfg:getValue("HolidayGift") or itemCfg:getValue("NormalGift")
    local arr2 = {}
    string.loopSplit(gift,"$|-",arr2)
    local item_list = {}
    for i=1,#arr2[hierarchy] do -- 元寶-銀兩-聲望-閱歷-修為點
        local itemID = tonumber(arr2[hierarchy][i][1])
        local itemNum = tonumber(arr2[hierarchy][i][2])
        if itemNum > 0 and itemID > 0 then
            item_list[#item_list + 1] = {itemID=itemID, itemNum = math.floor(itemNum*scale)}
        end
    end 

    return item_list,isHoliday
end


-- 獲取鏢車行走時間段
function GDataManager:getExpressVehicleStepTime(totalTimeStr)
    local length_list = cp.getUserData("UserVan"):getValue("length_list")
    local step_time_list = {}
    if length_list == nil or next(length_list) == nil then
        return
    end

    --把四個時間分配給8段路程
    local moveLengthStepTotal = { 
        [1] = length_list[1]+length_list[2], 
        [2] = length_list[3]+length_list[4]+length_list[5],
        [3] = length_list[6]+length_list[7],
        [4] = length_list[8]
    }
    
    --8段路加3個停留點
    step_time_list[1] = math.floor(length_list[1]/moveLengthStepTotal[1]*tonumber(totalTimeStr[1]))  --鏢局到鳳翔的時間
    step_time_list[2] = tonumber(totalTimeStr[1]) - step_time_list[1]                           --鳳翔到風雨亭的時間
    step_time_list[3] = tonumber(totalTimeStr[2])                                                    --風雨亭 停留時間
    step_time_list[4] = math.floor(length_list[3]/moveLengthStepTotal[2]*tonumber(totalTimeStr[3]))  --風雨亭到襄陽的時間
    step_time_list[5] = math.floor(length_list[4]/moveLengthStepTotal[2]*tonumber(totalTimeStr[3]))  --襄陽到開封的時間
    step_time_list[6] = tonumber(totalTimeStr[3]) - step_time_list[4] - step_time_list[5]  --開封到萬鬆嶺的時間
    step_time_list[7] = tonumber(totalTimeStr[4])                                                    --萬鬆嶺 停留時間
    step_time_list[8] = math.floor(length_list[6]/moveLengthStepTotal[3]*tonumber(totalTimeStr[5]))  --萬鬆嶺到臨安的時間
    step_time_list[9] = tonumber(totalTimeStr[5]) - step_time_list[8]                           --臨安到青陽崗的時間
    step_time_list[10] = tonumber(totalTimeStr[6])                                                   --青陽崗 停留時間
    step_time_list[11] = tonumber(totalTimeStr[7])                                                   --青陽崗到揚州的時間(到達揚州後鏢車消失)

    return step_time_list
end


--獲取揹包物品可操作的狀態名
function GDataManager:getPackageItemOperateState(itemInfo)
    local operateName = ""
    if itemInfo.Type == 5 then --可使用（體力，錢袋，修為丹）  類型(1裝備,2碎片，3寶箱，4書籍，5消耗品,6材料，7道具)
        operateName = "keshiyong"
    elseif itemInfo.Type == 3 then  --可使用 寶箱類
        local cfgItem = cp.getManager("ConfigManager").getItemByKey("GameChest",itemInfo.id)
        if cfgItem then
            local key_id = cfgItem:getValue("Key")
            if key_id then
                if key_id > 0 then
                    local uuid, itemInfo2 = cp.getUserData("UserItem"):getItemPackMax(key_id)
                    if uuid then
                        operateName = "keshiyong"
                    end
                else
                    operateName = "keshiyong"
                end
            end
        end
    elseif itemInfo.Type == 2 then
        if itemInfo.id ~= nil then
            local needNum = 0
            local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
            local str = string.split(conf:getValue("Extra"),"=")
            if str ~= nil and tonumber(str[2]) ~= nil then
                needNum = tonumber(str[2])
            end
            if itemInfo.num >= needNum then
                operateName = "kehecheng"
            end
        end
    elseif itemInfo.Type == 4 then
        if itemInfo.id ~= nil then
            local conf = cp.getManager("ConfigManager").getItemByKey("GameItem", itemInfo.id)
            local str = string.split(conf:getValue("Extra"),"=")
            if str ~= nil and tonumber(str[1]) ~= nil then
                local skillID = tonumber(str[1])
                local skillInfo = cp.getUserData("UserSkill"):getSkill(skillID)
                if skillInfo == nil then
                    operateName = "kexuexi"
                end
            end
        end
    end
    return operateName
end


function GDataManager:getGangPracticeMaxLevel()
    
    local maxLv = 0
    local cnt = cp.getManager("ConfigManager").getItemCount("GangPractice")
    local item = nil
    for i=1,cnt do
        item = cp.getManager("ConfigManager").getItemAt("GangPractice",i)
        maxLv = math.max(maxLv, item:getValue("ID")) 
    end
    return maxLv
end

--展示學提示標籤
function GDataManager:showLearnPoint(node) 
	local show = false

    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    local skillEntryList = cp.getManager("ConfigManager").getItemListByMatch("SkillEntry", {Gang = {major_roleAtt.career}, SkillType=1})
    for _, skillEntry in ipairs(skillEntryList) do
        if skillEntry:getValue("Colour") <= major_roleAtt.hierarchy then
            if cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID")) == nil then
				show = true
                break
            end
        end
    end

	if show then
	    cp.getManager("ViewManager").addRedDot(node, cc.p(85,85), "ui_common_xue.png")
	else
		cp.getManager("ViewManager").removeRedDot(node)
    end
end

--獲取門派操作可提示狀態
function GDataManager:checkMenPaiRedPoint()

    local needNotice = {0,0,0,0,0,0}  -- 門派武學，門派修煉，門派地位，門派進階，門派商店，門派守衛
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")

	--門派商店是否有紅點提示過，如果沒有且滿足提示條件，則進行一次紅點提示
	local needRedPoint = cp.getManager("LocalDataManager"):getUserValue("redpoint","menpaishop",false)
	if not needRedPoint then
		if major_roleAtt.hierarchy > 1 then
			needNotice[5] = 1
		end
	end
    
    --進階
    if major_roleAtt.hierarchy < 6 then --六階不提醒
        local newLevel = cp.getManager("GDataManager"):getNewHierarchyBeginLevel(major_roleAtt.hierarchy + 1,major_roleAtt.level)
        if newLevel ~= -1 and major_roleAtt.level >= newLevel then --可以進階了
            needNotice[4] = 1
        end
    end
    
    --武學
    local skillEntryList = cp.getManager("ConfigManager").getItemListByMatch("SkillEntry", {Gang = {major_roleAtt.career}, SkillType=1})
    for _, skillEntry in ipairs(skillEntryList) do
        if skillEntry:getValue("Colour") <= major_roleAtt.hierarchy then
            if cp.getUserData("UserSkill"):getSkill(skillEntry:getValue("SkillID")) == nil then
                needNotice[1] = 1
                break
            end
        end
    end
    
    --修煉 (可以免費修煉，有修煉丹時提示) 都滿級了不再提示
    local itemNum = cp.getUserData("UserItem"):getItemNum(cp.getConst("GameConst").XiuLianDan_ItemID)
    if itemNum > 0 then
        needNotice[2] = 1
    else
        local goldCount = cp.getUserData("UserMenPai"):getValue("goldCount")
        local leftFreeTimes = math.max(0,5 - goldCount) 
        if leftFreeTimes > 0 then
            needNotice[2] = 1
        end
    end
    if needNotice[2] == 1 then
        local allFullLevel = true
        local maxLv = cp.getManager("GDataManager"):getGangPracticeMaxLevel()

        local practiceLevelInfo = cp.getUserData("UserMenPai"):getValue("practiceLevelInfo")
        for i=1,table.nums(practiceLevelInfo) do
            if practiceLevelInfo[i].level < maxLv then
                allFullLevel = false
                break
            end
        end
        if allFullLevel then
            needNotice[2] = 0
        end
    end
	if self:getFeatureState(14) == 0 then
		needNotice[2] = 0
	end
    

    --門派地位
	if major_roleAtt.gangRank > 0 then
        local now = cp.getManager("TimerManager"):getTime()
        local str = os.date("%Y-%m-%d", now)
        local saveValue = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_getDate")
        local firstGetDate = cp.getManager("LocalDataManager"):getUserValue("redpoint","GangRankAward_firstGetDate","0-0-0")
        needNotice[3] = (saveValue ~= str and firstGetDate ~= str and firstGetDate ~= "0-0-0") and 1 or 0
    end
    local major_roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
    if major_roleAtt.gangRankCount > 0 then
        needNotice[3] = 1
    end
	if self:getFeatureState(13) == 0 then
		needNotice[3] = 0
	end
       

    return needNotice
end

--通過npcid及門派排行來獲取名字及頭像
function GDataManager:getGangNpcNameIcon(npcid,rank,career)
    
    local name,face = "",""
    local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    if itemCfg then
        name = itemCfg:getValue("Name")
        local modelId = itemCfg:getValue("ModelID")
        if modelId ~= nil and modelId > 0 then
            local itemCfg2 = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
            face = cp.DataUtils.getModelFace(itemCfg2:getValue("Face"))
        end
        
        if rank > 30 then
            local Career = career or itemCfg:getValue("Career")
            local npcNames = cp.getManualConfig("GangNpcName" .. Career)
            name = npcNames[rank-30]
        end
    end
    -- log(string.format("getGangNpcNameIcon npcid=%d,rank=%d,career=%d,name=%s,face=%s",npcid,rank,career,name,face))
    return name,face
end

--通過npcid來獲取人物頭像，半身像，全身像,名字
function GDataManager:getNpcNameIcon(npcid)
    local name,whole,half,head_big,head_small = "","","","",""
    local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameNpc", npcid)
    if itemCfg then
        name = itemCfg:getValue("Name")
        half = itemCfg:getValue("NpcImage")
        whole = itemCfg:getValue("WholeDraw")
        local modelId = itemCfg:getValue("ModelID")
        if modelId ~= nil and modelId > 0 then
            local itemCfg2 = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)
            head_big = cp.DataUtils.getModelFace(itemCfg2:getValue("Face"))
            head_small = cp.DataUtils.getModelCombatFace(itemCfg2:getValue("Face"))
            if half == "" then
                half = itemCfg2:getValue("HalfDraw")
            end
            if whole == "" then
                whole = itemCfg2:getValue("WholeDraw")
            end
        end    
    end
    
    return name,whole,half,head_big,head_small
end

--獲取日常任務列表
function GDataManager:getDailyTaskList()
    local taskList = {}
	local cnt = cp.getManager("ConfigManager").getItemCount("DailyTask")
	for i=1,cnt do
		local cfgItem = cp.getManager("ConfigManager").getItemAt("DailyTask",i)
		local ID = cfgItem:getValue("ID")
		local Accu = cfgItem:getValue("Accu")
		local Limit = cfgItem:getValue("Limit")
        local Item = cfgItem:getValue("Item")
        local Desc = cfgItem:getValue("Desc")
        local Name = cfgItem:getValue("Name")
        local arr2 = {}
        string.loopSplit(Item,"|-",arr2)
        local item_list = {}
        if Accu > 0 then
            table.insert(item_list, {id=1466, num=Accu})  --任務積分作為物品展示
        end
        for i=1,#arr2 do
            local itemID = tonumber(arr2[i][1])
            local itemNum = tonumber(arr2[i][2])
            table.insert(item_list, {id=itemID, num=itemNum})
        end
        local info = {ID = ID, Accu = Accu, Limit = Limit, Desc = Desc, Name = Name, item_list = item_list}
        table.insert(taskList,info)
    end
    table.sort(taskList,function(a,b)
        return a.ID < b.ID
    end)
    return taskList
end

--獲取任務積分配置
function GDataManager:getDailyTaskAccuList()
    local taskAccuList = {}
	local cnt = cp.getManager("ConfigManager").getItemCount("DailyAccu")
	for i=1,cnt do
		local cfgItem = cp.getManager("ConfigManager").getItemAt("DailyAccu",i)
		local ID = cfgItem:getValue("ID")
		local Accu = cfgItem:getValue("Accu")
		local Award = cfgItem:getValue("Award")
        
        local arr2 = {}
        string.loopSplit(Award,"|-",arr2)
        local item_list = {}
        for i=1,#arr2 do
            local itemID = tonumber(arr2[i][1])
            local itemNum = tonumber(arr2[i][2])
            table.insert(item_list, {id=itemID, num=itemNum})
        end
        taskAccuList[ID] = {ID = ID, Accu = Accu, item_list = item_list}
    end
    return taskAccuList
end

--獲取時裝表數據
function GDataManager:getAllFashionConfigInfo()
    local fashionList = {}
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
	local cnt = cp.getManager("ConfigManager").getItemCount("Fashion")
	for i=1,cnt do
        local cfgItem = cp.getManager("ConfigManager").getItemAt("Fashion",i)
        local Career = cfgItem:getValue("Career")
        local Gender = cfgItem:getValue("Gender")
        local _,idx1 = string.find(Career,tostring(majorRole.career))
        local _,idx2 = string.find(Gender,tostring(majorRole.gender))
        if idx1 ~= nil and idx2 ~= nil then
        
            local ID = cfgItem:getValue("ID")
            local Price = cfgItem:getValue("Price")
            local Condition = cfgItem:getValue("Condition")
            local ModelID = cfgItem:getValue("ModelID")
            local Att = cfgItem:getValue("Att")
            local Name = cfgItem:getValue("Name")
            local NameImg = cfgItem:getValue("NameImg")
            local Order = cfgItem:getValue("Order")
            local arr2 = {}
            string.loopSplit(Att,"|-",arr2)
            local att_list = {}
            for i=1,#arr2 do
                local type = tonumber(arr2[i][1])
                local value = tonumber(arr2[i][2])
                table.insert(att_list, {type=type, value=value})
            end
            table.insert(fashionList, {ID = ID, Price = Price or 0, Condition = Condition or 0, ModelID = ModelID or 0, att_list = att_list, NameImg = NameImg,Order = Order,Name=Name})
        end
    end
    table.sort(fashionList,function(a,b)
        if a and b then
            return a.Order < b.Order
        else
            return false
        end
    end)
    return fashionList
end

--獲取人物的畫像(參數：時裝ID,職業，性別)
function GDataManager:getMajorRoleIamge(fashionID,career,gender)
    local modelId = 0
    if fashionID == nil or fashionID <= 0 then
        modelId = cp.getManager("GDataManager"):getModelId(career, gender)
    else
        local cfg = cp.getManager("ConfigManager").getItemByKey("Fashion",fashionID)
        modelId = cfg:getValue("ModelID")
    end
    if modelId ~= nil and modelId > 0 then
        local itemCfg = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)  
        return itemCfg,modelId
    end
    return "",0
end


--獲得結交所有大俠需要的元寶數
function GDataManager:getAllHeroBribeNeed()
    local price = 0
    local hero_list = cp.getUserData("UserNpc"):getValue("hero_list")
    for uuid, info in pairs(hero_list) do
        if info.state == 0 then
            local cfgItem,i,_ = cp.getManager("GDataManager"):getHeroInfoByID(info.ID)
            local needGold = cfgItem:getValue("Gift" .. tostring(i))
            price = price + needGold
        end
    end
    return price
end

--獲得人物創建的初始頭像
function GDataManager:getRoleCreateFace(career,gender)
    local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",career)
    local modelId = cfgItem:getValue( gender == 0 and "Role1" or "Role2" )
    local cfgItem2 = cp.getManager("ConfigManager").getItemByKey("GameModel", modelId)  
    return cfgItem2:getValue("Face")
end

--保存聊天訊息
function GDataManager:saveChatMsg(data)

    --Base64編碼
    require "mime"
    local base64Str = mime.b64(data)

    local ptStr = cp.getManager("LocalDataManager"):getUserValue("chatdata","ChatChannelRsp","") 
    if ptStr == "" then
        ptStr = base64Str
    else
        local ptTable = string.split(ptStr,"__#__")
        while(table.nums(ptTable) >= 30) do
            table.remove(ptTable,1)
        end
        ptStr = ptStr .. "__#__" .. base64Str
    end
    cp.getManager("LocalDataManager"):setUserValue("chatdata","ChatChannelRsp",ptStr)
end

--導入聊天訊息
function GDataManager:loadSaveChatMsg()
    require "mime"
    local msgList = {}
    local ptStr = cp.getManager("LocalDataManager"):getUserValue("chatdata","ChatChannelRsp","") 
    if ptStr ~= "" then
        local ptTable = string.split(ptStr,"__#__")
        for i=1,table.nums(ptTable) do
            local unBase64Str = mime.unb64(ptTable[i]) 
            local proto = cp.getManager("ProtobufManager"):decode2Table("protocal.ChatChannelRsp",unBase64Str)
            if proto and next(proto) then
                cp.getUserData("UserChatData"):addNewMsg(proto)
            end
        end
        cp.getUserData("UserChatData"):resetNewMsgNum()
    end
    
end

--轉換分享的文字
function GDataManager:getShareChatMsgContent( fightInfo )
    local CombatConst = cp.getConst("CombatConst")
    local combat_type = fightInfo.combat_type
    local combat_id = fightInfo.combat_id
    local content = {}
    if combat_type == CombatConst.CombatType_Story then
        local partID = fightInfo.partID
        local chapter = math.floor(partID/1000)
        local part = partID%1000
        
        content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "我已通關劇情" or "今日惜敗於劇情", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=" 第" .. tostring(chapter) .. "章第" .. tostring(part) .. "節", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "，一氣呵成，舒服！ " or "，棋差一著，難受！ ", textColor=cp.getConst("GameConst").ChatMsgColor}
		
	elseif combat_type == CombatConst.CombatType_Friend or --好友對戰
            combat_type == CombatConst.CombatType_Arena or --擂臺
            combat_type == CombatConst.CombatType_Shane or --挑戰大俠
	        combat_type == CombatConst.CombatType_InviteHero then--受邀挑戰大俠

		content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "聽聞" or "今日有幸與", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=fightInfo.name, textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "武功高強，今日一戰不過爾爾，輕鬆！ " or "切磋，兩人你來我往，殺得難解難分，快哉！ ", textColor=cp.getConst("GameConst").ChatMsgColor}

    elseif combat_type == CombatConst.CombatType_MenPai then
        if fightInfo.career >= 0 then
            local name = ""
            local cfgItem = cp.getManager("ConfigManager").getItemByKey("GangEnhance",fightInfo.career)
            name = cfgItem:getValue("Name")
            if fightInfo.hierarchy and fightInfo.hierarchy > 0 then
                name = name .. cp.getConst("CombatConst").NumberZh_Cn[fightInfo.hierarchy].. "階接引人" .. fightInfo.name
                if name ~= "" then
                    content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "經過一番歷練，我終於贏得了 " or "由於歷練不足，我在 ", textColor=cp.getConst("GameConst").ChatMsgColor}
                    content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text= name .. " ", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
                    content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "的認可，順利進階。 " or "手中敗下陣來，真是可惜。 ", textColor=cp.getConst("GameConst").ChatMsgColor}
                end

            elseif fightInfo.rank > 0 then
                if fightInfo.rank < 8 then
                    local titleData = cp.getManager("ConfigManager").getItemByKey("Title", fightInfo.career .. "_" .. tostring(fightInfo.rank))
                    name = titleData:getValue("Title")
                    name = "【" .. name .. "】"
                else
                    if fightInfo.rank < 16 then
                        name = "【" .. name .. "天下行走弟子】"
                    elseif fightInfo.rank < 31 then
                        name = "【" .. name .. "真傳弟子】"
                    elseif fightInfo.rank < 532 then
                        name = "【" .. name .. "內門弟子】"
                    else
                        name = "【" .. name .. "外門弟子】"
                    end
                end
                if name ~= "" then
                    content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "我已將" or "今日與", textColor=cp.getConst("GameConst").ChatMsgColor}
                    content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text= name .. fightInfo.name .. " ", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
                    content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "輕鬆擊敗，能者居之，然也！ " or "切磋武藝，稍遜一籌，難受！ ", textColor=cp.getConst("GameConst").ChatMsgColor}
                end
            end
        end
        
	elseif combat_type == CombatConst.CombatType_Van then --伏擊鏢車
        content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text="我在", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text= "【" .. fightInfo.place .. "】", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text="伏擊了", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[4] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=fightInfo.name, textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[5] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "的鏢車，賺了個盆滿鉢滿，開心！ " or "的鏢車，不料竹籃打水一場空，哭唧唧！ ", textColor=cp.getConst("GameConst").ChatMsgColor}

	elseif combat_type == CombatConst.CombatType_Tower then --修羅塔
        
        content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "我已通關修羅塔" or "今日惜敗於修羅塔", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text= "第" .. tostring(fightInfo.floor) .. "層", textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "，坐等超越！ " or "，棋差一著，難受！ ", textColor=cp.getConst("GameConst").ChatMsgColor}

	elseif combat_type == CombatConst.CombatType_GuildWanted then --幫派緝拿
        
        content[1] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "我已將" or "今日緝拿", textColor=cp.getConst("GameConst").ChatMsgColor}
        content[2] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=fightInfo.name, textColor=cp.getConst("GameConst").QualityTextColor[2],outLineEnable=true,outLineColor=cp.getConst("GameConst").QualityOutlineColor[2],outLineSize=2}
        content[3] = {type="ttf", fontSize=22,fontName="fonts/msyh.ttf", text=(fightInfo.result == 1) and "目標成功緝拿，痛快！ " or "目標失敗，讓他逃出生天，可惜！ ", textColor=cp.getConst("GameConst").ChatMsgColor}
	end

    return content
end

--祕境是否在活動時間內
function GDataManager:isMijingInActivityTime(mijing_id)
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameMiJing",mijing_id)
    if cfg ~= nil then
        local Weekday = cfg:getValue("Weekday")  -- 0|1
        local weeks = string.split(Weekday,"|")
        local curDate = cp.getManager("TimerManager"):getDate()
       -- curDate.wday -- 1星期日，2星期一，3，4，5，6，7星期六
        for i=1,table.nums(weeks) do
            if tonumber(weeks[i]) == curDate.wday - 1 then
                return true
            end
        end
    end
    return false
end

--歷練是否在活動時間內
function GDataManager:isLiLianInActivityTime(lilian_id)
    local timeList = {}
    local cfg = cp.getManager("ConfigManager").getItemByKey("GameExercise",lilian_id)
    if cfg ~= nil then
        local curDate = cp.getManager("TimerManager"):getDate()
        local curTimeSec = curDate.hour*60*60+curDate.min*60+curDate.sec

        local Time = cfg:getValue("Time")   -- 12-00-14-00|18-00-20-00
        
        string.loopSplit(Time,"|-",timeList)
        for i=1,table.nums(timeList) do
            local beginTimeSec = tonumber(timeList[i][1])*60*60 + tonumber(timeList[i][2])*60
            local endTimeSec = tonumber(timeList[i][3])*60*60 + tonumber(timeList[i][4])*60
            if curTimeSec >= beginTimeSec and curTimeSec < endTimeSec then
                return true,timeList
            end
        end
    end
    return false,timeList
end

--領取體力時間
function GDataManager:isPhysicalGiftTime()
	local curDate = cp.getManager("TimerManager"):getDate()
	local c = curDate.hour*60*60+curDate.min*60+curDate.sec

    local conf = cp.getManager("ConfigManager").getItemByKey("Other", "physical_time"):getValue("StrValue")
	local times = {}
    string.loopSplit(conf, "|", times)
    

	local index = 1
	for i=1,table.nums(times),4 do
		local b = tonumber(times[i])*60*60 + tonumber(times[i+1])*60
		local e = tonumber(times[i+2])*60*60 + tonumber(times[i+3])*60
		if c >= b and c < e then
			return true, index
		end
		index = index + 1
	end

	return false, 0
end

--裝備附加屬性顏色, 返回字體和描邊顏色
function GDataManager:getEquipAttachAttributeColor(itemid, attType, attVal)
    local colorText,colorOutline = cp.getConst("CombatConst").SkillQualityColor4b[2], cp.getConst("CombatConst").QualityOutlineC4b[2]
	local conf = cp.getManager("ConfigManager").getItemByKey("GameEquip", itemid)
	if conf == nil then
		log("get GameEquip failure, itemid:" .. itemid)
		return colorText,colorOutline
	end

    local attrString = conf:getValue("AttributeRandom")
	--example: 2-30-280;4-20-55;6-30-180;7-30-180;17-30-180;3-30-55;0-30-280
	local color = {}
	local result = {}
	string.loopSplit(attrString, ";-", result)
	for _, v in pairs(result) do
      local min = tonumber(v[2])
      local max = tonumber(v[3])
	  local tmp = (max - min) / 3
	  color[tonumber(v[1])] = {
		  {s = min, 	  	  e = min + tmp, 	 bg = cp.getConst("CombatConst").SkillQualityColor4b[2], outline = cp.getConst("CombatConst").QualityOutlineC4b[2]},
		  {s = min + tmp, 	  e = min + 2 * tmp, bg = cp.getConst("CombatConst").SkillQualityColor4b[5], outline = cp.getConst("CombatConst").QualityOutlineC4b[5]},
		  {s = min + 2 * tmp, e = max, 			 bg = cp.getConst("CombatConst").SkillQualityColor4b[6], outline = cp.getConst("CombatConst").QualityOutlineC4b[6]},
		  }
	end

	-- dump(color)

	local val = color[attType]
	if val == nil then
		log("get color failure, type:" .. attType)
		return colorText,colorOutline
	end

	for _, v in pairs(val) do
		if attVal >= v.s and attVal <= v.e then
			return v.bg, v.outline
		end
	end

	if attVal < val[1].s then
		return val[1].bg, val[1].outline
	end

	if attVal > val[3].e then
		return val[3].bg, val[3].outline
	end

	log("not found color, type:" .. attType .. " value:" .. attValue)
	return colorText,colorOutline
end

function GDataManager:onCreateTextField(node)
	local function editboxHandle(strEventName,sender)
		if strEventName == "began" then   		--光標進入，清空內容/選擇全部
			log("begin")												    
			sender:setText(node:getString())               
		elseif strEventName == "ended" then		--當編輯框失去焦點並且鍵盤消失的時候被調用
			log("ended")												    
			log(sender:getText())												    
			node:setString(sender:getText())
		elseif strEventName == "return" then 	--當用戶點擊編輯框的鍵盤以外的區域，或者鍵盤的Return按鈕被點擊時所調用
			log("return")												    
			log(sender:getText())												    
			node:setString(sender:getText())
		elseif strEventName == "changed" then 	--輸入內容改變時調用 
			log("changed")												    
			log(sender:getText())												    
			node:setString(sender:getText())
		end
	end

	local editTxt = ccui.EditBox:create(node:getContentSize(), ccui.Scale9Sprite:create())

	--local editTxt= ccui.EditBox:create(cc.size(350,100), "D:\\ui_chat_module33_liaotian_di01.png")  --輸入框尺寸，背景圖片
    editTxt:setName("inputTxt")
    editTxt:setAnchorPoint(0,0)
    editTxt:setPosition(0,0)                        	--設置輸入框的位置
    editTxt:setFontSize(30)                            	--設置輸入設置字體的大小
    editTxt:setMaxLength(100)                           	--設置輸入最大長度為6
    editTxt:setFontColor(cc.c4b(255,255,255,0))       --設置輸入的字體顏色
    editTxt:setFontName("fonts/msyh.ttf")               --設置輸入的字體為simhei.ttf
    editTxt:setInputMode(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS) --設置數字符號鍵盤
 	--editTxt:setPlaceHolder(node:getString())                		--設置預製提示文本
    editTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)  --輸入鍵盤返回類型，done，send，go等KEYBOARD_RETURNTYPE_DONE
    editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 	--輸入模型，如整數類型，URL，電話號碼等，會檢測是否符合
    editTxt:registerScriptEditBoxHandler(function(eventname,sender) editboxHandle(eventname,sender) end) --輸入框的事件，主要有光標移進去，光標移出來，以及輸入內容改變等
	node:addChild(editTxt,5)
	--self.editTxt = editTxt
--  editTxt:setHACenter() --輸入的內容錨點為中心，與anch不同，anch是用來確定控件位置的，而這裡是確定輸入內容向什麼方向展開(。。。說不清了。。自己測試一下)
    return editTxt
end

--獲取自動售賣狀態
function GDataManager:getAutoSellState()
    local selectedState = {0,0,0,0}
    local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")
    for i=0,3 do
        local ss = bit.lshift(1, i)
        selectedState[i+1] = bit.band(ss, majorRole.exerciseAuto) == ss and 1 or 0
    end
    return selectedState
end

function GDataManager:flashForver(node, interval) 
    local function func1()
		node:setBrightStyle(ccui.BrightStyle.highlight)
    end

    local function func2()
		node:setBrightStyle(ccui.BrightStyle.normal)
    end

    node:runAction(cc.RepeatForever:create(cc.Sequence:create(
	cc.CallFunc:create(func1),
	cc.DelayTime:create(interval),
	cc.CallFunc:create(func2),
	cc.DelayTime:create(interval)
	)))
end

function GDataManager:flash(node, interval, times) 
    local function func1()
		node:setBrightStyle(ccui.BrightStyle.highlight)
    end

    local function func2()
		node:setBrightStyle(ccui.BrightStyle.normal)
    end

    node:runAction(cc.Repeat:create(cc.Sequence:create(
	cc.CallFunc:create(func1),
	cc.DelayTime:create(interval),
	cc.CallFunc:create(func2),
	cc.DelayTime:create(interval)
	), times))
end

function GDataManager:setFeature(button, lockTip, v) 
	if button == nil or lockTip == nil or v == nil then
		return
    end

    if v.type == nil then
        return
    end
    
    if cp.getManager("ConfigManager").getItemByKey("Feature", v.type) == nil then
        return
    end

	local lockPic = cp.getManager("ConfigManager").getItemByKey("Feature", v.type):getValue("Pic")
	if lockPic == nil then
		return
	end

	--cp.getManager("ViewManager").setShader(button, nil)
	lockTip:setVisible(true)

	if v.value == 0 then --鎖定
		lockTip:loadTexture(lockPic, ccui.TextureResType.plistType)
		--cp.getManager("ViewManager").setShader(button, "GrayShader")
	elseif v.value == 1 then --解鎖
		lockTip:loadTexture("ui_major_unlock.png", ccui.TextureResType.plistType)
	elseif v.value == 2 then --開啟
		lockTip:setVisible(false)
	end
end

function GDataManager:getFeatureState(id) 
    local major_feature = cp.getUserData("UserRole"):getValue("major_feature")
	for _, v in ipairs(major_feature) do
        if v.type == id then
            return v.value  --鎖定 0 ,解鎖 1, 開啟 2
        end
    end
    return -1
end

--判斷是否顯示新 
--return table, key: id, value: bool
--id：1都城，2門派，3角色，4揹包，5武學，6江湖
function GDataManager:showNew() 
	local ret = {false, false, false, false, false, false}

    local cnt = cp.getManager("ConfigManager").getItemCount("Feature")
    for i=1,cnt do
		local st = self:getFeatureState(i)
		local cfg = cp.getManager("ConfigManager").getItemAt("Feature",i)
		if cfg then
			local sys = cfg:getValue("Sys")
			--解鎖狀態為新
			if st == 1 then
				ret[sys] = true
			end
			--江湖多一個條件
			if sys == 6 then
				if self:getHierarchyExercise() == false then
					ret[sys] = true
				end
			end
		end
    end
	return ret
end

function GDataManager:procFeatureState(id, node) 
	local major_feature = cp.getUserData("UserRole"):getValue("major_feature")
	for _, v in ipairs(major_feature) do
		if v.type == id then
			if v.value == 0 then --鎖定
				local tip = cp.getManager("ConfigManager").getItemByKey("Feature", v.type):getValue("Tip")
				cp.getManager("ViewManager").gameTip(tip)
			elseif v.value == 1 then --解鎖
				node:doSendSocket(cp.getConst("ProtoConst").FeatureReq, {unlockID = id})
			elseif v.value == 2 then --開啟
			end
			return v.value
		end
	end
	cp.getManager("ViewManager").gameTip("無解鎖數據")
	return -1
end

function GDataManager.GetRankListAward(rankType, rank)
    local rankEntry = nil
    local lastRank = 1
    cp.getManager("ConfigManager").foreach("RankAward", function(item)
        if rank >= lastRank and rank <= item:getValue("Rank") then
            rankEntry = item
            return false
        end

        lastRank = item:getValue("Rank") + 1                                                                       
        return true 
    end)

    return rankEntry
end

function GDataManager.getRankPlace(rank)
    local place = -1
    cp.getManager("ConfigManager").foreach("GangRank", function(cfgItem)
        local info = cp.getUtils("DataUtils").split(cfgItem:getValue("ID"), "-")
        if #info == 1 then
            if rank == info[1] then
                place = cfgItem:getValue("Grade")
                return false
            end
        elseif #info == 2 then
            if rank >= info[1] and rank <= info[2] then
                place = cfgItem:getValue("Grade")
                return false
            end
        end

        return true
    end)

    return place
end

function GDataManager:checkPackageFull()
	--檢測是否揹包滿了。
	local major_roleItem = cp.getUserData("UserItem"):getValue("major_roleItem") or {}
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")

	return table.nums(major_roleItem) >= majorRole.packSize 
end

--獲取邀請好友的禮包狀態
function GDataManager:getInviteGiftState(gift_id)
    local giftStateList = cp.getUserData("UserInvite"):getValue("giftState")
    if giftStateList and next(giftStateList) then
        for i=1,table.nums(giftStateList) do
            if giftStateList[i] and giftStateList[i].id == gift_id then 
                return giftStateList[i]
            end
        end
    end
    return nil
end

--獲取禮包可領取獎勵狀態
function GDataManager:checkInviteGiftStateNotice()
    local noticeGift = {}
    local noticeType = {0,0}
    local giftStateList = cp.getUserData("UserInvite"):getValue("giftState")
    if giftStateList and next(giftStateList) then
        for i=1,table.nums(giftStateList) do
            if giftStateList[i] and giftStateList[i].openCount > giftStateList[i].getCount then 
                table.insert(noticeGift,giftStateList[i].id)

                local cfg = cp.getManager("ConfigManager").getItemByMatch("InviteGift",{ID = giftStateList[i].id})
                local Type = cfg:getValue("Type")
                if Type == 2 then
                    noticeType[2] = 1
                else
                    noticeType[1] = 1
                end
            end
        end
    end
    return noticeGift,noticeType
end

--獲取俠客行表格配置數據
function GDataManager:getHeroStroyInfo()
    local infoList = {}
    local all_id_list = {}
	local cnt = cp.getManager("ConfigManager").getItemCount("HeroStory")
	for i=1,cnt do
        local cfgItem = cp.getManager("ConfigManager").getItemAt("HeroStory",i)
        if cfgItem then
            local ID = cfgItem:getValue("ID")
            if ID % 1000 == 0 then
                local info =  {ID = math.floor(ID/1000), Name = cfgItem:getValue("Name"), BgIcon = cfgItem:getValue("BgIcon"), PrimevalID = cfgItem:getValue("PrimevalID")}
                table.insert(infoList,info) 
            else
                table.insert(all_id_list,ID)
            end
        end
    end
    
    if table.nums(infoList) > 1 then
        table.sort(infoList,function(a,b)
            return a.ID < b.ID
        end)
    end
	return infoList,all_id_list
end

--通過章id獲取本章內所有節的id
function GDataManager:getHeroStroyPartIDList(chapterId)
    local idList = {}
    local cnt = cp.getManager("ConfigManager").getItemCount("HeroStory")
    local i=1
    while(cnt > 0 ) do
        local id = chapterId * 1000 + i
        local cfg = cp.getManager("ConfigManager").getItemByKey("HeroStory",id)
        if cfg then
            i = i + 1
            cnt = cnt - 1
            table.insert(idList,id)
        else
            break
        end
    end
    return idList
end

--獲取每一章的通關狀態
function GDataManager:getHeroStroyChapterState(idList)
    -- //額外獎勵領取狀態 0 未達成， 1 可領取， 2 已領取, 格式[(關卡id1, 狀態), (關卡id2, 狀態)]
    local box_award_state_list = cp.getUserData("UserXiakexing"):getValue("box_award_state_list")
    local current = cp.getUserData("UserXiakexing"):getValue("current")
    local unclearedCount = 0
    local clearedCount = 0
    local canGetBoxReward = false
    for i=1,table.nums(idList) do
        if current <= idList[i] then
            unclearedCount = unclearedCount + 1
        else
            clearedCount = clearedCount + 1
            local state = box_award_state_list[idList[i]] or 0
            if state == 2 then
                canGetBoxReward = true
            end
        end
    end

    local result = 0 -- 0未解鎖 1未通關， 2已通關
    if unclearedCount == table.nums(idList) then
        result = 0
    else
        result = clearedCount < table.nums(idList) and 1 or 2
    end

    return result,canGetBoxReward
end


--獲取逐鹿戰場所有建築訊息
function GDataManager:getZhulujianghuAllBuildInfo()
    local infoList = {}
    local cnt = cp.getManager("ConfigManager").getItemCount("DeerCity")
    for i=1,cnt do
        local cfg = cp.getManager("ConfigManager").getItemAt("DeerCity",i)
        if cfg then
            local Type = cfg:getValue("Type")
            local ID = cfg:getValue("ID")
            local Name = cfg:getValue("Name")
            local BufferID = cfg:getValue("BufferID")
            local Hp = cfg:getValue("Hp")
            local Pos = cfg:getValue("Pos")
            local IconNormal = cfg:getValue("IconNormal")
            local IconBroken = cfg:getValue("IconBroken")
            local arr = {}
            string.loopSplit(Pos,"|-",arr)
            infoList[ID]= {ID=ID,Type=Type,Name=Name,BufferID=BufferID,Hp=Hp,IconNormal=IconNormal,IconBroken=IconBroken,posArr=arr}
        end
    end
    return infoList
end

--獲取本地化類型 return: 0 簡體中文， 1 繁體中文
function GDataManager:getTextLocalType() 
	return 1
end

function GDataManager:getTextFormat(str) 

	local conf = cp.getManager("ConfigManager").getItemByKey("TextFormat", str)
	local localtype = self:getTextLocalType()
	if localtype == 0 then
		 return conf:getValue("Format")
	end

	if localtype == 1 then
		return conf:getValue("Format2")
	end
	return ""
end

function GDataManager:getUnlockInfoList()
    local infoList = {}
    local cnt = cp.getManager("ConfigManager").getItemCount("Feature")
    for i=1,cnt do
        local cfg = cp.getManager("ConfigManager").getItemAt("Feature",i)
        if cfg then
            local ID = cfg:getValue("ID")
            local Desc = cfg:getValue("Desc")
            local Level = cfg:getValue("Level")
            local Icon = cfg:getValue("Icon")
            infoList[ID]= {ID=ID,Level=Level,Icon=Icon,Desc=Desc}
        end
    end
    return infoList
end

function GDataManager:setFightDelay(delay)
	if self.fightDelay == nil then
		self.fightDelay = false 
	end
	self.fightDelay = delay 
end

function GDataManager:getFightDelay()
	if self.fightDelay == nil then
		self.fightDelay = false 
	end
	return self.fightDelay 
end

function GDataManager:addFightBuff(oldFight, newFight)
	if self.fightBuff == nil then
		self.fightBuff = {}
	end
	self.fightBuff["oldFight"] = oldFight
	self.fightBuff["newFight"] = newFight
end

function GDataManager:showFightBuff()
	if self.fightBuff == nil then
		return
	end
	local oldFight = self.fightBuff["oldFight"] 
	local newFight = self.fightBuff["newFight"] 
	cp.getManager("ViewManager").fightTip(oldFight, newFight)
	self.fightBuff = nil
	self:setFightDelay(false)
end

function GDataManager:showFightChange(oldFight, newFight) 
	if oldFight == newFight then
		return
	end

	if oldFight == 0 then
		return
	end

	if self:getFightDelay() then
		self:addFightBuff(oldFight, newFight)
		self:setFightDelay(false)
		log("delay")
		return
	end

	cp.getManager("ViewManager").fightTip(oldFight, newFight)
end


--獲取成就配置訊息
function GDataManager:getAchivementConfigInfo()
    local infoList = {}
    local cnt = cp.getManager("ConfigManager").getItemCount("Achieve")
    for i=1,cnt do
        local cfg = cp.getManager("ConfigManager").getItemAt("Achieve",i)
        if cfg then
            local ID = cfg:getValue("ID")
            local Desc = cfg:getValue("Desc")
            local Level = cfg:getValue("Level")
            local Hierarchy = cfg:getValue("Hierarchy")
            local Icon = cfg:getValue("Icon")
            local ShowType = cfg:getValue("ShowType")
            local Items = cfg:getValue("Items")
            local Att = cfg:getValue("Att")
            local Quality = cfg:getValue("Quality")
            local Title = cfg:getValue("Title")
            local Type = cfg:getValue("Type")
            local Condition1 = cfg:getValue("Condition1")
            local Condition2 = cfg:getValue("Condition2")
            local Condition3 = cfg:getValue("Condition3")
            local QualityText = cfg:getValue("QualityText")
            

            infoList[ID]= {ID=ID,Level=Level,Icon=Icon,Desc=Desc,Hierarchy=Hierarchy,ShowType=ShowType,Quality=Quality,Title=Title,Type=Type,Items=Items,Att=Att,Condition1=Condition1,Condition2=Condition2,Condition3=Condition3,QualityText=QualityText}
        end
    end
    return infoList
end

--升階後是否打開過歷練界面
function GDataManager:setHierarchyExercise(open)
	cp.getManager("LocalDataManager"):setUserValue("tip_info","HierarchyExercise", open)
end

--false 沒開過， true 開過
function GDataManager:getHierarchyExercise()
	local ret = cp.getManager("LocalDataManager"):getUserValue("tip_info","HierarchyExercise", nil)
	if ret == nil then
		log("error")
		return true
	end
	return ret
end

function GDataManager:hierarchyChange(olddata, newdata)
	if olddata == 0 or newdata == 0 then
		return
	end
	if olddata < newdata then
		self:setHierarchyExercise(false)
	end
end


return GDataManager

