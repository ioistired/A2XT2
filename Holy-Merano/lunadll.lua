local myLevelData = Data(Data.DATA_LEVEL, "myData")
coinCount = 0
coinCount2 = 0
coinCheck = 0
coinCounted = 0
coinCounted2 = 0
coinHelpMe = 0
coinAdd = 0
horizontal = 0
row = 0
col = 0
gameStart = 0
piece = 0
text = 0

function onLoad()
	bigLeft = Graphics.loadImage("bigLeft.png")
	bigRight = Graphics.loadImage("bigRight.png")
	duckLeft = Graphics.loadImage("duckLeft.png")
	duckRight = Graphics.loadImage("duckRight.png")
	smallLeft = Graphics.loadImage("smallLeft.png")
	smallRight =  Graphics.loadImage("smallRight.png")
	smallSpinLeft = Graphics.loadImage("smallSpinLeft.png")
	smallSpinRight = Graphics.loadImage("smallSpinRight.png")
	smallSlidLeft = Graphics.loadImage("smallSlidLeft.png")
	smallSlidRight = Graphics.loadImage("smallSlidRight.png")
	bigSpinLeft = Graphics.loadImage("bigSpinLeft.png")
	bigSpinRight = Graphics.loadImage("bigSpinRight.png")
	bigSlidLeft = Graphics.loadImage("bigSlidLeft.png")
	bigSlidRight = Graphics.loadImage("bigSpinRight.png")
	selector = Graphics.loadImage("selector.png")

--	mem(0x00B2C5A8,FIELD_WORD,0)
end



--this is how the image thing works. first, the player can only be small or big. then it checks to see which state of five the player is in (big,big ducking, big spinjumping, small, small spinjumping) and draws an image of the player in the same state 600 pixels above and below them.

function onLoopSection0()

if(coinCheck ~= mem(0x00B2C5A8,FIELD_WORD)) then
	coinCount = coinCount + 1
	coinCheck = mem(0x00B2C5A8,FIELD_WORD)
end
--Text.print(coinCount,30,30)

if(player.powerup == PLAYER_BIG) then
	--check for if ducking
	if(player:mem(0x12E,FIELD_WORD) == -1) then

--DUCK WRAP HERE
if (player.speedY > 0) then
	if (player.y > -200014) then
		--bottom to top
		player.y = -200604
	end
elseif (player.speedY < 0) then
	if (player.y < -200614) then
		--top to bottom
		player.y = -200014
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(duckLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(duckLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(duckRight,player.x,player.y - 600)
			Graphics.drawImageToScene(duckRight,player.x,player.y + 600)
		end

	--check for if sliding
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then

--BIG SLIDING WRAP HERE
if (player.speedY > 0) then
	if (player.y > -200038) then
		--bottom to top
		player.y = -200630
	end
elseif (player.speedY < 0) then
	if (player.y < -200638) then
		--top to bottom
		player.y = -200038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y + 600)
		end

	--check for if spinjumping
	elseif(player:mem(0x50,FIELD_WORD) == -1) then

--BIG SPINJUMP WRAP HERE
if (player.speedY > 0) then
	if (player.y > -200038) then
		--bottom to top
		player.y = -200630
	end
elseif (player.speedY < 0) then
	if (player.y < -200638) then
		--top to bottom
		player.y = -200038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y + 600)
		end

	else

--BIG WRAP HERE
if (player.speedY > 0) then
	if (player.y > -200038) then
		--bottom to top
		player.y = -200630
	end
elseif (player.speedY < 0) then
	if (player.y < -200638) then
		--top to bottom
		player.y = -200038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then



			Graphics.drawImageToScene(bigLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigRight,player.x,player.y + 600)
		end
	end

elseif(player.powerup == PLAYER_SMALL) then

--SMALL WRAP HERE
if (player.speedY > 0) then
	if (player.y > -200014) then
		--bottom to top
		player.y = -200604
	end
elseif (player.speedY < 0) then
	if (player.y < -200614) then
		--top to bottom
		player.y = -200014
	end
end

	--check for if spinjumping
	if(player:mem(0x50,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y + 600)
		end
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y + 600)
		end
	else
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallRight,player.x,player.y + 600)
		end
	end

end
--yes, there's two or three ends here
end






--YOU ARE NOW CHANGING SECTIONS
--YOU ARE NOW IN SECTION TWO







function onEvent(eventname)
	if eventname == "logFirst" then
		myLevelData:set("coyn",tostring(coinCount))
		myLevelData:save()
	elseif eventname == "logSecond" then
		coinCounted2 = coinCount2
		if coinCounted ~= nil and coinCounted ~= '' then
			coinAdd = coinCounted2 + tonumber(coinCounted)
		end
		if coinAdd >= 600 then
			triggerEvent("switchOne")
		else
			triggerEvent("switchTwo")
		end
	elseif eventname == "wrapOne" then
		horizontal = 1
	elseif eventname == "wrapTwo" then
		horizontal = 0
	elseif eventname == "WrapThree" then
		horizontal = 1

	elseif eventname == "1" then
		row = 1
	elseif eventname == "2" then
		row = 2
	elseif eventname == "3" then
		row = 3
	elseif eventname == "4" then
		row = 4
	elseif eventname == "5" then
		row = 5
	elseif eventname == "21" then
		col = 1
	elseif eventname == "22" then
		col = 2
	elseif eventname == "23" then
		col = 3
	elseif eventname == "24" then
		col = 4
	elseif eventname == "25" then
		col = 5
	elseif eventname == "26" then
		col = 6
	elseif eventname == "27" then
		col = 7
	elseif eventname == "28" then
		col = 8
	elseif eventname == "confirmPiece" then
		gameStart = 3
		row = 0
		col = 0
		triggerEvent("pieceSwitchOff")
	elseif eventname == "confirmMove" then
		gameStart = 4
		triggerEvent("moveSwitchOff")
		triggerEvent("switchSwitch")
		text = 5
	elseif eventname == "boop" then
		text = 6
	elseif eventname == "boop2" then
		text = 7
	elseif eventname == "cancel" then
		gameStart = 2
		row = 0
		col = 0
		piece = 0
	elseif eventname == "START" then
		if gameStart == 0 then
			gameStart = 1
		end
	elseif eventname == "timetalk2" then
		text = 1
	elseif eventname == "timetalk3" then
		text = 2
	elseif eventname == "timetalk4" then
		text = 3
	elseif eventname == "timetalk5" then
		text = 4
	end
end







function onLoopSection1()

coinCounted = myLevelData:get("coyn");
Text.print(coinCounted,480,520)

if(player.powerup == PLAYER_BIG) then
	--check for if ducking
	if(player:mem(0x12E,FIELD_WORD) == -1) then

--DUCK WRAP HERE
if (player.speedY > 0) then
	if (player.y > -180014) then
		--bottom to top
		player.y = -180604
	end
elseif (player.speedY < 0) then
	if (player.y < -180614) then
		--top to bottom
		player.y = -180014
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(duckLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(duckLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(duckRight,player.x,player.y - 600)
			Graphics.drawImageToScene(duckRight,player.x,player.y + 600)
		end

	--check for if sliding
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then

--BIG SLIDING WRAP HERE
if (player.speedY > 0) then
	if (player.y > -180038) then
		--bottom to top
		player.y = -180630
	end
elseif (player.speedY < 0) then
	if (player.y < -180638) then
		--top to bottom
		player.y = -180038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y + 600)
		end

	--check for if spinjumping
	elseif(player:mem(0x50,FIELD_WORD) == -1) then

--BIG SPINJUMP WRAP HERE
if (player.speedY > 0) then
	if (player.y > -180038) then
		--bottom to top
		player.y = -180630
	end
elseif (player.speedY < 0) then
	if (player.y < -180638) then
		--top to bottom
		player.y = -180038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y + 600)
		end

	else

--BIG WRAP HERE
if (player.speedY > 0) then
	if (player.y > -180038) then
		--bottom to top
		player.y = -180630
	end
elseif (player.speedY < 0) then
	if (player.y < -180638) then
		--top to bottom
		player.y = -180038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then



			Graphics.drawImageToScene(bigLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigRight,player.x,player.y + 600)
		end
	end

elseif(player.powerup == PLAYER_SMALL) then

--SMALL WRAP HERE
if (player.speedY > 0) then
	if (player.y > -180014) then
		--bottom to top
		player.y = -180604
	end
elseif (player.speedY < 0) then
	if (player.y < -180614) then
		--top to bottom
		player.y = -180014
	end
end

	--check for if spinjumping
	if(player:mem(0x50,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y + 600)
		end
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y + 600)
		end
	else
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallRight,player.x,player.y + 600)
		end
	end

end
--yes, there's two or three ends here
end



--YOU ARE NOW CHANGING SECTIONS
--YOU ARE NOW ENTERING SECTION THREE, GOOD LUCK



function onLoopSection2()

if(coinCheck ~= mem(0x00B2C5A8,FIELD_WORD)) then
	coinCount2 = coinCount2 + 1
	coinCheck = mem(0x00B2C5A8,FIELD_WORD)
end
--Text.print(coinCount2,30,30)


if(horizontal == 1) then

if(player.powerup == PLAYER_BIG) then
	--check for if ducking
	if(player:mem(0x12E,FIELD_WORD) == -1) then

--DUCK WRAP HERE
if (player.speedY > 0) then
	if (player.y > -160014) then
		--bottom to top
		player.y = -160604
	end
elseif (player.speedY < 0) then
	if (player.y < -160614) then
		--top to bottom
		player.y = -160014
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(duckLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(duckLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(duckRight,player.x,player.y - 600)
			Graphics.drawImageToScene(duckRight,player.x,player.y + 600)
		end

	--check for if sliding
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then

--BIG SLIDING WRAP HERE
if (player.speedY > 0) then
	if (player.y > -160038) then
		--bottom to top
		player.y = -160630
	end
elseif (player.speedY < 0) then
	if (player.y < -160638) then
		--top to bottom
		player.y = -160038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSlidRight,player.x,player.y + 600)
		end

	--check for if spinjumping
	elseif(player:mem(0x50,FIELD_WORD) == -1) then

--BIG SPINJUMP WRAP HERE
if (player.speedY > 0) then
	if (player.y > -160038) then
		--bottom to top
		player.y = -160630
	end
elseif (player.speedY < 0) then
	if (player.y < -160638) then
		--top to bottom
		player.y = -160038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigSpinRight,player.x,player.y + 600)
		end

	else

--BIG WRAP HERE
if (player.speedY > 0) then
	if (player.y > -160038) then
		--bottom to top
		player.y = -160630
	end
elseif (player.speedY < 0) then
	if (player.y < -160638) then
		--top to bottom
		player.y = -160038
	end
end

		if(player:mem(0x106,FIELD_WORD) == -1) then



			Graphics.drawImageToScene(bigLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(bigLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(bigRight,player.x,player.y - 600)
			Graphics.drawImageToScene(bigRight,player.x,player.y + 600)
		end
	end

elseif(player.powerup == PLAYER_SMALL) then

--SMALL WRAP HERE
if (player.speedY > 0) then
	if (player.y > -160014) then
		--bottom to top
		player.y = -160604
	end
elseif (player.speedY < 0) then
	if (player.y < -160614) then
		--top to bottom
		player.y = -160014
	end
end

	--check for if spinjumping
	if(player:mem(0x50,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSpinRight,player.x,player.y + 600)
		end
	elseif(player:mem(0x3C,FIELD_WORD) == -1) then
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallSlidRight,player.x,player.y + 600)
		end
	else
		if(player:mem(0x106,FIELD_WORD) == -1) then
			Graphics.drawImageToScene(smallLeft,player.x,player.y - 600)
			Graphics.drawImageToScene(smallLeft,player.x,player.y + 600)
		else
			Graphics.drawImageToScene(smallRight,player.x,player.y - 600)
			Graphics.drawImageToScene(smallRight,player.x,player.y + 600)
		end
	end

end
--yes, there's two or three or four ends here
end
end



--IT'S SECTION FOUR
--IT'S NOT COMPLICATED FOR ONCE
--OH WAIT IT IS

function onLoadSection3()
	coinCounted = myLevelData:get("coyn");
end

function onLoopSection3()
	Text.print(coinCounted,200,290)
	Text.print(coinCounted2,200,320)
	if coinCounted ~= nil and coinCounted ~= '' then
		Text.print(tostring(coinAdd),200,350)
	else
		Text.print(coinCounted2,200,350)
	end
end




--HERE WE GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO SECTION 5
--SECTION 5 - CHESS CHESS CHESS




function onLoopSection4()
if gameStart == 1 then
	if text == 0 then
		Text.print("COINFLIP: COM GOES FIRST",190,156)
	elseif text == 1 then
		Text.print("COM TURN",327,156)
	elseif text == 2 then
		Text.print("Chessbot is",600,30)
		Text.print("thinking...",600,50)
	elseif text == 3 then
		triggerEvent("comMove")
		Text.print("YOUR TURN",320,156)
	elseif text == 4 then
		triggerEvent("switchSwitch")
		gameStart = 2
	end
elseif gameStart == 2 then
	if row == 2 and col == 1 then
		Graphics.drawImage(selector,142,382)
		triggerEvent("pieceSwitch")
		piece = 1
	elseif row == 2 and col == 2 then
		Graphics.drawImage(selector,206,382)
		triggerEvent("pieceSwitch")
		piece = 2
	elseif row == 2 and col == 3 then
		Graphics.drawImage(selector,270,382)
		triggerEvent("pieceSwitch")
		piece = 3
	elseif row == 2 and col == 4 then
		Graphics.drawImage(selector,334,382)
		triggerEvent("pieceSwitch")
		piece = 4
	elseif row == 2 and col == 5 then
		Graphics.drawImage(selector,398,382)
		triggerEvent("pieceSwitch")
		piece = 5
	elseif row == 2 and col == 6 then
		Graphics.drawImage(selector,462,382)
		triggerEvent("pieceSwitch")
		piece = 6
	elseif row == 2 and col == 7 then
		Graphics.drawImage(selector,526,382)
		triggerEvent("pieceSwitch")
		piece = 7
	elseif row == 2 and col == 8 then
		Graphics.drawImage(selector,590,382)
		triggerEvent("pieceSwitch")
		piece = 8
	elseif row == 1 and col == 2 then
		Graphics.drawImage(selector,206,446)
		triggerEvent("pieceSwitch")
		piece = 9
	elseif row == 1 and col == 7 then
		Graphics.drawImage(selector,526,446)
		triggerEvent("pieceSwitch")
		piece = 10
	else
		triggerEvent("pieceSwitchOff")
		piece = 0
	end
elseif gameStart == 3 then

if piece == 1 then
	Graphics.drawImage(selector,142,382)
	if row == 3 and col == 1 then
		Graphics.drawImage(selector,142,318)
		triggerEvent("1-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 1 then
		Graphics.drawImage(selector,142,254)
		triggerEvent("1-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no1")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 2 then
	Graphics.drawImage(selector,206,382)
	if row == 3 and col == 2 then
		Graphics.drawImage(selector,206,318)
		triggerEvent("2-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 2 then
		Graphics.drawImage(selector,206,254)
		triggerEvent("2-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no2")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 3 then
	Graphics.drawImage(selector,270,382)
	if row == 3 and col == 3 then
		Graphics.drawImage(selector,270,318)
		triggerEvent("3-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 3 then
		Graphics.drawImage(selector,270,254)
		triggerEvent("3-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no3")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 4 then
	Graphics.drawImage(selector,334,382)
	if row == 3 and col == 4 then
		Graphics.drawImage(selector,334,318)
		triggerEvent("4-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 4 then
		Graphics.drawImage(selector,334,254)
		triggerEvent("4-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no4")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 5 then
	Graphics.drawImage(selector,398,382)
	if row == 3 and col == 5 then
		Graphics.drawImage(selector,398,318)
		triggerEvent("5-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 5 then
		Graphics.drawImage(selector,398,254)
		triggerEvent("5-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no5")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 6 then
	Graphics.drawImage(selector,462,382)
	if row == 3 and col == 6 then
		Graphics.drawImage(selector,462,318)
		triggerEvent("6-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 6 then
		Graphics.drawImage(selector,462,254)
		triggerEvent("6-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no6")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 7 then
	Graphics.drawImage(selector,526,382)
	if row == 3 and col == 7 then
		Graphics.drawImage(selector,526,318)
		triggerEvent("7-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 7 then
		Graphics.drawImage(selector,526,254)
		triggerEvent("7-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no7")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 8 then
	Graphics.drawImage(selector,590,382)
	if row == 3 and col == 8 then
		Graphics.drawImage(selector,590,318)
		triggerEvent("8-1")
		triggerEvent("moveSwitch")
	elseif row == 4 and col == 8 then
		Graphics.drawImage(selector,590,254)
		triggerEvent("8-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no8")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 9 then
	Graphics.drawImage(selector,206,446)
	if row == 3 and col == 1 then
		Graphics.drawImage(selector,142,318)
		triggerEvent("9-1")
		triggerEvent("moveSwitch")
	elseif row == 3 and col == 3 then
		Graphics.drawImage(selector,270,318)
		triggerEvent("9-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no9")
		triggerEvent("moveSwitchOff")
	end
end

if piece == 10 then
	Graphics.drawImage(selector,526,446)
	if row == 3 and col == 6 then
		Graphics.drawImage(selector,462,318)
		triggerEvent("1-1")
		triggerEvent("moveSwitch")
	elseif row == 3 and col == 8 then
		Graphics.drawImage(selector,590,318)
		triggerEvent("1-2")
		triggerEvent("moveSwitch")
	else
		triggerEvent("no1")
		triggerEvent("moveSwitchOff")
	end
end

elseif gameStart == 4 then
	if text == 5 then
		Text.print("COM TURN",327,156)
	elseif text == 6 then
		Text.print("Chessbot is",600,30)
		Text.print("thinking...",600,50)
	elseif text == 7 then
	end

end

end



