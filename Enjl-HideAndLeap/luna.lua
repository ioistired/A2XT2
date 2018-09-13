local eventu = API.load("eventu")
local timer = API.load("timer")
local checkpoints = API.load("checkpoints")
local scene = API.load("a2xt_scene")
local message = API.load("a2xt_message")
local leveldata = API.load("a2xt_leveldata")
local cman = API.load("cameraman")

local cp_rao = checkpoints.create{x=-139936, y=-140256, section = 3}	
local cp_kood = checkpoints.create{x=-119936, y=-120256, section = 4}

local holdRight = false
local holdRightHard = false
local holdLeft = false

timer.setSecondLength(30)

local cb = Graphics.CaptureBuffer(800, 600)

local fadeAmount = 0
local fadeMeanwhile = 0

local meanwhileImg = Graphics.loadImage("meanwhile.png")

local function startAsRao()
	player.powerup = 2
	for i=1, 80 do
		fadeMeanwhile = math.min(fadeMeanwhile + 0.02, 1)
		eventu.waitFrames(1)
	end
	eventu.waitFrames(50)
	fadeAmount = 1.25
	for i=1, 15 do
		fadeAmount = math.min(fadeAmount - 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile - 0.02, 1)
		eventu.waitFrames(1)
	end
	holdRight = true
	for i=1, 65 do
		fadeAmount = math.min(fadeAmount - 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile - 0.02, 1)
		eventu.waitFrames(1)
	end
	holdRight = false
	message.showMessageBox {target=player, text="I should be able to find a good hiding spot somewhere around here. I gotta hurry though, since Demo easily gets impatient when she's the seeker."}
	message.waitMessageEnd()
	Audio.MusicPlay()
	timer.activate(400)
	scene.endScene();
end

local function startAsKood()
	player.powerup = 2
	holdRight = true
	eventu.waitFrames(65)
	holdRight = false
	message.showMessageBox {target=player, text="Of course he would destroy everything in his path! Typical. Well, I'll look for a spot in the other direction then!"}
	message.waitMessageEnd()
	Audio.MusicPlay()
	timer.activate(320)
	player.direction = -1
	scene.endScene();
end

local function raoTransition()
	Graphics.drawScreen{texture=cb, priority=10}
	player:mem(0xD0,FIELD_DFLOAT, 50)
	timer.toggle(false)
	local cam = cman.playerCam[1]
	player.direction = -1
	player.powerup = 2
	cam.targets={}
	Audio.MusicStopFadeOut(500)
	local camx = -159068
	local camy = -160224
	cam.x = camx;
	cam.y = camy;
	cam.zoom = 1.5
	holdLeft = true
	eventu.waitFrames(85)
	cam:Queue{time=2, zoom=1.3, x=-159368}
	eventu.waitFrames(85)
	holdLeft=false
	eventu.waitFrames(30)
	message.showMessageBox {target=player, text="Oh! This spot should be good!"}
	message.waitMessageEnd()
	eventu.waitFrames(5)
	fadeMeanwhile = -0.25
	for i=1, 80 do
		fadeAmount = math.min(fadeAmount + 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile + 0.02, 1)
		eventu.waitFrames(1)
	end
	eventu.waitFrames(50)
	cp_rao:collect()
	player.x = cp_rao.x
	player.y = cp_rao.y
	player.section = 3
	fadeAmount = 1.25
	cam.targets={player}
	cam.zoom = 1
	player:transform(3)
	eventu.run(startAsKood)
	for i=1, 80 do
		fadeAmount = math.min(fadeAmount - 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile - 0.02, 1)
		eventu.waitFrames(1)
	end
end

local function startAsIris()
	player.powerup = 2
	holdRight = true
	eventu.waitFrames(65)
	holdRight = false
	message.showMessageBox {target=player, text="Kood is probably gonna just bump right into Demo. At this rate, getting the chicken wing should be easy!"}
	message.waitMessageEnd()
	Audio.MusicPlay()
	timer.activate(240)
	scene.endScene();
end

local function koodTransition()
	timer.toggle(false)
	local cam = cman.playerCam[1]
	Audio.MusicStopFadeOut(500)
	holdLeft = true
	for i=1, 35 do
		cam.zoom = cam.zoom + 0.01
		eventu.waitFrames(1)
	end
	eventu.waitFrames(120)
	holdLeft=false
	eventu.waitFrames(30)
	message.showMessageBox {target=player, text="Finally a piece of foliage voluminous enough to hide your average turtle!"}
	message.waitMessageEnd()
	eventu.waitFrames(5)
	holdLeft = true
	fadeMeanwhile = -0.25
	for i=1, 80 do
		fadeAmount = math.min(fadeAmount + 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile + 0.02, 1)
		eventu.waitFrames(1)
	end
	holdLeft = false
	eventu.waitFrames(50)
	cp_kood:collect()
	player.x = cp_kood.x
	player.y = cp_kood.y
	player.section = 4
	fadeAmount = 1.25
	cam.zoom = 1
	player:transform(2)
	eventu.run(startAsIris)
	for i=1, 80 do
		fadeAmount = math.min(fadeAmount - 0.02, 1)
		fadeMeanwhile = math.min(fadeMeanwhile - 0.02, 1)
		eventu.waitFrames(1)
	end
end

local function endLevel()
	timer.toggle(false)
	while player.x < -111488 do
		eventu.waitFrames(1)
	end
	player:mem(0x122, FIELD_WORD, 0)
	SFX.play(22)
	player.speedX = 9
	player.speedY = -15
	notIrisd = false
	local cam = cman.playerCam[1]
	Audio.MusicStopFadeOut(500)
	holdRightHard = true
	eventu.waitFrames(65)
	for i=1, 40 do
		fadeAmount = math.min(fadeAmount + 0.025, 1)
		eventu.waitFrames(1)
	end
	holdRightHard = false
	player.section = 6
	player.direction = 1
	player.x = -79648
	player.y = -80704
	player.speedX = 0
	cam.targets = {}
	cam.x = -79500
	cam.y = -80154
	cam.zoom = 1.25
	player.powerup = 2
	for i=1, 40 do
		fadeAmount = math.min(fadeAmount - 0.025, 1)
		player.speedY = -1
		eventu.waitFrames(1)
	end
	for i=1, 50 do
		player.speedY = -1
		eventu.waitFrames(1)
	end
	eventu.waitFrames(65)
	message.showMessageBox {target=player, text="Blame actors."}
	message.waitMessageEnd()
	eventu.waitFrames(5)
	Level.winState(4)
	for i=1, 50 do
		fadeAmount = math.min(fadeAmount + 0.02, 1)
		eventu.waitFrames(1)
	end
end

function onStart()
	Audio.MusicOpen("dont let her find you.ogg")
	Audio.SeizeStream(-1)
	
	if cp_kood.collected then
		player:transform(2)
		scene.startScene{scene=startAsIris}
	elseif cp_rao.collected then
		player:transform(3)
		scene.startScene{scene=startAsKood}
	else
		player:transform(4)
		fadeAmount = 1
		scene.startScene{scene=startAsRao}
	end
end


local exitState = nil;

function onTick()
	if holdLeft then
		player.leftKeyPressing = true
		player.runKeyPressing = false
	end
	if holdRight then
		player.rightKeyPressing = true
		player.runKeyPressing = false
	end
	if holdRightHard then
		player.rightKeyPressing = true
		player.runKeyPressing = false
		player.speedX = 14
		player.speedY = math.min(0, player.speedY)
	end
	
	if(player:mem(0x13E, FIELD_WORD) > 0) then
		exitState = false;
	elseif(Level.winState() > 0) then
		exitState = true;
	else
		exitState = nil;
	end
end

local notKooded = true
local notIrisd = true

function onTickEnd()
	if player.section == 1 and player:mem(0x122, FIELD_WORD) == 3 then
		cb:captureAt(9)
	end
	
	if notKooded and player.section == 5 and player.x < -101824 then
		scene.startScene{scene=koodTransition}
		notKooded = false
	end
	
	if notIrisd and player.section == 4 and player:mem(0x122, FIELD_WORD) == 3 then
		scene.startScene{scene=endLevel}
		notIrisd = false
	end
	if player.deathTimer > 0 then
		Audio.MusicStop()
	end
end

function onDraw()
	if fadeAmount > 0 then
		Graphics.drawScreen{color = {0,0,0,fadeAmount}, priority=6}
		Graphics.drawImageWP(meanwhileImg, 0, 0, fadeAmount * fadeMeanwhile, 7)
	end
end

function onLoadSection2()
	scene.startScene{scene=raoTransition}
end

function onExitLevel()	
	if(SaveData.currentTutorial ~= nil)  then
		if(exitState == false) then
			leveldata.LoadLevel(Level.filename());
		elseif(exitState == true) then
			SaveData.currentTutorial = "Hoeloe-TheGirlWhoLeaptThroughTime.lvl";	
			Misc.saveGame();
			leveldata.LoadLevel(SaveData.currentTutorial);
		end
	end
end