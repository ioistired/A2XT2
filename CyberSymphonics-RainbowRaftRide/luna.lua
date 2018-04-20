function onTick()
	for  k,v in ipairs(NPC.get(194, -1))  do
		v:mem(0x24, FIELD_WORD, 0);
	end
end

function onStart()
	if(player.powerup == PLAYER_SMALL) then
		player.powerup = PLAYER_BIG
	end
end