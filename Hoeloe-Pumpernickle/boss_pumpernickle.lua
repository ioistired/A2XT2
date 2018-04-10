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
local ease = API.load("ext/easing");

local playerManager = API.load("playerManager")

local audioMaster = API.load("audioMaster");

local panim = API.load("playerAnim");

local DEBUG = false;

boss.SuperTitle = "Maximillion"
boss.Name = "Pumpernickle"
boss.SubTitle = "Off Several Rockers"

boss.MaxHP = 90;

boss.TitleDisplayTime = 360;

local bossBegun = false;
local nomusic = false;
local Zero = vectr.v2(0,0);

local pumpernick = {};
pumpernick.x = -199344;
pumpernick.y = -200064;
pumpernick.up = vectr.up2;

pumpernick.spd = vectr.zero2;
pumpernick.lastpos = vectr.v2(pumpernick.x, pumpernick.y);

local GROUNDBODY = -200064;
local hurt = false;
local iframes = 0;

local function getLegPos(x,y,u)
	if(x == nil) then
		x = pumpernick.x;
		y = pumpernick.y;
		u = pumpernick.up;
	elseif(u == nil) then
		u = y;
		y = x.y;
		x = x.x;
	end
	
	local c = vectr.v2(x,y)+u*32;
	local r = u:rotate(-90);
	local cl = c + r*32;
	local cr = c - r*34;
	if(pumpernick.dir == -1) then
		local d = cr;
		cr = cl;
		cl = d;
	end
		
	return cl.x, cl.y, cr.x, cr.y;
end

pumpernick.left = {x = -199312, y = -200032, up = vectr.up2, leg = hermite.new{start = vectr.zero2, stop = vectr.zero2, startTan = vectr.zero2, stopTan = vectr.zero2}, hitbox = colliders.Poly(0,0,{-16,0},{-16,-16},{16,-16},{16,0}), hitboxAngle = 0, hitboxActive = false};
pumpernick.right = {x = -199378, y = -200032, up = vectr.up2, leg = hermite.new{start = vectr.zero2, stop = vectr.zero2, startTan = vectr.zero2, stopTan = vectr.zero2}, hitbox = colliders.Poly(0,0,{-16,0},{-16,-16},{16,-16},{16,0}), hitboxAngle = 0, hitboxActive = false};

pumpernick.dir = 1;
pumpernick.turncounter = 0;

pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();

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

pumpernick.msg = {x=0,y=0,width=32,height=32}

pumpernick.spin = false;
pumpernick.spinframe = 0;
pumpernick.spinspeed = 1.25;
pumpernick.spincounter = 0;

pumpernick.rocket = false;
pumpernick.rocketframe = 0;
pumpernick.rocketspeed = 1.25;
pumpernick.rocketcounter = 0;


local EYE_OPEN = 0;
local EYE_CLOSED = 1;
pumpernick.eye = { state = EYE_OPEN, timer = 0, target = player };

pumpernick.hitbox = colliders.Poly(0,0,{-32,18},{-54,-8},{-30,-24},{-12,-38},{12,-38},{30,-24},{50,-8},{24,18});
pumpernick.hitboxAngle = 0;
pumpernick.hitboxActive = true;

local playerMomentum = 0;

pumpernick.sprites = 
{
	body = Graphics.loadImage(Misc.resolveFile("pump_body.png")),
	feet = Graphics.loadImage(Misc.resolveFile("pump_feet.png")),
	leg = Graphics.loadImage(Misc.resolveFile("pump_leg.png")),
	eyeball = Graphics.loadImage(Misc.resolveFile("pump_eyeball.png")),
	pupil = Graphics.loadImage(Misc.resolveFile("pump_pupil.png")),
	eyelid = Graphics.loadImage(Misc.resolveFile("pump_eyelid.png")),
	spin = Graphics.loadImage(Misc.resolveFile("pump_shell_spin.png")),
	spin_eyelid = Graphics.loadImage(Misc.resolveFile("pump_shell_spin_eyelid.png")),
	rocket = Graphics.loadImage(Misc.resolveFile("pump_shell_rocket.png")),
};

local bullets = {};

local bullet = { SHOCKWAVE = 0, MINISHOCK = 1 }

bullet.img = {}
bullet.img[bullet.SHOCKWAVE] = Graphics.loadImage(Misc.resolveFile("bullet_shockwave.png"));
bullet.img[bullet.MINISHOCK] = Graphics.loadImage(Misc.resolveFile("bullet_shockwave.png"));

local function makeBullet(x,y,typ,v)
	local b = {x=x, y=y, v=v, a=vectr.zero2, typ=typ, frametimer = 0, frametime = 8, frames = 1, frame = 1};
	if(typ == bullet.SHOCKWAVE) then
		b.frames = 4;
		b.width = 256;
		b.height = 256;
		b.frametime = 4;
		b.flip = v.x < 0;
		b.additive = true;
		local f = 1;
		if(b.flip) then
			f = -1;
		end
		b.hitbox = colliders.Tri(x,y,{f*110,74},{f*74,-44},{-f*54,74})
	elseif(typ == bullet.MINISHOCK) then
		b.frames = 4;
		b.width = 64;
		b.height = 64;
		b.frametime = 4;
		b.flip = v.x < 0;
		b.additive = true;
		local f = 1;
		if(b.flip) then
			f = -1;
		end
		b.hitbox = colliders.Tri(x,y,{f*27,18},{f*18,-11},{-f*13,18})
	end
	
	table.insert(bullets, b);
	return b;
end

local function drawBullet(b)
	local ft = (b.frame-1)/b.frames;
	local fb = (b.frame)/b.frames;
	local fx = 0;
	if(b.flip) then
		fx = 1;
	end
	local t = 	{	x = b.x-b.width*0.5, y = b.y - b.height*0.5, w = b.width, h = b.height, 
					textureCoords = {fx,ft,1-fx,ft,1-fx,fb,fx,fb}, 
					priority = -45, sceneCoords = true,
					texture = bullet.img[b.typ]
				}
	if(b.additive) then
		t.vertexColors = {1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0};
	end
	Graphics.drawBox(t);
end

local function updateBullet(b)
	b.x = b.x+b.v.x;
	b.y = b.y+b.v.y;
	b.v = b.v+b.a;
	
	b.hitbox.x = b.x;
	b.hitbox.y = b.y;
	
	if(colliders.collide(b.hitbox, player)) then
		player:harm();
	end
	
	if(b.x - b.width > Zero.x+800 or b.x + b.width < Zero.x
	or b.y - b.height > Zero.y+600 or b.y + b.height < Zero.y) then
		for i = 1,#bullets do
			if(bullets[i] == b) then
				table.remove(bullets, i);
				break;
			end
		end
	end
	
	b.frametimer = b.frametimer + 1;
	if(b.frametimer > b.frametime) then
		b.frame = (b.frame%b.frames)+1;
		b.frametimer = 0;
	end
end


local effects = {}

local effect = { WHIRL = 0 }

effect.img = {};
effect.img[effect.WHIRL] = Graphics.loadImage(Misc.resolveFile("effect_whirlwind.png"));

local function makeEffect(x,y,typ)
	local b = {x=x, y=y, typ=typ, frametimer = 0, frametime = 8, frames = 1, frame = 1, alpha = 1};
	if(typ == effect.WHIRL) then
		b.frames = 10;
		b.width = 192;
		b.height = 128;
		b.frametime = 2;
		b.foreground = true;
		b.looping = true;
	end
	
	b.kill = 	function(b)
					b.dead = true;
				end
	
	table.insert(effects, b);
	return b;
end

local function drawEffect(b)
	local ft = (b.frame-1)/b.frames;
	local fb = (b.frame)/b.frames;
	local fx = 0;
	if(b.flip) then
		fx = 1;
	end
	
	local p = -60;
	if(b.foreground) then
		p = -5;
	end
	
	local t = 	{	x = b.x-b.width*0.5, y = b.y - b.height*0.5, w = b.width, h = b.height, 
					textureCoords = {fx,ft,1-fx,ft,1-fx,fb,fx,fb}, 
					priority = p, sceneCoords = true,
					texture = effect.img[b.typ],
					color = {1,1,1,b.alpha}
				}
	if(b.additive) then
		t.vertexColors = {1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0};
	end
	Graphics.drawBox(t);
end

local function updateEffect(b)
	b.frametimer = b.frametimer + 1;
	if(b.frametimer > b.frametime) then
		b.frame = b.frame+1;
		if(b.frame > b.frames) then
			if(b.looping) then
				b.frame = 1;
			else
				b.dead = true;
			end
		end
		b.frametimer = 0;
	end
	
	if(b.dead) then
		for i = 1,#bullets do
			if(bullets[i] == b) then
				table.remove(bullets, i);
				break;
			end
		end
	end
end

local dustTrail = particles.Emitter(0,0,Misc.resolveFile("p_dust.ini"))
dustTrail.enabled = false;

local flash = 0;

local audio = {};
audio.hurt = Misc.resolveFile("pump_hurt.ogg")
audio.spin = Misc.resolveFile("pump_spin.ogg")
audio.rocket = Misc.resolveFile("pump_rocket.ogg")


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

local function doBounce(f)
	if(player:mem(0x13E, FIELD_WORD) == 0 and player:mem(0x122, FIELD_WORD) == 0 and colliders.bounce(player, pumpernick.hitbox)) then
		colliders.bounceResponse(player);
		if(f ~= nil) then
			f();
		end
		return true;
	end
	return false;
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
	Audio.MusicVolume(128);
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
	
	eventu.run(events.intro);
end

local function Sound(name, volume, tags)
	audioMaster.PlaySound{sound = name, loops = 1, volume = volume, tags = tags}
end

local function damage(damage, stun)
	boss.Damage(damage);
	if(stun == nil) then
		stun = damage*16 + 8;
	end
	if(stun > 0) then
		hurt = true;
		pumpernick.eye.state = EYE_CLOSED;
		eventu.setFrameTimer(stun, function() pumpernick.eye.state = EYE_OPEN; hurt = false; end);
	end
	--iframes = 64;
	--eyeHitstun = stun;
	Sound(audio.hurt);
	--Voice(audio.voice.hurt, 0.75);
end

local function updateHitbox(obj)
	local a = math.deg(math.atan2(obj.up.y, obj.up.x) - 1.5707963267949 --[[math.atan2(1, 0)]]);
	obj.hitbox.x = obj.x;
	obj.hitbox.y = obj.y;
	obj.hitbox:Rotate(a-obj.hitboxAngle);
	obj.hitboxAngle = a;
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
	
	updateHitbox(pumpernick.left);
	updateHitbox(pumpernick.right);
	
	if(DEBUG and pumpernick.left.hitboxActive) then
		pumpernick.left.hitbox:Draw();
	end
	if(DEBUG and pumpernick.right.hitboxActive) then
		pumpernick.right.hitbox:Draw();
	end
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
	
	if((l.start - l.stop).sqrlength >= 16) then
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
	end
	local d = pumpernick.dir;
	if(flip) then 
		d = -d;
	end
	local t = drawFromVector(leg.up, vectr.v2(leg.x, leg.y)-leg.up*6, d, pumpernick.sprites.feet, -45);
end

local function drawLegs()
	if(not pumpernick.spin and not pumpernick.rocket) then
		drawLeg(pumpernick.left, -45);
		drawLeg(pumpernick.right, -45, pumpernick.turncounter > 0);
	end
end

local function drawBody()
	local eyepos = vectr.v2(pumpernick.x, pumpernick.y)-pumpernick.up*14;
	if(not pumpernick.spin or pumpernick.eye.state == EYE_OPEN) then
		local eyeframe = 1;
		if(hurt) then
			eyeframe = 2;
		end
		
		drawFromVector(pumpernick.up, eyepos, pumpernick.dir, pumpernick.sprites.eyeball, -45, eyeframe, 2);
		
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
	end
	
	if(pumpernick.spin) then
		local f = pumpernick.spinframe + 1;
		drawFromVector(pumpernick.up, vectr.v2(pumpernick.x, pumpernick.y)-pumpernick.up*16, pumpernick.dir, pumpernick.sprites.spin, -45, f, 7);
		if(pumpernick.eye.state == EYE_CLOSED) then
			drawFromVector(pumpernick.up, eyepos, pumpernick.dir, pumpernick.sprites.spin_eyelid, -45, f, 7);
		end
	else
	
		local f = 1;
		if(pumpernick.rocket) then
			f = pumpernick.rocketframe + 1;
			drawFromVector(pumpernick.up, vectr.v2(pumpernick.x, pumpernick.y)-pumpernick.up*16, pumpernick.dir, pumpernick.sprites.rocket, -45, f, 6);
			f = 1;
		else
			if(pumpernick.turncounter > 0) then
				f = 2;
			end
			
			drawFromVector(pumpernick.up, vectr.v2(pumpernick.x, pumpernick.y), pumpernick.dir, pumpernick.sprites.body, -45, f, 2);
		end
		drawFromVector(pumpernick.up, eyepos, pumpernick.dir, pumpernick.sprites.eyelid, -45, (f-1)*4 + 1 + (math.floor(pumpernick.eye.timer)), 8);
	end
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
			Audio.MusicResume();
			if(Audio.MusicClock() >= audiotimer) then
				progressMusic();
			end
		end
	end
	
	--pumpernick.y = pumpernick.y - 0.5;
	
	updateHitbox(pumpernick);
	pumpernick.msg.x, pumpernick.msg.y = pumpernick.x-16,pumpernick.y-32;
	pumpernick.spd.x, pumpernick.spd.y = pumpernick.x-pumpernick.lastpos.x, pumpernick.y-pumpernick.lastpos.y;
	pumpernick.lastpos.x, pumpernick.lastpos.y = pumpernick.x, pumpernick.y;
	
	player:mem(0x138, FIELD_FLOAT, playerMomentum);
	
	local ma = 0.5;
	if(math.abs(playerMomentum) <= ma) then
		playerMomentum = 0;
	else
		playerMomentum = playerMomentum-math.sign(playerMomentum)*ma;
	end
	
	if(pumpernick.spin) then
		pumpernick.spincounter = pumpernick.spincounter + 1;
		if(pumpernick.spincounter > 10/pumpernick.spinspeed) then
			pumpernick.spinframe = pumpernick.spinframe+1;
			if(pumpernick.spinframe > 6) then
				pumpernick.spinframe = 1;
			end
			pumpernick.spincounter = 0;
		end
	elseif(pumpernick.rocket) then
		pumpernick.rocketcounter = pumpernick.rocketcounter + 1;
		if(pumpernick.rocketcounter > 10/pumpernick.rocketspeed) then
			pumpernick.rocketframe = pumpernick.rocketframe+1;
			if(pumpernick.rocketframe > 5) then
				pumpernick.rocketframe = 2;
			end
			pumpernick.rocketcounter = 0;
		end
	else
		pumpernick.spinframe = 0;
		pumpernick.rocketframe = 0;
	end
	
	if(DEBUG and pumpernick.hitboxActive) then
		pumpernick.hitbox:Draw();
	end
	
	if(pumpernick.hitboxActive) then
		doBounce(function() 
					if(pumpernick.eye.state == EYE_OPEN and pumpernick.eye.timer == 0) then
						damage(1);
					end
				end);
	end
	
	if(iframes > 0) then
		iframes = iframes-1;
	else
		if((pumpernick.left.hitboxActive and colliders.collide(pumpernick.left.hitbox, player)) or (pumpernick.right.hitboxActive and colliders.collide(pumpernick.right.hitbox, player))) then
			player:harm();
		end
	end
	
	if(pumpernick.turncounter > 0) then
		pumpernick.turncounter = pumpernick.turncounter-1;
		if(pumpernick.turncounter <= 0) then
			pumpernick.flip();
		end
	end
	
	local eyeblinktime = lunatime.toSeconds(12);
	if(pumpernick.eye.timer > 0 and pumpernick.eye.state == EYE_OPEN) then
		pumpernick.eye.timer = math.max(pumpernick.eye.timer - eyeblinktime,0);
	elseif(pumpernick.eye.timer < 3 and pumpernick.eye.state == EYE_CLOSED) then
		pumpernick.eye.timer = pumpernick.eye.timer + eyeblinktime;
	end
	
	for _,v in ipairs(bullets) do
		updateBullet(v);
	end
	
	for _,v in ipairs(effects) do
		updateEffect(v);
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
	
	for _,v in ipairs(bullets) do
		drawBullet(v);
	end
	for _,v in ipairs(effects) do
		drawEffect(v);
	end
	
	dustTrail:Draw(-60);
	
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

local currentBodyMove = nil;

local cutscene = {};

local function abortSubphases()
	for k,v in pairs(subphases) do
		eventu.abort(v);
		subphases[k] = nil;
	end
end

local function abortBodyMove()
	if(currentBodyMove ~= nil) then
		eventu.abort(currentBodyMove);
		eventu.signal("BODYMOVED")
		currentBodyMove = nil;
	end
end

local function abortAll()
	abortBodyMove();
	abortSubphases();
end

local function ease(t)
	return 0.5*(1-math.cos(t * math.pi));
end

local function moveAndRotateBody(t,x,y,u)
	abortBodyMove()
	if(u == nil) then
		u = y;
		y = x.y;
		x = x.x;
	end
	
	local startx = pumpernick.x;
	local starty = pumpernick.y;
	local startup = pumpernick.up;
	_, currentBodyMove = eventu.run( function()
					local dt = 0;
					while(dt <= 1) do
						dt = dt + 1/t;
						local t2 = ease(dt);
						pumpernick.x = math.lerp(startx, x, t2);
						pumpernick.y = math.lerp(starty, y, t2);
						pumpernick.up = math.lerp(startup, u, t2);
						eventu.waitFrames(0);
					end
					
					eventu.signal("BODYMOVED")
					currentBodyMove = nil;
				end)
end

local function moveBody(t,x,y)
	abortBodyMove()
	if(y == nil) then
		y = x.y;
		x = x.x;
	end
	
	local startx = pumpernick.x;
	local starty = pumpernick.y;
	_, currentBodyMove = eventu.run( function()
					local dt = 0;
					while(dt <= 1) do
						dt = dt + 1/t;
						local t2 = ease(dt);
						pumpernick.x = math.lerp(startx, x, t2);
						pumpernick.y = math.lerp(starty, y, t2);
						eventu.waitFrames(0);
					end
					
					eventu.signal("BODYMOVED")
					currentBodyMove = nil;
				end)
end

local function waitForBody()
	return eventu.waitSignal("BODYMOVED");
end

local function waitAndDo(t, func)
	local st = t;
	while(t > 0) do
		t = t-1;
		func(1-(t/st));
		eventu.waitFrames(0);
	end
end

local function phase_idle()
	pumpernick.up = vectr.up2;
	local t = 0;
	while(true) do
		pumpernick.up = pumpernick.up:rotate(0.4*math.cos(t/20));
		t = t+1;
		eventu.waitFrames(0);
	end
end

local function waitPhase()
	return eventu.waitSignal("PHASE")
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


local function phase_pogo()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	for i = 1,10 do
		local t = 0;
		local targ = pumpernick.dir * rng.random(120,240);
		
		if(pumpernick.turncounter > 0) then
			targ = -targ;
		end
			
		if(i == 10) then
			targ = (Zero.x + 400 + 256*pumpernick.dir) - pumpernick.x;
		end
		while(t < 10) do
			pumpernick.up = pumpernick.up:rotate(pumpernick.dir)
			t = t+1;
			eventu.waitFrames(0);
		end
		local totTime = 64;
		local g = 0.75;
		local v = vectr.v2(targ/totTime,g*totTime*0.5);
		t = 0;
		
		local stomped = false;
		
		while(t <= totTime) do
			local dir = pumpernick.dir;
			if(pumpernick.turncounter > 0) then
				dir = -dir;
			end
			pumpernick.x = pumpernick.x + v.x;
			pumpernick.y = pumpernick.y - v.y;
			pumpernick.up = vectr.up2:rotate((10 - 20*math.sin(5*(t/totTime)*math.pi/6))*dir)
			
			if((pumpernick.x < Zero.x + 64 and pumpernick.dir == -1) or (pumpernick.x > Zero.x+800-64 and pumpernick.dir == 1)) then
				v.x = -v.x;
				pumpernick.turn();
			end
			
			do
				local lx,ly,rx,ry = getLegPos();
				local legupl,legupr = pumpernick.up, pumpernick.up;
				local lrp = 0.25
				local spd = 16;
				if(t > totTime*0.5) then
					pumpernick.left.hitboxActive = true;
					pumpernick.right.hitboxActive = true;
					lrp = t/totTime;
					local x = (1-(2*(1-lrp)) - 0.464);
					spd = spd * (1 - 3.482*x*x);
					--y = 1 + (-sqrt3 - 7/4)(x + 3-2sqrt3)^2
					lx = lx + spd*v.x;
					rx = rx + spd*v.x;
					ly = math.min(ly - spd*v.y, GROUNDBODY+32);
					ry = math.min(ry - spd*v.y, GROUNDBODY+32);
					
					lrp = lrp*lrp;
					
					if(ly >= GROUNDBODY+32) then
						legupl = vectr.up2;
						if(not stomped) then
							Audio.playSFX(37);
							Defines.earthquake = 8;
							stomped = true;
						end
					end
					
					if(ry >= GROUNDBODY+32) then
						legupr = vectr.up2;
						if(not stomped) then
							Audio.playSFX(37);
							Defines.earthquake = 8;
							stomped = true;
						end
					end
					
				end
				pumpernick.left.x, pumpernick.left.y = math.lerp(pumpernick.left.x, lx, lrp), math.lerp(pumpernick.left.y, ly, lrp)
				pumpernick.right.x, pumpernick.right.y = math.lerp(pumpernick.right.x, rx, lrp), math.lerp(pumpernick.right.y, ry, lrp)
				pumpernick.left.up, pumpernick.right.up = legupl,legupr;
			end
			
			t = t+1;
			v.y = v.y-g;
			eventu.waitFrames(0);
		end
		pumpernick.left.hitboxActive = false;
		pumpernick.right.hitboxActive = false;
	end
	if((pumpernick.x < Zero.x + 400 and pumpernick.dir == -1) or (pumpernick.x > Zero.x + 400 and pumpernick.dir == 1)) then
		pumpernick.turn();
	end
	moveAndRotateBody(lunatime.toTicks(0.25), pumpernick.x, GROUNDBODY, vectr.up2);
	eventu.waitFrames(lunatime.toTicks(0.25));
	setPhase();
end

local function phase_pendulum()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	
	local targ = Zero.x + rng.random(256,800-256);
	
	moveBody(32, pumpernick.x, pumpernick.y + 5);
	waitForBody();
	
	eventu.waitFrames(32);
	
	local startx, starty = pumpernick.x, pumpernick.y;
	
	local lx,ly,rx,ry = getLegPos(targ, Zero.y + 24 + 32, -vectr.up2);
	local slx, sly = pumpernick.left.x, pumpernick.left.y;
	local srx, sry = pumpernick.right.x, pumpernick.right.y;
	
	local t = 0;
	local jumptime = 32;
	while(t <= jumptime) do
		local dt = t/jumptime;
		pumpernick.x = math.lerp(startx, targ, dt);
		pumpernick.y = math.lerp(starty, Zero.y + 24 + 32, dt);
		pumpernick.up = vectr.up2:rotate(pumpernick.dir*180*dt);
		
		pumpernick.left.x = math.lerp(slx, lx, dt)
		pumpernick.left.y = math.lerp(sly, ly, dt)
		pumpernick.left.up = vectr.up2:rotate(pumpernick.dir*180*dt);
		pumpernick.right.x = math.lerp(srx, rx, dt)
		pumpernick.right.y = math.lerp(sry, ry, dt)
		pumpernick.right.up = vectr.up2:rotate(pumpernick.dir*180*dt);
		
		t = t+1;
		eventu.waitFrames(0);
	end
	pumpernick.y = Zero.y + 24 + 32;
	pumpernick.up = -vectr.up2;
	
	moveBody(32, pumpernick.x, pumpernick.y - 5);
	waitForBody();
	
	t = 0;
	local falltime = 32;
	starty = pumpernick.y;
	local v = 0;
		
	pumpernick.hitboxActive = false;
	pumpernick.eye.state = EYE_CLOSED;
	
	local targy = GROUNDBODY + 8;
	local g = 2*(targy - starty)/(falltime*falltime);
	while (t < falltime) do
		local dt = t/falltime;
		pumpernick.y = math.lerp(starty, targy, dt*dt*dt);
		v = v + g;
		
		if(colliders.collide(player, pumpernick.hitbox)) then
			player:harm();
		end
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	pumpernick.y = targy;
	Audio.playSFX(37);
	Audio.playSFX(42);
	Defines.earthquake = 24;
	
	makeBullet(pumpernick.x-32, GROUNDBODY-32, bullet.SHOCKWAVE, 6*vectr.right2);
	makeBullet(pumpernick.x+32, GROUNDBODY-32, bullet.SHOCKWAVE, -6*vectr.right2);
	
	falltime = 8;
	t = 0;
	while (t < falltime) do
		local dt = t/falltime;
		pumpernick.y = pumpernick.y - math.lerp(2,0,dt);
		
		if(colliders.collide(player, pumpernick.hitbox)) then
			player:harm();
		end
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	startx = pumpernick.x;
	local swing = vectr.v2(0, pumpernick.y-starty);
	local dist = swing.length;
	
	t = 0;
	local swingtime = 384;
	
	local offset = 0;
	if(rng.randomInt(1) == 1) then
		offset = math.pi;
	end
	local lastxsign = 0;
	
	local hits = 0;
	local legl = pumpernick.left;
	local legr = pumpernick.right;
	if(legl.x > legr.x) then
		legl = pumpernick.right;
		legr = pumpernick.left;
	end
	
	local legltarget = legl.x;
	local legrtarget = legr.x;
	
	local fall = false;
	local swingspd = vectr.zero2;
	local inv = 0;
	while(true) do
		local dt = t/swingtime;
		pumpernick.x = startx+swing.x;
		pumpernick.y = starty+swing.y;
		pumpernick.up = -swing:normalise();
		
		legl.x = math.lerp(legl.x, legltarget, 0.5);
		legr.x = math.lerp(legr.x, legrtarget, 0.5);
		
		if(lastxsign == 0 and (pumpernick.x > Zero.x + 800 - 32 or pumpernick.x < Zero.x + 32)) then
			local x = (offset + t/64)%(2*math.pi)
			if(x < math.pi*0.5) then
				x = math.pi-2*x;
			elseif(x < 3*math.pi*0.5) then
				x = 3*math.pi-2*x;
			else --x < 2pi
				x = 5*math.pi-2*x;
			end
			offset = offset + x;
			lastxsign = math.sign(swing.x);
		end
		local lastswing = swing;
		swing = vectr.up2:rotate(40*math.sin(offset + t/64))*dist;
		swingspd = swing-lastswing;
		
		if(lastxsign ~= 0 and math.sign(swing.x) ~= lastxsign) then
			lastxsign = 0;
		end
		
		if(inv > 0) then
			inv = inv-1;
		end
		
		local breaker = false;
		if(not doBounce(
			function()
				inv = 8;
				hits = hits+1;
				legltarget = legltarget - 32;
				legrtarget = legrtarget + 32;
				if(hits >= 3) then
					fall = true;
					breaker = true;
				end
			end)
		and inv <= 0 and colliders.collide(player, pumpernick.hitbox)) then
			player:harm();
		end
		if(breaker) then 
			break 
		end;
		
		if(t >= swingtime) then
			if(swingspd.y < -1.7) then
				break;
			end
		end
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	if(not fall) then
		local v = swingspd;
		local s = GROUNDBODY-pumpernick.y;
		local g = 0.1
		falltime = (math.sqrt(2*g*s+v.y*v.y))/(g);
		t = 0;
		local startup = pumpernick.up;
		local startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
		local startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
		pumpernick.eye.state = EYE_OPEN;
		while(t <= falltime) do
			local dt = t/falltime;
			pumpernick.up = math.lerp(startup, vectr.up2, dt):normalise();
			pumpernick.x = math.clamp(pumpernick.x + v.x, Zero.x+128, Zero.x+800-128);
			pumpernick.y = pumpernick.y + v.y;
			if(pumpernick.y > GROUNDBODY) then
				pumpernick.y = GROUNDBODY;
			end
			
			v.y = v.y + g;
			
			local lx,ly,rx,ry = getLegPos();
			
			pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, dt), math.lerp(startl.y, ly, dt)
			pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, dt), math.lerp(startr.y, ry, dt)
			pumpernick.left.up, pumpernick.right.up = -vectr.up2:rotate(180*dt),-vectr.up2:rotate(180*dt)
			
			v.y = v.y + g;
			
			if(colliders.collide(player, pumpernick.hitbox)) then
				player:harm();
			end
		
			t = t+1;
			eventu.waitFrames(0);
		end
	
		pumpernick.hitboxActive = true;
		pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();
		pumpernick.left.up, pumpernick.right.up = vectr.up2, vectr.up2;
	else
		--[[
		
		local hovertime = 64;
		t = 0;
		pumpernick.eye.state = EYE_OPEN;
		
		local startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
		local startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
			
		local lx,ly,rx,ry = getLegPos();
		while(t < hovertime) do
			local dt = t/hovertime;
			
			pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, dt), math.lerp(startl.y, ly, dt)
			pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, dt), math.lerp(startr.y, ry, dt)
			pumpernick.left.up, pumpernick.right.up = math.lerp(-vectr.up2, pumpernick.up, dt):normalise(), math.lerp(-vectr.up2, pumpernick.up, dt):normalise();
			
			t = t+1;
			eventu.waitFrames(0);
		end]]
		
		local legsDone = false;
		
		eventu.run(	function()
						local legtime = 48;
						local t = 0;
						
						local startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
						local startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
						
						local offsetl = vectr.v2(64,0):rotate(rng.random(360));
						local offsetr = vectr.v2(64,0):rotate(rng.random(360))
							
						while(t <= legtime) do
							local dt = t/legtime;
							dt = dt*dt*dt
							
							offsetl = offsetl:rotate(rng.random(64));
							offsetr = offsetr:rotate(rng.random(64));
							
							local lx,ly,rx,ry = getLegPos();
							local lo = offsetl * (1-(2*dt-1)*(2*dt-1));
							local ro = offsetr * (1-(2*dt-1)*(2*dt-1));
							if(dt >= 1) then
								lo = vectr.zero2;
								ro = vectr.zero2;
							end
							pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, dt) + lo.x, math.lerp(startl.y, ly, dt) + lo.y
							pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, dt) + ro.x, math.lerp(startr.y, ry, dt) + ro.y
							pumpernick.left.up, pumpernick.right.up = math.lerp(-vectr.up2, pumpernick.up, dt):normalise(), math.lerp(-vectr.up2, pumpernick.up, dt):normalise();
							
							t = t+1;
							eventu.waitFrames(0);
						end
						legsDone = true;
					end)
		
		pumpernick.eye.state = EYE_OPEN;
		
		eventu.waitFrames(32);
		
		
		local s = GROUNDBODY-pumpernick.y;
		local g = 0.5
		local falltime = math.sqrt(2*s/g);
		t = 0;
		local v = 0;
		local startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
		local startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
		local startlup, startrup = pumpernick.left.up, pumpernick.right.up;
		local startup = pumpernick.up;
		local hit = false;
		
		local legscache = -1;
		
		while(t <= falltime + 8) do
			local dt = math.min(t/falltime, 1);
			
			pumpernick.y = pumpernick.y + v;
			if(pumpernick.y >= GROUNDBODY) then
				pumpernick.y = GROUNDBODY;
				if(not hit) then
					damage(10, 128);
					Defines.earthquake = 8;
					hit = true;
				end
			end
			
			if(legsDone) then
				if(legscache < 0) then
					startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
					startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
					startlup, startrup = pumpernick.left.up, pumpernick.right.up;
					legscache = dt;
				end
				lx,ly,rx,ry = getLegPos();
				local lt = math.clamp((dt-legscache)/(1-legscache),0,1);
				if(legscache == 1) then
					lt = 1;
				end
				pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, lt), math.lerp(startl.y, ly, lt)
				pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, lt), math.lerp(startr.y, ry, lt)
				pumpernick.left.up, pumpernick.right.up = math.lerp(startlup, pumpernick.up, lt):normalise(), math.lerp(startrup, pumpernick.up, lt):normalise();
			end
			
			v = v + g;
			
			pumpernick.up = math.lerp(startup, -vectr.up2, dt):normalise();
			
			t = t+1;
			eventu.waitFrames(0);
		end
		
		eventu.waitFrames(128);
		
		t = 0;
		fliptime = 32;
		startl = vectr.v2(pumpernick.left.x, pumpernick.left.y);
		startr = vectr.v2(pumpernick.right.x, pumpernick.right.y);
		startlup, startrup = pumpernick.left.up, pumpernick.right.up;
		
		while(t <= fliptime) do
			local dt = t/fliptime;
			
			pumpernick.y = GROUNDBODY - 64*(1-(2*dt-1)*(2*dt-1));
			
			pumpernick.up = -vectr.up2:rotate(180*dt*pumpernick.dir);
			
			--[ --Trailing legs
			lx,ly,rx,ry = getLegPos();
			dt = math.sqrt(dt);
			pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, dt), math.lerp(startl.y, ly, dt)
			pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, dt), math.lerp(startr.y, ry, dt)
			pumpernick.left.up, pumpernick.right.up = math.lerp(startlup, pumpernick.up, dt):normalise(), math.lerp(startrup, pumpernick.up, dt):normalise();
			--]]
			
			--[[ --Snapping legs
			pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();
			pumpernick.left.up, pumpernick.right.up= pumpernick.up, pumpernick.up;
			--]]
			
			t = t+1;
			eventu.waitFrames(0);
		end
		pumpernick.hitboxActive = true;
		pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();
		pumpernick.left.up, pumpernick.right.up = vectr.up2, vectr.up2;
	end
	local px = player.x + player.width*0.5;
	if((pumpernick.dir == 1 and px < pumpernick.x) or (pumpernick.dir == -1 and px > pumpernick.x)) then
		pumpernick.turn();
		eventu.waitFrames(16);
	end
	setPhase();
	
end

local function phase_noodlewalk()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	
	local _;
	_,subphases[1] = eventu.run(phase_idle);
	
	moveBody(64, pumpernick.x, GROUNDBODY-400);
	waitForBody();
	
	eventu.waitFrames(64);
	
	local noodle = pumpernick.left;
	local othernoodle = pumpernick.right;
	local noodleoffset = -34;
	if(pumpernick.dir == -1) then
		noodle = pumpernick.right;
		othernoodle = pumpernick.left;
		noodleoffset = 32;
	end
	
	for i = 1,6 do
		local raiseTime = 32;
		local t = 0;
		local sx,sy = noodle.x,noodle.y;
		while(t <= raiseTime) do
			local dt = t/raiseTime;
			dt = ease(dt);
			
			noodle.x = math.lerp(sx,player.x+player.width*0.5,dt);
			noodle.y = math.lerp(sy,pumpernick.y + 192, dt);
			
			t=t+1;
			eventu.waitFrames(0);
		end
		
		waitAndDo(32, function() noodle.x = player.x+player.width*0.5; end);
		
		local stompTime = 16;
		t = 0;
		sy = noodle.y;
		noodle.hitboxActive = true;
		while(t <= stompTime) do
			local dt = t/stompTime;
			dt = dt*dt*dt;
			
			noodle.y = math.lerp(sy,GROUNDBODY+32, dt);
			
			t=t+1;
			eventu.waitFrames(0);
		end
		
		Audio.playSFX(37);
		Defines.earthquake = 4;
		
		local dir = 1;
		if(player.x + player.width*0.5 < noodle.x) then
			dir = -1;
		end
		--makeBullet(noodle.x, GROUNDBODY+20, bullet.MINISHOCK, dir*4*vectr.right2);
		--Audio.playSFX(42);
		
		eventu.waitFrames(2);
		
		noodle.hitboxActive = false;
		
		eventu.waitFrames(14);
		
		local tmp = noodle;
		noodle = othernoodle;
		othernoodle = tmp;
		moveBody(64, othernoodle.x-noodleoffset, GROUNDBODY-400);
		local px = player.x + player.width*0.5;
		if((pumpernick.dir == 1 and px < pumpernick.x) or (pumpernick.dir == -1 and px > pumpernick.x)) then
			pumpernick.turn();
			eventu.waitFrames(16)
			tmp = noodle;
			noodle = othernoodle;
			othernoodle = tmp;
		else
			if(noodleoffset < 0) then
				noodleoffset = 33;
			else
				noodleoffset = -34;
			end
		end
	end
	
	local recoverTime = 64;
	moveBody(recoverTime, pumpernick.x, GROUNDBODY);
	local lx,ly,rx,ry = getLegPos(pumpernick.x, GROUNDBODY, vectr.up2);
	local slx,sly = pumpernick.left.x,pumpernick.left.y;
	local srx,sry = pumpernick.right.x,pumpernick.right.y;
	local t = 0;
	while(t <= recoverTime) do
		local dt = t/recoverTime;
		dt = ease(dt);
		
		pumpernick.left.x,pumpernick.left.y = math.lerp(slx,lx,dt),math.lerp(sly,ly,dt)
		pumpernick.right.x,pumpernick.right.y = math.lerp(srx,rx,dt),math.lerp(sry,ry,dt)
			
		t=t+1;
		eventu.waitFrames(0);
	end
	
	
	abortSubphases();
	
	setPhase();
end

local function phase_spin()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	waitAndDo(16, function() pumpernick.eye.state = EYE_CLOSED end);
	pumpernick.spin = true;
	pumpernick.spinspeed = 0.75
	moveBody(32,pumpernick.x,GROUNDBODY+16);
	waitAndDo(32, function() pumpernick.eye.state = EYE_CLOSED end);
	
	local spintime = 768;
	local t = 0;
	local v = 0;
	local a = 0.15;
	local maxspd = 14;
	local dir = 1.25;
	if(player.x + player.width*0.5 < pumpernick.x) then
		dir = -1.25;
	end
	pumpernick.hitboxActive = false;
	
	local whirl = makeEffect(pumpernick.x, pumpernick.y,effect.WHIRL);
	dustTrail.enabled = true;
	
	local inv = 0;
	
	while(t <= spintime) do
		local px = player.x + player.width*0.5;
		
		if(t > 128) then
			dir = math.sign(px-pumpernick.x);
		end
		
		v = math.clamp(v+dir*a, -maxspd, maxspd);
		
		pumpernick.x = pumpernick.x + v;
		if((pumpernick.x < Zero.x+64 and v < 0) or (pumpernick.x > Zero.x+800-64 and v > 0)) then
			dir = -dir;
			v = -v;
			Audio.playSFX(37);
			Audio.playSFX(9);
		end
		
		whirl.x = pumpernick.x;
		whirl.alpha = math.clamp(math.abs(v)/10,0,1)
		
		dustTrail.x = pumpernick.x;
		dustTrail.y = pumpernick.y+16;
		dustTrail:setParam("rate", math.abs(v)/32);
		
		if(pumpernick.spinframe == 2 and pumpernick.spincounter == 0) then
			Sound(audio.spin, math.lerp(0.5,1,whirl.alpha));
		end
		
		if(inv > 0) then
			inv = inv-1;
		end
		
		if(t < spintime-64) then
			local b = false;
			if(player.y + player.height < GROUNDBODY+8) then
				b = doBounce(function() 
								inv = 8;
								if((px > pumpernick.x and v > 0) or (px > pumpernick.x and v < 0)) then
									playerMomentum = playerMomentum-v;
								else
									playerMomentum = playerMomentum+v;
								end
							end);
			end
			if(not b and inv <= 0 and colliders.collide(player, pumpernick.hitbox)) then
				player:harm();
			end
		else
			pumpernick.hitboxActive = true;
		end
		
		if(t > spintime-128) then
			local dt = (1-((spintime-t)/128));
			v = math.lerp(v,0,dt*dt)
		end
		
		pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos(pumpernick.x, GROUNDBODY, pumpernick.up);
		
		pumpernick.spinspeed = math.lerp(0.75, 10, math.clamp(math.abs(v)/10,0,1));
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	dustTrail.enabled = false;
	whirl.dead = true;
	
	
	moveBody(32,pumpernick.x,GROUNDBODY);
	pumpernick.spinframe = 0;
	pumpernick.spinspeed = 0;
	eventu.waitFrames(16);
	pumpernick.spin = false;
	pumpernick.eye.state = EYE_OPEN
	eventu.waitFrames(16);
	
	local px = player.x + player.width*0.5;
	if((pumpernick.dir == 1 and px < pumpernick.x) or (pumpernick.dir == -1 and px > pumpernick.x)) then
		pumpernick.turn();
	end
	eventu.waitFrames(32);
	
	setPhase();
end

local function phase_slam()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	
	moveBody(32, pumpernick.x, pumpernick.y + 5);
	waitForBody();
	
	local h = GROUNDBODY-400;
	local jumptime = 64;
	local t = 0;
	local g = -2*(h-pumpernick.y)/(jumptime*jumptime);
	local v = -g*jumptime;
	while(t <= jumptime) do
		local dt = t/jumptime;
		pumpernick.y = pumpernick.y + v;
		v = v+g;
		
		local lx,ly,rx,ry = getLegPos();
		if(t > jumptime - 32) then
			lx = Zero.x+400+400*pumpernick.dir;
			rx = Zero.x+400-400*pumpernick.dir;
			dt = (t+32-jumptime)/32;
			ly = ly+32;
			ry = ry+32;
			
			pumpernick.left.up = math.lerp(pumpernick.left.up, pumpernick.dir*vectr.right2, dt);
			pumpernick.right.up = math.lerp(pumpernick.right.up, -pumpernick.dir*vectr.right2, dt);
		end
		pumpernick.left.x, pumpernick.left.y = math.lerp(pumpernick.left.x, lx, dt), math.lerp(pumpernick.left.y, ly, dt)
		pumpernick.right.x, pumpernick.right.y = math.lerp(pumpernick.right.x, rx, dt), math.lerp(pumpernick.right.y, ry, dt)
		
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	local hovertime = 256;
	t = 0;
	
	while(t <= hovertime) do
		pumpernick.x = math.lerp(pumpernick.x, player.x+player.width*0.5, 0.05);
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	eventu.waitFrames(64);
	
	local basey = pumpernick.y;
	for i = 1,3 do
		local slamtime = 16;
		t = 0;
		
		while(t <= slamtime) do
			local dt = t/slamtime;
			dt = dt*dt*dt;
			
			pumpernick.y = math.lerp(basey, GROUNDBODY+16, dt);
			
			t = t+1;
			eventu.waitFrames(0);
		end
		
		t = 0;
		slamtime = 48;
		
		Audio.playSFX(37);
		Audio.playSFX(42);
		Defines.earthquake = 24;
		
		makeBullet(pumpernick.x-32, GROUNDBODY-32, bullet.SHOCKWAVE, 6*vectr.right2);
		makeBullet(pumpernick.x+32, GROUNDBODY-32, bullet.SHOCKWAVE, -6*vectr.right2);
		
		while(t <= slamtime) do
			local dt = t/slamtime;
			dt = dt*dt*dt;
			
			pumpernick.y = math.lerp(basey, GROUNDBODY+16, 1-dt);
			
			t = t+1;
			eventu.waitFrames(0);
		end
	
		eventu.waitFrames(8);
	end
	
	h = GROUNDBODY+5;
	jumptime = 64;
	t = 0;
	g = 2*(h-pumpernick.y)/(jumptime*jumptime);
	v = 0;
	while(t < jumptime) do
		local dt = t/jumptime;
		dt = dt*dt*dt
		pumpernick.y = pumpernick.y + v;
		v = v+g;
		
		local lx,ly,rx,ry = getLegPos();
		ly = ly + (1-dt)*64;
		ry = ry + (1-dt)*64;
		pumpernick.left.x, pumpernick.left.y = math.lerp(pumpernick.left.x, lx, dt), math.lerp(pumpernick.left.y, ly, dt)
		pumpernick.right.x, pumpernick.right.y = math.lerp(pumpernick.right.x, rx, dt), math.lerp(pumpernick.right.y, ry, dt)
		pumpernick.left.up = math.lerp(pumpernick.left.up, vectr.up2, dt);
		pumpernick.right.up = math.lerp(pumpernick.right.up, vectr.up2, dt);
		
		
		t = t+1;
		eventu.waitFrames(0);
	end
	
	pumpernick.y = GROUNDBODY;
	pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos()
	pumpernick.y = pumpernick.y+5;
	
	moveBody(32, pumpernick.x, GROUNDBODY);
	waitForBody();
	
	setPhase();
end

local function phase_bounce()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	
	moveBody(32, pumpernick.x, pumpernick.y + 5);
	waitForBody();
	
	local h = GROUNDBODY-rng.random(200,400);
	
	local side = 1;
	if(pumpernick.x < Zero.x+400) then
		side = -1;
	end
	
	local start = vectr.v2(pumpernick.x, pumpernick.y);
	local target = Zero.x+400+side*400-side*32;
	
	local startl = vectr.v2(pumpernick.left.x, pumpernick.left.y)
	local startr = vectr.v2(pumpernick.right.x, pumpernick.right.y)
	
	local jumptime = 64;
	local t = 0;
	while(t <= jumptime) do
		dt = t/jumptime;
		
		pumpernick.eye.state = EYE_CLOSED;
		
		pumpernick.x,pumpernick.y = math.lerp(start.x, target, dt*dt*dt*dt),math.lerp(start.y, h, math.sqrt(dt));
		pumpernick.up = vectr.up2:rotate(-side*90*dt);
		
		local lx,ly,rx,ry = getLegPos(target, h, vectr.right2*side);
		local ldt = math.clamp(dt*2,0,1);
		pumpernick.left.x, pumpernick.left.y = math.lerp(startl.x, lx, ldt*ldt), math.lerp(startl.y, ly, ldt)
		pumpernick.right.x, pumpernick.right.y = math.lerp(startr.x, rx, ldt*ldt), math.lerp(startr.y, ry, ldt)
		pumpernick.left.up, pumpernick.right.up = vectr.up2:rotate(-side*90*ldt), vectr.up2:rotate(-side*90*ldt);
		
		t=t+1;
		eventu.waitFrames(0);
	end
	
	eventu.waitFrames(32);
	
	pumpernick.spinspeed = 2;
	pumpernick.spin = true;
	
	eventu.waitFrames(8);
	
	local bouncetime = 768;
	t = 0;
	local v = vectr.v2(side*rng.random(3,5), 0);
	local g = 0.5;
	local a = -side*90;
	local inv = 0;
	
	pumpernick.hitboxActive = false;
	
	while(t <= bouncetime) do
		pumpernick.x, pumpernick.y = pumpernick.x + v.x, pumpernick.y + v.y;
		
		v.y = v.y + g;
		
		local ta = a%360;
		local cs = math.cos(math.rad(ta));
		--local sn = math.sin(math.rad(ta));
		
		if(t < bouncetime-64) then
			pumpernick.up = pumpernick.up:rotate(v.x*side);
			a = a+v.x*side;
		else
			local dt = (bouncetime-t)/64;
			local adir = math.sign(v.x*side);
			local todo = (360-ta)%360
			local da = math.lerp(v.x*side, todo, 1-dt);
			if((todo > 0 and da > todo) or (todo < 0 and da < todo) or (todo == 0)) then
				da = todo;
			end
			pumpernick.up = pumpernick.up:rotate(da);
			a = a + da;
		end
		
		if(t > bouncetime - 16) then
			if(pumpernick.spinframe == 1) then
				pumpernick.spinspeed = 0;
				pumpernick.spinframe = 0;
			end
			pumpernick.eye.state = EYE_OPEN;
			if(t > bouncetime-8) then
				pumpernick.spin = false;
				pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();
				pumpernick.left.up, pumpernick.right.up = pumpernick.up, pumpernick.up;
			end
		end
		
		if(inv > 0) then
			inv = inv-1;
		end
		
		if(not doBounce(function() inv=32 end) and inv <= 0 and colliders.collide(player, pumpernick.hitbox)) then
			player:harm();
		end
		
		if(v.y > 0 and pumpernick.y > GROUNDBODY+16*cs*cs) then
			v.y = rng.random(0.9,1.1)*math.max(-v.y, -16);
			pumpernick.y = GROUNDBODY+16*cs*cs;
			Audio.playSFX(37);
			Defines.earthquake = 4;
			if(t >= bouncetime) then
				break;
			end
		end
		
		if((v.x < 0 and pumpernick.x < Zero.x+32) or (v.x > 0 and pumpernick.x > Zero.x+800-32)) then
			v.x = -v.x;
		end
	
		if(t < bouncetime) then
			t=t+1;
		end
		eventu.waitFrames(0);
	end
	pumpernick.y = GROUNDBODY;
	pumpernick.left.x, pumpernick.left.y, pumpernick.right.x, pumpernick.right.y = getLegPos();
	
	pumpernick.hitboxActive = true;
	
	setPhase();
end

local function phase_rocket()
	pumpernick.up = vectr.up2;
	abortBodyMove();
	
	pumpernick.rocket = true;
	pumpernick.rocketspeed = 1;
	
	local rocketSound = audioMaster.Create{	sound = audio.rocket, 
											volume = 0, 
											x = Zero.x+400, y = Zero.y+300, 
											falloffRadius = 800, falloffType = audioMaster.FALLOFF_NONE
										  };
	
	moveBody(128, pumpernick.x, pumpernick.y-192)
	
	waitAndDo(128, function() 
						rocketSound.volume = rocketSound.volume+(1/128);
					end);
	
	waitAndDo(64, function() pumpernick.eye.state = EYE_CLOSED; end);

	local rockettime = 512;
	local t = 0;
	local v = vectr.zero2;
	local d = -vectr.up2;
	local a = 0.2;
	local maxspd = 12;
	pumpernick.hitboxActive = false;
	while(t <= rockettime) do
		pumpernick.x, pumpernick.y = pumpernick.x+v.x, pumpernick.y+v.y
		
		v = v+d*a;
		
		if(v.sqrlength > maxspd*maxspd) then
			v = v:normalise()*maxspd;
		end
		
		local bnc = false;
		if((pumpernick.x < Zero.x+64 and v.x < 0) or (pumpernick.x > Zero.x+800-64 and v.x > 0)) then
			v.x = -v.x;
			bnc = true;
		end
		if((pumpernick.y < Zero.y+64 and v.y < 0) or (pumpernick.y > Zero.y+568-64 and v.y > 0)) then
			v.y = -v.y;
			bnc = true;
		end
		
		if(bnc) then
			Defines.earthquake=4;
			Audio.playSFX(37);
		end
		
		local tg = vectr.v2(player.x + player.width*0.5, player.y+player.height*0.25);
		local dp = tg-vectr.v2(pumpernick.x, pumpernick.y);
		local ta = math.atan2(dp.y, dp.x) - math.atan2(d.y,d.x); --[[math.atan2(1, 0)]]
		while (ta < -math.pi) do
			ta = ta+2*math.pi;
		end
		while (ta > math.pi) do
			ta = ta-2*math.pi;
		end
		
		local inv = 0;
		if(not doBounce(function() inv = 32 end) and inv <= 0 and v.sqrlength > 1 and colliders.collide(player, pumpernick.hitbox)) then
			player:harm();
		end
		
		d=d:rotate(ta);
		pumpernick.up = math.lerp(pumpernick.up, -v:normalise(), 0.5):normalise();
		
		if(t > rockettime-64) then
			local dt = ((rockettime-t)/64);
			v = v*dt*dt;
			dt = 1-dt;
			pumpernick.up = math.lerp(pumpernick.up, vectr.up2, dt):normalise();
		end
	
		t = t+1;
		eventu.waitFrames(0);
	end
	
	pumpernick.hitboxActive = true;
	
	pumpernick.eye.state = EYE_OPEN;
	moveBody(128, pumpernick.x, GROUNDBODY);
	
	waitAndDo(128, function() 
						rocketSound.volume = rocketSound.volume-(1/128);
					end);
					
	rocketSound:Destroy();
	
	pumpernick.rocketspeed = 0;
	pumpernick.rocketframe = 0;
	eventu.waitFrames(16);
	pumpernick.rocket = false;
	
	pumpernick.left.x,pumpernick.left.y,pumpernick.right.x,pumpernick.right.y = getLegPos();
	
	local px = player.x + player.width*0.5;
	if((px < pumpernick.x and pumpernick.dir == 1) or (px > pumpernick.x and pumpernick.dir == -1)) then
		pumpernick.turn();
	end
	
	eventu.waitFrames(16);
	
	setPhase();
end

function events.intro()
	moveBody(lunatime.toTicks(6), pumpernick.x, pumpernick.y - 400);
	
	waitForBody();
	
	eventu.waitFrames(350);
	
	
	moveBody(lunatime.toTicks(1), pumpernick.x, pumpernick.y + 400);
	
	waitForBody();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="Here I come!<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_pogo);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="You darn bipeds. This is how dumb you look.<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_noodlewalk);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="Whoop!<pause 60> Floor is lava!<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_pendulum);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="You spin me right round baby! Ahahaha!<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_spin);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="Look at me go!<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_slam);
	waitPhase();
	eventu.waitFrames(64);	
	setPhase(phase_pendulum);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="Watch me get the DROP on you!<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_bounce);
	waitPhase();
	eventu.waitFrames(64);
	message.showMessageBox {target=pumpernick.msg, text="Mars ain't the kind of place to raise your kids.<pause 90>", closeWith = "auto", keepOnscreen = true}
	setPhase(phase_rocket);
	waitPhase();
	eventu.waitFrames(64);
	local phases;
	while(true) do
		setPhase(phase_pendulum);
		waitPhase();
		eventu.waitFrames(64);
		for i = 1,2 do
			if(phases == nil or #phases == 0) then
				phases = {phase_pogo, phase_noodlewalk, phase_spin, phase_slam, phase_bounce, phase_rocket};
			end
			local i = rng.randomInt(1,#phases);
			local p = phases[i];
			table.remove(phases, i);
			setPhase(p);
			waitPhase();
			eventu.waitFrames(64);
		end
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
	
	
	StartBoss();
	
	eventu.waitFrames(64);
	scene.endScene();
end

function cutscene.intro()
	Audio.MusicVolume(100);
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
	
	flash = 1;
	
	player.x = Zero.x+96;
	
	cp:collect();
	
	StartBoss();
	eventu.waitFrames(64);
	
	scene.endScene();
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