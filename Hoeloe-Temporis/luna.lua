--local cinematx = loadSharedAPI("cinematx");
local eventu = loadSharedAPI("eventu");
local particles = loadSharedAPI("particles");
local raocoin = loadSharedAPI("raocoin2");
local colliders = loadSharedAPI("colliders");
local sanctuary = loadSharedAPI("a2xt_leeksanctuary");
local defines =  API.load("expandedDefines");
local paralx2 = API.load("paralx2");
local vectr = API.load("vectr");
local rng=API.load("rng")
local pnpc=API.load("pnpc");
local audio = API.load("audioMaster");
local imagic = API.load("imagic");
local a2xt_message = API.load("a2xt_message");
local a2xt_scene = API.load("a2xt_scene")

sanctuary.world = 1;
sanctuary.sections[4] = true

local shop = {}

local ylimit = -200320;
local targetcamY;
local lastcamY;
local refreshCamera;

local sandstorm = particles.Emitter(0,0,Misc.resolveFile("p_sandstorm.ini"));
sandstorm:AttachToCamera(Camera.get()[1]);

local waterfallTop = particles.Emitter(-172672,-180440,Misc.resolveFile("p_waterfall.ini"));
local waterfallBase = particles.Emitter(-172672,-179104,Misc.resolveFile("p_waterfallBase.ini"));
local waterfallOverlay = Graphics.loadImage("waterfallOverlay.png");

local idolIDs = {154,155,156,157};
local idolSpawns = {};
local idolsDone = {};
local idolColliders = {};
local idolBlocks = {};

for _,v in ipairs(idolIDs) do
	idolsDone[v] = false;
end

audio.Create{sound="waterfall.ogg", x = -172672, y = -179774, type = audio.SOURCE_BOX, sourceWidth = 1024, sourceHeight = 1408, falloffRadius = 1600, volume = 2};

local waterY = -179088;
local waterWid = 3264;
local splashes = {};

audio.Create{sound="waterfall.ogg", x = -173184 - waterWid*0.5, y = waterY + 24, type = audio.SOURCE_BOX, sourceWidth = waterWid, sourceHeight = 48, falloffRadius = 800, volume = 1};


local waterwheel = imagic.Create{x = -175872 + 16, y = -179488 + 16, width = 1024, height = 1024, primitive = imagic.TYPE_BOX, texture = Graphics.loadImage("waterwheel.png"), align = imagic.ALIGN_CENTRE, scene = true}
local wheelAudio = audio.Create{sound="waterwheel.ogg", x = waterwheel.x, y = waterwheel.y, type = audio.SOURCE_CIRCLE, sourceRadius = 512, falloffRadius = 800, volume = 1};

local wheelParticles = particles.Emitter(waterwheel.x,waterY,Misc.resolveFile("p_waterwheel.ini"));
local wheelRadius = 512-32;
local wheelPlatforms = 8;
local wheelBlocks = 289;


local cavebg = paralx2.Background(1, {left = -176480, top = -180320, right=-173186, bottom=-179008},
{img=Graphics.loadImage("cave_0.png"), depth = INFINITE, alignY = paralx2.align.BOTTOM, x = -4992, y = -76, repeatX = true},
{img=Graphics.loadImage("cave_1.png"), depth = 200, alignY = paralx2.align.BOTTOM, x = -4992, y = 40, repeatX = true},
{img=Graphics.loadImage("cave_2.png"), depth = 160, alignY = paralx2.align.BOTTOM, x = -4992, y = 40, repeatX = true},
{img=Graphics.loadImage("cave_3.png"), depth = 120, alignY = paralx2.align.BOTTOM, x = -4992, y = -20, repeatX = true},
{img=Graphics.loadImage("cave_4.png"), depth = 80, alignY = paralx2.align.BOTTOM, x = -4992, y = 40, repeatX = true},
{img=Graphics.loadImage("cave_5.png"), depth = 40, alignY = paralx2.align.BOTTOM, x = -4992, y = 40, repeatX = true});

--Copy cave background to new section and reposition
local cavebg2 = cavebg:Clone();
cavebg2.section = 0;
local bg2bounds = {};
for k,v in pairs(cavebg2.bounds) do
	bg2bounds[k] = v-20000;
end
cavebg2.bounds = bg2bounds;

--Offset layers to account for different section size (use `cavebg2:Get(1).debug = true` to calibrate this)
for k,v in ipairs(cavebg2:Get()) do
	--v.y = v.y-960;
end

local waterImgs = 
{
	{ img = Graphics.loadImage("water_3.png"), offset = 0, speed = 1.6 },
	{ img = Graphics.loadImage("water_2.png"), offset = 0, speed = 2.6 },
	{ img = Graphics.loadImage("water_1.png"), offset = 0, speed = 3.7 },
}


idolColliders[154] = colliders.Box(-176160,-181248,32,32);
idolColliders[155] = colliders.Box(-176064,-181248,32,32);
idolColliders[156] = colliders.Box(-175968,-181248,32,32);
idolColliders[157] = colliders.Box(-175872,-181248,32,32);

idolBlocks[154] = 227;
idolBlocks[155] = 228;
idolBlocks[156] = 229;
idolBlocks[157] = 230;

local idolDoor = {Layer(4),Layer(5),Layer(6),Layer(7)};

local idolDoorOpen = false;

local torches = {};
local grabtorches = {};

--cinematx.defineQuest ("dickson", "An Explorer's Mission", "Help Prof. Dr. D. Dickson Esq. to discover the history of Temporis.")

function onStart()
	
	for _,v in ipairs(BGO.get(10)) do
		if(v.x > Section(1).boundary.left and v.x < Section(1).boundary.right) then
			waterwheel.x = v.x + 512;
			waterwheel.y = v.y + 512;
			wheelAudio.x = waterwheel.x;
			wheelAudio.y = waterwheel.y;
			wheelParticles.x = waterwheel.x;
			v.isHidden = true;
		end
	end
	
	for i = 1, wheelPlatforms do
		local x = waterwheel.x + (wheelRadius * math.cos((i-1)/wheelPlatforms * 2 * math.pi));
		local y = waterwheel.y + (wheelRadius * math.sin((i-1)/wheelPlatforms * 2 * math.pi));
		
		for j = -2,2 do
			local b = Block.spawn(wheelBlocks, x-16+j*32, y-16);
			b:mem(0x18, FIELD_STRING, "WheelPlatforms"..i);
		end
		
	end

	for _,v in ipairs(NPC.get(idolIDs,-1)) do
		idolSpawns[v.id] = {x=v.x, y=v.y};
	end

	for _,id in ipairs(idolIDs) do
		local c = idolColliders[id]
		for _,v in ipairs(Block.getIntersecting(c.x,c.y,c.x+c.width,c.y+c.height)) do
			if(v.id == idolBlocks[id]) then
				v:mem(0x1C, FIELD_WORD, -1);
				break;
			end
		end
	end
	
	for _,v in ipairs(BGO.get(21)) do
		local p = particles.Emitter(v.x+16,v.y-4,Misc.resolveFile("particles/p_flame_small.ini"));
		audio.Create{sound="torches.ogg", x = v.x+16, y=v.y, falloffRadius = 500, volume = 0.5};
		table.insert(torches, p);
	end
	
	for _,v in ipairs(NPC.get(31)) do
		local p = particles.Emitter(v.x+8,v.y-4,Misc.resolveFile("particles/p_flame_small.ini"));
		p:setParam("space", "local");
		p:Attach(v,false);
		v = pnpc.wrap(v);
		audio.Create{sound="torches.ogg", parent = v, x = v.x+16, y=v.y, falloffRadius = 400, volume = 0.4};
		v.data.particles = p;
		table.insert(grabtorches, v);
	end
end

local function checkIdolPlaced(npc)
	local c = idolColliders[npc.id];
	if(c == nil) then return false; end
	if(colliders.collide(npc,c)) then
		idolsDone[npc.id] = true;
		npc:kill(9);
		Animation.spawn(10,c.x,c.y);
		playSFX(37);
		for _,v in ipairs(Block.getIntersecting(c.x,c.y,c.x+c.width,c.y+c.height)) do
			if(v.id == idolBlocks[npc.id]) then
				v:mem(0x1C, FIELD_WORD, 0);
				break;
			end
		end
		return true;
	end
	return false;
end

local wheelTime = 0;
	
function onTick()

	local allIdolsDone = true;
	local bounds = Section(1).boundary;
	
	for _,k in ipairs(idolIDs) do
		if(not idolsDone[k]) then
			allIdolsDone = false;
			local ps = NPC.get(k,-1);
			local oob = (ps[1]:mem(0x146, FIELD_WORD) == 1 and (ps[1].x > bounds.right or ps[1].x < bounds.left-32 or ps[1].y > bounds.bottom or ps[1].y < bounds.top-32));
			if(#ps < 1 or oob) then
				if(oob) then
					ps[1]:kill(9);
				end
				local v = NPC.spawn(k,idolSpawns[k].x,idolSpawns[k].y,1);
				v:mem(0x12A,FIELD_WORD,180);
				v:mem(0xA8,FIELD_DFLOAT,v.x);
				v:mem(0xB0,FIELD_DFLOAT,v.y);
			end
			for _,v in ipairs(ps) do
				if(not checkIdolPlaced(v)) then
					v:mem(0x12A,FIELD_WORD,180);
					if(player.section == 0) then
						v:mem(0xA8,FIELD_DFLOAT,idolSpawns[k].x);
						v:mem(0xB0,FIELD_DFLOAT,idolSpawns[k].y);
					else
						v:mem(0xA8,FIELD_DFLOAT,v.x);
						v:mem(0xB0,FIELD_DFLOAT,v.y);
					end
				end
			end
		end
	end
	
	if(allIdolsDone and not idolDoorOpen) then
		idolDoorOpen = true;
		local delay = 0.5;
		--cinematx.runCutscene(function() cinematx.panToPos(1, -175744, -181184-player.height, 5, true); cinematx.waitSeconds(delay*4 + 1); cinematx.panToObj(1,player,5,true) cinematx.endCutscene() end);
		local i = 1;
		eventu.setTimer(delay,function() idolDoor[i]:hide(false); i = i+1; playSFX(37); Defines.earthquake = 2; end, 4);
		eventu.setTimer(delay*5,function() Audio.playSFX("smash.ogg"); Defines.earthquake = 8; end);
	end
	
	if(player.section == 1) then
		local npcs = NPC.get(defines.NPC_ALL, 1);
		table.insert(npcs, player);
		for _,v in ipairs(npcs) do
			local sy = v.speedY;
			if(v.IsInWater ~= nil and v.IsInWater ~= 0 and v:mem(0x48,FIELD_WORD) ~= 0) then --is the player, underwater, and on a slope
				sy = math.abs(v.speedX); --For some reason, speed is 3 when on a slope underwater. Cancel that out.
			end
			if(math.abs(sy) > 0) then
				local py = v.y + v.height;
				local px = v.x + v.width*0.5;
				if(py - sy < waterY and py > waterY or py - sy > waterY and py < waterY) then
					local cam = Camera.get()[1];
					if(px > cam.x - 32 and px < cam.x + cam.width + 32 and py > cam.y - 32 and py < cam.y + cam.height + 32) then
						table.insert(splashes, {x = px-16, y = waterY-32, frame = 0, timer = 8});
						if(sy > 11 and v.width >= 24) then
							audio.PlaySound{sound = "splash-big.ogg", volume = 2}
						else
							audio.PlaySound{sound = "splash-small.ogg", volume = 1}
						end
					end
				end
			end
		end
	elseif(player.section == 7) then --furba farm
		if(not a2xt_scene.inCutscene and rng.random() < 0.02) then
			local npc = pnpc.wrap(rng.irandomEntry(NPC.get(89,7)));
			if(npc.data.meep == nil or npc.data.meep:isFinished()) then
				npc.data.meep = a2xt_message.showMessageBox {target=npc, x=npc.x,y=npc.y, text="Meep.<pause 20>", closeWith = "auto"}
			end
		end
	end
	
	if(not Layer.isPaused()) then
		local rspd = 0.3;
		local deg2rad = math.pi/180;
		waterwheel:Rotate(rspd);
		
		for i=1,wheelPlatforms do
			local l = Layer.get("WheelPlatforms"..i)
			l.speedX = -wheelRadius*deg2rad*rspd * math.sin(wheelTime*deg2rad*rspd + (math.pi * 2 * ((i-1)/wheelPlatforms)));
			l.speedY = wheelRadius*deg2rad*rspd * math.cos(wheelTime*deg2rad*rspd + (math.pi * 2 * ((i-1)/wheelPlatforms)));
		end
		
		wheelTime = (wheelTime + 1)%(360/rspd);
	end
end

local reflections = Graphics.CaptureBuffer(800,600);
local waterShader = nil;

function onDraw()
	local i = 1;
	while i <= #splashes do
		Graphics.drawImageToSceneWP(Graphics.sprites.effect[114].img, splashes[i].x, splashes[i].y, 0, splashes[i].frame * 32, 32, 32, -60);
		splashes[i].timer = splashes[i].timer - 1;
		if(splashes[i].timer == 0) then
			splashes[i].timer = 8;
			splashes[i].frame = splashes[i].frame + 1;
			if(splashes[i].frame >= 5) then
				table.remove(splashes, i);
				i = i - 1;
			end
		end
		i = i + 1;
	end
	
	waterwheel:Draw(-70);
end

local function tableadd(t, c, ...)
	for _,v in ipairs({...}) do
		t[c] = v;
		c = c + 1;
	end
	return c;
end

local function drawWater(cam)
	if(cam.y > waterY - cam.height) then
		
		do
			local maxX = -173184;
			local y = waterY-8;
			local h = 8;
			local blendDist = 64;
			local alpha = 0.8;
				
			local verts = {}
			local txs = {}
			local cols = {}
			
			local vc = 0;
			local pr = -75;
			
			for k = 1,#waterImgs do
				local v = waterImgs[k];
				vc = 0;
				if(k > 1) then
					pr = -24;
				end
					
				while(v.offset < cam.x - 64) do
						v.offset = v.offset + 64;
				end
				while(v.offset > cam.x) do
						v.offset = v.offset - 64;
				end
				local hi = v.img.height;
				local i = 0;
				for x = v.offset,864,64 do
					
					if(x < maxX) then
						local wid = 64;
						local tw = 1;
						if(x + 64 >= maxX) then
							wid = maxX - x;
							tw = wid/64;
						end
						
						verts[vc+1], verts[vc+2] = x, y;
						verts[vc+3], verts[vc+4] = x+wid, y;
						verts[vc+5], verts[vc+6] = x, y+hi;
						verts[vc+7], verts[vc+8] = x, y+hi;
						verts[vc+9], verts[vc+10] = x+wid, y;
						verts[vc+11], verts[vc+12] = x+wid, y+hi;
						
						txs[vc+1], txs[vc+2] = 0,0;
						txs[vc+3], txs[vc+4] = tw,0;
						txs[vc+5], txs[vc+6] = 0,1;
						txs[vc+7], txs[vc+8] = 0,1;
						txs[vc+9], txs[vc+10] = tw,0;
						txs[vc+11], txs[vc+12] = tw,1;
									
						local la = math.min((maxX - x)/blendDist, 1) * alpha
						local ra = math.min((maxX - x - wid)/blendDist, 1) * alpha
						
						cols[(2*vc)+1], cols[(2*vc)+2], cols[(2*vc)+3],cols[(2*vc)+4] = la, la, la, la;
						cols[(2*vc)+5], cols[(2*vc)+6], cols[(2*vc)+7],cols[(2*vc)+8] = ra, ra, ra, ra;
						cols[(2*vc)+9], cols[(2*vc)+10], cols[(2*vc)+11],cols[(2*vc)+12] = la, la, la, la;
						cols[(2*vc)+13], cols[(2*vc)+14], cols[(2*vc)+15],cols[(2*vc)+16] = la, la, la, la;
						cols[(2*vc)+17], cols[(2*vc)+18], cols[(2*vc)+19],cols[(2*vc)+20] = ra, ra, ra, ra;
						cols[(2*vc)+21], cols[(2*vc)+22], cols[(2*vc)+23],cols[(2*vc)+24] = ra, ra, ra, ra;
									
						vc = vc + 12;
					end
				end
				
				while (#verts > vc) do
					verts[#verts] = nil;
					verts[#verts] = nil;
					
					txs[#txs] = nil;
					txs[#txs] = nil;
					
					cols[#cols] = nil;
					cols[#cols] = nil;
					cols[#cols] = nil;
					cols[#cols] = nil;
				end
				
				Graphics.glDraw{texture = v.img, vertexCoords = verts, textureCoords = txs, vertexColors = cols, sceneCoords = true, priority = pr};
				
				alpha = alpha + 0.05;
				
				y = y + h;
				h = 24;
				v.offset = v.offset - v.speed;
				
			end	
		end	
		
			reflections:captureAt(-2);
			local reflecty = waterY - cam.y;
			local th = (reflecty/600);
			local stretchFactor = 0.9;
			local brightness = 0.2;
			Graphics.glDraw {
								vertexCoords = {0,reflecty,800,reflecty,800,600,0,600}, 
								textureCoords = {0,th,1,th,1,(th*2-1)*stretchFactor,0,(th*2-1)*stretchFactor}, 
								vertexColors = {brightness,brightness,brightness,0,brightness,brightness,brightness,0,brightness,brightness,brightness,0,brightness,brightness,brightness,0},
								primitive = Graphics.GL_TRIANGLE_FAN, 
								texture=reflections, 
								priority = -2, 
								shader = waterShader,
								uniforms = 
											{
												time = lunatime.tick(), 
												fadeR = {-173280-cam.x, -173216-cam.x}, 
												depthOffset = reflecty,
												intensity = 0.00007,
												frequency = 1,
												speed = 0.3
											}
							};
		end
end

function onCameraUpdate(obj, camid)
	if(camid ~= 1) then return end;
	if(waterShader == nil) then
		waterShader = Shader();
		waterShader:compileFromFile(nil, "reflection.frag");
	end
	local cam = Camera.get()[1];
	
	if(player.section < 2) then
		ybound = ylimit+20000*player.section;
		ycam = ybound - 560;
		
		if(player.y < ybound and cam.y > ycam and (cam.x < -193536 or cam.x > -192448)) then
			targetcamY = ycam;
		else
			targetcamY = cam.y;
		end
		
		if(refreshCamera) then
			lastcamY = targetcamY;
			refreshCamera = false;
		end
		
		if(lastcamY == nil) then
			lastcamY = cam.y;
		end
		
		if(math.abs(lastcamY-targetcamY) > 500) then
			lastcamY = cam.y;
		end
		
		if(targetcamY > ycam+600) then
			cam.y = targetcamY;
		else
			cam.y = lastcamY*0.8 + targetcamY*0.2;
		end
		lastcamY = cam.y;
	end
	
	for _,v in ipairs(torches) do
		v:Draw(-84);
	end
	
	for _,v in ipairs(grabtorches) do
		v:mem(0x12A,FIELD_WORD,180);
		if(v:mem(0x12A,FIELD_WORD) >= 0) then
			v.data.particles:Draw(-60);
		else
			v.data.particles:KillParticles();
		end
	end


	
	if(player.section == 1) then
		waterfallTop:Draw(-70);
		waterfallBase:Draw(-20);
		wheelParticles:Draw(-20);
		
		Graphics.drawImageToSceneWP(waterfallOverlay, -173184, -180448, 0.9, -85);
		
		drawWater(cam);
		
	elseif(player.section == 0) then
		sandstorm:Draw(-40);
	end
end

function onLoadSection()
	refreshCamera = true;
end

local function getGender(p)
	if(p.character == CHARACTER_MARIO or p.character == CHARACTER_LUIGI or p.character == CHARACTER_LINK) then
		return true;
	else
		return false;
	end
end