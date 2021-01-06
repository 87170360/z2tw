local ProtoConst = {} 

ProtoConst.RegisterReq = "RegisterReq"
ProtoConst.RegisterRsp = "RegisterRsp"
ProtoConst.GuestReq = "GuestReq"
ProtoConst.GuestRsp = "GuestRsp"
ProtoConst.LoginReq = "LoginReq"
ProtoConst.LoginRsp = "LoginRsp"
ProtoConst.ZoneReq = "ZoneReq"
ProtoConst.ZoneRsp = "ZoneRsp"
ProtoConst.ThirdLoginReq = "ThirdLoginReq"
ProtoConst.ThirdLoginRsp = "ThirdLoginRsp"
ProtoConst.DispatchMailReq = "DispatchMailReq"
ProtoConst.DispatchMailRsp = "DispatchMailRsp"
ProtoConst.GetMailListReq = "GetMailListReq"
ProtoConst.GetMailListRsp = "GetMailListRsp"
ProtoConst.ReceiveMailReq = "ReceiveMailReq"
ProtoConst.ReceiveMailRsp = "ReceiveMailRsp"
ProtoConst.DeleteMailReq = "DeleteMailReq"
ProtoConst.DeleteMailRsp = "DeleteMailRsp"
ProtoConst.EnterGameReq = "EnterGameReq"
ProtoConst.EnterGameRsp = "EnterGameRsp"
ProtoConst.CreateReq = "CreateReq"
ProtoConst.CreateRsp = "CreateRsp"
ProtoConst.GetRoleReq = "GetRoleReq"
ProtoConst.GetRoleRsp = "GetRoleRsp"
ProtoConst.GetRoleItemReq = "GetRoleItemReq"
ProtoConst.GetRoleItemRsp = "GetRoleItemRsp"
ProtoConst.ReconnectReq = "ReconnectReq"
ProtoConst.ReconnectRsp = "ReconnectRsp"
ProtoConst.ItemUpdateReq = "ItemUpdateReq"
ProtoConst.ItemUpdateRsp = "ItemUpdateRsp"
ProtoConst.UseEquipReq = "UseEquipReq"
ProtoConst.UseEquipRsp = "UseEquipRsp"
ProtoConst.UseConsumeReq = "UseConsumeReq"
ProtoConst.UseConsumeRsp = "UseConsumeRsp"
ProtoConst.SellItemReq = "SellItemReq"
ProtoConst.SellItemRsp = "SellItemRsp"
ProtoConst.SkillItemReq = "SkillItemReq"
ProtoConst.SkillItemRsp = "SkillItemRsp"
ProtoConst.ChestItemReq = "ChestItemReq"
ProtoConst.ChestItemRsp = "ChestItemRsp"
ProtoConst.CrushSkillReq = "CrushSkillReq"
ProtoConst.CrushSkillRsp = "CrushSkillRsp"
ProtoConst.ViewPlayerReq = "ViewPlayerReq"
ProtoConst.ViewPlayerRsp = "ViewPlayerRsp"
ProtoConst.ViewItemReq = "ViewItemReq"
ProtoConst.ViewItemRsp = "ViewItemRsp"
ProtoConst.UpdateCurrencyRsp = "UpdateCurrencyRsp"
ProtoConst.GetFaceReq = "GetFaceReq"
ProtoConst.GetFaceRsp = "GetFaceRsp"
ProtoConst.BuyFaceReq = "BuyFaceReq"
ProtoConst.BuyFaceRsp = "BuyFaceRsp"
ProtoConst.ChangeFaceReq = "ChangeFaceReq"
ProtoConst.ChangeFaceRsp = "ChangeFaceRsp"
ProtoConst.BuyPhysicalReq = "BuyPhysicalReq"
ProtoConst.BuyPhysicalRsp = "BuyPhysicalRsp"
ProtoConst.UpdatePhysicalReq = "UpdatePhysicalReq"
ProtoConst.UpdatePhysicalRsp = "UpdatePhysicalRsp"
ProtoConst.FragMergeReq = "FragMergeReq"
ProtoConst.FragMergeRsp = "FragMergeRsp"
ProtoConst.UpdateSinsReq = "UpdateSinsReq"
ProtoConst.UpdateSinsRsp = "UpdateSinsRsp"
ProtoConst.ChangeLeadReq = "ChangeLeadReq"
ProtoConst.ChangeLeadRsp = "ChangeLeadRsp"
ProtoConst.OnlineCrossDayReq = "OnlineCrossDayReq"
ProtoConst.OnlineCrossDayRsp = "OnlineCrossDayRsp"
ProtoConst.FeatureReq = "FeatureReq"
ProtoConst.FeatureRsp = "FeatureRsp"
ProtoConst.KickOfflineReq = "KickOfflineReq"
ProtoConst.KickOfflineRsp = "KickOfflineRsp"
ProtoConst.ExpandPackSizeReq = "ExpandPackSizeReq"
ProtoConst.ExpandPackSizeRsp = "ExpandPackSizeRsp"
ProtoConst.InviteReq = "InviteReq"
ProtoConst.InviteRsp = "InviteRsp"
ProtoConst.InviteBindReq = "InviteBindReq"
ProtoConst.InviteBindRsp = "InviteBindRsp"
ProtoConst.InviteGiftReq = "InviteGiftReq"
ProtoConst.InviteGiftRsp = "InviteGiftRsp"
ProtoConst.FulfillGiftReq = "FulfillGiftReq"
ProtoConst.FulfillGiftRsp = "FulfillGiftRsp"
ProtoConst.UpdateVigorReq = "UpdateVigorReq"
ProtoConst.UpdateVigorRsp = "UpdateVigorRsp"
ProtoConst.HeroStoryInfoReq = "HeroStoryInfoReq"
ProtoConst.HeroStoryInfoRsp = "HeroStoryInfoRsp"
ProtoConst.HeroStoryChallengeReq = "HeroStoryChallengeReq"
ProtoConst.HeroStoryChallengeRsp = "HeroStoryChallengeRsp"
ProtoConst.HeroStorySweepReq = "HeroStorySweepReq"
ProtoConst.HeroStorySweepRsp = "HeroStorySweepRsp"
ProtoConst.HeroStoryExtraReq = "HeroStoryExtraReq"
ProtoConst.HeroStoryExtraRsp = "HeroStoryExtraRsp"
ProtoConst.GetRoleInfoReq = "GetRoleInfoReq"
ProtoConst.GetRoleInfoRsp = "GetRoleInfoRsp"
ProtoConst.GetArenaTopReq = "GetArenaTopReq"
ProtoConst.CardReq = "CardReq"
ProtoConst.CardRsp = "CardRsp"
ProtoConst.OtherReq = "OtherReq"
ProtoConst.OtherRsp = "OtherRsp"
ProtoConst.GetRechargeGiftReq = "GetRechargeGiftReq"
ProtoConst.GetRechargeGiftRsp = "GetRechargeGiftRsp"
ProtoConst.RechargeGiftConfReq = "RechargeGiftConfReq"
ProtoConst.RechargeGiftConfRsp = "RechargeGiftConfRsp"
ProtoConst.FirstRechargeConfReq = "FirstRechargeConfReq"
ProtoConst.FirstRechargeConfRsp = "FirstRechargeConfRsp"
ProtoConst.GetFirstRechargeReq = "GetFirstRechargeReq"
ProtoConst.GetFirstRechargeRsp = "GetFirstRechargeRsp"
ProtoConst.FundConfReq = "FundConfReq"
ProtoConst.FundConfRsp = "FundConfRsp"
ProtoConst.GetFundReq = "GetFundReq"
ProtoConst.GetFundRsp = "GetFundRsp"
ProtoConst.AchieveReq = "AchieveReq"
ProtoConst.AchieveRsp = "AchieveRsp"
ProtoConst.GetAchieveReq = "GetAchieveReq"
ProtoConst.GetAchieveRsp = "GetAchieveRsp"
ProtoConst.SetAchieveTitleReq = "SetAchieveTitleReq"
ProtoConst.SetAchieveTitleRsp = "SetAchieveTitleRsp"
ProtoConst.EnterStoryLevelReq = "EnterStoryLevelReq"
ProtoConst.EnterStoryLevelRsp = "EnterStoryLevelRsp"
ProtoConst.SweepStoryReq = "SweepStoryReq"
ProtoConst.SweepStoryRsp = "SweepStoryRsp"
ProtoConst.GetStoryInfoReq = "GetStoryInfoReq"
ProtoConst.GetStoryInfoRsp = "GetStoryInfoRsp"
ProtoConst.CombatFinishRsp = "CombatFinishRsp"
ProtoConst.ResetStoryReq = "ResetStoryReq"
ProtoConst.ResetStoryRsp = "ResetStoryRsp"
ProtoConst.GetCombatDataReq = "GetCombatDataReq"
ProtoConst.GetCombatDataRsp = "GetCombatDataRsp"
ProtoConst.GetCombatListReq = "GetCombatListReq"
ProtoConst.GetCombatListRsp = "GetCombatListRsp"
ProtoConst.FirstEnterGameReq = "FirstEnterGameReq"
ProtoConst.FirstEnterGameRsp = "FirstEnterGameRsp"
ProtoConst.IdleStaffReq = "IdleStaffReq"
ProtoConst.IdleStaffRsp = "IdleStaffRsp"
ProtoConst.SwitchConductTypeReq = "SwitchConductTypeReq"
ProtoConst.SwitchConductTypeRsp = "SwitchConductTypeRsp"
ProtoConst.GetConductReq = "GetConductReq"
ProtoConst.GetConductRsp = "GetConductRsp"
ProtoConst.StartHangConductReq = "StartHangConductReq"
ProtoConst.StartHangConductRsp = "StartHangConductRsp"
ProtoConst.BreakHangConductReq = "BreakHangConductReq"
ProtoConst.BreakHangConductRsp = "BreakHangConductRsp"
ProtoConst.UpdateHangConductReq = "UpdateHangConductReq"
ProtoConst.UpdateHangConductRsp = "UpdateHangConductRsp"
ProtoConst.StartFightConductReq = "StartFightConductReq"
ProtoConst.StartFightConductRsp = "StartFightConductRsp"
ProtoConst.StopConductReq = "StopConductReq"
ProtoConst.StopConductRsp = "StopConductRsp"
ProtoConst.StartFightIdleStaffReq = "StartFightIdleStaffReq"
ProtoConst.StartFightIdleStaffRsp = "StartFightIdleStaffRsp"
ProtoConst.GetHeroReq = "GetHeroReq"
ProtoConst.GetHeroRsp = "GetHeroRsp"
ProtoConst.StartFightHeroReq = "StartFightHeroReq"
ProtoConst.StartFightHeroRsp = "StartFightHeroRsp"
ProtoConst.BribeHeroReq = "BribeHeroReq"
ProtoConst.BribeHeroRsp = "BribeHeroRsp"
ProtoConst.InviteHeroReq = "InviteHeroReq"
ProtoConst.InviteHeroRsp = "InviteHeroRsp"
ProtoConst.AcceptHeroReq = "AcceptHeroReq"
ProtoConst.AcceptHeroRsp = "AcceptHeroRsp"
ProtoConst.OtherDefeatReq = "OtherDefeatReq"
ProtoConst.OtherDefeatRsp = "OtherDefeatRsp"
ProtoConst.BribeAllHeroReq = "BribeAllHeroReq"
ProtoConst.BribeAllHeroRsp = "BribeAllHeroRsp"
ProtoConst.GetAccuAwardReq = "GetAccuAwardReq"
ProtoConst.GetAccuAwardRsp = "GetAccuAwardRsp"
ProtoConst.RobotFightReq = "RobotFightReq"
ProtoConst.RobotFightRsp = "RobotFightRsp"
ProtoConst.ViewHeroStateReq = "ViewHeroStateReq"
ProtoConst.ViewHeroStateRsp = "ViewHeroStateRsp"
ProtoConst.GetAllSkillReq = "GetAllSkillReq"
ProtoConst.GetAllSkillRsp = "GetAllSkillRsp"
ProtoConst.SkillLevelUpReq = "SkillLevelUpReq"
ProtoConst.SkillLevelUpRsp = "SkillLevelUpRsp"
ProtoConst.UpdateSkillCombineReq = "UpdateSkillCombineReq"
ProtoConst.UpdateSkillCombineRsp = "UpdateSkillCombineRsp"
ProtoConst.SkillBreakOutReq = "SkillBreakOutReq"
ProtoConst.SkillBreakOutRsp = "SkillBreakOutRsp"
ProtoConst.ResetSkillReq = "ResetSkillReq"
ProtoConst.ResetSkillRsp = "ResetSkillRsp"
ProtoConst.ArtLevelUpReq = "ArtLevelUpReq"
ProtoConst.ArtLevelUpRsp = "ArtLevelUpRsp"
ProtoConst.UseSkillArtReq = "UseSkillArtReq"
ProtoConst.UseSkillArtRsp = "UseSkillArtRsp"
ProtoConst.DecomposeSkillPiecesReq = "DecomposeSkillPiecesReq"
ProtoConst.DecomposeSkillPiecesRsp = "DecomposeSkillPiecesRsp"
ProtoConst.ImproveSkillBoundaryReq = "ImproveSkillBoundaryReq"
ProtoConst.ImproveSkillBoundaryRsp = "ImproveSkillBoundaryRsp"
ProtoConst.LearnSkillReq = "LearnSkillReq"
ProtoConst.LearnSkillRsp = "LearnSkillRsp"
ProtoConst.BuyTrainPointReq = "BuyTrainPointReq"
ProtoConst.BuyTrainPointRsp = "BuyTrainPointRsp"
ProtoConst.UseCombineReq = "UseCombineReq"
ProtoConst.UseCombineRsp = "UseCombineRsp"
ProtoConst.GetCareerSkillReq = "GetCareerSkillReq"
ProtoConst.GetCareerSkillRsp = "GetCareerSkillRsp"
ProtoConst.SignReq = "SignReq"
ProtoConst.SignRsp = "SignRsp"
ProtoConst.GetSignInfoReq = "GetSignInfoReq"
ProtoConst.GetSignInfoRsp = "GetSignInfoRsp"
ProtoConst.GetSummarySignRewardReq = "GetSummarySignRewardReq"
ProtoConst.GetSummarySignRewardRsp = "GetSummarySignRewardRsp"
ProtoConst.SignAllReq = "SignAllReq"
ProtoConst.SignAllRsp = "SignAllRsp"
ProtoConst.GetLotteryDataReq = "GetLotteryDataReq"
ProtoConst.GetLotteryDataRsp = "GetLotteryDataRsp"
ProtoConst.BuySkillLotteryReq = "BuySkillLotteryReq"
ProtoConst.BuySkillLotteryRsp = "BuySkillLotteryRsp"
ProtoConst.BuyTreasureLotteryReq = "BuyTreasureLotteryReq"
ProtoConst.BuyTreasureLotteryRsp = "BuyTreasureLotteryRsp"
ProtoConst.BuyLotteryPointShopReq = "BuyLotteryPointShopReq"
ProtoConst.BuyLotteryPointShopRsp = "BuyLotteryPointShopRsp"
ProtoConst.RefreshLotteryPointShopReq = "RefreshLotteryPointShopReq"
ProtoConst.RefreshLotteryPointShopRsp = "RefreshLotteryPointShopRsp"
ProtoConst.GetLotteryRankReq = "GetLotteryRankReq"
ProtoConst.GetLotteryRankRsp = "GetLotteryRankRsp"
ProtoConst.GetExerciseReq = "GetExerciseReq"
ProtoConst.GetExerciseRsp = "GetExerciseRsp"
ProtoConst.StartExerciseReq = "StartExerciseReq"
ProtoConst.StartExerciseRsp = "StartExerciseRsp"
ProtoConst.QuickExerciseReq = "QuickExerciseReq"
ProtoConst.QuickExerciseRsp = "QuickExerciseRsp"
ProtoConst.AutoSellReq = "AutoSellReq"
ProtoConst.AutoSellRsp = "AutoSellRsp"
ProtoConst.GetMijingReq = "GetMijingReq"
ProtoConst.GetMijingRsp = "GetMijingRsp"
ProtoConst.StartMijingReq = "StartMijingReq"
ProtoConst.StartMijingRsp = "StartMijingRsp"
ProtoConst.BuyMijingReq = "BuyMijingReq"
ProtoConst.BuyMijingRsp = "BuyMijingRsp"
ProtoConst.StoreOpenReq = "StoreOpenReq"
ProtoConst.StoreOpenRsp = "StoreOpenRsp"
ProtoConst.StoreGoodsReq = "StoreGoodsReq"
ProtoConst.StoreGoodsRsp = "StoreGoodsRsp"
ProtoConst.StoreRefreshReq = "StoreRefreshReq"
ProtoConst.StoreRefreshRsp = "StoreRefreshRsp"
ProtoConst.StoreBuyReq = "StoreBuyReq"
ProtoConst.StoreBuyRsp = "StoreBuyRsp"
ProtoConst.GetFriendDataReq = "GetFriendDataReq"
ProtoConst.GetFriendDataRsp = "GetFriendDataRsp"
ProtoConst.GetRoleSimpleReq = "GetRoleSimpleReq"
ProtoConst.GetRoleSimpleRsp = "GetRoleSimpleRsp"
ProtoConst.FriendFightReq = "FriendFightReq"
ProtoConst.FriendFightRsp = "FriendFightRsp"
ProtoConst.DeleteFriendReq = "DeleteFriendReq"
ProtoConst.DeleteFriendRsp = "DeleteFriendRsp"
ProtoConst.SearchPlayerReq = "SearchPlayerReq"
ProtoConst.SearchPlayerRsp = "SearchPlayerRsp"
ProtoConst.AddFriendReq = "AddFriendReq"
ProtoConst.AddFriendRsp = "AddFriendRsp"
ProtoConst.AddFriendNotifyRsp = "AddFriendNotifyRsp"
ProtoConst.ChangeSearchListReq = "ChangeSearchListReq"
ProtoConst.ChangeSearchListRsp = "ChangeSearchListRsp"
ProtoConst.AgreeRequestReq = "AgreeRequestReq"
ProtoConst.AgreeRequestRsp = "AgreeRequestRsp"
ProtoConst.DeclineRequestReq = "DeclineRequestReq"
ProtoConst.DeclineRequestRsp = "DeclineRequestRsp"
ProtoConst.EnemyFightReq = "EnemyFightReq"
ProtoConst.EnemyFightRsp = "EnemyFightRsp"
ProtoConst.AddEnemyReq = "AddEnemyReq"
ProtoConst.AddEnemyRsp = "AddEnemyRsp"
ProtoConst.DeleteEnemyReq = "DeleteEnemyReq"
ProtoConst.DeleteEnemyRsp = "DeleteEnemyRsp"
ProtoConst.GetPlayerOnlineReq = "GetPlayerOnlineReq"
ProtoConst.GetPlayerOnlineRsp = "GetPlayerOnlineRsp"
ProtoConst.PlayerLoginNotifyRsp = "PlayerLoginNotifyRsp"
ProtoConst.PlayerLogoutNotifyRsp = "PlayerLogoutNotifyRsp"
ProtoConst.GangEnhanceReq = "GangEnhanceReq"
ProtoConst.GangEnhanceRsp = "GangEnhanceRsp"
ProtoConst.GangRankInfoReq = "GangRankInfoReq"
ProtoConst.GangRankInfoRsp = "GangRankInfoRsp"
ProtoConst.GangRankRefreshReq = "GangRankRefreshReq"
ProtoConst.GangRankRefreshRsp = "GangRankRefreshRsp"
ProtoConst.GangRankFightReq = "GangRankFightReq"
ProtoConst.GangRankFightRsp = "GangRankFightRsp"
ProtoConst.GangRankAwardReq = "GangRankAwardReq"
ProtoConst.GangRankAwardRsp = "GangRankAwardRsp"
ProtoConst.GangRankBuyCountReq = "GangRankBuyCountReq"
ProtoConst.GangRankBuyCountRsp = "GangRankBuyCountRsp"
ProtoConst.GangPracticeInfoReq = "GangPracticeInfoReq"
ProtoConst.GangPracticeInfoRsp = "GangPracticeInfoRsp"
ProtoConst.GangPracticeGoldReq = "GangPracticeGoldReq"
ProtoConst.GangPracticeGoldRsp = "GangPracticeGoldRsp"
ProtoConst.GangPracticeSilverReq = "GangPracticeSilverReq"
ProtoConst.GangPracticeSilverRsp = "GangPracticeSilverRsp"
ProtoConst.GangPracticeItemReq = "GangPracticeItemReq"
ProtoConst.GangPracticeItemRsp = "GangPracticeItemRsp"
ProtoConst.ChatChannelReq = "ChatChannelReq"
ProtoConst.ChatChannelRsp = "ChatChannelRsp"
ProtoConst.ChatShareReq = "ChatShareReq"
ProtoConst.ChatShareRsp = "ChatShareRsp"
ProtoConst.EquipStrengthenReq = "EquipStrengthenReq"
ProtoConst.EquipStrengthenRsp = "EquipStrengthenRsp"
ProtoConst.EquipStrengthenEvaluateReq = "EquipStrengthenEvaluateReq"
ProtoConst.EquipStrengthenEvaluateRsp = "EquipStrengthenEvaluateRsp"
ProtoConst.EquipStrengthenQuickSelectReq = "EquipStrengthenQuickSelectReq"
ProtoConst.EquipStrengthenQuickSelectRsp = "EquipStrengthenQuickSelectRsp"
ProtoConst.EquipInheritedReq = "EquipInheritedReq"
ProtoConst.EquipInheritedRsp = "EquipInheritedRsp"
ProtoConst.EquipMeltReq = "EquipMeltReq"
ProtoConst.EquipMeltRsp = "EquipMeltRsp"
ProtoConst.EquipMeltCancleReq = "EquipMeltCancleReq"
ProtoConst.EquipMeltCancleRsp = "EquipMeltCancleRsp"
ProtoConst.ConvertSilverReq = "ConvertSilverReq"
ProtoConst.ConvertSilverRsp = "ConvertSilverRsp"
ProtoConst.ConvertSilverExReq = "ConvertSilverExReq"
ProtoConst.ConvertSilverExRsp = "ConvertSilverExRsp"
ProtoConst.GetConvertInfoReq = "GetConvertInfoReq"
ProtoConst.GetConvertInfoRsp = "GetConvertInfoRsp"
ProtoConst.BuyFashionReq = "BuyFashionReq"
ProtoConst.BuyFashionRsp = "BuyFashionRsp"
ProtoConst.UseFashionReq = "UseFashionReq"
ProtoConst.UseFashionRsp = "UseFashionRsp"
ProtoConst.GetGuessFingerDataReq = "GetGuessFingerDataReq"
ProtoConst.GetGuessFingerDataRsp = "GetGuessFingerDataRsp"
ProtoConst.GetGuessOpponentReq = "GetGuessOpponentReq"
ProtoConst.GetGuessOpponentRsp = "GetGuessOpponentRsp"
ProtoConst.GuessFingerReq = "GuessFingerReq"
ProtoConst.GuessFingerRsp = "GuessFingerRsp"
ProtoConst.PickWineReq = "PickWineReq"
ProtoConst.PickWineRsp = "PickWineRsp"
ProtoConst.WantFightReq = "WantFightReq"
ProtoConst.WantFightRsp = "WantFightRsp"
ProtoConst.GetRollDiceDataReq = "GetRollDiceDataReq"
ProtoConst.GetRollDiceDataRsp = "GetRollDiceDataRsp"
ProtoConst.RollDiceReq = "RollDiceReq"
ProtoConst.RollDiceRsp = "RollDiceRsp"
ProtoConst.ChangeDiceReq = "ChangeDiceReq"
ProtoConst.ChangeDiceRsp = "ChangeDiceRsp"
ProtoConst.ResetDiceStateReq = "ResetDiceStateReq"
ProtoConst.ResetDiceStateRsp = "ResetDiceStateRsp"
ProtoConst.GetMonthRewardReq = "GetMonthRewardReq"
ProtoConst.GetMonthRewardRsp = "GetMonthRewardRsp"
ProtoConst.UpdateGuessGuideStepReq = "UpdateGuessGuideStepReq"
ProtoConst.UpdateGuessGuideStepRsp = "UpdateGuessGuideStepRsp"
ProtoConst.GetSelfVanReq = "GetSelfVanReq"
ProtoConst.GetSelfVanRsp = "GetSelfVanRsp"
ProtoConst.RefreshSelfVanReq = "RefreshSelfVanReq"
ProtoConst.RefreshSelfVanRsp = "RefreshSelfVanRsp"
ProtoConst.StartVanReq = "StartVanReq"
ProtoConst.StartVanRsp = "StartVanRsp"
ProtoConst.GetAllVanReq = "GetAllVanReq"
ProtoConst.GetAllVanRsp = "GetAllVanRsp"
ProtoConst.RobVanReq = "RobVanReq"
ProtoConst.RobVanRsp = "RobVanRsp"
ProtoConst.BeRobVanReq = "BeRobVanReq"
ProtoConst.BeRobVanRsp = "BeRobVanRsp"
ProtoConst.BuyRobReq = "BuyRobReq"
ProtoConst.BuyRobRsp = "BuyRobRsp"
ProtoConst.GetArenaDataReq = "GetArenaDataReq"
ProtoConst.GetArenaDataRsp = "GetArenaDataRsp"
ProtoConst.RefreshOpponentRankReq = "RefreshOpponentRankReq"
ProtoConst.RefreshOpponentRankRsp = "RefreshOpponentRankRsp"
ProtoConst.GetArenaRankListReq = "GetArenaRankListReq"
ProtoConst.GetArenaRankListRsp = "GetArenaRankListRsp"
ProtoConst.ArenaFightReq = "ArenaFightReq"
ProtoConst.ArenaFightRsp = "ArenaFightRsp"
ProtoConst.BuyBufferReq = "BuyBufferReq"
ProtoConst.BuyBufferRsp = "BuyBufferRsp"
ProtoConst.BuyChallengeReq = "BuyChallengeReq"
ProtoConst.BuyChallengeRsp = "BuyChallengeRsp"
ProtoConst.GetLastRankAwardReq = "GetLastRankAwardReq"
ProtoConst.GetLastRankAwardRsp = "GetLastRankAwardRsp"
ProtoConst.ArenaRankChangeRsp = "ArenaRankChangeRsp"
ProtoConst.PvPCombatReq = "PvPCombatReq"
ProtoConst.PvPCombatRsp = "PvPCombatRsp"
ProtoConst.UpdateArenaGuideReq = "UpdateArenaGuideReq"
ProtoConst.UpdateArenaGuideRsp = "UpdateArenaGuideRsp"
ProtoConst.GetMountainPlayerListReq = "GetMountainPlayerListReq"
ProtoConst.GetMountainPlayerListRsp = "GetMountainPlayerListRsp"
ProtoConst.GetMountainDataReq = "GetMountainDataReq"
ProtoConst.GetMountainDataRsp = "GetMountainDataRsp"
ProtoConst.SignUpMountainReq = "SignUpMountainReq"
ProtoConst.SignUpMountainRsp = "SignUpMountainRsp"
ProtoConst.MountainGuessReq = "MountainGuessReq"
ProtoConst.MountainGuessRsp = "MountainGuessRsp"
ProtoConst.GetMountainPhaseStateReq = "GetMountainPhaseStateReq"
ProtoConst.GetMountainPhaseStateRsp = "GetMountainPhaseStateRsp"
ProtoConst.UpdateMountainGuideReq = "UpdateMountainGuideReq"
ProtoConst.UpdateMountainGuideRsp = "UpdateMountainGuideRsp"
ProtoConst.CMeetingSupportReq = "CMeetingSupportReq"
ProtoConst.CMeetingSupportRsp = "CMeetingSupportRsp"
ProtoConst.CMeetingPredictReq = "CMeetingPredictReq"
ProtoConst.CMeetingPredictRsp = "CMeetingPredictRsp"
ProtoConst.GetVipInfoReq = "GetVipInfoReq"
ProtoConst.GetVipInfoRsp = "GetVipInfoRsp"
ProtoConst.GetVipGiftReq = "GetVipGiftReq"
ProtoConst.GetVipGiftRsp = "GetVipGiftRsp"
ProtoConst.RechargeReq = "RechargeReq"
ProtoConst.RechargeRsp = "RechargeRsp"
ProtoConst.GetPlayerGuildDataReq = "GetPlayerGuildDataReq"
ProtoConst.GetPlayerGuildDataRsp = "GetPlayerGuildDataRsp"
ProtoConst.CreateGuildReq = "CreateGuildReq"
ProtoConst.CreateGuildRsp = "CreateGuildRsp"
ProtoConst.GetJoinGuildListReq = "GetJoinGuildListReq"
ProtoConst.GetJoinGuildListRsp = "GetJoinGuildListRsp"
ProtoConst.JoinGuildReq = "JoinGuildReq"
ProtoConst.JoinGuildRsp = "JoinGuildRsp"
ProtoConst.JoinGuildNotifyRsp = "JoinGuildNotifyRsp"
ProtoConst.HandleJoinGuildReq = "HandleJoinGuildReq"
ProtoConst.HandleJoinGuildRsp = "HandleJoinGuildRsp"
ProtoConst.HandleJoinGuildNotifyRsp = "HandleJoinGuildNotifyRsp"
ProtoConst.GetGuildSalaryReq = "GetGuildSalaryReq"
ProtoConst.GetGuildSalaryRsp = "GetGuildSalaryRsp"
ProtoConst.ContributeGuildReq = "ContributeGuildReq"
ProtoConst.ContributeGuildRsp = "ContributeGuildRsp"
ProtoConst.GetGuildRankReq = "GetGuildRankReq"
ProtoConst.GetGuildRankRsp = "GetGuildRankRsp"
ProtoConst.AppointGuildManagerReq = "AppointGuildManagerReq"
ProtoConst.AppointGuildManagerRsp = "AppointGuildManagerRsp"
ProtoConst.UpgradeGuildReq = "UpgradeGuildReq"
ProtoConst.UpgradeGuildRsp = "UpgradeGuildRsp"
ProtoConst.QuitGuildReq = "QuitGuildReq"
ProtoConst.QuitGuildRsp = "QuitGuildRsp"
ProtoConst.ModifyGuildNoticeReq = "ModifyGuildNoticeReq"
ProtoConst.ModifyGuildNoticeRsp = "ModifyGuildNoticeRsp"
ProtoConst.GuildActivitySweepReq = "GuildActivitySweepReq"
ProtoConst.GuildActivitySweepRsp = "GuildActivitySweepRsp"
ProtoConst.GuildActivityExpelReq = "GuildActivityExpelReq"
ProtoConst.GuildActivityExpelRsp = "GuildActivityExpelRsp"
ProtoConst.GuildBuildReq = "GuildBuildReq"
ProtoConst.GuildBuildRsp = "GuildBuildRsp"
ProtoConst.GetGuildWantedListReq = "GetGuildWantedListReq"
ProtoConst.GetGuildWantedListRsp = "GetGuildWantedListRsp"
ProtoConst.FightGuildWantedReq = "FightGuildWantedReq"
ProtoConst.FightGuildWantedRsp = "FightGuildWantedRsp"
ProtoConst.GuildPrepareFightReq = "GuildPrepareFightReq"
ProtoConst.GuildPrepareFightRsp = "GuildPrepareFightRsp"
ProtoConst.GuildSignFightReq = "GuildSignFightReq"
ProtoConst.GuildSignFightRsp = "GuildSignFightRsp"
ProtoConst.GuildFightOverRsp = "GuildFightOverRsp"
ProtoConst.GetGuildFightCityReq = "GetGuildFightCityReq"
ProtoConst.GetGuildFightCityRsp = "GetGuildFightCityRsp"
ProtoConst.GetGuildFightCombatListReq = "GetGuildFightCombatListReq"
ProtoConst.GetGuildFightCombatListRsp = "GetGuildFightCombatListRsp"
ProtoConst.ShowCityOwnerReq = "ShowCityOwnerReq"
ProtoConst.ShowCityOwnerRsp = "ShowCityOwnerRsp"
ProtoConst.GetGuildByNameReq = "GetGuildByNameReq"
ProtoConst.GetGuildByNameRsp = "GetGuildByNameRsp"
ProtoConst.GuildEventNotifyRsp = "GuildEventNotifyRsp"
ProtoConst.GetFightCityCountReq = "GetFightCityCountReq"
ProtoConst.GetFightCityCountRsp = "GetFightCityCountRsp"
ProtoConst.NotifyMemberContributeRsp = "NotifyMemberContributeRsp"
ProtoConst.UpdateMemberDailyRewardRsp = "UpdateMemberDailyRewardRsp"
ProtoConst.DispatchGuildTalkReq = "DispatchGuildTalkReq"
ProtoConst.GetFightCityStateReq = "GetFightCityStateReq"
ProtoConst.GetFightCityStateRsp = "GetFightCityStateRsp"
ProtoConst.AddGuildCurrencyRsp = "AddGuildCurrencyRsp"
ProtoConst.GetDailyDataReq = "GetDailyDataReq"
ProtoConst.GetDailyDataRsp = "GetDailyDataRsp"
ProtoConst.GetDailyPointReq = "GetDailyPointReq"
ProtoConst.GetDailyPointRsp = "GetDailyPointRsp"
ProtoConst.GetDailyTaskReq = "GetDailyTaskReq"
ProtoConst.GetDailyTaskRsp = "GetDailyTaskRsp"
ProtoConst.GetUpgradeGiftReq = "GetUpgradeGiftReq"
ProtoConst.GetUpgradeGiftRsp = "GetUpgradeGiftRsp"
ProtoConst.GetFightGiftReq = "GetFightGiftReq"
ProtoConst.GetFightGiftRsp = "GetFightGiftRsp"
ProtoConst.GetPhysicalReq = "GetPhysicalReq"
ProtoConst.GetPhysicalRsp = "GetPhysicalRsp"
ProtoConst.GetTowerDataReq = "GetTowerDataReq"
ProtoConst.GetTowerDataRsp = "GetTowerDataRsp"
ProtoConst.FightTowerFloorReq = "FightTowerFloorReq"
ProtoConst.FightTowerFloorRsp = "FightTowerFloorRsp"
ProtoConst.FightTowerQuickReq = "FightTowerQuickReq"
ProtoConst.FightTowerQuickRsp = "FightTowerQuickRsp"
ProtoConst.QuickFightDoneReq = "QuickFightDoneReq"
ProtoConst.QuickFightDoneRsp = "QuickFightDoneRsp"
ProtoConst.ResetTowerFightReq = "ResetTowerFightReq"
ProtoConst.ResetTowerFightRsp = "ResetTowerFightRsp"
ProtoConst.GetTowerRankReq = "GetTowerRankReq"
ProtoConst.GetTowerRankRsp = "GetTowerRankRsp"
ProtoConst.UpdateTowerGuideReq = "UpdateTowerGuideReq"
ProtoConst.UpdateTowerGuideRsp = "UpdateTowerGuideRsp"
ProtoConst.GetRankListReq = "GetRankListReq"
ProtoConst.GetRankListRsp = "GetRankListRsp"
ProtoConst.GetPrimevalDataReq = "GetPrimevalDataReq"
ProtoConst.GetPrimevalDataRsp = "GetPrimevalDataRsp"
ProtoConst.UsePrimevalChestReq = "UsePrimevalChestReq"
ProtoConst.UsePrimevalChestRsp = "UsePrimevalChestRsp"
ProtoConst.EquipMetaReq = "EquipMetaReq"
ProtoConst.EquipMetaRsp = "EquipMetaRsp"
ProtoConst.StrengthMetaReq = "StrengthMetaReq"
ProtoConst.StrengthMetaRsp = "StrengthMetaRsp"
ProtoConst.SellMetaReq = "SellMetaReq"
ProtoConst.SellMetaRsp = "SellMetaRsp"
ProtoConst.LearnMetalReq = "LearnMetalReq"
ProtoConst.LearnMetalRsp = "LearnMetalRsp"
ProtoConst.UpdateMetaLockReq = "UpdateMetaLockReq"
ProtoConst.UpdateMetaLockRsp = "UpdateMetaLockRsp"
ProtoConst.ExpandSpaceReq = "ExpandSpaceReq"
ProtoConst.ExpandSpaceRsp = "ExpandSpaceRsp"
ProtoConst.DeerTestReq = "DeerTestReq"
ProtoConst.DeerTestRsp = "DeerTestRsp"
ProtoConst.DeerLoginReq = "DeerLoginReq"
ProtoConst.DeerLoginRsp = "DeerLoginRsp"
ProtoConst.DeerSignReq = "DeerSignReq"
ProtoConst.DeerSignRsp = "DeerSignRsp"
ProtoConst.DeerViewCityReq = "DeerViewCityReq"
ProtoConst.DeerViewCityRsp = "DeerViewCityRsp"
ProtoConst.DeerFightReq = "DeerFightReq"
ProtoConst.DeerFightRsp = "DeerFightRsp"
ProtoConst.SyncMeetingStateReq = "SyncMeetingStateReq"
ProtoConst.GetArenaTopRsp = "GetArenaTopRsp"
ProtoConst.GetMeetingPhaseReq = "GetMeetingPhaseReq"
ProtoConst.GetMeetingPhaseRsp = "GetMeetingPhaseRsp"
ProtoConst.GetMeetingStateReq = "GetMeetingStateReq"
ProtoConst.GetMeetingStateRsp = "GetMeetingStateRsp"
ProtoConst.MeetingGuessReq = "MeetingGuessReq"
ProtoConst.MeetingGuessRsp = "MeetingGuessRsp"
ProtoConst.MeetingSupportReq = "MeetingSupportReq"
ProtoConst.MeetingSupportRsp = "MeetingSupportRsp"
ProtoConst.MeetingPredictReq = "MeetingPredictReq"
ProtoConst.MeetingPredictRsp = "MeetingPredictRsp"

return ProtoConst