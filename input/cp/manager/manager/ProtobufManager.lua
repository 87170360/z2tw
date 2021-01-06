local ProtobufManager = class("ProtobufManager")

function ProtobufManager:create()
    local ret =  ProtobufManager.new() 
    ret:init()
    return ret
end  

function ProtobufManager:init()
    require("cp.manager.manager.pbc.protobuf")
    require "protobuf"
    self.msgs = {}
end


function ProtobufManager:registerFiles(files)
    local idx1 = table.arrIndexOf(files,"prt/skill.prt")
    local idx2 = table.arrIndexOf(files,"prt/role.prt")
    if idx1 > idx2 then
        files[idx1] = "prt/role.prt"
        files[idx2] = "prt/skill.prt"
    end

    for _,prtFile in ipairs(files) do
        log("register file="..prtFile)
        local fullpath = ""
 --log("ProtobufManager:registerFiles prtFile=" .. prtFile)
        if device.platform == "mac" or device.platform == "ios" then
            local prtfilename = string.sub(prtFile,string.len("prt/")+1)
            fullpath = cc.FileUtils:getInstance():fullPathForFilename(prtFile)
        else
           fullpath = cc.FileUtils:getInstance():fullPathForFilename(prtFile) 
        end
 --log("ProtobufManager:registerFiles fullpath=" .. fullpath)
        local buffer = cc.FileUtils:getInstance():getStringFromFile(fullpath)

        --local buffer = cc.FileUtils:getInstance():getDataFromFile(prtFile)
        protobuf.register(buffer)

        local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
        local proto = t.file[1]
        local msgs = proto.message_type
        for _, msg in ipairs(msgs) do
            local msgName 
            if proto.package and proto.package~=""  then
                msgName = proto.package .. "." .. msg.name
            else
                msgName = msg.name
            end
            self.msgs[msgName] = {}
            for _,item in ipairs(msg.field) do
                local mitem = {}
                mitem.name = item.name
                mitem.label = item.label
                mitem.type = item.type
                if mitem.type == "TYPE_MESSAGE" then
                    mitem.type_name = string.sub(item.type_name,2)
                end
                table.insert(self.msgs[msgName],mitem)
            end
        end
    end

end

function ProtobufManager:decode(protoName,data)
    return protobuf.decode(protoName, data)
end

function ProtobufManager:encode(protoName,data)
    return protobuf.encode(protoName, data)
end

function ProtobufManager:decodeProtoUserData2Tabel(protoName,proto)
    local ret = {}
    if self.msgs[protoName]~=nil then
        for _,mitem in ipairs(self.msgs[protoName]) do
            if mitem.label == "LABEL_REPEATED" then
                ret[mitem.name] = {}
                for _,proto2 in ipairs(proto[mitem.name]) do
                    if mitem.type == "TYPE_MESSAGE" then
                        table.insert(ret[mitem.name],self:decodeProtoUserData2Tabel(mitem.type_name,proto2))
                    else
                        table.insert(ret[mitem.name],proto2)
                    end
                end
            else
                if mitem.type == "TYPE_MESSAGE" then
                    ret[mitem.name] = self:decodeProtoUserData2Tabel(mitem.type_name,proto[mitem.name])
                else
                    if type(proto) == "boolean" then
                        log("mitem.name = " .. mitem.name, ",protoName = " .. protoName)
                    end
                    ret[mitem.name] = proto[mitem.name]
                end
            end
        end
    end
    return ret
end

function ProtobufManager:decode2Table(protoName,data)
    local proto = protobuf.decode(protoName, data)
    return self:decodeProtoUserData2Tabel(protoName,proto)
end


        -- local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
        -- proto = t.file[1]
        -- print(proto.name)
        -- print(proto.package)
        -- message = proto.message_type
        -- for _,v in ipairs(message) do
        --     print(v.name)
        --     for _,v2 in ipairs(v.field) do
        --         print("\t".. v2.name .. " ["..v2.number.."] " .. v2.label .." ["..v2.type.."] " ..v2.type_name )
        --         -- for k3,v3 in pairs(v2) do
        --         --     if type(k3)=="string" or type(k3)=="number" then
        --         --         print ("\t"..k3..":")
        --         --     end
        --         -- end
        --     end
        -- end
-- v2.name : msgIdx
-- v2.label : LABEL_REPEATED
-- v2.type:             TYPE_MESSAGE
-- v2.type_name:            .NetProto.CCityAttribute



return ProtobufManager
