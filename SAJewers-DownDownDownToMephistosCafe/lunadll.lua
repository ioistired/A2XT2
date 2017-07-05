function onLoop()


	for  k,v in pairs(NPC.get(29, -1))  do
	    --NPC:mem(Address, Data type, Value);
		v.speedY = 0;
	end

	for  k,v in pairs(NPC.get(30, -1))  do
		v:mem(0xE2,FIELD_WORD,147);

	end
end

