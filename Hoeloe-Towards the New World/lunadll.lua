local maxx;
local snowStart = -197548;
local snowEnd = -195000;
local npcconfig = API.load("npcconfig");
local basex = -190624;
local endx = -170000;

local trees = {{4,700},{1,1700}, {1,2300}, {4,3000}, {1,3900}, {1,4600},{4,5200}, {2,6000}, {2,6720}, {5,7800}, {2,8660}, {5, 9300}, {5, 10500}, {3,11000}, {3,12000}, {6,12750}, {6,13570}, {3,14400}, {6,15070}, {3,16000}, {3,16900}}
local treetypes = {Graphics.loadImage("tree_bare_1.png"), Graphics.loadImage("tree_bare_2.png"), Graphics.loadImage("tree_bare_3.png"),Graphics.loadImage("tree_green_1.png"),Graphics.loadImage("tree_green_2.png"),Graphics.loadImage("tree_green_3.png")}
local parallaxFactor = 1.2;

local snows = {Graphics.loadImage("snow_1.png"), Graphics.loadImage("snow_2.png"), Graphics.loadImage("snow_3.png")};
local snowStr = 0;
local snowOffset = 0;
local snowTimer = 0;

local bird = Graphics.loadImage("bird.png");
local birds = {{x = -199904, y = -200352, frame = 0, flap = 3, flapTime = 5, speedX = 9, speedY = 5}, {x = -199712, y = -200384, frame = 0, flap = 4, flapTime = 7, speedX = 8, speedY = 6}}
local birdspawns = {{x = -199056, y = -200352, frame = 0, flap = 3, flapTime = 5, speedX = 12, speedY = 4}, {x = -197472, y = -200320, frame = 0, flap = 3, flapTime = 5, speedX = 12, speedY = 4}, {x = -195776, y = -200256, frame = 0, flap = 3, flapTime = 5, speedX = 9, speedY = 4}};

Audio.playSFX("birds.ogg");

local function DrawBird(x,y,img)
		Graphics.drawImageToSceneWP(bird, x, y, 0, 32*img, 32, 32, 0.898);
end

function onTick()
	if(maxx == nil or player.x > maxx) then
		maxx = player.x;
	end
	
	local spdMult =  math.min(1,(math.max(0,1-((maxx-basex)/(endx-basex)))));
	
	player.speedX = player.speedX * spdMult;
	if(player2 ~= nil) then player2.speedX = player2.speedX * spdMult; end
	
	Defines.jumpheight = 15*math.max((spdMult-0.8)/0.2,0) + 5
	Defines.jumpheight_bounce = Defines.jumpheight;
	
	for _,v in ipairs(NPC.get()) do
		v.speedX = v.speedX * spdMult;
		if(v:mem(0x136, FIELD_WORD) == -1 and math.abs(v.speedX) < 0.1) then
			v.speedX = 0;
			v:mem(0x136, FIELD_WORD,0);
		end
	end
	
	npcconfig[1].speed = spdMult;
	npcconfig[109].speed = spdMult;
	npcconfig[117].speed = spdMult;
	
	for k,v in ipairs(birdspawns) do
		if(maxx > v.x+400) then
			table.insert(birds,v);
			table.remove(birdspawns,k);
			Audio.playSFX("birds2.ogg");
		end
	end
end

function onHUDDraw()
	for k,v in ipairs(birds) do
		DrawBird(v.x,v.y,v.frame);
		v.x = v.x + v.speedX;
		v.y = v.y - v.speedY;
		v.speedX = v.speedX*0.99;
		if(v.flap > 0) then
			v.flapTime = v.flapTime-1;
			if(v.flapTime == 0) then
				v.flap = v.flap - 1;
				v.frame = 1;
			end
			if(v.flapTime < -3) then
				v.frame = 0;
				v.flapTime = 5;
			end
		end
		if(v.y < -200704) then
			table.remove(birds,k);
		end
	end

	local cx = Camera.get()[1].x;
	for _,v in ipairs(trees) do
		Graphics.drawImageWP(treetypes[v[1]], v[2] - ((cx+199968)*parallaxFactor), 60, 0.6, 0.899)
	end
	
	if(snowOffset == 0 and maxx > -191840) then
		snowStart = -191840;
		snowEnd = -190000;
		snowOffset = 1;
	end
	
	if(snowOffset == 1 and maxx > -187460) then
		snowStart = -187460;
		snowEnd = -185504;
		snowOffset = 2
	end
	
	if(snowOffset == 2 and Level.winState() == 0 and maxx > -185920) then
		Level.winState(1);
		Audio.SeizeStream(0);
		Audio.MusicStopFadeOut(26000);
		Misc.npcToCoins()
	end
	
	snowStr = snowOffset + math.min(1,(maxx-(snowStart))/((snowEnd-snowStart)))
	
	if(snowStr > 2) then
		Graphics.drawImageWP(snows[3], 0, 0, math.min(snowStr - 2,1), 0.9)
	end
	
	if(snowStr > 1) then
		local spd = math.max(0,((maxx + 190000)/(-185504+190000)*0.732)) + 2.17;
		Graphics.drawImageWP(snows[2], -(spd*snowTimer%800), spd*snowTimer%600, math.min(snowStr - 1,1), 0.9)
		Graphics.drawImageWP(snows[2], 800-(spd*snowTimer%800), spd*snowTimer%600, math.min(snowStr - 1,1), 0.9)
		Graphics.drawImageWP(snows[2], -(spd*snowTimer%800), spd*snowTimer%600 - 600, math.min(snowStr - 1,1), 0.9)
		Graphics.drawImageWP(snows[2], 800-(spd*snowTimer%800), spd*snowTimer%600 - 600, math.min(snowStr - 1,1), 0.9)
	end
	
	if(snowStr > 0) then
		Graphics.drawImageWP(snows[1], -(snowTimer%800), snowTimer%600, math.min(snowStr,1), 0.9)
		Graphics.drawImageWP(snows[1], 800-(snowTimer%800), snowTimer%600, math.min(snowStr,1), 0.9)
		Graphics.drawImageWP(snows[1], -(snowTimer%800), snowTimer%600 - 600, math.min(snowStr,1), 0.9)
		Graphics.drawImageWP(snows[1], 800-(snowTimer%800), snowTimer%600 - 600, math.min(snowStr,1), 0.9)
		
		snowTimer = snowTimer + 1;
	end
end