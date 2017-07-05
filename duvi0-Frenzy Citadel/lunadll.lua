function onStart()
	if (player == isValid) then
		if (player.character == 5) then
			player:mem(0xF0, FIELD_WORD, 1)
		end
	end
end
