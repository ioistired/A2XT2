--local cinematx = loadSharedAPI("cinematx");
local eventu = API.load("eventu");
local particles = API.load("particles");
local raocoin = API.load("raocoin2");
local colliders = API.load("colliders");
local sanctuary = API.load("a2xt_leeksanctuary");
local minigame = API.load("a2xt_minigame");
local defines =  API.load("expandedDefines");
local paralx2 = API.load("paralx2");
local vectr = API.load("vectr");
local rng=API.load("rng")
local pnpc=API.load("pnpc");
local audio = API.load("audioMaster");
local imagic = API.load("imagic");
local cameraman = API.load("cameraman");
local a2xt_message = API.load("a2xt_message");
local a2xt_scene = API.load("a2xt_scene")
local a2xt_raocoins = API.load("a2xt_raocoincounter");
local a2xt_rewards = API.load("a2xt_rewards");
local a2xt_pause = API.load("a2xt_pause");
local a2xt_hud = API.load("a2xt_hud");
local npcmanager = API.load("npcmanager")

local textblox = API.load("textblox");

textblox.npcPresets[151] = textblox.PRESET_BUBBLE

sanctuary.world = 1;
sanctuary.sections[4] = true

npcmanager.setNpcSettings{id = 65, talkrange = 64};

local shop = {}

local ylimit = -200320;
local targetcamY;
local lastcamY;
local refreshCamera;

local blockInput = false;

local sandstorm = particles.Emitter(0,0,Misc.resolveFile("p_sandstorm.ini"));
sandstorm:AttachToCamera(Camera.get()[1]);

local waterfallTop = particles.Emitter(-172672,-180440,Misc.resolveFile("p_waterfall.ini"));
local waterfallBase = particles.Emitter(-172672,-179104,Misc.resolveFile("p_waterfallBase.ini"));
local waterfallOverlay = Graphics.loadImage("waterfallOverlay.png");

local idolIDs = {154,155,156,157};
local idolsReady = 
{
	[154] = SaveData.world3.town.fireIdolReady;
	[155] = true;
	[156] = SaveData.world3.town.stoneIdolReady;
	[157] = true;
};

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

local idolOverlays = {};
for _,v in pairs(idolBlocks) do
	idolOverlays[v] = {alpha = 0, x = 0, y = 0, visible = false, obj = imagic.Create{x = 0, y = 0, width = 48, height = 48, primitive = imagic.TYPE_BOX, texture = Graphics.loadImage("overlay-"..v..".png")}};
end

local idolDoor = {Layer(4),Layer(5),Layer(6),Layer(7)};

local idolDoorOpen = false;

local torches = {};
local grabtorches = {};

--cinematx.defineQuest ("dickson", "An Explorer's Mission", "Help Prof. Dr. D. Dickson Esq. to discover the history of Temporis.")

--Arena minigame stuff
local arenaNPCs = nil;

local function spawnArenaPowerup(id)
	Audio.playSFX(11);

	local n = NPC.spawn(id, player.x+player.width*0.5--[[1024]], -544, 10);
	n.x = n.x-n.width*0.5;
	n:mem(0x138, FIELD_WORD, 2);
end

local function doRoundHeader(count)
	local t = 0;
	local maxt = 300;
	local alpharate = 5;
	local alpha = 0;
	local window = nil;
	while(t < maxt) do
		local w,h = textblox.printExt("ROUND "..count, {x = 400, y = 200, width=250, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_MID, z=6, color=0xFFFFFF00+alpha})
	
		if(window == nil) then
			window = a2xt_hud.window{x=400,y=200,width=w+128,height=h+48+GENERIC_FONT.charHeight};
		end
		local bga = alpha*0.75;
		window:Draw{priority=5.9, colour=0x07122700+bga, bordercolour = 0xFFFFFF00+bga};
		if(t < (maxt-(255/alpharate))) then
			alpha = math.min(alpha + alpharate, 255);
		else
			alpha = alpha - alpharate;
		end
		
		if(t == maxt-216) then
			spawnArenaPowerup(9);
		end
		
		t = t+1;
		eventu.waitFrames(0);
	end
end

local function spawnArenaNPC(id, spawnpos, direction, extra)
	local n = pnpc.wrap(NPC.spawn(id, spawnpos.x, spawnpos.y, 10));
	
	n.data.t = 0;
	
	n.y = n.y-n.height;
	n.x = n.x-n.width*0.5;
	
	n.data.x = n.x
	n.data.y = n.y
	
	n.x = -100;
	n.y = 0;
	
	if(direction ~= nil) then
		n.direction = direction;
	end
	
	if(extra) then
		for k,v in pairs(extra) do
			if(k=="hp") then
				n:mem(0x148, FIELD_FLOAT, v)
			else
				n[k] = v;
			end
		end
	end
	
	table.insert(arenaNPCs, n);
end

local function waitUntilEmpty(list)
	while(#list > 0) do
		eventu.waitFrames(0);
	end
end
	
local function waitUntilDead()
	waitUntilEmpty(arenaNPCs);
end

 --arena minigame
local function cor_arena(state)
	local t = 0;
	blockInput = true;
	
	Audio.SeizeStream(9);
	Audio.MusicStopFadeOut(1000);
	
	while(t < 1) do
		t = t+0.025;
		Graphics.drawScreen{color = math.lerp(Color.transparent, Color.black, t), priority = 4};
		eventu.waitFrames(0);
	end
	
	player.x = 1008;
	player.y = -player.height-64;
	player:mem(0x15A,FIELD_WORD,10) --player.section = 10;
	
	player.powerup = 1;
	player.reservePowerup = 0;
	player:mem(0x16,FIELD_WORD,1);
	player:mem(0x108, FIELD_WORD,0);
	player:mem(0x10A, FIELD_WORD,0);
	
	playMusic(10);
	Audio.ReleaseStream(9);
	
	while(t > 0) do
		t = t-0.025;
		Graphics.drawScreen{color = math.lerp(Color.transparent, Color.black, t), priority = 4};
		eventu.waitFrames(0);
	end
	
	blockInput = false;
	a2xt_pause.Unblock();
	local spawnPos = {{x=224; y=-128;}, {x=736; y=-64;}, {x=1312; y=-64;}, {x=1824; y=-128;}}
	
	
	arenaNPCs = {};
	
	doRoundHeader(state.round)
	
	spawnArenaNPC(1, spawnPos[2], 1);
	spawnArenaNPC(1, spawnPos[3], -1);
	eventu.waitFrames(48);
	spawnArenaNPC(1, spawnPos[2], 1);
	spawnArenaNPC(1, spawnPos[3], -1);
	eventu.waitFrames(48);
	spawnArenaNPC(1, spawnPos[2], 1);
	spawnArenaNPC(1, spawnPos[3], -1);
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(109, spawnPos[2], 1);
	spawnArenaNPC(109, spawnPos[3], -1);
	spawnArenaNPC(109, spawnPos[1], 1);
	spawnArenaNPC(109, spawnPos[4], -1);
	eventu.waitFrames(48)
	spawnArenaNPC(109, spawnPos[2], 1);
	spawnArenaNPC(109, spawnPos[3], -1);
	spawnArenaNPC(109, spawnPos[1], 1);
	spawnArenaNPC(109, spawnPos[4], -1);
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(109, spawnPos[2], 1);
	spawnArenaNPC(109, spawnPos[3], -1);
	eventu.waitFrames(48)
	spawnArenaNPC(109, spawnPos[2], 1);
	spawnArenaNPC(109, spawnPos[3], -1);
	spawnArenaNPC(29, spawnPos[1], 1);
	spawnArenaNPC(29, spawnPos[4], -1);
	
	waitUntilDead();
	eventu.waitFrames(64);
	state.round = state.round + 1;
	doRoundHeader(state.round)
	
	spawnArenaNPC(121, spawnPos[2], 1, {ai1 = 1});
	spawnArenaNPC(121, spawnPos[3], -1, {ai1 = 1});
	spawnArenaNPC(121, spawnPos[1], 1, {ai1 = 1});
	spawnArenaNPC(121, spawnPos[4], -1, {ai1 = 1});
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(29, spawnPos[2], 1);
	spawnArenaNPC(29, spawnPos[3], -1);
	spawnArenaNPC(29, spawnPos[1], 1);
	spawnArenaNPC(29, spawnPos[4], -1);
	
	
	waitUntilDead();
	eventu.waitFrames(64);
	state.round = state.round + 1;
	doRoundHeader(state.round)
	
	spawnArenaNPC(129, spawnPos[2], 1);
	spawnArenaNPC(129, spawnPos[3], -1);
	spawnArenaNPC(130, spawnPos[1], 1);
	spawnArenaNPC(130, spawnPos[4], -1);
	eventu.waitFrames(144)
	spawnArenaNPC(130, spawnPos[1], 1);
	spawnArenaNPC(130, spawnPos[4], -1);
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(135, spawnPos[2], 1);
	spawnArenaNPC(135, spawnPos[3], -1);
	eventu.waitFrames(96)
	spawnArenaNPC(135, spawnPos[2], 1);
	spawnArenaNPC(135, spawnPos[3], -1);
	spawnArenaNPC(39, spawnPos[1], 1, {hp=1});
	spawnArenaNPC(39, spawnPos[4], -1, {hp=1});
	eventu.waitFrames(96)
	spawnArenaNPC(135, spawnPos[2], 1);
	spawnArenaNPC(135, spawnPos[3], -1);
	eventu.waitFrames(96)
	spawnArenaNPC(135, spawnPos[2], 1);
	spawnArenaNPC(135, spawnPos[3], -1);
	eventu.waitFrames(144)
	spawnArenaNPC(77, spawnPos[1], 1);
	spawnArenaNPC(77, spawnPos[4], -1);
	eventu.waitFrames(48);
	spawnArenaNPC(77, spawnPos[1], 1);
	spawnArenaNPC(77, spawnPos[4], -1);
	eventu.waitFrames(48);
	spawnArenaNPC(77, spawnPos[1], 1);
	spawnArenaNPC(77, spawnPos[4], -1);
	eventu.waitFrames(48);
	
	
	waitUntilDead();
	eventu.waitFrames(64);
	state.round = state.round + 1;
	doRoundHeader(state.round)
	
	spawnArenaNPC(121, spawnPos[2], 1);
	spawnArenaNPC(121, spawnPos[3], -1);
	spawnArenaNPC(121, spawnPos[1], 1);
	spawnArenaNPC(121, spawnPos[4], -1);
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(123, spawnPos[2], 1, {ai1 = 1});
	spawnArenaNPC(123, spawnPos[3], -1, {ai1 = 1});
	eventu.waitFrames(300);
	spawnArenaNPC(123, spawnPos[2], 1, {ai1 = 1});
	spawnArenaNPC(123, spawnPos[3], -1, {ai1 = 1});
	spawnArenaNPC(389, spawnPos[1], 1);
	spawnArenaNPC(389, spawnPos[4], -1);
	
	waitUntilDead();
	eventu.waitFrames(48);
	
	spawnArenaNPC(315, spawnPos[2], 1);
	spawnArenaNPC(315, spawnPos[3], -1);
	eventu.waitFrames(196)
	spawnArenaNPC(313, spawnPos[1], 1);
	spawnArenaNPC(313, spawnPos[4], -1);
	
	
	waitUntilDead();
	eventu.waitFrames(64);
	state.round = state.round + 1;
	doRoundHeader(state.round)
	
	spawnArenaNPC(15, spawnPos[2], 1);
	spawnArenaNPC(15, spawnPos[3], -1);
	eventu.waitFrames(500)
	spawnArenaNPC(280, spawnPos[1], 1);
	spawnArenaNPC(280, spawnPos[4], -1);
	
	waitUntilDead();
	
	Audio.SeizeStream(10);
	Audio.MusicStopFadeOut(1000);
	
	eventu.waitFrames(64);
	
	blockInput = true;
	
	Audio.playSFX(52);
	state.round = state.round + 1;
	
	eventu.waitFrames(256);
	
	minigame.exit();
end

local minigameRound = 0;

 --arena minigame
local function cor_exitarena(state)
	local t = 0;

	
	blockInput = true;
	while(t < 1) do
		if(player:mem(0x13E, FIELD_WORD) > 120) then
			player:mem(0x13E, FIELD_WORD, 120)
		end
		t = t+0.025;
		Graphics.drawScreen{color = math.lerp(Color.transparent, Color.black, t), priority = 4};
		eventu.waitFrames(0);
	end
	
	for _,v in ipairs(arenaNPCs) do
		if(v.isValid) then
			v:kill(9);
		end
	end
	
	player:mem(0x13E, FIELD_WORD, 0)
	player.x = state.owner.x + state.owner.width*0.5 + 32 - player.width*0.5;
	player.y = -player.height-64-20000;
	player:mem(0x15A,FIELD_WORD,9) --player.section = 9;
	
	minigame.restorePlayerState();
	
	Graphics.drawScreen{color = Color.black, priority = 4};
	
	playMusic(9);
	Audio.ReleaseStream(10);
	
	while(t > 0) do
		t = t-0.025;
		Graphics.drawScreen{color = math.lerp(Color.transparent, Color.black, t), priority = 4};
		eventu.waitFrames(0);
	end
	
	minigameRound = state.round;
	a2xt_message.talkToNPC(state.owner)
	
	blockInput = false;
end

function minigame.onEnd(state)
	eventu.run(cor_exitarena, state);
end

local function cor_openIdolDoor(args)
	idolDoorOpen = true;
	local delay = 0.5;
	
	local tempTargets = cameraman.playerCam[1].targets;
	
	cameraman.playerCam[1]:Queue {time=1, targets={{x=-175744, y=-181184-player.height}}, easeBoth=cameraman.EASE.QUAD};
	
	eventu.waitSeconds(1);
	
	for i = 1,4 do
		eventu.waitSeconds(0.5);
		idolDoor[i]:hide(false); 
		Audio.playSFX(37);
		Defines.earthquake = 2;
	end
	
	eventu.waitSeconds(0.5);
	
	Audio.playSFX("smash.ogg");
	Defines.earthquake = 8;
	
	eventu.waitSeconds(0.5);
	
	cameraman.playerCam[1]:Queue {time=1, targets=tempTargets, easeBoth=cameraman.EASE.QUAD};
	
	eventu.waitSeconds(1);
	
	a2xt_scene.endScene();
end

do --funky dialogue
	a2xt_message.presetSequences.buyStoneIdol = function(args)
		local talker = args.npc
		
		if(idolsReady[156] or idolsDone[156]) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Hey again. Sorry, I'm all outta curios this time.<page>Hope you got some good use outta that rock though!"}
			a2xt_message.waitMessageEnd()
		else
			local price = 20;
			a2xt_message.promptChosen = false
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Hey. Want to buy something cool? Only asking for "..price..CHAR_RC..".", closeWith="prompt"}
			a2xt_message.waitMessageDone()
			
			a2xt_scene.displayRaocoinHud(true);
			
			a2xt_message.showPrompt()
			a2xt_message.waitPrompt()
			
			if a2xt_message.promptChoice == 1 then
				if(a2xt_raocoins.buy(price)) then
					a2xt_message.showMessageBox {target=talker, type="bubble", text="Pleasure doing business with ya!"}
					idolsReady[156] = true
					SaveData.world3.town.stoneIdolReady = true;
				else
					a2xt_message.showMessageBox {target=talker, type="bubble", text="Hey now... I've gotta make a living here..."}
				end
			elseif  a2xt_message.promptChoice == 2  then
				a2xt_message.showMessageBox {target=talker, type="bubble", text="Aw. Shame. I know you would have liked it too..."}
			end	
			
			a2xt_message.waitMessageEnd()
			
			a2xt_scene.displayRaocoinHud(false);
		
		end
		
		a2xt_scene.endScene()
		a2xt_message.endMessage();
	end
	
	a2xt_message.presetSequences.garish = function(args)
		local talker = args.npc;
		
		if(SaveData.world3.town.garishComplete) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Hmm...\0"}
			a2xt_message.waitMessageEnd();
			
			a2xt_scene.endScene()
			a2xt_message.endMessage();
			
		else
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Well now, look who it is!<page>These fine people have finally realised my extreme prowess and elevated me to my rightful place as the King of Time!<page>With all of time as my dominion, I will conquer the world!"}
			a2xt_message.waitMessageEnd();
			
			local tempTargets = cameraman.playerCam[1].targets
			cameraman.playerCam[1]:Queue {time=0.5, targets={talker}, easeBoth=cameraman.EASE.QUAD, zoom=2}
			
			a2xt_message.showMessageBox {target=talker, type="bubble", text="...\0"}
			a2xt_message.waitMessageEnd();
			
			cameraman.playerCam[1]:Queue {time=0.5, targets={talker}, easeBoth=cameraman.EASE.QUAD, zoom=3}
			
			a2xt_message.showMessageBox {target=talker, type="bubble", text="......\0"}
			a2xt_message.waitMessageEnd();
			
			cameraman.playerCam[1]:Queue {time=0.5, targets=tempTargets, easeBoth=cameraman.EASE.QUAD, zoom=1.5}
			
			a2xt_message.showMessageBox {target=talker, type="bubble", text="...Wait, if I rule time, does that mean I <tremble>ALREADY</tremble> rule the world?!?<page>I need to think about this...<page>Oh, you're still here?<page>Take this card or whatever."}
			a2xt_message.waitMessageEnd();
			
			
			eventu.waitSeconds(0.5)
			
			eventu.waitFrames(0)
			
			cameraman.playerCam[1]:Queue {time=0.25, targets={player}, easeBoth=cameraman.EASE.QUAD, zoom=1.5}
			
			a2xt_rewards.give{type="card", quantity="butts", useTransitions = false, endScene = false, wait=true}
			
			cameraman.playerCam[1]:Queue {time=0.25, targets={player}, easeBoth=cameraman.EASE.QUAD, zoom=1}
			
			SaveData.world3.town.garishComplete = true;
			talker.data.talkIcon = 1;
			talker.data.a2xt_message.iconSpr.state = 1;
			
			a2xt_scene.endScene()
			a2xt_message.endMessage();
		end
	end
	
	a2xt_message.presetSequences.arena = function(args)
		local talker = args.npc;
			
		local price = 5;
		
		if(minigameRound ~= 0) then
			if(minigameRound > 5) then --WINNER IS YOU
				if(not SaveData.world3.town.fireIdolReady) then
					a2xt_message.showMessageBox {target=talker, type="bubble", text="Wow! That was incredible! We have a new champion!<page>You've won our champion's trophy!"}
					a2xt_message.waitMessageEnd();
					SaveData.world3.town.fireIdolReady = true;
					idolsReady[154] = true;
					local tempTargets = cameraman.playerCam[1].targets;
					
					cameraman.playerCam[1]:Queue {time=0.5, targets={{x=-18992; y=-20256; width=32; height=32;}}, easeBoth=cameraman.EASE.QUAD, zoom = 2}
					
					a2xt_message.showMessageBox {target=talker, type="bubble", text="The trophy is actually sitting above the door there, so just grab it when you're ready!", keepOnscreen = true}
					a2xt_message.waitMessageEnd();
					
					cameraman.playerCam[1]:Queue {time=0.5, targets=tempTargets, easeBoth=cameraman.EASE.QUAD, zoom = 1.5}
					
					a2xt_message.showMessageBox {target=talker, type="bubble", text="It's your trophy for good now, but if you can beat the Arena again, you'll get a bunch of raocoins in reward! It's a sweet deal!"}
					a2xt_message.waitMessageEnd();
				else
					a2xt_message.showMessageBox {target=talker, type="bubble", text="DING DING DING! We have a winner!<page>Here's your prize!"}
					a2xt_message.waitMessageEnd();
					
					a2xt_rewards.give{type="raocoin", quantity=20, useTransitions = false, endScene = false, wait=true}
				end
			elseif(minigameRound >= 4) then
				a2xt_message.showMessageBox {target=talker, type="bubble", 
				text="Ah, so close! You may not have won the grand prize, but you've won your entry fee back, so that's something!"}
				a2xt_message.waitMessageEnd();
				a2xt_rewards.give{type="raocoin", quantity=price, useTransitions = false, endScene = false, wait=true}
			else
				a2xt_message.showMessageBox {target=talker, type="bubble", 
				text="Aww, what a shame. Better luck next time!"}
				a2xt_message.waitMessageEnd();
			end
			
			minigameRound = 0;
		else
		
			a2xt_message.showMessageBox {target=talker, type="bubble", 
			text="Hello, and welcome to the Temporis Arena!<page>Here you can compete in gladitorial combat for a chance to win big!"}
			a2xt_message.waitMessageEnd();
			if(not SaveData.world3.town.fireIdolReady) then
				a2xt_message.showMessageBox {target=talker, type="bubble", text="We're currently searching for a champion to take home our grand trophy, think you're up for the task?"}
				a2xt_message.waitMessageEnd();
			end
			
			a2xt_message.promptChosen = false
			a2xt_message.showMessageBox {target=talker, type="bubble", text="How about giving it a shot? The entry fee is only "..price..CHAR_RC..", sound good?", closeWith="prompt"}
			a2xt_message.waitMessageDone()
				
			a2xt_scene.displayRaocoinHud(true);
				
			a2xt_message.showPrompt()
			a2xt_message.waitPrompt()
			
			if(a2xt_message.promptChoice == 1) then
				if(a2xt_raocoins.buy(price)) then
					a2xt_message.showMessageBox {target=talker, type="bubble", text="Beat all 5 rounds to score our top prize!<page>Are you ready?"}
					a2xt_message.waitMessageEnd();
					minigame.start(cor_arena, {round = 1, owner = talker});
				else
					a2xt_message.showMessageBox {target=talker, type="bubble", text="Oof. Sorry, but you can't compete unless you can front the entry fee."}
					a2xt_message.waitMessageEnd();
				end
			else
				a2xt_message.showMessageBox {target=talker, type="bubble", text="Your loss. Come back if you change your mind."}
				a2xt_message.waitMessageEnd();
			end
		
			a2xt_scene.displayRaocoinHud(false);
		end
		
		a2xt_scene.endScene()
		a2xt_message.endMessage();
	end
	
	a2xt_message.presetSequences.bes = function(args)
		local talker = args.npc;
		
		if(SaveData.chests[Level.filename()]["1"]) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Oh, that's what it was? That's not a rare one at all.<page>You can keep that card. I've got 6 more."}
		elseif(idolDoorOpen) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Oh man! You got the door open!"}
		else
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Gosh darnit. I left one of my trading cards in that chest over there, and now the door is locked.<page>It was a pretty rare one too... darn..."}
		end
		a2xt_message.waitMessageEnd();
			
		a2xt_scene.endScene()
		a2xt_message.endMessage();
		
		--[[ --Old text for Garish
		local talker = args.npc;
		
		local val = "acquaintance";
		if(player.character == CHARACTER_DEMO or player.character == CHARACTER_IRIS) then
			val = "brother";
		end
		
		if(SaveData.world3.town.garishComplete) then
			if(#NPC.get(65) >= 1) then
				a2xt_message.showMessageBox {target=talker, type="bubble", text="Oh dear, he seems to be thinking about something.<page>We may have to come up with a new plan..."}
			else
				a2xt_message.showMessageBox {target=talker, type="bubble", text="We've had to move your "..val.." over to P.O.R.T. to keep an eye on him.<page>He should be out of harm's way there."}
			end
		else
			a2xt_message.showMessageBox {target=talker, type="bubble", text="You may be wondering what you semi-liquid "..val.." is doing sitting on that throne there.<page>He is under the impression that he is the King of Time.<page>We thought this would be the most effective way to pacify him, or at least the way that would cause the least collateral damage.<page>To be perfectly honest, he's just so overjoyed to be in power that he hasn't actually tried to use it.<page>So far all he's done is lock himself in demanding 'tribute'.<page>Well, it's all for the best. Just humour him, it'll make things much easier."}
		end
		
		a2xt_message.waitMessageEnd();
			
		a2xt_scene.endScene()
		a2xt_message.endMessage();
		]]
	end
	
	
	a2xt_message.presetSequences.arn = function(args)
		local talker = args.npc;
		
		if(talker.data.expletive) then
			talker.data.expletive:closeSelf()
			talker.data.expletive = nil;
		end
		
		a2xt_message.showMessageBox {target=talker, type="bubble", text="DAMN THIS GAME!"}
		a2xt_message.waitMessageEnd();
			
		a2xt_scene.endScene()
		a2xt_message.endMessage();
	end
	
	a2xt_message.presetSequences.dog = function(args)
		local talker = args.npc;
		
		if(player:mem(0x154,FIELD_WORD) > 0 and player.holdingNPC ~= nil and player.holdingNPC.id == 985) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="!!! Identity thief!"}
		elseif(SaveData.world3.town.spokenToDog) then
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Woof."}
		else
			a2xt_message.showMessageBox {target=talker, type="bubble", text="Hi, I'm Dog."}
		end
		
		SaveData.world3.town.spokenToDog = true;
		talker.data.name = "Dog"
		
		a2xt_message.waitMessageEnd();
			
		a2xt_scene.endScene()
		a2xt_message.endMessage();
	end
end


function onStart()
	if(SaveData.world3.town.garishComplete) then
		for _,v in ipairs(NPC.get(65)) do
			v:kill(9)
		end
	end
	
	if(SaveData.world3.town.spokenToDog) then
		for _,v in ipairs(NPC.get(403, 13)) do
			v = pnpc.wrap(v);
			v.data.name = "Dog";
		end
	end
	
	local allidolsplaced = true;
	for k,_ in pairs(idolsDone) do
		if(not SaveData.world3.town["idol"..k]) then
			allidolsplaced = false;
		end
	end

	if(idolsReady[154] or SaveData.world3.town.idol154) then
		Layer.get("FireBGOs"):hide(true);
	end
	
	if(allidolsplaced) then
		idolDoorOpen = true;
		for i = 1,4 do
			idolDoor[i]:hide(true); 
		end
	end
	
	for _,v in ipairs(NPC.get()) do
		v = pnpc.getExistingWrapper(v);
		if(v and v.data.saveDeath and SaveData.world3.town[v.data.saveDeath]) then
			v:kill(9);
		end
	end
	
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
	if(colliders.collide(npc,c) or SaveData.world3.town["idol"..npc.id]) then
		idolsDone[npc.id] = true;
		SaveData.world3.town["idol"..npc.id] = true;
		npc:kill(9);
		if(lunatime.tick() > 2) then
			Animation.spawn(10,c.x,c.y);
		end
		Audio.playSFX(37);
		for _,v in ipairs(Block.getIntersecting(c.x,c.y,c.x+c.width,c.y+c.height)) do
			if(v.id == idolBlocks[npc.id]) then
				idolOverlays[v.id].visible = true;
				idolOverlays[v.id].x = v.x - 8;
				idolOverlays[v.id].y = v.y + 16;
				v:mem(0x1C, FIELD_WORD, 0);
				break;
			end
		end
		return true;
	end
	return false;
end

function onNPCKill(event, npc, reason)
	npc = pnpc.getExistingWrapper(npc);
	if(npc and npc.data.saveDeath) then
		SaveData.world3.town[npc.data.saveDeath] = true;
	end
end


local wheelTime = 0;
	
function onTick()
	local allIdolsDone = true;
	local bounds = Section(1).boundary;
	
	for _,k in ipairs(idolIDs) do
		if(not idolsDone[k]) then
			allIdolsDone = false;
			local ps = NPC.get(k,-1);
			local pcnt = #ps;
			local oob = false;
			if(pcnt >= 1) then
				oob = (ps[1]:mem(0x146, FIELD_WORD) == 1 and (ps[1].x > bounds.right or ps[1].x < bounds.left-32 or ps[1].y > bounds.bottom or ps[1].y < bounds.top-32));
			end
			if((pcnt < 1 or oob or not idolsReady[k]) and not (player:mem(0x154,FIELD_WORD) > 0 and player.holdingNPC ~= nil and player.holdingNPC.id == k)) then
				if(pcnt >= 1) then
					ps[1]:kill(9);
				end
				if(idolsReady[k]) then
					local v = NPC.spawn(k,idolSpawns[k].x,idolSpawns[k].y,1);
					
					if(k == 154) then -- fire idol
						Layer.get("FireBGOs"):hide(true);
					else
						Animation.spawn(10,v.x,v.y);
					end
					
					v:mem(0x12A,FIELD_WORD,180);
					v:mem(0xA8,FIELD_DFLOAT,v.x);
					v:mem(0xB0,FIELD_DFLOAT,v.y);
				end
			end
			for _,v in ipairs(ps) do
				if(k == 154) then
					v = pnpc.wrap(v);
					if(v:mem(0x12C,FIELD_WORD) > 0) then
						v.data.grabbed = true;
					end
					if(not v.data.grabbed) then
						v.speedY = -Defines.npc_grav;
					end
				end
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
		a2xt_scene.startScene{scene=cor_openIdolDoor}
	end
	
	--Update Bes' icon
	if(idolDoorOpen) then
		for _,v in ipairs(NPC.get(107,1)) do
			v = pnpc.wrap(v);
			if(v.data.name == "Bes" and v.data.a2xt_message) then
				v.data.talkIcon = 1;
				v.data.a2xt_message.iconSpr.state = 1;
			end
		end
	end
	
	if(player.section == 1) then
		
		for _,v in pairs(idolOverlays) do
			if(v.visible) then
				v.alpha = math.min(1,v.alpha + 0.1);
			end
		end
	
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
	elseif(player.section == 11) then --game grumps
		if(not a2xt_scene.inCutscene and rng.random() < 0.02) then
			local npc = pnpc.wrap(NPC.get(404,11)[1]);
			if(npc.data.expletive == nil or npc.data.expletive:isFinished()) then
				npc.data.expletive = a2xt_message.showMessageBox 
				{
					target=npc, x=npc.x,y=npc.y, 
					text=rng.irandomEntry
					{
					"DAMMIT!", "NO!\0", "ARRRRGHHH!", "WHAT IS THIS?", "WHAT IS MY LIFE?", "This time for real.", "How am I supposed to watch anime on a sushi?","I! WANT! MURDER!","I'm OUT.",
					"EVERYTHING I KNOW IS A LIE!","Really? Yeah? Okay, fine. FINE. ALRIGHT.","This is a SCONE.","You are uninvited to my birthday party.","WHAT?! YOU DECAYING MONGOOSE!",
					"Dude, just... just pity laugh, at least.","I'm not physically good at anything aside from yelling a lot.","Dude, I just had a smart for a sec.","I'll just steal and destroy another cop car.",
					"My dad told me that I would be accepted as I am. As a true man. Little did he know that that wouldn't be the case, actually.", "Why do you enjoy watching me suffer so?", 
					"If by okay you mean like on the inside I'm just going AAAAAAAHHHHHH! Then yes I'm quite okay.","I didn't have any problem at all after I died twice.", "Such a nice man we ripped off there.",
					"HEY LADIES. I'M TOM JONES. LEADER OF THE TOM JONES CULT. MY NAME'S TOM JONES. GIMME THIRTY APPLES. TWENTY-FIVE APPLES.", "23 is my number!", "Yes... yes... NOOOOO!", "Even 90s rock won't make me feel good about this!",
					"I don't know anything about memes.", "I moved to Madagascar... where my best friend was a SLOTH!", "I'm in a totally different spot now. Like a spot I wasn't before.", "Um, did you see how strong his bullet was?",
					"My eyebrows are slippery and slimy. I grease them.", "MARK ZUCKERBERG!", "Well thank you so much, that's so nice of you to say, but I don't believe you and you're a liar.", "If you can't beat em, shoot 'em with a gun!"
					}.."<pause 30>", 
					closeWith = "auto"
				}
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

function onInputUpdate()
	if(blockInput) then
		player.keys.jump = false;
		player.keys.altJump = false;
		player.keys.left = false;
		player.keys.right = false;
		player.keys.run = false;
		player.keys.altRun = false;
		player.keys.up = false;
		player.keys.down = false;
		player.keys.pause = false;
		player.keys.dropItem = false;
		a2xt_pause.Block();
	end
end

local reflections = Graphics.CaptureBuffer(800,600);
local waterShader = nil;

local npc_hardcoded = 
{
	[109] = {framestyle = 1, frames = 2};
	[121] = {framestyle = 1, frames = 2};
	[29] = {framestyle = 1, frames = 3};
	[130] = {framestyle = 2, frames = 2};
	[129] = {framestyle = 2, frames = 2};
	[135] = {framestyle = 2, frames = 2};
	[39] = {framestyle = 1, frames = 5};
	[77] = {framestyle = 1, frames = 2};
	[123] = {framestyle = 1, frames = 2};
	
	[389] = {framestyle = 1, frames = 3};
	[313] = {framestyle = 1, frames = 7};
	[315] = {framestyle = 1, frames = 3};
	[280] = {framestyle = 1, frames = 5};
}

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
	
	do
		--Arena Lobby stuff
		
		for _,v in ipairs(NPC.get(111,9)) do
			v.x = v:mem(0xA8, FIELD_DFLOAT)
		end
		
		--Minigame stuff
		if(minigame.inGame) then
		
			if(player:mem(0x13E, FIELD_WORD) > 120) then
				player:mem(0x13E, FIELD_WORD,120);
				minigame.exit();
			end
		
			--"generator" hackery
			if(arenaNPCs) then
				local npcsInArena = NPC.get(NPC.HITTABLE,10);
				if(#npcsInArena > #arenaNPCs) then
					for _,v in ipairs(npcsInArena) do
						v = pnpc.wrap(v);
						if(not table.ifind(arenaNPCs, v)) then
							v.data.t = 9999;
							table.insert(arenaNPCs, v);
						end
					end
				end
				for i = #arenaNPCs,1,-1 do
					local v = arenaNPCs[i];
					if(v.isValid) then
						v:mem(0x12A,FIELD_WORD, 180);
						local t = v.data.t/32;
						if(t <= 1) then
							local gfxHeight = v:mem(0xB8, FIELD_DFLOAT);
							local gfxWidth = v:mem(0xC0, FIELD_DFLOAT);
							v.speedX = 0;
							v.speedY = 0;
							v.x = -100;
							v.y = 0;
							v.data.t = v.data.t + 1;
							v.friendly = true;
							local y = 0;
							local id = v.id;
							local cfg = NPC.config[id];
							if(v.direction == 1) then
								if(cfg.framestyle >= 1 or (npc_hardcoded[id] and npc_hardcoded[id].framestyle and npc_hardcoded[id].framestyle >= 1)) then
									local frms = cfg.frames;
									if(npc_hardcoded[id] and npc_hardcoded[id].frames) then
										frms = npc_hardcoded[id].frames;
									end
									y = (frms)*gfxHeight;
								end
							end
							
							Graphics.draw{type = RTYPE_IMAGE, 
											x = v.data.x + (v.width - gfxWidth)*0.5 + cfg.gfxoffsetx, 
											y = v.data.y + (v.height - gfxHeight) + cfg.gfxoffsety + math.lerp(gfxHeight,0,t), 
											isSceneCoordinates = true, 
											priority = -75, 
											image = Graphics.sprites.npc[v.id].img, 
											sourceX = 0, sourceY = y, sourceWidth = gfxWidth, sourceHeight = math.lerp(0,gfxHeight,t)
										}
						else
							if(v.friendly) then
								v.friendly = false;
								v.x = v.data.x;
								v.y = v.data.y;
							end
						end
					else
						table.remove(arenaNPCs,i);
					end
				end
			end
		end
	end
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
		ycam = ybound - 560 + (cam.height - cameraman.playerCam[1].zoomedHeight)*0.6;
		
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
		
		if(targetcamY > ycam+600 and math.abs(lastcamY-targetcamY) < 32) then
			cam.y = targetcamY;
		else
			cam.y = lastcamY*0.8 + targetcamY*0.2;
		end
		lastcamY = cam.y;
	end
end

function onCameraDraw()
	local cam = Camera.get()[1];
	
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
		
		for _,v in pairs(idolOverlays) do
			if(v.visible) then
				v.obj.x = v.x-cam.x;
				v.obj.y = v.y-cam.y;
				v.obj:Draw(-64,0xFFFFFF00+(v.alpha*255));
			end
		end
		
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