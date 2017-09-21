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

pause.StopMusic = true;

boss.Name = "Tumulta Gloria"
boss.SuperTitle = "Chaos Pumpernickel"
boss.SubTitle = "Anarchy Personified"

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

local bullets = {};

local BULLET_SMALL = 0;
local bulletImgs = {}
bulletImgs[BULLET_SMALL] = Graphics.loadImage(Misc.resolveFile("bullet_1.png"));

local largeBulletImgs = 
{
Graphics.loadImage(Misc.resolveFile("bullet_large_1.png"));
Graphics.loadImage(Misc.resolveFile("bullet_large_2.png"));
Graphics.loadImage(Misc.resolveFile("bullet_large_3.png"));
}

local largeBullet = nil;

local function drawBullets()
	for _,v in ipairs(bullets) do
		Graphics.drawImageToSceneWP(bulletImgs[v.type], v.pos.x - v.gfxwidth*0.5, v.pos.y - v.gfxheight*0.5, 0, v.frame*v.gfxheight, v.gfxwidth, v.gfxheight, -50)
	end
end

local function getPlayerPos()
	return vectr.v2(player.x+player.width*0.5, player.y+player.height*0.5);
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
		
		if(colliders.collide(player,bullets[i].hitbox)) then
			player:harm();
		end
		if(bullets[i].pos.x > Zero.x + 864 or bullets[i].pos.x < Zero.x - 64 or
		   bullets[i].pos.y > Zero.y + 664 or bullets[i].pos.y < Zero.y - 64) then
			table.remove(bullets,i);
		end
	end
end

local function spawnBullet(bulletType, pos, speed)
	local b = {pos = pos, type = bulletType, speed = speed, frame = 0}
	if(bulletType == BULLET_SMALL) then
		b.framespeed = 4;
		b.frames = 6
		b.hitbox = colliders.Circle(0,0,11);
		b.gfxheight=22;
		b.gfxwidth=22;
	end
	b.frametimer = b.framespeed;
	table.insert(bullets, b);
end

local largeBulletChargeTime = 256;

local function spawnLargeBullet(pos)
	local b = {pos = pos, imgs = {}, launchTimer = largeBulletChargeTime, hitbox = colliders.Circle(0,0,4), speed=4}
	
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
			local s = math.lerp(1.02,1,1 - largeBullet.launchTimer/largeBulletChargeTime);
			largeBullet.hitbox.radius = largeBullet.hitbox.radius*(s+0.001);
			for _,v in ipairs(largeBullet.imgs) do
				v:Scale(s);
				s = s + 0.001;
			end
		end
		if(colliders.collide(player,largeBullet.hitbox)) then
			player:harm();
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
					
					v.hand:Rotate(angle - v.rotation);
					v.rotation = angle;
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
	
local function MoveArm(idx, target, speed)
	local v = vectr.v2(arms[idx].hand.x, arms[idx].hand.y);
	local d = (v-target).length;
	if(v.x == 0 or v.y == 0 or d <= 4) then
		v = target;
	end
	IKMove(computeNewPos(v,target,speed), arms[idx].joints);
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

local function DoArmMove(idx, target, t)
	if(armEvent[idx]) then
		eventu.abort(armEvent[idx]);
		armEvent[idx] = nil;
		eventu.signal("ARM_"..idx)
	end
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

local function MoveBody(target, speed)
	local v = vectr.v2(x, y);
	local d = (v-target).length;
	if(v.x == 0 or v.y == 0 or d <= 4) then
		v = target;
	end
	v = computeNewPos(v,target,speed);
	x = v.x;
	y = v.y;
	for i = 1,4 do
		arms[i].joints[1].x = x;
		arms[i].joints[1].y = y;
		IKMove(arms[i].joints[#arms[i].joints], arms[i].joints);
	end
end

local function DoBodyMove(target, t)
	if(bodyEvent) then
		eventu.abort(bodyEvent);
		bodyEvent = nil;
		eventu.signal("BODY")
	end
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
		local timer = 0;
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
		eventu.abort(current_phase);
	end
	if(phase == nil) then
		phase = phase_idle;
		eventu.signal("PHASE")
	end
	
	local _,c = eventu.run(phase, args)
	current_phase = c;
end

local function phase_armattack1()
	for i = 1,4 do
		arms[1].targetobj = player;
	end
	stopMoveEvent();
	local side = rng.randomInt(0,1);
	local bodyCentre = Zero+vectr.v2(side*578 + 64,64);
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
		p = p + dir*128;
		arms[i].targetobj = p;
		DoArmMove(i, p, 0.5);
		eventu.waitFrames(48);
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
	eventu.waitFrames(16);
	
	for i = 1,4 do
		for j = 1,10 do
			local spawnpos = vectr.v2(arms[i].hand.x, arms[i].hand.y);
			local dir = (getPlayerPos() - spawnpos):normalise();
			spawnBullet(BULLET_SMALL, spawnpos + dir*16, dir*3.5);
			eventu.waitFrames(28);
		end
		eventu.waitFrames(48);
	end
	
	eventu.waitFrames(256);
	
	setPhase();
end

local function phase_tennis()
	stopMoveEvent();
	
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
			MoveArm(i, corners[i] + t*t*32*vectr.up2:rotate(rng.random(360)), 5);
		end
		eventu.waitFrames(0);
	end
	
	local idling = eventu.run(phase_idle);
	
	DoBodyMove(Zero+vectr.v2(rng.random(64,800-64),rng.random(64,600-128)), rng.random(2,4));
	waitForBody();
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
	
	populatePlates(5);
	bgShader:compileFromFile(nil, Misc.resolveFile("background2.frag"));
	
	Audio.MusicVolume(100);

	boss.Start();
	
	setPhase();
end

function onStart()
	StartBoss();
end

function onTick()
	--Idle body anim
	y = y + 0.5*math.sin(0.05*lunatime.tick());
	
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
	Graphics.drawImageToSceneWP(eye1, x-28, y-28, -50);
	
	local toplayer = vectr.v2(player.x-x, player.y-y);
	toplayer = toplayer*0.01;
	if(toplayer.length > 1) then
		toplayer = toplayer:normalise();
	end
	Graphics.drawImageToSceneWP(eye2, x-7 + toplayer.x * 10, y-7 + toplayer.y * 10, -50);
end

local function DrawPlates()
	for _,v in ipairs(smokepos) do
		local order = -50;
		
		local col = smokegrad:get(v.col);
		if(math.sin(v.t) < 0) then
			order = -50.5;
			col = col * vectr.lerp(1, 0.4, math.min(1,-2*math.sin(v.t)));
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
	
	local st = math.sin(lunatime.tick()*0.01);
	--Graphics.glDraw{vertexCoords = {0,0,800,0,0,600,800,600}, primitive = Graphics.GL_TRIANGLE_STRIP, color={1,0,0,0.25*st*st+vectr.lerp(0.25,1,lunatime.time()/30)}}
end
function onDraw()
	DrawBoss();
end

