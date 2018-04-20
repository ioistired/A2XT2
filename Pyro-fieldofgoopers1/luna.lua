function onTick()
	if player.section == 4 then
		for _,v in pairs(NPC.get(176,4)) do
			v:mem(0x12A,FIELD_WORD,180)
		end
	end
end