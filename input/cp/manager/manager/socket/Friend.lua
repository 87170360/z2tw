local ProtoConst = cp.getConst("ProtoConst")
--解析從伺服器收到的數據，
local m = {
    [ProtoConst.GetFriendDataRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserFriend"):setValue("PlayerSimpleData", {})
            cp.getUserData("UserFriend"):setValue("FriendData", proto.friend_data)
        end
    end,
    [ProtoConst.GetRoleSimpleRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserFriend"):updatePlayerSimpleData(proto.player_info_list)
            self:dispatchViewEvent(cp.getConst("EventConst").GetRoleSimpleRsp , proto.player_info_list)
        end
    end,
    [ProtoConst.DeleteFriendRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserFriend"):deleteFriend(proto.player_info)
            self:dispatchViewEvent(cp.getConst("EventConst").DeleteFriendRsp , proto.player_info)
        end
    end,
    [ProtoConst.AddFriendRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getManager("ViewManager").gameTip("好友請求已發送")
            cp.getUserData("UserFriend"):addFriendRequest(proto.request_info)
            self:dispatchViewEvent(cp.getConst("EventConst").AddFriendRsp , proto.request_info)
        elseif proto.result == 1 then
            cp.getManager("ViewManager").gameTip("對方已經在您的好友列表裡了")
        elseif proto.result == 3 then
            cp.getManager("ViewManager").gameTip("對方在您的對立列表中")
        end
    end,
    [ProtoConst.AddFriendNotifyRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserFriend"):addFriendRequestNotify(proto.request_info)
            self:dispatchViewEvent(cp.getConst("EventConst").AddFriendNotifyRsp , proto.request_info)
        end
    end,
    [ProtoConst.AgreeRequestRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 and proto.player_list then
            cp.getUserData("UserFriend"):deleteResponse(proto.player_list)
            cp.getUserData("UserFriend"):deleteRequest(proto.player_list)
            cp.getUserData("UserFriend"):addFriend(proto.player_list)
            self:dispatchViewEvent(cp.getConst("EventConst").AgreeRequestRsp)
        end
    end,
    [ProtoConst.DeclineRequestRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            cp.getUserData("UserFriend"):deleteResponse(proto.player_list)
            cp.getUserData("UserFriend"):deleteRequest(proto.player_list)
            self:dispatchViewEvent(cp.getConst("EventConst").DeclineRequestRsp)
        end
    end,
    [ProtoConst.SearchPlayerRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        if proto.result == 0 then
            self:dispatchViewEvent(cp.getConst("EventConst").SearchPlayerRsp, proto.player_list)
        end
    end,
    [ProtoConst.PlayerLoginNotifyRsp] = function(self,key,proto,senddata)
        if proto.result == -1 then
            cp.getManager("ViewManager").gameTip("伺服器請求超時")
            return
        end

        cp.getUserData("UserFriend"):updateOnlineStatus(proto.player_info, true)
        self:dispatchViewEvent(cp.getConst("EventConst").PlayerLoginNotifyRsp)
    end,
    [ProtoConst.PlayerLogoutNotifyRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserFriend"):updateOnlineStatus(proto.player_info, false)
        self:dispatchViewEvent(cp.getConst("EventConst").PlayerLogoutNotifyRsp)
    end,
    [ProtoConst.ChangeSearchListRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserFriend"):updateRequestList(proto.request_list)
        self:dispatchViewEvent(cp.getConst("EventConst").ChangeSearchListRsp)
    end,
    [ProtoConst.FriendFightRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserCombat"):setCombatReward(proto.combat_reward)
        self:dispatchViewEvent(cp.getConst("EventConst").FriendFightRsp)
    end,
    [ProtoConst.EnemyFightRsp] = function(self,key,proto,senddata)
        if proto.result == 1 then
            cp.getManager("ViewManager").gameTip("罪惡值已滿，不能比試")
        end

        if proto.result == 0 then
            self:dispatchViewEvent(cp.getConst("EventConst").EnemyFightRsp)
        end
    end,
    [ProtoConst.AddEnemyRsp] = function(self,key,proto,senddata)
        if proto.result == 3 then
            cp.getManager("ViewManager").gameTip("對方在您好友列表中")
            return
        elseif proto.result == 2 then
            cp.getManager("ViewManager").gameTip("該玩家已在您的對立列表裡了")
        elseif proto.result == 0 then
            cp.getManager("ViewManager").gameTip("操作成功")
        end
        
        cp.getUserData("UserFriend"):addEnemy(proto.player_info)
        self:dispatchViewEvent(cp.getConst("EventConst").AddEnemyRsp)
    end,
    [ProtoConst.DeleteEnemyRsp] = function(self,key,proto,senddata)
        cp.getUserData("UserFriend"):deleteEnemy(proto.player_info)
        self:dispatchViewEvent(cp.getConst("EventConst").DeleteEnemyRsp)
    end,
}

return m