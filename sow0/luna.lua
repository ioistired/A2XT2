local leveldata = API.load("a2xt_leveldata")
local scene = API.load("a2xt_scene")

local eventu = API.load("eventu")
local cman = API.load("cameraman")
local animatx = API.load("animatx")

local costumes = API.load("a2xt_costumes");
local actors = API.load("a2xt_actor");
local pause = API.load("a2xt_pause");
local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local textblox = API.load("textblox");
local checkpoints = API.load("checkpoints");

local playerManager = API.load("playerManager")

local broadsword = API.load("Characters/unclebroadsword")

local audioMaster = API.load("audioMaster");

local panim = API.load("playerAnim");




local function cor_intro()
	Audio.resetMciSections()
	--playMusic(1)

	local pStates = Player.getTemplates()
	for  k,v in pairs(pStates)  do
		if  v.powerup == PLAYER_SMALL  then
			v.powerup = PLAYER_BIG
		end
	end

	-- Move the player to the proper section
	scene.setTint{color=0x000000FF}
	player.section = 1
	player.x = -179500
	player.y = -180200
	eventu.waitFrames(4)

	-- Initialize Actor objects for the krew
	actors.groundY = -180160
	ACTOR_DEMO:PlayerReplaceNPC()
	actors.KrewToActors()
	ACTOR_DEMO.direction = DIR_RIGHT

	local cam = cman.playerCam[1]

	-- Start panning and fading in
	cam.targets={}
	cam.x = -180400
	cam.y = -180225
	cam:Queue{time=8, zoom=1.5, x=-179050}--, easeBoth=cman.EASE.QUAD, zoom=1.25}
	scene.setTint{color=0x00000000, time=3}
	eventu.waitSeconds(8)

	--[[
	ACTOR_IRIS:Jump{strength=9}
	eventu.waitSeconds(1)
	ACTOR_IRIS:Walk{speed=-2}
	eventu.waitSeconds(1)
	ACTOR_IRIS:Walk{speed=2}
	eventu.waitSeconds(2)
	ACTOR_IRIS:Walk{speed=-2}
	eventu.waitSeconds(1)
	ACTOR_IRIS:StopWalking()
	--]]

	-- Begin conversation
	ACTOR_KOOD : Emote("happy")
	eventu.waitSeconds(1)
	ACTOR_KOOD : Talk{text="Man, isn't it great how we defeated Science and saved the universe and nothing bad happened at all ever?"}
	eventu.waitSeconds(0.5)
	ACTOR_IRIS.direction = DIR_RIGHT
	message.waitMessageEnd()
	eventu.waitSeconds(1)

	ACTOR_IRIS.direction = DIR_LEFT
	ACTOR_IRIS : Talk{text="Somebody remind me why we invited Kood again?"}
	message.waitMessageEnd()

	ACTOR_DEMO : Talk{text="<i>We<i/> didn't, Pily did."}
	message.waitMessageEnd()

	ACTOR_IRIS : Talk{text="I swear, I just don't know what she sees in him..."}
	message.waitMessageEnd()

	ACTOR_KOOD : Emote("sweat")
	ACTOR_RAOCOW : Walk{speed=-2}
	cam : Queue{time=1, zoom=1.25, x=-178900}--, easeBoth=cman.EASE.QUAD}
	eventu.waitSeconds(1)

	ACTOR_RAOCOW : StopWalking()
	ACTOR_DEMO.direction = DIR_RIGHT
	ACTOR_IRIS.direction = DIR_RIGHT
	ACTOR_KOOD.direction = DIR_RIGHT
	ACTOR_RAOCOW : Talk{text="Hey, everyone!  We should play hide and seek!<page>The winner gets the last chicken wing!"}
	message.waitMessageEnd()
	eventu.waitSeconds(1)

	ACTOR_IRIS : Talk{text="...<page>Fine, it's better than sitting around and listening to the turtle.  You go first, Sis."}
	message.waitMessagePage(nil, 2)
	ACTOR_IRIS.direction = DIR_LEFT
	message.waitMessageEnd()
end

local function skip_intro()
	
end

local function cor_picnic()
	
end

local function skip_picnic()
	
end



local hubLevel = "hub.lvl"
function onStart()
	mem(0xB2572A,FIELD_BOOL,false)


	-- If the hub is unlocked, start there
	if  leveldata.Visited(hubLevel)  then
		leveldata.LoadLevel(hubLevel)

	-- else if the player is in world 1 or 2
	elseif  leveldata.GetWorldsUnlocked() > 0  then

		-- if the current SOW level is beaten, go to that submap
		if  leveldata.GetWorldsUnlocked() == leveldata.GetMapsUnlocked()  then
			Level.exit()

		-- else if the player is currently on a different SOW level, go to that one
		else
			mem(0xB2572A,FIELD_BOOL,true)
			leveldata.LoadLevel(leveldata.GetWorldStart(leveldata.GetWorldsUnlocked()))
		end

	-- Else if in the tutorial world
	elseif  SaveData.currentTutorial ~= nil  then
		mem(0xB2572A,FIELD_BOOL,true)
		leveldata.LoadLevel(SaveData.currentTutorial)

	-- else start the intro cutscene
	else
		scene.startScene{scene=cor_intro, skip=skip_intro}
	end
end
