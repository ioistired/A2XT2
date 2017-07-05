local playerSpawnX = 0;
local playerSpawnY = 0;
local deathX = 0;
local deathY = 0;
local amountOfDeaths = 0;
local playerOnUpConveyor = false;

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

function friendlyEnemy(npcID)
	for k,v in pairs(NPC.get(npcID,-1)) do
		v:mem(0x46,FIELD_WORD,-1)
		v:mem(0x12A,FIELD_WORD,180)
	end
end

function onInputUpdate()
	-- wall slide technique
	if playerOnUpConveyor == false then
	if player.leftKeyPressing ~= 0 then
		if player:mem(0x148,FIELD_WORD) == 2 and player:mem(0xFA,FIELD_WORD) == 0 and player:mem(0xFC,FIELD_WORD) == 0 then
			player.speedY = 1;
		end
	end
	if player.rightKeyPressing ~= 0 then
		if player:mem(0x14C,FIELD_WORD) == 2 and player:mem(0xFA,FIELD_WORD) == 0 and player:mem(0xFC,FIELD_WORD) == 0 then
			player.speedY = 1;
		end
	end
	end
	-- respawning
	for _, v in pairs(NPC.getIntersecting(player.x + 8, player.y + 8, player.x + player.width - 8, player.y + player.height - 8)) do
		if v.id == 1 or v.id == 2 or v.id == 260 or v.id == 179 or v.id == 206 then
			spawnDeadDemo()
			player.x = playerSpawnX;
			player.y = playerSpawnY;
			playSFX(54)
		end
		if v.id == 246 and player:mem(0x140, FIELD_WORD) == 0 then
			spawnDeadDemo()
			player.x = playerSpawnX;
			player.y = playerSpawnY;
			player:mem(0x140, FIELD_WORD, 160)
			playSFX(54)
		end
	end
	for _, b in pairs(BGO.getIntersecting(player.x + 12, player.y + 12, player.x + player.width - 12, player.y + player.height - 12)) do
		if b.id == 99 or b.id == 158 or b.id == 159 then
			spawnDeadDemo()
			player.x = playerSpawnX;
			player.y = playerSpawnY;
			playSFX(54)
		end
	end
	for _, q in pairs(Block.getIntersecting(player.x-4, player.y-4, player.x + player.width + 4, player.y + player.height + 4)) do
		if q.id == 1 or q.id == 16 or q.id == 110 or q.id == 9 or q.id == 10 or q.id == 11 or q.id == 12 or q.id == 13 or q.id == 14 or q.id == 18 or q.id == 15 or q.id == 16 or q.id == 17 or q.id == 3 or q.id == 29 or q.id == 9 or q.id == 459 or q.id == 460 or q.id == 461 or q.id == 462 or q.id == 463 or q.id == 464 or q.id == 465 or q.id == 466 or q.id == 467 or q.id == 468 or q.id == 469 or q.id == 470 or q.id == 471 then
			spawnDeadDemo()
			player.x = playerSpawnX;
			player.y = playerSpawnY;
			playSFX(54)
		end
		if q.id == 530 then
			player.speedY = player.speedY - 0.35;
			playerOnUpConveyor = true;
		else
			playerOnUpConveyor = false;
		end
	end
	--459 471
	-- automatically make certain enemies always friendly, to prevent their killing
	friendlyEnemy(1)
	friendlyEnemy(2)
	friendlyEnemy(260)
	friendlyEnemy(246)
	friendlyEnemy(145)
	friendlyEnemy(179)
	friendlyEnemy(206)
	-- activate spikes
	for k,v in pairs(NPC.get(285,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
	end
end

function onHUDDraw()
	-- death counter
	Text.print("TOTAL DEATHS: " .. tostring(amountOfDeaths),275,0)
end

function onKeyDown(keycode)
	-- wall jump!
	if keycode == KEY_JUMP then
		if player:mem(0x148,FIELD_WORD) == 2 then
			player.speedX = 3;
			player.speedY = -10;
			playSFX(9)
			player:mem(0x50,FIELD_WORD,1)
		elseif player:mem(0x14C,FIELD_WORD) == 2 then
			player.speedX = -3;
			player.speedY = -10;
			playSFX(9)
			player:mem(0x50,FIELD_WORD,1)
		end
	end
	-- spin wall jump!
	if keycode == KEY_SPINJUMP then
		if player:mem(0x148,FIELD_WORD) == 2 then
			player.speedX = 12;
			player.speedY = -7;
			playSFX(22)
			player:mem(0x50,FIELD_WORD,-1)
		elseif player:mem(0x14C,FIELD_WORD) == 2 then
			player.speedX = -12;
			player.speedY = -7;
			playSFX(22)
			player:mem(0x50,FIELD_WORD,-1)
		end
	end
end

function onEvent(eventname)
	if eventname == "set death point" then
		playerSpawnX = player.x
		playerSpawnY = player.y
	end
end