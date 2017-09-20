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

local x = -199400;
local y = -200350;
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

function onStart()
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
end

function onTick()
	--Idle body anim
	y = y + 0.5*math.sin(0.05*lunatime.tick());
	
	--Idle arm anim
	IKMove(vectr.v2(x-200-64*math.sin(lunatime.tick()/100), y-100+64*math.cos(lunatime.tick()/100)), arms[1].joints);
	IKMove(vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +14), y-60+64*math.cos(lunatime.tick()/100 + 14)), arms[2].joints);
	IKMove(vectr.v2(x-200-64*math.sin(lunatime.tick()/100 +37), y+100+64*math.cos(lunatime.tick()/100 + 37)), arms[3].joints);
	IKMove(vectr.v2(x+160-64*math.sin(lunatime.tick()/100 +73), y+120+64*math.cos(lunatime.tick()/100 + 73)), arms[4].joints);
	
	--Prep animations for rendering
	HandlePlates(0.025, 1);
	HandleArmPartciles(24);
	
	if(not bossStarted and Audio.MusicClock() > 12 and boss.isReady()) then
		bossStarted = true;
	end
	Text.print(bossStarted,0,0)
end

function makeArm(js)
	local t =  {};
	t.joints = js;
	t.frame = rng.randomInt(0,15);
	t.frameTime = 0.2;
	t.hand = imagic.Create{texture = hand, primitive=imagic.TYPE_BOX, x = 0, y = 0, width = 36, height = 36, scene = true, align = imagic.ALIGN_CENTRE};
	t.handBox = colliders.Box(0,0,32,32);
	t.rotation = 0;
	t.target = vectr.v2(x,y);
	table.insert(arms, t);
end

function HandleArmPartciles(stepSize)
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
					v.target.x = player.x;
					v.target.y = player.y;
					
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


function populatePlates(num)
	for k,v in ipairs(smokepos) do
		smokepos[k] = nil;
	end
	for i=1,num,1 do
		smokepos[i] = {};
	end
	numPlates = num;
end

function HandlePlates(speed, radiusScale)
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

function IKUpdate(bns)
	IKMove(bns[#bns], bns);
end

function IKMove(target, bns)
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
		local lenSub = (range+lenBranch-lens[1])/#(lens-1);
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

function onDraw()
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
	
	armemit:Draw(-52);
	for _,v in ipairs(arms) do
		v.hand:Draw(-50);
	end
	
	fogtest.x = x;
	fogtest.y = y;
	fogtest:Draw(-51);
	Graphics.drawImageToSceneWP(eye1, x-28, y-28, -50);
	
	local toplayer = vectr.v2(player.x-x, player.y-y);
	toplayer = toplayer*0.01;
	if(toplayer.length > 1) then
		toplayer = toplayer:normalise();
	end
	Graphics.drawImageToSceneWP(eye2, x-7 + toplayer.x * 10, y-7 + toplayer.y * 10, -50);
	
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
	local st = math.sin(lunatime.tick()*0.01);
	--Graphics.glDraw{vertexCoords = {0,0,800,0,0,600,800,600}, primitive = Graphics.GL_TRIANGLE_STRIP, color={1,0,0,0.25*st*st+vectr.lerp(0.25,1,lunatime.time()/30)}}
end

