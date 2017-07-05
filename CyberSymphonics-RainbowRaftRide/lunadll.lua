function onLoop()
	for  k,v in pairs(NPC.get(194, -1))  do
	v:mem(0x24, FIELD_WORD, 0);

	end
end

function onLoad()
	if (player.isValid) then
		if(player.powerup == PLAYER_SMALL) then
			player.powerup = PLAYER_BIG
		end
	end
end