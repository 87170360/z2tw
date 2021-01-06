

local TipsHelp = class("TipsHelp",function() return cc.Node:create() end)
function TipsHelp:create(systemTytpe)
    local ret = TipsHelp.new()
    ret:init(systemTytpe)
    return ret
end



function TipsHelp:init(systemTytpe)
	
	self.rootView = cc.CSLoader:createNode("uicsb/uicsb_public/uicsb_public_help_tips.csb")
    self:addChild(self.rootView)
   
	local childConfig = {
        ["Image_bg"] = {name = "Image_bg" },
        ["Image_bg.Image_title.Text_title"] = {name = "Text_title"},
        ["Image_bg.ScrollView_content"] = {name = "ScrollView_content" },
        ["Image_bg.ScrollView_content.Text_content"] = {name = "Text_content" },
		["Image_bg.Button_close"] = {name = "Button_OK" ,click = "onCloseButtonClick"},
	}
	cp.getManager("ViewManager").setCSNodeBinding(self,self.rootView,childConfig)
	cp.getManager("ViewManager").setCSNodeTextClear(self.rootView)
	self["Image_bg"]:setTouchEnabled(true)
	self["ScrollView_content"]:setVisible(true)
	
    self.systemTytpe = systemTytpe
    self:initText()

    self.Text_title:setString(self.textList[self.systemTytpe].title)

    local txtSize = self.Text_content:getContentSize()
    local scale = self.Text_content.clearScale
    self.Text_content:setContentSize(cc.size(txtSize.width,0))
    self.Text_content:ignoreContentAdaptWithSize(false)
    self.Text_content:setString(self.textList[self.systemTytpe].content)
    self.Text_content:getAutoRenderSize() --必須調用此接口，使重新設置一次ContentSize
    local szNew = self.Text_content:getVirtualRendererSize()
    self.Text_content:setContentSize(cc.size(szNew.width,szNew.height))
    -- self.Text_content:setContentSize(cc.size(470,txtSize.height))

    self["ScrollView_content"]:setScrollBarEnabled(false)
    self["ScrollView_content"]:setTouchEnabled(true)
    self["ScrollView_content"]:jumpToTop()
    local sz = self["ScrollView_content"]:getContentSize()
    if szNew.height/scale > sz.height then
        self["ScrollView_content"]:setInnerContainerSize(cc.size(sz.width,szNew.height/scale+10))
    end
    self.Text_content:setPositionY(self["ScrollView_content"]:getInnerContainerSize().height-2)
    
end

function TipsHelp:initText()
    
    self.textList = {
        MenPaiMockFights = {title = "地位規則", content = [[
        1.每天可進行門派地位挑戰10次，無論勝利或失敗，挑戰次數都會減少1次。每日0時重置挑戰次數。
        2.每次挑戰勝利可獲得10點聲望值，失敗則扣除2點聲望值。
        3.門派地位挑戰中，如果自身低於對方排名並挑戰勝利，則雙方排名互換。如果高於對方排名並挑戰勝利，則獲得挑戰獎勵，排名不互換。
        4.聲望可用於在聲望商店中兌換獎勵。
        5.排名獎勵將於每日24:00結算，請及時領取。
        6.門派地位排名對應屬性加成獎勵，具體獎勵如下：
        少林方丈 生命值+5% 防禦值+5%
        達摩首座 生命值+4% 防禦值+4%
        羅漢首座 生命值+4% 防禦值+4%
        鎮派高手 生命值+3% 防禦值+3%
        天下行走 生命值+2% 防禦值+2%
        真傳弟子 生命值+1% 防禦值+1% 
        （每個門派的地位稱謂略有不同，此處以少林為例。）]]
        },

        ExpressEscort = {title = "押鏢規則", content = [[        1.鏢車分為一級、二級、三級、四級、五級鏢車區別，級別越高的鏢車可以獲得更加豐富的獎勵。
        2.鏢車每天12:00自動刷新，玩家也可以點擊刷新鏢車進行鏢車刷新，使用元寶刷新將大概率出現獎勵豐富的鏢車。
        3.每日的12:00-13:00以及20:00-21:00進行押鏢，押鏢獎勵將會進行翻倍。
        4.玩家押鏢經過風雨亭、萬鬆嶺、青陽岡，鏢車停靠休息45秒，在這3個地點有風險被其他玩家伏擊，損失部分的押鏢獎勵。
        5.玩家通送不同的鏢車可以獲得銀兩、聲望值、閱歷值、修為點、元寶獎勵。
        6.玩家每天可以押送5次鏢車。]]
        },

        ExpressLoot = {title = "伏擊規則", content = [[        1.玩家可以通過風雨亭、萬鬆嶺、青陽岡進行伏擊。
        2.每輛鏢車僅會在風雨亭、萬鬆嶺、青陽岡停留40秒。
        3.不同伏擊地點僅顯示停靠在該地點的鏢車訊息。
        4.玩家伏擊成功後可以獲得部分鏢師的鏢車獎勵。
        5.無論伏擊成功或失敗，伏擊次數都減少1，玩家每天可以進行10次伏擊。]]
        },

        ZuiEValueRule = {title = "罪惡值規則", content = [[1、玩家在主動與其他玩家進行比試後，無論輸贏，都會獲得5點罪惡值，罪惡值上限為100點，每小時系統會自動消除5點罪惡值。
2、當罪惡值達到100點時，玩家將不在允許與其他玩家進行比試，且在此期間不在獲得系統的體力恢復。
3、在每日0時，玩家的罪惡值將會清零。]]
        },

        jingtong = {title = "精通註釋", content = [[ 各類精通值既可增加自身對應類型武學的傷害值，也可抵禦對手對應類型武學的傷害值，每250點精通值對應的提升效果為1%。]]
        },

        riverEventList = {title = "江湖事件規則", content = [[       【江湖陣營】
        分為六扇門和俠客堂，玩家可選擇其中一種陣營，通過完成江湖事件，可對應獲取 【鐵膽令】與【俠義令】，使用這兩種道具，可在【俠義商店】中兌換部分裝備與武學書籍。
        
       【玩法說明】
        通過積累【鐵膽令】與【俠義令】，可自動獲取對應的稱號，如下：
        六扇門：役馬小卒、帶刀捕快、錦衣捕頭、金刀鐵捕、鐵血名捕、捕神傳奇
        俠義堂：江湖蝦米、青衫俠少、塞外奇俠、中原大俠、神州巨俠、俠隱傳說。]]
        },
        zhuluzhanchang = {title = "規則說明", content = [[        1.逐鹿戰場玩法為每週日18點開啟，分為兩個階段18點~20點為攻堅階段、20點~21點為決勝階段。
        2.攻堅階段：在此階段，雙方陣營玩家可以儘可能爭奪對方的功能建築,當成功擊破對方的功能建築後，陣營會獲得攻破該建築的陣營獎勵，在攻堅階段儘可能攻破更多的敵方功能建築將在決勝階段起著至關重要的作用。
        3.決勝階段：雙方陣營各自對地方總陣營發起進攻，哪邊先擊破對方陣營則勝利，若時間到達時還未有一方擊破地方陣營，則以攻破進度高的陣營方獲得勝利。
        4.玩家可以通過對地方陣營敵人進行挑戰獲得建築擊破進度，當建築擊破進度達到100%時，代表敵方該建築被擊破，則玩家可以獲得該建築物的擊破獎勵。
        5.玩家可以通過“欺負弱雞”、“勢均力敵”、“越級挑戰”來挑選自身的對手，對手實力越強，勝利獲得的功勳和真武令牌也越多。玩家每次進行挑戰需要消耗1個鳴鏑令，在玩家鳴鏑令不足10個時，系統每隔3分鐘自動刷新1個鳴鏑令，在戰鬥過程中也有概率獲得鳴鏑令。
        6.當陣營通過努力擊破地方的功能建築物時，會在逐鹿江湖全圖頭撒大量的寶箱，寶箱數量有限，只有迅敏的玩家才能從中獲得寶箱獎勵。
        7.在逐鹿江湖中，每隔30分鐘六珠上人即到逐鹿江湖對江湖各大豪俠進行試煉，正確回答六珠上人的試煉會獲得豐厚的獎勵，六珠上人每次僅停留10分鐘。
        8.玩家可以通過獲得的真武令牌去真武堂兌換相應的獎勵，真武令牌越多玩家可以解鎖更划算的獎勵，真武令牌以及真武堂在下次逐鹿江湖活動開啟前30分鐘進行重置刷新。
        9.在活動結束後，會發放功勳獎勵禮包，功勳越高的玩家會獲得高額的功勳獎勵。
        ]]
        }
        
    }
end


function TipsHelp:onCloseButtonClick(sender)
	cp.getManager("PopupManager"):removePopup(self)
	--self:removeFromParent()
end

return TipsHelp
