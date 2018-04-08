local bossAPI = {};


local particles = API.load("particles");
local vectr = API.load("vectr");
local imagic = API.load("imagic");
local rng = API.load("rng");
local eventu = API.load("eventu");
local colliders = API.load("colliders");
local boss = API.load("a2xt_boss");
local pause = API.load("a2xt_pause");
local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local textblox = API.load("textblox");
local checkpoints = API.load("checkpoints");
local hermite = API.load("hermite");

local playerManager = API.load("playerManager")

local broadsword = API.load("Characters/unclebroadsword")

local audioMaster = API.load("audioMaster");

local panim = API.load("playerAnim");

boss.SuperTitle = "Maximillion"
boss.Name = "Pumpernickle"
boss.SubTitle = "Off Several Rockers"

boss.MaxHP = 100;

boss.TitleDisplayTime = 360;

local bossBegun = false;
local nomusic = false;
local Zero = vectr.v2(0,0);


local pumpernick = {};
pumpernick.x = -199344;
pumpernick.y = -200064;
pumpernick.up = vectr.up2;
pumpernick.left = {x = -199312, y = -200032, up = vectr.up2, leg = hermite.new{start = vectr.zero2, stop = vectr.zero2, startTan = vectr.zero2, stopTan = vectr.zero2}};
pumpernick.right = {x = -199378, y = -200032, up = vectr.up2, leg = hermite.new{start = vectr.zero2, stop = vectr.zero2, startTan = vectr.zero2, stopTan = vectr.zero2}};
pumpernick.dir = 1;
pumpernick.turncounter = 0;

pumpernick.flip = function()
	pumpernick.dir = -pumpernick.dir;
	local lx = pumpernick.left.x;
	local ly = pumpernick.left.y;
	local lu = pumpernick.left.up;
			
	pumpernick.left.x = pumpernick.right.x;
	pumpernick.left.y = pumpernick.right.y;
	pumpernick.left.up = pumpernick.right.up;
	pumpernick.right.x = lx;
	pumpernick.right.y = ly;
	pumpernick.right.up = lu;
end

pumpernick.turn = function()
	pumpernick.turncounter = 8;
end

local EYE_OPEN = 0;
local EYE_CLOSED = 1;
pumpernick.eye = { state = EYE_OPEN, timer = 0, target = player };

pumpernick.hitbox = colliders.Poly(0,0,{-32,20},{-54,-8},{-34,-24},{-12,-42},{12,-42},{34,-24},{50,-8},{24,20});
pumpernick.hitboxAngle = 0;

pumpernick.sprites = 
{
	body = Graphics.loadImage(Misc.resolveFile("pump_body.png")),
	feet = Graphics.loadImage(Misc.resolveFile("pump_feet.png")),
	leg = Graphics.loadImage(Misc.resolveFile("pump_leg.png")),
	eyeball = Graphics.loadImage(Misc.resolveFile("pump_eyeball.png")),
	pupil = Graphics.loadImage(Misc.resolveFile("pump_pupil.png")),
	eyelid = Graphics.loadImage(Misc.resolveFile("pump_eyelid.png")),
};

local flash = 0;


local events = {};

local bossSection = 20;

local cp = checkpoints.create{x = 0, y = 0, section = bossSection, actions = 
				function()
					player.x = Section(bossAPI.section).boundary.left + 128;
					player.y = Section(bossAPI.section).boundary.bottom - 32 - player.height;
					
					bossAPI.Begin(true); 
					
				end}
				


local bossmt = {};
function bossmt.__index(tbl, k)
	if(k == "section") then
		return bossSection;
	else
		return rawget(tbl, k);
	end
end
function bossmt.__newindex(tbl, k, v)
	if(k == "section") then
		bossSection = v;
		cp.section = v;
	else
		return rawset(tbl, k, v);
	end
end

setmetatable(bossAPI, bossmt)

function bossAPI.GetCheckpoint()
	return cp;
end


local tesseract = API.load("CORE/tesseract");
local backgrounds = API.load("CORE/core_bg");

local flip_stabletime = -6393693;
backgrounds.initFlipclocks(-flip_stabletime);
backgrounds.colour = Color.lightblue;
backgrounds.flipsilent = true;


local bgwindow = Graphics.loadImage("window.png");

--local core_audio = audioMaster.Create{sound="core_active2.ogg", x = 0, y = 0, type = audioMaster.SOURCE_POINT, falloffRadius = 800, volume = 0, tags = {"COREBG"}};

local tess = tesseract.Create(400,300,32);
tess.color = Color.lightblue;

tess.rotationXYZ.x = math.rad(45);
tess.rotationXYZ.y = math.rad(50);

--[[
tess.rotationXYZ.x = rng.random(0,2*math.pi);
tess.rotationXYZ.z = rng.random(0,2*math.pi);
tess.rotationW.x = rng.random(0,2*math.pi);
tess.rotationW.y = rng.random(0,2*math.pi);
tess.rotationW.z = rng.random(0,2*math.pi);]]

local tess_rotspdxyz = vectr.v3(0, 0.01, 0);
local tess_rotspdw = vectr.v3(0,0,0.004)
local tess_spdmult = 3;

local starttime = 0;

function bossAPI.Begin(fromCheckpoint)
	if(not bossBegun) then
		registerEvent(bossAPI, "onTick");
		registerEvent(bossAPI, "onDraw");
		registerEvent(bossAPI, "onCameraUpdate");
		
		bossBegun = true;
		
		Audio.SeizeStream(bossAPI.section);
		Audio.MusicStop();
		
		nomusic = true;

		pause.StopMusic = true;
		
		events.InitBoss(fromCheckpoint);
	end
end

local musicList = {};
local audiotimer = 0;
local audioTimes = {68.672, 35.335, 13.154, 14.401, 85.829}

local function shuffleMusic()
	local t = table.ishuffle{2,3,4};
	table.insert(t, 1)
	table.insert(t, 1, 5)
	return t;
end

local function progressMusic()
	local n = musicList[#musicList];
	musicList[#musicList] = nil;
	if(#musicList == 0) then
		musicList = shuffleMusic();
	end
	Audio.MusicOpen(Misc.resolveFile("entropyelemental_"..n..".ogg"));
	Audio.MusicPlay();
	audiotimer = audioTimes[n];
end

local function StartBoss()
	musicList = shuffleMusic();
	progressMusic();
	
	nomusic = false;
	
	starttime = lunatime.time();
	boss.Start();
end

local function updateLegs()
	pumpernick.left.leg.start.x = pumpernick.left.x - pumpernick.left.up.x * 12;
	pumpernick.left.leg.start.y = pumpernick.left.y - pumpernick.left.up.y * 12;
	
	pumpernick.right.leg.start.x = pumpernick.right.x - pumpernick.right.up.x * 12;
	pumpernick.right.leg.start.y = pumpernick.right.y - pumpernick.right.up.y * 12;
	
	local p = vectr.v2(pumpernick.x, pumpernick.y) + pumpernick.up*12;
	
	local l,r = p,p;
	l = l + pumpernick.up:rotate(pumpernick.dir*-90)*38;
	r = r + pumpernick.up:rotate(pumpernick.dir*90)*32;
	
	pumpernick.left.leg.stop.x = l.x;
	pumpernick.left.leg.stop.y = l.y;
	
	pumpernick.right.leg.stop.x = r.x;
	pumpernick.right.leg.stop.y = r.y;
	
	local ltan = ((pumpernick.left.leg.stop - pumpernick.left.leg.start)%pumpernick.left.up).length * 0.5;
	local rtan = ((pumpernick.right.leg.stop - pumpernick.right.leg.start)%pumpernick.right.up).length * 0.5;
	
	pumpernick.left.leg.startTan = -pumpernick.left.up * ltan;
	pumpernick.left.leg.stopTan = -pumpernick.up * ltan;
	
	pumpernick.right.leg.startTan = -pumpernick.right.up * rtan;
	pumpernick.right.leg.stopTan = -pumpernick.up * rtan;
end

local function drawFromVector(up, pos, dir, sprite, priority, frame, frames)
	
	frames = frames or 1;
	frame = frame or 1;

	local r = up:rotate(dir*90) * sprite.width*0.5;
	local u = -up * sprite.height * 0.5 / frames;
	
	Graphics.glDraw {
						vertexCoords = 
						{
							(u-r).x+pos.x, (u-r).y+pos.y, 
							(u+r).x+pos.x, (u+r).y+pos.y, 
							(-u-r).x+pos.x, (-u-r).y+pos.y, 
							(r-u).x+pos.x, (r-u).y+pos.y
						},
						
						textureCoords = {0,(frame-1)/frames,1,(frame-1)/frames,0,frame/frames,1,frame/frames},
						primitive = Graphics.GL_TRIANGLE_STRIP,
						priority = priority,
						sceneCoords = true,
						texture = sprite
					}
end

local function drawLeg(leg, priority, flip)
	local ps = {};
	local txs = {};
	local l = leg.leg;
	local dir = l.startTan:normalise();
	local p = l.start;
	
	local t = 0;
	
	for i = 0, 50 do
		local r = dir:rotate(pumpernick.dir*90);
			
		table.insert(ps, p.x-r.x*32)
		table.insert(ps, p.y-r.y*32)
			
		table.insert(ps, p.x+r.x*32)
		table.insert(ps, p.y+r.y*32)
			
		if(not flip) then
			table.insert(txs, 1)
			table.insert(txs, t)
			table.insert(txs, 0)
			table.insert(txs, t)
		else
			table.insert(txs, 0)
			table.insert(txs, t)
			table.insert(txs, 1)
			table.insert(txs, t)
		end
		
		local p2 = l:eval((i+1)/50);
		dir = (p2-p):normalise();
		p = p2;
		
		t = 1-t;
	end
	
	Graphics.glDraw{vertexCoords = ps, textureCoords = txs, sceneCoords = true, texture = pumpernick.sprites.leg, priority = priority, primitive = Graphics.GL_TRIANGLE_STRIP}
	local d = pumpernick.dir;
	if(flip) then 
		d = -d;
	end
	local t = drawFromVector(leg.up, vectr.v2(leg.x, leg.y-6), d, pumpernick.sprites.feet, -45);
end

local function drawLegs()
	drawLeg(pumpernick.left, -45);
	drawLeg(pumpernick.right, -45, pumpernick.turncounter > 0);
end

local function drawBody()
	local eyepos = vectr.v2(pumpernick.x, pumpernick.y)-pumpernick.up*14;
	drawFromVector(pumpernick.up, eyepos, pumpernick.dir, pumpernick.sprites.eyeball, -45);
	
	local r = pumpernick.up:rotate(pumpernick.dir*90);
	
	if(pumpernick.turncounter > 0) then
		r = vectr.zero2;
	end
	local pupilpos = eyepos - r * 12 - pumpernick.up * 4;
	
	local t = vectr.v2(pumpernick.eye.target.x, pumpernick.eye.target.y) - pupilpos;
	
	t = t*0.1;
	
	local rangelimit = 8;
	if(t.sqrlength > rangelimit*rangelimit) then
		t = t:normalise()*rangelimit;
	end
	pupilpos = pupilpos+t;
	Graphics.drawImageToSceneWP(pumpernick.sprites.pupil, pupilpos.x-8, pupilpos.y-8, -45);
	
	local f = 1;
	if(pumpernick.turncounter > 0) then
		f = 2;
	end
	
	
	drawFromVector(pumpernick.up, vectr.v2(pumpernick.x, pumpernick.y), pumpernick.dir, pumpernick.sprites.body, -45, f, 2);
	drawFromVector(pumpernick.up, eyepos, pumpernick.dir, pumpernick.sprites.eyelid, -45, (f-1)*4 + 1 + (math.floor(pumpernick.eye.timer)), 8);
end

function bossAPI.onTick()
	tess.rotationXYZ = tess.rotationXYZ + tess_rotspdxyz*tess_spdmult;
	tess.rotationW = tess.rotationW + tess_rotspdw*tess_spdmult;
	
	backgrounds.flipnumber = lunatime.time()-flip_stabletime;
	
	if(boss.Active) then
		--Workaround for bug with music resuming erroneously when the window loses focus
		if(nomusic) then
			Audio.MusicStop();
		else
			if(Audio.MusicClock() >= audiotimer) then
				progressMusic();
			end
		end
	end
	
	--pumpernick.y = pumpernick.y - 0.5;
	
	local a = math.deg(math.atan2(pumpernick.up.y, pumpernick.up.x) - 1.5707963267949 --[[math.atan2(1, 0)]]);
	pumpernick.hitbox.x = pumpernick.x;
	pumpernick.hitbox.y = pumpernick.y;
	pumpernick.hitbox:Rotate(a-pumpernick.hitboxAngle);
	pumpernick.hitboxAngle = a;
	
	if(colliders.bounce(player, pumpernick.hitbox)) then
		colliders.bounceResponse(player);
	end
	
	if(pumpernick.turncounter > 0) then
		pumpernick.turncounter = pumpernick.turncounter-1;
		if(pumpernick.turncounter <= 0) then
			pumpernick.flip();
		end
	end
	
	local eyeblinktime = lunatime.toSeconds(8);
	if(pumpernick.eye.timer > 0 and pumpernick.eye.state == EYE_OPEN) then
		pumpernick.eye.timer = math.max(pumpernick.eye.timer - eyeblinktime,0);
	elseif(pumpernick.eye.timer < 3 and pumpernick.eye.state == EYE_CLOSED) then
		pumpernick.eye.timer = pumpernick.eye.timer + eyeblinktime;
	end
	
	updateLegs();
	
	if(flash > 0) then
		flash = flash - lunatime.toSeconds(0.75);
	end
end

local glasstarget = Graphics.CaptureBuffer(800,600);

local function drawReflection()

	glasstarget:clear(-90);
	
	local tx1,ty1 = panim.getFrame(player, true);
			
	local ps = PlayerSettings.get(playerManager.getCharacters()[player.character].base, player.powerup);
	local xOffset = ps:getSpriteOffsetX(tx1, ty1);
	local yOffset = ps:getSpriteOffsetY(tx1, ty1) + player:mem(0x10E,FIELD_WORD);
			
	tx1 = tx1*0.1;
	ty1 = ty1*0.1;
	local tx2,ty2 = tx1+0.1,ty1+0.1;
			
	local x = player.x+xOffset;
	local y = player.y+yOffset;
			
	Graphics.glDraw	{	
						vertexCoords = 	{x, y, x + 100, y, x + 100, y + 100, x, y + 100},
						textureCoords = {tx1, ty1, tx2, ty1, tx2, ty2, tx1, ty2},
						primitive = Graphics.GL_TRIANGLE_FAN,
						texture = Graphics.sprites[playerManager.getCharacters()[player.character].name][player.powerup].img,
						sceneCoords = true,
						priority = -85,
						target=glasstarget
					}
	Graphics.drawImageToSceneWP(bgwindow,Zero.x,Zero.y,-71);
end

local function DrawBG()
	local gametime = lunatime.time() - starttime;
	
	tess:Draw(-99,false,Color.lightblue);
	backgrounds.pulsetimer = lunatime.time();
	backgrounds.Draw(-99.9);
	
	--drawReflection();
	glasstarget:captureAt(0);
	
	Graphics.drawBox{texture=glasstarget,x=Zero.x+30,y=Zero.y,priority=-70,sceneCoords=true,w=740,h=580, color = {0.9,0.95,1,0.2}};
	Graphics.drawImageToSceneWP(bgwindow,Zero.x,Zero.y,-70);
end


local function DrawBoss()
	DrawBG();
	drawLegs();
	drawBody();
	
end

function bossAPI.onDraw()
	DrawBoss();
	
	if(flash > 0) then
		local c = Color.white;
		c.a = flash;
		Graphics.drawScreen{color = c}
	end
end

function bossAPI.onCameraUpdate()
	if(Zero ~= nil) then
		Camera.get()[1].x = Zero.x;
	end
end

----------------------------------------------------------------------

local subphases = {};
local current_phase = nil;

local cutscene = {};

local function abortSubphases()
	for k,v in pairs(subphases) do
		eventu.abort(v);
		subphases[k] = nil;
	end
end

local function abortAll()
	abortSubphases();
end

local function phase_idle()
	pumpernick.up = vectr.up2;
	while(true) do
		pumpernick.up = pumpernick.up:rotate(0.5*math.cos(lunatime.tick()/20));
		eventu.waitFrames(0);
	end
end


local function setPhase(phase, args)
	if(current_phase) then
		abortAll();
		eventu.abort(current_phase);
	end
	if(phase == nil) then
		phase = phase_idle;
		eventu.signal("PHASE")
	end
	
	local _,c = eventu.run(phase, args)
	current_phase = c;
end


local function waitAndDo(t, func)
	while(t > 0) do
		t = t-1;
		func();
		eventu.waitFrames(0);
	end
end

function cutscene.intro_checkpoint()
	setPhase();
	pumpernick.flip();
	
	local b = Section(bossAPI.section).boundary;
	b.left = Zero.x-64;
	Section(bossAPI.section).boundary = b;
	
	player.x = Zero.x-64;
	eventu.waitFrames(32);
	
	waitAndDo(36, function() 
		player.speedX = 3;
		player.direction = 1; 
	end);
	
	b.left = Zero.x;
	Section(bossAPI.section).boundary = b;
	
	scene.endScene();
	
	StartBoss();
end

function cutscene.intro()
	Audio.MusicOpen(Misc.resolveFile("music/a2xt-bonkers.ogg"));
	Audio.MusicPlay();
	setPhase();
	pumpernick.eye.target = vectr.v2(pumpernick.x + 100, pumpernick.y);
	
	local pump = {x = pumpernick.x-96, y = pumpernick.y-32, width = 64, height = 64};
	
	local b = Section(bossAPI.section).boundary;
	b.left = Zero.x-64;
	Section(bossAPI.section).boundary = b;
	
	player.x = Zero.x-64;
	eventu.waitFrames(32);
	
	waitAndDo(80, function() 
		player.speedX = 3;
		player.direction = 1; 
	end);
	
	local demo = {x = player.x+64, y = player.y, width = player.width, height = player.height};
	local iris = {x = player.x+32, y = player.y, width = player.width, height = player.height}
	local raocow = {x = player.x+0, y = player.y, width = player.width, height = player.height}
	local kood = {x = player.x-32, y = player.y, width = player.width, height = player.height}
	local sheath = {x = player.x-64, y = player.y, width = player.width, height = player.height}
	
	b.left = Zero.x;
	Section(bossAPI.section).boundary = b;
	
	eventu.waitFrames(64);
	
	pumpernick.turn();
	
	local t = 0;
	local bt = pumpernick.eye.target;
	waitAndDo(32, function() 
		pumpernick.eye.target = math.lerp(bt, vectr.v2(player.x, player.y), t);
		t = t + (1/32);
		eventu.waitFrames(0);
	end);
	
	pumpernick.eye.target = player;
	
	
	message.showMessageBox {target=pump, text="And here they are. The bipeds, here to ruin my fun.<page>Really, children, why must you resist? I'm sure if you gave entropy a try you'd love it!"}
	message.waitMessageEnd();
	message.showMessageBox {target=demo, text="Sorry, not interested."}
	message.waitMessageEnd();
	message.showMessageBox {target=iris, text="With a sales pitch like that, the product's probably pretty underwhelming."}
	message.waitMessageEnd();
	message.showMessageBox {target=kood, text="We've stopped at least, what, five other omnicidal maniacs already? So I dunno what makes you think you're so special!"}
	message.waitMessageEnd();
	message.showMessageBox {target=sheath, text="I forgot what we're talking about but, uh... what they said!"}
	message.waitMessageEnd();
	message.showMessageBox {target=raocow, text="Yeah, you big dumb space potato!"}
	message.waitMessageEnd();
	pumpernick.eye.state = EYE_CLOSED;
	eventu.waitFrames(96);
	pumpernick.eye.state = EYE_OPEN;
	eventu.waitFrames(16);
	message.showMessageBox {target=pump, text="Very well, then! Let's put some action to those words!<page>Show me your resolve, children! Prove to me you're truly the 'future of cyclops kind' that Augustus says you are!"}
	message.waitMessageEnd();
	
	Audio.MusicStopFadeOut(1000);
	eventu.waitFrames(64);
	
	scene.endScene();
	
	flash = 1;
	
	player.x = Zero.x+96;
	
	cp:collect();
	
	StartBoss();
end


function events.InitBoss(checkpoint)
	Zero.x = Section(bossAPI.section).boundary.left;
	Zero.y = Section(bossAPI.section).boundary.top;
	
	--[[
	core_audio.x = Zero.x+400;
	core_audio.y = Zero.y+300;
	]]
	
	if(checkpoint) then
		scene.startScene{scene=cutscene.intro_checkpoint, noletterbox=true}
	else
		scene.startScene{scene=cutscene.intro, noletterbox=true}
	end
end

return bossAPI;