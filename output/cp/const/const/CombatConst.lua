local CombatConst = {}
--戰鬥人員類型
CombatConst.CombatEntityType_NPC		=	0
CombatConst.CombatEntityType_Player	=	1

--戰鬥結果
CombatConst.CombatRoundResult_None	=	0
CombatConst.CombatRoundResult_Left	=	1
CombatConst.CombatRoundResult_Right	=	2
CombatConst.CombatRoundResult_Draw	=	3

--攻擊標誌
CombatConst.CombatRoundFlag_DoubleHit	=	1
CombatConst.CombatRoundFlag_Dodge		=	2
CombatConst.CombatRoundFlag_Parry		=	4
CombatConst.CombatRoundFlag_Critic	=	8

--戰鬥單位狀態
CombatConst.CombatEntityState_Idle = 0		--站立等待
CombatConst.CombatEntityState_Forward = 1		--站立等待
CombatConst.CombatEntityState_FallBack = 2		--回撤
CombatConst.CombatEntityState_Spell = 3	--技能連擊中
CombatConst.CombatEntityState_Defence = 4		--被攻擊
CombatConst.CombatEntityState_Run = 5			--跑
CombatConst.CombatEntityState_Jump = 6		--跳戰鬥位置
CombatConst.CombatEntityState_CounterAttack = 7		--反擊
CombatConst.CombatEntityState_Parry = 8		--格擋
CombatConst.CombatEntityState_Dodge = 9		--閃避
CombatConst.CombatEntityState_Into = 10		--入場動畫
CombatConst.CombatEntityState_Win = 11		--勝利
CombatConst.CombatEntityState_DeadAlive = 12		--死亡復活
CombatConst.CombatEntityState_Dead = -1		--死亡倒地
CombatConst.CombatEntityState_Cleanup = -2		--屍體可以從地圖清除

--戰鬥對狀態
CombatConst.CombatPairState_BothStandby =   1   --雙方聚氣
CombatConst.CombatPairState_Attack  =   2   --左方攻擊
CombatConst.CombatPairState_End =   3           --打完
CombatConst.CombatPairState_JoinPair =   4    --其它玩家正在加入
CombatConst.CombatPairState_RunStage =   5    --跑關卡

--關卡狀態狀態
--CombatConst.CombatState_InitStage      =   1  --關卡開始
CombatConst.CombatState_StartStage      =   1  --關卡開始
CombatConst.CombatState_RunStage        =   3  --本關卡結束，跑關卡
CombatConst.CombatState_FinishStage     =   4  --戰鬥結束
CombatConst.CombatState_GameStory       =   5  --劇情對話

--劇情狀態
CombatConst.CombatStoryState_Begin      =   0   --劇情已經開始
CombatConst.CombatStoryState_End        =   1   --劇情已經結束

--戰鬥副本類型，1為章節模式,2善惡，3祕境，4好友切磋，5仇敵復仇，6門派地位戰
CombatConst.CombatType_Guide        =   0   --指引
CombatConst.CombatType_Story       =   1   --章節模式
CombatConst.CombatType_Shane       =   2   --善惡事件模式
CombatConst.CombatType_Mijing      =   3   --祕境模式
CombatConst.CombatType_Friend      =   4   --好友切磋
CombatConst.CombatType_Enemy       =   5   --仇敵
CombatConst.CombatType_MenPai      =   6   --門派地位戰
CombatConst.CombatType_GuessFinger =   7   --猜拳斗酒
CombatConst.CombatType_Arena       =   8   --擂臺
CombatConst.CombatType_Van         =   9   --押鏢
CombatConst.CombatType_Mountain    =   10  --華山論劍
CombatConst.CombatType_InviteHero  =   11  --挑戰邀請大俠
CombatConst.CombatType_GuildExpel  =   12  --幫派驅逐強盜
CombatConst.CombatType_GuildWanted =   13  --幫派通緝
CombatConst.CombatType_GuildWar    =   14  --幫派戰
CombatConst.CombatType_Tower       =   15  --修羅塔
CombatConst.CombatType_ArenaGuide  =   16  --擂臺指引
CombatConst.CombatType_Hero        =   17  --大俠
CombatConst.CombatType_Idle        =   18  --pk閒逛玩家
CombatConst.CombatType_HeroChallenge   =   19  --俠客行

CombatConst.SkillQualityColor4b = {
    cc.c4b(242,242,242,255),
    cc.c4b(117,233,90,255),
    cc.c4b(108,209,247,255),
    cc.c4b(219,176,255,255),
    cc.c4b(247,236,108,255),
    cc.c4b(247,108,108,255),
}

CombatConst.QualityOutlineC4b = {
    cc.c4b(96,96,96,255),
    cc.c4b(39,118,37,255),
    cc.c4b(41,99,159,255),
    cc.c4b(141,38,123,255),
    cc.c4b(146,110,24,255),
    cc.c4b(110,28,28,255),
}

CombatConst.AttributeList = {
[0]="生命", "內力","攻擊","防禦","命中","閃避","連擊","暴擊","聚氣",
"聚氣時間","調息","修養","拳掌","刀法","劍法","棍法","奇門","招架",
[50]="生命", [51]="內力",[52]="攻擊",[53]="防禦",[54]="命中",[55]="閃避",[56]="連擊",[57]="暴擊",[58]="聚氣",
[59]="聚氣時間",[60]="調息",[61]="修養",[62]="拳掌",[63]="刀法",[64]="劍法",[65]="棍法",[66]="奇門",[67]="招架",
[100]="連擊率", [101]="命中率",[102]="暴擊率",[103]="招架率",
}

CombatConst.AttributeEffect = {
    [1]="運內",[2]="高攻",[3]="高防",[4]="高命",
    [100]="高連",[101]="高命",[102]="高爆",
}

CombatConst.SkillSeriseList = {
    "Force","Blade","Sword","Fist","Strange","Body","Stick","Unorthodox"
}

CombatConst.SeriseColor = {
    "White", "Green", "Blue", "Purole", "Gold", "Red"
}

CombatConst.SeriseColorZhCN = {
    "白", "綠", "藍", "紫", "金", "紅"
}

CombatConst.WeaponNameList = {"knife", "blade", "dagger", "fist", "club"}

CombatConst.ItemColor_White = 1
CombatConst.ItemColor_Green = 2
CombatConst.ItemColor_Blue = 3
CombatConst.ItemColor_Purole = 4
CombatConst.ItemColor_Gold = 5
CombatConst.ItemColor_Red = 6

--內功
CombatConst.SkillSerise_Force = 1
--劍
CombatConst.SkillSerise_Sword = 2
--刀
CombatConst.SkillSerise_Blade = 3
--拳掌
CombatConst.SkillSerise_Fist = 4
--奇門
CombatConst.SkillSerise_Strange = 5
--身法
CombatConst.SkillSerise_Body = 6
--棍
CombatConst.SkillSerise_Stick = 7
--雜學
CombatConst.SkillSerise_Unorthodox = 8

CombatConst.SkillSerise_IconList = {
    "ui_common_module14_wuxue_neigong.png",
    "ui_common_module14_wuxue_jianfa.png",
    "ui_common_module14_wuxue_daofa.png",
    "ui_common_module14_wuxue_quanzhang.png",
    "ui_common_module14_wuxue_qimen.png",
    "ui_common_module14_wuxue_shenfa.png",
    "ui_common_module14_wuxue_gunfa.png",
    "ui_common_module14_wuxue_zaxue.png",
}

CombatConst.QualityBottomList = {
    "ui_common_w.png",
    "ui_common_g.png",
    "ui_common_b.png",
    "ui_common_p.png",
    "ui_common_y.png",
    "ui_common_r.png",
}

CombatConst.SkillType_Sound = {
    "attack_02",
    "attack_03",
    "attack_04",
    "attack_07",
    "attack_06",
    "attack_08",
    "attack_05",
    "attack_09",
}

CombatConst.Challenge_Count_Max = 3 --困難副本每日挑戰次數上限

CombatConst.CombatType = {
    "劇情關卡"
}

CombatConst.SkillTypeName = {
    "內功", "劍法", "刀法", "拳掌", "奇門", "身法", "棍法", "雜學"
}

CombatConst.ItemTypeName = {
    "裝備", "碎片", "寶箱", "書籍", "消耗品", "材料", "道具"
}

CombatConst.SkillBoxList = {
    "ui_common_quality_whitebox.png",
    "ui_common_quality_greenbox.png",
    "ui_common_quality_bluebox.png",
    "ui_common_quality_purolebox.png",
    "ui_common_quality_goldbox.png",
    "ui_common_quality_redbox.png",
}

CombatConst.NumberZh_Cn = {
    [0] = "零",
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
    [7] = "七",
    [8] = "八",
    [9] = "九",
    [10] = "十",
}

--生命值
CombatConst.Attr_HpValue             = 0
--內力值
CombatConst.Attr_MpValue             = 1
--攻擊值
CombatConst.Attr_AttackValue         = 2
--防禦值
CombatConst.Attr_DefendValue         = 3
--命中值
CombatConst.Attr_HitValue            = 4
--閃避值
CombatConst.Attr_DodgeValue          = 5
--連擊值
CombatConst.Attr_BatterValue         = 6
--暴擊值
CombatConst.Attr_CritValue           = 7
--聚氣值
CombatConst.Attr_EnergyValue         = 8
--聚氣時間
CombatConst.Attr_EnergyTimeValue     = 9
--回藍值(修養）
CombatConst.Attr_MpResumeValue       = 10
--回血值(調息）
CombatConst.Attr_HpResumeValue       = 11
--武器：拳套精通
CombatConst.Attr_FistValue           = 12
--武器：雙刀精通
CombatConst.Attr_KnifeValue          = 13
--武器：劍法精通
CombatConst.Attr_SwordValue          = 14
--武器：棍法精通
CombatConst.Attr_StickValue          = 15
--武學：奇門精通
CombatConst.Attr_StrangeValue        = 16
--招架值
CombatConst.Attr_ParryValue          = 17
--威力值
CombatConst.Attr_PowerValue          = 45
--加值屬性結束
CombatConst.Attr_ValueEnd            = 50
--生命百分比
CombatConst.Attr_HpPercent           = 50
--內力百分比
CombatConst.Attr_MpPercent           = 51
--攻擊百分比
CombatConst.Attr_AttackPercent       = 52
--防禦百分比
CombatConst.Attr_DefendPercent       = 53
--命中百分比
CombatConst.Attr_HitPercent          = 54
--閃避百分比
CombatConst.Attr_DodgePercent        = 55
--連擊百分比
CombatConst.Attr_BatterPercent       = 56
--暴擊百分比
CombatConst.Attr_CritPercent         = 57
--聚氣百分比
CombatConst.Attr_EnergyPercent       = 58
--聚氣時間百分比
CombatConst.Attr_EnergyTimePercent   = 59
--回藍百分比
CombatConst.Attr_MpResumePercent     = 60
--回血百分比
CombatConst.Attr_HpResumePercent     = 61
--武器：拳套精通百分比
CombatConst.Attr_FistPercent         = 62
--武器：雙刀精通百分比
CombatConst.Attr_KnifePercent        = 63
--武器：劍術精通百分比
CombatConst.Attr_SwordPercent        = 64
--武器：棍法精通百分比
CombatConst.Attr_StickPercent        = 65
--武學：奇門精通百分比
CombatConst.Attr_StrangePercent      = 66
--招架百分比
CombatConst.Attr_ParryPercent        = 67
--威力值
CombatConst.Attr_PowerPercent        = 95
--加百分比屬性結束
CombatConst.Attr_PercentEnd          = 99
--連擊機率
CombatConst.Attr_BatterRate          = 100
--命中機率
CombatConst.Attr_HitRate             = 101
--暴擊機率
CombatConst.Attr_CritRate            = 102
--招架機率
CombatConst.Attr_ParryRate           = 103
CombatConst.Attr_HurtPercent  = 106
CombatConst.Attr_BeHurtPercent  = 107
CombatConst.Attr_RateEnd             = 149

CombatConst.GameElement_ConditionRate = 152

CombatConst.BoolStatusToElement = {159, 160, 161, 183, 184, 185}

CombatConst.EffectType_Parry = 1
CombatConst.EffectType_Batter = 2
CombatConst.EffectType_Critic = 3
CombatConst.EffectType_Dodge = 4
CombatConst.EffectType_Effect = 10
CombatConst.EffectType_Event = 11

CombatConst.FightEvent_RoundBegin = 1
CombatConst.FightEvent_Attack   =   2
CombatConst.FightEvent_Defence  =   3
CombatConst.FightEvent_RoundEnd = 4

--使用武學後
CombatConst.GameEvent_UseSkill = 1
--攻擊敵人後
CombatConst.GameEvent_Attack = 2
--被攻擊
CombatConst.GameEvent_BeAttack = 3
--造成傷害
CombatConst.GameEvent_Hurt = 4
--受到傷害
CombatConst.GameEvent_BeHurt = 5
--產生暴擊
CombatConst.GameEvent_Critic = 6
--被暴擊
CombatConst.GameEvent_BeCritic = 13
--死亡
CombatConst.GameEvent_Dead = 7
--回合開始
CombatConst.GameEvent_RoundBegin = 8
--回合結束
CombatConst.GameEvent_RoundEnd = 9
--生命低於
CombatConst.GameEvent_LifeLow = 10
--造成傷害計量以後
CombatConst.GameEvent_CalHurt = 11
--承受傷害計量以後
CombatConst.GameEvent_CalBeHurt = 12
--產生暴擊
CombatConst.GameEvent_BeCritic = 13
--添加buff後(有回合數的buffer)
CombatConst.GameEvent_AddBuffer = 14
--添加或者刪除後(此事件不針對某個或者某類型的buffer)
CombatConst.GameEvent_ChangeBuffer = 15
--連擊後
CombatConst.GameEvent_Batter = 16
--被連擊後
CombatConst.GameEvent_BeBatter = 17

CombatConst.MaxQi = 4000

CombatConst.PrimevalColorList = {
    "ui_primeval_module98_hunyuan_13.png",
    "ui_primeval_module98_hunyuan_16.png",
    "ui_primeval_module98_hunyuan_15.png",
    "ui_primeval_module98_hunyuan_14.png",
    "ui_primeval_module98_hunyuan_17.png",
    "ui_primeval_module98_hunyuan_18.png"
}

CombatConst.SkillSpecial = {
    [1] = "高屬性", [2] = "高閃避", [3] = "高招架", [4] = "高暴擊", [5] = "高傷害", [6] = "反彈傷害", [7] = "減傷",
    [21] = "高爆發", [22] = "聚氣掌控", [23] = "封禁武功", [24] = "削弱敵人", [25] = "高續航", [26] = "高連擊", [27] = "高生存", [28] = "免疫精通", 
    [31] = "持續傷害", [32] = "百分比傷害", [33] = "削減內力", [34] = "生命吸取", [35] = "狀態清空", [36] = "內力吸取",
    [51] = "棍系精通", [52] = "武學精通"
}
return CombatConst
