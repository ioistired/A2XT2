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

--contains the top left corner of the boss section, useful for positioning
local Zero = vectr.v2(0,0);

--store event sequences here
local events = {};

--store cutscene sequences here
local cutscene = {};

local bossSection = 0;
local mainloop;

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

--Called by the level luna code to start the boss
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

--coroutine containing the main boss event loop
local function EventLoop()
end

--use this to abort all the boss coroutines for when the fight is over
local function AbortEvents()
	eventu.abort(mainloop); --abort the boss event loop
end

--initialises the boss library and starts the event loop
local function StartBoss()
	boss.Start();
	--start the event loop
	_,mainloop = eventu.run(EventLoop);
end

local function DrawBoss()
end

function bossAPI.onTick()
	if(boss.Active) then --only run code while the boss is active
		if(boss.isDefeated()) then
			boss.Active = false; --hides HP bar
			AbortEvents(); --abort all the boss events
			
			--end boss events
		end
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

--waitAndDo is a useful coroutine function - it waits t frames and performs func() every frame
local function waitAndDo(t, func)
	while(t > 0) do
		t = t-1;
		func();
		eventu.waitFrames(0);
	end
end

--cutscene to play when entering from the checkpoint
function cutscene.intro_checkpoint()
	
	scene.endScene();
	
	StartBoss();
end

--cutscene to play when starting the boss for the first time
function cutscene.intro()
	scene.endScene();
	
	cp:collect();
	
	StartBoss();
end

--Initial setup, should more or less be kept alone in most cases
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