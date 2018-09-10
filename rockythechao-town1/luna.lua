local particles = API.load ("particles")
local paralx2   = API.load("paralx2");

local cman      = API.load ("cameraman")

local sanctuary = API.load("a2xt_leeksanctuary");
local costumes  = API.load ("a2xt_costumes")
local scene     = API.load ("a2xt_scene")
local message   = API.load ("a2xt_message")
local eventu    = API.load ("eventu")



sanctuary.world = 1;
sanctuary.sections[4] = true



for  _,v in pairs{"DEMO","IRIS","KOOD","RAOCOW","SHEATH"}  do
	costumes.unlock (v.."_TEMPLATE")
end


--*************************
--** CONSTANTS AND ENUMS **
--*************************

-- Background images
local bgKitchenImage = Graphics.loadImage("kitchen.png")

-- Foreground images
local fgTreeImage = Graphics.loadImage("fgTreesNoGrass.png")
local fgGrassImage = Graphics.loadImage("fgGrass.png")
local fgShadowImage = Graphics.loadImage("fgShadow.png")

local parallaxFg = paralx2.Background(1, 
  {left = -200580, top = -200900, right=-194700, bottom=-200000},
  {img=Graphics.loadImage("fgTreesNoGrass.png"), depth = -20, priority = -2.1, alignY = paralx2.align.BOTTOM, x = -100, y = 0,  repeatX = true},
  {img=Graphics.loadImage("fgGrass.png"),        depth = -40, priority = -2,   alignY = paralx2.align.BOTTOM, x = 0,    y = 72, repeatX = true});
parallaxFg.section = 0;

parallaxFg.fillColor = Color.alphablack;



--*************************
--** COROUTINE SEQUENCES  *
--*************************
message.presetSequences.sportsball = function(args)
	local talker = args.npc

	message.promptChosen = false
	while  not message.promptChosen  or  (message.promptChoice ~= 1  and  message.promptChoice ~= 3)  do
		message.promptChosen = false
		message.showMessageBox {target=talker, text=message.quickparse("Hey there, [gal/gal/guy/guy/gal]!  Wanna basket some sportsball?"), closeWith="prompt"}
		message.waitMessageDone()

		message.showPrompt{options={message.getYesOption(),"How do I play?",message.getNoOption()}}
		message.waitPrompt()

		if  message.promptChoice == 2  then
			message.showMessageBox {target=talker, text="It's simple, if you get the ball into your opponent's hoop you get a point.<page>When the timer runs out, the player with the most points wins.<page>Also, to make things interesting we encourage audience participation.  So, uh, don't be too surprised if someone hurls something onto the court."}
			message.waitMessageEnd()
		end
	end
	if  message.promptChoice == 1  then
		message.showMessageBox {target=talker, text="Well, tough luck!  This minigame's not done yet!"}
		message.waitMessageEnd()
	end
	if  message.promptChoice == 3  then
		message.showMessageBox {target=talker, text="Arrighty then.  Have a <wave>sportstacular</wave> day!"}
		message.waitMessageEnd()
	end
	
	eventu.waitSeconds(0.1)

	scene.endScene()
end

message.presetSequences.chefQuest = function(args)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="Oh, woe is moi! Whatever shallot do!?", closeWith="prompt"}
	message.waitMessageDone()

	message.showPrompt{options={"What's wrong?","*Ignore him*"}}
	message.waitPrompt()

	if  message.promptChoice == 1  then
		message.promptChosen = false
		message.showMessageBox {target=talker, text="Zis upcoming banquet is mon debut in ze world of 'igh cuisine!<page>I've done everyzing I can in preparation so I can make a big impact:<page>I renovated zis restaraunt, I downloaded ze best recipes from ze food network...<page>I even taught myzelf zis cheesy French accent for auzenticity!<page>But I still knead ze ingredients for ze piece de resistance: mon fruit salad a la mode!<page>Wizout enough of Muffin Bluff's berries, ze dish will be incomplete and all mon effort will be for naught!<page>I would go get zem myzelf, but my body, it is not made for ze running and jumping.<page>If only I 'ad a fit, young "..message.perCharString("[mademoiselle/mademoiselle/damoiseau/damoiseau/mademoiselle]").." like vous to fetch zem for moi...", closeWith="prompt"}
		message.waitMessageDone()

		message.showPrompt{options={"How many?","Bummer. Well, good luck with that!"}}
		message.waitPrompt()
		
		if  message.promptChoice == 1  then
			message.showMessageBox {target=talker, text="Mon dieu, merci!  I need about ten of ze berries.<page>Be careful not to get 'urt while collecting zem, zey bruise quite easily and I need zem in top condition!"}
			message.waitMessageEnd()
		else
			message.showMessageBox {target=talker, text="Adieu.  Please let me know if you find anyone who could 'elp moi!"}
			message.waitMessageEnd()
		end
	end

	scene.endScene()
end

message.presetSequences.revealBase = function(args)
	args.npc.data.name = "Reveal the secret entrance again"

	Audio.SeizeStream(-1)
	Audio.MusicPause()
	playSFX(28)
	eventu.waitSeconds (1)

	playSFX(25)
	scene.quake = 10
	scene.setTint {time=0.5, color=0x000000FF}
	eventu.waitSeconds (0.5)

	triggerEvent("Goopinati Wall Reveal")
	eventu.waitSeconds (0.5)

	scene.quake = 0

	scene.setTint {time=0.5, color=0x00000000}
	eventu.waitSeconds (1.0)

	scene.endScene()
	baseRevealed = true
	baseRevealTimes = baseRevealTimes + 1
end

message.presetSequences.lookatthatdog = function(args)
	local talker = args.npc
	local palnpc = NPC.get(985,-1)[1]
	local tempTargets = cman.playerCam[1].targets

	cman.playerCam[1]:Queue {time=0.5, targets={palnpc}, easeBoth=cman.EASE.QUAD}
	eventu.waitSeconds(0.5)

	message.showMessageBox {target=talker, text="Is that your puppy over there?  I'm so jealous!<page>I want a dog of my own, by my parents won't allow it because it'd dig up stuff around the house.", keepOnscreen=true}
	message.waitMessageEnd()

	cman.playerCam[1]:Queue {time=0.5, targets=tempTargets, easeBoth=cman.EASE.QUAD}
	eventu.waitSeconds(0.5)

	message.showMessageBox {target=talker, text="Well, <shake box> beans to that!<page><shake box>Don't let authority figures snuff out your starlight!  Together you can <shake box>DIG TO <tremble 0.5>INFINITY</tremble>!"}
	message.waitMessageEnd()
	scene.endScene()
end

message.presetSequences.baseguard = function(args)
	local talker = args.npc

	-- Base is currently hidden
	if  not baseRevealed  then
		if  baseRevealTimes == 0  then
			message.promptChosen = false
			message.showMessageBox {target=talker, text="Hello there, fellow law-abiding citizen!<page>What sort of completely legal merchandise can I get for you at our fine establishment that is not at all a cover-up for the hideout of a secret organization?<page>How about a delicious FURBATAIL?  It can be yours today for the low, low price of only 9,999,999,999,992 raocoins!", closeWith="prompt"}
			message.waitMessageDone()

			message.showPrompt()
			message.waitPrompt()

			if  message.promptChoice == 1  then
				message.showMessageBox {target=talker, text="Well, screw you t- wait, did you say YES?<page>Er, sorry, I just didn't expect... well, uh, never mind.  That'll be 9,999,999,999,992 raocoins!<page>Wait... OH, COME ON!<page>You should've just told me you didn't have that much money!  Thanks for getting my hopes up, jerk."}
				message.waitMessageEnd()
			end
			if  message.promptChoice == 2  then
				message.showMessageBox {target=talker, text="...No?  Then scram, I ain't got no time for window shoppers.<page>And whatever you do, don't go snooping around near that bookshelf behind me!<page>Because it's a completely normal bookshelf.  There's nothing strange about it and it'd be a total waste of your time to examine it.  I guarantee it."}
			end
		elseif  baseRevealTimes == 1  then
			message.showMessageBox {target=talker, text="Oh, it's you again.  Look, if you leave that bookshelf alone I'll go ahead and pretend nothing happened, okay?"}
		elseif  baseRevealTimes == 2  then
			message.showMessageBox {target=talker, text="Stop messing with the entrance to our secret base!  Closing it back up is a really tedious process."}
		else
			message.showMessageBox {target=talker, text="Please don't."}
		end


	-- Base is revealed
	else
		if  baseRevealTimes == 1  then
			message.showMessageBox {target=talker, text="Oh, hey, look at that!  I, uh, I wonder who put that secret room there huh? Ehehehehe...<page>...the boss is gonna have my shell on a stake for this."}
		elseif  baseRevealTimes == 2  then
			message.showMessageBox {target=talker, text="Again?  Ugh..."}
		else
			message.showMessageBox {target=talker, text="..."}
		end
	end

	message.waitMessageEnd()
	scene.endScene()
end

local function scene_Elevator ()
	Audio.MusicStop()

	eventu.waitSeconds(1)
	Audio.MusicOpen("Netarou Village Intro.ogg")
	Audio.MusicPlay()

	local timeAmt = 0
	while  (timeAmt < 7.5)  do
		Audio.MusicVolume(64 * (timeAmt/7.5))

		timeAmt = timeAmt + eventu.deltaTime
		eventu.waitFrames(0)
	end
	Audio.MusicStop()
end

local function scene_hideSecretRoom ()
	Audio.SeizeStream(-1)
	playSFX(28)
	eventu.waitSeconds (1)

	playSFX(25)
	scene.quake = 10

	triggerEvent("Goopinati Wall Hide")
	eventu.waitSeconds (1)

	scene.quake = 0
	eventu.waitSeconds (0.5)

	Audio.MusicResume()
	scene.endScene()
end

local function cor_catllama1 ()
	Audio.playSFX(Misc.resolveFile("yoshi-swallow.ogg"))
end


--********************
--** LOAF FUNCTIONS **
--********************
function onLoadSection0 ()
	if  baseRevealed  then
		baseRevealed = false
		scene.startScene{scene=scene_hideSecretRoom, sceneArgs={}}
	end
	--cinematX.runCutscene (cutscene_Calleoca)
end

function onEvent (eventName)
	if eventName == "Elevator Start"  then
		scene.startScene{scene=scene_Elevator, sceneArgs={}}
	end
	if eventName == "Dump Dialog"  then
		message.textLogToConsole()
	end
	if eventName == "Reset Chests"  then
		SaveData.chests = {}
	end
end


--********************
--** LOOP FUNCTIONS **
--********************

local fenceGfx = {}
fenceGfx[129] = Graphics.loadImage("background-129.png")
fenceGfx[130] = Graphics.loadImage("background-130.png")
fenceGfx[131] = Graphics.loadImage("background-131.png")


function onDraw ()
	-- Draw kitchen
	Graphics.draw  {type=RTYPE_IMAGE,
					image=bgKitchenImage,
					priority=-50.0,
					isSceneCoordinates=true,
					x=-179648, y=-180320}

	local fences = BGO.get({129,130,131})

	for k,v in pairs(fences) do
		
		Graphics.draw  {type=RTYPE_IMAGE,
						image=fenceGfx[v.id],
						priority=-38.0,
						isSceneCoordinates=true,
						x=v.x, y=v.y}
	end
end


baseRevealed = false
baseRevealTimes = 0
bookshelfActor = nil

do
	function onLoop ()
		local courtLeft = -159830 + 64
		local courtRight = -158859 - 88
	end
end

 
local snow = particles.Emitter(0, 0, Misc.resolveFile("particles/p_leaf.ini"), 1)
snow:AttachToCamera(Camera.get()[1]);

function onCameraUpdate()
	if  player.section == 0  then
		snow:Draw();
	end
end