local bossAPI = {};

local vectr = API.load("vectr");
local eventu = API.load("eventu");
local colliders = API.load("colliders");
local boss = API.load("a2xt_boss");
local pause = API.load("a2xt_pause");
local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local textblox = API.load("textblox");
local checkpoints = API.load("checkpoints");

local playerManager = API.load("playerManager")

boss.SuperTitle = "This is"
boss.Name = "A Boss"
boss.SubTitle = "He's probably cool"

boss.MaxHP = 100;

boss.TitleDisplayTime = 360;

local bossBegun = false;
local Zero = vectr.v2(0,0);

local events = {};
local cutscene = {};

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

function bossAPI.Begin(fromCheckpoint)
	if(not bossBegun) then
		registerEvent(bossAPI, "onTick");
		registerEvent(bossAPI, "onDraw");
		registerEvent(bossAPI, "onCameraUpdate");
		
		bossBegun = true;
		
		Audio.SeizeStream(bossAPI.section);
		Audio.MusicStop();
		
		events.InitBoss(fromCheckpoint);
	end
end

local function StartBoss()
	boss.Start();
end

local function DrawBoss()
end

function bossAPI.onDraw()
	DrawBoss();
end

function bossAPI.onCameraUpdate()
	if(Zero ~= nil) then
		Camera.get()[1].x = Zero.x;
	end
end


local function waitAndDo(t, func)
	while(t > 0) do
		t = t-1;
		func();
		eventu.waitFrames(0);
	end
end

function cutscene.intro_checkpoint()
	--INTRO CUTSCENE WITH CHECKPOINT
	
	scene.endScene();
	
	StartBoss();
end

function cutscene.intro()

	--INTRO CUTSCENE
	
	scene.endScene();
	
	cp:collect();
	
	StartBoss();
end

function events.InitBoss(checkpoint)
	Zero.x = Section(bossAPI.section).boundary.left;
	Zero.y = Section(bossAPI.section).boundary.top;
	
	if(checkpoint) then
		scene.startScene{scene=cutscene.intro_checkpoint, noletterbox=true}
	else
		scene.startScene{scene=cutscene.intro, noletterbox=true}
	end
end

return bossAPI;