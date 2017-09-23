--------------------------------------------------
-- Level code
-- Created 18:50 2017-2-3
--------------------------------------------------

local particles = API.load("particles");
local vectr = API.load("vectr");
local imagic = API.load("imagic");
local rng = API.load("rng");
local eventu = API.load("eventu");
local colliders = API.load("colliders");
local boss = API.load("a2xt_boss");
local pause = API.load("a2xt_pause");

local playerManager = API.load("playerManager")

local broadsword = API.load("Characters/unclebroadsword")

pause.StopMusic = true;

boss.Name = "Tumulta Gloria"
boss.SuperTitle = "Chaos Pumpernickel"
boss.SubTitle = "Anarchy Incarnate"

boss.HP = 175;

boss.TitleDisplayTime = 380;

local bossStarted = false;

local Zero = vectr.v2(0,0);

local x = 0;
local y = 0;
local fogtest = particles.Emitter(x, y, Misc.resolveFile("p_pumpernick.ini"), 2);
local eye1 = Graphics.loadImage(Misc.resolveFile("eyeball.png"));
local eye2 = Graphics.loadImage(Misc.resolveFile("eyepupil.png"));
local smoke = Graphics.loadImage(Misc.resolveFile("puff.png"));

local hand = Graphics.loadImage(Misc.resolveFile("hand.png"));

local noise = Graphics.loadImage(Misc.resolveFile("noise.png"));

local armemit  = particles.Emitter(x, y, Misc.resolveFile("p_armfog.ini"));

local arms = {};

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

local eyeBox = colliders.Circle(0,0,32);

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

local events = {};

local stunned = false;
local stunRecovery = false;

local eyeAnimTimer = 0;
local eyeFrame = 0;
local eyeHitstun = 0;
local eyeRecoveryAmt = 0;

local plateCounts = {3,5,7,10}
local plateIndex = 1;

local subphases = {};

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
		b.gfxheight=22;
		b.gfxwidth=22;
		b.killable = true;
	elseif(bulletType == BULLET_MED) then
		b.framespeed = 4;
		b.frames = 6
		b.duration = 128;
		b.timer = b.duration;
		b.initSpd = speed;
		b.hitbox = colliders.Circle(0,0,18);
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
		
		bullets[i].frametimer = bullets[i].frametimer - 1;
		if(bullets[i].frametimer < 0) then
			bullets[i].frametimer = bullets[i].framespeed;
			bullets[i].frame = (bullets[i].frame + 1)%bullets[i].frames;
		end
		
		local hb = getSwordHitbox();
		if(bullets[i].killable and hb and colliders.collide(hb, bullets[i].hitbox)) then
			bullets[i].dead = true;
			spawnHitflash(1, bullets[i].pos, vectr.v2(1,1)*bullets[i].hitbox.radius+5);
		elseif(colliders.collide(player,bullets[i].hitbox)) then
			player:harm();
		end
		
		if(bullets[i].type == BULLET_MED) then
		
			if(bullets[i].timer > 32 and bullets[i].pos.y + (bullets[i].speed.y*bullets[i].speed.y/2) > Zero.y+600-32) then
				bullets[i].timer = 32;
			end
		
			bullets[i].speed = bullets[i].initSpd * math.clamp((bullets[i].timer - 32)/(bullets[i].duration - 32));
			
			bullets[i].timer = bullets[i].timer - 1;
			
			if(bullets[i].timer == 0) then
				bullets[i].dead = true;
				spawnHitflash(1, bullets[i].pos, vectr.v2(1,1)*40);
				local s = vectr.up2;
				for j = 1,8 do
					spawnBullet(BULLET_SMALL, bullets[i].pos, s*2);
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
local largeBulletSize = 128;

local function spawnLargeBullet(pos)
	local b = {pos = pos, imgs = {}, launchTimer = largeBulletChargeTime, hitbox = colliders.Circle(0,0,4), speed=4, target = player}
	
	for _,v in ipairs(largeBulletImgs) do
		table.insert(b.imgs, imagic.Create{texture = v, primitive = imagic.TYPE_BOX, vertColors = {0xFFFFFF00,0xFFFFFF00,0xFFFFFF00,0xFFFFFF00}, x=pos.x, y = pos.y, width=8, height = 8, scene = true, align = imagic.ALIGN_CENTRE})
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
		for k,v in ipairs(largeBullet.imgs) do
			v.x = largeBullet.pos.x;
			v.y = largeBullet.pos.y;
			if(k == 3) then
				v:Rotate(1);
			end
		end
		if(largeBullet.launchTimer > 0) then
			largeBullet.launchTimer = largeBullet.launchTimer - 1;
			if(largeBullet.launchTimer == 0) then
				largeBullet.velocity = (getPlayerPos() - largeBullet.pos):normalise() * largeBullet.speed;
			end
			--local s = math.lerp(1.02,1,1 - largeBullet.launchTimer/largeBulletChargeTime);
			local s = math.lerp(math.pow(largeBulletSize,1/largeBulletChargeTime),1,1 - largeBullet.launchTimer/largeBulletChargeTime);
			largeBullet.hitbox.radius = largeBullet.hitbox.radius*(s+0.001);
			for _,v in ipairs(largeBullet.imgs) do
				v:Scale(s);
				s = s + 0.001;
			end
		end
		
		local hb = getLungeHitbox() or getSwipeHitbox() or getUpstabHitbox();
		
		if(largeBullet.target == player) then
			if(hb and colliders.collide(hb, largeBullet.hitbox)) then
				largeBullet.target = nil;
				largeBullet.speed = largeBullet.speed*1.05;
				largeBullet.velocity = (vectr.v2(x,y) - largeBullet.pos):normalise() * largeBullet.speed;
				
				local p = vectr.v2(hb.x+hb.width*0.5, hb.y+hb.height*0.5);
				local d = p-largeBullet.pos;
				if(d.length > largeBullet.hitbox.radius) then
					d = d:normalise();
					p = largeBullet.pos + d*largeBullet.hitbox.radius;
				end
				
				spawnHitflash(2, p, vectr.v2(200, 200));
			elseif(colliders.collide(player,largeBullet.hitbox)) then
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
					
					spawnHitflash(2, d, vectr.v2(200, 200));
					spawnHitflash(3, p, vectr.v2(150, 150), eyeBox);
				else
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
	t.handBox = colliders.Box(0,0,32,32);
	t.rotation = 0;
	t.target = vectr.v2(x,y);
	t.targetobj = player;
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
				for i=1,jointlen,stepSize do
					local p = c + dir*i;
					armemit.x = p.x;
					armemit.y = p.y;
					if(rng.randomInt(0,2) == 0) then
						armemit:Emit(1);
					end
					
				end
				
				table.insert(verts, c.x)
				table.insert(verts, c.y)
					
					table.insert(verts, j.x)
					table.insert(verts, j.y)
				
				if(v.joints[k+1]) then
					c = j;
					joint = v.joints[k+1] - c;
				else
					v.hand.x = j.x;
					v.hand.y = j.y;
					v.handBox.x = j.x-16;
					v.handBox.y = j.y-16;
					
					if(player:mem(0x13E, FIELD_WORD) == 0) then
						local b,s = colliders.bounce(player,v.handBox);
						if(b and s) then
							colliders.bounceResponse(player);
						elseif(colliders.collide(v.handBox,player) and (not player:mem(0x50,FIELD_BOOL) or player.y+player.height > v.handBox.y+v.handBox.height*0.5)) then
							player:harm();
						end
					end
					
					c = vectr.v2(x,y);
					v.target.x = v.targetobj.x;
					v.target.y = v.targetobj.y;
					
					local rotdir = (v.target-j):normalise();
					local angle = (math.atan2(rotdir.y, rotdir.x) - math.atan2(-0.7071068,-0.7071068)) / imagic.DEG2RAD;
					angle = angle + 180;
					
					if(stunRecovery) then
						angle = math.lerp(v.rotation, angle, 0.1)
					end
					
					if(stunRecovery or not stunned) then
						v.hand:Rotate(angle - v.rotation);
						v.rotation = angle;
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

local function startMoveEvent()
	stopMoveEvent();
	local _,e = eventu.run(function()
		local timer = 1;
		while(true) do
			if(timer <= 0) then 
				timer = rng.random(600); 
				local _,r = DoBodyMove(Zero+vectr.v2(rng.random(64,800-64),rng.random(64,600-128)), rng.random(2,4));
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

--------------
--	PHASES	--
--------------

local function phase_idle()
	for i = 1,4 do
		arms[i].targetobj = player;
	end
	while(true) do
		--Idle arm anim
		MoveArm(1, vectr.v2(x-200-64*math.sin(lunatime.tick()/100), y-100+64*math.cos(lunatime.tick()/100)), 5);
		MoveArm(2, vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +14), y-60+64*math.cos(lunatime.tick()/100 + 14)), 5);
		MoveArm(3, vectr.v2(x-200-64*math.sin(lunatime.tick()/100 +37), y+100+64*math.cos(lunatime.tick()/100 + 37)), 5);
		MoveArm(4, vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +73), y+120+64*math.cos(lunatime.tick()/100 + 73)), 5);
		
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

function events.Stun(timer)
	if(stunned) then
		return;
	end
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
				speed = -speed*0.5;
			end
			SetBodyPos(pos);
			t = t-1;
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
				waitForArm();
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
		arms[1].targetobj = player;
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
	eventu.waitFrames(16);
	
	for i = 1,4 do
		local p = getPlayerPos();
		local dir = (p-vectr.v2(arms[i].hand.x,arms[i].hand.y)):normalise();
		p = p + (dir*128);
		arms[i].targetobj = p;
		DoArmMove(i, p, 0.5);
		eventu.waitFrames(48);
	end
	
	eventu.waitFrames(32);
	
	startMoveEvent();
	setPhase();
end

local function phase_armattack2()
	for i = 1,4 do
		arms[1].targetobj = player;
	end
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
	
	local t = 720;
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
		
		if(dist > r) then
			r = r+0.5;
		else
			r = r-0.5;
		end
		
		r=math.max(r,64);
		
		for i = 1,4 do
			armpos[i] = armpos[i]:rotate(spd);
			SetArmPos(i, bodyCentre+r*armpos[i]);
		end
		
		if(t > math.abs(spd*100)) then
			if(d.x < 0) then
				spd = spd - 0.01;
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
	
	startMoveEvent();
	setPhase();
end

local function phase_danmaku1()
	for i = 1,4 do
		arms[1].targetobj = player;
	end
	
	DoArmMove(1, Zero + vectr.v2(32,32), 2);
	DoArmMove(2, Zero + vectr.v2(800-32,32), 2);
	DoArmMove(3, Zero + vectr.v2(32,600-32), 2);
	DoArmMove(4, Zero + vectr.v2(800-32,600-32), 2);
	
	waitForArm{1,2,3,4};
	
	for i = 1,4 do
		local spawnpos = vectr.v2(arms[i].hand.x, arms[i].hand.y);
		spawnHitflash(1, spawnpos, vectr.v2(32,32));
		eventu.waitFrames(16);
		for j = 1,10 do
			local dir = (getPlayerPos() - spawnpos):normalise();
			spawnBullet(BULLET_SMALL, spawnpos + dir*16, dir*3.5);
			eventu.waitFrames(28);
		end
		eventu.waitFrames(32);
	end
	
	eventu.waitFrames(128);
	
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
	
	for i = 1,4 do
		for j = 1,4 do
			eventu.waitFrames(64);
			spawnBullet(BULLET_MED, bodyCentre + armlocs[j], armlocs[j]:normalise():rotate(rng.random(-5,5))*(getPlayerPos() - bodyCentre).length/rng.random(65,85));
		end
	end
	
	eventu.waitFrames(256);
	
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
				DoBodyMove(Zero+vectr.v2(rng.random(64,800-64),rng.random(64,600-300)), rng.random(1,2));
				waitForBody();
			end
			eventu.waitFrames(0);
		end
		
		abortSubphases();
		
	until(false);
end

local function bossEvents()
	eventu.waitFrames(128);
	setPhase(phase_armattack1);
	waitPhase();
	eventu.waitFrames(256);
	setPhase(phase_danmaku1);
	waitPhase();
	eventu.waitFrames(256);
	setPhase(phase_tennis);
	waitPhase();
	
	eventu.waitFrames(256);
	setPhase(phase_armattack2);
	waitPhase();
	eventu.waitFrames(256);
	setPhase(phase_danmaku2);
	waitPhase();
	eventu.waitFrames(256);
	setPhase(phase_tennis);
	waitPhase();
	
	while(true) do
		local phaseOptions = {phase_armattack1, phase_armattack2, phase_danmaku1, phase_danmaku2}
		for i = 1,2 do
			eventu.waitFrames(256);
			local j = rng.randomInt(1,#phaseOptions);
			setPhase(phaseOptions[j]);
			table.remove(phaseOptions,j);
			waitPhase();
		end
		eventu.waitFrames(256);
		setPhase(phase_tennis);
		waitPhase();
	end
end

local function StartBoss()
	
	Zero.x = Section(0).boundary.left;
	Zero.y = Section(0).boundary.top;
	
	x = Zero.x+600;
	y = Zero.y+250;

	player.character = CHARACTER_UNCLEBROADSWORD;
	player.powerup = 2;
	player.reserveItem = 0;
	
	makeArm{ vectr.v2(x-80, y-90), vectr.v2(x-140, y-120), vectr.v2(x-200, y-100)};
	makeArm{ vectr.v2(x+50, y-50), vectr.v2(x+100, y-75), vectr.v2(x+160, y-60)};
	makeArm{ vectr.v2(x-100, y+80), vectr.v2(x-130, y+90), vectr.v2(x-200, y+100)};
	makeArm{ vectr.v2(x+50, y+50), vectr.v2(x+100, y+80), vectr.v2(x+160, y+120)};
	
	populatePlates(plateCounts[plateIndex]);
	bgShader:compileFromFile(nil, Misc.resolveFile("background2.frag"));
	
	Audio.MusicVolume(100);

	boss.Start();
	
	setPhase();
end

function onStart()
	StartBoss();
end

function onTick()
	if(not stunned) then
		--Idle body anim
		y = y + 0.5*math.sin(0.05*lunatime.tick());
	end
	
	--Prep animations for rendering
	HandlePlates(0.025, 1);
	HandleArmPartciles(24);
	
	updateBullets();
	updateLargeBullet();
	
	if(not bossStarted and Audio.MusicClock() > 12 and boss.isReady()) then
		bossStarted = true;
		startMoveEvent();
		eventu.run(bossEvents);
	end
	
	if(bossStarted) then
		signalChecks();
		eyeBox.x = x;
		eyeBox.y = y;
		
		if(eyeHitstun > 0) then
			eyeHitstun = eyeHitstun - 1;
		elseif(stunned) then
			local box = getSwipeHitbox();
			if(box and colliders.collide(box, eyeBox)) then
				boss.Damage(1);
				eyeHitstun = 16;
			else
				box = getLungeHitbox();
				if(box and colliders.collide(box, eyeBox)) then
					if(broadsword.GetLungeType() == 1) then
						boss.Damage(2);
						eyeHitstun = 64;
					else
						boss.Damage(math.lerp(1,4, broadsword.GetLungeAmount()));
						eyeHitstun = 96;
					end
				else
					box = getDownstabHitbox();
					if(box and colliders.collide(box, eyeBox)) then
						boss.Damage(2);
						eyeHitstun = 64;
					end
				end
			end
		end
	end
end

local function DrawBG()
	local t = math.min(2,lunatime.time() * 0.05);
	local gradt = math.pow(math.sin(lunatime.time()*0.05),2);
	local gradcol = smokegrad:get(gradt);
	Graphics.glDraw{vertexCoords={0,0,800,0,800,600,0,600}, primitive = Graphics.GL_TRIANGLE_FAN, textureCoords = {0,0,1,0,1,1,0,1}, texture = noise, shader = bgShader, color = {1,1,1,lunatime.time()},
									uniforms =  {
                                        iResolution = {800,600,1},
                                        iGlobalTime = lunatime.time(),
										gSpeedMult = t,
										gColBase = {gradcol.r,gradcol.g,gradcol.b},
										gColAdd = {0.3,0.4,0.6},
										gBossPos = {x-Camera.get()[1].x,y-Camera.get()[1].y}
                                     }, priority = -65};
end

local function DrawFog()
	armemit:Draw(-52);
	for _,v in ipairs(arms) do
		v.hand:Draw(-50);
	end
	
	fogtest.x = x;
	fogtest.y = y;
	fogtest:Draw(-51);
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
		toplayer = toplayer*0.01;
		if(toplayer.length > 1) then
			toplayer = toplayer:normalise();
		end
		
		if(stunRecovery) then
			toplayer = math.lerp(vectr.up2:rotate(lunatime.tick()*10), toplayer, eyeRecoveryAmt);
		end
	end
	Graphics.drawImageToSceneWP(eye2, x-7 + toplayer.x * 10, y-7 + toplayer.y * 10, -50);
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

local function DrawBoss()
	DrawBG();
	
	DrawFog();
	DrawEye();
	DrawPlates();
	
	drawBullets();
	drawLargeBullet();
	
	drawHitFlashes();
	
	local st = math.sin(lunatime.tick()*0.01);
	--Graphics.glDraw{vertexCoords = {0,0,800,0,0,600,800,600}, primitive = Graphics.GL_TRIANGLE_STRIP, color={1,0,0,0.25*st*st+vectr.lerp(0.25,1,lunatime.time()/30)}}
end
function onDraw()
	DrawBoss();
end

