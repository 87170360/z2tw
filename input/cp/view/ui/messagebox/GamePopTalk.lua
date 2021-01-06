 
local BNode = require "cp.view.ui.base.BNode"
local GamePopTalk = class("GamePopTalk",BNode)
function GamePopTalk:create(gameStoryList,needBlackMark, delay)
	local ret = GamePopTalk.new(gameStoryList,needBlackMark)
	ret.delay = delay or 0
    return ret
end

function GamePopTalk:initListEvent()
	self.listListeners = {
		["GamePopTalkCloseMsg"] = function()
			self:removeFromParent()
		end,
	}

end
--[[參數說明
        gameStoryList 見 cp.story.GameStory1.lua
    ]]
function GamePopTalk:onInitView(gameStoryList,needBlackMark)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_talk.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
		["Panel_bg"] = {name = "Panel_bg"},
		["Panel_root"] = {name = "Panel_root", click = "onNextButtonClick", clickScale = 1},
		["Panel_root.Image_bg"] = {name = "Image_bg"},
        ["Panel_root.Text_content"] = {name = "Text_content"},
        ["Panel_root.Image_role"] = {name = "Image_role"},
		["Panel_root.Text_time"] = {name = "Text_time"},
		["Panel_root.Image_name"] = {name = "Image_name"},
		["Panel_root.Image_name.Text_name"] = {name = "Text_name"},
		["Panel_root.Image_skip"] = {name = "Image_skip", click = "onSkipButtonClick"},
		
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self.Panel_bg:setContentSize(display.size)
	self.Panel_bg:setBackGroundColorOpacity(100)


	local function onTouch(sender, event)
		if event == cc.EventCode.ENDED then
			if self.touchBgTime == nil or  os.clock() - self.touchBgTime > 0.5 then
				self:onNextButtonClick()
				self.touchBgTime = os.clock()
			end
        end
    end
    if self.Panel_bg.addTouchEventListener ~= nil then
        self.Panel_bg:addTouchEventListener(onTouch)
	end
	self.Panel_bg:setTouchEnabled(true)

	self.contentList = gameStoryList
	self.index = 1
	
	self.Text_time:setVisible(true)
	if needBlackMark == false then
		self.Panel_bg:setBackGroundColorOpacity(0)
	end
	-- self.Panel_bg:setVisible(false)
	ccui.Helper:doLayout(self.rootView)
end

function GamePopTalk:hideSkip()
	self.Image_skip:setVisible(false)
end

-- function GamePopTalk:createRichText(childContentTable)
-- 	local richText = require("cp.view.ui.base.RichText"):create()
--     for i=1, #childContentTable do
--         richText:addElement(childContentTable[i])
-- 	end
-- 	local sz = self["Text_content"]:getContentSize()
-- 	local posX,posY = self["Text_content"]:getPosition()
--     richText:setContentSize(cc.size(400, 120)) --sz.width,sz.height))
--     richText:setAnchorPoint(cc.p(0,0.5))
--     richText:ignoreContentAdaptWithSize(false)
--     richText:setPosition(cc.p(14,58)) -- posX,posY))
--     richText:setHAlign(cc.TEXT_ALIGNMENT_LEFT)  			--水平居左
--     richText:setVAlign(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)   --垂直居中
--     richText:setLineGap(2)
--     richText:setVisible(true)
--     return richText

-- end

function GamePopTalk:onEnterScene()
	if self.delay > 0 then
		self.Panel_bg:setBackGroundColorOpacity(0)
		self.Panel_root:setVisible(false)

		self:runAction(cc.Sequence:create(cc.DelayTime:create(self.delay), cc.CallFunc:create(function()
			self.Panel_root:setVisible(true)
			self.Panel_bg:setBackGroundColorOpacity(100)
			self:initContent()
		end)))
	else
		self:initContent()
	end
end

function GamePopTalk:onExitScene()
	if self.scheduler_entry ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_entry)
	end
	self.scheduler_entry = nil
end

function GamePopTalk:initContent()
--[[
	[1] = {
			duration=3,
			name="莊老",
			head="img/model/half/half_zhuanglao.png",
			pos = 0,
			text="畜牲，你給我滾...咳咳"
		},
]]	

	if self.contentList == nil or self.contentList[self.index] == nil then
		return
	end
	local gameStory = self.contentList[self.index]
	local majorRole = cp.getUserData("UserRole"):getValue("major_roleAtt")

	--對話中文字替換
	if string.find(gameStory.text,"【玩家】") then 
		gameStory.text = string.gsub(gameStory.text,"【玩家】",majorRole.name)
	end
	if string.find(gameStory.text,"%[玩家%]") then 
		gameStory.text = string.gsub(gameStory.text,"%[玩家%]",majorRole.name)
	end
	if string.find(gameStory.text,"【門派】") then 
		local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", majorRole.career)
		gameStory.text = string.gsub(gameStory.text,"【門派】",cfg:getValue("Name"))
	end
	if string.find(gameStory.text,"%[門派%]") then 
		local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", majorRole.career)
		gameStory.text = string.gsub(gameStory.text,"%[門派%]",cfg:getValue("Name"))
	end
	if string.find(gameStory.text,"%[師兄姐%]") then 
		if majorRole.gender == 0 then
			gameStory.text = string.gsub(gameStory.text,"%[師兄姐%]", majorRole.career == 0  and "師兄" or "師姐")
		elseif majorRole.gender == 1 then
			gameStory.text = string.gsub(gameStory.text,"%[師兄姐%]", majorRole.career == 3  and "師姐" or "師兄")
		end
	end

	-- name 替換
	if gameStory.name == "%[player%]" or gameStory.name == "玩家" then
		gameStory.name = majorRole.name 

		local fashion_data = cp.getUserData("UserRole"):getValue("fashion_data")
		local cfg, _ = cp.getManager("GDataManager"):getMajorRoleIamge(fashion_data.use,majorRole.career,majorRole.gender) 
		if cfg then
		  	local halfFile = cfg:getValue("HalfDraw")
		  	gameStory.head = halfFile
		end
	elseif  gameStory.name == "師兄姐" then 
		if majorRole.gender == 0 then
			if majorRole.career == 0 then
				gameStory.head = "img/model/half/half_shixiong.png"
				gameStory.name = "師兄"
			else
				gameStory.head = "img/model/half/half_shijie.png"
				gameStory.name = "師姐"
			end
		elseif majorRole.gender == 1 then
			if majorRole.career == 3 then
				gameStory.head = "img/model/half/half_shijie.png"
				gameStory.name = "師姐"
			else
				gameStory.head = "img/model/half/half_shixiong.png"
				gameStory.name = "師兄"
			end
		end
	elseif gameStory.name == "師父" or gameStory.name == "師傅" then
		local cfg = cp.getManager("ConfigManager").getItemByKey("GangEnhance", majorRole.career)
		if cfg then
			local npcid = cfg:getValue("Leader")
			if npcid>0 then
				local _,_,half,_,_ = cp.getManager("GDataManager"):getNpcNameIcon(npcid)
				gameStory.head = half
			end
		end
	end

	self.time = tonumber(gameStory.duration)
	self.Text_content:setString(gameStory.text)
	self.Text_time:setString("(" .. tostring(self.time) .. "秒)")
	self.Text_name:setString(gameStory.name)

	self.Image_role:loadTexture(gameStory.head,ccui.TextureResType.localType)
	self.Image_role:setAnchorPoint(cc.p(0.5,0))
	self.Image_role:ignoreContentAdaptWithSize(true)

	if gameStory.pos > display.width/2 then
		self.Text_content:setAnchorPoint(cc.p(0,1))
		self.Text_content:setPositionX(15)
		self.Text_content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)

		self.Text_time:setPositionX(70)

		self.Image_name:setPositionX(454)
		self.Image_bg:setFlippedX(true)
		self.Image_role:setFlippedX(true)
		self.Image_role:setPositionX(630)
		self.Image_skip:setPositionX(128)
	else
		self.Text_content:setAnchorPoint(cc.p(1,1))
		self.Text_content:setPositionX(697)
		self.Text_content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		
		self.Text_time:setPositionX(643)

		self.Image_name:setPositionX(27)
		self.Image_bg:setFlippedX(false)
		self.Image_role:setFlippedX(false)
		self.Image_role:setPositionX(90)

		self.Image_skip:setPositionX(590)
	end
	
	if self.scheduler_entry ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_entry)
	end
	self.scheduler_entry = nil
	self.scheduler_entry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		function(dt)
			self.time = self.time - 1
			log("self.time = " .. tostring(self.time))
			self.Text_time:setString("(" .. tostring(self.time) .. "秒)")
			if self.time <= 0 then
				self:Next()
			else
				
			end
		end, 
		1, 
		false)
	
end

function GamePopTalk:onNextButtonClick(sender)
	self:Next()
end

function GamePopTalk:Next()
	if self.index < #self.contentList then
		self.index = self.index + 1
        -- self["Panel_root"]:removeChildByName("richText")
        -- local richText = self:createRichText(self.contentList[self.index])
		-- richText:setName("richText")
        -- self["Panel_root"]:addChild(richText,10)
		self:initContent()
	else
		if self.finishCallBack ~= nil then
			if self.scheduler_entry ~= nil then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_entry)
			end
			self.scheduler_entry = nil
			self.finishCallBack()
		end	
	end
end


function GamePopTalk:resetTalkText(contentTable)
	-- self["Panel_root"]:removeChildByName("richText")
	if contentTable ~= nil and next(contentTable) ~= nil then
		self.contentList = contentTable
		self.index = 1
		-- if self.contentList[self.index].content ~= nil then
		-- 	local richText = self:createRichText(self.contentList[self.index].content)
		-- 	richText:setName("richText")
		-- 	self["Panel_root"]:addChild(richText,10)

		-- end
		self:initContent()
	end
end

function GamePopTalk:setFinishedCallBack(callback)
    self.finishCallBack = callback
end

function GamePopTalk:onSkipButtonClick(sender)
	self.index = #self.contentList
	if self.finishCallBack ~= nil then
		if self.scheduler_entry ~= nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_entry)
		end
		self.scheduler_entry = nil
		self.finishCallBack()
	end
end

function GamePopTalk:resetBgOpacity(opacity)
	self.Panel_bg:setBackGroundColorOpacity(opacity)
end

function GamePopTalk:getDescription()
	return "GamePopTalk"
end

return GamePopTalk