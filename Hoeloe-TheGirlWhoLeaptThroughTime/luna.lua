local scene = API.load("a2xt_scene");
local actors = API.load("a2xt_actor");
local eventu = API.load("eventu");
local message = API.load("a2xt_message");
local cman = API.load("cameraman")

local checkpoints = API.load("checkpoints");
local colliders = API.load("colliders");
local particles = API.load("particles");

local introText = Graphics.loadImage("intro.png")
local startingroom = Graphics.loadImage("startroom.png")
local noise = Graphics.loadImage("noise.png")

local earthquakeset = 0;

local startinglayer;
local startroomvisible = true;
local startroomtime = 0;

local dissolveShader = Shader();
local portalbgShader = Shader();
local portalfgShader = Shader();

local backgrounds = {};

for i=1,13 do
	backgrounds[i] = Graphics.loadImage("bg-"..i..".png");
end

local tarpz = Graphics.loadImage("tarpzimg.png");

local cpintro = checkpoints.create{x=-199710--[[+17000]], y=-200232, section = 0}	

local function startMusic()
	Audio.MusicOpen("09 Copied City OST - Nier Automata.ogg");
	Audio.MusicPlay();
end

local function cor_intro()
	playMusic(1)
	local cam = cman.playerCam[1]
	cam.targets={}
	local camx = -200000+400
	local camy = -200600+300
	cam.x = camx;
	cam.y = camy;
	
	actors.groundY=-200194;
	actors.ToActors {ACTOR_SHEATH, ACTOR_SCIENCE}
	
	local introtextalpha = 0;
	local t = 0;
	
	while(t < 64) do
		Graphics.drawScreen{color = Color.black, priority = 0};
		t = t+1;
		eventu.waitFrames(0);
	end
	
	t = 0;
	
	while(t < 256) do
		t = t+1;
		
		if(t < 32) then
			introtextalpha = introtextalpha + 1/32;
		elseif(t > 256-32) then
			introtextalpha = introtextalpha - 1/32;
		end
		
		Graphics.drawScreen{color = Color.black, priority = 0};
		Graphics.drawScreen{texture=introText, color = {1,1,1,introtextalpha}, priority = 0};
		
		eventu.waitFrames(0);
	end
	
	local introtextalpha = 1;
	t = 0;
	
	while(t < 64) do
		introtextalpha = 1 - t/64
		Graphics.drawScreen{color = {0,0,0,introtextalpha}, priority = 0};
		t = t+1;
		eventu.waitFrames(0);
	end
	
	eventu.waitSeconds(1);
	
	
	ACTOR_SCIENCE : Talk{text="You are. the only hope."}	
	message.waitMessageEnd()
	
	eventu.waitSeconds(1);
	
	local a = Animation.spawn(13, ACTOR_SCIENCE.x, ACTOR_SCIENCE.y - 2*ACTOR_SCIENCE.height - 16);
	ACTOR_SCIENCE:BecomeNPC ():kill()
	SFX.play(22)
	
	eventu.waitSeconds(4);
	
	ACTOR_SHEATH.direction = DIR_RIGHT
	ACTOR_SHEATH:Pose("victory")
	
	Audio.MusicOpen("Escaping.ogg")
	Audio.MusicPlay();
	
	cam.zoom = 5;
	cam.x = ACTOR_SHEATH.x;
	cam.y = ACTOR_SHEATH.y - ACTOR_SHEATH.height + 16;
	eventu.waitFrames(2);
	
	ACTOR_SHEATH : Talk{text="WE DID IT! WE DEFEATED SCIENCE!"}	
	message.waitMessageEnd()
	eventu.waitSeconds(1);
	earthquakeset = 3;
	SFX.play("Earthquake.ogg");
	eventu.waitSeconds(0.25);
	cam.targets={}
	cam:Queue{time=1.5, zoom=1, x=camx, y=camy}
	Audio.MusicStopFadeOut(500);
	ACTOR_SHEATH:Pose("shocked")
	eventu.waitSeconds(1);
	ACTOR_SHEATH:Pose("slash")
	ACTOR_SHEATH.gfx.speed = 0;
	
	eventu.waitSeconds(0.5);
	Audio.MusicStop();
	
	startinglayer:hide(true);
	startroomvisible = false;
	SFX.play("Dissolve.ogg");
	startroomtime = 600;
	
	while(startroomtime > 0) do
		startroomtime = startroomtime-1;
		eventu.waitFrames(0);
	end
	
	t = 0;
	
	while(t < 64) do
		earthquakeset = 5*(1-t/64);
		t = t+1;
		eventu.waitFrames(0);
	end
	earthquakeset = 0;
	eventu.waitSeconds(1.5);
	ACTOR_SHEATH:Pose("idle")
	eventu.waitSeconds(1);
	ACTOR_SHEATH:BecomePlayer();
	cam:Reset();
	cpintro:collect();
	scene.endScene();
	playMusic(0)
end


function onStart()
	dissolveShader:compileFromFile(nil, "dissolve.frag")
	portalbgShader:compileFromFile(nil, "portalbg.frag")
	portalfgShader:compileFromFile(nil, "portalfg.frag")
	startinglayer = Layer.get("StartingRoom");

	player:transform(CHARACTER_SHEATH);
	player.powerup = 2;
	

	Graphics.drawScreen{color = Color.black, priority = 6};
	
	if(cpintro.collected) then
		startinglayer:hide(true);
		startroomvisible = false;
		ACTOR_SHEATH:BecomePlayer();
	else
		scene.startScene{scene=cor_intro}
	end
	
end

local firstSniffit = true;
local exitpos = vector.v2(-183136+150, -200096-150);
local exitBox = colliders.Circle(exitpos.x, exitpos.y, 50);
local exitsound = SFX.create{x=exitpos.x,y=exitpos.y,falloffRadius=800,sound=Misc.resolveFile("Portal.ogg")}
local exitParticles = particles.Emitter(exitpos.x, exitpos.y, Misc.resolveFile("p_portal.ini"), 1);
local endLevel = -1;

function onTick()
	if(earthquakeset > 0) then
		Defines.earthquake=earthquakeset;
	end
	
	if(firstSniffit) then
		for _,v in ipairs(NPC.get(131)) do
			if(v:mem(0x12A, FIELD_WORD) >= 180 and v.ai1 < 100) then
				v.ai1 = 100;
				firstSniffit = false;
			end
		end
	end
	
	if(endLevel == -1 and colliders.collide(player,exitBox)) then
		endLevel = 256;
		Audio.MusicStopFadeOut(4000);
	end
	
	if(endLevel > 0) then
		endLevel = endLevel-1;
		player.speedX = (exitpos.x-(player.x+player.width*0.5))*0.02;
		player.speedY = (exitpos.y-(player.y+player.height*0.5))*0.02;
		exitsound.volume = endLevel/256;
		if(endLevel == 1) then
			Level.winState(2);
			Level.exit();
		end
	end
end

local function drawBG(id, x, y, width, height, parallax)
		local cx = Camera.get()[1].x;
		
		x = x+parallax*(cx+800-x);
		
		if(x < cx+800 and x > cx-width) then
		
			local scale = (width/backgrounds[id].width)/(height/backgrounds[id].height);
			
			local d = (cx-x+800)/(800+width);
			
			Graphics.drawBox{x=x,y=y,width=width,height=height,texture=backgrounds[id],shader=portalbgShader, 
							uniforms =	{
											cycle=50+25*math.sin(lunatime.tick()/100),
											widthScale = scale,
											parallax = d*(1-scale)
										},
							sceneCoords = true,
							priority = -96
						}
		end
end

function onCameraDraw()
	if(startroomvisible) then
		Graphics.drawScreen{color=Color.black, priority = -99}
	elseif(startroomtime > 0) then
		Graphics.drawScreen{texture=startingroom, priority = -26, shader = dissolveShader, uniforms = {alpha = 1 - startroomtime/600, noise = noise}}
	end
	
	drawBG(2, -198832, -200384-150, 600, 300, 0.4)
	drawBG(9, -197088-200, -200320-100, 600, 300, 0.6)
	drawBG(6, -194880, -200384-150, 800, 400, 0.15)
	drawBG(12, -193472-600, -200416-200, 600, 300, 0.3)
	drawBG(7, -192928-400, -200384, 600, 300, 0.4)
	drawBG(13, -192480, -200576, 600, 300, 0.2)
	drawBG(5, -191392-200, -200512, 600, 300, 0.25)
	drawBG(3, -190752, -200448, 600, 300, 0.4)
	drawBG(1, -189344-200, -200544, 600, 300, 0.3)
	drawBG(8, -187680, -200480, 600, 300, 0.2)
	drawBG(10, -187680+700, -200480-120, 600, 300, 0.4)
	drawBG(11, -185600, -200448, 600, 300, 0.3)
	
	if(camera.x > exitpos.x - 200 - 800) then
		Graphics.drawBox{x = exitpos.x - 150, y=exitpos.y - 150, width=300, height=300, texture = tarpz, shader=portalfgShader, 
							uniforms =	{
											cycle=50+25*math.sin(lunatime.tick()/100)
										},
							sceneCoords = true,
							priority = -96}
		exitParticles:draw(-96, true);
	end
	
	if(endLevel > 0) then
		Graphics.drawScreen{color = {1,1,1,1 - (endLevel-64)/(256-64)}, priority = 6}
	end
end