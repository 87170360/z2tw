local SceneConst = {}

SceneConst.enter= "enter"
SceneConst.enterTransitionFinish= "enterTransitionFinish"
SceneConst.exit= "exit"
SceneConst.exitTransitionFinish= "exitTransitionFinish"
SceneConst.cleanup= "cleanup"

SceneConst.SCENE_SPLASH = "cp.view.scene.splashscene.SplashScene"
SceneConst.SCENE_LOGIN = "cp.view.scene.login.LoginScene"
SceneConst.SCENE_WORLD = "cp.view.scene.world.WorldScene"
SceneConst.SCENE_COMBAT = "cp.view.scene.combat.CombatScene"
SceneConst.SCENE_HOTUP = "cp.view.scene.hotup.HotUpScene"


SceneConst.MODULE_MajorMap = "cp.view.scene.world.major.MajorLayer"         --都城主界面 
SceneConst.MODULE_MenPai = "cp.view.scene.world.menpai.MenPaiMainLayer"     --門派 
SceneConst.MODULE_MajorRole = "cp.view.scene.world.major.MajorRoleSelf"     --角色
SceneConst.MODULE_MajorPackage = "cp.view.scene.world.major.MajorPackage"   --揹包
SceneConst.MODULE_SkillSummary = "cp.view.scene.skill.SkillSummaryLayer"    --武學
SceneConst.MODULE_JiangHu = "cp.view.scene.world.worldmap.JiangHuLayer"     --江湖
SceneConst.MODULE_SkillMap = "cp.view.scene.skill.SkillMapLayer"    --武學
SceneConst.MODULE_SkillCombine = "cp.view.scene.skill.SkillCombineLayer"    --武學
SceneConst.MODULE_SkillRecommend = "cp.view.scene.skill.SkillRecommendLayer"    --武學

SceneConst.MODULE_WorldMap = "cp.view.scene.world.worldmap.WorldMapLayer"     --世界地圖
SceneConst.MODULE_LotteryHouse = "cp.view.scene.lottery.LotteryHouseLayer"    --抽獎
SceneConst.MODULE_ActivitySign = "cp.view.scene.activity.ActivitySignLayer"   --簽到
SceneConst.MODULE_ArenaHouse = "cp.view.scene.arena.ArenaHouseLayer"          --擂臺
SceneConst.MODULE_Guide = "cp.view.scene.activity.ActivityGuideLayer"          --我要xx

SceneConst.MODULE_ExpressEscort = "cp.view.scene.world.express.ExpressEscort" --押鏢
SceneConst.MODULE_ExpressLoot = "cp.view.scene.world.express.ExpressLoot"     --伏擊


return SceneConst
