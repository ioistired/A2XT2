--local cinematx = loadSharedAPI("cinematx");
local eventu = loadSharedAPI("eventu");
local particles = loadSharedAPI("particles");
local raocoin = loadSharedAPI("raocoin2");
local colliders = loadSharedAPI("colliders");
local sanctuary = loadSharedAPI("a2xt_leeksanctuary");
local paralx = API.load("paralx");
local vectr = API.load("vectr");
local shadows = API.load("darkfilter");
local rng=API.load("rng")
local pnpc=API.load("pnpc");

sanctuary.world = 1;
sanctuary.sections[4] = true

local pastImgs = {}
local presImgs = {}


for i=0,9 do
	local pst = Misc.resolveFile("bg_f_"..i..".png");
	local prs = Misc.resolveFile("bg_p_"..i..".png")
	pastImgs[i+1] = Graphics.loadImage(pst);
	
	if(prs == nil) then prs = pst; end
	
	presImgs[i+1] = Graphics.loadImage(prs);
end

local shop = {}

--cinematx.configExt{hudBox=false, imageUi=false, textbloxSub=true}

local ylimit = -200320;
local targetcamY;
local lastcamY;
local refreshCamera;

local sandstorm = particles.Emitter(0,0,Misc.resolveFile("p_sandstorm.ini"));
--local sandstorm = particles.Emitter(0,0,Misc.resolveFile("particles/p_snow.ini"));
sandstorm:AttachToCamera(Camera.get()[1]);

local idolIDs = {154,155,156,157};
local idolSpawns = {};
local idolsDone = {};
local idolColliders = {};
local idolBlocks = {};

for _,v in ipairs(idolIDs) do
	idolsDone[v] = false;
end

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

local dickson;
--local anim_Dickson = cinematx.readAnimData("Dickson.anim")
local dickson_marks = {};

local dickson_mark_index = 0;
local dickson_info_index = 0;
local dickson_info_gather = {};

local dickson_info_actor;

local caveShadow = shadows.Shadow();

local function makeShadowCollider(shadow,bufferleft,buffertop,bufferright,bufferdown)
	return colliders.Box(shadow.x1-bufferleft,shadow.y1-buffertop,shadow.x2-shadow.x1+bufferright*2,shadow.y2-shadow.y1+bufferdown*2);
end

local shadow1 = caveShadow:AddSection{x1 = -175360, x2 = -173184, y1 = -180480, y2 = Section(1).boundary.bottom, alpha = 0.85, edge = 128};
local shadow1collider = makeShadowCollider(shadow1,64,-224,64,64);

--local pshadow;

local torches = {};

local grabtorches = {};

--cinematx.defineQuest ("dickson", "An Explorer's Mission", "Help Prof. Dr. D. Dickson Esq. to discover the history of Temporis.")

function onStart()
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
	
	local y = -400
	
	for i=0,1 do
	local imgs;
	if(i == 0) then 
		imgs = pastImgs;
	else 
		imgs = presImgs;
	end
	
	local s = {1-i}
	
	paralx.create{image=imgs[1], priority = -99, y=y+50,repeatY = false, parallaxX = 0, parallaxY = 0.05, sections=s}
	paralx.create{image=imgs[2], priority = -98.9, y=y+100,repeatY = false, parallaxX = 0.2, parallaxY = 0.06, speedX=0.3972, sections=s}
	paralx.create{image=imgs[3], priority = -98.8, y=y+100,repeatY = false, parallaxX = 0.25, parallaxY = 0.07, speedX=0.7916, sections=s}
	paralx.create{image=imgs[4], priority = -98.7, y=y,repeatY = false, parallaxX = 0.3, parallaxY = 0.08, sections=s}
	paralx.create{image=imgs[5], priority = -98.6, y=y,repeatY = false, parallaxX = 0.4, parallaxY = 0.09, sections=s}
	paralx.create{image=imgs[6], priority = -98.5, y=y,repeatY = false, parallaxX = 0.5, parallaxY = 0.1, sections=s}
	paralx.create{image=imgs[7], priority = -98.4, y=y,repeatY = false, parallaxX = 0.6, parallaxY = 0.11, sections=s}
	paralx.create{image=imgs[8], priority = -98.3, y=y,repeatY = false, parallaxX = 0.7, parallaxY = 0.12, sections=s}
	paralx.create{image=imgs[9], priority = -98.2, y=y,repeatY = false, parallaxX = 0.8, parallaxY = 0.13, sections=s}
	paralx.create{image=imgs[10], priority = -98.1, y=y,repeatY = false, parallaxX = 0.9, parallaxY = 0.14, sections=s}
	
	end
	
	for _,v in ipairs(BGO.get(21)) do
		local p = particles.Emitter(v.x+16,v.y-4,Misc.resolveFile("particles/p_flame_small.ini"));
		local s = caveShadow:AddLight{x=v.x+16,y=v.y-8,radius=64,sourceRadius=32,borderRes=8,innerRes=4,colour=0xDDBB77}
		table.insert(torches,{particles=p,shadow=s,lightrad=128})
	end
	
	for _,v in ipairs(NPC.get(31)) do
		local p = particles.Emitter(v.x+8,v.y-4,Misc.resolveFile("particles/p_flame_small.ini"));
		p:Attach(v,false);
		local s = caveShadow:AddLight{x=v.x+4,y=v.y-8,radius=64,sourceRadius=32,borderRes=8,innerRes=4,colour=0xFFDD99}
		local npc = pnpc.wrap(v);
		npc.data.particles = p;
		npc.data.shadow=s;
		npc.data.lightrad=256;
		table.insert(grabtorches,npc)
	end
	--pshadow = caveShadow:AddLight{x=-199100,y=-200500,radius=0--[[196]],sourceRadius=64,borderRes=16,innerRes=8}
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
	
function onTick()
	
	if(colliders.collide(player,shadow1collider)) then
		shadow1.alpha = vectr.lerp(shadow1.alpha,0.85,0.1);
	else
		shadow1.alpha = vectr.lerp(shadow1.alpha,0,0.1);
	end

	local allIdolsDone = true;
	
	for _,k in ipairs(idolIDs) do
		if(not idolsDone[k]) then
			allIdolsDone = false;
			local ps = NPC.get(k,-1);
			if(#ps < 1) then
				NPC.spawn(k,idolSpawns.x,idolSpawns.y,1);
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
end

function onCameraUpdate()
	
	local cam = Camera.get()[1];
	
	if(player.section < 2) then
	ybound = ylimit+20000*player.section;
	ycam = ybound - 560;
	
	if(player.y < ybound and cam.y > ycam) then
		targetcamY = ycam;
	else
		targetcamY = cam.y;
	end
	
	if(refreshCamera or cam.y < ycam) then
		lastcamY = targetcamY;
		refreshCamera = false;
	end
	
	if(lastcamY == nil) then
		lastcamY = cam.y;
	end
	
	if(math.abs(lastcamY-targetcamY) > 500) then
		lastcamY = cam.y;
	end
	
	cam.y = lastcamY*0.8 + targetcamY*0.2;
	lastcamY = cam.y;
	end
	
	for _,v in ipairs(torches) do
		v.particles:Draw(-86);
		v.shadow.radius = rng.random(v.lightrad-5,v.lightrad+5);
	end
	
	for _,v in ipairs(grabtorches) do
		v:mem(0x12A,FIELD_WORD,180);
		if(v:mem(0x12A,FIELD_WORD) >= 0) then
			v.data.particles:Draw(-60);
			v.data.shadow.radius = rng.random(v.data.lightrad-5,v.data.lightrad+5);
			v.data.shadow.x = v.x+8;
			v.data.shadow.y = v.y-2;
		else
			v.data.shadow.radius = 0;
			v.data.particles:KillParticles();
		end
	end
	

	caveShadow:Draw(0)
end

--[[
--TEMPORARY LIGHT TEST CODE
	local vs = {}
	local cs = {}
		
	local lights = {{x=-177694,y=-180382},{x=-177694,y=-180382}}
	
	
	local w = 400;
	local h = 300;
	local dx = 800/w;
	local dy = 600/h;
	for j=0,600,dy do
		vs[j] = {}
		cs[j] = {}
		for i=0,800,dx do
			table.insert(vs[j],i)
			table.insert(vs[j],j)
			table.insert(vs[j],i)
			table.insert(vs[j],j+dy)
			
			
			local x1 = i + Camera.get()[1].x;
			local x2 = x1;
			local y1 = j + Camera.get()[1].y;
			local y2 = y1+dy;
			
			table.insert(cs[j],0)
			table.insert(cs[j],0)
			table.insert(cs[j],0)
			table.insert(cs[j],0.5)
			table.insert(cs[j],0)
			table.insert(cs[j],0)
			table.insert(cs[j],0)
			table.insert(cs[j],0.5)
		end
	end
	
local function falloff(i)
	if(i == 0) then return 0; end;
	return 1-(math.pow(i,2))
end]]

function onDraw()

	--if(dickson ~= nil) then
	--	dickson:overrideAnimation(anim_Dickson)
	--end
	
	--if(player.section == 0) then
	--	sandstorm:Draw(-20);
	--else
	--	sandstorm:KillParticles();
	--end
	
	--[[ --TEMPORARY LIGHT TEST CODE
	local cx,cy = Camera.get()[1].x,Camera.get()[1].y;
	
	lights[1].x = player.x;
	lights[1].y = player.y+32;
	
	local alpha = 0.75;
		
	for k,verts in pairs(vs) do
		for i=1,#verts,2 do
			local il = 0;
			for _,v in ipairs(lights) do
				local ddx = verts[i]+cx-v.x
				local ddy = verts[i+1]+cy-v.y
				local d2 = ddx*ddx + ddy*ddy;
				if(d2 < 40000) then
					il = math.min(il + falloff(d2/40000),1);
				end
			end
			cs[k][math.ceil(i*0.5)*4] = alpha - (il*alpha)
		end
	
		Graphics.glDraw{vertexCoords=verts,primitive=Graphics.GL_TRIANGLE_STRIP,vertexColors=cs[k],priority=-4}
	end]]
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

function text_intro()
	--[[
	cinematx.startDialogExt("Welcome to Temporis, home of the Chronotons. Feel free to use our Temporal Shift Devices as you like.");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	]]
end

function text_shop()
	--[[
	cinematx.startDialogExt("Buy somethin' will ya?");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	]]
end

function text_biv()
	--[[
	cinematx.startDialogExt("Oh, that temple we built to hold the Leek of Time?");
	cinematx.waitForDialog();
	cinematx.startDialogExt("Turns out that Leek isn't anything special. Actually, all Leeks have the ability to bend space and time!");
	cinematx.waitForDialog();
	cinematx.startDialogExt("Super Leeks are particularly good at it, because they're bigger. Relativity, yo!");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	]]
end

function text_yot()
	--[[
	cinematx.startDialogExt("Hello there. Have you come to join me?");
	cinematx.waitForDialog();
	cinematx.startDialogExt("I like it up here. It's nice and relaxing, and you get a good view of the Palace.");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	]]
end

local function setInfo(key)
	--[[
	dickson_info_gather[key] = true;
	dickson.messageIsNew = true;
	]]
end

local function getInfo(key)
	return true;
	--[[
		return dickson_info_gather[key] ~= nil and dickson_info_gather[key];
		]]
end

function text_bes()
	--[[
	local v = "";
	if(player.character == CHARACTER_MARIO or player.character == CHARACTER_LUIGI) then
		v = "brother";
	else
		v = "friend";
	end
	cinematx.startDialogExt("You may be wondering what you semi-liquid "..v.." is doing sitting on that throne there.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("He is under the impression that he is the King of Time.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("We thought this would be the most effective way to pacify him, or at least the way that would cause the least collateral damage.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("To be perfectly honest, he's just so overjoyed to be in power that he hasn't actually tried to use it.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("So far all he's done is lock himself in demanding 'tribute'.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("Well, it's all for the best. Just humour him, it'll make things much easier.");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	setInfo("throne");
	]]
end

function text_explorer_1()
	--[[
	cinematx.startDialogExt("We found devices like this scattered throughout that temple we were exploring.");
	cinematx.waitForDialog();
	cinematx.startDialogExt("I wonder if they're connected...?");
	cinematx.waitForDialog();
	cinematx.endCutscene();
	]]
end

do --Dickson Texts
	function text_dickson_intro()

	--[[
		local s = "";
		if(player.character == CHARACTER_MARIO or player.character == CHARACTER_LUIGI) then
			s = "cycloptic ";
		elseif(player.character == CHARACTER_PEACH) then
			s = "turtle ";
		elseif(player.character == CHARACTER_TOAD) then
			s = "Canadian ";
		end
		
		cinematx.startDialogExt("Hello there my "..s.."friend!<pause 4> My name is Prof. Dr. D. Duff Dickson Esq.",{autoTime=false});
		cinematx.waitForDialog();
		cinematx.startDialogExt("As you can no doubt see, I am an explorer, and I am leading this venture!");
		cinematx.waitForDialog();
		cinematx.startDialogExt("We believe this ancient city is the home of a race of time-travelling beings, and it is my humble task to prove this!");
		cinematx.waitForDialog();
		cinematx.startDialogExt("...");
		cinematx.waitForDialog();
		cinematx.startDialogExt("...Unfortunately we have made very little headway. But nevertheless, our search continues!");
		cinematx.waitForDialog();
		cinematx.startDialogExt("Perhaps you could aid in our efforts? I am not as agile as I used to be...");
		cinematx.waitForDialog();
		cinematx.startDialogExt("Back in my day, I spent many a year raiding castles, rescuing damsels in distress, defeating oversized apes... things are not what they used to be...");
		cinematx.waitForDialog();
		cinematx.startDialogExt("In any case, I wish you good fortune in any and all of your ventures.");
		cinematx.waitForDialog();
		if(getGender(player)) then
			s = "madam";
		else
			s = "sir";
		end
		cinematx.startDialogExt("Good day to you "..s.."! If you should require my assistance, I shall be exploring this ruin.");
		cinematx.waitForDialog();
		--dickson:walk(2);
		cinematx.beginQuest ("dickson")
		cinematx.waitFrames(300);
		--dickson.wordBubbleIcon = 3;
		return true;
		]]
	end

	function text_dickson_throne()
	--[[
		cinematx.startDialogExt("Ah, hello there!");
		cinematx.waitForDialog();
		cinematx.startDialogExt("This remarkable structure appears to be some sort of throne room.");
		cinematx.waitForDialog();
		cinematx.startDialogExt("Interesting... our research suggests that these people, whomever they may be, were a democractic people, so what use would they have with a throne room?");
		cinematx.waitForDialog();
		cinematx.startDialogExt("Most intriguing...");
		cinematx.waitForDialog();
		if(getInfo("throne")) then
			cinematx.startDialogExt("What?");
			cinematx.waitForDialog();
			cinematx.startDialogExt("So you say they used this throne room in order to placate a dangerous tyrant by granting him the illusion of power...");
			cinematx.waitForDialog();
			cinematx.startDialogExt("Of course! This fits our hypothesis perfectly. I must move on to the next site to learn all I can.");
			cinematx.waitForDialog();
		--	dickson:walk(-2);
			cinematx.waitFrames(75);
		--	dickson:jump(6);
			cinematx.waitFrames(52);
		--	dickson:jump(4);
			cinematx.waitFrames(52);
		--	dickson:jump(4);
			cinematx.waitFrames(52);
		--	dickson:jump(4);
			cinematx.waitFrames(60);
		else
			return false;
		end
		]]
	end


	function text_dickson()
	--[[
		if(dickson_marks[dickson_mark_index] == nil) then
			dickson_mark_index = 0;
		end
		
		if(dickson_marks[dickson_mark_index].f()) then
			if(dickson_mark_index < #dickson_marks) then
				local infoActor = cinematx.getActorFromKey("dickson_info_"..dickson_marks[dickson_mark_index].info);
				if(infoActor ~= nil) then
					infoActor.wordBubbleIcon = 0;
				end
				dickson_mark_index = dickson_mark_index + 1;
				dickson.messageIsNew = true;
			end
		elseif(dickson_info_index < dickson_mark_index) then
			local infoActor = cinematx.getActorFromKey("dickson_info_"..dickson_marks[dickson_mark_index].info);
			if(infoActor ~= nil) then
				infoActor.wordBubbleIcon = 3;
			end
			dickson_info_index = dickson_mark_index;
		end
		dickson:setX(dickson_marks[dickson_mark_index].x);
		dickson:setY(dickson_marks[dickson_mark_index].y);
		dickson:setMem(0xA8,FIELD_DFLOAT,dickson_marks[dickson_mark_index].x)
		dickson:setMem(0xB0,FIELD_DFLOAT,dickson_marks[dickson_mark_index].y)
		dickson:walk(0);
		cinematx.endCutscene();
		]]
	end

end