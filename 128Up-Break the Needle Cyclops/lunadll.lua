local JumpCounter = 1
local previousPlayerOnGround = true
local secondPreviousPlayerOnGround = true
local doubleJumpActive = false

local SECOND_JUMP_TIMER = 15 -- length of second jump in frames
local currentTimer = 0

local playerSpawnX = 0;
local playerSpawnY = 0;
local deathX = 0;
local deathY = 0;
local amountOfDeaths = 0

local butts = Graphics.loadImage(Misc.resolveFile("npc-251.png"))

local tableOfKillers = {60,62,64,66,79,80,81,82}

function onLoad()
	if (player.isValid) then
		player:mem(0xF0,FIELD_WORD,1)
		player:mem(0x108,FIELD_WORD,0)
		player:mem(0x112,FIELD_WORD,0)
		player:mem(0x158,FIELD_WORD,0)
	end
end

function onLoadSection()
	playerSpawnX = player.x;
	playerSpawnY = player.y;
end

function spawnDeadDemo()
	deathX = player.x;
	deathY = player.y;
	player.speedX = 0;
	player.speedY = 0;
	if deathX ~= playerSpawnX and deathX ~= playerSpawnY then
		demo = NPC.spawn(145, deathX, deathY, player.section)
		demo.speedX = 0;
		demo.speedY = -10;
		amountOfDeaths = amountOfDeaths + 1;
	end
end

function onHUDDraw()
	-- death counter
	Text.print("TOTAL DEATHS: " .. tostring(amountOfDeaths),275,0)
end
 
function onKeyDown(keycode)
	if (JumpCounter > 0) and keycode == KEY_JUMP and not secondPreviousPlayerOnGround then
		JumpCounter = JumpCounter - 1
		doubleJumpActive = true
	end
end
 
function onLoop()
	for k,v in pairs(NPC.get(145,player.section)) do
		v:mem(0x46,FIELD_WORD,-1)
	end
	for k,v in pairs(NPC.get(tableOfKillers,player.section)) do
		v:mem(0x46,FIELD_WORD,-1)
	end
	if player:mem(0x146, FIELD_WORD) == 2 then
		JumpCounter = 1
		currentTimer = 0
	end
	if JumpCounter == 0 and doubleJumpActive and currentTimer < SECOND_JUMP_TIMER then
		player.speedY = -5 --speed of second jump
		currentTimer = currentTimer + 1
		if currentTimer == 1 then
			Audio.playSFX("sndDJump.ogg")
		end
	end
	if not player.jumpKeyPressing then
		doubleJumpActive = false
	end

	secondPreviousPlayerOnGround = previousPlayerOnGround
	previousPlayerOnGround = (player:mem(0x146, FIELD_WORD) == 2)
end

function onEvent(eventname)
	if eventname == "set death point" then
		playerSpawnX = player.x
		playerSpawnY = player.y
	end
end

function onInputUpdate()
	for _, v in pairs(NPC.getIntersecting(player.x + 8, player.y + 8, player.x + player.width - 8, player.y + player.height - 8)) do
		if v.id == 60 or v.id == 62 or v.id == 64 or v.id == 66 or v.id == 79 or v.id == 80 or v.id == 81 or v.id == 82 then
			spawnDeadDemo()
			Audio.playSFX("sndDeath.ogg")
			player.x = playerSpawnX;
			player.y = playerSpawnY;
		end
	end
end

function onNPCKill(eventObj,npcID,killReason)
	if npcID.id == 252 then
		Graphics.placeSprite(2,butts,npcID.x,npcID.y)
	end
end