local tableOfCharacterBlocks = {626, 627, 628, 629, 632}

function onTick()
	for _,a in ipairs(Block.get(tableOfCharacterBlocks)) do
		a.id = tableOfCharacterBlocks[player.character]
	end
	
	for _, v in ipairs(NPC.get(122,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
	end
end

function onStart()
	_G["ManualTitle"] = "I Sawed the Deamond"
	_G["ManualArtist"] = "Robert Prince"
	_G["ManualAlbum"] = "Doom"
end