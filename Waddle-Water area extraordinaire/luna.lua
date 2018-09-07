function onTick()
	for k,v in ipairs (NPC.get(231)) do
		v:mem(0x1C,FIELD_WORD,2)
	end
end