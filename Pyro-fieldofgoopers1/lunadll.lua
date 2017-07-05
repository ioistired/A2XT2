function onLoop()
	butts = NPC.get(176,4)
	if player.section == 4 then
		for _,v in pairs(butts) do
			v:mem(0x12A,FIELD_WORD,180)
		end
	end
	if player:mem(0xF0,FIELD_WORD) == 5 then
		player:mem(0xF0,FIELD_WORD,1)
	end
end