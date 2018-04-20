function onTick()
	for  k,v in ipairs(NPC.get(29, -1))  do
	    --NPC:mem(Address, Data type, Value);
		v.speedY = 0;
	end

	for  k,v in ipairs(NPC.get(30, -1))  do
		v:transform(147);
		v:mem(0xE2,FIELD_WORD,147);
	end
end

