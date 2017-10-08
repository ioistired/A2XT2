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

boss.SuperTitle = "Maximillion"
boss.Name = "Pumpernickle"
boss.SubTitle = "Off Several Rockers"

boss.MaxHP = 100;

boss.TitleDisplayTime = 360;

local bossBegun = false;
local nomusic = false;
local Zero = vectr.v2(0,0);

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

function events.InitBoss(fromCheckpoint)
	Zero.x = Section(bossAPI.section).boundary.left;
	Zero.y = Section(bossAPI.section).boundary.top;
	
	--[[
	core_audio.x = Zero.x+400;
	core_audio.y = Zero.y+300;
	]]
	
	StartBoss();
end

function bossAPI.onTick()
	tess.rotationXYZ = tess.rotationXYZ + tess_rotspdxyz*tess_spdmult;
	tess.rotationW = tess.rotationW + tess_rotspdw*tess_spdmult;
	
	backgrounds.flipnumber = lunatime.time()-flip_stabletime;
	
	--Workaround for bug with music resuming erroneously when the window loses focus
	if(nomusic) then
		Audio.MusicStop();
		lastAudioClock = 0;
	else
		if(Audio.MusicClock() >= audiotimer) then
			progressMusic();
		end
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