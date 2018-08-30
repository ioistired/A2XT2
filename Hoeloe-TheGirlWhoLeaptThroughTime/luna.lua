local scene = API.load("a2xt_scene");
local actors = API.load("a2xt_actor");
local eventu = API.load("eventu");
local message = API.load("a2xt_message");
local cman = API.load("cameraman")

local introText = Graphics.loadImage("intro.png")
local startingroom = Graphics.loadImage("startroom.png")
local noise = Graphics.loadImage("noise.png")

local earthquakeset = 0;

local startinglayer;
local startroomvisible = true;
local startroomtime = 0;

local dissolveShader = Shader();

local function cor_intro()

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
	eventu.waitSeconds(0.25);
	cam.targets={}
	cam:Queue{time=1.5, zoom=1, x=camx, y=camy}
	Audio.MusicStopFadeOut(500);
	ACTOR_SHEATH:Pose("shocked")
	eventu.waitSeconds(1);
	ACTOR_SHEATH:Pose("slash")
	ACTOR_SHEATH.gfx.speed = 0;
	
	eventu.waitSeconds(0.5);
	
	startinglayer:hide(true);
	startroomvisible = false;
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
	scene.endScene();
end


function onStart()
	dissolveShader:compileFromFile(nil, "dissolve.frag")
	startinglayer = Layer.get("StartingRoom");

	player:transform(CHARACTER_SHEATH);
	player.powerup = 2;
	

	Graphics.drawScreen{color = Color.black, priority = 6};
	scene.startScene{scene=cor_intro}
end

function onTick()
	if(earthquakeset > 0) then
		Defines.earthquake=earthquakeset;
	end
end

function onCameraDraw()
	if(startroomvisible) then
		Graphics.drawScreen{color=Color.black, priority = -99}
	elseif(startroomtime > 0) then
		Graphics.drawScreen{texture=startingroom, priority = -26, shader = dissolveShader, uniforms = {alpha = 1 - startroomtime/600, noise = noise}}
	end
end