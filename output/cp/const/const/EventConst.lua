-------遊戲中，需要發送的各種事件常量寫在這裡-----------
-- 需要把事件按對應模塊分類放在一起，方便查找    ------
-- 需要寫註釋，標明事件常量的用處，以及參數列表 -----
---------------------------------------------------------------------------

local EventConst = {}


--=====界面跳轉公用事件=====================

--[[
    需要打開遊戲中某個場景層界面的時候調用 
    參數:     
         open_info: 要打開的場景界面的訊息，包含name... , 以及打開此界面傳遞的參數
         back_info: 當前要關閉界面的訊息，包含name... , 以及保存此界面的參數,當下次打開時使用 
]]
EventConst.game_world_to_open_module = "game_world_to_open_module"

--[[
    需要關閉遊戲中某個場景層全部界面的時候調用 
    參數:無 
]]
EventConst.game_world_to_close_module = "game_world_to_close_module"

--[[
    返回按鈕觸發的界面關閉事件 
    參數:無
]]
EventConst.game_world_to_return_module = "game_world_to_return_module"
--==================================================================


--=============註冊登錄模塊事件==============

--[[
    遊客登入返回
]]
EventConst.GuestRsp = "GuestRsp"

--[[
    普通登入返回
]]
EventConst.LoginRsp = "LoginRsp"

--[[
    註冊返回
]]
EventConst.RegisterRsp = "RegisterRsp"

--[[
    伺服器列表返回
]]
EventConst.ZoneRsp = "ZoneRsp"

--[[
    創建角色返回
]]

EventConst.CreateRsp = "CreateRsp"
--[[
    獲取角色屬性返回
]]
EventConst.GetRoleRsp = "GetRoleRsp"
EventConst.UpdateCurrencyRsp = "UpdateCurrencyRsp"
EventConst.onRoleLevelChange = "onRoleLevelChange"
--[[
    獲取角色物品返回
]]
EventConst.GetRoleItemRsp = "GetRoleItemRsp"

--[[
    進入遊戲服返回
]]
EventConst.EnterGameRsp = "EnterGameRsp"

--查看玩家訊息
EventConst.ViewPlayerRsp = "ViewPlayerRsp"

--查看物品詳情訊息
EventConst.ViewItemRsp = "ViewItemRsp"

--物品更新
EventConst.ItemUpdateRsp = "ItemUpdateRsp"

--出售物品
EventConst.SellItemRsp = "SellItemRsp"

--學習武學書
EventConst.SkillItemRsp = "SkillItemRsp"

------------- 大地圖相關事件 begin ---------------
--吃瓜群眾
EventConst.IdleStaffRsp = "IdleStaffRsp"

--請求善惡事件列表返回
EventConst.GetConductRsp = "GetConductRsp"

--開啟掛機善惡事件
EventConst.StartHangConductRsp = "StartHangConductRsp"

--開啟挑戰善惡事件
EventConst.StartFightConductRsp = "StartFightConductRsp"

--打斷善惡事件返回
EventConst.BreakHangConductRsp = "BreakHangConductRsp"

--[[
    --更新善惡事件
]]
EventConst.UpdateHangConductRsp = "UpdateHangConductRsp"

--停止善惡事件
EventConst.StopConductRsp = "StopConductRsp"

--挑戰吃瓜群眾
EventConst.StartFightIdleStaffRsp = "StartFightIdleStaffRsp"

--獲取大俠列表
EventConst.GetHeroRsp = "GetHeroRsp"

--挑戰大俠
EventConst.StartFightHeroRsp = "StartFightHeroRsp"

--收買大俠
EventConst.BribeHeroRsp = "BribeHeroRsp"
--收買所有大俠
EventConst.BribeAllHeroRsp = "BribeAllHeroRsp"
--領取累積獎勵
EventConst.GetAccuAwardRsp = "GetAccuAwardRsp"
--求助挑戰大俠
EventConst.InviteHeroRsp = "InviteHeroRsp"
--接受並幫助挑戰大俠
EventConst.AcceptHeroRsp = "AcceptHeroRsp"
--他人幫助挑戰大俠結果返回
EventConst.OtherDefeatRsp = "OtherDefeatRsp"
--查看大俠狀態
EventConst.ViewHeroStateRsp = "ViewHeroStateRsp"



EventConst.GetSelfVanRsp = "GetSelfVanRsp"  --獲取個人鏢車訊息
EventConst.StartVanRsp = "StartVanRsp"      --開始押鏢
EventConst.RefreshSelfVanRsp = "RefreshSelfVanRsp" --刷新所有未開始的鏢車
EventConst.GetAllVanRsp = "GetAllVanRsp" --獲取所有其他人的鏢車訊息列表返回
EventConst.RobVanRsp = "RobVanRsp" --伏擊返回
EventConst.BeRobVanRsp = "BeRobVanRsp" --被伏擊返回
EventConst.BuyRobRsp = "BuyRobRsp" --購買伏擊次數返回

EventConst.ExpressFinished = "ExpressFinished"  --押鏢完成

EventConst.onEnterRestErea = "onEnterRestErea" --進入鏢車休息區，顯示頭像

------------- 大地圖相關事件 end ---------------


--[[
    斷線重連重發驗證協議返回
]]
EventConst.ReconnectRsp = "ReconnectRsp"

--重連並且伺服器驗證成功
EventConst.ReconnectLoginOK = "ReconnectLoginOK"


--[[
    獲取章節訊息列表返回
]]
EventConst.GetStoryInfoRsp = "GetStoryInfoRsp"

--[[
	返回戰鬥訊息
]]
EventConst.EnterStoryLevelRsp = "EnterStoryLevelRsp"

--[[
    掃蕩結果返回
]]
EventConst.SweepStoryRsp = "SweepStoryRsp"

--重置掃蕩或挑戰次數返回
EventConst.ResetStoryRsp = "ResetStoryRsp"

--查詢戰鬥錄像
EventConst.GetCombatDataRsp = "GetCombatDataRsp"

--查詢戰鬥錄像
EventConst.GetCombatListRsp = "GetCombatListRsp"

--[[
    大地圖中玩家移動到指定位置後，給地圖層發送移動結束消息 
    參數:     
         role: 當前移動結束的玩家MapRole
]]
EventConst.map_role_move_to = "map_role_move_to"

--移動到建築附近後操作
EventConst.onOpenAcceptUI = "onOpenAcceptUI"

--[[
    大地圖中打開劇情章節選擇界面
    參數:     
         city: 當前城鎮id
]]
EventConst.map_open_chapter = "map_open_chapter"


--戰鬥界面相關消息
EventConst.combat_show_story = "combat_show_story"

--戰鬥結束消息
EventConst.combat_finish = "combat_finish"

--玩家升級消息
EventConst.player_level_up = "player_level_up"

--獲取所有武學列表
EventConst.GetAllSkillRsp = "get_all_skill_rsp"

--學習武學返回
EventConst.LearnSkillRsp = "learn_skill_rsp"

--武學突破
EventConst.SkillBreakOutRsp = "skill_breakout"

--武學升級
EventConst.SkillLevelUpRsp = "skill_levelup"

--武學重置
EventConst.ResetSkillRsp = "reset_skill"

--武學招式升級
EventConst.ArtLevelUpRsp = "art_levelup_sp"

--裝備武學招式
EventConst.UseSkillArtRsp = "UseSkillArtRsp"

--分解武學碎片
EventConst.DecomposeSkillPiecesRsp = "decompose_skill_pieces_rsp"

--更新武學組合
EventConst.UpdateSkillCombineRsp = "update_skill_combine_rsp"

--更新武學境界
EventConst.ImproveSkillBoundaryRsp = "improve_skill_boundary_rsp"

--參悟
EventConst.BuyTrainPointRsp = "BuyTrainPointRsp"

--獲取抽獎數據
EventConst.GetLotteryDataRsp = "get_lottery_data_rsp"
--抽獎返回
EventConst.BuySkillLotteryRsp = "buy_skill_lottery_rsp"
--抽獎返回
EventConst.BuyTreasureLotteryRsp = "buy_treasure_lottery_rsp"
--購買積分商店物品
EventConst.BuyLotteryPointShopRsp = "buy_lottery_point_shop_rsp"
--刷新積分商店
EventConst.RefreshLotteryPointShopRsp = "refresh_lottery_point_shop_rsp"
--琅琊閣積分排行榜
EventConst.GetLotteryRankRsp = "get_lottery_rank_rsp"
--琅琊閣積分排行榜
EventConst.GetSignInfoRsp = "get_sign_info_rsp"
--琅琊閣積分排行榜
EventConst.SignRsp = "sign_rsp"
--琅琊閣積分排行榜
EventConst.GetSummarySignRewardRsp = "get_summary_sign_reward_rsp"
--琅琊閣積分排行榜
EventConst.SignAllRsp = "sign_all_rsp"


--開始歷練
EventConst.StartExerciseRsp = "StartExerciseRsp"

--快速歷練
EventConst.QuickExerciseRsp = "QuickExerciseRsp"

--獲取歷練
EventConst.GetExerciseRsp = "GetExerciseRsp"

--歷練物品自動出售
EventConst.AutoSellRsp = "AutoSellRsp"

--獲取祕境次數訊息
EventConst.GetMijingRsp = "GetMijingRsp"

--開始祕境挑戰
EventConst.StartMijingRsp = "StartMijingRsp"

--購買祕境挑戰次數
EventConst.BuyMijingRsp = "BuyMijingRsp"

--請求商店物品列表
EventConst.StoreGoodsRsp = "StoreGoodsRsp"
--請求刷新商店物品列表
EventConst.StoreRefreshRsp = "StoreRefreshRsp"
--購買商品返回
EventConst.StoreBuyRsp = "StoreBuyRsp"
--請求神祕商店開啟狀態
EventConst.StoreOpenRsp = "StoreOpenRsp"
--神祕商店時間結束
EventConst.StoreTimeOut = "StoreTimeOut"


--門派進階返回
EventConst.GangEnhanceRsp = "GangEnhanceRsp"
--門派請求排名訊息返回
EventConst.GangRankInfoRsp = "GangRankInfoRsp"
--門派比武刷新挑戰對象返回
EventConst.GangRankRefreshRsp = "GangRankRefreshRsp"
--門派比武進入對戰返回
EventConst.GangRankFightRsp = "GangRankFightRsp"
--門派請求排名獎勵
EventConst.GangRankAwardRsp = "GangRankAwardRsp"
--重置門派挑戰次數返回
EventConst.GangRankBuyCountRsp = "GangRankBuyCountRsp"
--門派修煉訊息返回
EventConst.GangPracticeInfoRsp = "GangPracticeInfoRsp"
--門派元寶修煉返回
EventConst.GangPracticeGoldRsp = "GangPracticeGoldRsp"
--門派銀兩修煉返回
EventConst.GangPracticeSilverRsp = "GangPracticeSilverRsp"
--門派道具修煉返回
EventConst.GangPracticeItemRsp = "GangPracticeItemRsp"
--聊天訊息返回
EventConst.ChatChannelRsp = "ChatChannelRsp"

EventConst.ChatLayerClose = "ChatLayerClose"

--強化預估返回
EventConst.EquipStrengthenEvaluateRsp = "EquipStrengthenEvaluateRsp"
--強化結果返回
EventConst.EquipStrengthenRsp = "EquipStrengthenRsp"
--一鍵選擇強化材料
EventConst.EquipStrengthenQuickSelectRsp = "EquipStrengthenQuickSelectRsp"
--傳承返回
EventConst.EquipInheritedRsp = "EquipInheritedRsp"
--熔鍊返回
EventConst.EquipMeltRsp = "EquipMeltRsp"
--撤銷熔鍊結果
EventConst.EquipMeltCancleRsp = "EquipMeltCancleRsp"

--裝備強化，熔鍊，傳承確認通知
EventConst.EquipOperateConfirmed = "EquipOperateConfirmed"

--合成碎片
EventConst.FragMergeRsp = "FragMergeRsp"


--銀兩兌換
EventConst.ConvertSilverRsp = "ConvertSilverRsp"
--快速銀兩兌換
EventConst.ConvertSilverExRsp = "ConvertSilverExRsp"
--獲取兌換訊息
EventConst.GetConvertInfoRsp = "GetConvertInfoRsp"

-- EventConst.open_SelectEquipTip_view = "open_SelectEquipTip_view" -- 打開選擇裝備界面
EventConst.open_face_change_view = "open_face_change_view" --打開頭像更換界面
EventConst.open_vip_view = "open_vip_view"            -- 打開vip特權及禮包界面
EventConst.open_daily_task = "open_daily_task"
EventConst.open_activity_view = "OpenActivityView"
EventConst.open_friend_view = "OpenFriendView"
EventConst.open_skill_map_view = "OpenSkillMapView"
EventConst.open_mail_view = "open_mail_view"
EventConst.on_combat_finished = "OnCombatFinished"
EventConst.open_xiakexing_view = "open_xiakexing_view" --打開俠客行的界面
EventConst.open_xiakexing_heroselect_view = "open_xiakexing_heroselect_view" --打開俠客行選擇npc的界面
EventConst.open_zhuluzhanchang_view = "open_zhuluzhanchang_view" --打開或關閉逐鹿戰場主界面
EventConst.open_achivement_view = "open_achivement_view" --打開成就係統
EventConst.open_all_achive_attribute = "open_all_achive_attribute" --打開成就所有屬性界面

-- 對於緩存的界面，需要在setVisible，false，true時處理一些界面顯示的問題
EventConst.on_cache_ui_visible_state_changed = "on_cache_ui_visible_state_changed"   --緩存界面顯示或隱藏

EventConst.on_major_down_btn_clicked = "on_major_down_btn_clicked"


EventConst.GetRoleSimpleRsp = "GetRoleSimpleRsp"
EventConst.DeleteFriendRsp = "DeleteFriendRsp"
EventConst.AddFriendRsp = "AddFriendRsp"
EventConst.AddFriendNotifyRsp = "AddFriendNotifyRsp"
EventConst.AgreeRequestRsp = "AgreeRequestRsp"
EventConst.DeclineRequestRsp = "DeclineRequestRsp"
EventConst.DeleteEnemyRsp = "DeleteEnemyRsp"
EventConst.SearchPlayerRsp = "SearchPlayerRsp"
EventConst.GetPlayerOnlineRsp = "GetPlayerOnlineRsp"
EventConst.PlayerLogoutNotifyRsp = "PlayerLogoutNotifyRsp"
EventConst.PlayerLoginNotifyRsp = "PlayerLoginNotifyRsp"
EventConst.ChangeSearchListRsp = "ChangeSearchListRsp"
EventConst.FriendFightRsp = "FriendFightRsp"
EventConst.EnemyFightRsp = "EnemyFightRsp"
EventConst.AddEnemyRsp = "AddEnemyRsp"
EventConst.DeleteEnemyRsp = "DeleteEnemyRsp"

EventConst.GetMailListRsp = "GetMailListRsp"
EventConst.DispatchMailRsp = "DispatchMailRsp"
EventConst.ReceiveMailRsp = "ReceiveMailRsp"
EventConst.DeleteMailRsp = "DeleteMailRsp"
--斗酒
EventConst.GetGuessFingerDataRsp = "GetGuessFingerDataRsp"
EventConst.GetGuessOpponentRsp = "GetGuessOpponentRsp"
EventConst.GuessFingerRsp = "GuessFingerRsp"
EventConst.PickWineRsp = "PickWineRsp"
EventConst.WantFightRsp = "WantFightRsp"
--鬥老千
EventConst.GetRollDiceDataRsp = "GetRollDiceDataRsp"
EventConst.RollDiceRsp = "RollDiceRsp"
EventConst.ChangeDiceRsp = "ChangeDiceRsp"
EventConst.ResetDiceStateRsp = "ResetDiceStateRsp"
EventConst.GetMonthRewardRsp = "GetMonthRewardRsp"

--天下事
EventConst.NavigateEvent = "NavigateEvent"

--刷新紅點提示
EventConst.refreshRedPoint = "refreshRedPoint" 
---------------------------------------------------------------

EventConst.UseEquipRsp = "UseEquipRsp"

--界面打開通知
EventConst.enter_layer_notice = "enter_layer_notice"
--打開/關閉/隱藏 新手指引界面
EventConst.open_playerguider_view = "open_playerguider_view"
--獲取指引界面的按鈕位置
EventConst.get_guide_view_point = "get_guide_view_point" 
--點擊指引點，打開新界面
EventConst.guide_click_view_point = "guide_click_view_point"

EventConst.click_view_button = "click_view_button"

--檢測界面是否顯示
EventConst.check_layer_visible = "check_layer_visible"
--打開選擇武學流派界面
EventConst.show_skillsect_layer = "show_skillsect_layer"
--指向第2類流派
EventConst.point_skillsect_2 = "point_skillsect_2"
--指向第3類流派
EventConst.point_skillsect_3 = "point_skillsect_3"
--開始選擇流派
EventConst.select_skillsect = "select_skillsect"


--進入選擇裝備界面
EventConst.onEnterSelectTips = "onEnterSelectTips"

--進入求助的挑戰界面
EventConst.enterSeekHelpFightUI = "enterSeekHelpFightUI"

--獲取已購買的頭像
EventConst.GetFaceRsp = "GetFaceRsp"
--購買頭像
EventConst.BuyFaceRsp = "BuyFaceRsp"
--更換頭像
EventConst.ChangeFaceRsp = "ChangeFaceRsp"

--購買體力
EventConst.BuyPhysicalRsp = "BuyPhysicalRsp" 
EventConst.UpdatePhysicalRsp = "UpdatePhysicalRsp"

--在線跨天
EventConst.OnlineCrossDayRsp = "OnlineCrossDayRsp"


---擂臺
EventConst.GetArenaDataRsp = "GetArenaDataRsp"
EventConst.RefreshOpponentRankRsp = "RefreshOpponentRankRsp"
EventConst.GetArenaRankListRsp = "GetArenaRankListRsp"
EventConst.ArenaFightRsp = "ArenaFightRsp"
EventConst.BuyBufferRsp = "BuyBufferRsp"
EventConst.BuyChallengeRsp = "BuyChallengeRsp"
EventConst.GetLastRankAwardRsp = "GetLastRankAwardRsp"

--華山論劍
EventConst.GetMountainPlayerListRsp = "GetMountainPlayerListRsp"
EventConst.GetMountainDataRsp = "GetMountainDataRsp"
EventConst.SignUpMountainRsp = "SignUpMountainRsp"
EventConst.MountainGuessRsp = "MountainGuessRsp"
EventConst.GetMountainPhaseStateRsp = "GetMountainPhaseStateRsp"

--領取/購買VIP禮包
EventConst.GetVipGiftRsp = "GetVipGiftRsp"
--獲取VIP訊息
EventConst.GetVipInfoRsp = "GetVipInfoRsp"
--儲值(模擬)
EventConst.RechargeRsp = "RechargeRsp"

EventConst.BuyFashionRsp = "BuyFashionRsp" --購買時裝
EventConst.UseFashionRsp = "UseFashionRsp" --使用時裝

EventConst.ChangeLeadRsp = "ChangeLeadRsp" --指引更新
EventConst.OnNewGuideAutoAcceptEvent = "OnNewGuideAutoAcceptEvent" --江湖事指引自動接事件
EventConst.OnNewGuideDouCheng = "OnNewGuideDouCheng"

EventConst.FeatureRsp = "FeatureRsp" --指引更新

--日常任務
EventConst.GetDailyDataRsp = "GetDailyDataRsp"
EventConst.GetDailyPointRsp = "GetDailyPointRsp"
EventConst.GetDailyTaskRsp = "GetDailyTaskRsp"
EventConst.on_auto_open_ui = "on_auto_open_ui" --快速打開ui

--幫派
EventConst.GetPlayerGuildDataRsp = "GetPlayerGuildDataRsp"
EventConst.GetGuildWantedListRsp = "GetGuildWantedListRsp"
EventConst.FightGuildWantedRsp = "FightGuildWantedRsp"
EventConst.GetFightCityStateRsp = "GetFightCityStateRsp"

--升級禮包
EventConst.GetUpgradeGiftRsp = "GetUpgradeGiftRsp"
--戰力禮包
EventConst.GetFightGiftRsp = "GetFightGiftRsp"
--體力禮包
EventConst.GetPhysicalRsp = "GetPhysicalRsp"


EventConst.open_arena_view = "open_arena_view"

EventConst.close_shop_view = "close_shop_view"


EventConst.ExpandPackSizeRsp = "ExpandPackSizeRsp"

--邀請好友，綁定好友，邀請獎勵
EventConst.InviteBindRsp = "InviteBindRsp"
EventConst.InviteRsp = "InviteRsp"
EventConst.InviteGiftRsp = "InviteGiftRsp"
EventConst.FulfillGiftRsp = "FulfillGiftRsp"

--俠客行訊息
EventConst.HeroStoryInfoRsp = "HeroStoryInfoRsp"
EventConst.HeroStoryExtraRsp = "HeroStoryExtraRsp"
EventConst.HeroStoryChallengeRsp = "HeroStoryChallengeRsp"
EventConst.HeroStorySweepRsp = "HeroStorySweepRsp"

--逐鹿戰場
EventConst.DeerSignRsp = "DeerSignRsp"
EventConst.DeerViewCityRsp = "DeerViewCityRsp"
EventConst.DeerFightRsp = "DeerFightRsp"

--同步月卡，終身卡，季卡，年卡數據
EventConst.CardRsp = "CardRsp"
EventConst.OtherRsp = "OtherRsp" -- 同步限時儲值及江湖基金訊息
EventConst.GetRechargeGiftRsp = "GetRechargeGiftRsp" --領取限時儲值獎勵
EventConst.GetFirstRechargeRsp = "GetFirstRechargeRsp" --領取首儲活動獎勵
EventConst.ChangeFirstRechargeState = "ChangeFirstRechargeState" -- 領取獎勵後刪除首儲界面
EventConst.GetFundRsp = "GetFundRsp" --領取基金獎勵
EventConst.FirstRechargeConfRsp = "FirstRechargeConfRsp"
EventConst.FundConfRsp = "FundConfRsp"
EventConst.RechargeGiftConfRsp = "RechargeGiftConfRsp"

--成就
EventConst.achive_goto = "achive_goto" --成就界面跳轉
EventConst.GetAchieveRsp = "GetAchieveRsp" --領取成就獎勵
EventConst.AchieveRsp = "AchieveRsp" --成就訊息
EventConst.SetAchieveTitleRsp = "SetAchieveTitleRsp" --設置成就稱號

--歷練
EventConst.lilian_open = "lilian_open"

return EventConst
