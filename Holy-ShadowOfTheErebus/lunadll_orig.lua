function round(num) 
        if num >= 0 then return math.floor(num+.5) 
        else return math.ceil(num-.5) end
end

nub = 40
bun = 0
yeah = 0
moon = 0
stars = 0
dense = 1.0
musak = 97

function onLoad()
	Audio.SeizeStream(-1)
	tops = Graphics.loadImage("tops.png")
	sides = Graphics.loadImage("sides.png")
	full = Graphics.loadImage("full.png")
	lamp = Graphics.loadImage("lamp.png")
end


function onLoopSection0()
	yeah = 0


--CREATE DARKNESS
--bottom
	Graphics.drawImageToScene(tops,player.x - (134 + nub),player.y + (166 - (nub*2.45)))

--top
	Graphics.drawImageToScene(tops,player.x - 760 + (166 + nub),player.y - 1440 - (134 - (nub*2.45)))

--left
	Graphics.drawImageToScene(sides,player.x - 760 - (134 - (nub*2.45)),player.y - (134 + nub))

--right	
	Graphics.drawImageToScene(sides,player.x + (166 - (nub*2.45)),player.y - 1440 + (166 + nub))

--	Text.print(nub,400,300)

--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if (b.id == 95 or b.id == 96) then
			nub = nub - (nub * 0.02)
			yeah = 1
		end
	end

--DRAW WHITE CIRCLE FOR LAMP
	if (yeah == 0) then
		for _, b in pairs(BGO.get()) do
			if (b.id == 96) then
				Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
			end
		end
	end

--TIGHTEN CIRCLE
	if (nub < 150 and yeah == 0) then
		nub = nub + .08
	end

	if (nub < 40) then
		nub = 40
	end

--AUDIO STUFF
	if (nub > 85 and nub < 130) then
		Audio.MusicVolume(100 - ((nub - 85) * 2))
	elseif (nub > 130) then
		Audio.MusicVolume(5)
	end

	if (Audio.MusicIsPlaying() == -1) then
		Audio.MusicPlay()
	end

--DEAD
	if(player:mem(0x13E,FIELD_WORD) ~= 0) then
		Audio.MusicStop()
--		Graphics.drawImage(full,0,0)
		if (nub < 150) then
			nub = nub + 2.5
		end
	end

end








function onLoopSection2()

bun = 40 + ((player.y + 160000) / 16.8)

--BOTTOM
	Graphics.drawImageToScene(tops,player.x - (134 + bun),player.y + (166 - (bun*2.45)))

--TOP
	Graphics.drawImageToScene(tops,player.x - 760 + (166 + bun),player.y - 1440 - (134 - (bun*2.45)))

--LEFT
	Graphics.drawImageToScene(sides,player.x - 760 - (134 - (bun*2.45)),player.y - (134 + bun))

--RIGHT	
	Graphics.drawImageToScene(sides,player.x + (166 - (bun*2.45)),player.y - 1440 + (166 + bun))

--	Text.print(nub,400,300)

end





function onLoadSection1()
	Audio.MusicOpen("banditcamp2.ogg")
	Audio.MusicPlay()
	Audio.MusicVolume(100)
end

function onLoopSection1()
	if(player:mem(0x13E,FIELD_WORD) ~= 0) then
		Audio.MusicStop()
	end
end




function onLoadSection4()
	Audio.MusicStop()
end

function onLoopSection4()
	yeah = 0


--CREATE DARKNESS
--bottom
	Graphics.drawImageToScene(tops,player.x - (134 + nub),player.y + (166 - (nub*2.45)))

--top
	Graphics.drawImageToScene(tops,player.x - 760 + (166 + nub),player.y - 1440 - (134 - (nub*2.45)))

--left
	Graphics.drawImageToScene(sides,player.x - 760 - (134 - (nub*2.45)),player.y - (134 + nub))

--right	
	Graphics.drawImageToScene(sides,player.x + (166 - (nub*2.45)),player.y - 1440 + (166 + nub))

--	Text.print(nub,400,300)

--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if (b.id == 95 or b.id == 96) then
			nub = nub - (nub * 0.02)
			yeah = 1
		end
	end

--DRAW WHITE CIRCLE FOR LAMP
	if (yeah == 0) then
		for _, b in pairs(BGO.get()) do
			if (b.id == 96) then
				Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
			end
		end
	end

--TIGHTEN CIRCLE
	if (nub < 150 and yeah == 0) then
		nub = nub + .08
	end

	if (nub < 40) then
		nub = 40
	end

--AUDIO STUFF
--	if (nub > 85 and nub < 130) then
--		Audio.MusicVolume(100 - ((nub - 85) * 2))
--	elseif (nub > 130) then
--		Audio.MusicVolume(5)
--	end
--
--	if (Audio.MusicIsPlaying() == -1) then
--		Audio.MusicPlay()
--	end

--DEAD
--	if(player:mem(0x13E,FIELD_WORD) ~= 0) then
--		Audio.MusicStop()
--		Graphics.drawImage(full,0,0)
--		if (nub < 150) then
--			nub = nub + 2.5
--		end
--	end

end


function onLoadSection3()
	Audio.MusicOpen("noise.ogg")
	Audio.MusicVolume(0)
	Audio.MusicPlay()
end


function onLoopSection3()
	yeah = 0


--CREATE DARKNESS
--bottom
	Graphics.drawImageToScene(tops,player.x - (134 + nub),player.y + (166 - (nub*2.45)))

--top
	Graphics.drawImageToScene(tops,player.x - 760 + (166 + nub),player.y - 1440 - (134 - (nub*2.45)))

--left
	Graphics.drawImageToScene(sides,player.x - 760 - (134 - (nub*2.45)),player.y - (134 + nub))

--right	
	Graphics.drawImageToScene(sides,player.x + (166 - (nub*2.45)),player.y - 1440 + (166 + nub))

--	Text.print(nub,400,300)

--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if (b.id == 95 or b.id == 96) then
			nub = nub - (nub * 0.02)
			yeah = 1
		end
	end

--DRAW WHITE CIRCLE FOR LAMP
--	if (yeah == 0) then
--		for _, b in pairs(BGO.get()) do
--			if (b.id == 96) then
--				Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
--			end
--		end
--	end

--TIGHTEN CIRCLE
	if (nub < 150 and yeah == 0) then
		nub = nub + 0.12
	end

	if (nub < 40) then
		nub = 40
	end

--AUDIO STUFF
	if (nub > 65 and nub < 130) then
		Audio.MusicVolume(round(0 + ((nub - 65) * 1.5)))
	elseif (nub > 130) then
		Audio.MusicVolume(round(97.5))
	end

	if (Audio.MusicIsPlaying() == -1) then
		Audio.MusicPlay()
	end

--DEAD
--	if(player:mem(0x13E,FIELD_WORD) ~= 0) then
--		Audio.MusicStop()
--		Graphics.drawImage(full,0,0)
--		if (nub < 150) then
--			nub = nub + 2.5
--		end
--	end

end






function onLoadSection5()
	nub = 150
	Audio.MusicOpen("noise.ogg")
	Audio.MusicVolume(round(97.5))
	Audio.MusicPlay()
end

function onLoopSection5()
	yeah = 0


--CREATE DARKNESS
--bottom
	Graphics.drawImageToScene(tops,player.x - (134 + nub),player.y + (166 - (nub*2.45)))

--top
	Graphics.drawImageToScene(tops,player.x - 760 + (166 + nub),player.y - 1440 - (134 - (nub*2.45)))

--left
	Graphics.drawImageToScene(sides,player.x - 760 - (134 - (nub*2.45)),player.y - (134 + nub))

--right	
	Graphics.drawImageToScene(sides,player.x + (166 - (nub*2.45)),player.y - 1440 + (166 + nub))

--	Text.print(nub,400,300)

--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if (b.id == 95 or b.id == 96) then
			nub = nub - (nub * 0.08)
			yeah = 1
		end
	end

--DRAW WHITE CIRCLE FOR LAMP
	if (yeah == 0 and moon == 1) then
		for _, b in pairs(BGO.get()) do
			if (b.id == 96 or b.id == 57) then
				Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
			end
		end
	end

--TIGHTEN CIRCLE
	if (nub < 150 and yeah == 0) then
		nub = nub + (nub * 0.08)
	end

	if (nub < 40) then
		nub = 40
	end

--AUDIO STUFF
	if (nub > 65 and nub < 130) then
		Audio.MusicVolume(round(0 + ((nub - 65) * 1.5)))
	elseif (nub > 130) then
		Audio.MusicVolume(round(97.5))
	end

	if (Audio.MusicIsPlaying() == -1) then
		Audio.MusicPlay()
	end

--DEAD
--	if(player:mem(0x13E,FIELD_WORD) ~= 0) then
--		Audio.MusicStop()
--		Graphics.drawImage(full,0,0)
--		if (nub < 150) then
--			nub = nub + 2.5
--		end
--	end

end

function onEvent(eventname)
	if eventname == "axe" then
		moon = 1
	elseif eventname == "curtain" then
		stars = 1
	end
end




--OUTER SPACE STUFF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function onLoopSection7()
	if (stars == 0) then
		if (musak >= 0) then
			Audio.MusicVolume(round(musak))
			musak = musak - 0.25
		elseif (musak < 0) then
			Audio.MusicStop()
		end
	end

	if (dense > 0) then
		Graphics.drawImage(full,0,0,dense)
		if (stars == 1) then
			Audio.MusicOpen("wilderness2.ogg")
			Audio.MusicVolume(100)
			Audio.MusicPlay()
			dense = dense - 0.001
		end
	end
end

function onLoopSection6()
	if (dense > 0) then
		Graphics.drawImage(full,0,0,dense)
		dense = dense - 0.001
	end
end