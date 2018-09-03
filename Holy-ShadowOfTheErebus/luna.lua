local rng = API.load ("rng")

local checkpoints = API.load("checkpoints");

local darkness = API.load("darkness")

local cp1 = checkpoints.create{x=-98976+16, y=-100192, section = 5}	

function round(num) 
    if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
end

local encroach = 40
local bun = 0
local yeah = 0
local moon = 0
local stars = false
local dense = 1.0
local musak = 97
local framecount = 0
local nextLoop = 5

local imgIndex = 1
local topsArray, sidesArray = {}, {}

for  i=1,5  do
	topsArray[i] = Graphics.loadImage("tops"..tostring(i)..".png")
	sidesArray[i] = Graphics.loadImage("sides"..tostring(i)..".png")
end

local tops = topsArray[imgIndex]
local sides = sidesArray[imgIndex]

local lamp = Graphics.loadImage("lamp.png")

local field = darkness.Create{falloff=Misc.resolveFile("falloff_jitter.glsl"), uniforms = {noise = Graphics.loadImage("noise.png"), time = 0}, sections={0,2,3,4, 5}}
local plight = darkness.Light(0,0,0,1,Color.white);
field:AddLight(plight);

darkness.objects.bgos[57] = darkness.objects.bgos[96]

function onStart()
	plight:Attach(player);
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
	local altAudio = boolDefault {props.altAudio, false}
	local superShrink = boolDefault {props.superShrink, false}
	local showWhiteCircle = boolDefault {props.showWhiteCircle, true}
	local shrinkRate = props.shrinkRate  or  0.08
	local growRate = props.growRate  or  0.02
		
	encroach = props.forcedVal  or  encroach
	
	local lampTouched = false
	
	
	-- RANDOM DARKNESS FRAMES
	framecount = (framecount + 1) % nextLoop
	
	if  framecount == 0  then
		local oldIndex = imgIndex
		
		while oldIndex == imgIndex  do
			imgIndex = rng.randomInt (1, #topsArray)
		end

		tops = topsArray [imgIndex]
		sides = sidesArray [imgIndex]
		nextLoop = rng.randomInt (5,15)
	end
	
	if(lunatime.tick()%8 == 0) then
		field.uniforms.time = field.uniforms.time + 1;
	end
	if(player:mem(0x13E, FIELD_WORD) ~= 0) then
		plight:Detach();
	end
	plight.radius = (150-encroach)/150 * 760;
	--[[
	--CREATE DARKNESS
	--bottom
		Graphics.drawImageToScene (tops,player.x - (134 + encroach),player.y + player.height - 32 + (166 - (encroach*2.45)))

	--top
		Graphics.drawImageToScene (tops,player.x - 760 + (166 + encroach),player.y + player.height - 32 - 1440 - (134 - (encroach*2.45)))

	--left
		Graphics.drawImageToScene (sides,player.x - 760 - (134 - (encroach*2.45)),player.y + player.height - 32 - (134 + encroach))

	--right	
		Graphics.drawImageToScene (sides,player.x + (166 - (encroach*2.45)),player.y + player.height - 32 - 1440 + (166 + encroach))
]]
	--	Text.print(encroach,400,300)

	
	--DARKNESS ABATED WHEN TOUCH LAMP
	for _, b in ipairs (BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
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
	if (not lampTouched or encroach > 125)  and  showWhiteCircle  then
		for _, b in ipairs(BGO.get(96, player.section)) do
			Graphics.drawImageToSceneWP(lamp,b.x,b.y,1.1)
		end
	end

	
	--TIGHTEN CIRCLE
	if (encroach < 150 and not lampTouched) then
		if  superShrink  then
			encroach = encroach + (encroach * shrinkRate)
		else
			encroach = encroach + shrinkRate
		end
	end

	if (encroach < 40) then
		encroach = 40
	end

	
	if  controlAudio  then
		if  altAudio  then
			if (encroach > 65 and encroach < 130) then
				Audio.MusicVolume(round(0 + ((encroach - 65) * 1.5)))
			elseif (encroach > 130) then
				Audio.MusicVolume(round(97.5))
			else
				Audio.MusicVolume(0)
			end
		else
			--AUDIO STUFF
			if (encroach > 85 and encroach < 130) then
				Audio.MusicVolume(100 - ((encroach - 85) * 2))
			elseif (encroach > 130) then
				Audio.MusicVolume(5)
			end
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

local lastSection = 1;

function onTick()
	--Entered a new section
	if(player.section ~= lastSection) then
		if(player.section == 3) then
			Audio.MusicOpen ("noise.ogg")
			Audio.MusicVolume (0)
			Audio.MusicPlay ()
		elseif(player.section == 4) then
			Audio.MusicStop()
		elseif(player.section == 5) then
			encroach = 150
			Audio.MusicOpen ("noise.ogg")
			Audio.MusicVolume (round(97.5))
			Audio.MusicPlay ()
			
			field.ambient = Color.black
		end
	end
	
	local changedSection = false;
	
	if(player.section == 0) then
		manageDarkness {}
	elseif(player.section == 1) then
		-- If the player dies, stop the music
		if(player:mem(0x13E,FIELD_WORD) ~= 0) then
			Audio.MusicStop ()
		end
		
		--Warp when player jumps down hole
		if(player.y + player.height >= -180000) then
			player.section = 2;
			player.x = player.x + 19776;
			player.y = -160608-32;
			changedSection = true;
			playMusic(2);
		end
	elseif(player.section == 2) then
		local bun = 40 + ((player.y + 160000) / 16.8)
		manageDarkness {forcedVal = bun}
		
		--Warp when player jumps down hole
		if(player.y + player.height >= -160000) then
			player.section = 0;
			player.x = player.x - 39424;
			player.y = -200896-32;
			changedSection = true;
			playMusic(0);
		end
		
	elseif(player.section == 3) then
		manageDarkness {showWhiteCircle=false, shrinkIfDead=false, controlAudio=false}		
		
		if(player.y + player.height > -138272) then
			Audio.MusicVolume(math.min(100, Audio.MusicVolume()+0.12))
		end
		
		--Warp when player jumps down hole
		if(player.y + player.height >= -128512) then
			player.section = 5;
			player.x = -98976;
			player.y = -100608-32;
			changedSection = true;
			playMusic(5);
		end
	elseif(player.section == 4) then
		manageDarkness {}
		
		--Warp when player jumps down hole
		if(player.y + player.height >= -120000) then
			player.section = 3;
			player.x = player.x - 20448;
			player.y = -140608-32;
			changedSection = true;
			playMusic(3);
		end
	elseif(player.section == 5) then
		manageDarkness {superShrink=true, growRate=0.08, shrinkRate=0.08, shrinkIfDead=false, useMoon=true, altAudio=true}
		if(not cp1.collected and player:isOnGround()) then
			cp1:collect()
		end
		if (player.x > -96150)  then
			player.x = -96128
			if (musak >= 0) then
				Audio.MusicVolume(round(musak))
				musak = musak - 0.25
			elseif (musak < 0) then
				player.section = 7;
				player.x = -59512;
				player.y = -60128-player.height;
				changedSection = true;
				stars = true
				triggerEvent("curtain")
				playMusic(7)
			end
		end

	--OUTER SPACE STUFF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	elseif(player.section == 6) then
		if (dense > 0) then
			dense = dense - 0.002
			Audio.MusicVolume(100-100*dense)
		end
	elseif(player.section == 7) then
		if (not stars) then

		elseif (dense > 0) then
			--Audio.MusicOpen("wilderness2.ogg")
			Audio.MusicVolume(100-100*dense)
			--Audio.MusicPlay()
			dense = dense - 0.002
		end
	end
	
	if(not changedSection) then
		lastSection = player.section;
	end
end

function onDraw()
	if((player.section == 6 or player.section == 7) and dense > 0) then
		Graphics.drawScreen{color={0,0,0,dense}}
	end
end