local rng = API.load ("rng")

function round(num) 
    if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
end

local encroach = 40
local bun = 0
local yeah = 0
local moon = 0
local stars = 0
local dense = 1.0
local musak = 97
local framecount = 0

function onLoad()
	Audio.SeizeStream(-1)
	tops1 = Graphics.loadImage("tops1.png")
	sides1 = Graphics.loadImage("sides1.png")
	tops2 = Graphics.loadImage("tops2.png")
	sides2 = Graphics.loadImage("sides2.png")
	tops3 = Graphics.loadImage("tops3.png")
	sides3 = Graphics.loadImage("sides3.png")
	
	tops = tops1
	sides = sides1
	
	full = Graphics.loadImage("full.png")
	lamp = Graphics.loadImage("lamp.png")
end


function boolDefault (args)
	local returnval
	
	i = 1;
	while  i <= #args  do
		if  args[i] ~= nil  then
			returnval = args[i]
			break;
		else
			i = i+1
		end
	end
	
	return returnval;
end


function manageDarkness (props)
	local controlAudio = boolDefault {props.controlAudio, true}
	local shrinkIfDead = boolDefault {props.shrinkIfDead, true}
	local useMoon = boolDefault {props.useMoon, false}
	local showWhiteCircle = boolDefault {props.showWhiteCircle, true}
	local shrinkRate = props.shrinkRate  or  0.08
	local growRate = props.growRate  or  0.02
		
	encroach = props.forcedVal  or  encroach
	
	local lampTouched = false
	
	if  framecount == 0  then
		tops = rng.randomEntry {tops1,tops2,tops3}
		if  tops == tops3  then
			sides = sides3
		else
			sides = rng.randomEntry {sides1,sides2}
		end
	end
	
		
	--CREATE DARKNESS
	--bottom
		Graphics.drawImageToScene (tops,player.x - (134 + encroach),player.y + (166 - (encroach*2.45)))

	--top
		Graphics.drawImageToScene (tops,player.x - 760 + (166 + encroach),player.y - 1440 - (134 - (encroach*2.45)))

	--left
		Graphics.drawImageToScene (sides,player.x - 760 - (134 - (encroach*2.45)),player.y - (134 + encroach))

	--right	
		Graphics.drawImageToScene (sides,player.x + (166 - (encroach*2.45)),player.y - 1440 + (166 + encroach))

	--	Text.print(encroach,400,300)

	
	--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in pairs (BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if (b.id == 95 or b.id == 96) then
			encroach = encroach - (encroach * growRate)
			lampTouched = true
		end
	end

	
	-- MOON MANAGEMENT
	if  (useMoon)  then
		if  moon == false  then  lampTouched = true;  end;
	end
	
	
	--DRAW WHITE CIRCLE FOR LAMP
	if (not lampTouched)  and  showWhiteCircle  then
		for _, b in pairs(BGO.get()) do
			if (b.id == 96) then
				Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
			end
		end
	end

	
	--TIGHTEN CIRCLE
	if (encroach < 150 and yeah == 0) then
		encroach = encroach + shrinkRate
	end

	if (encroach < 40) then
		encroach = 40
	end

	
	if  controlAudio  then
		--AUDIO STUFF
		if (encroach > 85 and encroach < 130) then
			Audio.MusicVolume(100 - ((encroach - 85) * 2))
		elseif (encroach > 130) then
			Audio.MusicVolume(5)
		end

		if (Audio.MusicIsPlaying () == -1) then
			Audio.MusicPlay ()
		end
	end
	
	
	if  shrinkIfDead  then
		--DEAD
		if (player:mem (0x13E,FIELD_WORD) ~= 0) then
			Audio.MusicStop ()
	--		Graphics.drawImage(full,0,0)
			if (encroach < 150) then
				encroach = encroach + 2.5
			end
		end
	end
end


function onLoop ()
	framecount = (framecount + 1) % 10
end


function onLoopSection0 ()
	manageDarkness {}
end


function onLoadSection1 ()
	Audio.MusicOpen ("banditcamp2.ogg")
	Audio.MusicPlay ()
	Audio.MusicVolume (100)
end


function onLoopSection1 ()
	-- If the player dies, stop the music
	if (player:mem(0x13E,FIELD_WORD) ~= 0) then
		Audio.MusicStop ()
	end
end

function onLoopSection2 ()
	local bun = 40 + ((player.y + 160000) / 16.8)
	manageDarkness {forcedVal = bun}
end


function onLoadSection3()
	Audio.MusicOpen ("noise.ogg")
	Audio.MusicVolume (0)
	Audio.MusicPlay ()
end

function onLoopSection3()
	manageDarkness {showWhiteCircle=false, shrinkIfDead=false}
end


function onLoadSection4()
	Audio.MusicStop()
end

function onLoopSection4()
	manageDarkness {}
end



function onLoadSection5()
	encroach = 150
	Audio.MusicOpen ("noise.ogg")
	Audio.MusicVolume (round(97.5))
	Audio.MusicPlay ()
end

function onLoopSection5 ()
	manageDarkness {shrinkIfDead=false, useMoon=true}
end




function onEvent(eventname)
	if eventname == "axe" then
		moon = 1
	elseif eventname == "curtain" then
		stars = 1
	end
end




--OUTER SPACE STUFF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function onLoopSection7 ()
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

function onLoopSection6 ()
	if (dense > 0) then
		Graphics.drawImage (full,0,0,dense)
		dense = dense - 0.001
	end
end