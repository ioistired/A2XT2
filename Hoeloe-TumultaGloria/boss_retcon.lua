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

local playerManager = API.load("playerManager")

local broadsword = API.load("Characters/unclebroadsword")

local audioMaster = API.load("audioMaster");

local panim = API.load("playerAnim");

boss.Name = "Tumulta Gloria"
boss.SuperTitle = "Chaos Pumpernickel"
boss.SubTitle = "Anarchy Incarnate"

boss.MaxHP = 110;

boss.TitleDisplayTime = 380;

local bossStarted = false;
local starttime = 0;
local drawBG = false;

local flashTimer = 0;

local bossSection = 0;

local intensifies = false;
local intensifiesTimeMult = 1.3;
local intensifiesTime = lunatime.toTicks(90)/intensifiesTimeMult;
local intensifiesTimer = 0;

local Zero = vectr.v2(0,0);

local eyeTarget = nil;
local lastEyePos = nil;

local globalfog = 0;
local emitfgfog = false;

local x = 0;
local y = 0;
local bodyfog = particles.Emitter(x, y, Misc.resolveFile("p_pumpernick.ini"), 2);
local bodyfog2 = particles.Emitter(x, y, Misc.resolveFile("p_pumpernick.ini"));
bodyfog2:setParam("space","world");
local eye1 = Graphics.loadImage(Misc.resolveFile("eyeball.png"));
local eye2 = Graphics.loadImage(Misc.resolveFile("eyepupil.png"));
local eyelid = Graphics.loadImage(Misc.resolveFile("eyelid.png"));

local eyelidFrame = 0;

local smoke = Graphics.loadImage(Misc.resolveFile("puff.png"));

local hand = Graphics.loadImage(Misc.resolveFile("hand.png"));

local noise = Graphics.loadImage(Misc.resolveFile("noise.png"));

local anges = Graphics.loadImage(Misc.resolveFile("anges.png"));

local armemit  = particles.Emitter(x, y, Misc.resolveFile("p_armfog.ini"));

local ceilfog = particles.Emitter(x, y, Misc.resolveFile("p_ceilfog.ini"));

local cornerfog = particles.Emitter(x, y, Misc.resolveFile("p_cornerfog.ini"));
local cornerFogRange=vectr.v2(192,96);

local arms = {};
local useStraightArms = false;
local armStunTime = lunatime.toTicks(2);

local ellipse = {f1 = vectr.v2(-32,0), f2 = vectr.v2(32,0), Rm = 24};

local smokepos = {};
local numPlates = 0;

local bgShader = Shader();

local coltbl = {0xFF5555, 0xffaa55, 0xffff55, 0xaaff55, 0x55ff55, 0x55ffaa, 0x55ffff, 0x55aaff, 0x5555ff, 0xaa55ff, 0xff55ff, 0xff55aa};
for k,v in ipairs(coltbl) do
	coltbl[k] = particles.ColFromHexRGB(v);
end
local smokegrad = particles.Grad({0,0.0909,0.1818,0.2727,0.3636,0.4545,0.5455,0.6364,0.7273,0.8182,0.9091,1}, coltbl)

local current_phase = nil;
local movement_loop = nil;
local move_event = nil;
local player_pos = {x=0, y=0, width=0, height = 0};
local eye_pos = {x=0, y=0, width=0, height = 0};

local eyeBox = colliders.Circle(0,0,32);

local armInitTimer = 0;

local bullets = {};

local BULLET_SMALL = 0;
local BULLET_MED = 1;
local bulletImgs = {}
bulletImgs[BULLET_SMALL] = Graphics.loadImage(Misc.resolveFile("bullet_1.png"));
bulletImgs[BULLET_MED] = Graphics.loadImage(Misc.resolveFile("bullet_2.png"));

local largeBulletImgs = 
{
Graphics.loadImage(Misc.resolveFile("bullet_large_1.png"));
Graphics.loadImage(Misc.resolveFile("bullet_large_2.png"));
Graphics.loadImage(Misc.resolveFile("bullet_large_3.png"));
}

local largeBullet = nil;

local hitflashes = {};

local hitflashImgs = 
{
	Graphics.loadImage(Misc.resolveFile("hitflash_1.png"));
	Graphics.loadImage(Misc.resolveFile("hitflash_2.png"));
	Graphics.loadImage(Misc.resolveFile("hitflash_3.png"));
	Graphics.loadImage(Misc.resolveFile("hitflash_4.png"));
}

local audio = {}
audio.sunball_charge = Misc.resolveFile("charge_sunball.ogg")
audio.sunball_fire = Misc.resolveFile("fire_sunball.ogg")
audio.sunball_reflect = Misc.resolveFile("reflect_sunball.ogg")
audio.sunball_die = Misc.resolveFile("explode_sunball.ogg")
audio.sunball_charge_final = Misc.resolveFile("charge_sunball_final.ogg")
audio.plate_break = Misc.resolveFile("break_plate.ogg")
audio.stun = Misc.resolveFile("stun.ogg")
audio.thud = Misc.resolveFile("thud.ogg")
audio.hurt = Misc.resolveFile("hurt.ogg")
audio.whoosh = Misc.resolveFile("whoosh.ogg")
audio.hand_stun = Misc.resolveFile("hand_stun.ogg")
audio.hand_stun_recover = Misc.resolveFile("hand_stun_2.ogg")
audio.bullet_small = Misc.resolveFile("bullet_1.ogg")
audio.bullet_hit = Misc.resolveFile("bullet_2.ogg")
audio.bullet_med = Misc.resolveFile("bullet_3.ogg")
audio.bullet_split = Misc.resolveFile("bullet_4.ogg")
audio.fog = Misc.resolveFile("fog.ogg")
audio.core_reset = Misc.resolveFile("core_reset.ogg")
audio.core_active = Misc.resolveFile("core_active.ogg")
audio.core_active_loop = Misc.resolveFile("core_active2.ogg")

audio.voice = {}

audio.voice.hurt = {Misc.resolveFile("voice_hurt_1.ogg"), Misc.resolveFile("voice_hurt_2.ogg")}
audio.voice.stun = {Misc.resolveFile("voice_stun_1.ogg"), Misc.resolveFile("voice_stun_2.ogg")}

local broken_core = audioMaster.Create{sound="core_error.ogg", x = 0, y = 0, type = audio.SOURCE_POINT, falloffRadius = 800, volume = 1, tags = {"COREBG"}};

local events = {};
local cutscene = {};

local bossBegun = false;

function bossAPI.Begin(fromCheckpoint)
	if(not bossBegun) then
		registerEvent(bossAPI, "onTick");
		registerEvent(bossAPI, "onDraw");
		registerEvent(bossAPI, "onCameraUpdate");
		
		bossBegun = true;

		pause.StopMusic = true;
		
		events.InitBoss(fromCheckpoint);
	end
end

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


local rng = API.load("rng")
local vectr = API.load("vectr")
local tesseract = API.load("CORE/tesseract");
local backgrounds = API.load("CORE/core_bg");
backgrounds.colour = Color.red;
backgrounds.fliprandomise = true;
backgrounds.initFlipclocks(rng.randomInt(0,99999999));
backgrounds.nebulaspeed = -3;
backgrounds.consolestate = -1;

local tess = tesseract.Create(400,300,32);

tess.rotationXYZ.x = rng.random(0,2*math.pi);
tess.rotationXYZ.y = rng.random(0,2*math.pi);
tess.rotationXYZ.z = rng.random(0,2*math.pi);
tess.rotationW.x = rng.random(0,2*math.pi);
tess.rotationW.y = rng.random(0,2*math.pi);
tess.rotationW.z = rng.random(0,2*math.pi);

local tess_rotspdxyz = vectr.v3(0.011, 0.023, 0.047);
local tess_rotspdw = vectr.v3(0.028,0.013,0.021)
local tess_spdmult = 1.5;
local tess_colour = math.lerp(Color.white,Color.red,0.8);

local flip_stabletime = 0;

local bg_pulsetime = 0;
				
local stunned = false;
local stunRecovery = false;

local eyeAnimTimer = 0;
local eyeFrame = 0;
local eyeHitstun = 0;
local eyeRecoveryAmt = 0;

local plateCounts = {3,5,7,10}
local plateIndex = 1;

local moveBoundsX;
local moveBoundsY;

local function resetMoveBounds()
	moveBoundsX = vectr.v2(64,64);
	moveBoundsY = vectr.v2(64,128);
end

resetMoveBounds();

local subphases = {};

local function Sound(name, volume, tags)
	audioMaster.PlaySound{sound = name, loops = 1, volume = volume, tags = tags}
end

local function Voice(name, volume, tags)
	audioMaster.PlaySound{sound = rng.irandomEntry(name), loops = 1, volume = volume, tags = tags}
end

local function choose(a, b, bool)
	if(bool == nil) then bool = not intensifies; end
	if(bool) then return a else return b end
end

local function waitAndDo(t, func)
	while(t > 0) do
		t = t-1;
		func();
		eventu.waitFrames(0);
	end
end

local function spawnHitflash(flashType, pos, size, target)
	local b = {pos = pos, size = size, type = flashType, frame = 0, framespeed = 0, frames = 1, t = 0, target = target, loop = true}
	if(flashType == 1) then
		b.gfxwidth = 128;
		b.gfxheight = 128;
		b.framespeed = 2;
		b.frames = 10;
		b.duration = b.frames*b.framespeed;
	elseif(flashType == 2) then
		b.gfxwidth = 256;
		b.gfxheight = 256;
		b.framespeed = 1;
		b.frames = 15;
		b.duration = b.frames*b.framespeed;
	elseif(flashType == 3) then
		b.gfxwidth = 128;
		b.gfxheight = 128;
		b.framespeed = 2;
		b.frames = 18;
		b.duration = b.frames*b.framespeed;
	elseif(flashType == 4) then
		b.gfxwidth = 512;
		b.gfxheight = 512;
		b.framespeed = 8;
		b.frames = 3;
		b.loop = false;
		b.duration = 48;
	end
	b.frametimer = b.framespeed;
	table.insert(hitflashes, b);
end

local function computeAdditiveFade(a)
	local c = math.floor(a*0xFF);
	local t = {};
	for i=1,4 do
		t[i] = c*256*256*256+c*256*256+c*256;
	end
	return t;
end

local function drawHitFlashes()
	for i=#hitflashes,1,-1 do
		local v = hitflashes[i];
		
		if(v.target) then
			v.pos.x = v.target.x;
			v.pos.y = v.target.y;
		end
		
		local drawArgs = {x = v.pos.x, y = v.pos.y, texture = hitflashImgs[v.type], align = imagic.ALIGN_CENTRE, width = v.size.x, height = v.size.y, sourceX = 0, sourceY = v.frame*v.gfxheight, sourceWidth = v.gfxwidth, sourceHeight = v.gfxheight, scene=true}
		local additive = {vertColors = {0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00}}
		
		if(v.type == 1) then
			v.size = v.size*1.05;
			imagic.Draw(table.join(additive, drawArgs));
		elseif(v.type == 2) then
			imagic.Draw(table.join(additive, drawArgs));
		elseif(v.type == 3) then
			v.size = v.size*1.01;
			imagic.Draw(table.join(additive, drawArgs));
		elseif(v.type == 4) then
			v.size = v.size*1.02;
			imagic.Draw(table.join({vertColors = computeAdditiveFade(1- math.clamp((v.t+8-v.duration)/8))}, drawArgs));
		end
		
		v.frametimer = v.frametimer-1;
		if(v.frametimer < 0) then
			v.frame = (v.frame + 1);
			if(v.loop) then
				v.frame = v.frame%v.frames;
			else
				v.frame = math.min(v.frame, v.frames-1);
			end
			v.frametimer = v.framespeed;
		end
		
		v.t = v.t+1;
		if(v.t > v.duration) then
			table.remove(hitflashes,i);
		end
	end
end

local function drawBullets()
	for _,v in ipairs(bullets) do
		Graphics.drawImageToSceneWP(bulletImgs[v.type], v.pos.x - v.gfxwidth*0.5, v.pos.y - v.gfxheight*0.5, 0, v.frame*v.gfxheight, v.gfxwidth, v.gfxheight, -50)
	end
end

local function flashScreen(val)
	flashTimer = val or 100;
end

local function getPlayerPos()
	return vectr.v2(player.x+player.width*0.5, player.y+player.height*0.5);
end

local function getSwipeHitbox()
	if(player:mem(0x13E,FIELD_WORD) > 0) then return nil end;
	return playerManager.getCollider(CHARACTER_UNCLEBROADSWORD, 1, "swipe");
end

local function getLungeHitbox()
	if(player:mem(0x13E,FIELD_WORD) > 0) then return nil end;
	return playerManager.getCollider(CHARACTER_UNCLEBROADSWORD, 1, "lunge");
end

local function getDownstabHitbox()
	if(player:mem(0x13E,FIELD_WORD) > 0) then return nil end;
	return playerManager.getCollider(CHARACTER_UNCLEBROADSWORD, 1, "downstab");
end

local function getUpstabHitbox()
	if(player:mem(0x13E,FIELD_WORD) > 0) then return nil end;
	return playerManager.getCollider(CHARACTER_UNCLEBROADSWORD, 1, "upstab");
end

local function getSwordHitbox()
	if(player:mem(0x13E,FIELD_WORD) > 0) then return nil end;
	return getDownstabHitbox() or getLungeHitbox() or getSwipeHitbox() or getUpstabHitbox();
end

local function UpdatePlates(newnum)
	numPlates = newnum;
end

local function spawnBullet(bulletType, pos, speed)
	local b = {pos = pos, type = bulletType, speed = speed, frame = 0}
	if(bulletType == BULLET_SMALL) then
		b.framespeed = 4;
		b.frames = 6
		b.hitbox = colliders.Circle(0,0,11);
		b.swordhitbox = colliders.Circle(0,0,15);
		b.gfxheight=22;
		b.gfxwidth=22;
		b.killable = true;
	elseif(bulletType == BULLET_MED) then
		b.framespeed = 4;
		b.frames = 6
		b.duration = choose(128,192);
		b.timer = b.duration;
		b.initSpd = speed;
		b.hitbox = colliders.Circle(0,0,18);
		b.swordhitbox = colliders.Circle(0,0,22);
		b.gfxheight=36;
		b.gfxwidth=36;
		b.killable = true;
	end
	b.frametimer = b.framespeed;
	table.insert(bullets, b);
end

local function updateBullets()
	for i = #bullets,1,-1 do
		bullets[i].pos = bullets[i].pos+bullets[i].speed;
		bullets[i].hitbox.x = bullets[i].pos.x;
		bullets[i].hitbox.y = bullets[i].pos.y;
		bullets[i].swordhitbox.x = bullets[i].pos.x;
		bullets[i].swordhitbox.y = bullets[i].pos.y;
		
		bullets[i].frametimer = bullets[i].frametimer - 1;
		if(bullets[i].frametimer < 0) then
			bullets[i].frametimer = bullets[i].framespeed;
			bullets[i].frame = (bullets[i].frame + 1)%bullets[i].frames;
		end
		
		local hb = getSwordHitbox();
		if(bullets[i].killable and hb and colliders.collide(hb, bullets[i].swordhitbox)) then
			bullets[i].dead = true;
			Sound(audio.bullet_hit);
			spawnHitflash(1, bullets[i].pos, vectr.v2(1,1)*bullets[i].hitbox.radius+5);
		elseif(colliders.collide(player,bullets[i].hitbox)) then
			player:harm();
		end
		
		if(bullets[i].type == BULLET_MED) then
		
			if(bullets[i].timer > 32 and bullets[i].pos.y + (bullets[i].speed.y*bullets[i].speed.y/2) > Zero.y+600-choose(32,128)) then
				bullets[i].timer = 32;
			end
		
			bullets[i].speed = bullets[i].initSpd * math.clamp((bullets[i].timer - 32)/(bullets[i].duration - 32));
			
			bullets[i].timer = bullets[i].timer - 1;
			
			if(bullets[i].timer == 0) then
				bullets[i].dead = true;
				spawnHitflash(1, bullets[i].pos, vectr.v2(1,1)*40);
				local s = vectr.up2;
				Sound(audio.bullet_split);
				local ioffset = rng.randomInt(0,1);
				for j = 1,8 do
					if(not intensifies or (j+ioffset)%2 == 0) then
						spawnBullet(BULLET_SMALL, bullets[i].pos, s*2);
					end
						s = s:rotate(45);
				end
			end
		end
		
		
		if(bullets[i].dead or 
		   bullets[i].pos.x > Zero.x + 864 or bullets[i].pos.x < Zero.x - 64 or
		   bullets[i].pos.y > Zero.y + 664 or bullets[i].pos.y < Zero.y - 64) then
			table.remove(bullets,i);
		end
	end
end

local largeBulletChargeTime = 200;
local largeBulletEndTime = 600;
local largeBulletSize = 128;
local largeBulletEndSize = 400;

local isEnding = false;

local function spawnLargeBullet(pos, isend)
	local b = {pos = pos, imgs = {}, launchTimer = largeBulletChargeTime, hitbox = colliders.Circle(0,0,4), dmghitbox = colliders.Circle(0,0,3), speed=4, target = player, isend = isend}
	
	for _,v in ipairs(largeBulletImgs) do
		table.insert(b.imgs, imagic.Create{texture = v, primitive = imagic.TYPE_BOX, vertColors = {0xFFFFFF00,0xFFFFFF00,0xFFFFFF00,0xFFFFFF00}, x=pos.x, y = pos.y, width=8, height = 8, scene = true, align = imagic.ALIGN_CENTRE})
	end
	
	if(isend) then
		Sound(audio.sunball_charge_final);
	else
		Sound(audio.sunball_charge);
	end
	
	largeBullet = b;
end

local function updateLargeBullet()
	if(largeBullet) then
		if(largeBullet.velocity) then
			largeBullet.pos = largeBullet.pos + largeBullet.velocity;
		end
		largeBullet.hitbox.x = largeBullet.pos.x;
		largeBullet.hitbox.y = largeBullet.pos.y;
		largeBullet.dmghitbox.x = largeBullet.pos.x;
		largeBullet.dmghitbox.y = largeBullet.pos.y;
		for k,v in ipairs(largeBullet.imgs) do
			v.x = largeBullet.pos.x;
			v.y = largeBullet.pos.y;
			if(k == 3) then
				v:Rotate(1);
			end
		end
		if(largeBullet.launchTimer > 0 or largeBullet.isend) then
			largeBullet.launchTimer = largeBullet.launchTimer - 1;
			
			if(not largeBullet.isend) then
				if(largeBullet.launchTimer == 20) then
					Sound(audio.sunball_fire);
				elseif(largeBullet.launchTimer == 0) then
					largeBullet.velocity = (getPlayerPos() - largeBullet.pos):normalise() * largeBullet.speed;
				end
			end
			--local s = math.lerp(1.02,1,1 - largeBullet.launchTimer/largeBulletChargeTime);
			local s = 1;
			if(largeBullet.isend) then
				s = math.lerp(math.pow(largeBulletEndSize,1/largeBulletChargeTime),1.001,math.clamp(1-(intensifiesTimer/largeBulletEndTime)));
				if(largeBullet.hitbox.radius > 400) then
					s = 1;
				end
			else
				s = math.lerp(math.pow(largeBulletSize,1/largeBulletChargeTime),1,1 - largeBullet.launchTimer/largeBulletChargeTime);
			end
			largeBullet.hitbox.radius = largeBullet.hitbox.radius*(s+0.001);
			largeBullet.dmghitbox.radius = math.max(largeBullet.hitbox.radius-8,1);
			for _,v in ipairs(largeBullet.imgs) do
				v:Scale(s);
				s = s + 0.001;
			end
		end
		
		if(not largeBullet.isend) then
			local hb = getLungeHitbox() or getSwipeHitbox() or getUpstabHitbox();
			
			if(largeBullet.target == player) then
				if(largeBullet.launchTimer <= 0 and hb and colliders.collide(hb, largeBullet.hitbox)) then
					largeBullet.target = nil;
					largeBullet.speed = largeBullet.speed*1.05;
					largeBullet.velocity = (vectr.v2(x,y) - largeBullet.pos):normalise() * largeBullet.speed;
					
					Sound(audio.sunball_reflect);
					
					local p = vectr.v2(hb.x+hb.width*0.5, hb.y+hb.height*0.5);
					local d = p-largeBullet.pos;
					if(d.length > largeBullet.hitbox.radius) then
						d = d:normalise();
						p = largeBullet.pos + d*largeBullet.hitbox.radius;
					end
					
					spawnHitflash(2, p, vectr.v2(200, 200));
				elseif(colliders.collide(player,largeBullet.dmghitbox)) then
					player:harm();
				end
			else
				if(colliders.collide(eyeBox,largeBullet.hitbox)) then
					if(numPlates >= 1) then
						largeBullet.target = player;
						largeBullet.speed = largeBullet.speed*1.05;
						largeBullet.velocity = (getPlayerPos() - largeBullet.pos):normalise() * largeBullet.speed;
						
						local p = vectr.v2(x,y);
						local d = (largeBullet.pos-p):normalise();
						d = p + d*32;
						
						Sound(audio.sunball_reflect);
						Sound(audio.plate_break, 0.5);
					
						spawnHitflash(2, d, vectr.v2(200, 200));
						spawnHitflash(3, p, vectr.v2(150, 150), eyeBox);
					else
						Sound(audio.sunball_die);
						
						spawnHitflash(4, largeBullet.pos, vectr.v2(150, 150));
						spawnHitflash(3, vectr.v2(x,y), vectr.v2(150, 150), eyeBox);
						largeBullet = nil;
						boss.Damage(10);
						events.Stun(512);
						return;
					end
					UpdatePlates(numPlates-1);
				end
			end
		end
				  
		if(largeBullet.pos.x > Zero.x + 800 + largeBullet.hitbox.radius*2 or largeBullet.pos.x < Zero.x - largeBullet.hitbox.radius*2 or
		   largeBullet.pos.y > Zero.y + 600 + largeBullet.hitbox.radius*2 or largeBullet.pos.y < Zero.y - largeBullet.hitbox.radius*2) then
			largeBullet = nil;
		end
	end
end

local function drawLargeBullet()
	if(largeBullet) then
		for _,v in ipairs(largeBullet.imgs) do
			for i = 1,16,4 do
				v.vertColors[i] = 1-(largeBullet.launchTimer/largeBulletChargeTime);
				v.vertColors[i+1] = 1-(largeBullet.launchTimer/largeBulletChargeTime);
				v.vertColors[i+2] = 1-(largeBullet.launchTimer/largeBulletChargeTime);
			end
			v:Draw(-50)
		end
	end
end

local function makeArm(js)
	local t =  {};
	t.joints = js;
	t.frame = rng.randomInt(0,15);
	t.frameTime = 0.2;
	t.hand = imagic.Create{texture = hand, primitive=imagic.TYPE_BOX, x = 0, y = 0, width = 36, height = 36, scene = true, align = imagic.ALIGN_CENTRE};
	t.initPos = nil;
	t.handBox = colliders.Box(0,0,32,32);
	t.speed = vectr.v2(0,0);
	t.rotation = 0;
	t.target = vectr.v2(x,y);
	t.targetobj = player;
	t.stuntimer = 0;
	t.vibrate = 0;
	table.insert(arms, t);
end

local function HandleArmPartciles(stepSize)
	local c = vectr.v2(x,y);
	for _,v in ipairs(arms) do
		local verts = {};
		if(#v.joints > 0) then
			local joint = v.joints[1] - c;
			for k,j in ipairs(v.joints) do
				local jointlen = joint.length;
				local dir = joint:normalise();
				local rgt = (dir:tov3()^vectr.forward3):tov2();
				
				--uncomment for vanishing smoke during stun
				--if(not(stunned and not stunRecovery)) then
					for i=1,jointlen,stepSize do
						local p = c + dir*i;
						armemit.x = p.x;
						armemit.y = p.y;
						if(rng.randomInt(0,2) == 0) then
							armemit:Emit(1);
						end
						
					end
				--end
				
				table.insert(verts, c.x)
				table.insert(verts, c.y)
					
				table.insert(verts, j.x)
				table.insert(verts, j.y)
				
				if(v.joints[k+1]) then
					c = j;
					joint = v.joints[k+1] - c;
				else
					v.speed.x = j.x - v.hand.x;
					v.speed.y = j.y - v.hand.y;
					v.hand.x = j.x;
					v.hand.y = j.y;
					if(v.initPos == nil) then
						v.initPos = vectr.v2(v.hand.x, v.hand.y);
					end
					v.handBox.x = j.x-16;
					v.handBox.y = j.y-16;
					
					if(player:mem(0x13E, FIELD_WORD) == 0 and v.stuntimer <= 0) then
						local b,s = colliders.bounce(player,v.handBox);
						if(b and s) then
							colliders.bounceResponse(player);
							if(v.speed.y < 0) then
								player.speedY = player.speedY + v.speed.y;
							end
						else
							local hb = getLungeHitbox() or getSwipeHitbox();
							local doBounce = false;
							if(hb == nil) then
								hb = getDownstabHitbox();
								doBounce = true;
							end
							if(hb and colliders.collide(v.handBox, hb)) then
								v.stuntimer = armStunTime;
								Sound(audio.hand_stun);
								if(doBounce) then
									player.speedY = -8;
									if(v.speed.y < 0) then
										player.speedY = player.speedY + v.speed.y;
									end
								end
							elseif(colliders.collide(v.handBox,player) and (not player:mem(0x50,FIELD_BOOL) or player.y+player.height > v.handBox.y+v.handBox.height*0.5)) then
								player:harm();
							end
						end
					end
					
					c = vectr.v2(x,y);
					v.target.x = v.targetobj.x;
					v.target.y = v.targetobj.y;
					
					local rotdir = (v.target-j):normalise();
					local angle = (math.atan2(rotdir.y, rotdir.x) - math.atan2(-0.7071068,-0.7071068)) / imagic.DEG2RAD;
					angle = angle + 180;
					
					
					if(v.stuntimer > 0) then
						v.stuntimer = v.stuntimer - 1;
						if(v.stuntimer == 0) then
							v.vibrate = 0;
							Sound(audio.hand_stun_recover);
						elseif(v.stuntimer < 64) then
							v.vibrate = 4;
						end
						local newrot = math.anglelerp(v.rotation, 45, 0.2);
						v.hand:Rotate(newrot-v.rotation);
						v.rotation = newrot;
					else
						if(stunRecovery) then
							angle =  math.anglelerp(v.rotation, angle, 0.1)
						end
						
						if(stunRecovery or not stunned) then
							angle =  math.anglelerp(v.rotation, angle, 0.6);
							v.hand:Rotate(angle - v.rotation);
							v.rotation = angle;
						end
					end
				end
			end
		end
		--Graphics.glDraw{vertexCoords = verts, primitive = Graphics.GL_LINES, sceneCoords=true}
	end
	armemit.x = x;
	armemit.y = y;
end

local function populatePlates(num)
	for k,v in ipairs(smokepos) do
		smokepos[k] = nil;
	end
	for i=1,num,1 do
		smokepos[i] = {};
	end
	numPlates = num;
end

local function HandlePlates(speed, radiusScale)
	if(numPlates ~= #smokepos) then
		populatePlates(numPlates);
	end

	ellipse.f1.y = ellipse.f1.y + 0.9*math.sin(0.05*lunatime.tick());
	ellipse.f2.y = ellipse.f2.y + 0.85*math.sin(0.043*lunatime.tick());
	
	for i = 1,numPlates,1 do
		local DM = (ellipse.f1 - ellipse.f2):normalise();
		local Dm = (DM:tov3()^vectr.forward3):tov2();
		local RM = radiusScale*math.sqrt((ellipse.f1 - ellipse.f2).sqrlength + ellipse.Rm*ellipse.Rm*radiusScale*radiusScale);
		
		local t = speed*lunatime.tick() + math.pi*(2/numPlates)*i;
		if(smokepos[i] ~= nil) then
			smokepos[i].t = t;
			smokepos[i].vec = RM * math.cos(t) * DM + ellipse.Rm *radiusScale * math.sin(t) * Dm;
			smokepos[i].vec = smokepos[i].vec + vectr.up2*16*radiusScale*math.sin(t*2 + 0.013*lunatime.tick());
			if(smokepos[i].obj == nil) then
				smokepos[i].obj = imagic.Box{texture = smoke, x = 0, y = 0, width = 32, height = 32, scene = true, align = imagic.ALIGN_CENTRE};
				smokepos[i].rot = rng.random(0,60);
				smokepos[i].rotspd = rng.random(0,7);
				smokepos[i].col = rng.random(0,1);

			end
			smokepos[i].rot = (smokepos[i].rot + smokepos[i].rotspd)%360;
			smokepos[i].col = (smokepos[i].col + 0.01)%1;
		end
	end
end

local function IKMove(target, bns)
	if(#bns < 2) then return; end
	
	local elasticLength = 75;
	
	local lens = {};
	local bones = {vectr.v2(x,y)};
	
	for k,v in ipairs(bns) do
		bones[k+1] = v;
	end
	
	local lenTot = 0;
	local lenBase = 0;
	local lenBranch = 0;
	
	for k,v in ipairs(bones) do
		if(k < #bones) then
			lens[k] = (bones[k+1]-v).length;
			lenTot = lenTot + lens[k];
			if(k > 1) then
				lenBranch = lenBranch + lens[k];
			end
		end
	end
	
	lenBase = lens[1] - lenBranch;
	
	if(lenBase < 0) then
		lenBase = 0;
	end
	
	local range = (target - bones[1]).length;
	
	if(useStraightArms) then
		for k,v in ipairs(lens) do
			lens[k] = vectr.lerp(v,range/#lens,0.5);
		end
	else
		--E-FABRIK length elasticity
		for k,v in ipairs(lens) do
			lens[k] = vectr.lerp(v,elasticLength,0.01);
		end
		
		--E-FABRIK length retract (shrinks arms at close ranges to ensure target is reachable)
		if(range < lenBase) then
			local lenSub = (range+lenBranch-lens[1])/(#lens-1);
			for k,v in ipairs(lens) do
				lens[k] = v-lenSub;
			end
		end
		
		--E-FABRIK length extend (extends arms at far ranges to ensure target is reachable)
		if(range > lenTot) then
			local lenAdd = (range-lenTot)/#lens;
			for k,v in ipairs(lens) do
				lens[k] = v+lenAdd;
			end
		end
	end
	
	local t;
	local start = bones[1];
	
	
	for iter = 1,4,1 do --Iteration loop
		for i = -1,1,2 do --Forward Backward loop
			local k;
			if(i < 0) then
				k = #bones;
				t = target;
			else
				k = 1;
				t = start;
			end
			while(bones[k+i]) do
				bones[k] = t;
				local dir = (bones[k+i]-t):normalise();
				if(i < 0) then
					bones[k+i] = t + (dir*lens[k-1]);
				else
					bones[k+i] = t + (dir*lens[k]);
				end
				
				t = bones[k+i];
				k = k+i;
			end
		end
		if((bones[#bones] - target).sqrlength < 1) then
			break;
		end
	end
	
	for k,v in ipairs(bones) do
		if(k > 1) then
			bns[k-1] = bones[k];
		end
		--E-FABRIK step 3
		if(k == #bones) then
			bns[k-1] = target;
		end
	end
	--[[]
	--Reorient end bone
	local lastBone = bones[#bones];
	local prevBone = bones[#bones-1];
	bones[#bones] = target;
	local dir = (lastBone-target):normalise();
	bones[#bones-1] = target + dir*lens[#bones-1];
	
	for k,v in ipairs(bones) do
		if(k < #bones-1) then
			local d = (bones[k+1]-v):normalise();
			local oldLen = (bones[k+1]-v).length;
			local a = 0.9;
			if(k == 1) then
				a = 0.999999;
			end
			local newLen = vectr.lerp(oldLen,lens[k],a);
			local midp = (v + oldLen*d*0.5);
			bones[k] = midp - d*newLen*0.5;
			bones[k+1] = midp + d*newLen*0.5;
		end
	end
	
	for k,v in ipairs(bones) do
		if(k < #bones) then
			local d = (bones[k+1]-v):normalise();
			local oldLen = (bones[k+1]-v).length;
			local a = 0.99;
			if(k == 1) then
				a = 0.999999
			elseif(k >= #bones-1) then
				a = 0;
			end
			local newLen = vectr.lerp(oldLen,lens[k],a);
			bones[k+1] = v+d*newLen;
		end
		if(k < #bones) then
			bns[k] = bones[k+1];
		end
	end]]
end

local decelDist = 256;

local function computeNewPos(v,target,speed)
	local d = (target-v);
	local dist = d.length;
	if(dist <= 4) then
		return target;
	end
	local s = speed;
	if(dist < decelDist) then
		s = math.sqrt(speed*speed*dist/decelDist); --SUVAT yo
	end
	s = math.min(s,dist)
	return v + d:normalise()*s;
end

local function initMoveEvent(v,target,t)
	local timer = lunatime.toTicks(t);
	local d = (v-target).length;
	return (d+2*decelDist)/timer;
end

local function SetArmPos(idx, pos)
	IKMove(pos, arms[idx].joints);
end
	
local function MoveArm(idx, target, speed)
	local v = vectr.v2(arms[idx].hand.x, arms[idx].hand.y);
	local d = (v-target).length;
	if(v.x == 0 or v.y == 0 or d <= 4) then
		v = target;
	end
	SetArmPos(idx, computeNewPos(v,target,speed));
end

local armEvent = {};
local bodyEvent = nil;

local function signalChecks()
	for i = 1,4 do
		if(armEvent[i] == nil) then
			eventu.signal("ARM_"..i)
		end
	end
	if(bodyEvent == nil) then
		eventu.signal("BODY");
	end
end

local function abortArmMove(idx)
	if(armEvent[idx]) then
		eventu.abort(armEvent[idx]);
		armEvent[idx] = nil;
		eventu.signal("ARM_"..idx)
	end
end

local function DoArmMove(idx, target, t)
	local a,b = eventu.run(function()
		local v = vectr.v2(arms[idx].hand.x, arms[idx].hand.y);
		local speed = initMoveEvent(v, target, t);
		while(true) do
			MoveArm(idx, target, speed);
			eventu.waitFrames(0);
			if((vectr.v2(arms[idx].hand.x, arms[idx].hand.y)-target).length <= 4) then
				break;
			end
		end
		armEvent[idx] = nil;
		eventu.signal("ARM_"..idx)
	end)
	armEvent[idx] = b;
	return a,b;
end

local function SetBodyPos(v)
	x = v.x;
	y = v.y;
	for i = 1,4 do
		arms[i].joints[1].x = x;
		arms[i].joints[1].y = y;
		IKMove(arms[i].joints[#arms[i].joints], arms[i].joints);
	end
end

local function MoveBody(target, speed)
	local v = vectr.v2(x, y);
	local d = (v-target).length;
	if(v.x == 0 or v.y == 0 or d <= 4) then
		v = target;
	end
	v = computeNewPos(v,target,speed);
	SetBodyPos(v);
end

local function abortBodyMove()
	if(bodyEvent) then
		eventu.abort(bodyEvent);
		bodyEvent = nil;
		eventu.signal("BODY")
	end
end

local function abortSubphases()
	for k,v in pairs(subphases) do
		eventu.abort(v);
		subphases[k] = nil;
	end
end

local function abortAll()
	abortBodyMove();
	for i = 1,4 do
		abortArmMove();
	end
	abortSubphases();
end

local function DoBodyMove(target, t)
	abortBodyMove();
	local a,b = eventu.run(function()
		local v = vectr.v2(x, y);
		local speed = initMoveEvent(v, target, t);
		while(true) do
			MoveBody(target, speed);
			eventu.waitFrames(0);
			if((vectr.v2(x, y)-target).length <= 4) then
				break;
			end
		end
		eventu.signal("BODY")
		bodyEvent = nil;
	end)
	bodyEvent = b;
	return a,b;
end

local function waitForArm(idx)
	if(idx == nil) then
		return waitForArm{1,2,3,4};
	end
	if(type(idx) == "table") then
		local t = {}
		for _,v in ipairs(idx) do
			table.insert(t, "ARM_"..v);
		end
		return eventu.waitSignal(t);
	else
		return eventu.waitSignal("ARM_"..idx);
	end
end

local function waitForBody()
	return eventu.waitSignal("BODY");
end

local function waitForArmAndBody(idx)
	if(type(idx) == "table") then
		local t = {"BODY"}
		for _,v in ipairs(idx) do
			table.insert(t, "ARM_"..v);
		end
		return eventu.waitSignal(t);
	else
		return eventu.waitSignal("ARM_"..idx);
	end
end

local function waitForAll()
	local t = {"BODY"}
	for i = 1,4 do
		table.insert(t, "ARM_"..i);
	end
	return eventu.waitSignal(t);
end
	
local function IKUpdate(bns)
	IKMove(bns[#bns], bns);
end

local function waitPhase()
	return eventu.waitSignal("PHASE")
end

local function stopMoveEvent()
	if(movement_loop) then
		if(move_event) then 
			eventu.abort(move_event);
			move_event = nil;
		end
		eventu.abort(movement_loop);
		movement_loop = nil;
	end
end

local function startMoveEvent(instant)
	if(instant == nil) then
		instant = false;
	end
	stopMoveEvent();
	local _,e = eventu.run(function()
		local timer = 1;
		if(not instant) then
			timer = rng.random(600); 
		end
		while(true) do
			if(timer <= 0) then 
				timer = rng.random(600); 
				local _,r = DoBodyMove(Zero+vectr.v2(rng.random(moveBoundsX.x,800-moveBoundsX.y),rng.random(moveBoundsY.x,600-moveBoundsY.y)), rng.random(2,4));
				move_event = r;
				waitForBody();
				move_event = nil;
			end
			timer = timer - 1;
			eventu.waitFrames(0);
		end
	end);
	movement_loop = e;
end

local function orientArms()
	local angles = {};
	local base = -vectr.right2;
	
	for i = 1,4 do
		local v = vectr.v2(arms[i].hand.x - x, arms[i].hand.y - y);
		
		local cs = (base..v)/v.length;
		local sn = (vectr.forward3^base:tov3()):tov2()..v/v.length;
		
		local t = math.acos(cs);
		if(sn < 0) then
			t = 2*math.pi - t;
		end
		
		angles[i] = {v = arms[i], ang = t};
	end
	
	table.sort(angles, function(a,b) return a.ang < b.ang end);
	
	for i = 1,4 do
		arms[i] = angles[i].v;
	end
	
	arms[3],arms[4] = arms[4],arms[3];
end

--------------
--	PHASES	--
--------------

local function phase_idle()
	if(arms[1] ~= nil) then 
		for i = 1,4 do
			arms[i].targetobj = player;
		end
	end
	--orientArms();
	while(true) do
		if(arms[1] ~= nil) then
			--Idle arm anim
			MoveArm(1, vectr.v2(x-200-64*math.sin(lunatime.tick()/100), y-100+64*math.cos(lunatime.tick()/100)), 5);
			MoveArm(2, vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +14), y-60+64*math.cos(lunatime.tick()/100 + 14)), 5);
			MoveArm(3, vectr.v2(x-200-64*math.sin(lunatime.tick()/100 +37), y+100+64*math.cos(lunatime.tick()/100 + 37)), 5);
			MoveArm(4, vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +73), y+120+64*math.cos(lunatime.tick()/100 + 73)), 5);
		end
		
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
	
	local _,c = eventu.run(phase, table.join({intensifies = intensifies}, args))
	current_phase = c;
end

function events.Stun(timer)
	if(stunned) then
		return;
	end
	
	Sound(audio.stun);
	Voice(audio.voice.stun);
	
	stunned = true;
	abortAll();
	local t = timer;
	setPhase(function()
		stopMoveEvent();
		local pos = vectr.v2(x,y);
		
		local armpos = {}
		for i = 1,4 do
			armpos[i] = vectr.v2(arms[i].hand.x,arms[i].hand.y);
		end
		local speed = 0;
		local armspd = {0,0,0,0};
		local flr = Zero.y+600-64;
		
		eventu.waitFrames(64);
		
		while(true) do
			speed = speed + 1;
			for i = 1,4 do
				armspd[i] = armspd[i]+1;
				armpos[i] = armpos[i]+vectr.up2*armspd[i];
				if(armspd[i] > 0 and armpos[i].y > flr) then
					armpos[i].y = flr;
					armspd[i] = 0;
				end
				
				SetArmPos(i, armpos[i]);
				
			end
			pos = pos+vectr.up2*speed;
			if(speed > 0 and pos.y > flr) then
				pos.y = flr;
				if(speed > 1) then
					Sound(audio.thud, math.clamp(speed/10));
				end
				speed = -speed*0.5;
			end
			SetBodyPos(pos);
			t = t-1;
			
			for i = 1,4 do
				arms[i].targetobj = pos;
			end
			
			if(t > 0 and t < 128) then
				stunRecovery = true;
				for i = 1,4 do
					armpos[i] = armpos[i] + vectr.up2:rotate(rng.random(360))*rng.random(4);
				end
			end
			if(t == 0) then
				for i = 1,4 do
					DoArmMove(i, pos, 0.5);
				end
				Sound(audio.whoosh);
				eventu.waitFrames(8);
				Sound(audio.whoosh);
				waitForArm();
				for i = 1,4 do
					arms[i].targetobj = player;
				end
				stunned = false;
				stunRecovery = false;
				plateIndex = math.min(plateIndex+1, #plateCounts);
				UpdatePlates(plateCounts[plateIndex]);
				startMoveEvent();
				setPhase();
				return;
			end
			eventu.waitFrames(0)
		end
		
	end);
end

local function phase_armattack1()
	for i = 1,4 do
		arms[i].targetobj = player;
	end
	stopMoveEvent();
	local side = rng.randomInt(0,1);
	local bodyCentre = Zero+vectr.v2(side*(800-128) + 64,64);
	DoBodyMove(bodyCentre, 2);
	
	side = 1-(2*side);
	
	DoArmMove(1, bodyCentre + vectr.v2(side*64,48), 2);
	DoArmMove(2, bodyCentre + vectr.v2(side*56,64), 2);
	DoArmMove(3, bodyCentre + vectr.v2(side*64,56), 2);
	DoArmMove(4, bodyCentre + vectr.v2(side*48,64), 2);
	
	waitForAll();
	
	arms[1].vibrate = 4;
	arms[1].stuntimer = 0;
	
	eventu.waitFrames(16);
	
	for i = 1,4 do
		arms[i].vibrate = 0;
		local p = getPlayerPos();
		local dir = (p-vectr.v2(arms[i].hand.x,arms[i].hand.y)):normalise();
		p = p + (dir*256);
		arms[i].targetobj = p + dir;
		Sound(audio.whoosh);
		DoArmMove(i, p, 0.6);
		
		if(not intensifies) then
			eventu.waitFrames(48-16);
		end
		
		if(i < 4) then
			arms[i+1].vibrate = 4;
			arms[i+1].stuntimer = 0;
		end
		eventu.waitFrames(choose(16,12));
	end
	
	DoBodyMove(Zero+vectr.v2(rng.random(64,800-64), rng.random(64, 300-64)), 2);
	eventu.waitFrames(32);
	
	local _;
	_,subphases[1] = eventu.run(phase_idle);
	
	waitForBody();
	
	eventu.waitFrames(32);
	
	abortSubphases();
	
	startMoveEvent();
	setPhase();
end
--[[ --old pinwheel
local function phase_armattack2_old()
	for i = 1,4 do
		arms[i].targetobj = player;
	end
	useStraightArms = true;
	stopMoveEvent();
	
	local bodyCentre = Zero+vectr.v2(rng.random(64,800-64), rng.random(64,256));
	
	DoBodyMove(bodyCentre,2);
	
	
	local r = 128;
	local spd = 0;
	
	local armpos = {(-vectr.up2)}
	for i = 2,4 do
		armpos[i] = armpos[i-1]:rotate(90);
	end
	
	do
		local t = armpos[3];
		armpos[3] = armpos[4];
		armpos[4] = t;
	end
	
	for i = 1,4 do
		DoArmMove(i, bodyCentre + r*armpos[i], 2);
	end
	
	waitForAll();
	eventu.waitFrames(16);
	
	local t = choose(720,500);
	while(t > 0) do
		t = t-1;
		bodyCentre = vectr.v2(x,y);
		local d = (getPlayerPos()-bodyCentre)
		
		local dist = d.length;
		if(dist > 1) then
			d = d:normalise();
		end
		
		bodyCentre = bodyCentre + d;
		
		SetBodyPos(bodyCentre);
		
		local radchange = choose(0.5,0.3);
		if(dist > r) then
			r = r+radchange;
		else
			r = r-radchange;
		end
		
		r=math.max(r,choose(64,128));
		
		local armx = armpos[1].x;
		local army = armpos[1].y;
		
		for i = 1,4 do
			armpos[i] = armpos[i]:rotate(spd);
			SetArmPos(i, bodyCentre+r*armpos[i]);
		end
		
		if((armx >= 0 and armpos[1].x < 0) or (armx <= 0 and armpos[1].x > 0) or
		   (army >= 0 and armpos[1].y < 0) or (army <= 0 and armpos[1].y > 0)) then
			Sound(audio.whoosh, math.clamp(math.abs(spd)/3));
		end
		
		
		if(t > math.abs(spd*100)) then
			if(d.x < 0 or intensifies) then
				spd = spd - choose(0.01,0.02);
			elseif(d.x > 0) then
				spd = spd + 0.01;
			end
		elseif(spd > 0) then
			spd = spd - 0.01;
		elseif(spd < 0) then
			spd = spd + 0.01;
		end
		spd = math.clamp(spd,-3,3);
		eventu.waitFrames(0);
		
	end
	t=32
	spd = 1;
	while(t > 0) do
		t = t-1;
		
		spd = spd-1/32;
		
		bodyCentre = vectr.v2(x,y);
		local d = (getPlayerPos()-bodyCentre)
		local dist = d.length;
		if(dist > 1) then
			d = d:normalise();
		end
		
		bodyCentre = bodyCentre + d * spd;
	end
	
	eventu.waitFrames(32);
	
	useStraightArms = false;
	
	startMoveEvent();
	setPhase();
end
]]

local function phase_armattack2()
	for i = 1,4 do
		arms[i].targetobj = player;
	end
	useStraightArms = true;
	stopMoveEvent();
	
	local bodyCentre = Zero+vectr.v2(rng.random(64,800-64), rng.random(64,256));
	
	DoBodyMove(bodyCentre,2);
	
	
	local r = choose(256,192);
	local spd = 0;
	local spin = 1.5;
	
	
	local armpos = {(-vectr.up2)}
	for i = 2,4 do
		armpos[i] = armpos[i-1]:rotate(90);
	end
	
	do
		local t = armpos[3];
		armpos[3] = armpos[4];
		armpos[4] = t;
	end
	
	for i = 1,4 do
		DoArmMove(i, bodyCentre + r*armpos[i], 2);
	end
	
	waitForAll();
	
	if(not intensifies) then
		eventu.waitFrames(16);
	end
	
	local accel = choose(0.015,0.03);
	local target = vectr.v2(800-64, 600-32-r);
	
	if(getPlayerPos().x < bodyCentre.x) then
		accel = -accel;
		target.x = 800-target.x;
	end
	
	local t = choose(720,400);
	local vel = vectr.v2(0,0);
	
	local movspd = 2.5;
	while(t > 0) do
		t = t-1;
		bodyCentre = vectr.v2(x,y);
		local d = (Zero + target-bodyCentre);
		
		local dist = d.length;
		if(dist > movspd) then
			d = d:normalise()*movspd;
		elseif(dist < 1) then
			target.x = 800-target.x;
		end
		
		vel = math.lerp(vel, d, 0.2);
		
		bodyCentre = bodyCentre + vel;
		
		SetBodyPos(bodyCentre);
		
		local armx = armpos[1].x;
		local army = armpos[1].y;
		
		for i = 1,4 do
			armpos[i] = armpos[i]:rotate(spd);
			SetArmPos(i, bodyCentre+r*armpos[i]);
		end
		
		if((armx >= 0 and armpos[1].x < 0) or (armx <= 0 and armpos[1].x > 0) or
		   (army >= 0 and armpos[1].y < 0) or (army <= 0 and armpos[1].y > 0)) then
			Sound(audio.whoosh);
		end
		
		if(t > 128) then
			spd = spd + accel;
		else
			spd = spin*(spd/math.abs(spd)) * (t/128);
		end
		
		spd = math.clamp(spd,-spin,spin);
		
		eventu.waitFrames(0);
		
	end
	t=32
	spd = vectr.v2(vel.x, vel.y);
	while(t > 0) do
		t = t-1;
		
		vel = math.lerp(vectr.zero2, spd, t/32);
		
		SetBodyPos(vectr.v2(x,y) + vel);
		eventu.waitFrames(0);
	end
	
	if(not intensifies) then
		eventu.waitFrames(32);
	end
	
	useStraightArms = false;
	
	startMoveEvent();
	setPhase();
end

--[[ --old grabbyhands
local function phase_armattack3_old()

	local armpos = {-vectr.up2:rotate(-45)}
	local r = 300;
	local maxr = r;

	for i = 1,4 do
		arms[i].targetobj = player;
		
		if(i > 1) then
			if(i == 3) then
				armpos[i] = armpos[i-1]:rotate(180);
			elseif(i == 4) then
				armpos[i] = armpos[i-1]:rotate(-90);
			else
				armpos[i] = armpos[i-1]:rotate(90);
			end
		end
	end
	
	DoArmMove(1, Zero + vectr.v2(128,128), 2);
	DoArmMove(2, Zero + vectr.v2(800-128,128), 2);
	DoArmMove(3, Zero + vectr.v2(128,600-128), 2);
	DoArmMove(4, Zero + vectr.v2(800-128,600-128), 2);
	
	waitForArm();
	
	local t = choose(350,200);
	local maxt = t;
	while(t > 0) do
		t = t-1;
		r = math.lerp(maxr, 96, 1-(t/maxt));
		
		for i = 1,4 do
			MoveArm(i, getPlayerPos() + r*armpos[i], math.lerp(4,8,t/maxt));
		end
		eventu.waitFrames(0);
	end
	
	local p = getPlayerPos();
	for i = 1,4 do
		arms[i].targetobj = p;
	end
	eventu.waitFrames(choose(48,96));
	
	for i = 1,4 do
		DoArmMove(i, p, 0.2);
	end
	Sound(audio.whoosh);
	
	eventu.waitFrames(32);

	setPhase();
end
]]

local function getCoordOffscreen(maxheight, includeBottom)
	local mx = 3;
	if(includeBottom) then mx = 4 end;
	local side = rng.randomInt(1,mx);
	if(side == 1) then
		return vectr.v2(-32,rng.random(-32,maxheight));
	elseif(side == 2) then
		return vectr.v2(rng.random(-32,800+32),-32);
	elseif(side == 3) then
		return vectr.v2(800+32,rng.random(-32,maxheight));
	else --if(side == 4) then
		return vectr.v2(rng.random(-32,800+32),maxheight);
	end
end

local function phase_armattack3()

	local t = 0;
	local maxt = 128;
	
	moveBoundsX.x = 128;
	moveBoundsX.y = 128;
	moveBoundsY.x = 128;
	moveBoundsY.y = 256;
	
	DoBodyMove(Zero + vectr.v2(400,300), 2)
	
	--[[
	DoArmMove(1, Zero + vectr.v2(-32,-32), 2);
	DoArmMove(2, Zero + vectr.v2(800+32,-32), 2);
	DoArmMove(3, Zero + vectr.v2(-32,600+32), 2);
	DoArmMove(4, Zero + vectr.v2(800+32,600+32), 2);
	]]
	DoArmMove(1, Zero + vectr.v2(267,-32), 2);
	DoArmMove(2, Zero + vectr.v2(533,-32), 2);
	DoArmMove(3, Zero + vectr.v2(-32,-32), 2);
	DoArmMove(4, Zero + vectr.v2(800+32,-32), 2);
	
	Sound(audio.fog);
	
	while(t < maxt) do
		globalfog = t/maxt;
		t = t+1;
		if(t >= maxt*0.5) then
			emitfgfog = true;
		end
		eventu.waitFrames(0);
	end
	
	local handPos = {};
	
	local function prepareHand(i,h)
		local c = Zero+getCoordOffscreen(h);
		SetArmPos(i, c);
		table.insert(handPos, c);
		return c;
	end
	
	local function launchHand(i, c)
		local d = (getPlayerPos() - c):normalise();
		arms[i].targetobj = c+(d*1400);
		DoArmMove(i, c+(d*1400), choose(2,3));
	end
	
	if(not intensifies) then
		for i = 1,4 do
			local c = prepareHand(i,choose(400,300));
			eyeTarget = handPos[1];
			eventu.waitFrames(32);
			eyeTarget = nil;
			Sound(audio.whoosh);
			launchHand(i, c);
			handPos = {};
			eventu.waitFrames(64);
		end
	
		waitForArm();
	end
	
	for i = 1,4,2 do
		local c1 = prepareHand(i,choose(400,300));
		eventu.waitFrames(0);
		local c2 = prepareHand(i+1,choose(400,300));
		eyeTarget = handPos[1];
		eventu.waitFrames(32);
		eyeTarget = handPos[2];
		eventu.waitFrames(32);
		eyeTarget = nil;
		Sound(audio.whoosh);
		launchHand(i, c1);
		launchHand(i+1, c2);
		handPos = {};
		eventu.waitFrames(choose(64,48));
	end
	
	local eyevec = vectr.v2(-100,0);
	
	local t2 = 32;
	while(t2 > 0) do
		local a = 1- (t2/32);
		eyeTarget = vectr.v2(x, y)+eyevec:rotate(a*180);
		t2 = t2-1;
		eventu.waitFrames(0);
	end
	
	waitForArm();
	
	resetMoveBounds();
	
	for i = 1,4 do
		prepareHand(i,100);
		eventu.waitFrames(0);
	end
	
	eyeTarget = nil;
	
	Sound(audio.whoosh);
	Sound(audio.whoosh);
	for i = 1,4 do
		local p = vectr.v2(arms[i].hand.x, arms[i].hand.y);
		arms[i].targetobj = getPlayerPos() + (getPlayerPos()-p);
		DoArmMove(i, getPlayerPos(), 1);
	end
	
	waitForArm();
	
	eventu.waitFrames(64);
	
	emitfgfog = false;
	while(t > 0) do
		globalfog = t/maxt;
		t = t-1;
		eventu.waitFrames(0);
	end
	
	eventu.waitFrames(32);

	setPhase();
end

local function phase_danmaku1()
	for i = 1,4 do
		arms[1].targetobj = player;
	end
	
	if(intensifies) then
		eventu.waitFrames(32);
	end
	
	DoArmMove(1, Zero + vectr.v2(32,32), 2);
	DoArmMove(2, Zero + vectr.v2(800-32,32), 2);
	DoArmMove(3, Zero + vectr.v2(32,600-32), 2);
	DoArmMove(4, Zero + vectr.v2(800-32,600-32), 2);
	
	waitForArm{1,2,3,4};
	
	for i = 1,4 do
		local spawnpos = vectr.v2(arms[i].hand.x, arms[i].hand.y);
		spawnHitflash(1, spawnpos, vectr.v2(32,32));
		eventu.waitFrames(choose(16,8));
		for j = 1,choose(8,5) do
			if(arms[i].stuntimer == 0) then
				local dir = (getPlayerPos() - spawnpos):normalise();
				spawnBullet(BULLET_SMALL, spawnpos + dir*16, dir*3.5);
				Sound(audio.bullet_small);
			end
			eventu.waitFrames(choose(28,14));
		end
		eventu.waitFrames(choose(24,12));
	end
	
	eventu.waitFrames(choose(128,86));
	
	setPhase();
end

local function phase_danmaku2()

	stopMoveEvent();
	
	local side = rng.randomInt(0,1);
	
	local bodyCentre = Zero+vectr.v2(side*(800-128) + 64,64);
	
	DoBodyMove(bodyCentre, 2);
	
	side = 1-(2*side);
	
	local baseangle = 5;
	local armpos = 128 * vectr.right2:rotate(baseangle);
	
	local armlocs = {}
	
	for i = 1,4 do
		armlocs[i] = vectr.v2(side*armpos.x, armpos.y);
		DoArmMove(i, bodyCentre + armlocs[i], 2);
		
		arms[i].targetobj = bodyCentre + armlocs[i]*1.1;
		
		armpos = armpos:rotate((90-(2*baseangle))/3);
	end
	
	waitForAll();
	
	for i = 1,3 do
		for j = 1,4 do
			eventu.waitFrames(choose(48,8));
			if(arms[i].stuntimer == 0) then
				Sound(audio.bullet_med);
				spawnBullet(BULLET_MED, bodyCentre + armlocs[j], armlocs[j]:normalise():rotate(choose(rng.random(-5,5),0))*choose((getPlayerPos() - bodyCentre).length/rng.random(70,80), 5));
			end
		end
		if(intensifies) then
			eventu.waitFrames(56);
		end
	end
	
	eventu.waitFrames(256);
	
	startMoveEvent();
	setPhase();
end

local function getRectEdgeFromAngle(angle, w, h)
	
	w=w*0.5;
	h=h*0.5;
	
	local v = vectr.v2(math.cos(math.rad(angle)), math.sin(math.rad(angle)));
	
	local t = math.min(math.abs(w/v.x), math.abs(h/v.y));
	
	return v*t;
end

local function phase_danmaku3()
	stopMoveEvent();
	
	local w,h = 800-64, 600-64
	local angles = { math.deg(math.atan(h/w)) };
	
	angles[2] = -angles[1];
	angles[3] = angles[2]+180;
	angles[4] = -angles[3];
	
	angles[1],angles[4] = angles[4],angles[1]
	
	DoBodyMove(Zero + vectr.v2(400,300), 2);
	
	for i = 1,4 do
		DoArmMove(i, Zero + vectr.v2(400,300) + getRectEdgeFromAngle(angles[i], w, h), 2);
		arms[i].targetobj = Zero + vectr.v2(400,300);
	end
	
	waitForAll();
	eventu.waitFrames(choose(64,16));
	
	local t = choose(720,300);
	local shootTime = choose(42,26);
	while(t > 0) do
		t = t-1;
		local shoot = false;
		for i = 1,4 do
			angles[i] = (angles[i]+choose(0.4,0.3))%360;
			MoveArm(i, Zero + vectr.v2(400,300) + getRectEdgeFromAngle(angles[i], w, h), 50);
			if((t--[[+((math.ceil(i*0.5)-1)*shootTime/2)]])%shootTime == 0 and arms[i].stuntimer == 0) then
				local p = vectr.v2(arms[i].hand.x,arms[i].hand.y)
				spawnBullet(BULLET_SMALL, p, (arms[i].target-p):normalise()*3.5);
				shoot = true;
			end
		end
		if(shoot) then
			Sound(audio.bullet_small);
		end
		eventu.waitFrames(0);
	end
	
	eventu.waitFrames(128);
	
	local c = Zero + vectr.v2(400,300);
	for i = 1,4 do
		DoArmMove(i, c + (vectr.v2(arms[i].hand.x, arms[i].hand.y)-c):normalise()*96, 3);
	end
	
	waitForArm();
	
	eventu.waitFrames(32);
	
	for i = 1,4 do
		arms[i].targetobj = player;
	end
	
	startMoveEvent();
	setPhase();
end

local function phase_tennis()
	stopMoveEvent();
	
	repeat
		local bodyPos = Zero+vectr.v2(400,400)+(vectr.v2(-300,0):rotate(rng.random(180)));
		DoBodyMove(bodyPos, 2);
		
		
		local side = 0;
		if(bodyPos.x - Zero.x < 300) then
			side = -1;
		elseif(bodyPos.x - Zero.x > 500) then
			side = 1;
		end
		
		local corners = {}
		if(side == 0) then
			corners[1] = bodyPos+vectr.v2(-48,48);
			corners[2] = bodyPos+vectr.v2(48,48);
			corners[3] = bodyPos+vectr.v2(-48,144);
			corners[4] = bodyPos+vectr.v2(48,144);
		else
			corners[1] = bodyPos+vectr.v2(48*-side,-48);
			corners[2] = bodyPos+vectr.v2(48*-side,48);
			corners[3] = bodyPos+vectr.v2(144*-side,-48);
			corners[4] = bodyPos+vectr.v2(144*-side,48);
		end
		
		local centre = vectr.zero2;
		for i=1,4 do
			DoArmMove(i, corners[i], 2);
			centre = (centre + corners[i]);
		end
		centre = centre/4;
		
		for i=1,4 do
			arms[i].targetobj = centre;
		end
		
		waitForAll();
	
		eventu.waitFrames(16);
		
		spawnLargeBullet(centre);
		
		while(largeBullet.launchTimer > 0) do
			local t = 1 - (largeBullet.launchTimer/largeBulletChargeTime);
			for i=1,4 do
				MoveArm(i, ((corners[i]-centre):rotate(t*t*720))*math.lerp(1,0.75,t) + centre + t*t*32*vectr.up2:rotate(rng.random(360)), 12);
			end
			eventu.waitFrames(0);
		end
		
		local dir = (getPlayerPos()-centre):normalise();
		for i=1,4 do
			DoArmMove(i, corners[i] - dir*64, 1);
		end
		waitForArm();
		eventu.waitFrames(4);
		
		local _;
		_,subphases[1] = eventu.run(phase_idle);
		
		local targetIsBoss = true;
		while(true) do
			if(stunned) then
				return;
			end
			if(largeBullet == nil) then
				break;
			end
			if(not targetIsBoss and largeBullet.target == nil) then
				targetIsBoss = true;
			elseif(targetIsBoss and largeBullet.target == player) then
				targetIsBoss = false;
				local px = (getPlayerPos().x - Zero.x);
				
				local n = vectr.v2(rng.random(64,800-64),0);
				if(math.abs(px-n.x) > 256) then
					n.y = rng.random(64,600-300)
				else
					n.y = rng.random(64,600-450)
				end
				
				DoBodyMove(Zero+n, rng.random(1,2));
				waitForBody();
			end
			eventu.waitFrames(0);
		end
		
		abortSubphases();
		
	until(false);
end


local function phase_supertennis()
	stopMoveEvent();
	
	local bodyPos = Zero+vectr.v2(400,400)+(vectr.v2(-300,0):rotate(120));
	DoBodyMove(bodyPos, 2);
		
		
	local side = 1;
		
	local corners = {}
	corners[1] = bodyPos+vectr.v2(48*-side,-48);
	corners[2] = bodyPos+vectr.v2(48*-side,48);
	corners[3] = bodyPos+vectr.v2(144*-side,-48);
	corners[4] = bodyPos+vectr.v2(144*-side,48);
		
	local centre = vectr.zero2;
	for i=1,4 do
		DoArmMove(i, corners[i], 2);
		centre = (centre + corners[i]);
	end
	centre = centre/4;
		
	for i=1,4 do
		arms[i].targetobj = centre;
	end
		
	waitForAll();
	
	eventu.waitFrames(16);
	spawnLargeBullet(centre, true);
					
	local tim = 0;
	while(intensifiesTimer > 0) do
		local t = 1 - (largeBullet.launchTimer/largeBulletChargeTime);
		tim = tim + 1;
		
		if(tim == 64) then
			message.showMessageBox {target=player_pos, text="Together, I know you'll do us all proud.<pause 90>", closeWith = "auto", keepOnscreen = true}
		end
		
		for i=1,4 do
			MoveArm(i, ((corners[i]-centre):rotate(t*t*720))*math.lerp(1,0.75,t) + centre + t*t*32*vectr.up2:rotate(rng.random(360)), 12);
		end
		eventu.waitFrames(0);
	end
end

-------------------
--	MAIN EVENTS  --
-------------------

local function bossEvents()	
	eventu.waitFrames(128);
	setPhase(phase_armattack1);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_danmaku1);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_tennis);
	waitPhase();
	
	eventu.waitFrames(128);
	setPhase(phase_armattack2);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_danmaku2);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_tennis);
	waitPhase();
	
	eventu.waitFrames(128);
	setPhase(phase_armattack3);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_danmaku3);
	waitPhase();
	eventu.waitFrames(128);
	setPhase(phase_tennis);
	waitPhase();
	
	while(true) do
		local phaseOptions = {phase_armattack1, phase_armattack2, phase_armattack3, phase_danmaku1, phase_danmaku2, phase_danmaku3}
		for i = 1,2 do
			eventu.waitFrames(128);
			local j = rng.randomInt(1,#phaseOptions);
			setPhase(phaseOptions[j]);
			table.remove(phaseOptions,j);
			waitPhase();
		end
		eventu.waitFrames(128);
		setPhase(phase_tennis);
		waitPhase();
	end
end

local function showPumpMsg(args)
	local boxcol = {boxColor=0x292c4aFF};
	if(args.bloxProps) then
		args.bloxProps = table.join(args.bloxProps, boxcol);
	else
		args.bloxProps = boxcol;
	end
	
	args.text = "<color rainbow>"..string.gsub(args.text, "<page>", "<page><color rainbow>");
	return message.showMessageBox(args);
end

local intensifiesMonologue = {
[2] = "I'm sorry I couldn't stick around longer, girls, but I have no regrets.",
[4] = "Knowing that your story continues, I'm content with mine ending here.",
[5] = "Demo...",
[6] = "and Iris..."
}

local function intensifiesEvents()
	intensifies = true;
	intensifiesTimer = intensifiesTime;
	boss.Active = false;
	local t = 0;
	
	broken_core:Stop();
	
	showPumpMsg {target=eye_pos, text="SAYONARA CAUSALITY!<pause 60>", closeWith="auto"}
	message.waitMessageEnd();
	
	while(true) do
		local phaseOptions = {phase_armattack1, phase_armattack2, phase_danmaku1, phase_danmaku2, phase_danmaku3}
		while(#phaseOptions > 0) do
			eventu.waitFrames(32);
			if(intensifiesTimer > largeBulletEndTime) then
				local j = rng.randomInt(1,#phaseOptions);
				setPhase(phaseOptions[j]);
				table.remove(phaseOptions,j);
				waitPhase();
				t = t + 1;
				if(intensifiesMonologue[t]) then
					message.showMessageBox {target=player_pos, text=intensifiesMonologue[t].."<pause 90>", closeWith = "auto", keepOnscreen = true}
					eventu.waitFrames(64);
				end
			else
				isEnding = true;
				setPhase(phase_supertennis);
				return;
			end
		end
	end
end

local initPos = vectr.v2(0,0);
local initPlayerPos = vectr.v2(0,0);


local function StartBoss()
	Audio.MusicOpen(Misc.resolveFile("music/a2xt-aurevoir.ogg"));
	Audio.MusicPlay();
	
	drawBG = true;
	starttime = lunatime.time();
	boss.Start();
end

local function LowerCoreVolume(ti)
	eventu.run(function()
				local t = ti;
				while(t > 0) do
					t = t-1;
					audioMaster.volume.COREBG = t/ti;
					eventu.waitFrames(0);
				end
				broken_core:Stop();
		end);
end

function cutscene.intro_checkpoint()

	local b = Section(bossAPI.section).boundary;
	b.left = Zero.x-64;
	Section(bossAPI.section).boundary = b;

	player.x = Zero.x-64;
	
	LowerCoreVolume(400);
	
	waitAndDo(128, function()
		player.speedX = 1.5;
		player.FacingDirection = 1; 
	end);
	
	b.left = Zero.x;
	Section(bossAPI.section).boundary = b;
	
	scene.endScene();
	
	StartBoss();
end

function cutscene.intro()

	local b = Section(bossAPI.section).boundary;
	b.left = Zero.x-64;
	Section(bossAPI.section).boundary = b;

	player.x = Zero.x-64;
	
	waitAndDo(128, function() 
		player.speedX = 1.5;
		player.FacingDirection = 1; 
	end);
	
	b.left = Zero.x;
	Section(bossAPI.section).boundary = b;
	
	message.showMessageBox {target=player_pos, text="So this is the accursed ailment. I was expecting something more... corporeal."}
	message.waitMessageEnd();
	
	showPumpMsg {target={x=x, y=y+350, width=0, height = 0}, text="Meh, having a euclidean body is overrated.", bloxProps={hasTail = false}}
	message.waitMessageEnd();
	
	message.showMessageBox {target=player_pos, text="T-that voice!"}
	message.waitMessageEnd();
	
	Audio.SeizeStream(bossAPI.section);
	Audio.MusicVolume(100);
	Audio.MusicOpen(Misc.resolveFile("music/a2xt-smokingisbadforyou.ogg"));
	Audio.MusicPlay();
	
	local t = 256;
	local u = 2*(initPos.y-y)/t;
	local a = -u/t;
	
	local w = (initPos.x-Zero.x+32);
	local basex = 800-w+64;
	local basey = Zero.y-16;
	
	waitAndDo(t, function() 
		y = y + u; 
		u = u + a;
		globalfog = math.max(globalfog - 0.005, 0); 
		w = math.max(w-4,0);
		if(w <= 0) then
			ceilfog.enabled = false;
		else
			ceilfog:setParam("xOffset", -w..":"..math.min(w, basex));
			ceilfog.y = math.lerp(basey, math.max(y,basey), 0.5);
		end
	end);
		
	eyelidFrame = 1;
	eventu.waitFrames(8);
	eyelidFrame = 2;
	eventu.waitFrames(8);
	eyelidFrame = 3;
	eventu.waitFrames(8);
	eyelidFrame = 4;
	eventu.waitFrames(8);
	eyelidFrame = -1;
	eventu.waitFrames(32);
	
	local v = vectr.v2(x, y);
	for i = 1,4 do
		makeArm{ v,v,v };
		MoveArm(i, v, 100);
	end
	populatePlates(plateCounts[plateIndex]);
	armInitTimer = 32;
	eventu.waitFrames(2)
	setPhase();
	
	eventu.waitFrames(16);
	
	showPumpMsg {target=eye_pos, text="You just couldn't leave me alone, could you Augustus?"}
	message.waitMessageEnd();
	
	message.showMessageBox {target=player_pos, text="I take it this is the true Pumpernickel I'm speaking to?<page>A fitting form for such a twisted, detestable soul as yourself."}
	message.waitMessageEnd();
	
	showPumpMsg {target=eye_pos, text="If only I could say the same for that hostility of yours."}
	message.waitMessageEnd();
	
	eventu.waitFrames(16);
	
	showPumpMsg {target=eye_pos, text="Honestly, what is with you lot and your constant antagonism?<page>All I'm trying to do is corrupt one teensy tiny little reality!<page>I'm sure you'll all come to appreciate my efforts once the deed is done."}
	message.waitMessageEnd();
	
	eventu.waitFrames(16);
	
	local function SetReady()
		panim.setFrame(player, 45);
	end
	
	local function waitMsgWhileReady(msg)
		while(msg ~= nil and not msg.deleteMe) do
			SetReady();
			eventu.waitFrames(0);
		end
	end
	
	Audio.SfxPlayCh(-1, Audio.SfxOpen(playerManager.getSound(CHARACTER_UNCLEBROADSWORD, 2)), 0)
	waitAndDo(32, SetReady);
	
	local m = message.showMessageBox {target=player_pos, text="My Brynhilde begs to differ."}
	waitMsgWhileReady(m);
	
	waitAndDo(32, SetReady);
	
	m = showPumpMsg {target=eye_pos, text="<tremble>UGH.</tremble><page>YOU'RE JUST. <tremble>NO.<pause 20> FUN.</tremble><page>Fine. If you must draw your blade on me, let's just get this over with."}
	waitMsgWhileReady(m);
	
	Audio.MusicStopFadeOut(2000);
	
	LowerCoreVolume(400);
	
	eventu.waitFrames(128);
	
	scene.endScene();
	
	cp:collect();
	
	StartBoss();
end

function events.InitBoss(checkpoint)
	Zero.x = Section(bossAPI.section).boundary.left;
	Zero.y = Section(bossAPI.section).boundary.top;
	
	broken_core.x = Zero.x+400;
	broken_core.y = Zero.y+300;
	
	initPos.x = Zero.x+600;
	initPos.y = Zero.y+250;
	
	x = initPos.x;
	y = initPos.y - 400;
	
	ceilfog.x = initPos.x;
	ceilfog.y = Zero.y - 16;
	ceilfog:setParam("xOffset", (Zero.x-initPos.x-32)..":"..800+(Zero.x-initPos.x)+32);
	ceilfog:setPrewarm(2)
	
	
	initPlayerPos.x = player.x+player.width*0.5;
	initPlayerPos.y = player.y+player.height;

	player.character = CHARACTER_UNCLEBROADSWORD;
	player.powerup = 2;
	player.reservePowerup = 9;
	
	globalfog = 0.5;
	
	if(checkpoint) then
		y = y + 400;
		ceilfog.enabled = false;
		globalfog = 0;
		
		makeArm{ vectr.v2(x-80, y-90), vectr.v2(x-140, y-120), vectr.v2(x-200, y-100)};
		makeArm{ vectr.v2(x+50, y-50), vectr.v2(x+100, y-75), vectr.v2(x+160, y-60)};
		makeArm{ vectr.v2(x-100, y+80), vectr.v2(x-130, y+90), vectr.v2(x-200, y+100)};
		makeArm{ vectr.v2(x+50, y+50), vectr.v2(x+100, y+80), vectr.v2(x+160, y+120)};
		
		setPhase();
		
		eyelidFrame = -1;
		
		populatePlates(plateCounts[plateIndex]);
	end
	
	bgShader:compileFromFile(nil, Misc.resolveFile("background.frag"));
	
	if(checkpoint) then
		scene.startScene{scene=cutscene.intro_checkpoint, noletterbox=true}
		--scene.startScene{scene=cutscene.mid, noletterbox=true}
	else
		scene.startScene{scene=cutscene.intro, noletterbox=true}
	end
end

local function damage(damage, stun)
	boss.Damage(damage);
	eyeHitstun = stun;
	Sound(audio.hurt);
	Voice(audio.voice.hurt, 0.75);
end

local mainloop;
local intensifyReady = false;

function cutscene.mid()
	
	audioMaster.volume.COREBG = 1;
	broken_core:Play();

	--Broadsword in ready pose
	
	local function SetReady()
		panim.setFrame(player, 45);
	end
	
	SetReady();
	
	player.speedX = 0.1;
	player.FacingDirection = 1;
	eventu.waitFrames(0);
	player.speedX = 0;
	
	waitAndDo(200, SetReady);
	
	boss.Heal(boss.MaxHP);
	
	waitAndDo(64, SetReady);
	
	showPumpMsg {target=eye_pos, text="Give it up, Augustus!  You can't kill me!"}
	
	waitAndDo(32, SetReady);
	
	message.waitMessageEnd();
	
	--Broadsword walk to centre
	eventu.waitFrames(32);
	local m = message.showMessageBox {target=player_pos, text="That may be, but..."}
	
	while(true) do
		if(player.x < Zero.x+340) then
			player.speedX = 2;
		elseif(m == nil or m.deleteMe) then
			break;
		end
		eventu.waitFrames(0);
	end
	
	
	message.showMessageBox {target=player_pos, text="I don't need to kill you."}
	message.waitMessageEnd();
	--Broadsword press button
	
	local t = 128;
	local initc = tess_colour;
	local rotxyza = -tess_rotspdxyz/t;
	local rotwa = -tess_rotspdw/t;
	
	Sound(audio.core_reset);
	broken_core:Stop();
	
	backgrounds.fliprandomise = false;
	backgrounds.flipnumber = 0;
	flip_stabletime = math.huge;
	backgrounds.consolestate = 0;
	
	waitAndDo(t, function()
		t = t-1;
		local a = t/128;
		
		backgrounds.pulsebrightness = a;
		backgrounds.nebulaspeed = -3*a;
		a = 1-a;
		
		backgrounds.colour = math.lerp(Color.red, Color.black, a);
		
		tess_rotspdxyz = tess_rotspdxyz+rotxyza;
		tess_rotspdw = tess_rotspdw+rotwa;
		tess_colour = math.lerp(initc, Color.black, a);
		tess.rotationXYZ.x = math.rad(math.anglelerp(math.deg(tess.rotationXYZ.x),50,a));
		tess.rotationXYZ.y = math.rad(math.anglelerp(math.deg(tess.rotationXYZ.y),45,a));
		tess.rotationXYZ.z = math.rad(math.anglelerp(math.deg(tess.rotationXYZ.z),0,a));
		tess.rotationW.x = math.rad(math.anglelerp(math.deg(tess.rotationW.x),0,a));
		tess.rotationW.y = math.rad(math.anglelerp(math.deg(tess.rotationW.y),0,a));
		tess.rotationW.z = math.rad(math.anglelerp(math.deg(tess.rotationW.z),0,a));
	end);
	tess_spdmult = 0;
	
	backgrounds.pulsetimer = 0;
	
	eventu.waitFrames(64);
	
	bg_pulsetime = lunatime.time();
	flip_stabletime = lunatime.time();
	
	Sound(audio.core_active);
	broken_core.sound=Audio.SfxOpen(audio.core_active_loop);
	broken_core.volume = 0;
	broken_core:Play();
	eventu.run(function()
		local t = 128;
		while(t > 0) do
			t = t-1;
			local a = 1-t/128;
			backgrounds.consolestate = a;
			backgrounds.pulsebrightness = a;
			backgrounds.nebulaspeed = a;
			backgrounds.colour = math.lerp(Color.black, Color.lightblue, a);
			tess_rotspdxyz.y = 0.02;
			tess_rotspdw.z = 0.005;
			tess_spdmult = math.lerp(0,4,a*a);
			tess_colour = math.lerp(Color.black, Color.lightblue, a);
			broken_core.volume = math.lerp(0,1,a);
			eventu.waitFrames(0);
		end
	end);
	
	message.showMessageBox {x=400, y=300, text="CORE REBOOT INITIATED.<br>BEGINNING GARBAGE DISPOSAL IN T-MINUS 2 MINUTES.<page>GIVE OR TAKE.", screenSpace = true, type="system"}
	message.waitMessageEnd();
	
	message.showMessageBox {target=player_pos, text="I only need to keep you busy!"}
	message.waitMessageEnd();
	showPumpMsg {target=eye_pos, text="You cheeky brand!"}
	message.waitMessageEnd();
	
	
	Audio.MusicOpen(Misc.resolveFile("music/a2xt-aurevoir2.ogg"));
	Audio.MusicPlay();
	
	local function waitMsgWhileReady(msg)
		while(msg ~= nil and not msg.deleteMe) do
			SetReady();
			eventu.waitFrames(0);
		end
	end
	
	Audio.SfxPlayCh(-1, Audio.SfxOpen(playerManager.getSound(CHARACTER_UNCLEBROADSWORD, 2)), 0)
	m = message.showMessageBox {target=player_pos, text="This is the end, Pumpernickel! Neither of us escape this room! <pause 20>", closeWith="auto"}
	waitMsgWhileReady(m);
	
	m = showPumpMsg {target=eye_pos, text="Yeeaah, no. Here's how this is going to work.<pause 20><page>One: I erase you right here and now.<pause 20><page>Two: I step outside until they're done with this purging nonsense.<pause 20><page>And finally, C:<pause 20>", closeWith="auto"}
	waitMsgWhileReady(m);
	
	intensifyReady = 1;
	
	while(not drawBG) do
		SetReady();
		eventu.waitFrames(0);
	end
	
	scene.endScene();
end

function bossAPI.onTick()
	tess.rotationXYZ = tess.rotationXYZ + tess_rotspdxyz*tess_spdmult;
	tess.rotationW = tess.rotationW + tess_rotspdw*tess_spdmult;
	
	if(not backgrounds.fliprandomise) then
		backgrounds.flipnumber = lunatime.time()-flip_stabletime;
	end
	
	eye_pos.x = x-32;
	eye_pos.y = y-32;
	eye_pos.width = 64;
	eye_pos.height = 64;
			
	if(not intensifies or intensifiesTimer > 0) then
		
		player_pos.x = player.x;
		player_pos.y = player.y;
		player_pos.width = player.width;
		player_pos.height = player.height;
	
		if(not stunned) then
			--Idle body anim
			y = y + 0.5*math.sin(0.05*lunatime.tick());
		end
		
		--Prep animations for rendering
		HandlePlates(0.025, 1);
		HandleArmPartciles(24);
		if(armInitTimer > 0) then
			armInitTimer = armInitTimer - 1;
		end
		
		updateBullets();
		updateLargeBullet();
		
		if(not bossStarted and Audio.MusicClock() > 12 and boss.isReady()) then
			bossStarted = true;
			startMoveEvent(true);
			_,mainloop = eventu.run(bossEvents);
		end
		
		if((boss.Active or intensifies) and player:mem(0x13E, FIELD_WORD) > 0) then
				Audio.MusicStopFadeOut(500);
		end
		
		if(bossStarted) then
		
		if(not drawBG and not intensifies) then
			player:mem(0x140, FIELD_WORD, 2);
			player.powerup = 2;
		end
		
			if(intensifies) then
				if(intensifiesTimer < largeBulletEndTime) then
					Defines.earthquake = math.lerp(4,2,intensifiesTimer/largeBulletEndTime);
				else
					Defines.earthquake = 2;
				end
				if(intensifiesTimer > 0) then
					intensifiesTimer = intensifiesTimer - 1;
				end
			elseif(drawBG and boss.HP <= 10) then
				stopMoveEvent();
				setPhase();
				eventu.abort(mainloop);
				boss.HP = math.max(boss.HP,1);
				flashScreen(150);
				drawBG = false;
				stunned = false;
				player:mem(0x140, FIELD_WORD, 2);
				SetBodyPos(initPos);
				for i=1,4 do
					SetArmPos(i, arms[i].initPos);
				end
				Audio.MusicStop();
				Voice(audio.voice.hurt);
				Sound(audio.sunball_die);
				player.powerup = 2;
				player.x = initPlayerPos.x-player.width*0.5;
				player.y = initPlayerPos.y-player.height;
				
				player.speedX = 0;
				player.speedY = 0;
				player.FacingDirection = 1;
				intensifyReady = true;
				scene.startScene{scene=cutscene.mid, noletterbox=true}
			elseif(not intensifies and intensifyReady == 1 and Audio.MusicIsPlaying() and Audio.MusicClock() > 11.4) then
				flashScreen();
				drawBG = true;
				_,mainloop = eventu.run(intensifiesEvents);
			end
			
			signalChecks();
			eyeBox.x = x;
			eyeBox.y = y;
			
			
			if(eyeHitstun > 0) then
				eyeHitstun = eyeHitstun - 1;
			elseif(stunned) then
				local box = getSwipeHitbox();
				if(box and colliders.collide(box, eyeBox)) then
					damage(1, 16);
				else
					box = getLungeHitbox();
					if(box and colliders.collide(box, eyeBox)) then
						if(broadsword.GetLungeType() == 1) then
							damage(2, 64);
						else
							damage(math.lerp(1,4, broadsword.GetLungeAmount()), 96);
						end
					else
						box = getDownstabHitbox();
						if(box and colliders.collide(box, eyeBox)) then
							damage(2, 64);
						end
					end
				end
			end
		end
	end
	
	if(intensifies) then
		player.powerup = 2;
		if(player:mem(0x140,FIELD_WORD) > 32 and player:isGroundTouching()) then
			player.downKeyPressing = true;
		end
		
		if(intensifiesTimer < largeBulletEndTime - 128 and not isEnding) then
			setPhase(phase_supertennis);
			eventu.abort(mainloop);
			isEnding = true;
		end
		
		if(math.floor(intensifiesTimer) == 100) then
			Audio.MusicStopFadeOut(3000);
		end
	end
end

local function DrawBG()
	local gametime = lunatime.time() - starttime;
	
	if(gametime < 5 or not drawBG) then
		tess:Draw(-99,false,tess_colour);
		backgrounds.pulsetimer = lunatime.time()-bg_pulsetime;
		backgrounds.Draw(-99.9);
	end
	
	if(drawBG) then
		local t = math.min(2,gametime * 0.05);
		local gradt = math.pow(math.sin(gametime*0.05),2);
		local gradcol = smokegrad:get(gradt);
		Graphics.glDraw{vertexCoords={0,0,800,0,800,600,0,600}, primitive = Graphics.GL_TRIANGLE_FAN, textureCoords = {0,0,1,0,1,1,0,1}, texture = noise, shader = bgShader, color = {1,1,1,(gametime-1)*0.25},
										uniforms =  {
											iResolution = {800,600,1},
											iGlobalTime = gametime,
											gSpeedMult = t,
											gColBase = {gradcol.r,gradcol.g,gradcol.b},
											gColAdd = {0.3,0.4,0.6},
											gBossPos = {x-Camera.get()[1].x,y-Camera.get()[1].y}
										 }, priority = -65};
	end
end

local function DrawFog()
	
	ceilfog:Draw(-51);
	
	--uncomment for vanishing smoke during stun
	--bodyfog.enabled = not(stunned and not stunRecovery);

	if(globalfog < 1) then
		armemit:Draw(-52);
		
		bodyfog.enabled = not stunned or stunRecovery;
		bodyfog2.enabled = stunned and not stunRecovery;
		
		if(stunned and not stunRecovery) then
			bodyfog2.x = x;
			bodyfog2.y = y;
		else
			bodyfog.x = x;
			bodyfog.y = y;
		end
		bodyfog:Draw(-51);
		bodyfog2:Draw(-51);
	end
	
	if(globalfog > 0) then
		local c = Color.fromHex(0x0A2E1600+0xFF*globalfog);
		Graphics.drawScreen{color = c, priority = -60};
		c.a = c.a*0.5;
		Graphics.drawScreen{color = c, priority = -5};
		
		if(emitfgfog) then
			local emit = math.lerp(0,40,globalfog);
			
			for i = 1, rng.random(0,emit) do
				local randx = rng.random(0,800);
				cornerfog.x = Zero.x + randx;
				
				local tb = rng.randomInt(0,1);
				
				cornerfog.y = Zero.y + 600*tb;
				
				tb = (tb-0.5)*2;
				
				local dx = math.abs((randx - 400)/400);
				local dy = rng.random(0,math.lerp(-64,128,dx));
				
				if(dy > 0) then
					cornerfog.y = cornerfog.y - tb*dy;
					cornerfog:Emit(1);
				end
			end
		end
	end
		
	cornerfog:Draw(-4)
end

local function DrawHands()
	for _,v in ipairs(arms) do
		local c = 0xFFFFFFFF;
		if(v.stuntimer > 0) then
			c = 0x6688AAFF;
		end
		local pos = vectr.v2(v.hand.x, v.hand.y);
		local p2 = pos + vectr.up2:rotate(rng.random(360))*rng.random(v.vibrate);
		v.hand.x = p2.x;
		v.hand.y = p2.y;
		
		local priority = -50;
		if(armInitTimer > 0) then
			priority = -51;
		end
		
		v.hand:Draw(priority,c);
		v.hand.x = pos.x;
		v.hand.y = pos.y;
	end
end

local function DrawEye()

	if(stunned) then
		eyeAnimTimer = eyeAnimTimer-1;
		if(eyeAnimTimer < 0) then
			eyeAnimTimer = 8;
			eyeFrame = (eyeFrame+1)%2;
		end
	else
		eyeFrame = 0;
		eyeAnimTimer = 0;
	end
	
	local frameOffset = 0;
	local offset = vectr.zero2;
	if(eyeHitstun > 0) then
		frameOffset = 2;
		offset = vectr.up2:rotate(rng.random(360))*rng.random(4*math.min(1,eyeHitstun/16));
	end
	
	if(eyelidFrame ~= 0) then
		Graphics.drawImageToSceneWP(eye1, x-28+offset.x, y-28+offset.y, 0, 56*(eyeFrame+frameOffset), 56, 56, -50);
		
		local toplayer = vectr.v2(player.x-x, player.y-y);
		
		if(not stunRecovery) then
			eyeRecoveryAmt = 0;
		else
			eyeRecoveryAmt = math.min(eyeRecoveryAmt+0.01,1);
		end
			
		if(stunned and not stunRecovery) then
			toplayer = vectr.up2:rotate(lunatime.tick()*10);
		else
			if(eyeTarget ~= nil) then
				toplayer = vectr.v2(eyeTarget.x-x, eyeTarget.y-y);
			end
			toplayer = toplayer*0.01;
			if(toplayer.length > 1) then
				toplayer = toplayer:normalise();
			end
			
			if(stunRecovery) then
				toplayer = math.lerp(vectr.up2:rotate(lunatime.tick()*10), toplayer, eyeRecoveryAmt);
			end
			
			if(lastEyePos ~= nil) then
				toplayer = math.lerp(lastEyePos, toplayer, 0.2);
			end
			lastEyePos = toplayer;
		end
		Graphics.drawImageToSceneWP(eye2, x-7 + toplayer.x * 10, y-7 + toplayer.y * 10, -50);
		
		if(eyelidFrame > 0) then
			Graphics.drawImageToSceneWP(eyelid, x-28+offset.x, y-28+offset.y, 0, 56*(eyelidFrame-1), 56, 56, -50);
		end
	end
end

local function DrawPlates()
	for _,v in ipairs(smokepos) do
		local order = -50;
		
		local col = smokegrad:get(v.col);
		if(math.sin(v.t) < 0) then
			order = -50.5;
			col = col * math.lerp(1, 0.4, math.min(1,-2*math.sin(v.t)));
		end
		col = 255 + math.floor(col.b * 255) * 256 + math.floor(col.g * 255) * 256 * 256 + math.floor(col.r * 255) * 256 * 256 * 256;
		v.obj.width = vectr.lerp(2,32,1-math.abs(math.cos(v.t)));
		v.obj:Reconstruct();
		v.obj:RotateTexture(v.rot);
		v.obj.x = x + v.vec.x;
		v.obj.y = y + v.vec.y;
		v.obj:Draw(order, col);
	end
end
local function pad0(val, num)
	val = tostring(val)
	return string.rep("0", num - #val)..val;
end

local function DrawIntensifies()
	local s = lunatime.toSeconds(intensifiesTimer)*intensifiesTimeMult;
	
	local t = 1 - intensifiesTimer/intensifiesTime;
	local a = math.lerp(0.5,0.9, t*t);
	local alpha = math.cos(t*150);
	alpha = alpha*alpha*a;
	
	local a2 = math.cos(t*100);
	a2 = math.clamp(a2*a2*t + 0.5*t);
	s = math.max(0,s);
	textblox.printExt(pad0(math.floor(s/60),2)..":"..pad0(math.floor(s%60),2)..":"..pad0(math.floor((s*100)%100),2), 
	{x=400,y=120,z=1,scale=4, color=math.lerp(Color.fromHex(0xFF000099), Color.fromHex(0xFFFFFFFF), a2):toHex(), 
	font=textblox.FONT_SPRITEDEFAULT1X2, halign=textblox.ALIGN_MID, z = 5, valign=textblox.ALIGN_MID});
	
	if(intensifiesTimer < 128) then
		alpha = math.lerp(1, alpha, intensifiesTimer/128);
		player:mem(0x140, FIELD_WORD, 2);
	end
	
	Graphics.drawScreen{color=math.lerp(Color.transparent, Color.red, alpha)}
	
	if(math.floor(intensifiesTimer) == 0) then
		intensifiesTimer = -1;
		local angesTime = 300;
		local angesDelay = lunatime.toTicks(5);
		pause.Block();
		scene.startScene{scene=function()
			local fade = 0;
			local timer = 0;
			while(true) do
				if(fade < 1) then
					fade = fade + 0.01;
				end
				Graphics.drawScreen{color=math.lerp(Color.transparent, Color.white, fade), priority = 9}
				
				timer = timer + 1;
				if(timer > angesTime) then
					Graphics.drawImageWP(anges, 0, 0, (timer-angesTime)/100, 9.5);
				end
				
				if(timer > angesTime + angesDelay) then
					Graphics.drawScreen{color=math.lerp(Color.transparent, Color.black, math.clamp((timer-angesTime-angesDelay)/100)), priority = 10}
				end
				
				eventu.waitFrames(0);
			end
		end, noletterbox = true};
	end
end

local function DrawBoss()
	if(not intensifies or intensifiesTimer > 0) then
		DrawBG();
	
		DrawFog();
		DrawEye();
		DrawPlates();
		DrawHands();
		
		drawBullets();
		drawLargeBullet();
		
		drawHitFlashes();
	end
	
	if(flashTimer > 0) then
		Graphics.drawScreen{color=math.lerp(Color.transparent, Color.white, math.clamp(flashTimer/100)), priority = -5}
		flashTimer = flashTimer - 1;
	end
	
	if(intensifies) then
		DrawIntensifies();
	end
end
function bossAPI.onDraw()
	DrawBoss();
end

function bossAPI.onCameraUpdate()
	if(Zero ~= nil) then
		Camera.get()[1].x = Zero.x;
	end
end

return bossAPI;