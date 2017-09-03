function onLoad()
--Filter out Hammer
	if (player.isValid) then
		if (player.powerup == PLAYER_HAMMER) then
        player.powerup = PLAYER_BIG;
		end
	end
--Remove Mount	
	if (player.isValid) then
	player:mem(0x108, FIELD_WORD, 0)
	end
--Filter to Demo
	if (player.isValid) then
    player:mem(0xF0, FIELD_WORD, 1)
	end
end

function onLoop()
--Filter out Reserve Hammer
	if (player.isValid) then
		if (player.reservePowerup == 170) then
        player.reservePowerup = 34;
		end
	end
end