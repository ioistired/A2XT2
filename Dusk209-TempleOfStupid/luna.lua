function onTick()
	--Prevent platform goopa from despawning
	if(player.section == 2) then
		for _,v in ipairs(NPC.get(118, 2)) do
			v:mem(0x12A, FIELD_WORD, 180);
		end
	end
end