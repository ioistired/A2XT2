local leveldata = API.load("a2xt_leveldata")
local scene = API.load("a2xt_scene")

local eventu = API.load("eventu")
local cman = API.load("cameraman")
local imagic = API.load("imagic")

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


SaveData.calleMemory = SaveData.calleMemory  or  {}
local calleMemory = SaveData.calleMemory

local function initCalleMemory()
	calleMemory.attempts = calleMemory.attempts  or  0
	calleMemory.wins = calleMemory.wins  or  0
	calleMemory.losses = calleMemory.losses  or  0
	calleMemory.perfects = calleMemory.perfects  or  0
	calleMemory.annoyance = calleMemory.annoyance  or  0
end



local NPCID = {
	RAOCOIN = 274
}

local allDagadons = false
local cheated = false
local uncheated = false
local allDagadons = false
local gotHit = false
local forcewin = false

local calleGroundY = -200190


local race = {
	startX = -199680,
	endX = -184032,
	flag = Graphics.loadImage(Misc.resolveFile("raceFlag.png")),
	calleHead = Graphics.loadImage(Misc.resolveFile("calleHead.png")),
	playerHead = nil,
	active = false
}
race.hudBox = imagic.Create{primitive=imagic.TYPE_BOX, x=400, y=550, align=imagic.ALIGN_CENTRE, width=400, height=10};


function onStart()
	actors.Player:BecomePlayer();
	race.playerHead = Graphics.loadImage(Misc.resolveFile(string.lower(CHARACTER_NAME[player.character]).."Head.png"))
end


function onDraw ()
	--if  race.active  then
		race.hudBox:Draw{priority=0.01, colour=0x00000099};
		local bar = {left=300, right=500}

		local playerProgress = math.clamp (math.invlerp(race.startX, race.endX, player.x), 0,1)
		local calleProgress = math.clamp (math.invlerp(race.startX, race.endX, ACTOR_CALLEOCA.x  or  player.x), 0,1)

		local playerPrior = 0.5
		local callePrior = 1

		if  (playerProgress >= calleProgress)  then
			playerPrior = 1
			callePrior = 0.5
		end

		if  race.playerHead ~= nil  then
			Graphics.drawImageWP(race.playerHead, 200 - 0.5*race.playerHead.width + 400*playerProgress,540-0.5*race.playerHead.height, playerPrior);
		end
		Graphics.drawImageWP(race.calleHead, 200 - 0.5*race.calleHead.width + 400*calleProgress, 540-0.5*race.calleHead.height, callePrior);
		Graphics.drawImageWP(race.flag, 600,750, 1);

	--end
end


function onLoop ()
	if  player.powerup == PLAYER_SMALL  and  player:mem(0x122, FIELD_WORD) == 0   then
		player.powerup = PLAYER_BIG
		gotHit = true
	end
	
	if  player:mem(0x122, FIELD_WORD) == 2  then
		if  player:mem (0x106, FIELD_WORD) == -1  then
			player.speedX = 6
		else
			player.speedX = -6
		end
	end

	if  player.y + player.height > Section(player.section).boundary.bottom + 16  then
		player.speedY = -2
	end

	if  ACTOR_CALLEOCA.bounds  then
		ACTOR_CALLEOCA.bounds.bottom = calleGroundY
	end

	if  #NPC.get(NPCID.RAOCOIN, -1) == 0  then
		if  allDagadons == false  then
			triggerEvent ("Show Perfect Star")
		end
		allDagadons = true
	end
end




-- ************************************************************
-- ** COROUTINES                                             **
-- ************************************************************

local function waitX(xpos)
	eventu.run (function()
		while  ACTOR_CALLEOCA.x < xpos  do
			eventu.waitFrames(0)
		end
		eventu.signal("calleAt"..tostring(xpos))
	end)

	return eventu.waitSignal("calleAt"..tostring(xpos))
end


local calleRaceRoutine
local function cor_calleocaPath()
	ACTOR_CALLEOCA.speedX = 5

	waitX(-199460)
	ACTOR_CALLEOCA : Jump {strength=7}

	waitX(-199060)
	ACTOR_CALLEOCA : Jump {strength=4}
	calleGroundY = calleGroundY - 64

	waitX(-199050)
	ACTOR_CALLEOCA : Jump {strength=5}
	calleGroundY = calleGroundY - 32

	--cinematX.startDialog (racerActor, ACTOR_CALLEOCA.nameString, "Last one there's a rotten egg!")

	eventu.waitSeconds (1.0)
	ACTOR_CALLEOCA : Jump {strength=4}

	eventu.waitSeconds (1)--1.0)
	ACTOR_CALLEOCA : Jump {strength=4}

	-- In water
	eventu.waitSeconds (0.8)

	while (ACTOR_CALLEOCA.x < -197000)  do
		ACTOR_CALLEOCA.speedX = 0
		ACTOR_CALLEOCA.x = ACTOR_CALLEOCA.x + 2
		if  ACTOR_CALLEOCA.y > -200100  then
			ACTOR_CALLEOCA : Jump {strength=1}
		end
		eventu.waitFrames(0)
	end

	-- In water
	while (ACTOR_CALLEOCA.x < -196800)  do
		if  ACTOR_CALLEOCA.isUnderwater == true  then
			eventu.waitSeconds (0.1)
			ACTOR_CALLEOCA : Jump {strength=6}
		end
		ACTOR_CALLEOCA.speedX = 2
		eventu.waitFrames(0)
	end
	
	ACTOR_CALLEOCA.speedX = 6
	eventu.waitSeconds (0.75)
	
	ACTOR_CALLEOCA.speedX = 5
	ACTOR_CALLEOCA : Jump {strength=5}
	
	eventu.waitSeconds (0.75)
	ACTOR_CALLEOCA.speedX = 6
	ACTOR_CALLEOCA : Jump {strength=6}
	
	-- Jump up the zigzag
	eventu.waitSeconds (0.5)
	ACTOR_CALLEOCA.speedX = 5
	ACTOR_CALLEOCA : Jump {strength=10}
	
	eventu.waitSeconds (0.8)
	ACTOR_CALLEOCA.speedX = -3
	ACTOR_CALLEOCA : Jump {strength=8}
	
	eventu.waitSeconds (0.8)
	ACTOR_CALLEOCA.speedX = 1
	ACTOR_CALLEOCA : Jump {strength=9}
	
	eventu.waitSeconds (0.75)
	ACTOR_CALLEOCA.speedX = 4
	
	eventu.waitSeconds (0.5)
	ACTOR_CALLEOCA.speedX = 3.5
	ACTOR_CALLEOCA : Jump {strength=9.25}

	eventu.waitSeconds (0.57)
	ACTOR_CALLEOCA.speedX = 3
	eventu.waitSeconds (0.035)
	ACTOR_CALLEOCA.speedX = 1
	eventu.waitSeconds (0.145)
	ACTOR_CALLEOCA : Jump {strength=8}
	
	-- Spike section
	eventu.waitSeconds (0.45)
	ACTOR_CALLEOCA.speedX = 4

	eventu.waitSeconds (0.25)
	ACTOR_CALLEOCA : Jump {strength=8}
	
	eventu.waitSeconds (0.75)
	--ACTOR_CALLEOCA.speedX = 5)
	eventu.waitSeconds (0.2)
	ACTOR_CALLEOCA : Jump {strength=6}
	
	eventu.waitSeconds (1.15)
	ACTOR_CALLEOCA.speedX = 5
	ACTOR_CALLEOCA : Jump {strength=7}
	
	while (ACTOR_CALLEOCA.x < -190030)  do
		ACTOR_CALLEOCA.speedX = 0
		ACTOR_CALLEOCA.x = ACTOR_CALLEOCA.x + 3
		if  ACTOR_CALLEOCA.y > -200100  then
			ACTOR_CALLEOCA : Jump {strength=1}
		end
		eventu.waitFrames(0)
	end
	
	-- Resurface
	while (ACTOR_CALLEOCA.x < -189940)  do
		if  ACTOR_CALLEOCA.y > -200100  then
			eventu.waitSeconds (0.1)
			ACTOR_CALLEOCA : Jump {strength=6}
		end
		ACTOR_CALLEOCA.speedX = 2
		eventu.waitFrames(0)
	end
	
	-- Jump into last water
	ACTOR_CALLEOCA.speedX = 5
	eventu.waitSeconds (1)
	ACTOR_CALLEOCA : Jump {strength=5}
	
	-- Last swim
	while (ACTOR_CALLEOCA.x < -189060)  do
		ACTOR_CALLEOCA.speedX = 0
		ACTOR_CALLEOCA.x = ACTOR_CALLEOCA.x + 3
		if  ACTOR_CALLEOCA.y > -200100  then
			ACTOR_CALLEOCA : Jump {strength=1}
		end
		eventu.waitFrames(0)
	end
	
	-- Last resurface
	while (ACTOR_CALLEOCA.x < -188900)  do
		if  ACTOR_CALLEOCA.isUnderwater == true  then
			eventu.waitSeconds (0.1)
			ACTOR_CALLEOCA : Jump {strength=6}
		end
		ACTOR_CALLEOCA.speedX = 2
		eventu.waitFrames(0)
	end


	-- Second-to-last dash
	while (ACTOR_CALLEOCA.x < -187880)  do
		ACTOR_CALLEOCA.speedX = 5
		eventu.waitFrames(0)
	end


	-- Jump up to the final dash
	ACTOR_CALLEOCA.speedX = 1
	ACTOR_CALLEOCA : Jump {strength=9}

	eventu.waitSeconds (1)
	ACTOR_CALLEOCA.speedX = 0
	ACTOR_CALLEOCA : Jump {strength=9}

	eventu.waitSeconds (0.75)
	ACTOR_CALLEOCA.speedX = 2
	ACTOR_CALLEOCA : Jump {strength=8}

	eventu.waitSeconds (0.8)
	ACTOR_CALLEOCA:walkToX (raceEndX+96, 5)


	--ACTOR_CALLEOCA:walk (0)

	-- Now in water
	--ACTOR_CALLEOCA : Jump {strength=4}

end



local function cor_countdown()
	Audio.MusicStopFadeOut (1000)

	eventu.waitSeconds (1)
	Audio.MusicVolume(0)

	eventu.waitSeconds (1.5)

	Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
	triggerEvent ("Show One")
	eventu.waitSeconds (1)

	Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
	triggerEvent ("Show Two")
	eventu.waitSeconds (1)

	Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
	triggerEvent ("Show Three")
	eventu.waitSeconds (1)

	Audio.playSFX (Misc.resolveFile("racecount_2.ogg"))
	triggerEvent ("Show Go")
	eventu.waitSeconds (1)

	Audio.MusicVolume(128)
	race.active = true
	triggerEvent ("Race Start")

	calleMemory.attempts = calleMemory.attempts + 1
	_, calleRaceRoutine = eventu.run (cor_calleocaPath)

	--[[
	activeRaceRoutine = cinematX.beginRace (racerActor, ACTOR_CALLEOCA:getX (), raceEndX, 
											coroutine_racerPath, coroutine_LoseRace, coroutine_WinRace)
	--]]
end


message.presetSequences.eraseMemory = function(args)
	local talkerNpc = args.npc;
	local talker = {x=talkerNpc.x, y=talkerNpc.y, width=talkerNpc.width, height=talkerNpc.height}

	initCalleMemory()
	message.showMessageBox {target=talker, type="bubble", text="Hi there, welcome to the super-secret debug room the level creator may or may not have left in by mistake!<page>Would you like to reset Calleoca's memory?", closeWith="prompt"}
	message.waitMessageDone()

	message.promptChosen = false
	message.showPrompt()
	message.waitPrompt()

	if  (message.promptChoice == 1)  then
		local finalText = "Okie-dokie!  I'll just wipe all of her memories of her encounters with you in this level.<page>Memories she will never get back.<page>Ever.<page>But it's just for the sake of testing and debugging and all that, right?  It's not like you're doing it for some petty reason, like, say..."

		local noResetButton = false
		if  calleMemory.annoyance > 0  then
			finalText = finalText.."<page>You feel guilty for upsetting her, or you just want her to keep being nice to you."
			noResetButton = true

		elseif  calleMemory.losses > calleMemory.wins  then
			finalText = finalText.."<page>You want to erase all traces of some embarassing losses."
			noResetButton = true

		else
			finalText = finalText.."<page>You like maintaining a certain level of control over your peers.<page>You're not the type to manipulate those close to you, right?"
		end

		finalText = finalText.."<page>But hey, I get it.  Maybe you're just here to enjoy a silly action platformer game, and you've already had your fill of video games guilt-tripping you.<page>These aren't real people, right?  They don't have free will, they're all just fictional characters following pre-programmed routines.  So why should you care about them?<page>So, from one NPC to another...<page>...have a nice day and a clear conscience!"

		if  noResetButton  then
			finalText = finalText..[[<page>You can't undo stuff like that in real life, you know.  As the old cliche goes, "there's no reset button."]]
		end

		message.showMessageBox {target=talker, type="bubble", text=finalText}
		message.waitMessageEnd()

		SaveData.calleMemory = {}

	else
		message.showMessageBox {target=talker, type="bubble", text="Okie-dokie, then!  Have a nice day and a clear conscience!"}
		message.waitMessageEnd()
	end

	scene.endScene()
	message.endMessage();
end

message.presetSequences.startRace = function(args)
	-- Initialize calleoca's memory
	initCalleMemory()

	ACTOR_CALLEOCA:ToActor()

	if  calleMemory.annoyance > 0  then
		if  calleMemory.annoyance > 1  then
			ACTOR_CALLEOCA : Talk{text="You know, I'm tempted to just let you keep your normal damage system...<page>But the guy who made this level doesn't want to put in the extra effort.  He'd rather just write more dialogue branches."}
			message.waitMessageEnd()
		end
		ACTOR_CALLEOCA : Talk {text="Poof.  You can't be killed now.  Yay for you."}
		message.waitMessageEnd()
		ACTOR_CALLEOCA.direction = DIR_RIGHT

	else
		local finalText = ""
		if  calleMemory.attempts > 0  then
			ACTOR_CALLEOCA : Talk {text="Hey there!  Ready for a rematch?"}
			message.waitMessageEnd ()

		else
			ACTOR_CALLEOCA : Talk {text="<wave>Heeeeeey</wave>, guess what's at the end of this spooky, flooded, baddie-infested cave?<page>That's right, a leek!  Ya wanna race for it?"}
			message.waitMessageEnd ()

			eventu.waitSeconds (0.5)
			ACTOR_CALLEOCA.directionMirror = true
			ACTOR_CALLEOCA : Pose ("happy")

			ACTOR_CALLEOCA : Talk {text="...okay, I mean, it's not like you have a choice in the matter, just, you know, figured I should ask anyway!"}
			message.waitMessageEnd ()

			ACTOR_CALLEOCA.directionMirror = false

			ACTOR_CALLEOCA : Talk {text="<shake box>Don't worry, though!  I'll share a bit of my magical anime powers with you to make this more of a fair competition!"}
			message.waitMessageEnd ()
		end

		-- Magic animu powers
		local i = 15
		math.randomseed( os.time() )

		while (i > 0)  do
			Audio.playSFX (Misc.resolveFile("sound\\zelda-sword-beam.ogg"))
			ACTOR_CALLEOCA.speedY = -2.5
			ACTOR_CALLEOCA : Pose ("spin")
			Animation.spawn(131, ACTOR_CALLEOCA.x + math.random (-12,12), ACTOR_CALLEOCA.y + math.lerp (ACTOR_CALLEOCA.y, player.y + player.height - 16, math.random(0,1)))
			i = i -1
			eventu.waitSeconds (0.25)
		end
		ACTOR_CALLEOCA : Pose ("idle")
		eventu.waitSeconds (1)


		-- Explanation of the mechanics
		if  calleMemory.attempts > 0  then
			ACTOR_CALLEOCA : Talk {text="Again, you can't be killed but enemies can still knock you back."}
			message.waitMessageEnd ()
			eventu.waitSeconds (0.5)
			ACTOR_CALLEOCA.direction = DIR_RIGHT

			ACTOR_CALLEOCA : Talk {text="Okay, let's get started!"}
			message.waitMessageEnd ()

		else
			ACTOR_CALLEOCA : Talk {text="There we go!  You won't take any lasting damage, but hits will still stun you and probably knock you back!<page>Now you have no excuse to not finish the race!  So I'll be waiting for you at the finish line, <wave>m'kay?</wave>"}
			message.waitMessageEnd ()

			eventu.waitSeconds (0.5)
			ACTOR_CALLEOCA.direction = DIR_RIGHT

			ACTOR_CALLEOCA : Talk {text="Okie dokie, then... <shake box>on the count of 3!"}
			message.waitMessageEnd ()
		end
	end

	message.endMessage()
	scene.endScene()

	eventu.run(cor_countdown)
end

local function cor_winRace()
end

local function cor_loseRase()
end

message.presetSequences.postRace = function(args)
end