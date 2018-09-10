local eventu = API.load("eventu")
local timer = API.load("timer")
local checkpoints = API.load("checkpoints")
local scene = API.load("a2xt_scene")
local message = API.load("a2xt_message")

local cp_rao = checkpoints.create{x=-179936, y=-180256, section = 1}	
local cp_kood = checkpoints.create{x=-159936, y=-160256, section = 2}

local holdRight = false

local function startAsRao()
	player.powerup = 2
	holdRight = true
	eventu.waitFrames(65)
	holdRight = false
	message.showMessageBox {target=player, text="I should be able to find a good hiding spot somewhere around here. I gotta hurry though, since Demo easily gets impatient when she's the seeker."}
	message.waitMessageEnd()
	playMusic(1)
	timer.activate(400)
	scene.endScene();
end

local function startAsKood()
	player.powerup = 2
	eventu.waitFrames(65)
	holdRight = false
	message.showMessageBox {target=player, text="Of course he would destroy everything in his path! Typical. Well, I'll look for a spot in the other direction then!"}
	message.waitMessageEnd()
	playMusic(1)
	timer.activate(320)
	scene.endScene();
end

local function startAsIris()
	player.powerup = 2
	eventu.waitFrames(65)
	holdRight = false
	message.showMessageBox {target=player, text="Kood is probably gonna just bump right into Demo. At this rate, getting the chicken wing should be easy!"}
	message.waitMessageEnd()
	playMusic(1)
	timer.activate(240)
	scene.endScene();
end

function onStart()
	if cp_kood.collected then
		player:transform(2)
		scene.startScene{scene=startAsIris}
	elseif cp_rao.collected then
		player:transform(3)
		scene.startScene{scene=startAsKood}
	else
		player:transform(4)
		scene.startScene{scene=startAsRao}
	end
end

function onTick()
	if holdRight then
		player.rightKeyPressing = true
		player.runKeyPressing = false
	end
end