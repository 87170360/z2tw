--基本的一些工具類方法寫在這裡

local BaseUtils = {}

--獲取時間（單位秒）的小時，分，秒數
function BaseUtils.getTimeSplit(time)
    time = math.modf(tonumber(time) or 0)
    local hour = math.floor(time/3600)
    local minute = math.floor((time%3600)/60)
    local second = time%60
    return hour,minute,second
end

--通過位數獲取數值的string型，前面幾位如為空則補0
function BaseUtils.getStrNum(num , zerocnt)
    zerocnt = zerocnt or 0
    local intnum = math.modf(tonumber(num) or 0)
    local strintnum = tostring(intnum) or ""
    local ret = tostring(num) or ""
    if #strintnum < zerocnt then
        --補0
        for i=#strintnum+1,zerocnt do
            ret = "0" .. ret
        end
    end
    return ret
end

--獲取時間（單位秒）的小時，分，秒數 。 返回3個值的string類型，不足2位補0
function BaseUtils.getStrTimeSplit(time)
    local hour,minute,second = BaseUtils.getTimeSplit(time)
    local strhour = BaseUtils.getStrNum(hour , 2)
    local strminute = BaseUtils.getStrNum(minute , 2)
    local strsecond = BaseUtils.getStrNum(second , 2)
    return strhour,strminute,strsecond
end

----------------------顏色相關-------------------------------------
function BaseUtils.convertC4bToC3b(c4b)
    return cc.c3b(c4b.r,c4b.g,c4b.b)
end

function BaseUtils.convertC3bToC4b(c3b)
    return cc.c4b(c3b.r,c3b.g,c3b.b,255)
end

function BaseUtils.convertHexToARGB(hexValue)
	local hexValue = tostring(hexValue)
	local b = tonumber(string.sub(hexValue,-2,-1),16)
	local g = tonumber(string.sub(hexValue,-4,-3),16)
	local r = tonumber(string.sub(hexValue,-6,-5),16)
	local a = tonumber(string.sub(hexValue,-8,-7),16)
	
	if a == nil then
		return cc.c4b(r,g,b,255)
	else
		return cc.c4b(r,g,b,a)
	end
end
------------------------end of 顏色相關-----------------------------



-------------------------數據加密------------------------------------
BaseUtils._encodeKey = math.random(10001,99999)
-- BaseUtils._encodeKey = 60631

function BaseUtils.encodeData(data)
    if type(data) ~= "string" and  type(data) ~= "number" then
        return nil
    end
    local numkey = BaseUtils._encodeKey
    data = checkstring(data)
    local strlen = string.len(data)
    local ret = ""
    for i=1,strlen do
        local bytenum = string.byte(data,i)
        local encodebyte = bit.bxor(bytenum,numkey)
        ret = ret .. encodebyte
        if i ~= strlen then
            ret = ret .. "_"
        end
    end
    return ret
end

--decodeType 默認1解析為number，2解析為string
function BaseUtils.decodeData(data,decodeType)
    if type(data) ~= "string" then
        return nil
    end
    local numkey = BaseUtils._encodeKey
    local dataTable = string.split(data, "_")
    local ret = ""
    for i,bytenum in ipairs(dataTable) do
        bytenum = checknumber(bytenum)
        local decodebyte = bit.bxor(bytenum,numkey)
        local strchar = string.char(decodebyte)
        ret = ret .. strchar
    end
    decodeType = decodeType or 1
    if decodeType == 2 then
        --do nothing
    else
        ret = checknumber(ret)
    end
    return ret
end


function BaseUtils.xxtea_encode(data,key)
    data = checkstring(data)
    key =  checkstring(key)
    return cp.CpEncrypter:xxtea_encode(data,key)
end

function BaseUtils.xxtea_decode(data,key)
    data = checkstring(data)
    key =  checkstring(key)
    return cp.CpEncrypter:xxtea_decode(data,key)
end

function BaseUtils.xxtea_encodeData(data)
    return BaseUtils.xxtea_encode(data,BaseUtils._encodeKey)
end

function BaseUtils.xxtea_decodeData(data)
    return BaseUtils.xxtea_decode(data,BaseUtils._encodeKey)
end

--------------------end of 數據加密---------------------------------




--通過路徑獲取文件名，默認不包含後綴 如"effect/role/eff_role_shaowei_1.csb"，得到"eff_role_shaowei_1"
function BaseUtils.getFileName(fullPath,containExtension)
    fullPath = string.gsub(fullPath,"\\","/")
    local str = string.match(fullPath, ".+/([^/]*%.%w+)$")
    if containExtension then
        return str
    else
        local idx = str:match(".+()%.%w+$")  
        if(idx) then  
            return str:sub(1, idx-1)  
        else  
            return str  
        end     
    end
end

--獲取文件路徑  
function BaseUtils.getFilePath(fullPath)  
   return string.match(fullPath, "(.+)/[^/]*%.%w+$") 
end  
  
--獲取擴展名  
function BaseUtils.getFileExtension(fullPath)  
    return fullPath:match(".+%.(%w+)$")  
end  

--標籤文本轉換  只能靠[#1]物理技能[#2]魔法技能
--例：local str2 = [[<fontsize=16><color=0xFFFFFF>恭喜您！您以</color><color=0xFF0000>#1幸運幣</color><color=0xFFFFFF>競拍成功，獲得</color><color=0xFFFF00>【#2】</color></fontsize>]]
function BaseUtils.convertTagString(input)

	input = tostring(input)
	if (input=='') then return nil end

	local pos,arr = 1, {}
	while true do
		local i,j = string.find(input,"^%<(.-)%=",pos,false)
		if i==nil or j==nil then
			break
		end
		--log(string.format("i=%s,j=%s",tostring(i),tostring(j)))

		local item = {}
		--取出標籤
		local strSub = string.sub(input,i+1,j-1)
		--log(string.format("strSub=%s,i=%d,j=%d",strSub,i+1,j-1))
		item.tag = strSub

		--取出標籤值
		local m = string.find(input,">",j,true)
		--log(string.format("m=%s",tostring(m)))
		local strSub2 = string.sub(input,j+1,m-1)
		--log(string.format("strSub2=%s,i=%d,j=%d",strSub2,j+1,m-1))
		item.tagValue = strSub2

		--取出標籤對應的內容
		local x,y = string.find(input, "</" .. strSub .. ">" , m, true)
		--log(string.format("x=%s,y=%s",tostring(x),tostring(y)))
		local strSub3 = string.sub(input,m+1,x-1)
		--log(string.format("strSub3=%s,x=%d,y=%d",strSub3,m+1,x-1))


        local subTable = BaseUtils.convertTagString(strSub3)
		if subTable == nil or table.nums(subTable) == 0 then
			item.content = strSub3
		else
			if item.content == nil then
				item.content = {}
			end
			item.content = subTable
		end
		table.insert(arr,item )
		pos = y + 1

	end
	return arr
end

--錶轉string
function BaseUtils.tableToStr(srcTab)
        local desStr = ""
        local split = ","
        local i = 1
        for k, v in pairs(srcTab) do
                if v ~=nil or v ~= "" then
                    if i < #srcTab then
                        desStr = desStr..v..split
                    else
                        desStr = desStr..v
                    end
                end
                i = i+1
        end
        return desStr
end

--string轉表
function BaseUtils.strToTable(str, type)
        local desTab = {}
        local split = ","
        local srcTab = string.split(str, split)
        for k, v in pairs(srcTab) do
                if type == "number" then
                    desTab[k] = tonumber(v)
                else
                    desTab[k] = v
                end
        end
        return desTab
end

return BaseUtils
