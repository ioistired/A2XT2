local leveldata = API.load("a2xt_leveldata")
local scene = API.load("a2xt_scene")

local eventu = API.load("eventu")
local cman = API.load("cameraman")
local animatx = API.load("animatx")

local costumes = API.load("a2xt_costumes");
local actors = API.load("a2xt_actor");
local pause = API.load("a2xt_pause");
local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local textblox = API.load("textblox");
local checkpoints = API.load("checkpoints");

local playerManager = API.load("playerManager")

local broadsword = API.load("Characters/unclebroadsword")

local audioMaster = API.load("audioMaster");

local panim = API.load("playerAnim");


local introText = Graphics.loadImage("introtext.png");
local title = Graphics.loadImage("title.png");
local ep2 = Graphics.loadImage("episode2.png");
local starfield = Graphics.loadImage("starfield.png");
local previously = Graphics.loadImage("previously.png");
local meanwhile = Graphics.loadImage("meanwhile.png");
local unrelated = Graphics.loadImage("unrelated.png");

local flashback1 = {frames = 15, img = Graphics.loadImage("introflashback1.png"), delay = 4, [1] = 256, rows = 5, cols = 3, sfx = {[1] = "message.ogg", [8] = "boxbreak.ogg", [15] = "message.ogg"}};
local flashback2 = {frames = 28, img = Graphics.loadImage("introflashback2.png"), delay = 4, [19] = 256, rows = 7, cols = 4, offset = -100, sfx = {[2] = "dash.ogg", [19] = "message.ogg", [20] = "jump.ogg"}};
local flashback3 = {frames = 5, img = Graphics.loadImage("introflashback3.png"), delay = 256, rows = 3, cols = 2, sfx = {}};
for i = 1,5 do
	flashback3.sfx[i] = "message.ogg";
end

local everyoneHidesRoutine

local function cor_intro()
	playMusic(1)

	local pStates = Player.getTemplates()
	for  k,v in pairs(pStates)  do
		if  v.powerup == PLAYER_SMALL  then
			v.powerup = PLAYER_BIG
		end
	end

	-- Move the player to the proper section
	scene.setTint{color=0x000000FF}
	player.section = 1
	player.x = -179500
	player.y = -180200
	eventu.waitFrames(4)

	-- Initialize Actor objects for the krew
	actors.groundY = -180159
	ACTOR_DEMO:PlayerReplaceNPC()
	ACTOR_DEMO.direction = DIR_RIGHT

	actors.ToActors {ACTOR_DEMO, ACTOR_IRIS, ACTOR_KOOD, ACTOR_RAOCOW, ACTOR_PILY, ACTOR_SCIENCE, ACTOR_NEVADA, ACTOR_CALLEOCA, ACTOR_PAL}
	eventu.waitFrames(2)

	ACTOR_SCIENCE : Pose ("sad")
	ACTOR_PAL : Pose ("dig")
	ACTOR_CALLEOCA : Pose ("happy")


	-- Start panning and fading in
	local cam = cman.playerCam[1]
	cam.targets={}
	cam.x = -180400
	cam.y = -180225
	cam:Queue{time=8, zoom=2, x=-178960}--, easeBoth=cman.EASE.QUAD, zoom=1.25}
	scene.setTint{color=0x00000000, time=3}
	eventu.waitSeconds(8)


	-- Begin conversation
	ACTOR_KOOD : Emote("happy")
	eventu.waitSeconds(1)

	ACTOR_KOOD : Pose("victory")
	ACTOR_KOOD : Talk{text="Man, isn't it great how we defeated Science and saved the universe and nothing bad happened at all ever?"}
	eventu.waitSeconds(0.5)
	ACTOR_IRIS.direction = DIR_RIGHT
	message.waitMessageEnd()
	eventu.waitSeconds(1)

	ACTOR_IRIS.direction = DIR_LEFT
	ACTOR_IRIS : Pose ("sad")
	ACTOR_IRIS : Talk{text="Somebody remind me why we invited Kood again?"}
	message.waitMessageEnd()

	ACTOR_KOOD.direction = DIR_LEFT
	ACTOR_KOOD : Pose("idle")
	ACTOR_DEMO : Talk{text="<i>We<i/> didn't, Pily did."}
	message.waitMessageEnd()

	cam : Queue{time=0.5, x=-178900}
	eventu.waitSeconds(1.5)

	ACTOR_IRIS : Pose ("upset")
	ACTOR_IRIS : Talk{text="I swear, I just don't get what she sees in him..."}
	message.waitMessageEnd()

	ACTOR_KOOD : Pose ("sad")
	ACTOR_KOOD : Emote("sweat")
	ACTOR_PILY : Emote("angry")
	ACTOR_RAOCOW : Walk(-3)
	eventu.waitSeconds(1.6)

	ACTOR_RAOCOW : StopWalking()
	eventu.waitSeconds(0.5)
	ACTOR_RAOCOW.direction = DIR_RIGHT
	eventu.waitSeconds(0.5)

	ACTOR_RAOCOW.direction = DIR_LEFT
	ACTOR_DEMO.direction = DIR_RIGHT
	ACTOR_IRIS.direction = DIR_RIGHT
	ACTOR_IRIS : Pose ("idle")
	ACTOR_KOOD : Pose ("idle")
	ACTOR_RAOCOW : Pose ("hold")
	ACTOR_RAOCOW : Talk{text="Hey, everyone!  We should play hide and seek!<page>The winner gets the last chicken wing!"}
	message.waitMessagePage(nil, 2)

	ACTOR_RAOCOW : Pose ("idle")
	message.waitMessageEnd()

	eventu.waitSeconds(1)

	ACTOR_IRIS : Talk{text="...<page>Fine, it's better than sitting around and listening to the turtle.<page>You go first, Sis."}
	message.waitMessagePage(nil, 2)

	ACTOR_IRIS : Pose ("sad")
	message.waitMessagePage(nil, 3)

	ACTOR_KOOD.direction = DIR_LEFT
	ACTOR_KOOD : Emote("sad")
	ACTOR_KOOD : Pose("shocked")

	ACTOR_IRIS.direction = DIR_LEFT
	ACTOR_IRIS : Pose ("idle")
	message.waitMessageEnd()

	eventu.run(function ()
		while  (true)  do
			player.speedY = -2
			eventu.waitFrames(0)
		end
	end)
	ACTOR_KOOD : Pose("sad")
	ACTOR_DEMO : Talk{text="Uh, okay then."}
	message.waitMessageEnd()

	Audio.SeizeStream(-1)
	Audio.MusicStopFadeOut(2000)

	ACTOR_DEMO : Pose("sad")
	eventu.waitSeconds(0.5)

	ACTOR_RAOCOW : Walk (4)
	eventu.waitSeconds(0.25)


	-- Everyone runs to go hide
	_,everyoneHidesRoutine = eventu.run(function ()
		ACTOR_PILY : Walk (4)
		eventu.waitSeconds(0.25)

		ACTOR_IRIS : Walk (4)
		eventu.waitSeconds(0.25)

		ACTOR_CALLEOCA.x = ACTOR_DEMO.x - 96
		ACTOR_SCIENCE.x = ACTOR_DEMO.x - 96
		ACTOR_NEVADA.x = ACTOR_DEMO.x - 96
		ACTOR_PAL.x = ACTOR_DEMO.x - 96

		ACTOR_SCIENCE : Walk (4)
		eventu.waitSeconds(0.5)

		ACTOR_NEVADA : Walk (4)

		eventu.waitSeconds(0.25)

		ACTOR_PAL : Walk (4)
		eventu.waitSeconds(0.5)

		ACTOR_CALLEOCA : Walk (4)
		eventu.waitSeconds(0.5)

		ACTOR_KOOD : Pose("idle")
		eventu.waitSeconds(0.25)
		ACTOR_KOOD : Pose("shocked")
		eventu.waitSeconds(0.5)
		ACTOR_KOOD.direction = DIR_RIGHT
		eventu.waitSeconds(0.5)
		ACTOR_KOOD.direction = DIR_LEFT
		eventu.waitSeconds(0.5)
		ACTOR_KOOD : Walk(5)

	end)

	-- Demo starts counting down
	--cam:Queue{delay=2,time=2, x=ACTOR_DEMO.x}
	for  i=10,1,-1  do
		local numString

		numString = tostring(i).."..."

		if  i <= 5  then
			numString = tostring(i).."."
			cam.zoom = cam.zoom+0.25
			cam.x=ACTOR_DEMO.x
			cam.y=ACTOR_DEMO.y-36
		end
		if  i <= 3  then
			Audio.playSFX("dramahit"..tostring(i)..".ogg")
			numString = "<shake box>"..tostring(i).."!"
			cam.zoom = cam.zoom+2*(4-i)
		end
		if  i == 1  then
			numString = "<shake screen><shake box>"..tostring(i).."!"
		end

		ACTOR_DEMO : Talk{closeWith="auto", finishDelay=20, text=numString}--, instant=true}
		eventu.waitSeconds(1)
	end
	eventu.waitSeconds(1)

	Defines.earthquake = 50
	cam.zoom = cam.zoom+8
	ACTOR_DEMO : Pose ("pipe")
	Audio.playSFX("dramaslam.ogg")
	message.showMessageBox {screenSpace=true, x=600,y=500, type="bubble", text="<shake screen><tremble 0.25><color orange>Ready or not, here I come!"}--, instant=true}
	message.waitMessageEnd()

	-- Start tutorial level 1
	eventu.waitSeconds(1)
	SaveData.currentTutorial = "Pyro-Tutorial Area Region Place Zone.lvl"
	leveldata.LoadLevel(SaveData.currentTutorial)
	scene.endScene()
end

local function skip_intro()
	
end

local function doFlashback(obj, t)
	local frame = 1;
	
	if(obj.sfx and t == 1 and obj.sfx[1]) then
		SFX.play(obj.sfx[1]);
	end
	
	local timer = 0;
	while(timer < t) do
		if(obj[frame]) then
			timer = timer + obj[frame];
		else
			timer = timer + obj.delay;
		end
		if(timer <= t) then
			frame = frame + 1;
			if(obj.sfx and t == timer and obj.sfx[frame]) then
				SFX.play(obj.sfx[frame]);
			end
		end
	end
	
	frame = math.min(frame, obj.frames);
	
	local col = (frame-1)%obj.cols;
	local row = math.floor((frame-1)/obj.cols);
	
	local tx1, tx2 = col/obj.cols, (col+1)/obj.cols;
	local ty1, ty2 = row/obj.rows, (row+1)/obj.rows;
	
	obj.offset = obj.offset or 0;
	
	Graphics.glDraw{vertexCoords = {0,obj.offset,800,obj.offset,800,obj.offset+600,0,obj.offset+600}, primitive = Graphics.GL_TRIANGLE_FAN, texture = obj.img,
					textureCoords = {tx1,ty1,tx2,ty1,tx2,ty2,tx1,ty2}}
	Graphics.drawBox{color=Color.black, x = 0, y = 0, width = 800, height = 100}
	Graphics.drawBox{color=Color.black, x = 0, y = 600-100, width = 800, height = 100}
end

local function cor_titles()
	Graphics.activateHud(false);
	Audio.resetMciSections()
	
	eventu.waitSeconds(1);
	
	local introtextalpha = 0;
	local t = 0;
	
	while(t < 256) do
		t = t+1;
		
		if(t < 32) then
			introtextalpha = introtextalpha + 1/32;
		elseif(t > 256-32) then
			introtextalpha = introtextalpha - 1/32;
		end
		
		Graphics.drawScreen{texture=introText, color = {1,1,1,introtextalpha}, priority = 0};
		
		eventu.waitFrames(0);
	end
	
	eventu.waitSeconds(2);
	
	t = 0;
	local titlescale = 1;
	local scrollwidth = 1;
	local scrollheight = 0.9;
	local scrollspeed = 1;
	local y = 0;
	
	while(t < 1152) do
	
		Graphics.drawScreen{texture=starfield, color = {1,1,1,0.5}, priority = 0};
		
		t = t+1;
		
		local w = 1920*titlescale;
		local h = 720*titlescale;
		local a = 1;
		if(t > 320) then
			a = (1-(t-320)/128);
			
			local a2 = 1;
			if(t > 1024) then
				a2 = 1 - (t-1024)/128;
			end
			
			local w2 = 1600*scrollwidth;
			local h2 = 600*scrollheight;
			y = y - scrollspeed;
			scrollspeed = scrollspeed*0.997;
			
			scrollwidth = scrollwidth * 0.998;
			scrollheight = scrollheight * 0.997;
			
			Graphics.drawBox{x = 400-w2*0.5, y = 600+y, texture=ep2, color = {1,1,1,a2}, width = w2, height = h2, priority=10};
			
			
		end
		Graphics.drawBox{x = 400-w*0.5, y = 250-h*0.5, texture=title, color = {1,1,1,a}, width = w, height = h, priority=10};
		
		titlescale = titlescale * 0.995;
		
		eventu.waitFrames(0);
	end
	
	t = 0;
	while(t < 64) do
		t = t+1;
		
		Graphics.drawScreen{texture=starfield, color = {1,1,1,0.5*(64-t)/64}, priority = 0};
		eventu.waitFrames(0);
	end
	
	SFX.play("previously.ogg");
	t = 0;
	while(t < 256) do
		t = t+1;
		
		local a = 1;
		if(t > 256-32) then
			a = 1- (t+32-256)/32;
		end
		
		Graphics.drawScreen{texture=previously, color = {1,1,1,a}, priority = 0};
		eventu.waitFrames(0);
	end
	
	eventu.waitSeconds(0.5);
	
	Audio.MusicOpen("siblings.ogg")
	Audio.MusicPlay()
	
	t = 0;
	while(t < 564) do
		t = t+1;
		doFlashback(flashback1, t);
		eventu.waitFrames(0);
	end
	
	t = 0;
	while(t < 108+256) do
		t = t+1;
		doFlashback(flashback2, t);
		eventu.waitFrames(0);
	end
	
	t = 0;
	while(t < 1280 + 64) do
		t = t+1;
		doFlashback(flashback3, t);
		
		if(t == 1280) then
			Audio.MusicStopFadeOut(1500)
		end
		
		if(t > 1280) then
			Graphics.drawScreen{color = {0,0,0,(t-1280)/64}}
		end
		
		eventu.waitFrames(0);
	end
	
	eventu.waitSeconds(0.5);
	
	local img = meanwhile;
	
	for i = 1,2 do
		t = 0;
		while(t < 384) do
			t = t+1;
			local a = 1;
			
			if(t < 64) then
				a = t/64;
			elseif(t > 384-64) then
				a = 1-(t-384+64)/64;
			end
			
			Graphics.drawScreen{texture = img, color = {1,1,1,a}}
			
			eventu.waitFrames(0);
		end
	
		eventu.waitSeconds(0.5);
		img = unrelated;
	end
	
	scene.endScene()
	scene.startScene{scene=cor_intro, skip=skip_intro}
end

local function skip_titles()
	scene.inCutscene = false;
	scene.startScene{scene=cor_intro, skip=skip_intro}
end

local function cor_picnic()
	
end

local function skip_picnic()
	
end



local hubLevel = "hub.lvl"
function onStart()
	mem(0xB2572A,FIELD_BOOL,false)


	-- If the hub is unlocked, start there
	if  leveldata.Visited(hubLevel)  then
		leveldata.LoadLevel(hubLevel)

	-- else if the player is in world 1 or 2
	elseif  leveldata.GetWorldsUnlocked() > 0  then

		-- if the current SOW level is beaten, go to that submap
		if  leveldata.GetWorldsUnlocked() == leveldata.GetMapsUnlocked()  then
			Level.exit()

		-- else if the player is currently on a different SOW level, go to that one
		else
			mem(0xB2572A,FIELD_BOOL,true)
			leveldata.LoadLevel(leveldata.GetWorldStart(leveldata.GetWorldsUnlocked()))
		end

	-- Else if in the tutorial world
	elseif  SaveData.currentTutorial ~= nil  then
		mem(0xB2572A,FIELD_BOOL,true)
		leveldata.LoadLevel(SaveData.currentTutorial)

	-- else start the intro cutscene
	else
		scene.startScene{scene=cor_titles, skip=skip_titles, noletterbox=true}
	end
end
