local UIGuideConfig = {
	--引導的索引及等級配置

	-- ["firstFight"] = {name = "firstFight", index = 1,max_step=3, lv = 1,forceguide = true},

	["menpai_wuxue"] = {name = "menpai_wuxue", index = 2,max_step=17, lv = 1,forceguide = true},
	["wuxue"] = {name = "wuxue", index = 3,max_step=22, lv = 1, forceguide = true},
	["story"] = {name = "story", index = 4, max_step=16, lv = 1, forceguide = true},
	["character"] = {name = "character", index = 5, max_step=28, lv = 1, forceguide = true},
	["lottery"] = {name = "lottery", index = 6, max_step=29, lv = 1, forceguide = true},
	--["wuxue_use"] = {name = "wuxue_use", index =3, max_step=18, lv = 1, forceguide = true},
	["wuxue_pos_change"] = {name = "wuxue_pos_change", index =7, max_step=16, lv = 1, forceguide = true},
	["mail"] = {name = "mail", index = 8, max_step=16, lv = 1, forceguide = true},
	["equip"] = {name = "equip", index = 9, max_step=36, lv = 1, forceguide = true},

	["lilian"] = {name = "lilian", index = 10, max_step=13, lv = 50, forceguide = true, firstguide = true},--首次進入歷練界面開啟指引
	["mijing"] = {name = "mijing", index = 11, max_step=4, lv = 50, forceguide = false, firstguide = true},--首次進入祕境界面開啟指引
	["river_event"] = {name = "river_event", index = 12, max_step=16, lv = 50, forceguide = true, firstguide = true},--首次江湖界面開啟指引
	["escort"] = {name = "escort", index = 13, max_step=5, lv = 50, forceguide = false, firstguide = true},--首次進入押鏢界面開啟指引
	["loot"] = {name = "loot", index = 14, max_step=5, lv = 50, forceguide = false, firstguide = true},--首次進入劫鏢界面開啟指引
	["doucheng"] = {name = "doucheng", index = 15, max_step=5, lv = 50, forceguide = false, firstguide = true},--完成equip指引後首次進入都城界面開啟指引

	["primeval_main"] = {name = "primeval_main", index = 16, max_step=4, lv = 50, forceguide = false, firstguide = true},--首次進入風雨樓界面開啟指引
	["primeval_equip"] = {name = "primeval_equip", index = 17, max_step=3, lv = 50, forceguide = false, firstguide = true},--首次進入混元界面開啟指引
	["skill_boundary"] = {name = "skill_boundary", index = 18, max_step=5, lv = 50, forceguide = false, firstguide = true},--首次進入武學境界界面開啟指引
	["skill_art"] = {name = "skill_art", index = 19, max_step=4, lv = 50, forceguide = false, firstguide = true},--首次進入武學招式界面開啟指引
}

return UIGuideConfig