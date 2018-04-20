function onTick()
	if(player:mem(0x56, FIELD_WORD) > 8) then
		player:mem(0x56, FIELD_WORD, 0)
	end
end 