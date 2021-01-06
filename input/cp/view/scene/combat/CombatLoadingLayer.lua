local BLayer = require "cp.view.ui.base.BLayer"
local CombatLoadingLayer = class("CombatLoadingLayer", BLayer)

function CombatLoadingLayer:create()
    local scene = CombatLoadingLayer.new()
    return scene
end

function CombatLoadingLayer:initListEvent()
    self.listListeners = {
		["CloseCombatLoadingLayer"] = function(data)
			log("22222222222222222222222222222222222222222222222222222222222222")
			self:removeFromParent()
		end
    }
end

--初始化界面，以及設定界面元素標籤
function CombatLoadingLayer:onInitView()
    self.rootView = cc.CSLoader:createNode("uicsb/uicsb_combat/uicsb_combat_loading.csb")
	self.rootView:setPosition(cc.p(0,0))
    self:addChild(self.rootView, 1)
    self.rootView:setContentSize(display.size)

    local childConfig = {
		["Panel_root"] = {name = "Panel_root"},
		["Panel_root.Image_1"] = {name = "Image_1"},
		["Panel_root.Image_BG"] = {name = "Image_BG"},
		["Panel_root.Panel_Notice"] = {name = "Panel_Notice"},
		["Panel_root.Image_Notice"] = {name = "Image_Notice"},
		["Panel_root.Image_Top"] = {name = "Image_Top"},
		["Panel_root.Image_Logo"] = {name = "Image_Logo"},
		["Panel_root.Image_Bottom"] = {name = "Image_Bottom"},
		["Panel_root.Panel_Notice.Text_Notice"] = {name = "Text_Notice"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView, childConfig)

	self.status = true
	local cfg = cp.getManager("ConfigManager").getItemByKey("GameChapterPart", cp.getUserData("UserCombat"):getID())
	local delayTime = 1
	if cp.getUserData("UserCombat"):getCombatType() == cp.getConst("CombatConst").CombatType_Story  then
		local loading = cfg:getValue("Loading")
		local roleAtt = cp.getUserData("UserRole"):getValue("major_roleAtt")
		local loadingIntro = cp.getUtils("DataUtils").replaceGameTalk(cfg:getValue("LoadingIntro"), roleAtt.name, roleAtt.gender, roleAtt.career)
		if cp.getUserData("UserCombat"):getValue("IsFirst") and loadingIntro ~= "" then
			local introList = string.split(loadingIntro, "\n")
			self.Text_Notice:setString(loadingIntro)
			local size = self.Text_Notice:getVirtualRendererSize()
			self.Panel_Notice:setAnchorPoint(cc.p(0, 1))
			self.Panel_Notice:setPosition(cc.p(display.width/2 - size.width/2, display.height/2 + size.height/2))
			local index = 1
			local lastFrame, overFrame = 40, 60
			local deltaHeight = size.height / (#introList * lastFrame)
			local totalFrame = #introList * overFrame + lastFrame
			local csz = self.Panel_Notice:setContentSize(cc.size(size.width, 0))
			self.status = false
			self.Panel_Notice:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
				--log("index="..index..",mod="..index%overFrame..",total="..totalFrame)
				if index % overFrame <= lastFrame  then
					local csz = self.Panel_Notice:getContentSize()
					csz.height = csz.height + deltaHeight
					self.Panel_Notice:setContentSize(csz)
					self.Text_Notice:setPosition(cc.p(0, csz.height))
				end
				if index >= totalFrame then
					self.Panel_Notice:stopAllActions()
					if self.status then
						self:updateCombatLoadingView()
					else
						self.status = true
					end
				end
				index = index + 1
				self.Panel_Notice:setVisible(true)
			end), cc.DelayTime:create(1/60))))
			self.Image_BG:setVisible(true)
			self.Image_Notice:setVisible(false)
			self.Image_Top:setVisible(true)
			self.Image_Bottom:setVisible(true)
			self.Image_Logo:setVisible(false)
			delayTime = totalFrame / 60
		end

		if loading ~= "" then
			self.Image_1:loadTexture("img/bg/bg_common/"..loading)
		end
	end

	self:runAction(cc.Sequence:create(cc.Spawn:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function()
			if self.status then
				self:updateCombatLoadingView()
			else
				self.status = true
			end
		end)), cc.CallFunc:create(function()
			self:dispatchViewEvent("OpenCombatView")
	end)))
	
	ccui.Helper:doLayout(self.rootView)
end

function CombatLoadingLayer:preloadSkillEffect(skillEntry)
	local effectID = skillEntry:getValue("AttackEffect")
	if not effectID or effectID == 0 then
		return
	end

	local effectEntry = cp.getManager("ConfigManager").getItemByKey("SkillEffect", effectID)
	local effectFileName = effectEntry:getValue("EffectFile")
	local fileName = "res/img/effect/"..effectFileName.."/"..effectFileName
	--log("PreloadFile================="..fileName)
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(fileName..".plist", fileName..".png")
end

function CombatLoadingLayer:preloadSkill(modelEntry, skillID)
	local skillEntry = cp.getManager("ConfigManager").getItemByKey("SkillEntry", skillID)
	if not skillEntry then return end
	self:preloadSkillEffect(skillEntry)
	local sex = modelEntry:getValue("Sex") or 0
	if sex == -1 then
		return
	end
	local sound = string.split(skillEntry:getValue("Sound"), ":")[sex+1]
	sound = tonumber(sound)
	if not sound or sound == 0 then
		return
	end

	local soundEntry = cp.getManager("ConfigManager").getItemByKey("GameSound", sound)
	if not soundEntry then
		return
	end
	local soundPath = soundEntry:getValue("path")
	cc.SimpleAudioEngine:getInstance():preloadEffect("audio/"..soundPath)
end

function CombatLoadingLayer:preloadPrimeval(primevalList)
	for _, primeval in ipairs(primevalList) do
        local primevalEntry = cp.getManager("ConfigManager").getItemByKey("PrimevalChaos", primeval)
		local name = primevalEntry:getValue("Combat_Effect")
		local fileName = "res/img/effect/"..name.."/"..name
		--log("PreloadFile================="..fileName)
		local frameCache = cc.SpriteFrameCache:getInstance()
		frameCache:addSpriteFrames(fileName..".plist", fileName..".png")
	end
end

function CombatLoadingLayer:updateCombatLoadingView()
	local combatResult = cp.getUserData("UserCombat").CombatData.combat_result
	for _, stageResult in ipairs(combatResult.stage_result) do
		for _, pairResult in ipairs(stageResult.combat_round_result) do
			local leftModelEntry = nil
			local rightModelEntry = nil
			for idx, roundResult in ipairs(pairResult.round_result) do
				local leftResult = roundResult.side_result_list[1]
				local rightResult = roundResult.side_result_list[2]
				if idx == 1 then
					self:preloadPrimeval(leftResult.primeval)
					self:preloadPrimeval(rightResult.primeval)
					leftModel = cp.getManager("ConfigManager").getItemByKey("GameModel", leftResult.model_id)
					rightModel = cp.getManager("ConfigManager").getItemByKey("GameModel", rightResult.model_id)
				else
					self:preloadSkill(leftModel, leftResult.use_skill)
					self:preloadSkill(rightModel, rightResult.use_skill)
				end
			end
		end
	end
end

function CombatLoadingLayer:onEnterScene()
    --self:updateCombatLoadingView()
end

function CombatLoadingLayer:onExitScene()
end

return CombatLoadingLayer