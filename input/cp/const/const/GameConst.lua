local GameConst = {} 

-- VirtualItemType的值 對應於 item表格中的虛擬貨幣子類型 SubType
GameConst.VirtualItemType = {
    silver=1,     --銀兩
    gold=2,       --元寶
    trainPoint=3, --修為點
    learnPoint=4, --領悟點
    prestige=5,   --聲望值
    goodPoint=6,  --俠義令
    badPoint=7,   --鐵膽令
    physical=8,   --體力
    exp=9,        --閱歷值(經驗)
    sins=10,      --罪惡值
    guildGold=11, --幫派個人資金
    totalGood=12, --累計善
    totalBad=13,  --累計惡
    fashion=14,   --時裝券
    normalEvent=15,--善惡事件剩餘次數
    vip_exp=16,   --vip經驗
    vip_level=17, --vip等級
    jade=18,      --玄玉
    vigor=19,     --精力

    guildExp=100,        --幫派經驗(客戶端使用)
    guildContribute=101, --幫派貢獻(客戶端使用)
    taskPoint=102,       --任務積分(客戶端使用)
    tscy=103,            --天山殘頁
}


GameConst.DutyName = {
    [0] = "幫眾",
    [1] = "長老",
    [2] = "副幫主",
    [3] = "幫主",
}

--使用到的物品id,表格如果更改了，此處需要一起更改
GameConst.XiuLianDan_ItemID = 812
GameConst.TianShuCanYe_ItemID = 10
GameConst.Silver_ItemID = 2
GameConst.Gold_ItemID = 3
GameConst.GongXunZhi_ItemID = 2489


--地圖相關
GameConst.map_min_distance = 100 --世界地圖的最小檢測距離
GameConst.map_min_scale = 1 --世界地圖的最小縮放比例
GameConst.map_max_scale = 3 --世界地圖的最大縮放比例
GameConst.role_move_speed = 100 --小人在世界地圖的默認移動速度


GameConst.TabTextColor = {cc.c4b(80, 44, 8, 255), cc.c4b(244, 222, 199, 255)}
GameConst.ContentTextColor = cc.c4b(52,32,17,255) --描述性文字顏色  #342011
GameConst.ButtonTextColor = cc.c4b(122,22,22,255)  --按鈕文字顏色 #7A1616
GameConst.ChatMsgColor = cc.c4b(93,51,13,255) -- #5D330D

--品質
-- 品級(6、紅色   5、金色   4、紫色   3、藍色   2、綠色   1、白色)
GameConst.QualityTextColor = {
    cc.c4b(242,242,242,255),
    cc.c4b(117,233,90,255),
    cc.c4b(108,209,247,255),
    cc.c4b(219,176,255,255),
    cc.c4b(247,236,108,255),
    cc.c4b(247,108,108,255),
}

GameConst.QualityOutlineColor = {
    cc.c4b(96,96,96,255),
    cc.c4b(39,118,37,255),
    cc.c4b(41,99,159,255),
    cc.c4b(141,38,123,255),
    cc.c4b(146,110,24,255),
    cc.c4b(110,28,28,255),
}


--物品品質對應的物品框圖片
GameConst.QualityItemFrame = {
    "ui_common_quality_whitebox.png",
    "ui_common_quality_greenbox.png",
    "ui_common_quality_bluebox.png",
    "ui_common_quality_purolebox.png",
    "ui_common_quality_goldbox.png",
    "ui_common_quality_redbox.png",
}

--裝備的最大強化等級
GameConst.EquipStrengthenMaxLevel = {
    {5,10,20,30,40,50},      -- 一階 白,綠,藍,紫,金,紅
    {10,20,40,60,80,100},    -- 二階
    {15,30,60,90,120,150},
    {20,40,80,120,160,200},
    {25,50,100,150,200,250},
    {30,60,120,180,240,300}  -- 六階

    -- for test
    -- {5,10,15,20,20,20},
    -- {5,10,15,20,20,20},
    -- {5,10,15,20,20,20},
    -- {5,10,15,20,20,20},
    -- {5,10,15,20,20,20},
    -- {5,10,15,20,20,20}
}

--對應的公式
GameConst.getMaxStrengthenLv = function(quality, hierarchy)
    if quality <= 1 then
        return 5*hierarchy
    else
        return (quality-1)*10*hierarchy
    end 
end

--善惡稱號及稱號的臨界值
GameConst.ConductValue = {100,1000,5000,12000,50000,100000}
GameConst.ConductName = {
    [1] = {"役馬小卒","帶刀捕快","錦衣捕頭","金刀鐵捕","鐵血名捕","捕神傳奇"},
    [2] = {"江湖蝦米","青衫俠少","塞外奇俠","中原大俠","神州巨俠","俠隱傳說"}
}

--城市名字
GameConst.CityName = {
    [0] = "無",
    "成都", "鳳翔", "襄陽", "開封", "臨安", "揚州"
}

GameConst.Vip_Effect_FreeSweep                  = 0 --最大免費掃蕩次數
GameConst.Vip_Effect_BuyPhysical                = 1 --最大購買體力次數
GameConst.Vip_Effect_BuySilver                  = 2 --最大招財銀兩次數
GameConst.Vip_Effect_BuyTrainPoint              = 3 --最大購買修為點次數
GameConst.Vip_Effect_QuickExercise              = 4 --最大快速歷練次數
GameConst.Vip_Effect_ResetStory                 = 5 --最大重置困難本關卡次數
GameConst.Vip_Effect_ArenaTimes                 = 6 --最大比武擂臺挑戰次數
GameConst.Vip_Effect_FreeRoleDice               = 7 --最大免費搖骰次數
GameConst.Vip_Effect_Mijing                     = 8 --最大祕境挑戰次數
GameConst.Vip_Effect_RiverEvent                 = 9 --最大同時進行的江湖事數量

GameConst.GuildBuildingName = {
    "練武堂", "練兵場", "修煉房"
}

GameConst.GuildBuildingLevel = {
    "初級", "中級", "高級"
}

GameConst.EffectScale = 1
return GameConst